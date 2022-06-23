<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function show_question_data($question)
{
    ?>
	<div id="asd">
	<div id="questiondiv">

	<table id="quizTable" align="center" border="0">  
	<tr>
		<td><button name="gy" class = "butt" disabled><?=$question?></button>
	<form action ="game.php" method ="POST" id="my_form">
	<tr>
		<td>
		<button name="btn1" class="butn" id="bt1" value="<?php echo $_SESSION['valaszok_shuff'][0]; ?>" onclick='validateMyForm1();'><?=$_SESSION['valaszok_shuff'][0]?></button><br>
	<tr>
		<td>
		<button name="btn2" class="butn" id="bt2" value="<?php echo $_SESSION['valaszok_shuff'][1]; ?>" onclick='validateMyForm2();'><?=$_SESSION['valaszok_shuff'][1]?></button><br>
	<tr>
		<td>
		<button name="btn3" class="butn" id="bt3" value="<?php echo $_SESSION['valaszok_shuff'][2]; ?>" onclick='validateMyForm3();'><?=$_SESSION['valaszok_shuff'][2]?></button><br>
	<tr>
		<td>
		<button name="btn4" class="butn" id="bt4" value="<?php echo $_SESSION['valaszok_shuff'][3]; ?>" onclick='validateMyForm4();'><?=$_SESSION['valaszok_shuff'][3]?></button>
	</form>
	</table>
	</div>
	<div id="helperdiv">
	<center>
	
	<table id="quizTableCount">
	<tr>
		<td style='height:25px;margin-bottom:20px;'><center><b><font face="verdana" color="red" style='font-size:20px;'><span id="count">20</span></font></b></center>
	</table><br>
	
	<?php
	if($_SESSION['whichType'] == -1)
	{
		if($_SESSION['has_help'] > 0)
		{
			if($_SESSION['helpSfert'] == 1)
			{
				?>
				<button id="negyedelo" onclick='validateHelp("<?php echo "1"; ?>")'>1 / 3</button><br>
				<?php
			}
			else
			{
				?>
				<button id="negyedelo-" disabled>Elhasználva</button><br>
				<?php
			}
			
			if($_SESSION['helpHalf'] == 1)
			{
				?>
				<button id="felezo" onclick='validateHelp("<?php echo "2"; ?>")'>50 : 50</button><br>
				<?php
			}
			else
			{
				?>
				<button id="felezo-" disabled>Elhasználva</button><br>
				<?php
			}
			
			if($_SESSION['helpFull'] == 1)
			{
				?>
				<button id="teljes" onclick='validateHelp("<?php echo "3"; ?>")'>100%</button><br>
				<?php
			}
			else
			{
				?>
				<button id="teljes-" disabled>Elhasználva</button><br>
				<?php
			}
		}
		else
		{
			?>
			<button id="negyedelo-" disabled>Nincs</button><br>
			<button id="felezo-" disabled>Nincs</button><br>
			<button id="teljes-" disabled>Nincs</button><br>
			<?php
		}
	}?>
	</center>
	</div>
	</div>
	<?php
}

function show_no_question()
{
    ?><table align="center" border="1" width = "30%" bgcolor="white">
		<tr>
			<td>
			<center><a href="index.php"><button id="goto_index" class="button">Vissza a főoldalra</button></a></center>
		<tr>
			<td><center>
		<?php echo "Nem maradt több megválaszolandó kérdés.<br>A játék véget ért!!"; ?>
		<meta http-equiv="refresh" content="1;url=index.php"/><?php
		?><center><h3>Redirecting in 1 seconds...</h3></center>
    <?php
}

function show_gameresult($result)
{
    ?><br>
    <table id="jatekTable" class="box" border="1">
        <tr id="totalcorrJatekTable">
            <td colspan="2">Eredmény: <?php echo $_SESSION['totalcorrect'] . " / " . $_SESSION['numberofquestion']; ?>
        <?php

    if($_SESSION['whichType'] == -2)
    {
        ?>
        <tr id="gyakorloUzenet">
            <td colspan="2"><font color="red">Pontok nem szerezhetőek ebben a kategóriában!</font><br><br>
        <?php
    }
    else
    {
        ?>
        <tr id="cimJatekTable">
                <td colspan="2">Jutalmak<br>
        <tr id="meritPoints">
            <td style='padding-left:10px;'><br>Kiérdemelt pontok:
            <td style='padding-left:5px;'><br><?php echo $_SESSION['totalcorrect'] . " pont"; ?>
        <tr id="bonusPoints">
            <td style='padding-left:10px;'><br>Bónusz pontok:
            <td style='padding-left:5px;'><br><?php echo $result - $_SESSION['totalcorrect'] . " pont"; ?>
        <tr id="totalPoints">
            <td style='padding-left:10px;'><br>Összesen:
            <td style='padding-left:5px;'><br><?php echo $result . " pont"; ?>
        <tr>
            <td colspan="2">
        <?php
    }
    ?>
    <meta http-equiv="refresh" content="20;url=index.php"/>
    <center><br>Visszairányítás 20 másodpercen belül...<p></p>
    <a href="index.php"><button id="goto_index" class="button">Vissza a főoldalra</button></a>
    </center>
    </table><?php
}

?>