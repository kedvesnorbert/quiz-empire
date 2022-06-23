<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_profile.php");
require_once("includes/responses.php");
require_once("includes/update.php");
require_once("includes/update_logoff.php");
require_once("includes/ip_functions.php");
require_once("view/menu.php");
require_once("view/view_profile.php");

if(!isset($_SESSION["user"]))
{
	$fromurl = urlencode($_SERVER["REQUEST_URI"]);
	setcookie("fromwhere", $fromurl);
	header("location: login.php");
	$_SESSION = array();
	session_destroy();
}

function toArray($res)
{
	if(!$res)
	{
		return false;
	}
	$resultarray = array();
	while($row = mysqli_fetch_assoc($res))
	{
		array_push($resultarray, $row);
	}
	return $resultarray;
}

function show_accepting_privmessages()
{
	$current = db_getacceptingmsg();
	view_accepting_privmessages($current);
}

function show_buy_help()
{
	$res = db_getuserdata($_SESSION['user_id']);
	if(!$res)
	{
		die(err_db());
	}
	$row = mysqli_fetch_assoc($res);
	$pr = $row['premium'];
	$szint = $row['level'];
	view_buy_help($szint, $pr);
}

function show_friends()
{
	$res = db_baratLista(0);
	if(!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res)>0)
	{
		show_markedfriends($res);
	}
	$res = db_baratLista(1);
	if(!$res)
	{
		die(err_db());
	}
	?><span id="baratok_cim">Barátok <?php echo " (" . mysqli_num_rows($res) . ")"; ?></span><?php
	if(mysqli_num_rows($res)==0)
	{
		?>
		<div class="friends_maindiv"><p id='no_friends'>Jelenleg nincsenek barátaid.</p></div>
		<?php
	}
	else{
		?>
		<div class="card-columns justify-content-center" style="margin-right:20pt;margin-top:20pt;">
		<?php
		while($row = mysqli_fetch_assoc($res))
		{
			?>
			<div id="<?php echo "friend" . $row['azon']; ?>" class="card">
				<p id='friend_name'><?php echo "<u><a href=profile.php?profil_id=" . $row['azon'] . ">"; echo $row['nev'] . "</a></u>"; ?><br>
				<p id='friend_rang'><b>Rang:</b> <?php echo $row['rang']; ?>
				<p id='friend_points'><b>Pontok:</b> <?php echo $row['points']; ?>
				<p id='friend_lastv'><b>Itt járt:</b> <?php echo $row['lastvisit']; ?><br>
				<button id="<?php echo "del_friendship" . $row['azon'] ?>" class='btn btn-danger' onclick='del_friendship("<?php echo $row["azon"]; ?>")' style="margin-top:15px;padding:5px 10px;font-size:13px;">Barát törlése</button>
			</div>
			<?php
		}
		?></div>
		<?php
	}
	
	show_blockedusers();
}

function show_markedfriends($res)
{
	?><br><br><p id="baratok_cim">Barátnak jelöltek <?php echo " (" . mysqli_num_rows($res) . ")"; ?></p><?php
	if(mysqli_num_rows($res)==0)
	{
		?>
		<p id='no_friends'>Jelenleg senki sem várja, hogy visszaigazold barátnak.</p>
		<?php
	}
	else{
		?><div class="card-columns justify-content-center" style="margin-right:20pt;margin-top:20pt;margin-bottom:20pt;"><?php
		while($row = mysqli_fetch_assoc($res))
		{
			?>
			<div id="<?php echo "almostfriend" . $row['azon']; ?>" class="card">
				<p id='friend_name'><?php echo "<a href=profile.php?profil_id=" . $row['azon'] . ">"; echo $row['nev'] . "</a>"; ?><br>
				<p id='friend_rang'>Rang: <?php echo $row['rang']; ?><br>
				<p id='friend_lastv'>Legutóbb itt járt: <?php echo $row['lastvisit']; ?><br><br>
				<button id="<?php echo "accept_friendship" . $row['azon'] ?>" class='btn btn-success' onclick='validate_almostfriendship("<?php echo $row["azon"]; ?>", "<?php echo "1"; ?>")' style="margin-top:5px;padding:5px 10px;font-size:13px;margin-left:-5px;margin-right:-5px;">Elfogad</button>
				<button id="<?php echo "delete_friendship" . $row['azon'] ?>" class='btn btn-warning' onclick='validate_almostfriendship("<?php echo $row["azon"]; ?>", "<?php echo "0"; ?>")' style="margin-top:5px;padding:5px 10px;font-size:13px;margin-right:-5px;">Törlés</button>
			</div>
			<?php
		}
		?></div><?php
	}
}

function show_blockedusers()
{
	$res = db_baratLista(-1);
	if(!$res)
	{
		die(err_db());
	}
	?><br><br><p id="baratok_cim">Tiltott felhasználók <?php echo " (" . mysqli_num_rows($res) . ")"; ?></p><?php
	if(mysqli_num_rows($res)==0)
	{
		?><p id='no_friends'>Még senkit sem tiltottál le.</p><?php
	}
	else{
		?><div class="card-columns justify-content-center" style="margin-right:20pt;margin-top:20pt;margin-bottom:20pt;"><?php
		while($row = mysqli_fetch_assoc($res))
		{
			?>
			<div id="<?php echo "blockeduser" . $row['azon']; ?>" class="card" style="background-image: url('../documents/images/blockedbg.jpg');min-height: 300px;">
				<p id='friend_name'><?php echo "<a href=profile.php?profil_id=" . $row['azon'] . ">"; echo $row['nev'] . "</a>"; ?><br>
				<p id='friend_rang'><i>Rang: <?php echo $row['rang']; ?></i><br>
				<p id='friend_lastv'>Itt volt: <?php echo $row['lastvisit']; ?><br>
			</div>
			<?php
		}
		?></div><?php
	}
}

function show_last_played_quizzes()
{
	$res = db_lastplayedquizzes($_GET['profil_id']);
	if (!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res) < 1)
	{
		echo "<h3 class='h3_title_1'>Kvízek az elmúlt időszakból </h3><div id='quizplayed_notfound_id'>Még egyetlen kvízen sem vett részt!</div>";
	}
	else
	{
		?><h3 class='h3_title_1'>Kvízek az elmúlt időszakból </h3><br>
		<table id="tableLastKvizId" class="table-bordered table-hover">
		<tr class="fejlecLastKviz">
			<th>Kvíz neve
			<th>Eredmény
			<th>Időpont
			<?php
			if($_GET['profil_id'] == $_SESSION['user_id'])
			{
				echo "<th>Exportálás";
			}
			
			$deviceType = checkDevice();
			while ($row = mysqli_fetch_assoc($res))
			{
				if($row['score']>=$row['sikeresseg'])
				{
					echo "<tr>\n";
				}
				else
				{
					echo "<tr style='background-color:#FFCCCC;'>\n";
				}
				echo "<td align='center' style='width:60%'>" . $row['temakor'];
				echo "<td align='center' class='align-middle' style='width:15%';>" . $row['totalcorrect'] . " / " . $row['numofquestion'] . "<hr class='hr1'>" . $row['score'] . "%";
				echo "<td align='center' style='width:15%'>" . $row['idopont'];
				if($_GET['profil_id'] == $_SESSION['user_id'])
				{
					echo "<td align='center'>";
					if($deviceType != 0)
					{
						?><a id="pdf_button" href='fpdf/topdf.php?test_id=<?php echo $row['test_id']; ?>&test_name=<?php echo rawurlencode($row['temakor']); ?>'><img src="documents/images/pdf.png" style="width:80%"></img></a><?php
					}
					else
					{
						?><button id="pdf_button" onclick="window.open('fpdf/topdf.php?test_id=<?php echo $row['test_id']; ?>&test_name=<?php echo rawurlencode($row['temakor']); ?>', '_blank', 'toolbar=yes,scrollbars=yes,resizable=yes,top=500,left=500,width=screen.availWidth,height=screen.availHeight')"><img src="documents/images/pdf.png" style="width:80%"></img></button><?php
					}
				}
			}
		?></table><?php
	}
}

function show_all_played_quizzes()
{
	$res = db_alldistinctplayed($_SESSION['user_id']);
	if(!$res)
	{
		die(err_db());
	}
	$res1 = db_allattempts($_SESSION['user_id']);
	if(!$res1)
	{
		die(err_db());
	}
	$tmb = toArray($res1);
	
	if(mysqli_num_rows($res) < 1)
	{
		echo "<div id='quizplayed_notfound_id'>Még egyetlen kvízen sem vettél részt!</div>";
	}
	else
	{
		?><h3 class='h3_title_1'>Minden kvíz</h3><br>
		<table id="tableAllKvizId" class="table table-bordered table-hover">
		<tr>
			<th class='align-middle'>Kvíz neve
			<th class='align-middle'>Teljesítés
			<th class='align-middle'>Legjobb eredmény
			<th class='align-middle'>Összes próbálkozás
		<?php
		while ($row = mysqli_fetch_assoc($res))
		{
			echo "<tr>";
			echo "<td align='center' style='width:60%'>"; ?><a href="#" class="togglerQ" data-prod-cat="<?php echo $row['quiz_id']; ?>"> <?php echo $row['temakor']; ?></a><?php
			if($row['legjobbscore']>=$row['sikeresseg'])
			{
				echo "<td align='center' style='width:15%'>" . "<img src='documents/images/pipa.png' style='width:20%'></img>";
			}
			else
			{
				echo "<td align='center' style='width:15%'>" . "<img src='documents/images/x.png' style='width:20%'></img>";
			}
			echo "<td align='center' style='width:15%'>" . $row['legjobb'] . " / " . $row['numofquestion'] . "<hr class='hr1'>" . $row['legjobbscore'] . "%";
			echo "<td align='center' style='width:25%'>" . $row['darab'];?>
			
			<tr id="detailQ" class="<?php echo "detailQ" . $row['quiz_id']; ?>">
			<?php echo "<td colspan='4'>"; ?>
			
			<table id='quiz_attempts_table' class="table table-bordered table-hover">
			<tr colspan='4'>
				<th>Próbálkozás
				<th>Eredmény
				<th>Időpont
				<th>Exportálás
				<?php
				$deviceType = checkDevice();
				$szamlalo = 1;
				foreach($tmb as $tomb)
				{
					if($tomb['quiz_id'] == $row['quiz_id'])
					{
						$sikeres_str = "asd";
						if($tomb['score'] >= $tomb['sikeresseg'])
						{
							$sikeres_str = "<b><font color='green'>SIKERES";
						}
						else
						{
							$sikeres_str = "<b><font color='red'>Sikertelen";
						}
						echo "<tr >\n";
						echo "<td align='center' style='width:20%'>" . $szamlalo++ . "." . "\n";
						echo "<td align='center' style='width:30%'><b>" . $tomb['totalcorrect'] . " / " . $tomb['numofquestion'] . "</b><hr class='hr1'>" . $sikeres_str . " (" . $tomb['score'] . "%)</font></b>" . "\n";
						echo "<td align='center' style='width:15%'>" . $tomb['idopont'] . "\n";
						echo "<td align='center' style='width:15%'>" . "\n";
						
						if($deviceType != 0)
						{
							?><a id="pdf_button" href='fpdf/topdf.php?test_id=<?php echo $tomb['test_id']; ?>&test_name=<?php echo rawurlencode($tomb['temakor']); ?>'><img src="documents/images/pdf.png" style="width:80%"></img></a><?php
						}
						else
						{
							?><button id='pdf_button' onclick="window.open('fpdf/topdf.php?test_id=<?php echo $tomb['test_id']; ?>&test_name=<?php echo rawurlencode($tomb['temakor']); ?>', '_blank', 'toolbar=yes,scrollbars=yes,resizable=yes,top=500,left=500,width=screen.availWidth,height=screen.availHeight')"><img src="documents/images/pdf.png" style="width:60%"></img></button><?php
						}
						
					}
				}
				?>
			</table>
			<?php
		}
		?></table><?php
	}
}

function show_quizzes_in_progress()
{
	$res = db_sajatkvizek_folyamatban();
	if (!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res) < 1)
	{
		echo "<div id='quizplayed_notfound_id'>Jelenleg egyetlen kvízed sincs folyamatban!</div>";
	}
	else
	{
		$tqstat = db_getquestion_stat($_SESSION['user']);
		if(!$tqstat)
		{
			die(err_db());
		}
		$tmb = toArray($tqstat);
		?><h3 class='h3_title_1'>Folyamatban lévő kvízek</h3><br>
		<table id="tableInprocessKvizId" class="table table-bordered table-hover">
		<tr>
			<th class='align-middle' style='width:50%'>Név
			<th class='align-middle' style='width:20%'>Státusz
			<th class='align-middle' style='width:15%'>Kérdések
			<th class='align-middle' style='width:15%'>Kérés ideje
		<?php
		while ($row = mysqli_fetch_assoc($res))
		{
			$fazis = $row['phase'];
			if($row['phase'] == 1)
			{
				$row['phase'] = "Jóváhagyásra vár";
			}
			elseif($row['phase'] == 2)
			{
				$row['phase'] = "Kérdések beküldésére vár";
			}
			if($row['language'] == 1)
			{
				$row['language'] = 'Magyar';
			}
			elseif($row['language'] == 2)
			{
				$row['language'] = 'Angol';
			}
			
			if($row['access'] == 1)
			{
				$row['access'] = "Csak én és adminok";
			}
			elseif($row['access'] == 2)
			{
				$row['access'] = "Én, adminok és a kijelölt barátaim";
			}
			elseif($row['access'] == 3)
			{
				$row['access'] = "Mindenki";
			}
			elseif($row['access'] == 4)
			{
				$row['access'] = "Akik ismerik a jelszót";
			}
			elseif($row['access'] == 5)
			{
				$row['access'] = "Én, adminok és a jelenlegi/ezutáni összes barátom";
			}
			if($row['num_of_playing'] == 0)
			{
				$row['num_of_playing'] = "Korlátlan";
			}
			if($row['start_date'] == '')
			{
				$row['start_date'] = "Nincs korlátozva";
			}
			if($row['end_date'] == '')
			{
				$row['end_date'] = "Nincs korlátozva";
			}
			
			if($row['show_answers'] == 1)
			{
				$row['show_answers'] = 'Engedélyezve';
			}
			elseif($row['show_answers'] == 2)
			{
				$row['show_answers'] = 'Nincs engedélyezve';
			}
			
			foreach($tmb as $tomb)
			{
				if($tomb['temakorid'] == $row['id_number'])
				{
					echo "<tr>";
					echo "<td align='center' >"; ?><a href="" class="togglerOwnPQ" data-prod="<?php echo $row['id_number']; ?>"> <?php echo $row['quiz_name']; ?></a><?php
					echo "<td align='center'>" . $row['phase'];
					echo "<td align='center'>" . $tomb['elfogadottk'] . " / " . $row['minimum_requested_quest'];
					echo "<td align='center'>" . $row['request_date'];
					
					?>
					<tr id="detailsOwnPQuiz" class="<?php echo "detailsOwnPQuiz" . $row['id_number']; ?>" style="display:none;">
						<?php echo "<td colspan='9' style='padding-left:40pt;padding-right:40pt'>"; ?>Részletek:<br><br>
						<b>A kvíz nyelve: </b><?php echo $row['language']; ?><br>
						<b>Kvízenkénti kérdések: </b><?php echo $row['num_of_question']; ?><br>
						<b>Egy kérdésre jutó válaszolási idő: </b><?php echo $row['time_to_answer']; ?> másodperc<br>
						<b>Helyes válaszok megmutatása: </b><?php echo $row['show_answers']; ?><br>
						<b>Próbálkozások száma: </b><?php echo $row['num_of_playing']; ?><br>
						<b>A kvíz elérhetősége: </b><?php echo $row['access']; ?><br>
						<b>Indulás dátuma: </b><i><?php echo $row['start_date']; ?></i><br>
						<b>Lezárulás dátuma: </b><i><?php echo $row['end_date']; ?></i><br>
						<b>Létrehozás oka: </b><?php echo $row['reason']; ?><br>
						<br><b>Részletes leírás: </b><?php echo nl2br(htmlentities($row['description'])) . "<br>"; ?>
						
						<br><b>A kvíz teljesítésének állapota: </b>
						<div style='margin-left:40px;margin-bottom:15px;'>
							<b>Eddig beküldött kérdések: <span style="color:green;"><?php echo $tomb['osszesk']; ?></span></b>
						<br><b>Ebből ellenőrzive: <span style="color:red;"><?php echo $tomb['ellenorzottk']; ?></span></b>
						<br><b>Ebből ELFOGADVA: <span style="color:green;"><?php echo $tomb['elfogadottk']; ?></span></b>
						<?php if($fazis > 1){ ?>
							<br><br><button id="<?php echo "questionlist" . $row['id_number']; ?>" class='btn btn-primary' onclick='show_sentquestions("<?php echo $row["id_number"]; ?>", "<?php echo $row["quiz_name"]; ?>")'>Beküldött kérdések</button>
							<div id="dialogShowQuestionList" class="<?php echo "dialogShowQuestionList" . $row['id_number']; ?>" title="Kérdések megtekintése" style="display:none;"></div>
							<button type="button" class='btn btn-primary' onclick='new_background("<?php echo $row["id_number"]; ?>")'>Új háttérkép</button>
							<div id="dialogAddNewBackground" title="Új háttérkép feltöltése" style="display:none;"></div>
							<div id="dialogAddNewBackgroundAlert" class='<?php echo "dialogAddNewBackgroundAlert" .$row["id_number"]; ?>' title="Info" style="display:none;"></div>
						</div><?php
						}
				}
			}
		}
		?>
		</table>
		<?php
	}
}

function user_datalist()
{
	$res = db_listarolam($_GET['profil_id']);
	if (!$res)
	{
		die(err_db());
	}
	$row = mysqli_fetch_assoc($res);

	$array_data = array("username"=>$row["user"], "rang"=>$row["level"], "points"=>$row["points"], "quiz_played"=>$row["quizplayed_total"], "helps"=>$row["help"], "own_quiz"=>$row["ownquizzes"], "requests_acc"=>$row["accomplishedrequests"], "premium"=>$row['premium'], "premium_expire"=>$row['premium_expire'], "profile_hiding"=>$row['profilehiding'], "profilehiding_expire"=>$row['profilehiding_expire'], "warn"=>db_warn($_GET['profil_id']), "warn_expire"=>$row['warn_expire'], "totalwarn"=>$row["totalwarn"], "fav_quiz"=>$row["favoritequizzes"], "chatgroups"=>$row["chatgroups"], "questions"=>$row["allquestionssent"], "friends"=>$row["friends"], "quizcomments"=>$row["quizcomments"], "news"=>$row["postednews"], "registration"=>$row["registrtime"], "lastvisit"=>$row["lastvisit"], "name"=>$row["fullname"], "email"=>$row["email"], "lawtogetpoints"=>$row['lawtogetpoints'], "lawtosendmail"=>$row['lawtosendmail'], "lawtousechat"=>$row['lawtousechat'], "lawtousechat"=>$row['lawtousechat'], "lawtouserequests"=>$row['lawtouserequests'], "lawtocreatequiz"=>$row['lawtocreatequiz'], "lawtosendquestion"=>$row['lawtosendquestion'], "lawtosearchuser"=>$row['lawtosearchuser']);

	view_my_datalist($array_data);
}

function other_user_datalist()
{
	$res = db_listarolam($_GET['profil_id']);
	if (!$res)
	{
		die(err_db());
	}
	$row = mysqli_fetch_assoc($res);

	$s = db_getfriend_status($_GET['profil_id']);
	if(!$s && $s != 0)
	{
		echo $s;
		die(err_db());
	}

	$array_data = array("username"=>$row["user"], "rang"=>$row["level"], "points"=>$row["points"], "quiz_played"=>$row["quizplayed_total"], "helps"=>$row["help"], "own_quiz"=>$row["ownquizzes"], "requests_acc"=>$row["accomplishedrequests"], "premium"=>$row['premium'], "premium_expire"=>$row['premium_expire'], "warn"=>db_warn($_GET['profil_id']), "warn_expire"=>$row['warn_expire'], "friends"=>$row["friends"], "quizcomments"=>$row["quizcomments"], "news"=>$row["postednews"], "registration"=>$row["registrtime"], "lastvisit"=>$row["lastvisit"], "lawtogetpoints"=>$row['lawtogetpoints'], "lawtosendmail"=>$row['lawtosendmail'], "lawtousechat"=>$row['lawtousechat'], "lawtousechat"=>$row['lawtousechat'], "lawtouserequests"=>$row['lawtouserequests'], "lawtocreatequiz"=>$row['lawtocreatequiz'], "lawtosendquestion"=>$row['lawtosendquestion'], "lawtosearchuser"=>$row['lawtosearchuser'], "friendship"=>$s, "profil_id"=>$_GET["profil_id"]);

	view_others_datalist($array_data);
	?>
	<?php
}

function check_friendship()
{
	$er = db_getfriend_status($_GET['profil_id']);
	if(!$er && $er != 0)
	{
		die(err_db());
	}
	if($er == 1)
	{
		echo "BARÁTOK VAGYTOK";
	}
	elseif($er == 2)
	{
		echo "Barátság folyamatban";
	}
	elseif($er == 3)
	{
		echo "Barátság elfogadása";
	}
	elseif($er == 4)
	{
		echo "Tiltott felhasználó!";
	}
	elseif($er == 5)
	{
		//echo "Barátnak jelölés MEGTAGADVA!";
	}
	elseif($er == 0)
	{
		view_making_friendship($_GET['profil_id']);
	}
}

function show_various()
{
	if($_GET['action_id'] == 10)
	{
		view_delete_account();
	}
	elseif($_GET['action_id'] == 9)
	{
		show_accepting_privmessages();
	}
	elseif($_GET['action_id'] == 8)
	{
		view_changing_password();
	}
	elseif($_GET['action_id'] == 7)
	{
		view_buying_premium();
	}
	elseif($_GET['action_id'] == 6)
	{
		view_profile_hiding();
	}
	elseif($_GET['action_id'] == 5)
	{
		show_buy_help();
	}
	elseif($_GET['action_id'] == 4)
	{
		show_friends();
	}
	elseif($_GET['action_id'] == 3)
	{
		show_all_played_quizzes();
	}
	elseif($_GET['action_id'] == 2)
	{
		show_quizzes_in_progress();
	}
	else
	{
		show_last_played_quizzes();
	}
}

?>
<html>
<head>
	<title>Profil</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/profile.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/jQuery-ui.css">
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css"> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/profile.js"></script>
	<script type = "text/javascript" src="js/menu.js"></script>
</head>
<body>
<?php
main_menu();

if(!isset($_GET['profil_id']) || !preg_match("/^[0-9]+$/", $_GET['profil_id']) || $_GET['profil_id'] < 1)
{
	$p_id = db_getid();
	if(!$p_id)
	{
		die(err_db());
	}
	$_GET['profil_id'] = $p_id;
}

if(!isset($_GET['action_id']) || !preg_match("/^[0-9]+$/", $_GET['action_id']) || $_GET['action_id'] < 1)
{
	$_GET['action_id'] = 1;
}

$userstatusz = db_userstatusz($_GET['profil_id']);
if($userstatusz == 1)
{
	?>
	<div id="main_div">
		<div id="data_div"><?php user_datalist(); ?></div>
		
		<div id="second_div">
			<div id="submenu_div"><?php view_profile_menu(); ?></div>
			<div id="various_div"><?php show_various(); ?></div>
		</div>
	</div>
	<?php
}
elseif($userstatusz == 0)
{
	?>
	<div id="main_div">
		<div id="data_div"><?php other_user_datalist(); ?></div>
		
		<div id="second_div">
			<div id="submenu_div"><?php view_others_profile($_GET['profil_id'], db_getuser($_GET['profil_id'])); ?></div>
			<div id="various_div">
				<?php
				if($_GET['action_id'] == 1)
				{
					show_last_played_quizzes();
				}
				else
				{
					show_forbidden_toview("Nincs jogosultságod megtekinteni ezt a részt!");
				}
				?>
			</div>
		</div>
	</div><?php
}
elseif($userstatusz == -1)
{
	show_user_notfound("Nincs ilyen felhasználó!");
}
else
{
	show_user_notfound("Törölt felhasználó!");
}
?>
</body>
</html>
