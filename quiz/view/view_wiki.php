<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function wiki_main()
{
	?><br><br>
	<div class='container'><h5>Főbb kategóriák (olvasnivaló)</h5>
		<div id='a_div'>
			<a href="wiki.php?whatRules=8#start">Kvízek böngészése, részvétel kvízeken</a><br>
				<a class='det_a' href="wiki.php?whatRules=8#browserquiz">- Kvízek keresése</a><br>
				<a class='det_a' href="wiki.php?whatRules=8#quizsettings">- Kvíz felvétele a kedvencekhez, értékelés, kedvelés, hozzászólás írás- és törlés, ranglisták megtekintése</a><br>
				<a class='det_a' href="wiki.php?whatRules=8#getquizresult">- Kvíz eredmények megtekintése</a><br>
				<a class='det_a' href="wiki.php?whatRules=8#modifyquiz">- Kvíz módosítása</a><br>
				<a class='det_a' href="wiki.php?whatRules=8#quizbackground">- Háttérkép beküldése, megtekintése és törlése</a><br>
			<a href="wiki.php?whatRules=1#start">Kérések (Requests)</a><br>
				<a class='det_a' href="wiki.php?whatRules=1#start">- Általános tudnivalók</a><br>
				<a class='det_a' href="wiki.php?whatRules=1#solverequest">- Kérés teljesítése</a><br>
				<a class='det_a' href="wiki.php?whatRules=1#createrequest">- Kérés létrehozásának lépései</a><br>
				<a class='det_a' href="wiki.php?whatRules=1#deleterequest">- Saját kérés teljesítésének lépései</a><br>
				<a class='det_a' href="wiki.php?whatRules=1#accomplishrequest">- Kérés kiírása</a><br>
				<a class='det_a' href="wiki.php?whatRules=1#offerpoints">- Pontok felajánlása kérésre</a><br>
			<a href="wiki.php?whatRules=2#start">Kérdés beküldése (Questions)</a><br>
				<a class='det_a' href="wiki.php?whatRules=2#start">- Általános szabályok</a><br>
				<a class='det_a' href="wiki.php?whatRules=2#newwquestion">- Kérdés beküldése</a><br>
				<a class='det_a' href="wiki.php?whatRules=2#faqquestion">- Gyakori kérdések</a><br>
			<a href="wiki.php?whatRules=4#start">Saját kvíz készítése (Own Quizzes)</a><br>
				<a class='det_a' href="wiki.php?whatRules=4#start">- Általános tudnivalók</a><br>
				<a class='det_a' href="wiki.php?whatRules=4#createquiz">- Új kvíz létrehozása</a><br>
				<a class='det_a' href="wiki.php?whatRules=4#afterquizsent">- A kvíz beküldése utáni teendők</a><br>
			<a href="wiki.php?whatRules=9#start">Barátok, jelölések, tiltások</a><br>
				<a class='det_a' href="wiki.php?whatRules=9#start">- Általános tudnivalók</a><br>
				<a class='det_a' href="wiki.php?whatRules=9#makefriend">- Barátnak jelölés</a><br>
				<a class='det_a' href="wiki.php?whatRules=9#validatefriend">- Baráti jelölés elfogadása, elutasítása</a><br>
				<a class='det_a' href="wiki.php?whatRules=9#deletefriend">- Barátság törlése</a><br>
				<a class='det_a' href="wiki.php?whatRules=9#blockuser">- Felhasználó tiltása</a><br>
				<a class='det_a' href="wiki.php?whatRules=9#enableuser">- Tiltott felhasználó engedélyezése</a><br>
			<a href="wiki.php?whatRules=6#start">Privát üzenetek</a><br>
			<a href="wiki.php?whatRules=10#start">Profil és beállításai</a><br>
				<a class='det_a' href="wiki.php?whatRules=10#start">- Általános tudnivalók</a><br>
				<a class='det_a' href="wiki.php?whatRules=10#lastquizzes">- Legutóbbi kvízek</a><br>
				<a class='det_a' href="wiki.php?whatRules=10#quizzesinprocess">- Folyamatban levő kvízek</a><br>
				<a class='det_a' href="wiki.php?whatRules=10#allquizzes">- Összes kvíz</a><br>
				<a class='det_a' href="wiki.php?whatRules=10#helps">- Segítség csomagok</a><br>
				<a class='det_a' href="wiki.php?whatRules=10#hideprofile_a">- Profil retettség</a><br>
				<a class='det_a' href="wiki.php?whatRules=10#premium">- PRÉMIUM tagság</a><br>
				<a class='det_a' href="wiki.php?whatRules=10#acceptprivatemsg">- Üzenetek fogadásának korlátozása</a><br>
				<a class='det_a' href="wiki.php?whatRules=10#changepassword">- Jelszó megváltoztatása</a><br>
				<a class='det_a' href="wiki.php?whatRules=10#deleteaccount">- Saját fiók törlése</a><br>
			<a href="wiki.php?whatRules=11#start">Hírek a Főoldalon</a><br>
				<a class='det_a' href="wiki.php?whatRules=11#start">- Általános tudnivalók</a><br>
				<a class='det_a' href="wiki.php?whatRules=11#newnews">- Új hír kiírása</a><br>
				<a class='det_a' href="wiki.php?whatRules=11#deletenews">- Hír törlése</a><br>
			<a href="wiki.php?whatRules=3#start">Rangok és a velük járó jogok</a><br>
			<a href="wiki.php?whatRules=5#start">Chat funkciók</a><br>
				<a class='det_a' href="wiki.php?whatRules=5#start">- Általános tudnivalók</a><br>
				<a class='det_a' href="wiki.php?whatRules=5#newgroup">- Új csoport létrehozás</a><br>
				<a class='det_a' href="wiki.php?whatRules=5#addmember">- Új tag felvétele a csoportba</a><br>
				<a class='det_a' href="wiki.php?whatRules=5#exitgroup">- Kilépés a csoportból</a><br>
				<a class='det_a' href="wiki.php?whatRules=5#deletegroup">- Csoport törlése</a><br>
				<a class='det_a' href="wiki.php?whatRules=5#removemember">- Tag eltávolítása</a><br>
				<a class='det_a' href="wiki.php?whatRules=5#otherinfo">- Egyéb megjegyzések</a><br>
			<a href="wiki.php?whatRules=12#start">Pontrendszer</a><br>
			<a href="wiki.php?whatRules=7#start">Gyakran Ismételt Kérdések (GY.I.K. / F.A.Q)</a><br>
		</div>
	</div><br>
	<?php
}

function show_title()
{
    ?><h2 class='text-center'>Szabályzat és tudnivalók</h2><?php
}

function laws_data()
{
	?><a id="start"></a>
	<h4 class="text-center">Rangok és a velük járó jogok</h4><br>

    <table id="levelsTable" class="table table-bordered">
    <tr>
        <td class='text-center'><font color='red'><b>Rang 1.</b></font><br><i>Nincs követelmény</i>
        <td class='text-center'><font color='red'><b>Rang 2.</b></font><br><b>20 pont és 2 kvíz</b>
        <td class='text-center'><font color='red'><b>Rang 3.</b></font><br><b>501 pont és 51 kvíz</b>
        <td class='text-center'><font color='red'><b>Rang 4.</b></font><br><b>5001 pont és 501 kvíz</b>
        <td class='text-center'><font color='red'><b>Rang 5.</b></font><br><b>15000 pont és 1500 kvíz</b>
    </table>
    <p id="levelsTable"><b>Megjegyzés:</b> A fenti táblázatban összefoglalva látható, hogy melyek azok a követelmények, amelyek elérése által megkapható az adott rang.
    <br><u>A pontszám azt jelenti, hogy a megjelölt számú pontja kell legyen összesen a felhasználónak.</u>
    <br><u>A bizonyos számú kvíz itt azt jelenti, hogy legalább annyi darab próbálkozás / kvízen való részvétel szükséges. A próbálkozások nem muszáj különböző kvízek esetében legyenek!</u><br>
    <b>A pontok vesztése a jelenlegi szintről való visszaesést feltételezheti egy előző szintre/rangra!!</b><br>
    Ha a Főoldalon rákattintasz a <u>Rang</u> szócskára, egy felugró ablakban megláthatod, hogy még mennyi pont, illetve kvízen részvétel szükséges a következő rangig, valamint mennyi pontlevonás esetén lesz visszaesés az előző szintre.
    </p>

	<table id="levelsTable" class="table table-bordered table-hover">
        <th class='align-middle' id="levelsHeader">
            <td id="levelsColumn" class='align-middle'>Rang 1.
            <td id="levelsColumn" class='align-middle'>Rang 2.
            <td id="levelsColumn" class='align-middle'>Rang 3.
            <td id="levelsColumn" class='align-middle'>Rang 4.
            <td id="levelsColumn" class='align-middle'>Rang 5.
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Kvízek elérése, böngészése
            <td class="text-center"><img id="imOk" src="documents/images/pipa.png"></img>
            <td class="text-center"><img id="imOk" src="documents/images/pipa.png"></img>
            <td class="text-center"><img id="imOk" src="documents/images/pipa.png"></img>
            <td class="text-center"><img id="imOk" src="documents/images/pipa.png"></img>
            <td class="text-center"><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Pontok gyűjtése
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Privát üzenet küldés
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Üzenetküldés a Chaten
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Chat csoport létrehozása
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Kvíz eredményének PDF-be exportálása
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Segítség vásárlása
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Kérés kiírása
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Saját kvíz készítése
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Új kvízkérdés beküldése
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Kérés teljesítése
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Felhasználókereső használata
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Új hír kiírása a Főoldalra
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Kvíz készítése jelszavas védelemmel
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
        <tr>
            <td class='align-middle' id="levelsEngedelyek">Kvíz kérése, beküldése Anonymus-ként
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imNemok" src="documents/images/x.png"></img>
            <td class='text-center'><img id="imOk" src="documents/images/pipa.png"></img>
	</table>
	<?php
}

function new_request()
{
	?><a id="start"></a>
    <h3 class='text-center'>Kérésekkel kapcsolatos szabályok</h3>
	<div id="topic_maindiv">
		<br><br><h5><u>A kérés kiírásával kapcsolatos szabályok</u></h5>
		<ul>
            <li>Jelenleg csak 2. RANG-tól kezdődően lehet használni a kérések funkciót.
			<li>Ellenőrizd, hogy NE legyen ugyanilyen, vagy nagyon hasonló témájú kvíz a kérések és a beküldött kvízek között!
			<li>A kérés témája legyen minél szűkebb! (pl: egy irodalmi mű, egy film, egy sorozat, de akár egy együttes, vagy egy híres személy is lehet)
			<li>A leírásnál kötelező a lehető <b>legrészletesebb bemutatni</b> kért kvíz témáját és az ide kapcsolódó kérdéseket is!
			<li><b>KÖTELEZŐ minimum 100 pontot</b> felajánlani a kérésre, de lehet több is. Ezt a pontmennyiséget levonja tőled a rendszer, melynek <b>felét</b> hozzáadja a kérésre felajánlott pontokhoz. A pontok másik felét a rendszer veszi el. Például: ha a pontok száma 107, akkor ebből 51-et hozzáad a kérésre felajánlott pontokhoz.
			<li>A kvíz minimum <b> 13</b> és maximum <b> 45 </b> kérdésből állhat.
			<li>Megadható (de nem kötelező), hogy a kérésedet teljesítő felhasználó minimum hány kérdést küldjön be a kvízhez. (Maximum 99-t lehet kérni.) A rendszer által kötelezett minimális kérdésszám az alábbi képlet segítségével számítandó ki: <b>Menetenkénti kérdések száma * 145% (felfele kerekítve).</b>
			<li>Az egy kérdésre engedélyezett válaszolási idő <b>másodpercben 15 és 99 közötti</b> szám lehet!
			<li>Elfogadod, hogy a kérés teljesítése után a kvízt bárki bármikor elérheti mindenféle korlátozások nélkül, illetve bárki küldhet be hozzá új kvízkérdéseket.
			<li><b>Ne kérj olyan kvízt:</b>
			<ul>
				<li>amely már be lett küldve
				<li>amelynek esetén nem teljesíthető a minimális kvízkérdésszám beküldése
				<li>amelynek teljes témaköre még nem ismert (pl: egy olyan sorozat, amelynek még nem volt leadva az utolsó epizódja; olyan regény, amelynek még nem jelent meg a teljes tartalma)
			</ul>
			<li><b>Tiltott anyagok</b><br>
			<ul>
				<li>KRESZ és ennek minden alkategóriája (A, B, B1, stb.)
				<li>Karácsony és az Adventtel kapcsolatos témájú kvízek (ok: duplikált kvíz, lásd: <a href="quizdetails.php?quiz_id=12">katt ide.</a>)
				<li>Halloween-el kapcsolatos kvízek (ok: duplikált kvíz, lásd: <a href="quizdetails.php?quiz_id=11">katt ide.</a>)
			</ul>
		
		</ul>
		<br>

        <a id="solverequest"></a>
		<h5><u>A kérés teljesítésével kapcsolatos szabályok</u></h5>
		<ul>
			<li><b>Csak egyszer</b> van lehetőség egy kérés teljesítésére.
			<li>Egy adott kérést egy időben csak egy felhasználó teljesíthet.
			<li>Csak akkor vállald el egy kérés teljesítését, ha részben jártas vagy az adott témakörben és ha biztosan be tudod küldeni a kért számú kvízkérdéseket.
			<li>A kérésre való jelentkezés időpontjától számítva <b><font color="red">7 nap</font></b> áll rendelkezésedre a kérés teljesítésére. (Vagyis a kért számú kvízkérdések beküldésére)
			<li>Ha egy kvízkérdésedet nem fogadják el, akkor kötelezően egy másik, új kérdést kell beküldeni helyette.
            <li>Az elvállalt kérés teljesítésének állapotát a kérés oldalának alján láthatod
                <br>
			<b>MEGKÖTÉSEK, MEGSZORÍTÁSOK</b>
			<li>Egyszerre maximum 5 kérés teljesítését vállalhatod el.
			<li>Ha 7 napon belül nincs beküldve a kért számú kvízkérdés, akkor a teljesítés törlésre kerül, valamint a kérdésekért kapott pontokat is visszavonjuk. = SIKERTELEN KÉRÉS TELJESÍTÉS
			<li>Rendelkezésre áll további 21 nap a kérés teljesítésére, ha: be lett küldve a kért számű kvízkérdés (függetlenül attól, hogy elfogadták, vagy sem), de van közöttük olyan kérdés, amelyet nem fogadtak el.
		</ul>
		
        <a id="createrequest"></a>
		<h5><u>Kérés létrehozásának lépései:</u></h5>
		<ol>
			<li>A kérés kiírásával kapcsolatos szabályok elolvasása</li>
			<li>Lépj a <a href="newrequest.php">KÉRÉSEK --> Új kérés létrehozása</a> oldalra</li>
			<li>Töltsd ki az ott található űrlapot, majd lépj a <b>KÉRÉS ELKÜLDÉSE</b> gombra. Megjegyzés: A (*)-al jelölt mezők kitöltése kötelező.
		</ol>
		
        <a id="deleterequest"></a>
		<h5><u>Saját kérés törlése</u></h5>
		<ul>
			<li>Saját kérésedet bármikor törölheted, ha még nem jelentkeztek annak teljesítésére, vagy jelenleg senki sincs, aki teljesítené.
			<li><b>Kérés törlésének lépései:</b>
				<ul>
					<li>Lépj a <a href="requests.php?nameOfReq=&whereSearchReq=2&startSearchReq=KERES">KÉRÉSEK --> Saját kérések</a> oldalra.
					<li>Válaszd ki a kívánt kérésedet a listából és a Részletek megjelenítésénél a <u>Saját kérés törlése</u> résznél írd be, hogy miért szeretnéd törölni a kérést, majd lépj a <b>TÖRLÉS</b> gombra.
				</ul>
			<li>A kérés törlése, illetve elutasítása esetén az itt felajánlott pontokat visszaadjuk.<br>
		</ul>
		
        <a id="accomplishrequest"></a>
		<h5><u>Kérés teljesítése:</u></h5>
		<ul>
			<li>Lépj a <a href="requests.php">KÉRÉSEK</a> oldalra
			<li>Válaszd ki az általad teljesíteni kívánt kérést és lépj a <b>TELJESÍTÉS</b> gombra.
			<br><i>5. RANGÚ felhasználók figyelmébe: Ha névtelenek szeretnének maradni a teljesítés folyamán, jelöljék be a TELJESÍTÉS ANONYMUSKÉNT négyzetet, majd utána lépjenek a TELJESÍTÉS gombra.</i>
			<li>Amennyiben sikerült jelentkezni a teljesítésre, lépj az <a href="newquestion.php">ÚJ KÉRDÉS</a> oldalra. Válaszd ki az immár számodra elérhetővé vált témakört (a kérés neve) és töltsd ki az űrlapot (azaz küldj be kérdést a témakörben). Ezt annyiszor ismételd, ahány kérdést kell/szeretnél beküldeni.
			<li><font color="red">Megjegyzés:</font> Csak abban az esetben jelentkezz a kérés teljesítésére, ha biztosan be tudod küldeni a kért számú kvízkérdéseket az adott a témakörben.
			<b>A kérés teljesítésének részleteit</b> a <a href="requests.php?nameOfReq=&whereSearchReq=4&startSearchReq=KERES">KÉRÉSEK --> Elvállalt kérések</a> oldalon találod az adott kérés részleteinél.
		</ul>

        <a id="offerpoints"></a>
        <h5><u>Pontok felajánlása:</u></h5>
		<ul>
			<li>A <a href="requests.php">Kérések</a> oldalon válaszd ki a kívánt témakört és kattints a nevére. A megjelenő részleteknél a <u>Pontok felajánlása</u> beviteli mezőbe írd be a pontszámot, amit hozzá szeretnél adni a kéréshez és lépj a MEHET gombra!</li>
            <li>FONTOS! A beírt pontszámot levonjuk tőled, a felét hozzáadjuk a kérésre felajánlott pontokhoz, a másik felét a rendszer veszi el. Minimum 30 pontot kötelező megadni. Ezt a műveletet addig ismételheted, amíg elegendő pontszámod marad, vagy a kérést teljesítik.</li>
            <li>Ha egy kérésre pontokat ajánlottál fel, akkor azt a későbbiekben <b>NEM vonhatod vissza</b>. Kivéve, ha a kérés kiírója törli a kérését! (Erről értesítünk)</li>
		</ul>
	</div><br><br>
	<?php
}

function new_quiz_data()
{
	?><a id="start"></a>
    <h3 class='text-center'>Saját kvíz létrehozásával kapcsolatos szabályok</h3>
	<div id="topic_maindiv">
	<br><br><h5><u>Általános szabályok</u></h5>
	<ul>
        <li>Jelenleg csak 3. RANG-tól kezdődően lehet új kvízt beküldeni.
		<li>Saját kvíz létrehozásának alapfeltétele az ezen az oldalon leírt szabályok elfogadása.
		<li>Ne legyen olyan témájú a kvíz, amely már létezik az oldalon és szorosan kapcsolódik a már fent lévő kvíz témájához!
		<li>A kvíz témája legyen minél szűkebb! (pl: egy irodalmi mű, egy film, vagy egy sorozat)
		<li>Jelenleg csak magyar és angol nyelvű kvízeket lehet beküldeni.
		<li>A leírásnál kötelező a lehető <b>legrészletesebb bemutatni</b> az általad létrehozandó témakört!
		<li>A kvízben szereplő kérdések száma <b>(egy menetben) 13 és 45 közötti</b> érték lehet. Megjegyzés: Nincs korlátozva a maximálisan beküldendő kérdések száma! Minél több kérdést küldessz be, annál változatosabb és izgalmasabb lesz a kvíz a felhasználók számára.
		<li>Az egy kérdésre engedélyezett válaszolási idő <b>másodpercben 15 és 99 közötti</b> szám lehet!
		<li>A kvíz próbálkozásainak idejénél/korlátainál a következőket kell figyelembe venni: Sem a kezdő-, sem a befejezés dátumát nem kötelező megadni, egyik sem lehet kisebb mint a mai dátum, illetve a két dátum között legyen legalább 1 nap.
		<li>Elfogadom, hogy beküldök minimum annyi kérdést, amennyit az alábbi képlet számítása eredményez: 
		<b>Menetenkénti kérdések száma * 145% (felfele kerekítve)</b>
		<li>Elfogadom, hogy a kvízemen csak azután vehetek részt, amiután beküldtem a minimálisan kötelezett kérdéseket és azokat mind ellenőrizték és elfogadták a moderátorok.
		<li>Elfogadom, hogy miután a kvízem elérhetővé válik a felhasználók számára, már nem fogom tudni megtekinteni a hozzá beküldött kérdéseimet.
		<li>Elfogadom, hogy teljesítés után a kvízt nem törölhetem és a hozzá beküldött kérdések is megmaradnak.
		<br><br>
		<b>Szigorúan TILOS létrehozni minden olyan kvízt:</b>
		<ul>
			<li>amelyből már be van küldve egy változat (vagy nagyon hasonló témájú kvíz)
			<li>amelynek esetén nem teljesíthető a minimális kvízkérdésszám beküldése
			<li>amelynek teljes témája / tartalma még nem ismert (pl: egy olyan sorozat, amelynek még nem volt leadva az utolsó epizódja; olyan regény, amelynek még nem jelent meg a teljes tartalma)
		</ul>
		<br><b>Tiltott anyagok<br>Az alábbi témák beküldése, illetve kérése szigorúan TILOS! Ezen szabály megszegése WARN-t von maga után.</b>
		<ul>
			<li>KRESZ és ennek minden alkategóriája (A, B, B1, stb.)
		</ul>
	</ul><br><br>
    
    <a id="createquiz"></a>
    <h5><u>Új kvíz létrehozásának lépései:</u></h5>
		<ol>
			<li>Az új/saját kvíz létrehozásával kapcsolatos szabályok elolvasása</li>
			<li>Lépj az <a href="newquiz.php">ÚJ KVÍZ</a> oldalra</li>
			<li>Töltsd ki az ott található űrlapot. Megjegyzés: A (*)-al jelölt mezők kitöltése kötelező.<br>
			A további részletekért lépj a Profilodon a <a href="profile.php?action_id=2">Kvízek --> Folyamatban lévő kvízek</a> oldalra.
		</ol>

    <a id="afterquizsent"></a>
	<br><br><h5><u>A kvíz beküldése utáni teendők</u></h5>
	<ul>
		<li>Miután kitöltötted és beküldted az űrlapot, várnod kell, amíg egy admin jóváhagyja a kvízt. Ez napokba is telhet. Amint ellenőrizve lettek a kvízed adatai, értesíteni fogunk.
		<li>Ha a kvízed elutasításra kerül, kérünk, ne próbálkozz újra beküldeni ugyanazt a kvízt.
		<li>Ha a kvízedet elfogadtuk, megkezdheted a kérdések beküldését az <a href="newquestion.php">ÚJ KÉRDÉS</a> oldalon.
		<li>Ha beküldtél annyi darab kérdést, mint amennyi minimálisan kötelező és azokat elfogadtuk, akkor a kvízed már aktív állapotba kerül (erről külön kapsz értesítést), így el fogják tudni érni mindazon felhasználók, akiknek erre jogot adtál.
        <li>A kvíz teljesítése során lehetőséged van megtekinteni a beküldött kérdéseket. Ezt a <a href="profile.php?action_id=2">Profil --> Folyamatban levő kvízek</a> oldalon teheted meg, ha lenyitod a kvíz adatlapját és a <u>Beküldött kérdések</u> gombra lépsz.
	</ul>
	
	<br><h5><u>Jutalmak:</u></h5>
		<ul>
			<li>Minden elfogadott kérdésért +15 pont jár.
			<li>Minden kvíz elkészítéséért +300 pont jutalom jár. (Miután a kvízt teljesen elkészítetted és aktív állapotba került.)
		</ul>
	</div>
	<?php
}

function new_questiondata()
{
	?><a id="start"></a>
    <h3 class='text-center'>Kérdés beküldésével kapcsolatos szabályok</h3>
	<div id="topic_maindiv">
	<h5><u>Általános szabályok</u></h5>
	<ol>
	<li>A kérdés beküldése után a kérdésedet nem törölheted! éMódosítani csak abban az esetben tudod, ha egy moderátor engedélyt ad rá és <b><i>visszaküldi azt javításra. </i></b>A javítás során kizárólag a moderátor által megjelölt hibát kell kijavítani. Újabb hibák elkövetése a kérdés törlését vonhatja maga után.
	<br><i>MEGJEGYZÉS</i>: A javításra visszaküldött kérdések <b>kijavítása KÖTELEZŐ</b>, tehát ennek figyelmen kívűl hagyása a kérdés törlésével jár.</li>
	<li>Jelenleg csak magyar és angol nyelven íródott kérdések küldhetők be!</li>
	<li>Csak a listában megjelenő témakörökben küldhető be kérdés. Kötelező a kérdésnek megfelelően kiválasztani a <b><i>HELYES témakört</i></b>!
	<br><i>MEGJEGYZÉS</i>: Ha a kérdés több témakörbe is beillik, akkor válaszd a számodra leginkább megfelelőt!</li>
	<li>A kérdés legyen érthetően megfogalmazva, vigyázva a szóhasználatra, valamint a kérdésnek legyen kérdés formája (Nagybetűvel kezdődjön, kérdőjellel végződjön, ne legyenek felesleges fehér karakterek (szóköz tab, újsor) a kérdés szövegében, stb.) <b><i>A helyesírási hibák nem megengedettek</i></b>!</li>
	<li>Csak olyan kérdés küldhető be, amely esetén <b><i>mindig csak 1 helyes válasz lehet</i></b>.</li>
	<li>Ha tudomásod van olyan kérdésről, amely már be lett küldve az oldalra (például: egy kvíz során kaptad azt a kérdést) és nagyrészt hasonlít az általad beküldendő kérdéshez, akkor azt NE KÜLDD BE!</li>
	<li>Nem kötelező, de lehetőség van megjegyzést írni a beküldendő kérdéshez, ahol szívesen elfogadunk magyarázatokat, tényeket, információkra mutató linkeket, amelyek hozzájárulnak a kérdés helyességének ellenőrzéséhez, vagy akár annak egyediségét igazolják (azaz, hogy nem duplikált kérdés).</li>
	<li>Tilos a rendszer feltörésére / nem engedélyezett információk hozzáférésére tett bármilyen kísérlet/művelet, valamint minden egyéb szabálytalanság is büntetve lesz.</li>
	</ol>
	
	<h5><u>További szabalyok!</u></h5>
	<ol>
		<li>Elfogadom, hogy a kérdésem csak ellenőrzés és elfogadás után kerül be a kvízhez.
		<li>Elfogadom, hogy beküldés után már nem módosíthatok a kérdésen. (Kivéve: ha a kérdést visszaküldték javításra)
		<li>Elfogadom, hogy a beküldött kérdéseimet már nem fogom tudni megnézni, vagy adatokat megtudni róla. (Kivétel: Saját kvízhez beküldött kérdések, amíg a kvíz elkészítése folyamatban van).
		<li>Elfogadom, hogy a javításra visszaküldött kérdéseket kijavítom mihamarabb és visszaküldöm őket az újabb ellenőrzésre.
		<li>Elfogadom, hogy ha egy kérdésemet törlik, akkor azt tiszteletben tartom, és nem próbálom meg azt újra beküldeni.
	</ol>
	A kérdés beküldésével automatikusan elfogadod a fent leírt szabályokat!<br><br>
	
    <a id="newwquestion"></a>
    <h5><u>Kérdés beküldésének lépései</u></h5>
	<ol>
		<li>Lépj az <a href="newquestion.php">Új kérdés beküldése</a> oldalra!
		<li>Töltsd ki az ott látható űrlapot az ott leírt szabályoknak megfelelően és küldd be! Fontos, hogy <u>mind a 4 választási lehetőség szövege különbözzön egymástól is, illetve a kérdéstől is</u>!! A kérdés nehézségét te választhatod ki, viszont igyekezz logikusan, ésszerűen dönteni! (Például, a "Mennyi 1+1?" kérdés KÖNNYŰ-nek tekinthető. De a "Mennyi 74*32-9?" már távolról látszik, hogy a NEHÉZ kategóriába illik bele). Megjegyzés írása nem kötelező, de mi örülünk neki, ha információkkal látod el a kérdésedet a helyességének könnyebb ellenőrzése, vagy nem duplikáltságának megerősítése érdekében.
		<li>Miután beküldted a kérdést, a rendszer értesítést küldd, hogy sikeresen megérkezett hozzánk. A továbbiakban várnod kell, amíg az adminok ellenőrzik és eldöntik, hogy megfelel, vagy javítésra szorul, vagy nem felel meg és törlik. Bármi is legyen az eredmény, a rendszer egy újabb értesítést küld erről.<br>
            &emsp;- Ha a kérdésed helyes volt, jutalompontokat kapsz.<br>
            &emsp;- Ha a kérdésed hibás, vagy javításra szorul, visszaküldik javításra, amelyet <a href="newquestion.php?action_id=2">ezen az oldalon</a> láthatsz.<br>
            &emsp;- Ha a kérdésed nem felelt meg az előírt szabályoknak, a rendszer törölni fogja és az adminok fogják eldönteni, hogy mennyi pontlevonást fogsz érte kapni.<br>
		<li>Ha további kérdést szeretnél beküldeni, azt bármikor megteheted. Nem kötelező megvárni az előzőleg beküldött kérdésed ellenőrzését az újabb beküldéséhez.
	</ol>

    <a id="faqquestion"></a>
	<h5><u>Gyakran ismételt kérdések</u></h5><br>
	<b>Mikor küldhetek be kérdéseket?</b><br>
	Jelenleg csak 3. RANGtól kezdődően küldhetők be kérdések, ha engedélyezve van számodra, illetve ha nincs WARN-od. (A Profilod egyéb adatainál ellenőrizheted ezeket az adatokat)<br><br>
	<b>Milyen témakörökben küldhetek be kérdéseket?</b><br>
	Csak a számodra engedélyezett témakörökben küldhetsz be kérdéseket. Ezen témakörök listáját megtalálod az Új kérdés beküldése oldalon, és nagyon egyszerűen megnézheted a listát, hiszen csak ezen témakörök nevét fogod látni.
	<br>
	</div>
	<?php
}

function quiz_listing_data()
{
    ?><a id="start"></a>
    <h3 class='text-center'>Kvízek böngészése, részvétel kvízeken</h3>
	<div id="topic_maindiv">
    <a id="general"></a>
	<h5><u>Általános tudnivalók</u></h5>
    <ul>
		<li>Az oldalra beküldött minden kvízt <a href="quizzes.php">ezen az oldalon</a> találhatod meg!</li>
        <li>Csak a befejezett fázisú kvízek láthatóak az oldalon, így értelemszerűen csak ezeken lehet részt venni</li>
        <li>Egy kvíz esetében 3 fázist különböztetünk meg:</li>
            &emsp;- <b>Kezdő fázis (vagy 1.fázis)</b> - amikor beküldöd az űrlapot a létrehozandó kvíz adataival, a kvíz első fázisba kerül<br>
            &emsp;- <b>Közép fázis (vagy 2.fázis)</b> - ha ellenőrizték a kvíz adatait, és engedélyezték annak létrehozását, a kvíz átkerül a 2.fázisba. Ez az a stádium, <u>amikor kérdéseket lehet beküldeni a kvízhez</u>.<br>
            &emsp;- <b>Végső fázis (vagy 3.fázis)</b> -ha be lett küldve a legalább <i>kötelező számú</i> kvízkérdés, és azokból <i>elfogadtak</i> annyit, amennyi kötelező beküldeni, akkor az adminok lezárják a kvízt. Ez az a stádium,  <u>amikor részt lehet venni a kvízen </u>. <font color="red">FONTOS! A kvíz lezárása azt jelenti, hogy a kvíz teljesítve lett. Ezt követően továbbra is lehet újabb kérdéseket beküldeni, és bizonyos adatokat módosítani a kvízen</font><br>
        <li>Egy adott kvízen 2-féle képpen lehet részt venni:</li>
            &emsp;- A kvízek listájában a kiválasztott kvíz jobb szélén található <u>Kvíz indítása</u> zöld gombra kattintva<br>
            &emsp;- A kvíz adatlapján található <u>Kvíz indítása</u> zöld gombra kattintva<br>
            Mindkét esetben egy felugró ablak jelenik meg, ahol információkat láthatsz a kvízről, illetve ha szükséges, be kell írnod a kvíz jelszavát az indításhoz. Innen már csak az <b>Indítás</b> gombra kell lépni, és a kvíz el is indult.
        <li>A kvízről további információkat a kvíz adatlapján láthatsz, illetve ha rákattintassz a kvíz nevére</li>
        <li>Egy kvíznek számos elérhetőségi típusa lehet, így ebből a szempontból a következő kvízeket különböztetjük meg:</li>
            &emsp;- <b>csak a feltöltő és az adminok számára elérhető kvíz</b><br>
            &emsp;- <b>csak a feltöltő, az adminok és a feltöltő összes barátai számára elérhető kvíz</b> (FONTOS! Ha a feltöltő töröl egy barátot, akkor annak a számára már nem lesz elérhető ez a fajta kvíz, de az új barátai számára igen!!)<br>
            &emsp;- <b>csak a feltöltő, az adminok és a feltöltő által kijelölt barátok számára elérhető kvíz</b> (FONTOS! Ha a feltöltő töröl egy barátot, akinek engedélyezte a kvízt, annak továbbra is elérhető marad, de az új barátai számára már nem lesz elérhető ez a fajta kvíz!!)<br>
            &emsp;- <b>jelszavas kvíz</b> (Bármely felhasználó mindentől függetlenül, aki ismeri a kvíz jelszavát, elérheti ezt a fajta kvízt. Megjegyzés: Jelszavas kvízek beküldése csak 5.RANG-tól kezdődően lehetséges)<br>
            &emsp;- <b>mindenki számára elérhető kvíz</b> (Megjegyzés: minden kérés ebbe a kategóriába tartozik)<br>
        <li>Bizonyos kvízek elérhetősége időhöz kötött. <b>(-- IDŐKORLÁTOS KVÍZ --)</b> Ha a fenti kategóriák valamelyikét teljesíted (pl: jelszavas teszt esetében ha ismered a jelszót), az még mindig nem elegendő feltétel a kvízen való részvételhez, ha időkorlát van rá téve. Ez a korlát lehet, hogy csak a kezdési dátumot korlátozza (Start date), lehet, hogy csak a lezárás korlátját (End date), de az is lehet, hogy mindkettőt. Vagyis a kvíz csak a megszabott időintervalumon belül lehet elérhető. A feltöltő ezt a korlátot bármikor módosíthatja.</li>
    </ul>

    <a id="browserquiz"></a>
    <h5><u>Kvízek keresése</u></h5>
    <ul>
        <li>A kvíz nevéhez olyan kifejezést írj (egyébként nem kötelező kitölteni, mert anélkül is fog találatokat kiadni), ami legalább egy szó, mivel ha a kvíz teljes nevében bárhol előfordul az adott kifejezés, akkor azt találatnak fogja venni a rendszer (például: ha a kifejezés = "s", akkor minden olyan kvízt meg fog jeleníteni, amely nevében van s betű)</li>
        <li>A kvíz keresővel 4 kategóriában böngészhetsz a kvízek között: <br>
            &emsp;- <b>Saját kvízek</b> - az általad beküldött kvízeket, illetve általad kérésként teljesített kvízeket listázza ki
        <li>&emsp;- <b>Elérhető kvízek</b> - azokat a kvízeket jeleníti meg, amelyeknek időkorlátja éppen megengedi a kvízen való részvételt
        <li>&emsp;- <b>Kedvenc kvízek</b> - az általad kedvencként megjelölt kvízeket fogja kilistázni
        <li>&emsp;- <b>Minden kvíz</b> - megjelenít minden kvízt, amely a végső fázisban van
        <li>Továbbá lehetőség van kiválasztani, hogy milyen nyelvű kvízek között történjen a keresés (Magyar, vagy Angol nyelvű kvízek)</li>
        <li>Túl sok találat esetén a lapozó segítségével lehet továbbmenni a találatokon.</li>
    </ul>

    <a id="quizsettings"></a>
    <h5><u>Műveletek kvízekkel</u></h5>
    <ul>
        <li><b>Kvíz felvétele a kedvencekhez: </b>Ezt a kvíz kereső oldalán teheted meg. Az adott kvíz nevére kattintva megjelennek további adatok a kvízről. Itt a <u>Hozzáadás a kedvencekhez</u> gombra lépve adhatod a Kedvenceid közé a kvízt. Ezt bármikor visszavonhatod, vagy újból megismételheted, ugyanerre a gombva kattintva. (Ez a gomb mindig változik annak függvényében, hogy adott időben a kvíz szerepel a kedvenceid között, vagy sem.)</li>
        <li><b>Kvíz értékelése: </b> Legalább 1, legfeljebb 5 csillaggal minősíthetsz kvízeket. Ezt a kvíz oldalán teheted meg, az <u>Általános rész --> Értékelés</u> résznél. Csak egyszer van erre lehetőség, és nem lehet visszavonni, vagy megváltoztatni. Egy felhasználó a saját kvízeit nem értékelheti!!</li>
        <li><b>Kvíz kedvelése:</b> Az adott kvíz oldalán az <u>Általános rész --> Tetszik a kvíz</u> gombra kattintva teheted meg. Ezt követően a felhasználóneved megjelenik a listában azoké mellett, akik ugyancsak kedvelik a kvízt. Ez a művelet csak egyszer ismételhető meg, és nem vonható vissza. Egy felhasználó a saját kvízeit nem kedvelheti!!</li>
        <li><b>Hozzászólás írása a kvízhez: </b>Az adott kvíz oldalán az <u>Általános résznél </u> kicsit lennebb görgetve megjelenik egy nagyobb szövegbeviteli mező. Ide írhatod be a commentedet, használhatsz emojikat is, majd a <b>MEHET</b> gombra lépve küldheted el. Megjegyzés:</li>
            &emsp;- <b>Csak akkor írhatsz hozzászólást, ha legalább egyszer részt vettél a kvízen!</b><br>
            &emsp;- <b>Várj legalább 5 percet két hozzászólás írása között!</b><br>
            &emsp;- <b>Lehetőleg ne legyenek egymásutáni commentjeid a kvíznél! (Ne szemeteld tele a comment szekciót, lehetőleg egy hozzászólásban fogalmazd meg a mondandódat!) </b><br>
        <li><b>Kvíz hozzászólás törlése: </b>Bármikor törölheted egy kvízhez írt, saját commentedet ha szeretnéd, a hozzászólásod jobb alsó sarkában megjelenő <u>Törlés</u> gombra lépve.</li>
        <li><b>Kvíz hozzászólások olvasása: </b> A kvíz oldalán az <u>Általános részénél</u> folyamatosan lefele haladva olvashatod az ide írt commenteket. A rendszer automatikusan tovább tölti be az újabb hozzászóásokat, ha leértél az oldal aljára.</li>
        <li><b>Ranglisták megtekintése: </b> A kvíz oldalán fent baloldalt a <u>Ranglisták</u> linkre kattintva kiválasztható, hogy milyen szempont szerint jelenítsen meg a ranglistákat a rendszer. Kivétel nélkül, minden felhasználó eredményét megjeleníti a ranglista, ha beleesik az adott kritériumba. A ranglistát a továbbiakban lehet rendezni különböző szempontok szerint (felhasználó, eredmény, időpont) növekvő, vagy csökkenő sorrendbe. Egy adott próbálkozásról megtekinthető a felhasználó neve, az elért eredmény százalékban, valamint a helyesen megválaszolt kérdések száma, illetve a részvétel időpontja.</li>
    </ul>

    <a id="getquizresult"></a>
    <h5>A kvíz feltöltője még további intézkedéseket végezhet:</h5>

    <h5><u>Kvíz eredmények megtekintése</u></h5>
    <ul>
        <li>Mint a kvíz feltöltője, lehetőséged van minden felhasználó minden próbálkozásának részletes eredményét megtekinteni, azaz PDF-be exportálni és letölteni.</li>
        <li>Ezt a kvíz oldalán a <b>Ranglisták --> Összes próbálkozások</b> linkre kattintva teheted meg. Minden próbálkozásnak van egy PDF-ikonja, amelyre kattintva megtekinthető az adott próbálkozás részletei. Ez a dokumentum tartalmazza a felhasználó nevét, a kvíz során kapott kérdéseket a megjelenésük sorrendjében,a felhasználó válaszait és a válaszok helyességét; továbbá a kérdések nehézségét, a részvétel és a kiexportálás dátumát. A dokumentum letölthető.</li>
    </ul>

    <a id="modifyquiz"></a>
    <h5><u>Kvíz módosítása</u></h5>
    <ul>
        <li>A kvíz oldalán fent baloldalon a <u>Módosítás</u> linkre kattintva tehető meg.</li>
        <li>Csak a kvíz feltöltője módosíthat a kvízen! FIGYELEM! <b><font color="red">Kérésre teljesített kvízeken nem lehet módosítani!!</font> </b></li>
        <li>A módosítás-funkció csak azután érhető el, miután a kvízt lezárták (azaz ha a végső fázisba lépett)</li>
        <li>Csak bizonyos adatok változtathatók meg, mint például: <i>az elérhetőség, próbálkozások száma, kérdések beküldése a kvízhez, időkorlát, ellenőrzés lehetőségei.</i></li>
        <li>Az alábbi adatok NEM változtathatók meg: <font color="red">a kvíz neve, leírása, nyelve, az átmenő, menetenkénti kérdések száma, válaszolási idő, helyes válaszok mutatása.</font> </li>
        <li>Ezt a funkciót a feltöltő a későbbiekben bármikor használhatja.</li>
    </ul>

    <a id="quizbackground"></a>
    <h5><u>Háttérkép beküldése, megtekintése és törlése</u></h5>
    <ul>
        <li>A kvíz oldalán fent baloldalon a <u>Háttérképek</u> linkre kattintva tehető meg. Itt választható, hogy új háttérképet küldessz be, vagy megtekinted az eddig beküldött képeket.</li>
        <li>Csak a kvíz feltöltője küldhet be új képeket és tekintheti meg őket!</li>
        <li>Az Új háttérkép beküldése-funkció csak azután érhető el, miután a kvíz átkerült 2. fázisba. <font color="red">Amíg a kvíz a 2.fázisban van, addig ideiglenesen új háttérképet a <a href="profile.php?action_id=2">Profil --> Folyamatban levő kvízek</a> oldalon küldhetsz be, ha rálépsz a kvíz nevére és az ott látható <u>Új háttérkép</u> gombra.</font><br>A háttérképek megtekintése és törlése pedig csak azután lesz elérhető funkció, hogy a kvíz átkerült 3. fázisba.</li>
        <li>Egy kvízhez legfeljebb 50 kép küldhető be. Ha újat szeretnél beküldeni, de elérted az 50 kép limitet, akkor törölj a régebben beküldött képekből!</li>
        <li>A beküldendő kép kizárólag <b> .jpg, .jpeg, .png</b> formátumú lehet, és legfeljebb <b> 0.5 Megabájt (500 KB)</b></li>
        <li>Egy ilyen kép csak akkor lesz látható a kvíz folyamán mint háttérkép, ha ellenőrizték és elfogadták az adminok.</li>
        <li>A rendszer véletlenszerűen fogja megjeleníteni ezeket a háttérképeket a kvíz során. Ha nem küldessz be egy képet sem, akkor az alapértelmezett háttérkép fog megjelenni minden kérdésnél a kvízen való részvétel során.</li>
    </ul>

    </div>
    <?php
}

function friends_data()
{
    ?><a id="start"></a>
    <h3 class='text-center'>Barátok, jelölések, tiltott felhasználók</h3>
	<div id="topic_maindiv">
	<h5><u>Általános tudnivalók</u></h5>
    <ul>
		<li>A barátaid listáját a <a href="profile.php?action_id=4">Profil --> Barátok</a> oldalon nézheted meg. Ugyanezen az oldalon legalul pedig a tiltott felhasználókat láthatod.</li>
        <li>Egy felhasználót bármikor jelölhetsz barátnak, illetve bármikor törölheted őt. Ugyanez érvényes a felhasználó tiltásra, illetve annak visszavonására is</li>
        <li>Jelenleg nincs korlátozva a maximális barátok száma egy felhasználó számára.</li>
    </ul>

    <a id="makefriend"></a>
    <h5><u>Barátnak jelölés</u></h5>
    <ol>
		<li>Lépj a felhasználó oldalára! (Ha még nem tudsz rákeresni az illetőre a felhasználókeresővel, akkor keresgélj az oldalon a comment szekciókban, kvízek kedvelésénél, amíg megtalálod a nevét és arra kattints rá)</li>
        <li>A felhasználó oldalán lépj a Barátnak jelölés gombra!</li>
        <li>Várj, amíg az illető megerősíti a barátságot! Erről értesítést is kapsz.</li>
        <font color="red"><i>Megjegyzés: Rejtett felhasználókat és tiltott felhasználókat nem jelölhetsz barátnak!</i></font><br>
        <li>Ha meggondoltad a barátnak jelölést, tiltsd le a felhasználót, majd rögtön engedélyezd, így a barátnak jelölés semmissé lesz. Ettől viszont a felhasználó üzenetben tudomást szerez, hogy barátnak akartad jelölni (a tiltásról nem fog tudni)</li>
        <li>Ha a felhasználó nem igazolja vissza a barátságot, addig függőben marad a barátság.</li>
    </ol>

    <a id="validatefriend"></a>
    <h5><u>Baráti jelölés elfogadása, vagy elutasítása</u></h5>
    <ol>
		<li>A baráti jelölések listáját a <a href="profile.php?action_id=4">Profil --> Barátok</a> oldalon nézheted meg.</li>
        <li>Egy-egy kártyalapon megjelenik az adott felhasználók neve (<u>amelyre kattintva megnyithatod a felhasználó profilját</u>) és hogy mikor jártak utoljára az oldalon. Ezek alatt láthatsz két gombot, melyek egyikével elfogadhatod a barátságot, míg a másikkal elutasíthatod azt.</li>
        <li>Ha elfogadod a barátságot, akkor attól a perctől barátok lesztek mindaddíg, amíg valamelyik fél törli a barátságot. A barátság létrejöttéről értesítést kap a felhasználó.</li>
        <li>Ha elutasítod a barátságot, akkor nem történik semmi. Minden marad úgy, mielőtt barátnak jelölt volna a felhasználó. A barátság elutasításáról nem kap értesítést a felhasználó.</li>
    </ol>

    <a id="deletefriend"></a>
    <h5><u>Barátság törlése</u></h5>
    <ol>
		<li>A barátaid listáját a <a href="profile.php?action_id=4">Profil --> Barátok</a> oldalon nézheted meg.</li>
        <li>Egy-egy kártyalapon megjelenik az adott felhasználó neve (<u>amelyre kattintva megnyithatod a felhasználó profilját</u>), pontszáma, valamint hogy mikor járt utoljára az oldalon. Ezek alatt láthatod a <b>Barát törlése</b> gombot, mellyel törölheted a meglévő barátságot. A törlésről nem kap értesítést a felhasználó.</li>
        <i>Megj: A barátság törlését követően bármelyik fél újból kezdeményezheti a barátságot.</i>
    </ol>

    <a id="blockuser"></a>
    <h5><u>Felhasználó tiltása</u></h5>
    <ol>
		<li>Lépj a felhasználó oldalára! (Ha még nem tudsz rákeresni az illetőre a felhasználókeresővel, akkor keresgélj az oldalon a comment szekciókban, kvízek kedvelésénél, amíg megtalálod a nevét és arra kattints rá)</li>
        <li>A felhasználó oldalán lépj a <b>Felhasználó tiltása</b> gombra! Ezt a -Személyes adatok- rész alján találod meg.</li>
        <li>A felhasználó nem fog értesítést kapni a tiltásról.</li>
        <li>Amíg tiltva van a felhasználó, addíg nem jelölheted barátnak, és ő sem jelölhet téged barátnak.</li>
        <li>Egy általad letiltott felhasználó nem tilthat le téged.</li>
        <li><font color="red">Nem tilthatsz le olyan felhasználót, akivel barát vagy, illetve azt, aki barátnak jelölt!! Barát letiltásához előbb töröld a barátságot, vagy utasítsd el a baráti jelölést, és utána tilthatod le!</font></li>
    </ol>

    <a id="enableuser"></a>
    <h5><u>Tiltott felhasználó engedélyezése</u></h5>
    <ol>
		<li>Lépj a felhasználó oldalára! Ezt megteheted a <a href="profile.php?action_id=4">Profil --> Barátok</a> oldal legalján, ahol láthatod a tiltott felhasználóid listáját.</li>
        <li>A felhasználó oldalán lépj a <b>Felhasználó engedélyezése</b> gombra! Ezt a -Személyes adatok- rész alján találod meg. A felhasználó nem fog erről értesítést kapni.</li>
        <li>Felhasználó engedélyezése után mindkét fél előlről kezdheti a baráti jelölést.</li>
    </ol>
    </div>

    <?php
}

function profile_data()
{
    ?><a id="start"></a>
    <h3 class='text-center'>Profil információk, beállítások</h3>
	<div id="topic_maindiv">
    <h5><u>Személyes adatok megtekintése</u></h5>
    <ul>
		<li>A profilod <a href="profile.php?action_id=1">ezen az oldalon</a> láthatod.</li>
        <li>Baloldalon a személyes adataidat és pár statisztikai adatot nézhetsz meg. Ez a rész mindig látható, amíg a profilodon vagy. <br>Fontos!! <u>Más felhasználók számára rejtett marad minden személyes adatod (pl: Teljes név, email-cím), de a <b>statisztikai adataidat nagy részét látni fogják.</b></u> Ha ezeket az információkat is el akarod rejteni más felhasználók elől, akkor állítsd be a profilod rejtettségét. <a href="wiki.php?whatRules=10#hideprofile_a">Lásd bővebben!</a></li>
    </ul>

    <a id="lastquizzes"></a>
	<h5><u>Legutóbbi kvízek megtekintése</u></h5>
    <ul>
		<li>A profilod <a href="profile.php?action_id=1">Legutóbbi kvízek</a> részénél láthatod.</li>
        <li>A 20 legutóbbi próbálkozásod eredményét és időpontját láthatod részvételi idő szerint csökkenő sorrendben. Ha többet szeretnél látni, akkor lépj a <a href="profile.php?action_id=3">Kvízek --> Minden kvíz</a> részre.</li>
        <li><b>Ezt a részt más felhasználók is megtekinthetik, ha rálépnek a profilodra.</b> Ha ezeket is el szeretnéd rejteni más felhasználók elől, akkor állítsd be a profilod rejtettségét. <a href="wiki.php?whatRules=10#hideprofile_a">Lásd bővebben!</a></li>
        <li>Ugyanitt lehetőséged van kiexportálni PDF-be és letölteni a kvízen elért eredményedet és a további részleteket a PDF iconra kattintva. Megjegyzés! Nem minden kvíz esetén jeleníthetők meg az elért eredmény részletei, melynek az alábbi okai lehetnek:</li>
            &emsp;- elfogyott az ellenõrzési lehetõségeid száma ennél a kvíznél.<br>
            &emsp;- nem érted el legalább a 2. szintet.<br>
    </ul>

    <a id="quizzesinprocess"></a>
    <h5><u>Folyamatban levő kvízek megtekintése</u></h5>
    <ul>
		<li>A profilod <a href="profile.php?action_id=2">Kvízek --> Folyamatban levő kvízek</a> részénél láthatod.</li>
        <li>Itt tekinthető meg minden olyan kvízed, amely az 1., vagy a 2. fázisban van.</li>
        <li>Itt ellenőrizheted a kvízed állapotát, ahogy folyamatosan változik. Lehetőséged van háttérképeket beküldeni a kvízedhez, és megtekinteni az eddig beküldött kérdéseket.</li>
        <i>Megjegyzés! Ha a kvízed átkerül a végső stádiumba (3.fázis), akkor automatikusan eltűnik ebből a listából.</i>
        <li>Ezt a részt csak te láthatod.</li>
    </ul>

    <a id="allquizzes"></a>
    <h5><u>Összes kvíz</u></h5>
    <ul>
		<li>A profilod <a href="profile.php?action_id=3">Kvízek --> Minden kvíz</a> részénél láthatod.</li>
        <li>Itt tekinthető meg <b>minden kvíz próbálkozásod</b> (a regisztrációd pillanatától egészen mostanáig) kvízenként csoportosítva.</li>
        <li>A kvíz nevére lépve láthatod minden próbálkozásodat az adott kvízből, annak sikerességét, időpontját <i>(időpont szerint növekvő sorrendben)</i>, illetve lehetőség van kiexportálni és letölteni a próbálkozás részleteit. <u>(amennyiben ez engedélyezett)</u></li>
        <i><font color="red">Egy kvíz számodra akkor tekinthető <b><u>teljesítettnek</u></b>, ha a próbálkozásaid számától függetlenül, <b><u>legalább egyszer sikeres (ÁTMENŐ) eredményt érsz el</u></b>!</font></i>
        <li>Ezt a részt csak te láthatod.</li>
    </ul>

    <a id="helps"></a>
    <h5><u>Segítség csomagok</u></h5>
    <ul>
		<li>A profilod <a href="profile.php?action_id=5">Beállítások --> Segítség csomagok</a> részénél láthatod.</li>
        <li>Minden szinten, Prémiumtól függően más-más pontösszegért váltható be egy segítség csomag. Ezekről az árakról bővebben olvashatsz <a href="profile.php?action_id=5">ugyanitt</a>. Csak a csomagok számot kell beírnod a mezőbe, így az adott pontösszeget levonjuk tőled és cserébe jóváírjuk a kért csomagokat!</li>
        <li>Fontos! Egy ilyen művelet <u>NEM vonható vissza!</u></li>
        <li>Egy csomag 3 különböző segítséget tartalmaz, mindenikből egy-egyet, melyek a következők:</li>
            &emsp;- <b>1 : 3</b> - más néven "harmadoló"; Ez a segítség eltüntet egy helytelen választ, így rögtön egyharmad esélyed lesz kiválasztani a helyes választ.<br>
            &emsp;- <b>50 : 50</b> - más néven "felező"; Ahogy a neve is sugallja, ez a segítség eltüntet 2 helytelen választ, így 50%-os esélyed lesz kiválasztani a helyes választ.<br>
            &emsp;- <b>100%</b> - ez a segítség a legerősebb hiszen konkrétan megmutatja a helyes választ úgy, hogy eltünteti mind a 3 helytelen választ.<br>
        <li>A kvíz során te döntheted el, hogy mikor melyik segítséget használod fel.</li>
        <li><font color="red">Megjegyzés: A segítség csomagok kizárólag az <b>Főoldal --> Általános kvíz --> Vegyes kvíz</b> típusú kvízek során használhatók fel. (Minden menetben csak egy csomag áll rendelkezésre)
        <br>Egy csomag már akkor elhasználtnak tekinthető, ha egy kvíz során már egy segítséget felhasználsz a háromból.</font></li>
    </ul>

    <a id="hideprofile_a"></a>
    <h5><u>Profil retettség</u></h5>
    <ul>
		<li><b>Mit jelent a profilom rejtettsége?</b> Válasz: A Profil rejtettség egy olyan állapot, amelynek teljes időtartama alatt a Profilod nem lesz látható más felhasználók számára.</li>
        <li><b>Mi az előnye a Profil rejtettségnek?</b> Válasz: Mindenki számára egy nem létező felhasználóként tüntet fel a rendszer. Vagyis nem fognak tudni rákeresni a profilodra, így semmilyen információhoz nem fognak jutni veled kapcsolatban. (például: mikor jártál utoljára az oldalon, mennyi pontod van, melyek a legutóbbi kvízeid és azok eredményei, stb.) <br><font color="red">Kivétel: a Ranglisták rész</font>.</li>
        <li><b>Kik állíthatják be a profiljuk rejtettségét?</b> Válasz: Rangtól függetlenül, azok a felhasználók állíthatják be a profiljuk rejtettségét, akik éppen nincsenek WARN alatt és elegendő pontszámuk van.</li>
        <li><b>Hogyan állíthatom be a Profilom rejtettségét?</b> Válasz: Lépj a profilod <a href="profile.php?action_id=6">Beállítások --> Profil rejtettség</a> részre és kattints az ott látható piros <u>MEHET</u> gombra.</li>
        <li><b>Megjegyzések:</b> <br><i><font color="red">
            &emsp;- Egy havi profil rejtettség ára 500 pont. (Kivéve Prémium felhasználók, akik számára ez ingyenes.)<br>
            &emsp;- Egyszerre csak 1 hónapnyi profil rejtettség állítható be. A Profil rejtettség a 30 napos idő leteltével automatikusan kikapcsol (erről értesítést kapsz), ami természetesen újabb 30 napra megújítható.<br>
            &emsp;- Ez a beállítás NEM vonható vissza semmilyen körülmények között!<br>
            &emsp;- A WARN-ok automatikusan eltörlik a Profil rejtettséget és annak lejártáig nem használható ez a funkció.<br>
        </font></i></li>
    </ul>

    <a id="premium"></a>
    <h5><u>PRÉMIUM tagság</u></h5>
    <ul>
		<li>Lépj a profilod <a href="profile.php?action_id=7">Beállítások --> Prémium tagság</a> részére.</li>
        <li>Minden szinten <b>15000 pontért</b> (tizenötezer) állítható be a Prémium egy felhasználó számára, amely <u>30 napig érvényes</u>. Az egy hónap lejárta után véget ér a Prémium tagság (erről értesítést kapsz), ami megújítható újabb 30 napra.</li>
        <li>Fontos! Egy ilyen művelet <u>NEM vonható vissza!</u></li>
        <li>A Prémium tagság előnyei:</li>
            &emsp;- A Chat használata rangtól függetlenül (üzenetküldés, csoport létrehozás)<br>
            &emsp;- A Profil rejtettség INGYENES beállítása<br>
            &emsp;- Segítség vásárlása 4 pont/csomag értékben rangtól függetlenül<br>
            &emsp;- Jogosultság saját kérés kiírására rangtól függetlenül<br>
            &emsp;- Jogosultság kérések teljesítésére rangtól függetlenül<br>
            &emsp;- Jogosultság új, saját kvíz létrehozására<br>
            &emsp;- Jogosultság új kvízkérdések beküldésére<br>
            &emsp;- A felhasználókereső használata rangtól függetlenül<br>
        <li><font color="red">Megjegyzés: A WARN-ok automatikusan eltörlik a Prémium tagságot és annak lejártáig nem használható ez a funkció.<br></font></li>
    </ul>

    <a id="acceptprivatemsg"></a>
    <h5><u>Üzenetek fogadásának korlátozása</u></h5>
    <ul>
		<li>Lépj a profilod <a href="profile.php?action_id=9">Beállítások --> Üzenetek fogadása</a> részére.</li>
        <li>Itt lehetőséged van korlátozni a bejövő privát üzeneteket és módosítani ezt a beállítást. Ez személyes igények tekintetében bármikor megváltoztatható.</li>
        <li>Csak válaszd ki, hogy milyen felhasználóktól szeretnél üzeneteket fogadni és lépj a Mentés gombra.</li>
    </ul>

    <a id="changepassword"></a>
    <h5><u>Jelszó megváltoztatása</u></h5>
    <ul>
		<li>Lépj a profilod <a href="profile.php?action_id=8">Beállítások --> Jelszó csere</a> részére.</li>
        <li>Itt lehetőséged van bármikor megváltoztatni a fiókod jelszavát az ott látható űrlap kitöltésével.</li>
    </ul>

    <a id="deleteaccount"></a>
    <h5><u>Saját fiók törlése</u></h5>
    <ul>
		<li>Lépj a profilod <a href="profile.php?action_id=10">Beállítások --> Fiók törlése</a> részére.</li>
        <li>Itt lehetőséged van bármikor törölni a fiókodat a <b>Fiók törlése</b> gombra kattintva.</li>
        <li><b><font color="red">FONTOS! Ez a művelet VÉGLEGES és nem vonható vissza!! Jól gondolod meg fiókod törlését, mert többé nem lesz lehetőséged ennek a visszaállítására!! A művelet véglegesítéséhez meg kell adnod a fiókod jelszavát!</b></font> </li>
    </ul>

    </div>
    <?php
}

function pm_data()
{
    ?><a id="start"></a>
    <h3 class='text-center'>Privát üzenetek</h3>
	<div id="topic_maindiv">
    <h5><u>Általános infók</u></h5>
    <ul>
        <h6>A következőkben nevezzük <u>"küldő fél"</u>-nek azt a felhasználót, aki szeretne privát üzenetet küldeni, illetve  <u>"fogadó fél"</u>-nek azt, akinek szeretnéd elküldeni az üzenetet.</h6>
        <li>Egy felhasználó bárkinek küldhet privát üzenet, amennyiben nem áll fenn az alábbi esetek egyike sem:</li>
            &emsp;- ha a küldő fél számára engedélyezve van a privát üzenet küldés joga<br>
            &emsp;- ha a fogadó fél <u>mindenkitől</u> fogad üzenetet. <i>Megjegyzés: Ha a fogadó fél csak adminoktól és a barátaitól fogad üzenetet és a küldő fél a fogadó fél barátja, akkor engedélyezett az üzenetküldés.</i><br>
            &emsp;- ha a küldő, vagy a fogadó fél egyike sem tiltotta le egymást. Vagyis tiltott felhasználónak nem küldhető privát üzenet, illetve, ha a fogadó fél letiltotta a küldőt, akkor sem lesz engedélyezve az üzenetküldés.<br>
        <li>Privát üzenet küldéséhez lépj a fogadó fél profiljára. Ha a fogadó fél barát, akkor a <a href="profile.php?action_id=4">Profil --> Barátok</a> oldalon a nevére kattintva könnyen eljuthatsz a profiljához. Majd ott az <b>Üzenet küldés</b> gombra kattintva megjelenik egy felugró ablak, ahová beírhatod az üzenetet és elküldheted. <br>
        <li><b><font color="red">Ha nem találod a fogadó fél profilját</font></b>, akkor lépj bármelyik felhasználó profiljára és az <u>Üzenet küldés</u> gombra kattintva megjelenő felugró ablakban <u>írd át a címzett nevét a fogadó fél felhasználónevére.</u> Így az elküldött üzenetet az kapja meg, akinek címezted a levelet. <br><b><font color="red">Megjegyzés: Rejtett felhasználónak való privát üzenet küldése is így történik!</font></b></li>
        <li>Ha nem szeretnél üzeneteket kapni egy felhasználótól, akkor le kell tiltanod! A felhasználók tiltásáról bővebben <a href="wiki.php?whatRules=9">itt</a> olvashatsz.<br></li>
        <li>Egy privát üzenet hossza max 5000 karakterből állhat (csak karakterek küldhetők)! Lehetőség van az emojik használatára is!</li>
		<li>Két privát üzenet küldése között legalább 5 percet kell várnod!</li>
        <li>A rendszer által küldött üzeneteket fogadnod kell és KÖTELEZŐ ELOLVASNI!</li>
        <li>Jelenleg nincs lehetőség a rendszerüzenetekre válaszolni, vagy privát üzenetet küldeni az admin felhasználóknak!</li>
    </ul>

    <h5><u>Privát üzenetek olvasása</u></h5>
    <ul>
        <li>A bejövő privát- és rendszerüzeneteidet az <b>Üzenetek</b> oldalon találod, vagy <a href="inbox.php">erre a linkre kattintva</a> nézheted meg! <u>Erre az oldalra lépéskor először mindig a rendszerüzenetek töltődnek be.</u> Baloldalon válaszd ki, hogy mely felhasználó üzeneteit szeretnéd olvasni a felhasználó nevére kattintva. <b><font color="red">FONTOS! A SYSTEM által küldött értesítések a rendszerüzenetek.</font></b></li>
        <li>Ha új értesítésed érkezik, akkor azt mindig az oldal fenti menüjében egy kis piros kör jelzi, amely az olvasatlan privát- és rendszerüzenetek számát mutatja. Amint egy olvasatlan üzenetet megjelölsz olvasottnak, ez a szám 1-el csökken. Ha nem marad több olvasatlan értesítés, akkor a piros kör eltűnik.</li>
        <li>Egy üzenet olvasottnak való megjelöléséhez kattints az adott üzenet jobb felső sarkában található <b>Láttam</b> gombra!</li>
        <li>Más felhasználók nem fogják tudni, mikor olvastad el az általuk küldött üzenetet, vagy mikor jelölted meg azt olvasottnak!!</li>
    </ul>
    </div>
    <?php
}

function chat_data()
{
    ?><a id="start"></a>
    <h3 class='text-center'>Chat funkciók</h3>
	<div id="topic_maindiv">
    <h5><u>Általános infók</u></h5>
    <ul>
        <li>A Chat az aktuális oldal fenti menüjéből érhető el a <a href="chat.php">Műveletek --> Chat megnyitása</a> linkeken keresztül.</li>
        <li>A Chat bármely felhasználó számára megnyitható, viszont <font color='red'>az üzenet küldése és új chat csoport létrehozása csak 2.RANG-tól lehetséges</font>!</li>
        <li>Baloldalon azon a csoportok neveit láthatod, melyeknek tagja vagy. Egy ilyen csoport nevére kattintva jobboldalon megjelennek a tagok által küldött chat üzenetek, illetve a csoport további adatai (pl: létrehozás ideje, tagok, stb.). Pirossal bekeretezett lesz annak a csoportnak a neve, amelyben épp vagy, így bármikor tudhatod, hogy éppen hová küldöd az üzenetet.</li>
        <li>A <b>Toggle</b> gombra kattintva elrejthető a csoport részleteit megjelenítő jobboldali rész, így a chat üzenetek kiterjeszthetők a képernyő jobb széléig. Ugyanerre a gombra kattintva pedig ismét előhozhatóak a részletek.</li>
        <li>Chat üzenetet a <b>Küldés</b> gomb segítségével küldhetsz el, vagy az <b>Enter billentyű lenyomásával</b>. (Csak karakterek és emojik küldhetők)</li>
        <li>A csoport üzeneteit a küldésük ideje szerint csökkenő sorrendben láthatod (legújabbak elől, régebbiek lennebb)</li>
        <li>A baloldalt látható csoportok listája minden pillanatban változik annak függvényében, hogy melyik csoportban írtak legutoljára a tagok (legelől jelennek meg az aktív csoportok).</li>
        <br>
        <li><u>Egy csoport üzeneteit kizárólag a tagok olvashatják.</u></li>
        <li>A <b>Nyilvános chatszoba</b> mindenki számára látható (mindenki tagja és nem lehet kilépni onnan), valamint az ott küldött üzenetek is bárki számára elolvashatók. A chat megnyitásakor mindig ez a csoport jelenik meg először. <b>Mivel ez egy nyilvános csoport, emiatt ELVÁRT A KULTURÁLT VISELKEDÉS ÉS SZÓHASZNÁLAT!!</b></li>
        <li>Ezt a Chatet nem ajánlott állandó chatelsére használni, mert <u>csak bizonyos számú üzenet olvasható vissza egy csoporton belül</u>. Így előfordulhat, hogy bizonyos üzeneteket nem fogsz tudni elolvasni, ha távol vagy, vagy sokáig nem lépsz be az oldalra! A rendszer amúgy sem küld értesítést, ha valaki írt üzenetet az egyik csoportban.</li>
    </ul>

    <a id="newgroup"></a>
    <h5><u>Új csoport létrehozás</u></h5>
    <ul> 
        <li>Lépj a baloldalon látható <b>Új csoport</b> gombra!</li>
        <li>Adj nevet a létrehozandó csoportnak (ajánlott egyedi nevet választani a félreértések végett) és válaszd ki a leendő tagokat az ott megjelenő listából (<b>legalább egyet!</b>).  <br><font color='red'>FONTOS! Csak a barátaidat hívhatod meg a csoportba! Ebből következik, hogy ha nincsen egy barátod sem, akkor nem hozhatsz létre csoportot!</font> <br>További lehetőség van beállítani, hogy a későbbiekben kik vehetnek fel újabb tagokat.</li>
        <li>A létrehozást követően pillanatok alatt megjelenik baloldalt az új csoportod neve és már használható is a felvett tagok és a te számodra.</li>
        <li>A csoport létrehozója lesz a <u>csoport adminisztrátora</u>. Ez a jog nem ruházható át senkire. Az adminisztrátornak jogában áll tagokat felvenni, eltávolítani és törölni a csoportot; viszont nem léphet ki a csoportból!</li>
        <li><i>Megjegyzés: Csak 2.RANG-tól felfele hozhatók létre Chat csoportok!</i></li>
        <li>Egy csoport a létrehozásától kezdve addig létezik, amíg azt nem törli az adminisztrátora, vagy az oldal adminjai.</li>
    </ul>

    <a id="addmember"></a>
    <h5><u>Új tag felvétele a csoportba</u></h5>
    <ul> 
        <li>Lépj az adott csoporton belül a jobboldalon (csoport részleteinél) látható <b>Új tag felvétele</b> gombra! Az ott megjelenő lista azokat a barátaidat tartalmazza, amelyek még nem tagjai a csoportnak. Így tudni fogod, hogy kik azok, akik már csatlakoztak a csoportnak és kik nem, valamint elkerülhető, hogy egy felhasználót ne add hozzá kétszer a csoporthoz. Ebből értelemszerűen következik, hogy csak a barátaid hívhatók meg egy csoportba.</li>
        <li>Egyszerre csak egy felhasználó vehető fel a csoportba, ezért érdemes már a létrehozáskor jól átgondolni, hogy kik lesznek a csoport tagjai.</li>
        <li>A csoport összes tagja és az újonnan felvett tag a chat jobboldali részén látható a részleteknél.</li>
        <li><i>Megjegyzés: Ennek a funkciónak a használata nincs szinthez kötve, hanem az adminisztrátor dönti el a csoport létrehozásakor, hogy csak ő, vagy a csoport bármely tagja hívhat-e meg új felhasználót. (Ez a beállítás nem változatható meg az adminisztrátor által sem a későbbiekben!)</i></li>
    </ul>

    <a id="exitgroup"></a>
    <h5><u>Kilépés a csoportból</u></h5>
    <ul> 
        <li>Lépj az adott csoporton belül a jobboldalon (csoport tagjai alatt) látható <b>Kilépés a csoportból</b> gombra, majd erősítsd meg a döntésed a felugró ablakban látható IGEN gombra kattintva!</li>
        <li>A csoport elhagyását követően már nem fogod látni a csoport üzeneteit, és semmilyen információt, ami ezzel kapcsolatos, hiszen már nem leszel a tagja. A későbbiekben bármikor újra visszavehetnek téged a csoport tagjai (az adminisztrátor, vagy a többi tag, ha engedélyezve van számukra az új tag felvétele)</li>
        <li>Ez a funkció bármely tag számára bármikor engedélyezve van, <u>kivéve a csoport adminisztrátorát</u>. Az adminok nem hagyhatják el az általuk létrehozott csoportot, mivel az admin jog nem ruházható át senkire sem és mindig kell legyen legalább egy felhasználó, aki a csoport tagja. <br><i>Egy csoport adminisztrátor csak úgy léphet ki egy csoportból, ha TÖRLI A CSOPORTOT.</i></li>
    </ul>

    <a id="deletegroup"></a>
    <h5><u>Csoport törlése</u></h5>
    <ul> 
        <li><u>Ez a művelet csak a csoport adminisztrátornának engedélyezett!</u><br> A csoport törlésével véglegesen lezárul a csoport. Ezt követően minden tag eltávolításra kerül a csoportból, az admint is beleértve, valamint az ottani chat üzenetek sem lesznek többé láthatóak. (a csoport többé nem fog létezni) Ez a művelet csak egyszer hajtható végre és nem vonható vissza!</li>
        <li>A funkció használatához lépj az adott csoporton belül a jobboldalon (csoport tagjai alatt) látható <b>Csoport törlése</b> gombra (ezt csak az adminisztrátor látja), majd erősítsd meg a döntésed a felugró ablakban látható Csoport törlése gombra kattintva!</li>
    </ul>

    <a id="removemember"></a>
    <h5><u>Tag eltávolítása</u></h5>
    <ul> 
        <li>Egy csoportból csak az adminisztrátor távolíthat el tagokat!</li>
        <li>A funkció használatához lépj a csoport tagjainak listájához (jobboldalon a részleteknél). Minden tag mellett látható egy piros <b>Eltávolítás</b> gomb. (ezt csak az adminisztrátor látja), melyre kattintva egy felugró ablakban megerősítheted a döntésed.</li>
        <li>Egy eltávolított tag bármikor újra visszavehető a csoportba!</li>
        <li>Az adminisztrátor nem törölheti saját magát a csoportból!</li>
    </ul>

    <a id="otherinfo"></a>
    <h5><u>Egyéb megjegyzések</u></h5>
    <ul> 
        <li>Lehetőség van megnézni a csoport előzményeit. Ez a csoport tagok alatt látható <b>A csoport előzményei</b> gombra kattintva olvasható egy felugró ablakban. Ez tartalmazza a csoport létrehozásának pontos dátumát, a mindenkori felvett és eltávolított tagok neveit és ezek időpontját, valamint a felhasználó nevét, aki felvette, vagy eltávolította őket a csoportból.</li>
        <li>Egy felhasználó korlátlan számú csoport tagja lehet.</li>
        <li>A csoportból eltávolított felhasználók nevei nem lesznek láthatóak az általuk hagyott chat üzenetek fejlécében.</li>
    </ul>
    </div>
    <?php
}

function news_data()
{
    ?><a id="start"></a>
    <h3 class='text-center'>Hírek a Főoldalon</h3>
	<div id="topic_maindiv">
    <h5><u>Általános infók</u></h5>
    <ul>
        <li>A Főoldalon lefele haladva híreket lehet olvasni közzétételük ideje szerint csökkenő sorrendben (az újak elől, régebbiek lennebb)</li>
        <li>Általában olyan hírek olvashatók, amelyek egy bizonyos kvíz megjelenéséről szolgálnak információval.</li>
        <li>Egy hír tartalmazza a következőket:</li>
            &emsp;- a közzétevő felhasználónevét. <br>
                &emsp;&emsp; <i>Megjegyzés: Admin felhasználók esetén a <b>SYSTEM</b> név lesz kiírva a felhasználónév helyett</i> <br>
            &emsp;- a közzétevés dátumát <br>
            &emsp;- egy hír opcionálisan tartalmazhat egy képet, illetve egy fájlt is, amely letölthető <br>
        <li>Naponta csak egy hír tehető közzé az oldalon.</li>
    </ul>

    <a id="newnews"></a>
    <h5><u>Új hír kiírása</u></h5>
    <ul>
        <li>Egy hír esetében az alábbi követelmények vannak:</li>
            &emsp;- a hír ne legyen reklám egy külső szervezet/oldal számára<br>
            &emsp;- a hír nem tartalmazhat személyes információkat, bankszámla- és egyéb fizetéssel kapcsolatos adatokat<br>
            &emsp;- a hír tartalma szigorúan egy kvízzel, vagy az oldal egy bármilyen témájával/pontjával kapcsolatos lehet<br>
            &emsp;- felhasználók sértegetése szigorúan tilos!<br>
        <li>Lépj a Főoldalon az <b>Új hír kiírása</b> gombra és töltsd ki az ott megjelenő kis űrlapot. <b>Utólagos módosításra NINCS LEHETŐSÉG, kérünk erre figyeljetek!</b></li>
        <li>Minden hír esetében kötelező egy rövid címet adni! A hír tartalma legalább 25 karakter hosszúságú kell legyen!</li>
        <li>Opcionálisan feltölthető egy kép, amely a hírhez kapcsolódik, valamint egy fájl is, amely letölthető, ha a rákattintunk. Ez nem kötelező. Amennyiben képet szeretnél közzétenni a hír mellé, vigyázz az alábbi kritériumokra: <u>csak .jpg, .jpeg, vagy .png formátumú képet lehet feltölteni, melynek mérete maximum 2 MB (megabájt) lehet. A feltöltendő fájl mérete maximum 4 MB lehet és csak az alábbi típusokat fogadjuk el: .zip, .pdf, .docx. Több fájl esetén ajánlott összecsomagolni egy zip fájlba és azt tölteni fel.</u></li>
        <li>A hír addig marad látható az oldalon, amíg nem törli a közzétevője, vagy az adminok.</li>
    </ul>

    <a id="deletenews"></a>
    <h5><u>Hír törlése</u></h5>
    <ul>
        <li>Keresd meg a Főoldalon a törlendő hírt és kattints a <b>Hír törlése</b> piros gombra, amely a hír jobb felső sarkában található! A megjelenő felugró ablakban fogalmazd meg röviden, hogy miért szeretnéd törölni a hírt, majd lépj a <u>Törlés</u> gombra a megerősítéshez!</li>
        <li>Egy hír törlése <u>végleges és nem vonható vissza! A csatolt kép és fájlok is törlődnek a szerverről</u>!</li>
        <li>Egy hírt csak a közzétevője törölhet, amikor úgy látja jónak, illetve az adminok, ha úgy ítélik meg, hogy nem felel meg az elvárásoknak!</li>
    </ul>

    <?php
}

function points_data()
{
    ?><a id="start"></a>
    <h3 class='text-center'>Pontrendszer</h3>
	<div id="topic_maindiv">
    <h5><u>Általános infók</u></h5>
    <ul>
        <li>Minden felhasználó esetében a regisztrációt követően a rendszer automatikusan elindít egy pontozást, melynek keretén belül hozzátársít egy pontösszeget. <b>Kezdetben ez a pontszám 0 pont</b>.</li>
        <li>További pontokat lehet szerezni is, de veszíteni is (előfordulhat hogy egy felhasználónak mínusz pontszáma lesz), melyet alább részletezünk.</li>
        <li>Minél nagyobb pontszámmal rendelkezik egy felhasználó, annál több lehetősége van az oldalon. (például a szintlépéshez szükséges, de nem elégséges feltétel a nagy pontszám). A változó pontszám határozza meg főképp egy felhasználó rangját (mert mivel lehet veszíteni is pontokat, ezért visszalépés történik egy előző rangra;  pontok gyűjtése során pedig szintlépés lesz). Megjegyzés: <font color='red'>A pontszám önmagában nem határozza meg egy felhasználó rangját!!</font> A rangokról bővebben <a href="wiki.php?whatRules=3">itt</a> olvashatsz.</li>
        <li>Naponta KORLÁTLAN pontszám gyűjthető!</li>
        <li>Pontok csak akkor gyűjthetők, ha engedélyezve van a felhasználó számára a pontszerzés joga!</li>
    </ul>

    <h5><u>Pontok gyűjtése</u></h5>
    <ul>
        <li>a bejelentkezéskor <b>naponta egy alkalommal 2*RANG pont</b> kapható! (a RANG a felhasználó aktuális szintjét/rangját jelzi, amely 1 és 5 közötti egész szám)</li>
        <li>a regisztrációt követően automatikusan jóváíródik <b>1 pont</b></li>
        <li>a kvízeken <u>HELYESEN megválaszolt kérdésekért</u> <b>egy-egy pont</b> kapható, <u>amennyiben a teszt eredménye sikeres</u>!</li>
        <li>minden <u>kvíz első próbálkozása</u> után <b>bónuszpontok </b> szerezhetőek, (egy teszt során a bónuszpontok száma = kb. a teszten HELYESEN megválaszolt kérdések száma), <u>amennyiben a tesz eredménye sikeres</u>!</li>
        <li>minden beküldött és <u>ELFOGADOTT</u> kvízkérdésere <b>+15 pont</b> íródik jóvá.</li>
        <li>minden kvíz elkészítéséért <b>+300 pont</b> jutalom jár. (Miután a kvízt teljesen elkészítetted és aktív állapotba került.)</li>
        <li>egy kérés teljesítésekor jóváíródik a <b>kérésre felajánlott pontszám</b>. (Miután a teljesített kvíz aktív állapotba került.)</li>
        <li>minden <b>kiemelt kvízen</b> elért eredményért (Kiemelt kvíz a Főoldalon látható alkalmanként) <b>nagyobb pontmennyiség (jutalom pontszám)</b> íródik jóvá. (a fix pontszám értékéről a Főoldalon a Kiemelt kvíz résznél olvashatsz)</li>
    </ul>

    <h5><u>Pontok levonása és felhasználása</u></h5>
    <ul>
        <li>Adminok által <b>ELUTASÍTOTT</b>-nak minősített beküldött <u>kvízkérdésekért</u> <b>0-100 pont</b> közötti pontszám kerül levonásra. (azaz előfordulhat, hogy nem vonnak le pontokat)</li>
        <li>A felhasználó által <b>kérésekre felajánlott pontszám</b> levonódik a felhasználótól</li>
        <li><u>Segítség csomagok vásárlása</u> esetén is meghatározott összeg levonódik a pontokból</li>
        <li>A <u>profil rejtettég</u> beállítása során <b>-500 pont</b> vonódik le (kivéve Prémium felhasználók)</li>
        <li><u>Egy hónapos Prémium csomag</u> beváltása <b>-15000 pontot</b> hagy jóváírásra.</li>
        <li><font color='red'>WARN / Figyelmeztetésben részesült felhasználóktól előre nem meghatározott pontszámot vonunk le (az adminok döntik el a levonandó pontösszeget; bármekkora összeg lehet)</font></li>
    </ul>
    <?php
}

function faq()
{
	?><a id="start"></a>
	<div id="gyik_container">
    <h3 class='text-center'>Gyakran ismételt kérdések (GY.I.K.)</h3><br><br>
	<ul>

    <li>
		<b>Épp most regisztráltam az oldalra, de félek elindítani az első kvízt, mert nem tudom hogyan kell végigvinni és nem akarok hibázni. Van esetleg olyan lehetőség, ahol megnézhetem milyen lesz a kvíz és azt próbálhatom ki, hogy hogyan kell helyesen résztvenni egy ilyen kvízen?</b><br>
		Igen, lépj a Főoldalon a <b>Műveletek --> Általános kvíz</b> linkre, majd a megjelenő ablakban válaszd a GYAKORLÓ kvízt. Az ezen a kvízen elért eredmény nem fog sehová sem számítani.<br><br>
	</li>

	<li>
		<b>Van lehetőség felhasználónév váltásra?</b><br>
		Nincs és nem is lesz erre lehetőség.<br><br>
	</li>
	<li>
		<b>Mi a WARN / figyelmeztetés és mit kell tudni róla?</b><br>
		A WARN egy büntetés, amelyet a felhasználó bizonyos tetteiért von maga után. A Warn-nak van egy időtartama, és annak lejártáig bizonyos jogokat megvonnak a felhasználótól. Minden figyelmeztetés pontlevonással jár, melyet a warn-t adó admin határoz meg. Ő dönti el, hogy pontosan mely jogok kerülnek megvonásra. A <a href="profile.php">Profil --> Személyes adatok</a> részénél látható, hogy mikor jár le az adott figyelmeztetés. Miután lejárt a warn időtartama, automatikusan újból jóváíródik minden megvont jog, viszont a felhasználó nem kapja vissza a levont pontokat és az Össz-figyelmeztetés számláló is 1-el növekszik.<br><br>
	</li>

    <li>
		<b>Mi az Általános kvíz? Hol érhető el és miben különbözik a többi kvíztől?</b><br>
		Az Általános kvíz 10 tág témakörben VEGYESEN tartalmaz kérdéseket. Az indításhoz lépj a <b>Főoldalra</b>, majd a menüből válaszd ki a <b>Műveletek --> Általános kvíz</b> linket, majd ott válaszd a <b>Vegyes kvíz</b>t.
        A lényeges különbség a többi kvízhez képest: itt felhasználhatóak a segítségcsomagok, bónuszpontok is szerezhetők minden menet során, nincs ellenőrizve az átmenés, és ezen próbálkozások NEM SZÁMÍTANAK BELE a statisztikába!!<br><br>
	</li>



	</ul>
	</div>
	<?php
}

?>