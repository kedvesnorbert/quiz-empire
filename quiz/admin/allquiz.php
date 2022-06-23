<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_allquiz.php");
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

function datediff_in_days($date1)
{
	$date2 = time(); // NOW()
	$date1 = strtotime($date1);
	$datediff = $date2 - $date1;
	return round($datediff / (60 * 60 * 24));
}

function oldalszamok($number_of_pages, $pagequiz, $search_quizname, $where_searchquiz, $quiz_phase, $quiz_type)
{
	if($number_of_pages < 2)
	{
		;
	}
	else
	{
		if($_GET['pagequiz'] > 10)
		{
			$link = '';
			$link .= '<a href="allquiz.php?pagequiz=' . "1" . '&search_quizname=' . $search_quizname . '&where_searchquiz=' . $where_searchquiz . '&quiz_phase=' . $quiz_phase . '&quiz_type=' . $quiz_type . '&search_for_quiz=KERES">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
			echo "&nbsp; ... &nbsp; ";
		}
		else
		{
			$link = '';
			$link .= '<a href="allquiz.php?pagequiz=' . "1" . '&search_quizname=' . $search_quizname . '&where_searchquiz=' . $where_searchquiz . '&quiz_phase=' . $quiz_phase . '&quiz_type=' . $quiz_type . '&search_for_quiz=KERES">' . "1" . '</a> '; echo $link; echo '&nbsp; | &nbsp; ';
		}
		
		
		for($pagequiz=$_GET['pagequiz']-3; $pagequiz < $_GET['pagequiz']+3 && $pagequiz <=$number_of_pages-1; ++$pagequiz)
		{
			if($pagequiz > 1)
			{
				$link = '';
				$link .= '<a href="allquiz.php?pagequiz=' . $pagequiz . '&search_quizname=' . $search_quizname . '&where_searchquiz=' . $where_searchquiz . '&quiz_phase=' . $quiz_phase . '&quiz_type=' . $quiz_type . '&search_for_quiz=KERES">' . $pagequiz . '</a> ';
				
				echo $link;
				echo '&nbsp; | &nbsp; ';
			}
			
		}
		if($pagequiz == $number_of_pages)
		{
			$link = '';
			$link .= '<a href="allquiz.php?pagequiz=' . $pagequiz . '&search_quizname=' . $search_quizname . '&where_searchquiz=' . $where_searchquiz . '&quiz_phase=' . $quiz_phase . '&quiz_type=' . $quiz_type . '&search_for_quiz=KERES">' . $pagequiz . '</a> '; echo $link;
		}
		else
		{
			echo "&nbsp; ... &nbsp;";
			$link = '';
			$link .= '<a href="allquiz.php?pagequiz=' . $number_of_pages . '&search_quizname=' . $search_quizname . '&where_searchquiz=' . $where_searchquiz . '&quiz_phase=' . $quiz_phase . '&quiz_type=' . $quiz_type . '&search_for_quiz=KERES">' . $number_of_pages . '</a> '; echo $link;
		}
	}
}

function quizlist($search_quizname, $where_searchquiz, $quiz_phase, $quiz_type, $limit)
{
	if($quiz_phase == 5)
	{
		echo "<p id='title_searchquiz'>Moderátori ellenőrzésre váró kvízek</p>";
	}
	elseif($quiz_phase == 4)
	{
		echo "<p id='title_searchquiz'>Törölt kvízek</p>";
	}
	elseif($quiz_phase == 3)
	{
		echo "<p id='title_searchquiz'>Aktív kvízek</p>";
	}
	elseif($quiz_phase == 2)
	{
		echo "<p id='title_searchquiz'>Kérdések beküldésére váró kvízek</p>";
	}
	elseif($quiz_phase == 1)
	{
		echo "<p id='title_searchquiz'>Jóváhagyásra váró kvízek</p>";
	}
	$all_newquiz = db_numrows_quizlist($search_quizname, $where_searchquiz, $quiz_phase, $quiz_type);
	if(!$all_newquiz)
	{
		$all_newquiz = 0;
	}
	$number_of_pagesq = ceil($all_newquiz/$limit);
	if(!isset($_GET['pagequiz']))
	{
		$pagequiz = $_GET['pagequiz'] = 1;
	}
	else
	{
		if(preg_match("/^[0-9]+$/", $_GET['pagequiz']) && $_GET['pagequiz'] > 0 && $_GET['pagequiz'] <= $number_of_pagesq)
		{
			$pagequiz = $_GET['pagequiz'];
		}	
		else
		{
			$pagequiz = $_GET['pagequiz'] = 1;
		}	
	}
	$this_page_first_result = ($pagequiz-1)*$limit;
	$res = db_quizlist($this_page_first_result, $search_quizname, $where_searchquiz, $quiz_phase, $quiz_type, $limit);
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
			oldalszamok($number_of_pagesq, $pagequiz, $search_quizname, $where_searchquiz, $quiz_phase, $quiz_type);
		?>
	</div>

	<table id="allquizlist_table" border="1" align="center">
	<tr id="table_head">
		<th style='width:30%'>Kvíz neve
		<th style='width:10%'>Fázis
		<th style='width:10%'>Típus
		<th style='width:13%'>Kérő neve
		<th style='width:13%'>Kérés ideje
		<th style='width:25%'>Műveletek
	<?php
	while ($row = mysqli_fetch_assoc($res))
	{
		$fazis = $row['phase'];
		if($row['phase'] == 1)
		{
			$row['phase'] = "Jóváhagyásra vár";
		}
		elseif($row['phase'] == 2)
		{
			$row['phase'] = "Kérdések beküldésére vár";
		}
		elseif($row['phase'] == 3)
		{
			$row['phase'] = "Aktív kvíz";
		}

		if($row['is_request'] == 1)
		{
			$isrequest = "Kérés";
		}
		elseif($row['is_request'] == 0)
		{
			$isrequest = "Saját kvíz";
		}

		if($row['is_deleted'] == 1)
		{
			$is_deletedquiz = "Igen";
		}
		elseif($row['is_deleted'] == 0)
		{
			$is_deletedquiz = "Nem";
		}

		if($row['anonymus_request'] == 1)
		{
			$anonymus_request = "Igen";
		}
		elseif($row['anonymus_request'] == 0)
		{
			$anonymus_request = "Nem";
		}

		if($row['anonymus_accomplish'] == 1)
		{
			$anonymus_accomplish = "Igen";
		}
		elseif($row['anonymus_accomplish'] == 0)
		{
			$anonymus_accomplish = "Nem";
		}
			
		if($row['language'] == 1)
		{
			$row['language'] = 'Magyar';
		}
		elseif($row['language'] == 2)
		{
			$row['language'] = 'Angol';
		}
		if($row['show_answers'] == 1)
		{
			$row['show_answers'] = 'Engedélyezve';
		}
		elseif($row['show_answers'] == 2)
		{
			$row['show_answers'] = 'Nincs engedélyezve';
		}

		if($row['num_of_playing'] == 0)
		{
			$row['num_of_playing'] = "korlátlan";
		}
		if($row['start_date'] == '')
		{
			$row['start_date'] = "Nincs korlátozva";
		}
		if($row['end_date'] == '')
		{
			$row['end_date'] = "Nincs korlátozva";
		}

		if($row['access'] == 1)
		{
			$row['access'] = 'Csak a beküldő';
		}
		elseif($row['access'] == 2)
		{
			$row['access'] = 'A beküldő, adminok és pár kijelölt felhasználó';
		}
		elseif($row['access'] == 3)
		{
			$row['access'] = 'Mindenki';
		}
		elseif($row['access'] == 4)
		{
			$row['access'] = 'Akik ismerik a jelszót';
		}
		elseif($row['access'] == 5)
		{
			$row['access'] = 'Adminok, a beküldő és az ő barátai';
		}

		if($row['accept_questions'] == 1)
		{
			$row['accept_questions'] = 'Csak a beküldő';
		}
		elseif($row['accept_questions'] == 2)
		{
			$row['accept_questions'] = 'Csak a beküldő és az adminok';
		}
		elseif($row['accept_questions'] == 3)
		{
			$row['accept_questions'] = 'A beküldő, adminok és pár kijelölt felhasználó';
		}
		elseif($row['accept_questions'] == 4)
		{
			$row['accept_questions'] = 'Mindenki';
		}
		elseif($row['accept_questions'] == 5)
		{
			$row['accept_questions'] = 'Adminok, a beküldő és az ő barátai';
		}

		if(strlen($row['byuser_minreq_quest']) > 0)
		{
			if($row['minimum_requested_quest'] > $row['byuser_minreq_quest'])
			{
				$requested_questions = $row['minimum_requested_quest'];
			} 	 
			else
			{
				$requested_questions = $row['byuser_minreq_quest'];
			}
		}
		else
		{
			$requested_questions = $row['minimum_requested_quest'];
		}
		$date = new DateTime("now", new DateTimeZone('Europe/Bucharest') );
        $date_now = $date->format('Y-m-d H:i:s');
			
		echo "<tr id='rows_table' class='mainDatasQuiz" . $row['id_number'] . "'>";
		echo "<td align='center'>"; ?><a href="" class="toggler1_1" data-prod="<?php echo $row['id_number']; ?>"> <?php echo $row['quiz_name']; ?></a><?php echo "\n";
		echo "<td align='center'>" . $row['phase'] . "\n";
		echo "<td align='center'>" . $isrequest . "\n";
		echo "<td align='center'>" . $row['requested_by'] . "\n";
		echo "<td align='center'>" . $row['request_date'] . "\n";
		
		echo "<td align='center'>";
		if($row['is_request'] == 0)
		{
			if($row['is_deleted'] == 0)
			{
				if($fazis == 1)
				{
					?>
					<button id='confirm_newquiz' onclick="confirm_newquiz('<?php echo $row['id_number'] ?>', '<?php echo $row['quiz_name'] ?>')">Jóváhagyás</button>
					<div id="dialogConfirmNewQuiz" title="Kvíz jóváhagyása" style="display:none;"></div>

					<button id='reject_newquiz' onclick="reject_newquiz('<?php echo $row['id_number'] ?>', '<?php echo $row['quiz_name'] ?>')">Törlés</button>
					<div id="dialogRejectNewQuiz" title="Kvíz elutasítása" style="display:none;"></div>
					<?php
				}
				elseif($fazis == 2)
				{
					if($row['ownquiz_allquestion'] >= $row['minimum_requested_quest'] && $row['ownquiz_accepted'] >= $row['minimum_requested_quest'])
					{
						?>
						<button id='accept_newquiz' onclick="accept_newquiz('<?php echo $row['id_number'] ?>', '<?php echo $row['quiz_name'] ?>')">ELFOGADÁS</button>
						<div id="dialogAcceptNewQuiz" title="Kvíz elfogadása" style="display:none;"></div>
						<?php
					}
					else
					{
						echo "Folyamatban...";
					}	
				}
				elseif($fazis == 3)
				{
					?>
					<input type="button" id="goToQuizPage" onclick="window.location.href='allquizdetail.php?quiz_id=<?php echo $row['id_number'] ?>'" value="Tovább a kvíz oldalára">
					<?php
				}
			}
			else
			{
				if($fazis < 3)
				{
					echo "Törölt kvíz!";
				}
				else
				{
					?>
					<input type="button" id="goToDeletedQuizPage" onclick="window.location.href='allquizdetail.php?quiz_id=<?php echo $row['id_number'] ?>'" value="Törölt kvíz - Részletek">
					<?php
				}
			}
		}
		elseif($row['is_request'] == 1)
		{
			if($row['is_deleted'] == 0)
			{
				if($fazis == 1)
				{
					?>
					<button id='confirm_request' onclick="confirm_request('<?php echo $row['id_number'] ?>', '<?php echo $row['quiz_name'] ?>')">Jóváhagyás</button>
					<div id="dialogConfirmRequest" title="Kérés jóváhagyása" style="display:none;"></div>

					<button id='reject_request' onclick="reject_request('<?php echo $row['id_number'] ?>', '<?php echo $row['quiz_name'] ?>')">Törlés</button>
					<div id="dialogRejectRequest" title="Kérés elutasítása" style="display:none;"></div>
					<?php
				}
				elseif($fazis == 2)
				{
					if($row['is_undertaken'] == 1 && $row['request_allquestion'] >= $requested_questions && $row['request_accepted'] >= $requested_questions && $row['request_verifiedallquestion'] == 0)
					{
						?>
						<button id='accept_request' onclick="accept_request('<?php echo $row['id_number'] ?>', '<?php echo $row['quiz_name'] ?>')">ELFOGADÁS</button>
						<div id="dialogAcceptRequest" title="Kérés elfogadása" style="display:none;"></div>
						<?php
					}
					elseif($row['is_undertaken'] == 1 && $date_now > $row['accomplish_deadline'] && $row['request_allquestion'] < $requested_questions)
					{
						$delay_in_days = datediff_in_days($row['accomplish_deadline']);
						?>
						<button id='failed_request_fulfillment' onclick="failed_request_fulfillment('<?php echo $row['id_number'] ?>', '<?php echo $row['quiz_name'] ?>', '<?php echo $row['undertaken_by'] ?>', '<?php echo $row['accomplish_deadline'] ?>', '<?php echo $row['request_allquestion'] ?>', '<?php echo $row['request_verifiedquestion'] ?>', '<?php echo $row['request_accepted'] ?>', '<?php echo $requested_questions ?>', '<?php echo $delay_in_days ?>')">Sikertelen teljesítés</button>
						<div id="dialogFailedRequestFulfillment" title="Sikertelen kérés teljesítés" style="display:none;"></div>
						<?php
					}
					elseif($row['is_undertaken'] == 0)
					{
						echo "Nincs elvállalva!";
					}
					else
					{
						echo "Teljesítés alatt...";
					}
				}
				elseif($fazis == 3)
				{
					?>
					<input type="button" id="goToQuizPage" onclick="window.location.href='allquizdetail.php?quiz_id=<?php echo $row['id_number'] ?>'" value="Tovább a kvíz oldalára">
					<?php
				}
			}
			else
			{
				if($fazis < 3)
				{
					echo "Törölt kvíz!";
				}
				else
				{
					?>
					<input type="button" id="goToDeletedQuizPage" onclick="window.location.href='allquizdetail.php?quiz_id=<?php echo $row['id_number'] ?>'" value="Törölt kvíz - Részletek">
					<?php
				}
			}
		}
		
		?>
		<tr id='rows_table' class="<?php echo "detailsQuiz" . $row['id_number']; ?>" style="display:none;">
			<td colspan='6' class='toggle_td_class'>
			<?php
			if($fazis > 1)
			{
				if($row["is_deleted"] == 0)
				{
					?>
					<button class='deleteQuiz' id="<?php echo "deleteQuiz" . $row['id_number']; ?>" onclick='delete_quiz("<?php echo $row["id_number"] ?>", "<?php echo $row["quiz_name"] ?>")'>Kvíz törlése</button>
					<div id="dialogDeleteQuiz" class="<?php echo "dialogDeleteQuiz" . $row['id_number']; ?>" title="Kvíz törlése" style="display:none;"></div>
					<div id="dialogEnableQuiz" class="<?php echo "dialogEnableQuiz" . $row['id_number']; ?>" title="Kvíz visszaállítása" style="display:none;"></div>					
					<?php
				}
				else
				{
					?>
					<button class="enableQuiz" id="<?php echo "enableQuiz" . $row['id_number']; ?>" onclick='enable_quiz("<?php echo $row["id_number"] ?>", "<?php echo $row["quiz_name"] ?>")'>Kvíz visszaállítása</button>
					<div id="dialogEnableQuiz" class="<?php echo "dialogEnableQuiz" . $row['id_number']; ?>" title="Kvíz visszaállítása" style="display:none;"></div>
					<div id="dialogDeleteQuiz" class="<?php echo "dialogDeleteQuiz" . $row['id_number']; ?>" title="Kvíz törlése" style="display:none;"></div>
					<?php
				}
				?>
				<button class='activequestionlist' id="<?php echo "activequestionlist" . $row['id_number']; ?>" onclick='show_activequestions("<?php echo $row["id_number"]; ?>", "<?php echo $row["quiz_name"]; ?>")'>Aktív kérdések megtekintése</button>
				<div id="dialogShowActiveQuestionList" class="<?php echo "dialogShowActiveQuestionList" . $row['id_number']; ?>" title="Aktív kérdések megtekintése" style="display:none;"></div>
				<?php
			}
			?>
			<p class='toggle_det_subtitle'>A kvíz állapota</p>
			<?php
			
				?>
				<span class='toggle_det_title'>Azonosító szám: </span><span class='toggle_det_data'><b><?php echo $row['id_number']; ?></b></span><br>
				<span class='toggle_det_title'>Törölt kvíz: </span><span class='toggle_det_data'><?php echo $is_deletedquiz; ?></span><br>
				<span class='toggle_det_title'>Névtelen kérés: </span><span class='toggle_det_data'><?php echo $anonymus_request; ?></span><br>
				<span class='toggle_det_title'>Névtelen teljesítés: </span><span class='toggle_det_data'><?php echo $anonymus_accomplish; ?></span><br><br>
				<?php
				if($row['is_request'] == 0)
				{
					?>
					<span class='toggle_det_title'>Eddig beküldött kérdések: </span><span class='toggle_det_data' style='color:green;font-weight:bold;'><?php echo $row['ownquiz_allquestion']; ?></span><br>
					<span class='toggle_det_title'>Ebből ellenőrzive: </span><span class='toggle_det_data' style='color:red;font-weight:bold;'><?php echo $row['ownquiz_verifiedquestion']; ?></span><br>
					<span class='toggle_det_title'>Ebből ELFOGADVA (beküldött / kötelező): </span><span class='toggle_det_data' style='color:red;font-weight:bold;'><?php echo $row['ownquiz_accepted'] . " / " . $requested_questions; ?></span><br>
					<?php
				}
				elseif($row['is_request'] == 1)
				{
					if($fazis == 3)
					{
						?>
						<span class='toggle_det_title'>Teljesítette: </span><span class='toggle_det_data' style='color:green;font-weight:bold;'><?php echo $row['accomplished_by']; ?></span><br>
						<?php
					}
					if($fazis < 3)
					{
						?>
						<span class='toggle_det_title'>Felajánlott pontok: </span><span class='toggle_det_data' style='color:red;font-weight:bold;'><?php echo floor($row['request_offeredpoints']/2) . " ( " . $row['request_votes'] . " felhasználó kérte )"; ?></span><br>
						<span class='toggle_det_title'>Elvállalta: </span><span class='toggle_det_data' style='color:green;font-weight:bold;'><?php if(strlen($row['undertaken_by']) < 1) { echo 'Jelenleg nincs elvállalva'; } else {echo $row['undertaken_by'];} ?></span><br>
						<?php
					}
					?>
					<span class='toggle_det_title'>Eddig beküldött kérdések: </span><span class='toggle_det_data' style='color:green;font-weight:bold;'><?php echo $row['request_allquestion']; ?></span><br>
					<span class='toggle_det_title'>Ebből ellenőrzive: </span><span class='toggle_det_data' style='color:red;font-weight:bold;'><?php echo $row['request_verifiedquestion']; ?></span><br>
					<span class='toggle_det_title'>Ebből ELFOGADVA (beküldött / kötelező): </span><span class='toggle_det_data' style='color:red;font-weight:bold;'><?php echo $row['request_accepted'] . " / " . $requested_questions;; ?></span><br><?php
					if($fazis < 3)
					{
						?>
						<span class='toggle_det_title'>Teljesítési határidő: </span><span class='toggle_det_data' style='color:red;font-weight:bold;'><?php if(strlen($row['accomplish_deadline']) < 1) { echo 'Még nincs'; } else {echo $row['accomplish_deadline'];} ?></span><br>
						<?php
					}
				}
				
				if($fazis == 3)
				{
					?>
					<span class='toggle_det_title'>Teljesítés ideje: </span><span class='toggle_det_data'><?php echo $row['accomplish_date']; ?></span><br>
					<?php
				}
				?>
				<p class='toggle_det_subtitle'>A kvíz adatai</p>
				<span class='toggle_det_title'>A kvíz nyelve: </span><span class='toggle_det_data'><?php echo $row['language']; ?></span><br>
				<span class='toggle_det_title'>Átmenő: </span><span class='toggle_det_data'><?php echo $row['pass_degree'] . "%"; ?></span><br>
				<span class='toggle_det_title'>Játszmánkénti kérdések: </span><span class='toggle_det_data'><?php echo $row['num_of_question'] . " db"; ?></span><br>
				<span class='toggle_det_title'>Egy kérdésre jutó válaszolási idő: </span><span class='toggle_det_data'><?php echo $row['time_to_answer'] . " mp"; ?></span><br>
				<span class='toggle_det_title'>Helyes válaszok megmutatása: </span><span class='toggle_det_data'><?php echo $row['show_answers']; ?></span><br>
				<span class='toggle_det_title'>Ellenőrizhető: </span><span class='toggle_det_data'><?php echo $row['verification'] . " alkalommal"; ?></span><br>
				<span class='toggle_det_title'>Beküldés oka: </span><span class='toggle_det_data'><?php echo $row['reason']; ?></span>

				<p class='toggle_det_subtitle'>Korlátozások</p>
				<span class='toggle_det_title'>Elérhetőség: </span><span class='toggle_det_data'><?php echo $row['access']; ?></span><br>
				<span class='toggle_det_title'>Összes próbálkozás: </span><span class='toggle_det_data'><?php echo $row['num_of_playing'] . " alkalommal"; ?></span><br>
				<span class='toggle_det_title'>Indulás ideje: </span><span class='toggle_det_data'><?php echo $row['start_date']; ?></span><br>
				<span class='toggle_det_title'>Lezárulás ideje: </span><span class='toggle_det_data'><?php echo $row['end_date']; ?></span><br>
				<span class='toggle_det_title'>Kérdések beküldése: </span><span class='toggle_det_data'><?php echo $row['accept_questions']; ?></span><br>

				<p class='toggle_det_subtitle'>Részletes leírás: </p><span class='toggle_det_data'><?php echo nl2br(htmlentities($row['description'])); ?></span><br>
				<?php			
	}
	?>
	</table>
	<p id="current_page_num">Jelenlegi oldal: <?php if(isset($_GET['pagequiz'])) echo $_GET['pagequiz']; else echo 1; ?></p>
	<div id='div_pagination'>
		<?php
			oldalszamok($number_of_pagesq, $pagequiz, $search_quizname, $where_searchquiz, $quiz_phase, $quiz_type);
		?>
	</div>
	<?php
}

function quiz_search()
{
    ?><center>
	<div id="tablquizzes">
    <p id='p_description'>Részletes kereső</p>
    <table>
	<form action="allquiz.php" method="GET">
		<tr>
			<td><input type="text" id="td_input" class='search_class' name="search_quizname" placeholder="Enter some text..." <?php if (isset($_GET["search_quizname"])) echo "value=\"" . $_GET["search_quizname"] . "\""; ?> maxlength='50' autofocus>
		<td>
			<select id="td_selectwhere" name="where_searchquiz">
				<option value="1" <?php if(isset($_GET['where_searchquiz'])) echo $_GET['where_searchquiz'] == '1' ? ' selected="selected"' : ''; ?>>Kvíz nevére</option>
				<option value="2" <?php if(isset($_GET['where_searchquiz'])) echo $_GET['where_searchquiz'] == '2' ? ' selected="selected"' : ''; ?>>Leírásban</option>
				<option value="3" <?php if(isset($_GET['where_searchquiz'])) echo $_GET['where_searchquiz'] == '3' ? ' selected="selected"' : ''; ?>>Azonosító számra</option>
				<option value="4" <?php if(isset($_GET['where_searchquiz'])) echo $_GET['where_searchquiz'] == '4' ? ' selected="selected"' : ''; ?>>Beküldő nevére</option>
			</select>
			<select id="td_selectorder" name="quiz_phase">
				<option value="5" <?php if(isset($_GET['quiz_phase'])) echo $_GET['quiz_phase'] == '5' ? ' selected="selected"' : ''; ?>>Ellenőrzésre váró</option>
				<option value="1" <?php if(isset($_GET['quiz_phase'])) echo $_GET['quiz_phase'] == '1' ? ' selected="selected"' : ''; ?>>Jóváhagyásra vár (1.fázis)</option>
				<option value="2" <?php if(isset($_GET['quiz_phase'])) echo $_GET['quiz_phase'] == '2' ? ' selected="selected"' : ''; ?>>Ellenőrzés alatt (2.fázis)</option>
				<option value="3" <?php if(isset($_GET['quiz_phase'])) echo $_GET['quiz_phase'] == '3' ? ' selected="selected"' : ''; ?>>Aktív kvízek (3.fázis)</option>
				<option value="4" <?php if(isset($_GET['quiz_phase'])) echo $_GET['quiz_phase'] == '4' ? ' selected="selected"' : ''; ?>>Törölt kvízek</option>
			</select>
			<select id="td_selecttype" name="quiz_type">
				<option value="3" <?php if(isset($_GET['quiz_type'])) echo $_GET['quiz_type'] == '3' ? ' selected="selected"' : ''; ?>>Mindenhol</option>
				<option value="1" <?php if(isset($_GET['quiz_type'])) echo $_GET['quiz_type'] == '1' ? ' selected="selected"' : ''; ?>>Csak saját kvízekben</option>
				<option value="2" <?php if(isset($_GET['quiz_type'])) echo $_GET['quiz_type'] == '2' ? ' selected="selected"' : ''; ?>>Csak kérések között</option>
			</select>
		
			<td><input id="submitbtn_search" type="submit" class="submit" name="search_for_quiz" value="KERESÉS">
    </form>
    </table>
	</div>
	</center>
    <?php
}

?>
<html>
<head>
	<title>Kvízek</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=../includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/allquiz.css" />
	<link rel="stylesheet" type="text/css" href="css/menu_admin.css" />
	<link rel="stylesheet" href="../includes/jQuery-ui.css">
	<script type = "text/javascript" src="../includes/jQuery.js"></script>
	<script type = "text/javascript" src="../includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/allquiz.js"></script>
</head>
<body>
<?php main_menu(); ?>
<p id="p_title">Kvízek és kérések</p>
<?php
quiz_search();
/**-------------------------- */
$limit = 15;
/**-------------------------- */

if(isset($_GET['search_for_quiz']))
{
	
	if(!isset($_GET['search_quizname']))
	{
		$_GET['search_quizname'] = "";
	}
	$keresendoNev = 1;
	if(preg_match("/^[a-zA-Z0-9 ]*$/", $_GET['search_quizname']) && strlen($_GET['search_quizname'])<50)
	{
		$keresendoNev = $_GET['search_quizname'];
	}
	else
	{
		$keresendoNev = $_GET['search_quizname'] = "";
	}
	
	if(!isset($_GET['where_searchquiz']))
	{
		$_GET['where_searchquiz'] = 1;
	}
	$holKeres = 1;
	if(preg_match("/^[0-9]+$/", $_GET['where_searchquiz']) && $_GET['where_searchquiz'] > 0 && $_GET['where_searchquiz'] <= 4)
	{
		$holKeres = $_GET['where_searchquiz'];
	}
	else
	{
		$holKeres = $_GET['where_searchquiz'] = 1;
	}

	if(!isset($_GET['quiz_phase']))
	{
		$_GET['quiz_phase'] = 1;
	}
	$fazisTipus = 1;
	if(preg_match("/^[0-9]+$/", $_GET['quiz_phase']) && $_GET['quiz_phase'] > 0 && $_GET['quiz_phase'] <= 6)
	{
		$fazisTipus = $_GET['quiz_phase'];
	}
	else
	{
		$fazisTipus = $_GET['quiz_phase'] = 1;
	}

	if(!isset($_GET['quiz_type']))
	{
		$_GET['quiz_type'] = 1;
	}
	$kvizTipus = 1;
	if(preg_match("/^[0-9]+$/", $_GET['quiz_type']) && $_GET['quiz_type'] > 0 && $_GET['quiz_type'] <= 3)
	{
		$kvizTipus = $_GET['quiz_type'];
	}
	else
	{
		$kvizTipus = $_GET['quiz_type'] = 1;
	}

	quizList($keresendoNev, $holKeres, $fazisTipus, $kvizTipus, $limit);
}
else
{
	quizList("", 1, 5, 3, $limit);
}

?>
</body>
</html>