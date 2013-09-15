<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title><%=PageValue.Title%></title>
    <meta name="keywords" content="<%=PageValue.KeyWord %>" />
    <meta name="description" content="<%=PageValue.Description %>" />
    <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="format-detection" content="address=no" />
    <link rel="apple-touch-icon-precomposed" sizes="57x57" href="<%=PageValue.CurrentSystem.domain+WebRoot+ PageValue.CurrentSystem.iphone_icon %>" />
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="<%=PageValue.CurrentSystem.domain+WebRoot+PageValue.CurrentSystem.iphone_retina_icon %>" />
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="<%=PageValue.CurrentSystem.domain+WebRoot+PageValue.CurrentSystem.ipad_icon %>" />
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="<%=PageValue.CurrentSystem.domain+WebRoot+PageValue.CurrentSystem.ipad_retina_icon %>" />
    <link rel="apple-touch-startup-image" size="640x920" href="<%=PageValue.CurrentSystem.domain+WebRoot+PageValue.CurrentSystem.iphone4_startup %>"
        media="(device-height:480px)">
    <link rel="apple-touch-startup-image" href="<%=PageValue.CurrentSystem.domain+WebRoot+PageValue.CurrentSystem.iphone5_startup %>"
        media="(device-height:568px)">
    <link rel="icon" href="<%=PageValue.CurrentSystem.domain+PageValue.WebRoot %>upfile/icon/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" href="<%=PageValue.CurrentSystem.domain+PageValue.WebRoot %>upfile/icon/favicon.ico" type="image/x-icon" />
    <script>
        var MT = window.MT || {};
    </script>
    <link rel="stylesheet" href="<%=PageValue.CurrentSystem.domain+PageValue.MobileCssPath %>/css/index.css" type="text/css" />
</head>
