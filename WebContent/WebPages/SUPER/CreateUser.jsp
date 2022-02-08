<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page session="true" %>	
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<style>

.datepicker
{ 
    width: 26em;
    height: 2.5em;
}
body {
  /* background-image: url('../../Media/bg9.jpg') ;
  background-repeat: no-repeat;
  background-size: /* 300px 100px   auto ; */
  background-color: #cccccc; 
}

 {
	box-sizing: border-box;
}

input[type=text],select,textarea {
	width: 100%;
	padding: 12px;
	border: 1px solid #ccc;
	border-radius: 4px;
	resize: vertical;
}
input[type=password],select,textarea {
	width: 100%;
	padding: 12px;
	border: 1px solid #ccc;
	border-radius: 4px;
	resize: vertical;
}
label {
	padding: 12px 12px 12px 0;
	display: inline-block;
}

input[type=submit] {
	background-color: #4CAF50;
	color: white;
	padding: 12px 20px;
	border: none;
	border-radius: 4px;
	cursor: pointer;
	float: left;
}

input[type=submit]:hover {
	background-color: #45a049;
}

.container {
	border-radius: 5px;
	background-color: #85adad;
	padding: 20px;
}

.col-25 {
	float: left;
	width: 40%;
	margin-top: 6px;
}
.col-15{
float: left;
	width: 20%;
	margin-top: 6px;
}
.col-35{
float: left;
	width: 30%;
	margin-top: 6px;
}

.col-75 {
	float: left;
	width: 50%;
	margin-top: 6px;
}



/* Clear floats after the columns */
.row:after {
	content: "";
	display: table;
	clear: both;
}

/* Responsive layout - when the screen is less than 600px wide, make the two columns stack on top of each other instead of next to each other */
@media screen and (max-width: 600px) {
	.col-25,.col-75,input[type=submit] {
		width: 100%;
		margin-top: 0;
	}
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
function upperCase(a){
    setTimeout(function(){
        a.value = a.value.toUpperCase();
    }, 1);
}


function InitValues(){
	document.getElementById("branch_code").value="";
	document.getElementById("UserRole").value="";
	document.getElementById("UserPass").value="";
	document.getElementById("ConUserPass").value="";
	document.getElementById("branch_name").value="";
	document.getElementById("UserRole").focus();
}
function UserRoleKeyPress(event)
{
	if (event.keyCode == 13 || event.which == 13) {
		if (document.getElementById("UserRole").value != "") {
			document.getElementById("branch_code").focus();
		}
	}
}
function BranchKeyPress(event)
{
	if (event.keyCode == 13 || event.which == 13) {
		if (document.getElementById("branch_code").value != "") {
			clear();
		    SetValue("branch_code",document.getElementById("branch_code").value);
			SetValue("Class","PRMSValidator");
			SetValue("Method","BranchKeyPress");
			var xhttp = new XMLHttpRequest();
			xhttp.onreadystatechange = function() {
				if (this.readyState == 4 && this.status == 200) {
					var obj = JSON.parse(this.responseText);
					if (obj.ERROR_MSG != "") {
						alert(obj.ERROR_MSG);
					} else {
						if (obj.ERROR_MSG != "") {
							alert(obj.ERROR_MSG);
						} else {
							document.getElementById("branch_name").value=obj.BRN_NAME;
							document.getElementById("UserPass").focus();
						}
						
					}
				}
			};
			xhttp.open("POST", "HTTPValidator?" + DataMap, true);
			xhttp.send();
		}
		else{
			alert("User Id should not be null");
		}
	}
}

function PasswordKeyPress(event)
{
	if (event.keyCode == 13 || event.which == 13) {
		if (document.getElementById("UserPass").value != "") {
			document.getElementById("ConUserPass").focus();
		}
		else{
			alert("Password  should not be null");
		}
	}
}
function RevalidatePassword(event)
{
	if (event.keyCode == 13 || event.which == 13) {
		if (document.getElementById("ConUserPass").value != "") {
			if (document.getElementById("UserPass").value==document.getElementById("ConUserPass").value){
					document.getElementById("submitLogin").focus();
				}
			else{
					alert("Password Does not Match");
				}
		}
		else{
			alert("Password  should not be null");
		}
	}
}

function CreateUser(event)
{
		clear();
	    SetValue("branch_code",document.getElementById("branch_code").value);
	    SetValue("UserRole",document.getElementById("UserRole").value);
	    SetValue("Branch_name",document.getElementById("branch_name").value);
	    SetValue("Password",document.getElementById("UserPass").value);
		SetValue("Class","SuperOperation");
		SetValue("Method","CreateUser");
		var xhttp = new XMLHttpRequest();
		xhttp.onreadystatechange = function() {
			if (this.readyState == 4 && this.status == 200) {
				var obj = JSON.parse(this.responseText);
					if (obj.ERROR_MSG != "") {
						alert(obj.ERROR_MSG);
					} else {
						alert(obj.SUCCESS);
						InitValues();
					}									
			}
		};
		xhttp.open("POST", "HTTPValidator?" + DataMap, true);
		xhttp.send();	
	
}
</script>

</head>
<body onload="InitValues()">

<center>
<h2>User Creation Form</h2>

		<div class="container">
				<div class="row">
					<div class="col-25">
						<label for="UserRole">User Role</label>
					</div>
					<div class="col-75">
						<select id ="UserRole"  onkeypress="UserRoleKeyPress(event)">
			        		<option id="RoleAdmin"   value="A">A-Admin</option>
			        		<option id="RoleFinance" value="F">F-Finance</option>	
			        		<option id="RoleManager" value="M">M-Branch Manager</option>
			        		<option id="RoleSuper"   value="S">S-Super User</option>		  
			           </select>				
			        </div>
				</div>
			   <div class="row">
					<div class="col-25">
						<label for="branch_code">Branch Code</label>
					</div>
					<div class="col-75">
						<input id="branch_code" type="text" name="branch_code"  maxlength="45" onkeypress="BranchKeyPress(event)" onkeydown="upperCase(this)">
					</div>
				</div>	
				
				<div class="row">
					<div class="col-25">
						<label for="branch_name">Branch Name</label>
					</div>
					<div class="col-75">
						<input id="branch_name" type="text" name="branch_name"  maxlength="45" readonly>
					</div>
				</div>	
				
				<div class="row">
					<div class="col-25">
						<label for="UserPass">Password</label>
					</div>
					<div class="col-75">
						<input id="UserPass" type="password" name="UserPass" maxlength="45" onkeypress="PasswordKeyPress(event)">
					</div>
				</div>	
								
				<div class="row">
					<div class="col-25">
						<label for="ConUserPass">Confirm Password</label>
					</div>
					<div class="col-75">
						<input id="ConUserPass" type="password" name="ConUserPass" maxlength="45" onkeypress="RevalidatePassword(event)">
					</div>
				</div>	
				
				<div class="col-75"></div>
				<div class="row">
					<input type="submit" id="submitLogin" value="Submit" onclick="CreateUser(event)" >
				</div>				
		</div>	
</center>
</body>
</html>