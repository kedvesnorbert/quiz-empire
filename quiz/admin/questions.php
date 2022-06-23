<?php
session_start();

require_once("db/db_connect.php");
require_once("db/db_questions.php");
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

function oldalszamok($number_of_pages, $pageQr, $quizcategory, $questiontext, $where_searchresult, $search_in, $q_diff, $q_activity, $result_order, $result_dir)
{
	if($number_of_pages < 2)
	{
		;
	}
	else
	{
		if($_GET['pageQr'] > 10)
		{
			$link = '';
			$link .= '<a href="questions.php?pageQr=' . "1" . '&quizcategory=' . $quizcategory . '&questiontext=' . $questiontext . '&search_in=' . $search_in . '&where_searchresult=' . $where_searchresult . '&q_diff=' . $q_diff . '&q_activity=' . $q_activity . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_question=MEHET">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
			echo "&nbsp; ... &nbsp; ";
		}
		else
		{
			$link = '';
			$link .= '<a href="questions.php?pageQr=' . "1" . '&quizcategory=' . $quizcategory . '&questiontext=' . $questiontext . '&search_in=' . $search_in . '&where_searchresult=' . $where_searchresult . '&q_diff=' . $q_diff . '&q_activity=' . $q_activity . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_question=MEHET">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
		}
		
		
		for($pageQr=$_GET['pageQr']-3; $pageQr < $_GET['pageQr']+3 && $pageQr <=$number_of_pages-1; ++$pageQr)
		{
			if($pageQr > 1)
			{
				$link = '';
				$link .= '<a href="questions.php?pageQr=' . $pageQr . '&quizcategory=' . $quizcategory . '&questiontext=' . $questiontext . '&search_in=' . $search_in . '&where_searchresult=' . $where_searchresult . '&q_diff=' . $q_diff . '&q_activity=' . $q_activity . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_question=MEHET">' . $pageQr . '</a> ';
				
				echo $link;
				echo '&nbsp; | &nbsp; ';
			}
			
		}
		if($pageQr == $number_of_pages)
		{
			$link = '';
			$link .= '<a href="questions.php?pageQr=' . $pageQr . '&quizcategory=' . $quizcategory . '&questiontext=' . $questiontext . '&search_in=' . $search_in . '&where_searchresult=' . $where_searchresult . '&q_diff=' . $q_diff . '&q_activity=' . $q_activity . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_question=MEHET">' . $pageQr . '</a> '; echo $link;
		}
		else
		{
			echo "&nbsp; ... &nbsp;";
			$link = '';
			$link .= '<a href="questions.php?pageQr=' . $number_of_pages . '&quizcategory=' . $quizcategory . '&questiontext=' . $questiontext . '&search_in=' . $search_in . '&where_searchresult=' . $where_searchresult . '&q_diff=' . $q_diff . '&q_activity=' . $q_activity . '&result_order=' . $result_order . '&result_dir=' . $result_dir . '&search_for_question=MEHET">' . $number_of_pages . '</a> '; echo $link;
		}
	}
}

function question_list($quizcategory, $questiontext, $where_searchresult, $search_in, $q_diff, $q_activity, $result_order, $result_dir, $limit)
{	
	$all_question = db_questionlist_numrows($quizcategory, $questiontext, $where_searchresult, $search_in, $q_diff, $q_activity);
	$number_of_pages = ceil($all_question/$limit);
	if(!isset($_GET['pageQr']))
	{
		$pageQr = $_GET['pageQr'] = 1;
	}
	else
	{
		if(preg_match("/^[0-9]+$/", $_GET['pageQr']) && $_GET['pageQr'] > 0 && $_GET['pageQr'] <= $number_of_pages)
		{
			$pageQr = $_GET['pageQr'];
		}	
		else
		{
			$pageQr = $_GET['pageQr'] = 1;
		}	
	}
	$this_page_first_result = ($pageQr-1)*$limit;
	
	$res = db_questionlist($this_page_first_result, $quizcategory, $questiontext, $where_searchresult, $search_in, $q_diff, $q_activity, $result_order, $result_dir, $limit);
	if (!$res)
	{
		echo "<center><br><b><font face='verdana' color='black' style='font-size:20px'>Nincs találat!</b></font></center>";
		die(err_db());
	}
	if(mysqli_num_rows($res)< 1)
	{
		die("<p id='notfound_alert'>Nincs találat ebben a kategóriában!</p>");
	}
	if($all_question > 0)
	{
		echo "<center><br><b><font face='verdana' color='red' style='font-size:20px'>Találatok száma: " . $all_question . "</font></b></center>";
	}
	?>

	<p id="current_page_num">Jelenlegi oldal: <?php if(isset($_GET['pageQr'])) echo $_GET['pageQr']; else echo 1; ?></p>
	<div id='div_pagination'>
		<?php
			oldalszamok($number_of_pages, $pageQr, $quizcategory, $questiontext, $where_searchresult, $search_in, $q_diff, $q_activity, $result_order, $result_dir);
		?>
	</div>

	<table id="tabl_questions" border="1" align="center">
	<tr id="table_head">
		<th style='width:6%'>Azon.
		<th style='width:13%'>Témakör
		<th style='width:25%'>Kérdés
		<th style='width:20%'>Helyes válasz
		<th style='width:10%;'>Beküldő
		<th style='width:12%'>Beküldés ideje
		<th style='width:7%'>Státusz
	<?php
	while ($row = mysqli_fetch_assoc($res))
	{
		$is_verified = $row['is_verified'];
		$difficulty = $row['difficulty'];
		$is_active = $row['is_active'];
		$language = $row['language'];
		if($row['is_verified'] == 0 || strlen($row['is_verified']) < 1)
		{
			$row['is_verified'] = "Nincs még ellenőrizve";
		}
		elseif($row['is_verified'] == 1)
		{
			$row['is_verified'] = "Ellenőrzött";
		}
		elseif($row['is_verified'] == 2)
		{
			$row['is_verified'] = "Javítás alatt";
		}
		elseif($row['is_verified'] == 3)
		{
			$row['is_verified'] = "Törölt";
		}
		if($row['difficulty'] == 2)
		{
			$row['difficulty'] = "Nehéz";
			echo "<tr style='height:80px;font-weight:bold;' class='mainrowQuestion" . $row['id'] . "'>\n";
		}
		else
		{
			$row['difficulty'] = "Könnyű";
			echo "<tr style='height:80px;' class='mainrowQuestion" . $row['id'] . "'>\n";
		}
		if($row['is_active'] == 1)
		{
			$row['is_active'] = "Aktív";
		}
		else
		{
			$row['is_active'] = "Inaktív";
		}
		if($row['language'] == 1)
		{
			$row['language'] = "Magyar";
		}
		else
		{
			$row['language'] = "Angol";
		}
		
		echo "<td style='text-align:center;'>" ?><a href="" class="toggler_question" data-prod="<?php echo $row['id']; ?>"> <?php echo $row['id']; ?></a><?php echo "\n";
		echo "<td style='text-align:center;'>" . $row['quiz_name'];
		echo "<td>" . htmlentities($row['question']);
		echo "<td>" . htmlentities($row['ans1']);
		echo "<td style='text-align:center;'>" . $row['username'];
		echo "<td style='text-align:center;'>" . $row['sending_time'];
		echo "<td style='text-align:center;'>" . $row['is_verified'];
		?>

		<tr id='rows_table' class="<?php echo "detailsQuestion" . $row['id']; ?>" style="display:none;">
			<td colspan='8' class='toggle_td_class'>
				<div id='details_q_tr'>
					<br><span class='info_title_span'>Információ:</span>
					<button class="questiondatashow" id="<?php echo "questiondata" . $row['id']; ?>" onclick='show_questiondata("<?php echo $row["id"] ?>", "<?php echo $row["quiz_name"] ?>", "<?php echo $row["username"] ?>", "<?php echo $row["sending_time"] ?>", "<?php echo urlencode($row["question"]) ?>", "<?php echo urlencode($row["ans1"]) ?>", "<?php echo urlencode($row["ans2"]) ?>", "<?php echo urlencode($row["ans3"]) ?>", "<?php echo urlencode($row["ans4"]) ?>", "<?php echo $row["difficulty"] ?>", "<?php echo $row["is_active"] ?>", "<?php echo $row["is_verified"] ?>", "<?php echo $row["verification_time"] ?>", "<?php echo $row["popularity"] ?>")'>Kérdés adatlapja</button>
					<div id="dialogQuestionData" class="<?php echo "dialogQuestionData" . $row['id']; ?>" title="Kérdés adatlapja" style="display:none;"></div>

					<button class="questiondatashow" id="<?php echo "questioncomments" . $row['id']; ?>" onclick='show_questioncomments("<?php echo $row["id"] ?>")'>Kérdés megjegyzései</button>
					<div id="dialogQuestionComments" class="<?php echo "dialogQuestionComments" . $row['id']; ?>" title="Kérdés megjegyzései" style="display:none;"></div>

					<button class="questiondatashow" id="<?php echo "similarquestions" . $row['id']; ?>" onclick='show_similarquestions("<?php echo $language ?>", "<?php echo urlencode($row["question"]) ?>", "<?php echo urlencode($row["ans1"]) ?>", "<?php echo $row["id"] ?>")'>Hasonló kérdések</button>
					<div id="dialogSimilarQuestions" class="<?php echo "dialogSimilarQuestions" . $row['id']; ?>" title="Hasonló kérdések" style="display:none;"></div>
					
					<?php

					if($is_verified == 0 || strlen($is_verified)< 1)
					{
						?>
						<br><br><span class='info_title_span'>Műveletek:</span>
						<button class="acceptQuestion" id="<?php echo "acceptQuestion" . $row['id']; ?>" onclick='accept_question("<?php echo $row["id"] ?>")'>ELFOGADÁS</button>
						<div id="dialogAcceptQuestion" class="<?php echo "dialogAcceptQuestion" . $row['id']; ?>" title="Kérdés elfogadása" style="display:none;"></div>

						<button class="sendBackForUpdate" id="<?php echo "sendBackForUpdate" . $row['id']; ?>" onclick='sendback_forupdate("<?php echo $row["id"] ?>")'>VISSZAKÜLDÉS JAVÍTÁSRA</button>
						<div id="dialogSendBackForUpdate" class="<?php echo "dialogSendBackForUpdate" . $row['id']; ?>" title="Kérdés visszaküldése javításra" style="display:none;"></div>

						<button class="rejectQuestion" id="<?php echo "rejectQuestion" . $row['id']; ?>" onclick='reject_question("<?php echo $row["id"] ?>")'>ELUTASÍTÁS</button>
						<div id="dialogRejectQuestion" class="<?php echo "dialogRejectQuestion" . $row['id']; ?>" title="Kérdés elutasítása" style="display:none;"></div>
					<?php
					}
					if(superadmin()==true)
					{
						?><br><br><span class='info_title_span'>SuperAdmin műveletek:</span><?php
						if($is_active == 1)
						{
							?>
							<button class='inactivateQuestion' id="<?php echo "inactivateQuestion" . $row['id']; ?>" onclick='inactivate_question("<?php echo $row["id"] ?>")'>Kérdés inaktiválása</button>
							<div id="dialogActivateQuestion" class="<?php echo "dialogActivateQuestion" . $row['id']; ?>" title="Kérdés aktiválása" style="display:none;"></div>
							<div id="dialogInactivateQuestion" class="<?php echo "dialogInactivateQuestion" . $row['id']; ?>" title="Kérdés inaktiválása" style="display:none;"></div>					
							<?php
						}
						else
						{
							?>
							<button class='activateQuestion' id="<?php echo "activateQuestion" . $row['id']; ?>" onclick='activate_question("<?php echo $row["id"] ?>")'>Kérdés aktiválása</button>
							<div id="dialogActivateQuestion" class="<?php echo "dialogActivateQuestion" . $row['id']; ?>" title="Kérdés aktiválása" style="display:none;"></div>
							<div id="dialogInactivateQuestion" class="<?php echo "dialogInactivateQuestion" . $row['id']; ?>" title="Kérdés inaktiválása" style="display:none;"></div>	
							<?php
						}
						?>
						<button class="updateQuestion" id="<?php echo "updateQuestion" . $row['id']; ?>" onclick='update_question_secret("<?php echo $row["id"] ?>", "<?php echo $row["id_number"] ?>")'>Módosítás</button>
						<div id="dialogUpdateQuestionSecret" class="<?php echo "dialogUpdateQuestionSecret" . $row['id']; ?>" title="Kérdés módosítása" style="display:none;"></div>

						<button class="deleteQuestion" id="<?php echo "deleteQuestion" . $row['id']; ?>" onclick='delete_question("<?php echo $row["id"] ?>")'>Törlés csendben</button>
						<div id="dialogDeleteQuestion" class="<?php echo "dialogDeleteQuestion" . $row['id']; ?>" title="Kérdés törlése csendben" style="display:none;"></div>
						<?php
					}
					?>
					<p><b><span class='info_title_span'>Egyéb adatok:</span></b></p>
				</div>
				
				<div id='detailsq_tr_other'>
					<span class='toggle_det_title'>Nyelv: </span><span class='toggle_det_data'><?php echo $row['language']; ?></span><br>
					<span class='toggle_det_title'>Nehézség: </span><span class='toggle_det_data'><?php echo $row['difficulty']; ?></span><br>
					<span class='toggle_det_title'>Aktivitás: </span><span class='toggle_det_data'><?php echo $row['is_active']; ?></span><br>
					<span class='toggle_det_title'>Commentek: </span><span class='toggle_det_data'><?php echo $row['c_comments'] . " db"; ?></span><br>
					<?php
					if($is_verified == 1 || $is_verified == 3)
					{
						?>
						<span class='toggle_det_title'>Ellenőrizte: </span><span class='toggle_det_data'><?php echo $row['adminname'] . " ( " . $row['verification_time'] . " )"; ?></span><br>
						<?php
					}
					else
					{
						?>
						<span class='toggle_det_data'><?php echo "Még nem ellenőrizte senki!"; ?></span><br>
						<?php
					}
					?>
					<span class='toggle_det_title'>Népszerűség: </span><span class='toggle_det_data'><?php echo $row['popularity']; ?></span><br><br>
					<span class='toggle_det_title'>A témakör leírása: </span><span class='toggle_det_data'><?php echo nl2br(htmlentities($row['description'])); ?></span><br> 
				</div>
			<?php


			?>
			</td>
		<?php
	}
	?>
	</table>
	<?php
	if(mysqli_num_rows($res) < 1)
	{
		echo "<br><b><font face='verdana' color='black' style='font-size:18px'>Nincs találat!";
	}
	?>

	<p id="current_page_num">Jelenlegi oldal: <?php if(isset($_GET['pageQr'])) echo $_GET['pageQr']; else echo 1; ?></p>
	<div id='div_pagination'>
		<?php
			oldalszamok($number_of_pages, $pageQr, $quizcategory, $questiontext, $where_searchresult, $search_in, $q_diff, $q_activity, $result_order, $result_dir);
		?>
	</div>
	
	<?php
}

function search_questions()
{
	?>
	<center>
	<div id="tablquestions">
    <p id='p_description'>Részletes kereső</p>
    <table width="75%">
	<form action="questions.php" method="GET">
		<tr><td>(Keresendő szöveg)<td>(Kvíz kiválasztása)<td>(Státusz)<td>(Egyéb feltétel)<td>(Nehézség kiválasztása)	
		<tr>
		<td width="25%"><input type="text" id="questiontext" class='search_class' name="questiontext" placeholder="Enter text to search..." <?php if (isset($_GET["questiontext"])) echo "value=\"" . $_GET["questiontext"] . "\""; ?> maxlength='25'>	
		
		<td width="20%">	
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

			<td width="13%">
			<select id="td_selectwhere" class='search_class' name="where_searchresult">
				<option value="0" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '0' ? ' selected="selected"' : ''; ?>>Csak ellenőrizetlenek</option>
				<option value="1" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '1' ? ' selected="selected"' : ''; ?>>Csak ellenőrzöttek </option>
				<option value="2" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '2' ? ' selected="selected"' : ''; ?>>Javítás alattiak</option>
				<option value="3" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '3' ? ' selected="selected"' : ''; ?>>Törölt kérdések</option>
				<option value="4" <?php if(isset($_GET['where_searchresult'])) echo $_GET['where_searchresult'] == '4' ? ' selected="selected"' : ''; ?>>Mindenhol</option>
			</select>

			<td width="13%">
			<select id="td_selectdel" class='search_class' name="search_in">
				<option value="1" <?php if(isset($_GET['search_in'])) echo $_GET['search_in'] == '1' ? ' selected="selected"' : ''; ?>>Kérdés szövegében</option>
				<option value="2" <?php if(isset($_GET['search_in'])) echo $_GET['search_in'] == '2' ? ' selected="selected"' : ''; ?>>Válaszok szövegében </option>
				<option value="3" <?php if(isset($_GET['search_in'])) echo $_GET['search_in'] == '3' ? ' selected="selected"' : ''; ?>>Kérdés és válaszok szövegében </option>
				<option value="4" <?php if(isset($_GET['search_in'])) echo $_GET['search_in'] == '4' ? ' selected="selected"' : ''; ?>>Beküldő nevére </option>
				<option value="5" <?php if(isset($_GET['search_in'])) echo $_GET['search_in'] == '5' ? ' selected="selected"' : ''; ?>>ID-re </option>
			</select>

			
			<td width="13%">
			<select id="td_selectorder" class='search_class' name="q_diff">
				<option value="3" <?php if(isset($_GET['q_diff'])) echo $_GET['q_diff'] == '3' ? ' selected="selected"' : ''; ?>>Mindenhol</option>
				<option value="1" <?php if(isset($_GET['q_diff'])) echo $_GET['q_diff'] == '1' ? ' selected="selected"' : ''; ?>>Csak könnyű kérdések</option>
				<option value="2" <?php if(isset($_GET['q_diff'])) echo $_GET['q_diff'] == '2' ? ' selected="selected"' : ''; ?>>Csak nehéz kérdések</option>
			</select>

			<tr><td><p id='sort_text'>Rendezési feltétel megadása</p> <td>

			<select id="td_selectorder" class='search_class' name="q_activity">
				<option value="3" <?php if(isset($_GET['q_activity'])) echo $_GET['q_activity'] == '3' ? ' selected="selected"' : ''; ?>>Mindenhol</option>
				<option value="1" <?php if(isset($_GET['q_activity'])) echo $_GET['q_activity'] == '1' ? ' selected="selected"' : ''; ?>>Csak Aktívak</option>
				<option value="2" <?php if(isset($_GET['q_activity'])) echo $_GET['q_activity'] == '2' ? ' selected="selected"' : ''; ?>>Csak inaktívak</option>
			</select>

			<td>
			<select id="td_selectorder" class='search_class' name="result_order">
				<option value="2" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '2' ? ' selected="selected"' : ''; ?>>Beküldés időpontja</option>
				<option value="1" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '1' ? ' selected="selected"' : ''; ?>>Kérdés szövege</option>
				<option value="3" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '3' ? ' selected="selected"' : ''; ?>>Kvíz neve</option>
				<option value="4" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '4' ? ' selected="selected"' : ''; ?>>Felhasználónév</option>
				<option value="5" <?php if(isset($_GET['result_order'])) echo $_GET['result_order'] == '5' ? ' selected="selected"' : ''; ?>>Népszerűség</option>
			</select>

			<td>
			<select id="td_selectdirection" class='search_class' name="result_dir">
				<option value="1" <?php if(isset($_GET['result_dir'])) echo $_GET['result_dir'] == '1' ? ' selected="selected"' : ''; ?>>Növekvő</option>
				<option value="2" <?php if(isset($_GET['result_dir'])) echo $_GET['result_dir'] == '2' ? ' selected="selected"' : ''; ?>>Csökkenő</option>
			</select>
		
			<td><input type="submit" id="submitbtn_search" class="submit" name="search_for_question" value="MEHET">
    </form>
    </table>
	</div>
	</center>
	<?php
}

?>
<html>
<head>
	<title>Kérdések</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=../includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/questions.css" />
	<link rel="stylesheet" type="text/css" href="css/menu_admin.css" />
	<link rel="stylesheet" href="../includes/jQuery-ui.css">
	<script type = "text/javascript" src="../includes/jQuery.js"></script>
	<script type = "text/javascript" src="../includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/stopwords.js"></script>
	<script type = "text/javascript" src="js/questions.js"></script>
</head>
<body>
<?php main_menu(); ?>
<p id="p_title">Kvízek kérdései</p>
<?php
search_questions();
/**-------------------------- */
$limit = 15;
/**-------------------------- */

if(isset($_GET['search_for_question']))
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

	if(!isset($_GET['questiontext']))
	{
		$_GET['questiontext'] = "";
	}
	$questiontext = "";
	if(strlen($_GET['questiontext']) >= 0 && strlen($_GET['questiontext'])<=30)
	{
		$questiontext = $_GET['questiontext'];
	}
	else
	{
		$questiontext = $_GET['questiontext'] = "";
	}

	if(!isset($_GET['where_searchresult']))
	{
		$_GET['where_searchresult'] = 0;
	}
	$where_searchresult = 0;
	if(preg_match("/^[0-9]+$/", $_GET['where_searchresult']) && $_GET['where_searchresult'] >= 0 && $_GET['where_searchresult'] <= 4)
	{
		$where_searchresult = $_GET['where_searchresult'];
	}
	else
	{
		$where_searchresult = $_GET['where_searchresult'] = 0;
	}

	if(!isset($_GET['search_in']))
	{
		$_GET['search_in'] = 1;
	}
	$search_in = 1;
	if(preg_match("/^[0-9]+$/", $_GET['search_in']) && $_GET['search_in'] >= 1 && $_GET['search_in'] <= 5)
	{
		$search_in = $_GET['search_in'];
	}
	else
	{
		$search_in = $_GET['search_in'] = 1;
	}

	if(!isset($_GET['q_diff']))
	{
		$_GET['q_diff'] = 3;
	}
	$q_diff = 3;
	if(preg_match("/^[0-9]+$/", $_GET['q_diff']) && $_GET['q_diff'] >= 1 && $_GET['q_diff'] <= 3)
	{
		$q_diff = $_GET['q_diff'];
	}
	else
	{
		$q_diff = $_GET['q_diff'] = 3;
	}

	if(!isset($_GET['q_activity']))
	{
		$_GET['q_activity'] = 3;
	}
	$q_activity = 3;
	if(preg_match("/^[0-9]+$/", $_GET['q_activity']) && $_GET['q_activity'] > 0 && $_GET['q_activity'] <= 3)
	{
		$q_activity = $_GET['q_activity'];
	}
	else
	{
		$q_activity = $_GET['q_activity'] = 3;
	}

	if(!isset($_GET['result_order']))
	{
		$_GET['result_order'] = 1;
	}
	$result_order = 1;
	if(preg_match("/^[0-9]+$/", $_GET['result_order']) && $_GET['result_order'] > 0 && $_GET['result_order'] <= 5)
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

	question_list($quizcategory, $questiontext, $where_searchresult, $search_in, $q_diff, $q_activity, $result_order, $result_dir, $limit);
}
else
{
	question_list(0, "", 0, 1, 3, 3, 2, 1, $limit);
}

?>
</body>
</html>