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
	elseif(!isset($_POST['competitionid']) || !preg_match("/^[0-9]+$/", $_POST['competitionid']) || $_POST['competitionid'] < 1)
	{
		echo err_missing_data();
	}
	elseif(!isset($_POST['themaid']) || !preg_match("/^[0-9]+$/", $_POST['themaid']) || $_POST['themaid'] < 1)
	{
		echo err_missing_data();
	}
	else
	{
		?><div id='updatecompetition_maindiv'>
		<span class='competitiondata_span'>Témakör</span>
		<select id='select_thema_forupdate' class="<?php echo "select_thema_forupdate" . $_POST['competitionid']; ?>">
		<option value="" disabled>(Válassz) <?php
		$res = db_competitiondata_forupdate($_POST['competitionid']);
		if(!$res)
		{
			die(err_db());
		}
		$row = mysqli_fetch_assoc($res);
		$resAd = db_quizlist_forupdate();
		if(!$resAd)
		{
			die(err_db());
		}
		while ($rowAd = mysqli_fetch_assoc($resAd))
		{
			if ($rowAd["id_number"] == $row['quiz_id'])
			{
				echo "<option value=\"" . $rowAd["id_number"] . "\" selected>" . $rowAd["quiz_name"] . "\n";
			}
			else
			{
				echo "<option value=\"" . $rowAd["id_number"] . "\">" . $rowAd["quiz_name"] . "\n";
			}
		}
		?></select>
		
		<span class='competitiondata_span'>Button színe</span>
		<input type='color' id='select_color_forupdate' class="<?php echo "select_color_forupdate" . $_POST['competitionid']; ?>" value="<?php echo $row['button_color'] ?>">
		
		<span class='competitiondata_span'>Bejelentés ideje</span>
		<input type="date" id="select_anouncementdate_forupdate" class="<?php echo "select_anouncementdate_forupdate" . $_POST['competitionid']; ?>" value='<?php echo $row["announcement_date"]; ?>'>
		
		<span class='competitiondata_span'>Kezdés ideje</span>
		<input type="text" id="select_startdate_forupdate" class="<?php echo "select_startdate_forupdate" . $_POST['competitionid']; ?>" value='<?php echo $row["startdate"]; ?>'>

		<span class='competitiondata_span'>Lezárulás ideje</span>
		<input type="text" id="select_enddate_forupdate" class="<?php echo "select_enddate_forupdate" . $_POST['competitionid']; ?>" value='<?php echo $row["enddate"]; ?>'>

		<span class='competitiondata_span'>Aktivitás</span>
		<select id="select_activity_forupdate" class="<?php echo "select_activity_forupdate" . $_POST['competitionid']; ?>">
			<option value="0" <?php if($row['activity'] == 0) echo "selected"; ?>>Inaktív</option>
			<option value="1" <?php if($row['activity'] == 1) echo "selected"; ?>>Aktív</option>
		</select>

		<span class='competitiondata_span'>Jutalom 1.</span>
		<input type="text" id="select_reward1_forupdate" class="<?php echo "select_reward1_forupdate" . $_POST['competitionid']; ?>" value='<?php echo $row["reward1"]; ?>'>

		<span class='competitiondata_span'>Jutalom 2.</span>
		<input type="text" id="select_reward2_forupdate" class="<?php echo "select_reward2_forupdate" . $_POST['competitionid']; ?>" value='<?php echo $row["reward2"]; ?>'>

		<span class='competitiondata_span'>Jutalom 3.</span>
		<input type="text" id="select_reward3_forupdate" class="<?php echo "select_reward3_forupdate" . $_POST['competitionid']; ?>" value='<?php echo $row["reward3"]; ?>'>

		<span class='competitiondata_span'>Jutalom 4.</span>
		<input type="text" id="select_reward4_forupdate" class="<?php echo "select_reward4_forupdate" . $_POST['competitionid']; ?>" value='<?php echo $row["reward4"]; ?>'>

		<span class='competitiondata_span'>Jutalom 5.</span>
		<input type="text" id="select_reward5_forupdate" class="<?php echo "select_reward5_forupdate" . $_POST['competitionid']; ?>" value='<?php echo $row["reward5"]; ?>'>

		<span class='competitiondata_span'>Jutalom 6.</span>
		<input type="text" id="select_reward6_forupdate" class="<?php echo "select_reward6_forupdate" . $_POST['competitionid']; ?>" value='<?php echo $row["reward6"]; ?>'>

		<span class='competitiondata_span'>Jutalom 7.</span>
		<input type="text" id="select_reward7_forupdate" class="<?php echo "select_reward7_forupdate" . $_POST['competitionid']; ?>" value='<?php echo $row["reward7"]; ?>'>
		
		</div><?php
	}
}
else
{
	require_once("../error.php");
}
}