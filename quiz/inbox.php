<?php
session_start();
require_once("db/db_connect.php");
require_once("includes/responses.php");
require_once("db/db_inbox.php");
require_once("includes/update_logoff.php");
require_once("includes/ip_functions.php");
require_once("view/menu.php");
require_once("view/view_inbox.php");

if(!isset($_SESSION["user"]))
{
	$fromurl = urlencode($_SERVER["REQUEST_URI"]);
	setcookie("fromwhere", $fromurl);
	header("location: login.php");
	$_SESSION = array();
	session_destroy();
}

function show_container()
{
	?><div id="main_div">
		<div id="senders_div">
		<?php
		$res = db_clientsdata();
		while($row = mysqli_fetch_assoc($res))
		{
			$temp1 = $row['identifier'];
			$temp2 = $row['username'];
			$temp3 = $row['olvasott'];
			if($temp1 == 0)
			{
				if($temp3 == 1)
				{
					echo "<button id='sendername_div$temp1' class='sendername' onclick='show_this_messages($temp1);' style='border:3px solid black'>" . "<b><font color='red'>$temp2</font></b>" . "</button>" . "<br>";
				}
				else
				{
					echo "<button id='sendername_div$temp1' class='sendername' onclick='show_this_messages($temp1);' style='border:3px solid black'>" . "$temp2" . "</button>" . "<br>";
				}
			}
			else
			{
				if($temp3 == 1)
				{
					echo "<button id='sendername_div$temp1' class='sendername' onclick='show_this_messages($temp1);'>" . "<b><font color='red'>$temp2</font></b>" . "</button>" . "<br>";
				}
				else
				{
					echo "<button id='sendername_div$temp1' class='sendername' onclick='show_this_messages($temp1);'>" . "$temp2" . "</button>" . "<br>";
				}
			}
		}
		?>
		</div>
		<div id="description_div"><br><br></div>
	</div><?php
}

?>
<html>
<head>
	<title>Értesítések</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/inbox.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css"> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="js/inbox.js"></script>
	<script type = "text/javascript" src="js/menu.js"></script>
</head>
<body>
<?php
main_menu();
view_title();
show_container();
?>
</body>
</html>