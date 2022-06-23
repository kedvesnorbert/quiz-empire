<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

global $log_types;
$log_types = inbox_msg_types();

function db_messagedata_system()
{
    $con = connect();
	if (!$con)
	{
		return false;
	}
    global $log_types;
	$res = mysqli_query($con, "SELECT id, log_message AS uzenet, admin_name AS modder, log_date AS ido, is_seen AS latta, 0 AS sender_id, 0 AS receiver_id FROM log_data WHERE log_type IN (" . $log_types . ") AND username = '" . mysqli_real_escape_string($con, $_SESSION['user']) . "' ORDER BY is_seen ASC, log_date DESC LIMIT 100");
	mysqli_close($con);
	if(!$res){
		return false;
	}
	return $res;
}

function db_clientsdata()
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
    global $log_types;
	$res = mysqli_query($con, "SELECT DISTINCT 'SYSTEM' AS username, 0 AS identifier, CASE WHEN 0 = (SELECT COUNT(*) FROM log_data  WHERE username = '" . $_SESSION['user'] . "' AND log_type IN (" . $log_types . ") AND is_seen = 0) THEN 0 ELSE 1 END AS olvasott FROM dual 
    UNION 
    SELECT DISTINCT CASE WHEN pm.sender_id = '" . $_SESSION['user_id'] . "' THEN (SELECT user FROM user WHERE id = pm.receiver_id) ELSE (SELECT user FROM user WHERE id = pm.sender_id) END AS username, CASE WHEN pm.sender_id = '" . $_SESSION['user_id'] . "' THEN pm.receiver_id ELSE pm.sender_id END AS identifier, CASE WHEN 0 = (SELECT COUNT(*) FROM private_message WHERE receiver_id = '" . $_SESSION['user_id'] . "' AND sender_id = pm.sender_id AND read_msg = 0) THEN 0 ELSE 1 END AS olvasott FROM private_message pm WHERE pm.receiver_id = '" . $_SESSION['user_id'] . "' OR pm.sender_id = '" . $_SESSION['user_id'] . "' ORDER BY olvasott DESC");
	mysqli_close($con);
	if(!$res)
    {
		return false;
	}
	return $res;
}

function db_messagedata($id)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}
	$res = mysqli_query($con, "SELECT id, sender_id, receiver_id, description AS uzenet, sending_time AS ido, read_msg AS latta, CASE WHEN sender_id = '" . $_SESSION['user_id'] . "' THEN (SELECT user FROM user WHERE id = receiver_id) ELSE (SELECT user FROM user WHERE id = sender_id) END AS to_username FROM private_message WHERE ((receiver_id = '" . $_SESSION['user_id'] . "' AND sender_id = '" . $id . "') OR (receiver_id = '" . $id . "' AND sender_id = '" . $_SESSION['user_id'] . "')) ORDER BY sending_time DESC");
	mysqli_close($con);
    if(!$res)
    {
		return false;
	}
	return $res;
}

?>