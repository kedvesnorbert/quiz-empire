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
require_once("../db/db_questions.php");
require_once("../../includes/responses.php");
require_once("sessiontimeoutadmin.php");

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(adminlogoff_ajax()== -1)
    {
        echo err_session_timeout();
    }
	elseif(!superadmin())
    {
        echo "Ez a beállítás csak a SzuperAdmin ranggal érhető el!";
    }
	elseif(!isset($_POST['questionid']) || !preg_match("/^[0-9]+$/", $_POST['questionid']) || $_POST['questionid'] < 1)
	{
		echo err_missing_data();
	}
	elseif(!isset($_POST['themaid']) || !preg_match("/^[0-9]+$/", $_POST['themaid']) || $_POST['themaid'] < 1)
	{
		echo err_missing_data();
	}
	else
	{
		?><div id='updatequestion_maindiv'>
		<span class='questiondata_span'>Témakör</span>
		<select id='select_thema_forupdate' class="<?php echo "select_thema_forupdate" . $_POST['questionid']; ?>">
		<option value="" disabled>(Válassz) <?php
		$res = db_questiondata($_POST['questionid']);
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
		
		<span class='questiondata_span'>Nehézség</span>
		<select id='select_diff_forupdate' class="<?php echo "select_diff_forupdate" . $_POST['questionid']; ?>">
			<option value="0" <?php if($row['difficulty'] == 0) echo "selected"; ?> disabled>Nincs eldöntve</option>
			<option value="1" <?php if($row['difficulty'] == 1) echo "selected"; ?>>KÖNNYŰ</option>
			<option value="2" <?php if($row['difficulty'] == 2) echo "selected"; ?>>NEHÉZ</option>
		</select>

		<span class='questiondata_span'>Kérdés</span>
		<input type="text" id="select_questiontext_forupdate" class="<?php echo "select_questiontext_forupdate" . $_POST['questionid']; ?>" value='<?php echo urlencode($row["question"]); ?>'>
		
		<span class='questiondata_span'>Helyes válasz</span>
		<input type="text" id="select_ans1_forupdate" class="<?php echo "select_ans1_forupdate" . $_POST['questionid']; ?>" value='<?php echo urlencode($row["ans1"]); ?>'>

		<span class='questiondata_span'>Helytelen válasz 1.</span>
		<input type="text" id="select_ans2_forupdate" class="<?php echo "select_ans2_forupdate" . $_POST['questionid']; ?>" value='<?php echo urlencode($row["ans2"]); ?>'>

		<span class='questiondata_span'>Helytelen válasz 2.</span>
		<input type="text" id="select_ans3_forupdate" class="<?php echo "select_ans3_forupdate" . $_POST['questionid']; ?>" value='<?php echo urlencode($row["ans3"]); ?>'>

		<span class='questiondata_span'>Helytelen válasz 3.</span>
		<input type="text" id="select_ans4_forupdate" class="<?php echo "select_ans4_forupdate" . $_POST['questionid']; ?>" value='<?php echo urlencode($row["ans4"]); ?>'>

		<input type='checkbox' id='select_makeunverified' class="<?php echo "select_makeunverified" . $_POST['questionid']; ?>"><span class='questiondata_span'>Megjelölés ellenőrzetlenként</span>
		</div><?php
	}
}
else
{
	require_once("../error.php");
}
}