<?php
session_start();

require_once("db/db_connect.php");
require_once("db/db_newquestion.php");
require_once("includes/responses.php");
require_once("includes/update_logoff.php");
require_once("includes/ip_functions.php");
require_once("view/menu.php");
require_once("view/view_newquestion.php");

if(!isset($_SESSION["user"]))
{
	$fromurl = urlencode($_SERVER["REQUEST_URI"]);
	setcookie("fromwhere", $fromurl);
	header("location: login.php");
	$_SESSION = array();
	session_destroy();
}

function recorrecting_questionlist()
{
	?><br>
	<h2 style="text-align:center;margin-bottom:25px;">Javításra váró kérdések</h2>
	<?php
	$res = db_correct_questionlist();
	if (!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res) < 1)
	{
		show_norecorrecting();
	}
	else
	{
		?>
		<div class="row" style="width:90%;">
			<?php
			while ($row = mysqli_fetch_assoc($res))
			{
				$question_abr = (strlen($row['question'])>40) ? substr($row['question'],0,40).'...' : $row['question'];
				$ans_abr = (strlen($row['ans1'])>20) ? substr($row['ans1'],0,20).'...' : $row['ans1'];
				$comment_abr = substr($row['comment_text'],49);
				show_questioncard($row['id'], $row['quiz_name'], $row['quiz_id'], $question_abr, $ans_abr, $comment_abr, $row['comment_time'], $row['question'], $row['ans1'], $row['ans2'], $row['ans3'], $row['ans4']);
			}
			?>
		</div><?php
	}
}
?>

<html>
<head>
	<title>Új kérdés beküldése</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/newquestion.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/jQuery-ui.css">
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css"> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/newquestion.js"></script>
	<script type = "text/javascript" src="js/menu.js"></script>
</head>
<body>
<?php
main_menu();

if(!isset($_GET['action_id']) || !preg_match("/^[0-9]+$/", $_GET['action_id']) || $_GET['action_id'] < 1)
{
	$_GET['action_id'] = 1;
}

if(db_lawto_sendquestion() == true)
{
	newquestion_menu();
	if($_GET['action_id'] == 1)
	{
		new_question_form();
	}
	elseif($_GET['action_id'] == 2)
	{
		recorrecting_questionlist();
	}
}
else
{
	show_forbidden();
}
?>
</body>
</html>