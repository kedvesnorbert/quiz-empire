<?php
session_start();

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}

require_once("../db/db_connect.php");
require_once("../ajax/sessiontimeout.php");


function db_gettest_data()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT k.question, k.ans1, k.ans2, k.ans3, k.ans4, k.difficulty, p.position, p.correct, p.own_answer, q.totalcorrect, q.finishing_date, q.score, t.pass_degree FROM quiz_played q JOIN played_quiz_question p ON (q.test_id = p.quiz_id) JOIN quiz_question k ON (p.question_id = k.id) JOIN thema t ON (k.quiz_id = t.id_number) WHERE q.test_id = '" . mysqli_real_escape_string($con, $_GET['test_id']) . "' ORDER BY p.position";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(mysqli_num_rows($res)>0)
	{
		return $res;
	}
	return false;
}

function db_gettest_user()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT u.user FROM quiz_played q JOIN user u ON (q.user_id = u.id) WHERE q.test_id = '" . mysqli_real_escape_string($con, $_GET['test_id']) . "'";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(mysqli_num_rows($res)>0)
	{
		$row = mysqli_fetch_assoc($res);
		return $row['user'];
	}
	return false;
}

function forbidden_pdf()
{
	require('fpdf.php');

	$pdf=new FPDF();
	$pdf->AddPage();
	$pdf->SetFont('Arial','B',16);
	$pdf->Cell(0,5,iconv("UTF-8", "CP1250//TRANSLIT", "Nincs jogod megtekinteni a kvíz eredményét!"),0,1,'L');
	$pdf->Cell(0,5,iconv("UTF-8", "CP1250//TRANSLIT", ""),0,1,'L');
	$pdf->SetFont('Arial','',16);
	$pdf->Cell(0,5,iconv("UTF-8", "CP1250//TRANSLIT", "Lehetséges okok: "),0,1,'L');
	$pdf->Cell(0,5,iconv("UTF-8", "CP1250//TRANSLIT", ""),0,1,'L');
	$pdf->SetFont('Arial','I',14);
	$pdf->Cell(0,5,iconv("UTF-8", "CP1250//TRANSLIT", "   - elfogyott az ellenőrzési lehetőségeid száma ennél a kvíznél."));
	$pdf->Cell(0,5,iconv("UTF-8", "CP1250//TRANSLIT", ""),0,1,'L');
	$pdf->Cell(0,5,iconv("UTF-8", "CP1250//TRANSLIT", "   - nem te vagy a kvíz feltöltője."));
	$pdf->Cell(0,5,iconv("UTF-8", "CP1250//TRANSLIT", ""),0,1,'L');
	$pdf->Cell(0,5,iconv("UTF-8", "CP1250//TRANSLIT", "   - nem a te kvízed eredményét próbálod megnézni."));
	$pdf->Cell(0,5,iconv("UTF-8", "CP1250//TRANSLIT", ""),0,1,'L');
	$pdf->Cell(0,5,iconv("UTF-8", "CP1250//TRANSLIT", "   - nem érted el legalább a 2. szintet."));
	$pdf->Output();
}

function topdf()
{
	require('fpdf.php');
	require('html_table.php');
	require('mc_table.php');

	$pdft=new PDF_MC_Table();
	$pdft->SetProtection(array('print'));
	$pdft->AddPage();
	$pdft->SetFont('Arial','',14);
	$title = "Felhasználó: <b>" . db_gettest_user() . "</b><br><br>Témakör: <i>" . rawurldecode($_GET['test_name']) . "</i><br><br><br>";
	$title = iconv('UTF-8', 'CP1250//TRANSLIT', $title);
	$pdft->WriteHTML($title);
	
	$res = db_gettest_data();
	if(!$res)
	{
		echo "Ez a teszt nem exportálható ki!";
		return false;
	}
	
	$pdft->SetFont('Times','I',13);
	$pdft->SetWidths(array(15,90,50,30));
	$a = "Nr.";
	$b = iconv('UTF-8', 'CP1250//TRANSLIT', "Kérdés szövege");
	$c = iconv('UTF-8', 'CP1250//TRANSLIT', "A te válaszod");
	$d = iconv('UTF-8', 'CP1250//TRANSLIT', "Helyesség");
	$pdft->SetFillColor(70,130,180);
	//$pdft->SetDrawColor(205,25,120);
	
	$pdft->Row(array($a, $b, $c, $d));
	
	$countrows = mysqli_num_rows($res);
	for($i=0;$i<$countrows;++$i)
	{
		$row = mysqli_fetch_assoc($res);
		$ownanswer = "";
		$ertekeles = "";
		if($row['correct'] == -1)
		{
			$ownanswer = "";
			$ertekeles = "Nincs";
		}
		else
		{
			if($row['own_answer'] == 1)
			{
				$ownanswer = $row['ans1'];
				$ertekeles = "HELYES";
			}
			elseif($row['own_answer'] == 2)
			{
				$ownanswer = $row['ans2'];
				$ertekeles = "Helytelen";
			}
			elseif($row['own_answer'] == 3)
			{
				$ownanswer = $row['ans3'];
				$ertekeles = "Helytelen";
			}
			elseif($row['own_answer'] == 4)
			{
				$ownanswer = $row['ans4'];
				$ertekeles = "Helytelen";
			}
		}
		
		$row['question'] = iconv('UTF-8', 'CP1250//TRANSLIT', $row['question']);
		$ownanswer = iconv('UTF-8', 'CP1250//TRANSLIT', $ownanswer);
		if($row['difficulty'] == 2)
		{
			$pdft->SetFont('Arial','B',12);
		}
		else
		{
			$pdft->SetFont('Arial','',12);
		}
		if($ertekeles == "Helytelen" || $ertekeles == "Nincs")
		{
			$pdft->SetTextColor(255, 0, 0);
		}
		else
		{
			$pdft->SetTextColor(0, 0, 0);
		}
		
		$pdft->Row(array($row['position'] . ".", $row['question'], $ownanswer, $ertekeles));
	}
		
	$pdft->WriteHTML("<br><br>");
	$pdft->SetFont('Arial','B',14);
	$pdft->SetTextColor(0, 0, 0);
	$a = "Helyes válaszok: " . $row['totalcorrect'] . " db";
	$a = iconv('UTF-8', 'CP1250//TRANSLIT', $a);
	$pdft->SetWidths(array(80,20,10,120));
	$pdft->RowNoBorder(array($a, "", "", ""));
	
	$pdft->SetFont('Arial','B',14);
	$pdft->SetTextColor(0, 0, 0);
	$a = "Átlag: " . $row['score'] . " %";
	$a = iconv('UTF-8', 'CP1250//TRANSLIT', $a);
	$pdft->SetWidths(array(80,20,10,120));
	$pdft->RowNoBorder(array($a, "", "", ""));
	
	$b = "A teszt eredménye:";
	if($row['score']>=$row['pass_degree'])
	{
		$b = "A teszt eredménye: SIKERES";
		$pdft->SetTextColor(0, 128, 0);
	}
	else
	{
		$b = "A teszt eredménye: Sikertelen";
		$pdft->SetTextColor(255, 0, 0);
	}
	
	$b = iconv('UTF-8', 'CP1250//TRANSLIT', $b);
	$pdft->SetWidths(array(90,10,10,120));
	$pdft->RowNoBorder(array($b, "", "", ""));
	$pdft->SetTextColor(0, 0, 0);
	$line = '<hr>';
	$line = iconv('UTF-8', 'CP1250//TRANSLIT', $line);
	$pdft->WriteHTML($line);
	
	$pdft->SetFont('Arial','I',12);
	$c = "A teszt időpontja: " . $row['finishing_date'];
	$c = iconv('UTF-8', 'CP1250//TRANSLIT', $c);
	$pdft->WriteHTML($c);
	
	$pdft->SetFont('Arial','I',12);
	$date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
    $date = $date->format('Y-m-d H:i:s');
	$c = "<br><br>Exportálás ideje: " . $date;
	$c = iconv('UTF-8', 'CP1250//TRANSLIT', $c);
	$pdft->WriteHTML($c);
	$pdft->Output();
	
}

if(!isset($_GET['test_id']) || !preg_match("/^[0-9]+$/", $_GET['test_id']) || $_GET['test_id'] < 1 || !isset($_GET['test_name']) || strlen($_GET['test_name'])< 2)
{
	forbidden_pdf();
}
else
{
	$con = connect();
	if(!$con)
	{
		die(mysqli_connect_error());
	}
	$res = mysqli_query($con, "SELECT export_pdf('" . mysqli_real_escape_string($con, $_GET['test_id']) . "', '" . $_SESSION['user_id'] . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "') AS visszaErtek");
	$row = mysqli_fetch_assoc($res);
	mysqli_close($con);
	if($row['visszaErtek'] != 1)
	{
		forbidden_pdf();
	}
	else
	{
		topdf();
	}
	
}

?>