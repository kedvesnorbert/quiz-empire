<?php
if(!isset($_SERVER['REDIRECT_STATUS']))
{
	$error = 403;
	$err_response = "Direct Access Not Allowed!";
}
else
{
	$error = $_SERVER["REDIRECT_STATUS"];
	if($error == 404)
	{
		$err_response = "Hoppá! Az oldal nem található!";
	}
	elseif($error == 403)
	{
		$err_response = "Forbidden! Belépés megtagadva!";
	}
}

function my_url()
{
	$url = (!empty($_SERVER['HTTPS'])) ? "https://".$_SERVER['SERVER_NAME'] : "http://".$_SERVER['SERVER_NAME'];
	return $url;
}

?>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>This is an error</title>
	<link rel="stylesheet" type="text/css" href="<?php echo my_url() . "/css/error.css"; ?>" />
	<style>
	#notfound .notfound-bg {
		background-image:
		  <?php
		  echo "url(" . my_url() . "/documents/images/errorbg.jpg);";
		  ?>
	}
	</style>
</head>

<body>
<div id="notfound">
	<div class="notfound-bg"></div>
	<div class="notfound">
		<div class="notfound-404">
			<h1><?php echo $error; ?></h1>
		</div>
		<h2><?php echo $err_response; ?></h2>
		<form class="notfound-search">
			<input type="text" placeholder="Keresés...">
			<button type="button" onclick="location.href='<?php echo my_url() . '/index.php'; ?>'">Keresés</button>
		</form>
		<div class="notfound-social">
			<a href="<?php echo my_url() . "/quizzes.php"; ?>"><i class="fa fa-kvizek">Kvízek</i></a>
			<a href="<?php echo my_url() . "/profile.php"; ?>"><i class="fa fa-profil">Profil</i></a>
			<a href="<?php echo my_url() . "/inbox.php"; ?>"><i class="fa fa-ertesitesek">Üzenetek</i></a>
		</div>
		<a href="<?php echo my_url() . "/index.php"; ?>">Vissza a Főoldalra</a>
	</div>
</div>

</body>
</html>
