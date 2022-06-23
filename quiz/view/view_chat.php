<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

/*chat.php */
function show_newgroupbtn()
{
    ?>
    <div id="firstdiv_veryfirst">
    <button id="create_newgroup" class="btn btn-primary" onclick='creating_newgroup()'>Új csoport</button><br>
		<div id="dialogCreateNewGroup" title="Új csoport létrehozás" style="display:none;"></div><br>
		<p id="firstdiv_title">Csoportjaid listája</p>
    </div>
    <?php
}

/*chat.php */
function show_input()
{
	if(db_usingchat() == true)
	{
		?><div id="sendmsg_header" class='inline-form'>
			<span id="seconddiv_title">Üzenet küldése</span>
			<button type="button" class=" btn btn-primary float-right" onclick="toggle_chatdetails()">Toggle</button>
		</div>
		<br>
		<table id="msginput_table" align="center">
			<tr>
				<td style="width:94%"><input type="text" id="msg_text" name="msg" class="form-control" placeholder="Írd be az üzeneted! ..." autofocus></td>
			
				<td align="center">
				<button type="submit" id="send_msg_button" class="btn btn-success" onclick="submitChat()">Küldés</button>
				<span id="imageload" style="visibility:hidden;">
					<img src="documents/images/ajax-loader.gif" width="25"/>
				</span></td>
			</tr>
			
		</table>
		<?php
	}
	else
	{
		?>
		<center><img src="documents/images/warning.png" align = "center" width="12%"><br><?php
		echo "Nincs jogod üzenetet küldeni!</center>";
		
	}
}

/*chat.php */
function show_msg()
{
	?>
	<div id="chatlogs" style="width:100%; text-align:center; margin-top:20px; margin-bottom:30px;"><br>
	Loading chatlogs, please wait! (A BETÖLTÉS FOLYAMATBAN...) <br><br><center><img src="documents/images/ajax-loader.gif" width="40" /></center>
	</div>
	<?php
}

/* chat.php AND ajax/my_groups.php */
function show_mygroups()
{
	?>
	<div id="firstdiv_first">
		
		<div id='my_groupsdiv'>
		<?php
		$res = db_getmygroups();
        if(!$res)
        {
            die();
        }
		while($row = mysqli_fetch_assoc($res))
		{
			$temp1 = $row["group_name"];
			$temp2 = $row["id"];

            if(!isset($_POST['curr_group']))
            {
                ?>
			    <button id="<?php echo "groupname_div" . $temp2; ?>" class='groupname' onclick='show_this_msglist("<?php echo $temp2; ?>");' style="<?php if($temp2 == 1) echo "border:3px solid red";  else  echo ""; ?>"><b><font color='black'><?php echo $temp1; ?></font></b></button><br>
                <?php
            }
            else
            {
                ?>
			    <button id="<?php echo "groupname_div" . $temp2; ?>" class='groupname' onclick='show_this_msglist("<?php echo $temp2; ?>");' style="<?php if($temp2 == $_POST['curr_group']) echo "border:3px solid red";  else  echo ""; ?>"><b><font color='black'><?php echo $temp1; ?></font></b></button><br>
                <?php
            }
		}
		?>
		</div>
	</div>
	<?php
}

/* ajax/load_friends_to_invite.php */
function show_friends_invite()
{
	$res = db_baratListaUj($_POST['groupid']);
	if($res==false)
	{
		echo "<option value=\"" . 0 . "\" disabled>" . "Nincs barát, akit meghívhatsz a csoportba" . "\n";
	}
	else
	{
		while ($row = mysqli_fetch_assoc($res))
		{	
			echo "<option value=\"" . $row["azon"] . "\">" . $row["nev"] . "\n";
		}
	}
}

/*ajax/load_friends.php */
function show_friends()
{
	$res = db_baratLista();
	if(!$res)
	{
		echo "no_friends";
	}
	else
	{
		while ($row = mysqli_fetch_assoc($res))
		{	
			echo "<option value=\"" . $row["azon"] . "\">" . $row["nev"] . "\n";
		}
	}
}

/* ajax/insert_msg.php AND ajax/logs.php */
function show_chatlogs($groupid)
{
    echo "<br>";
    $res1 = db_getmsgs($groupid, $_SESSION['user_id']);
    if($res1 != false)
    {
        while($row = mysqli_fetch_array($res1))
        {
            ?>
            <table border="0" id="table_listmsgs" style="<?php if($row['username'] == $_SESSION['user']){ echo "float: right; background-color: lightgreen"; } else { echo "float:left; background-color:orange";} ?>">
            <tr>
                <td id="table_listmsgs_username"><?php if($row['username'] != "Törölt felhasználó") { echo "<b>" . $row['username'] . "</b>"; } else { echo "<i>Törölt felhasználó</i>";} ?>
            <tr>
                <td id="table_listmsgs_msg"><?php echo nl2br($row['msg']); ?>
            <tr>
                <td id="table_listmsgs_time"><?php echo "(" . $row['sending_time'] . ")"; ?>
            </table>
            <?php
        }
    }
}

/*ajax/group_details*/
function view_public_chatgroup()
{
	?>
	<p id="p_title_availablegroup">Nyilvános chatszoba</p><br><br>
	<ul>
		<li>Ez a csoport nyilvános és bárki írhat ide, ha engedélyezve van</li>
		<li>Ezt a csoportot nem lehet törölni</li>
	</ul>
	<?php
}
?>