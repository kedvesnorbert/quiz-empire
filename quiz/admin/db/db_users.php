<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function db_userlist($pge, $keresendoNev, $holKeres, $hogyRendez, $limit)
{
	if(!preg_match("/^[0-9]+$/", $pge) || !preg_match("/^[0-9]+$/", $limit))
    {
        return false;
    }
	$con = connect();
	if (!$con)
    {
        return false;
    }
	$q = "SELECT id, deleteduser, adminuser, points, quizplayed_total, warn, level, premium, registrtime, lastvisit, user FROM user WHERE "; 
	if($keresendoNev != "")
	{
		$keresendoNev = $keresendoNev . '%';
		$q .= "user LIKE '" . mysqli_real_escape_string($con, $keresendoNev) . "' AND ";
	}
		
	if($holKeres == 2)
    {
	    $q .= "deleteduser = 1 ";
    }
	elseif($holKeres == 3)
    {
        $q .= "warn != 0 ";
    }
	elseif($holKeres == 4)
    {
        $q .= "premium != 0 ";
    }
	elseif($holKeres == 5)
    {
        $q .= "adminuser != 0 ";
    }
	elseif($holKeres == 6)
    {
        $q .= "DATEDIFF(NOW(), lastvisit) < 31 ";
    }
	else
    {
        $q .= "id > 0 ";
    }

	if($hogyRendez == 1)
    {
        $q .= "ORDER BY user ";
    }	
	elseif($hogyRendez == 2)
    {
        $q .= "ORDER BY points DESC ";
    }
	elseif($hogyRendez == 3)
    {
        $q .= "ORDER BY registrtime ";
    }
	elseif($hogyRendez == 4)
    {
        $q .= "ORDER BY registrtime DESC ";
    }
    elseif($hogyRendez == 5)
    {
        $q .= "ORDER BY lastvisit DESC ";
    }
	$q .= "LIMIT $pge, $limit";
	$res = mysqli_query($con, $q);
	mysqli_close($con);
    if(!$res)
    {
        return false;
    }
	return $res;
}

function db_numrowsUsers($keresendoNev, $holKeres)
{
	$con = connect();
	if (!$con)
	{
		return false;
	}	
	$q = "SELECT id from user WHERE "; 
	if($keresendoNev != "")
	{
		$keresendoNev = $keresendoNev . '%';
		$q .= "user LIKE '" . mysqli_real_escape_string($con, $keresendoNev) . "' AND ";
	}
		
	if($holKeres == 2)
	{
		$q .= "deleteduser = 1 ";
	}
	elseif($holKeres == 3)
	{
		$q .= "warn != 0 ";
	}
	elseif($holKeres == 4)
	{
		$q .= "premium != 0 ";
	}
	elseif($holKeres == 5)
	{
		$q .= "adminuser != 0 ";
	}
	elseif($holKeres == 6)
	{
		$q .= "DATEDIFF(NOW(), lastvisit) < 31 ";
	}
	else
	{
		$q .= "id > 0 ";
	}
	$res=mysqli_query($con, $q);
	mysqli_close($con);
	if (!$res)
	{
		return false;
	}
	$rowcount=mysqli_num_rows($res);
	mysqli_free_result($res);
	return $rowcount;
}

?>