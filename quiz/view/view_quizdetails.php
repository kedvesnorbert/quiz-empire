<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function view_startquiz_btn($id_number, $quiz_name, $time_to_answer, $num_of_question, $access, $quiz_id)
{
    ?><center>
    <button id="startQuizFromDetails" class="btn btn-success" onclick='show_beforestartquiz_det("<?php echo $id_number ?>", "<?php echo $quiz_name ?>", "<?php echo $time_to_answer ?>", "<?php echo $num_of_question ?>", "<?php echo $access ?>", "<?php echo 1 ?>", "<?php echo "" ?>", "<?php echo 0 ?>", "<?php echo 0 ?>", "<?php echo $quiz_id ?>")'>KVÍZ INDÍTÁSA</button></center><br>
	<div id="dialogBeforeStartQuizDet" title="Kvíz indítása" style="display:none;"></div>
    <?php
}

function view_quizdetails_minimenu($id, $updatequiz, $actionid)
{
    ?>
    <form action="quizdetails.php" method="GET">
    <ul id="minimenu_nav" class="nav">
        <li class="nav-item">
        <a id="minimenu_nav" class="nav-link" href="quizdetails.php?quiz_id=<?php echo $id ?>&action_id=1">Általános</a>
        </li>
        <li class="nav-item dropdown">
            <a id="minimenu_nav" class="nav-link dropdown-toggle" data-toggle="dropdown" style="margin-left:10px;">Ranglisták</a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href="quizdetails.php?quiz_id=<?php echo $id ?>&action_id=2&sorting=2&direction=1#ranglistsanchor">A mai napi ranglista</a>
                <a class="dropdown-item" href="quizdetails.php?quiz_id=<?php echo $id ?>&action_id=3&sorting=2&direction=1#ranglistsanchor">Legelső próbálkozások</a>
                <a class="dropdown-item" href="quizdetails.php?quiz_id=<?php echo $id ?>&action_id=4&sorting=2&direction=1#ranglistsanchor">Összes próbálkozás</a>
                <a class="dropdown-item" href="quizdetails.php?quiz_id=<?php echo $id ?>&action_id=5&sorting=2&direction=1#ranglistsanchor">Saját összes próbálkozás</a>
                <a class="dropdown-item" href="quizdetails.php?quiz_id=<?php echo $id ?>&action_id=7&sorting=2&direction=1#ranglistsanchor">Az idei év összes játszmái</a>
            </div>
        </li>
        <?php
        if($updatequiz == true)
		{
			?>
            <li class="nav-item">
                <a id="minimenu_nav" class="nav-link" href="quizdetails.php?quiz_id=<?php echo $id ?>&action_id=6#upquizsanchor">Módosítás</a>
            </li>
            <li class="nav-item dropdown">
                <a id="minimenu_nav" class="nav-link dropdown-toggle" data-toggle="dropdown" style="margin-left:10px;">Háttérképek</a>
                <div class="dropdown-menu">
                    <a class="dropdown-item" onclick='new_background("<?php echo $id ?>", "<?php echo $actionid ?>")'>Új háttérkép</a>
                    <div id="dialogAddNewBackground" title="Új háttérkép feltöltése" style="display:none;"></div>
                    <div id="dialogAddNewBackgroundAlert" title="Info" style="display:none;"></div>
                    <a class="dropdown-item" href="quizdetails.php?quiz_id=<?php echo $id ?>&action_id=8#backgroundanchor">Háttérképek listázása</a>
                </div>
            </li>
			<?php
		}
        ?>
    </ul>
    </form>
    <?php
}

function view_doing_rating()
{
    ?><br>
    <span class="star_rated" onclick="rat1(<?php echo $_GET['quiz_id'] ?>, 1)">&#x2605;</span>
    <span class="star_rated" onclick="rat1(<?php echo $_GET['quiz_id'] ?>, 2)">&#x2605;</span>
    <span class="star_rated" onclick="rat1(<?php echo $_GET['quiz_id'] ?>, 3)">&#x2605;</span>
    <span class="star_rated" onclick="rat1(<?php echo $_GET['quiz_id'] ?>, 4)">&#x2605;</span>
    <span class="star_rated" onclick="rat1(<?php echo $_GET['quiz_id'] ?>, 5)">&#x2605;</span>
    <?php
}

function view_quizdata($quiz_name, $num_of_question, $num_of_playing, $time_to_answer, $accessquiz, $pass_degree, $accept_questions, $language, $quiz_uploader, $start_date, $verification, $end_date, $avg_rating, $own_rating, $show_answers, $accomplish_date, $quiz_description, $questions_by_users)
{
    ?>
    <h2 id="quiztitle"><?php echo $quiz_name ?></h2>
	<table id="quizdetailstable" class="table justify-content-center align-items-center">
		<tr>
			<td class="detailstable_td_left1">Kérdések:
			<td class="detailstable_td_right1"><?php echo $num_of_question ?>
			<td class="detailstable_td_left2">Próbálkozás: 
			<td class="detailstable_td_right2"><?php echo $num_of_playing ?> alkalom
		<tr>
			<td class="detailstable_td_left1">Idő:
			<td class="detailstable_td_right1"><?php echo $time_to_answer; ?> mp/kérdés
			<td class="detailstable_td_left2">Elérhetőség:
			<td class="detailstable_td_right2"><?php echo $accessquiz ?>
		<tr>
			<td class="detailstable_td_left1">Átmenő:
			<td class="detailstable_td_right1"><?php echo $pass_degree ?>%
			<td class="detailstable_td_left2">Kérdések beküldése:
			<td class="detailstable_td_right2"> <?php echo $accept_questions ?>
		<tr>
			<td class="detailstable_td_left1">Nyelv:
			<td class="detailstable_td_right1"><?php echo $language ?>
			<td class="detailstable_td_left2">Feltöltő:
			<td class="detailstable_td_right2"><?php echo $quiz_uploader ?>
        <tr>
			<td class="detailstable_td_left1">Indulás ideje:
			<td class="detailstable_td_right1"><?php echo $start_date ?>
			<td class="detailstable_td_left2">Ellenőrizhető:
			<td class="detailstable_td_right2"><?php echo $verification ?> alkalommal
		<tr>
			<td class="detailstable_td_left1">Lezárulás ideje:
			<td class="detailstable_td_right1"><?php echo $end_date ?>
			<td class="detailstable_td_left2">Értékelés:
			<td class="detailstable_td_right2"><?php echo $avg_rating; 
            if(strlen($own_rating)==0)
            {
                ;
            }
            elseif($own_rating == "need")
            {
                view_doing_rating();
            }
            else
            {
                echo $own_rating;
            } ?>
        <tr>
			<td class="detailstable_td_left1">Helyes válaszok:
			<td class="detailstable_td_right1"><?php echo $show_answers ?>
			<td class="detailstable_td_left2">Feltöltés ideje:
			<td class="detailstable_td_right2"><?php echo $accomplish_date ?>
        <tr>
			<td colspan="4" style="font-size:13pt;"><b>Leírás:</b> <?php echo $quiz_description . $questions_by_users ?>
    </table> 
    <?php
}

function view_quizlikes($data, $like_btn)
{
    ?>
    <div id="container_likes">
        <p id="likes_title">Akik kedvelik a kvízt</p>
        <div id="likes_div">
            <?php
            echo $data;
            ?>
        </div>
        <div id='like_btndiv'>
            <?php echo $like_btn ?>
        </div>
    </div>
    <?php
}

function view_leave_comment($id)
{
    ?>
    <div id="comment_div">
		<p id="comment_title">Hozzászólás írása</p>
        <textarea id="textarea_input" class="form-control" name="mycomment" maxlength="1500" placeholder="Szólj hozzá te is!" required></textarea><br>
        <input type="hidden" id="commented_quizid" value="<?php echo $id ?>">
        <button id="send_comment" class="btn btn-light" onclick="leave_comment()">MEHET</button>
        <div id="loading_commentdiv" style="display:none;">
            <img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="2%">
        </div>
	</div>
    <?php
}

function view_forbidden_leaving_comment($id)
{
    ?>
    <div id="comment_div">
        <input type="hidden" id="commented_quizid" value="<?php echo $id ?>">
		<p id="comment_title">Hozzászólás írása</p>
		<p id="comment_not_allowed"><br>Vegyél részt a kvízen legalább egyszer, hogy Te is írhass hozzászólást!</p>
    </div>
    <?php
}

function show_commentsection_base()
{
	?>
	<p id="commentsection_title">Hozzászólások</p>
	<p id="no_comment_text_">Ehhez a kvízhez még senki nem írt hozzászólást!</p>
    <div id="first_one_commentdiv"></div>
	<?php
}

function view_commentsection($id, $commenter, $commenttime, $comment_text, $moderation, $owncomment, $encoded_comment, $quizid)
{
    ?>
    <div id="one_commentdiv">
        <input type="hidden" id="commented_quizid" value="<?php echo $id ?>">
        <table border="0" width="100%">
            <tr>
            <td id="one_comment_username"><i>Írta: </i><?php echo $commenter ?></td>
            <td id="one_comment_date"><?php echo "Időpont: " . $commenttime ?></td>
            <tr>
            <td id="one_comment_fulltext" colspan="2"><?php echo $comment_text; ?></td>
            <tr>
            <td id="one_comment_moderation" colspan="2"><?php echo $moderation; ?></td>
            <tr>
            <?php 
            if($owncomment == "1")
            {
                ?>
                <td id="one_comment_settings" colspan="2">
                <button class='btn btn-light' onclick='show_deldialog("<?php echo $encoded_comment ?>", "<?php echo $commenttime ?>", "<?php echo $quizid ?>")'>Törlés</button>
                </td>
                <div id="dialogDelMyComment" title="Hozzászólás törlése" style="display:none;"></div>
                <?php
            }
        ?>
        </table>
    </div>
    <?php
}

function view_bgimages($data_bool, $data)
{
    ?><a href="backgroundanchor" id="backgroundanchor"></a>
    <hr class='bgimagelist_hr'><h4>Beküldött háttérképek</h4><br><br>
    <?php
    if($data_bool == 0)
    {
        echo "<span id='no_bgimage_span'>" . $data . "</span>";
    }
    else
    {
        ?>
        <table id='bgimage_table' class='table-bordered'>
            <tr style="height:45px;text-align:center;font-size:17px;">
                <th>Kép
                <th>Info / Műveletek
            <?php echo $data; ?>
        </table>
        <?php
    }
}

function show_updatequiz_error()
{
	?>
	<div align="center">
		<img src="documents/images/warning.png" align="center" width="7%"><br>
        <span id='updatequiz_err_span'>Hiba!<br>Kérésre teljesített kvízeket nincs jogod módosítani!</span><br><br>
	</div>
	<?php
}

function show_errquiz_notfound()
{
	?><div align="center"><p id="errNotFound"><br><img src="documents/images/warning.png" align="center" width="7%"><br>
        Hiba!<br>A kvíz nem található!<br><br>
        <button class="btn btn-link"><u><a href="quizzes.php" style="color:black;">Vissza a kvízek böngészéséhez</button></a></u>
     </p></div>
	<?php
}

?>