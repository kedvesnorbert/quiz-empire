<?php
session_start();

require_once("../db/db_connect.php");
require_once("../db/db_searchuser.php");
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

function show_users($nev)
{
	?>
	<br>
	<p id="cim_p">
	<?php
	if($_POST['searching_item'] == "@!#%^&*")
	{
		echo "Legújabb felhasználóink";
		$res = db_getlastregistered();
		if(!$res)
		{
			die(err_db());
		}
	}
	else
	{
		echo "Találatok";
		$res = db_keres($nev);
		if(!$res)
		{
			die(err_db());
		}
	}
	?>
	</p>
	<table id="users_list" class="table table-striped">
	<tr>
		<th style='width:40%'>Felhasználónév
		<th style='width:10%'>Rang
		<th style='width:20%'>Legutóbb itt járt
		<th style='width:20%'>Regisztrálás ideje
	<?php
	
	if(mysqli_num_rows($res) < 1 || !$res)
	{
		echo "<tr>\n";
		echo "<td align='center' colspan='4' style='width:40%'>" . "Nincs találat!" . "\n";
	}
	
	while ($row = mysqli_fetch_assoc($res))
	{
		echo "<tr>\n";
		echo "<td class='align-middle'>" . "<a href=profile.php?profil_id=" . $row['id'] . ">" . $row['user'] . "</a>" . "\n";
		echo "<td class='align-middle'>" . $row['level'] . "\n";
		echo "<td class='align-middle'>" . $row['lastvisit'] . "\n";
		echo "<td class='align-middle'>" . $row['registrtime'] . "\n";
	}
	?></table><?php
}


if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(!isset($_POST['searching_item']) || strlen($_POST['searching_item']) < 1 || strlen($_POST['searching_item']) > 30)
	{
		echo "<p style='text-align:center;margin-top:30px;font-size:18px;'>Hiba a keresendő kifejezés nevével!</p>";
	}
	elseif(logoff_ajax()==-1)
	{
		echo "<p style='text-align:center;margin-top:30px;font-size:18px;'>" . err_session_timeout() . "</p>";
	}
	elseif(db_using_usersearch()==false && $_POST['searching_item'] != "@!#%^&*")
	{
		echo "<p style='text-align:center;margin-top:30px;font-size:18px;'>Nincs jogod használni a keresőt!</p>";
	}
	else
	{
		show_users($_POST['searching_item']);
	}
}
else
{
	require_once("../error.php");
}
}
?>