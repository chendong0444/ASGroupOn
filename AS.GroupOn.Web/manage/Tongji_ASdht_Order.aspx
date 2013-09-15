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
<script runat="server">
    protected List<Hashtable> hashtable = null;
    protected List<Hashtable> hashtablepage = null;
    protected List<Hashtable> hashtableDown = null;
    protected System.Data.DataTable datatable = null;
    protected System.Data.DataTable datatablepage = null;
    protected System.Data.DataTable datatableDown = null;
    StringBuilder sb1 = new StringBuilder();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TJ_UserOrder))
        {
            SetError("你不具有查看用户订单统计的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (!Page.IsPostBack)
        {
            beginTime.Value = DateTime.Now.ToShortDateString();
            endTime.Value = DateTime.Now.ToShortDateString();
            ViewState["SortOrder"] = " 在线支付费用 ";
            ViewState["OrderDire"] = "ASC";
            initCityDrop();

            initPage();
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
        string strFromDomain = Request.Form["checkFromdomain"];
        string strService = Request.Form["checkService"];
        string strExpress = Request.Form["checkExpress"];
        string strPay_time = drPayTime.SelectedValue;
        string strCreate_time = drCreateTime.SelectedValue;
        string strExpress_id = drExpress_id.SelectedValue;
        string strSeviceWhere = drSeviceWhere.SelectedValue;
        string strTimeType = drTimeType.SelectedValue;
        string strUserID = userid.Value;
        string strUser = Request.Form["checkUser"];
        string strState = ddlstate.SelectedValue;
        string strCity = ddlcity.SelectedValue;
        string strcheckCity = Request.Form["checkCity"];
        string strddlExpress = ddlExpress.SelectedValue;
        string strSql = "";
        string strSqlMsg = "";
        string strGroup = "";
        string orderstr = "";
        string where = " where  1=1 ";
        string strPayFind = "";//子查询
        if (strUser != "")
        {
            if (strUser == "on")
            {
                strSql = strSql + ", user_id as '用户名', count(id) as '购买次数' ";
                strGroup = strGroup + ",user_id";
                orderstr = orderstr + ",user_id desc";
            }

        }
        if (strcheckCity != null && strcheckCity != "")
        {
            if (strcheckCity == "on")
            {
                strSql = strSql + ",City_id as '城市' ";
                strGroup = strGroup + ",City_id";
                orderstr = orderstr + ",City_id desc";
            }
        }
        if (strState != "")
        {
            if (strState == "0")
            {
                where = where + " and state in ('pay','scorepay') ";
            }
            if (strState == "1")
            {
                where = where + " and state in ('nocod','unpay','scoreunpay') ";
            }
            if (strState == "2")
            {
                where = where + " and state in ('refund','scorrefund') ";
            }
            if (strState == "3")
            {
                where = where + " and state in ('cancel','scorecancel') ";

            }
        }


        if (strService != null && strService != "")
        {
            if (strService == "on")
            {
                strSql = strSql + ",service as '付款方式' ";
                strPayFind = strPayFind + "and isnull(order1.service,'11')=isnull(service,'11') ";
                strGroup = strGroup + ",service";
                orderstr = orderstr + ",service desc";
            }
        }

        if (strExpress != null && strExpress != "")
        {
            if (strExpress == "on")
            {
                strSql = strSql + ", Express as '递送方式' ";

                strPayFind = strPayFind + "and isnull(order1.Express,'11')=isnull(Express,'11') ";
                strGroup = strGroup + ",Express";
                orderstr = orderstr + ",Express desc";
            }
        }

        if (strPay_time != null && strPay_time != "")
        {
            if (strPay_time == "year")
            {

                strSql = strSql + ", year(Pay_time) as '支付年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Pay_time),year(getdate()))=isnull(year(Pay_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Pay_time)";
                orderstr = orderstr + ",year(Pay_time) desc";
            }
            if (strPay_time == "month")
            {
                strSql = strSql + ", year(Pay_time) as '支付年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Pay_time),year(getdate()))=isnull(year(Pay_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Pay_time)";
                orderstr = orderstr + ",year(Pay_time) desc";


                strSql = strSql + ", month(Pay_time) as '支付月' ";
                strPayFind = strPayFind + "and isnull(month(order1.Pay_time),month(getdate()))=isnull(month(Pay_time),month(getdate()))  ";
                strGroup = strGroup + ",month(Pay_time)";
                orderstr = orderstr + ",month(Pay_time) desc";
            }

            if (strPay_time == "day")
            {
                strSql = strSql + ", year(Pay_time) as '支付年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Pay_time),year(getdate()))=isnull(year(Pay_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Pay_time)";
                orderstr = orderstr + ",year(Pay_time) desc";


                strSql = strSql + ", month(Pay_time) as '支付月' ";
                strPayFind = strPayFind + "and isnull(month(order1.Pay_time),month(getdate()))=isnull(month(Pay_time),month(getdate()))  ";
                strGroup = strGroup + ",month(Pay_time)";
                orderstr = orderstr + ",month(Pay_time) desc";

                strSql = strSql + ", day(Pay_time) as '支付日' ";
                strPayFind = strPayFind + "and isnull(day(order1.Pay_time),day(getdate()))=isnull(day(Pay_time),day(getdate()))  ";
                strGroup = strGroup + ",day(Pay_time)";
                orderstr = orderstr + ",day(Pay_time) desc";
            }
        }

        if (strPay_time == "hour")
        {
            strSql = strSql + ", year(Pay_time) as '支付年' ";
            strPayFind = strPayFind + "and isnull(year(order1.Pay_time),year(getdate()))=isnull(year(Pay_time),year(getdate()))  ";
            strGroup = strGroup + ",year(Pay_time)";
            orderstr = orderstr + ",year(Pay_time) desc";


            strSql = strSql + ", month(Pay_time) as '支付月' ";
            strPayFind = strPayFind + "and isnull(month(order1.Pay_time),month(getdate()))=isnull(month(Pay_time),month(getdate()))  ";
            strGroup = strGroup + ",month(Pay_time)";
            orderstr = orderstr + ",month(Pay_time) desc";

            strSql = strSql + ", day(Pay_time) as '支付日' ";
            strPayFind = strPayFind + "and isnull(day(order1.Pay_time),day(getdate()))=isnull(day(Pay_time),day(getdate()))  ";
            strGroup = strGroup + ",day(Pay_time)";
            orderstr = orderstr + ",day(Pay_time) desc";

            strSql = strSql + ", datepart(HH,Pay_time) as '支付时' ";
            strPayFind = strPayFind + "and isnull(datepart(HH,order1.Pay_time),datepart(HH,getdate()))=isnull(datepart(HH,Pay_time),datepart(HH,getdate()))  ";
            strGroup = strGroup + ",datepart(HH,Pay_time)";
            orderstr = orderstr + ",datepart(HH,Pay_time) desc";
        }

        if (strCreate_time != null && strCreate_time != "")
        {
            if (strCreate_time == "year")
            {
                strSql = strSql + ", year(Create_time) as '下单年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Create_time),year(getdate()))=isnull(year(Create_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Create_time)";
                orderstr = orderstr + ",year(Create_time) desc";
            }

            if (strCreate_time == "month")
            {
                strSql = strSql + ", year(Create_time) as '下单年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Create_time),year(getdate()))=isnull(year(Create_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Create_time)";
                orderstr = orderstr + ",year(Create_time) desc";

                strSql = strSql + ", month(Create_time) as '下单月' ";
                strPayFind = strPayFind + "and isnull(month(order1.Create_time),month(getdate()))=isnull(month(Create_time),month(getdate()))  ";
                strGroup = strGroup + ",month(Create_time)";
                orderstr = orderstr + ",month(Create_time) desc";
            }

            if (strCreate_time == "day")
            {
                strSql = strSql + ", year(Create_time) as '下单年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Create_time),year(getdate()))=isnull(year(Create_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Create_time)";
                orderstr = orderstr + ",year(Create_time) desc";

                strSql = strSql + ", month(Create_time) as '下单月' ";
                strPayFind = strPayFind + "and isnull(month(order1.Create_time),month(getdate()))=isnull(month(Create_time),month(getdate()))  ";
                strGroup = strGroup + ",month(Create_time)";
                orderstr = orderstr + ",month(Create_time) desc";


                strSql = strSql + ", day(Create_time) as '下单日' ";
                strPayFind = strPayFind + "and isnull(day(order1.Create_time),day(getdate()))=isnull(day(Create_time),day(getdate()))  ";
                strGroup = strGroup + ",day(Create_time)";
                orderstr = orderstr + ",day(Create_time) desc";
            }


            if (strCreate_time == "hour")
            {
                strSql = strSql + ", year(Create_time) as '下单年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Create_time),year(getdate()))=isnull(year(Create_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Create_time)";
                orderstr = orderstr + ",year(Create_time) desc";

                strSql = strSql + ", month(Create_time) as '下单月' ";
                strPayFind = strPayFind + "and isnull(month(order1.Create_time),month(getdate()))=isnull(month(Create_time),month(getdate()))  ";
                strGroup = strGroup + ",month(Create_time)";
                orderstr = orderstr + ",month(Create_time) desc";


                strSql = strSql + ", day(Create_time) as '下单日' ";
                strPayFind = strPayFind + "and isnull(day(order1.Create_time),day(getdate()))=isnull(day(Create_time),day(getdate()))  ";
                strGroup = strGroup + ",day(Create_time)";
                orderstr = orderstr + ",day(Create_time) desc";


                strSql = strSql + ", datepart(HH,Create_time) as '下单时' ";
                strPayFind = strPayFind + "and isnull(datepart(HH,order1.Create_time),datepart(HH,getdate()))=isnull(datepart(HH,Create_time),datepart(HH,getdate()))  ";
                strGroup = strGroup + ",datepart(HH,Create_time)";
                orderstr = orderstr + ",datepart(HH,Create_time) desc";
            }


        }


        if (strFromDomain != null && strFromDomain != "")
        {
            if (strFromDomain == "on")
            {
                strSql = strSql + ",fromdomain as '来源地址' ";
                strPayFind = strPayFind + "and isnull(order1.fromdomain,'11')=isnull(fromdomain,'11')  ";
                strGroup = strGroup + ",fromdomain";
                orderstr = orderstr + ",fromdomain desc";
            }
        }

        if (strSql.Length > 0)
        {
            strSql = strSql.Substring(1);
        }
        if (strService == "on" || strSeviceWhere != "")
        {
            strPayFind = "  (sum( patindex(state,'pay'))+sum( patindex(state,'scorepay'))) as '付款订单'";
        }
        else
        {
            strPayFind = " (sum( patindex(state,'pay'))+sum( patindex(state,'scorepay'))) as '付款订单', (sum( patindex(state,'nocod'))+sum( patindex(state,'unpay'))+sum( patindex(state,'scoreunpay')))  as '未付款订单'";
        }
        if (strSql.Length > 0)
        {
            if (strPayFind.Length > 0)
            {
                strSql = "select  " + strSql + ", sum(Money) as '在线支付费用',sum(cashondelivery) as '货到付款', sum(Credit) as '余额付款', sum(Card) as '代金券费',sum(Fare) as '快递费', sum(Origin) as '总款', sum(totalscore) as '积分'," + strPayFind + " from [order] ";

            }
            else
            {
                strSql = "select  " + strSql + ", sum(Money) as '在线支付费用',sum(cashondelivery) as '货到付款', sum(Credit) as '余额付款', sum(Card) as '代金券费',sum(Fare) as '快递费', sum(Origin) as '总款', sum(totalscore) as '积分'  from [order] ";
            }

        }
        else
        {


            if (strPayFind.Length > 0)
            {
                strSql = "select sum(Money) as '在线支付费用', sum(cashondelivery) as '货到付款', sum(Credit) as '余额付款', sum(Card) as '代金券费',sum(Fare) as '快递费', sum(Origin) as '总款', sum(totalscore) as '积分', " + strPayFind + " from [order] ";
            }
            else
            {
                strSql = "select sum(Money) as '在线支付费用', sum(cashondelivery) as '货到付款', sum(Credit) as '余额付款', sum(Card) as '代金券费',sum(Fare) as '快递费', sum(Origin) as '总款',sum(totalscore) as '积分'  from [order] ";
            }
        }


        if (strExpress_id != null && strExpress_id != "")
        {
            if (strExpress_id == "1")
            {
                where = where + " and Express_id >0";
            }
            else
            {
                where = where + " and Express_id <=0";
            }
        }

        if (beginTime.Value != "")
        {
            if (strTimeType == "0")
            {
                where = where + "  and Pay_time >='" + beginTime.Value + "'";
            }

            if (strTimeType == "1")
            {
                where = where + " and Create_time >='" + beginTime.Value + "'";
            }
        }
        if (endTime.Value != "")
        {
            string endtime = DateTime.Parse(endTime.Value).AddDays(1).ToString();
            if (strTimeType == "0")
            {
                where = where + "  and Pay_time <='" + endtime + "'";
            }

            if (strTimeType == "1")
            {
                where = where + " and Create_time <='" + endtime + "'";

            }

        }

        if (strSeviceWhere != null && strSeviceWhere != "")
        {
            if (strSeviceWhere == "0")
            {
                where = where + " and isnull( Service,'11' )='11'";
            }
            else
            {
                where = where + " and Service='" + strSeviceWhere + "'";
            }
        }

        if (strUserID != "")
        {
            where = where + " and user_id=" + strUserID;
        }

        if (strCity != "0")
        {
            where = where + " and City_id=" + strCity;
        }

        if (strddlExpress != "")
        {
            where = where + " and Express='" + strddlExpress + "'";

        }



        strSql = strSql + where;
        if (strGroup != "")
        {
            strGroup = strGroup.Substring(1);
            strSql = strSql + " group by " + strGroup;

        }
        if (orderstr.Length > 0)
            strSql = strSql + " order by " + orderstr.Substring(1);


        /***************************************************/
        //              提示统计信息开始
        /***************************************************/

        strSqlMsg = "select  sum(Money) as '在线支付费用', sum(cashondelivery) as '货到付款', sum(Credit) as '余额付款', sum(Card) as '代金券费',sum(Fare) as '快递费', sum(Origin) as '总款',sum(totalscore) as '积分'  from [order] ";
        if (strPayFind.Length > 0)
        {

            strSqlMsg = "select  sum(Money) as '在线支付费用', sum(cashondelivery) as '货到付款', sum(Credit) as '余额付款', sum(Card) as '代金券费',sum(Fare) as '快递费', sum(Origin) as '总款',sum(totalscore) as '积分', " + strPayFind + "  from [order] ";



        }

        strSqlMsg = strSqlMsg + where;

        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            hashtable = session.GetData.GetDataList(strSqlMsg);
        }
        datatable = AS.Common.Utils.Helper.ConvertDataTable(hashtable);

        string strMsg = "";

        if (datatable.Rows.Count > 0)
        {
            strMsg = strMsg + "<font color='green'><strong>【 提示信息 】：</strong>  在线支付费用：" + datatable.Rows[0]["在线支付费用"] + "; 货到付款：" + datatable.Rows[0]["货到付款"] + "; 余额付款: " + datatable.Rows[0]["余额付款"] + "; 代金券费: " + datatable.Rows[0]["代金券费"] + "; 快递费: " + datatable.Rows[0]["快递费"] + "; 总款: " + datatable.Rows[0]["总款"] + "; 积分：" + datatable.Rows[0]["积分"];
            if (datatable.Columns["付款订单"] != null)
            {
                strMsg = strMsg + "; 付款订单: " + datatable.Rows[0]["付款订单"];
            }
            if (datatable.Columns["未付款订单"] != null)
            {
                strMsg = strMsg + "; 未付款订单: " + datatable.Rows[0]["未付款订单"];
            }
            //msg.Text = "<font color='green'><strong>【 提示信息 】：</strong>  在线支付费用：" + datatable.Rows[0]["在线支付费用"] + "; 余额付款: " + datatable.Rows[0]["余额付款"] + "; 代金券费: " + datatable.Rows[0]["代金券费"] + "; 快递费: " + datatable.Rows[0]["快递费"] + "; 总款: " + datatable.Rows[0]["总款"] + "; 付款订单: " + datatable.Rows[0]["付款订单"] + "; 未付款订单: " + datatable.Rows[0]["未付款订单"] + "</font>";

            strMsg = strMsg + "</font>";

            msg.Text = strMsg;
        }

        /***************************************************/
        //              提示统计信息结束
        /***************************************************/

        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            hashtablepage = session.GetData.GetDataList(strSql);
        }
        datatablepage = AS.Common.Utils.Helper.ConvertDataTable(hashtablepage);


        System.Data.DataView view = datatablepage.DefaultView;

        if (strSql.IndexOf(((string)ViewState["SortOrder"])) > 0)
        {
            string sort = (string)ViewState["SortOrder"] + " " + (string)ViewState["OrderDire"];
            view.Sort = sort;
        }
        GridView1.DataSource = view;
        GridView1.DataBind();
    }
    protected void GridView1_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        this.GridView1.PageIndex = e.NewPageIndex;
        initPage();
    }
    protected void Button1_Click(object sender, EventArgs e)
    {

        initPage();
    }
    protected void GridView1_Sorting(object sender, GridViewSortEventArgs e)
    {
        string sPage = e.SortExpression;

        if (ViewState["SortOrder"].ToString() == sPage)
        {
            if (ViewState["OrderDire"].ToString() == "Desc")
                ViewState["OrderDire"] = "ASC";
            else
                ViewState["OrderDire"] = "Desc";
        }
        else
        {
            ViewState["SortOrder"] = e.SortExpression;
        }
        initPage();
    }
    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            System.Data.DataRowView dr = (System.Data.DataRowView)e.Row.DataItem;
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
                    case "chinabank":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "网银在线";
                        break;
                    case "cashondelivery":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "货到付款";
                        break;
                    case "cash":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "线下支付";
                        break;
                    case "chinamobilepay":
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "移动支付";
                        break;
                    default:
                        e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款方式")].Text = "未选择";
                        break;

                }
            }
            if (dr.Row.Table.Columns["城市"] != null)
            {
                string value = dr["城市"].ToString();
                ICategory cate = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    cate = session.Category.GetByID(int.Parse(value));
                }
                if (cate != null)
                {
                    e.Row.Cells[dr.Row.Table.Columns.IndexOf("城市")].Text = cate.Name;
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
            if (dr.Row.Table.Columns["支付时"] != null)
            {
                string hour = dr["支付时"].ToString();
                if (hour.Length == 1)
                {
                    hour = "0" + hour;
                }
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("支付时")].Text = hour + "时";
            }

            if (dr.Row.Table.Columns["下单年"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("下单年")].Text = dr["下单年"].ToString() + "年";
            }
            if (dr.Row.Table.Columns["下单月"] != null)
            {
                string month = dr["下单月"].ToString();
                if (month.Length == 1)
                {
                    month = "0" + month;
                }
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("下单月")].Text = month + "月";
            }
            if (dr.Row.Table.Columns["下单日"] != null)
            {
                string day = dr["下单日"].ToString();
                if (day.Length == 1)
                {
                    day = "0" + day;
                }
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("下单日")].Text = day + "日";
            }
            if (dr.Row.Table.Columns["下单时"] != null)
            {

                string hour = dr["下单时"].ToString();
                if (hour.Length == 1)
                {
                    hour = "0" + hour;
                }
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("下单时")].Text = hour + "时";
            }
            if (dr.Row.Table.Columns["在线支付费用"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("在线支付费用")].Text = dr["在线支付费用"].ToString() + "元";
            }
            if (dr.Row.Table.Columns["货到付款"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("货到付款")].Text = dr["货到付款"].ToString() + "元";
            }
            if (dr.Row.Table.Columns["余额付款"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("余额付款")].Text = dr["余额付款"].ToString() + "元";
            }
            if (dr.Row.Table.Columns["代金券费"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("代金券费")].Text = dr["代金券费"].ToString() + "元";
            }
            if (dr.Row.Table.Columns["快递费"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("快递费")].Text = dr["快递费"].ToString() + "元";
            }
            if (dr.Row.Table.Columns["总款"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("总款")].Text = dr["总款"].ToString() + "元";
            }
            if (dr.Row.Table.Columns["积分"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("积分")].Text = dr["积分"].ToString();
            }
            if (dr.Row.Table.Columns["付款订单"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("付款订单")].Text = dr["付款订单"].ToString() + "个";
            }
            if (dr.Row.Table.Columns["未付款订单"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("未付款订单")].Text = dr["未付款订单"].ToString() + "个";
            }


            if (dr.Row.Table.Columns["用户名"] != null)
            {
                string userID = dr["用户名"].ToString();
                IUser user = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    user = session.Users.GetByID(int.Parse(userID));
                }
                if (user != null)
                {
                    e.Row.Cells[dr.Row.Table.Columns.IndexOf("用户名")].Text = "【" + userID + "】" + user.Username;
                }
            }

            if (dr.Row.Table.Columns["购买次数"] != null)
            {
                string userID = dr["用户名"].ToString();

                e.Row.Cells[dr.Row.Table.Columns.IndexOf("购买次数")].Text = "<a class='ajaxlink' href='ajax_manage.aspx?action=showbuy&id=" + userID + "&pageIndex=1'>" + dr["购买次数"].ToString() + "次</a>";
            }

        }
    }


    /// <summary>
    ///  下载事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDown_Click(object sender, EventArgs e)
    {
        string strFromDomain = Request.Form["checkFromdomain"];
        string strService = Request.Form["checkService"];
        string strExpress = Request.Form["checkExpress"];
        string strPay_time = drPayTime.SelectedValue;
        string strCreate_time = drCreateTime.SelectedValue;
        string strExpress_id = drExpress_id.SelectedValue;
        string strSeviceWhere = drSeviceWhere.SelectedValue;
        string strTimeType = drTimeType.SelectedValue;
        string strUserID = userid.Value;
        string strUser = Request.Form["checkUser"];
        string strState = ddlstate.SelectedValue;
        string strCity = ddlcity.SelectedValue;
        string strcheckCity = Request.Form["checkCity"];
        string strddlExpress = ddlExpress.SelectedValue;
        string strSql = "";
        string strGroup = "";
        string orderstr = "";
        string where = " where 1=1 ";
        string strPayFind = "";//子查询


        if (strUser != "")
        {
            if (strUser == "on")
            {
                strSql = strSql + ", user_id as '用户名', count(id) as '购买次数' ";
                strGroup = strGroup + ",user_id";
                orderstr = orderstr + ",user_id desc";
            }

        }

        if (strcheckCity != null && strcheckCity != "")
        {
            if (strcheckCity == "on")
            {
                strSql = strSql + ",City_id as '城市' ";
                strGroup = strGroup + ",City_id";
                orderstr = orderstr + ",City_id desc";
            }
        }

        if (strState != "")
        {
            if (strState == "0")
            {
                where = where + " and state in ('pay','scorepay') ";
            }
            if (strState == "1")
            {
                where = where + " and state in ('unpay','scoreunpay','nocod') ";
            }
            if (strState == "2")
            {
                where = where + " and state in ('refund','scorrefund') ";
            }
            if (strState == "3")
            {
                where = where + " and state in ('cancel','scorecancel') ";

            }
        }


        if (strService != null && strService != "")
        {
            if (strService == "on")
            {
                strSql = strSql + ",service as '付款方式' ";
                strPayFind = strPayFind + "and isnull(order1.service,'11')=isnull(service,'11') ";
                strGroup = strGroup + ",service";
                orderstr = orderstr + ",service desc";
            }
        }

        if (strExpress != null && strExpress != "")
        {
            if (strExpress == "on")
            {
                strSql = strSql + ", Express as '递送方式' ";

                strPayFind = strPayFind + "and isnull(order1.Express,'11')=isnull(Express,'11') ";
                strGroup = strGroup + ",Express";
                orderstr = orderstr + ",Express desc";
            }
        }

        if (strPay_time != null && strPay_time != "")
        {
            if (strPay_time == "year")
            {

                strSql = strSql + ", year(Pay_time) as '支付年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Pay_time),year(getdate()))=isnull(year(Pay_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Pay_time)";
                orderstr = orderstr + ",year(Pay_time) desc";
            }
            if (strPay_time == "month")
            {
                strSql = strSql + ", year(Pay_time) as '支付年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Pay_time),year(getdate()))=isnull(year(Pay_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Pay_time)";
                orderstr = orderstr + ",year(Pay_time) desc";


                strSql = strSql + ", month(Pay_time) as '支付月' ";
                strPayFind = strPayFind + "and isnull(month(order1.Pay_time),month(getdate()))=isnull(month(Pay_time),month(getdate()))  ";
                strGroup = strGroup + ",month(Pay_time)";
                orderstr = orderstr + ",month(Pay_time) desc";
            }

            if (strPay_time == "day")
            {
                strSql = strSql + ", year(Pay_time) as '支付年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Pay_time),year(getdate()))=isnull(year(Pay_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Pay_time)";
                orderstr = orderstr + ",year(Pay_time) desc";


                strSql = strSql + ", month(Pay_time) as '支付月' ";
                strPayFind = strPayFind + "and isnull(month(order1.Pay_time),month(getdate()))=isnull(month(Pay_time),month(getdate()))  ";
                strGroup = strGroup + ",month(Pay_time)";
                orderstr = orderstr + ",month(Pay_time) desc";

                strSql = strSql + ", day(Pay_time) as '支付日' ";
                strPayFind = strPayFind + "and isnull(day(order1.Pay_time),day(getdate()))=isnull(day(Pay_time),day(getdate()))  ";
                strGroup = strGroup + ",day(Pay_time)";
                orderstr = orderstr + ",day(Pay_time) desc";
            }

            if (strPay_time == "hour")
            {
                strSql = strSql + ", year(Pay_time) as '支付年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Pay_time),year(getdate()))=isnull(year(Pay_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Pay_time)";
                orderstr = orderstr + ",year(Pay_time) desc";


                strSql = strSql + ", month(Pay_time) as '支付月' ";
                strPayFind = strPayFind + "and isnull(month(order1.Pay_time),month(getdate()))=isnull(month(Pay_time),month(getdate()))  ";
                strGroup = strGroup + ",month(Pay_time)";
                orderstr = orderstr + ",month(Pay_time) desc";

                strSql = strSql + ", day(Pay_time) as '支付日' ";
                strPayFind = strPayFind + "and isnull(day(order1.Pay_time),day(getdate()))=isnull(day(Pay_time),day(getdate()))  ";
                strGroup = strGroup + ",day(Pay_time)";
                orderstr = orderstr + ",day(Pay_time) desc";

                strSql = strSql + ", datepart(HH,Pay_time) as '支付时' ";
                strPayFind = strPayFind + "and isnull(datepart(HH,order1.Pay_time),datepart(HH,getdate()))=isnull(datepart(HH,Pay_time),datepart(HH,getdate()))  ";
                strGroup = strGroup + ",datepart(HH,Pay_time)";
                orderstr = orderstr + ",datepart(HH,Pay_time) desc";
            }
        }
        if (strCreate_time != null && strCreate_time != "")
        {
            if (strCreate_time == "year")
            {
                strSql = strSql + ", year(Create_time) as '下单年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Create_time),year(getdate()))=isnull(year(Create_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Create_time)";
                orderstr = orderstr + ",year(Create_time) desc";
            }

            if (strCreate_time == "month")
            {
                strSql = strSql + ", year(Create_time) as '下单年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Create_time),year(getdate()))=isnull(year(Create_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Create_time)";
                orderstr = orderstr + ",year(Create_time) desc";

                strSql = strSql + ", month(Create_time) as '下单月' ";
                strPayFind = strPayFind + "and isnull(month(order1.Create_time),month(getdate()))=isnull(month(Create_time),month(getdate()))  ";
                strGroup = strGroup + ",month(Create_time)";
                orderstr = orderstr + ",month(Create_time) desc";
            }

            if (strCreate_time == "day")
            {
                strSql = strSql + ", year(Create_time) as '下单年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Create_time),year(getdate()))=isnull(year(Create_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Create_time)";
                orderstr = orderstr + ",year(Create_time) desc";

                strSql = strSql + ", month(Create_time) as '下单月' ";
                strPayFind = strPayFind + "and isnull(month(order1.Create_time),month(getdate()))=isnull(month(Create_time),month(getdate()))  ";
                strGroup = strGroup + ",month(Create_time)";
                orderstr = orderstr + ",month(Create_time) desc";


                strSql = strSql + ", day(Create_time) as '下单日' ";
                strPayFind = strPayFind + "and isnull(day(order1.Create_time),day(getdate()))=isnull(day(Create_time),day(getdate()))  ";
                strGroup = strGroup + ",day(Create_time)";
                orderstr = orderstr + ",day(Create_time) desc";
            }


            if (strCreate_time == "hour")
            {
                strSql = strSql + ", year(Create_time) as '下单年' ";
                strPayFind = strPayFind + "and isnull(year(order1.Create_time),year(getdate()))=isnull(year(Create_time),year(getdate()))  ";
                strGroup = strGroup + ",year(Create_time)";
                orderstr = orderstr + ",year(Create_time) desc";

                strSql = strSql + ", month(Create_time) as '下单月' ";
                strPayFind = strPayFind + "and isnull(month(order1.Create_time),month(getdate()))=isnull(month(Create_time),month(getdate()))  ";
                strGroup = strGroup + ",month(Create_time)";
                orderstr = orderstr + ",month(Create_time) desc";


                strSql = strSql + ", day(Create_time) as '下单日' ";
                strPayFind = strPayFind + "and isnull(day(order1.Create_time),day(getdate()))=isnull(day(Create_time),day(getdate()))  ";
                strGroup = strGroup + ",day(Create_time)";
                orderstr = orderstr + ",day(Create_time) desc";

                strSql = strSql + ", datepart(HH,Create_time) as '下单时' ";
                strPayFind = strPayFind + "and isnull(datepart(HH,order1.Create_time),datepart(HH,getdate()))=isnull(datepart(HH,Create_time),datepart(HH,getdate()))  ";
                strGroup = strGroup + ",datepart(HH,Create_time)";
                orderstr = orderstr + ",datepart(HH,Create_time) desc";
            }
        }


        if (strFromDomain != null && strFromDomain != "")
        {
            if (strFromDomain == "on")
            {
                strSql = strSql + ",fromdomain as '来源地址' ";
                strPayFind = strPayFind + "and isnull(order1.fromdomain,'11')=isnull(fromdomain,'11')  ";
                strGroup = strGroup + ",fromdomain";
                orderstr = orderstr + ",fromdomain desc";
            }
        }
        if (strSql.Length > 0)
        {
            strSql = strSql.Substring(1);
        }
        if (strPayFind.Length > 0)
        {

            if (strService == "on" || strSeviceWhere != "")
            {
                strPayFind = "  (sum( patindex(state,'pay'))+sum( patindex(state,'scorepay'))) as '付款订单'";
            }
            else
            {
                strPayFind = " (sum( patindex(state,'pay'))+sum( patindex(state,'scorepay'))) as '付款订单', (sum( patindex(state,'nocod'))+sum( patindex(state,'unpay'))+sum( patindex(state,'scoreunpay')))   as '未付款订单'";
            }
        }
        if (strSql.Length > 0)
        {
            if (strPayFind.Length > 0)
            {
                strSql = "select  " + strSql + ", sum(Money) as '在线支付费用', sum(cashondelivery) as '货到付款', sum(Credit) as '余额付款', sum(Card) as '代金券费',sum(Fare) as '快递费', sum(Origin) as '总款', sum(totalscore) as '积分', " + strPayFind + " from [order] ";
            }
            else
            {
                strSql = "select  " + strSql + ", sum(Money) as '在线支付费用', sum(cashondelivery) as '货到付款', sum(Credit) as '余额付款', sum(Card) as '代金券费',sum(Fare) as '快递费', sum(Origin) as '总款',sum(totalscore) as '积分'  from [order] ";
            }

        }
        else
        {


            if (strPayFind.Length > 0)
            {
                strSql = "select sum(Money) as '在线支付费用', sum(cashondelivery) as '货到付款', sum(Credit) as '余额付款', sum(Card) as '代金券费',sum(Fare) as '快递费', sum(Origin) as '总款', sum(totalscore) as '积分', " + strPayFind + " from [order] ";
            }
            else
            {
                strSql = "select sum(Money) as '在线支付费用', sum(cashondelivery) as '货到付款', sum(Credit) as '余额付款', sum(Card) as '代金券费',sum(Fare) as '快递费', sum(Origin) as '总款',sum(totalscore) as '积分'  from [order] ";
            }
        }

        if (strExpress_id != null && strExpress_id != "")
        {
            if (strExpress_id == "1")
            {
                where = where + " and Express_id >0";
            }
            else
            {
                where = where + " and Express_id <=0";
            }
        }
        if (beginTime.Value != "")
        {
            if (strTimeType == "0")
            {
                where = where + " and Pay_time >='" + beginTime.Value + "'";
            }

            if (strTimeType == "1")
            {
                where = where + " and Create_time >='" + beginTime.Value + "'";
            }
        }
        if (endTime.Value != "")
        {
            string endtime = DateTime.Parse(endTime.Value).AddDays(1).ToString();
            if (strTimeType == "0")
            {
                where = where + " and Pay_time <='" + endtime + "'";
            }

            if (strTimeType == "1")
            {
                where = where + " and Create_time <='" + endtime + "'";

            }

        }
        if (strSeviceWhere != null && strSeviceWhere != "")
        {
            if (strSeviceWhere == "0")
            {
                where = where + " and isnull( Service,'11' )='11'";
            }
            else
            {
                where = where + " and Service='" + strSeviceWhere + "'";
            }
        }
        if (strUserID != "")
        {
            where = where + " and user_id=" + strUserID;
        }
        if (strCity != "0")
        {
            where = where + " and City_id=" + strCity;
        }
        if (strddlExpress != "")
        {
            where = where + " and Express='" + strddlExpress + "'";
        }

        strSql = strSql + where;
        if (strGroup != "")
        {
            strGroup = strGroup.Substring(1);
            strSql = strSql + " group by " + strGroup;

        }
        if (orderstr.Length > 0)
            strSql = strSql + " order by " + orderstr.Substring(1);


        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            hashtableDown = session.GetData.GetDataList(strSql); 
        }
        datatableDown = AS.Common.Utils.Helper.ConvertDataTable(hashtableDown);
        sb1.Append("<html>");
        sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
        sb1.Append("<body><table border=\'1\'>");
        sb1.Append("<tr>");
        sb1.Append("<td>ID</td>");
        if (datatableDown.Columns["付款方式"] != null)
        {
            sb1.Append("<td align='left'>付款方式</td>");
        }
        if (datatableDown.Columns["递送方式"] != null)
        {
            sb1.Append("<td align='left'>递送方式</td>");
        }
        if (datatableDown.Columns["支付年"] != null)
        {
            sb1.Append("<td align='left'>支付年</td>");
        }
        if (datatableDown.Columns["支付月"] != null)
        {
            sb1.Append("<td align='left'>支付月</td>");
        }
        if (datatableDown.Columns["支付日"] != null)
        {
            sb1.Append("<td align='left'>支付日</td>");
        }
        if (datatableDown.Columns["支付时"] != null)
        {
            sb1.Append("<td align='left'>支付时</td>");
        }
        if (datatableDown.Columns["下单年"] != null)
        {
            sb1.Append("<td align='left'>下单年</td>");
        }
        if (datatableDown.Columns["下单月"] != null)
        {
            sb1.Append("<td align='left'>下单月</td>");
        }
        if (datatableDown.Columns["下单日"] != null)
        {
            sb1.Append("<td align='left'>下单日</td>");
        }
        if (datatableDown.Columns["下单时"] != null)
        {
            sb1.Append("<td align='left'>下单时</td>");
        }
        if (datatableDown.Columns["来源地址"] != null)
        {
            sb1.Append("<td align='left'>来源地址</td>");
        }
        if (datatableDown.Columns["在线支付费用"] != null)
        {
            sb1.Append("<td align='left'>在线支付费用</td>");
        }
        if (datatableDown.Columns["货到付款"] != null)
        {
            sb1.Append("<td align='left'>货到付款</td>");
        }
        if (datatableDown.Columns["余额付款"] != null)
        {
            sb1.Append("<td align='left'>余额付款</td>");
        }
        if (datatableDown.Columns["代金券费"] != null)
        {
            sb1.Append("<td align='left'>代金券费</td>");
        }
        if (datatableDown.Columns["快递费"] != null)
        {
            sb1.Append("<td align='left'>快递费</td>");
        }


        if (datatableDown.Columns["总款"] != null)
        {
            sb1.Append("<td align='left'>总款</td>");
        }
        if (datatableDown.Columns["付款订单"] != null)
        {
            sb1.Append("<td align='left'>付款订单</td>");
        }
        if (datatableDown.Columns["未付款订单"] != null)
        {
            sb1.Append("<td align='left'>未付款订单</td>");
        }

        if (datatableDown.Columns["用户名"] != null)
        {
            sb1.Append("<td align='left'>用户名</td>");
        }


        if (datatableDown.Columns["城市"] != null)
        {
            sb1.Append("<td align='left'>城市</td>");
        }

        if (datatableDown.Columns["购买次数"] != null)
        {
            sb1.Append("<td align='left'>购买次数</td>");
        }
        sb1.Append("</tr>");
        for (int i = 0; i < datatableDown.Rows.Count; i++)
        {
            sb1.Append("<tr>");
            sb1.Append("<td>" + (i + 1).ToString() + "</td>");
            if (datatableDown.Columns["付款方式"] != null)
            {
                string strTrue = "";
                string value = datatableDown.Rows[i]["付款方式"].ToString();
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
                    case "cash":
                        strTrue = "线下支付";
                        break;
                    case "chinamobilepay":
                        strTrue = "移动支付";
                        break;
                    case "cashondelivery":
                        strTrue = "货到付款";
                        break;
                    default:
                        strTrue = "未选择";
                        break;

                }

                sb1.Append("<td align='left'>" + strTrue + "</td>");

            }
            if (datatableDown.Columns["递送方式"] != null)
            {

                string strTrue = "";
                string value = datatableDown.Rows[i]["递送方式"].ToString();
                switch (value)
                {
                    case "Y":
                        strTrue = "快递";
                        break;
                    case "N":
                        strTrue = "优惠卷";
                        break;
                    case "D":
                        strTrue = "抽奖";
                        break;
                    case "P":
                        strTrue = "站外券";
                        break;
                }
                sb1.Append("<td align='left'>" + strTrue + " </td>");

            }
            if (datatableDown.Columns["支付年"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["支付年"] + "</td>");
            }
            if (datatableDown.Columns["支付月"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["支付月"] + "</td>");
            }
            if (datatableDown.Columns["支付日"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["支付日"] + "</td>");
            }
            if (datatableDown.Columns["支付时"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["支付时"] + "</td>");
            }
            if (datatableDown.Columns["下单年"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["下单年"] + "</td>");
            }
            if (datatableDown.Columns["下单月"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["下单月"] + "</td>");
            }
            if (datatableDown.Columns["下单日"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["下单日"] + "</td>");
            }
            if (datatableDown.Columns["下单时"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["下单时"] + "</td>");
            }
            if (datatableDown.Columns["来源地址"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["来源地址"] + "</td>");
            }
            if (datatableDown.Columns["在线支付费用"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["在线支付费用"] + "</td>");
            }
            if (datatableDown.Columns["货到付款"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["货到付款"] + "</td>");
            }
            if (datatableDown.Columns["余额付款"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["余额付款"] + "</td>");
            }
            if (datatableDown.Columns["代金券费"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["代金券费"] + "</td>");
            }
            if (datatableDown.Columns["快递费"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["快递费"] + "</td>");
            }


            if (datatableDown.Columns["总款"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["总款"] + "</td>");
            }
            if (datatableDown.Columns["付款订单"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["付款订单"] + "</td>");
            }
            if (datatableDown.Columns["未付款订单"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["未付款订单"] + "</td>");
            }

            if (datatableDown.Columns["用户名"] != null)
            {

                string userID = datatableDown.Rows[i]["用户名"].ToString();
                IUser user = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    user = session.Users.GetByID(int.Parse(userID));
                }
                if (user != null)
                {
                    sb1.Append("<td align='left'>" + "【" + userID + "】" + user.Username + "</td>");

                }
            }
            if (datatableDown.Columns["城市"] != null)
            {

                string value = datatableDown.Rows[i]["城市"].ToString();
                ICategory cate = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    cate = session.Category.GetByID(int.Parse(value));
                }
                if (cate != null)
                {
                    sb1.Append("<td align='left'>" + "【" + cate.Id + "】" + cate.Name + "</td>");

                }
            }
            if (datatableDown.Columns["购买次数"] != null)
            {
                sb1.Append("<td align='left'>" + datatableDown.Rows[i]["购买次数"] + "</td>");
            }
            sb1.Append("</tr>");
        }
        sb1.Append("</table></body></html>");
        Response.ClearHeaders();
        Response.Clear();
        Response.Expires = 0;
        Response.Buffer = true;
        Response.AddHeader("Accept-Language", "zh-tw");
        Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("tongji_order_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
        Response.ContentType = "Application/octet-stream";
        Response.Write(sb1.ToString());
        Response.End();
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
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
    <form id="form1" runat="server">
    <div>
    </div>
    <div>
    </div>
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                 <h2>订单统计</h2>
                                    <div class="lie_fl">
                                        筛选条件：按<asp:DropDownList ID="drTimeType" runat="server">
                                            <asp:ListItem Value="0" Text="付款时间"></asp:ListItem>
                                            <asp:ListItem Value="1" Text="下单时间"></asp:ListItem>
                                        </asp:DropDownList>
                                        日期：<input id="beginTime" type="text"  style="margin-right:0px;" runat="server" onclick="WdatePicker();" class="h-input" />--<input
                                            id="endTime" type="text" runat="server" onclick="WdatePicker();" class="h-input" />
                                        订单状态:
                                        <asp:DropDownList ID="ddlstate" runat="server">
                                            <asp:ListItem Text="已支付" Value="0"></asp:ListItem>
                                            <asp:ListItem Text="未支付" Value="1"></asp:ListItem>
                                            <asp:ListItem Text="已退款" Value="2"></asp:ListItem>
                                            <asp:ListItem Text="已取消" Value="3"></asp:ListItem>
                                        </asp:DropDownList>
                                        &nbsp;&nbsp; 发货状态:
                                        <asp:DropDownList ID="drExpress_id" runat="server">
                                            <asp:ListItem Text="-------" Value=""></asp:ListItem>
                                            <asp:ListItem Text="未发货" Value="0"></asp:ListItem>
                                            <asp:ListItem Text="已发货" Value="1"></asp:ListItem>
                                        </asp:DropDownList>
                                        &nbsp;&nbsp;
                                    </div>
                                    <div class="lie_fl">
                                        筛选条件：付款方式:
                                        <asp:DropDownList ID="drSeviceWhere" runat="server">
                                            <asp:ListItem Text="-------" Value=""></asp:ListItem>
                                            <asp:ListItem Text="易宝" Value="yeepay"></asp:ListItem>
                                            <asp:ListItem Text="支付宝" Value="alipay"></asp:ListItem>
                                            <asp:ListItem Text="财付通" Value="tenpay"></asp:ListItem>
                                            <asp:ListItem Text="移动支付" Value="chinamobilepay"></asp:ListItem>
                                            <asp:ListItem Text="网银在线" Value="chinabank"></asp:ListItem>
                                            <asp:ListItem Text="货到付款" Value="cashondelivery"></asp:ListItem>
                                            <asp:ListItem Text="余额付款" Value="credit"></asp:ListItem>
                                            <asp:ListItem Text="线下支付" Value="cash"></asp:ListItem>
                                            <asp:ListItem Text="未选择" Value="0"></asp:ListItem>
                                        </asp:DropDownList>
                                        &nbsp; 用户ID：<input id="userid" type="text" runat="server" class="h-input" />&nbsp; 城市：<asp:DropDownList
                                            ID="ddlcity" runat="server">
                                        </asp:DropDownList>
                                        &nbsp; 递送方式：<asp:DropDownList ID="ddlExpress" runat="server">
                                            <asp:ListItem Text="--------" Value=""></asp:ListItem>
                                            <asp:ListItem Text="快递" Value="Y"></asp:ListItem>
                                            <asp:ListItem Text="站内券" Value="N"></asp:ListItem>
                                            <asp:ListItem Text="站外券" Value="P"></asp:ListItem>
                                            <asp:ListItem Text="抽奖" Value="D"></asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="lie_fl">
                                        统计依据：
                                        <asp:CheckBox ID="checkCity" runat="server" Text="城市ID" />&nbsp;<asp:CheckBox ID="checkFromdomain"
                                            runat="server" Text="来源地址" />&nbsp;<asp:CheckBox ID="checkService" runat="server"
                                                Checked="false" Text="付款方式" />
                                        &nbsp;<asp:CheckBox ID="checkExpress" runat="server" Checked="false" Text="递送方式" />&nbsp;<asp:CheckBox
                                            ID="checkUser" runat="server" Checked="false" Text="用户ID" />
                                        &nbsp;付款时间:<asp:DropDownList ID="drPayTime" runat="server">
                                            <asp:ListItem Text="-----" Value=""></asp:ListItem>
                                            <asp:ListItem Text="年" Value="year"></asp:ListItem>
                                            <asp:ListItem Text="月" Value="month"></asp:ListItem>
                                            <asp:ListItem Text="日" Value="day"></asp:ListItem>
                                            <asp:ListItem Text="时" Value="hour"></asp:ListItem>
                                        </asp:DropDownList>
                                        &nbsp;下单时间:
                                        <asp:DropDownList ID="drCreateTime" runat="server">
                                            <asp:ListItem Text="-----" Value=""></asp:ListItem>
                                            <asp:ListItem Text="年" Value="year"></asp:ListItem>
                                            <asp:ListItem Text="月" Value="month"></asp:ListItem>
                                            <asp:ListItem Text="日" Value="day"></asp:ListItem>
                                            <asp:ListItem Text="时" Value="hour"></asp:ListItem>
                                        </asp:DropDownList>
                                        &nbsp;
                                        <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" class="formbutton"
                                            Text="统计" style="padding: 1px 6px; width: 60px;" />
                                        &nbsp;
                                        <asp:Button ID="btnDown" runat="server" class="formbutton" Text="下载" OnClick="btnDown_Click" style="padding: 1px 6px; width: 60px;" />
                                    </div>
                                    <div class="lie_fl">
                                        <br />
                                        <asp:Label ID="msg" runat="server"></asp:Label></div>
                                </div>
                                <div class="sect">
                                    <div>
                                        <asp:GridView ID="GridView1" runat="server" AllowPaging="True" EnableModelValidation="True"
                                            OnPageIndexChanging="GridView1_PageIndexChanging" PageSize="30" AllowSorting="True"
                                            Height="25px" OnSorting="GridView1_Sorting" Width="100%" OnRowDataBound="GridView1_RowDataBound">
                                            <AlternatingRowStyle Width="100px" BackColor="White" />
                                            <HeaderStyle Font-Bold="True" ForeColor="Black" Height="30px" />
                                            <PagerSettings FirstPageText="首页&amp;nbsp;&amp;nbsp;" LastPageText="尾页&amp;nbsp;&amp;nbsp;"
                                                NextPageText="下一页&amp;nbsp;&amp;nbsp;" PreviousPageText="上一页&amp;nbsp;&amp;nbsp;"
                                                Mode="NextPreviousFirstLast" />
                                            <PagerStyle Height="25px" HorizontalAlign="Right" ForeColor="Black" />
                                            <RowStyle Width="100px" Height="25px" />
                                        </asp:GridView>
                                    </div>
                                </div>
                            </div>
                            <div class="">
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
