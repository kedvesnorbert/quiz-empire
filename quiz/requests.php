<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_requests.php");
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

$request_limit = 5;

function request_listing($mitkeres, $holkeres, $request_limit)
{
	if($request_limit < 1)
	{
		echo err_db();
		return;
	}
	$all_request = db_numrowsReq($mitkeres, $holkeres);
	$number_of_pages = ceil($all_request/$request_limit);
	if(!isset($_GET['pageReq']))
	{
		$pageReq = $_GET['pageReq'] = 1;
	}
	else
	{
		if(preg_match("/^[0-9]+$/", $_GET['pageReq']) && $_GET['pageReq'] > 0)
		{
			$pageReq = $_GET['pageReq'];

		}
		else
		{
			$pageReq = 1;			
		}
	}
	$this_page_first_result = ($pageReq-1)*$request_limit;
	$res = db_request_list($this_page_first_result, $mitkeres, $holkeres, $request_limit);
	if (!$res)
	{
		die(err_db());
	}
	
	request_pagination($number_of_pages, $pageReq, $mitkeres, $holkeres);
	
	?>
	<table id="tableId" class="table table-striped table-hover">
	<tr id='fejlec' class='table-secondary'>
		<th style='width:35%' class='align-middle'>Kérés neve
		<th style='width:10%' class='align-middle'>Pontok
		<th style='' class='align-middle'>Kérve
		<th style='' class='align-middle'>Kérdések
		<th style='width:14%' class='align-middle'>Kérte
		<th style='width:13%' class='align-middle'>Kérés ideje
		<th style='width:10%' class='align-middle'>Teljesítés
	<?php
	$i = 1;
	$res1 = db_getRang();
	if(!$res1)
	{
		die(err_db());
	}
	$row1 = mysqli_fetch_assoc($res1);
	while ($row = mysqli_fetch_assoc($res))
	{
		$ki_a_kero = $row['requested_by'];
		$el_van_vallalva = $row['is_undertaken'];
		if($row['anonymus_request'] == 1)
		{
			$row['requested_by'] = "Anonymus";
		}
		if($row['minimum_requested_quest'] > $row['byuser_minreq_quest']) 
		{
			$nagyobb = $row['minimum_requested_quest']; 
		}
		else 
		{
			$nagyobb = $row['byuser_minreq_quest'];
		}
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
		if($row['is_undertaken'] == 0)
		{
			$row['is_undertaken'] = "Nincs";
		}
		else
		{
			$row['is_undertaken'] = "Igen";
		}

		if($i%2)
		{
			echo "<tr id='reqDet' class='table-info'>\n";			
		}
		else
		{
			echo "<tr id='reqDet' class='table-secondary'>\n";
		}

		echo "<td align='left' style='font-weight:bold;' class='align-middle'>"; ?><a href="#" class="toggler" data-prod-cat="<?php echo $row['id_number']; ?>"> <?php echo $row['quiz_name']; ?></a><?php echo "\n";
		$ptemp_id = "requestpoints" . $row['id_number'];
		echo "<td align='center' class='align-middle'><span id='$ptemp_id'>" . floor($row['felajanlottpontok']/2) . "</span>\n";
		
		$ptemp1_id = "requestvoters" . $row['id_number'];
		echo "<td align='center' class='align-middle'><span id='$ptemp1_id'>" . $row['szavaz'] . "</span>\n";
		
		$ptemp2_id = "requestquestions" . $row['id_number'];
		echo "<td align='center' class='align-middle'><span id='$ptemp2_id'>" . $nagyobb . "</span>\n";
		
		$ptemp3_id = "requestusername" . $row['id_number'];
		echo "<td align='center' class='align-middle'><span id='$ptemp3_id'>" . $row['requested_by'] . "</span>\n";
		
		$ptemp4_id = "requestdatetime" . $row['id_number'];
		echo "<td align='center' class='align-middle'><span id='$ptemp4_id'>" . $row['request_date'] . "</span>\n";
		if($el_van_vallalva == 0)
		{
			if($row1['level'] > 4)
			{
				$anonym = 1;
			}
			else
			{
				$anonym = 0;
			}
			echo "<td align='center' class='align-middle'>" ?><span id='<?php echo "spanbutton" . $row["id_number"] ?>'>
			<button class="btn btn-danger" id="accomplish_request" onclick='accomplish_req("<?php echo $row["id_number"] ?>", "<?php echo $row['quiz_name'] ?>", <?php  echo $anonym ?>)'>Teljesítés</button></span>
			<div id="dialogAccomplishRequest" title="Kérés teljesítése" style="display:none;"></div>
			<?php echo "\n";
		}
		else
		{
			echo "<td align='center' class='align-middle'>"; 
			?><span id='<?php echo "spanbutton" . $row["id_number"] ?>'>Folyamatban</span>
			<?php echo "\n";
		}
		
		if($i%2)
		{
			echo "<tr class='table-secondary' id='detail" . $row["id_number"] . "' style='display:none;'>";
		}
		else
		{
			echo "<tr class='table-secondary' id='detail" . $row["id_number"] . "' style='display:none;'>";
		}
		$i++;

		?>
			<?php echo "<td colspan='9'>"; ?><br>
			<div id='other_quizinfo'>
			Részletek:<br><br>
			<b>A kvíz nyelve: </b><?php echo $row['language'] . "\n"; ?><br>
			<b>Válaszolási idő: </b><?php echo $row['time_to_answer'] . "\n"; ?> másodperc / kérdés<br>
			<b>Helyes válaszok megmutatása: </b><?php echo $row['show_answers'] . "\n"; ?><br>
			<b>Teljesítés elvállalva: </b><?php echo $row['is_undertaken'] . "\n"; ?><br>

			<div class="myInlineDiv">
			<br><b><span>Pontok felajánlása: </span></b>
			<input type="text" class="myoffer" id="<?php echo "myoffer" . $row['id_number'] ?>" required>
			<button type="submit" class="btn btn-success" id="offerPoints" onclick='offerPoints("<?php echo $row['id_number'] ?>")'>MEHET</button>
			<span>A beírt pontokat levonjuk tőled és a felét hozzáadjuk a kérésre felajánlott pontokhoz.
			A minimálisan megadandó pontszám 30 pont. Csak a számot írd be!</span>
			</div>

			<br><br><b>Részletes leírás: </b><?php echo nl2br(htmlentities($row['description'])) . "\n"; ?><br>
			
			<?php 
			if($ki_a_kero == $_SESSION['user']) { ?>
				<br><b>Saját kérés törlése: </b>
				<button type="submit" id="delmyreq" class="btn btn-danger" onclick='delete_myrequest("<?php echo $row['id_number'] ?>", "<?php echo $row['quiz_name'] ?>")'>TÖRLÉS</button>
				<div id="dialogDelMyRequest" title="Kérés törlése" style="display:none;"></div>
			<?php }
			if($el_van_vallalva == 1 && $row['undertaken_by'] == $_SESSION['user'])
			{
				?>
				<br><b>A kérés teljesítésének állapota: </b>
				<br><span id='blackspan'>- Eddig beküldött kérdések: </span>
					<span id='greenspan'><?php echo $row['osszesk']; ?></span>
				<br><span id='blackspan'>- Ebből ellenőrzive: </span>
					<span id='redspan'><?php echo $row['ellenorzottk']; ?></span>
				<br><span id='blackspan'>- Ebből ELFOGADVA: </span>
					<span id='greenspan'><?php echo $row['elfogadottk'] . " / " . $nagyobb; ?></span>
				<br><span id='blackspan'>- Teljesítésre vállalt határidő: </span>
					<span id='redspan'><?php echo $row['accomplish_deadline']; ?></span>
				
				<br><br>
				<button class="btn btn-info" id="<?php echo "reqquestionlist" . $row['id_number']; ?>" onclick='show_sentreqquestions("<?php echo $row['id_number']; ?>", "<?php echo $row['quiz_name']; ?>")'>Beküldött kérdések</button>
				<div id="dialogShowReqQuestionList" class="<?php echo "dialogShowReqQuestionList" . $row['id_number']; ?>" title="Kérdések megtekintése" style="display:none;"></div>
				<?php
			}
			?></div><?php	
	}
	?>
	</table>
	<?php
	if(mysqli_num_rows($res) < 1)
	{
		echo "<table id='tableNotFound'><tr><td align='center'>Nincs találat! <br>Keresési javaslat: használj más, kevesebb kifejezést! </tr> </table>";
	}
	
	request_pagination($number_of_pages, $pageReq, $mitkeres, $holkeres);
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

function request_pagination($number_of_pages, $pageReq, $mitkeres, $holkeres)
{
	if(preg_match("/^[0-9]+$/", $_GET['pageReq']))
	{
		$prev = $_GET['pageReq'] - 1;
		$next = $_GET['pageReq'] + 1;
	}
	else
	{
		$prev = 1;
		$next = 2;
	}
	?><br>
	<nav aria-label="Page navigation example mt-5">
		<ul class="pagination justify-content-center">
		<li class="page-item <?php if($_GET['pageReq'] <= 1){ echo 'disabled'; } ?>">
		<a class="page-link"
		href="<?php if($_GET['pageReq'] <= 1){ echo '#'; } else { echo 'requests.php?pageReq=' . $prev . '&nameOfReq=' . $mitkeres . '&whereSearchReq=' . $holkeres . '&startSearchReq=KERES"'; } ?>">Előbbi</a>
		</li>
		<?php 
		$page_nums = get_page_numbers($number_of_pages, $_GET['pageReq']);
		for($i = 0; $i < count($page_nums); ++$i ):
			if($page_nums[$i] != "...")
			{
				?><li class="page-item <?php if($_GET['pageReq'] == $page_nums[$i]) {echo 'active'; } ?>">
				<a class="page-link" href="<?php echo 'requests.php?pageReq=' . $page_nums[$i] . '&nameOfReq=' . $mitkeres . '&whereSearchReq=' . $holkeres . '&startSearchReq=KERES'; ?>"> <?php echo $page_nums[$i] ?> </a><?php
			}
			else
			{
				?><li class="page-item disabled">
				<a class="page-link" href="<?php echo 'requests.php?pageReq=' . $page_nums[$i] . '&nameOfReq=' . $mitkeres . '&whereSearchReq=' . $holkeres . '&startSearchReq=KERES'; ?>"> <?php echo $page_nums[$i] ?> </a><?php
			}
		?>
		</li>
		<?php endfor; ?>
		<li class="page-item <?php if($_GET['pageReq'] >= $number_of_pages) { echo 'disabled'; } ?>">
		<a class="page-link"
		href="<?php if($_GET['pageReq'] >= $number_of_pages){ echo '#'; } else {echo 'requests.php?pageReq=' . $next . '&nameOfReq=' . $mitkeres . '&whereSearchReq=' . $holkeres . '&startSearchReq=KERES'; } ?>">Következő</a>
		</li>
		</ul>
	</nav>
	<?php
}

function request_searching()
{
	?>
	<div class="container" style="text-align:center;padding-left:0px;padding-right:0px;">
		<h2>Keress a kérések között!</h2>
		<p>Böngéssz az alábbi kérések között, vagy kérj egy újat!</p><br>
		
		<button class="btn btn-primary" onclick="location.href='newrequest.php'">Új Kérés kiírás</button>
		<button class="btn btn-info" onclick="window.location.href='wiki.php?whatRules=1';">Szabályzat</button>
		
		<form class="form-inline justify-content-center" action="requests.php" method="GET">
			<input type="text" class="form-control" id="nameOfReq" name="nameOfReq" placeholder="Kérés neve..." <?php if (isset($_GET["nameOfReq"])) echo "value=\"" . $_GET["nameOfReq"] . "\""; ?>>
			
			<select id="whereSearchReq" name="whereSearchReq" class="form-control">
				<option value="1" <?php if(isset($_GET['whereSearchReq'])) echo $_GET['whereSearchReq'] == '1' ? ' selected="selected"' : ''; ?>>Összes kérés</option>
				<option value="2" <?php if(isset($_GET['whereSearchReq'])) echo $_GET['whereSearchReq'] == '2' ? ' selected="selected"' : ''; ?>>Saját kérések</option>
				<option value="3" <?php if(isset($_GET['whereSearchReq'])) echo $_GET['whereSearchReq'] == '3' ? ' selected="selected"' : ''; ?>>Szavazott kéréseim</option>
				<option value="4" <?php if(isset($_GET['whereSearchReq'])) echo $_GET['whereSearchReq'] == '4' ? ' selected="selected"' : ''; ?>>Elvállalt kéréseim</option>
			</select>

			<button type="submit" id="startSearchReq" class="btn btn-success" name="startSearchReq">Keresés</button>
		</form>
	</div>
	<?php
}
?>

<html>
<head>
	<title>Kérések</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/requests.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/jQuery-ui.css">
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css"> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/requests.js"></script>
	<script type = "text/javascript" src="js/menu.js"></script>
</head>
<body style="">
<?php
main_menu();
request_searching();

if(isset($_GET['startSearchReq']))
{
	if(!isset($_GET['nameOfReq']))
		$_GET['nameOfReq'] = ""; 
	$mitk = "";
	if(!empty($_GET['nameOfReq']) && strlen($_GET['nameOfReq']) > 0 && strlen($_GET['nameOfReq']) < 50)
	{
		$mitk = $_GET['nameOfReq'];
	}
	else
	{
		$_GET['nameOfReq'] = $mitk = ""; 
	}
	
	if(!isset($_GET['whereSearchReq']))
	{
		$_GET['whereSearchReq'] = 1;
	}
	$holKeres = 1;
	if(preg_match("/^[0-9]+$/", $_GET['whereSearchReq']) && $_GET['whereSearchReq'] > 0 && $_GET['whereSearchReq'] < 5)
	{
		$holKeres = $_GET['whereSearchReq'];
	}
	else
	{
		$holKeres = $_GET['whereSearchReq'] = 1;
	}
	request_listing($mitk, $holKeres, $request_limit);
}
else{
	request_listing("", 1, $request_limit);
}
?>
</body>
</html>