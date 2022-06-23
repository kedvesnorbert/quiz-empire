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
require_once("sessiontimeoutadmin.php");

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
    if(adminlogoff_ajax()== -1)
    {
        echo json_encode(array("resp"=>err_session_timeout()));
    }
    elseif(!isset($_POST['p_userid']) || !preg_match("/^[0-9]+$/", $_POST["p_userid"]) || $_POST["p_userid"] < 1 )
    {
        echo json_encode(array("resp"=>"Helytelen érték: user id!"));
    }
    elseif(!isset($_POST['p_accountrestorereason']) || strlen($_POST["p_accountrestorereason"]) < 5 || strlen($_POST["p_accountrestorereason"]) > 100)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_accountrestorereason!"));
    }
    else
    {
        $con = connect();
        if(!$con)
        {
            die(err_db());
        }
        $res = mysqli_query($con, "SELECT restore_account('" . mysqli_real_escape_string($con, $_POST['p_userid']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', '" . mysqli_real_escape_string($con, $_POST['p_accountrestorereason']) . "') AS response");
        mysqli_close($con);
        if(!$res)
        {
            die(err_db());
        }
        $row = mysqli_fetch_assoc($res);
		$kiir = $row['response'];
        echo json_encode(array("resp"=>"$kiir"));
    }
}
else
{
	require_once("../../error.php");
}

	
}


?>
