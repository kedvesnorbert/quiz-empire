<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function show_quizquestion_data($id, $question)
{
    ?>
    <div id="asd">
	<table id="quizTableCount">
	<tr>
		<td style='width:25%'><b>Kérdés: <?php echo $_SESSION['numberofquestion'] . " / " . $_SESSION['num_of_question']; ?></b>
		
		<td id="quiz_time_header" style='text-align:right;width:55%'><b><span id='ido_next'>Hátramaradt idő: </span><span id="count"><?php echo $_SESSION['time_to_answer'] ?></span> mp</b>
	</table>

	<table id="quizTable">  
	<tr>
		<td><button type="button" name="gy" class = "butt" disabled><?=$question?></button>
	<form action="quizgame.php" method ="POST" id="my_form">
	<tr>
		<td>
		<button name="btn1" class="butn" id="bt1" value="<?php echo $_SESSION['valaszok_shuff'][0]; ?>" onclick='<?php if($_SESSION['show_answers'] == 1) echo 'validateMyForm1()'; else echo 'validateMyForm1_B()';?>'><?=$_SESSION['valaszok_shuff'][0]?></button><br>
	<tr>
		<td>
		<button name="btn2" class="butn" id="bt2" value="<?php echo $_SESSION['valaszok_shuff'][1]; ?>" onclick='<?php if($_SESSION['show_answers'] == 1) echo 'validateMyForm2()'; else echo 'validateMyForm2_B()';?>'><?=$_SESSION['valaszok_shuff'][1]?></button><br>
	<tr>
		<td>
		<button name="btn3" class="butn" id="bt3" value="<?php echo $_SESSION['valaszok_shuff'][2]; ?>" onclick='<?php if($_SESSION['show_answers'] == 1) echo 'validateMyForm3()'; else echo 'validateMyForm3_B()';?>'><?=$_SESSION['valaszok_shuff'][2]?></button><br>
	<tr>
		<td>
		<button name="btn4" class="butn" id="bt4" value="<?php echo $_SESSION['valaszok_shuff'][3]; ?>" onclick='<?php if($_SESSION['show_answers'] == 1) echo 'validateMyForm4()'; else echo 'validateMyForm4_B()';?>'><?=$_SESSION['valaszok_shuff'][3]?></button>
	</form>
	</table>
	<div align='right'><button id='exitbtn' onclick='stop_playing()'>Kilépés a kvízből</button></div>
	<div id='dialogLeaveQuiz' title="Kvíz elhagyása" style="display:none;">Biztos, hogy kilépsz a kvízből?<br>
	Minden eddigi eredményed el fog veszni!</div>
	</div>
    <?php
}

function show_quizresult($res)
{
    if(!$res)
    {
        die(mysqli_connect_error());
    }
    $row = mysqli_fetch_assoc($res);    
    ?>
    ?><br>
    <table id="jatekTable" border="1">
        <tr id="totalcorrJatekTable">
            <td colspan="2">Eredmény: <?php echo $_SESSION['totalcorrect'] . " / " . $_SESSION['num_of_question']; ?>
    
    <tr id="cimJatekTable">
        <td colspan="2"><?php if($row['score'] >= $_SESSION['teszt_sikeresseg']) 
        { 
            echo "<b><font color='green'>SIKERES TESZT! ( " . $row['score'] . " % )</font></b>";
        } 
        else 
        { 
            echo "<font color='red'>Sikertelen teszt! ( " . $row['score'] . " % )</font>";
            $_SESSION['totalcorrect'] = 0;
        } ?><br>
    <tr id="meritPoints">
        <td style='padding-left:10px;'><br>Kiérdemelt pontok:
        <td style='padding-left:5px;'><br><?php echo $_SESSION['totalcorrect'] . " pont"; ?>
    <tr id="bonusPoints">
        <td style='padding-left:10px;'><br>Bónusz pontok:
        <td style='padding-left:5px;'><br><?php echo $row['result'] - $_SESSION['totalcorrect'] . " pont"; ?>
    <tr id="totalPoints">
        <td style='padding-left:10px;'><br>Összesen:
        <td style='padding-left:5px;'><br><?php echo $row['result'] . " pont"; ?>
    <tr>
        <td colspan="2">
    <?php
}

function show_competitionresult($res)
{
    if(!$res)
    {
        die(mysqli_connect_error());
    }
    $row = mysqli_fetch_assoc($res);
    ?><br>
    <table id="jatekTable" border="1">
        <tr id="totalcorrJatekTable">
            <td colspan="2">Eredmény: <?php echo $_SESSION['totalcorrect'] . " / " . $_SESSION['num_of_question']; ?>
    
    <tr id="cimJatekTable">
        <td colspan="2"><?php if($row['score'] >= $_SESSION['teszt_sikeresseg']) 
        { 
            echo "<b><font color='green'> " . $row['score'] . "% / 100%</font></b>";
        } 
        else 
        { 
            echo "<font color='red'>" . $row['score'] . "% / 100%</font>";
        } ?><br>
    <tr id="bonusPoints">
        <td style='padding-left:10px;'><br>Bónusz pontok:
        <td style='padding-left:5px;'><br><?php echo $row['result'] . " pont"; ?>
    <tr id="totalPoints">
        <td style='padding-left:10px;'><br>Összesen:
        <td style='padding-left:5px;'><br><?php echo $row['result'] . " pont"; ?>
    <tr>
        <td colspan="2">
    <?php
}

function show_no_quiz()
{
    ?><table align="center" border="1" width = "30%" bgcolor="white">
    <tr>
        <td><center>
    <?php echo "<br>Nem maradt több megválaszolandó kérdés.<br>A kvíz véget ért!"; 
    if(!isset($_SESSION['pageQuiz']) || !isset($_SESSION['nameOfQuiz']) || !isset($_SESSION['langOfQuiz']) || !isset($_SESSION['whereSearchQuiz']) || !isset($_SESSION['fromcurrentquiz']))
    {
        ?>
        <meta http-equiv="refresh" content="0;url=index.php"/><?php
        ?><center><h3>Redirecting in 1 seconds...</h3></center><?php
    }
    elseif($_SESSION['fromcurrentquiz']>0)
    {
        ?>
        <meta http-equiv="refresh" content="0;url=quizdetails.php?quiz_id=<?php echo $_SESSION['fromcurrentquiz'] ?>"/><?php
        ?><center><h3>Redirecting in 1 seconds...</h3></center><?php
    }
    else
    {
        ?>
        <meta http-equiv="refresh" content="0;url=quizzes.php?pageQuiz=<?php echo $_SESSION['pageQuiz'] ?>&nameOfQuiz=<?php echo $_SESSION['nameOfQuiz']; ?>&langOfQuiz=<?php echo $_SESSION['langOfQuiz'] ?>&whereSearchQuiz=<?php echo $_SESSION['whereSearchQuiz'] ?>&startSearchQuiz=KERESES"/><?php
        ?><center><h3>Redirecting in 1 seconds...</h3></center><?php
    }
}

function redirect_to_lastpage()
{
    if(isset($_SESSION['fromcurrentquiz']) && $_SESSION['fromcurrentquiz'] > 0)
    {
        ?>
        <form action="quizdetails.php?quiz_id=<?php echo $_SESSION['fromcurrentquiz'] ?>" method="GET">
        <meta http-equiv="refresh" content="20;url=quizdetails.php?quiz_id=<?php echo $_SESSION['fromcurrentquiz'] ?>"/></form>
        <center><br>Visszairányítás 20 másodpercen belül...<p></p>
        <a href="quizdetails.php?quiz_id=<?php echo $_SESSION['fromcurrentquiz'] ?>"><button class="button">Vissza a kvíz oldalára</button></a>
        </center>
        <?php
        $_SESSION['fromcurrentquiz'] = 0;
    }
    elseif(!isset($_SESSION['pageQuiz']) || !isset($_SESSION['nameOfQuiz']) || !isset($_SESSION['langOfQuiz']) || !isset($_SESSION['whereSearchQuiz']) || !isset($_SESSION['fromcurrentquiz']))
    {
        ?>
        <meta http-equiv="refresh" content="20;url=index.php"/>
        <center><br>Visszairányítás 20 másodpercen belül...<p></p>
        <a href="index.php"><button class="button">Vissza a Főoldalra</button></a></center>
        <?php
    }
    else
    {
        ?>
        <form action="quizzes.php?pageQuiz=<?php echo $_SESSION['pageQuiz'] ?>&nameOfQuiz=<?php echo $_SESSION['nameOfQuiz']; ?>&langOfQuiz=<?php echo $_SESSION['langOfQuiz'] ?>&whereSearchQuiz=<?php echo $_SESSION['whereSearchQuiz'] ?>&startSearchQuiz=KERESES" method="GET">
        <meta http-equiv="refresh" content="20;url=quizzes.php?pageQuiz=<?php echo $_SESSION['pageQuiz'] ?>&nameOfQuiz=<?php echo $_SESSION['nameOfQuiz']; ?>&langOfQuiz=<?php echo $_SESSION['langOfQuiz'] ?>&whereSearchQuiz=<?php echo $_SESSION['whereSearchQuiz'] ?>&startSearchQuiz=KERESES"/></form>
        <center><br>Visszairányítás 20 másodpercen belül...<p></p>
        <a href="quizzes.php?pageQuiz=<?php echo $_SESSION['pageQuiz'] ?>&nameOfQuiz=<?php echo $_SESSION['nameOfQuiz']; ?>&langOfQuiz=<?php echo $_SESSION['langOfQuiz'] ?>&whereSearchQuiz=<?php echo $_SESSION['whereSearchQuiz'] ?>&startSearchQuiz=KERESES"><button class="button">Vissza a kvízek böngészéséhez</button></a>
        </center>
        <?php
    }
    ?></table><?php
}

?>