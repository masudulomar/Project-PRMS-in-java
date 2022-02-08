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
<%@ page session="true" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<link rel="shortcut icon" href="../../Media/bhbfc_icon.ico"> 
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Manager Home</title>

<style>
.rectangle {  
    background-color: #85adad;
	overflow: auto;
	align: center;
	height: 100;
	width: 60.4%;
}

.topnav {
	background-color: #00b33c;
	overflow: auto;
	align: center;
  	height: 100;
	width: 60.4%;
}

.topnav a {
	float: left;
	color: #f2f2f2;
	text-align: center;
	padding: 14px 16px;
	text-decoration: none;
	font-size: 15px;
	width: 16%;
}

.topnav a:hover {
	background-color: #196619;
	color: white;
}

.topnav a.active {
	background-color: #196619;
	color: white;
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
function InitValues(){
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
	else if(userRole!="M"){
		LogOut();	
	}
}

</script>
</head>
<body onload="InitValues()">
	<center>
		<!-- <div>
			<img src="../../Media/bhbfc_home.jpg" alt="" width="804" height="100">
		</div> -->
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
		 
		<!-- <div class="rectangle" style="height: 100%">
		<center>
			<h2><font color="blue" >Payroll Management System</font></h2>
			<hr style=" border: 1px solid coral;">
			<h2><font color="blue" >Bangladesh House Building Finance Corporation</font></h2>
		</center>
		</div> -->
		
		<div class="topnav" style="align: center">
			<a class="active" href="Manager.jsp"><i class="fa fa-fw fa-home" style="font-size: 24px"></i> Home</a> 
			<a href="SalaryReport.jsp" target="contents_1"><i class="fa fa-download" style="font-size: 24px"></i> Salary Report</a>
			<a href="BonusReport.jsp" target="contents_1"><i class="fa fa-download" style="font-size: 24px"></i> Bonus Report</a>
			<a href="../ResetPassword.jsp" target="contents_1"><i class="fa fa-cog fa-spin" style="font-size: 24px"></i> Reset Password</a>				
			<a href="../Help.jsp" target="contents_1"><i class="fa fa-phone-square" style="font-size: 24px"></i> Help</a>
		</div>
		
		<div>
			<iframe height="450px" width="48.7%" src="../Welcome.jsp" name="contents_1" style="border: 1px solid green;"> </iframe>
			<iframe height="450px" width="11.1%" src="../Aside.jsp" name="contents_2" style="border: 1px solid green;"></iframe>
		</div>
	</center>
	<footer>
	<div style="text-align: center;">
            <p>Copyright &#xA9; 2019.
              <strong>Design & Developed By ICT Department, <a href="http://www.bhbfc.gov.bd/" target="_blank">BHBFC.</a></strong>
              All Rights Reserved.</p>              
        </div>
    </footer>
</body>
</html>