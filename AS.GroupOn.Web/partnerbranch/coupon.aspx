<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerBranchPage" %>

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
<script runat="server">
    public string strCouponname = "";
    public NameValueCollection _system = new NameValueCollection();
    
    int page = 1;
    protected int type = 0;
    protected string pagerhtml = String.Empty;
    string url = String.Empty;
    string request_tteamId = String.Empty;
    string request_orderId = String.Empty;
    string request_coupon = String.Empty;
    string request_state = String.Empty;
    string request_teamid = String.Empty;
    protected IPagers<ICoupon> pager = null;
   protected CouponFilter coufilter = new CouponFilter();
   protected IList<ICoupon> ilistcoupon = null;
   protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (CookieUtils.GetCookieValue("pbranch", key) == null || CookieUtils.GetCookieValue("pbranch", key) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=branch");
        }
        _system = WebUtils.GetSystem();

        if (Request.HttpMethod == "POST")
        {
            request_tteamId = txtTeamId.Text.ToString();
            request_orderId = txtOrderId.Text.ToString();
            request_coupon = txtcoupon.Text.ToString();
            request_state = ddlstate.SelectedValue.ToString();
            request_teamid = Helper.GetString(Request.QueryString["teamid"], String.Empty);
        }
        else
        {
            request_tteamId =Helper.GetString(Request.QueryString["tteamid"], String.Empty);
            request_orderId = Helper.GetString(Request.QueryString["orderId"], String.Empty);
            request_coupon = Helper.GetString(Request.QueryString["coupon"], String.Empty);
            request_state =Helper.GetString(Request.QueryString["state"], String.Empty);
            page = Helper.GetInt(Request.QueryString["page"], 1);
            request_teamid = Helper.GetString(Request.QueryString["teamid"], String.Empty);
            txtTeamId.Text = request_tteamId;
             txtOrderId.Text =request_orderId;
             txtcoupon.Text=request_coupon ;
             ddlstate.SelectedValue=request_state ;
        }


        if (Request["couponsecret"] != null && Request["couponsecret"].ToString() != "" && Request["couponid"] != null && Request["couponid"] != "")
        {
            string result = "";
            if (couponConsume(Request["couponid"].ToString(), Request["couponsecret"].ToString(), ref result))
            {
                SetSuccess("消费成功：" + result + "，密码：" + Request["couponsecret"].ToString());
            }
            else
            {
                SetError("消费失败：" + result);
            }
            Response.Redirect("coupon.aspx");
            Response.End();
            return;
        }

        ISystem system = Store.CreateSystem();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
        }
        if (system != null)
        {
            strCouponname = system.couponname;
        }
        //if (Request.HttpMethod == "POST")
        //{
            type = 1;
            initPage();
        //}

        //if (!Page.IsPostBack)
        //{
        //    initPage();
        //}
       

    }
    private void initPage()
    {
        if (CookieUtils.GetCookieValue("pbranch", key) == null || CookieUtils.GetCookieValue("pbranch", key) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=pbranch");
        }

        string strPartnerID = CookieUtils.GetCookieValue("pbranch", key).ToString();

        if (type == 1)
        {
            string strSqlWhere ="where 1=1";

            if (request_teamid != String.Empty)
            {
                strSqlWhere = strSqlWhere + " and Team_id =" + request_teamid;
                url = "teamid=" + request_teamid;
                txtTeamId.Enabled = false;
                txtTeamId.Text = request_teamid;
            }
            else
            {
                if (request_tteamId != String.Empty)
                {
                    strSqlWhere = strSqlWhere + " and Team_id =" + request_tteamId;
                    url += "&tteamid=" + request_tteamId;
                }
            }
            if (request_orderId != String.Empty)
            {
                strSqlWhere = strSqlWhere + "and Order_id =" + request_orderId;
                url += "&orderId=" + request_orderId;
            }
            if (request_coupon != String.Empty)
            {
                strSqlWhere = strSqlWhere + " and ID='" + request_coupon + "' ";
                url += "&coupon=" + request_coupon;
            }
            if (request_state != "0" && request_state != String.Empty)
            {
                strSqlWhere = strSqlWhere + " and  Consume='" + request_state + "'";
                url += "&state=" + request_state;
            }
            coufilter.table = "(select * from Coupon where Coupon.Team_id in(select Team.Id from Team where branch_id=" + Helper.GetInt(CookieUtils.GetCookieValue("pbranch", key).ToString(), 0) + "))t " + strSqlWhere;
            coufilter.PageSize = 30;
            coufilter.CurrentPage = page;
            coufilter.AddSortOrder(CouponFilter.Create_time_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pager = session.Coupon.PagerCoupon(coufilter);
            }

          }
        else
        {
            coufilter.table = "(select * from Coupon where Coupon.Team_id in(select Team.Id from Team where branch_id=" + Helper.GetInt(CookieUtils.GetCookieValue("pbranch", key).ToString(), 0) + "))t";
            coufilter.PageSize = 30;
            coufilter.CurrentPage = page;
            coufilter.AddSortOrder(CouponFilter.Create_time_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pager = session.Coupon.PagerCoupon(coufilter);
            }
            }
        StringBuilder sb = new StringBuilder();
        sb.Append("<tr><th width=\"12%\" nowrap>编号</th><th width=\"23%\">项目名称</th><th width=\"17%\">购买者</th><th width=\"12%\" nowrap>密码</th><th width=\"13%\" nowrap>开始时间</th><th width=\"13%\" nowrap>有效日期</th><th width=\"10%\">状态</th></tr>");

        ilistcoupon = pager.Objects;
        if (ilistcoupon.Count > 0)
        {
            int i = 0;
            foreach(ICoupon coupon in ilistcoupon)
            {
                
                //显示的数据
                if (i % 2 != 0)
                {
                    sb.Append("<tr  id='team-list-id-" + coupon.Id+ "'>");
                }
                else
                {
                    sb.Append("<tr class=\"alt\"  id='team-list-id-" + coupon.Id+ "'>");
                }

                sb.Append("<td>" + coupon.Id.ToString() + "</td>");
                ITeam mTeam = Store.CreateTeam();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mTeam = session.Teams.GetByID(Helper.GetInt(coupon.Team_id,0));
                }
                sb.Append("<td width=\"450\" nowrop>" +coupon.Team_id.ToString() + "&nbsp;(<a class=\"deal-title\" href=\"" + getTeamPageUrl(Helper.GetInt(coupon.Team_id,0)) + "\" target=\"_blank\">" + mTeam.Title + "</a>)</td>");

                IUser mUser = Store.CreateUser();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mUser = session.Users.GetByID(Helper.GetInt(coupon.User_id, 0));
                }
                if (mUser != null)
                {
                    sb.Append("<td nowrap>" + mUser.Email + "<br/>" + mUser.Username + "</td>");
                }
                else
                {
                    sb.Append("<td nowrap></td>");
                }
                if (ASSystem != null)
                {
                    if (ASSystem.partnerdown == 1)
                    {
                        sb.Append("<td>" +coupon.Secret.ToString() + "</td>");

                    }
                    else
                    {
                        sb.Append("<td>*******</td>");
                    }
                }
                sb.Append("<td nowrap>" + ((coupon.start_time is DateTime) ? DateTime.Parse(coupon.start_time.ToString()).ToString("yyyy-MM-dd") : String.Empty) + "</td>");
                sb.Append("<td nowrap>" + DateTime.Parse(coupon.Expire_time.ToString()).ToString("yyyy-MM-dd") + "</td>");

                if (coupon.Consume.ToString() == "Y")
                {
                    sb.Append("<td nowrap>已消费<br/>");

                }
                else
                {
                    if (Convert.ToDateTime(DateTime.Parse(coupon.Expire_time.ToString()).ToString("yyyy-MM-dd 23:59:59")) < DateTime.Now)
                    {
                        sb.Append("<td nowrap>已过期</td>");
                    }
                    else
                    {
                        sb.Append("<td nowrap>有效</td>");
                    }
                }
                sb.Append("</tr>");
                i++;
            }
        }
        else
        {
            sb.Append("<tr><td colspan=\"7\">暂无数据！</td></tr>");
        }

        ltCouponn.Text = sb.ToString();
        pagerhtml = WebUtils.GetPagerHtml(30, pager.TotalRecords, page, WebRoot + "partnerbranch/coupon.aspx?" + url + "&page={0}");
    }



    private bool couponConsume(string cid, string secret, ref string result)
    {
        bool bRes = false;
        ICoupon couponmodel = Store.CreateCoupon();
        CouponFilter couponfilter = new CouponFilter();
        couponfilter.Id = cid;
        couponfilter.Secret = secret;
        //找到id值为cid的优惠券记录
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            couponmodel = session.Coupon.Get(couponfilter);
        }
        //找到商家
        if (couponmodel != null)
        {
            IPartner partnermodel = Store.CreatePartner();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                partnermodel = session.Partners.GetByID(couponmodel.Partner_id);
            }
            //找到项目
            ITeam teammodel = Store.CreateTeam();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teammodel = session.Teams.GetByID(couponmodel.Team_id);
            }
            coufilter.Id = cid;
            coufilter.Secret = couponmodel.Secret;
            int count=0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                count = session.Coupon.GetCount(coufilter);
            }
            if(count>0)
            {//如果优惠券已使用
                bRes = false;
            }
            else
            {
                //更新优惠券 ip，使用时间 使用状态
                ICoupon coupon = Store.CreateCoupon();
                coupon.Id = cid;
                coupon.IP = WebUtils.GetClientIP.ToString();
                coupon.Consume_time = DateTime.Now;
                coupon.Consume = "Y";
                coupon.Secret = couponmodel.Secret;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int upresult = session.Coupon.UpCoupon(coupon);
                }
                //写入消费记录表 
                IOrder ordermodel = Store.CreateOrder();
                coufilter.Id = cid;
                coufilter.Secret = couponmodel.Secret;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    couponmodel = session.Coupon.Get(coufilter);
                    ordermodel = session.Orders.GetByID(couponmodel.Order_id);
                }
                if (couponmodel.Credit > 0)
                {
                    IFlow flowmodel = Store.CreateFlow();
                    
                    flowmodel.User_id = couponmodel.User_id;
                    flowmodel.Detail_id = couponmodel.Id;
                    flowmodel.Direction = "income";
                    flowmodel.Money = couponmodel.Credit;
                    flowmodel.Action = "coupon";
                    flowmodel.Create_time = DateTime.Now;
                    IUser user = Store.CreateUser();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int addresult = session.Flow.Insert(flowmodel);
                        user = session.Users.GetByID(couponmodel.User_id);
                    }
                    IUser users = Store.CreateUser();
                    users.Id = user.Id;
                    users.Money = user.Money+couponmodel.Credit;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int upmoney = session.Users.Update(users);
                    }
                   
                }
                //修改用户表的里面的账户余额

                result = "券号：[" + cid + "]";

                bRes = true;

                if (_system != null)
                {
                    if (_system["opencoupon"] != null)
                    {
                        if (_system["opencoupon"] == "1")//开启优惠券打印提醒
                        {
                            #region 发送短信
                            List<string> phone = new List<string>();
                            if (ordermodel != null)
                            {
                                IUser buyuser = Store.CreateUser();
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    buyuser = session.Users.GetByID(couponmodel.User_id);
                                }
                                NameValueCollection values = new NameValueCollection();
                                values.Add("网站简称", ASSystem.abbreviation);
                                values.Add("用户名", buyuser.Username);
                                values.Add("券号", couponmodel.Id);
                                values.Add("消费时间", couponmodel.Consume_time.ToString());
                                string message =ReplaceStr("consumption", values);
                                phone.Add(buyuser.Mobile);
                                EmailMethod sms = new EmailMethod();
                              //sms.SendSMS(phone, message);
                              EmailMethod.SendSMS(phone, message);
                                //提示尊敬的{网站简称}用户{用户名}您的券号{券号}已于{消费时间}被消费。
                            }
                            #endregion
                        }
                    }
                }

            }
        }
        else
        {
            result = "券号：[" + cid + "]&nbsp;无效";

            bRes = false;
        }
        return bRes;
    }

</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
<form id="form1" runat="server" method="post">
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
                                    <h2>
                                        <%=strCouponname %>列表</h2>
                                    <ul class="contact-filter">
                                        <li>
                                            项目ID：<asp:TextBox ID="txtTeamId" runat="server" CssClass="h-input" />
                                            订单ID：<asp:TextBox ID="txtOrderId" runat="server" CssClass="h-input" />
                                            券编号：<asp:TextBox ID="txtcoupon" runat="server" CssClass="h-input" />&nbsp;
                                            <asp:DropDownList ID="ddlstate" runat="server">
                                                <asp:ListItem Value="0" Selected="True">请选择</asp:ListItem>
                                                <asp:ListItem Value="Y">已使用</asp:ListItem>
                                                <asp:ListItem Value="N">未使用</asp:ListItem>
                                            </asp:DropDownList>
                                            <input type="submit" value="筛选" name="btnselect" class="formbutton" style="padding: 1px 6px;" /></li></ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="ltCouponn" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="7">
                                            <ul class="paginator">
                                                    <li class="current">
                                                         <%= pagerhtml %>
                                                    </li>
                                                </ul>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>