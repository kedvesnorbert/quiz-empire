<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_index.php");
require_once("includes/update_logoff.php");
require_once("includes/ip_functions.php");
require_once("includes/responses.php");
require_once("includes/update.php");
require_once("view/menu.php");
require_once("view/view_index.php");

if(!isset($_SESSION["user"]))
{
	$fromurl = urlencode($_SERVER["REQUEST_URI"]);
	setcookie("fromwhere", $fromurl);
	header("location: login.php");
	$_SESSION = array();
	session_destroy();
}

function display_competition()
{
	$res = db_getCompetition();
	if($res == false)
	{
		return;
	}
	$row = mysqli_fetch_assoc($res);
	
	$start = new DateTime($row['startdate']);	//kezdes ideje
	$today = $start->format('Y-m-d H:i:s');
	$ma = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
	$now = $ma->format('Y-m-d H:i:s');
	$expire = new DateTime($row['enddate']);	//meddig tart
	$endd = $expire->format('Y-m-d H:i:s');

	$today_time = strtotime($today);
	$now_time = strtotime($now);
	$expire_time = strtotime($endd);
	
	$con = connect();
	if(!$con)
	{
		die(err_db());
	}
	$res1 = mysqli_query($con, "SELECT access_competition('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', 0) AS eredmeny");
	mysqli_close($con);	
	$row1 = mysqli_fetch_assoc($res1);
	$kiir = $row1['eredmeny'];
	
	echo "<center><div id='display_comp_container'><p id='kiemeltkviz_p'>Kiemelt kvíz</p>";

	$btn_color = (strlen($row['button_color']) >0) ? "background-color:" . $row['button_color'] . ";" : "background-color:#1E90FF;";
	$quizname = $row['quiz_name'] . " KVÍZ";

	if($kiir == 'ok' && ($expire_time - $now_time >0) && ($now_time - $today_time)>=0)
	{
		show_competition_data($btn_color, $quizname, $row['enddate']);
	}
	else
	{
		if(($now_time - $today_time)<0)
		{
			$time_info = "Indulás ideje: " . $row['startdate'] . "<br> GMT + 02:00";
		}
		elseif(($expire_time - $now_time) <0)
		{
			$time_info = "Ez a kvíz már nem elérhető!";
		}
		else
		{
			$time_info = "Ez a kvíz nem elérhető!";
		}
		show_competition_expired_data($btn_color, $quizname, $time_info);
	}

	if(($now_time - $today_time)>=0)
	{
		$quizname = $row['quiz_name'] . " kvíz ranglista";
		show_comp_ranglist($quizname);
	}

	echo "</div></center>";
}

function showImportantData($res)
{
	if(!$res)
	{
		return false;
	}
	$row = mysqli_fetch_assoc($res);
	
	$prefix = "";
	if($row['warn'] != 0)
	{
		$prefix = "<span id='w_span'>WARN!</span>";
	}
	elseif($row['premium'] == 1)
	{
		$prefix = "<span id='p_span'>PR!</span>";
	}
	$username = $_SESSION['user'];
	$points = $row['points'];
	$quizplayed = $row['quizplayed_total'];
	$level = "Rang: " . $row['level'] . ".";

	show_important_userdata($prefix, $username, $points, $quizplayed, $level);

	if($row['premium'] == 2)
	{
		?><script> alert("Gratulálunk! Nyertél egy 30 napos PRÉMIUM funkciót."); </script><?php
		free_premium();
	}
}

?>
<html>
<head>
	<title>Index</title>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/index.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/jQuery-ui.css">
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css"> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/index.js"></script>
	<script type = "text/javascript" src="js/menu.js"></script>
</head>
<body>
<?php
$res = db_getUserData();
if(!$res)
{
	die(err_db());
}
main_menu();
showImportantData($res);
$res = db_getUserData();
if(!$res)
{
	die(err_db());
}
$row = mysqli_fetch_assoc($res);
if($row['deleteduser'] != 0)
{
	$_SESSION = array();
	session_destroy();
	header('location: login.php');
}
menu();
display_competition();

if($_SESSION['admin_user'] == 1 || $row['level'] >= 4 || $row['premium'] == 1)
{
	index_main_long();
}
else
{
	index_main();
}
?>
</body>
</html>