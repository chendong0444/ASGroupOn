<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.SalePage" %>

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
<%@ Import Namespace="System.IO" %>
<script runat="server">
    public string cata = "";
    int strSaleId = 0;
    protected System.Data.DataTable datable = null;
    protected List<Hashtable> hashtable = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        strSaleId = Helper.GetInt(CookieUtils.GetCookieValue("sale", key).ToString(), 0);

        if (!Page.IsPostBack)
        {
            beginTime.Value = DateTime.Now.ToShortDateString();
            endTime.Value = DateTime.Now.ToShortDateString();
            ViewState["SortOrder"] = "项目";
            ViewState["OrderDire"] = "ASC";
            initCityDrop();
            cataloglist();
            initPage();
        }
    }

    #region 显示目录信息
    public void cataloglist()
    {
        ddlparent.Items.Clear();
        ddlparent.Items.Add(new ListItem("请选择分类...", "0"));
        IList<ICatalogs> list_catelog = null;
        CatalogsFilter filter = new CatalogsFilter();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            list_catelog = session.Catalogs.GetList(filter);
        }
        System.Data.DataTable dt = Helper.ToDataTable(list_catelog.ToList());
        BindData(dt, 0, "");
        ddlparent.DataBind();
    }
    #endregion

    private void BindData(DataTable dt, int id, string blank)
    {
        if (dt!=null&&dt.Rows.Count>0)
        {
            DataView dv = new DataView(dt);
            dv.RowFilter = "parent_id = " + id.ToString();
            if (id != 0)
            {
                blank += "|─";
            }

            foreach (DataRowView drv in dv)
            {
                ddlparent.Items.Add(new ListItem(blank + drv["catalogname"].ToString(), drv["id"].ToString()));

                BindData(dt, Convert.ToInt32(drv["id"]), blank);
            } 
        }
    }

    private void initCityDrop()
    {
        ddlcity.Items.Add(new ListItem("--------", "0"));
        CategoryFilter fileter = new CategoryFilter();
        fileter.Zone = "city";
        IList<ICategory> list_cate = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            list_cate = session.Category.GetList(fileter);
        }
        foreach (var city in list_cate)
        {
            ddlcity.Items.Add(new ListItem(city.Name, city.Id.ToString()));
        }


        ddlcity.DataBind();
    }


    private void initPage()
    {
        string strCity = Request.Form["checkCity"];
        string strPay_time = drPayTime.SelectedValue;

        DataTable table = null;
        if (ViewState["table"] == null)
        {
            string strSql = "";
            string strGroup = "";
            if (strCity != null && strCity != "")
            {
                if (strCity == "on")
                {
                    strSql = strSql + ",t.city_id as '城市' ";
                    strGroup = strGroup + ",t.city_id";
                }
            }

            if (strPay_time != null && strPay_time != "")
            {
                if (strPay_time == "year")
                {
                    strSql = strSql + ", year(pay_time) as '支付年' ";
                    strGroup = strGroup + ",year(pay_time)";
                }
                if (strPay_time == "month")
                {
                    strSql = strSql + ", year(pay_time) as '支付年' ";
                    strGroup = strGroup + ",year(pay_time)";
                    strSql = strSql + ", month(pay_time) as '支付月' ";
                    strGroup = strGroup + ",month(pay_time)";
                }

                if (strPay_time == "day")
                {
                    strSql = strSql + ", year(pay_time) as '支付年' ";
                    strGroup = strGroup + ",year(pay_time)";
                    strSql = strSql + ", month(pay_time) as '支付月' ";
                    strGroup = strGroup + ",month(pay_time)";
                    strSql = strSql + ", day(pay_time) as '支付日' ";
                    strGroup = strGroup + ",day(pay_time)";
                }
            }

            strSql = strSql + ",teamid as [项目ID],product as [项目名称],sum(num) as [购买数量],sum(num*Team_price) as [项目收款],t.fare as [快递费] ";
            strGroup = strGroup + ",teamid,product,Team_price,t.fare";
            strSql = strSql.Substring(1);
            strSql = "select " + strSql + " from(";
            strSql = strSql + "select ISNULL(Teamid,Team_id) as teamid,ISNULL(num,quantity) as num,Fare,pay_time,orderdetail.result as result,City_id,Express from [Order] left join orderdetail on([Order].Id=[orderdetail].Order_id) where state='pay' ";
            strSql = strSql + " and pay_time>='" + Helper.GetDateTime(beginTime.Value, DateTime.Now).ToString("yyyy-MM-dd 00:00:00") + "' and pay_time <='" + Helper.GetDateTime(endTime.Value, DateTime.Now).ToString("yyyy-MM-dd 23:59:59") + "'";
            if (ddlExpress.SelectedIndex > 0)
                strSql = strSql + " and Express ='" + ddlExpress.SelectedValue + "' ";
            if (ddlcity.SelectedIndex > 0)
                strSql = strSql + " and city_id ='" + ddlcity.SelectedValue + "' ";
            if (teamid.Value.Length > 0)
                strSql = strSql + " and (Team_id=" + Helper.GetInt(teamid.Value, 0) + " or Teamid=" + Helper.GetInt(teamid.Value, 0) + ")";
            strSql = strSql + ")t inner join Team on(Team.Id=t.teamid) where 1=1 ";
            if (ddlparent.SelectedIndex > 0)
            {
                ICatalogs logs = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    logs = session.Catalogs.GetByID(int.Parse(ddlparent.SelectedValue));
                }
                if (logs != null)
                {
                    string ids =Helper.GetString(logs.id,string.Empty);
                    if (logs.ids.Length > 0) ids = ids + "," + logs.ids;
                    strSql = strSql + "and (cataid in(" + ids + "))";
                }
            }

            strSql = strSql + "and team.sale_id=" + strSaleId + " group by " + strGroup.Substring(1);
            /***************************************************/
            //              提示统计信息开始
            /***************************************************/
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                hashtable = session.GetData.GetDataList(strSql);
            }
            ViewState["table"] = table;
            table = AS.Common.Utils.Helper.ConvertDataTable(hashtable);
            decimal[] prices = new decimal[] { 0, 0, 0 };//快递费，购买数量,项目收款
            for (int i = 0; i < table.Rows.Count; i++)
            {
                DataRow row = table.Rows[i];
                prices[0] = prices[0] + Convert.ToDecimal(row["快递费"]);
                prices[1] = prices[1] + Convert.ToInt32(row["购买数量"]);
                prices[2] = prices[2] + Helper.GetDecimal(row["项目收款"], 0);
                int aa = Helper.GetInt(row["项目收款"], 0);
            }
            msg.Text = "【 提示信息 】： 快递费：" + prices[0] + "; 购买数量：" + prices[1] + "; 项目收款: " + prices[2];
        }
        else
        {
            table = (DataTable)ViewState["table"];
        }
        GridView1.DataSource = table;
        GridView1.DataBind();
    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        ViewState.Remove("table");
        initPage();
    }

    protected void btnDown_Click(object sender, EventArgs e)
    {
        string strCity = Request.Form["checkCity"];
        string strPay_time = drPayTime.SelectedValue;
        string strSql = "";
        string strGroup = "";
        if (strCity != null && strCity != "")
        {
            if (strCity == "on")
            {
                strSql = strSql + ",t.city_id as '城市' ";
                strGroup = strGroup + ",t.city_id";
            }
        }
        if (strPay_time != null && strPay_time != "")
        {
            if (strPay_time == "year")
            {
                strSql = strSql + ", year(pay_time) as '支付年' ";
                strGroup = strGroup + ",year(pay_time)";
            }
            if (strPay_time == "month")
            {
                strSql = strSql + ", year(pay_time) as '支付年' ";
                strGroup = strGroup + ",year(pay_time)";
                strSql = strSql + ", month(pay_time) as '支付月' ";
                strGroup = strGroup + ",month(pay_time)";
            }

            if (strPay_time == "day")
            {
                strSql = strSql + ", year(pay_time) as '支付年' ";
                strGroup = strGroup + ",year(pay_time)";
                strSql = strSql + ", month(pay_time) as '支付月' ";
                strGroup = strGroup + ",month(pay_time)";
                strSql = strSql + ", day(pay_time) as '支付日' ";
                strGroup = strGroup + ",day(pay_time)";
            }
        }

        strSql = strSql + ",teamid as [项目ID],product as [项目名称],sum(num) as [购买数量],sum(num*Team_price) as [项目收款],t.fare as [快递费] ";
        strGroup = strGroup + ",teamid,product,Team_price,t.fare";
        strSql = strSql.Substring(1);
        strSql = "select " + strSql + " from(";
        strSql = strSql + "select ISNULL(Teamid,Team_id) as teamid,ISNULL(num,quantity) as num,Fare,pay_time,orderdetail.result as result,City_id,Express from [Order] left join orderdetail on([Order].Id=[orderdetail].Order_id) where state='pay' ";
        strSql = strSql + " and pay_time>='" + Helper.GetDateTime(beginTime.Value, DateTime.Now).ToString("yyyy-MM-dd 00:00:00") + "' and pay_time <='" + Helper.GetDateTime(endTime.Value, DateTime.Now).ToString("yyyy-MM-dd 23:59:59") + "'";

        if (teamid.Value.Length > 0)
            strSql = strSql + " and (Team_id=" + Helper.GetInt(teamid.Value, 0) + " or Teamid=" + Helper.GetInt(teamid.Value, 0) + ")";
        strSql = strSql + ")t inner join Team on(Team.Id=t.teamid) where 1=1 ";
        if (ddlExpress.SelectedIndex > 0)
            strSql = strSql + " and Express ='" + ddlExpress.SelectedValue + "' ";
        if (ddlparent.SelectedIndex > 0)
        {
            strSql = strSql + "and (catalogid in(" + ddlparent.SelectedValue + "))";
        }

        strSql = strSql + "and team.sale_id=" + strSaleId + " group by " + strGroup.Substring(1);
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            hashtable = session.GetData.GetDataList(strSql);
        }
        datable = AS.Common.Utils.Helper.ConvertDataTable(hashtable);
        downshuju(datable);
    }


    /// <summary>
    /// 下载数据
    /// </summary>
    /// <param name="ds">数据集</param>
    private void downshuju(DataTable datable)
    {
        StringBuilder sb1 = new StringBuilder();
        if (datable == null)
        {
            SetError("-ERR ERR_NO_DATA");
            Response.Redirect("Tongji_ASdht_Team.aspx");
            return;
        }
        else
        {
            sb1.Append("<html>");
            sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
            sb1.Append("<body><table border=\'1\'>");
            sb1.Append("<tr>");
            sb1.Append("<td>ID</td>");
            if (datable.Columns["项目ID"] != null)
            {
                sb1.Append("<td align='left'>项目ID</td>");
            }
            if (datable.Columns["项目名称"] != null)
            {
                sb1.Append("<td align='left'>项目名称</td>");
            }
            if (datable.Columns["付款方式"] != null)
            {
                sb1.Append("<td align='left'>付款方式</td>");
            }

            if (datable.Columns["城市"] != null)
            {
                sb1.Append("<td align='left'>城市</td>");
            }
            if (datable.Columns["支付年"] != null)
            {
                sb1.Append("<td align='left'>支付年</td>");
            }
            if (datable.Columns["支付月"] != null)
            {
                sb1.Append("<td align='left'>支付月</td>");
            }
            if (datable.Columns["支付日"] != null)
            {
                sb1.Append("<td align='left'>支付日</td>");
            }
            if (datable.Columns["项目收款"] != null)
            {
                sb1.Append("<td align='left'>项目收款</td>");
            }
            if (datable.Columns["购买数量"] != null)
            {
                sb1.Append("<td align='left'>购买数量</td>");
            }

            if (datable.Columns["快递费"] != null)
            {
                sb1.Append("<td align='left'>快递费</td>");
            }
            sb1.Append("</tr>");

            //处理性别结束

            for (int i = 0; i < datable.Rows.Count; i++)
            {
                sb1.Append("<tr>");
                sb1.Append("<td>" + (i + 1).ToString() + "</td>");
                sb1.Append("<td>" + datable.Rows[i]["项目ID"].ToString() + "</td>");
                sb1.Append("<td>" + datable.Rows[i]["项目名称"].ToString() + "</td>");
                if (datable.Columns["付款方式"] != null)
                {
                    string strTrue = "";
                    string value = datable.Rows[i]["付款方式"].ToString();
                    switch (value)
                    {
                        case "yeepay":
                            strTrue = "易宝";
                            break;
                        case "credit":
                            strTrue = "余额付款";
                            break;
                        case "alipay":
                            strTrue = "支付宝";
                            break;
                        case "tenpay":
                            strTrue = "财付通";
                            break;
                        case "chinabank":
                            strTrue = "网银在线";
                            break;
                        case "chinamobilepay":
                            strTrue = "移动支付";
                            break;
                        case "cash":
                            strTrue = "线下支付";
                            break;
                        default:
                            strTrue = "未选择";
                            break;

                    }

                    sb1.Append("<td align='left'>" + strTrue + "</td>");

                }

                if (datable.Columns["递送方式"] != null)
                {

                    string value = datable.Rows[i]["递送方式"].ToString();
                    switch (value)
                    {
                        case "Y":
                            sb1.Append("<td align='left'>快递</td>");

                            break;
                        case "N":
                            sb1.Append("<td align='left'>优惠券</td>");

                            break;

                        case "D":
                            sb1.Append("<td align='left'>抽奖</td>");

                            break;
                        case "P":
                            sb1.Append("<td align='left'>站外券</td>");

                            break;

                    }
                }

                if (datable.Columns["城市"] != null)
                {

                    string strTrue = "";
                    string value = datable.Rows[i]["城市"].ToString();
                    if (value == "0")
                    {
                        strTrue = "全部城市";
                    }
                    ICategory cate = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        cate = session.Category.GetByID(Helper.GetInt(value, 0));
                    }
                    if (cate != null)
                    {
                        strTrue = cate.Name;
                    }
                    sb1.Append("<td align='left'>" + strTrue + " </td>");

                }
                if (datable.Columns["支付年"] != null)
                {
                    sb1.Append("<td align='left'>" + datable.Rows[i]["支付年"] + "</td>");
                }
                if (datable.Columns["支付月"] != null)
                {
                    sb1.Append("<td align='left'>" + datable.Rows[i]["支付月"] + "</td>");
                }
                if (datable.Columns["支付日"] != null)
                {
                    sb1.Append("<td align='left'>" + datable.Rows[i]["支付日"] + "</td>");
                }
                if (datable.Columns["项目收款"] != null)
                {
                    sb1.Append("<td align='left'>" + datable.Rows[i]["项目收款"] + "</td>");
                }

                if (datable.Columns["购买数量"] != null)
                {
                    sb1.Append("<td align='left'>" + datable.Rows[i]["购买数量"] + "</td>");
                }
                if (datable.Columns["快递费"] != null)
                {
                    sb1.Append("<td align='left'>" + datable.Rows[i]["快递费"] + "</td>");
                }

                sb1.Append("</tr>");
            }
            sb1.Append("</table></body></html>");
            Response.ClearHeaders();
            Response.Clear();
            Response.Expires = 0;
            Response.Buffer = true;
            Response.AddHeader("Accept-Language", "zh-tw");
            //文件名称
            Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("tongji_team_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
            Response.ContentType = "Application/octet-stream";
        }
        //文件内容
        Response.Write(sb1.ToString());//-----------
        Response.End();
    }

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView dr = (DataRowView)e.Row.DataItem;
            if (dr.Row.Table.Columns["付款方式"] != null)
            {

                string value = dr["付款方式"].ToString();
                switch (value)
                {
                    case "yeepay":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "易宝";
                        break;
                    case "credit":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "余额付款";
                        break;
                    case "alipay":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "支付宝";
                        break;
                    case "tenpay":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "财付通";
                        break;
                    case "chinamobilepay":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "移动支付";
                        break;
                    case "chinabank":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "网银在线";
                        break;
                    case "cash":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "线下支付";
                        break;
                    default:
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "未选择";
                        break;

                }
            }

            if (dr.Row.Table.Columns["递送方式"] != null)
            {

                string value = dr["递送方式"].ToString();
                switch (value)
                {
                    case "Y":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("递送方式")].Text = "快递";
                        break;
                    case "N":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("递送方式")].Text = "优惠券";
                        break;

                    case "D":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("递送方式")].Text = "抽奖";
                        break;
                    case "P":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("递送方式")].Text = "站外券";
                        break;

                }
            }

            if (dr.Row.Table.Columns["城市"] != null)
            {
                string value = dr["城市"].ToString();
                if (value == "0")
                {
                    e.Row.Cells[dr.Row.Table.Columns.IndexOf("城市")].Text = "全部城市";
                }
                ICategory cate = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    cate = session.Category.GetByID(Helper.GetInt(value, 0));
                }

                if (cate != null)
                {
                    e.Row.Cells[dr.Row.Table.Columns.IndexOf("城市")].Text = cate.Name;
                }

            }

            if (dr.Row.Table.Columns["项目"] != null)
            {
                string value = dr["项目"].ToString();
                ITeam team = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    team = session.Teams.GetByID(Helper.GetInt(dr["项目"].ToString(), 0));
                }

                if (team != null)
                {
                    string strTile = Helper.NoHTML(team.Title);
                    if (strTile.Length > 40)
                    {
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("项目")].Text = "【项目" + dr["项目"].ToString() + "】:" + strTile.Substring(0, 40) + "...";
                    }
                    else
                    {
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("项目")].Text = "【项目" + dr["项目"].ToString() + "】:" + strTile;
                    }
                }
                else
                {
                    e.Row.Cells[dr.Row.Table.Columns.IndexOf("项目")].Text = "【项目" + dr["项目"].ToString() + "】：不存在";
                }
            }

            if (dr.Row.Table.Columns["支付年"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("支付年")].Text = dr["支付年"].ToString() + "年";
            }
            if (dr.Row.Table.Columns["支付月"] != null)
            {
                string month = dr["支付月"].ToString();
                if (month.Length == 1)
                {
                    month = "0" + month;
                }
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("支付月")].Text = month + "月";
            }
            if (dr.Row.Table.Columns["支付日"] != null)
            {
                string day = dr["支付日"].ToString();
                if (day.Length == 1)
                {
                    day = "0" + day;
                }
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("支付日")].Text = day + "日";
            }

            if (dr.Row.Table.Columns["购买数量"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("购买数量")].Text = dr["购买数量"].ToString() + "个";
            }
            if (dr.Row.Table.Columns["订单数量"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("订单数量")].Text = dr["订单数量"].ToString() + "个";
            }
            if (dr.Row.Table.Columns["快递费"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("快递费")].Text = dr["快递费"].ToString() + "元";
            }
        }
    }

    protected void GridView1_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        this.GridView1.PageIndex = e.NewPageIndex;

        initPage();
    }

    protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
    {
        DataTable table = (DataTable)ViewState["table"];
        if (table != null)
        {
            ViewState["sortfield"] = e.SortExpression;
            if (ViewState["sortdirection"] != null)
            {
                if (ViewState["sortdirection"].ToString() == "asc")
                    ViewState["sortdirection"] = "desc";
                else
                    ViewState["sortdirection"] = "asc";
            }
            else
                ViewState["sortdirection"] = "desc";

            if (ViewState["sortfield"] != null && ViewState["sortdirection"] != null)
            {
                table.DefaultView.Sort = ViewState["sortfield"].ToString() + " " + ViewState["sortdirection"].ToString();

            }
            ViewState["table"] = table.DefaultView.ToTable();
        }

        initPage();
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <script language="javascript" type="text/javascript">
        jQuery(function () {

            $("#checkDay").click(function () {

                if ($("#checkDay").val() == "on") {

                    $("#checkYear").removeAttr("checked").attr("checked", true);
                    $("#checkMonth").removeAttr("checked").attr("checked", true);

                }
                else {
                    $("#checkYear").removeAttr("checked").attr("checked", false);
                    $("#checkMonth").removeAttr("checked").attr("checked", false);
                }
            });

            $("#checkMonth").click(function () {
                if ($("#checkMonth").val() == "on") {

                    $("#checkYear").removeAttr("checked").attr("checked", true);

                }
                else {
                    $("#checkYear").removeAttr("checked").attr("checked", false);

                }
            });
        });
    </script>
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
                                        项目统计</h2>
                                    <br />
                                    <div class="lie_fl">
                                        筛选条件：项目编号：<input id="teamid" class="h-input" type="text" runat="server" />
                                        &nbsp;付款日期：<input id="beginTime" class="h-input" type="text" runat="server" onclick="WdatePicker();"/>—&nbsp;&nbsp;&nbsp;<input
                                           class="h-input" id="endTime" type="text" runat="server" onclick="WdatePicker();" />
                                    </div>
                                    <div class="lie_fl">
                                        筛选条件： &nbsp; 城市：<asp:DropDownList ID="ddlcity" runat="server">
                                        </asp:DropDownList>
                                        &nbsp; 递送方式：<asp:DropDownList ID="ddlExpress" runat="server">
                                            <asp:ListItem Text="--------" Value=""></asp:ListItem>
                                            <asp:ListItem Text="快递" Value="Y"></asp:ListItem>
                                            <asp:ListItem Text="站内券" Value="N"></asp:ListItem>
                                            <asp:ListItem Text="站外券" Value="P"></asp:ListItem>
                                            <asp:ListItem Text="抽奖" Value="D"></asp:ListItem>
                                        </asp:DropDownList>
                                        &nbsp; 项目分类:
                                        <asp:DropDownList ID="ddlparent" runat="server">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="lie_fl">
                                        统计依据：<asp:CheckBox ID="checkCity" runat="server" Text="城市ID" />&nbsp; 付款时间:<asp:DropDownList
                                            ID="drPayTime" runat="server">
                                            <asp:ListItem Text="-----" Value=""></asp:ListItem>
                                            <asp:ListItem Text="年" Value="year"></asp:ListItem>
                                            <asp:ListItem Text="月" Value="month"></asp:ListItem>
                                            <asp:ListItem Text="日" Value="day"></asp:ListItem>
                                        </asp:DropDownList>
                                        &nbsp;
                                        <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" class="formbutton"
                                            Text="统计" />
                                        &nbsp;
                                        <asp:Button ID="btnDown" runat="server" class="formbutton" Text="下载" OnClick="btnDown_Click" />
                                    </div>
                                    <div class="lie_fl">
                                        <br />
                                        <asp:Label ForeColor="Green" ID="msg" runat="server"></asp:Label></div>
                                </div>
                                <div class="sect">
                                    <div>
                                        <asp:GridView ID="GridView1" runat="server" AllowPaging="True" EnableModelValidation="True"
                                            OnPageIndexChanging="GridView1_PageIndexChanging" PageSize="30" AllowSorting="True"
                                            Height="30px" OnSorting="GridView1_Sorting" Width="100%" OnRowDataBound="GridView1_RowDataBound">
                                            <AlternatingRowStyle Width="100px" BackColor="White" BorderStyle="None" />
                                            <HeaderStyle Font-Bold="True" ForeColor="Black" Height="30px" />
                                            <PagerSettings FirstPageText="首页&amp;nbsp;&amp;nbsp;" LastPageText="尾页&amp;nbsp;&amp;nbsp;"
                                                NextPageText="下一页&amp;nbsp;&amp;nbsp;" PreviousPageText="上一页&amp;nbsp;&amp;nbsp;"
                                                Mode="NextPreviousFirstLast" />
                                            <PagerStyle Height="25px" HorizontalAlign="Right" Width="100%" ForeColor="Black" />
                                            <RowStyle Width="100px" Height="30px" />
                                        </asp:GridView>
                                        <asp:SqlDataSource ID="SqlDataSource1" runat="server"></asp:SqlDataSource>
                                    </div>
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
