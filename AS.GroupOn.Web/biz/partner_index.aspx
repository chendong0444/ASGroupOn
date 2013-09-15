<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>

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
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
        int page = 1;
        protected string pagerhtml = String.Empty;
       protected TeamFilter filter = new TeamFilter();
       protected IList<ITeam> teamlist = null;
       protected IPagers<ITeam> pager = null;
        protected string url = "";
        protected OrderFilter orderfilter = new OrderFilter();
        protected string strPartnerID = null;
        protected string key = FileUtils.GetKey();
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            page = Helper.GetInt(Request.QueryString["page"], 1);
            //需要日期选择脚本
            
            initPro();
            if (Request.HttpMethod == "POST" && Request.Form["downtxt"] != null)
            {
                initPage();
            }
        }
        private void initPro()
        {
            StringBuilder sb = new StringBuilder();
            
            strPartnerID = CookieUtils.GetCookieValue("partner",key).ToString();
            url = url + "&page={0}";
            
            url = "partner_index.aspx?" + url.Substring(1);
            filter.Partner_id = Convert.ToInt32(strPartnerID);
            filter.teamcata = 0;
            filter.NotDelivery = "draw";
            filter.AddSortOrder(TeamFilter.ID_DESC);
            filter.PageSize = 30;
            filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pager = session.Teams.GetPager(filter);
            }
            teamlist = pager.Objects;
            if (teamlist.Count > 0)
            {
                int i = 0;
                foreach (ITeam teaminfo in teamlist)
                {
                    //显示的数据
                    if (i % 2 != 0)
                    {
                        sb.Append("<tr  id='team-list-id-" + teaminfo.Id + "'>");
                    }
                    else
                    {
                        sb.Append("<tr class=\"alt\"  id='team-list-id-" + teaminfo.Id + "'>");
                    }
                    sb.Append("<td>" + teaminfo.Id + "</td>");
                    sb.Append("<td style=\"text-align:left;\"><a class=\"deal-title\" href=\"" + getTeamPageUrl( Helper.GetInt(teaminfo.Id.ToString(), 0)) + "\" target=\"_blank\">" + teaminfo.Title.ToString() + "</a></td>");
            
                    ICategory category = Store.CreateCategory();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        category = session.Category.SelectById(Convert.ToInt32(teaminfo.City_id));
                    }
                    if (int.Parse(teaminfo.City_id.ToString()) != 0 && category != null)
                    {
                        sb.Append("<td>" + category.Name + "</td>");
                    }
                    else
                    {
                        sb.Append("<td>全部城市</td>");
                    }
                    sb.Append("<td>" + DateTime.Parse(teaminfo.Begin_time.ToString()).ToString("yyyy-MM-dd") + "<br/>" + DateTime.Parse(teaminfo.End_time.ToString()).ToString("yyyy-MM-dd") + "</td>");
                    sb.Append("<td>" + teaminfo.Now_number.ToString() + "/" + teaminfo.Min_number + "</td>");
                    string strCurrency = "";
                    ISystem system = Store.CreateSystem();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        system = session.System.GetByID(1);
                    }
                    if (system != null)
                    {
                        strCurrency = system.currency;
                    }
                    sb.Append("<td><span class=\"money\">" + strCurrency + "</span>" + teaminfo.Team_price.ToString() + "<br/><span class=\"money\">" + strCurrency + "</span>" + teaminfo.Market_price.ToString() + "</td>");
                    sb.Append("<td class=\"op\" nowrap><a href=\"" + PageValue.WebRoot + "manage/ajax_manage.aspx?action=teamdetail&id=" + teaminfo.Id.ToString() + "\" class=\"ajaxlink\">详情</a>");
                 AS.Enum.TeamState ts = GetState(teaminfo);
                 if (ts == AS.Enum.TeamState.successnobuy || ts == AS.Enum.TeamState.successtimeover || ts == AS.Enum.TeamState.successbuy)
                    {
                        sb.Append("｜<a href=\"" + PageValue.WebRoot + "biz/down.aspx?id=" + teaminfo.Id.ToString() + "\">下载</a>");
                    }
                    if (teaminfo.Delivery.ToString().Trim() == "coupon")
                    {
                        CouponFilter coufilter = new CouponFilter();
                        coufilter.Partner_id = Helper.GetInt(strPartnerID, 0);
                        coufilter.Team_id = teaminfo.Id;
                        int count = 0;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            count = session.Coupon.SelectCount(coufilter);
                        }
                        sb.Append("<br><a href=\"" + PageValue.WebRoot + "biz/coupon.aspx?teamid=" + teaminfo.Id.ToString() + "\" >查看优惠券("+count+")</a>");
                    }
                    if (teaminfo.Delivery.ToString().Trim() == "pcoupon")
                    {
                        PcouponFilter pcoufilter = new PcouponFilter();
                        pcoufilter.partnerid = Helper.GetInt(strPartnerID, 0);
                        pcoufilter.teamid=teaminfo.Id;
                        int count1 = 0;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            count1 = session.Pcoupon.SelectCount(pcoufilter);
                        }
                        sb.Append("<br><a href=\"" + PageValue.WebRoot + "biz/pcoupon.aspx?teamid=" + teaminfo.Id.ToString() + "\" >查看站外券("+count1+")</a>");
                    }
                    sb.Append("</td>");

                    sb.Append("</tr>");
                    i++;
                }
            }
            else
            {
                sb.Append("<tr><td colspan=\"6\">暂无数据！</td></tr>");
            }

            ltTeam.Text = sb.ToString();
            pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        }

        private void initPage()
        {
            
            if (CookieUtils.GetCookieValue("partner",key) == null || CookieUtils.GetCookieValue("partner",key) == "")
            {
                Response.Redirect("login.aspx");
            }

            if (Request.Form["begin_time"] != null && Request.Form["begin_time"].ToString() != "")
            {
                orderfilter.FromPay_time =Convert.ToDateTime(Helper.GetDateTime(Request.Form["begin_time"], DateTime.Now).ToString("yyyy-MM-dd"));
               
            }
            if (Request.Form["endTime"] != null && Request.Form["endTime"].ToString() != "")
            {
                orderfilter.ToPay_time = Convert.ToDateTime(Helper.GetDateTime(Request.Form["endTime"], DateTime.Now).ToString("yyyy-MM-dd"));
               
            }
            if (Request.Form["teamId"] != null && Request.Form["teamId"].ToString() != "")
            {
                orderfilter.Team_id = Helper.GetInt(Request.Form["teamId"], 0);
            }
               
            else
            {
                SetError("项目ID不能为空,请填写项目ID");
                Response.Redirect("partner_index.aspx");
            }
            orderfilter.Partner_id = Helper.GetInt(strPartnerID, 0);
            ITeam mteam = Store.CreateTeam();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mteam = session.Teams.GetByID(Helper.GetInt(Request.Form["teamId"].ToString(), 0));
            }
           AS.Enum.TeamState ts = GetState(mteam);
            string downString = "";
            if (ts == AS.Enum.TeamState.successnobuy || ts == AS.Enum.TeamState.successtimeover || ts == AS.Enum.TeamState.successbuy)
            {
                if (mteam.Delivery == "coupon")
                {
                     downString = DownCoupon();
                }
                else if (mteam.Delivery == "pcoupon")
                {
                    downString = DownPCoupon();
                }
                else if (mteam.Delivery == "express")
                {
                    downString = DownKuaiDi();
                }
                Response.ClearHeaders();
                Response.Clear();
                Response.Expires = 0;
                Response.Buffer = true;
                Response.AddHeader("Accept-Language", "zh-tw");
                //文件名称
                Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("Order_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
                Response.ContentType = "Application/octet-stream";
                //文件内容
                Response.Write(downString);//-----------
                Response.End();
            }
            else
            {
                SetError("该项目不能下载！");
            }
        }
        /// <summary>
        /// 快递项目下载
        /// </summary>
        /// <returns></returns>
        private string DownKuaiDi()
        {
            StringBuilder sb1 = new StringBuilder();

            sb1.Append("<html>");
            sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
            sb1.Append("<body><table border=\'1\'>");
            sb1.Append("<tr>");
            sb1.Append("<td>ID</td>");
            sb1.Append("<td align='left'>订单号</td>");
            sb1.Append("<td>购买总数量</td>");
            sb1.Append("<td>付款状态</td>");
            sb1.Append("<td>收货人姓名</td>");
            sb1.Append("<td>联系电话</td>");
            sb1.Append("<td>送货地址</td>");
            sb1.Append("<td>邮编</td>");
            sb1.Append("<td>付款时间</td>");
            sb1.Append("<td>用户备注</td>");
            //sb1.Append("<td>产品规格</td>");
            sb1.Append("</tr>");
            IList<Hashtable> table = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                table = session.Orders.SelById2(orderfilter);
            }
            ITeam team = Store.CreateTeam();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                team = session.Teams.GetByID(Helper.GetInt(Request.Form["teamId"], 0));
            }
            if (table.Count > 0)
            {
                foreach (Hashtable ht in table)
                {
                    sb1.Append("<tr>");
                    sb1.Append("<td>" +Helper.GetString(ht["orderid"],string.Empty) + "</td>");
                    sb1.Append("<td>" + team.Product +Helper.GetString(ht["result"],string.Empty) + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["num"],string.Empty) + "</td>");
                    sb1.Append("<td>已支付</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["realname"],string.Empty) + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["mobile"],string.Empty) + "</td>");
                    sb1.Append("<td>" + Helper.GetString(ht["address"], string.Empty) + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["zipcode"],string.Empty) + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["pay_time"],string.Empty) + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["remark"],string.Empty) + "</td>");
                    //sb1.Append("<td>" + Maticsoft.BLL.Order.Getbulletin(dr["result"].ToString()) + "</td>");
                    sb1.Append("</tr>");
                }
            }

            sb1.Append("</table></body></html>");
            return sb1.ToString();
        }

        /// <summary>
        /// 站内券项目下载
        /// </summary>
        /// <returns></returns>
        private string DownCoupon()
         {
            StringBuilder sb1 = new StringBuilder();
            sb1.Append(title());
            IList<Hashtable> table = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                table = session.Orders.SelById1(orderfilter);
            }
            ITeam team = Store.CreateTeam();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                team = session.Teams.GetByID(Helper.GetInt(Request.Form["teamId"], 0));
            }
            if (table.Count > 0)
            {
                foreach(Hashtable ht in table)
                {
                    string total = null;
                    string xiaoFei = null;
                    string weiXiaofei = null;
                   
                    CouponFilter cfilter = new CouponFilter();
                    cfilter.Partner_id = Helper.GetInt(CookieUtils.GetCookieValue("partner",key), 0);
                    cfilter.Team_ids = Helper.GetInt(Request["id"], 0);
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        total = session.Coupon.SelById1(cfilter).ToString();
                        xiaoFei = session.Coupon.SelById2(cfilter).ToString();
                        weiXiaofei = session.Coupon.SelById3(cfilter).ToString();
                    }
                    
                    sb1.Append("<tr>");
                    sb1.Append("<td>" +Helper.GetString(ht["orderid"],string.Empty) + "</td>");
                    sb1.Append("<td>" + team.Product + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["num"],string.Empty) + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["mobile"],string.Empty) + "</td>");
                    sb1.Append("<td>" + total + "</td>");
                    sb1.Append("<td>" + xiaoFei + "</td>");
                    sb1.Append("<td>" + weiXiaofei + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["pay_time"],string.Empty)+ "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["End_time"],string.Empty) + "</td>");
                    sb1.Append("</tr>");
                }
            }

            sb1.Append("</table></body></html>");
            return sb1.ToString();
        }

        /// <summary>
        /// 站外券项目下载
        /// </summary>
        /// <returns></returns>
        private string DownPCoupon()
        {
            StringBuilder sb1 = new StringBuilder();
            sb1.Append(title());
            IList<Hashtable> table = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                table = session.Orders.SelById3(orderfilter);
            }
            ITeam team = Store.CreateTeam();
           
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                team = session.Teams.GetByID(Helper.GetInt(Request.Form["teamId"], 0));
            }
            if (table.Count > 0)
            {
                foreach (Hashtable ht in table)
                {
                    string total = null;
                    string xiaoFei = null;
                    string weiXiaofei = null;
                    PcouponFilter pfilter = new PcouponFilter();
                    pfilter.partnerid = Helper.GetInt(CookieUtils.GetCookieValue("partner",key), 0);
                    pfilter.teamid = Helper.GetInt(Request["id"], 0);
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        total = session.Pcoupon.SelById1(pfilter).ToString();
                        xiaoFei = session.Pcoupon.SelById2(pfilter).ToString();
                        weiXiaofei = session.Pcoupon.SelById3(pfilter).ToString();
                    }
                    
                    sb1.Append("<tr>");
                    sb1.Append("<td>" +Helper.GetString(ht["orderid"],string.Empty) + "</td>");
                    sb1.Append("<td>" + team.Product + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["num"],string.Empty) + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["mobile"],string.Empty) + "</td>");
                    sb1.Append("<td>" + total + "</td>");
                    sb1.Append("<td>" + xiaoFei + "</td>");
                    sb1.Append("<td>" + weiXiaofei + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["pay_time"],string.Empty) + "</td>");
                    sb1.Append("<td>" +Helper.GetString(ht["End_time"],string.Empty) + "</td>");
                    sb1.Append("</tr>");
                }
            }

            sb1.Append("</table></body></html>");
            return sb1.ToString();
        }

        /// <summary>
        /// 站内券和站外券共用的标题栏
        /// </summary>
        /// <returns></returns>
        public string title()
        {
            StringBuilder sb3 = new StringBuilder();
            sb3.Append("<html>");
            sb3.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
            sb3.Append("<body><table border=\'1\'>");
            sb3.Append("<tr>");
            sb3.Append("<td>ID</td>");
            sb3.Append("<td align='left'>订单号</td>");
            sb3.Append("<td>购买总数量</td>");
            sb3.Append("<td>联系电话</td>");
            sb3.Append("<td>优惠券总数量</td>");
            sb3.Append("<td>已消费数量</td>");
            sb3.Append("<td>未消费数量</td>");
            sb3.Append("<td>付款时间</td>");
            sb3.Append("<td>优惠券到期时间</td>");
            sb3.Append("</tr>");
            return sb3.ToString();
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
                                        项目列表</h2>
                                    <ul class="contact-filter">
                                        <li>开始时间:<input type="text" name="begin_time" class="h-input" group="a" datatype="date" onclick="WdatePicker();"/>
                                            结束时间:<input name="endTime" class="date" group="a" datatype="date" onclick="WdatePicker();"
                                                type="text" />
                                            项目ID：<input type="text" name="teamId" class="h-input" group="a" require="true" onkeyup="clearNoNum(this)"
                                                value="" />&nbsp;
                                            <input datatype="number" name="downtxt" class="formbutton" type="submit" group="a" value="下载" /></li></ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width="10%">
                                                项目ID
                                            </th>
                                            <th width="25%">
                                                项目名称
                                            </th>
                                            <th width="10%">
                                                城市
                                            </th>
                                            <th width="15%">
                                                日期
                                            </th>
                                            <th width="10%">
                                                成交
                                            </th>
                                            <th width="10%">
                                                团购价
                                            </th>
                                            <th width="20%">
                                                操作
                                            </th>
                                        </tr>
                                        <asp:Literal ID="ltTeam" runat="server"></asp:Literal>
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
<script type="text/javascript">
    function isNum() {
        if (event.keyCode < 48 || event.keyCode > 57) {
            event.keyCode = 0;
        }
    }
    function clearNoNum(obj) {
        obj.value = obj.value.replace(/[^\d.]/g, "");  //清除“数字”和“.”以外的字符 
        obj.value = obj.value.replace(/^\./g, "");  //验证第一个字符是数字而不是. 
        obj.value = obj.value.replace(/\.{2,}/g, "."); //只保留第一个. 清除多余的. 
        obj.value = obj.value.replace(".", "$#$").replace(/\./g, "").replace("$#$", ".");
    }
</script>