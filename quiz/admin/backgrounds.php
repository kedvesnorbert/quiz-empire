<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_backgrounds.php");
require_once("../includes/ip_functions.php");
require_once("../includes/responses.php");
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

function oldalszamok($number_of_pagescom, $pagebg, $quizcategory, $username_to_search, $imagenametext, $where_searchresult, $result_order, $result_dir)
{
	if($number_of_pagescom < 2)
	{
		;
	}
	else
	{
		if($_GET['pagebg'] > 10)
		{
			$link = '';
			$link .= '<a href="backgrounds.php?pagebg=' . "1" . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&imagenametext=' . $imagenametext . '&where_searchresult=' . $where_searchresult . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_background=MEHET">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
			echo "&nbsp; ... &nbsp; ";
		}
		else
		{
			$link = '';
			$link .= '<a href="backgrounds.php?pagebg=' . "1" . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&imagenametext=' . $imagenametext . '&where_searchresult=' . $where_searchresult . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_background=MEHET">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
		}
		
		
		for($pagebg=$_GET['pagebg']-3; $pagebg < $_GET['pagebg']+3 && $pagebg <=$number_of_pagescom-1; ++$pagebg)
		{
			if($pagebg > 1)
			{
				$link = '';
				$link .= '<a href="backgrounds.php?pagebg=' . $pagebg . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&imagenametext=' . $imagenametext . '&where_searchresult=' . $where_searchresult . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_background=MEHET">' . $pagebg . '</a> ';
				
				echo $link;
				echo '&nbsp; | &nbsp; ';
			}
			
		}
		if($pagebg == $number_of_pagescom)
		{
			$link = '';
			$link .= '<a href="backgrounds.php?pagebg=' . $pagebg . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&imagenametext=' . $imagenametext . '&where_searchresult=' . $where_searchresult . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_background=MEHET">' . $pagebg . '</a> '; echo $link;
		}
		else
		{
			echo "&nbsp; ... &nbsp;";
			$link = '';
			$link .= '<a href="backgrounds.php?pagebg=' . $number_of_pagescom . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&imagenametext=' . $imagenametext . '&where_searchresult=' . $where_searchresult . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_background=MEHET">' . $number_of_pagescom . '</a> '; echo $link;
		}
	}
}

function backgroundResultList($quizcategory, $username_to_search, $imagenametext, $where_searchresult, $result_order, $result_dir, $limit)
{
	if($where_searchresult == 2)
	{
		echo "<p id='title_searchquizresult'>Minden háttérkép</p>";
	}
	elseif($where_searchresult == 1)
	{
		echo "<p id='title_searchquizresult'>Elfogadott háttérképek</p>";
	}
	elseif($where_searchresult == 0)
	{
		echo "<p id='title_searchquizresult'>Ellenőrizetlen háttérképek</p>";
	}
	$all_bgs = db_numrows_backgroundresultlist($quizcategory, $username_to_search, $imagenametext, $where_searchresult);
	if(!$all_bgs)
	{
		$all_bgs = 0;
	}
	$number_of_pagescom = ceil($all_bgs/$limit);
	if(!isset($_GET['pagebg']))
	{
		$pagebg = $_GET['pagebg'] = 1;
	}
	else
	{
		if(preg_match("/^[0-9]+$/", $_GET['pagebg']) && $_GET['pagebg'] > 0 && $_GET['pagebg'] <= $number_of_pagescom)
		{
			$pagebg = $_GET['pagebg'];
		}	
		else
		{
			$pagebg = $_GET['pagebg'] = 1;
		}	
	}
	$this_page_first_result = ($pagebg-1)*$limit;
	$res = db_getbackgroundresults($this_page_first_result, $quizcategory, $username_to_search, $imagenametext, $where_searchresult, $result_order, $result_dir, $limit);
	if (!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res)< 1)
	{
		die("<p id='notfound_alert'>Nincs találat ebben a kategóriában!</p>");
	}
	?>
	<p id="current_page_num">Jelenlegi oldal: <?php if(isset($_GET['pagebg'])) echo $_GET['pagebg']; else echo 1; ?></p>
	<div id='div_pagination'>
		<?php
			oldalszamok($number_of_pagescom, $pagebg, $quizcategory, $username_to_search, $imagenametext, $where_searchresult, $result_order, $result_dir);
		?>
	</div>

	<table id="backgroundslist_table" class='outlined' border="1" align="center">
	<tr id="table_head">
		<th>Kép / Info<th>Kép / Info
	<?php
	$counter = 1;
	
	while ($row = mysqli_fetch_assoc($res))
	{		
		$isactive = $row['active'];
		if($row['active'] == 1)
		{
			$row['active'] = "<span id='active_span'>Aktív</span>";
		}
		else
		{
			$row['active'] = "<span id='inactive_span'>Nincs ellenőrizve!</span>";
		}
		
		if($counter%2 != 0)
		{
			echo "<tr>";
		}
		$td_id = "td" . $row['id'];
		echo "<td id='" . $td_id . "' width='50%' height='100px'>" . "<img src=../" . $row['image_path'] . " width='100%'></img>";

		if($isactive == 0)
		{
			echo "<div id='imgbgdet'>" . $row['active'] . "<br><br><b>Kvíz:</b> " . $row['quiz_name'] . "<br><b>Feltöltve:</b> " . $row['user'] . " által, " . $row['posting_time'] . "-kor<br><b>Méret:</b> " . $row['image_size']*1024 . " KB, ." . $row['image_ext'] . " fájl" . "<br><br>" . "<button id='watch_in_big' class='bgimg_setbtn'><a href=../" . $row['image_path'] . " target='_BLANK' style='color:white;'>Megtekintés</a></button>" . "<button id='accept_bgimg' class='bgimg_setbtn' onclick='accept_bgimg(" . $row['id'] . ")'>Elfogadás</button>" . "<button id='delete_bgimg' class='bgimg_setbtn' onclick='delete_bgimg(" . $row['id'] . ")'>Törlés</button>\n" . "</div></td>";
		}
		else
		{
			echo "<div id='imgbgdet'>" . $row['active'] . "<br><br><b>Kvíz:</b> " . $row['quiz_name'] . "<br><b>Feltöltve:</b> " . $row['user'] . " által, " . $row['posting_time'] . "-kor<br><b>Méret:</b> " . $row['image_size']*1024 . " KB, ." . $row['image_ext'] . " fájl" . "<br><b>Ellenőrizve:</b> " . $row['adminusername'] . " által, " . $row['accept_time'] . "-kor<br><br><button id='watch_in_big' class='bgimg_setbtn'><a href=../" . $row['image_path'] . " target='_BLANK' style='color:white;'>Megtekintés</a></button>" . "<button id='delete_bgimg' class='bgimg_setbtn' onclick='delete_bgimg(" . $row['id'] . ")'>Törlés</button>\n" . "</div></td>";
		}
		
		++$counter;
	}
	?>
	</table>
	<p id="current_page_num">Jelenlegi oldal: <?php if(isset($_GET['pagebg'])) echo $_GET['pagebg']; else echo 1; ?></p>
	<div id='div_pagination'>
		<?php
			oldalszamok($number_of_pagescom, $pagebg, $quizcategory, $username_to_search, $imagenametext, $where_searchresult, $result_order, $result_dir);
		?>
	</div>
	<?php
}

function background_search()
{
    ?><center>
	<div id="tablbackgrounds">
    <p id='p_description'>Részletes kereső</p>
    <table width="75%">
	<form action="backgrounds.php" method="GET">
		<tr><td>(Kvíz kiválasztása)<td>(Felhasználónév megadása)<td>(Kép neve / kiterjesztése)<td>(Egyéb feltétel)
		<tr>
		<td width="30%">	
			<select id="quizcategory" class='search_class' name="quizcategory">
			<option value="0">Minden kvíz
			<?php
			$res = db_quizlist();
			if(!$res)
			{
				die(err_db());
			}
			while ($row = mysqli_fetch_assoc($res))
			{
				if (isset($_GET["quizcategory"]) && $row["id_number"] == $_GET["quizcategory"])
				{
					echo "<option value=\"" . $row["id_number"] . "\" selected>" . $row["quiz_name"] . "\n";
				}
				else
				{
					echo "<option value=\"" . $row["id_number"] . "\">" . $row["quiz_name"] . "\n";
				}
			}
			?>
			</select>

			<td width="20%"><input type="text" id="username_to_search" class='search_class' name="username_to_search" placeholder="Enter username..." <?php if (isset($_GET["username_to_search"])) echo "value=\"" . $_GET["username_to_search"] . "\""; ?> maxlength='50'>

			<td width="20%"><input type="text" id="imagenametext" class='search_class' name="imagenametext" placeholder="Enter imagename or extension..." <?php if (isset($_GET["imagenametext"])) echo "value=\"" . $_GET["imagenametext"] . "\""; ?> maxlength='30'>

			<td width="12%">
			<select id="td_selectwhere" class='search_class' name="where_searchresult">
				<option value="0" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '0' ? ' selected="selected"' : ''; ?>>Ellenőrizetlenek</option>
				<option value="1" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '1' ? ' selected="selected"' : ''; ?>>Ellenőrzöttek</option>
				<option value="2" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '2' ? ' selected="selected"' : ''; ?>>Mindenhol</option>
			</select>

			<tr><td><p id='sort_text'>Rendezési feltétel megadása</p> <td>
			<select id="td_selectorder" class='search_class' name="result_order">
				<option value="1" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '1' ? ' selected="selected"' : ''; ?>>Beküldés ideje szerint</option>
				<option value="2" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '2' ? ' selected="selected"' : ''; ?>>Kvíz neve szerint</option>
				<option value="3" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '3' ? ' selected="selected"' : ''; ?>>Felhasználó szerint</option>
				<option value="4" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '4' ? ' selected="selected"' : ''; ?>>Kép mérete szerint</option>
			</select>

			<td>
			<select id="td_selectdirection" class='search_class' name="result_dir">
				<option value="1" <?php if(isset($_GET['result_dir'])) echo $_GET['result_dir'] == '1' ? ' selected="selected"' : ''; ?>>Növekvő</option>
				<option value="2" <?php if(isset($_GET['result_dir'])) echo $_GET['result_dir'] == '2' ? ' selected="selected"' : ''; ?>>Csökkenő</option>
			</select>
		
			<td><input type="submit" id="submitbtn_search" class="submit" name="search_for_background" value="MEHET">
    </form>
    </table>
	</div>
	</center>
    <?php
}

?>
<html>
<head>
	<title>Háttérképek</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=../includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/backgrounds.css" />
	<link rel="stylesheet" type="text/css" href="css/menu_admin.css" />
	<script type = "text/javascript" src="../includes/jQuery.js"></script>
	<script type = "text/javascript" src="js/backgrounds.js"></script>
</head>
<body>
<?php main_menu(); ?>	
<p id="p_title">Háttérképek</p>
<?php
background_search();
/**-------------------------- */
$limit = 16;
/**-------------------------- */

if(isset($_GET['search_for_background']))
{
	if(!isset($_GET['quizcategory']))
	{
		$_GET['quizcategory'] = 0;
	}
	$quizcategory = 0;
	if(preg_match("/^[0-9]+$/", $_GET['quizcategory']) && $_GET['quizcategory'] >= 0 )
	{
		$quizcategory = $_GET['quizcategory'];
	}
	else
	{
		$quizcategory = $_GET['quizcategory'] = 0;
	}

	if(!isset($_GET['username_to_search']))
	{
		$_GET['username_to_search'] = "";
	}
	$username_to_search = 1;
	if(preg_match("/^[a-zA-Z0-9]*$/", $_GET['username_to_search']) && strlen($_GET['username_to_search'])<50)
	{
		$username_to_search = $_GET['username_to_search'];
	}
	else
	{
		$username_to_search = $_GET['username_to_search'] = "";
	}

	if(!isset($_GET['imagenametext']))
	{
		$_GET['imagenametext'] = '';
	}
	$imagenametext = '';
	if(preg_match("/^[a-zA-Z0-9 .\/]*$/", $_GET['imagenametext']) && strlen($_GET['imagenametext'])<=30)
	{
		$imagenametext = $_GET['imagenametext'];
	}
	else
	{
		$imagenametext = $_GET['imagenametext'] = "";
	}
	
	if(!isset($_GET['where_searchresult']))
	{
		$_GET['where_searchresult'] = 0;
	}
	$where_searchresult = 0;
	if(preg_match("/^[0-9]+$/", $_GET['where_searchresult']) && $_GET['where_searchresult'] >= 0 && $_GET['where_searchresult'] <= 2)
	{
		$where_searchresult = $_GET['where_searchresult'];
	}
	else
	{
		$where_searchresult = $_GET['where_searchresult'] = 0;
	}

	if(!isset($_GET['result_order']))
	{
		$_GET['result_order'] = 1;
	}
	$result_order = 1;
	if(preg_match("/^[0-9]+$/", $_GET['result_order']) && $_GET['result_order'] > 0 && $_GET['result_order'] <= 4)
	{
		$result_order = $_GET['result_order'];
	}
	else
	{
		$result_order = $_GET['result_order'] = 1;
	}

	if(!isset($_GET['result_dir']))
	{
		$_GET['result_dir'] = 1;
	}
	$result_dir = 1;
	if(preg_match("/^[0-9]+$/", $_GET['result_dir']) && $_GET['result_dir'] > 0 && $_GET['result_dir'] <= 2)
	{
		$result_dir = $_GET['result_dir'];
	}
	else
	{
		$result_dir = $_GET['result_dir'] = 1;
	}

	backgroundResultList($quizcategory, $username_to_search, $imagenametext, $where_searchresult, $result_order, $result_dir, $limit);
}
else
{
	backgroundResultList(0, "", "", 0, 1, 1, $limit);
}

?>
</body>
</html>