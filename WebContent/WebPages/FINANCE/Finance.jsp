<!-- ***************************************************************************
|*			Project Name: 	Payroll Management System						  *|
|*			Developer	: 	1. Md. Rubel Talukder							  *|
|*					   		2. Mosharraf Hossain Talukder					  *|
|*					 		------------------------------					  *|
|*					      	ICT Department, HO BHBFC.						  *|
|*		    Supervised By	: 	Md Rokunuzzaman								  *|
|*																			  *|
*****************************************************************************-->
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<link rel="shortcut icon" href="../../Media/bhbfc_icon.ico"> 
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script src='https://kit.fontawesome.com/a076d05399.js'></script>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Accounts Home</title>

<style>
.rectangle {  
    background-color: #85adad;
	overflow: auto;
	align: center;
	height: 100;
	width: 60.4%;
}

body {
  font-family: Arial, Helvetica, sans-serif;
}

.navbar {
  background-color: #00b33c;
	overflow: auto;
	align: center;
	height: 40px;
	width: 60.5%;
}

.navbar a {
  float: left;
	color: #f2f2f2;
	text-align: center;
	padding: 15px;
	text-decoration: none;
	font-size: 14px;
	width: 10.2%;
}

.navbar a.active {
	background-color: #196619;
	color: coral;
	height: 40px;
}

.navbar a:hover, .dropdown:hover .dropbtn {
  background-color: #196619;
	color: coral;
	height: 40px;
}

.dropdown {
  float: left;
  overflow: hidden;
}

.dropdown .dropbtn {
  font-size: 16px;  
  border: none;
  outline: none;
  color: white;
  padding: 18px 16px;
  background-color: inherit;
  font-family: inherit;
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: #00b33c;
  min-width: 120px;
  z-index: 1;
}

.dropdown-content a {
  float: none;
  color: black;
  padding: 12px 16px;
  text-decoration: none;
  display: block;
  text-align: left;
  min-width: 89px;
}

.dropdown-content a:hover {
  background-color: #196619;
  height: 20px;
}

.dropdown:hover .dropdown-content {
  display: block;
}

</style>

<script type="text/javascript">
var DataMap="";
function SetValue(key,value){
	var Node = key+"*"+value;
	if(DataMap!=""){
		DataMap=DataMap+"$"+Node;
	}
	else{
		DataMap="data="+Node;
	}
}
function clear(){
	DataMap="";
}

function initValues(){
	Redirect();
}

function LogOut()
{
	clear();
	SetValue("Class","LoginValidation");
	SetValue("Method","LogOut");
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			top.location = self.location.href = "../../";
		}
	};
	xhttp.open("POST", "HTTPValidator?" + DataMap, true);
	xhttp.send();
		
}
function Redirect(){
	var userRole = "<%= session.getAttribute("USER_ROLE")%>";
	if(userRole=="null"){
		top.location = self.location.href = "../../";
	}
	else if(userRole!="G"){
		LogOut();	
	}
}

</script>
</head>
<body onload="initValues()">
	<center>
	<div class="rectangle" style="align: center">
			<!-- <table>
				<tr>
					<td rowspan="2"><img src="../../Media/bhbfc_icon.ico" width="100" height="100"></td>
   					<td><h1 style="color:maroon; font-family:Georgia"><center>Payroll Management System</center></h1></td>
					<td></td>
				</tr>
				<tr>
					<td><h1 style="color:green; font-family:impact"><center>Bangladesh House Building Finance Corporation</center></h1></td>
				</tr>
			</table> -->
			<table>
				<tr>
					<td><img src="../../Media/bhbfc_icon.ico" width="100" height="100"></td>
					<td><h1 style="color:maroon; font-family:Georgia"><center>Payroll Management System</center></h1>
					<h1 style="color:green; font-family:impact"><center>Bangladesh House Building Finance Corporation</center></h1></td>
				</tr>
			</table>
			<!-- <h1 style="color:maroon; font-family:Georgia">Payroll Management System</h1>
			<h1 style="color:green; font-family:impact">Bangladesh House Building Finance Corporation</h1> -->
		</div>
		<!-- <div style="height: 25%"></div>
		<div style="height: 50%">
			<img src="../../Media/bhbfc_home.jpg" alt="" width="806" height="100">
		</div> -->
		<div class="navbar" style="height: 100%">
			<a class="active" href="Finance.jsp"><i class="fa fa-fw fa-home" style="font-size: 15px"></i><br>Home</a> 
			<a href="InitProfile.jsp" target="contents_1"><i class="fas fa-user-edit" style="font-size: 15px"></i> <br>Active Profile</a>
			<a href="AddAllowance.jsp" target="contents_1"><i class="fa fa-plus-circle" style="font-size: 15px"></i><br> Allowance</a>
			<a href="AddDeduction.jsp" target="contents_1"><i class="fa fa-minus-circle" style="font-size: 15px"></i><br> Deduction</a>			
			<a href="PersonalInfo.jsp" target="contents_1"><i class="fa fa-minus-circle" style="font-size: 15px"></i><br> Personal info</a>
			<a href="EntryForm.jsp" target="contents_1"><i class="fa fa-minus-circle" style="font-size: 15px"></i><br> Entry Form</a>
			
			</div>


		<div>
			<iframe height="500px" width="48.8%" src="../Welcome.jsp" name="contents_1" style="border: 1px solid green;"> </iframe>
			<iframe height="500px" width="11.1%" src="../Aside.jsp" name="contents_2" style="border: 1px solid green;"></iframe>
		</div>
	</center>
	<footer>
	<div style="text-align: center;">
            <p>Copyright &#xA9; 2019-20.
              <strong>Design & Developed By ICT Department, <a href="http://www.bhbfc.gov.bd/" target="_blank">BHBFC.</a></strong>
              All Rights Reserved.</p>              
        </div>
    </footer>
</body>
</html>