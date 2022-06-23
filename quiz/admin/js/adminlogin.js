function check_adminlogin(){
	var u = document.getElementById('adminuser_id').value;
	var p = document.getElementById('adminpw_id').value;
	if (u.length < 1 && p.length < 1) {
		alert('Felhasználónév és jelszó nélkűl nem lehet bejelentkezni!');
		return false;
	}
	if (u.length < 1) {
		alert('Nem írtál be felhasználónevet!');
		return false;
	}
	if (p.length < 1) {
		alert('Nem írtál be jelszót!');
		return false;
	}
	if (u.length > 25) {
		alert('A felhasználónév hossza túl nagy!');
		return false;
	}
	if (p.length > 100) {
		alert('A jelszó hossza túl nagy!');
		return false;
	}
	if (!u.match(/^[a-zA-Z0-9]*$/) && !u.match(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)){
		alert('Érvénytelen felhasználónév vagy e-E-mail cím!');
		return false;
	}
	if (!p.match(/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,100}$/) && p.match(/^\S*$/)){
		alert('Érvénytelen jelszó!');
		return false;
	}
	return true;
}