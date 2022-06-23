<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_quizzes.php");
require_once("includes/update_logoff.php");
require_once("includes/ip_functions.php");
require_once("includes/responses.php");
require_once("view/menu.php");

if(!isset($_SESSION["user"]))
{
	$fromurl = urlencode($_SERVER["REQUEST_URI"]);
	setcookie("fromwhere", $fromurl);
	header("location: login.php");
	$_SESSION = array();
	session_destroy();
}

$quizlimit = 14;

function quiz_listing($mitkeres, $holkeres, $kviznyelve, $quizlimit)
{
	if($quizlimit < 1)
	{
		echo err_db();
		return;
	}
	$all_quizzes = db_numrowsQuiz($mitkeres, $holkeres, $kviznyelve);
	$number_of_pages = ceil($all_quizzes/$quizlimit);
	if(!isset($_GET['pageQuiz']))
	{
		$pageQuiz = $_GET['pageQuiz'] = 1;
	}
	else
	{
		if(preg_match("/^[0-9]+$/", $_GET['pageQuiz']) && $_GET['pageQuiz'] > 0 && $_GET['pageQuiz'] <= $number_of_pages)
		{
			$pageQuiz = $_GET['pageQuiz'];
		}
		else
		{
			$pageQuiz = 1;			
		}
	}
	$this_page_first_result = ($pageQuiz-1)*$quizlimit;
	$res = db_quiz_list($this_page_first_result, $mitkeres, $holkeres, $kviznyelve, $quizlimit);
	if (!$res)
	{
		die(err_db());
	}
	quiz_pagination($number_of_pages, $pageQuiz, $mitkeres, $kviznyelve, $holkeres);
	?>
	
	<table id="tableKvizId" class="table table-striped table-hover">
	<tr class="fejlecQ">
		<th style='width:35%;'>Kvíz neve
		<th style='width:9%;'>Nyelv
		<th style='width:9%;'>Kérdések
		<th style='width:9%;'>Átmenő
		<th style='width:9%;'>Beküldő
		<th style='width:9%;'>Megjelenés
		<th style='width:10%;'>Indítás
	<?php
	$i = 1;
	while ($row = mysqli_fetch_assoc($res))
	{
		$ki_a_bekuldo = $row['accomplished_by'];
		if($row['anonymus_accomplish'] == 1)
			$row['accomplished_by'] = "Anonymus";
		if($row['language'] == 1)
		{
			$row['language'] = 'Magyar';
		}
		elseif($row['language'] == 2)
		{
			$row['language'] = 'Angol';
		}
		if($row['show_answers'] == 1)
		{
			$row['show_answers'] = 'Engedélyezve';
		}
		elseif($row['show_answers'] == 2)
		{
			$row['show_answers'] = 'Nincs engedélyezve';
		}
		if($row['num_of_playing'] == 0)
		{
			$row['num_of_playing'] = "korlátlan";
		}
		if($row['start_date'] == '')
		{
			$row['start_date'] = "Nincs korlátozva";
		}
		if($row['end_date'] == '')
		{
			$row['end_date'] = "Nincs korlátozva";
		}

		if($i%2)
		{
			echo "<tr id='quizDet' class='table-success'>\n";
		}
		else
		{
			echo "<tr id='quizDet' class='table-secondary'>\n";
		}
		
		echo "<td align='left' style='font-weight:bold;' class='align-middle'>"; ?><a href="#" class="togglerQ" data-prod-cat="<?php echo $row['id_number']; ?>"> <?php echo $row['quiz_name']; ?></a><?php echo "\n";
		echo "<td align='center' class='align-middle'>" . $row['language'] . "\n";
		echo "<td align='center' class='align-middle'>" . $row['num_of_question'] . "\n";
		echo "<td align='center' class='align-middle'>" . $row['pass_degree'] . "%\n";
		echo "<td align='center' class='align-middle'>" . $row['accomplished_by'] . "\n";
		echo "<td align='center' class='align-middle'>" . $row['accomplish_date'] . "\n";
		echo "<td align='center' class='align-middle'>" ?>
		
		<button class="btn btn-success" id="startQuiz" onclick='show_beforestartquiz("<?php echo $row["id_number"] ?>", "<?php echo $row["quiz_name"] ?>", "<?php echo $row["time_to_answer"] ?>", "<?php echo $row["num_of_question"] ?>", "<?php echo $row["access"] ?>", "<?php echo $_GET['pageQuiz'] ?>", "<?php echo $mitkeres ?>", "<?php echo $kviznyelve ?>", "<?php echo $holkeres ?>", "<?php echo 0 ?>")'>Kvíz indítása</button>
		<div id="dialogBeforeStartQuiz" title="Kvíz indítása" style="display:none;"></div>
		<?php
		if($i%2)
		{
			echo "<tr class='table-success' id='detailQ" . $row["id_number"] . "' style='display:none;'>";
		}
		else
		{
			echo "<tr class='table-secondary' id='detailQ" . $row["id_number"] . "' style='display:none;'>";
		}
		$i++;
		echo "<td colspan='7'>"; ?>
			<div id='other_quizinfo'>
			<input type="button" id="goToQuizPage" onclick="window.location.href='quizdetails.php?quiz_id=<?php echo $row['id_number'] ?>'" value="Tovább a kvíz oldalára"> 	
			<?php
			if($row["kedvenc"] > 0)
			{
				?>
				<button class='removeFromFavorites' id="<?php echo "removeFromFavorites" . $row['id_number']; ?>" onclick='remove_from_favorites("<?php echo $row["id_number"] ?>", "<?php echo $row["quiz_name"] ?>")'>Törlés a kedvencekből</button>
				<div id="dialogRemoveFromFavorites" class="<?php echo "dialogRemoveFromFavorites" . $row['id_number']; ?>" title="Eltávolítás a kedvencekből" style="display:none;"></div>
				<div id="dialogAddToFavorites" class="<?php echo "dialogAddToFavorites" . $row['id_number']; ?>" title="Hozzáadás a kedvencekhez" style="display:none;"></div>					
				<?php
			}
			else
			{
				?>
				<button class="addToFavorites" id="<?php echo "addToFavorites" . $row['id_number']; ?>" onclick='add_to_favorites("<?php echo $row["id_number"] ?>", "<?php echo $row["quiz_name"] ?>")'>Hozzáadás a kedvencekhez</button>
				<div id="dialogAddToFavorites" class="<?php echo "dialogAddToFavorites" . $row['id_number']; ?>" title="Hozzáadás a kedvencekhez" style="display:none;"></div>
				<div id="dialogRemoveFromFavorites" class="<?php echo "dialogRemoveFromFavorites" . $row['id_number']; ?>" title="Eltávolítás a kedvencekből" style="display:none;"></div>
				<?php
			}
			?>
			
			<br>További információ:<br><br>
			<b>Összes próbálkozási lehetőség: </b><?php echo $row['num_of_playing'] . "\n"; ?> alkalommal.
			<?php  
			if($row['num_of_playing'] > 0)
			{
				$alkalmak = $row['num_of_playing'] - $row['osszessajatalkalom'];
				if($alkalmak > 0)
				{
					?><span id='is_more_possibility'>( Hátramaradt még: <?php echo $alkalmak ?> alkalom )</span><?php
				}
				else
				{
					?><span id='no_more_possibility'>( Nem maradt több próbálkozási lehetőség! )</span><?php
				}	
			}
			?><br>
			<b>Egy kérdésre jutó válaszolási idő: </b><?php echo $row['time_to_answer'] . "\n"; ?> másodperc<br>
			<b>Helyes válaszok megmutatása: </b><?php echo $row['show_answers'] . "\n"; ?><br>
			<b>Indulás dátuma: </b><i><?php echo $row['start_date'] . "\n"; ?></i><br>
			<b>Lezárulás dátuma: </b><i><?php echo $row['end_date'] . "\n"; ?></i><br>
			<b>Népszerűség: </b> 
			<?php
			$d_szam = $row['osszesalkalom'];
			if($ki_a_bekuldo == $_SESSION['user'])
			{
				echo $d_szam; 
			}
			else
			{
				echo get_quiz_popularity($d_szam);	
			}
			 
			?><br><br><b>Részletes leírás: </b><?php echo nl2br(htmlentities($row['description'])) . "\n"; ?>

		</div><?php	
	}
	?>
	</table>
	<?php
	if(mysqli_num_rows($res) < 1)
	{
		echo "<table id='tableNotFound'><tr><td align='center'>Nincs találat!<br>Keresési javaslat: használj más, kevesebb kifejezést! </tr> </table>";
	}

	quiz_pagination($number_of_pages, $pageQuiz, $mitkeres, $kviznyelve, $holkeres);
}

function get_quiz_popularity($popularity)
{
	if($popularity == 0)
	{
		return "0";
	}
	if($popularity > 0 && $popularity <=10)
	{
		return "+";
	}
	if($popularity > 10 && $popularity <100)
	{
		return "++";
	}
	if($popularity >= 100 && $popularity <1000)
	{
		return "+++";
	}
	if($popularity >= 1000 && $popularity <10000)
	{
		return "++++";
	}
	return "+++++";
}

function get_page_numbers($n, $akt){
	$arr = array();
    if($n <= 7)
    {
    	for($i=1; $i <= $n; ++$i)
        {
        	array_push($arr, $i);
        }
		return $arr;
    }
    
	if($akt <=3)
	{
		array_push($arr, 1, 2, 3, 4, "...", ($n-2),($n-1), $n);
		return $arr;
	}
	if($akt >= ($n-3))
	{
		array_push($arr, 1, 2, "...", ($n-4), ($n-3), ($n-2), ($n-1), $n);
		return $arr;
	}
	if(($akt-3) > 0)
	{
		array_push($arr, 1);
		array_push($arr, "...");
		array_push($arr, $akt-2);
		array_push($arr, $akt-1);
		array_push($arr, $akt);
	}
		
	if($n > ($akt+3))
	{
		array_push($arr, $akt+1);
		array_push($arr, $akt+2);
		array_push($arr, "...");
		array_push($arr, $n);
	}
	return $arr;
}

function quiz_pagination($number_of_pages, $pageQuiz, $mitkeres, $kviznyelve, $holkeres)
{
	if(preg_match("/^[0-9]+$/", $_GET['pageQuiz']))
	{
		$prev = $_GET['pageQuiz'] - 1;
		$next = $_GET['pageQuiz'] + 1;
	}
	else
	{
		$prev = 1;
		$next = 2;
	}
	?><br>
	<nav aria-label="Page navigation example mt-5">
		<ul class="pagination justify-content-center">
		<li class="page-item <?php if($_GET['pageQuiz'] <= 1){ echo 'disabled'; } ?>">
		<a class="page-link"
		href="<?php if($_GET['pageQuiz'] <= 1){ echo '#'; } else { echo 'quizzes.php?pageQuiz=' . $prev . '&nameOfQuiz=' . $mitkeres . '&langOfQuiz=' . $kviznyelve . '&whereSearchQuiz=' . $holkeres . '&startSearchQuiz=KERES'; } ?>">Előbbi</a>
		</li>
		<?php 
		$page_nums = get_page_numbers($number_of_pages, $_GET['pageQuiz']);
		for($i = 0; $i < count($page_nums); ++$i ):
			if($page_nums[$i] != "...")
			{
				?><li class="page-item <?php if($_GET['pageQuiz'] == $page_nums[$i]) {echo 'active'; } ?>">
				<a class="page-link" href="<?php echo 'quizzes.php?pageQuiz=' . $page_nums[$i] . '&nameOfQuiz=' . $mitkeres . '&langOfQuiz=' . $kviznyelve . '&whereSearchQuiz=' . $holkeres . '&startSearchQuiz=KERES'; ?>"> <?php echo $page_nums[$i] ?> </a><?php
			}
			else
			{
				?><li class="page-item disabled">
				<a class="page-link" href="<?php echo 'quizzes.php?pageQuiz=' . $page_nums[$i] . '&nameOfQuiz=' . $mitkeres . '&langOfQuiz=' . $kviznyelve . '&whereSearchQuiz=' . $holkeres . '&startSearchQuiz=KERES'; ?>"> <?php echo $page_nums[$i] ?> </a><?php
			}
		?>
		</li>
		<?php endfor; ?>
		<li class="page-item <?php if($_GET['pageQuiz'] >= $number_of_pages) { echo 'disabled'; } ?>">
		<a class="page-link"
		href="<?php if($_GET['pageQuiz'] >= $number_of_pages){ echo '#'; } else {echo 'quizzes.php?pageQuiz=' . $next . '&nameOfQuiz=' . $mitkeres . '&langOfQuiz=' . $kviznyelve . '&whereSearchQuiz=' . $holkeres . '&startSearchQuiz=KERES'; } ?>">Következő</a>
		</li>
		</ul>
	</nav>
	<?php
}

function quiz_searching()
{
	?>
	<div class="container" style="text-align:center;padding-left:0px;padding-right:0px;">
		<h2>Böngéssz a kvízek között!</h2>
		<p>Keress rá kedvenc kvízeidre, vagy próbáld ki a legújabbakat!</p>
		<form class="form-inline justify-content-center" action="quizzes.php" method="GET">
			<input type="text" class="form-control" id="nameOfQuiz" name="nameOfQuiz" placeholder="Kvíz neve" <?php if (isset($_GET["nameOfQuiz"])) echo "value=\"" . $_GET["nameOfQuiz"] . "\""; ?>>
			
			<select id="whereSearchQuiz" name="whereSearchQuiz" class="form-control">
				<option value="1" <?php if(isset($_GET['whereSearchQuiz'])) echo $_GET['whereSearchQuiz'] == '1' ? ' selected="selected"' : ''; ?>>Összes kvíz</option>
				<option value="2" <?php if(isset($_GET['whereSearchQuiz'])) echo $_GET['whereSearchQuiz'] == '2' ? ' selected="selected"' : ''; ?>>Saját kvízek</option>
				<option value="3" <?php if(isset($_GET['whereSearchQuiz'])) echo $_GET['whereSearchQuiz'] == '3' ? ' selected="selected"' : ''; ?>>Elérhető kvízek</option>
				<option value="4" <?php if(isset($_GET['whereSearchQuiz'])) echo $_GET['whereSearchQuiz'] == '4' ? ' selected="selected"' : ''; ?>>Kedvencek</option>
			</select>

			<select id="langOfQuiz" name="langOfQuiz" class="form-control">
				<option value="0" <?php if(isset($_GET['langOfQuiz'])) echo $_GET['langOfQuiz'] == '0' ? ' selected="selected"' : ''; ?>>Bármilyen nyelvű
				<option value="1" <?php if(isset($_GET['langOfQuiz'])) echo $_GET['langOfQuiz'] == '1' ? ' selected="selected"' : ''; ?>>MAGYAR
				<option value="2" <?php if(isset($_GET['langOfQuiz'])) echo $_GET['langOfQuiz'] == '2' ? ' selected="selected"' : ''; ?>>ANGOL
			</select>
			
			<button type="submit" id="startSearchQuiz" class="btn btn-success" name="startSearchQuiz">Keresés</button>
		</form>
	</div>
	<?php
}

?>
<html>
<head>
	<title>Kvízek böngészése</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/quizzes.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/jQuery-ui.css">
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css">
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script>
  	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script>
	<script type = "text/javascript" src="includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/quizzes.js"></script>
	<script type = "text/javascript" src="js/menu.js"></script>
	
</head>

<body style="background-color:#ffffff;">
<?php
main_menu();
quiz_searching();

if(isset($_GET['startSearchQuiz']))
{
	if(!isset($_GET['nameOfQuiz']))
		$_GET['nameOfQuiz'] = ""; 
	$mitk = "";
	if(!empty($_GET['nameOfQuiz']) && strlen($_GET['nameOfQuiz']) > 0 && strlen($_GET['nameOfQuiz']) < 50)
	{
		$mitk = $_GET['nameOfQuiz'];
	}
	else
	{
		$_GET['nameOfQuiz'] = $mitk = ""; 
	}
	
	if(!isset($_GET['whereSearchQuiz']))
	{
		$_GET['whereSearchQuiz'] = 1;
	}
	$holKeres = 1;
	if(preg_match("/^[0-9]+$/", $_GET['whereSearchQuiz']) && $_GET['whereSearchQuiz'] > 0 && $_GET['whereSearchQuiz'] < 5)
	{
		$holKeres = $_GET['whereSearchQuiz'];
	}
	else
	{
		$holKeres = $_GET['whereSearchQuiz'] = 1;
	}
	
	if(!isset($_GET['langOfQuiz']))
	{
		$_GET['langOfQuiz'] = 0;
	}
	$nyelvKeres = 0;
	if(preg_match("/^[0-9]+$/", $_GET['langOfQuiz']) && $_GET['langOfQuiz'] >=0 && $_GET['langOfQuiz'] < 3)
	{
		$langOfQuiz = $_GET['langOfQuiz'];
	}
	else
	{
		$langOfQuiz = $_GET['langOfQuiz'] = 1;
	}
	
	quiz_listing($mitk, $holKeres, $langOfQuiz, $quizlimit);
}
else
{
	quiz_listing("", 1, 0, $quizlimit);
}

?>
</body>
</html>