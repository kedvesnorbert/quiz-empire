<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

/* chat.php */
function db_usingchat()
{
	$con = connect();
	if(!$con){
		return false;
	}
	$q = "SELECT lawtousechat FROM user WHERE id='" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "'";
	$res = mysqli_query($con, $q);
    mysqli_close($con);
    if(!$res)
    {
        die(err_db());
    }
	$row = mysqli_fetch_assoc($res);
	if($row['lawtousechat'] == 1){
		return true;
	}
	return false;
}

/* ajax/group_details.php AND ajax/my_groups.php*/

function db_getmygroups()
{
	$con = connect();
	if(!$con){
		return false;
	}
	$q = "SELECT id id, group_name group_name, NOW() + INTERVAL 1 MINUTE ido FROM chat_group WHERE id = 1
	UNION (SELECT cg.id id, cg.group_name group_name, MAX(cm.sending_time) ido FROM chat_group cg JOIN group_member gm ON (cg.id = gm.group_id) JOIN chat_message cm ON (gm.group_id = cm.group_id) WHERE cg.is_deleted = 0 AND gm.user_id = '" . mysqli_real_escape_string($con, $_SESSION['user_id']) . "' GROUP BY cg.id ) ORDER BY ido DESC";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
    if(!$res)
    {
        return false;
    }
	return $res;
}

function db_getgroupdetails($id)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT group_name, group_creator, creation_date FROM chat_group WHERE id = '" . mysqli_real_escape_string($con, $id) . "' AND is_deleted = 0";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
    if(!$res)
    {
        return false;
    }
	return $res;
}

function db_isadministrator_group($id)
{
	$con = connect();
	if(!$con){
		return false;
	}
	$q = "SELECT group_creator FROM chat_group WHERE id = '" . mysqli_real_escape_string($con, $id) . "'";
	$res = mysqli_query($con, $q);
    mysqli_close($con);
    if(!$res)
    {
        die(err_db());
    }
	$row = mysqli_fetch_assoc($res);
	if($row['group_creator'] == $_SESSION['user_id'])
	{
		return true;
	}
	return false;
}

function db_getgroupmembers_details($id)
{
	$con = connect();
	if(!$con){
		return false;
	}
	$q = "SELECT u.user username, gm.user_id userid, gm.joining_date joining_date, (SELECT user FROM user WHERE id = gm.invited_by) meghivta, CASE WHEN gm.user_id = gm.invited_by THEN 'admin' ELSE 'nemadmin' END admine FROM group_member gm JOIN user u ON (gm.user_id = u.id) WHERE gm.group_id = '" . mysqli_real_escape_string($con, $id) . "' AND u.deleteduser = 0 ORDER BY gm.joining_date";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
    if(!$res)
    {
        return false;
    }
	return $res;
}

function db_isgroupmember($userid, $groupid)
{
	if($groupid == 1){
		return true;
	}
	$con = connect();
	if(!$con){
		return false;
	}
	$q = "SELECT COUNT(*) AS darab FROM group_member WHERE group_id = '" . mysqli_real_escape_string($con, $groupid) . "' AND user_id = '" . mysqli_real_escape_string($con, $userid) . "'";
	$res = mysqli_query($con, $q);
    mysqli_close($con);
    if(!$res)
    {
        die(err_db());
    }
	$row = mysqli_fetch_assoc($res);
	if($row['darab'] != 1){
		return false;
	}
	return true;
}

/* ajax/insert_msg.php AND ajax/logs.php*/
function db_getmsgs($id, $userid)
{
	$con = connect();
	if(!$con){
		return false;
	}
	if($id == 1)
	{
		$q = "SELECT u.id iduser, cm.id id, CASE WHEN u.deleteduser = 0 THEN u.user ELSE 'Törölt felhasználó' END username, cm.msg msg, CASE WHEN DATE(cm.sending_time) = CURDATE() THEN DATE_FORMAT(cm.sending_time, '%H:%i') ELSE DATE_FORMAT(cm.sending_time, '%Y-%m-%d %H:%i') END sending_time FROM chat_message cm JOIN user u ON (cm.user_id = u.id) WHERE cm.group_id = '" . mysqli_real_escape_string($con, $id) . "' ORDER by cm.sending_time DESC LIMIT 15";
	}
	else
	{
		$q = "SELECT u.id iduser, cm.id id, CASE WHEN 2 = (SELECT COUNT(*) FROM group_member WHERE group_id = '" . mysqli_real_escape_string($con, $id) . "' AND user_id = iduser) + (SELECT 1 FROM user WHERE id = u.id AND deleteduser = 0) THEN u.user ELSE 'Törölt felhasználó' END username, cm.msg msg, CASE WHEN DATE(cm.sending_time) = CURDATE() THEN DATE_FORMAT(cm.sending_time, '%H:%i') ELSE DATE_FORMAT(cm.sending_time, '%Y-%m-%d %H:%i') END sending_time FROM chat_group cg JOIN chat_message cm ON (cg.id = cm.group_id) JOIN user u ON (cm.user_id = u.id) WHERE cm.group_id = '" . mysqli_real_escape_string($con, $id) . "' AND cg.is_deleted = 0 AND 1 = (SELECT COUNT(*) AS darab FROM group_member WHERE group_id = '" . mysqli_real_escape_string($con, $id) . "' AND user_id = '" . mysqli_real_escape_string($con, $userid) . "') ORDER by cm.sending_time DESC LIMIT 15";
	}
	$res = mysqli_query($con, $q);
	mysqli_close($con);
    if(!$res)
    {
        return false;
    }
	return $res;
}

/* ajax/load_friends.php */
function db_baratLista()
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT f.id1 azon, u.user nev FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND f.status = 1 AND u.deleteduser = 0 UNION SELECT f.id2 azon, u2.user nev FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND f.status = 1 AND u2.deleteduser = 0";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
    if(!$res)
    {
        return false;
    }
	if(mysqli_num_rows($res))
    {
        return $res;
    }
	return false;
}

/* ajax/load_friends/to_invite.php */
function db_baratListaUj($csoportid)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT f.id1 azon, u.user nev FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u2.user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND f.status = 1 AND u.deleteduser = 0 AND f.id1 NOT IN (SELECT user_id FROM group_member WHERE group_id = '" . mysqli_real_escape_string($con, $csoportid) . "') UNION (SELECT f.id2 azon, u2.user nev FROM user u JOIN friend f ON f.id1 = u.id JOIN user u2 ON f.id2 = u2.id WHERE u.user = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' AND f.status = 1 AND u2.deleteduser = 0 AND f.id2 NOT IN (SELECT user_id FROM group_member WHERE group_id = '" . mysqli_real_escape_string($con, $csoportid) . "'))";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res)
	{
		return false;
	}
	if(mysqli_num_rows($res))
	{
		return $res;
	}
	return false;
}

/*ajax/show_chathistory.php */
function db_chathistory($groupid, $userid)
{
	$con = connect();
	if(!$con)
	{
		return false;
	}
	$q = "SELECT event_text, event_date FROM chat_history WHERE group_id = '" . mysqli_real_escape_string($con, $groupid) . "' AND 1 = (SELECT COUNT(DISTINCT user_id) FROM group_member WHERE group_id = '" . mysqli_real_escape_string($con, $groupid) . "' AND user_id = '" . mysqli_real_escape_string($con, $userid) . "') ORDER BY event_date DESC";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
	if(!$res || mysqli_num_rows($res)< 1)
	{
		return false;
	}
	return $res;
}
?>