﻿<%@ Control Language="C#" AutoEventWireup="true"  Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta name="keywords" content="<%=PageValue.KeyWord %>"/>
<meta name="description" content="<%=PageValue.CurrentSystemConfig["malldescription"] %>" />
<script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/mall.js"></script>
<link rel="stylesheet" href="<%=PageValue.MallCssPath %>/css/mall.css" type="text/css" media="screen" charset="utf-8" />
<link rel="icon" href="<%=PageValue.WebRoot %>upfile/icon/favicon.ico" mce_href="<%=PageValue.WebRoot %>upfile/icon/favicon.ico" type="image/x-icon">
<script type="text/javascript" src="<%=PageValue.WebRoot %>upfile/js/jquery-1.4.2.min.js"></script>
<script type="text/javascript" src="<%=PageValue.WebRoot %>upfile/js/srolltop.js"></script>
<%if (IsTotw)
  {%>
<script>totw = true;</script>
<script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/zhtotw.js"></script>
<%}
  else
  {%>
<script>totw = false;</script>
<%} %>
<script type="text/javascript">
    $(document).ready(function () {
        if (totw) { StranBody(null); }
    });
</script>
<script type='text/javascript'>webroot = '<%=PageValue.WebRoot %>'; LOGINUID = '<%=AsUser.Id %>';</script>
<title><%=PageValue.CurrentSystemConfig["malltitle"]%></title>
</head>
<body class="newbie">
<div id="pagemasker"></div>
<div id="dialog"></div>
<div id="doc">