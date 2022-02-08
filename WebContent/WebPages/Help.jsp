<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<style>
body {
  background-color: #cccccc; 
  /* background-image: url('../Media/bg6.jpg') ;
  background-repeat: repeat;
  background-size: /* 300px 100px   auto ; */
}

/* latin */
@font-face {
	font-family: 'Satisfy';
	font-style: normal;
	font-weight: 400;
	src: local('Satisfy Regular'), local('Satisfy-Regular'),
		url(https://fonts.gstatic.com/s/satisfy/v9/rP2Hp2yn6lkG50LoCZOIHQ.woff2)
		format('woff2');
	unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6,
		U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2122, U+2191, U+2193,
		U+2212, U+2215, U+FEFF, U+FFFD;
}

.quote-container {
	margin-top: 50px;
	position: relative;
}

.note {
	color: #333;
	position: relative;
	width: 450px;
	margin: 0 auto;
	padding: 20px;
	font-family: Satisfy;
	font-size: 30px;
	box-shadow: 0 10px 10px 2px rgba(0, 0, 0, 0.3);
}

.note .author {
	display: block;
	margin: 40px 0 0 0;
	text-align: right;
}

.yellow {
	background: #eae672;
	-webkit-transform: rotate(2deg);
	-moz-transform: rotate(2deg);
	-o-transform: rotate(2deg);
	-ms-transform: rotate(2deg);
	transform: rotate(2deg);
}

.pin {
	background-color: #aaa;
	display: block;
	height: 32px;
	width: 2px;
	position: absolute;
	left: 50%;
	top: -16px;
	z-index: 1;
}

.pin:after {
	background-color: #A31;
	background-image: radial-gradient(25% 25%, circle, hsla(0, 0%, 100%, .3),
		hsla(0, 0%, 0%, .3));
	border-radius: 50%;
	box-shadow: inset 0 0 0 1px hsla(0, 0%, 0%, .1), inset 3px 3px 3px
		hsla(0, 0%, 100%, .2), inset -3px -3px 3px hsla(0, 0%, 0%, .2), 23px
		20px 3px hsla(0, 0%, 0%, .15);
	content: '';
	height: 12px;
	left: -5px;
	position: absolute;
	top: -10px;
	width: 12px;
}

.pin:before {
	background-color: hsla(0, 0%, 0%, 0.1);
	box-shadow: 0 0 .25em hsla(0, 0%, 0%, .1);
	content: '';
	height: 24px;
	width: 2px;
	left: 0;
	position: absolute;
	top: 8px;
	transform: rotate(57.5deg);
	-moz-transform: rotate(57.5deg);
	-webkit-transform: rotate(57.5deg);
	-o-transform: rotate(57.5deg);
	-ms-transform: rotate(57.5deg);
	transform-origin: 50% 100%;
	-moz-transform-origin: 50% 100%;
	-webkit-transform-origin: 50% 100%;
	-ms-transform-origin: 50% 100%;
	-o-transform-origin: 50% 100%;
}
</style>
</head>
<body>
	<div class="quote-container">
		<i class="pin"></i>
		<blockquote class="note yellow">
			Contact to the following Numbers:
			<ul class="a">
				<li> Office Mobile : 01550051143</li>
			    <li> Office Phone  : 0247120608</li>
			</ul>
			<cite class="author"></cite>
		</blockquote>
	</div>
</body>
</html>