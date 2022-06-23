<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function index_main_long() // this user can post news
{
	?>
	<br><center>
	<div id='news_container'>
		<div id='newsheader'>
			<p id='newstitle'>Hírfolyam</p>
			<button id='create_new_news' class="btn btn-success" onclick='posting_news()'>Új hír kiírása</button>
			<div id="dialogPostNews" title="Új hír kiírás" style="display:none;"></div>
			<div id="dialogPostNewsAlert" title="Info" style="display:none;"></div>
		</div>
		<div id='news_display'></div>
	</div></center>
	<?php
}

function index_main()
{
	?>
	<br><center>
	<div id='news_container'>
		<div id='newsheader'>
			<p id='newstitle'>Hírfolyam</p>
		</div>
		<div id='news_display'></div>
	</div></center>
	<?php
}

function show_competition_data($btn_color, $quizname, $end_date)
{
	?><table id="comp_table">
		<td>
			<button class="compbtn" onclick="display_comp_details()" style="<?php echo $btn_color ?>"><?php echo $quizname ?></button>
			<div id="dialogBeforeCompetition" title="<?php echo $quizname ?>" style="display:none;"></div>
			<input type="hidden" id="comp_enddate" value='<?php echo $end_date; ?>'></td>
		<td id="comp_timetd">Még lejátszható: 
			<p id="demo"></p></td>
	</table><?php
}

function show_competition_expired_data($btn_color, $quizname, $end_date)
{
	?><table id="comp_table">
		<td><button class="compbtn" style="<?php echo $btn_color ?>" disabled><?php echo $quizname ?></button></td>
		<td id="comp_timetd"><?php echo $end_date ?></td>
	</table><?php
}

function show_comp_ranglist($quizname)
{
	?>
	<button id='competition_ranglist' class="btn btn-info" onclick='show_competition_ranglist()'>Ranglista</button>
	<div id="dialogShowCompetitionRanglist" title="<?php echo $quizname ?>" style="display:none;"></div>
	<?php
}

function show_start_competition($num_question, $time_to_answer, $show_answers, $r7, $r6, $r5, $r4, $r3, $r2, $r1)
{
	?>
	<div id="competitionDetails">
		<p id="cim2">Fontos tudnivalók!<br><br>
		<ol id="ol_importantdata">
			<li>A kvízen csak <b><i>egyszer </i></b> lehet részt venni.
			<li>Összesen <?php echo $num_question ?> kérdésre kell válaszolni.
			<li>Egy kérdés válaszolására <?php echo $time_to_answer ?> másodperc áll rendelkezésre.
			<li>A helyes válaszokat <?php echo $show_answers ?>
		</ol>
		<p id="cim3">Jutalmak</p>
		</div>
		<table id="rewardTable" class="table-bordered table-striped" align = "center"><ul>
		<tr id="header_rewardtable">
			<td>Teljesítés aránya
			<td>Jutalom
		<tr>
			<td id="szazalek">0% - 20%
			<td id="pontok"><?php echo $r7 ?> pont
		<tr>
			<td id="szazalek">20% - 36%
			<td id="pontok"><?php echo $r6 ?> pont
		<tr>
			<td id="szazalek">36% - 51%
			<td id="pontok"><?php echo $r5 ?> pont
		<tr>
			<td id="szazalek">51% - 74%
			<td id="pontok"><?php echo $r4 ?> pont
		<tr>
			<td id="szazalek">74% - 84%
			<td id="pontok"><?php echo $r3 ?> pont
		<tr>
			<td id="szazalek">84% - 94%
			<td id="pontok"><?php echo $r2 ?> pont
		<tr>
			<td id="szazalek">94% - 100%
			<td id="pontok"><?php echo $r1 ?> pont
		</table>
	<?php
}

function show_important_userdata($prefix, $username, $points, $quizplayed, $level)
{
	?><table align="center" id='importantData_table'>
	<tr align="center"><th><?php echo $prefix; ?>
		<th>Név: <a href="profile.php"><?php echo $username ?></a>&nbsp;&nbsp;&nbsp;
		<th>Pontok: <?php echo $points ?> &nbsp;&nbsp;&nbsp;
		<th>Kvízek: <?php echo $quizplayed ?> &nbsp;&nbsp;&nbsp;
		<th><button id="show_nextlevel" onclick='show_next_level()'><?php echo $level ?></button>
			<div id="dialogShowNextLevel" title="Információ" style="display:none;"></div>
	</table><?php
}

function game_menu()
{
	?>
	<center><h5>Válassz játéktípust!</h5>
	<table id="d_selectgametype_table">
	<tr>
		<td id="d_selectgametype_table_col1">Pontok és bónuszpontok szerezhetőek ebben a kategóriában, valamint használhatóak a segítségek, de nem kötelező. Mindegyik variánsból egy használható fel. 
		<td style="width:10%;">
		<td style="width:30%;"><button id="submit_game" class="btn btn-success" onclick='start_quizsegitseggelgyakorlo("<?php echo -1; ?>")'>Vegyes kvíz</button>
	<tr>
		<td id="d_selectgametype_table_col1">Ebben a témakörben nem lehet pontokat szerezni, valamint a segítségek sem használhatóak fel. Viszonylag könnyű, vegyes kérdésekből áll.
		<td>
		<td><button id="submit_game" class="btn btn-success" onclick='start_quizsegitseggelgyakorlo("<?php echo -2; ?>")'>Gyakorló</button>
	</table>
	</center>
	<p id='note_p_selectgame'>Megjegyzés: Egy segítség árában benne van a 3 variáns (negyedelő, felező, 100%) mindegyike. Egy kvíz alatt érdemes mindhármat felhasználni, mert már az első használatakor levonjuk a teljes segítség árát. </p>
<?php
	
}

function game_menu2()
{
	?>
	<center><br><img src="documents/images/warning.png" align = "center" width="14%"><br>
	<p id="warning_startquiz_id">Egy másik belépést észleltünk!<br>
	Előbb fejezd be a már elkezdett kvízt és utána kezdj neki egy másiknak!</p></center>
	<?php
}

?>