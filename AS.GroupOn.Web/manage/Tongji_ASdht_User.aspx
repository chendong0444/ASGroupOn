<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
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
    protected List<Hashtable> dt = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TJ_UserReister))
        {
            SetError("你不具有查看用户注册统计的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (!Page.IsPostBack)
        {
            beginTime.Value = DateTime.Now.ToShortDateString();
            endTime.Value = DateTime.Now.ToShortDateString();
            initPage();
        }
    }
    private void initPage()
    {
        string strFromDomain = Request.Form["checkFromdomain"];
        string strYear = Request.Form["checkYear"];
        string strMoth = Request.Form["checkMonth"];
        string strDay = Request.Form["checkDay"];
        string strSql = "";
        string strGroup = "";
        string orderstr = "";
        string where = " where 1=1 ";
        strSql = "select count(*) as '数量'";
        if (strYear != null && strYear != "")
        {
            if (strYear == "on")
            {
                strSql = strSql + ", year(Create_time) as '年' ";
                strGroup = strGroup + ",year(Create_time)";
                orderstr = orderstr + ",year(Create_time) desc";
            }
        }
        if (strMoth != null && strMoth != "")
        {
            if (strMoth == "on")
            {
                strSql = strSql + ", month(Create_time) as '月' ";
                strGroup = strGroup + ",month(Create_time)";
                orderstr = orderstr + ",month(Create_time) desc";
            }
        }
        if (strDay != null && strDay != "")
        {
            if (strDay == "on")
            {
                strSql = strSql + ", day(Create_time) as '日' ";
                strGroup = strGroup + ",day(Create_time)";
                orderstr = orderstr + ",day(Create_time) desc";
            }
        }
        if (strFromDomain != null && strFromDomain != "")
        {
            if (strFromDomain == "on")
            {
                strSql = strSql + ",fromdomain as '来源地址' ";
                strGroup = strGroup + ",fromdomain";
                orderstr = orderstr + ",fromdomain desc";
            }
        }
        strSql = strSql + "  from [User] ";
        if (beginTime.Value != "")
        {
            where = where + " and Create_time >='" + beginTime.Value + "'";
        }
        if (endTime.Value != "")
        {
            string endtime = DateTime.Parse(endTime.Value).AddDays(1).ToString();
            where = where + " and Create_time <='" + endtime + "'";

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
            dt = session.GetData.GetDataList(strSql); 
        }
        this.GridView1.DataSource = AS.Common.Utils.Helper.ConvertDataTable(dt);
        this.GridView1.DataBind();

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
        initPage();
        e.SortDirection = SortDirection.Descending;
    }
    protected void btnDown_Click(object sender, EventArgs e)
    {
        StringBuilder sb1 = new StringBuilder();
        string strFromDomain = Request.Form["checkFromdomain"];
        string strYear = Request.Form["checkYear"];
        string strMoth = Request.Form["checkMonth"];
        string strDay = Request.Form["checkDay"];
        string strSql = "";
        string strGroup = "";
        string orderstr = "";
        string where = " where 1=1 ";
        strSql = "select count(*) as '数量'";
        if (strYear != null && strYear != "")
        {
            if (strYear == "on")
            {
                strSql = strSql + ", year(Create_time) as '年' ";
                strGroup = strGroup + ",year(Create_time)";
                orderstr = orderstr + ",year(Create_time) desc";
            }
        }
        if (strMoth != null && strMoth != "")
        {
            if (strMoth == "on")
            {
                strSql = strSql + ", month(Create_time) as '月' ";
                strGroup = strGroup + ",month(Create_time)";
                orderstr = orderstr + ",month(Create_time) desc";
            }
        }
        if (strDay != null && strDay != "")
        {
            if (strDay == "on")
            {
                strSql = strSql + ", day(Create_time) as '日' ";
                strGroup = strGroup + ",day(Create_time)";
                orderstr = orderstr + ",day(Create_time) desc";
            }
        }
        if (strFromDomain != null && strFromDomain != "")
        {
            if (strFromDomain == "on")
            {
                strSql = strSql + ",IP_Address as '来源地址' ";
                strGroup = strGroup + ",IP_Address";
                orderstr = orderstr + ",IP_Address desc";
            }
        }
        strSql = strSql + "  from [User] ";
        if (beginTime.Value != "")
        {
            where = where + " and Create_time >='" + beginTime.Value + "'";
        }
        if (endTime.Value != "")
        {
            string endtime = DateTime.Parse(endTime.Value).AddDays(1).ToString();
            where = where + " and Create_time <='" + endtime + "'";
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
            dt = session.GetData.GetDataList(strSql); 
        }
        sb1.Append("<html>");
        sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
        sb1.Append("<body><table border=\'1\'>");
        sb1.Append("<tr>");
        sb1.Append("<td>ID</td>");
        if (dt[0]["年"] != null)
        {
            sb1.Append("<td align='left'>年</td>");
        }
        if (dt[0]["月"] != null)
        {
            sb1.Append("<td align='left'>月</td>");
        }
        if (dt[0]["日"] != null)
        {
            sb1.Append("<td align='left'>日</td>");
        }

        if (dt[0]["来源地址"] != null)
        {
            sb1.Append("<td align='left'>来源地址</td>");
        }

        if (dt[0]["数量"] != null)
        {
            sb1.Append("<td align='left'>数量</td>");
        }


        sb1.Append("</tr>");
        for (int i = 0; i < dt.Count; i++)
        {
            sb1.Append("<tr>");
            sb1.Append("<td>" + (i + 1).ToString() + "</td>");
            if (dt[i]["年"] != null)
            {
                sb1.Append("<td align='left'>" + dt[i]["年"] + "</td>");
            }
            if (dt[i]["月"] != null)
            {
                sb1.Append("<td align='left'>" + dt[i]["月"] + "</td>");
            }
            if (dt[i]["日"] != null)
            {
                sb1.Append("<td align='left'>" + dt[i]["日"] + "</td>");
            }

            if (dt[i]["来源地址"] != null)
            {
                sb1.Append("<td align='left'>" + dt[i]["来源地址"] + "</td>");
            }

            if (dt[i]["数量"] != null)
            {
                sb1.Append("<td align='left'>" + dt[i]["数量"] + "</td>");
            }
            sb1.Append("</tr>");
        }
        sb1.Append("</table></body></html>");
        Response.ClearHeaders();
        Response.Clear();
        Response.Expires = 0;
        Response.Buffer = true;
        Response.AddHeader("Accept-Language", "zh-tw");
        Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("tongji_user_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
        Response.ContentType = "Application/octet-stream";
        Response.Write(sb1.ToString());
        Response.End();

    }
    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            System.Data.DataRowView dr = (System.Data.DataRowView)e.Row.DataItem;
            if (dr.Row.Table.Columns["年"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("年")].Text = dr["年"].ToString() + "年";
            }
            if (dr.Row.Table.Columns["月"] != null)
            {
                string month = dr["月"].ToString();
                if (month.Length == 1)
                {
                    month = "0" + month;
                }
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("月")].Text = month + "月";
            }
            if (dr.Row.Table.Columns["日"] != null)
            {
                string day = dr["日"].ToString();
                if (day.Length == 1)
                {
                    day = "0" + day;
                }
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("日")].Text = day + "日";
            }
            if (dr.Row.Table.Columns["数量"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("数量")].Text = dr["数量"].ToString() + "个";
            }
        }
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
                                  <h2>
                                        用户注册统计</h2>
                                         <div class="lie_fl">
                                        筛选条件：注册日期：<input id="beginTime" type="text" style="margin-right:0px;" runat="server" onclick="WdatePicker();"  class="h-input" />--<input
                                            id="endTime" type="text" runat="server" onclick="WdatePicker();"  class="h-input" />
                                    </div>
                                    <div class="lie_fl">
                                        统计依据：<asp:CheckBox ID="checkFromdomain" runat="server" Text="来源地址" />&nbsp;&nbsp;
                                        <asp:CheckBox ID="checkYear" runat="server" Checked="false" Text="年" />&nbsp;&nbsp;
                                        <asp:CheckBox ID="checkMonth" runat="server" Checked="false" Text="月" />&nbsp;&nbsp;
                                        <asp:CheckBox ID="checkDay" runat="server" Text="日" Checked="false" />
                                        &nbsp;
                                        <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" class="formbutton"
                                            Text="统计" style="padding: 1px 6px; width: 60px;" />
                                        &nbsp;
                                        <asp:Button ID="btnDown" runat="server" class="formbutton" Text="下载" OnClick="btnDown_Click" style="padding: 1px 6px; width: 60px;" />
                                    </div>
                                      <div class="lie_fl">
                                </div>
                                  </div>
                                   
                              
                                <div class="sect">
                                    <div>
                                        <asp:GridView ID="GridView1" runat="server" AllowPaging="True" EnableModelValidation="True"
                                            OnPageIndexChanging="GridView1_PageIndexChanging" PageSize="30" AllowSorting="True"
                                            Height="22px" OnSorting="GridView1_Sorting" Width="100%" OnRowDataBound="GridView1_RowDataBound">
                                            <AlternatingRowStyle Width="100px" BackColor="White" />
                                            <HeaderStyle Font-Bold="True" ForeColor="Black" Height="30px" />
                                            <PagerSettings FirstPageText="首页&amp;nbsp;&amp;nbsp;" LastPageText="尾页&amp;nbsp;&amp;nbsp;"
                                                NextPageText="下一页&amp;nbsp;&amp;nbsp;" PreviousPageText="上一页&amp;nbsp;&amp;nbsp;"
                                                Mode="NextPreviousFirstLast" />
                                            <PagerStyle HorizontalAlign="Right" Width="25px" ForeColor="Black" />
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
