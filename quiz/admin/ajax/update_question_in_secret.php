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
    elseif(!isset($_POST['p_questionid']) || !preg_match("/^[0-9]+$/", $_POST["p_questionid"]) || $_POST["p_questionid"] < 1 )
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_questionid!"));
    }
    elseif(!isset($_POST['p_themaid']) || !preg_match("/^[0-9]+$/", $_POST["p_themaid"]) || $_POST["p_themaid"] < 1 )
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_themaid!"));
    }
    elseif(!isset($_POST['p_diff']) || !preg_match("/^[0-9]+$/", $_POST["p_diff"]) || $_POST["p_diff"] < 1 || $_POST["p_diff"] > 2)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_diff!"));
    }
    elseif(!isset($_POST['p_questiontext']) || strlen($_POST["p_questiontext"]) < 2 || strlen($_POST["p_questiontext"]) > 255)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_questiontext!"));
    }
    elseif(!isset($_POST['p_ans1']) || strlen($_POST["p_ans1"]) < 1 || strlen($_POST["p_ans1"]) > 150)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_ans1!"));
    }
    elseif(!isset($_POST['p_ans2']) || strlen($_POST["p_ans2"]) < 1 || strlen($_POST["p_ans2"]) > 150)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_ans2!"));
    }
    elseif(!isset($_POST['p_ans3']) || strlen($_POST["p_ans3"]) < 1 || strlen($_POST["p_ans3"]) > 150)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_ans3!"));
    }
    elseif(!isset($_POST['p_ans4']) || strlen($_POST["p_ans4"]) < 1 || strlen($_POST["p_ans4"]) > 150)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_ans4!"));
    }
    elseif(!isset($_POST['p_reverify']) || !preg_match("/^[0-9]+$/", $_POST["p_reverify"]) || $_POST["p_reverify"] < 0 || $_POST["p_reverify"] > 1)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_reverify!"));
    }
    else
    {
        $con = connect();
        if(!$con)
        {
            die(err_db());
        }
        mysqli_query($con, "SET @p_response");
        mysqli_query($con, "CALL update_question_in_secret('" . mysqli_real_escape_string($con, $_POST['p_questionid']) . "', '" . mysqli_real_escape_string($con, $_POST['p_themaid']) . "', '" . mysqli_real_escape_string($con, $_POST['p_diff']) . "', '" . mysqli_real_escape_string($con, $_POST['p_questiontext']) . "', '" . mysqli_real_escape_string($con, $_POST['p_ans1']) . "', '" . mysqli_real_escape_string($con, $_POST['p_ans2']) . "',  '" . mysqli_real_escape_string($con, $_POST['p_ans3']) . "', '" . mysqli_real_escape_string($con, $_POST['p_ans4']) . "', '" . mysqli_real_escape_string($con, $_POST['p_reverify']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', @p_response)");
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
