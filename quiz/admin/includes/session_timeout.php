<?php

if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function adminLogOff()
{
    if(isset($_SESSION['adminuser']))
    {
        $date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
        $date_1 = $date->format('Y-m-d H:i:s');
        $date_1_1 = strtotime($date_1);
        $_SESSION["last_adminactivity"] = $date_1_1;
        if(($_SESSION['last_adminactivity'] - $_SESSION['last_adminvisit'])>59)
        {
            $date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
            $date_1 = $date->format('Y-m-d H:i:s');
            $date_1_1 = strtotime($date_1);
            $exp = date('Y-m-d H:i:s', $_SESSION['last_adminvisit']);
            $exp_1 = strtotime($exp);
            
            if(($date_1_1 - $exp_1) > 899)
            {
                $con = connect();
				if(!$con)
				{
					die(mysqli_connect_error());
				}
				$q = "SELECT logout('" . mysqli_real_escape_string($con, $_SESSION['adminuser']) . "', 0, 1, '" . mysqli_real_escape_string($con, $_SESSION['login_time']) . "') AS is_success";
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
					header("location: adminlogin.php");
				}
				
            }
            else
            {
                $con = connect();
				if(!$con)
				{
					die(mysqli_connect_error());
				}
                $q = "SELECT update_lastvisit('" . mysqli_real_escape_string($con, $_SESSION['adminuser']) . "', 1) AS is_success";
				$res = mysqli_query($con, $q);
                mysqli_close($con);
				if(!$res)
				{
					die(mysqli_connect_error());
				}
				$row = mysqli_fetch_assoc($res);
				if($row['is_success'] == 1)
				{
					$_SESSION['last_adminvisit'] = $_SESSION['last_adminactivity'];
				}
            } 

        }
        else
        {
            $date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
            $date_1 = $date->format('Y-m-d H:i:s');
            $date_1_1 = strtotime($date_1);
            $_SESSION["last_adminactivity"] = $date_1_1;
        }
    }
}

adminLogOff();
?>