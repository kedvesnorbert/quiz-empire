<?php
session_start();

require_once("db/db_connect.php");
require_once("db/db_index.php");
require_once("../includes/responses.php");
require_once("../includes/ip_functions.php");
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

function show_competitionlist()
{
	$res = db_allcompetition();
	if(!$res)
	{
		die(err_db());
	}
	?>
	<table id='allcompetition_table' border='1'>
	<tr>
		<th style='width:18%'>Kvíz
		<th style='width:10%'>Kezdés ideje
		<th style='width:10%'>Lezárulás ideje
		<th style='width:10%'>Bejelentés ideje
		<th style='width:15%'>Jutalom 1-7.
		<th style='width:6%'>Aktivitás
		<th style='width:10%'>Műveletek
	<?php
	while ($row = mysqli_fetch_assoc($res))
	{
		if($row['activity'] == 1)
		{
			$is_active = "Aktív";
		}
		else
		{
			$is_active = "Inaktív";
		}
		if($row['is_expired'] == 1 && $row['activity'] == -1)
		{
			echo "<tr style='background-color:darkgrey'>";
		}
		else
		{
			echo "<tr style='background-color:white'>";
		}
		echo "<td style='text-align:center;font-weight:bold;color:" . $row['button_color'] . "'>" . $row['quiz_name'];
		echo "<td style='text-align:center;'>" . $row['startdate'];
		echo "<td style='text-align:center;'>" . $row['enddate'];
		echo "<td style='text-align:center;'>" . $row['announcement_date'];
		echo "<td style='text-align:center;'>" . "<hr>" . $row['reward1'] . " pont<hr>" . "...<hr>" . $row['reward7'] . " pont<hr>\n";
		echo "<td style='text-align:center;'>" . $is_active;
		echo "<td style='text-align:center;'>";

		if($row['is_expired'] == 0)
		{
			?>
			<button id="<?php echo "modify_competition" . $row['id'] ?>" class="modify_competition" onclick='modify_competition("<?php echo $row["id"] ?>", "<?php echo $row["quiz_id"] ?>")'>Módosítás</button>
			<div id="<?php echo "dialogModifyCompetition" . $row["id"] ?>" class="dialogModifyCompetition" title="Adatok módosítása" style="display:none;text-align:left;"></div>
			<br>
			<button id="<?php echo "delete_competition" . $row["id"] ?>" class="delete_competition" onclick='delete_competition("<?php echo $row["id"] ?>")'>Törlés</button>
			<div id="<?php echo "dialogDeleteCompetition" . $row['id'] ?>" class="dialogDeleteCompetition" title="Verseny törlése" style="display:none;"></div>
			<?php
		}
		else
		{
			echo "No settings available!";
		}
	}
	?>
	</table>
	<?php
}

?>
<html>
<head>
	<title>Dashboard</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=../includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/index.css" />
	<link rel="stylesheet" type="text/css" href="css/menu_admin.css" />
	<link rel="stylesheet" href="../includes/jQuery-ui.css">
	<script type = "text/javascript" src="../includes/jQuery.js"></script>
	<script type = "text/javascript" src="../includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/index.js"></script>
</head>
<body>

<b><font face="verdana" color="red">Üdvözlünk <?php echo $_SESSION["adminuser"]; ?>!</font></b>
<?php
	main_menu();
?>

<div id='main_indexdiv'>
	<p id='comp_title'>Versenykvízek</p>
	<div align='right'><button id='new_competition' onclick='new_competition()'>Új verseny létrehozása</button></div>
	<div id="dialogNewCompetition" title="Új verseny létrehozása" style="display:none;"></div>
<?php
	show_competitionlist();
?>
</div>

</body>
</html>