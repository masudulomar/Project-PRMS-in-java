<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page session="true" %>
<%@ page import = "java.util.Date" %>
<%@ page import = "java.text.SimpleDateFormat" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link href='https://fonts.googleapis.com/css?family=Orbitron' rel='stylesheet' type='text/css'>

<%
  SimpleDateFormat sdf = new SimpleDateFormat("E, dd MMM yyyy HH:mm:ss z");
  String date = sdf.format(new Date());
%>

</head>
<style> 
body {
  background-color: #cccccc;
 /*  background-image: url('../Media/bg5.jpg') ;
  background-repeat: repeat;
  background-size: /* 300px 100px   auto ; */
}
table {
    border:none;
    border-collapse: collapse;
}

table td {
    border-left: 2px solid green;
    border-right: 2px solid green;
}

table td:first-child {
    border-left: none;
}

table td:last-child {
    border-right: none;
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
function startTime() {
	  var today = new Date();
	  var h = today.getHours();
	  var m = today.getMinutes();
	  var s = today.getSeconds();
	  m = checkTime(m);
	  s = checkTime(s);
	  document.getElementById('clock').innerHTML =
	  h + ":" + m + ":" + s;
	  var t = setTimeout(startTime, 500);
	}
	function checkTime(i) {
	  if (i < 10) {i = "0" + i};  // add zero in front of numbers < 10
	  return i;
	}

function LoggedData()
{
	startTime();
}
function LogOut()
{
	clear();
	SetValue("Class","LoginValidation");
	SetValue("Method","LogOut");
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			if (top.location!= self.location) {
		        top.location = self.location.href = "../";
		    }
		}
	};
	xhttp.open("POST", "HTTPValidator?" + DataMap, true);
	xhttp.send();
		
}

</script>
<body onload="LoggedData()" >

<table> 
	<tr>
		<!-- <td> <%=date%></td> -->
		<td colspan="2"><center>
	<p id="clock" style=" font-family: 'Orbitron', sans-serif; border-style: groove; 
	text-align:center; font-size: 1.5em; color:red; background-color: black; height:1.1em; width: 4.9em;"  ></p>
	</center></td>
	</tr>
	<tr> 
		<td align="left"><font size="2" style="font-family:courier;">USER ID</font></td>
		<td align="right"><font size="2" style="font-family:courier;"><%= session.getAttribute("User_Id")%></font></td>
	</tr> 
	
	<tr>
		<td colspan="2" align="center"><font size="2" style="font-family:courier;"><br><%= session.getAttribute("BRN_NAME")%><hr width="100%" style="border: 1px dashed green;"></font></td>
	</tr> 
	<tr>
		<td colspan="2" align="center"><font size="2" style="font-family:courier;"><br>LOGGED ON DATE AND TIME</font></td>
	</tr> 
	<tr>
		<td colspan="2" align="center"><font size="2" style="font-family:courier;"><%= session.getAttribute("LogOnDate")%> </font></td>
	</tr> 
	<tr>
		<td colspan="2" align="center"><br><button id="logout" onClick="LogOut()" style="font-family:courier; text-align:center; font-size : 18px; color:red" >Log Out</button></td>
	</tr>
</table>

</body>
</html>