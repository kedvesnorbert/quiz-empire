<?php
session_start();
require_once("db/db_connect.php");
require_once("../includes/ip_functions.php");
require_once("db/db_userdetails.php");
require_once("../includes/responses.php");
require_once("includes/session_timeout.php");
require_once("menu_admin.php");

if(!isset($_SESSION['adminuser']) || !isset($_SESSION['is_admin']) || !isset($_SESSION['user_id']))
{
    $fromurladmin = urlencode($_SERVER["REQUEST_URI"]);
	setcookie("fromwhereadmin", $fromurladmin);
	$_SESSION = array();
	session_destroy();
	header("location: adminlogin.php");
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

function show_userdata()
{
	$res = db_userdata($_GET['profil_id']);
	if(!$res)
	{
		die(err_db());
	}
	if (mysqli_num_rows($res) == 0)
	{
		?><script>alert( 'HIBA!\nNincs a keresésnek megfelelő találat!!');</script><?php
		die(err_notfound());
	}
	$row = mysqli_fetch_assoc($res);
	
	?>
	<table align = "center" border="1" bgcolor="lightgray">
	<tr>
	<th align = "left"><font face="verdana" color="black" size="5px"><center>Egyéb adatok</center></font><ul class="profiladatok">
		<b><font face="verdana" color="black">Felhasználónév: </font><font face="verdana" color="red"><?php echo $row["user"];?></font></b><br>
		<b><font face="verdana" color="black">TÖRÖLT-e: </font>
		<?php
		if($row['deleteduser'] == 1)
		{
			?><b><font face="verdana" color="blue">
			<?php
			echo "IGEN";?>
			</font></b>
			<?php
			
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "NEM";
			?>
			</font></b>
			<?php
		}
		?>
		<br>
		<b><font face="verdana" color="black">Rang: </font><font face="verdana" color="red"><?php echo $row["level"];?>.</font></b><br>
		<b><font face="verdana" color="black">Pontszám: </font><font face="verdana" color="red"><?php echo $row["points"];?></font></b><br>
		<b><font face="verdana" color="black">Lejátszott kvízek: </font><font face="verdana" color="red"><?php echo $row["quizplayed_total"];?></font></b><br>
		<b><font face="verdana" color="black">Tökéletes kvízek (10/10): </font><font face="verdana" color="green"><?php echo $row["perfectgames"];?></font></b><br>
		<b><font face="verdana" color="black">Segítségcsomag száma: </font><font face="verdana" color="red"><?php echo $row["help"];?></font></b><br>
		<b><font face="verdana" color="black">Saját kvízek: </font><font face="verdana" color="red"><?php echo $row["ownquizzes"];?></font></b><br>
		<b><font face="verdana" color="black">Teljesített kérések: </font><font face="verdana" color="red"><?php echo $row["accomplishedrequests"];?></font></b><br>
		<b><font face="verdana" color="black">Összes beküldött kérdés: </font><font face="verdana" color="red"><?php echo $row["allquestionssent"];?></font></b><br><br>
		<br>

		<b><font face="verdana" color="black">Kedvenc kvízek: </font><font face="verdana" color="red"><?php echo $row["favoritequizzes"];?></font></b><br>
		<b><font face="verdana" color="black">Kvíz hozzászólások: </font><font face="verdana" color="red"><?php echo $row["quizcomments"];?></font></b><br>
		<b><font face="verdana" color="black">Kedvelt kvízek: </font><font face="verdana" color="red"><?php echo $row["likedquizzes"];?></font></b><br>
		<b><font face="verdana" color="black">Barátok: </font><font face="verdana" color="red"><?php echo $row["friends"];?></font></b><br>
		<b><font face="verdana" color="black">Chat csoportok: </font><font face="verdana" color="red"><?php echo $row["chatgroups"];?></font></b><br>
		<b><font face="verdana" color="black">Közzétett hírek: </font><font face="verdana" color="red"><?php echo $row["postednews"];?></font></b><br><br>		

		<b><font face="verdana" color="black">PRÉMIUM tagság: </font>
		<?php
		if($row['premium'] == 1)
		{
			?><b><font face="verdana" color="blue">
			<?php
			echo "VAN, <br>Lejár: ";
			echo $row['premium_expire'];?>
			</font></b>
			<?php
			
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "NINCS";
			?>
			</font></b>
			<?php
		}
		?>
		<br>
		
		<b><font face="verdana" color="black">Profil rejtettség: </font></b>
		<?php
		if($row['profilehiding'] == 0)
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "KIKAPCSOLVA";
			?>
			</font></b>
			<?php
		}
		else
		{
			?><b><font face="verdana" color="red">
			<?php
			echo "BEKAPCSOLVA, <br>Lejár: ";
			echo $row['profilehiding_expire'];?>
			</font></b>
			<?php
		}
		?>
		<br>
		
		<b><font face="verdana" color="black">Aktív figyelmeztetés: </font></b>
		<?php
		if($row['warn'] != 0)
		{
			?><b><font face="verdana" color="red">
			<?php
			echo "VAN, <br>Lejár: ";
			echo $row['warn_expire'];?>
			</font></b>
			<?php
		}
		else
		{
			?>
			<b><font face="verdana" color="green">
			<?php
			echo "NINCS";
			?>
			</font></b>
			<?php
		}
		?><br>
		<b><font face="verdana" color="black">Összes figyelmeztetés száma: </font><font face="verdana" color="red"><?php echo $row["totalwarn"];?></font></b><br>
		
		<br>
		<b><font face="verdana" color="black">Regisztrált az oldalra: </font><font face="verdana" color="blue"><?php echo $row["registrtime"];?>-kor</font></b><br>
		<b><font face="verdana" color="black">Legutóbb itt volt: </font><font face="verdana" color="green"><?php echo $row["lastvisit"];?></font></b><br>
		<b><font face="verdana" color="black">Legutóbb itt volt Adminként: </font><font face="verdana" color="green"><?php echo $row["lastvisit_admin"];?></font></b></li>
		<br>
		<b><font face="verdana" color="black">Teljes név: </font><font face="verdana" color="blue"><?php echo $row["fullname"];?></font></b><br>
		<b><font face="verdana" color="black">E-mail cím: </font><font face="verdana" color="blue"><?php echo $row["email"];?></font></b><br><br>
		
		<b><center><font face="verdana" color="black" size="5px">Speciális </font></center><br>
		<b><font face="verdana" color="black">ADMIN-e: </font>
		<?php
		if($row['adminuser'] == 1)
		{
			?><b><font face="verdana" color="blue">
			<?php
			echo "IGEN";?>
			</font></b>
			<?php
			
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "NEM";
			?>
			</font></b>
			<?php
		}
		?>
		<br><b><font face="verdana" color="black">Szintmegtartás: </font>
		<?php
		if($row['keep_level'] == 1)
		{
			?><b><font face="verdana" color="blue">
			<?php
			echo "BEKAPCSOLVA";?>
			</font></b>
			<?php
			
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "KIKAPCSOLVA";
			?>
			</font></b>
			<?php
		}
		?>
		<br><b><font face="verdana" color="black">Kérdés nehézsége: </font>
		<?php
		if($row['questiontype'] == 2)
		{
			?><b><font face="verdana" color="red">
			<?php
			echo "CSAK NEHÉZ";?>
			</font></b>
			<?php
			
		}
		elseif($row['questiontype'] == 1)
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "CSAK KÖNNYŰ";
			?>
			</font></b>
			<?php
		}
		else
		{
			?><b><font face="verdana" color="blue">
			<?php
			echo "VEGYES";
			?>
			</font></b>
			<?php
		}
		?>
		<br>
		<br>
        <b><center><font face="verdana" color="black" size="5px">Jogok </font></center><br>
        <b><font face="verdana" color="black">Pontok gyűjtése: </font></b>
		<?php
		if($row['lawtogetpoints'] == 0)
		{
			?><b><font face="verdana" color="red">
			<?php
			echo "NINCS engedélyezve";
			?>
			</font></b>
			<?php
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "Engedélyezve";?>
			</font></b>
			<?php
		}
		?>
        <b><br><font face="verdana" color="black">Chat használata: </font></b>
		<?php
		if($row['lawtousechat'] == 0)
		{
			?><b><font face="verdana" color="red">
			<?php
			echo "NINCS engedélyezve";
			?>
			</font></b>
			<?php
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "Engedélyezve";?>
			</font></b>
			<?php
		}
		?>
        <br><b><font face="verdana" color="black">Kérés kiírása: </font></b>
        <?php
		if($row['lawtouserequests'] == 0)
		{
			?><b><font face="verdana" color="red">
			<?php
			echo "NINCS engedélyezve";
			?>
			</font></b>
			<?php
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "Engedélyezve";?>
			</font></b>
			<?php
		}
		?>
		
		<br><b><font face="verdana" color="black">Saját kvíz létrehozása: </font></b>
        <?php
		if($row['lawtocreatequiz'] == 0)
		{
			?><b><font face="verdana" color="red">
			<?php
			echo "NINCS engedélyezve";
			?>
			</font></b>
			<?php
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "Engedélyezve";?>
			</font></b>
			<?php
		}
		?>
		
        <br><b><font face="verdana" color="black">Új kvízkérdés beküldése: </font></b>
        <?php
		if($row['lawtosendquestion'] == 0)
		{
			?><b><font face="verdana" color="red">
			<?php
			echo "NINCS engedélyezve";
			?>
			</font></b>
			<?php
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "Engedélyezve";?>
			</font></b>
			<?php
		}
		?>
        <br><b><font face="verdana" color="black">Új hír kiírása: </font></b>
        <?php
		if($row['lawtopostnews'] == 0)
		{
			?><b><font face="verdana" color="red">
			<?php
			echo "NINCS engedélyezve";
			?>
			</font></b>
			<?php
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "Engedélyezve";?>
			</font></b>
			<?php
		}
		?>
        <br><b><font face="verdana" color="black">Felhasználókereső használata: </font></b>
        <?php
		if($row['lawtosearchuser'] == 0)
		{
			?><b><font face="verdana" color="red">
			<?php
			echo "NINCS engedélyezve";
			?>
			</font></b>
			<?php
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "Engedélyezve";?>
			</font></b>
			<?php
		}
		?>
        <br><b><font face="verdana" color="black">A GYIK oldal szerkesztése: </font></b>
        <?php
		if($row['lawtoeditfaq'] == 0)
		{
			?><b><font face="verdana" color="red">
			<?php
			echo "NINCS engedélyezve";
			?>
			</font></b>
			<?php
		}
		else
		{
			?><b><font face="verdana" color="green">
			<?php
			echo "Engedélyezve";?>
			</font></b>
			<?php
		}	
		?>
	</ul>
	</table>
	<?php
}

function show_lastplayed()
{
	$res = db_lastplayedquizzes($_GET['profil_id']);
	if (!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res) < 1)
	{
		echo "<p id='quizplayed_notfound_id'>Nincs találat!<br>Még egyetlen kvízen sem vett részt. </p>";
	}
	else
	{
		?>
		Az elmúlt időszakban lejátszott kvízek<br>
		<br><center>
		<table id="tableLastKvizId" border="1">
		<tr class="fejlecLastKviz">
			<th>Kvíz neve
			<th>Eredmény
			<th>Időpont
			<th>Exportálás
		<?php
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
			echo "<td align='center' style='width:60%'>" . $row['temakor'] . "\n";
			echo "<td align='center' style='width:15%'>" . $row['totalcorrect'] . " / " . $row['numofquestion'] . "<hr>" . $row['score'] . "%\n";
			echo "<td align='center' style='width:20%'>" . $row['idopont'] . "\n";
			
			echo "<td align='center'>";
			?><button id="pdf_button" onclick="window.open('../fpdf/topdf_admin.php?test_id=<?php echo $row['test_id']; ?>&test_name=<?php echo rawurlencode($row['temakor']); ?>', '_blank', 'toolbar=yes,scrollbars=yes,resizable=yes,top=500,left=500,width=screen.availWidth,height=screen.availHeight')"><img src="../documents/images/pdf.png" style="width:80%"></img></button><?php
			
		}
		?></table></center><?php
	}
}

function show_allplayed()
{
	$res = db_alldistinctplayed($_GET['profil_id']);
	if(!$res)
	{
		die(err_db());
	}
	$res1 = db_allattempts($_GET['profil_id']);
	if(!$res1)
	{
		die(err_db());
	}
	$tmb = toArray($res1);
	
	if(mysqli_num_rows($res) < 1)
	{
		echo "<p id='quizplayed_notfound_id'>Nincs találat!<br>Még egyetlen kvízen sem vett részt. </p>";
	}
	else
	{
		?>
		Összes lejátszott kvíz<br>
		<br><center>
		<table id="tableAllKvizId" border="1">
		<tr class="fejlecAllKviz">
			<th>Kvíz neve
			<th>Teljesítés
			<th>Legjobb eredmény
			<th>Próbálkozások száma
		<?php
		while ($row = mysqli_fetch_assoc($res))
		{
			echo "<tr>\n";
			echo "<td align='center' style='width:60%'>"; ?><a href="#" class="togglerU" data-prod-cat="<?php echo $row['quiz_id']; ?>"> <?php echo $row['temakor']; ?></a><?php echo "\n";
			if($row['legjobbscore']>=$row['sikeresseg'])
			{
				echo "<td align='center' style='width:15%'>" . "<img src='../documents/images/pipa.png' style='width:20%'></img>" . "\n";
			}
			else
			{
				echo "<td align='center' style='width:15%'>" . "<img src='../documents/images/x.png' style='width:20%'></img>" . "\n";
			}
			echo "<td align='center' style='width:15%'>" . $row['legjobb'] . " / " . $row['numofquestion'] . "<hr>" . $row['legjobbscore'] . "%\n";
			echo "<td align='center' style='width:25%'>" . $row['darab'] . "\n";?>
			
			<tr id="detailU" class="<?php echo "detailU" . $row['quiz_id']; ?>">
			<?php echo "<td colspan='4'>"; ?>
			
			<table border="1" align="center" width="75%">
			<tr class="fejlecAllKviz" colspan='4'>
				<th>Próbálkozás
				<th>Eredmény
				<th>Időpont
				<th>Exportálás
				<?php
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
						echo "<td align='center' style='width:30%'>" . $tomb['totalcorrect'] . " / " . $tomb['numofquestion'] . "<hr>" . $sikeres_str . " (" . $tomb['score'] . "%)</font></b>" . "\n";
						echo "<td align='center' style='width:15%'>" . $tomb['idopont'] . "\n";
						echo "<td align='center' style='width:15%'>" . "\n";
						?><button id='pdf_button' onclick="window.open('../fpdf/topdf_admin.php?test_id=<?php echo $tomb['test_id']; ?>&test_name=<?php echo rawurlencode($tomb['temakor']); ?>', '_blank', 'toolbar=yes,scrollbars=yes,resizable=yes,top=500,left=500,width=screen.availWidth,height=screen.availHeight')"><img src="../documents/images/pdf.png" style="width:70%"></img></button><?php
					}
				}
				?>
			</table>
			<?php
		}
		?></table></center><?php
	}
}

function show_inprocess()
{
	$uname = db_getuser($_GET['profil_id']);
	if(!$uname)
	{
		die(err_db());
	}
	$res = db_quiz_in_process($uname);
	if(mysqli_num_rows($res) < 1 || !$res)
	{
		echo "<p id='quizplayed_notfound_id'><br>Jelenleg egyetlen kvízed sincs folyamatban. </p>";
	}
	else
	{
		$tqstat = db_getquestion_stat($uname);
		if(!$tqstat)
		{
			die(err_db());
		}
		$tmb = toArray($tqstat);
		?>Folyamatban lévő kvízek
		<table id="tableInprocessKvizId" border="1" width="100%">
		<tr class="fejlecInprocessKviz">
			<th style='width:50%'>Név
			<th style='width:20%'>Státusz
			<th style='width:5%'>Kérdések
			<th style='width:20%'>Kérés időpontja
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
					echo "<tr>\n";
					echo "<td align='center' >"; ?><a href="" class="togglerUserQ" data-prod="<?php echo $row['id_number']; ?>"> <?php echo $row['quiz_name']; ?></a><?php echo "\n";
					echo "<td align='center'>" . $row['phase'] . "\n";
					echo "<td align='center'>" . $tomb['elfogadottk'] . " / " . $row['minimum_requested_quest'] . "\n";
					echo "<td align='center'>" . $row['request_date'] . "\n";
					
					?>
					<tr id="detailsUserQuiz" class="<?php echo "detailsUserQuiz" . $row['id_number']; ?>" style="display:none;">
						<?php echo "<td colspan='9'>"; ?>&emsp;&emsp; Részletek:<br><br>
						&emsp;&emsp; <b>A kvíz nyelve: </b><?php echo $row['language'] . "\n"; ?><br>
						&emsp;&emsp; <b>Játszmánkénti kérdések: </b><?php echo $row['num_of_question'] . "\n"; ?><br>
						&emsp;&emsp; <b>Egy kérdésre jutó válaszolási idő: </b><?php echo $row['time_to_answer'] . "\n"; ?> másodperc<br>
						&emsp;&emsp; <b>Helyes válaszok megmutatása: </b><?php echo $row['show_answers'] . "\n"; ?><br>
						&emsp;&emsp; <b>Próbálkozások száma: </b><?php echo $row['num_of_playing'] . "\n"; ?><br>
						&emsp;&emsp; <b>A kvíz elérhetősége: </b><?php echo $row['access'] . "\n"; ?><br>
						&emsp;&emsp; <b>Indulás dátuma: </b><i><?php echo $row['start_date'] . "\n"; ?></i><br>
						&emsp;&emsp; <b>Lezárulás dátuma: </b><i><?php echo $row['end_date'] . "\n"; ?></i><br>
						<br>&emsp;&emsp; <b>Részletes leírás: </b><?php echo nl2br(htmlentities($row['description'])) . "<br>\n"; ?>
						<br>&emsp;&emsp; <b>Létrehozás oka: </b><?php echo $row['reason'] . "\n"; ?><br>
						
						<br>&emsp;&emsp; <b>A kvíz teljesítésének állapota: </b>
						<br>&emsp;&emsp;&emsp;&emsp; <b><font color="black">Eddig beküldött kérdések: </font>
						<font color="green"><?php echo $tomb['osszesk']; ?></font></b>
						<br>&emsp;&emsp;&emsp;&emsp; <b><font color="black">Ebből ellenőrzive: </font>
						<font color="red"><?php echo $tomb['ellenorzottk']; ?></font></b>
						<br>&emsp;&emsp;&emsp;&emsp; <b><font color="black">Ebből ELFOGADVA: </font>
						<font color="green"><?php echo $tomb['elfogadottk']; ?></font></b>
						<?php
				}
			}
		}
		?>
		</table>
		<?php
	}
}

function show_own()
{
	$res = db_ownquizzes($_GET['profil_id']);
	if (!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res) < 1)
	{
		echo "<p id='quizplayed_notfound_id'>Nincs találat!<br>Még egyetlen kvízt sem küldött be. </p>";
	}
	else
	{
		?>
		Beküldött kvízek<br>
		<br><center>
		<table id="tableLastKvizId" border="1">
		<tr class="fejlecLastKviz">
			<th>Kvíz neve
			<th>Lejátszva
			<th>Like
			<th>Értékelés
			<th>Kérdések
			<th>Comments
		<?php
		while ($row = mysqli_fetch_assoc($res))
		{
			
			if(strlen($row['rating'])<1)
			{
				$row['rating'] = "Nincs";
			}

			echo "<tr>\n";
			echo "<td align='center' style='width:60%'>" . $row['quiz_name'] . "\n";
			echo "<td align='center' style='width:10%'>" . $row['played'] . "\n";
			echo "<td align='center' style='width:10%'>" . $row['likes'] . " db" . "\n";
			echo "<td align='center' style='width:10%'>" . $row['rating'] . "\n";
			echo "<td align='center' style='width:10%'>" . $row['questions'] . " db" . "\n";
			echo "<td align='center' style='width:10%'>" . $row['comments'] . " db" . "\n";
		}
		?></table></center><?php
	}
}

function show_logins()
{
	$res = db_logins($_GET['profil_id']);
	if (!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res) < 1)
	{
		echo "<p id='quizplayed_notfound_id'>A felhasználó még nem lépett be! </p>";
	}
	else
	{
		?>
		Belépések<br>
		<br><center>
		<table id="tableLoginsId" border="1">
		<tr class="fejlecLogins">
			<th>Eszköz
			<th>Időpont
			<th>Kilépett
		<?php
		while ($row = mysqli_fetch_assoc($res))
		{
			if($row['logged_out'] == 0)
			{
				$row['logged_out'] = "Nem";
			}
			else
			{
				$row['logged_out'] = "Igen";
			}
			if($row['login_type'] == 1)
			{
				echo "<tr style='background-color:lightgray'>\n";
			}
			else
			{
				echo "<tr>\n";
			}
			echo "<td align='center' style='width:20%'>" . $row['device_type'] . "\n";
			echo "<td align='center' style='width:15%'>" . $row['login_date'] . "\n";
			echo "<td align='center' style='width:5%'>" . $row['logged_out'] . "\n";
		}
		?></table></center><?php
	}
}

function show_userwarns()
{
	$res = db_userwarns($_GET['profil_id']);
	if (!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res) < 1)
	{
		echo "<p id='quizplayed_notfound_id'>A felhasználó még nem kapott warn-t! </p>";
	}
	else
	{
		?>
		Figyelmeztetések / Warn-ok<br>
		<br><center>
		<table id="tableLoginsId" border="1">
		<tr class="fejlecLogins">
			<th>Ok, megvont jogok
			<th>Levont pontok
			<th>Időtartam
			<th>Kezdés ideje
			<th>Lejárás ideje
		<?php
		while ($row = mysqli_fetch_assoc($res))
		{
			if(strlen($row['deletedby'])> 0)
			{
				$warnreason = "Ok: <u>" . $row['warnreason'] . "</u><br><i>Megvont jogok: " . $row['prohibited'] . "</i><br><br><font color='red'>" . " <b>ELTÖRÖLVE</b> " . $row['deletedbyusername'] . " által, " . $row['delete_time'] . "-kor. Törlés oka: " . $row['delete_reason'] . "</font>";
			}
			else
			{
				$warnreason = "Ok: <u>" . $row['warnreason'] . "</u><br><i>Megvont jogok: " . $row['prohibited'] . "</i>";
			}
			$wdelay = $row['warndelay'] . " nap";
			if($row['is_active'] == 1)
			{
				echo "<tr style='background-color:red'>\n";
			}
			else
			{
				echo "<tr>\n";
			}
			echo "<td align='center' style='width:40%'>" . $warnreason . "\n";
			echo "<td align='center' style='width:10%'>" . $row['minuspoints'] . "\n";
			echo "<td align='center' style='width:15%'>" . $wdelay . "\n";
			echo "<td align='center' style='width:15%'>" . $row['warningstarted'] . "\n";
			echo "<td align='center' style='width:15%'>" . $row['warningends'] . "\n";
		}
		?></table></center><?php
	}
}

function show_userpremiums()
{
	$res = db_userpremiums($_GET['profil_id']);
	if (!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res) < 1)
	{
		echo "<p id='quizplayed_notfound_id'>A felhasználó még nem volt Prémium alatt! </p>";
	}
	else
	{
		?>
		Prémiumok<br>
		<br><center>
		<table id="tableLoginsId" border="1">
		<tr class="fejlecLogins">
			<th>Kezdés ideje
			<th>Lejárás ideje
			<th>Levont pontok
			<th>Ár
			<th>Időtartam
			<th>Megjegyzés
		<?php
		while ($row = mysqli_fetch_assoc($res))
		{
			if(strlen($row['deletedby'])> 0)
			{
				$pnotes = "<b>ELTÖRÖLVE</b> " . $row['deletedbyusername'] . " által, " . $row['deletetime'] . "-kor. Törlés oka: " . $row['deletereason'] . "</font>";
			}
			elseif(strlen($row['adminid'])> 0)
			{
				$pnotes = "Adta " . $row['givenbyusername'];
			}
			else
			{
				$pnotes = " - ";
			}
			$pdelay = $row['delay'] . " nap";
			if($row['price'] > 0)
			{
				$pprice = $row['price'] . " RON";
			}
			else
			{
				$pprice = "Nincs";
			}
			
			if($row['is_active'] == 1)
			{
				echo "<tr style='background-color:lightblue'>\n";
			}
			else
			{
				echo "<tr>\n";
			}
			echo "<td align='center' style='width:15%'>" . $row['startdate'] . "\n";
			echo "<td align='center' style='width:15%'>" . $row['enddate'] . "\n";
			echo "<td align='center' style='width:10%'>" . $row['minuspoints'] . "\n";
			echo "<td align='center' style='width:10%'>" . $pprice . "\n";
			echo "<td align='center' style='width:15%'>" . $pdelay . "\n";
			echo "<td align='center' style='width:40%'>" . $pnotes . "\n";
		}
		?></table></center><?php
	}
}

function show_settings()
{
	?>
	<p>Beállítások megadása</p>
	<table id="settings_table" border="1">
		<tr>
			<td><p id="giveWarn_p" class="settings_table_title">WARN-adás</p>
				<div id="giveWarn_description" class="settings_table_description">Pontlevonás és bizonyos jogok megvonása adott ideig. Hatására eltörlődik az aktív Prémium és a profil rejtettsége.</div>
			<td id='table_tr_btn'><button id="giveWarn" class="setting_table_btn" onclick="load_userlawdata('<?php echo $_GET['profil_id'] ?>')">MEHET</button>
			<div id="dialogGiveWarn" title="WARN adás" style="display:none;"></div>
		<tr>
			<td><p id="deleteWarn_p" class="settings_table_title">WARN eltörlése</p>
				<div id="deleteWarn_description" class="settings_table_description">Jelenlegi Warn eltörlése, amellyel az adott ranghoz tartozó jogok újból jóváíródnak. A levont pontszámot nem adjuk vissza.</div>
			<td id='table_tr_btn'><button id="deleteWarn" class="setting_table_btn" onclick="delete_warn('<?php echo $_GET['profil_id'] ?>')">MEHET</button>
			<div id="dialogDeleteWarn" title="WARN eltörlése" style="display:none;"></div>
		<tr>
			<td><p id="givePremium_p" class="settings_table_title">Prémium ingyen</p>
				<div id="givePremium_description" class="settings_table_description">Adott ideig minden jog engedélyezése.<br>Csak akkor működik, ha a felhasználó nincs Warn alatt.</div>
			<td id='table_tr_btn'><input type="button" id="givePremium" class="setting_table_btn" onclick="free_premium('<?php echo $_GET['profil_id'] ?>')" value="MEHET">
			<div id="dialogFreePremium" title="Igyenes prémium adás" style="display:none;"></div>
		<tr>
			<td><p id="profilHiding_p" class="settings_table_title">Profil rejtettség be- és kikapcsolása</p>
				<div id="profilHiding_description" class="settings_table_description">A felhasználó profilrejtettségének bekapcsolása adott ideig, illetve kikapcsolása. Csak akkor működik, ha a felhasználó nincs Warn, vagy Prémium alatt.</div>
			<td id='table_tr_btn'><input type="button" id="profilHiding" class="setting_table_btn" onclick="profil_hiding_change('<?php echo $_GET['profil_id'] ?>')" value="MEHET">
			<div id="dialogProfilHidingChange" title="Profil rejtettség módosítása" style="display:none;"></div>
		<tr>
			<td><p id="modifyLaw_p" class="settings_table_title">Jogok adása és korlátozása</p>
				<div id="modifyLaw_description" class="settings_table_description">Jogok és pontszám jóváírása a visszavonás idejéig, vagy amíg Warn-t nem kap a felhasználó. Warn alatt nem használható ez a beállítás. Prémium tagság alatt a jogok és a szint nem változtatható, valamint csak az ingyenes prémiumot lehet eltörölni. Itt állítható be, hogy milyen nehézségű kvízkérdéseket kapjon a felhasználó. Csak a SzuperAdmin által használható ez a beállítás.</div>
			<td id='table_tr_btn'><input type="button" id="modifyLaw" class="setting_table_btn" onclick="modify_laws('<?php echo $_GET['profil_id'] ?>')" value="MEHET">
			<div id="dialogModifyLaws" title="Jogok módosítása" style="display:none;"></div>
		<tr>
			<td><p id="modifyAdmin_p" class="settings_table_title">Admin jog módosítása</p>
				<div id="modifyAdmin_description" class="settings_table_description">A felhasználó adminná kinevezése korlátlan ideig, illetve annak visszavonása. Csak a SzuperAdmin által használható ez a beállítás.</div>
			<td id='table_tr_btn'><input type="button" id="modifyAdmin" class="setting_table_btn" onclick="modify_adminlaw('<?php echo $_GET['profil_id'] ?>')" value="MEHET">
			<div id="dialogModifyAdminLaw" title="Admin jog módosítása" style="display:none;"></div>
		<tr>
			<td><p id="delAccount_p" class="settings_table_title">Fiók törlése</p>
				<div id="delAccount_description" class="settings_table_description">A felhasználó fiókjának végleges törlése. Admin felhasználók nem törölhetőek, csak amiután visszavonják az Admin jogát.</div>
			<td id='table_tr_btn'><input type="button" id="delAccount" class="setting_table_btn" onclick="delete_account('<?php echo $_GET['profil_id'] ?>')" value="MEHET">
			<div id="dialogDeleteAccount" title="Felhasználói fiók törlése" style="display:none;"></div>
		<tr>
			<td><p id="restoreAccount_p" class="settings_table_title">Fiók visszaállítása</p>
				<div id="restoreAccount_description" class="settings_table_description">A felhasználó fiókjának visszaállítása.</div>
			<td id='table_tr_btn'><input type="button" id="restoreAccount" class="setting_table_btn" onclick="restore_account('<?php echo $_GET['profil_id'] ?>')" value="MEHET">
			<div id="dialogRestoreAccount" title="Felhasználói fiók visszaállítása" style="display:none;"></div>
	</table>
	<?php
}

?>
<html>
<head>
	<title>Játékos adatai</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=../includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/userdetails.css" />
	
	<link rel="stylesheet" href="../includes/jQuery-ui.css">
	<script type = "text/javascript" src="../includes/jQuery.js"></script>
	<script type = "text/javascript" src="../includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/userdetails.js"></script>
</head>
<body>
<?php
if(!isset($_GET['profil_id']) || !preg_match("/^[0-9]+$/", $_GET['profil_id']) || $_GET['profil_id'] < 1)
{
	$_GET['profil_id'] = $_SESSION['user_id'];
}
if(!isset($_GET['action_id']) || !preg_match("/^[0-9]+$/", $_GET['action_id']) || $_GET['action_id'] < 1)
{
	$_GET['action_id'] = 1;
}
$userstatusz = db_userstatusz($_GET['profil_id']);
if($userstatusz)
{
	?>
	<div id="main_div">
	<div id="data_div">
	
	<?php
	show_userdata();
	?>
	</div>
	
	<div id="second_div">
	<form action="userdetails.php" method="GET">
		<div id="submenu_div">
		
		<a href="userdetails.php?profil_id=<?php echo $_GET['profil_id']; ?>&action_id=1">Beállítások</a>&nbsp;&nbsp;&nbsp;
		<div class="dropdown">
		<button class="dropbtn" disabled>Kvízek</button>
		<div class="dropdown-content">
			<a href="userdetails.php?profil_id=<?php echo $_GET['profil_id']; ?>&action_id=2">Legutóbbi kvízek</a>
			<a href="userdetails.php?profil_id=<?php echo $_GET['profil_id']; ?>&action_id=3">Lejátszott kvízek</a>
			<a href="userdetails.php?profil_id=<?php echo $_GET['profil_id']; ?>&action_id=4">Folyamatban lévő kvízek</a>
			<a href="userdetails.php?profil_id=<?php echo $_GET['profil_id']; ?>&action_id=5">Beküldött kvízek</a>
		</div>
		</div>&nbsp;&nbsp;&nbsp;	

		<div class="dropdown">
		<button class="dropbtn" disabled>Belépések</button>
		<div class="dropdown-content">
			<a href="userdetails.php?profil_id=<?php echo $_GET['profil_id']; ?>&action_id=6">Legutóbbi belépések</a>
		</div>
		</div>&nbsp;&nbsp;&nbsp;

		<div class="dropdown">
		<button class="dropbtn" disabled>Egyebek</button>
		<div class="dropdown-content">
			<a href="userdetails.php?profil_id=<?php echo $_GET['profil_id']; ?>&action_id=8">Warn</a>
			<a href="userdetails.php?profil_id=<?php echo $_GET['profil_id']; ?>&action_id=9">Prémium</a>
		</div>
		</div>&nbsp;&nbsp;&nbsp;

		</div>
	</form>
		<div id="various_div">
		<?php
		if($_GET['action_id'] == 9)
		{
			show_userpremiums();
		}
		elseif($_GET['action_id'] == 8)
		{
			show_userwarns();
		}
		elseif($_GET['action_id'] == 6)
		{
			show_logins();
		}
		elseif($_GET['action_id'] == 5)
		{
			show_own();
		}
		elseif($_GET['action_id'] == 4)
		{
			show_inprocess();
		}
		elseif($_GET['action_id'] == 3)
		{
			show_allplayed();
		}
		elseif($_GET['action_id'] == 2)
		{
			show_lastplayed();
		}
		elseif($_GET['action_id'] == 1)
		{
			show_settings();
		}
		else
		{
			echo "Hamarosan...";
		}
		?>
		</div>
	
	</div>
</div><?php


}
else
{
	echo "Nincs ilyen felhasznalo!";
}
?>
</body>
</html>