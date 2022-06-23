<?php
session_start();

require_once("db/db_connect.php");
require_once("includes/responses.php");
require_once("db/db_chat.php");
require_once("includes/update.php");
require_once("includes/update_logoff.php");
require_once("includes/ip_functions.php");
require_once("view/menu.php");
require_once("view/view_chat.php");

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
	<title>CHAT</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/chat.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/jQuery-ui.css">
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css"> <!-- B -->
	<script src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script> <!-- B -->
	<script src="includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/chat.js"></script>
	<script type = "text/javascript" src="js/menu.js"></script>
</head>
<body>
<?php
main_menu();
?>
<div id="container_msgdiv">
	<div id="first_msgdiv">
	<?php
	show_newgroupbtn();
	show_mygroups();
	?>
	</div>
	<div id="second_msgdiv">
		<?php
		//echo "A CHAT határozatlan ideig nem elérhető!";
		show_input();
		show_msg();
		?>
	</div>
	<div id="third_msgdiv">
		<div id="group_det_div"><?php view_public_chatgroup(); ?></div>
	</div>
</div>
</body>
</html>