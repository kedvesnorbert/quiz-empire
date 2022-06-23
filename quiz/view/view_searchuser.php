<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function show_searcherdiv()
{
	?>
	<div id="felhsearch_div" class="form-inline justify-content-center">
		<input type="text" id="search_input" class="form-control" placeholder="Írj be egy felhasználónevet..." required>
		<button id='search_button' class="btn btn-primary" onclick='searching_users()'>Keresés</button>
		<div id="processing_image" style='visibility:hidden;'><img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." height="100%"></div>
	</div>
	<?php
}

function show_errordiv()
{
	?>
	<div id="error_div">
		<center><img src="documents/images/warning.png" width = "5%"></center>
		A kereső használata csak 4. rangtól kezdődően lehetséges!<br> (Kivéve Prémium felhasználók)
	</div>
	<?php
}

?>