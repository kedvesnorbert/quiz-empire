function vk_ell(){
    var vk = document.getElementById('teljesnev').value;
    if(vk.match(/(\w.+\s).+/) && vk !=""){
        document.getElementById('teljesnev_error').style.fontStyle = "italic";
        document.getElementById('teljesnev_error').style.fontSize = "14px";
        document.getElementById('teljesnev_error').style.fontFamily = "Verdana";
        document.getElementById('teljesnev_error').style.color = "limegreen";
        document.getElementById('teljesnev_error').innerHTML = "Helyesen kitöltve";
        return true;
    }
    else if(vk == ""){
        document.getElementById('teljesnev_error').style.color = "red";
        document.getElementById('teljesnev_error').style.fontStyle = "italic";
        document.getElementById('teljesnev_error').style.fontSize = "14px";
        document.getElementById('teljesnev_error').style.fontFamily = "Verdana";
        document.getElementById('teljesnev_error').innerHTML = "Kérjük töltsd ki ezt a mezőt!";
        return false;
    }
    else if(!vk.match(/(\w.+\s).+/))
    {
        document.getElementById('teljesnev_error').style.color = "red";
        document.getElementById('teljesnev_error').style.fontStyle = "italic";
        document.getElementById('teljesnev_error').style.fontSize = "14px";
        document.getElementById('teljesnev_error').style.fontFamily = "Verdana";
        document.getElementById('teljesnev_error').style.color = "red";
        document.getElementById('teljesnev_error').innerHTML = "A vezetéknév és keresztnév megadása kötelező!";
        return false;
    }
}

function email_ell(){
    var em = document.getElementById('email').value;
    if(em == ""){
        document.getElementById('email_error').style.color = "red";
        document.getElementById('email_error').style.fontStyle = "italic";
        document.getElementById('email_error').style.fontSize = "14px";
        document.getElementById('email_error').style.fontFamily = "Verdana";
        document.getElementById('email_error').innerHTML = "Kérjük töltsd ki ezt a mezőt!";
        return false;
    }
    if(em.match(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)){
        document.getElementById('email_error').style.fontStyle = "italic";
        document.getElementById('email_error').style.fontSize = "14px";
        document.getElementById('email_error').style.fontFamily = "Verdana";
        document.getElementById('email_error').style.color = "limegreen";
        document.getElementById('email_error').innerHTML = "Helyesen kitöltve";
        return true;
    }
    else
       {
            document.getElementById('email_error').style.fontStyle = "italic";
            document.getElementById('email_error').style.fontSize = "14px";
            document.getElementById('email_error').style.fontFamily = "Verdana";
            document.getElementById('email_error').style.color = "red";
            document.getElementById('email_error').innerHTML = "Valós email-címet adj meg!";
            return false;
       }
}

function user_ell(){
    var us = document.getElementById('user').value;
    if(us != "" && us.length < 26 && us.length > 3 && us.match(/^[a-zA-Z0-9]*$/)){
        document.getElementById('user_error').style.fontStyle = "italic";
        document.getElementById('user_error').style.fontSize = "14px";
        document.getElementById('user_error').style.fontFamily = "Verdana";
        document.getElementById('user_error').style.color = "limegreen";
        document.getElementById('user_error').innerHTML = "Helyesen kitöltve";
        return true;
    }
    else if(us == ""){
        document.getElementById('user_error').style.color = "red";
        document.getElementById('user_error').style.fontStyle = "italic";
        document.getElementById('user_error').style.fontSize = "14px";
        document.getElementById('user_error').style.fontFamily = "Verdana";
        document.getElementById('user_error').innerHTML = "Kérjük töltsd ki ezt a mezőt!";
        return false;
    }
    else if(us.length > 15){
        document.getElementById('user_error').style.color = "red";
        document.getElementById('user_error').style.fontStyle = "italic";
        document.getElementById('user_error').style.fontSize = "14px";
        document.getElementById('user_error').style.fontFamily = "Verdana";
        document.getElementById('user_error').innerHTML = "A felhasználónév hossza maximum 15 karakter lehet!";
        return false;
    }
    else if(us.length < 4){
        document.getElementById('user_error').style.color = "red";
        document.getElementById('user_error').style.fontStyle = "italic";
        document.getElementById('user_error').style.fontSize = "14px";
        document.getElementById('user_error').style.fontFamily = "Verdana";
        document.getElementById('user_error').innerHTML = "A felhasználónév hossza minimum 4 karakter kell legyen!";
        return false;
    }
    else if(!us.match(/^[a-zA-Z0-9]*$/)){
        document.getElementById('user_error').style.color = "red";
        document.getElementById('user_error').style.fontStyle = "italic";
        document.getElementById('user_error').style.fontSize = "14px";
        document.getElementById('user_error').style.fontFamily = "Verdana";
        document.getElementById('user_error').innerHTML = "A felhasználónév csak betűket és számokat tartalmazhat!";
        return false;
    }
    
}

function pw_ell(){
    var pw = document.getElementById('pw').value;
    if(pw != "" && pw.length >= 6 && pw.length <= 100 && pw.match(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,100}$/) && pw.match(/^\S*$/)){
        document.getElementById('pw_error').style.fontStyle = "italic";
        document.getElementById('pw_error').style.fontSize = "14px";
        document.getElementById('pw_error').style.fontFamily = "Verdana";
        document.getElementById('pw_error').style.color = "limegreen";
        document.getElementById('pw_error').innerHTML = "Helyesen kitöltve";
        return true;
    }
    else if(pw == ""){
        document.getElementById('pw_error').style.color = "red";
        document.getElementById('pw_error').style.fontStyle = "italic";
        document.getElementById('pw_error').style.fontSize = "14px";
        document.getElementById('pw_error').style.fontFamily = "Verdana";
        document.getElementById('pw_error').innerHTML = "Kérjük töltsd ki ezt a mezőt!";
        return false;
    }
    else if(pw.length < 6){
        document.getElementById('pw_error').style.color = "red";
        document.getElementById('pw_error').style.fontStyle = "italic";
        document.getElementById('pw_error').style.fontSize = "14px";
        document.getElementById('pw_error').style.fontFamily = "Verdana";
        document.getElementById('pw_error').innerHTML = "A jelszó hossza minimum 6 karakter kell legyen!";
        return false;
    }
    else if(pw.length > 100){
        document.getElementById('pw_error').style.color = "red";
        document.getElementById('pw_error').style.fontStyle = "italic";
        document.getElementById('pw_error').style.fontSize = "14px";
        document.getElementById('pw_error').style.fontFamily = "Verdana";
        document.getElementById('pw_error').innerHTML = "A jelszó hossza maximum 100 karakter lehet!";
        return false;
    }
    else if(!pw.match(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,100}$/)){
        document.getElementById('pw_error').style.color = "red";
        document.getElementById('pw_error').style.fontStyle = "italic";
        document.getElementById('pw_error').style.fontSize = "14px";
        document.getElementById('pw_error').style.fontFamily = "Verdana";
        document.getElementById('pw_error').innerHTML = "A jelszó tartalmazzon legalább 1 számjegyet és 1 nagybetűt!";
        return false;
    }
    else if(!pw.match(/^\S*$/)){
        document.getElementById('pw_error').style.color = "red";
        document.getElementById('pw_error').style.fontStyle = "italic";
        document.getElementById('pw_error').style.fontSize = "14px";
        document.getElementById('pw_error').style.fontFamily = "Verdana";
        document.getElementById('pw_error').innerHTML = "A jelszó nem tartalmazhat szóközt!";
        return false;
    }
    
}

function pw2_ell(){
    var pw2 = document.getElementById('pw2').value;
    var pw = document.getElementById('pw').value;
    if(pw == pw2 && pw_ell() == true){
        document.getElementById('pw2_error').style.fontStyle = "italic";
        document.getElementById('pw2_error').style.fontSize = "14px";
        document.getElementById('pw2_error').style.fontFamily = "Verdana";
        document.getElementById('pw2_error').style.color = "limegreen";
        document.getElementById('pw2_error').innerHTML = "Helyesen kitöltve";
        return true;
    }
    else
    {
        document.getElementById('pw2_error').style.color = "red";
        document.getElementById('pw2_error').style.fontStyle = "italic";
        document.getElementById('pw2_error').style.fontSize = "14px";
        document.getElementById('pw2_error').style.fontFamily = "Verdana";
        document.getElementById('pw2_error').innerHTML = "Nem talál a két jelszó";
        return false;
    }
}

function validation(){
    if(vk_ell() == true && email_ell() == true && user_ell() == true && pw_ell() == true && pw2_ell() == true){
        return true;
    }
    return false;
}

function login_validation(){
	var u = document.getElementById('l_user').value;
	var p = document.getElementById('l_pw').value;
	if(u.length < 1 && p.length < 1){
		alert('Felhasználónév és jelszó nélkűl nem lehet bejelentkezni!');
		return false;
	}
	if(u.length < 1){
		alert('Nem írtál be felhasználónevet!');
		return false;
	}
	if(p.length < 1){
		alert('Nem írtál be jelszót!');
		return false;
	}
	return true;
}

window.onload = function(){
	
	const signUpButton = document.getElementById('signUp');
	const signInButton = document.getElementById('signIn');
	const container = document.getElementById('container');

	signUpButton.addEventListener('click', () => {
		container.classList.add("right-panel-active");
	});

	signInButton.addEventListener('click', () => {
		container.classList.remove("right-panel-active");
	});
}