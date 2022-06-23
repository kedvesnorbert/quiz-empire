<?php
session_start();

require_once("../db/db_connect.php");
require_once("../db/db_chat.php");
require_once("../includes/responses.php");
require_once("sessiontimeout.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{

function show_chathistory()
{
	$res = db_chathistory($_POST['groupid'], $_SESSION['user_id']);
	if(!$res)
	{
		die("A betöltés nem sikerült! Ellenőrizd a munkamenetet!");
	}
	?>
	<table id='chistory_table' border='0'>
	<?php
	while($row = mysqli_fetch_assoc($res))
	{
		echo "<tr>";
		echo "<td>" . $row['event_text'] . " (<i>" . $row['event_date'] ."</i>)\n";
	}
	?>
	</table><?php
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax()== -1)
	{
		;
	}
	elseif(isset($_POST['groupid']) && preg_match("/^[0-9]+$/", $_POST['groupid']) && $_POST['groupid']>=1)
	{
		show_chathistory();
	}
}
else
{
	require_once("../error.php");
}
}