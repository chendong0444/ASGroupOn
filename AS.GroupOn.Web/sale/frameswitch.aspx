<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.SalePage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>商户管理后台</title>
<link rel="stylesheet" href="css/index.css" type="text/css" media="screen" charset="utf-8"  />
  <script language="JavaScript">
      function Submit_onclick() {
          var myframe = parent.document.getElementById("myframe");
          if (myframe.cols == "165,7,*") {
              myframe.cols = "0,7,*";
              document.getElementById("ImgArrow").src = "css/i/switch_right.gif";
              document.getElementById("ImgArrow").alt = "收起";
          } else {
              myframe.cols = "165,7,*";
              document.getElementById("ImgArrow").src = "css/i/switch_left.gif";
              document.getElementById("ImgArrow").alt = "展开";
          }
      }

      function MyLoad() {
          if (window.parent.location.href.indexOf("MainUrl") > 0) {
              window.top.midFrame.document.getElementById("ImgArrow").src = "css/i/switch_right.gif";
          }
      }
</script>



<style>
*{margin:0;padding:0}
#switchpic{clear: both;cursor: pointer;margin-top: 220px;vertical-align: bottom;width: 6px;}
img{ border:none}
</style>
</head>

<body  onload="MyLoad()">

<div id="switchpic"><a href="javascript:Submit_onclick()"><img src="css/i/switch_left.gif" alt="展开" id="ImgArrow"/></a></div>



</body>
</html>
