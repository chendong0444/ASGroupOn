<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.SalePage" %>

<%@ Import Namespace="AS.Common" %>

<script runat="server">
    
    protected string date = DateTime.Now.ToString("yyyy-MM-dd");
    protected string date2 = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
    protected int id = 0;
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string type = AS.Common.Utils.Helper.GetString(Request["type"], String.Empty);
        string key = AS.Common.Utils.FileUtils.GetKey();
        id = AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("sale", key), 0);
        if (type == "shouye" || type == "")
        {
            this.defaultpage.Attributes.Add("style", "display:block");
            this.defaultuser.Attributes.Add("style", "display:block");
        }
        
        if (type == "project")
        {
            this.project.Attributes.Add("style", "display:block");
        }
       
        else if (type == "shanghu")
        {
            this.shanghu.Attributes.Add("style", "display:block");
        }
        else if (type == "tongji")
        {
            this.TongJi.Attributes.Add("style", "display:block");
        }
        else if (type == "ziliao")
        {
            this.ziliao.Attributes.Add("style", "display:block");
        }
        else if (type == "shouye")
        {

        }
    } 
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>商户管理后台头部</title>
<link href="css/index.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" language="javascript">
    window.onload = function () {
        var dashboard = document.getElementById('dashboard'), aLi = dashboard.getElementsByTagName('li'), i = 0;
        for (i = 0; i < aLi.length; i++) {
            aLi[i].index = i;
            aLi[i].onclick = function () {
                for (i = 0; i < aLi.length; i++) {
                    aLi[i].className = '';
                }
                this.className = 'current'
            }
        }

    }

</script>


</head>

<body style="background:#F1F1F1;">
<div class="bdw" id="bdw">
<div class="cf mainwide1" id="bd">
<div id="help">

<div id="dashboard" class="dashboard">
<%--登陆信息--%>
<div id="defaultuser" runat="server" style="display:none">
<dl class="acSide_Option" style="margin-top:0;">
<dt class="acSide_title">登录用户</dt>
<dd><ul>

<li name="type"><a href="SaleInfo.aspx?id=<%=id %>" target="Right">销售个人信息</a></li>
<li name="type"><a href="ChangePWD.aspx?id=<%=id %>" target="Right">修改密码</a></li>



</ul></dd>
</dl>


</div>
<%--首页默认 --%>
<div id="defaultpage" runat="server" style=" display:none">
<dl class="acSide_Option" style="margin-top:0;">
<dt class="acSide_title">常用操作</dt>
<dd><ul>
<li name="type"><a href="TeamNow.aspx" target="Right">项目列表</a></li>
<li name="type"><a href="PartnetList.aspx" target="Right">商户列表</a></li>
<li name="type"><a href="Team_TongJi.aspx" target="Right">统计</a></li>
<li name="type"><a href="PersonalData.aspx" target="Right">销售资料</a></li>
</ul></dd>
</dl>
</div>

<%--项目 --%>
<div id="project" runat="server" style=" display:none">
<dl class="acSide_Option" style="margin-top:0;">
<dt class="acSide_title">团购项目管理</dt>
<dd><ul>
<li name="type" ><a href="TeamNow.aspx" target="Right" >当前项目</a></li>
<li name="type" ><a href="TeamNotBegin.aspx" target="Right" >未开始项目</a></li>
<li name="type" ><a href="TeamScuess.aspx" target="Right" >成功项目</a></li>
<li name="type" ><a href="TeamFail.aspx" target="Right" >失败项目</a></li>
</ul></dd>
</dl>
<dl class="acSide_Option" style="margin-top:0;">
<dt class="acSide_title">商城项目管理</dt>
<dd><ul>
<li name="type" ><a href="CommodityList.aspx" target="Right" >当前项目</a></li>
</ul></dd>
</dl>
</div>
<%-- 我的商户--%>
<div id="shanghu" runat="server" style=" display:none">
<dl class="acSide_Option">
<dt class="acSide_title">我的商户</dt>
<dd>
<ul>
<li name="type"><a href="PartnetList.aspx" target="Right">商户列表</a></li>
<li name="type" ><a href="PartnetAdd.aspx" target="Right" >新建商户</a></li>
</ul>
</dd>
</dl>
</div>

<%--统计报表--%>
<div id="TongJi" runat="server" style=" display:none">
<dl class="acSide_Option">
<dt class="acSide_title">统计</dt>
<dd><ul>
<li name="type"><a href="Team_TongJi.aspx" target="Right">项目统计</a></li>
</ul></dd>
</dl>
</div>
<%--个人资料--%>
<div id="ziliao" runat="server" style=" display:none">
<dl class="acSide_Option">
<dt class="acSide_title">个人资料</dt>
<dd><ul>
<li name="type"><a href="PersonalData.aspx" target="Right">销售人员资料</a></li>
</ul></dd>
</dl>
</div>

</div></div></div></div>

</body>
</html>
