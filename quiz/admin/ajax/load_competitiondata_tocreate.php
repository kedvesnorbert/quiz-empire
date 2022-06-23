<?php
session_start();

if(!isset($_SESSION['adminuser']) || !isset($_SESSION['is_admin']) || !isset($_SESSION['user_id']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../adminlogin.php");
}
else
{
require_once("../db/db_connect.php");
require_once("../db/db_index.php");
require_once("../../includes/responses.php");
require_once("sessiontimeoutadmin.php");

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(adminlogoff_ajax()== -1)
    {
        echo err_session_timeout();
    }
	else
	{
		?><div id='createcompetition_maindiv'>
		<span class='competitiondata_span'>Témakör</span>
		<select id='select_thema_tocreate'>
		<option value="" disabled>(Válassz) <?php
		$resAd = db_quizlist_forupdate();
		if(!$resAd)
		{
			die(err_db());
		}
		while ($rowAd = mysqli_fetch_assoc($resAd))
		{
			echo "<option value=\"" . $rowAd["id_number"] . "\">" . $rowAd["quiz_name"] . "\n";
		}
		?></select>
		
		<span class='competitiondata_span'>Button színe</span>
		<input type='color' id='select_color_tocreate'>
		
		<span class='competitiondata_span'>Bejelentés ideje</span>
		<input type="date" id="select_anouncementdate_tocreate">
		
		<span class='competitiondata_span'>Kezdés ideje</span>
		<input type="text" id="select_startdate_tocreate" placeholder="2000-01-01 00:00:00">

		<span class='competitiondata_span'>Lezárulás ideje</span>
		<input type="text" id="select_enddate_tocreate" placeholder="2000-01-01 00:00:00">

		<span class='competitiondata_span'>Aktivitás</span>
		<select id="select_activity_tocreate">
			<option value="0">Inaktív</option>
			<option value="1">Aktív</option>
		</select>

		<span class='competitiondata_span'>Jutalom 1.</span>
		<input type="text" id="select_reward1_tocreate" placeholder="100 - 25000 pontmennyiség">

		<span class='competitiondata_span'>Jutalom 2.</span>
		<input type="text" id="select_reward2_tocreate" placeholder="Ez a pontszám legyen kisebb az előzőnél.">

		<span class='competitiondata_span'>Jutalom 3.</span>
		<input type="text" id="select_reward3_tocreate" placeholder="Ez a pontszám legyen kisebb az előzőnél.">

		<span class='competitiondata_span'>Jutalom 4.</span>
		<input type="text" id="select_reward4_tocreate" placeholder="Ez a pontszám legyen kisebb az előzőnél.">

		<span class='competitiondata_span'>Jutalom 5.</span>
		<input type="text" id="select_reward5_tocreate" placeholder="Ez a pontszám legyen kisebb az előzőnél.">

		<span class='competitiondata_span'>Jutalom 6.</span>
		<input type="text" id="select_reward6_tocreate" placeholder="Ez a pontszám legyen kisebb az előzőnél.">

		<span class='competitiondata_span'>Jutalom 7.</span>
		<input type="text" id="select_reward7_tocreate" placeholder="Ez a pontszám legyen kisebb az előzőnél.">
		
		<p id='newcompetition_notes'>
		- A kezdés és a befejezés dátuma az alábbi formátumban legyenek: 1999-12-20 18:07:01<br>
		- A három dátum szabálya: bejelentés dátum < Kezdés dátum < Lezárás dátum
		</p>
		</div><?php
	}
}
else
{
	require_once("../error.php");
}
}