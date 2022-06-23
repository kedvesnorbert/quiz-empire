<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function view_profile_menu()
{
    ?>
    <form action="profile.php" method="GET">
    <ul id="profile_menu" class="nav justify-content-center">
        <li class="nav-item">
        <a class="nav-link" href="profile.php?action_id=1">Legutóbbi kvízek</a>
        </li>

        <li class="nav-item dropdown">
            <a id="minimenu_nav" class="nav-link dropdown-toggle" data-toggle="dropdown" style="margin-left:10px;">Kvízek</a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href="profile.php?action_id=2">Folyamatban lévő kvízek</a>
                <a class="dropdown-item" href="profile.php?action_id=3">Minden kvíz</a>
            </div>
        </li>

        <li class="nav-item">
        <a class="nav-link" href="profile.php?action_id=4">Barátok</a>
        </li>

        <li class="nav-item dropdown">
            <a id="minimenu_nav" class="nav-link dropdown-toggle" data-toggle="dropdown" style="margin-left:10px;">Beállítások</a>
            <div class="dropdown-menu">
                <a class="dropdown-item" href="profile.php?action_id=5">Segítség csomagok</a>
                <a class="dropdown-item" href="profile.php?action_id=6">Profil rejtettség</a>
                <a class="dropdown-item" href="profile.php?action_id=7">Prémium tagság</a>
                <a class="dropdown-item" href="profile.php?action_id=9">Üzenetek fogadása</a>
                <a class="dropdown-item" href="profile.php?action_id=8">Jelszó csere</a>
                <a class="dropdown-item" href="profile.php?action_id=10">Fiók törlése</a>
            </div>
        </li>
    </ul>
    </form>
    <?php
}

function view_others_profile($id, $uname)
{
    ?>
    <ul id="profile_menu" class="nav justify-content-center">
        <li class="nav-item">
        <a class="nav-link"><?php check_friendship(); ?></a>
        </li>

        <li class="nav-item">
        <a class="nav-link">
        <span id='sendmail_span'><button id="send_mail_id" class="btn btn-info" onclick='send_mail("<?php echo $id ?>", "<?php echo $uname ?>")'>Üzenet küldés</button> <span id="sendmail_loading" style="display:none;"><img src="documents/images/ajax-loader.gif" alt="Folyamatban..." width="13%"></span></span></a>
        <div id="dialogSendMessage" title="Privát üzenet küldése" style="display:none;"></div>
        </li>
    </ul>
    <?php
}

function view_my_datalist($a)
{
    ?>
    <div id="datalist_card" class="card" style="width:95%;padding-right:15px;">
		<h4 id='adatok_h4'>Személyes adatok</h4>
		<ul id="no_bullets_ul">
			<li><span class='udata_cat'>Felhasználónév: </span><span id='udata_dred' class='udata_data'><?php echo $a["username"] ?></span></li>
			<li><span class='udata_cat'>Rang: </span><span id='udata_dred' class='udata_data'><?php echo $a["rang"] ?>.</span></li>
			<li><span class='udata_cat'>Pontszám:  </span><span id="sajatpontokid"><?php echo $a["points"] ?></span></li>
			<li><span class='udata_cat'>Lejátszott kvízek: </span><span id='udata_dred' class='udata_data'><?php echo $a["quiz_played"] ?></span></li>
			<li><span class='udata_cat'>Segítségek: </span><span id="segitsegekid"><?php echo $a["helps"] ?></span></li>
			<li><span class='udata_cat'>Saját kvízek: </span><span id='udata_dred' class='udata_data'><?php echo $a["own_quiz"] ?></span></li>
			<li><span class='udata_cat'>Teljesített kérések: </span><span id='udata_dred' class='udata_data'><?php echo $a["requests_acc"] ?></span></li>
			<br>

			<li><span class='udata_cat'>PRÉMIUM tagság:</span>
			<?php
			if($a['premium'] == 1)
			{
				?><span id='udata_dblue' class='udata_data'><span id="buypremiumid">VAN, <br>Lejár: <?php
				echo $a['premium_expire'] ?>
				</span></span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'><span id="buypremiumid">NINCS</span></span><?php
			}
			?></li>
			
            <li><span class='udata_cat'>Profil rejtettség: </span>
            <?php
            if($a['profile_hiding'] == 0)
            {
                ?><span id='udata_dgreen' class='udata_data'><span id="hideprofilid">KIKAPCSOLVA</span></span><?php
            }
            else
            {
                ?><span id='udata_dred' class='udata_data'><span id="hideprofilid">BEKAPCSOLVA, <br>Lejár: <?php
                echo $a['profilehiding_expire'];?>
                </span></span><?php
            }
            ?></li>
		
			<li><span class='udata_cat'>Aktív figyelmeztetés: </span>
			<?php
			if($a['warn']== true)
			{
				?><span id='udata_dred' class='udata_data'>VAN, <br>Lejár: <?php
				echo $a['warn_expire'] ?>
				</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>NINCS</span><?php
			}
			?></li>
		
			
			<li><span class='udata_cat'>Összes figyelmeztetés: </span><span id='udata_dred' class='udata_data'><?php echo $a["totalwarn"] ?></span></li>
			<br>
			<li><span class='udata_cat'>Kedvenc kvízek: </span><span id='udata_dred' class='udata_data'><?php echo $a["fav_quiz"] ?></span></li>
			<li><span class='udata_cat'>Chat-csoportok: </span><span id='udata_dred' class='udata_data'><?php echo $a["chatgroups"] ?></span></li>
			<li><span class='udata_cat'>Beküldött kérdések: </span><span id='udata_dred' class='udata_data'><?php echo $a["questions"] ?></span></li>
			<br>

			<li><span class='udata_cat'>Barátok: </span><span id='udata_dred' class='udata_data'><?php echo $a["friends"] ?></span></li>
			<li><span class='udata_cat'>Kvíz hozzászólások: </span><span id='udata_dred' class='udata_data'><?php echo $a["quizcomments"] ?></span></li>
			<li><span class='udata_cat'>Közzétett hírek: </span><span id='udata_dred' class='udata_data'><?php echo $a["news"] ?></span></li>
			<br>
			<li><span class='udata_cat'>Regisztrálás ideje: </span><span id='udata_dblue' class='udata_data'><?php echo $a["registration"] ?>-kor</span></li>
			<li><span class='udata_cat'>Legutóbb itt járt:  </span><span id='udata_dgreen' class='udata_data'><?php echo $a["lastvisit"] ?></span></li>
			<br>

			<li><span class='udata_cat'>Teljes név: </span><span id='udata_dblue' class='udata_data'><?php echo $a["name"] ?></span></li>
			<li><span class='udata_cat'>E-mail cím: </span><span id='udata_dblue' class='udata_data'><?php echo $a["email"] ?></span></li>
			<br>
		</ul>
		
		<h4 id='adatok_h4'>Jogok</h4>
		<ul id="no_bullets_ul">
			<li><span class='udata_cat'>Pontok gyűjtése: </span>
			<?php
			if($a['lawtogetpoints'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>

			<li><span class='udata_cat'>Privát üzenet küldés: </span>
			<?php
			if($a['lawtosendmail'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>


        	<li><span class='udata_cat'>Üzenetküldés a Chaten: </span>
			<?php
			if($a['lawtousechat'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>

			<li><span class='udata_cat'>Chat csoport létrehozás: </span>
			<?php
			if($a['lawtousechat'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>

        	<li><span class='udata_cat'>Kérés kiírása: </span>
			<?php
			if($a['lawtouserequests'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>
		
			<li><span class='udata_cat'>Saját kvíz készítése: </span>
			<?php
			if($a['lawtocreatequiz'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>
		
        	<li><span class='udata_cat'>Új kvízkérdés beküldése: </span>
			<?php
			if($a['lawtosendquestion'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>

        	<li><span class='udata_cat'>Felhasználókereső: </span>
			<?php
			if($a['lawtosearchuser'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>
		<br>
		</ul>
    </div>
    <?php
}

function view_others_datalist($a)
{
    ?>
    <div id="datalist_card" class="card" style="width:95%;padding-right:15px;">
		<h4 id='adatok_h4'>Személyes adatok</h4>
		<ul id="no_bullets_ul">
			<li><span class='udata_cat'>Felhasználónév: </span><span id='udata_dred' class='udata_data'><?php echo $a["username"] ?></span></li>
			<li><span class='udata_cat'>Rang: </span><span id='udata_dred' class='udata_data'><?php echo $a["rang"] ?>.</span></li>
			<li><span class='udata_cat'>Pontszám:  </span><span id="sajatpontokid"><?php echo $a["points"] ?></span></li>
			<li><span class='udata_cat'>Lejátszott kvízek: </span><span id='udata_dred' class='udata_data'><?php echo $a["quiz_played"] ?></span></li>
			<li><span class='udata_cat'>Segítségek: </span><span id="segitsegekid"><?php echo $a["helps"] ?></span></li>
			<li><span class='udata_cat'>Saját kvízek: </span><span id='udata_dred' class='udata_data'><?php echo $a["own_quiz"] ?></span></li>
			<li><span class='udata_cat'>Teljesített kérések: </span><span id='udata_dred' class='udata_data'><?php echo $a["requests_acc"] ?></span></li>
			<br>

			<li><span class='udata_cat'>PRÉMIUM tagság:</span>
			<?php
			if($a['premium'] == 1)
			{
				?><span id='udata_dblue' class='udata_data'><span id="buypremiumid">VAN, <br>Lejár: <?php
				echo $a['premium_expire'] ?>
				</span></span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'><span id="buypremiumid">NINCS</span></span><?php
			}
			?></li>
		
			<li><span class='udata_cat'>Aktív figyelmeztetés: </span>
			<?php
			if(db_warn($_GET['profil_id'])== true)
			{
				?><span id='udata_dred' class='udata_data'>VAN, <br>Lejár: <?php
				echo $a['warn_expire'] ?>
				</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>NINCS</span><?php
			}
			?></li>

			<li><span class='udata_cat'>Barátok: </span><span id='udata_dred' class='udata_data'><?php echo $a["friends"] ?></span></li>
			<li><span class='udata_cat'>Kvíz hozzászólások: </span><span id='udata_dred' class='udata_data'><?php echo $a["quizcomments"] ?></span></li>
			<li><span class='udata_cat'>Közzétett hírek: </span><span id='udata_dred' class='udata_data'><?php echo $a["news"] ?></span></li>
			<br>
			<li><span class='udata_cat'>Regisztrálás ideje: </span><span id='udata_dblue' class='udata_data'><?php echo $a["registration"] ?>-kor</span></li>
			<li><span class='udata_cat'>Legutóbb itt járt:  </span><span id='udata_dgreen' class='udata_data'><?php echo $a["lastvisit"] ?></span></li>
			<br>
		</ul>
		
		<h4 id='adatok_h4'>Jogok</h4>
		<ul id="no_bullets_ul">
			<li><span class='udata_cat'>Pontok gyűjtése: </span>
			<?php
			if($a['lawtogetpoints'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>

			<li><span class='udata_cat'>Privát üzenet küldés: </span>
			<?php
			if($a['lawtosendmail'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>


        	<li><span class='udata_cat'>Üzenetküldés a Chaten: </span>
			<?php
			if($a['lawtousechat'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>

			<li><span class='udata_cat'>Chat csoport létrehozás: </span>
			<?php
			if($a['lawtousechat'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>

        	<li><span class='udata_cat'>Kérés kiírása: </span>
			<?php
			if($a['lawtouserequests'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>
		
			<li><span class='udata_cat'>Saját kvíz készítése: </span>
			<?php
			if($a['lawtocreatequiz'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>
		
        	<li><span class='udata_cat'>Új kvízkérdés beküldése: </span>
			<?php
			if($a['lawtosendquestion'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>

        	<li><span class='udata_cat'>Felhasználókereső: </span>
			<?php
			if($a['lawtosearchuser'] == 0)
			{
				?><span id='udata_dred' class='udata_data'>NINCS engedélyezve</span><?php
			}
			else
			{
				?><span id='udata_dgreen' class='udata_data'>Engedélyezve</span><?php
			}
			?></li>
		<br>
		</ul>
        <?php
        if($a['friendship'] == 4)
        {
            ?><div class="d-flex justify-content-center">
                <button id="enable_user_id" class="btn btn-warning" onclick='enable_user("<?php echo $a["profil_id"]; ?>")'>Felhasználó engedélyezése</button><br>
                <button id="block_user_id" class="btn btn-danger" onclick='block_user("<?php echo $a["profil_id"]; ?>")' style='display:none;'>Felhasználó tiltása </button>
            </div>
            <?php
        }
        elseif($a['friendship'] == 2 || $a['friendship'] == 0)
        {
            ?>
            <div class="d-flex justify-content-center">
                <button id="enable_user_id" class="btn btn-warning" onclick='enable_user("<?php echo $a["profil_id"]; ?>")' style='display:none;'>Felhasználó engedélyezése</button>
                <button id="block_user_id" class="btn btn-danger" onclick='block_user("<?php echo $a["profil_id"]; ?>")'>Felhasználó tiltása</button>
            </div>
            <?php
        } ?>
    </div>
    <?php
}

function view_making_friendship($id)
{
    ?><span id='mark_as_friend_span'>
        <button id="mark_as_friend" class="btn btn-primary" onclick='make_friend("<?php echo $id ?>")'>Barátnak jelölés</button>
        <span id="makefriend_loading" style="display:none;"><img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="13%"></span>
    </span><?php
}

function view_buy_help($szint, $pr)
{
    ?>
    <div id='buy_help_div'>
		<h4 id="pr_cim">Segítség csomag vásárlása</h4>
		<br>
		<p id="arak_cimid">Árak:</p> 
		<ul id="arak_id">
			<li>2. ranggal 24 pont/csomag</li>
			<li>3. ranggal 18 pont/csomag</li> 
			<li>4. ranggal 12 pont/csomag</li>
			<li>5. ranggal 8 pont/csomag.</li>
			<li>Prémium felhasználóknak 4 pont/csomag.</li>
		</ul>
		<p id="arak_req">Követelmény: min. 2. RANG, vagy Prémium előfizetés</p>
		
		<div class='form-inline'>
			<input type="text" id="set4" name="szam" class="form-control" style="width:200px;margin-left:25pt;" placeholder="Írd be a számot!" onkeyup="osszesenFizetendo(<?php echo $szint; ?>, <?php echo $pr; ?>)" maxlength="2" pattern="^\d{0,2}$" required>
			<input type="text" id="paid_id" class="form-control" style="width:200px;" value="Fizetendő: " disabled>
			<button type="button" id="setpremium" name="kaland" class="btn btn-primary" onclick="buyhelp()">MEHET</button>
		</div>
		<p id="alert_gethelp" style="margin-left:25pt;margin-top:10pt;"></p>
	</div>
    <?php
}

function view_profile_hiding()
{
	?>
    <div id='profile_hiding_div'>
        <h4 id="pr_cim">Profil rejtettség beállítása</h4><br>
        <p id="arak_cimid">Előnyei:</p>
        <ol id="arak_id">
        <li>Láthatatlan maradsz a többi felhasználó előtt</li>
        <li>Nem jutnak semmilyen információhoz a felhasználók veled kapcsolatban (Kivétel: ranglisták)</li>
        </ol>
        <p id="arak_req">Követelmény: 500 pont / hónap és ne legyen WARN-od.</p>
        <div class='form-inline'>
            <span class="form-control" style="padding-left:25px;border:none;">Profil rejtettség a következő hónapra: </span>
            <button type="button" id="profilrejt" class="btn btn-danger" onclick="hideprofil()">MEHET</button>
            <div id="dialogHideProfil" title="Profil rejtettség" style="display:none;"></div>
        </div>
    </div>
	<?php
}

function view_buying_premium()
{
    ?><div id='buy_premium_div'>
        <h4 id="pr_cim">Pontok beváltása Prémiumra</h4><br>
        <p id="arak_cimid">A PRÉMIUM tagság előnyei:</p>
        <ol id="arak_id">
            <li>A Chat használata rangtól függetlenül</li>
            <li>A Profil rejtettség INGYENES beállítása</li>
            <li>Segítség vásárlása 4 pont/csomag értékben rangtól függetlenül</li>
            <li>Jogosultság saját kérés kiírására</li>
            <li>Jogosultság új, saját kvíz létrehozására</li>
            <li>Jogosultság új kvízkérdések beküldésére</li>
            <li>A felhasználókereső használata rangtól függetlenül</li>
        </ol>
        <p id="arak_req">Követelmény: 15000 pont és ne legyen WARN-od.</p>
        <div class='form-inline'>
            <span class="form-control" style="padding-left:25px;border:none;">Pontok beváltása Prémiumra: </span>
            <button type="button" id="setpremium" class="btn btn-danger" onclick="buypremium()">Prémium vásárlása</button>
            <div id="dialogBuyPremium" title="Prémium vásárlása" style="display:none;"></div>
        </div>
    </div>
	<?php
}

function view_accepting_privmessages($current)
{
    ?><div id='accept_messages_div'>
        <h4 id="pr_cim">Üzenetek fogadása</h4><br>
        <p id="arak_cimid">Ezen az oldalon lehetőséged van korlátozni a bejövő privát üzeneteket és módosítani ezt a beállítást.<br>Ez személyes igények tekintetében bármikor megváltoztatható.</p><br>
        <div class='form-inline justify-content-center'>
            <select id='accept_message_type' class="form-control">
                <option value="0" <?php if($current == 0) echo "selected"; ?>>Mindenkitől</option>
                <option value="1" <?php if($current == 1) echo "selected"; ?>>Csak az adminoktól</option>
                <option value="2" <?php if($current == 2) echo "selected"; ?>>Csak adminoktól és barátoktól</option>
            </select>
            <button class="btn btn-primary" onclick='update_accepting_msg()'>Mentés</button>
        </div>
        <div align="center" style="margin-top:15pt;"><span id="update_acceptmsg" style="display:none;"><img src="documents/images/ajax-loader.gif" alt="Folyamatban..." width="3%"></span></div>
    </div>
	<?php
}

function view_delete_account()
{
	?><div id='delete_account_div'>
        <h4 id="pr_cim">Fiók törlése</h4><br><br>
        <p id="delacc_text">Ezen az oldalon lehetőséged van törölni a fiókodat. </p>
        <p id="delacc_text2">Figyelem! Ez a művelet végleges és nem vonható vissza! <br><br><br>
        <button id="delaccount" class="btn btn-danger" onclick="delmyaccount()">Fiók törlése</button>
        <div id="dialogDeleteMyAccount" title="Saját fiók törlése" style="display:none;"></div>
    </div>
	<?php
}

function view_changing_password()
{
	?>
	<div id='change_pw_div'>
        <h4 id="pr_cim">Jelszó megváltoztatása</h4><br>
        <div class="d-flex justify-content-center align-items-center" align="center">
        <div id='conatiner_div' class="form-row">

        <form class="was-validated">
            <div class="form-group">
                <label for="pw1" class='mylabelnames'>Az új jelszó</label>
                <input class="form-control" type="password" id="pw1" name="pw1" minlength="6" maxlength="100" pattern="^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])\S{6,100}$" required>
                <div id="valid_quest" class="valid-feedback">Helyesen kitöltve!</div>
                <div id="invalid_quest" class="invalid-feedback">Helytelen adat! A jelszó tartalmazzon kis-és nagybetűket, legalább 1 számjegyet, de ne tartalmazzon szóközöket! Legalább 6, de maximum 100 karakterből álljon!</div>
            </div>
            <div class="form-group">
                <label for="pw2" class='mylabelnames'>Az új jelszó megerősítése</label>
                <input class="form-control" type="password" id="pw2" name="pw2" minlength="6" maxlength="100" pattern="^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])\S{6,100}$" required>
                <div id="valid_quest" class="valid-feedback">Helyesen kitöltve!</div>
                <div id="invalid_quest" class="invalid-feedback">Helytelen adat! A jelszó tartalmazzon kis-és nagybetűket, legalább 1 számjegyet, de ne tartalmazzon szóközöket! Legalább 6, de maximum 100 karakterből álljon!</div>
            </div>
            <div class="form-group">
                <label for="pw" class='mylabelnames'>Jelenlegi jelszavad</label>
                <input class="form-control" type="password" id="pw" name="pw" minlength="6" maxlength="100" pattern="^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])\S{6,100}$" required>
                <div id="valid_quest" class="valid-feedback">Helyesen kitöltve!</div>
                <div id="invalid_quest" class="invalid-feedback">Helytelen adat! A jelszavadnak tartalmaznia kis-és nagybetűket, legalább 1 számjegyet, de nem tartalmazhat szóközöket! Legalább 6, de maximum 100 karakterből kell álljon!</div>
            </div>
                
            <button type="button" class="btn btn-primary" onclick='changepw()'>Új jelszó mentése</button>
            <div id="loading_commentdiv" style="display:none;margin-top:10pt;">
                <img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="7%">
            </div>
        </form>
        </div>
        </div>
    </div>
	<?php
}

function show_user_notfound($hiba)
{
	?><p id="errNotFound"><br><img src="documents/images/warning.png" width="8%"><br>
	Hiba!<br><?php echo $hiba; ?><br><br>
	<a href="profile.php?action_id=1" class="btn btn-link">Vissza a Profilhoz</a></p>
	<?php
}

function show_forbidden_toview($hiba)
{
	?><p id="errNotFound"><br><img src="documents/images/warning.png" width="10%"><br>
	Hiba!<br><?php echo $hiba; ?><br><br>
	<?php
}

?>