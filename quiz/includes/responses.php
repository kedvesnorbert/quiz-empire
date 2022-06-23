<?php
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
	require_once("../error.php");
	die(); /*Direct Access Not Allowed */
	exit();
};

function err_session_timeout()
{
    return "Sajnáljuk! A munkamenet ideje lejárt. Jelentkezzen be újra!";
}

function err_missing_data()
{
    return "Hiba történt! Néhány adat nem érkezett meg a szerverhez, vagy azok hibásak! Nem sikerűlt végrehajtani a műveletet!";
}

function err_db()
{
    return "Az adatbázishoz való kapcsolódás sikertelen volt! (Failed to establish database connection!) - Database Error Occurred";
}

function err_playquiz()
{
    return "Hiba történt a kvíz betöltése során! Itt most nincs függőben levő kvíz!";
}

function err_notfound()
{
    return "Nincs találat!";
}

function is_valid_url($url)
{
    $urls = array("/chat.php", "/inbox.php", "/index.php", "/newquestion.php", "/newquiz.php", "/newrequest.php", "/profile.php", "/quizdetails.php", "/quizzes.php", "/requests.php", "/wiki.php", "/searchuser.php");
    foreach($urls as $i)
    {
        if(strpos(urldecode($url), $i) === 0)
        {
            return true;
        }
    }
    return false;
}

function is_valid_adminurl($url)
{
    $urls = array("/admin/allquiz.php", "/admin/allquizdetail.php", "/admin/backgrounds.php", "/admin/questions.php", "/admin/quizcomments.php", "/admin/quizresults.php", "/admin/userdetails.php", "/admin/users.php");
    foreach($urls as $i)
    {
        if(strpos(urldecode($url), $i) === 0)
        {
            return true;
        }
    }
    return false;
}

function inbox_msg_types()
{
    return "3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 29, 33, 35, 36, 37";
}
?>