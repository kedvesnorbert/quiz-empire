<?php
session_start();

require_once("../db/db_connect.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(isset($_POST['cim1']) && isset($_POST['leiras1']) && isset($_POST['nyelv1']) && isset($_POST['kerdszam1']) && isset($_POST['valsec1']) && isset($_POST['showcorr1']) && isset($_POST['points']) && isset($_POST['acceptconditions1']) && isset($_POST['rejtetten1']) && isset($_POST['kerdszamkot1']))
	{
		if(logoff_ajax()== -1)
		{
			echo json_encode(array("resp"=>err_session_timeout()));
		}
		elseif(strlen($_POST['cim1']) < 1 || strlen($_POST['cim1']) > 50)
		{
			echo json_encode(array("resp"=>"HIBA! A kérés címe 1 - 50 karakter hosszú legyen! Az ékezetes betűk dupla karakternek számítanak!"));
		}
		elseif(strlen($_POST['leiras1']) < 30 || strlen($_POST['leiras1']) > 999)
		{
			echo json_encode(array("resp"=>"HIBA! A kérés leírása 30 - 999 karakter hosszú legyen! Az ékezetes betűk dupla karakternek számítanak!"));
		}
		elseif(!preg_match("/^[0-9]+$/", $_POST["points"]) || $_POST['points'] < 100)
		{
			echo json_encode(array("resp"=>"HIBA! A felajánlott pontok száma minimum 100!!"));
		}
		elseif($_POST['nyelv1'] != 1 && $_POST['nyelv1'] != 2)
		{
			echo json_encode(array("resp"=>"HIBA! Nem választottad ki a kvíz nyelvét!"));
		}
		elseif(!preg_match("/^[0-9]+$/", $_POST["kerdszam1"]) || $_POST['kerdszam1'] < 13 || $_POST['kerdszam1'] > 45)
		{
			echo json_encode(array("resp"=>"HIBA! A kérdések száma 13 - 45 között legyen!"));
		}
		elseif(!preg_match("/^[0-9]+$/", $_POST["valsec1"]) || $_POST['valsec1'] < 15 || $_POST['valsec1'] > 99)
		{
			echo json_encode(array("resp"=>"HIBA! A válaszolási idő 15 - 99 másodperc legyen!!"));
		}
		elseif($_POST['showcorr1'] != 1 && $_POST['showcorr1'] != 2)
		{
			echo json_encode(array("resp"=>"HIBA! Nincs kiválasztva a helyes válaszok mutatása opció!"));
		}
		elseif($_POST['rejtetten1'] != 0 && $_POST['rejtetten1'] != 1)
		{
			echo json_encode(array("resp"=>"HIBA! Ismeretlen hiba a névtelen kérés jelölőnégyzet bejelölésénél!"));
		}
		elseif($_POST['kerdszamkot1'] > 0 && !preg_match("/^[0-9]+$/", $_POST["kerdszamkot1"]) || $_POST['kerdszamkot1'] > 99)
		{
			echo json_encode(array("resp"=>"HIBA! Helytelen érték az Általad kért kérdések mezőben! Ez a szám nem lehet nagyobb 99-nél!"));
		}
		elseif($_POST['acceptconditions1'] != 1)
		{
			echo json_encode(array("resp"=>"HIBA! A szabályzat elfogadása kötelező!"));
		}
		else
		{
			if($_POST['kerdszamkot1'] >= 0)
			{
				$kot = $_POST['kerdszamkot1'];
			}
			else
			{
				$kot = -1;
			}
			$con = connect();	
			mysqli_query($con, "SET @p_response");
			mysqli_query($con, "CALL create_request('" . mysqli_real_escape_string($con, $_POST['cim1']) . "', '" . mysqli_real_escape_string($con, $_POST['leiras1']) . "', '" . mysqli_real_escape_string($con, $_POST['points']) . "', '" . mysqli_real_escape_string($con, $_POST['nyelv1']) . "', '" . mysqli_real_escape_string($con, $_POST['kerdszam1']) . "', '" . mysqli_real_escape_string($con, $kot) . "', '" . mysqli_real_escape_string($con, $_POST['valsec1']) . "', '" . mysqli_real_escape_string($con, $_POST['showcorr1']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $_POST['rejtetten1']) . "', @p_response)");
			$q = "SELECT @p_response AS uzenet";
			$res = mysqli_query($con, $q);
			$row = mysqli_fetch_assoc($res);
			$kiir = $row['uzenet'];
			mysqli_close($con);	
			if($kiir == "Sikeres művelet!")
			{
				$kiir = "mindenok";
			}
			echo json_encode(array("resp"=>"$kiir"));
		}
	}
	else
	{
		echo json_encode(array("resp"=>err_missing_data()));
	}
}
else
{
	require_once("../error.php");
}
}
?>