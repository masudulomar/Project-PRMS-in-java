<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Personal Information - PRMS</title>

<style>

.datepicker
{ 
    width: 10.5em;
    height: 2.5em;
}
body {
  background-color: #cccccc;
  /* background-image: url('../../Media/bg6.jpg') ;
  background-repeat: repeat;
  background-size: /* 300px 100px  auto ; */
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

.col-15 {
	float: left;
	width: 20%;
}
.colr-15 {
	float: left;
	width: 15%;
	margin-left: 50px;
}
.col-20 {
	float: left;
	width: 30%;
}
.coln-20 {
	float: left;
	width: 20%;
}
.colr-20 {
	float: left;
	width: 20%;
	
}
.col-25 {
	float: left;
	width: 40%;
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
function initValues(){
	document.getElementById("PFId").value="";
	document.getElementById("EmpName").value="";	
	document.getElementById("University").value="";
	document.getElementById("Subject").value="";
	document.getElementById("PFId").focus();
}
function PFIdValidation(event)
{
	if(document.getElementById("PFId").value==""){
		initValues();											//newly added
	}

	if (event.keyCode == 13 || event.which == 13) 
	{
		var usr_brn = "<%= session.getAttribute("BranchCode")%>";
		clear();
		SetValue("PFId",document.getElementById("PFId").value);  
		SetValue("Class","FinanceOperation");
		SetValue("Method","FetchPersonalInitData");
		//SetValue("UserBranchCode",usr_brn);
		var xhttp = new XMLHttpRequest();
		
		/*xhttp.onreadystatechange = function() 
		{
			if (this.readyState == 4 && this.status == 200) 
			{
				var obj = JSON.parse(this.responseText);
				if (obj.ERROR_MSG != "") 
				{
					alert(obj.ERROR_MSG);
					initValues();
				} 
				else 
				{
					document.getElementById("EmpName").value=obj.EMP_NAME;							
					document.getElementById("University").value=obj.TEL_ALLOWANCE;
					document.getElementById("Subject").value=obj.TRANS_ALLOWANCE;
					document.getElementById("EmpName").focus();
				}									
			}
		};*/
		xhttp.onreadystatechange = function() 
		{
			if (this.readyState == 4 && this.status == 200)    ///https://www.w3schools.com/xml/ajax_xmlhttprequest_response.asp 
			{
				var obj = JSON.parse(this.responseText);
				if (obj.ERROR_MSG != "") 
				{
					document.getElementById("EmpName").value="";	
					document.getElementById("University").value="";
					document.getElementById("Subject").value="";
					document.getElementById("EmpName").focus();	
					
					
				} 
				else 
				{	
					if(obj.PF_NUM!=null)
					{							
						document.getElementById("EmpName").value=obj.UNAME;
						document.getElementById("University").value=obj.UNIVERSITY;
						document.getElementById("Subject").value=obj.SUBJECT;
						document.getElementById("PFId").focus();					
						var r = confirm("Profile already initialized!\nDo you want to update?");
						if (r == true) 
						{
							document.getElementById("EmpName").focus();													   
						} 
						else 
						{
							initValues();							 
						}		
					}
					else 
					{
							
						document.getElementById("EmpName").value="";
						document.getElementById("University").value="";
						document.getElementById("Subject").value="";
						document.getElementById("EmpName").focus();						 
					}							 				
				}									
			}
		};
		xhttp.open("POST", "HTTPValidator?" + DataMap, true);
		xhttp.send();			
	}
}

function EmpNameValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("University").focus();
	}
}

function UniversityValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("Subject").focus();
	}
}


function SubjectValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("submit").focus();
	}
}

function UpdatePersonalInfo(event)
{
	clear();
	SetValue("PFId",document.getElementById("PFId").value);
	SetValue("EmpName",document.getElementById("EmpName").value);
	SetValue("University",document.getElementById("University").value);
	SetValue("Subject",document.getElementById("Subject").value);
	SetValue("Class","FinanceOperation");
	SetValue("Method","UpdatePersonal_info");
	
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() 
	{
		if (this.readyState == 4 && this.status == 200) 
		{
			var obj = JSON.parse(this.responseText);
			if (obj.ERROR_MSG != "") 
			{
				alert(obj.ERROR_MSG);
				initValues(); //newly added -OM
			} 
			else 
			{
				alert(obj.SUCCESS);
				initValues();
			}
		}
	};			
	xhttp.open("POST", "HTTPValidator?" + DataMap, true);
	xhttp.send();
}
</script>
</head>
<body onload="initValues()">
	<center>
	<h2>Personal Information</h2>
		<div class="container">
		<fieldset>
			<div class="row">
				<div class="col-15">
					<label for="PFId">Employee's PF Number</label>
				</div>
				<div class="col-20">
					<input type="text" id="PFId" name="PFId" onkeypress="PFIdValidation(event)">
				</div>
				
				<div class="colr-15">
					<label for="EmpName">Employee Name</label>
				</div>
				<div class="coln-20">
					<input type="text" id="EmpName" name="EmpName" onkeypress="EmpNameValidation(event)" >
				</div>										
			 </div>

				<div class="row">
				<div class="col-15">
					<label for="University">University </label>
				</div>
				<div class="col-20">
					<input type="text" id="University" name="University"  onkeypress="UniversityValidation(event)" >
				</div>
				
				<div class="colr-15">
					<label for="Subject">Subject</label>
				</div>
				<div class="colr-20">
					<input type="text" id="Subject" name="Subject"  onkeypress="SubjectValidation(event)" >
				</div>										
			  </div>	
					
			  </fieldset>			  			  			  															
			<div class="col-75"></div>
			<div class="row">
				<input type="submit" id="submit" value="Update" onclick="UpdatePersonalInfo(event)" >
			</div>
		</div>
	</center>
</body>
</html>