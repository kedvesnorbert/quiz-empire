window.onload = function(){

	(function(){
	var counter = 900;

	setInterval(function() {
    counter--;
    if (counter >= 0) {
      span = document.getElementById("count_logoff");
	  var x = Math.floor(counter/60);
	  var y = counter%60;
	  if(counter >=600)
	  {
		  
		  if(y < 10)
		  {
			  span.innerHTML = x + ":0" + y;
		  }
		  else
		  {
			  span.innerHTML = x + ":" + y;
		  }
	  }
	  else
	  {
		  if(y < 10)
		  {
			  span.innerHTML = "0" + x + ":0" + y;
		  }
		  else
		  {
			  span.innerHTML = "0" + x + ":" + y;
		  }
	  }
    }
    if (counter === 0) {
        clearInterval(counter);
    }

	}, 1000);

	})();

}