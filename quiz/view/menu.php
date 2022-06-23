<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die();
	exit();
};

function main_menu()
{
	?>
	<nav class="navbar navbar-expand-sm bg-success navbar-dark" style="font-size:13pt;margin-bottom:15px;">
		<ul class="navbar-nav mr-auto">
			<li class="nav-item">
			<a id="mainmenu_a" class="nav-link" href="../index.php" style="margin-left:10px;">Főoldal</a>
			</li>
			<li class="nav-item">
			<a id="mainmenu_a" class="nav-link" href="../profile.php" style="margin-left:10px;">Profil</a>
			</li>
			<li class="nav-item dropdown">
				<a id="mainmenu_a" class="nav-link dropdown-toggle" data-toggle="dropdown" style="margin-left:10px;">Kvízek</a>
				<div class="dropdown-menu">
					<a class="dropdown-item" href="../quizzes.php">Kvízek böngészése</a>
					<a class="dropdown-item" href="../newquiz.php">Új kvíz létrehozása</a>
					<a class="dropdown-item" href="../newquestion.php">Új kvízkérdés beküldése</a>
					<a class="dropdown-item" href="../newquestion.php?action_id=2">Javítandó kvízkérdések</a>
					<a class="dropdown-item" href="../requests.php">Kérések listázása</a>
					<a class="dropdown-item" href="../newrequest.php">Új kérés kiírása</a>
				</div>
			</li>
		</ul>
		
		<ul class="navbar-nav">
			<li class="nav-item">
			<span class="badge" style='visibility:hidden'></span></a>
			<a id="mainmenu_a" class="nav-link" href="../inbox.php">Üzenetek</a>
			</li>
			<li class="nav-item dropdown">
				<a id="mainmenu_a" class="nav-link dropdown-toggle" data-toggle="dropdown">Műveletek</a>
				<div class="dropdown-menu">
					<?php  
					if($_SERVER["REQUEST_URI"] == "/index.php") 
					{ 
						?><a class="dropdown-item" onclick='show_start_generalquiz()'>Általános kvíz</a><?php 
					} ?>
					<div id="dialogStartGeneralQuiz" title="Kvíz indítása" style="display:none;"></div>
					<a class="dropdown-item" href="../chat.php">Chat megnyitása</a>
					<a class="dropdown-item" href="../searchuser.php">Felhasználók</a>
					<a class="dropdown-item" href="../wiki.php">Wiki</a>
					<a class="dropdown-item" onclick='log_out()'>Kijelentkezés</a>
				</div>
			</li>
			<li class="nav-item">
			<a class="nav-link" id="count_logoff" style="color:white;font-weight:bold;margin-right:10px;">15:00</a>
			</li>
		</ul>
	</nav>
	<?php
}

function menu()
{
	?>
	<ul class="nav justify-content-center" style="margin-top:30px;">
		<li class="nav-item" style="margin-right:5px;">
			<input type="button" class="btn btn-success" onclick="location.href='../quizzes.php'" value="KVÍZEK">
		</li>
		<li class="nav-item" style="margin-right:5px;">
			<input type="button" class="btn btn-success" onclick="location.href='../newquestion.php'" value="Új kérdés">
		</li>
		<li class="nav-item" style="margin-right:5px;">
			<input type="button" class="btn btn-success" onclick="location.href='../newquiz.php'" value="ÚJ KVÍZ">
		</li>
		<li class="nav-item" style="margin-right:5px;">
			<input type="button" class="btn btn-success" onclick="location.href='../requests.php'" value="Kérések">
		</li>		
	</ul>
	<?php
}
?>