<%@ Control Language="C#" AutoEventWireup="true"  Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<script runat="server">
    public string errtext = String.Empty;
    public string suctext = String.Empty;
    public int type = 2;
    public override void UpdateView()
    {
        base.UpdateView();
        ShowMessage();
    }
    public void ShowMessage()
    {
        if (PageValue.GetMessage() != null)
        {
            ShowMessageResult show = PageValue.GetMessage();
            if (show != null)
            {
                if (show.Result)
                {
                    type = 2;
                    suctext = show.Message;
                }
                else
                {
                    type = 1;
                    errtext = show.Message;
                }
            }
            Session.Remove("SuccessMessage");
        }
        if (Session["err"] != null)
        {
            type = AS.Common.Utils.Helper.GetInt(Session["type"], 2);
            if (type == 1) errtext = Session["err"].ToString();
            if (type == 2) suctext = Session["err"].ToString();
            Session.Remove("err");
            Session.Remove("type");
        }
    }
    </script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta name="keywords" content="<%=PageValue.KeyWord %>" />
<meta name="description" content="<%=PageValue.Description %>" />
<script type='text/javascript' src='/upfile/js/index.js'></script>
<script type="text/javascript">    var webroot = "/";</script>
<script type="text/javascript" src='/upfile/js/datePicker/WdatePicker.js' ></script>
<script src="<%=PageValue.WebRoot %>upfile/js/xheditor/xheditor-zh-cn.min.js" type="text/javascript"></script>
<link rel="stylesheet" href="css/index.css" type="text/css" media="screen" charset="utf-8" />
<title>后台管理</title>
</head>
<%if(errtext!=String.Empty&&type==1){ %>
<div class="sysmsgw" id="sysmsg-error"><div class="sysmsg"><p><%=errtext %></p><span class="close">关闭</span></div></div> 
<%} %>
<%if (suctext != String.Empty && type == 2)
  { %>
<div class="sysmsgw" id="sysmsg-success"><div class="sysmsg"><p><%=suctext%></p><span class="close">关闭</span></div></div> 
<%}%>