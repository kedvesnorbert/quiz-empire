<?php
session_start();

if(!isset($_SESSION['adminuser']) || !isset($_SESSION['is_admin']) || !isset($_SESSION['user_id']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../adminlogin.php");
}
else
{
require_once("../db/db_connect.php");
require_once("../../includes/responses.php");
require_once("../db/db_userdetails.php");
require_once("sessiontimeoutadmin.php");

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
    if(adminlogoff_ajax()== -1)
    {
        echo json_encode(array("resp"=>err_session_timeout()));
    }
    elseif(!isset($_POST['profile_id']) || !preg_match("/^[0-9]+$/", $_POST["profile_id"]) || $_POST["profile_id"] < 1)
    {
        $resp = array();
        array_push($resp, err_missing_data());
        echo json_encode($resp);
    }
    else
    {
        $res = db_getuserprofilehidingdata($_POST['profile_id']);
        if(!$res)
        {
            die(err_db());
        }
        $row = mysqli_fetch_assoc($res);
            $profilhiding = $row['profilehiding'];
            $profilhidingdelay = $row['profilehiding_expire'];
        
        $resp = array();
        array_push($resp, $profilhiding);
        array_push($resp, $profilhidingdelay);
        echo json_encode($resp);
    }
}
else
{
	require_once("../../error.php");
}

	
}


?>
