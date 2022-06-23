<?php
session_start();

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{
require_once("../db/db_connect.php");
require_once("../db/db_index.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");
require_once("../view/view_error.php");

function next_level_criteria($szint, $pontok, $jatekszam)
{
	if($szint == 2)
	{
		$req_pontok = 20 - $pontok;
		$req_jatekok = 2 - $jatekszam;
		if($req_pontok<1)
		{
			$req_pontok = 0;
		}
		if($req_jatekok<1)
		{
			$req_jatekok = 0;
		}
		echo "<b><u>" . $req_pontok . " pont</u></b> és <b><u>" . $req_jatekok . " kvíz</u></b>en való részvétel.";
	}
	elseif($szint == 3)
	{
		$req_pontok = 501 - $pontok;
		$req_jatekok = 51 - $jatekszam;
		if($req_pontok<1)
		{
			$req_pontok = 0;
		}
		if($req_jatekok<1)
		{
			$req_jatekok = 0;
		}
		echo "<b><u>" . $req_pontok . " pont</u></b> és <b><u>" . $req_jatekok . " kvíz</u></b>en való részvétel.";
	}
	elseif($szint == 4)
	{
		$req_pontok = 5001 - $pontok;
		$req_jatekok = 501 - $jatekszam;
		if($req_pontok<1)
		{
			$req_pontok = 0;
		}
		if($req_jatekok<1)
		{
			$req_jatekok = 0;
		}
		echo "<b><u>" . $req_pontok . " pont</u></b> és <b><u>" . $req_jatekok . " kvíz</u></b>en való részvétel.";
	}
	elseif($szint == 5)
	{
		$req_pontok = 15000 - $pontok;
		$req_jatekok = 1500 - $jatekszam;
		if($req_pontok<1)
		{
			$req_pontok = 0;
		}
		if($req_jatekok<1)
		{
			$req_jatekok = 0;
		}
		echo "<b><u>" . $req_pontok . " pont</u></b> és <b><u>" . $req_jatekok . " kvíz</u></b>en való részvétel.";
	}
}

function previuos_level_criteria($szint, $pontok)
{
	if($szint == 1)
	{
		$req_pontok = $pontok -20;
		echo "<i>" . $req_pontok . " pont vesztés</i>";
	}
	elseif($szint == 2)
	{
		$req_pontok = $pontok -501;
		echo "<i>" . $req_pontok . " pont vesztés</i>";
	}
	elseif($szint == 3)
	{
		$req_pontok = $pontok -5001;
		echo "<i>" . $req_pontok . " pont vesztés</i>";
	}
	elseif($szint == 4)
	{
		$req_pontok = $pontok -15000;
		echo "<i>" . $req_pontok . " pont vesztés</i>";
	}
}

function next_level_data()
{
	$res = db_nextleveldata();
	if(!$res)
	{
		die(err_db());
	}
	$row = mysqli_fetch_assoc($res);
	?>
	<div id='next_level_container'>
	<p id="current_level">Jelenlegi szint: <font color='red'><b><?php echo $row['level'] . "."; ?></b></font>
	<?php
	if($row['level']>=5)
	{
		echo " (Ez a legmagasabb szint. Innen már nincs továbblépés.) </p>";
	}
	else {?><br>
	</p>
	<p id="next_level_required">A következő szintig szükséges: 
	<?php
	$szint_kov = $row['level'] + 1;
	next_level_criteria($szint_kov, $row['points'], $row['quizplayed_total']);
	}?>
	</p>
	
	<?php
	$szint_prev = $row['level'] - 1;
	if($row['level']> 1){
		?>
		<p id="previuos_level">Visszaesés az előző szintre: -
		<?php
		previuos_level_criteria($szint_prev, $row['points']);
		?> esetén.<?php
	}
	?>
	</p>
	</div>
<?php
	
}

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax()!= -1)
	{
		next_level_data();
	}
	else
	{
		err_timeout();
	}
}
else
{
	require_once("../error.php");
}

}
?>