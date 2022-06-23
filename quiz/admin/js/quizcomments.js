function accept_comment(x, y, z, t) {
    if (window.confirm("Biztos, hogy jóváhagyod ezt a commentet?")) {
        if (x > 0 && x.match(/^[0-9]+$/) && y > 0 && y.match(/^[0-9]+$/) && z.match(/^\d{4}\-\d{2}\-\d{2} \d{2}:\d{2}:\d{2}$/)){
            jQuery.ajax({
                type: "POST",
                url: "ajax/accept_quizcomment.php",
                data: { p_quizid: x, p_userid: y, p_commentdate: z },
                dataType: "json",
                cache: false,
                success: function (data) {
                    if (data.resp == "ok") {
                        $('#' + t).remove();
                    }
                    else {
                        alert(data.resp);
                    }
                },
                fail: function () {
                    alert("Failed!");
                }
            });
        }
        else{
            alert("Hibás bemeneti adatok!");
        }
    }
}

function censore_partial(){
    var x = $('.d_textarea').attr('id');
    var highlight = window.getSelection();
    if(highlight.toString().length >= 10){
        $('#' + x).val($('#' + x).val().replace(highlight, "!!!censored!!!"));
    }
    else{
        alert('Legalább 10 karakter hosszúságú szöveget jelölj ki!');
    }
}

function censore_all() {
    var x = $('.d_textarea').attr('id');
    $('#' + x).val("!!!censored!!!");
}

function get_selected_modcomment(){
    var com = $("#select_moderator_comment option:selected").text();
    var x = $('.moderator_textarea').attr('id');
    $('#' + x).append(" " + com);
}

function censore_comment(qn, qid, u, uid, cd, ct, x){
    $("#dialogCensoreComment").html("<p id='d_title_p'><b>Írta: </b><u><i>" + u + "</i></u> -- Időpont: <u><i> " + cd + "</i></u><br><br><b>Kvíz: </b><u><i>" + qn + "</i></u></p>" + "<hr><br><center><textarea id='d_textarea" + x + "' class='d_textarea'>" + decodeURIComponent((ct + '').replace(/\+/g, '%20')) + "</textarea></center><hr><p id='d_settings_title'>Cenzúrázási műveletek</p><br><center><button id='censore_partial' onclick='censore_partial()'>Kijelölt rész cenzúrázása</button><button id='censore_all' onclick='censore_all()'>Teljes comment cenzúrázása</button></center><hr><p id='d_settings_title'>Moderátori megjegyzés hozzáfűzése</p><br><select id='select_moderator_comment' onchange='get_selected_modcomment()'><option value='' disabled selected>Válassz megjegyzést, vagy írj sajátot!</option><option value='1'>Kvíz hozzászólások esetén is kérlek ékezetes betükkel írj, helyesen és ha lehet, magyarul.</option><option value='2'>Ne használj feleslegesen szóismétléseket.</option><option value='3'>A nem helyén való hozzászólásoknak helye nincs!.</option><option value='4'>Vigyázz a szóhasználatra!.</option></select><textarea id='moderator_textarea'" + x + " class='moderator_textarea'></textarea><span style='font-style:italic;font-size:12pt;'>A fenti textbox-ban megadott moderátori szöveg fog hozzáfűződni a comment-hez.</span>\n");
    var y = $('.d_textarea').attr('id');
    $("#dialogCensoreComment").dialog({
        maxWidth: 650,
        width: 650,
        height: 700,
        modal: true,
        open: function (event, ui) {
            $(".ui-dialog-titlebar-close").hide();
        },
        position: { my: 'top', at: 'top+150' },
        buttons: {
            "Cenzúrázás mentése": function () {
                var moderator_comment = $('.moderator_textarea').val();
                var quiz_comment = $('#d_textarea'+x).val();

                if (qid < 1 || !qid.match(/^[0-9]+$/)){
                    alert("Hibás kvízazonosító!");
                }
                else if (uid < 1 || !uid.match(/^[0-9]+$/)){
                    alert("Hibás userazonosító!");
                }
                else if (!cd.match(/^\d{4}\-\d{2}\-\d{2} \d{2}:\d{2}:\d{2}$/)){
                    alert("Hibás comment dátum!");
                }
                else if (quiz_comment.length < 1 || quiz_comment.length > 2500){
                    alert('A kvíz hozzászólás 1-2500 karakter lehet!');
                }
                else if (moderator_comment.length < 10 || moderator_comment.length > 400) {
                    alert('A moderátori comment 10-400 karakter lehet és csak betűket/számokat/szóközöket tartalmazhat!');
                }
                else {
                    jQuery.ajax({
                        type: "POST",
                        url: "ajax/censore_quizcomment.php",
                        data: { p_quizid: qid, p_userid: uid, p_commentdate: cd, p_modifiedcomment: quiz_comment, p_moderatorcomment: moderator_comment },
                        dataType: "json",
                        cache: false,
                        async: false,
                        success: function (data) {
                            if (data.resp != "ok") {
                                alert(data.resp);
                            }
                            else {
                                $('#' + x).remove();
                            }
                        },
                        fail: function () {
                            alert("Failed!");
                        }
                    });
                }
                $(this).dialog('destroy');
            },
            "Mégsem": function () {
                $(this).dialog('destroy');
            }
        }
    });
}