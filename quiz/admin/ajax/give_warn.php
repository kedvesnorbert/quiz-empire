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
    elseif(!isset($_POST['p_lawtogetpoints']) || !preg_match("/^[0-9]+$/", $_POST["p_lawtogetpoints"]) || $_POST["p_lawtogetpoints"] < 0 || $_POST["p_lawtogetpoints"] > 1)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_lawtogetpoints!"));
    }
    elseif(!isset($_POST['p_lawtousechat']) || !preg_match("/^[0-9]+$/", $_POST["p_lawtousechat"]) || $_POST["p_lawtousechat"] < 0 || $_POST["p_lawtousechat"] > 1)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_lawtousechat!"));
    }
    elseif(!isset($_POST['p_lawtouserequests']) || !preg_match("/^[0-9]+$/", $_POST["p_lawtouserequests"]) || $_POST["p_lawtouserequests"] < 0 || $_POST["p_lawtouserequests"] > 1)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_lawtouserequests!"));
    }
    elseif(!isset($_POST['p_lawtosendmail']) || !preg_match("/^[0-9]+$/", $_POST["p_lawtosendmail"]) || $_POST["p_lawtosendmail"] < 0 || $_POST["p_lawtosendmail"] > 1 )
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_lawtosendmail!"));
    }
    elseif(!isset($_POST['p_lawtocreatequiz']) || !preg_match("/^[0-9]+$/", $_POST["p_lawtocreatequiz"]) || $_POST["p_lawtocreatequiz"] < 0 || $_POST["p_lawtocreatequiz"] > 1 )
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_lawtocreatequiz!"));
    }
    elseif(!isset($_POST['p_lawtosendquestion']) || !preg_match("/^[0-9]+$/", $_POST["p_lawtosendquestion"]) || $_POST["p_lawtosendquestion"] < 0 || $_POST["p_lawtosendquestion"] > 1)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_lawtosendquestion!"));
    }
    elseif(!isset($_POST['p_lawtosearchuser']) || !preg_match("/^[0-9]+$/", $_POST["p_lawtosearchuser"]) || $_POST["p_lawtosearchuser"] < 0 || $_POST["p_lawtosearchuser"] > 1)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_lawtosearchuser!"));
    }
    elseif(!isset($_POST['p_lawtopostnews']) || !preg_match("/^[0-9]+$/", $_POST["p_lawtopostnews"]) || $_POST["p_lawtopostnews"] < 0 || $_POST["p_lawtopostnews"] > 1)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_lawtopostnews!"));
    }
    elseif(!isset($_POST['minuspoints']) || !preg_match("/^[0-9]+$/", $_POST["minuspoints"]) || $_POST["minuspoints"] < 100 || $_POST["minuspoints"] > 10000 )
    {
        echo json_encode(array("resp"=>"Helytelen érték: minuspoints!"));
    }
    elseif(!isset($_POST['warndelay']) || !preg_match("/^[0-9]+$/", $_POST["warndelay"]) || $_POST["warndelay"] < 3 || $_POST["warndelay"] > 100)
    {
        echo json_encode(array("resp"=>"Helytelen érték: warndelay!"));
    }
    elseif(!isset($_POST['warnreason']) || strlen($_POST["warnreason"]) < 5 || strlen($_POST["warnreason"]) > 100)
    {
        echo json_encode(array("resp"=>"Helytelen érték: warnreason!"));
    }
    else
    {
        $con = connect();
        if(!$con)
        {
            die(err_db());
        }
        $res = mysqli_query($con, "SELECT give_warn('" . mysqli_real_escape_string($con, $_POST['p_lawtogetpoints']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtousechat']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtouserequests']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtosendmail']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtocreatequiz']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtosendquestion']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtosearchuser']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtopostnews']) . "', '" . mysqli_real_escape_string($con, $_POST['minuspoints']) . "', '" . mysqli_real_escape_string($con, $_POST['warndelay']) . "', '" . mysqli_real_escape_string($con, $_POST['warnreason']) . "', '" . mysqli_real_escape_string($con, $_POST['p_userid']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "') AS response");
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
