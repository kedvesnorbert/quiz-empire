<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_quizcomments.php");
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

function date_to_timestamp($date)
{
	$d = DateTime::createFromFormat('Y-m-d H:i:s', $date, new DateTimeZone('UTC'));

	if ($d === false)
	{
		die("Incorrect date string");
	}
	else
	{
		return $d->getTimestamp();
	}
}

function oldalszamok($number_of_pagescom, $pagecomment, $quizcategory, $username_to_search, $commenttext, $where_searchresult, $is_deletedcomment, $result_order, $result_dir)
{
	if($number_of_pagescom < 2)
	{
		;
	}
	else
	{
		if($_GET['pagecomment'] > 10)
		{
			$link = '';
			$link .= '<a href="quizcomments.php?pagecomment=' . "1" . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&commenttext=' . $commenttext . '&where_searchresult=' . $where_searchresult . '&is_deletedcomment=' . $is_deletedcomment . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_comment=MEHET">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
			echo "&nbsp; ... &nbsp; ";
		}
		else
		{
			$link = '';
			$link .= '<a href="quizcomments.php?pagecomment=' . "1" . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&commenttext=' . $commenttext . '&where_searchresult=' . $where_searchresult . '&is_deletedcomment=' . $is_deletedcomment . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_comment=MEHET">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
		}
		
		
		for($pagecomment=$_GET['pagecomment']-3; $pagecomment < $_GET['pagecomment']+3 && $pagecomment <=$number_of_pagescom-1; ++$pagecomment)
		{
			if($pagecomment > 1)
			{
				$link = '';
				$link .= '<a href="quizcomments.php?pagecomment=' . $pagecomment . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&commenttext=' . $commenttext . '&where_searchresult=' . $where_searchresult . '&is_deletedcomment=' . $is_deletedcomment . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_comment=MEHET">' . $pagecomment . '</a> ';
				
				echo $link;
				echo '&nbsp; | &nbsp; ';
			}
			
		}
		if($pagecomment == $number_of_pagescom)
		{
			$link = '';
			$link .= '<a href="quizcomments.php?pagecomment=' . $pagecomment . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&commenttext=' . $commenttext . '&where_searchresult=' . $where_searchresult . '&is_deletedcomment=' . $is_deletedcomment . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_comment=MEHET">' . $pagecomment . '</a> '; echo $link;
		}
		else
		{
			echo "&nbsp; ... &nbsp;";
			$link = '';
			$link .= '<a href="quizcomments.php?pagecomment=' . $number_of_pagescom . '&quizcategory=' . $quizcategory . '&username_to_search=' . $username_to_search . '&commenttext=' . $commenttext . '&where_searchresult=' . $where_searchresult . '&is_deletedcomment=' . $is_deletedcomment . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_comment=MEHET">' . $number_of_pagescom . '</a> '; echo $link;
		}
	}
}

function commentResultList($quizcategory, $username_to_search, $commenttext, $where_searchresult, $is_deletedcomment, $result_order, $result_dir, $limit)
{
	if($where_searchresult == 3)
	{
		echo "<p id='title_searchquizresult'>Összes hozzászólás</p>";
	}
	elseif($where_searchresult == 2)
	{
		echo "<p id='title_searchquizresult'>Cenzúrázott hozzászólások</p>";
	}
	elseif($where_searchresult == 1)
	{
		echo "<p id='title_searchquizresult'>Ellenőrzött hozzászólások</p>";
	}
	elseif($where_searchresult == 0)
	{
		echo "<p id='title_searchquizresult'>Ellenőrizetlen hozzászólások</p>";
	}
	$all_comments = db_numrows_quizresultlist($quizcategory, $username_to_search, $commenttext, $where_searchresult, $is_deletedcomment);
	if(!$all_comments)
	{
		$all_comments = 0;
	}
	$number_of_pagescom = ceil($all_comments/$limit);
	if(!isset($_GET['pagecomment']))
	{
		$pagecomment = $_GET['pagecomment'] = 1;
	}
	else
	{
		if(preg_match("/^[0-9]+$/", $_GET['pagecomment']) && $_GET['pagecomment'] > 0 && $_GET['pagecomment'] <= $number_of_pagescom)
		{
			$pagecomment = $_GET['pagecomment'];
		}	
		else
		{
			$pagecomment = $_GET['pagecomment'] = 1;
		}	
	}
	$this_page_first_result = ($pagecomment-1)*$limit;
	$res = db_getcommentresults($this_page_first_result, $quizcategory, $username_to_search, $commenttext, $where_searchresult, $is_deletedcomment, $result_order, $result_dir, $limit);
	if (!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res)< 1)
	{
		die("<p id='notfound_alert'>Nincs találat ebben a kategóriában!</p>");
	}
	?>
	<p id="current_page_num">Jelenlegi oldal: <?php if(isset($_GET['pagecomment'])) echo $_GET['pagecomment']; else echo 1; ?></p>
	<div id='div_pagination'>
		<?php
			oldalszamok($number_of_pagescom, $pagecomment, $quizcategory, $username_to_search, $commenttext, $where_searchresult, $is_deletedcomment, $result_order, $result_dir);
		?>
	</div>

	<table id="quizcommentslist_table" border="1" align="center" style='border-spacing:0px 25px;'>
	<tr id="table_head">
		<th style='width:75%'>Hozzászólás
		<th style='width:10%'>Ellenőrzött
		<th style='width:10%'>Műveletek
	<?php
	while ($row = mysqli_fetch_assoc($res))
	{
		$tstamp = "id" . date_to_timestamp($row['comment_date']) . $row['user'];
		if($row['is_verified'] == 2)
		{
			$isverified = "Cenzúrázott";
		}
		elseif($row['is_verified'] == 1)
		{
			$isverified = "Ellenőrzött";
		}
		else
		{
			$isverified = "Nincs ellenőrizve";
		}

		if($row['is_deleted'] == 1)
		{
			$isdeleted = "Törölt";
		}
		else
		{
			$isdeleted = "Aktív";
		}

		if(strlen($row['verification_time'])< 1)
		{
			$row['verification_time'] = "2000-01-01 00:00:00";
		}

		if($row['is_verified'] == 0 || $row['is_verified'] == 1)
		{
			echo "<tr id='" . $tstamp . "'>";
		}
		else
		{
			?><tr id='"<?php echo $tstamp; ?>"' style='background-color:pink;'><?php
		}

		$comment_text1 = nl2br(htmlentities($row['comment_text']));
		$comment_text = str_replace("!!!censored!!!", "<img id='censoreimg' src='../documents/images/censored.gif'></img>", $comment_text1);
		if($row['is_verified'] == 2)
		{
			$moderation = "<p id='comment_modsection'>" . nl2br(htmlentities($row['moderation'])) . ", " . $row['verification_time'] . " időpontban." . "</p>";
		}
		else
		{
			$moderation = "";
		}

		echo "<td align='left' style='height:150px;'><table id='nexted_table'><tr style='height:50px;'><td>" . "<p id='comment_title'><b>Írta: </b><u><i>" . $row['user'] . "</i></u> -- <b>Kvíz: </b><u><i>" . $row['quiz_name'] . "</i></u> -- Időpont: <u><i> " . $row['comment_date'] . "</i></u> -- " . $isdeleted . "</p>" . "<tr><td style='height:100px;'><p id='comment_textsection'>" . $comment_text . "</p>" . $moderation . "</table>\n";
		echo "<td align='center'>" . $isverified . "\n";
		echo "<td align='center'>";
		if(($row['is_verified'] == 0 || ($row['is_verified'] == 1 && strtotime($row['last_modified']) > strtotime($row['verification_time']))) && $row['is_deleted'] == 0)
		{
			?><button id='accept_comment' onclick="accept_comment('<?php echo $row['id_number'] ?>', '<?php echo $row['id'] ?>', '<?php echo $row['comment_date'] ?>', '<?php echo $tstamp ?>')">Elfogadás</button>

			<button id='censore_comment' onclick="censore_comment('<?php echo $row['quiz_name'] ?>', '<?php echo $row['id_number'] ?>', '<?php echo $row['user'] ?>', '<?php echo $row['id'] ?>', '<?php echo $row['comment_date'] ?>', '<?php echo urlencode($row['comment_text']) ?>', '<?php echo $tstamp ?>')">Cenzúrázás</button>
			<div id="dialogCensoreComment" title="Hozzászólás cenzúrázása" style="display:none;"></div><?php
		}
		elseif($row['is_verified'] == 1)
		{
			echo "Elfogadva!";
		}
		elseif($row['is_verified'] == 2)
		{
			echo "Cenzúrázva!";
		}
		else
		{
			echo "No action";
		}
	}
	?>
	</table>
	<p id="current_page_num">Jelenlegi oldal: <?php if(isset($_GET['pagecomment'])) echo $_GET['pagecomment']; else echo 1; ?></p>
	<div id='div_pagination'>
		<?php
			oldalszamok($number_of_pagescom, $pagecomment, $quizcategory, $username_to_search, $commenttext, $where_searchresult, $is_deletedcomment, $result_order, $result_dir);
		?>
	</div>
	<?php
}

function comment_search()
{
    ?><center>
	<div id="tablcomments">
    <p id='p_description'>Részletes kereső</p>
    <table width="75%">
	<form action="quizcomments.php" method="GET">
		<tr><td>(Keresendő szöveg)<td>(Kvíz kiválasztása)<td>(Felhasználónév megadása)<td>(Egyéb feltétel)<td>(Egyéb feltétel)	
		<tr>
		<td width="25%"><input type="text" id="commenttext" class='search_class' name="commenttext" placeholder="Enter text to search..." <?php if (isset($_GET["commenttext"])) echo "value=\"" . $_GET["commenttext"] . "\""; ?> maxlength='30'>	
		
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

			<td width="13%">
			<select id="td_selectwhere" class='search_class' name="where_searchresult">
				<option value="3" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '3' ? ' selected="selected"' : ''; ?>>Mindenhol</option>
				<option value="1" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '1' ? ' selected="selected"' : ''; ?>>Csak ellenőrzöttek </option>
				<option value="0" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '0' ? ' selected="selected"' : ''; ?>>Csak ellenőrizetlenek</option>
				<option value="2" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '2' ? ' selected="selected"' : ''; ?>>Csak cenzúrázottak</option>
			</select>

			<td width="13%">
			<select id="td_selectdel" class='search_class' name="is_deletedcomment">
				<option value="0" <?php if(isset($_GET['is_deletedcomment'])) echo $_GET['is_deletedcomment'] == '3' ? ' selected="selected"' : ''; ?>>Aktív hozzászólások közt</option>
				<option value="1" <?php if(isset($_GET['is_deletedcomment'])) echo $_GET['is_deletedcomment'] == '1' ? ' selected="selected"' : ''; ?>>Törölt hozzászólások közt </option>
				<option value="2" <?php if(isset($_GET['is_deletedcomment'])) echo $_GET['is_deletedcomment'] == '2' ? ' selected="selected"' : ''; ?>>Mindenhol </option>
			</select>

			<tr><td colspan='2'><p id='sort_text'>Rendezési feltétel megadása</p> <td>
			<select id="td_selectorder" class='search_class' name="result_order">
				<option value="1" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '1' ? ' selected="selected"' : ''; ?>>Hozzászólás időpontja szerint</option>
				<option value="2" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '2' ? ' selected="selected"' : ''; ?>>Kvíz neve szerint</option>
				<option value="3" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '3' ? ' selected="selected"' : ''; ?>>Felhasználó szerint</option>
			</select>

			<td>
			<select id="td_selectdirection" class='search_class' name="result_dir">
				<option value="1" <?php if(isset($_GET['result_dir'])) echo $_GET['result_dir'] == '1' ? ' selected="selected"' : ''; ?>>Növekvő</option>
				<option value="2" <?php if(isset($_GET['result_dir'])) echo $_GET['result_dir'] == '2' ? ' selected="selected"' : ''; ?>>Csökkenő</option>
			</select>
		
			<td><input type="submit" id="submitbtn_search" class="submit" name="search_for_comment" value="MEHET">
    </form>
    </table>
	</div>
	</center>
    <?php
}

?>
<html>
<head>
	<title>Kvíz hozzászólások</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=../includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/quizcomments.css" />
	<link rel="stylesheet" type="text/css" href="css/menu_admin.css" />
	<link rel="stylesheet" href="../includes/jQuery-ui.css">
	<script type = "text/javascript" src="../includes/jQuery.js"></script>
	<script type = "text/javascript" src="../includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/quizcomments.js"></script>
</head>
<body>
<?php main_menu(); ?>
<p id="p_title">Kvízek hozzászólásai</p>
<?php
comment_search();
/**-------------------------- */
$limit = 15;
/**-------------------------- */

if(isset($_GET['search_for_comment']))
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
	if(preg_match("/^[0-9]+$/", $_GET['where_searchresult']) && $_GET['where_searchresult'] >= 0 && $_GET['where_searchresult'] <= 3)
	{
		$where_searchresult = $_GET['where_searchresult'];
	}
	else
	{
		$where_searchresult = $_GET['where_searchresult'] = 1;
	}

	if(!isset($_GET['is_deletedcomment']))
	{
		$_GET['is_deletedcomment'] = 0;
	}
	$is_deletedcomment = 1;
	if(preg_match("/^[0-9]+$/", $_GET['is_deletedcomment']) && $_GET['is_deletedcomment'] >= 0 && $_GET['is_deletedcomment'] <= 2)
	{
		$is_deletedcomment = $_GET['is_deletedcomment'];
	}
	else
	{
		$is_deletedcomment = $_GET['is_deletedcomment'] = 0;
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

	if(!isset($_GET['commenttext']))
	{
		$_GET['commenttext'] = '';
	}
	$commenttext = '';
	if(preg_match("/^[a-zA-Z0-9 ]*$/", $_GET['commenttext']) && strlen($_GET['commenttext'])<=30)
	{
		$commenttext = $_GET['commenttext'];
	}
	else
	{
		$commenttext = $_GET['commenttext'] = "";
	}

	commentResultList($quizcategory, $username_to_search, $commenttext, $where_searchresult, $is_deletedcomment, $result_order, $result_dir, $limit);
}
else
{
	commentResultList(0, "", "", 0, 0, 1, 1, $limit);
}

?>
</body>
</html>