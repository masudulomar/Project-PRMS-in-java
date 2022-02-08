<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>User Home</title>

<style>
.topnav {
	overflow: hidden;
	background-color: #00b33c;
	overflow: auto;
	align: center;
	width: 59.4%;
}

.topnav a {
	float: left;
	color: #f2f2f2;
	text-align: center;
	padding: 14px 16px;
	text-decoration: none;
	font-size: 17px;
	width: 21%;
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
</head>
<body>
	<center>
		<!-- <div style="height: 25%"></div>
		<div class="topnav" style="height: 50%">
			<img src="../../Media/bhbfc_home.jpg" alt="" width="800" height="100">
		</div>
		<div style="height: 25%"></div> -->

		<div class="topnav" style="align: center">
			<a class="active" href="User.jsp"><i class="fa fa-fw fa-home" style="font-size: 24px"></i> Home</a> 
			<a href="#DownloadReport" target="contents_1"><i class="fa fa-download" style="font-size: 24px"></i> Download Report</a>
			<a href="#ResetPassword" target="contents_1"><i class="fa fa-cog fa-spin" style="font-size: 24px"></i> Reset Password</a>				
			<a href="Help.jsp" target="contents_1"><i class="fa fa-user-circle" style="font-size: 24px"></i> Help</a>
		</div>
		<div>
			<iframe height="200%" width="59.5%" src="../Welcome.jsp" name="contents_1"></iframe>
		</div>
	</center>
</body>
</html>