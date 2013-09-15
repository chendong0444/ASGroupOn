<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage"  %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected IPagers<ISmssubscribe> pager = null;
    protected IList<ISmssubscribe> ilistSmssubscribe = null;
    protected SmssubscribeFilter filter = new SmssubscribeFilter();
    protected string pagepar = "";
    protected string PageHtml = String.Empty;
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "短信订阅列表";
        id = AS.Common.Utils.Helper.GetInt(Request["remove"], 0);
       
        int delete = 0;
            if (id > 0)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    delete = session.Smssubscribe.Delete(id);
                }
                if (delete > 0)
                {
                    SetSuccess("删除成功");
                }
                else
                {
                    SetError("删除失败");
                }
                Response.Redirect("Index_DuanxinDingyue.aspx");
                Response.End();
                return;
            }
        if (!string.IsNullOrEmpty(Request["txtcity"])) 
        {
            filter.City_id = Convert.ToInt32(Request["txtcity"]);
            pagepar = pagepar + " &City_id=" + Request["txtcity"];
        }
        if (!string.IsNullOrEmpty(Request["txtmobile"])) 
        {
            filter.Mobile = Request["txtmobile"];
            pagepar = pagepar + " &Mobile=" + Request["txtmobile"];
        }
        pagepar = pagepar + "&page={0}" + pagepar;
        pagepar = "Index_DuanxinDingyue?" + pagepar;
        filter.PageSize = 30;
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        filter.AddSortOrder(SmssubscribeFilter.ID_DESC);
        filter.City_id = AsAdmin.City_id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Smssubscribe.GetPager(filter);
        }
        ilistSmssubscribe = pager.Objects;
        PageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, pagepar);
    }
</script>
<%LoadUserControl("_header.ascx", null);%>
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
      <div id="content" class="coupons-box clear mainwide">
            <div class="box clear">
                <div class="box-content">
                    <div class="head">
                        <h2>
                            短信订阅列表
                            <ul style="text-align:right">
                                <li><%--城市ID：
                                    <input type="text" id="txtcity" name="txtcity"  CssClass="h-input" value="<%=Request["txtcity"] %>" />--%>
                                    &nbsp;手机号：
                                    <input type="text" id="txtmobile" name="txtmobile" class="h-input" value="<%=Request["txtmobile"] %>" />
                                    &nbsp;
                                    <input type="submit" value="筛选" class="formbutton" style="padding: 1px 6px;" />
                                </li>
                            </ul>
                        </h2>
                    </div>
                    <div class="sect">
                            <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                            <tr>
                                <th>手机号</th>
                                <th>城市</th>
                                <th>密钥</th>
                                <th>操作</th>
                            </tr>
                            <%
                                int i = 0;
                                foreach (ISmssubscribe item in ilistSmssubscribe)
                               {
                                   if (i % 2 == 0)
                                   {
                                    %>
                               <tr class="alt">
                               <%}
                                   else
                                   { %>
                                   <tr>
                               <%} i++; %>
                                    <td><%=item.Mobile %></td>
                                    <td><%
                                    if(item.getCityName!=null){%>
                                        <%=item.getCityName.Name %>
                                    <%}else{%>
                                        全部城市
                                    <%} %>
                                    </td>
                                    <td><%=item.Secret %></td>
                                    <td><a ask="你确定要删除吗" href="Index_DuanxinDingyue.aspx?remove=<%=item.Id %>">删除</a></td>
                               </tr>
                               <%} %>
                            </table>
                    </div>
                </div>
            </div>
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>

