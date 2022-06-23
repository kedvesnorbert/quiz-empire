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
	$allright = true;
	if(logoff_ajax()==-1)
	{
		echo err_session_timeout();
	}
	elseif(!isset($_POST["the_newstitle"]) || strlen($_POST['the_newstitle']) < 5 || strlen($_POST['the_newstitle']) > 50)
	{
		echo "A hír címe 5-50 karakter legyen!";
		$allright = false;
	}
	elseif(!isset($_POST["the_newsdescription"]) || strlen($_POST['the_newsdescription']) < 25 || strlen($_POST['the_newsdescription']) > 3000)
	{
		echo "A hír leírása 25-3000 karakter legyen!";
		$allright = false;
	}
	else
	{
		$newskep = "";
		if(isset($_FILES["the_newsimage"]["name"]))
		{
			if(count(array($_FILES["the_newsimage"]["tmp_name"])) == 1)
			{
				if($_FILES["the_newsimage"]["name"] != '')
				{			
					$imgname = pathinfo(basename($_FILES["the_newsimage"]["name"]));
					
					$imgbase = basename($_FILES["the_newsimage"]["name"]);
					$imgsize = round($_FILES['the_newsimage']['size']/1024/1024, 2); // meret MB-ban
					$accepted_extensions = array("jpg", "jpeg", "png");
					$imgext = strtolower($imgname['extension']);
					$t=time();
					$imgnewname = "K_" . $imgname['filename'] . $_SESSION['user_id'] . "_" . $t . "." . $imgext;
					
					if($imgsize > 2)
					{
						$allright = false;
						echo "A kép maximális mérete 2 MB lehet!";
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
		}

		$newsfile = "";
		if(isset($_FILES["the_newsfiles"]["name"]))
		{
			if(count(array($_FILES["the_newsfiles"]["tmp_name"])) == 1)
			{
				if($_FILES["the_newsfiles"]["name"] != '')
				{			
					$filename = pathinfo(basename($_FILES["the_newsfiles"]["name"]));
					
					$filebase = basename($_FILES["the_newsfiles"]["name"]);
					$filesize = round($_FILES['the_newsfiles']['size']/1024/1024, 2); // meret MB-ban
					$accepted_extensions_file = array("docx", "zip", "pdf", "pptx");
					$fileext = strtolower($filename['extension']);
					$t=time();
					$filenewname = "F_" . $filename['filename'] . $_SESSION['user_id'] . "_" . $t . "." . $fileext;
					
					if($filesize > 4)
					{
						$allright = false;
						echo "A fájl maximális mérete 4 MB lehet!";
					}
					if(!in_array($fileext, $accepted_extensions_file))
					{
						$allright = false;
						echo "A fájl formátuma nem elfogadott!";
					}
					
					if($allright == true)
					{
						$newsfile = "ok";
					}
				}
				else
				{
					$newsfile = "";
				}
			}
			else
			{
				$allright = false;
				echo "Csak 1 fájlt lehet feltölteni!";
			}
		}
		else
		{
			$newsfile = "";
		}
		
		if($allright == true)
		{
			if($newskep != "")
			{
				$image_path = $imgnewname;
				$image_size = $imgsize;
			}
			else
			{
				$image_path = "";
				$image_size = 0;
			}
			if($newsfile != "")
			{
				$file_path = $filenewname;
				$file_size = $filesize;
				$file_name = $filebase;
			}
			else
			{
				$file_path = "";
				$file_size = 0;
				$file_name = "";
			}
			$con = connect();
			if(!$con)
			{
				die(err_db());
			}	
			mysqli_query($con, "SET @p_response");
			mysqli_query($con, "CALL post_news('" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "', '" . mysqli_real_escape_string($con, $_POST['the_newstitle']) . "', '" . mysqli_real_escape_string($con, $_POST['the_newsdescription']) . "', '" . mysqli_real_escape_string($con, $image_path) . "', '" . mysqli_real_escape_string($con, $file_path) . "', '" . mysqli_real_escape_string($con, $file_name) . "', '" . mysqli_real_escape_string($con, $image_size) . "', '" . mysqli_real_escape_string($con, $file_size) . "', @p_response)");
			$q = "SELECT @p_response AS p_response";
			$res = mysqli_query($con, $q);
			$row = mysqli_fetch_assoc($res);
			$kiir = $row['p_response'];
			mysqli_close($con);	
			if($kiir == "")
			{
				if($newskep == "ok")
				{
					$location_img = '../documents/images/newsimages/' . $imgnewname;  
					move_uploaded_file($_FILES["the_newsimage"]["tmp_name"], $location_img);
				}
				if($newsfile == "ok")
				{
					$location_file = '../documents/images/newsfiles/' . $filenewname;  
					move_uploaded_file($_FILES["the_newsfiles"]["tmp_name"], $location_file);
				}
				echo "mindenok";
			}
			else
			{
				echo $kiir;
			}
		}
		else{
			echo "Hiba történt! Nem sikerült közzétenni a hírt!";
		}
	}
}
else
{
	require_once("../error.php");
}
	
}

?>
