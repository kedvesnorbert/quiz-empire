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
require_once("../db/db_backgrounds.php");
require_once("../../includes/responses.php");
require_once("sessiontimeoutadmin.php");

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
    if(adminlogoff_ajax()== -1)
    {
        echo json_encode(array("resp"=>err_session_timeout()));
    }
    elseif(!isset($_POST['p_imgid']) || !preg_match("/^[0-9]+$/", $_POST['p_imgid']) || $_POST['p_imgid'] < 1)
	{
		echo json_encode(array("resp"=>err_missing_data()));
	}
    else
    {
        $res_s = db_getBgImagePath($_POST['p_imgid']);
		if(!$res_s)
		{
			die(err_db());
		}
		$con = connect();	
		$res = mysqli_query($con, "SELECT delete_backgroundimage('" . mysqli_real_escape_string($con, $_POST['p_imgid']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "') AS uzenet");
		$row = mysqli_fetch_assoc($res);
		$kiir = $row['uzenet'];
		mysqli_close($con);	
		if($kiir == "ok")
		{
			$row_s = mysqli_fetch_assoc($res_s);
			unlink("../../" . $row_s['image_path']);
		}
		echo json_encode(array("resp"=>"$kiir"));
    }
}
else
{
	require_once("../../error.php");
}

	
}


?>
