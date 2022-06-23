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

function validateDate($date, $format = 'Y-m-d H:i:s')
{
    $d = DateTime::createFromFormat($format, $date);
    return $d && $d->format($format) === $date;
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
    if(adminlogoff_ajax()== -1)
    {
        echo json_encode(array("resp"=>err_session_timeout()));
    }
    elseif(!isset($_POST['p_quizid']) || !preg_match("/^[0-9]+$/", $_POST["p_quizid"]) || $_POST["p_quizid"] < 1 )
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_quizid!"));
    }
    elseif(!isset($_POST['p_userid']) || !preg_match("/^[0-9]+$/", $_POST["p_userid"]) || $_POST["p_userid"] < 1 )
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_userid!"));
    }
    elseif(!isset($_POST['p_commentdate']) || !preg_match("/^\d{4}\-\d{2}\-\d{2} \d{2}:\d{2}:\d{2}$/", $_POST["p_commentdate"]) || !validateDate($_POST["p_commentdate"]))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_commentdate!"));
    }
    elseif(!isset($_POST['p_modifiedcomment']) || strlen($_POST['p_modifiedcomment']) < 1 || strlen($_POST['p_modifiedcomment'])> 2500)
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_modifiedcomment!"));
    }
    elseif(!isset($_POST['p_moderatorcomment']) || strlen($_POST['p_moderatorcomment']) < 10 || strlen($_POST['p_moderatorcomment'])> 400 || !preg_match("/^[a-zA-Z0-9 ]+$/", $_POST["p_userid"]))
    {
        echo json_encode(array("resp"=>"Helytelen érték: p_moderatorcomment!"));
    }
    else
    {
        $_POST['p_moderatorcomment'] .= "\nModerálva " . $_SESSION['adminuser'] . " által";
        $con = connect();
        if(!$con)
        {
            die(err_db());
        }
        $res = mysqli_query($con, "SELECT censore_quiz_comment('" . mysqli_real_escape_string($con, $_POST['p_quizid']) . "', '" . mysqli_real_escape_string($con, $_POST['p_userid']) . "', '" . mysqli_real_escape_string($con, $_POST['p_commentdate']) . "', '" . mysqli_real_escape_string($con, $_POST['p_modifiedcomment']) . "', '" . mysqli_real_escape_string($con, $_POST['p_moderatorcomment']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "') AS p_response");
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
