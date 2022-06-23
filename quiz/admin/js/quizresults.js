function delete_played_quiz(x, y, z, t, u) {
    $('#dialogDeletePlayedQuiz').html("<center><div id='deletequizresult_title'>Biztos, hogy törlöd a/az <u><i>" + y + "</i></u> nevű kvíz (" + x + ". teszt) eredményét?</div><br><table width='90%'><tr><td>A teszt adatai: <td><b>ID:</b> " + x + "<br><b>Témakör:</b> " + y + "<br><b>Felhasználó:</b> " + z + "<br><b>Eredmény:</b> " + t + "%<br><b>Időpont:</b> " + u + "</table><br></center><p id='deletequiz_alert'>Figyelem! Ez a művelet nem vonható vissza!</p>");

    if (x > 0 && x.match(/^[0-9]+$/)) {
        $("#dialogDeletePlayedQuiz").dialog({
            maxWidth: 600,
            width: 600,
            height: 360,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Törlés": function () {
                    jQuery.ajax({
                        type: "POST",
                        url: "ajax/delete_played_quiz.php",
                        data: { p_testid: x },
                        dataType: "json",
                        cache: false,
                        success: function (data) {
                            if (data.resp == "ok") {
                                alert("Teszt törölve!");
                                $('#tr_testid' + x).remove();
                            }
                            else {
                                alert(data.resp);
                            }
                        },
                        fail: function () {
                            alert("Failed!");
                        }
                    });
                    $(this).dialog('destroy');

                },
                "Mégsem": function () {
                    $(this).dialog('destroy');
                }
            }
        });

    }
    else {
        alert("Hibás bemeneti adat!");
    }
}