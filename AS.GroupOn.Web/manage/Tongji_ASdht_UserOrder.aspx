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
    protected DateTime? d = null;
    protected DateTime? ed = null;
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
            initPage();
        }
    }
    private void initPage()
    {
        if (beginTime.Value != "")
        {
            d = Helper.GetDateTime(Convert.ToDateTime(this.beginTime.Value).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
        }
        if (endTime.Value != "")
        {
            ed = Helper.GetDateTime(Convert.ToDateTime(this.endTime.Value).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
        }
        string sql = String.Format("select  username as '用户名', count([Order].id) as '下单数', ocount '总订单数' from (SELECT  uid, username, ocount FROM (SELECT  [User].Id AS uid, [User].Username AS username, COUNT([Order].Id) AS ocount FROM [Order] INNER JOIN [User] ON [Order].User_id = [User].Id WHERE ([Order].State = 'pay')  GROUP BY [User].Username, [User].Id) AS tt) v_tt, [order]  where uid=[Order].User_id and [Order].state='pay'  and Create_time >=' {0} ' and Create_time <='{1} 'group by v_tt.uid,v_tt.username,v_tt.ocount ", d, ed);
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            dt = session.GetData.GetDataList(sql);
        }
        this.GridView.DataSource = Helper.ConvertDataTable(dt);
        this.GridView.DataBind();

    }
    protected void GridView_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        this.GridView.PageIndex = e.NewPageIndex;
        initPage();
    }
    protected void btnDown_Click(object sender, EventArgs e)
    {
        StringBuilder sb1 = new StringBuilder();
        if (beginTime.Value != "")
        {
            d = Helper.GetDateTime(Convert.ToDateTime(this.beginTime.Value).ToString("yyyy-MM-dd 00:00:00"), DateTime.Now);
        }
        if (endTime.Value != "")
        {
            ed = Helper.GetDateTime(Convert.ToDateTime(this.endTime.Value).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
        }
        string sql = String.Format("select  username as '用户名', count([Order].id) as '下单数', ocount '总订单数' from (SELECT  uid, username, ocount FROM (SELECT  [User].Id AS uid, [User].Username AS username, COUNT([Order].Id) AS ocount FROM [Order] INNER JOIN [User] ON [Order].User_id = [User].Id WHERE ([Order].State = 'pay')  GROUP BY [User].Username, [User].Id) AS tt) v_tt, [order]  where uid=[Order].User_id and [Order].state='pay'  and Create_time >=' {0} ' and Create_time <='{1} 'group by v_tt.uid,v_tt.username,v_tt.ocount ", d, ed);
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            dt = session.GetData.GetDataList(sql);
        }
        sb1.Append("<html>");
        sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
        sb1.Append("<body><table border=\'1\'>");
        sb1.Append("<tr>");
        sb1.Append("<td>ID</td>");

        if (dt[0]["用户名"] != null)
        {
            sb1.Append("<td align='left'>用户名</td>");
        }
        if (dt[0]["手机号码"] != null)
        {
            sb1.Append("<td align='left'>手机号码</td>");
        }
        if (dt[0]["下单数"] != null)
        {
            sb1.Append("<td align='left'>下单数</td>");
        }
        if (dt[0]["总订单数"] != null)
        {
            sb1.Append("<td align='left'>总订单数</td>");
        }
        sb1.Append("</tr>");
        for (int i = 0; i < dt.Count; i++)
        {
            sb1.Append("<tr>");
            sb1.Append("<td>" + (i + 1).ToString() + "</td>");
            if (dt[i]["用户名"] != null)
            {
                sb1.Append("<td align='left'>" + dt[i]["用户名"] + "</td>");
            }
            if (dt[i]["手机号码"] != null)
            {
                sb1.Append("<td align='left'>" + dt[i]["手机号码"] + "</td>");
            }
            if (dt[i]["下单数"] != null)
            {
                sb1.Append("<td align='left'>" + dt[i]["下单数"] + "</td>");
            }
            if (dt[i]["总订单数"] != null)
            {
                sb1.Append("<td align='left'>" + dt[i]["总订单数"] + "</td>");
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
        Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("tongji_user_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
        Response.ContentType = "Application/octet-stream";
        //文件内容
        Response.Write(sb1.ToString());
        Response.End();
    }
    protected void BtnCount_Click(object sender, EventArgs e)
    {
        initPage();
    }
    protected void GridView_Sorting(object sender, GridViewSortEventArgs e)
    {
        initPage();
        e.SortDirection = SortDirection.Descending;
    }
    protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            System.Data.DataRowView dr = (System.Data.DataRowView)e.Row.DataItem;
            if (dr.Row.Table.Columns["用户名"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("用户名")].Text = dr["用户名"].ToString();
            }
            if (dr.Row.Table.Columns["手机号码"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("手机号码")].Text = dr["手机号码"].ToString();
            }
            if (dr.Row.Table.Columns["下单数"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("下单数")].Text = dr["下单数"].ToString() + "个";
            }
            if (dr.Row.Table.Columns["总订单数"] != null)
            {
                e.Row.Cells[dr.Row.Table.Columns.IndexOf("总订单数")].Text = dr["总订单数"].ToString() + "个";
            }
        }
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
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
                                        用户订单统计</h2>
                                         <div class="lie_fl">
                                    筛选条件：下单日期：<input id="beginTime" type="text" style="margin-right:0px;" runat="server" onclick="WdatePicker();" class="h-input" />--<input
                                        id="endTime" type="text" runat="server" onclick="WdatePicker();" class="h-input" />&nbsp;&nbsp;
                                    &nbsp;&nbsp; &nbsp;
                                    <asp:Button ID="BtnCount" runat="server" OnClick="BtnCount_Click" class="formbutton"
                                        Text="统计"  style="padding: 1px 6px; width: 60px;" />
                                    &nbsp;
                                    <asp:Button ID="btnDown" runat="server" class="formbutton" Text="下载" OnClick="btnDown_Click" style="padding: 1px 6px; width: 60px;" />
                                </div>
                                <div class="lie_fl">
                                </div>
                                </div>
                               
                                <div class="sect">
                                    <div>
                                        <asp:GridView ID="GridView" runat="server" AllowPaging="True" EnableModelValidation="True"
                                            OnPageIndexChanging="GridView_PageIndexChanging" PageSize="30" AllowSorting="True"
                                            Height="22px" OnSorting="GridView_Sorting" Width="100%" OnRowDataBound="GridView_RowDataBound">
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
