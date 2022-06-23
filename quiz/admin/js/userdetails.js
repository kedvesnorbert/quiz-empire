function load_userlawdata(x)
{
    $('#dialogGiveWarn').html("<div id='loading_userlawdatadiv'></div ><table id='d_lawtable' align='left' border='0'><tr id='tr_cb'><td id='td_text'>Pontok gyüjtése</td><td id='td_cb'><input type='checkbox' id='d_lawtogetpoints_cb' class='d_checkbox'></td><tr id='tr_cb'><td id='td_text'>Chat használata</td><td id='td_cb'><input type='checkbox' id='d_lawtousechat_cb' class='d_checkbox'></td><tr id='tr_cb'><td id='td_text'>Kérés kiírása</td><td id='td_cb'><input type='checkbox' id='d_lawtouserequests_cb' class='d_checkbox'></td><tr id='tr_cb'><td id='td_text'>Privát üzenet küldés</td><td id='td_cb'><input type='checkbox' id='d_lawtosendmail_cb' class='d_checkbox'></td><tr id='tr_cb'><td id='td_text'>Saját kvíz készítése</td><td id='td_cb'><input type='checkbox' id='d_lawtocreatequiz_cb' class='d_checkbox'></td><tr id='tr_cb'><td id='td_text'>Új kérdés beküldése</td><td id='td_cb'><input type='checkbox' id='d_lawtosendquestion_cb' class='d_checkbox'></td><tr id='tr_cb'><td id='td_text'>Felhasználókereső használata</td><td id='td_cb'><input type='checkbox' id='d_lawtosearchuser_cb' class='d_checkbox'></td><tr id='tr_cb'><td id='td_text'>Új hír kiírása</td> <td id='td_cb'><input type='checkbox' id='d_lawtopostnews_cb' class='d_checkbox'></td></table><table id='d_lawotherstable' border='0'><tr id='tr_otherinputtext'><td>Pontok levonása<td id='td_otherinput'><input type='text' id='minuspoints' onkeypress='return event.charCode >= 48 && event.charCode <= 57' required><tr id='tr_otherinputtext'><td>Warn időtartama (napok száma)<td id='td_otherinput'><input type='text' id='warndelay' onkeypress='return event.charCode >= 48 && event.charCode <= 57' required><tr id='tr_otherinputtext'><td>Warn oka (5-100 karakter)<td id='td_otherinput'><input type='text' id='warnreason' maxlength='100' required></table>");
    
    if (x > 0 && x.match(/^[0-9]+$/)) {
        
        jQuery.ajax({
            type: "POST",
            url: "ajax/load_userlawdata.php",
            data: { profile_id: x },
            dataType: "json",
            beforeSend: function () {
                $('#loading_userlawdatadiv').append('<div id="loading_showuserlawdatadiv" style="margin-top:10px;">Adatok betöltése...<br><img src="../../documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="7%"></div>');
            },
            cache: false,
            success: function (data) {
                setTimeout(function () {
                    $('#loading_userlawdatadiv').html('Töröld a négyzetek bejelölését a jogok megvonásához<br>');
                    resultObj = eval(data);
                    if (typeof resultObj[0] == 'undefined') {
                        alert("A munkamenet ideje lejárt! A folytatáshoz be kell újra jelentkezni!");
                    }
                    else {
                        if (resultObj.length == 8) {
                            if (resultObj[0] == 1) {
                                $("#d_lawtogetpoints_cb").attr("checked", true);
                            }
                            if (resultObj[1] == 1) {
                                $("#d_lawtousechat_cb").attr("checked", true);
                            }
                            if (resultObj[2] == 1) {
                                $("#d_lawtouserequests_cb").attr("checked", true);
                            }
                            if (resultObj[3] == 1) {
                                $("#d_lawtosendmail_cb").attr("checked", true);
                            }
                            if (resultObj[4] == 1) {
                                $("#d_lawtocreatequiz_cb").attr("checked", true);
                            }
                            if (resultObj[5] == 1) {
                                $("#d_lawtosendquestion_cb").attr("checked", true);
                            }
                            if (resultObj[6] == 1) {
                                $("#d_lawtosearchuser_cb").attr("checked", true);
                            }
                            if (resultObj[7] == 1) {
                                $("#d_lawtopostnews_cb").attr("checked", true);
                            }
                        }
                        else {
                            alert(resultObj[0]);
                        }
                    }
                }, 1500);
            },
            fail: function () {
                alert("Failed!");
            }

        });
        
        
        $("#dialogGiveWarn").dialog({
            maxWidth: 700,
            width: 600,
            height: 600,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Figyelmeztetés": function () {

                    if($('#d_lawtogetpoints_cb').is(':checked')){
                        var p_lawtogetpoints = 1;
                    }
                    else{
                        var p_lawtogetpoints = 0;
                    }

                    if($('#d_lawtousechat_cb').is(':checked')){
                        var p_lawtousechat = 1;
                    }
                    else{
                        var p_lawtousechat = 0;
                    }

                    if($('#d_lawtouserequests_cb').is(':checked')){
                        var p_lawtouserequests = 1;
                    }
                    else{
                        var p_lawtouserequests = 0;
                    }

                    if($('#d_lawtosendmail_cb').is(':checked')){
                        var p_lawtosendmail = 1;
                    }
                    else{
                        var p_lawtosendmail = 0;
                    }

                    if($('#d_lawtocreatequiz_cb').is(':checked')){
                        var p_lawtocreatequiz = 1;
                    }
                    else{
                        var p_lawtocreatequiz = 0;
                    }

                    if($('#d_lawtosendquestion_cb').is(':checked')){
                        var p_lawtosendquestion = 1;
                    }
                    else{
                        var p_lawtosendquestion = 0;
                    }

                    if($('#d_lawtosearchuser_cb').is(':checked')){
                        var p_lawtosearchuser = 1;
                    }
                    else{
                        var p_lawtosearchuser = 0;
                    }

                    if($('#d_lawtopostnews_cb').is(':checked')){
                        var p_lawtopostnews = 1;
                    }
                    else{
                        var p_lawtopostnews = 0;
                    }
                    var warnreason = $('#warnreason').val();
                    var minuspoints = $('#minuspoints').val();
                    var warndelay = $('#warndelay').val();
                    if (minuspoints < 100 || minuspoints > 10000) {
                        alert("Legalább 100 pontot le kell vonni (maximum 10.000-t)!");
                    }
                    else if (warndelay < 3 || warndelay > 100) {
                        alert("Egy Warn ideje 3 és 100 nap közötti idő!");
                    }
                    else if (warnreason.length < 5 || warnreason.length > 100)
                    {
                        alert("A Warn oka 5-100 karakter legyen!");
                    }
                    else {
                        jQuery.ajax({
                            type: "POST",
                            url: "ajax/give_warn.php",
                            data: { p_userid: x, p_lawtogetpoints: p_lawtogetpoints, p_lawtousechat: p_lawtousechat, p_lawtouserequests: p_lawtouserequests, p_lawtosendmail: p_lawtosendmail, p_lawtocreatequiz: p_lawtocreatequiz, p_lawtosendquestion: p_lawtosendquestion, p_lawtosearchuser: p_lawtosearchuser, p_lawtopostnews: p_lawtopostnews, warnreason: warnreason, minuspoints: minuspoints, warndelay: warndelay },
                            dataType: "json",
                            cache: false,
                            success: function (data) {
                                if (data.resp == "ok") {
                                    alert("Sikeres művelet!");
                                    location.reload();
                                }
                                else {
                                    alert(data.resp);
                                    $(this).dialog('destroy');
                                }

                            },
                            fail: function () {
                                alert("Failed!");
                            }
                        });
                        
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

function delete_warn(x) {
    $('#dialogDeleteWarn').html("<div id='deletewarn_title'>Biztos, hogy eltörlöd a felhasználó warn-ját?</div><input type='text' id='del_reason_text' placeholder='Írd be a törlés okát!'>");

    if (x > 0 && x.match(/^[0-9]+$/)) {  
        $("#dialogDeleteWarn").dialog({
            maxWidth: 600,
            width: 600,
            height: 300,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Warn törlése": function () {
                    
                    var warndelreason = $('#del_reason_text').val();
                    if (warndelreason.length < 5 || warndelreason.length > 100) {
                        alert("A Warn visszavonásának oka 5-100 karakter legyen!");
                    }
                    else{
                        jQuery.ajax({
                            type: "POST",
                            url: "ajax/delete_warn.php",
                            data: { p_userid: x, p_delreason: warndelreason},
                            dataType: "json",
                            cache: false,
                            success: function (data) {
                                if (data.resp == "ok") {
                                    alert("Sikeres művelet!");
                                    location.reload();
                                }
                                else {
                                    alert(data.resp);
                                    $(this).dialog('destroy');
                                }
                            },
                            fail: function () {
                                alert("Failed!");
                            }
                        });
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

function free_premium(x) {
    $('#dialogFreePremium').html("<center><div id='freepremium_title'>Add meg a felhasználó ingyenes prémium tagságának idejét!</div><input type='text' id='freepremium_text' placeholder='Írd be a napok számát!' onkeypress='return event.charCode >= 48 && event.charCode <= 57'></center>");

    if (x > 0 && x.match(/^[0-9]+$/)) {
        $("#dialogFreePremium").dialog({
            maxWidth: 600,
            width: 600,
            height: 275,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Ingyen prémium": function () {
                    var premiumdelay = $('#freepremium_text').val();
                    if (premiumdelay < 1 || premiumdelay > 365) {
                        alert("A Prémium ideje 1 naptól 1 évig (365 napig) kiterjedő legyen!");
                    }
                    else {
                        jQuery.ajax({
                            type: "POST",
                            url: "ajax/free_premium.php",
                            data: { p_userid: x, p_premiumdelay: premiumdelay },
                            dataType: "json",
                            cache: false,
                            success: function (data) {
                                if (data.resp == "ok") {
                                    alert("Sikeres művelet!");
                                    location.reload();
                                }
                                else {
                                    alert(data.resp);
                                    $(this).dialog('destroy');
                                }
                            },
                            fail: function () {
                                alert("Failed!");
                            }
                        });
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

function modify_laws(x) {
    $('#dialogModifyLaws').html("<div id='loading_userlawdatadiv'></div >");

    if (x > 0 && x.match(/^[0-9]+$/)) {

        jQuery.ajax({
            type: "POST",
            url: "ajax/load_userlawdata_tomodify.php",
            data: { profile_id: x },
            dataType: "json",
            beforeSend: function () {
                $('#loading_userlawdatadiv').append('<div id="loading_showuserlawdatadiv" style="margin-top:10px;">Adatok betöltése...<br><img src="../../documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="7%"></div>');
            },
            cache: false,
            success: function (data) {
                setTimeout(function () {
                    $('#loading_userlawdatadiv').html('');
                    resultObj = eval(data);
                    if (typeof resultObj[0] == 'undefined') {
                        alert("A munkamenet ideje lejárt! A folytatáshoz be kell újra jelentkezni!");
                    }
                    else {
                        if (resultObj.length == 14) {

                            $('#dialogModifyLaws').html("<p id='d_info_p'>A jogok és a szint változtatásához be kell jelölni a <u>szintmegtartás</u> négyzetet.</p><table id='d_lawcont_table' border='1' width='100%'><tr ><td width='20%' height='30pt'>Szintmegtartás<td id='td_keeplevel'><input type='checkbox' id='keeplevel_toggle'> <tr><td><td><table id='d_lawtable2' align='left' border='0' width='100%'><tr id='tr_cb2'><td id='td_text'>Aktuális szint</td><td id='td_cb2'><input type='text' id='d_currentlevel' class='d_checkbox' onkeypress='return event.charCode >= 48 && event.charCode <= 57'></td><tr id='tr_cb2'><td id='td_text'>Pontok gyüjtése</td><td id='td_cb2'><input type='checkbox' id='d_lawtogetpoints_cbm' class='d_checkbox'></td><tr id='tr_cb2'><td id='td_text'>Chat használata</td><td id='td_cb2'><input type='checkbox' id='d_lawtousechat_cbm' class='d_checkbox'></td><tr id='tr_cb2'><td id='td_text'>Kérés kiírása</td><td id='td_cb2'><input type='checkbox' id='d_lawtouserequests_cbm' class='d_checkbox'></td><tr id='tr_cb2'><td id='td_text'>Privát üzenet küldés</td><td id='td_cb2'><input type='checkbox' id='d_lawtosendmail_cbm' class='d_checkbox'></td><tr id='tr_cb2'><td id='td_text'>Saját kvíz készítése</td><td id='td_cb2'><input type='checkbox' id='d_lawtocreatequiz_cbm' class='d_checkbox'></td><tr id='tr_cb2'><td id='td_text'>Új kérdés beküldése</td><td id='td_cb2'><input type='checkbox' id='d_lawtosendquestion_cbm' class='d_checkbox'></td><tr id='tr_cb2'><td id='td_text'>Felhasználókereső használata</td><td id='td_cb2'><input type='checkbox' id='d_lawtosearchuser_cbm' class='d_checkbox'></td><tr id='tr_cb2'><td id='td_text'>Új hír kiírása</td> <td id='td_cb2'><input type='checkbox' id='d_lawtopostnews_cbm' class='d_checkbox'></td></table></table>    <table id='d_lawotherstablem' border='0'><tr id='tr_otherinputtext'><td>Pontok adása/levonása<td id='td_otherinput'><input type='text' id='plusminuspoints' value='0' required> <span id='currentpoints_span'></span><tr id='tr_otherinputtext'><td>Segítség jóváírása/levonása<td id='td_otherinput'><input type='text' id='counthelps' value='0' required><span id='currenthelps_span'></span><tr id='tr_otherinputtext'><td>Ingyen Prémium eltörlése<td id='td_otherinput'><input type='checkbox' id='delfreepremium'><tr id='tr_otherinputtext'><td>Kvízkérdések nehézsége<td id='td_otherinput'><select id='qtype_select'><option value='0'>Vegyes nehézségű</option><option value='1'>Csak könnyű kérdések</option><option value='2'>Csak nehéz kérdések</option></select></table>");
                            
                            $('#keeplevel_toggle').change(function ()
                            {
                                if ($('#keeplevel_toggle').prop("checked")==true)
                                {
                                    $("#d_currentlevel").attr("disabled", false);
                                    $("#d_lawtogetpoints_cbm").attr("disabled", false);
                                    $("#d_lawtousechat_cbm").attr("disabled", false);
                                    $("#d_lawtouserequests_cbm").attr("disabled", false);
                                    $("#d_lawtosendmail_cbm").attr("disabled", false);
                                    $("#d_lawtocreatequiz_cbm").attr("disabled", false);
                                    $("#d_lawtosendquestion_cbm").attr("disabled", false);
                                    $("#d_lawtosearchuser_cbm").attr("disabled", false);
                                    $("#d_lawtopostnews_cbm").attr("disabled", false);
                                }
                                else{
                                    $("#d_currentlevel").attr("disabled", true);
                                    $("#d_lawtogetpoints_cbm").attr("disabled", true);
                                    $("#d_lawtousechat_cbm").attr("disabled", true);
                                    $("#d_lawtouserequests_cbm").attr("disabled", true);
                                    $("#d_lawtosendmail_cbm").attr("disabled", true);
                                    $("#d_lawtocreatequiz_cbm").attr("disabled", true);
                                    $("#d_lawtosendquestion_cbm").attr("disabled", true);
                                    $("#d_lawtosearchuser_cbm").attr("disabled", true);
                                    $("#d_lawtopostnews_cbm").attr("disabled", true);
                                }
                            });

                            if (resultObj[0] == 1){
                                $("#keeplevel_toggle").attr("checked", true);
                            }
                            $('#d_currentlevel').val(resultObj[1]);

                            if (resultObj[2] == 1) {
                                $("#d_lawtogetpoints_cbm").attr("checked", true);
                            }
                            if (resultObj[3] == 1) {
                                $("#d_lawtousechat_cbm").attr("checked", true);
                            }
                            if (resultObj[4] == 1) {
                                $("#d_lawtouserequests_cbm").attr("checked", true);
                            }
                            if (resultObj[5] == 1) {
                                $("#d_lawtosendmail_cbm").attr("checked", true);
                            }
                            if (resultObj[6] == 1) {
                                $("#d_lawtocreatequiz_cbm").attr("checked", true);
                            }
                            if (resultObj[7] == 1) {
                                $("#d_lawtosendquestion_cbm").attr("checked", true);
                            }
                            if (resultObj[8] == 1) {
                                $("#d_lawtosearchuser_cbm").attr("checked", true);
                            }
                            if (resultObj[9] == 1) {
                                $("#d_lawtopostnews_cbm").attr("checked", true);
                            }

                            $('#currentpoints_span').text('Jelenleg van: ' + resultObj[10]);
                            $('#currenthelps_span').text('Jelenleg van: ' + resultObj[11]);

                            if (resultObj[12] == 0) {
                                $("#delfreepremium").attr("disabled", true);
                            }

                            if (resultObj[13] >= 0 && resultObj[13] <=2) {
                                $("#qtype_select").children(`[value="${resultObj[13]}"]`).attr('selected', true);
                            }

                            if ($('#keeplevel_toggle').prop("checked") == false) {
                                $("#d_currentlevel").attr("disabled", true);
                                $("#d_lawtogetpoints_cbm").attr("disabled", true);
                                $("#d_lawtousechat_cbm").attr("disabled", true);
                                $("#d_lawtouserequests_cbm").attr("disabled", true);
                                $("#d_lawtosendmail_cbm").attr("disabled", true);
                                $("#d_lawtocreatequiz_cbm").attr("disabled", true);
                                $("#d_lawtosendquestion_cbm").attr("disabled", true);
                                $("#d_lawtosearchuser_cbm").attr("disabled", true);
                                $("#d_lawtopostnews_cbm").attr("disabled", true);
                            }
                        }
                        else {
                            alert(resultObj[0]);
                        }
                    }
                }, 1500);
            },
            fail: function () {
                alert("Failed!");
            }

        });


        $("#dialogModifyLaws").dialog({
            maxWidth: 700,
            width: 700,
            height: 700,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Módosítások mentése": function () {
                    if ($('#keeplevel_toggle').is(':checked')) {
                        var pm_keeplevel = 1;
                    }
                    else {
                        var pm_keeplevel = 0;
                    }
                    
                    if ($('#d_lawtogetpoints_cbm').is(':checked')) {
                        var pm_lawtogetpoints = 1;
                    }
                    else {
                        var pm_lawtogetpoints = 0;
                    }

                    if ($('#d_lawtousechat_cbm').is(':checked')) {
                        var pm_lawtousechat = 1;
                    }
                    else {
                        var pm_lawtousechat = 0;
                    }

                    if ($('#d_lawtouserequests_cbm').is(':checked')) {
                        var pm_lawtouserequests = 1;
                    }
                    else {
                        var pm_lawtouserequests = 0;
                    }

                    if ($('#d_lawtosendmail_cbm').is(':checked')) {
                        var pm_lawtosendmail = 1;
                    }
                    else {
                        var pm_lawtosendmail = 0;
                    }

                    if ($('#d_lawtocreatequiz_cbm').is(':checked')) {
                        var pm_lawtocreatequiz = 1;
                    }
                    else {
                        var pm_lawtocreatequiz = 0;
                    }

                    if ($('#d_lawtosendquestion_cbm').is(':checked')) {
                        var pm_lawtosendquestion = 1;
                    }
                    else {
                        var pm_lawtosendquestion = 0;
                    }

                    if ($('#d_lawtosearchuser_cbm').is(':checked')) {
                        var pm_lawtosearchuser = 1;
                    }
                    else {
                        var pm_lawtosearchuser = 0;
                    }

                    if ($('#d_lawtopostnews_cbm').is(':checked')) {
                        var pm_lawtopostnews = 1;
                    }
                    else {
                        var pm_lawtopostnews = 0;
                    }

                    if ($('#delfreepremium').is(':checked')) {
                        var pm_delfreepremium = 1;
                    }
                    else {
                        var pm_delfreepremium = 0;
                    }
                    
                    var currentlevel = $('#d_currentlevel').val();
                    var plusminuspoints = $('#plusminuspoints').val();
                    var counthelps = $('#counthelps').val();
                    var questiontype = $('#qtype_select').val();
                    if (currentlevel < 1 || currentlevel > 5) {
                        alert("Érvénytelen szint/rang! Csak 1-től 5-ig terjednek ki a rangok!");
                    }
                    else if (!plusminuspoints.match(/^-?[0-9]\d*(\d+)?$/)) {
                        alert("Helytelen pontmennyiség!");
                    }
                    else if (!counthelps.match(/^-?[0-9]\d*(\d+)?$/)) {
                        alert("Helytelen adat a segítségek száma!");
                    }
                    else if (!questiontype.match(/^-?[0-9]\d*(\d+)?$/) || questiontype < 0 || questiontype > 2) {
                        alert("Helytelen adat a kérdés nehézsége!");
                    }
                    else {
                        jQuery.ajax({
                            type: "POST",
                            url: "ajax/modify_userlaws.php",
                            data: { p_userid: x, p_keeplevel: pm_keeplevel, p_currentlevel: currentlevel, p_lawtogetpoints: pm_lawtogetpoints, p_lawtousechat: pm_lawtousechat, p_lawtouserequests: pm_lawtouserequests, p_lawtosendmail: pm_lawtosendmail, p_lawtocreatequiz: pm_lawtocreatequiz, p_lawtosendquestion: pm_lawtosendquestion, p_lawtosearchuser: pm_lawtosearchuser, p_lawtopostnews: pm_lawtopostnews, p_plusminuspoints: plusminuspoints, p_counthelps: counthelps, p_delfreepremium: pm_delfreepremium, p_questiontype: questiontype },
                            dataType: "json",
                            cache: false,
                            success: function (data) {
                                alert(data.resp);
                                location.reload();
                                $(this).dialog('destroy');                             
                            },
                            fail: function () {
                                alert("Failed!");
                            }
                        });

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

function profil_hiding_change(x) {
    $('#dialogProfilHidingChange').html("<div id='loading_userlawdatadiv'></div >");

    if (x > 0 && x.match(/^[0-9]+$/)) {

        jQuery.ajax({
            type: "POST",
            url: "ajax/load_userprofilehidingdata.php",
            data: { profile_id: x },
            dataType: "json",
            beforeSend: function () {
                $('#loading_userlawdatadiv').append('<div id="loading_showuserlawdatadiv" style="margin-top:10px;">Adatok betöltése...<br><img src="../../documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="7%"></div>');
            },
            cache: false,
            success: function (data) {
                setTimeout(function () {
                    $('#loading_userlawdatadiv').html('');
                    resultObj = eval(data);
                    if (typeof resultObj[0] == 'undefined') {
                        alert("A munkamenet ideje lejárt! A folytatáshoz be kell újra jelentkezni!");
                    }
                    else {
                        if (resultObj.length == 2) {

                            $('#dialogProfilHidingChange').html("<div id='prof_hiding_container'><div id='first_prof_hiding'><span id='profhidingONspan'>Profil rejtettség ki-bekapcsolása</span><input type='checkbox' id='profhideOnOff_cb'><br><input type='text' id='profhidedays' placeholder='Írd be a napok számát!' onkeypress='return event.charCode >= 48 && event.charCode <= 57'></div><br><br><span id='currently_has_span'></span></div>");

                            $('#profhideOnOff_cb').change(function () {
                                if ($('#profhideOnOff_cb').prop("checked") == true) {
                                    $("#profhidedays").attr("disabled", false);
                                }
                                else {
                                    $("#profhidedays").attr("disabled", true);
                                }
                            });

                            if (resultObj[0] == 1) {
                                $("#profhideOnOff_cb").attr("checked", true);
                            }
                            if (resultObj[1] == '0000-00-00 00:00:00' || !resultObj[1]){
                                $('#currently_has_span').html('Jelenleg nincs beállítva.<br><font color="red">A beírt napok számával meg fog hosszabbodni a profilrejtettség ideje.</font>');
                            }
                            else{
                                $('#currently_has_span').html(`Lejár: ${resultObj[1]}-kor<br><font color="red">A beírt napok számával meg fog hosszabbodni a profilrejtettség ideje.</font>`);
                            }
                            
                            if ($('#profhideOnOff_cb').prop("checked") == false) {
                                $("#profhidedays").attr("disabled", true);
                            }
                        }
                        else {
                            alert(resultObj[0]);
                        }
                    }
                }, 1500);
            },
            fail: function () {
                alert("Failed!");
            }

        });


        $("#dialogProfilHidingChange").dialog({
            maxWidth: 600,
            width: 600,
            height: 315,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Módosítások mentése": function () {

                    if ($('#profhideOnOff_cb').is(':checked')) {
                        var p_profilehideing = 1;
                    }
                    else {
                        var p_profilehideing = 0;
                    }
                    
                    var profilehidingdelay = $('#profhidedays').val();
                    
                    if (p_profilehideing == 1 && (profilehidingdelay < 1 || profilehidingdelay > 365)) {
                        alert("Érvénytelen a napok száma! Csak 1-től 365-ig terjedhet ki a profil rejtettség ideje!");
                    }
                    else {
                        if (p_profilehideing == 0){
                            profilehidingdelay = 1;
                        }
                        jQuery.ajax({
                            type: "POST",
                            url: "ajax/change_profilehideing.php",
                            data: { p_userid: x, p_profilehideing: p_profilehideing, p_profilehidingdelay: profilehidingdelay },
                            dataType: "json",
                            cache: false,
                            success: function (data) {
                                alert(data.resp);
                                location.reload();
                                $(this).dialog('destroy');
                            },
                            fail: function () {
                                alert("Failed!");
                            }
                        });

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

function modify_adminlaw(x) {
    $('#dialogModifyAdminLaw').html("<div id='loading_userlawdatadiv'></div >");

    if (x > 0 && x.match(/^[0-9]+$/)) {

        jQuery.ajax({
            type: "POST",
            url: "ajax/load_useradmindata.php",
            data: { profile_id: x },
            dataType: "json",
            beforeSend: function () {
                $('#loading_userlawdatadiv').append('<div id="loading_showuserlawdatadiv" style="margin-top:10px;">Adatok betöltése...<br><img src="../../documents/images/ajax-loader.gif" alt="Feldolgozás folyamatban..." width="7%"></div>');
            },
            cache: false,
            success: function (data) {
                setTimeout(function () {
                    $('#loading_userlawdatadiv').html('');
                    resultObj = eval(data);
                    if (typeof resultObj[0] == 'undefined') {
                        alert("A munkamenet ideje lejárt! A folytatáshoz be kell újra jelentkezni!");
                    }
                    else{
                        if (resultObj.length == 1) {

                            $('#dialogModifyAdminLaw').html("<div id='admin_container'><div id='first_admin'><span id='adminlawspan'>Admin jog ki-bekapcsolása</span><input type='checkbox' id='adminOnOff_cb'></div><br><br><span id='currently_admin_span'></span></div>");

                            if (resultObj[0] == 1) {
                                $("#adminOnOff_cb").attr("checked", true);
                                $('#currently_admin_span').html('A felhasználó jelenleg Admin.<br>');
                            }
                            else{
                                $('#currently_admin_span').html('Jelenleg nincs beállítva Admin jog.<br>');
                            }
                            
                        }
                        else {
                            alert(resultObj[0]);
                        }
                    }
                }, 1500);
            },
            fail: function () {
                alert("Failed!");
            }

        });

        $("#dialogModifyAdminLaw").dialog({
            maxWidth: 600,
            width: 600,
            height: 315,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Módosítások mentése": function () {

                    if ($('#adminOnOff_cb').is(':checked')) {
                        var p_admin = 1;
                    }
                    else {
                        var p_admin = 0;
                    }
                    jQuery.ajax({
                        type: "POST",
                        url: "ajax/change_adminlaw.php",
                        data: { p_userid: x, p_admin: p_admin },
                        dataType: "json",
                        cache: false,
                        success: function (data) {
                            alert(data.resp);
                            location.reload();
                            $(this).dialog('destroy');
                        },
                        fail: function () {
                            alert("Failed!");
                        }
                    });
        
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

function delete_account(x) {
    $('#dialogDeleteAccount').html("<div id='deleteaccount_title'>Biztos, hogy törlöd a felhasználó fiókját?</div><input type='text' id='del_account_text' placeholder='Írd be a törlés okát!'>");

    if (x > 0 && x.match(/^[0-9]+$/)) {
        $("#dialogDeleteAccount").dialog({
            maxWidth: 600,
            width: 600,
            height: 275,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Fiók törlése": function () {

                    var accountdelreason = $('#del_account_text').val();
                    if (accountdelreason.length < 5 || accountdelreason.length > 100) {
                        alert("A fiók törlésének oka 5-100 karakter legyen!");
                    }
                    else {
                        jQuery.ajax({
                            type: "POST",
                            url: "ajax/delete_account.php",
                            data: { p_userid: x, p_accountdelreason: accountdelreason },
                            dataType: "json",
                            cache: false,
                            success: function (data) {
                                if (data.resp == "ok") {
                                    alert("Sikeres művelet!");
                                    location.reload();
                                }
                                else {
                                    alert(data.resp);
                                    $(this).dialog('destroy');
                                }
                            },
                            fail: function () {
                                alert("Failed!");
                            }
                        });
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

function restore_account(x) {
    $('#dialogRestoreAccount').html("<div id='restoreaccount_title'>Visszaállítod a felhasználó fiókját?</div><input type='text' id='restore_account_text' placeholder='Írd be a visszaállítás okát!'>");

    if (x > 0 && x.match(/^[0-9]+$/)) {
        $("#dialogRestoreAccount").dialog({
            maxWidth: 600,
            width: 600,
            height: 275,
            modal: true,
            open: function (event, ui) {
                $(".ui-dialog-titlebar-close").hide();
            },
            position: { my: 'top', at: 'top+150' },
            buttons: {
                "Fiók visszaállítása": function () {
                    var accountrestorereason = $('#restore_account_text').val();
                    if (accountrestorereason.length < 5 || accountrestorereason.length > 100) {
                        alert("A fiók visszaállításának oka 5-100 karakter legyen!");
                    }
                    else {
                        jQuery.ajax({
                            type: "POST",
                            url: "ajax/restore_account.php",
                            data: { p_userid: x, p_accountrestorereason: accountrestorereason },
                            dataType: "json",
                            cache: false,
                            success: function (data) {
                                if (data.resp == "ok") {
                                    alert("Sikeres művelet!");
                                    location.reload();
                                }
                                else {
                                    alert(data.resp);
                                    $(this).dialog('destroy');
                                }
                            },
                            fail: function () {
                                alert("Failed!");
                            }
                        });
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

$(document).ready(function () {
    $(".togglerU").click(function (e) {
        e.preventDefault();
        $('.detailU' + $(this).attr('data-prod-cat')).toggle();
    });

    $(".togglerUserQ").click(function (e) {
        e.preventDefault();
        $('.detailsUserQuiz' + $(this).attr('data-prod')).toggle();
    });
});