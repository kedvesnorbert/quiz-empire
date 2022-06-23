<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function checkDevice() 
{
	if(is_numeric(strpos(strtolower($_SERVER['HTTP_USER_AGENT']), "mobile"))) 
	{
		return is_numeric(strpos(strtolower($_SERVER['HTTP_USER_AGENT']), "tablet")) ? 2 : 1 ;
	} 
	else 
	{
		return 0;
	}
}
?>