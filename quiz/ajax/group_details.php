<?php
session_start();

require_once("../db/db_connect.php");
require_once("sessiontimeout.php");
require_once("../includes/responses.php");
require_once("../db/db_chat.php");
require_once("../view/view_chat.php");

if(!isset($_SESSION['user']))
{
    $_SESSION = array();
	session_destroy();
	header("location: ../login.php"); 
}
else
{

if (isset($_SERVER['HTTP_X_REQUESTED_WITH']) && ($_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest')) 
{
	if(logoff_ajax_onlycheck()== -1)
	{
		echo err_session_timeout();
	}
	elseif(!isset($_POST["curr_group"]) || !preg_match("/^[0-9]+$/", $_POST['curr_group']) || $_POST['curr_group'] <= 0)
	{
		echo "Hibás csoport azonosító!";
	}
	elseif(db_isgroupmember($_SESSION['user_id'], $_POST["curr_group"]) == false)
	{
		echo "<p style='margin-top:25px;margin-left:15px;margin-right:15px;text-align:center;'>Nincs engedélyed megtekinteni a csoport adatait!</p>";
	}
	else
	{
		echo "<br>";
		$res1 = db_getgroupdetails($_POST['curr_group']);
		if(!$res1)
		{
			die(err_db());
		}
		$row1 = mysqli_fetch_assoc($res1);
		
		if($_POST['curr_group'] == 1)
		{
			view_public_chatgroup();
		}
		else
		{
			?>
			<div id="thirddiv_helper">
			<p id="group_name_p"><?php echo $row1['group_name']; ?></p><br>
			<p id="group_creationdate_p">Létrehozás ideje: <?php echo substr($row1['creation_date'], 0, 10); ?></p><br>
			<button id="add_new_memberid" class="btn btn-warning" onclick='add_new_member("<?php echo $_POST["curr_group"]; ?>")'>Új tag felvétele</button><br>
			<div id="dialogAddNewMember" title="Új tag hozzáadása" style="display:none;"></div>
			<?php
			$res2 = db_getgroupmembers_details($_POST['curr_group']);
			if(!$res2)
			{
				die(err_db());
			}
			?><br><p id="group_members_p">Tagok:</p><br>
			
			<?php
			$csoportadmin = 0;
			if(db_isadministrator_group($_POST['curr_group']) == true)
			{
				$csoportadmin = 1;
			}
			while($row2 = mysqli_fetch_assoc($res2))
			{
				echo "<table id='table_groupmembers' border='0'>";
				
				echo "<tr>\n";
				if($row2['admine'] == 'admin')
				{
					echo "<td style='font-size:18px;'>" . $row2['username'] . " " . "<span id='name_administrator'>(Adminisztrátor)</span>" . "\n";
				}
				else
				{
					echo "<td style='font-size:18px;'>" . $row2['username'] . "\n";
				}
				
				
				if($csoportadmin == 1 && $_SESSION['user_id'] != $row2['userid'])
				{
					?><td align='left'><button class="removing_member" onclick='remove_from_thisgroup("<?php echo $_POST["curr_group"]; ?>", "<?php echo $row2['userid']; ?>", "<?php echo $row2['username']; ?>")'>Eltávolítás</button>
					<div id="dialogRemoveMember" title="Tag eltávolítása" style="display:none;"></div>
					<?php
				}
				echo "<tr style='font-size:14px;font-style:italic;max-width:20%;'><td> Csatlakozott: " . substr($row2['joining_date'], 0, 16) . "-kor\n";
				echo "<tr style='font-size:14px;font-style:italic;max-width:20%;'><td> Meghívta: " . $row2['meghivta'] . "\n";
				echo "</table><br>";
				
			}
			if($csoportadmin == 1)
			{
				?>
				<button class="del_group" onclick='delete_thisgroup("<?php echo $_POST["curr_group"]; ?>", "<?php echo $row1['group_name']; ?>")'>Csoport törlése</button>
				<div id="dialogDeleteGroup" title="Csoport törlése" style="display:none;"></div>
				<?php
			}
			else
			{
				?>
				<button class="exit_group" onclick='exit_thisgroup("<?php echo $_POST["curr_group"]; ?>", "<?php echo $row1['group_name']; ?>")'>Kilépés a csoportból</button>
				<div id="dialogExitGroup" title="Kilépés a csoportból" style="display:none;"></div>
				<?php
			}
			?>

			<button class="chathistory" onclick='chat_history("<?php echo $_POST["curr_group"]; ?>")'>A csoport előzményei</button>
				<div id="dialogChatHistory" title="A csoport előzményei" style="display:none;"></div>

			</div>
			<?php
		}
	}
}
else
{
	require_once("../error.php");
}

}
?>
