<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    
    protected NameValueCollection team = new NameValueCollection();
    protected AS.GroupOn.Domain.ITeam teamm = null;
    protected bool couponno = false;
    protected int buycount = 0;
    protected int paycount = 0;
    protected decimal onlinepay = 0;
    protected decimal creditpay = 0;
    protected decimal cardpay = 0;
    protected int mailcount = 0;//邮件订阅总数
    protected int smscount = 0;//短信订阅总数
    protected bool showsmscoupon = false;//是否显示短信发券
    protected bool showsmsautosmscoupon = false;//是否显示自动发券
    protected int backsendcount = 0;//补发优惠券数量
    protected int sendcount = 0;//优惠券已发送数量
    protected OrderFilter orderfilter = new OrderFilter();
    protected OrderDetailFilter orderdetailfilter = new OrderDetailFilter();

    protected IList<IOrderDetail> orderdetaillist = null;
    protected IList<IOrder> orderlist = null;

    protected int buycount1 = 0;
    protected int paycount1 = 0;
    protected decimal teamprice = 0; //项目收支

    protected AS.GroupOn.Domain.TeamState state = AS.GroupOn.Domain.TeamState.None; //项目状态
    protected bool showdingyue = false;//是否显示短信订阅与邮件订阅
    protected bool showbutton = false;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
       
        if (WebUtils.IsSupper || IsManage)
        {
            showbutton = true;
        }
        else
            showbutton = false;
            
        int teamid = AS.Common.Utils.Helper.GetInt(Request["id"], 0);
        TeamFilter teamb = new TeamFilter();

        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamm = session.Teams.GetByID(teamid);
        }
        team = AS.Common.Utils.Helper.GetObjectProtery(teamm);


        orderdetailfilter.TeamidOrder = teamm.Id;
        orderfilter.State = "pay";
        orderfilter.Team_id = teamm.Id;
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            orderdetaillist = session.OrderDetail.GetList(orderdetailfilter);
            orderlist = session.Orders.GetList(orderfilter);
        }
        foreach (var item in orderdetaillist)
        {
            buycount += item.Num;
            teamprice += item.Num * item.Teamprice;
            cardpay += item.Num * item.Credit;
        }
        foreach (var item in orderlist)
        {
            buycount += item.Quantity;
            teamprice += item.Quantity * item.Price;
            cardpay += item.Quantity * item.Card;
        }
        paycount = orderdetaillist.Count + orderlist.Count;

        if (teamm.Delivery == "coupon")
        {
            CouponFilter couponfilter = new CouponFilter();
            IList<ICoupon> couponlist = null;
            couponfilter.Team_id = teamm.Id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                couponlist = session.Coupon.GetList(couponfilter);
                sendcount = couponlist.Count;
            }
        }
        if (teamm.Delivery == "pcoupon")
        {
            PcouponFilter pcouponfilter = new PcouponFilter();
            IList<IPcoupon> pcouponlist = null;
            pcouponfilter.teamid = teamm.Id;
            pcouponfilter.state = "buy";

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pcouponlist = session.Pcoupon.GetList(pcouponfilter);
                sendcount = pcouponlist.Count;
            }
        }

        OrderFilter Orderfilter = new OrderFilter();
        IList<IOrder> Orderlist = null;
        Orderfilter.Team_id = teamm.Id;
        Orderfilter.State = "pay";

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            Orderlist = session.Orders.GetList(Orderfilter);
            foreach (IOrder item in Orderlist)
            {
                cardpay += item.Card;
            }
        }

        MailerFilter mailerfilter = new MailerFilter();
        SmssubscribeFilter smssfilter = new SmssubscribeFilter();
        IList<IMailer> mailerlist = null;
        IList<ISmssubscribe> smsslist = null;
        smssfilter.Enable = "Y";

        if (teamm.City_id != 0)
        {
            smssfilter.City_id = teamm.City_id;
            mailerfilter.City_id = teamm.City_id;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            mailerlist = session.Mailers.GetList(mailerfilter);
            smsslist = session.Smssubscribe.GetList(smssfilter);
        }
        mailcount = mailerlist.Count;
        smscount = smsslist.Count;

        state = GetState(teamm);

        if (teamm.Delivery == "coupon" || teamm.Delivery == "pcoupon")
        {
            if (state == TeamState.successbuy || state == TeamState.successnobuy || state == TeamState.successtimeover)
            {
                couponno = true;
                showsmscoupon = true;
                if (buycount > sendcount)
                {
                    showsmsautosmscoupon = true;
                    backsendcount = buycount - sendcount;
                }
            }
            else
            {
                couponno = false;
            }
        }
        if (state == TeamState.None || state == TeamState.Nowing || state == TeamState.successbuy)
        {
            showdingyue = true;
        }



    }
    protected string GetTeamStateName(TeamState state)
    {
        string val = String.Empty;
        switch (state)
        {
            case TeamState.None:
                val = "未开始";
                break;
            case TeamState.Nowing:
                val = "正在进行";
                break;
            case TeamState.fail:
                val = "失败";
                break;
            case TeamState.successbuy:
                val = "成功可继续";
                break;
            case TeamState.successnobuy:
                val = "成功已卖光";
                break;
            case TeamState.successtimeover:
                val = "成功已过期";
                break;

        }
        return val;
    }
    /// <summary>
    /// 得到当前项目状态
    /// </summary>
    /// <param name="t"></param>
    /// <returns></returns>
    protected TeamState GetState(ITeam t)
    {
        NameValueCollection _system = new NameValueCollection();


        if (t.Begin_time > DateTime.Now) //未开始
            return TeamState.None;
        //1未开始 2 4 8
        if (t.Begin_time > DateTime.Now) //未开始
            return TeamState.None;
        if (t.End_time < DateTime.Now)//结束时间小于当前时间，结束时间已过
        {
            //项目已结束，并且当前购买人数，并且已卖光状态
            if ((t.Now_number >= t.Max_number && t.Max_number != 0 && t.Now_number != 0) || (AS.Common.Utils.Helper.GetInt(t.open_invent, 0) == 1 && AS.Common.Utils.Helper.GetInt(t.inventory, 0) == 0) || t.status == 8)
            {
                return TeamState.successnobuy; //已结束不可以购买已卖光
            }
            else
            {
                if (t.Now_number < t.Min_number)//购买人数小于最小成团人数
                {
                    return TeamState.fail;  //失败项目： if(当前时间> 项目结束时间 && 最小成团人数>项目当前人数)
                }
                else
                {
                    return TeamState.successtimeover; //成功项目 if(当前时间> 项目结束时间 && 最小成团人数<=项目当前人数)
                }
            }

        }
        else if (DateTime.Now <= t.End_time)//当前时间小于等于项目结束时间
        {

            if ((t.Now_number >= t.Max_number && t.Max_number != 0 && t.Now_number != 0) || (AS.Common.Utils.Helper.GetInt(t.open_invent, 0) == 1 && AS.Common.Utils.Helper.GetInt(t.inventory, 0) == 0) || t.status == 8)
            {

                return TeamState.successnobuy; //已成功未过期不可以购买已卖光
            }
            else
            {
                if (t.Now_number < t.Min_number)
                {
                    if (t.Now_number >= t.Min_number)//当前人数 大于最小成团人数
                    {
                        return TeamState.successbuy;//已成功未过期可以购买   //成功项目:if(项目结束时间>=当前时间>= 项目开始时间 && 项目最大购买人数>0&& 最小成团人数<=项目当前人数)
                    }

                    else
                        return TeamState.Nowing;//正在进行   //正在进行项目:if(项目结束时间>=当前时间>= 项目开始时间 && 项目最大购买人数>0&& 最小成团人数>项目当前人数)
                }
                else
                {

                    if (t.Now_number < t.Min_number)
                    {
                        return TeamState.Nowing;//正在进行   //正在进行项目:if(项目结束时间>=当前时间>= 项目开始时间 && 项目最大购买人数=0&& 最小成团人数>项目当前人数)
                    }
                    else
                    {
                        if (t.Max_number == 0 && t.Now_number == 0)
                        {
                            return TeamState.Nowing;
                        }
                        else
                        {
                            return TeamState.successbuy;//已成功未过期可以购买      //成功项目:if(项目结束时间>=当前时间>= 项目开始时间 && 项目最大购买人数=0&& 最小成团人数<=项目当前人数)
                        }
                    }

                }
            }
        }

        return TeamState.None;  //未开始项目
    }
    private NameValueCollection _assytemarr = null;
    public NameValueCollection ASSystemArr
    {
        get
        {
            if (ASSystem != null) _assytemarr = AS.Common.Utils.Helper.GetObjectProtery(ASSystem);
            else _assytemarr = new NameValueCollection();
            return _assytemarr;
        }

    }
    /// <summary>
    /// 返回系统设置
    /// </summary>
    private ISystem _assystem = null;
    public ISystem ASSystem
    {
        get
        {
            if (_assystem == null)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    _assystem = session.System.GetByID(1);
                }
                //_assystem = new SystemFilter.GetModel(1);
            }
            return _assystem;
        }
        set
        {
            _assystem = value;
        }
    }


    private bool? _ismanager = null;
    /// <summary>
    /// 判断当前用户是否有管理权限
    /// </summary>
    public bool IsManage
    {
        get
        {
            if (_ismanager == null)
            {
                if (AsUser != null)
                {
                    if (AsUser.Manager.ToUpper() == "Y" || AsUser.Id == 1)
                    {
                        _ismanager = true;
                    }
                }
                if (_ismanager == null)
                    _ismanager = false;
            }

            return _ismanager.Value;
        }
    }
    
    
    
    private IUser _asuser = null;
    /// <summary>
    /// 返回当前登录的用户model
    /// </summary>
    public IUser AsUser
    {
        get
        {
            if (_asuser == null)
            {
                if (CookieUtils.GetCookieValue("userid", FileUtils.GetKey()).Length > 0)
                {
                    IList<IUser> users = null;
                    UserFilter usfiler = new UserFilter();
                    usfiler.ID=Helper.GetInt(CookieUtils.GetCookieValue("userid",FileUtils.GetKey()),0);
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        users = session.Users.GetList(usfiler);
                    }
                    if (users.Count > 0)
                        _asuser = users[0];
                }
            }
            return _asuser;
        }
    }
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:510px;">
	<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>项目详情</h3>
	
    <div style="overflow-x:hidden;padding:10px;">
    <tr><th colspan="2"><hr/></th></tr>
	<table width="96%" align="center" class="coupons-table-xq">
		<tr><td width="80"><b>项目名称：</b></td><td><b><%=team["title"] %></b></td></tr>
 <%if(int.Parse(team["teamcata"])==0){
       if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Team_Detail))
       {
           Response.Write("<script>alert(' 你没有查看团购项目详情的权限');</script>");
           Response.Redirect(WebRoot + "manage/index.aspx");
           Response.End();
           return;
       }
        %>

        <%if (teamm != null && teamm.Partner != null && teamm.Partner.Title != null && teamm.Partner.Title.Length > 0)
            { %>
                    <tr>
                <td>
                    <b>所属商户：</b>
                </td>
                <td>
                   <b><%=teamm.Partner.Title%></b>
                </td>
            </tr>
        <%} %>
            <tr>
                <td>
                    <b>项目时间：</b>
                </td>
                <td>
                    开始：<b><%=team["begin_time"] %></b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;截至：<b><%=team["end_time"] %></b>
                </td>
            </tr>
            <tr>
                <td>
                    <b>当前状态：</b>
                </td>
                <td>
                    <span style="color: #F00; font-weight: bold;">
                        <%=GetTeamStateName(GetState(teamm)) %></span><%if (teamm.Delivery == "coupon" && couponno)
                                                                                { %>&nbsp;&nbsp;<span style="color: #F8C; font-weight: bold;"><%if (showsmsautosmscoupon)
                                                                                                                                                { %>&lt;<%=ASSystemArr["couponname"]%>未发完&gt;<%}
                                                                                                                                                else
                                                                                                                                                { %>&lt;<%=ASSystemArr["couponname"]%>已发放&gt;</span><%} %><%} %>
                </td>
            </tr>
            <tr>
                <td>
                    <b>限购数量：</b>
                </td>
                <td>
                    成团最低数量：<%=team["min_number"]%>&nbsp;&nbsp;&nbsp;&nbsp;最高：<%=((teamm.Max_number == 0) ? "无上限" : team["max_number"])%>
                </td>
            </tr>
            <%}else if (int.Parse(team["teamcata"]) == 1)
              {
                  if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_MallTeam_DetailView))
                  {
                      Response.Write("<script>alert('你没有查看商城项目详情的权限')</script>");
                      Response.Redirect(WebRoot + "manage/index.aspx");
                      Response.End();
                      return;
                  }   %>
                <%if (teamm != null && teamm.Partner != null && teamm.Partner.Title != null && teamm.Partner.Title.Length>0)
            { %>
                    <tr>
                <td>
                    <b>所属商户：</b>
                </td>
                <td>
                   <b><%=teamm.Partner.Title%></b>
                </td>
            </tr>
        <%} %>
            <tr>
                <td>
                    <b>限购数量：</b>
                </td>
                <td>
                    最低购买数量：<%=team["Per_number"]%>
                </td>
            </tr>
            <%} %>
            <tr>
                <td>
                    <b>项目定价：</b>
                </td>
                <td>
                    市场价格：<b><%=team["market_price"]%></b>&nbsp;元&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;项目价格：<b><%=team["team_price"]%></b>&nbsp;元
                </td>
            </tr>            
            <tr><td></td>
                
                    <th colspan="2">
                        <hr />
                    </th>
                
            </tr>
            <tr>
                <td>
                    <b>成交情况：</b>
                </td>
                <td>
                    <b>
                        <%=team["now_number"]%></b>&nbsp;，实际共&nbsp;<b><%=paycount%></b>&nbsp;人购买了&nbsp;<b><%=buycount%></b>&nbsp;份
                </td>
            </tr>
            <tr>
                <td>
                    <b>项目收支：</b>
                </td>
                <td>
                    支付总额：<b><%=teamprice%></b>&nbsp;元&nbsp;&nbsp;&nbsp;&nbsp;代金券抵用：<b><%=cardpay%></b>&nbsp;元
                </td>
            </tr>
            <%if (showbutton)
              { %>
            <tr><td></td></tr>
		<tr>
                <td colspan="2">
                    <%if (showdingyue)
                      { %>
                    <button style="padding: 0;" id="dialog_subscribe_button_id" onclick="if(confirm('发送邮件过程中，请耐心等待，同意吗？')){this.disabled=true;return X.misc.noticenext(<%=team["id"] %>,0);}">
                        邮件订阅&nbsp;(<span id="dialog_subscribe_count_id">0</span>/<%=mailcount%>)</button>&nbsp;
                    <button style="padding: 0;" id="dialog_smssubscribe_button_id" onclick="if(confirm('发送短信过程中，请耐心等待，同意吗？')){this.disabled=true;return X.misc.noticenextsms(<%=team["id"] %>,0);}">
                        短信订阅&nbsp;(<span id="dialog_smssubscribe_count_id">0</span>/<%=smscount%>)</button>&nbsp;
                    <%} %>
                    <%if (showsmscoupon)
                      { %>
                    <button id="dialog_sms_button_id" onclick="if(confirm('此过程将为全部订购用户重新发送一遍，是否继续？')){this.disabled=true;return X.misc.noticesms(<%=team["id"] %>,0);}">
                        短信发券&nbsp;(<span id="dialog_sms_count_id">0</span>/<%=buycount%>)</button>&nbsp;
                    <%} %>
                    <%if (showsmsautosmscoupon)
                      { %>
                    <button onclick="this.disabled=true;return X.manage.teamcoupon(<%=team["id"] %>);">
                        自动发券&nbsp;(<%=sendcount%>/<%=buycount%>)</button>&nbsp;
                    <%} %>
                </td>
            </tr>
            <%} %>
        </table>
    </div>
</div>
