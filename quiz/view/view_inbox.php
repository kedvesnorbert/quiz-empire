<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function view_title()
{
    ?><h2 id="cimMymessage">Bejövő értesítések</h2><br><?php
}



?>