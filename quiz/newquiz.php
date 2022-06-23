<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_newquiz.php");
require_once("includes/responses.php");
require_once("includes/update_logoff.php");
require_once("includes/ip_functions.php");
require_once("view/menu.php");

if(!isset($_SESSION["user"]))
{
	$fromurl = urlencode($_SERVER["REQUEST_URI"]);
	setcookie("fromwhere", $fromurl);
	header("location: login.php");
	$_SESSION = array();
	session_destroy();
}

function show_forbidden()
{
	?><p id="errNewQuiz"><br><img src="documents/images/warning.png" align="center" width="7%"><br>
	Hiba!<br>Jelenleg nincs jogod a funkció használatához!</p><?php
}

function validate_date($date, $format = 'Y-m-d')
{
    $d = DateTime::createFromFormat($format, $date);
    	return $d && $d->format($format) === $date;
}

function new_quiz_form()
{
	$rang = db_getRang();
	?>
	<h2 style="text-align:center;margin-bottom:25px;">Új kvíz létrehozása</h2>
	<div class="d-flex justify-content-center align-items-center">
	<div id='conatiner_div' class="form-row">
	
	<form action="newquiz.php" method="POST" class="was-validated" onsubmit="return sendquiz_validation()">
		<div style="margin-bottom:15px;">
			<a href="wiki.php?whatRules=4">Elolvasom a szabályzatot</a>
		</div>

		<div class="form-group">
			<label for="cim" class='mylabelnames'>A kvíz neve</label>
			<span id="cimMegj"></span>
			<input type="text" id="cim" class="form-control" name="cim" maxlength="100" placeholder="Rövid, lényegretörő cím" value="<?php if (isset($_POST["cim"])) echo $_POST["cim"]; ?>" minlength="3" maxlength="100" required>
			<div id="valid_cim" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_cim" class="invalid-feedback">Helytelen adat! Legalább 5 és legfeljebb 100 karakter hosszú lehet a kvíz címe!</div>
		</div>
		
		<div id="similar_items">
			<span id='similarquiz_span'><i>Hasonló találatok:</i></span>
			<button type="button" id="search_similarquiz" class="btn btn-info" onclick="show_similar_quiznames()">Keresés...</button>
			<div id="dialogShowSimilarQuiznames" title="Hasonló találatok" style="display:none;"></div>
		</div>

		<div class="form-group">
			<label for="leiras" class='mylabelnames'>Leírás</label>
			<span id="leirasMegj"></span>
			<textarea id="leiras" name="leiras" class="form-control" maxlength="999" placeholder="Részletes leírás arról, hogy konkrétan milyen kérdéseket fog tartalmazni a kvíz (minimum 30 karakter)"  required><?php if (isset($_POST["leiras"])) echo $_POST["leiras"];?></textarea>
			<div id="valid_leiras" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_leiras" class="invalid-feedback">Legalább 30 és legfeljebb 999 karakter hosszú legyen a leírás!</div>
		</div>
		
		<div class="form-group">
			<label for="ok" class='mylabelnames'>Létrehozás oka</label>
			<span id="okMegj"></span>
			<textarea id="ok" name="ok" class="form-control" maxlength="150" placeholder="Miért szeretnéd létrehozni ezt a kvízt?" required><?php if (isset($_POST["ok"])) echo $_POST["ok"];?></textarea>
			<div id="valid_ok" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_ok" class="invalid-feedback">Legalább 5 és legfeljebb 150 karakter hosszú legyen!</div>
		</div>
		
		<div class="form-group">
			<label for="nyelv" class='mylabelnames'>Nyelv</label>
			<select id="nyelv" class="form-control" name="nyelv" required>
			<?php 
			if(isset($_POST['nyelv'])){
			?>
				<option value="" <?php if($_POST["nyelv"] == 0) echo "selected"; ?> disabled>Válaszd ki a kvíz nyelvét!</option>
				<option value="1" <?php if($_POST["nyelv"] == 1) echo "selected"; ?>>MAGYAR</option>
				<option value="2" <?php if($_POST["nyelv"] == 2) echo "selected"; ?>>ANGOL</option>
			<?php }
			else
			{
				?>
				<option value="" selected disabled>Válaszd ki a kvíz nyelvét!</option>
				<option value="1">MAGYAR</option>
				<option value="2">ANGOL</option>
				<?php
			} ?>
			</select>
			<div id="valid_lang" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_lang" class="invalid-feedback">Helytelen adat! Válassz a Magyar és Angol nyelvek közül!</div>
		</div>
			
		<div class="form-group">
			<label for="kvizelerhetoseg" class='mylabelnames'>A kvíz elérhetősége</label>
			<select id="kvizelerhetoseg" class="form-control" name="kvizelerhetoseg" onchange="showDiv('elerh', this)" onclick="showDivJel('jelszavas', this)" required>
			<?php
			if(isset($_POST['kvizelerhetoseg'])){
			?>
				<option value="" <?php if($_POST["kvizelerhetoseg"] == 0) echo "selected"; ?> disabled>Válaszd ki, hogy kik érhetik el a kvízt!</option>
				<option value="1" <?php if($_POST["kvizelerhetoseg"] == 1) echo "selected"; ?>>Csak én és adminok</option>
				<option value="2" <?php if($_POST["kvizelerhetoseg"] == 2) echo "selected"; ?>>Én, adminok és az alábbi barátaim</option>
				<option value="5" <?php if($_POST["kvizelerhetoseg"] == 5) echo "selected"; ?>>Én, adminok és a jelenlegi/ezutáni összes barátom</option>
				<option value="3" <?php if($_POST["kvizelerhetoseg"] == 3) echo "selected"; ?>>Mindenki</option>
				<?php 
				if($rang==true)
				{
					?>
					<option value="4" <?php if($_POST["kvizelerhetoseg"] == 4) echo "selected"; ?>>Akik ismerik a jelszót</option>
					<?php
				}
			} 
			else
			{
				?><option value="" selected disabled>Válaszd ki, hogy kik érhetik el a kvízt!</option>
				<option value="1">Csak én és az adminok</option>
				<option value="2">Én, adminok és az alábbi barátaim</option>
				<option value="5">Én, adminok és a jelenlegi/ezutáni összes barátom</option>
				<option value="3">Mindenki</option>
				<?php 
				if($rang==true)
				{
					?>
					<option value="4">Akik ismerik a jelszót</option>
					<?php
				}
			}?>
			</select>
			<div id="valid_elerh" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_elerh" class="invalid-feedback">Helytelen adat! Válassz a fenti elérhetőségek közül!</div>

			<?php
			if(isset($_POST['kvizelerhetoseg']))
			{
				?><div id="elerh" style=<?php if($_POST['kvizelerhetoseg'] == 2) echo "display:block;"; else echo "display:none;" ?>><?php
			}
			else
			{
				?><div id="elerh"><?php
			}
	
			$temp = db_baratLista(); 
			if($temp==false)
			{
				echo "<span style='color:#DC3545;font-weight:bold;font-size:10pt;'>Jelenleg egy barátod sincs!<br>Választanod kell a többi opció közül!</span>";
			}
			else
			{
				?><span id="select_friendsText">Válaszd ki a barátaidat az alábbi listából!<br><i>(Ctrl billenytűt nyomva tartva kattints a barátaid nevére!)</i></span><br>
				<select id="elerheto_select" name="elerheto[]" multiple>
				<?php
				$res = $temp;
				while ($row = mysqli_fetch_assoc($res))
				{	
					if(isset($_POST['elerheto']) && is_array($_POST['elerheto']) && in_array($row['azon'], $_POST['elerheto']) == 1 )
					{
						echo "<option value=\"" . $row["azon"] . "\" selected>" . $row["nev"] . "\n";
					}
					else
					{
						echo "<option value=\"" . $row["azon"] . "\">" . $row["nev"] . "\n";
					}
				}
				?></select>
				<span id="quizelerh_msg"></span>
				<?php
			}
			?>	
		</div>
		
		<?php
		if(isset($_POST['kvizelerhetoseg']))
		{
			?><div id="jelszavas" style=<?php if($_POST['kvizelerhetoseg'] == 4) echo "display:block;"; else echo "display:none;" ?>><?php
		}
		else
		{
			?><div id="jelszavas"><?php
		}
		?>
		
		<span id="quizpws"></span>
		<table>
		<tr>
			<td id="pwtext1">Jelszó a kvízhez:
			<td><input type="password" id="pwt1" name="pass1">
		<tr>
			<td id="pwtext2">Jelszó újra:
			<td><input type="password" id="pwt2" name="pass2">	
		</table>
		<span id="quizpws_msg"></span>
		</div>
	</div>
	
		<div class="form-group">
			<label for="numofplaying" class='mylabelnames'>Próbálkozások száma</label>
			<select id="numofplaying" class="form-control" name="numofplaying" required>
			<?php
			if(isset($_POST['numofplaying'])){
			?>
				<option value="" <?php if($_POST["numofplaying"] == 0) echo "selected"; ?> disabled>Válaszd ki, hány alkalommal lehet részt venni a kvízen!</option>
				<option value="1" <?php if($_POST["numofplaying"] == 1) echo "selected"; ?>>Csak egyszer</option>
				<option value="2" <?php if($_POST["numofplaying"] == 2) echo "selected"; ?>>2x</option>
				<option value="3" <?php if($_POST["numofplaying"] == 3) echo "selected"; ?>>3x</option>
				<option value="4" <?php if($_POST["numofplaying"] == 4) echo "selected"; ?>>5x</option>
				<option value="5" <?php if($_POST["numofplaying"] == 5) echo "selected"; ?>>10x</option>
				<option value="6" <?php if($_POST["numofplaying"] == 6) echo "selected"; ?>>Korlátlan alkalommal</option>
			<?php 
			} else {
			?>
				<option value="" selected disabled>Válaszd ki, hány alkalommal lehet részt venni a kvízen!</option>
				<option value="1">Csak egyszer</option>
				<option value="2">2x</option>
				<option value="3">3x</option>
				<option value="4">5x</option>
				<option value="5">10x</option>
				<option value="6">Korlátlan alkalommal</option>
			<?php
			}
			?>
			</select>
			<div id="valid_alkalmak" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_alkalmak" class="invalid-feedback">Helytelen adat! Válassz a fenti listából egy értéket!</div>
		</div>

		<div class="form-group">
			<label for="kerdszam" class='mylabelnames'>Kérdések száma</label>
			<div class='form-inline'>
				<input type="text" id="kerdszam" class="form-control" name="kerdszam" maxlength="2" placeholder="Hány kérdésből álljon a kvíz! (13-45)" onkeyup="minKot()" pattern="^[1][3-9]|[2-3][0-9]|[4][0-5]$" required>
				<input type="text" id="kerdszamkot" class="form-control" name="kerdszamkot" value="Kötelezően beküldendő: " disabled>
			</div>
			<div id="valid_kerd" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_kerd" class="invalid-feedback">Helytelen adat! A kérdések száma 13-tól 45-ig terjedő érték lehet!</div>
		</div>
		
		<div class="form-group">
			<label for="kerdfogadas" class='mylabelnames'>Kérdések fogadása</label>
			<select id="kerdfogadas" class="form-control" name="kerdfogadas" onchange="showDiv2('fogadkerd', this)" required>
			<?php
			if(isset($_POST['kerdfogadas'])){
			?>
				<option value="" <?php if($_POST["kerdfogadas"] == 0) echo "selected"; ?> disabled>Válaszd ki, hogy kik küldhetnek be kérdéseket a kvízhez!</option>
				<option value="1" <?php if($_POST["kerdfogadas"] == 1) echo "selected"; ?>>Csak én</option>
				<option value="2" <?php if($_POST["kerdfogadas"] == 2) echo "selected"; ?>>Én és az adminok</option>
				<option value="5" <?php if($_POST["kerdfogadas"] == 5) echo "selected"; ?>>Én, adminok és a jelenlegi/ezutáni összes barátom</option>
				<option value="3" <?php if($_POST["kerdfogadas"] == 3) echo "selected"; ?>>Én, adminok és az alábbi barátaim</option>
				<option value="4" <?php if($_POST["kerdfogadas"] == 4) echo "selected"; ?>>Mindenki</option>
			<?php
			} else
			{ ?>
				<option value="" selected disabled>Válaszd ki, hogy kik küldhetnek be kérdéseket a kvízhez!</option>
				<option value="1">Csak én</option>
				<option value="2">Én és az adminok</option>
				<option value="5">Én, adminok és a jelenlegi/ezutáni összes barátom</option>
				<option value="3">Én, adminok és az alábbi barátaim</option>
				<option value="4">Mindenki</option>
			<?php
			}
			?>
			</select>
			<div id="valid_fogad" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_fogad" class="invalid-feedback">Helytelen adat! Válassz a fenti elérhetőségek közül!</div>
	
		<?php
		if(isset($_POST['kerdfogadas']))
		{
			?><div id="fogadkerd" style=<?php if($_POST['kerdfogadas'] == 3) echo "display:block;"; else echo "display:none;" ?>><?php
		}
		else
		{
			?><div id="fogadkerd"><?php
		}

			$temp = db_baratLista();
			if($temp==false)
			{
				echo "<span style='color:#DC3545;font-weight:bold;font-size:10pt;'>Jelenleg egy barátod sincs!<br>Választanod kell a többi opció közül!</span>";
			}
			else
			{
				?>
				<span id="select_friendsText">Válaszd ki a barátaidat az alábbi listából!<br> <i>(Ctrl billenytűt nyomva tartva kattints a barátaid nevére!)</i></span></span><br>
				<select id="fogad_select" name="fogad[]" multiple>
				<?php
				$res_2 = $temp;
				while ($row_2 = mysqli_fetch_assoc($res_2))
				{	
					if(isset($_POST['fogad']) && is_array($_POST['fogad']) && in_array($row_2['azon'], $_POST['fogad']) == 1 )
					{
						echo "<option value=\"" . $row_2["azon"] . "\" selected>" . $row_2["nev"] . "\n";
					}
					else
					{
						echo "<option value=\"" . $row_2["azon"] . "\">" . $row_2["nev"] . "\n";
					}
				}
				?></select>
				<span id="quizkerdbekuld_msg"></span>
				<br><?php
			}
			?>	
		</div>
		</div>
		
		<div class="form-group">
			<label for="valsec" class='mylabelnames'>Válaszolási idő</label>
			<input type="text" class="form-control" id="valsec" name="valsec" maxlength="2" placeholder="Egy kérdésre jutó válaszolási idő (15 - 99 másodperc)" value="<?php if (isset($_POST["valsec"])) echo $_POST["valsec"]; ?>" pattern="^[1][5-9]|[2-9][0-9]$" required>
			<div id="valid_valaszol" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_valaszol" class="invalid-feedback">Helytelen adat! Az idő 15 másodperctől 99-ig terjedhet ki!</div>
		</div>
		
		<div class="form-group">
			<label for="showcorr" class='mylabelnames'>Helyes válaszok mutatása</label>
			<select id="showcorr" class="form-control" name="showcorr" required>
			<?php
			if(isset($_POST['showcorr'])){
			?>
				<option value="1" <?php if($_POST["showcorr"] == 1) echo "selected"; ?>>IGEN</option>
				<option value="2" <?php if($_POST["showcorr"] == 2) echo "selected"; ?>>NEM</option>
			<?php
			}
			else
			{
				?>
				<option value="1">IGEN</option>
				<option value="2">NEM</option>
				<?php
			}
			?>
			</select>
		</div>
		
		<div class="form-group">
			<label for="verifytest" class='mylabelnames'>Ellenőrzések száma</label>
			<input type="text" class="form-control" id="verifytest" name="verifytest" maxlength="6" placeholder="Hányszor lehet visszanézni és exportálni a kvízt eredményét?" value="<?php if (isset($_POST["verifytest"])) echo $_POST["verifytest"]; else echo "20"; ?>" pattern="^([1-9][0-9]{0,5}|[0])$" required>
			<div id="valid_ell" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_ell" class="invalid-feedback">Helytelen adat! Minimum 0 és legfeljebb 100000 értéket fogadunk el!</div>
		</div>
		
		<div class="form-group">
			<label for="admistest" class='mylabelnames'>Átmenő százalékban</label>
			<input type="text" class="form-control" id="admistest" name="admistest" maxlength="3" placeholder="Hány százalékot kell elérni az átmenéshez?" value="<?php if (isset($_POST["admistest"])) echo $_POST["admistest"]; else echo "50"; ?>" pattern="^([1-9][0-9]{0,1}|[0]|100)$" required>
			<div id="valid_szazalek" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_szazalek" class="invalid-feedback">Helytelen adat! Értelemszerűen 0-tól 100-ig terjedhet az átmenés értéke százalékban!</div>
		</div>
		
		<div class="form-group">
			<label for="startd" class='mylabelnames'>Időkorlát (kezdés és befejezés dátuma)</label>
			<div class='form-inline'>
				<input type="date" id="startd" class="form-control" name="startd" value="<?php if (isset($_POST["startd"])) echo $_POST["startd"]; ?>">
				<input type="date" id="endd" class="form-control" name="endd" value="<?php if (isset($_POST["endd"])) echo $_POST["endd"]; ?>">
			</div>
		</div>
	
		<?php
		if($rang== true)
		{
		?>
			<div class="form-group">
				<div class='form-inline'>
					A nevem legyen rejtett! <input type="checkbox" id="rejtetten" class="form-control" name="rejtetten">
				</div>
			</div>
		<?php 
		} ?>

		<div class="form-group">
			<div class='form-inline'>
				Elfogadom a szabályzatot! <input type="checkbox" id="szabalyzat_check" class="form-control" name="acceptconditions" required>
			</div>
			<div id="valid_ell" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_ell" class="invalid-feedback">Helytelen adat! A folytatáshoz be kell jelölni ezt a négyzetet!</div>
		</div>
	
		<button type="submit" class="btn btn-success" name="sendQuiz">BEKÜLDÉS</button>
	
	</form>
	</div>
	</div>
	
	<?php
}

?>
<html>
<head>
	<title>Új kvíz</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/newquiz.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/jQuery-ui.css">
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css"> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/newquiz.js"></script>
	<script type = "text/javascript" src="js/menu.js"></script>
</head>
<body>
<?php
main_menu();

if(db_keszithetQuizt()==true)
{
	if(isset($_POST['sendQuiz']))
	{
		if(strlen($_POST['cim']) < 1)
		{
			?><script>alert('Nem írtad be a kvíz címét!');</script><?php
		}
		elseif(strlen($_POST['cim']) > 100)
		{
			?><script>alert('A cím hosszát próbáld lecsökkenteni. Javaslat: törölj vissza a címből, tegyél 3 pontot a végére és a leírásban feltünteted a teljes címet!');</script><?php
		}
		elseif(strlen($_POST['leiras']) < 30)
		{
			?><script>alert('A leírás hossza legalább 30 karakter hosszú legyen!');</script><?php
		}
		elseif(strlen($_POST['leiras']) > 999)
		{
			?><script>alert('A leírás hosszát próbáld lecsökkenteni. Egy ékezetes karakter 2 átlagos karakternek felel meg!');</script><?php
		}
		elseif(strlen($_POST['ok']) < 5)
		{
			?><script>alert('A kvíz létrehozásának oka legalább 5 karakter hosszú legyen!');</script><?php
		}
		elseif(strlen($_POST['ok']) > 150)
		{
			?><script>alert('Túl hosszú a létrehozás oka! Egy ékezetes karakter 2 átlagos karakternek felel meg!');</script><?php
		}
		elseif($_POST['nyelv'] != 1 && $_POST['nyelv'] != 2)
		{
			?><script>alert('Nem választottad ki a kvíz nyelvét!');</script><?php
		}
		elseif($_POST['kvizelerhetoseg'] != 1 && $_POST['kvizelerhetoseg'] != 2 && $_POST['kvizelerhetoseg'] != 3 && $_POST['kvizelerhetoseg'] != 4 && $_POST['kvizelerhetoseg'] != 5)
		{
			?><script>alert('Nem választottad ki a kvíz elérhetőségét!');</script><?php
		}
		elseif($_POST['kvizelerhetoseg'] == 4 && ($_POST['pass1'] == "" || $_POST['pass2'] == "" || $_POST['pass1'] != $_POST['pass2']))
		{
			?><script>alert('HIBA! Nem írtál be semmit a jelszavakhoz, vagy nem talál a két jelszó!');</script><?php
		}
		elseif($_POST['numofplaying'] != 1 && $_POST['numofplaying'] != 2 && $_POST['numofplaying'] != 3 && $_POST['numofplaying'] != 4 && $_POST['numofplaying'] != 5 && $_POST['numofplaying'] != 6)
		{
			?><script>alert('Nem választottad ki a kvízen való részvételek számát!');</script><?php
		}
		elseif($_POST['kerdszam'] < 13 || $_POST['kerdszam'] > 45 || !preg_match("/^[0-9]+$/", $_POST["kerdszam"]))
		{
			?><script>alert('HIBA! A kvíz 13 és 45 közötti kérdésből állhat!');</script><?php
		}
		elseif($_POST['kerdfogadas'] != 1 && $_POST['kerdfogadas'] != 2 && $_POST['kerdfogadas'] != 3 && $_POST['kerdfogadas'] != 4 && $_POST['kerdfogadas'] != 5)
		{
			?><script>alert('Nem választottad ki a kvízhez való kérdések beküldési opcióját!');</script><?php
		}
		elseif($_POST['valsec'] < 15 || $_POST['valsec'] > 99 || !preg_match("/^[0-9]+$/", $_POST["valsec"]))
		{
			?><script>alert('HIBA! Az 1 kérdésre jutó válaszolási idő 15 - 99 másodperc lehet!');</script><?php
		}
		elseif($_POST['showcorr'] != 1 && $_POST['showcorr'] != 2)
		{
			?><script>alert('HIBA! Nincs kiválasztva a helyes válaszok megmutatása opció!');</script><?php
		}
		elseif($_POST['verifytest'] < 0 || $_POST['verifytest'] > 1000000 || strlen($_POST['verifytest']) > 8 || !preg_match("/^[0-9]+$/", $_POST["verifytest"]))
		{
			?><script>alert('HIBA! A kvíz ellenőrzési alkalmai 0 és 1000000 közötti szám lehet! ');</script><?php
		}
		elseif($_POST['admistest'] < 10 || $_POST['admistest'] > 100 || strlen($_POST["admistest"]) < 2 || strlen($_POST["admistest"]) > 3 || !preg_match("/^[0-9]+$/", $_POST["admistest"]))
		{
			?><script>alert('HIBA! Az átmenést százalékban kell megadni, amely minimum 10% kell legyen és értelemszerűen max 100%!!! Csak a számot írd be!');</script><?php
		}
		elseif(validate_date($_POST['startd']) == false  && !empty($_POST['startd']) )
		{
			?><script>alert('HIBA! Helytelen a KEZDŐ dátum!');</script><?php
		}
		elseif(validate_date($_POST['endd']) == false  && !empty($_POST['endd']) )
		{
			?><script>alert('HIBA! Helytelen a második dátum!');</script><?php
		}
		elseif(!isset($_POST['elerheto']) && $_POST['kvizelerhetoseg'] == 2)
		{
			?><script>alert('HIBA! Nem választottad ki egy barátodat sem, akik elérhetik a kvízt!');</script><?php
		}
		elseif(!isset($_POST['fogad']) && $_POST['kerdfogadas'] == 3)
		{
			?><script>alert('HIBA! Nem választottad ki egy barátodat sem, akik küldhetnek be kérdéseket a kvízedhez!');</script><?php
		}
		elseif(!isset($_POST['acceptconditions']))
		{
			?><script>alert('HIBA! A szabályzat elfogadása kötelező!');</script><?php
		}
		else
		{
			if(isset($_POST['rejtetten']))
			{
				$rej = 1;
			}
			else
			{
				$rej = 0;
			}
			if(isset($_POST['pass1']) && strlen($_POST['pass1'])>0 && isset($_POST['pass2']) && strlen($_POST['pass2'])>0)
			{
				$jel = hash("sha512", $_POST["pass1"]);
			}
			else
			{
				$jel = '';
			}
			
			if(isset($_POST['elerheto']) && is_array($_POST['elerheto']))
			{
				$_POST['elerheto'] = implode(',',$_POST['elerheto']);
			}
			else
			{
				$_POST['elerheto'] = "";
			}
			if(isset($_POST['fogad']) && is_array($_POST['fogad']))
			{
				$_POST['fogad'] = implode(',',$_POST['fogad']);
			}
			else
			{
				$_POST['fogad'] = "";
			}
			
			$con = connect();	
			mysqli_query($con, "SET @p_response");
			mysqli_query($con, "CALL create_quiz('" . mysqli_real_escape_string($con, $_POST['cim']) . "', '" . mysqli_real_escape_string($con, $_POST['leiras']) . "', '" . mysqli_real_escape_string($con, $_POST['ok']) . "', '" . mysqli_real_escape_string($con, $_POST['nyelv']) . "', '" . mysqli_real_escape_string($con, $_POST['kvizelerhetoseg']) . "', '" . mysqli_real_escape_string($con, $_POST['numofplaying']) . "', '" . mysqli_real_escape_string($con, $_POST['kerdszam']) . "', '" . mysqli_real_escape_string($con, $_POST['kerdfogadas']) . "', '" . mysqli_real_escape_string($con, $_POST['valsec']) . "', '" . mysqli_real_escape_string($con, $_POST['showcorr']) . "', '" . mysqli_real_escape_string($con, $_POST['startd']) . "', '" . mysqli_real_escape_string($con, $_POST['endd']) . "', '" . mysqli_real_escape_string($con, $_SESSION['user']) . "', '" . mysqli_real_escape_string($con, $rej) . "', '" . mysqli_real_escape_string($con, $jel) . "', '" . mysqli_real_escape_string($con, $_POST['verifytest']) . "', '" . mysqli_real_escape_string($con, $_POST['admistest']) . "', '" . mysqli_real_escape_string($con, $_POST['elerheto']) . "', '" . mysqli_real_escape_string($con, $_POST['fogad']) . "', @p_response)");
			$q = "SELECT @p_response AS uzenet";
			$res = mysqli_query($con, $q);
			$row = mysqli_fetch_assoc($res);
			$kiir = $row['uzenet'];
			mysqli_close($con);	
			if($kiir == "Sikeres művelet!")
			{
				$_POST["cim"] = $_POST["leiras"] = $_POST["ok"] = $_POST["elerheto"] = $_POST["kerdszam"] = $_POST["fogad"] = $_POST["valsec"] = $_POST["kerdszamkot1"] = $_POST["startd"] = $_POST["endd"] = "";
				$_POST["nyelv"] = $_POST["kvizelerhetoseg"] = $_POST["numofplaying"] = $_POST["kerdfogadas"] = 0;
				$_POST['showcorr'] = 1;
				$_POST["verifytest"] = 20;
				$_POST['admistest'] = 50;
			}
			?><script>alert('<?php echo $kiir; ?>') </script><?php
		}
	}
	new_quiz_form();
}
else
{
	show_forbidden();
}
?>
</body>
</html>