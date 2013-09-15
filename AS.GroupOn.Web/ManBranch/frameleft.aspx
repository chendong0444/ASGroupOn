<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.Common" %>

<script runat="server">
    
    protected string date = DateTime.Now.ToString("yyyy-MM-dd");
    protected string date2 = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
    protected int id = 0;
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string type = AS.Common.Utils.Helper.GetString(Request["type"], String.Empty);
        string key = AS.Common.Utils.FileUtils.GetKey();
        id = AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0);
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
        else if (type == "youhui")
        {
            this.youhui.Attributes.Add("style", "display:block");
        }
        else if (type == "huiyuan")
        {
            this.HuiYuan.Attributes.Add("style", "display:block");
        }
       
    } 
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>管理员分站后台头部</title>
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

<li name="type"><a href="PersonalInfo.aspx?id=<%=id %>" target="Right">个人信息</a></li>
<li name="type"><a href="ChangePWD.aspx?id=<%=id %>" target="Right">修改密码</a></li>

</ul></dd>
</dl>


</div>

<%--登陆信息--%>
<%--首页默认 --%>
<div id="defaultpage" runat="server" style=" display:none">
<dl class="acSide_Option" style="margin-top:0;">
<dt class="acSide_title">常用操作</dt>
<dd><ul>
<li name="type"><a href="Project_DangqianXiangmu.aspx" target="Right">项目列表</a></li>
<li name="type"><a href="Dingdan_DangqiDingdan.aspx" target="Right">订单列表</a></li>
<li name="type"><a href="User.aspx" target="Right">会员列表</a></li>
<li name="type"><a href="Youhui_WeiDaijinquan.aspx" target="Right">代金券列表</a></li>
</ul></dd>
</dl>


</div>


<%--项目 --%>
<div id="project" runat="server" style=" display:none">
<dl class="acSide_Option" style="margin-top:0;">
<dt class="acSide_title">团购项目管理</dt>
<dd><ul>
<li name="type" ><a href="Project_DangqianXiangmu.aspx" target="Right" >当前项目</a></li>
<li name="type" ><a href="Project_XinjianXiangmu.aspx" target="Right" >新建项目</a></li>
<li name="type" ><a href="Project_WeiKaishixiangmu.aspx" target="Right" >未开始项目</a></li>
<li name="type" ><a href="Project_ChenggongXiangmu.aspx" target="Right">成功项目</a></li>
<li name="type" ><a href="Project_ShibaiXiangmu.aspx" target="Right">失败项目</a></li>
<li name="type" ><a href="Project_PointXiangmu.aspx" target="Right">积分项目</a></li>
</ul></dd>
</dl>
<dl class="acSide_Option">
<dt class="acSide_title">商城项目管理</dt>
<dd><ul>
<li name="type" ><a href="commoditylist.aspx" target="Right">项目列表</a></li>
<li name="type"><a href="Commodity_add.aspx" target="Right">新建项目</a></li>
</ul></dd>
</dl>
<dl class="acSide_Option">
<dt class="acSide_title">项目分类管理</dt>
<dd><ul>
<li name="type" ><a href="Type_catalogs.aspx" target="Right">团购分类列表</a></li>
<li name="type"><a href="Type_addcatalogs.aspx" target="Right">添加团购分类</a></li>
<li name="type" ><a href="mall_catalogs.aspx" target="Right">商城分类列表</a></li>
<li name="type"><a href="mall_addcatalogs.aspx" target="Right">添加商城分类</a></li>
</ul></dd>
</dl>

<dl class="acSide_Option">
<dt class="acSide_title">产品管理</dt>
<dd><ul>
<li name="type"><a href="ProductList.aspx" target="Right">产品列表</a></li>
<li name="type"><a href="ProductAdd.aspx" target="Right">添加新产品</a></li>
</ul></dd>
</dl>

<dl class="acSide_Option">
<dt class="acSide_title">城市管理</dt>
<dd><ul>
<li name="type"><a href="Type_Chengshi.aspx?zone=city" target="Right">城市分类列表</a></li>
<li name="type"><a href="Type_Area.aspx" target="Right">区域商圈列表</a></li>
<li name="type"><a href="Type_addarea.aspx?zone=area" target="Right">新建区域商圈</a></li>
</ul></dd>
</dl>

<dl class="acSide_Option">
<dt class="acSide_title">品牌管理</dt>
<dd><ul>
<li name="type"><a href="Type_PinPai.aspx?zone=brand" target="Right">品牌列表</a></li>
</ul></dd>
</dl>
</div>

<%--订单 --%>
<div id="orders" runat="server" style=" display:none">
<dl class="acSide_Option" style="margin-top:0;">
<dt class="acSide_title">订单管理</dt>
<dd><ul>
<li name="type"><a href="Dingdan_DangqiDingdan.aspx" target="Right">所有订单</a></li>
<li name="type"><a href="Dingdan_FukuanDingdan.aspx" target="Right">付款订单</a></li>
<li name="type" ><a href="Dingdan_WeiFuDingdan.aspx" target="Right">未付款订单</a></li>
<li name="type"><a href="Dingdan_QuxiaoDingdan.aspx" target="Right">取消订单</a></li>
<li name="type"><a href="DingDan_Shenghe.aspx" target="Right">审核订单</a></li>
<li name="type"><a href="Dingdan_TuikuanDingdan.aspx" target="Right">退款订单</a></li>
<li name="type" ><a href="Dingdan_Chulituikuan.aspx" target="Right">处理退款</a></li>
<li name="type"  ><a href="Dingdan_Chengongtuikuan.aspx" target="Right">成功退款</a></li>
<li name="type"><a href="Dingdan_Score.aspx" target="Right">积分订单</a></li>
</ul></dd>
</dl>
</div>
<%--代金券 --%>
<div id="youhui" runat="server" style=" display:none"> 
<dl class="acSide_Option" style=" margin-top:0;">
<dt class="acSide_title">站内券管理</dt>
<dd><ul>
<li name="type" ><a href="Youhui_Weixiaofei.aspx" target="Right">未消费优惠券</a></li>
<li name="type" ><a href="Youhui_YiXiaofei.aspx" target="Right">已消费优惠券</a></li>
<li name="type" ><a href="Youhui_YiGuoqi.aspx" target="Right">已过期优惠券</a></li>
</ul></dd>
</dl>
<dl class="acSide_Option">
<dt class="acSide_title">站外券管理</dt>
<dd><ul>
<li name="type" ><a href="Youhui_pcoupon.aspx" target="Right">站外券列表</a></li>
</ul></dd>
</dl>
<dl class="acSide_Option">
<dt class="acSide_title">代金券管理</dt>
<dd><ul>
<li name="type"><a href="Youhui_WeiDaijinquan.aspx" target="Right">代金券列表</a></li>
</ul></dd>
</dl>
</div>
<%--会员 --%>
<div id="HuiYuan" runat="server" style=" display:none"> 
<dl class="acSide_Option" style=" margin-top:0;">
<dt class="acSide_title">会员管理</dt>
<dd><ul>
<li name="type"><a href="User.aspx" target="Right">会员列表</a></li>
</ul></dd>
</dl>

<dl class="acSide_Option">
<dt class="acSide_title">邮件订阅</dt>
<dd><ul>
<li name="type" ><a href="Index-youjiandingyue.aspx" target="Right">邮件订阅列表</a></li>
<%--<li name="type" ><a href="CancelSubscribe.aspx" target="Right">邮件退订列表</a></li>--%>
</ul></dd>
</dl>

<dl class="acSide_Option">
<dt class="acSide_title">短信订阅</dt>
<dd><ul>
<li name="type" ><a href="Index_DuanxinDingyue.aspx" target="Right">短信订阅列表</a></li>
</ul></dd>
</dl>
</div>
</div></div></div></div>
</body>
</html>
