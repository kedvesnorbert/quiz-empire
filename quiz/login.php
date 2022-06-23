<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_login.php");
require_once("includes/ip_functions.php");
require_once("view/view_login.php");
require_once("includes/responses.php");

function checkRegistration()
{
	if (isset($_POST["reg"]))
	{
		$_POST['fullname'] = addslashes($_POST['fullname']);
        $mindenok = true;
		if (empty($_POST["fullname"]) || empty($_POST["email"]) || empty($_POST["userR"]) || empty($_POST["pw"]) || empty($_POST["pw2"]))
		{
			?><script>alert("Minden mezőt kötelező kitölteni!!");</script><?php
			$mindenok = false;
		}
        
        if(!preg_match("/(\w.+\s).+/", $_POST['fullname']))
        {
            ?><script>alert("A vezetéknév és keresztnév megadása kötelező!!");</script><?php
			$mindenok = false;
        }
        
        if(!preg_match('/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/', $_POST['email']))
        {
            ?><script>alert("Kérjük helyes email-címet adjon meg!!");</script><?php
			$mindenok = false;
        }
        
        if(strlen($_POST['userR'])< 4 || strlen($_POST['userR'])>25)
        {
            ?><script>alert("A felhasználónév hossza 4 és 25 karakter között lehet!!");</script><?php
			$mindenok = false;
        }
        
        if(!preg_match("/^[a-zA-Z0-9]*$/", $_POST['userR']))
        {
            ?><script>alert("A felhasználónév csak betűket és számjegyeket tartalmazhat!!");</script><?php
			$mindenok = false;
        }
        
        if(strlen($_POST['pw'])< 6 || strlen($_POST['pw'])>100)
        {
            ?><script>alert("A jelszó hossza 6 és 100 karakter között lehet!!");</script><?php
			$mindenok = false;
        }
        
        if(!preg_match("/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,100}$/", $_POST['pw']) || !preg_match("/^\S*$/", $_POST['pw']))
        {
            ?><script>alert("A jelszó tartalmazzon kis-és nagybetűket, legalább 1 számjegyet<br>és ne legyen benne szóköz!!!");</script><?php
			$mindenok = false;
        }
        
		if ($_POST["pw"] != $_POST["pw2"])
		{
			?><script>alert("Nem talál a két jelszó!!");</script><?php
			$mindenok = false;
		}
		if ($mindenok)
		{
			$password = hash("sha512", $_POST['pw']);
			$con = connect();
			if(!$con)
			{
				return false;
			}
			$res = mysqli_query($con, "SELECT registration('" . mysqli_real_escape_string($con, $_POST['fullname']) . "', '" . mysqli_real_escape_string($con, $_POST['email']) . "', '" . mysqli_real_escape_string($con, $_POST['userR']) . "', '" . mysqli_real_escape_string($con, $password) . "') AS eredmeny");
			mysqli_close($con);
			
			if(!$res)
			{
				?><script>alert("Hiba történt. Próbáld újra később!");</script><?php
			}
			else
			{
				$row = mysqli_fetch_assoc($res);
				if($row['eredmeny'] == "ok")
				{
					$_POST["fullname"] =  $_POST["userR"] = $_POST["email"] = "";
					?><script>alert("A regisztrálás sikerült. Be lehet jelentkezni.");</script><?php
				}
				else
				{
					$kiir = $row['eredmeny'];
					?><script>alert('<?php echo $kiir; ?>');</script><?php
				}
			}
		}
	}
}

function checkLogin()
{
	if (isset($_POST["log"]))
	{		
		$deviceType = checkDevice();
		if($deviceType==0) 
		{
			$device = "DESKTOP";
		}
		else if ($deviceType==1)
		{
			$device = "PHONE OR MOBILE";
		}
		else
		{
			$device = "TABLET";
		}
		
		if (loginDataOK($_POST["user"], $_POST["pw"]))
		{
			$con = connect();
			if(!$con)
			{
				die(mysqli_connect_error());
			}
			$res = mysqli_query($con, "SELECT login('" . mysqli_real_escape_string($con, $_POST["user"]) . "', '" . mysqli_real_escape_string($con, hash("sha512", $_POST["pw"])) . "', '" . mysqli_real_escape_string($con, $device) . "') AS is_success");
			mysqli_close($con);
			
			if(!$res)
			{
				?><script>alert("Hibás felhasználónév vagy jelszó!!");</script><?php
			}
			else
			{
				$row = mysqli_fetch_assoc($res);
				if(strtotime($row['is_success']))
				{
					$res1 = db_getuserdata($_POST["user"]);
					if(!$res1)
					{
						?><script>alert("Hiba történt. Próbáld újra!");</script><?php
					}
					else
					{	
						if(isset($_POST['remember_logindata_checkbox']) && $deviceType != 0)
						{
							setcookie("uname", $_POST["user"]);
							setcookie("upw", $_POST["pw"]);
						}
						else
						{
							setcookie("uname", "", time() - 3600);
							setcookie("upw", "", time() - 3600);
						}
						
						$_SESSION = array();
						$row1 = mysqli_fetch_assoc($res1);
						$_SESSION["user"] = $row1["user"];
						$_SESSION["user_id"] = $row1['id'];
						$_SESSION["admin_user"] = $row1['adminuser'];
						$_SESSION['login_time'] = $row['is_success'];
						$date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
						$date_1 = $date->format('Y-m-d H:i:s');
						$date_1_1 = strtotime($date_1);
						$_SESSION["last_activity"] = $date_1_1;
						$_SESSION["lastvisit"] = $date_1_1;
						
						if($row1['is_quizstarted']> 0)
						{
							$con = connect();
							mysqli_query($con, "SET @result = '" . mysqli_real_escape_string($con, $row1['all_totalcorrect']) . "'");
							mysqli_query($con, "SET @score");
							mysqli_query($con, "CALL get_quiz_result(@result, '" . mysqli_real_escape_string($con, $row1['quizid']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', @score)");
							mysqli_close($con);
						}
						if(!isset($_COOKIE['fromwhere']) || !is_valid_url($_COOKIE['fromwhere']))
						{
							header("location:index.php");
						}
						else
						{
							header("location:" . urldecode($_COOKIE['fromwhere']));
						}
					}
				}
				else
				{
					?><script>alert("<?php echo $row['is_success']; ?>");</script><?php
				}
			}
			
		}
		else
		{
			$con = connect();
			if(!$con)
			{
				die(mysqli_connect_error());
			}
			$res = mysqli_query($con, "SELECT login('" . mysqli_real_escape_string($con, $_POST["user"]) . "', '" . mysqli_real_escape_string($con, hash("sha512", $_POST["pw"])) . "', '" . mysqli_real_escape_string($con, $device) . "') AS is_success");
			mysqli_close($con);
			?><script>alert("Hibás felhasználónév vagy jelszó!!");</script><?php
		}
	}
}

function loginDataOK($user, $pw)
{
	if(strlen($user) < 3 || strlen($user) > 60)
	{
		return false;
	}	
	if(!preg_match("/^[a-zA-Z0-9]*$/", $user) && !preg_match('/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/', $user))
	{
		return false;
	}
	if(strlen($pw)< 6 || strlen($pw)>100)
	{
		return false;
	}	
	if(!preg_match("/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,100}$/", $pw) || !preg_match("/^\S*$/", $pw))
	{
		return false;
	}
	return true;
}

function current_season() {
	$icons = array(
		"spring" => "documents/images/regimg_spring.jpg",
		"summer" => "documents/images/regimg.jpg",
		"autumn" => "documents/images/regimg_fall.jpg",
		"winter" => "documents/images/regimg_winter.jpg");

	$day = date("z");

	$spring_starts = date("z", strtotime("March 21"));
	$spring_ends   = date("z", strtotime("June 14"));

	$summer_starts = date("z", strtotime("June 15"));
	$summer_ends   = date("z", strtotime("September 22"));

	$autumn_starts = date("z", strtotime("September 23"));
	$autumn_ends   = date("z", strtotime("November 24"));

	if( $day >= $spring_starts && $day <= $spring_ends ) : $season = "spring";
	elseif( $day >= $summer_starts && $day <= $summer_ends ) : $season = "summer";
	elseif( $day >= $autumn_starts && $day <= $autumn_ends ) : $season = "autumn";
	else : $season = "winter";
	endif;

	$image_path = $icons[$season];
	echo $image_path;
}

checkLogin();
checkRegistration();
?>

<html>
<head>
	<title>Login</title>
	<meta charset="utf-8">	
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/login.css" />
    <script type = "text/javascript" src="js/reg.js"> </script>
</head>

<body background="<?php current_season(); ?>">
<p id="cimPs"></p>
<?php
show_loginform();
//show_service_maintenance();

?></p>
<footer>
	A regisztrációval automatikusan elfogadod az oldal <i>Adatkezelési szabályzatát</i>.
</footer>
</body>
</html>