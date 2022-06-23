<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_quizdetails.php");
require_once("includes/responses.php");
require_once("includes/update_logoff.php");
require_once("includes/ip_functions.php");
require_once("view/menu.php");
require_once("view/view_quizdetails.php");

if(!isset($_SESSION["user"]))
{
	$fromurl = urlencode($_SERVER["REQUEST_URI"]);
	setcookie("fromwhere", $fromurl);
	header("location: login.php");
	$_SESSION = array();
	session_destroy();
}

if(!isset($_GET['quiz_id']) || !preg_match("/^[0-9]+$/", $_GET['quiz_id']) || $_GET['quiz_id'] < 1)
{
	$_GET['quiz_id'] = 0;
}
/*Global variables*/
$isownquiz = db_isownquiz($_GET['quiz_id']);
$quizdata = db_getquizdata($_GET['quiz_id']);

function all_quizdata()
{
	global $quizdata;
	$res = $quizdata;
	if (!$res)
	{
		die(mysqli_connect_error());
	}
	$row = mysqli_fetch_assoc($res);
	if($row['language'] == 1)
	{
		$row['language'] = 'Magyar';
	}
	elseif($row['language'] == 2)
	{
		$row['language'] = 'Angol';
	}
	
	if($row['verification'] == -1)
	{
		$row['verification'] = "korlátlan";
	}
	
	if($row['show_answers'] == 1)
	{
		$row['show_answers'] = 'megmutatva';
	}
	else
	{
		$row['show_answers'] = 'Nincsenek megmutatva';
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
	
	global $isownquiz;
	if($isownquiz == true)
	{
		
		if($row['access'] == 1)
		{
			$row['access'] = 'Csak én';
		}
		elseif($row['access'] == 2)
		{
			$res1 = db_friends_access_quiz_d($_GET['quiz_id']);
			if(!$res1)
			{
				die(err_db());
			}
			$num_rows = mysqli_num_rows($res1);
			$counter = 1;
			$row['access'] = 'Én, adminok, valamint: ';
			while($row1 = mysqli_fetch_array($res1))
			{
				$row['access'] .= $row1['username'];
				if($counter < $num_rows)
				{
					$row['access'] .= ", ";
				}
				++$counter;
			}
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
			$row['access'] = 'Én, adminok és a jelenlegi barátaim';
		}
	}
	else
	{
		if($row['access'] == 1)
		{
			$row['access'] = 'Csak a feltöltő';
		}
		elseif($row['access'] == 2)
		{
			$row['access'] = 'A feltöltő, adminok és pár kijelölt felhasználó';
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
			$row['access'] = 'Adminok, a feltöltő és az ő barátai';
		}
	}
	global $isownquiz;
	if($isownquiz == true)
	{
		if($row['accept_questions'] == 1)
		{
			$row['accept_questions'] = 'Csak én';
		}
		elseif($row['accept_questions'] == 2)
		{
			$row['accept_questions'] = 'Csak én és az adminok';
		}
		elseif($row['accept_questions'] == 3)
		{	
			$res2 = db_friends_sendquestion($_GET['quiz_id']);
			if(!$res2)
			{
				die(err_db());
			}
			$num_rows2 = mysqli_num_rows($res2);
			$counter2 = 1;
			$row['accept_questions'] = 'Én, adminok, valamint: ';
			while($row2 = mysqli_fetch_assoc($res2))
			{
				$row['accept_questions'] .= $row2['username'];
				if($counter2 < $num_rows2)
				{
					$row['accept_questions'] .= ", ";
				}
				++$counter2;
			}
			
		}
		elseif($row['accept_questions'] == 4)
		{
			$row['accept_questions'] = 'Mindenki';
		}
		elseif($row['accept_questions'] == 5)
		{
			$row['accept_questions'] = 'Én, adminok és a barátaim';
		}
	}
	else
	{
		if($row['accept_questions'] == 1)
		{
			$row['accept_questions'] = 'Csak a feltöltő';
		}
		elseif($row['accept_questions'] == 2)
		{
			$row['accept_questions'] = 'Csak a feltöltő és az adminok';
		}
		elseif($row['accept_questions'] == 3)
		{
			$row['accept_questions'] = 'A feltöltő, adminok és pár kijelölt felhasználó';
		}
		elseif($row['accept_questions'] == 4)
		{
			$row['accept_questions'] = 'Mindenki';
		}
		elseif($row['accept_questions'] == 5)
		{
			$row['accept_questions'] = 'Adminok, a feltöltő és az ő barátai';
		}
	}
	
	view_quizdetails_minimenu($_GET['quiz_id'], $isownquiz, $_GET['action_id']);
	 
	if($row['anonymus_accomplish'] == 1)
	{
		$quiz_uploader = 'Anonymus';
	}
	else
	{
		$getuid = db_getuserid($row['accomplished_by']);
		if(!$getuid)
		{
			die(err_db());
		}
		$quiz_uploader = '<a href="profile.php?profil_id=' . $getuid . '">' . $row['accomplished_by'] . '</a>';
	}
	
	$res_rating = db_getquizrating_data($_GET['quiz_id']);
	$row_rating = mysqli_fetch_assoc($res_rating);
	if(strlen($row_rating['atl']) == 0)
	{
		$avg_rating = "Még senki sem értékelte!";
	}
	else
	{
		$avg_rating = number_format((float)$row_rating['atl'], 2, '.', '');
		$avg_rating = "Átlag: " . $avg_rating . " / 5.00 (" . $row_rating['users_rating'] . " felhasználó)";
	}

	$own_rating = "";
	$bool_myrating = $row_rating['bool_my_rating'];
	$myrating = $row_rating['my_rating'];
	
	if($isownquiz != true)
	{
		if($bool_myrating)
		{
			$own_rating =  "<br>Saját: " . $myrating . " csillag";
		}
		else
		{
			$own_rating = "need";
		}
	}
	else
	{
		$own_rating = "";
	}

	$quiz_description = nl2br(htmlentities($row['description']));		
				
	$questions_by_users = "";
	global $isownquiz;
	if($isownquiz == true)
	{
		$questions_by_users .= '<br><br><b>Felhasználók kérdései: </b>';
		$res3 = db_getquizquestions($_GET['quiz_id']);
		if(!$res3)
		{
			die(err_db());
		}
		$num_rows3 = mysqli_num_rows($res3);
		$counter3 = 1;
		while($row3 = mysqli_fetch_array($res3))
		{
			$questions_by_users .= $row3['username'] . " (" . $row3['kerdes_szam'] . " db)";
			if($counter3 < $num_rows3)
			{
				$questions_by_users .= ", ";
			}
			++$counter3;
		}
	}
			
	view_quizdata($row['quiz_name'], $row['num_of_question'], $row['num_of_playing'], $row['time_to_answer'], $row['access'], $row['pass_degree'], $row['accept_questions'], $row['language'], $quiz_uploader, $row['start_date'], $row['verification'], $row['end_date'], $avg_rating, $own_rating, $row['show_answers'], $row['accomplish_date'], $quiz_description, $questions_by_users);	
}

function show_startbutton()
{
	$res = db_getquizdata($_GET['quiz_id']);
	if(!$res)
	{
		die(err_db());
	}
	$row = mysqli_fetch_assoc($res);
	
	view_startquiz_btn($row["id_number"], $row["quiz_name"], $row["time_to_answer"], $row["num_of_question"], $row["access"], $_GET['quiz_id']);
}

function show_likes()
{
	$res = db_quizlikes($_GET['quiz_id']);
	if(!$res)
	{
		die(err_db());
	}
	$sorok = mysqli_num_rows($res);
	$i = 1;
	$data = "";
	if($sorok == 0)
	{
		$data .= '<p id="no_likes_text">Még senki sem kedvelte ezt a kvízt!</p>';
	}
	else
	{
		while($row = mysqli_fetch_assoc($res))
		{
			$data .= '<a href="profile.php?profil_id=' . $row["userid"] . '">' . $row['username'] . '</a>';
			if($i < $sorok)
			{
				$data .= ", ";
			}
			++$i;
		}
	}

	$like_btn = "";
	global $isownquiz;
	if(db_isalready_liked($_GET['quiz_id']) == false && $isownquiz == false)
	{
		$u = $_SESSION["user"];
		$t = $_GET['quiz_id'];
		$like_btn .= "<center><button id='like_button' class='btn btn-light' onclick='like_quiz(" . $t . ", \"" . $u . "\")'>Tetszik a kvíz</button></center>";
		
	}
	view_quizlikes($data, $like_btn);
}

function show_comment()
{	
	if(db_already_played($_GET['quiz_id']) == true)
	{
		view_leave_comment($_GET['quiz_id']);
	}
	else
	{
		view_forbidden_leaving_comment($_GET['quiz_id']);
	}
}

function show_ranglists($type)
{
	?>
	<a href="ranglistsanchor" id="ranglistsanchor"></a>
	<?php
	if($type == 2)
	{
		?><hr class="ranglist_hr"><p id="show_quizrating_title">A mai napi ranglista</p><br><?php
	}
	elseif($type == 3)
	{
		?><hr class="ranglist_hr"><p id="show_quizrating_title">A legelső próbálkozások listája</p><br><?php
	}
	elseif($type == 4)
	{
		?><hr class="ranglist_hr"><p id="show_quizrating_title">Minden próbálkozás listája</p><br><?php
	}
	elseif($type == 5)
	{
		?><hr class="ranglist_hr"><p id="show_quizrating_title">Összes saját próbálkozások</p><br><?php
	}
	elseif($type == 7)
	{
		?><hr class="ranglist_hr"><p id="show_quizrating_title">Az idei év összes próbálkozásai</p><br><?php
	}
	else
	{
		?><hr class="ranglist_hr"><p id="show_quizrating_title">Minden próbálkozás listája</p><br><?php
	}
	?>
		<table id="ranglist_table" class="table-hover table-bordered">
		<tr id="ranglist_table_header">
			<td>Helyezés
			<td><a href="quizdetails.php?quiz_id=<?php echo $_GET['quiz_id'] ?>&action_id=<?php echo $_GET['action_id'] ?>&sorting=1&direction=<?php echo $_GET['direction'] ?>#ranglistsanchor">Felhasználó</a>
			<td><a href="quizdetails.php?quiz_id=<?php echo $_GET['quiz_id'] ?>&action_id=<?php echo $_GET['action_id'] ?>&sorting=2&direction=<?php echo $_GET['direction'] ?>#ranglistsanchor">Eredmény</a>
			<td><a href="quizdetails.php?quiz_id=<?php echo $_GET['quiz_id'] ?>&action_id=<?php echo $_GET['action_id'] ?>&sorting=3&direction=<?php echo $_GET['direction'] ?>#ranglistsanchor">Időpont</a>
		<?php
	$res = db_getranglists($type, $_GET['quiz_id'], $_GET['sorting'], $_GET['direction']);
	if(!$res)
	{
		?></table><?php
		die(err_db());
	}
	
	if(mysqli_num_rows($res) == 0)
	{
		echo "<tr><td id='ranglist_table_notfound' colspan='4'>Nincs találat ebben a kategóriában!";
	}
	else
	{
		$deviceType = checkDevice();
		$i=1;
		while($row = mysqli_fetch_assoc($res))
		{
			if($row['user'] == $_SESSION['user'] && $type != 5)
			{
				echo "<tr style='background-color:#FFC107'>\n";
			}
			else
			{
				echo "<tr>\n";	
			}	
			echo "<td id='ranglist_table_rows' class='align-middle' align='left' width='10%' style='padding-left:10px;padding-right:10px;font-weight:bold;'>" . $i++ . ".\n";
			echo "<td id='ranglist_table_rows' class='align-middle' align='center'>" . $row['user'] . "\n";
			if($row['score']>=$row['sikeresseg'])
			{
				echo "<td id='ranglist_table_rows' class='align-middle' align='center' style='padding-top:10px;padding-bottom:10px;'><b>" . $row['score'] . "%</b><hr>" . $row['totalcorrect'] . " / " . $row['num_of_question'] . "\n";
			}
			else
			{
				echo "<td id='ranglist_table_rows' class='align-middle' align='center' style='color:red;padding-top:10px;padding-bottom:10px;'><b>" . $row['score'] . "%</b><hr>" . $row['totalcorrect'] . " / " . $row['num_of_question'] . "\n";
			}
			echo "<td id='ranglist_table_rows' class='align-middle' align='center' width='18%'>" . $row['idopont'] . "\n";
			if($row['accomplished_by'] == $_SESSION['user'])
			{
				echo "<td id='ranglist_table_rows' class='align-middle' align='center' width='15%'>";
				
				if($deviceType != 0)
				{
					?><a id="pdf_button" href='fpdf/topdf.php?test_id=<?php echo $row['test_id']; ?>&test_name=<?php echo rawurlencode($row['temakor']); ?>'><img src="documents/images/pdf.png" style="width:80%"></img></a><?php
				}
				else
				{
					?><button id="pdf_button" onclick="window.open('fpdf/topdf.php?test_id=<?php echo $row['test_id']; ?>&test_name=<?php echo rawurlencode($row['temakor']); ?>', '_blank', 'toolbar=yes,scrollbars=yes,resizable=yes,top=500,left=500,width=screen.availWidth,height=screen.availHeight')"><img src="documents/images/pdf.png" style="width:50%"></img></button><?php
				}
			}
		}
	}
	?></table><?php
}

function show_updatemyquiz()
{
	$res = db_getquizdata_forupdate($_GET['quiz_id']);
	if(!$res){
		die(err_db());
	}
	$row = mysqli_fetch_assoc($res);
	?>
	<a href="upquizsanchor" id="upquizsanchor"></a>
	<hr id='updatequiz_hr'>
	<h4 id="update_myquiz_title">A kvíz adatainak módosítása</h4>
	<div class="d-flex justify-content-center align-items-center">
	<div id='conatiner_div' class="form-row">
	<?php 
	if(mysqli_num_rows($res)==0)
	{
		show_updatequiz_error();
		return;
	}
	if($row['is_request'] == 0 && mysqli_num_rows($res)==1)
	{
	?>
		<form class="was-validated">
			<input type="hidden" id="quizid" value="<?php echo $_GET['quiz_id']; ?>">

		<div class="form-group" style="text-align:left;">
			<label for="kvizelerhetoseg" class='mylabelnames'>A kvíz elérhetősége</label>
			<select id="kvizelerhetoseg" class="form-control" name="kvizelerhetoseg" onchange="showDiv('elerh', this)" onclick="showDivJel('jelszavas', this)">
				<option value="" <?php if($row["access"] == 0) echo "selected"; ?> disabled>Válaszd ki, hogy kik érhetik el a kvízt!</option>
				<option value="1" <?php if($row["access"] == 1) echo "selected"; ?>>Csak én és adminok</option>
				<option value="2" <?php if($row["access"] == 2) echo "selected"; ?>>Én, adminok és az alábbi barátaim</option>
				<option value="5" <?php if($row["access"] == 5) echo "selected"; ?>>Én, adminok és a jelenlegi/ezutáni összes barátom</option>
				<option value="3" <?php if($row["access"] == 3) echo "selected"; ?>>Mindenki</option>
				<?php 
				if(getRang()==true)
				{
					?>
					<option value="4" <?php if($row["access"] == 4) echo "selected"; ?>>Akik ismerik a jelszót</option>
					<?php
				}
			?>
			</select>
			<div id="valid_elerh" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_elerh" class="invalid-feedback">Helytelen adat! Válassz a fenti elérhetőségek közül!</div>

			<div id="elerh" style=<?php if($row["access"] == 2) echo "display:block;"; else echo "display:none;" ?>>
				<?php
				$temp = db_baratLista();
				if($temp==false)
				{
					echo "<span style='color:#DC3545;font-weight:bold;font-size:10pt;'>Jelenleg egy barátod sincs!<br>Választanod kell a többi opció közül!</span>";
				}
				else
				{
					?><span id="select_friendsText">Válaszd ki a barátaidat az alábbi listából!<br><i>(Ctrl billenytűt nyomva tartva kattints a barátaid nevére!)</i></span><br>
					<select id="elerheto_select" name="elerheto[]" multiple>
					<?php
					$res1 = $temp;
					$res2 = db_friends_access_quiz_d($_GET['quiz_id']);
					if(!$res2)
					{
						die(err_db());
					}
					$arr_selected = array();
					while($row2 = mysqli_fetch_assoc($res2))
					{
						array_push($arr_selected, $row2['username']);
					}
					while ($row1 = mysqli_fetch_assoc($res1))
					{	
						if(in_array($row1['nev'], $arr_selected) == 1 )
						{
							echo "<option value=\"" . $row1["azon"] . "\" selected>" . $row1["nev"] . "\n";
						}
						else
						{
							echo "<option value=\"" . $row1["azon"] . "\">" . $row1["nev"] . "\n";
						}
					}
					?></select>
					<span id="quizelerh_msg"></span>
					<?php
				}
				?>
			</div>

			<div id="jelszavas" style=<?php if($row['access'] == 4) echo "display:block;"; else echo "display:none;" ?>>
				<table>
				<tr>
					<td id="pwtext1">Jelszó a teszthez
					<td><input type="password" id="pwt1" name="pass1">
				<tr>
					<td id="pwtext2">Jelszó újra
					<td><input type="password" id="pwt2" name="pass2">	
				</table>
				<div style='width:600px;'><span id="quizpwnew_msg"></span></div>
			</div>
		</div>

		<div class="form-group" style="text-align:left;">
			<label for="numofplaying" class='mylabelnames'>Próbálkozások száma</label>
			<select id="numofplaying" class="form-control" name="numofplaying" required>
				<option value="" <?php if($row["num_of_playing"] < 0) echo "selected"; ?> disabled>Válaszd ki, hány alkalommal lehet lejátszani a kvízt!</option>
				<option value="1" <?php if($row["num_of_playing"] == 1) echo "selected"; ?>>Csak egyszer</option>
				<option value="2" <?php if($row["num_of_playing"] == 2) echo "selected"; ?>>2x</option>
				<option value="3" <?php if($row["num_of_playing"] == 3) echo "selected"; ?>>3x</option>
				<option value="4" <?php if($row["num_of_playing"] == 5) echo "selected"; ?>>5x</option>
				<option value="5" <?php if($row["num_of_playing"] == 10) echo "selected"; ?>>10x</option>
				<option value="6" <?php if($row["num_of_playing"] == 0) echo "selected"; ?>>Korlátlan alkalommal</option>
			</select>
			<div id="valid_alkalmak" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_alkalmak" class="invalid-feedback">Helytelen adat! Válassz a fenti listából egy értéket!</div>
		</div>

		<div class="form-group" style="text-align:left;">
			<label for="kerdfogadas" class='mylabelnames'>Kérdések fogadása</label>
			<select id="kerdfogadas" class="form-control" name="kerdfogadas" onchange="showDiv2('fogadkerd', this)">
				<option value="" <?php if($row["accept_questions"] == 0) echo "selected"; ?> disabled>Válaszd ki, hogy kik küldhetnek be kérdéseket a kvízhez!</option>
				<option value="1" <?php if($row["accept_questions"] == 1) echo "selected"; ?>>Csak én</option>
				<option value="2" <?php if($row["accept_questions"] == 2) echo "selected"; ?>>Én és adminok</option>
				<option value="5" <?php if($row["accept_questions"] == 5) echo "selected"; ?>>Én, adminok és a jelenlegi/ezutáni összes barátom</option>
				<option value="3" <?php if($row["accept_questions"] == 3) echo "selected"; ?>>Én, adminok és az alábbi barátaim</option>
				<option value="4" <?php if($row["accept_questions"] == 4) echo "selected"; ?>>Mindenki</option>
			</select>
			<div id="valid_fogad" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_fogad" class="invalid-feedback">Helytelen adat! Válassz a fenti elérhetőségek közül!</div>
		
			<div id="fogadkerd" style=<?php if($row['accept_questions'] == 3) echo "display:block;"; else echo "display:none;" ?>>
				<?php
				$temp = db_baratLista();
				if($temp == false)
				{
					echo "<span style='color:#DC3545;font-weight:bold;font-size:10pt;'>Jelenleg egy barátod sincs!<br>Választanod kell a többi opció közül!</span>";
				}
				else
				{
					?>
					<span id="select_friendsText">Válaszd ki a barátaidat az alábbi listából!<br> <i>(Ctrl billenytűt nyomva tartva kattints a barátaid nevére!)</i></span></span><br>
					<select id="fogad_select" name="fogad[]" multiple>
					<?php
					$res3 = $temp;
					$res4 = db_friends_sendquestion($_GET['quiz_id']);
					if(!$res4)
					{
						die(err_db());
					}
					$arr1_selected = array();
					while($row4 = mysqli_fetch_assoc($res4))
					{
						array_push($arr1_selected, $row4['username']);
					}
					while ($row3 = mysqli_fetch_assoc($res3))
					{	
						if(in_array($row3['nev'], $arr1_selected) == 1 )
						{
							echo "<option value=\"" . $row3["azon"] . "\" selected>" . $row3["nev"] . "\n";
						}
						else
						{
							echo "<option value=\"" . $row3["azon"] . "\">" . $row3["nev"] . "\n";
						}
					}
					?></select>
					<span id="quizkerdbekuld_msg"></span><?php
				}
				?>
			</div>
		</div>
		
		<div class="form-group" style="text-align:left;">
			<label for="startd" class='mylabelnames'>Időkorlát (kezdés és befejezés dátuma)</label>
			<div class='form-inline'>
				<input type="date" id="startd" class="form-control" name="startd" value="<?php if (!empty($row['start_date'])) echo $row["start_date"]; ?>">
				<input type="date" id="endd" class="form-control" name="endd" value="<?php if (!empty($row['end_date'])) echo $row["end_date"]; ?>">
			</div>
		</div>
		
		<div class="form-group" style="text-align:left;">
			<label for="verifytest" class='mylabelnames'>Ellenőrzések száma</label>
			<input type="text" id="verifycurrent" class="form-control" name="verifycurrent" maxlength="6" placeholder="Hányszor lehet visszanézni és exportálni a kvízt eredményét?" value="<?php echo $row["verification"]; ?>" pattern="^([1-9][0-9]{0,5}|[0])$" required>
			<div id="valid_ell" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_ell" class="invalid-feedback">Helytelen adat! Minimum 0 és legfeljebb 100000 értéket fogadunk el!</div>
		</div>

		<?php
		if(!empty($row['password']))
		{
			?>
			<div class="form-group" style="text-align:left;">
				<label for="pwtcurrent" class='mylabelnames'>A teszt jelenlegi jelszava</label>
				<input type="password" id="pwtcurrent" class="form-control" name="passcurrent" placeholder="Add meg a teszt jelenlegi jelszavát!" required>
				<div id="valid_ell" class="valid-feedback">Helyesen kitöltve!</div>
				<div id="invalid_ell" class="invalid-feedback">Helytelen adat! Nem írtad be a teszt jelszavát!</div>
			</div>
			<?php
		}
		?>
		
		<div class="form-group" style="text-align:left;">
			<label for="mypasscurrent" class='mylabelnames'>A fiókod jelszava</label>
			<input type="password" id="mypasscurrent" class="form-control" name="mypasscurrent" placeholder="Írd be a bejelentkezéskor használt jelszavadat!" minlength="6" required>
			<div id="valid_ell" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_ell" class="invalid-feedback">Helytelen adat! Nem írtad be a fiókod jelszavát, ami legalább 6 karakterből kell álljon!</div>
		</div>

		<button type="button" class="btn btn-primary" name="sendQuizUpdate" onclick='updateMyQuiz()'>Módosítások mentése</button>

		</form>
		<?php
		}
		else
		{
			show_updatequiz_error();
		}
		?>
	</div>
	</div>
	<?php
}

function show_backgrounds()
{
	$deviceType = checkDevice();
	$data = '';
	$res = db_getbackgrounds($_GET['quiz_id']);
	if(!$res)
	{
		die(err_db());
	}
	if(mysqli_num_rows($res)<1)
	{
		$data .= "Még nem küldtél be háttérképet a kvízhez!";
		view_bgimages(0, $data);
	}
	else
	{
		while($row = mysqli_fetch_assoc($res))
		{
			if($row['active'] == 1)
			{
				$row['active'] = "<span id='active_span'>Aktív</span>";
			}
			else
			{
				$row['active'] = "<span id='inactive_span'>Nincs ellenőrizve!</span>";
			}
			$data .= "<tr style='text-align:center;'>";
			$data .= "<td width='70%' height='100px'>" . "<img src=" . $row['image_path'] . " width='90%' alt='Nem sikerült betölteni a képet!'></img>" . "</td>";
			if($deviceType != 0)
			{
				$data .= "<td style='font-size:17px;'>" . $row['active'] . "<br><br><b>Feltöltve:</b> " . $row['posting_time'] . "-kor<br><hr>" . "<a href=" . $row['image_path'] . " target='_SELF'><b>Megtekintés</b></a>" . "<br><br><button id='delete_mybgimg' class='btn btn-danger' onclick='delete_mybgimg(" . $row['id'] . ")'>Törlés</button>\n";
			}
			else
			{
				$data .= "<td style='font-size:17px;'>" . $row['active'] . "<br><br><b>Feltöltve:</b> " . $row['posting_time'] . "-kor<br><hr>" . "<a href=" . $row['image_path'] . " target='_BLANK'><b>Megtekintés</b></a>" . "<br><br><button id='delete_mybgimg' class='btn btn-danger' onclick='delete_mybgimg(" . $row['id'] . ")'>Törlés</button>\n";
			}
			
		}
		view_bgimages(1, $data);
	}
}

function show_various()
{
	if($_GET['action_id'] == 2)
	{
		show_ranglists(2);
	}
	elseif($_GET['action_id'] == 3)
	{
		show_ranglists(3);
	}
	elseif($_GET['action_id'] == 4)
	{
		show_ranglists(4);
	}
	elseif($_GET['action_id'] == 5)
	{
		show_ranglists(5);
	}
	elseif($_GET['action_id'] == 7)
	{
		show_ranglists(7);
	}
	elseif($_GET['action_id'] == 6)
	{
		global $isownquiz;
		if($isownquiz == true)
		{
			show_updatemyquiz();	
		}
	}
	elseif($_GET['action_id'] == 8)
	{
		global $isownquiz;
		if($isownquiz == true)
		{
			show_backgrounds();	
		}
	}
	else
	{
		show_likes();
		show_comment();
		show_commentsection_base();
	}
}

?>
<!DOCTYPE html>
<html>
<head>
	<title>Kvíz részletek</title>
	<meta charset="utf-8">
	<noscript>
		<meta http-equiv="refresh" content="0; url=includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/quizdetails.css" />
	<link rel="stylesheet" type="text/css" href="css/menu.css" />
	<link rel="stylesheet" href="includes/jQuery-ui.css">
	<link rel="stylesheet" href="includes/bootstrap.min.js.4.6.1.css"> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery.js"></script>
	<script type = "text/javascript" src="includes/popper.min.1.16.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/bootstrap.bundle.min.4.6.1.js"></script> <!-- B -->
	<script type = "text/javascript" src="includes/jQuery-ui.js"></script>
	<script type = "text/javascript" src="js/quizdetails.js"></script>
	<script type = "text/javascript" src="js/menu.js"></script>
</head>
<body>
<?php
main_menu();

if(!isset($_GET['quiz_id']) || !preg_match("/^[0-9]+$/", $_GET['quiz_id']) || $_GET['quiz_id'] < 1)
{
	$_GET['quiz_id'] = 0;
}
if(!isset($_GET['action_id']) || !preg_match("/^[0-9]+$/", $_GET['action_id']) || $_GET['action_id'] < 1)
{
	$_GET['action_id'] = 1;
}
if(!isset($_GET['sorting']) || !preg_match("/^[0-9]+$/", $_GET['sorting']) || $_GET['sorting'] < 1)
{
	$_GET['sorting'] = 2;
}
if(!isset($_GET['direction']) || !preg_match("/^[0-9]+$/", $_GET['direction']) || $_GET['direction'] < 1 || $_GET['direction'] > 2)
{
	$_GET['direction'] = 1;
}

if($_GET['direction'] == 1)
{
	$_GET['direction'] = 2;
}
elseif($_GET['direction'] == 2)
{
	$_GET['direction'] = 1;
}
global $quizdata;
if($quizdata != false)
{
	?>
	<div id="main_div">
		<div id="data_div" align="center">
		<?php
		all_quizdata();
		show_startbutton();
		?>
		</div>
		
		<div id="various_div" align="center">
		<?php
		show_various();
		?>
		</div>
	</div>
	<?php
}
else
{
	show_errquiz_notfound();
}
?>
</body>
</html>