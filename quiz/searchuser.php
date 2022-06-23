<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_searchuser.php");
require_once("includes/update.php");
require_once("includes/update_logoff.php");
require_once("includes/ip_functions.php");
require_once("view/menu.php");
require_once("view/view_searchuser.php");

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
	<title>Felhasználókereső</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/searchuser.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css"> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="js/searchuser.js"></script>
	<script type = "text/javascript" src="js/menu.js"></script>
</head>
<body>
<?php
main_menu();
?>
<div id='container'>
	<h3 id="felhsearch_title_id">Felhasználókereső</h3><br>
	<?php
	if(db_using_usersearch() == true)
	{
		show_searcherdiv();
	}
	else
	{
		show_errordiv();
	}
	?>
	<div id='results_div'>
	</div>
</div>
</body>
</html>