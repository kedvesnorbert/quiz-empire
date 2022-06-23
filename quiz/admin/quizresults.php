<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_quizresults.php");
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

function oldalszamok($number_of_pagesqr, $pagequiz, $quizcategory, $username_to_search, $scorecondition, $where_searchresult, $result_order, $result_dir)
{
	if($number_of_pagesqr < 2)
	{
		;
	}
	else
	{
		if($_GET['pagequiz'] > 10)
		{
			$link = '';
			$link .= '<a href="quizresults.php?pagequiz=' . "1" . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&scorecondition=' . $scorecondition . '&where_searchresult=' . $where_searchresult . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_result=MEHET">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
			echo "&nbsp; ... &nbsp; ";
		}
		else
		{
			$link = '';
			$link .= '<a href="quizresults.php?pagequiz=' . "1" . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&scorecondition=' . $scorecondition . '&where_searchresult=' . $where_searchresult . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_result=MEHET">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
		}
		
		
		for($pagequiz=$_GET['pagequiz']-3; $pagequiz < $_GET['pagequiz']+3 && $pagequiz <=$number_of_pagesqr-1; ++$pagequiz)
		{
			if($pagequiz > 1)
			{
				$link = '';
				$link .= '<a href="quizresults.php?pagequiz=' . $pagequiz . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&scorecondition=' . $scorecondition . '&where_searchresult=' . $where_searchresult . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_result=MEHET">' . $pagequiz . '</a> ';
				
				echo $link;
				echo '&nbsp; | &nbsp; ';
			}
			
		}
		if($pagequiz == $number_of_pagesqr)
		{
			$link = '';
			$link .= '<a href="quizresults.php?pagequiz=' . $pagequiz . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&scorecondition=' . $scorecondition . '&where_searchresult=' . $where_searchresult . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_result=MEHET">' . $pagequiz . '</a> '; echo $link;
		}
		else
		{
			echo "&nbsp; ... &nbsp;";
			$link = '';
			$link .= '<a href="quizresults.php?pagequiz=' . $number_of_pagesqr . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&scorecondition=' . $scorecondition . '&where_searchresult=' . $where_searchresult . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_result=MEHET">' . $number_of_pagesqr . '</a> '; echo $link;
		}
	}
}

function quizResultList($quizcategory, $username_to_search, $scorecondition, $where_searchresult, $result_order, $result_dir, $limit)
{
	if($where_searchresult == 4)
	{
		echo "<p id='title_searchquizresult'>Idei évi kvízek eredményei</p>";
	}
	elseif($where_searchresult == 3)
	{
		echo "<p id='title_searchquizresult'>Legelső alkalmak eredményei</p>";
	}
	elseif($where_searchresult == 2)
	{
		echo "<p id='title_searchquizresult'>A mai napi eredmények</p>";
	}
	elseif($where_searchresult == 1)
	{
		echo "<p id='title_searchquizresult'>Mindenkori kvízek eredményei</p>";
	}
	$all_newquiz = db_numrows_quizresultlist($quizcategory, $username_to_search, $scorecondition, $where_searchresult);
	if(!$all_newquiz)
	{
		$all_newquiz = 0;
	}
	$number_of_pagesqr = ceil($all_newquiz/$limit);
	if(!isset($_GET['pagequiz']))
	{
		$pagequiz = $_GET['pagequiz'] = 1;
	}
	else
	{
		if(preg_match("/^[0-9]+$/", $_GET['pagequiz']) && $_GET['pagequiz'] > 0 && $_GET['pagequiz'] <= $number_of_pagesqr)
		{
			$pagequiz = $_GET['pagequiz'];
		}	
		else
		{
			$pagequiz = $_GET['pagequiz'] = 1;
		}	
	}
	$this_page_first_result = ($pagequiz-1)*$limit;
	$res = db_getquizresults($this_page_first_result, $quizcategory, $username_to_search, $scorecondition, $where_searchresult, $result_order, $result_dir, $limit);
	if (!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res)< 1)
	{
		die("<p id='notfound_alert'>Nincs találat ebben a kategóriában!</p>");
	}
	?>
	<p id="current_page_num">Jelenlegi oldal: <?php if(isset($_GET['pagequiz'])) echo $_GET['pagequiz']; else echo 1; ?></p>
	<div id='div_pagination'>
		<?php
			oldalszamok($number_of_pagesqr, $pagequiz, $quizcategory, $username_to_search, $scorecondition, $where_searchresult, $result_order, $result_dir);
		?>
	</div>

	<table id="quizresultslist_table" border="1" align="center">
	<tr id="table_head">
		<th style='width:35%'>Kvíz neve
		<th style='width:13%'>Felhasználó
		<th style='width:10%'>Eredmény
		<th style='width:15%'>Időpont
		<th style='width:8%'>Megnézte
		<th style='width:10%'>Exportálás
		<th style='width:10%'>Műveletek
	<?php
	while ($row = mysqli_fetch_assoc($res))
	{
		if($row['is_verified'] == 1)
		{
			$row['is_verified'] = "Igen";
		}
		else
		{
			$row['is_verified'] = "Nem";
		}
		if($row['score']>=$row['sikeresseg'])
		{
			?><tr id="<?php echo "tr_testid" . $row['test_id']; ?>"><?php
		}
		else
		{
			?><tr id="<?php echo "tr_testid" . $row['test_id']; ?>" style='background-color:pink;'><?php
		}
		echo "<td align='center'>" . $row['temakor'] . "\n";
		echo "<td align='center'>" . $row['user'] . "\n";
		echo "<td align='center'><b>" . $row['score'] . "%</b><hr>" . $row['totalcorrect'] . " / " . $row['num_of_question'] . "\n";
		echo "<td align='center'>" . $row['idopont'] . "\n";
		echo "<td align='center'>" . $row['is_verified'] . "\n";
		echo "<td align='center'>";
		?><button id='pdf_button' onclick="window.open('../fpdf/topdf_admin.php?test_id=<?php echo $row['test_id']; ?>&test_name=<?php echo rawurlencode($row['temakor']); ?>', '_blank', 'toolbar=yes,scrollbars=yes,resizable=yes,top=500,left=500,width=screen.availWidth,height=screen.availHeight')"><img src="../documents/images/pdf.png" style="background-color:none;width:50%"></img></button><?php
		echo "<td align='center'>";
		?><button id='delete_played_quiz' onclick="delete_played_quiz('<?php echo $row['test_id'] ?>', '<?php echo $row['temakor'] ?>', '<?php echo $row['user'] ?>', '<?php echo $row['score'] ?>', '<?php echo $row['idopont'] ?>')">Törlés</button>
		<div id="dialogDeletePlayedQuiz" title="Kvíz eredményének törlése" style="display:none;"></div><?php
	}
	?>
	</table>
	<p id="current_page_num">Jelenlegi oldal: <?php if(isset($_GET['pagequiz'])) echo $_GET['pagequiz']; else echo 1; ?></p>
	<div id='div_pagination'>
		<?php
			oldalszamok($number_of_pagesqr, $pagequiz, $quizcategory, $username_to_search, $scorecondition, $where_searchresult, $result_order, $result_dir);
		?>
	</div>
	<?php
}

function result_search()
{
    ?><center>
	<div id="tablresults">
    <p id='p_description'>Részletes kereső</p>
    <table width="75%">
	<form action="quizresults.php" method="GET">
		<tr><td>(Kvíz kiválasztása)<td>(Felhasználónév megadása)<td>(Score megadása)<td>(Egyéb feltétel)	
		<tr>
			<td width="35%">	
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

			<td width="10%"><input type="text" id="scorecondition" class='search_class' name="scorecondition" placeholder="Enter score..." <?php if (isset($_GET["scorecondition"])) echo "value=\"" . $_GET["scorecondition"] . "\""; ?> maxlength='3'>

			<td width="13%">
			<select id="td_selectwhere" class='search_class' name="where_searchresult">
				<option value="1" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '1' ? ' selected="selected"' : ''; ?>>Mindenkori</option>
				<option value="2" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '2' ? ' selected="selected"' : ''; ?>>A mai nap</option>
				<option value="3" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '3' ? ' selected="selected"' : ''; ?>>Legelső alkalom</option>
				<option value="4" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '4' ? ' selected="selected"' : ''; ?>>Idei évi</option>
			</select>
			<tr><td><p id='sort_text'>Rendezési feltétel megadása</p> <td>
			<select id="td_selectorder" class='search_class' name="result_order">
				<option value="1" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '1' ? ' selected="selected"' : ''; ?>>Eredmény szerint</option>
				<option value="2" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '2' ? ' selected="selected"' : ''; ?>>Befejezési időpont szerint</option>
				<option value="3" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '3' ? ' selected="selected"' : ''; ?>>Kvíz neve szerint</option>
				<option value="4" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '4' ? ' selected="selected"' : ''; ?>>Felhasználó szerint</option>
			</select>

			<td>
			<select id="td_selectdirection" class='search_class' name="result_dir">
				<option value="1" <?php if(isset($_GET['result_dir'])) echo $_GET['result_dir'] == '1' ? ' selected="selected"' : ''; ?>>Növekvő</option>
				<option value="2" <?php if(isset($_GET['result_dir'])) echo $_GET['result_dir'] == '2' ? ' selected="selected"' : ''; ?>>Csökkenő</option>
			</select>
		
			<td><input type="submit" id="submitbtn_search" class="submit" name="search_for_result" value="MEHET">
    </form>
    </table>
	</div>
	</center>
    <?php
}

?>
<html>
<head>
	<title>Kvíz eredmények</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=../includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/quizresults.css" />
	<link rel="stylesheet" type="text/css" href="css/menu_admin.css" />
	<link rel="stylesheet" href="../includes/jQuery-ui.css">
	<script type = "text/javascript" src="../includes/jQuery.js"></script>
	<script type = "text/javascript" src="../includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/quizresults.js"></script>
</head>
<body>
<?php main_menu(); ?>
<p id="p_title">Kvízek eredményei</p>
<?php
result_search();
/**-------------------------- */
$limit = 30;
/**-------------------------- */

if(isset($_GET['search_for_result']))
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
	if(preg_match("/^[a-zA-Z0-9 ]*$/", $_GET['username_to_search']) && strlen($_GET['username_to_search'])<50)
	{
		$username_to_search = $_GET['username_to_search'];
	}
	else
	{
		$username_to_search = $_GET['username_to_search'] = "";
	}
	
	if(!isset($_GET['where_searchresult']))
	{
		$_GET['where_searchresult'] = 1;
	}
	$where_searchresult = 1;
	if(preg_match("/^[0-9]+$/", $_GET['where_searchresult']) && $_GET['where_searchresult'] > 0 && $_GET['where_searchresult'] <= 4)
	{
		$where_searchresult = $_GET['where_searchresult'];
	}
	else
	{
		$where_searchresult = $_GET['where_searchresult'] = 1;
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

	if(!isset($_GET['scorecondition']))
	{
		$_GET['scorecondition'] = 0;
	}
	$scorecondition = 0;
	if(preg_match("/^[0-9]+$/", $_GET['scorecondition']) && $_GET['scorecondition'] >= 0 && $_GET['scorecondition'] <= 100)
	{
		$scorecondition = $_GET['scorecondition'];
	}
	else
	{
		$scorecondition = $_GET['scorecondition'] = 0;
	}

	quizResultList($quizcategory, $username_to_search, $scorecondition, $where_searchresult, $result_order, $result_dir, $limit);
}
else
{
	quizResultList(0, "", 0, 1, 2, 2, $limit);
}

?>
</body>
</html>