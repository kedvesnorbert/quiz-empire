<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_users.php");
require_once("../includes/ip_functions.php");
require_once("includes/session_timeout.php");
require_once("menu_admin.php");

if(!isset($_SESSION['adminuser']) || !isset($_SESSION['is_admin']) || !isset($_SESSION['user_id']))
{
    $fromurladmin = urlencode($_SERVER["REQUEST_URI"]);
	setcookie("fromwhereadmin", $fromurladmin);
	$_SESSION = array();
	session_destroy();
	header("location: adminlogin.php");
}

function oldalszamok($number_of_pages, $pageD, $search_username, $where_search, $search_orderby)
{
	if($number_of_pages < 2)
	{
		;
	}
	else
	{
		if($_GET['pageD'] > 10)
		{
			$link = '';
			$link .= '<a href="users.php?pageD=' . "1" . '&search_username=' . $search_username . '&where_search=' . $where_search . '&search_orderby=' . $search_orderby . '&search_for_username=KERES">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
			echo "&nbsp; ... &nbsp; ";
		}
		else
		{
			$link = '';
			$link .= '<a href="users.php?pageD=' . "1" . '&search_username=' . $search_username . '&where_search=' . $where_search . '&search_orderby=' . $search_orderby . '&search_for_username=KERES">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
		}
		
		
		for($pageD=$_GET['pageD']-3; $pageD < $_GET['pageD']+3 && $pageD <=$number_of_pages-1; ++$pageD)
		{
			if($pageD > 1)
			{
				$link = '';
				$link .= '<a href="users.php?pageD=' . $pageD . '&search_username=' . $search_username . '&where_search=' . $where_search . '&search_orderby=' . $search_orderby . '&search_for_username=KERES">' . $pageD . '</a> ';
				
				echo $link;
				echo '&nbsp; | &nbsp; ';
			}
			
		}
		if($pageD == $number_of_pages)
		{
			$link = '';
			$link .= '<a href="users.php?pageD=' . $pageD . '&search_username=' . $search_username . '&where_search=' . $where_search . '&search_orderby=' . $search_orderby . '&search_for_username=KERES">' . $pageD . '</a> '; echo $link;
		}
		else
		{
			echo "&nbsp; ... &nbsp;";
			$link = '';
			$link .= '<a href="users.php?pageD=' . $number_of_pages . '&search_username=' . $search_username . '&where_search=' . $where_search . '&search_orderby=' . $search_orderby . '&search_for_username=KERES">' . $number_of_pages . '</a> '; echo $link;
		}
	}
}

function kisKeresoMenu()
{
    ?><center>
	<div id="tablusers">
    <p id='p_description'>Részletes kereső</p>
    <table>
	<form action="users.php" method="GET">
		<tr>
			<td><input type="text" id="td_input" class='search_class' name="search_username" placeholder="Enter username..." <?php if (isset($_GET["search_username"])) echo "value=\"" . $_GET["search_username"] . "\""; ?> autofocus>
		
		<td>
			<select id="td_selectwhere" name="where_search">
				<option value="1" <?php if(isset($_GET['where_search'])) echo $_GET['where_search'] == '1' ? ' selected="selected"' : ''; ?>>Mindenhol</option>
				<option value="2" <?php if(isset($_GET['where_search'])) echo $_GET['where_search'] == '2' ? ' selected="selected"' : ''; ?>>Töröltek között</option>
				<option value="3" <?php if(isset($_GET['where_search'])) echo $_GET['where_search'] == '3' ? ' selected="selected"' : ''; ?>>WARN alattiak között</option>
				<option value="4" <?php if(isset($_GET['where_search'])) echo $_GET['where_search'] == '4' ? ' selected="selected"' : ''; ?>>Prémium alattiak között</option>
				<option value="5" <?php if(isset($_GET['where_search'])) echo $_GET['where_search'] == '5' ? ' selected="selected"' : ''; ?>>Adminok között</option>
				<option value="6" <?php if(isset($_GET['where_search'])) echo $_GET['where_search'] == '6' ? ' selected="selected"' : ''; ?>>1 hónapja az oldalon jártak között</option>
			</select>
			<select id="td_selectorder" name="search_orderby">
				<option value="1" <?php if(isset($_GET['search_orderby'])) echo $_GET['search_orderby'] == '1' ? ' selected="selected"' : ''; ?>>Ábéce szerint</option>
				<option value="2" <?php if(isset($_GET['search_orderby'])) echo $_GET['search_orderby'] == '2' ? ' selected="selected"' : ''; ?>>Pontszám szerint csökkenő</option>
				<option value="3" <?php if(isset($_GET['search_orderby'])) echo $_GET['search_orderby'] == '3' ? ' selected="selected"' : ''; ?>>Legrégebb regisztrált</option>
				<option value="4" <?php if(isset($_GET['search_orderby'])) echo $_GET['search_orderby'] == '4' ? ' selected="selected"' : ''; ?>>Regisztrálás szerint csökkenő</option>
				<option value="5" <?php if(isset($_GET['search_orderby'])) echo $_GET['search_orderby'] == '5' ? ' selected="selected"' : ''; ?>>Legutóbb jelenlét ideje</option>
			</select>
		
			<td><input id="submitbtn_search" type="submit" class="submit" name="search_for_username" value="KERESÉS">
    </form>
    </table>
	</div>
	</center>
    <?php
}

function userList($search_username, $where_search, $search_orderby, $limit)
{	
	$all_users = db_numrowsUsers($search_username, $where_search);
	if(!$all_users)
	{
		$all_users = 0;
	}
	$number_of_pages = ceil($all_users/$limit);
	if(!isset($_GET['pageD']))
	{
		$pageD = $_GET['pageD'] = 1;
	}
	else
	{
		if(preg_match("/^[0-9]+$/", $_GET['pageD']) && $_GET['pageD'] > 0 && $_GET['pageD'] <= $number_of_pages)
		{
			$pageD = $_GET['pageD'];
		}	
		else
		{
			$pageD = $_GET['pageD'] = 1;
		}	
	}
	$this_page_first_result = ($pageD-1)*$limit;
	
	$res = db_userlist($this_page_first_result, $search_username, $where_search, $search_orderby, $limit);
	if (!$res)
	{
		die(err_db());
	}
	?>
	<p id="current_page_num">Jelenlegi oldal: <?php if(isset($_GET['pageD'])) echo $_GET['pageD']; else echo 1; ?></p>
	<div id='div_pagination'>
		<?php
			oldalszamok($number_of_pages, $pageD, $search_username, $where_search, $search_orderby);
		?>
		
	</div>
	
	<table id="userlist_table" border="1" align="center">
	<tr id="table_head">
		<th style='width:5%'>ID
		<th style='width:15%'>Felhasználónév
		<th style='width:7%'>Pontok
		<th style='width:10%'>Részvétel kvízeken 
		<th style='width:7%'>Szint
		<th style='width:7%'>Prémium
		<th >Regisztrálás ideje
		<th >Utoljára itt volt
		<th style='width:7%'>Részletek
	<?php
	if(mysqli_num_rows($res)==0)
	{
		echo "<tr id='notfound_row'><td colspan='9'>" . "Nincs találat!\n";
	}
	else
	{
		while ($row = mysqli_fetch_assoc($res))
		{
			$username = $row['user'];
			if($row['premium'] == 1)
			{
				$row['premium'] = "Van";
			}
			else
			{
				$row['premium'] = "Nincs";
			}
			if($row['deleteduser'] == 1)
			{
				echo "<tr id='rows_table' style='background-color:#F08080;'>\n";
			}
			elseif($row['warn'] != 0)
			{
				echo "<tr id='rows_table' style='background-color:pink;'>\n";
				$username = "&#10071;" . " " . $row['user'];
			}
			elseif($row['adminuser'] == 1)
			{
				echo "<tr id='rows_table' style='background-color:#00BFFF;'>\n";
			}
			else
			{
				echo "<tr id='rows_table'>\n";
			}
			
			echo "<td align='center'>" . $row['id'] . "\n";
			echo "<td align='center'>" . $username . "\n";
			echo "<td align='center'>" . $row['points'] . "\n";
			echo "<td align='center'>" . $row['quizplayed_total'] . "\n";
			echo "<td align='center'>" . $row['level'] . "\n";
			echo "<td align='center'>" . $row['premium'] . "\n";
			echo "<td align='center'>" . $row['registrtime'] . "\n";
			echo "<td align='center'>" . $row['lastvisit'] . "\n";
			?><td><input type="button" id="goToUserPage" onclick="window.location.href='userdetails.php?profil_id=<?php echo $row['id'] ?>'" value="RÉSZLETEK"><?php
		}
	}
	?>
	</table>

	<p id="current_page_num">Jelenlegi oldal: <?php if(isset($_GET['pageD'])) echo $_GET['pageD']; else echo 1; ?></p>
	<div id='div_pagination'>
		<?php
			oldalszamok($number_of_pages, $pageD, $search_username, $where_search, $search_orderby);
		?>
	</div><?php
}

?>
<html>
<head>
	<title>Felhasználók</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=../includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/users.css" />
	<link rel="stylesheet" type="text/css" href="css/menu_admin.css" />
</head>

<body>
<?php main_menu(); ?>
<p id="p_title">Felhasználók</p>
<?php
kisKeresoMenu();
/**-------------------------- */
$limit = 15;
/**-------------------------- */

if(isset($_GET['search_for_username']))
{
	
	if(!isset($_GET['search_username']))
	{
		$_GET['search_username'] = "";
	}
	$keresendoNev = 1;
	if(preg_match("/^[a-zA-Z0-9]*$/", $_GET['search_username']) && strlen($_GET['search_username'])<25)
	{
		$keresendoNev = $_GET['search_username'];
	}
	else
	{
		$keresendoNev = $_GET['search_username'] = "";
	}
	
	if(!isset($_GET['where_search']))
	{
		$_GET['where_search'] = 1;
	}
	$holKeres = 1;
	if(preg_match("/^[0-9]+$/", $_GET['where_search']) && $_GET['where_search'] > 0 && $_GET['where_search'] <= 6)
	{
		$holKeres = $_GET['where_search'];
	}
	else
	{
		$holKeres = $_GET['where_search'] = 1;
	}

	if(!isset($_GET['search_orderby']))
	{
		$_GET['search_orderby'] = 1;
	}
	$hogyRendez = 1;
	if(preg_match("/^[0-9]+$/", $_GET['search_orderby']) && $_GET['search_orderby'] > 0 && $_GET['search_orderby'] <= 5)
	{
		$hogyRendez = $_GET['search_orderby'];
	}
	else
	{
		$hogyRendez = $_GET['search_orderby'] = 1;
	}

	userList($keresendoNev, $holKeres, $hogyRendez, $limit);
}
else
{
	userList("", 1, 1, $limit);
}

?>
</body>
</html>