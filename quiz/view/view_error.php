<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function err_timeout()
{
	?>
	<center><br><img src="documents/images/warning.png" align = "center" width="14%"><br>
	<p id="warning_startquiz_id">Sajnáljuk!<br>
	A munkamenet ideje lejárt! Jelentkezzen be újra!</p></center>
	<?php
}

?>