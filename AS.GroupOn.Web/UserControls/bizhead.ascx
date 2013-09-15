<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>
<%--<link href="../../upfile/css/index.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../../upfile/js/index.js"></script>
<script src="../../upfile/js/datePicker/WdatePicker.js" type="text/javascript"></script>--%>
<script runat="server">
    private string _Select;
    public string PartnerSelect
    {
        get { return _Select; }
        set { _Select = value; }
    }
    public string headlogo = "";
    protected string menuhtml = String.Empty;
    protected string couponname = String.Empty;//优惠券名称
    protected NameValueCollection partner = new NameValueCollection();
    public NameValueCollection _system = new NameValueCollection();
    //public WebUtils sysmodel = new WebUtils();
    protected int viewcount = 0;//需要商家同意退款的数量

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        int pid = 0;
        pid = Helper.GetInt(CookieUtils.GetCookieValue("partner"), 0);
        RefundsFilter filter = new RefundsFilter();
        filter.PartnerId = pid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            viewcount = session.Refunds.SelectByPartid(filter);
        }
       
       
        string url = Request.Url.AbsoluteUri;
        if (url.IndexOf("partner_index.aspx") < 0) menuhtml = menuhtml + "<li><a href=\"" + PageValue.WebRoot + "partner_index.aspx\">首页</a></li>";
        else menuhtml = menuhtml + "<li class=\"current\"><a href=\"" + PageValue.WebRoot + "partner_index.aspx\">首页</a></li>";

        if (url.IndexOf("/manage/Partner_settings.aspx") < 0) menuhtml = menuhtml + "<li><a href=\"" + PageValue.WebRoot + "manage/Partner_settings.aspx\">商户资料</a></li>";
        else menuhtml = menuhtml + "<li class=\"current\"><a href=\"" + PageValue.WebRoot + "manage/Partner_settings.aspx\">商户资料</a></li>";

        if (url.IndexOf("/manage/Partner_coupon.aspx") < 0) menuhtml = menuhtml + "<li><a href=\"" + PageValue.WebRoot + "manage/Partner_coupon.aspx\">优惠券列表</a></li>";
        else menuhtml = menuhtml + "<li class=\"current\"><a href=\"" + PageValue.WebRoot + "manage/Partner_coupon.aspx\">优惠券利表</a></li>";
        IPartner partnermodel = Store.CreatePartner();
        ISystem system = Store.CreateSystem();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            partnermodel = session.Partners.GetByID(pid);
            system = session.System.GetByID(1);
        }
        partner = Helper.GetObjectProtery(partnermodel);
        if (system != null)
        {
            couponname = system.couponname;
        }
        headlogo = system.headlogo;
        #region  ####### 标题选项卡选中状态控制
        if (_Select == "partner_index")
        {
            this.partner_index.Attributes.Add("class", "dangqian");
        }
        else if (_Select == "partner_setting")
        {
            this.partner_setting.Attributes.Add("class", "dangqian");
        }
        else if (_Select == "partner_coupon")
        {
            this.partner_coupon.Attributes.Add("class", "dangqian");
        }
        else if (_Select == "partner_pcoupon")
        {
            this.partner_pcoupon.Attributes.Add("class", "dangqian");
        }
        else if (_Select == "partner_pmoney")
        {
            this.partner_pmoney.Attributes.Add("class", "dangqian");
        }
        else if (_Select == "partner_product")
        {
            this.partner_product.Attributes.Add("class", "dangqian");
        }
        else if (_Select == "partner_order")
        {
            this.partner_order.Attributes.Add("class", "dangqian");
        }
        else if (_Select == "partner_review")
        {
            this.partner_review.Attributes.Add("class", "dangqian");
        }
        else if (_Select == "partner_Tongji")
        {
            this.partner_Tongji_Week_biz.Attributes.Add("class", "dangqian");
        }
        else if (_Select == "partner_Commoditylist")
        {
            this.partner_Commoditylist.Attributes.Add("class", "dangqian");
        }
        else if (_Select == "partner_Branchlist")
        {
            this.partner_Branchlist.Attributes.Add("class", "dangqian");
        }
        #endregion
    }

</script>


<div id="hdw">

	<div id="hd">
    
		<div id="logo"><a href="<%=PageValue.WebRoot%>index.aspx" class="link" target="_blank"><img height="58" src="<%=headlogo %>" /></a></div>
		<div class="guides">
			<div class="city" style="width:80px;">
				<h2>商户后台</h2>
			</div>
		</div>
        <div id="menu2" class="menu wd_menu">
		<ul><li runat="server" id="partner_index"><a href="<%=PageValue.WebRoot%>partner_index.aspx">团购项目</a></li>
        <li runat="server" id="partner_Commoditylist"><a href="<%=PageValue.WebRoot%>manage/Partner_Commoditylist.aspx">商城项目</a></li>
        <li runat="server" id="partner_product"><a href="<%=PageValue.WebRoot%>manage/Partner_ProductList.aspx">我的产品</a></li>
       <li runat="server" id="partner_coupon"><a href="<%=PageValue.WebRoot%>manage/Partner_coupon.aspx">我的优惠券</a></li>
        <li runat="server" id="partner_pcoupon"><a href="<%=PageValue.WebRoot%>manage/Partner_pcoupon.aspx">我的站外券</a></li>
        <li runat="server" id="partner_order"><a href="<%=PageValue.WebRoot%>manage/Partner_OrderList.aspx">我的订单</a></li>
         <li runat="server" id="partner_pmoney"><a href="<%=PageValue.WebRoot%>manage/Partner_SHJieSuan.aspx">商户结算</a></li>
          <li runat="server" id="partner_setting"><a href="<%=PageValue.WebRoot%>manage/Partner_settings.aspx">商户资料</a></li>
          <li runat="server" id="partner_review"><a href="<%=PageValue.WebRoot%>manage/Partner_Review.aspx">商户评论</a></li>
          <li runat="server" id="partner_Tongji_Week_biz"><a href="<%=PageValue.WebRoot%>manage/Partner_Tongji_Week_biz.aspx">本周统计</a></li>
          <li runat="server" id="partner_Branchlist"><a href="<%=PageValue.WebRoot%>manage/Partner_BranchList.aspx">分站信息</a></li>
        </ul>
		</div>
        <%if(partner["id"] !=null && partner["id"]!=String.Empty){%>
		<div class="logins">
        <div class="links-v"><div class="vcoupon">&raquo;<a id="biz-verify-coupon-id" href="javascript:;" ><%=couponname%>验证及消费</a><em>|</em>退款审核<a class="ajaxlink"  href="<%=PageValue.WebRoot%>ajax/partner.aspx?action=refundview"><font color="red">(<%=viewcount%>)</font></a><em>|</em></div></div>
			 <ul class="links">
				<li class="username">欢迎您，<%=partner["title"]%>！</li>
				<li class="logout"><a href="<%=PageValue.WebRoot%>biz/logout.aspx">退出</a></li>
			</ul>
			<div class="line islogin"></div>
        </div>
		<%} %>
	</div>
</div>

<%if(suctext!=String.Empty){ %>
<div class="sysmsgw" id="sysmsg-success"><div class="sysmsg"><p><%=suctext %></p><span class="close">关闭</span></div></div> 
<%} %>
<%if(errtext!=String.Empty){ %>
<div class="sysmsgw" id="sysmsg-error"><div class="sysmsg"><p><%=errtext %></p><span class="close">关闭</span></div></div> 
<%} %>
