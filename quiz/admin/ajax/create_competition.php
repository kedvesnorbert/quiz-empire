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
    elseif(!isset($_POST['p_themaid']) || !preg_match("/^[0-9]+$/", $_POST["p_themaid"]) || $_POST["p_themaid"] < 1 )
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_themaid!"));
    }
    elseif(!isset($_POST['p_color']) || !preg_match("/[#]{1}[a-fA-F0-9]{6}$/", $_POST["p_color"]))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_color!"));
    }
    elseif(!isset($_POST['p_announcement']) || strlen($_POST["p_announcement"]) < 2 || !preg_match("/([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))$/", $_POST['p_announcement']))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_announcement!"));
    }
    elseif(!isset($_POST['p_startdate']) || strlen($_POST["p_startdate"]) < 10 || !preg_match("/^\d\d\d\d-(0?[1-9]|1[0-2])-(0?[1-9]|[12][0-9]|3[01]) (([0-1]{1}[0-9]{1})|([2-2]{1}[0-3]{1})):([0-9]|[0-5][0-9]):([0-9]|[0-5][0-9])$/", $_POST['p_startdate']))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_startdate!"));
    }
    elseif(!isset($_POST['p_enddate']) || strlen($_POST["p_enddate"]) < 10 || !preg_match("/^\d\d\d\d-(0?[1-9]|1[0-2])-(0?[1-9]|[12][0-9]|3[01]) (([0-1]{1}[0-9]{1})|([2-2]{1}[0-3]{1})):([0-9]|[0-5][0-9]):([0-9]|[0-5][0-9])$/", $_POST['p_enddate']))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_enddate!"));
    }
    elseif(!isset($_POST['p_activity']) || strlen($_POST["p_activity"]) != 1 || $_POST['p_activity'] < 0 || $_POST['p_activity']>1)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_activity!"));
    }
    elseif(!isset($_POST['p_rew1']) || strlen($_POST["p_rew1"]) < 1 || !preg_match("/^[0-9]+$/", $_POST["p_rew1"]) || $_POST["p_rew1"] < 100 || $_POST["p_rew1"] > 25000)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_rew1!"));
    }
    elseif(!isset($_POST['p_rew2']) || strlen($_POST["p_rew2"]) < 1 || !preg_match("/^[0-9]+$/", $_POST["p_rew2"]))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_rew2!"));
    }
    elseif(!isset($_POST['p_rew3']) || strlen($_POST["p_rew3"]) < 1 || !preg_match("/^[0-9]+$/", $_POST["p_rew3"]))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_rew3!"));
    }
    elseif(!isset($_POST['p_rew4']) || strlen($_POST["p_rew4"]) < 1 || !preg_match("/^[0-9]+$/", $_POST["p_rew4"]))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_rew4!"));
    }
    elseif(!isset($_POST['p_rew5']) || strlen($_POST["p_rew5"]) < 1 || !preg_match("/^[0-9]+$/", $_POST["p_rew5"]))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_rew5!"));
    }
    elseif(!isset($_POST['p_rew6']) || strlen($_POST["p_rew6"]) < 1 || !preg_match("/^[0-9]+$/", $_POST["p_rew6"]))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_rew6!"));
    }
    elseif(!isset($_POST['p_rew7']) || strlen($_POST["p_rew7"]) < 1 || !preg_match("/^[0-9]+$/", $_POST["p_rew7"]))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_rew7!"));
    }
    elseif($_POST['p_rew1'] <= $_POST['p_rew2'] || $_POST['p_rew2'] <= $_POST['p_rew3'] || $_POST['p_rew3'] <= $_POST['p_rew4'] || $_POST['p_rew4'] <= $_POST['p_rew5'] || $_POST['p_rew5'] <= $_POST['p_rew6'] || $_POST['p_rew6'] <= $_POST['p_rew7'])
    {
        echo json_encode(array("resp"=>"Hiba! A jutalmak nagysága szigorúan csökkenő érték legyen az elsőtől az utolsóig!"));
    }
    else
    {
        $con = connect();
        if(!$con)
        {
            die(err_db());
        }
        mysqli_query($con, "SET @p_response");
        mysqli_query($con, "CALL create_competition('" . mysqli_real_escape_string($con, $_POST['p_themaid']) . "', '" . mysqli_real_escape_string($con, $_POST['p_color']) . "', '" . mysqli_real_escape_string($con, $_POST['p_announcement']) . "', '" . mysqli_real_escape_string($con, $_POST['p_startdate']) . "', '" . mysqli_real_escape_string($con, $_POST['p_enddate']) . "',  '" . mysqli_real_escape_string($con, $_POST['p_activity']) . "', '" . mysqli_real_escape_string($con, $_POST['p_rew1']) . "', '" . mysqli_real_escape_string($con, $_POST['p_rew2']) . "', '" . mysqli_real_escape_string($con, $_POST['p_rew3']) . "', '" . mysqli_real_escape_string($con, $_POST['p_rew4']) . "', '" . mysqli_real_escape_string($con, $_POST['p_rew5']) . "', '" . mysqli_real_escape_string($con, $_POST['p_rew6']) . "', '" . mysqli_real_escape_string($con, $_POST['p_rew7']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', @p_response)");
        $q = "SELECT @p_response AS p_response";
        $res = mysqli_query($con, $q);
        mysqli_close($con);
        if(!$res)
        {
            die(err_db());
        }
        $row = mysqli_fetch_assoc($res);
        $kiir = $row['p_response'];
        echo json_encode(array("resp"=>"$kiir"));
    }
}
else
{
	require_once("../../error.php");
}

}
?>
