<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_newrequest.php");
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
	?><p id="errNewreq"><br><img src="documents/images/warning.png" align="center" width="8%"><br>
	Hiba!<br>Nincs jogod ehhez az oldalhoz!</p><?php
}

function new_request_form($szint)
{
	?>
	<h2 style="text-align:center;margin-bottom:25px;">Új kérés kiírása</h2>
	<div class="d-flex justify-content-center align-items-center">
	<div id='conatiner_div' class="form-row">

	<form class="was-validated">

		<div style="margin-bottom:15px;">
			<a href="wiki.php?whatRules=1">Elolvasom a szabályzatot</a>
		</div>
	
		<div class="form-group">
			<label for="cim1" class='mylabelnames'>A kvíz neve</label>
			<span id="cimMegj1"></span>
			<input type="text" id="cim1" class="form-control" name="cim1" placeholder="Rövid, lényegretörő cím..." value="<?php if (isset($_POST["cim1"])) echo $_POST["cim1"]; ?>" minlength="3" maxlength="100" required>
			<div id="valid_cim" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_cim" class="invalid-feedback">Helytelen adat! Legalább 5 és legfeljebb 100 karakter hosszú lehet a kvíz címe!</div>
		</div>

		<div id="similar_items">
			<span id='similarquiz_span'><i>Hasonló találatok:</i></span>
			<button type="button" id="search_similarquiz" class="btn btn-info" onclick="show_similar_quiznames()">Keresés...</button>
			<div id="dialogShowSimilarQuiznames" title="Hasonló találatok" style="display:none;"></div>
		</div>

		<div class="form-group">
			<label for="leiras1" class='mylabelnames'>Leírás</label>
			<span id="leirasMegj1"></span>
			<textarea id="leiras1" name="leiras1" class="form-control" maxlength="999" placeholder="Részletes leírás arról, hogy konkrétan milyen kérdéseket fog tartalmazni a kvíz (minimum 30 karakter)" required><?php if (isset($_POST["leiras1"])) echo $_POST["leiras1"];?></textarea>
			<div id="valid_leiras" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_leiras" class="invalid-feedback">Legalább 30 és legfeljebb 999 karakter hosszú legyen a leírás!</div>
		</div>
	
		<div class="form-group">
			<label for="points" class='mylabelnames'>Ajánlott pontok</label>
			<input type="text" id="points" name="points" class="form-control" value="<?php if(isset($_POST["points"])) echo $_POST["points"]; else echo "100"; ?>" placeholder="A kérésre felajánlott pontok" minlength="3" maxlength="7" pattern="^([1-9][0-9]{2,6})$" required>
			<div id="valid_leiras" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_leiras" class="invalid-feedback">Legalább 100 pontot kötelező felajánlani!</div>
		</div>

		<div class="form-group">
			<label for="nyelv1" class='mylabelnames'>Nyelv</label>
			<select id="nyelv1" class="form-control" name="nyelv1" required>
			<?php 
			if(isset($_POST['nyelv1'])){
			?>
				<option value="" <?php if($_POST["nyelv1"] == 0) echo "selected"; ?> disabled>Válaszd ki a kvíz nyelvét!</option>
				<option value="1" <?php if($_POST["nyelv1"] == 1) echo "selected"; ?>>MAGYAR</option>
				<option value="2" <?php if($_POST["nyelv1"] == 2) echo "selected"; ?>>ANGOL</option>
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
			<label for="kerdszam1" class='mylabelnames'>Kérdések száma</label>
			<input type="text" id="kerdszam1" class="form-control" name="kerdszam1" maxlength="2" placeholder="Hány kérdésből álljon a kvíz! (13 - 45)" onkeyup="minKot1()" pattern="^[1][3-9]|[2-3][0-9]|[4][0-5]$" required>
			<div id="valid_kerd" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_kerd" class="invalid-feedback">Helytelen adat! A kérdések száma 13-tól 45-ig terjedő érték lehet!</div>
		</div>

		<div class="form-group">
			<label for="kerdszamkot1" class='mylabelnames'>Általad kért kérdések</label>
			<div class='form-inline'>
				<input type="text" id="kerdszamkot1" class="form-control" name="kerdszamkot1" maxlength="2" 
				value="<?php if(isset($_POST["kerdszamkot1"])) echo $_POST["kerdszamkot1"]; ?>" placeholder="Nem kötelező megadni">
				<input type="text" id="kerdszamkot2" class="form-control" name="kerdszamkot2" value="Kötelezően beküldendő: " disabled>
			</div>
		</div>

		<div class="form-group">
			<label for="valsec1" class='mylabelnames'>Válaszolási idő</label>
			<input type="text" class="form-control" id="valsec1" name="valsec1" maxlength="2" placeholder="Hány másodperc adott 1 kérdés megválaszolására! (15 - 99)" value="<?php if(isset($_POST["valsec1"])) echo $_POST["valsec1"]; ?>" pattern="^[1][5-9]|[2-9][0-9]$" required>
			<div id="valid_valaszol" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_valaszol" class="invalid-feedback">Helytelen adat! Az idő 15 másodperctől 99-ig terjedhet ki!</div>
		</div>

		<div class="form-group">	
			<label for="showcorr1" class='mylabelnames'>Helyes válaszok mutatása</label>
			<select id="showcorr1" class="form-control" name="showcorr1" required>
				<option value="1" <?php if(isset($_POST['showcorr1'])) { if($_POST["showcorr1"] == 1) echo "selected"; } ?>>IGEN</option>
				<option value="2" <?php if(isset($_POST['showcorr1'])) { if($_POST["showcorr1"] == 2) echo "selected"; } ?>>NEM</option>
			</select>
		</div>

		<?php
		if($szint > 4)
		{
			?><div class="form-group">
				<div class='form-inline'>
					Kérés Anonymusként! <input type="checkbox" id="rejtetten1" class="form-control" name="rejtetten1">
				</div>
			</div><?php 
		} 
		?>
	
		<div class="form-group">
			<div class='form-inline'>
				Elfogadom a szabályzatot! <input type="checkbox" id="szabalyzat_check1" class="form-control" name="acceptconditions1" required>
			</div>
			<div id="valid_ell" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_ell" class="invalid-feedback">Helytelen adat! A folytatáshoz be kell jelölni ezt a négyzetet!</div>
		</div>

		<div id='process_div'>
			<button type="button" id="letrehoz" class="btn btn-primary" onclick='sendNewRequest()'>KÉRÉS ELKÜLDÉSE</button>
		
			<div id="loading_newrequestdiv" style="display:none;">
				<img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="4%" style="margin-left:30px;margin-top:8px;">
			</div>
		</div>
	
	</form>
	</div>
	</div>
	<?php
}
?>

<html>
<head>
	<title>Új kérés</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/newrequest.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/jQuery-ui.css">
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css"> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/newrequest.js"></script>
	<script type = "text/javascript" src="js/menu.js"></script>
</head>
<body>
<?php
main_menu();

$res = db_getRang();
if(!$res)
{
	die(err_db());
}
$row = mysqli_fetch_assoc($res);
if($row['lawtouserequests']==1)
{
	new_request_form($row['level']);
}
else
{
	show_forbidden();
}
?>
</body>
</html>