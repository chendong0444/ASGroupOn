<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerBranchPage" %>

<%@ Import Namespace="AS.Common" %>

<script runat="server">
    
    protected string date = DateTime.Now.ToString("yyyy-MM-dd");
    protected string date2 = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");

    protected int id = 0;
    protected void Page_Load(object sender, EventArgs e)
    {
        string type = AS.Common.Utils.Helper.GetString(Request["type"], String.Empty);
        string key = AS.Common.Utils.FileUtils.GetKey();
        id = AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("pbranch", key), 0);
        if (type == "shouye" || type == "")
        {
            this.defaultpage.Attributes.Add("style", "display:block");
            this.defaultuser.Attributes.Add("style", "display:block");
        }
        
        if (type == "project")
        {
            this.project.Attributes.Add("style", "display:block");
        }
        else if (type == "orders")
        {
            this.orders.Attributes.Add("style", "display:block");
        }
       
       
        else if (type == "kuaidi")
        {
            this.KuaiDi.Attributes.Add("style", "display:block");
        }
     
        else if (type == "youhuiquan")
        {
            this.youhuiquan.Attributes.Add("style", "display:block");
        }
        else if (type == "fenzhan")
        {
            this.fenzhan.Attributes.Add("style", "display:block");
        }
    } 
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>商户分站管理后台头部</title>
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

<li name="type"><a href="PbranchInfo.aspx?id=<%=id %>" target="Right">商家分站信息</a></li>
<li name="type"><a href="ChangePWD.aspx?id=<%=id %>" target="Right">修改密码</a></li>



</ul></dd>
</dl>


</div>
<%--首页默认 --%>
<div id="defaultpage" runat="server" style=" display:none">
<dl class="acSide_Option" style="margin-top:0;">
<dt class="acSide_title">常用操作</dt>
<dd><ul>
<li name="type"><a href="project.aspx" target="Right">项目列表</a></li>
<li name="type"><a href="OrderList.aspx" target="Right">订单列表</a></li>
<li name="type"><a href="OrderList_WeiXuanZe.aspx" target="Right">订单打印</a></li>
<li name="type"><a href="coupon.aspx" target="Right">优惠券券列表</a></li>

</ul></dd>
</dl>


</div>


<%--项目 --%>
<div id="project" runat="server" style=" display:none">
<dl class="acSide_Option" style="margin-top:0;">
<dt class="acSide_title">项目管理</dt>
<dd><ul>
<li name="type" ><a href="project.aspx" target="Right" >项目列表</a></li>
</ul></dd>
</dl>
</div>


<%--订单 --%>
<div id="orders" runat="server" style=" display:none">
<dl class="acSide_Option" style="margin-top:0;">
<dt class="acSide_title">订单管理</dt>
<dd><ul>
<li name="type"><a href="OrderList.aspx" target="Right">付款订单</a></li>
</ul></dd>
</dl>
</div>
<div id="youhuiquan" runat="server" style=" display:none">
<dl class="acSide_Option">
<dt class="acSide_title">优惠券管理</dt>
<dd><ul>
<li name="type" ><a href="coupon.aspx" target="Right">优惠券列表</a></li>
</ul></dd>
</dl>
<dl class="acSide_Option">
<dt class="acSide_title">站外券管理</dt>
<dd><ul>
<li name="type" ><a href="pcoupon.aspx" target="Right">站外券列表</a></li>
</ul></dd>
</dl>

</div>

<%--快递物流 --%>
<div id="KuaiDi" runat="server" style=" display:none">
<dl class="acSide_Option" style="margin-top:0;">
<dt class="acSide_title">在线订单打印</dt>
<dd><ul>
<li name="type"><a href="orderList_WeiXuanZe.aspx" target="Right">未选择快递</a></li>
<li name="type"><a href="orderList_WeiDaYin.aspx" target="Right">未打印</a></li>
<li name="type"><a href="orderList.aspx?key=3" target="Right">未发货</a></li>
<li name="type"><a href="orderList.aspx?key=2" target="Right">已发货</a></li>
<li name="type"><a href="Importxls.aspx" target="Right">批量上传快递单</a></li>
</ul></dd>
</dl>

<dl class="acSide_Option">
<dt class="acSide_title">货到付款订单</dt>
<dd><ul>
<li name="type"><a href="orderList_CashOnDelivery.aspx" target="Right">未选择快递</a></li>
<li name="type"><a href="orderList_CashWeiDaYin.aspx" target="Right">未打印</a></li>
<li name="type"><a href="orderList_CashState.aspx?key=2" target="Right">未发货</a></li>
<li name="type"><a href="orderList_CashState.aspx?key=1" target="Right">已发货</a></li>
<li name="type"><a href="orderList_CashState.aspx?key=3" target="Right">已完成</a></li>
<li name="type"><a href="importxls.aspx" target="Right">批量上传快递单</a></li>
</ul></dd>
</dl>
</div>
<div id="fenzhan" runat="server" style=" display:none">
<dl class="acSide_Option">
<dt class="acSide_title">分站管理</dt>
<dd><ul>
<li name="type"><a href="subbranchupdate.aspx" target="Right">分站信息</a></li>
</ul></dd>
</dl>
</div>

</div></div></div></div>

</body>
</html>
