<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    protected IPagers<IInvite> pager = null;
    protected IList<IInvite> iListInvite = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected InviteFilter filter = new InviteFilter();
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Invite_ListView))
        {
            SetError("你不具有查看邀请返利列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (Request["confir"] != null)//执行已返利动作
        {
            GetFanli(Convert.ToInt32(Request["confir"]));
        }
        if (Request["del"] != null)//执行违规动作
        {
            NoRule(Convert.ToInt32(Request["del"]));
        }
        if (Request["saiXuan"] == "筛选")
        {
            SelectWhere();
        }
        if (Request.QueryString["item"] != null && Request.QueryString["item"] != "")
        {
            BulkConfirm();//批量确认
        }
        fanLi();
    }
    
    /// <summary>
    /// 批量确认
    /// </summary>
    protected void BulkConfirm()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Invite_Handle))
        {
            SetError("你不具有确认邀请返利的权限！");
            Response.Redirect("Index-YaoqingFanli.aspx");
            Response.End();
            return;

        }
        else
        {
            string items = Request.QueryString["item"];
            string[] item = items.Split(';');
            foreach (string ids in item)
            {
                //SetSuccess("友情提示：返利成功，返利金额：" + ids + "元");
                int id = Convert.ToInt32(ids);
                IInvite iinvite = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iinvite = session.Invite.GetByID(id);
                }
                // 第一步 查询此用户是否下过订单，如果下过成功订单，那么可以返利，否则无法进行返利
                IOrder iorder = null;
                OrderFilter orderfilter = new OrderFilter();
                orderfilter.User_id = iinvite.Other_user_id;
                orderfilter.State = "Pay";
                orderfilter.AddSortOrder(OrderFilter.Create_time_ASC);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iorder = session.Orders.Get(orderfilter);
                }
                if (iorder != null)
                {
                    if (iinvite.Team != null)
                    {
                        if (iinvite.Team.Bonus > 0) //项目表是否优惠券返利是否>0,
                        {
                            decimal dec1 = iinvite.User.Money;
                            decimal dec2 = iinvite.Team.Bonus;
                            int sUserId = iinvite.User_id;
                            //修改主动用户的账户余额
                            //int i = 0;
                            IUser iuser = AS.GroupOn.App.Store.CreateUser();
                            iuser = iinvite.User;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                iuser.Money = dec1 + dec2;
                                iuser.Id = sUserId;
                                session.Users.UpdateUser(iuser);
                            }
                            //把项目表中的返利金额修改到邀请表中
                            iinvite.Admin_id = PageValue.CurrentAdmin.Id;
                            iinvite.Credit = iinvite.Team.Bonus;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                session.Invite.Update(iinvite);
                            }
                            //新增用户消费记录
                            IFlow iflow = AS.GroupOn.App.Store.CreateFlow();
                            iflow.User_id = iinvite.User_id;
                            iflow.Detail_id = iorder.Pay_id;
                            iflow.Direction = "income";
                            iflow.Money = iinvite.Credit;
                            iflow.Action = "invite";
                            iflow.Create_time = DateTime.Now;
                            iflow.Admin_id = 0;
                            iflow.Detail = String.Empty;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                session.Flow.Insert(iflow);
                            }

                            fanLi();
                            SetSuccess("友情提示：返利成功，返利金额：" + iinvite.Team.Bonus + "元");

                        }
                        else
                        {
                            SetError("对不起，被邀请人购买的项目没有邀请返利");
                        }
                    }
                    else
                    {
                        SetError("对不起，此项目不存在");
                    }
                }
                else
                {
                    SetError("对不起，此订单已退款");
                }
            }
            Response.Redirect(PageValue.WebRoot + "manage/index-YaoqingFanli.aspx");
        }
    }
    /// <summary>
    /// 邀请返利
    /// </summary>
    private void fanLi()
    {
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<th width='5%'><input type='checkbox' id='checkall' name='checkall' /> 全选</th>");
        sb1.Append("<th width='45%'>项目</th>");
        sb1.Append("<th width='15%'>主动用户</th>");
        sb1.Append("<th width='15%'>被邀用户</th>");
        sb1.Append("<th width='12%'>邀买时间</th>");
        sb1.Append("<th width='8%'>操作</th>");
        sb1.Append("</tr>");

        /*---------------获取邀请返利---------begin-----------------------------------------*/
        url = url + "&page={0}";
        url = "Index-YaoqingFanli.aspx?" + url.Substring(1);
        filter.Pay = "Y";//邀请记录
        filter.Credit = 0;
        filter.PageSize = 30;
        filter.AddSortOrder(InviteFilter.Buy_time_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Invite.GetPager(filter);
        }
        iListInvite = pager.Objects;
        /*---------------获取邀请返利--------end------------------------------------------*/
        
        int i = 0;
        StringBuilder sb2 = new StringBuilder();
        foreach (IInvite inviteInfo in iListInvite)
        {
            if (i % 2 != 0)
            {
                sb2.Append("<tr>");
            }
            else
            {
                sb2.Append("<tr class='alt'>");
            }
            sb2.Append("<td><input type='checkbox' id='check' name='check' value=" + inviteInfo.Id + " /></td>");
            i++;
            //项目
            if (inviteInfo.Team != null)
            {
                sb2.Append("<td><a class='deal-title' href='" + getTeamPageUrl(inviteInfo.Team.Id) + "' target='_blank'><b>项目ID:" + inviteInfo.Team.Id + "</b>  " + inviteInfo.Team.Title + "</td>");
            }
            else
            {
                sb2.Append("<td>");
                int num = 0;
                foreach (IOrderDetail orderdetailInfo in inviteInfo.OrderDetails)
                {
                    num++;
                    sb2.Append("(<a class='deal-title' href='" + getTeamPageUrl(orderdetailInfo.Teamid) + "' target='_blank'>" + num + ":");
                    sb2.Append(orderdetailInfo.Team == null ? "" : orderdetailInfo.Team.Title + "<font style='color:red'>(" + orderdetailInfo.Num + "件)</font>");
                    sb2.Append("</a>)<br>");
                }
                sb2.Append("</td>");
            }
            //主动用户
            if (inviteInfo.Users != null && inviteInfo.Users.Count>0)
            {
                foreach (IUser userInfo in inviteInfo.Users)
                {
                    sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 150px;'>");
                    sb2.Append("<font style='color:red'>" + userInfo.Email + "</font><br>");
                    sb2.Append("<a class='ajaxlink' href='ajax_manage.aspx?action=userview&Id=" + userInfo.Id + "'>" + userInfo.Username + "</a><br>");
                    sb2.Append(userInfo.IP + "<br>");
                    sb2.Append("<font style='color:red'>" + userInfo.Mobile + "</font>");
                    sb2.Append("</div></td>");
                }
            }
            else
            {
                sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 150px;'>&nbsp;</div></td>");
            }
            //被邀用户|邀买时间|操作
            if (inviteInfo.Other_user_id != 0 && inviteInfo.OtherUser != null)
            {
                sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 150px;'>");
                sb2.Append("<font style='color:red'>" + inviteInfo.OtherUser.Email + "</font><br>");
                sb2.Append("<a class='ajaxlink' href='ajax_manage.aspx?action=userview&Id=" + inviteInfo.OtherUser.Id + "'>" + inviteInfo.OtherUser.Username + "</a><br>");
                sb2.Append(inviteInfo.OtherUser.IP + "<br>");
                sb2.Append("<font style='color:red'>" + inviteInfo.OtherUser.Mobile + "</font>");
                sb2.Append("</div></td>");
                sb2.Append("<td>" + inviteInfo.Create_time + "</td>");
                sb2.Append("<td><a href='Index-YaoqingFanli.aspx?confir=" + inviteInfo.Id + "' ask='是否确认邀请返利？'>确认</a>｜    <a href='Index-YaoqingFanli.aspx?del=" + inviteInfo.Id + "' ask='取消此邀请信息吗？'>取消</a></td>");
                
            }
            else
            {
                sb2.Append("<td>&nbsp;</td>");
                sb2.Append("<td>&nbsp;</td>");
                sb2.Append("<td>&nbsp;</td>");
            }

            sb2.Append("</tr>");
        }
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
    }

    #region 执行邀请返利动作
    public void GetFanli(int id)
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Invite_Handle))
        {
            SetError("你不具有确认邀请返利的权限！");
            Response.Redirect("Index-YaoqingFanli.aspx");
            Response.End();
            return;

        }
        else
        {
            if (!string.IsNullOrEmpty(PageValue.CurrentAdmin.ToString()))
            {
                IInvite iinvite = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iinvite = session.Invite.GetByID(id);
                }
                // 第一步 查询此用户是否下过订单，如果下过成功订单，那么可以返利，否则无法进行返利
                IOrder iorder = null;
                OrderFilter orderfilter = new OrderFilter();
                orderfilter.User_id = iinvite.Other_user_id;
                orderfilter.State = "Pay";
                orderfilter.AddSortOrder(OrderFilter.Create_time_ASC);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iorder = session.Orders.Get(orderfilter);
                }
                if (iorder != null)
                {
                    if (iinvite.Team != null)
                    {
                        if (iinvite.Team.Bonus > 0) //项目表是否优惠券返利是否>0,
                        {
                            decimal dec1 = iinvite.User.Money;
                            decimal dec2 = iinvite.Team.Bonus;
                            int sUserId = iinvite.User_id;
                            //修改主动用户的账户余额
                            //int i = 0;
                            IUser iuser = AS.GroupOn.App.Store.CreateUser();
                            iuser = iinvite.User;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                iuser.Money = dec1 + dec2;
                                iuser.Id = sUserId;
                                session.Users.UpdateUser(iuser);
                            }
                            //把项目表中的返利金额修改到邀请表中
                            iinvite.Admin_id = PageValue.CurrentAdmin.Id;
                            iinvite.Credit = iinvite.Team.Bonus;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                session.Invite.Update(iinvite);
                            }
                            //新增用户消费记录
                            IFlow iflow = AS.GroupOn.App.Store.CreateFlow();
                            iflow.User_id = iinvite.User_id;
                            iflow.Detail_id = iorder.Pay_id;
                            iflow.Direction = "income";
                            iflow.Money = iinvite.Credit;
                            iflow.Action = "invite";
                            iflow.Create_time = DateTime.Now;
                            iflow.Admin_id = 0;
                            iflow.Detail = String.Empty;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                session.Flow.Insert(iflow);
                            }

                            fanLi();
                            SetSuccess("友情提示：返利成功，返利金额：" + iinvite.Team.Bonus + "元");
                            Response.Redirect(PageValue.WebRoot + "manage/index-YaoqingFanli.aspx");

                        }
                        else
                        {
                            SetError("对不起，被邀请人购买的项目没有邀请返利");
                        }
                    }
                    else
                    {
                        SetError("对不起，此项目不存在");
                    }
                }
                else
                {
                    SetError("对不起，此订单已退款");
                }
            }
            else
            {
                SetError("没有检索到您的登录");
                Response.Redirect("Login.aspx");
            }
        }
    }
    #endregion

    #region 执行违规操作
    public void NoRule(int id)
    {
         //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Invite_Cancle))
        {
            SetError("你不具有取消邀请返利的权限！");
            Response.Redirect("Index-YaoqingFanli.aspx");
            Response.End();
            return;

        }
        else
        {
            IInvite iinvite = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iinvite = session.Invite.GetByID(id);
            }
            iinvite.Admin_id = PageValue.CurrentAdmin.Id;
            iinvite.Pay = "C";//违规标记
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                session.Invite.Update(iinvite);
            }
            SetSuccess("已取消");
            fanLi();
        }
    }
    #endregion


    ///// <summary>
    ///// 筛选条件
    ///// </summary>
    public void SelectWhere()
    {
        if (!string.IsNullOrEmpty(Request["startTime"]))
        {
            url = url + "&startTime=" + Request["startTime"];
            filter.FromCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request["startTime"]).ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request["endTime"]))
        {
            url = url + "&endTime=" + Request["endTime"];
            filter.ToCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request["endTime"]).ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now);
        }

        if (!string.IsNullOrEmpty(Request["ddlState"]))
        {
            url = url + "&ddlState=" + Request["ddlState"];
            string ddlState = Request["ddlState"];

            if (ddlState == "1")//项目ID
            {
                filter.Team_id = Helper.GetInt(Request["txtcontent"], 0);
            }
            if (ddlState == "2")//邀请人用户名
            {
                IUser iuser = null;
                UserFilter userfilter = new UserFilter();
                userfilter.Username = Helper.GetString(Request["txtcontent"], String.Empty);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iuser = session.Users.GetByName(userfilter);
                }
                filter.User_id = iuser.Id;
            }
            if (ddlState == "3")//被邀请人用户名
            {
                IUser iuser = null;
                UserFilter userfilter = new UserFilter();
                userfilter.LoginName = Helper.GetString(Request["txtcontent"], String.Empty);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iuser = session.Users.Get(userfilter);
                }
                filter.Other_user_id = iuser.Id;
            }
            url = url + "&txtcontent=" + Request["txtcontent"];
        }
    }
    
    
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server" method="">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                   
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>邀请记录</h2>
                                    <div class="search">
                                    时&nbsp;间：
                                            <input type="text"  name="startTime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" class="date" style="width: 110px" 
                                            <%if(!string.IsNullOrEmpty(Request.QueryString["startTime"])){ %>value="<%=Request.QueryString["startTime"] %>" <%} %> />到&nbsp;&nbsp;&nbsp;
                                            <input type="text" name="endTime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" class="date" style="width: 110px" 
                                            <%if(!string.IsNullOrEmpty(Request.QueryString["endTime"])){ %>value="<%=Request.QueryString["endTime"] %>" <%} %> />
                                        <select name="ddlState">
                                                <option value="0">请选择</option>
                                                <option value="1" <%if(Request.QueryString["ddlState"] == "1"){ %>selected="selected" <%} %>>项目ID</option>
                                                <option value="2" <%if(Request.QueryString["ddlState"] == "2"){ %>selected="selected" <%} %>>邀请人用户名</option>
                                                <option value="3" <%if(Request.QueryString["ddlState"] == "3"){ %>selected="selected" <%} %>>被邀请人用户名</option>
                                            </select>&nbsp;&nbsp;
                                            <input type="text" name="txtcontent" class="h-input"
                                            <%if(!string.IsNullOrEmpty(Request.QueryString["txtcontent"])){ %>value="<%=Request.QueryString["txtcontent"] %>" <%} %>  />&nbsp;
                                            <input type="submit" value="筛选" class="formbutton" name="saiXuan" style="padding: 1px 6px;" />    
                                    <ul class="filter">
                                        
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="8">
                                                <input id="items" type="hidden" />
                                                <%if (pagerHtml != "")
                                                  { %>
                                                <input value="批量确认" type="button" class="formbutton" style="padding: 1px 6px;" onClick='javascript:GetDeleteItem(<%= Helper.GetInt(Request.QueryString["page"], 1) %>);' />
                                                <%} %><%=pagerHtml%>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>

<script type="text/javascript">
    $(function () {

        $("#checkall").click(function () {
            $("input[id='check']").attr("checked", $("#checkall").attr("checked"));
        });
    })
    function GetDeleteItem(url) {
        var str = "";
        var urls = url;
        $("input[id='check']:checked").each(function () {
            str += $(this).val() + ";";
        });

        $("#items").val(str.substring(0, str.length - 1));

        if (str.length > 0) {
            var istrue = window.confirm("是否确认选中项？");
            if (istrue) {
                window.location = "Index-YaoqingFanli.aspx?item=" + $("#items").val() + "&url=" + urls;
            }
        }
        else {
            alert("你还没有选择要确认的项！ ");
        }
    }
</script>