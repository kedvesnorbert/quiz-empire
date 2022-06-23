<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function show_service_maintenance()
{
	?>
	<div id="container" class="container">	
		<div>
			<center><h1>Karbantartás!<br>Nézz vissza kicsit később!</h1><br>
			<img src="documents/images/servicetruck_cat.jpg" width="75%">
			</center>
		</div>
	</div>
	<?php
}

function show_loginform()
{
	?>
	<div id="container" class="container">	
		<div id="regisztralasdiv" class="form-container sign-up-container">
		<form action="login.php" method="POST" onsubmit="return validation()">
			<h1>Regisztráció</h1>
			<div id="teljesnev_id">
			<input type="text" name="fullname" id="teljesnev" placeholder = "Teljes név" required onkeyup="return vk_ell()" onchange="return vk_ell()"
			<?php if (isset($_POST["fullname"])) echo "value=\"" . $_POST["fullname"] . "\""; ?> maxlength="100"><br>
			<span id="teljesnev_error"></span>
			</div>
		<br>
			<div id="email_id">
			<input type="text" name="email" id="email" placeholder = "E-mail cím" required onkeyup="return email_ell()" onchange="return email_ell()"
			<?php if (isset($_POST["email"])) echo "value=\"" . $_POST["email"] . "\""; ?> maxlength="100"><br>
			<span id="email_error"></span>
			</div>
		<br>
			<div id="user_id">
			<input type="text" name="userR" id="user" placeholder = "Felhasználónév" required onkeyup="return user_ell()"
			<?php if (isset($_POST["userR"])) echo "value=\"" . $_POST["userR"] . "\""; ?> maxlength="25"><br>
			<span id="user_error"></span>
			</div>
		<br>
			<div id="pw_id">
			<input type="password" name="pw" id="pw" placeholder="Jelszó" required onkeyup=" return pw_ell()" maxlength="100"><br>
			<span id="pw_error"></span>
			</div>
		<br>
			<div id="pw2_id">
			<input type="password" name="pw2" id="pw2" placeholder="Jelszó megerősítése" required onkeyup=" return pw2_ell()" maxlength="100"><br>
			<span id="pw2_error"></span>
			</div>
		<br>
			<div id="submitreg">
			<center><input type="submit" class="submit" name="reg" value="Regisztrálás"></center>
			</div>
		</form>
		</div>

		<div id="logdiv" class="form-container sign-in-container">
		<form action="login.php" method="POST" onsubmit="return login_validation()">
			<h1>Bejelentkezés</h1><br>
			<div id="log_user">
			<label for="log_user">Felhasználónév vagy E-mail</label><br>
			<input type="text" id="l_user" name="user" value="<?php if(isset($_COOKIE['uname'])) echo $_COOKIE['uname']; else echo ""; ?>">
			</div>
		<br>
			<div id="log_pw">
			<label for="log_pw">Jelszó</label><br>
			<input type="password" id="l_pw" name="pw" value="<?php if(isset($_COOKIE['upw'])) echo $_COOKIE['upw']; else echo ""; ?>">
			</div>
		<?php
			$deviceType = checkDevice();
			if($deviceType != 0)
			{
				?>
				<br>
					<div id="">
					<label for="remember_logindata_checkbox" id="remember_logindata_label">Jelszó megjegyzése</label>
					<input type="checkbox" id="remember_logindata_checkbox" name="remember_logindata_checkbox" checked>
					</div>
				<?php
			}
		?>
		<br>
			<div id="submitlog">
			<center><input type="submit" class="submit" name="log" value="Belépés"></center>
		</form>
			</div>
		
		</div>
	
		<div class="overlay-container">
			<div class="overlay">
				<div class="overlay-panel overlay-left">
					<h1>Üdvözlünk újra!</h1>
					<p>Jelentkezz be a személyes adataiddal, hogy kapcsolatban maradj velünk!</p>
					<button class="ghost" id="signIn">Bejelentkezés</button>
				</div>
				<div class="overlay-panel overlay-right">
					<h1>Helló, Barátunk!</h1>
					<p>Kérjük, add meg pár személyes adatodat, hogy új és izgalmas kalandokat élhess át velünk!</p>
					<button class="ghost" id="signUp">Regisztrálás</button>
				</div>
			</div>
		</div>
	</div>
	<?php
}
?>