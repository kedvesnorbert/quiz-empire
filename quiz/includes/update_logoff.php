<?php

if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function show_service($a)
{
	if($a == 1){
		$con = connect();
		if(!$con)
		{
			return null;
		}
		mysqli_query($con, "SET @p_response");
		mysqli_query($con, "CALL maintenance_time('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', @p_response)");
		$q = "SELECT @p_response AS p_response";
		$res = mysqli_query($con, $q);
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['p_response'];
		if($kiir == "ok")
		{
			$_SESSION = array();
			session_destroy();
			header("location: login.php");
		}
	}
}

function countTimetoLogOff()
{
	?><script type = "text/javascript" src="js/update_logoff.js"></script><?php
}

function logOff()
{
    if(isset($_SESSION['user']))
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
                $con = connect();
				if(!$con)
				{
					die(mysqli_connect_error());
				}
				$q = "SELECT logout('" . mysqli_real_escape_string($con, $_SESSION['user']) . "', 0, 0, '" . mysqli_real_escape_string($con, $_SESSION['login_time']) . "') AS is_success";
				$res = mysqli_query($con, $q);
                mysqli_close($con);
				if(!$res)
				{
					die(mysqli_connect_error());
				}
				$row = mysqli_fetch_assoc($res);
				if($row['is_success'] == 1)
				{
					$_SESSION = array();
					session_destroy();
					header("location: login.php");
				}
				
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
				}
            }
        }
        else
        {
            $date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
            $date_1 = $date->format('Y-m-d H:i:s');
            $date_1_1 = strtotime($date_1);
            $_SESSION["last_activity"] = $date_1_1;
        }
    }
    countTimetoLogOff();
}

logOff();
show_service(0);
?>