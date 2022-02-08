<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<style>
body {
  /* background-image: url('../Media/bg6.jpg') ;
  padding: 50px;
  background-repeat: no-repeat;
  background-size: auto ; */
  background-color: #cccccc;
}

.container {
	border-radius: 15px;
	background-color: #85adad;
	padding: 10px;
	align: bottom;
}

.alert {
	padding: 20px;
	background-color: #f44336;
	color: white;
}

.closebtn {
	margin-left: 15px;
	color: white;
	font-weight: bold;
	float: right;
	font-size: 22px;
	line-height: 20px;
	cursor: pointer;
	transition: 0.3s;
}

.closebtn:hover {
	color: black;
}

.alert {
	padding: 20px;
	background-color: #f44336;
	color: white;
}

.closebtn {
	margin-left: 15px;
	color: white;
	font-weight: bold;
	float: right;
	font-size: 22px;
	line-height: 20px;
	cursor: pointer;
	transition: 0.3s;
}

.closebtn:hover {
	color: black;
}
</style>
</head>
<body>
<center><p> <%-- Hello <%= session.getAttribute("USER_NAME")%>,  --%></p></center>
 
 
 <div class="container" style = "position:relative; top:20px;"> 
    <h3>Welcome to Payroll Management System(PRMS) of Bangladesh House Building Finance Corporation 
    which is specially designed and developed to generate monthly salary of this corporation as 
    well as festival and incentive bonuses.</h3>
 </div>
 
 <br><br><br><br>
 	<center>
	<div class="alert">
	
			<span class="closebtn"
				onclick="this.parentElement.style.display='none';">&times;</span> <strong>Attention! <br></strong>
			<a href="http://192.168.100.218:8080/PRMS/" target="_blank" style="color:white"> Alternative Server</a>
		</div>
		
		<!-- <marquee behavior="scroll" direction="left" scrollamount="3" bgcolor = "cyan" txt-color="coral">Send us instant message at Google Hangouts: query.prms@gmail.com   &nbsp;&nbsp;...Thanks!</marquee> -->
		
		</center>
		
 <!-- <div class="quote-container">

  <i class="pin"></i>
  
  <blockquote class="note yellow">
    Welcome to Payroll Management System(PRMS) of Bangladesh House Building Finance Corporation 
    which is specially designed and developed to generate monthly salary of this corporation as 
    well as festival and incentive bonuses.
    <cite class="author"></cite>
  </blockquote>

</div> -->
</body>
</html>