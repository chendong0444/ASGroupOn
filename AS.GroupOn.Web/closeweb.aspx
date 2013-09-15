<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    string title = String.Empty;
    string headlogo = String.Empty;
    string abbreviation = String.Empty;
    NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        _system = AS.GroupOn.Controls.PageValue.CurrentSystemConfig;
        //网站关闭开关
        if (_system["isCloseSite"] != null && _system["isCloseSite"].ToString() != String.Empty && _system["isCloseSite"] == "0")
        {
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
        }
        if (AS.GroupOn.Controls.PageValue.CurrentSystem != null)
        {
            title = AS.GroupOn.Controls.PageValue.CurrentSystem.sitetitle;
            headlogo = AS.GroupOn.Controls.PageValue.CurrentSystem.headlogo;
            abbreviation = AS.GroupOn.Controls.PageValue.CurrentSystem.abbreviation;
        }
    }
    
</script>
<style type="text/css">
    *
    {
        margin: 0;
        padding: 0;
    }

    a img
    {
        border: 0;
    }

    .wba_con
    {
        width: 500px;
        margin: 200px auto;
        font-size: 18px;
        color: #f00;
    }

    .error img
    {
        float: left;
        margin-right: 10px;
    }
</style>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>
        <%=title %></title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="wba_con">
            <div class="logo">
                <a href="<%=WebRoot%>index.aspx" class="link" target="_blank">
                    <img src="<%=headlogo %>" width="264" height="58" /></a>
            </div>
            <div class="error">
                <img width="40" height="40" src="/upfile/css/i/error.png" /><span>您好，网站正在维护中....</span>
            </div>
            <div>
            </div>
        </div>
    </form>
</body>
</html>
