<?php
session_start();

require_once("db/db_connect.php");
require_once("db/db_adminlogin.php");
require_once("../includes/ip_functions.php");
require_once("../db/db_login.php");
require_once("../includes/responses.php");

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

function checkAdminLogin()
{
	if(isset($_POST["adminlog"]))
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
		
		if (loginDataOK($_POST["adminuser"], $_POST["adminpw"]))
		{
			$con = connect();
			if(!$con)
			{
				die(mysqli_connect_error());
			}
			$res = mysqli_query($con, "SELECT loginadmin('" . mysqli_real_escape_string($con, $_POST["adminuser"]) . "', '" . mysqli_real_escape_string($con, hash("sha512", $_POST["adminpw"])) . "', '" . mysqli_real_escape_string($con, $device) . "') AS is_success");
			mysqli_close($con);
			
			if(!$res)
			{
				?><script>alert("Hibás felhasználónév vagy jelszó!\nBejelentkezni CSAK Admin tagoknak lehetséges!");</script><?php
			}
			else
			{
				$row = mysqli_fetch_assoc($res);
				if(strtotime($row['is_success']))
				{
					$res1 = db_getadminuserdata($_POST["adminuser"]);
					if(!$res1)
					{
						?><script>alert("Hiba történt. Próbáld újra!");</script><?php
					}
					else
					{
						$_SESSION = array();
						$row1 = mysqli_fetch_assoc($res1);
						$_SESSION["adminuser"] = $row1['user'];
						$_SESSION["user_id"] = $row1['id'];
						$_SESSION["is_admin"] = $row1['adminuser'];
						$_SESSION["login_time"] = $row['is_success'];

						$date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
						$date_1 = $date->format('Y-m-d H:i:s');
						$date_1_1 = strtotime($date_1);
						$_SESSION["last_adminactivity"] = $date_1_1;
						$_SESSION["last_adminvisit"] = $date_1_1;
						if(!isset($_COOKIE['fromwhereadmin']) || !is_valid_adminurl($_COOKIE['fromwhereadmin']))
						{
							header("location:index.php");
						}
						else
						{
							header("location:" . urldecode($_COOKIE['fromwhereadmin']));
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
			$res = mysqli_query($con, "SELECT loginadmin('" . mysqli_real_escape_string($con, $_POST["adminuser"]) . "', '" . mysqli_real_escape_string($con, hash("sha512", $_POST["adminpw"])) . "', '" . mysqli_real_escape_string($con, $device) . "') AS is_success");
			mysqli_close($con);
			?><script>alert("Hibás felhasználónév vagy jelszó!!");</script><?php
		}
	}
}

function show_adminloginform()
{
	?>
	<div class="main-content-agile">
		<div class="sub-main-w3">
			<h2>Login Here</h2>
			<form action="adminlogin.php" method="POST" onsubmit="return check_adminlogin()">
				<div class="pom-agile">
					<span class="fa fa-user-o" aria-hidden="true"></span>
					<input id='adminuser_id' placeholder="E-mail or Username" name="adminuser" class="user" type="text" required="">
				</div>
				<div class="pom-agile">
					<span class="fa fa-key" aria-hidden="true"></span>
					<input id='adminpw_id' placeholder="Password" name="adminpw" class="pass" type="password" required="">
				</div>
				
				<div class="right-w3l">
					<br><input type="submit" name="adminlog" value="Login">
				</div>
			</form>
		</div>
	</div>
	<?php
}

checkAdminLogin();
?>
<html>
<head>
	<title>Login for Admins</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=../includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/adminlogin.css" />
	<script type = "text/javascript" src="js/adminlogin.js"></script>
</head>
<body>
<?php
show_adminloginform();
?>

</body>
</html>