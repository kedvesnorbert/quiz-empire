<?php
session_start();
require_once("db/db_connect.php");
require_once("includes/update_logoff.php");
require_once("includes/ip_functions.php");
require_once("view/menu.php");
require_once("view/view_wiki.php");

if(!isset($_SESSION["user"]))
{
	$fromurl = urlencode($_SERVER["REQUEST_URI"]);
	setcookie("fromwhere", $fromurl);
	header("location: login.php");
	$_SESSION = array();
	session_destroy();
}

?>
<html>
<head>
	<title>Szabályzat</title>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/wiki.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css"> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="js/menu.js"></script>
</head>
<body>
<?php
main_menu();
show_title();
wiki_main();
if(!isset($_GET['whatRules']))
{
	laws_data();
}
else
{
	if($_GET['whatRules'] == 1)
	{
		new_request();
	}
	elseif($_GET['whatRules'] == 2)
	{
		new_questiondata();
	}
	elseif($_GET['whatRules'] == 3)
	{
		laws_data();
	}
	elseif($_GET['whatRules'] == 4)
	{
		new_quiz_data();
	}
	elseif($_GET['whatRules'] == 5)
	{
		chat_data();
	}
	elseif($_GET['whatRules'] == 6)
	{
		pm_data();
	}
	elseif($_GET['whatRules'] == 7)
	{
		faq();
	}
	elseif($_GET['whatRules'] == 8)
	{
		quiz_listing_data();
	}
	elseif($_GET['whatRules'] == 9)
	{
		friends_data();
	}
	elseif($_GET['whatRules'] == 10)
	{
		profile_data();
	}
	elseif($_GET['whatRules'] == 11)
	{
		news_data();
	}
	elseif($_GET['whatRules'] == 12)
	{
		points_data();
	}
	else
	{
		laws_data();
	}
}
?>
</body>
</html>