<?php
session_start();

require_once("../db/db_connect.php");
require_once("sessiontimeout.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{

function show_commentsection($textmsg)
{
	?><p id="commentsection_title">Legújabb hozzászólásom</p>
	<div id="commentsection_div">
		<div id="one_commentdiv">
			<table border="0" width="100%">
			<tr>
			<td id="one_comment_username"><i>Írta:</i> <b><a href="profile.php?profil_id=<?php echo $_SESSION['user_id'] ?>"><?php echo $_SESSION['user'] ?></a></b></td>
			<td id="one_comment_date"><?php echo date("Y-m-d H:i:s") ?></td>
			<tr>
			<td id="one_comment_fulltext" colspan="2"><?php echo nl2br(htmlentities($_POST['my_comment'])) ?></td>
			<tr>
			</table>
		</div>
	</div><?php
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax()== -1 || !isset($_POST['my_comment']))
	{
		;
	}
	else
	{
		show_commentsection($_POST['my_comment']);
	}
}
else
{
	require_once("../error.php");
}
}