<?php

if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function show_forbidden()
{
	?><p id="errNewreq"><br><img src="documents/images/warning.png" width="7%"><br>
	Hiba!<br>Jelenleg nincs jogod ehhez a funkcióhoz!</p><?php
}

function show_norecorrecting()
{
    ?><p id="no_recorrectingquestion">
        Nagyszerű!<br>Az általad beküldött kérdések esetén a szabályoknak megfelelően jártál el, a listád ennek köszönhetően üres!
    </p><?php
}

function new_question_form()
{
	?><br>
	<h2 style="text-align:center;margin-bottom:25px;">Új kérdés beküldése</h2>
	<div class="d-flex justify-content-center align-items-center">
	<div id='conatiner_div' class="form-row">

	<form class="was-validated">
	
		<div class="form-group">
			<label for="category" class='mylabelnames'>Témakör</label>
			<select id="category" class="form-control" name="tema" required>
			<option value="" selected disabled>(Válassz témakört!)
			<?php
			$res = db_themalist();
			if(!$res)
			{
				die(err_db());
			}
			while ($row = mysqli_fetch_assoc($res))
			{
				echo "<option value=\"" . $row["id_number"] . "\">" . $row["quiz_name"] . "\n";
			}
			?>
			</select>
			<div id="valid_category" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_category" class="invalid-feedback">Helytelen adat! Válassz egy témakört a listából!</div>
		</div>

		<div class="form-group">
			<label for="question" class='mylabelnames'>Kérdés</label>
			<span id="countdownQ" class="spanNewQuestion"></span>
			<input type="text" class="form-control" id="question" name="question" minlength="5" maxlength="254" pattern = "^([A-Z]|\x22[A-Z0-9]|\x27[A-Z0-9])(.|s)*[?]$" required>
			<div id="valid_quest" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_quest" class="invalid-feedback">Helytelen adat! A kérdés Nagybetűvel kezdődjön; Kezdődhet idézőjellel ("), vagy aposztróffal ('), amelyet ugyancsak nagybetű, vagy szám kell kövessen! A kérdést kérdőjellel zárd, vigyázva, hogy extra karakterek ne maradjanak a kérdőjel után! Legalább 5 karaktert írj!</div>
		</div>
	
		<div class="form-group">
			<label for="ans1" class='mylabelnames'>HELYES válasz</label>
			<span id="countdownA1" class="spanNewQuestion"></span>
			<input type="text" id="ans1" class="form-control" name="ans1" maxlength="150" required>
			<div id="valid_ans1" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_ans1" class="invalid-feedback">Helytelen adat! Legalább 1 karaktert írj be!</div>
		</div>

		<div class="form-group">
			<label for="ans2" class='mylabelnames'>1. rossz válasz</label>
			<span id="countdownA2" class="spanNewQuestion"></span>
			<input type="text" id="ans2" class="form-control" name="ans2" maxlength="150" required>
			<div id="valid_ans2" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_ans2" class="invalid-feedback">Helytelen adat! Legalább 1 karaktert írj be!</div>
		</div>

		<div class="form-group">
			<label for="ans3" class='mylabelnames'>2. rossz válasz</label>
			<span id="countdownA3" class="spanNewQuestion"></span>
			<input type="text" id="ans3" class="form-control" name="ans3" maxlength="150" required>
			<div id="valid_ans3" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_ans3" class="invalid-feedback">Helytelen adat! Legalább 1 karaktert írj be!</div>
		</div>

		<div class="form-group">
			<label for="ans4" class='mylabelnames'>3. rossz válasz</label>
			<span id="countdownA4" class="spanNewQuestion"></span>
			<input type="text" id="ans4" class="form-control" name="ans4" maxlength="150" required>
			<div id="valid_ans4" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_ans4" class="invalid-feedback">Helytelen adat! Legalább 1 karaktert írj be!</div>
		</div>

		<div class="form-group">
			<label for="difficulty" class='mylabelnames'>Nehézség</label>
			<select id="difficulty" class="form-control" required>
				<option value='' selected disabled>(Nehézség kiválasztása)</option>
				<option value='1'>Könnyű kérdés</option>
				<option value='2'>Nehéz kérdés</option>
			</select>
			<div id="valid_lang" class="valid-feedback">Helyesen kitöltve!</div>
			<div id="invalid_lang" class="invalid-feedback">Helytelen adat! Válassz egy opciót a listából!</div>
		</div>

		<div class="form-group">
			<label for="megj" class='mylabelnames'>Megjegyzés</label>
			<span id="countdownMegj" class="spanNewQuestion"></span>
			<input type="text" id="megj" class="form-control" name="megj" maxlength="150" placeholder="Nem kötelező...megadható a kérdés helyességét igazoló link, saját magyarázat">
		</div>
	
		<div id='process_div'>
			<button type="button" id="letrehoz" class="btn btn-success" onclick='sendNewQuestion();'>BEKÜLDÉS</button>
		
			<div id="loading_newquestiondiv" style="display:none;">
				<img src="documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="4%" style="margin-left:30px;margin-top:8px;">
			</div>
		</div>
	</form>
	</div>
	</div>
<?php
}

function show_questioncard($id, $thema, $themaid, $question, $corrans, $error, $errortime, $fullquestion, $fullans1, $fullans2, $fullans3, $fullans4)
{
    ?><div class="column">
        <div class="card align-items-center d-flex justify-content-center">
            <h4 class="card-title"><?php echo "Kérdés: " .  $id . "." ?></h4>
            <p class="card-text"><?php echo "- " . $thema . " -" ?></p>
            <p class="card-text"><?php echo $question ?></p>
            <p class="card-text"><?php echo "<i>Válasz: " . $corrans . "</i>" ?></p>
            <p class="card-text" style="color: #e60000;font-weight:bold;"><?php echo $error . "<br>@" . $errortime ?></p>
            <button id="correct_btn" class="btn btn-danger" onclick='show_correctingquestion_dialog(<?php echo urlencode($id) ?>)'>Javítás</button>

            <div id="<?php echo "dialogShowCorrectingQuestion" . $id; ?>" title="Kérdés javítása" style="display:none;">
                <div id="d_reason_to_correct">
                    <?php echo "Javítás oka: " . $error ?>
                </div>

                <div class="d-flex justify-content-center align-items-center">
                <div id='conatiner_div' class="form-row">
                <form class="was-validated">
                    <div class="form-group">
                        <label for="category" class='mylabelnames'>Témakör</label>
                        <select id="<?php echo "uptemakor" . $id; ?>" class="form-control" name="tema" required>
                        <option value="" selected disabled>(Válassz témakört!)
                        <?php
                        $resAd = db_themalist();
                        if(!$resAd)
                        {
                            die(err_db());
                        }
                        while ($rowAd = mysqli_fetch_assoc($resAd))
                        {
                            if ($rowAd["id_number"] == $themaid)
                            {
                                echo "<option value=\"" . $rowAd["id_number"] . "\" selected>" . $rowAd["quiz_name"] . "\n";
                            }
                            else
                            {
                                echo "<option value=\"" . $rowAd["id_number"] . "\">" . $rowAd["quiz_name"] . "\n";
                            }
                        }
                        ?>
                        </select>
                        <div id="valid_category" class="valid-feedback">Helyesen kitöltve!</div>
                        <div id="invalid_category" class="invalid-feedback">Helytelen adat! Válassz egy témakört a listából!</div>
                    </div>

                    <div class="form-group">
                        <label for="questionM" class='mylabelnames'>Kérdés</label>
                        <input type="text" class="form-control" id="<?php echo "questionM" . $id; ?>" name="question" minlength="5" maxlength="254" value="<?php echo htmlspecialchars($fullquestion); ?>" pattern = "^([A-Z]|\x22[A-Z0-9]|\x27[A-Z0-9])(.|s)*[?]$" required>
                        <div id="valid_quest" class="valid-feedback">Helyesen kitöltve!</div>
                        <div id="invalid_quest" class="invalid-feedback">Helytelen adat! A kérdés Nagybetűvel kezdődjön; Kezdődhet idézőjellel ("), vagy aposztróffal ('), amelyet ugyancsak nagybetű, vagy szám kell kövessen! A kérdést kérdőjellel zárd, vigyázva, hogy extra karakterek ne maradjanak a kérdőjel után! Legalább 5 karaktert írj!</div>
                    </div>

                    <div class="form-group">
                        <label for="ans1M" class='mylabelnames'>HELYES válasz</label>
                        <input type="text" id="<?php echo "ans1M" . $id; ?>" class="form-control" name="ans1" value="<?php echo htmlspecialchars($fullans1); ?>" maxlength="150" required>
                        <div id="valid_ans1" class="valid-feedback">Helyesen kitöltve!</div>
                        <div id="invalid_ans1" class="invalid-feedback">Helytelen adat! Legalább 1 karaktert írj be!</div>
                    </div>

                    <div class="form-group">
                        <label for="ans2M" class='mylabelnames'>1. rossz válasz</label>
                        <input type="text" id="<?php echo "ans2M" . $id; ?>" class="form-control" name="ans2" value="<?php echo htmlspecialchars($fullans2); ?>" maxlength="150" required>
                        <div id="valid_ans2" class="valid-feedback">Helyesen kitöltve!</div>
                        <div id="invalid_ans2" class="invalid-feedback">Helytelen adat! Legalább 1 karaktert írj be!</div>
                    </div>
                    
                    <div class="form-group">
                        <label for="ans3M" class='mylabelnames'>2. rossz válasz</label>
                        <input type="text" id="<?php echo "ans3M" . $id; ?>" class="form-control" name="ans3" value="<?php echo htmlspecialchars($fullans3); ?>" maxlength="150" required>
                        <div id="valid_ans3" class="valid-feedback">Helyesen kitöltve!</div>
                        <div id="invalid_ans3" class="invalid-feedback">Helytelen adat! Legalább 1 karaktert írj be!</div>
                    </div>

                    <div class="form-group">
                        <label for="ans4M" class='mylabelnames'>3. rossz válasz</label>
                        <input type="text" id="<?php echo "ans4M" . $id; ?>" class="form-control" name="ans4" value="<?php echo htmlspecialchars($fullans4); ?>" maxlength="150" required>
                        <div id="valid_ans4" class="valid-feedback">Helyesen kitöltve!</div>
                        <div id="invalid_ans4" class="invalid-feedback">Helytelen adat! Legalább 1 karaktert írj be!</div>
                    </div>

                    <div class="form-group">
                        <label for="megj" class='mylabelnames'>Megjegyzés</label>
                        <input type="text" id="<?php echo "megjM" . $id; ?>" class="form-control" name="megj" maxlength="150" placeholder="Nem kötelező...megadható a kérdés helyességét igazoló link, saját magyarázat">
                    </div>

                    <button type="button" id="recorrect" class="btn btn-primary" onclick="sendUpdatedQuestion(<?php echo urlencode($id) ?>)">Változtatások mentése</button>
            </form>
            </div>
            </div>
            </div>
        </div>
    </div>
    <?php
}

function newquestion_menu()
{
	?>
    <ul class="nav justify-content-center" style="background-color:#28A745;margin-left:auto;margin-right:auto;width:650px;">
        <li class="nav-item">
        <a class="nav-link" href="newquestion.php?action_id=1" >Új kérdés beküldése</a>
        </li>
        <li class="nav-item">
        <a class="nav-link" href="newquestion.php?action_id=2">Visszaküldött kérdések</a>
        </li>
        <li class="nav-item">
        <a class="nav-link" href="wiki.php?whatRules=2">Szabályzat elolvasása</a>
        </li>
    </ul><?php
}

?>