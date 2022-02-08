<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<style> 
body {
  background-color: #cccccc; 
 /*  background-image: url('../../Media/bg6.jpg') ;
  background-repeat: repeat;
  background-size: /* 300px 100px   auto ; */
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
.col-45{
float: left;
	width: 46%;
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


.alert {
	padding: 20px;
	background-color: green;
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
	background-color: green;
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

<script type="text/javascript">
var DataMap="";
var entdOn = "";
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
	var dt = new Date();
	document.getElementById("branchCode").value="<%= session.getAttribute("BranchCode")%>";	
	document.getElementById("year").value=dt.getFullYear();
	
	const months = ["JAN", "FEB", "MAR","APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
	var current_datetime = new Date()
	entdOn = current_datetime.getDate() + "-" + months[current_datetime.getMonth()] + "-" + current_datetime.getFullYear()
	document.getElementById("monthCode").value = dt.getMonth()+1;
	document.getElementById("remarks").value = "";
	document.getElementById("remarks").focus();
}
function BranchCodeValidation(event){
	if (event.keyCode == 13 || event.which == 13) {		
	if (document.getElementById("branchCode").value == ""){
		alert("ENTER YOUR BRANCH CODE!");
		document.getElementById("branchCode").focus();
	}
	if (document.getElementById("branchCode").value != "") {
		clear();
		SetValue("branch_code",document.getElementById("branchCode").value);
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
						document.getElementById("remarks").focus();
					}					
				}
			}
		};
		xhttp.open("POST", "HTTPValidator?" + DataMap, true);
		xhttp.send();
	}
	else{
		document.getElementById("branchCode").focus();
	}
 }
}
function YearValidation(event)
{
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("monthCode").focus();
	}
}

function MonthCodeValidation(event)
{
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("FeedbackType").focus();
	}
}

function UpdateFeedback(){
	clear();
	SetValue("entityNum", "1");
	SetValue("branchCode",document.getElementById("branchCode").value);
	SetValue("year",document.getElementById("year").value);
	SetValue("monthCode",document.getElementById("monthCode").value);
	SetValue("feedbackType",document.getElementById("feedbackType").value);
	SetValue("userID", "<%= session.getAttribute("User_Id")%>");
	SetValue("entd_on",entdOn);
	if(document.getElementById("remarks").value==""){
		document.getElementById("remarks").value = "N/A";
	}
	
	SetValue("remarks",document.getElementById("remarks").value);
	SetValue("Class","FinanceOperation");
	SetValue("Method","UpdateUserFeedback");
	  var xhttp = new XMLHttpRequest();
		xhttp.onreadystatechange = function() {
			if (this.readyState == 4 && this.status == 200) {
				var obj = JSON.parse(this.responseText);
				if (obj.ERROR_MSG != "") {
					alert(obj.ERROR_MSG);
					initValues();
				} else {
					alert(obj.SUCCESS);
					initValues();
				}
			}
		};		
		xhttp.open("POST", "HTTPValidator?" + DataMap, true);
		xhttp.send();
}

function Redirect(){
	var userRole = "<%= session.getAttribute("USER_ROLE")%>";
	if(userRole=="null"){
		top.location = self.location.href = "../";
	}
}
</script>
</head>
<body onload="initValues()">
		<center>
		<h2 style="color:#006600;">User Feedback Page</h2>
		<!-- <div class="alert">
	
			<span class="closebtn"
				onclick="this.parentElement.style.display='none';">&times;</span> <strong>Attention! <br></strong>
			<p>Send us feedback whether your salary is okay or not...</p>
		</div> -->
		<div class="container">
				<div class="row">
					<div class="col-25">
						<label for="branchCode">Branch Code</label>
					</div>
					<div class="col-45">
						<input type="text" id="branchCode" name="branchCode" onkeypress="BranchCodeValidation(event)" readonly>
					</div>
				</div>
				
				<div class="row">
					<div class="col-25">
						<label for="year">Year</label>
					</div>
					<div class="col-45">
						<input type="text" id="year" name="year" onkeypress="YearValidation(event)">
					</div>
				</div>
				
				
				<div class="row">
					<div class="col-25">
							<label for="monthCode">Month</label>
					</div>
					<div class="col-75">
						<select id="monthCode" name="monthCode"  onkeypress="MonthCodeValidation(event)">
							<option value="1">January</option>
							<option value="2">February</option>
							<option value="3">March</option>
							<option value="4">April</option>
							<option value="5">May</option>
							<option value="6">June</option>
							<option value="7">July</option>
							<option value="8">August</option>
							<option value="9">September</option>
							<option value="10">October</option>
							<option value="11">November</option>
							<option value="12">December</option>
						</select>
					</div>
				</div>
								
				<div class="row">
					<div class="col-25">
							<label for="feedbackType">Feedback Type</label>
					</div>
					<div class="col-75">
						<select id="feedbackType" name="feedbackType" >
							<option value="R">Ready - manual salary is ready</option>
							<option value="Y">Yes - all reports are okay</option>
							<option value="N">No - reports aren't okay</option>
							<option value="P">P - PRMS Salary</option>
							<option value="M">M - Manual Salary</option>
						</select>
					</div>
				</div>
				<div class="row">
					<div class="col-25">
						<label for="remarks">Remarks</label>
					</div>
					<div class="col-45">
						<textarea id="remarks" name="remarks" placeholder="Comments..." style="height:100px"></textarea>
					</div>
				</div>
				<div class="row">
					<div class="col-25"> 
						<label for="submit_feedback"></label>
					</div>
					<div class="col-75">
						<input type="submit" id="submit_feedback" value="Submit" onclick="UpdateFeedback()" >
					</div>
				</div>												
		</div>		
	</center>
</body>
</html>