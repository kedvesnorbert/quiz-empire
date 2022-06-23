<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function logoff_ajax()
{
	$date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
	$date_1 = $date->format('Y-m-d H:i:s');
	$date_1_1 = strtotime($date_1);
	$_SESSION["last_activity"] = $date_1_1;
	if(($_SESSION['last_activity'] - $_SESSION['lastvisit'])>59)
	{
		$date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
		$date_1 = $date->format('Y-m-d H:i:s');
		$date_1_1 = strtotime($date_1);
		$exp = date('Y-m-d H:i:s', $_SESSION['lastvisit']);
		$exp_1 = strtotime($exp);
		
		if(($date_1_1 - $exp_1) > 899)
		{
			return -1;
		}
		else
		{
			$con = connect();
			if(!$con)
			{
				die(mysqli_connect_error());
			}
			$q = "SELECT update_lastvisit('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', 0) AS is_success";
			$res = mysqli_query($con, $q);
			mysqli_close($con);
			if(!$res)
			{
				die(mysqli_connect_error());
			}
			$row = mysqli_fetch_assoc($res);
			if($row['is_success'] == 1)
			{
				$_SESSION['lastvisit'] = $_SESSION['last_activity'];
				return 0;
			}
		}
	}
	else
	{
		$date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
		$date_1 = $date->format('Y-m-d H:i:s');
		$date_1_1 = strtotime($date_1);
		$_SESSION["last_activity"] = $date_1_1;
		return 0;
	}
    
}

function logoff_ajax_onlycheck()
{
	$date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
	$date_1 = $date->format('Y-m-d H:i:s');
	$date_1_1 = strtotime($date_1);
	$_SESSION["last_activity"] = $date_1_1;
	if(($_SESSION['last_activity'] - $_SESSION['lastvisit'])>899)
	{
		return -1;
	}
	else
	{
		return 0;
	}
}

?>