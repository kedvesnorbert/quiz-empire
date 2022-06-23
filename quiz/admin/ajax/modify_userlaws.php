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
    elseif(!superadmin())
    {
        echo json_encode(array("resp"=>"Ez a beállítás csak a SzuperAdmin ranggal érhető el!"));
    }
    elseif(!isset($_POST['p_userid']) || !preg_match("/^[0-9]+$/", $_POST["p_userid"]) || $_POST["p_userid"] < 1 )
    {
        echo json_encode(array("resp"=>"Helytelen érték: user id!"));
    }
    elseif(!isset($_POST['p_keeplevel']) || !preg_match("/^[0-9]+$/", $_POST["p_keeplevel"]) || $_POST["p_keeplevel"] < 0 || $_POST["p_keeplevel"] > 1)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_keeplevel!"));
    }
    elseif(!isset($_POST['p_currentlevel']) || !preg_match("/^[0-9]+$/", $_POST["p_currentlevel"]) || $_POST["p_currentlevel"] < 1 || $_POST["p_currentlevel"] > 5)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_currentlevel!"));
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
    elseif(!isset($_POST['p_plusminuspoints']) || !preg_match("/^-?[0-9]\d*(\d+)?$/", $_POST["p_plusminuspoints"]))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_plusminuspoints!"));
    }
    elseif(!isset($_POST['p_counthelps']) || !preg_match("/^-?[0-9]\d*(\d+)?$/", $_POST["p_counthelps"]))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_counthelps!"));
    }
    elseif(!isset($_POST['p_delfreepremium']) || !preg_match("/^[0-9]+$/", $_POST["p_delfreepremium"]) || $_POST["p_delfreepremium"] < 0 || $_POST["p_delfreepremium"] > 1)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_delfreepremium!"));
    }
    elseif(!isset($_POST['p_questiontype']) || !preg_match("/^[0-9]+$/", $_POST["p_questiontype"]) || $_POST["p_questiontype"] < 0 || $_POST["p_questiontype"] > 2)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_questiontype!"));
    }
    else
    {
        $con = connect();
        if(!$con)
        {
            die(err_db());
        }
        $res = mysqli_query($con, "SELECT modify_user_laws('" . mysqli_real_escape_string($con, $_POST['p_keeplevel']) . "', '" . mysqli_real_escape_string($con, $_POST['p_currentlevel']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtogetpoints']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtousechat']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtouserequests']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtosendmail']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtocreatequiz']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtosendquestion']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtosearchuser']) . "', '" . mysqli_real_escape_string($con, $_POST['p_lawtopostnews']) . "', '" . mysqli_real_escape_string($con, $_POST['p_plusminuspoints']) . "', '" . mysqli_real_escape_string($con, $_POST['p_counthelps']) . "', '" . mysqli_real_escape_string($con, $_POST['p_delfreepremium']) . "', '" . mysqli_real_escape_string($con, $_POST['p_questiontype']) . "', '" . mysqli_real_escape_string($con, $_POST['p_userid']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "') AS response");
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
