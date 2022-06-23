function accept_bgimg(x) {
    if (window.confirm("Biztos, elfogadod ezt a képet?")) {
        jQuery.ajax({
            type: "POST",
            url: "ajax/accept_backgroundimg.php",
            data: { p_imgid: x },
            dataType: "json",
            cache: false,
            success: function (data) {
                if (data.resp == "ok") {
                    $('#td' + x).remove();
                }
                else {
                    alert(data.resp);
                }
            },
            fail: function () {
                alert('Sikertelen.');
            }
        });
    }
}

function delete_bgimg(x) {
    if (window.confirm("Biztos, törlöd ezt a képet?")) {
        jQuery.ajax({
            type: "POST",
            url: "ajax/delete_backgroundimg.php",
            data: { p_imgid: x },
            dataType: "json",
            cache: false,
            success: function (data) {
                if (data.resp == "ok") {
                    $('#td' + x).remove();
                }
                else {
                    alert(data.resp);
                }
            },
            fail: function () {
                alert('Sikertelen.');
            }
        });
    }
}