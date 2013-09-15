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
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<style type="text/css">
    .if_box
    {
        border-top: 1px solid #DDEEFF;
        overflow: hidden;
        padding: 20px 10px 50px;
        width: 650px;
        text-align:left;
        font-size:12px;
        font-family:’微软雅黑‘；
        
    }
   
    .bda
    {
        float: left;
        margin: 0;
        padding: 0;
        width: 650px;
    }
   
    td,th{
	font-size: 12px;
	line-height: 18px;
	padding: 10px;
	
	
}
.paginator { display: inline-block;*display:inline;_display:inline;margin: 0 auto;overflow: hidden;*zoom:1; _zoom:1; float:right;}
.paginator li{ float:left; line-height:32px; margin:5px 0; list-style-type:none;}
.paginator  A {TEXT-DECORATION: none;  border: 1px solid #E5E5E5;color: #3E71B9;float: left;height: 32px;line-height: 32px;margin-left: 4px; padding:0 10px;}
.paginator a.page-cur {color: #5F5F5F;font-weight: bold;}
.paginator A:hover { background: none repeat scroll 0 0 #3E71B9; border: 1px solid #3E71B9;color: #FFFFFF;}
.paginator A.nolink {COLOR: #ccc; CURSOR: default}
.paginator A.nolink:hover {BORDER: #ccc 1px solid;LINE-HEIGHT: 22px; BACKGROUND: none; HEIGHT: 22px;padding:0 6px;}

</style>
<script runat="server">
   
    protected string beginTime = "";
    protected string lasttime = "";
    protected string pagerHtml = String.Empty;
    public string title = "所有";

    protected string strTeamid = "";

    public int j = 0;
    protected IList<Hashtable> hashtable = null;
    protected string userid = string.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);


        getDingdan();
    }

    #region 视图

    public string sqlWhere
    {
        get
        {
            if (this.ViewState["sqlWhere"] != null)
                return this.ViewState["sqlWhere"].ToString();
            else
            {

                return setSqlWhere();
            }
        }
        set
        {
            this.ViewState["sqlWhere"] = value;
        }
    }
    #endregion
    /// <summary>
    /// 拼接SQL语句
    /// </summary>
    public string setSqlWhere()
    {



        userid = Request["Id"].ToString();

        string sql = String.Empty;
        if (sql != String.Empty)
            sqlWhere = sql.Substring(4);

        if (userid != "")
        {
            sql = sql + " and user_id=" + userid;
        }


        sqlWhere = " 1=1 " + sql;
        return sqlWhere;
    }



    private void xiazai()
    {
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();


        sb1.Append("<tr class='alt' >");
        sb1.Append("<th>ID</th>");
        sb1.Append("<th width='50%' >项目</th>");
        sb1.Append("<th>用户</th>");
        sb1.Append("<th >数量</th>");
        sb1.Append("<th>总款</th>");
        sb1.Append("<th >支付方式</th>");
        sb1.Append("<th >余付</th>");
        sb1.Append("<th >支付</th>");
        sb1.Append("<th>递送</th>");
        sb1.Append("</tr>");
        IList<IOrder> ilistorder = null;
        OrderFilter orfilter = new OrderFilter();
        IPagers<IOrder> pages = null;
        orfilter.table = " (SELECT  orderdetail.Num, orderdetail.Teamid, orderdetail.Teamprice, Team.Title, Team_1.Title AS team_title, [Order].*, [User].Email,[User].Username FROM Team RIGHT OUTER JOIN [Order] LEFT OUTER JOIN [User] ON [Order].User_id = [User].Id ON Team.Id = [Order].Team_id LEFT OUTER JOIN Team AS Team_1 INNER JOIN orderdetail ON Team_1.Id = orderdetail.Teamid ON [Order].Id = orderdetail.Order_id) ttt1 where " + sqlWhere;
        orfilter.PageSize = 4;
        orfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        orfilter.AddSortOrder(OrderFilter.ID_DESC + "," + OrderFilter.Payid_DESC);

        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pages = session.Orders.GetBranchPage(orfilter);
        }
        ilistorder = pages.Objects;
        if (ilistorder.Count > 0)
        {
            int orderId = 0;
            int count = 0;
            foreach (IOrder dr in ilistorder)
            {
                if (Convert.ToInt32(dr.Id.ToString()) != orderId)
                {
                    if (count % 2 != 0)
                    {
                        sb2.Append("<tr>");
                    }
                    else
                    {
                        sb2.Append("<tr style='background:#f1f1f1;' >");
                    }
                    sb2.Append("<td>" + dr.Id + "</td>");
                    orderId = Convert.ToInt32(dr.Id.ToString());
                    ITeam item1 = Store.CreateTeam();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        item1 = session.Teams.GetByID(Helper.GetInt(dr.Team_id, 0));
                    }
                    if (item1 != null)
                    {


                        sb2.Append("<td>" + item1.Id + "&nbsp;(" + item1.Title + "<font style='color:red'>" + Getbulletin(dr.result.ToString(), 0) + "</font>" + ")</td>");
                    }
                    else
                    {
                        IList<IOrderDetail> detaillist = null;
                        OrderDetailFilter ordetail = new OrderDetailFilter();
                        ordetail.Order_ID = Helper.GetInt(dr.Id, 0);
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            detaillist = session.OrderDetail.GetList(ordetail);
                        }

                        sb2.Append("<td >&nbsp;");
                        int num = 0;
                        foreach (IOrderDetail model in detaillist)
                        {
                            num++;
                            sb2.Append("(" + num + ":");
                            ITeam teammodel = Store.CreateTeam();
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                teammodel = session.Teams.GetByID(model.Teamid);
                            }
                            sb2.Append(teammodel == null ? "" : teammodel.Title + "<font style='color:red'>" + Getbulletin(model.result) + "</font>" + "<font style='color:red'>(" + model.Num + "件)</font>");
                            sb2.Append(")<br>");
                        }
                        sb2.Append("</td>");
                    }
                    IList<IUser> user = null;
                    UserFilter ufilter = new UserFilter();
                    ufilter.ID = Helper.GetInt(dr.User_id, 0);
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        user = session.Users.GetList(ufilter);
                    }
                    if (user.Count <= 0)
                    {
                        sb2.Append("<td>&nbsp;</td>");
                    }
                    else
                    {
                        foreach (IUser item2 in user)
                        {
                            sb2.Append("<td>" + item2.Email + "/" + item2.Username + "</td>");

                        }
                    }
                    sb2.Append("<td>" + dr.Quantity + "</td>");
                    sb2.Append("<td><span class='money'>¥</span>" + dr.Origin + "</td>");
                    if (dr.Service == "yeepay")
                    {
                        sb2.Append("<td><span class='money'>&nbsp;</span>易宝</td>");
                    }
                    else if (dr.Service == "alipay")
                    {
                        sb2.Append("<td><span class='money'>&nbsp;</span>支付宝</td>");
                    }
                    else if (dr.Service == "tenpay")
                    {
                        sb2.Append("<td><span class='money'>&nbsp;</span>财富通</td>");
                    }
                    else if (dr.Service == "chinabank")
                    {
                        sb2.Append("<td><span class='money'>&nbsp;</span>网银</td>");
                    }
                    else if (dr.Service == "credit")
                    {
                        sb2.Append("<td><span class='money'>&nbsp;</span>余额</td>");
                    }
                    else if (dr.Service == "cash")
                    {
                        sb2.Append("<td><span class='money'>&nbsp;</span>线下</td>");
                    }
                    else
                    {
                        sb2.Append("<td><span class='money'>&nbsp;</span>未支付</td>");
                    }

                    sb2.Append("<td><span class='money'>¥</span>" + dr.Credit + "</td>");
                    sb2.Append("<td><span class='money'>¥</span>" + dr.Money + "</td>");
                    if (dr.Express == "N")
                    {
                        sb2.Append("<td>优惠券</td>");

                    }
                    else if (Helper.GetInt(dr.Express_id, 0) != 0)
                    {
                        if (Helper.GetInt(dr.Express_id, 0) != 0)
                        {
                            ICategory mExpress = Store.CreateCategory();
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                mExpress = session.Category.GetByID(Helper.GetInt(dr.Express_id, 0));
                            }
                            if (mExpress != null)
                            {
                                sb2.Append("<td>" + mExpress.Name + "<br>");
                                sb2.Append("</td>");
                            }
                            else
                            {
                                sb2.Append("<td></td>");
                            }
                        }
                        else
                        {
                            sb2.Append("<td>快递</td>");
                        }
                    }
                    else
                    {
                        sb2.Append("<td></td>");
                    }


                    sb2.Append("</tr>");
                    count++;

                }

            }
        }
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(4, pages.TotalRecords, pages.CurrentPage, PageValue.WebRoot + "manage/ajaxpage/showorder.aspx?&Id=" + userid + "&page={0}");

    }


    private void getDingdan()
    {
        xiazai();
    }
    public string Getbulletin(string bulletin, int showhtml = 0)
    {
        string str = "";
        if (bulletin != "")
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
<body class="newbie">
    <form id="form1" runat="server">
    <div class="if_box">
        <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
            <asp:Literal ID="Literal1" runat="server"></asp:Literal>
            <asp:Literal ID="Literal2" runat="server"></asp:Literal>
            <tr>
                <td colspan="9">
                    <%=pagerHtml %>
                </td>
            </tr>
        </table>
    </div>
    <!-- bd end -->
    <!-- bdw end -->
    </form>
</body>
