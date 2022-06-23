<?php
session_start();

require_once("../db/db_connect.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");

function getRandomString($n) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $randomString = '';
  
    for ($i = 0; $i < $n; $i++) {
        $index = rand(0, strlen($characters) - 1);
        $randomString .= $characters[$index];
    }
  
    return $randomString;
}

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
	$allright = true;
	if(logoff_ajax()==-1)
	{
		echo err_session_timeout();
	}
	elseif(!isset($_POST['p_quizid']) || !preg_match("/^[0-9]+$/", $_POST["p_quizid"]) || $_POST["p_quizid"] < 1 )
    {
		echo "Helytelen érték: p_quizid!";
		$allright = false;
    }
	else
	{
		$newskep = "";
		if(isset($_FILES["p_bgimage"]["name"]))
		{
			if(count(array($_FILES["p_bgimage"]["tmp_name"])) == 1)
			{
				if($_FILES["p_bgimage"]["name"] != '')
				{			
					$imgname = pathinfo(basename($_FILES["p_bgimage"]["name"]));
					if(strlen($imgname['filename'])>50)
					{
						$allright = false;
						echo "A kép neve túl hosszú. Nevezd át a feltöltés folytatásához. Max 50 karakter hosszú lehet!";
					}
					$imgname = str_replace(' ', '', $imgname);
					$imgbase = basename($_FILES["p_bgimage"]["name"]);
					$imgsize = round($_FILES['p_bgimage']['size']/1024/1024, 2); // meret MB-ban
					$accepted_extensions = array("jpg", "jpeg", "png");
					$imgext = strtolower($imgname['extension']);
					$t=time();
					$imgnewname = getRandomString(11) . $_SESSION['user_id'] . $t . "." . $imgext;
					
					if($imgsize > 0.5)
					{
						$allright = false;
						echo "A kép maximális mérete 0.5 MB lehet!";
					}
					if(!in_array($imgext, $accepted_extensions))
					{
						$allright = false;
						echo "A kép formátuma nem elfogadott!";
					}
					
					if($allright == true)
					{
						$newskep = "ok";
					}
				}
				else
				{
					$newskep = "";
					$allright = false;
				}
			}
			else
			{
				$allright = false;
				echo "Csak 1 képet lehet feltölteni!";
			}
		}
		else
		{
			$newskep = "";
			$allright = false;
		}
		
		if($allright == true && $newskep != "")
		{
			$image_path = "documents/images/quizbackgrounds/" . $_POST['p_quizid'] . "/" . $imgnewname;
			$image_size = $imgsize;
		
			$con = connect();
			if(!$con)
			{
				die(err_db());
			}	
			mysqli_query($con, "SET @p_response");
			mysqli_query($con, "CALL upload_quizbackground('" . mysqli_real_escape_string($con, $_POST['p_quizid']) . "', '" . mysqli_real_escape_string($con, $image_path) . "', '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', '" . mysqli_real_escape_string($con, $image_size) . "', '" . mysqli_real_escape_string($con, $imgext) . "', @p_response)");
			$q = "SELECT @p_response AS p_response";
			$res = mysqli_query($con, $q);
			$row = mysqli_fetch_assoc($res);
			$kiir = $row['p_response'];
			mysqli_close($con);	
			if($kiir == "")
			{
				if($newskep == "ok")
				{
					$location_img = '../documents/images/quizbackgrounds/' . $_POST['p_quizid'] . "/" . $imgnewname;

					$directoryName = '../documents/images/quizbackgrounds/' . $_POST['p_quizid'];
					if(!is_dir($directoryName))
					{
						mkdir($directoryName, 0755);
					}
					move_uploaded_file($_FILES["p_bgimage"]["tmp_name"], $location_img);
				}
				echo "ok";
			}
			else
			{
				echo $kiir;
			}
		}
		else
		{
			echo "Hiba történt! Nem sikerült feltölteni a képet!";
		}
	}
}
else
{
	require_once("../error.php");
}
	
}

?>
