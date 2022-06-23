function confirm_newquiz(x, y) {
    $('#dialogConfirmNewQuiz').html("<div id='confirmnewquiz_title'>Biztos, hogy jóváhagyod a/az <u><i>" + y + "</i></u> nevű kvízt?</div><br><span id='confirmnewquiz_notes'>Megjegyzés! Ennek hatására a kvíz átkerül a 2. fázisba és lehetővé válik a kérdések beküldése ebben a témakörben.</span>");

    if (x > 0 && x.match(/^[0-9]+$/)) {
        $("#dialogConfirmNewQuiz").dialog({
            maxWidth: 600,
            width: 600,
            height: 255,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Jóváhagyás": function () {
                    jQuery.ajax({
                        type: "POST",
                        url: "ajax/confirm_newquiz.php",
                        data: { p_quizid: x },
                        dataType: "json",
                        cache: false,
                        success: function (data) {
                            if (data.resp == "ok") {
                                alert("Kvíz jóváhagyva!");
                                $('.mainDatasQuiz' + x).remove();
                                $('.detailsQuiz' + x).remove();
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

function reject_newquiz(x, y) {
    $('#dialogRejectNewQuiz').html("<center><div id='rejectquiz_title'>Biztos, hogy törlöd a/az <u><i>" + y + "</i></u> nevű kvízt?</div><input type='text' id='rejectquiz_text' placeholder='Írd be a törlés okát!' maxlength='150'></center>Gyakori okok a törlésre:<br><button id='dq_reason1' class='dq_reasons' onclick='add_reject_reason(1, 0)'>Nem megfelelő leírás. </button><button id='dq_reason2' class='dq_reasons' onclick='add_reject_reason(2, 0)'>Duplikált kvíz. </button><button id='dq_reason3' class='dq_reasons' onclick='add_reject_reason(3, 0)'>Tiltott témakör. </button><button id='dq_reason4' class='dq_reasons' onclick='add_reject_reason(4, 0)'>Hosszú / Bonyolult kvíznév. </button><button id='dq_reason5' class='dq_reasons' onclick='add_reject_reason(5, 0)'>Nem egyértelmű kvíznév, vagy leírás. </button><button id='dq_reason6' class='dq_reasons' onclick='add_reject_reason(6, 0)'>Túl tág témakör. </button>");

    if (x > 0 && x.match(/^[0-9]+$/)) {
        $("#dialogRejectNewQuiz").dialog({
            maxWidth: 600,
            width: 600,
            height: 375,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Elutasítás": function () {
                    var rejectquiz_text = $('#rejectquiz_text').val();
                    if (rejectquiz_text.length < 5 || rejectquiz_text.length > 100) {
                        alert("A kvíz törlésének oka 5-100 karakter legyen!");
                    }
                    else {
                        jQuery.ajax({
                            type: "POST",
                            url: "ajax/reject_newquiz.php",
                            data: { p_quizid: x, p_rejectquiz_reason: rejectquiz_text },
                            dataType: "json",
                            cache: false,
                            success: function (data) {
                                if (data.resp == "ok") {
                                    alert("Kvíz törölve!");
                                    $('.mainDatasQuiz' + x).remove();
                                    $('.detailsQuiz' + x).remove();
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
                        
                    }

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

function accept_newquiz(x, y) {
    $('#dialogAcceptNewQuiz').html("<div id='acceptnewquiz_title'>Biztos, hogy elfogadod a/az <u><i>" + y + "</i></u> nevű kvízt?</div><br><span id='acceptnewquiz_notes'>Megjegyzés! Ennek hatására a kvíz átkerül a végső fázisba (3. fázis - Aktív kvízek) és elérhető lesz a felhasználók számára (részt vehetnek a kvízen).</span>");

    if (x > 0 && x.match(/^[0-9]+$/)) {
        $("#dialogAcceptNewQuiz").dialog({
            maxWidth: 600,
            width: 600,
            height: 255,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "ELFOGADÁS": function () {
                    jQuery.ajax({
                        type: "POST",
                        url: "ajax/accept_newquiz.php",
                        data: { p_quizid: x },
                        dataType: "json",
                        cache: false,
                        success: function (data) {
                            if (data.resp == "ok") {
                                alert("Kvíz ELFOGADVA!");
                                $('.mainDatasQuiz' + x).remove();
                                $('.detailsQuiz' + x).remove();
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

function add_reject_reason(x, y){
    if(y == 0){
        $('#rejectquiz_text').val($('#rejectquiz_text').val() + $('#dq_reason' + x).text());
    }
    else{
        $('#rejectrequest_text').val($('#rejectrequest_text').val() + $('#dq_reason' + x).text());
    }
}

function confirm_request(x, y) {
    $('#dialogConfirmRequest').html("<div id='confirmrequest_title'>Biztos, hogy jóváhagyod a/az <u><i>" + y + "</i></u> nevű kérést?</div><br><span id='confirmrequest_notes'>Megjegyzés! Ennek hatására a kérés átkerül a 2. fázisba és lehetővé válik a teljesítése (a kérés elvállalása).</span>");

    if (x > 0 && x.match(/^[0-9]+$/)) {
        $("#dialogConfirmRequest").dialog({
            maxWidth: 600,
            width: 600,
            height: 255,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Jóváhagyás": function () {
                    jQuery.ajax({
                        type: "POST",
                        url: "ajax/confirm_request.php",
                        data: { p_quizid: x },
                        dataType: "json",
                        cache: false,
                        success: function (data) {
                            if (data.resp == "ok") {
                                alert("Kérés jóváhagyva!");
                                $('.mainDatasQuiz' + x).remove();
                                $('.detailsQuiz' + x).remove();
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

function reject_request(x, y) {
    $('#dialogRejectRequest').html("<center><div id='rejectrequest_title'>Biztos, hogy törlöd a/az <u><i>" + y + "</i></u> nevű kérést?</div><input type='text' id='rejectrequest_text' placeholder='Írd be a törlés okát!' maxlength='150'></center>Gyakori okok a törlésre:<br><button id='dq_reason1' class='dq_reasons' onclick='add_reject_reason(1, 1)'>Nem megfelelő leírás. </button><button id='dq_reason2' class='dq_reasons' onclick='add_reject_reason(2, 1)'>Duplikált kvíz. </button><button id='dq_reason3' class='dq_reasons' onclick='add_reject_reason(3, 1)'>Tiltott témakör. </button><button id='dq_reason4' class='dq_reasons' onclick='add_reject_reason(4, 1)'>Hosszú / Bonyolult kvíznév. </button><button id='dq_reason5' class='dq_reasons' onclick='add_reject_reason(5, 1)'>Nem egyértelmű kvíznév, vagy leírás. </button><button id='dq_reason6' class='dq_reasons' onclick='add_reject_reason(6, 1)'>Túl tág témakör. </button>");

    if (x > 0 && x.match(/^[0-9]+$/)) {
        $("#dialogRejectRequest").dialog({
            maxWidth: 600,
            width: 600,
            height: 375,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Elutasítás": function () {
                    var rejectrequest_text = $('#rejectrequest_text').val();
                    if (rejectrequest_text.length < 5 || rejectrequest_text.length > 100) {
                        alert("A kérés törlésének oka 5-100 karakter legyen!");
                    }
                    else {
                        jQuery.ajax({
                            type: "POST",
                            url: "ajax/reject_request.php",
                            data: { p_quizid: x, p_rejectrequest_reason: rejectrequest_text },
                            dataType: "json",
                            cache: false,
                            success: function (data) {
                                if (data.resp == "ok") {
                                    alert("Kérés törölve!");
                                    $('.mainDatasQuiz' + x).remove();
                                    $('.detailsQuiz' + x).remove();
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

                    }

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

function failed_request_fulfillment(x, y, t, dl, bk, bell, bek, bkk, late) {
    if(late < 0){
        late = "Még nem járt le a határidő!!!";
    }
    else{
        late = late + " nap késés!";
    }
    $('#dialogFailedRequestFulfillment').html("<center><div id='failedrequestfulfillment_title'>Biztos, hogy törlöd a/az <u><i>" + y + "</i></u> nevű kérés jelenlegi teljesítését?</div></center><br>Teljesítést elvállalta: " + t + "<br>Teljesítési határidő: <u>" + dl + "</u> ( " + late + " )<br><br>Beküldött / Ellenőrzött kérdések: " + bk + " / " + bell + "<br><b>Elfogadott / Kötelező kérdések: " + bek + " / " + bkk + "</b><br><br><span style='color:red;font-weight:bold;'>Megjegyzés! A felhasználónak nem lesz több lehetősége teljesíteni ezt a kérést és visszavonódik a kérdéseiért kapott pontszám.</span><br><hr><br>Teljesítés határidejének meghosszabbítása <input type='text' id='renew_accomplish_deadline' onkeypress='return event.charCode >= 48 && event.charCode <= 57' maxlength='2' placeholder='Írd be a napok számát!'><br><br><span style='color:red;font-weight:bold;'>Megjegyzés! A beírt napok számával kitolódik a kérés teljesítésének határideje.</span>");

    if (x > 0 && x.match(/^[0-9]+$/)) {
        $("#dialogFailedRequestFulfillment").dialog({
            maxWidth: 600,
            width: 600,
            height: 475,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Határidő hosszabítása": function () {
                    var p_days = $('#renew_accomplish_deadline').val();
                    if (p_days.length < 1 || p_days.length > 2 || !p_days.match(/^[0-9]+$/) || p_days < 1) {
                        alert("A határidőt legfeljebb 30 nappal lehet meghosszabbítani!");
                    }
                    else{
                        jQuery.ajax({
                            type: "POST",
                            url: "ajax/renew_accomplish_deadline.php",
                            data: { p_quizid: x, p_days: p_days },
                            dataType: "json",
                            cache: false,
                            success: function (data) {
                                if (data.resp == "ok") {
                                    alert("Kérés teljesítésének határideje meghosszabbítva!");
                                    $('.mainDatasQuiz' + x).remove();
                                    $('.detailsQuiz' + x).remove();
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
                    }
                },
                "Teljesítés törlése": function () {
                    jQuery.ajax({
                        type: "POST",
                        url: "ajax/failed_request_fulfillment.php",
                        data: { p_quizid: x },
                        dataType: "json",
                        cache: false,
                        success: function (data) {
                            if (data.resp == "ok") {
                                alert("Kérés teljesítése törölve!");
                                $('.mainDatasQuiz' + x).remove();
                                $('.detailsQuiz' + x).remove();
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

function accept_request(x, y) {
    $('#dialogAcceptRequest').html("<div id='acceptrequest_title'>Biztos, hogy elfogadod a/az <u><i>" + y + "</i></u> nevű kérést?</div><br><span id='acceptrequest_notes'>Megjegyzés! Ennek hatására a kérés átkerül a végső fázisba (3. fázis - Aktív kvízek) és elérhető lesz.<br><br> A felhasználó megkapja a teljesítésért felajánlott pontokat és a kérés teljesítése véglegesen lezárul.</span>");

    if (x > 0 && x.match(/^[0-9]+$/)) {
        $("#dialogAcceptRequest").dialog({
            maxWidth: 600,
            width: 600,
            height: 325,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "ELFOGADÁS": function () {
                    jQuery.ajax({
                        type: "POST",
                        url: "ajax/accept_request.php",
                        data: { p_quizid: x },
                        dataType: "json",
                        cache: false,
                        success: function (data) {
                            if (data.resp == "ok") {
                                alert("Kérés ELFOGADVA!");
                                $('.mainDatasQuiz' + x).remove();
                                $('.detailsQuiz' + x).remove();
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

function enable_quiz(x, y) {
    $("#dialogEnableQuiz").html("<center><br>Visszaállítod a következő kvízt: <b>" + y + "</b>?<br><input type='text' id='enablequizreason_text' placeholder='Írd be a visszaállítás okát!' maxlength='150'></center>");
    $("#dialogEnableQuiz").dialog({
        maxWidth: 600,
        width: 600,
        height: 275,
        modal: true,
        open: function (event, ui) {
            $(".ui-dialog-titlebar-close").hide();
        },
        position: { my: 'top', at: 'top+150' },
        buttons: {
            "Igen": function () {
                var enablequizreason_text = $('#enablequizreason_text').val();
                if (enablequizreason_text.length < 5 || enablequizreason_text.length > 100) {
                    alert("A kvíz visszaállításának oka 5-100 karakter legyen!");
                }
                else{
                    jQuery.ajax({
                        type: "POST",
                        url: "ajax/delete_enable_quiz.php",
                        data: { p_quizid: x, p_reason: enablequizreason_text, p_action: 0 },
                        dataType: "json",
                        cache: false,
                        async: false,
                        success: function (data) {
                            if (data.resp != "ok") {
                                alert(data.resp);
                            }
                            else {
                                $("#enableQuiz" + x).replaceWith("<button class='deleteQuiz' id='deleteQuiz" + x + "' onclick='delete_quiz(" + x + ", " + '"' + y + '"' + ")'>Kvíz törlése</button>");
                            }
                        },
                        fail: function () {
                            alert("Failed!");
                        }
                    });
                    $(this).dialog('destroy');
                }

            },
            "Nem": function () {
                $(this).dialog('destroy');
            }
        }
    });
}

function delete_quiz(x, y) {
    $("#dialogDeleteQuiz").html("<center><br>Törölöd a következő kvízt: <b>" + y + "</b>?<br><input type='text' id='deletequizreason_text' placeholder='Írd be a törlés okát!' maxlength='150'></center>");
    $("#dialogDeleteQuiz").dialog({
        maxWidth: 600,
        width: 600,
        height: 275,
        modal: true,
        open: function (event, ui) {
            $(".ui-dialog-titlebar-close").hide();
        },
        position: { my: 'top', at: 'top+150' },
        buttons: {
            "Igen": function () {
                var deletequizreason_text = $('#deletequizreason_text').val();
                if (deletequizreason_text.length < 5 || deletequizreason_text.length > 100) {
                    alert("A kvíz törlésének oka 5-100 karakter legyen!");
                }
                else {
                    jQuery.ajax({
                        type: "POST",
                        url: "ajax/delete_enable_quiz.php",
                        data: { p_quizid: x, p_reason: deletequizreason_text, p_action: 1 },
                        dataType: "json",
                        cache: false,
                        async: false,
                        success: function (data) {
                            if (data.resp != "ok") {
                                alert(data.resp);
                            }
                            else {
                                $("#deleteQuiz" + x).replaceWith("<button class='enableQuiz' id='enableQuiz" + x + "' onclick='enable_quiz(" + x + ", " + '"' + y + '"' + ")'>Kvíz visszaállítása</button>");
                            }
                        },
                        fail: function () {
                            alert("Failed!");
                        }
                    });
                    $(this).dialog('destroy');
                }

            },
            "Nem": function () {
                $(this).dialog('destroy');
            }
        }
    });
}

function show_activequestions(x, y) {
    $('#dialogShowActiveQuestionList').html("<br><center><div id='title_div'>" + y + " </div><br><br><div id='content_div'><div id = 'loading_questiondiv'> </div></div>");

    jQuery.ajax({
        type: "POST",
        url: "ajax/load_activequestions_towatch.php",
        data: { quizid: x },
        cache: false,
        beforeSend: function () {
            $('#loading_questiondiv').append('<div id="loading_showquestiondiv" style="margin-top:10px;margin-bottom:10px;">Kérdések betöltése...<br><br><img src="../documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="6%"></div>')
        },
        success: function (data) {
            setTimeout(function () {
                $("#loading_questiondiv").remove();
                $('#content_div').append(data);

            }, 1500);
        },
        fail: function () {
            alert("Failed!");
        }

    });

    $("#dialogShowActiveQuestionList").dialog({
        width: 1000,
        height: 650,
        modal: true,
        my: "center",
        at: "center",
        of: window,
        open: function (event, ui) {
            $(".ui-dialog-titlebar-close").hide();
        },
        buttons: {
            "Bezárás": function () {
                $(this).dialog('destroy');
            }
        }
    });
}

$(document).ready(function(){
    $(".toggler1_1").click(function(e){
        e.preventDefault();
        $('.detailsQuiz'+$(this).attr('data-prod')).toggle();
    });
});
