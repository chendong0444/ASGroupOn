<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public string strOrderID = "";
    public string strOrderCTime = "";
    public string strTeamID = "";
    public string strTeamTitle = "";
    public string strCurrency = "";
    public string strPrice = "";
    public string strQuantity = "";
    public string strOrigin = "";
    public string strState = "";
    public string catename = "";
    public string kuaino = "";
    public string wuliu = "";
    IOrderDetail detailbll = null;
    IOrder mOrder = null;
    PcouponFilter pcouponfil = new PcouponFilter();
    IList<IPcoupon> pcouponlist = null;
    OrderDetailFilter orderdetafile = new OrderDetailFilter();
    public IList<IOrderDetail> detaillist = new List<IOrderDetail>();
    protected NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "order";
        _system = WebUtils.GetSystem();
        //通过request["id"]得到订单ID号
        NeedLogin();
        if (!Page.IsPostBack)
        {
            if (Request["id"] != null)
            {
                if (AS.Common.Utils.NumberUtils.IsNum(Request["id"].ToString()))
                {
                    initPage();
                }
                else
                {
                    SetError("对不起，参数非法");
                }
            }
        }
    }
    //根据项目编号，查询项目内容
    public string GetTeam(string id)
    {
        string str = "";
        ITeam teamodel = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(Helper.GetInt(id, 0));
        }
        if (teamodel != null)
        {
            str = teamodel.Title;
        }
        else
        {
            str = "";
        }
        return str;
    }
    private void initPage()
    {
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            strOrderID = Request["id"].ToString();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mOrder = session.Orders.GetByID(Helper.GetInt(strOrderID, 0));
            }
            //用户无法修改其他用户的额单子
            if (mOrder.User_id != AsUser.Id)
            {
                SetError("友情提示：无法操作其他用户的订单");
                Response.Redirect(PageValue.WebRoot + "index.aspx");
                Response.End();
                return;
            }
            if (mOrder == null || mOrder.User_id != AsUser.Id)//判断该订单是否存在并且是不是自己的订单
            {
                Response.Redirect(PageValue.WebRoot + "index.aspx");
                Response.End();
                return;
            }
            if (mOrder.State == "unpay") //如果订单是未付款状态此跳转到付款页面
            {
                if (mOrder.Team_id == 0)//走购物车的
                {
                    Response.Redirect(GetUrl("购物车订单", "shopcart_confirmation.aspx?orderid=" + strOrderID));
                    Response.End();
                }
                else
                {
                    Response.Redirect(GetUrl("优惠卷确认","order_check.aspx?orderid=" + strOrderID));
                    Response.End();
                }
                return;
            }
            else if (mOrder.State == "scoreunpay")
            {
                Response.Redirect(GetUrl("积分支付", "PointsShop_Pconfir.aspx?orderid=" + strOrderID));
                Response.End();
                return;
            }
            if (mOrder.State != "pay" && mOrder.State != "scorepay" && mOrder.State != "nocod") //如果订单不是付款状态则提示错误
            {
                SetError("不存在此订单");
                Response.Redirect(PageValue.WebRoot + "index.aspx");
                Response.End();
                return;
            }
            strOrderCTime = DateTime.Parse(mOrder.Create_time.ToString()).ToString("yyyy-MM-dd HH-mm");
            strTeamID = mOrder.Team_id.ToString();
            ITeam mTeam = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mTeam = session.Teams.GetByID(Helper.GetInt(strTeamID, 0));
            }

            if (mOrder.State == "pay" || mOrder.State == "scorepay")
            {
                strState = "交易成功";
            }
            if (mOrder.State == "unpay" || mOrder.State == "scoreunpay")
            {
                strState = "-";
            }
            if (ASSystem != null)
            {
                strCurrency = ASSystem.currency;
            }
            strPrice = mOrder.Price.ToString();
            strQuantity = mOrder.Quantity.ToString();
            strOrigin = (float.Parse(strPrice) * float.Parse(strQuantity)).ToString();
            if (mOrder.Express == "Y")//显示快递
            {
                initExpress(mOrder.Id);
            }
            if (mOrder.State == "pay" || mOrder.State == "scorepay")//订单交易成功
            {
                initStateInfo(mOrder);

            }

            if (mTeam != null)
            {

                strTeamTitle = mTeam.Title + "&nbsp;&nbsp;&nbsp;<font style='color:red'>" + Getbulletin(mOrder.result, 0) + "</font>";
                if (mOrder.Card_id != "" && mOrder.Card_id != null)  //是否显示代金券
                {
                    initCard(mOrder.Card_id);
                }

                if (mTeam.Delivery == "coupon" || mTeam.Delivery == "pcoupon")//显示优惠券  ，显示商户优惠券
                {
                    initCoupon();
                }
                else if (mTeam.Delivery == "express")//不明白
                {
                    initExpressInfo(mOrder);
                }
                else if (mTeam.Delivery == "draw")//抽奖
                {
                    initdraw(mOrder.Team_id, mOrder.Id);
                }
                else if (mTeam.Delivery == "pickup")//自提
                {
                    initPickUp(mTeam);
                }
            }
            else
            {
                initExpressInfo(mOrder);
            }
        }
    }
    private void initPickUp(ITeam mTeam)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" class=\"data-table\">");
        sb.Append("<tr>");
        sb.Append("<th>自取：</th>");
        sb.Append("<td class=\"other-coupon\"></td>");
        sb.Append("</tr>");
        sb.Append(" <tr>");
        sb.Append("<th>取货地址：</th>");
        sb.Append("<td>" + mTeam.Address + "</td>");
        sb.Append("</tr>");
        sb.Append(" <tr>");
        sb.Append("<th>联系电话：</th>");
        sb.Append("<td>" + mTeam.Mobile + "</td>");
        sb.Append("</tr>");
        sb.Append("</table>");
        ltPickUp.Text = sb.ToString();
    }
    private void initExpressInfo(IOrder mOrder)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" class=\"data-table\">");
        sb.Append(" <tr>");
        sb.Append(" <th>快递：</th>");
        sb.Append("");
        if (mOrder.Express_id > 0)
        {
            CategoryFilter Categoryfil = new CategoryFilter();
            IList<ICategory> CategoryList = null;
            Categoryfil.Id = mOrder.Express_id;
            Categoryfil.Zone = "express";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                CategoryList = session.Category.GetList(Categoryfil);
            }

            if (CategoryList.Count > 0)
            {
                if (CategoryList[0].Name != null && CategoryList[0].Name.ToString() != "")
                {
                    sb.Append("<td>" + CategoryList[0].Name.ToString() + "：" + mOrder.Express_no + "</td>");
                }
            }
        }
        else
        {
            sb.Append(" <td class=\"other-coupon\">请耐心等待发货</td>");
        }
        sb.Append("</tr>");
        if (mOrder.Express_id > 0)
        {
            CategoryFilter Categoryfil = new CategoryFilter();
            IList<ICategory> CategoryList = null;
            Categoryfil.Id = mOrder.Express_id;
            Categoryfil.Zone = "express";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                CategoryList = session.Category.GetList(Categoryfil);
            }
            if (CategoryList.Count > 0)
            {
                catename = CategoryList[0].Ename.ToString();
                kuaino = mOrder.Express_no;
                if (mOrder.Express_no != "")
                {
                    wuliu = "<img src='" + PageValue.WebRoot + "upfile/css/i/loading.gif'/>";
                }
                sb.Append("<tr>");
                sb.Append("<th>物流跟踪：</th>");
                sb.Append("<td>以下跟踪信息由<a href=\"http://www.kuaidi100.com/?refer=hishop\" target=\"_blank\">快递100</a>提供,如有疑问请到物流公司官网查询</td>");
                sb.Append("</tr>");
                sb.Append("<tr>");
                sb.Append("<td id='wu' style='color:red' colspan='2'></td>");
                sb.Append("</tr>");

            }
        }
        sb.Append("<tr>");
        sb.Append(" <th>收件人：</th>");
        sb.Append("<td>" + mOrder.Realname + "</td>");
        sb.Append(" </tr>");
        sb.Append("<tr>");
        sb.Append("<th>收件地址：</th>");
        sb.Append("<td>" + mOrder.Address + "</td>");
        sb.Append("</tr>");
        sb.Append("<tr>");
        sb.Append(" <th>手机号码：</th>");
        sb.Append("<td>" + mOrder.Mobile + "</td>");
        sb.Append("</tr>");
        sb.Append("<tr>");
        sb.Append(" <th>订单附言：</th>");
        sb.Append("<td>" + mOrder.Remark + "</td>");
        sb.Append("</tr>");
        if (mOrder.rviewstate != 0 && mOrder.rviewstate != 8)
        {
            sb.Append("<tr>");
            sb.Append(" <th>退款状态：</th>");
            if (mOrder.rviewstate == 1)
            {
                sb.Append("<td>退款订单待审核</td>");

            }
            if (mOrder.rviewstate == 4)
            {
                sb.Append("<td>退款订单正在审核</td>");
            }
            if (mOrder.rviewstate == 2)
            {
                sb.Append("<td>退款订单被拒绝</td>");
            }
            sb.Append("</tr>");
            sb.Append("<tr>");
            sb.Append(" <th>退款原因：</th>");
            if (mOrder.rviewstate != 1 && mOrder.rviewstate != 8)
            {
                sb.Append("<td>" + mOrder.rviewremarke + "</td>");
            }
            sb.Append("<td>" + mOrder.userremarke + "</td>");
            sb.Append("</tr>");
        }
        sb.Append("</table>");
        ltExpressInfo.Text = sb.ToString();
    }
    public string Getkuai(string code, string kuaidi)
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();

        sb.Append("<table style='width:100%;margin-left:14px;'>");
        if (code != "" && kuaidi != "")
        {
        }
        sb.Append("</table>");
        return sb.ToString();
    }
    /// <summary>
    /// 优惠券信息
    /// </summary>
    public static bool istuan(int now_number, int min_number)
    {
        bool falg = false;
        if (now_number >= min_number)
        {
            falg = true;
        }
        else
        {
            falg = false;
        }
        return falg;
    }
    private void initCoupon()
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" class=\"data-table\">");
        sb.Append("<tr>");
        sb.Append(" <th>优惠券：</th>");
        ITeam teammodel = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(Helper.GetInt(strTeamID, 0));
        }
        //判断项目是否达到了团购人数
        if (istuan(Convert.ToInt32(teammodel.Now_number.ToString()), Convert.ToInt32(teammodel.Min_number)))
        {
            CouponFilter couponfil = new CouponFilter();
            IList<ICoupon> couplist = null;
            couponfil.Order_id = Helper.GetInt(strOrderID, 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                couplist = session.Coupon.GetList(couponfil);
            }
            pcouponfil.orderid = Helper.GetInt(strOrderID, 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pcouponlist = session.Pcoupon.GetList(pcouponfil);
            }
            sb.Append("<td class=\"other-coupon\">");
            for (int i = 0; i < couplist.Count; i++)
            {
                ICoupon iCoupon = couplist[i];
                sb.Append("<p>" + iCoupon.Id + " - " + iCoupon.Secret + "</p>");

            }
            for (int i = 0; i < pcouponlist.Count; i++)
            {
                IPcoupon ipcoupon = pcouponlist[i];
                sb.Append("<p>" + ipcoupon.number + "</p>");
            }
            sb.Append("</td>");
            sb.Append("</tr>");
        }
        else
        {
            sb.Append("<td class=\"other-coupon\">");
            sb.Append("" + ASSystem.couponname + "将在团购成功后，由系统自动发放</td>");
            sb.Append("</td>");
            sb.Append("</tr>");
        }
        sb.Append("<tr>");
        sb.Append(" <th>使用方法：</th>");
        sb.Append(" <td>至商家消费时，请出示" + ASSystem.couponname + "，配合商家验证券的编号及密码</td>");
        sb.Append("</tr>");
        sb.Append("</table>");
        ltCoupon.Text = sb.ToString();
    }
    /// <summary>
    /// 抽奖信息
    /// </summary>
    private void initdraw(int teamid, int orderid)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("<table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" class=\"data-table\">");
        sb.Append("<tr>");
        sb.Append(" <th>抽奖号码：</th>");
        sb.Append("<td class=\"other-coupon\">");
        sb.Append("<p>" + DrawMethod.GetDrawCode(orderid) + "</p>");
        sb.Append("</td>");
        sb.Append("</tr>");
        sb.Append("</table>");
        ltdraw.Text = sb.ToString();
    }
    /// <summary>
    /// 订单支付信息
    /// </summary>
    /// <param name="mOrder">订单实体</param>
    private void initStateInfo(IOrder mOrder)
    {
        StringBuilder sb = new StringBuilder();
        if (mOrder.State == "scorepay" || mOrder.State == "scoreunpay")
        {
            sb.Append("<tr>");
            sb.Append(" <td class=\"left\"></td>");
            sb.Append("<td></td>");
            sb.Append("<td></td>");
            sb.Append("<td></td>");
            sb.Append("<td></td>");
            sb.Append("<td ><span class=\"money\"></span>" + mOrder.totalscore + "积分</td>");
            sb.Append("<td class=\"status\">交易成功</td>");
            sb.Append("</tr>");
            sb.Append("<tr>");
            sb.Append(" <td class=\"left\">总金额</td>");
            sb.Append("<td></td>");
            sb.Append("<td></td>");
            sb.Append("<td></td>");
            sb.Append("<td></td>");
            sb.Append("<td ><span class=\"money\">" + ASSystem.currency + "</span>" + mOrder.Origin.ToString() + "</td>");
            sb.Append("<td class=\"status\">交易成功</td>");
            sb.Append("</tr>");
        }
        else
        {
            sb.Append("<tr>");
            sb.Append(" <td class=\"left\"></td>");
            sb.Append("<td></td>");
            sb.Append("<td></td>");
            sb.Append("<td></td>");
            sb.Append("<td></td>");
            sb.Append("<td><span class=\"money\">" + ASSystem.currency + "</span>" + mOrder.Origin.ToString() + "</td>");
            sb.Append("<td class=\"status\">交易成功</td>");
            sb.Append("</tr>");
        }
        ltState.Text = sb.ToString();
    }
    /// <summary>
    /// 快递信息
    /// </summary>
    /// <param name="TeamID">项目ID</param>
    private void initExpress(int TeamID)
    {
        StringBuilder sb = new StringBuilder();
        IOrder morder = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            morder = session.Orders.GetByID(Helper.GetInt(TeamID, 0));
        }
        sb.Append("<tr>");
        sb.Append("<td class=\"left\">快递</td>");
        sb.Append("<td></td>");
        sb.Append("<td>x</td>");
        sb.Append("<td></td>");
        sb.Append("<td>=</td>");
        sb.Append("<td ><span class=\"money\">" + ASSystem.currency + "</span>" + morder.Fare.ToString() + "</td>");
        sb.Append("<td class=\"status\">-</td>");
        sb.Append("</tr>");
        ltExpress.Text = sb.ToString();
    }
    //初始化代金卷
    private void initCard(string cardId)
    {
        StringBuilder sb = new StringBuilder();
        ICard mCard = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            mCard = session.Card.GetByID(cardId);
        }
        sb.Append("<tr>");
        sb.Append(" <td class=\"left\">代金券：" + cardId + "</td>");
        sb.Append("<td>" + mCard.Credit + "</td>");
        sb.Append("<td>x</td>");
        sb.Append("<td>1</td>");
        sb.Append("<td>=</td>");
        sb.Append("<td ><span class=\"money\">" + strCurrency + "</span>" + mCard.Credit + "</td>");
        if (mCard.consume.ToUpper() == "Y")
        {
            sb.Append("<td class=\"status\">已使用</td>");
        }
        else
        {
            sb.Append("<td class=\"status\">-</td>");
        }
        sb.Append("</tr>");
        ltCard.Text = sb.ToString();
    }
    /// <summary>
    /// 显示订单中所选项目的格式
    /// </summary>
    /// <param name="bulletin"></param>
    /// <param name="showhtml">是否显示html格式 0显示 1不显示</param>
    /// <returns></returns>
    public static string Getbulletin(string bulletin, int showhtml = 0)
    {
        string str = "";
        if (bulletin != null && bulletin.Length > 0)
        {
            str = "<font style='color: rgb(153, 153, 153);'>";
            string strs = "<br><b style='color: red;'>[规格]</b>";
            if (showhtml == 1)
            {
                str = String.Empty;
                strs = String.Empty;
            }
            string[] strArray = bulletin.Split('|');

            for (int i = 0; i < strArray.Length; i++)
            {
                if (bulletin != "" && bulletin != null)
                {
                    str += strs + strArray[i].Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "") + "";
                }

            }
            if (showhtml == 0)
                str = str + "</font><br><br>";
        }
        return str;
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <form id="form1" runat="server">
       
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="order-detail">
            <div id="dashboard" class="menu_tab">
                     <%LoadUserControl("_MyWebside.ascx", Ordertype); %>
                    </div>
                    <div class="coupons-box" id="tabsContent">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        订单详情</h2>
                                </div>
                                <div class="sect">
                                    <table cellspacing="0" cellpadding="0" border="0" class="data-table">
                                        <tr>
                                            <th>
                                                订单编号：
                                            </th>
                                            <td class="orderid">
                                                <strong>
                                                    <%=strOrderID %></strong>
                                            </td>
                                            <th>
                                                下单时间：
                                            </th>
                                            <td>
                                                <span>
                                                    <%=strOrderCTime %></span>
                                            </td>
                                        </tr>
                                    </table>
                                    <table cellspacing="0" cellpadding="0" border="0" class="info-table">
                                        <tr>
                                            <th class="left" width="auto">
                                                项目名称
                                            </th>
                                            <%if (mOrder.State == "scorepay" || mOrder.State == "scoreunpay")
                                              { %>
                                            <th width="35">
                                                积分
                                            </th>
                                            <% }
                                              else
                                              {%>
                                            <th width="35">
                                                单价
                                            </th>
                                            <% }%>
                                            <th width="10">
                                            </th>
                                            <th width="45">
                                                数量
                                            </th>
                                            <th width="10">
                                            </th>
                                            <%if (mOrder.State == "scorepay" || mOrder.State == "scoreunpay")
                                              { %>
                                            <th width="45">
                                                总积分
                                            </th>
                                            <% }
                                              else
                                              {%>
                                            <th width="45">
                                                总价
                                            </th>
                                            <% }%>
                                            <th width="150">
                                                状态
                                            </th>
                                        </tr>
                                        <%if (strTeamID != "0")
                                          { %>
                                        <tr>
                                            <td class="left">
                                                <a href="<%=getTeamPageUrl(Helper.GetInt(strTeamID,0))%>" target="_blank">
                                                    <%=strTeamTitle%></a>
                                            </td>
                                            <td>
                                                <span class="money">
                                                    <%=strCurrency%></span><%=strPrice%>
                                            </td>
                                            <td>
                                                x
                                            </td>
                                            <td>
                                                <%=strQuantity%>
                                            </td>
                                            <td>
                                                =
                                            </td>
                                            <td>
                                                <span class="money">
                                                    <%=strCurrency%></span><%=strOrigin%>
                                            </td>
                                            <td class="status">
                                                <%=strState%>
                                            </td>
                                        </tr>
                                        <% }
                                          else
                                          {
                                          orderdetafile.Order_ID =Helper.GetInt(strOrderID,0);  
                                          using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                          {
                                              detaillist = session.OrderDetail.GetList(orderdetafile);
                                          } 
                                          foreach (IOrderDetail model in detaillist)
                                          {
                                              string detailresult = model.result;
                                        %>
                                        <tr>
                                            <td class="left">
                                                <a href='<%=getTeamPageUrl(model.Teamid)%>' target="_blank">
                                                    <%=GetTeam(model.Teamid.ToString())+"&nbsp; <font style='color:red'>"+Getbulletin(detailresult)+"</font>" %></a>
                                            </td>
                                            <%if (mOrder.State == "scorepay" || mOrder.State == "scoreunpay")
                                              { %>
                                            <td>
                                                <span class="money"></span>
                                                <%=model.totalscore%>积分
                                            </td>
                                            <% }
                                              else
                                              {%>
                                            <td>
                                                <span class="money">
                                                    <%=ASSystem.currency%></span><%=model.Teamprice%>
                                            </td>
                                            <% }%>
                                            <td>
                                                x
                                            </td>
                                            <td>
                                                <%=model.Num %>
                                            </td>
                                            <td>
                                                =
                                            </td>
                                            <td>
                                                <%if (mOrder.State == "scorepay" || mOrder.State == "scoreunpay")
                                                  { %>
                                                <span class="money"></span>
                                                <%=model.Num * model.totalscore%>积分
                                                <% }
                                                  else
                                                  {%>
                                                <span class="money">
                                                    <%=ASSystem.currency %></span>
                                                <%=model.Num * model.Teamprice%>
                                                <% }%>
                                            </td>
                                            <td class="status">
                                                <%=strState%>
                                            </td>
                                        </tr>
                                        <% }%>
                                        <% } %>
                                        <asp:Literal ID="ltCard" runat="server"></asp:Literal>
                                        <asp:Literal ID="ltExpress" runat="server"></asp:Literal>
                                        <asp:Literal ID="ltState" runat="server"></asp:Literal>
                                    </table>
                                    <asp:Literal ID="ltCoupon" runat="server"></asp:Literal>
                                    <asp:Literal ID="ltdraw" runat="server"></asp:Literal>
                                    <asp:Literal ID="ltExpressInfo" runat="server"></asp:Literal>
                                    <asp:Literal ID="ltPickUp" runat="server"></asp:Literal>
                                </div>
                            </div>
                        </div>
                    </div>
                  <%--  <div id="sidebar">
                    </div>--%>
                </div>
            </div>
            <!-- bd end -->
        </div>
        </form>
        <%if (!string.IsNullOrEmpty(kuaino))
          { %>
        <script type="text/javascript">
            X.get("<%=PageValue.WebRoot %>manage/ajax_wuliu.aspx?id=<%=catename %>&&kuai=<%=kuaino %>");
        </script>
        <% }%>
    </div>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
