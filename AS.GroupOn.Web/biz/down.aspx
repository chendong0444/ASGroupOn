<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

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
    protected OrderFilter orderfilter = new OrderFilter();
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!Page.IsPostBack)
        {
            initPage();
        }
    }
    private void initPage()
    {
        if (CookieUtils.GetCookieValue("partner",key) == null || CookieUtils.GetCookieValue("partner",key) == "")
        {
            Response.Redirect(GetUrl("后台管理", "Login.aspx?type=merchant"));
            Response.End();
        }
       
        if (Request["id"] == null || Request["id"].ToString() == "")
        {
            Response.Redirect("partner_index.aspx");
            Response.End();
        }
        ITeam mteam = Store.CreateTeam();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            mteam = session.Teams.GetByID(Helper.GetInt(Request["id"], 0));
        }
        string downString = "";
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
        sb1.Append("</tr>");
        IList<Hashtable> table = null;
        orderfilter.Partner_id = Helper.GetInt(CookieUtils.GetCookieValue("partner",key), 0);
        orderfilter.Team_id = Helper.GetInt(Request["id"], 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            table = session.Orders.SelById2(orderfilter);
        }
        ITeam team = Store.CreateTeam();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            team = session.Teams.GetByID(Helper.GetInt(Request["id"], 0));
        }
        if (table.Count > 0)
        {
            foreach (Hashtable ht in table)
            {
                sb1.Append("<tr>");
                sb1.Append("<td>" + ht["orderid"].ToString() + "</td>");
                sb1.Append("<td>" + team.Product + ht["result"].ToString() + "</td>");
                sb1.Append("<td>" + ht["num"].ToString() + "</td>");
                sb1.Append("<td>已支付</td>");
                sb1.Append("<td>" + ht["realname"].ToString() + "</td>");
                sb1.Append("<td>" + ht["mobile"].ToString() + "</td>");
                sb1.Append("<td>" + ht["address"].ToString() + "</td>");
                sb1.Append("<td>" + ht["zipcode"].ToString() + "</td>");
                sb1.Append("<td>" + ht["pay_time"].ToString() + "</td>");
                sb1.Append("<td>" + ht["remark"].ToString() + "</td>");
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
        orderfilter.Partner_id = Helper.GetInt(CookieUtils.GetCookieValue("partner",key), 0);
        orderfilter.Team_id = Helper.GetInt(Request["id"], 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            table = session.Orders.SelById1(orderfilter);
        }
        ITeam team = Store.CreateTeam();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            team = session.Teams.GetByID(Helper.GetInt(Request["id"], 0));
        }
        if (table.Count > 0)
        {
            foreach (Hashtable ht in table)
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
                sb1.Append("<td>" + ht["orderid"].ToString() + "</td>");
                sb1.Append("<td>" + team.Product + "</td>");
                sb1.Append("<td>" + ht["num"].ToString() + "</td>");
                sb1.Append("<td>" + ht["mobile"].ToString() + "</td>");
                sb1.Append("<td>" + total + "</td>");
                sb1.Append("<td>" + xiaoFei + "</td>");
                sb1.Append("<td>" + weiXiaofei + "</td>");
                sb1.Append("<td>" + ht["pay_time"].ToString() + "</td>");
                sb1.Append("<td>" + ht["End_time"].ToString() + "</td>");
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
        orderfilter.Partner_id = Helper.GetInt(CookieUtils.GetCookieValue("partner",key), 0);
        orderfilter.Team_id = Helper.GetInt(Request["id"], 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            table = session.Orders.SelById3(orderfilter);
        }
        ITeam team = Store.CreateTeam();

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            team = session.Teams.GetByID(Helper.GetInt(Request["id"], 0));
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
                sb1.Append("<td>" + ht["orderid"].ToString() + "</td>");
                sb1.Append("<td>" + team.Product + "</td>");
                sb1.Append("<td>" + ht["num"].ToString() + "</td>");
                sb1.Append("<td>" + ht["mobile"].ToString() + "</td>");
                sb1.Append("<td>" + total + "</td>");
                sb1.Append("<td>" + xiaoFei + "</td>");
                sb1.Append("<td>" + weiXiaofei + "</td>");
                sb1.Append("<td>" + ht["pay_time"].ToString() + "</td>");
                sb1.Append("<td>" + ht["End_time"].ToString() + "</td>");
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
