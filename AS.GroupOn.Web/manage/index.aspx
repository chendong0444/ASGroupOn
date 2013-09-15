<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>管理后台</title>
    <link href="css/index.css" rel="stylesheet" type="text/css" />
    <script src="../upfile/js/index.js" type="text/javascript"></script>
    <link rel="icon" href="<%=AS.GroupOn.Controls.PageValue.CurrentSystem.domain+AS.GroupOn.Controls.PageValue.WebRoot %>upfile/icon/favicon.ico"
        type="image/x-icon" />
</head>
<frameset framespacing="0" rows="60,*" frameborder="0" bordercolor="#000000">
<frame frameborder="0" noresize="noresize"  name="Header"  src="frametop.aspx">

<frameset framespacing="0" frameborder="0"  name="myframe" id="myframe"  cols="165,7,*">
<frame  frameborder="0"   noresize="noresize" name="Left" id="Left" src="frameleft.aspx" >
<frame  frameborder="0"  noresize="noresize" name="switchframe" id="switchframe" src="frameswitch.aspx" >
<frame  frameborder="0"  noresize="noresize"  name="Right" id="Right" src="index_index.aspx">
</frameset>
</frameset>
<noframes>
</noframes>
</html>
