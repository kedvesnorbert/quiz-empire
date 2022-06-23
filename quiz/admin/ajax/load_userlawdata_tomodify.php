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
        $res = db_getuserlawdatatomodify($_POST['profile_id']);
        if(!$res)
        {
            die(err_db());
        }
        $row = mysqli_fetch_assoc($res);
            $keep_level = $row['keep_level'];
            $szint = $row['level'];
            $lawtogetpoints = $row['lawtogetpoints'];
            $lawtousechat = $row['lawtousechat'];
            $lawtouserequests = $row['lawtouserequests'];
            $lawtosendmail = $row['lawtosendmail'];
            $lawtocreatequiz = $row['lawtocreatequiz'];
            $lawtosendquestion = $row['lawtosendquestion'];
            $lawtosearchuser = $row['lawtosearchuser'];
            $lawtopostnews = $row['lawtopostnews'];
            $lawtoeditfaq = $row['lawtoeditfaq'];
            $points = $row['points'];
            $helps = $row['help'];
            $freepremium = $row['freepremium'];
            $questiontype = $row['questiontype'];
        
        $resp = array();
        array_push($resp, $keep_level);
        array_push($resp, $szint);
        array_push($resp, $lawtogetpoints);
        array_push($resp, $lawtousechat);
        array_push($resp, $lawtouserequests);
        array_push($resp, $lawtosendmail);
        array_push($resp, $lawtocreatequiz);
        array_push($resp, $lawtosendquestion);
        array_push($resp, $lawtosearchuser);
        array_push($resp, $lawtopostnews);
        array_push($resp, $points);
        array_push($resp, $helps);
        array_push($resp, $freepremium);
        array_push($resp, $questiontype);
        echo json_encode($resp);
    }
}
else
{
	require_once("../../error.php");
}

	
}


?>
