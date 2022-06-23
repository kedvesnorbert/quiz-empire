<?php
session_start();
require_once("db/db_connect.php");
require_once("db/db_allquizdetail.php");
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

function show_quiznotfound()
{
    ?>
    <div id='error_div'>
        <img src='../documents/images/warning.png' width='7%'><br>
        Hibás kvízazonosító!<br>Csak 3. fázisban lévő kvízeknek lehet megtekinteni a részleteit.
    </div>
    <?php
}

function show_submenu()
{
    ?>
    <div id='submenu'>
    <button id='general' class='submenu_class' onclick='window.location.href="allquizdetail.php?quiz_id=<?php echo $_GET["quiz_id"];?>&action_id=1"'>Általános</button>
    <button id='ranglist' class='submenu_class' onclick='window.location.href="allquizdetail.php?quiz_id=<?php echo $_GET["quiz_id"];?>&action_id=2"'>Ranglisták</button>
    <button id='comment' class='submenu_class' onclick='window.location.href="allquizdetail.php?quiz_id=<?php echo $_GET["quiz_id"];?>&action_id=3"'>Hozzászólások</button>
    <button id='background' class='submenu_class' onclick='window.location.href="allquizdetail.php?quiz_id=<?php echo $_GET["quiz_id"];?>&action_id=4"'>Háttérképek</button>
    <button id='question' class='submenu_class' onclick='window.location.href="allquizdetail.php?quiz_id=<?php echo $_GET["quiz_id"];?>&action_id=5"'>Kvízkérdések</button>
    </div>
    <?php
}

function show_title()
{
    $res = db_getquiz_main_data($_GET['quiz_id']);
    if(!$res || mysqli_num_rows($res)< 1)
    {
        die(show_quiznotfound());
    }
    $row = mysqli_fetch_assoc($res);
    if($row['language'] == 1)
    {
        $row['language'] = "Magyar";
    }
    elseif($row['language'] == 2)
    {
        $row['language'] = "Angol";
    }
    ?>
    <div id='title_div'>
        <p id='quiz_title'><?php echo $row['quiz_name']; ?></p><br>
        <p id='quiz_lang_sender'><?php echo "( " . $row['language'] . " nyelvű kvíz, beküldte: " . $row['accomplished_by'] . " )"; ?></p>
    </div>
    <?php
}

function show_quizdata()
{
    $res = db_getquizdata($_GET['quiz_id']);
    if(!$res || mysqli_num_rows($res)< 1)
    {
        die(err_db());
    }
    $row = mysqli_fetch_assoc($res);
    $is_deleted = $row['is_deleted'];
    if($is_deleted == 0)
    {
        $is_deleted = "<b><font color='green'>Aktív kvíz</font></b>";
    }
    else
    {
        $is_deleted = "<b><font color='red'>Törölt kvíz</font></b>";
    }

    $is_request = $row['is_request'];
    if($is_request == 0)
    {
        $is_request = " ( <i><font color='green'>Saját kvíz</font></i> ) ";
    }
    else
    {
        $is_request = " ( <i><font color='red'>Kérésre teljesített kvíz</font></i> ) ";
    }

    if($row['show_answers'] == 1)
	{
		$row['show_answers'] = 'A helyes válaszokat megmutatjuk.';
	}
	else
	{
		$row['show_answers'] = 'A helyes válaszokat nem mutatjuk meg.';
	}

    if($row['access'] == 1)
    {
        $row['access'] = 'Csak ' . $row['accomplished_by'];
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
        $row['access'] = $row['accomplished_by'] . ', az adminok és az alább felsorolt felhasználók: ';
        while($row1 = mysqli_fetch_array($res1))
        {
            $row['access'] .= "<a href='userdetails.php?profil_id=" . $row1['id'] . "'>" . $row1['username'] . "</a>";
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
        $res1 = db_userfriends($row['accomplish_userid']);
        if(!$res1)
        {
            die(err_db());
        }
        $num_rows = mysqli_num_rows($res1);
        $counter = 1;
        $row['access'] = $row['accomplished_by'] . ', az adminok és az összes barátja: ';
        while($row1 = mysqli_fetch_array($res1))
        {
            $row['access'] .= "<a href='userdetails.php?profil_id=" . $row1['azon'] . "'>" . $row1['nev'] . "</a>";
            if($counter < $num_rows)
            {
                $row['access'] .= ", ";
            }
            ++$counter;
        }
    }

    if($row['accept_questions'] == 1)
    {
        $row['accept_questions'] = 'Csak '. $row['accomplished_by'];
    }
    elseif($row['accept_questions'] == 2)
    {
        $row['accept_questions'] = 'Csak '. $row['accomplished_by'] . ' és az adminok';
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
        $row['accept_questions'] = $row['accomplished_by'] . ', adminok és az alább felsorolt felhasználók: ';
        while($row2 = mysqli_fetch_assoc($res2))
        {
            $row['accept_questions'] .= "<a href='userdetails.php?profil_id=" . $row2['id'] . "'>" . $row2['username'] . "</a>";
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
        $res2 = db_userfriends($row['accomplish_userid']);
        if(!$res2)
        {
            die(err_db());
        }
        $num_rows2 = mysqli_num_rows($res2);
        $counter2 = 1;
        $row['accept_questions'] = $row['accomplished_by'] . ', adminok és az alább felsorolt felhasználók: ';
        while($row2 = mysqli_fetch_assoc($res2))
        {
            $row['accept_questions'] .= "<a href='userdetails.php?profil_id=" . $row2['azon'] . "'>" . $row2['nev'] . "</a>";
            if($counter2 < $num_rows2)
            {
                $row['accept_questions'] .= ", ";
            }
            ++$counter2;
        }
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

    if($row['show_answers'] == 1)
    {
        $row['show_answers'] = "Engedélyzeve";
    }
    else
    {
        $row['show_answers'] = "Nincs engedélyezve";
    }


    ?>
    <div id='quizdata_container'>
        <div id='quizdata_information'>
        <p class='quizdata_data'><?php echo $is_deleted; echo $is_request; ?></p>
        <span class='quizdata_info'>Kérés ideje: </span><span class='quizdata_data'><?php echo $row['request_date'] . " ( " . "<a href='userdetails.php?profil_id=" . $row['requestedby_id'] . "'>" . $row['requested_by'] . "</a>" . " által )"; ?></span><br>
        <span class='quizdata_info'>Aktíválás ideje: </span><span class='quizdata_data'><?php echo $row['accomplish_date']; ?></span><hr>
        <span class='quizdata_info'>Kérdések: </span><span class='quizdata_data'><?php echo $row['num_of_question'] . " db"; ?></span><br>
        <span class='quizdata_info'>Válaszolási idő: </span><span class='quizdata_data'><?php echo $row['time_to_answer'] . " mp"; ?></span><br>
        <span class='quizdata_info'>Átmenő: </span><span class='quizdata_data'><?php echo $row['pass_degree'] . "%"; ?></span><br>
        <span class='quizdata_info'>Összes próbálkozás: </span><span class='quizdata_data'><?php echo $row['num_of_playing'] . " alkalommal"; ?></span><br>
        <span class='quizdata_info'>Elérhetőség: </span><span class='quizdata_data'><?php echo $row['access']; ?></span><br>
        <span class='quizdata_info'>Kérdések beküldése: </span><span class='quizdata_data'><?php echo $row['accept_questions']; ?></span><br>
        <span class='quizdata_info'>Indulás ideje: </span><span class='quizdata_data'><?php echo $row['start_date']; ?></span><br>
        <span class='quizdata_info'>Lezárulás ideje: </span><span class='quizdata_data'><?php echo $row['end_date']; ?></span><br>
        <span class='quizdata_info'>Ellenőrizhető: </span><span class='quizdata_data'><?php echo $row['verification'] . " alkalommal"; ?></span><br>
        <span class='quizdata_info'>Helyes válaszok mutatása: </span><span class='quizdata_data'><?php echo $row['show_answers']; ?></span><br>
        </div>
    
        
    <div id='quizdata_statistics'>
        <p id='title_statistics'>Statisztikai adatok</p>
        <span class='quizdata_info'>Lejátszva: </span><span class='quizdata_data'><?php echo $row['quizplayed'] . " alkalommal"; ?></span><br>
        <span class='quizdata_info'>Legutolsó játszma: </span><span class='quizdata_data'><?php echo $row['lastplayedquiz']; ?></span><br>
        <span class='quizdata_info'>Kedvencek között szerepel: </span><span class='quizdata_data'><?php echo $row['favoritequiz'] . "x"; ?></span><br>
        <span class='quizdata_info'>Kedvelések száma: </span><span class='quizdata_data'><?php echo $row['quizlike'] . " db"; ?></span><br>
        <span class='quizdata_info'>Értékelés: </span><span class='quizdata_data'><?php echo number_format((float)$row['quizrating'], 2, '.', '') ?></span><br>
        <span class='quizdata_info'>Háttérképek száma: </span><span class='quizdata_data'><?php echo $row['backgrounds'] . " db"; ?></span><br>
        <span class='quizdata_info'>Aktív kérdések száma: </span><span class='quizdata_data'><?php echo $row['allactivequestion'] . " db"; ?></span><br>
        <span class='quizdata_info'>Hozzászólások száma: </span><span class='quizdata_data'><?php echo $row['quizcomments'] . " db"; ?></span><br>
    </div>
    </div>

    <span class='quizdata_info'>Leírás</span><p class='quizdata_data'><?php echo nl2br(htmlentities($row['description'])); ?></p>
    <span class='quizdata_info'>Létrehozás oka: </span><span class='quizdata_data'><?php echo $row['reason']; ?></span>
    <?php
}

function show_likes()
{
	?>
	<div id="likes_div">
	<?php
	$res = db_quizlikes($_GET['quiz_id']);
	if(!$res)
	{
		die(err_db());
	}
	$sorok = mysqli_num_rows($res);
	$i = 1;
	echo '<p id="likes_text">';
	if($sorok == 0)
	{
		echo '<p id="no_likes_text">Még senki sem kedvelte ezt a kvízt!</p>';
	}
	else
	{
		echo '<p id="likes_title">Akik kedvelik a kvízt</p>';
        while($row = mysqli_fetch_assoc($res))
		{
			?><a href="userdetails.php?profil_id=<?php echo $row['userid'] ?>"><?php echo $row['username']; ?></a> <?php
			if($i < $sorok)
			{
				echo ", ";
			}
			++$i;
		}
		echo '</p>';
	}
	?>
	</div><?php
}

function show_playedquizzes()
{
    ?>
    <iframe src="quizresults.php?quizcategory=<?php echo $_GET['quiz_id']; ?>&where_searchresult=1&result_order=2&result_dir=2&search_for_result=MEHET" width="100%" height="1000px" style="border:none;"></iframe>
    <?php
}

function show_comments()
{
    ?>
    <iframe src="quizcomments.php?quizcategory=<?php echo $_GET['quiz_id']; ?>&where_searchresult=3&is_deletedcomment=0&result_order=1&result_dir=2&search_for_comment=MEHET" width="100%" height="1000px" style="border:none;"></iframe>
    <?php
}

function show_backgrounds()
{
    ?>
    <iframe src="backgrounds.php?quizcategory=<?php echo $_GET['quiz_id']; ?>&where_searchresult=2&result_order=1&result_dir=2&search_for_background=MEHET" width="100%" height="1000px" style="border:none;"></iframe>
    <?php
}

function show_questions()
{
    ?>
    <iframe src="questions.php?quizcategory=<?php echo $_GET['quiz_id']; ?>&where_searchresult=1&search_in=1&q_diff=3&q_activity=1&result_order=2&result_dir=1&search_for_question=MEHET" width="100%" height="1000px" style="border:none;"></iframe>
    <?php
}

?>
<html>
<head>
	<title>Kvíz részletei</title>
	<meta charset="utf-8">
    <noscript>
		<meta http-equiv="refresh" content="0; url=../includes/enablejavascript.html">
	</noscript>
	<link rel="stylesheet" type="text/css" href="css/allquizdetail.css" />
	<link rel="stylesheet" href="../includes/jQuery-ui.css">
	<script type = "text/javascript" src="../includes/jQuery.js"></script>
	<script type = "text/javascript" src="../includes/jQuery-ui.js"></script>
</head>
<body>
<p id="p_title"></p>
<?php
if(!isset($_GET['quiz_id']) || !preg_match("/^[0-9]+$/", $_GET['quiz_id']) || $_GET['quiz_id'] < 1)
{
	$_GET['quiz_id'] = 0;
}
if(!isset($_GET['action_id']) || !preg_match("/^[0-9]+$/", $_GET['action_id']) || $_GET['action_id'] < 1)
{
	$_GET['action_id'] = 1;
}

show_title();
show_submenu();

if($_GET['action_id'] == 5)
{
    show_questions();
}
elseif($_GET['action_id'] == 4)
{
    show_backgrounds();
}
elseif($_GET['action_id'] == 3)
{
    show_comments();
}
elseif($_GET['action_id'] == 2)
{
    show_playedquizzes();
}
else
{
    show_quizdata();
    show_likes();
}
?>
</body>
</html>