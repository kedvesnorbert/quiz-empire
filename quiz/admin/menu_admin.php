<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function main_menu()
{
	?>
	<center>
	<table><tr>
		<td><input type="button" class="buttonFM" onclick="location.href='index.php'" value="Főoldal">
		<td><input type="button" class="buttonFM" onclick="location.href='users.php'" value="Felhasználók">
		<td><input type="button" class="buttonFM" onclick="location.href='questions.php'" value="Kérdések">
		<td><input type="button" class="buttonFM" onclick="location.href='allquiz.php'" value="Kvízek">
		<td><input type="button" class="buttonFM" onclick="location.href='quizresults.php'" value="Eredmények">
		<td><input type="button" class="buttonFM" onclick="location.href='quizcomments.php'" value="Commentek">
		<td><input type="button" class="buttonFM" onclick="location.href='backgrounds.php'" value="Hátterek">
		<td><input type="submit" class="buttonFM" onclick='adminlog_out()' value="Kilépés">	
	</table>
	</center>
	<?php
}
?>