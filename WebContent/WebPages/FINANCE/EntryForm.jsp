<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Entry Form</title>

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

.colt-5 {
	float: left;
	width: 23%;
	margin-left: 0px;
}
.colt-10 {
	float: left;
	width: 10%;
	margin-left: 1px;
}

.colt-15 {
	float: left;
	width: 40%;
	margin-left: 28px;
}

.col-15 {
	float: left;
	width: 23%;
}

.coll-20 {
	float: left;
	width: 55%;
}

.col-20 {
	float: left;
	width: 26%;
}
.colr-15 {
	float: left;
	width: 18%;
	margin-left: 30px;
}

.colr-20 {
	float: left;
	width: 22%;	
}

.coln-20 {
	float: left;
	width: 30%;
}

.col-25 {
	float: left;
	width: 40%;
}

.col-35{
float: left;
	width: 30%;

}

.col-75 {
	float: left;
	width: 50%;
	margin-left: 250px;

}
.col-1 {
	float: left;
	width: 3%;

}
.col-2 {
	float: left;
	width: 14%;
	margin-left: 28px;

}
.col-3 {
	float: left;
	width: 5%;

}
.col-4 {
	float: left;
	width: 16%;
	margin-left: 28px;

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

	document.getElementById("BorrowerName").value="";   //NAME1
	document.getElementById("JointBorrower").value="";  //NAME2
	document.getElementById("FatherName").value="";     //F_NAME
	document.getElementById("HusbandName").value="";    //H_NAME
	document.getElementById("MotherName").value="";     //M_NAME
	document.getElementById("MailingAddress").value=""; //M_ADD1
	document.getElementById("PhoneRes").value="";       //PHONE_RES
	document.getElementById("PhoneOff").value="";       //PHONE_OFF
	document.getElementById("MobileNo").value="";	    //CELL_NO				
	document.getElementById("SiteAddress").value="";    //S_ADD1
	document.getElementById("Email").value="";          //EMAIL
	document.getElementById("ProjCode").value="";       //PROJ_CODE
	document.getElementById("NID1").value="";           //NID1
	document.getElementById("DistrictCode").value="";   //S_DIST_CODE
	document.getElementById("NID2").value="";           //NID2
	document.getElementById("ThanaCode").value="";      //S_THANA_CODE
	document.getElementById("BranchCode").focus();
	
	
	//LOAN_CODE, LOC_CODE, NAME1, NAME2, F_NAME, H_NAME, M_NAME, M_ADD1, PHONE_RES, PHONE_OFF, CELL_NO, S_ADD1, EMAIL, PROJ_CODE, NID1, S_DIST_CODE, NID2, S_THANA_CODE   
}

function BranchCodeValidation(event)
{
	if(document.getElementById("BranchCode").value==""){
		document.getElementById("LoanCode").value="";
		initValues();
	}
	if (event.keyCode == 13 || event.which == 13) 
	{
		clear();
		SetValue("BranchCode",document.getElementById("BranchCode").value);
	}
	document.getElementById("LoanCode").focus();
	
}


function LoanCodeValidation(event)
{

	if(document.getElementById("LoanCode").value=="" && document.getElementById("BranchCode").value=="")
	{
		initValues();
	}
	if (event.keyCode == 13 || event.which == 13) 
	{
		if(document.getElementById("LoanCode").value.toString().length != 13)
		{
			confirm("Loan Code should be 13 digit");
			document.getElementById("LoanCode").focus();
		}
		else
		{	
			clear();
			SetValue("LoanCode",document.getElementById("LoanCode").value);
			SetValue("BranchCode",document.getElementById("BranchCode").value);
			SetValue("Class","FinanceOperation");
			SetValue("Method","FetchLoanData");
			
			var xhttp = new XMLHttpRequest();
			xhttp.onreadystatechange = function() 
			{
				if (this.readyState == 4 && this.status == 200) 
				{
					var obj = JSON.parse(this.responseText);
					if (obj.ERROR_MSG != "") 
					{
						alert(obj.ERROR_MSG);
						initValues();
						document.getElementById("BorrowerName").focus();
					} 
					else 
					{
						
						if(obj.LOAN_CODE!=null)
						{
							document.getElementById("BorrowerName").value = (obj.NAME1!=null) ? obj.NAME1 :"";
							document.getElementById("JointBorrower").value= (obj.NAME2!=null) ? obj.NAME2 :"";
							document.getElementById("FatherName").value=(obj.F_NAME!=null) ? obj.F_NAME :"";
							document.getElementById("HusbandName").value=(obj.H_NAME!=null) ? obj.H_NAME :"";
							document.getElementById("MotherName").value=(obj.M_NAME!=null) ? obj.M_NAME :"";
							document.getElementById("MailingAddress").value=(obj.M_ADD!=null) ? obj.M_ADD :"";
							document.getElementById("PhoneRes").value=(obj.PHONE_RES!=null) ? obj.PHONE_RES :"";
							document.getElementById("PhoneOff").value=(obj.PHONE_OFF!=null) ? obj.PHONE_OFF :"";
							document.getElementById("MobileNo").value=(obj.CELL_NO!=null) ? obj.CELL_NO :"";						
							document.getElementById("SiteAddress").value=(obj.S_ADD!=null) ? obj.S_ADD :"";
							document.getElementById("Email").value=(obj.EMAIL!=null) ? obj.EMAIL :"";
							document.getElementById("ProjCode").value=(obj.PROJ_CODE!=null) ? obj.PROJ_CODE :"";
							document.getElementById("NID1").value=(obj.NID1!=null) ? obj.NID1 :"";
							document.getElementById("DistrictCode").value=(obj.S_DIST_CODE!=null) ? obj.S_DIST_CODE :"";
							document.getElementById("NID2").value=(obj.NID2!=null) ? obj.NID2 :"";
							document.getElementById("ThanaCode").value=(obj.S_THANA_CODE!=null) ? obj.S_THANA_CODE :"";
							document.getElementById("LoanCode").focus();
							
							var r = confirm("Profile already initialized!\nDo you want to update?");
							if (r == true) 
							{
								document.getElementById("BorrowerName").focus();													   
							} 
							else 
							{
								document.getElementById("BranchCode").value="";
								document.getElementById("LoanCode").value="";
								initValues();							 
							}		
						}
						else 
						{
							initValues();
							document.getElementById("BorrowerName").focus();	
						}
					}									
				}
			};

			xhttp.open("POST", "HTTPValidator?" + DataMap, true);
			xhttp.send();
		}
	}
}

function BorrowerNameValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("JointBorrower").focus();
	}
}

function JointBorrowerValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("FatherName").focus();
	}
}

function FatherNameValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("HusbandName").focus();
	}
}

function HusbandNameValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("MotherName").focus();
	}
}

function MotherNameValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("MailingAddress").focus();
	}
}

function MailingAddressValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("SiteAddress").focus();
	}
}

function SiteAddressValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("DistrictCode").focus();
	}
}


function DistrictCodeValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("ThanaCode").focus();
	}
}

function ThanaCodeValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("PhoneRes").focus();
	}
}

function PhoneResValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("PhoneOff").focus();
	}
}

function PhoneOffValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("MobileNo").focus();
	}
}

function MobileNoValidation(event)
{
	if (event.keyCode == 13 || event.which == 13) 
	{
		if(document.getElementById("MobileNo").value.toString().length != 11)
		{
			confirm("Mobile Number should be 11 digit");
			document.getElementById("MobileNo").focus();
		}
		else
		{
			document.getElementById("Email").focus();
		}
	}
}
//document.getElementById("Email").value.toString().indexOf('@')!=1
//document.getElementById("Email").value.toString().indexOf('@')+1!=document.getElementById("Email").value.toString().length
function EmailValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		//if(1)
		if(document.getElementById("Email").value.toString().indexOf('@')==-1 || document.getElementById("Email").value.toString().indexOf('@')==0 || document.getElementById("Email").value.toString().indexOf('@')+1==document.getElementById("Email").value.toString().length)
		{
			//confirm(document.getElementById("Email").value.toString().indexOf('@'));
			confirm("Email Address in not valid");
			document.getElementById("Email").focus();
		}
		else
		{
			document.getElementById("ProjCode").focus();
		}
		//document.getElementById("ProjCode").focus();
	}
}

function ProjCodeValidation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("NID1").focus();
	}
}

function NID1Validation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("NID2").focus();
	}
}

function NID2Validation(event){
	if (event.keyCode == 13 || event.which == 13) {
		document.getElementById("submit").focus();
	}
}

function InsertUpdateLoanDataFunc(event)
{
	clear();
	SetValue("BranchCode",document.getElementById("BranchCode").value);
	//SetValue("BranchName",document.getElementById("BranchName").value);
	SetValue("LoanCode",document.getElementById("LoanCode").value);
	//SetValue("LoanName",document.getElementById("LoanName").value);
	SetValue("BorrowerName",document.getElementById("BorrowerName").value);
	SetValue("JointBorrower",document.getElementById("JointBorrower").value);
	SetValue("FatherName",document.getElementById("FatherName").value);
	SetValue("HusbandName",document.getElementById("HusbandName").value);
	SetValue("MotherName",document.getElementById("MotherName").value);
	SetValue("MailingAddress",document.getElementById("MailingAddress").value);
	//SetValue("MailingAddress",document.getElementById("MailingAddress").value+" "+document.getElementById("MailingAddress2").value+" "+document.getElementById("MailingAddress3").value);
	//SetValue("MailingAddress2","";
	//SetValue("MailingAddress3","");
	
	SetValue("PhoneRes",document.getElementById("PhoneRes").value);
	SetValue("PhoneOff",document.getElementById("PhoneOff").value);
	SetValue("MobileNo",document.getElementById("MobileNo").value);
	SetValue("SiteAddress",document.getElementById("SiteAddress").value);
	SetValue("Email",document.getElementById("Email").value);
	//SetValue("ProjName",document.getElementById("ProjName").value);
	SetValue("ProjCode",document.getElementById("ProjCode").value);
	SetValue("NID1",document.getElementById("NID1").value);
	//SetValue("DistrictName",document.getElementById("DistrictName").value);
	SetValue("DistrictCode",document.getElementById("DistrictCode").value);
	SetValue("NID2",document.getElementById("NID2").value);
	//SetValue("ThanaName",document.getElementById("ThanaName").value);
	SetValue("ThanaCode",document.getElementById("ThanaCode").value);
	
	SetValue("Class","FinanceOperation");
	SetValue("Method","InsertUpdateLoanData");
	
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() 
	{
		if (this.readyState == 4 && this.status == 200) 
		{
			var obj = JSON.parse(this.responseText);
			if (obj.ERROR_MSG != "") 
			{
				alert(obj.ERROR_MSG);
				//initValues(); //newly added -OM
			} 
			else 
			{
				alert(obj.SUCCESS);
				//initValues();
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
	<h2>Entry Form</h2>
		<div class="container">

		<fieldset>
			<div class="row">
				<div class="colt-5">
					<label for="BranchCode">Branch Code</label>
				</div>
				<%/*
				<div class="colt-10">
					<input type="text" id="BranchName" name="BranchName" onkeypress="BranchNameValidation(event)">
				</div>
				*/%>
				<div class="colt-15">
					<input type="text" id="BranchCode" name="BranchCode" onkeypress="BranchCodeValidation(event)">
				</div>
			</div>
				
			<div class="row">
				<div class="colt-5">
					<label for="LoanCode">Loan Code</label>
				</div>
				<div class="colt-15">
					<input type="text" id="LoanCode" name="LoanCode" onkeypress="LoanCodeValidation(event)">
				</div>	
			</div>
			 
		</fieldset>
		
		
		<fieldset>	
			<div class="row">
				<div class="col-15">
					<label for="BorrowerName">Borrower Name: </label>
				</div>
				<div class="coll-20">
					<input type="text" id="BorrowerName" name="BorrowerName"  onkeypress="BorrowerNameValidation(event)">
				</div>
			</div>
				
			<div class="row">
				<div class="col-15">
					<label for="JointBorrower">Joint borrower: </label>
				</div>
				<div class="coll-20">
					<input type="text" id="JointBorrower" name="JointBorrower"  onkeypress="JointBorrowerValidation(event)" >
				</div>										
			</div>	
					
			<div class="row">
				<div class="col-15">
					<label for="FatherName">Father Name: </label>
				</div>
				<div class="coll-20">
					<input type="text" id="FatherName" name="FatherName"   onkeypress="FatherNameValidation(event)">
				</div>
			</div>
				
			<div class="row">
				<div class="col-15">
					<label for="HusbandName">Husband Name: </label>
				</div>
				<div class="coll-20">
					<input type="text" id="HusbandName" name="HusbandName"  onkeypress="HusbandNameValidation(event)" >
				</div>										
			 </div>	
			
			<div class="row">
				<div class="col-15">
					<label for="MotherName">Mother Name: </label>
				</div>
				<div class="coll-20">
					<input type="text" id="MotherName" name="MotherName"  onkeypress="MotherNameValidation(event)">
				</div>
			</div>
				
			<div class="row">
				<div class="col-15">
					<label for="MailingAddress">Mailing address: </label>
				</div>
				<div class="col-20">
					<input type="text" id="MailingAddress" name="MailingAddress"   onkeypress="MailingAddressValidation(event)">
				</div>										

				<div class="colr-15">
					<label for="PhoneRes">Phone (Res): </label>
				</div>
				<div class="colr-20">
					<input type="text" id="PhoneRes" name="PhoneRes"  onkeypress="PhoneResValidation(event)">
				</div>
			</div>
			
			<div class="row">		
				<div class="col-15">
					<label for="SiteAddress">Site address: </label>
				</div>
				<div class="col-20">
					<input type="text" id="SiteAddress" name="SiteAddress"   onkeypress="SiteAddressValidation(event)">
				</div>									
				<div class="colr-15">
					<label for="PhoneOff">Phone (Off): </label>
				</div>
				<div class="colr-20">
					<input type="text" id="PhoneOff" name="PhoneOff"  onkeypress="PhoneOffValidation(event)">
				</div>
			</div>
			
			<div class="row">	
				<div class="col-15">
					<label for="NID1">NID1: </label>
				</div>
				<div class="col-20">
					<input type="text" id="NID1" name="NID1"  onkeypress="NID1Validation(event)">
				</div>								
				<div class="colr-15">
					<label for="MobileNo">Mobile no: </label>
				</div>
				<div class="colr-20">
					<input type="text" id="MobileNo" name="MobileNo"  onkeypress="MobileNoValidation(event)">
				</div>	
			</div>
			
			<div class="row">
				<div class="col-15">
					<label for="NID2">NID2: </label>
				</div>
				<div class="col-20">
					<input type="text" id="NID2" name="NID2"  onkeypress="NID2Validation(event)">
				</div>	
				<div class="colr-15">
					<label for="Email">Email: </label>
				</div>
				<div class="colr-20">
					<input type="text" id="Email" name="Email"  onkeypress="EmailValidation(event)">
				</div>	
			</div>
			
			<div class="row">									
				<div class="col-15">
					<label for="DistrictCode">District Code: </label>
				</div>
				<div class="col-20">
					<input type="text" id="DistrictCode" name="DistrictCode"   onkeypress="DistrictCodeValidation(event)">
				</div>	
				
				<div class="colr-15">
					<label for="ProjCode">Proj code: </label>
				</div>
				<%/*
				<div class="col-1">
					<input type="text" id="ProjName" name="ProjName"  onkeypress="ProjValidation(event)">
				</div>
				*/%>
				<div class="colr-20">
					<input type="text" id="ProjCode" name="ProjCode"  onkeypress="ProjCodeValidation(event)">
				</div>
			</div>
			

			
			<div class="row">
				<div class="col-15">
					<label for="ThanaCode">Thana Code: </label>
				</div>
				<%/*
				<div class="col-3">
					<input type="text" id="ThanaName" name="ThanaName"   onkeypress="ThanaNameValidation(event)">
				</div>	
				*/%>
				<div class="col-20">
					<input type="text" id="ThanaCode" name="ThanaCode"   onkeypress="ThanaCodeValidation(event)">
				</div>									
			</div>
	
		</fieldset>			  			  			  															

			<div class="row">
				<div class="col-75">
					<input type="submit" id="submit" value="Insert/Update" onclick="InsertUpdateLoanDataFunc(event)" >
				</div>
			</div>
		</div>
	</center>
</body>
</html>



