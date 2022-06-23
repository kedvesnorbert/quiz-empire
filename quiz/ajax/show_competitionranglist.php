<?php
session_start();

require_once("../db/db_connect.php");
require_once("../db/db_index.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");
require_once("../view/view_error.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{

function show_competition_ranglist()
{
	$res = db_getCompetitionRanglist();
	if(!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res) == 0)
	{
		echo "<p id='list404'>Még senki sem vett részt a versenyen!</p>";
		return;
	}
	?>
	
	<table id='comp_ranglist_tbl' class='table-bordered'>
	<tr style='height:55px;background-color:lightgray;'>
		<th style='width:10%'>Helyezés
		<th style='width:30%'>Felhasználó
		<th style='width:25%'>Eredmény
		<th style='width:20%'>Időpont
	<?php
	$i = 1;
	while($row = mysqli_fetch_assoc($res))
	{
		if($row['user'] == $_SESSION['user'])
		{
			echo "<tr style='background-color:yellow'>";
		}
		else
		{
			echo "<tr>";
		}
		echo "<td style='text-align:left;'>" . $i++ . ".</td>";
		echo "<td style='text-align:center;'>" . $row['user'] . "</td>";
		echo "<td style='text-align:center;'>" . $row['score'] . "%</td>";
		echo "<td style='text-align:center;'>" . $row['finishing_date'] . "</td>";
	}
	?>
	</table>
	<p id='comp_r_note'>Ha részt vettél a kvízen és nem vagy rajta a listán, az azt jelenti, hogy nem vagy a TOP 500-ban!</p>
	<?php
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax()==-1)
	{
		err_timeout();
	}
	else
	{
		show_competition_ranglist();
	}
}
else
{
	require_once("../error.php");
}
}
?>