<%@ Page Language="C#" AutoEventWireup="true"  Inherits="AS.GroupOn.Controls.AdminPage"  %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected IPagers<IMailer> pager = null;
    protected IList<IMailer> ilistMailer = null;
    protected MailerFilter filter = new MailerFilter();
    protected string pagepar = "";
    protected string PageHtml = String.Empty;
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        id = AS.Common.Utils.Helper.GetInt(Request["remove"], 0);

            if (id > 0)
            {
                int delete = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    delete = session.Mailers.Delete(id);
                }
                if (delete > 0)
                {
                    SetSuccess("删除成功");
                    Response.Write("<script>alert('删除成功')</"+"script>");
                }
                else
                {
                    SetError("删除失败");
                    //Response.Write("<script>alert('删除失败')</" + "script>");
                }
                Response.Redirect("Index-youjiandingyue.aspx");
                Response.End();
                return;
            }


        if (!string.IsNullOrEmpty(Request["city_id"])) 
        {
            filter.City_id = Convert.ToInt32(Request["city_id"]);
            pagepar = pagepar + " &City_id = " + Request["city_id"];
            //filter.AddSortOrder(MailerFilter.ID_DESC);
        }
        if (!string.IsNullOrEmpty(Request["txtemail"])) 
        {
            filter.Email = Request["txtemail"];
            pagepar = pagepar + " &Email =" + Request["txtemail"];
        
        }
        pagepar = pagepar + "&page={0}" + pagepar;
        pagepar = "Index-youjiandingyue.aspx?" + pagepar;
        filter.PageSize = 30;
        filter.CurrentPage=AS.Common.Utils.Helper.GetInt(Request.QueryString["page"],1);
        filter.AddSortOrder(MailerFilter.ID_DESC);
        filter.City_id = AsAdmin.City_id;
        using(IDataSession session = AS.GroupOn .App .Store .OpenSession(false))
        {
            pager = session .Mailers .GetPager(filter);
        }
        ilistMailer = pager.Objects;
        PageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, pagepar);
        
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<head>
    <title></title>
</head>
<body>
    <form id="form1" action=""  class="validator" method="post" runat="server">
    <input type="hidden" name="action" value="DelYoujian" />
    <div id="content" class="coupons-box clear mainwide">
		<div class="box clear">            
            <div class="box-content">
                <div class="head">
                    <h2>邮件订阅列表</h2>
					<ul  style="text-align :right">
						<%--<li>城市ID：                      
                        <input type="text" id="city_id" name="city_id" CssClass="h-input" value="<%=Request["city_id"] %>"/>--%>
                        &nbsp;邮件：                                         
                          <input type="text" id="txtemail" name="txtemail" class="h-input" value="<%=Request["txtemail"] %>"  />
                        &nbsp;<input type="submit" value="筛选" class="formbutton validator" group="a"  style="padding:1px 6px;"/></li>
					</ul>
				</div>
                <div class="sect">
                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                        <tr style="text-align:center">
                            <th>邮件地址</th>
                            <th>城市</th>
                            <th>密钥</th>
                            <th>操作</th>
                        </tr>
                        <%
                            int i = 0;
                            foreach (IMailer  item in ilistMailer)
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
                                  <td><%=item.Email %></td>
                                 <td>
                                  <%if (item.GetCityName != null)
                                    {
                                    %>
                                     <%=item.GetCityName.Name %>

                                    <%}else{ %> 
                                    全国
                                    <%} %>
                                 </td>
                                  <td><%=item.Secret %></td>
                                  <td><a ask="确认删除吗？" href="Index-youjiandingyue.aspx?remove=<%=item.Id %>">删除</a></td>

                              </tr> 
                            <%}
                         %>
                            <tr>
                            <td colspan="8">
                                <ul class="paginator" style="width:100%;">
                                    <li class="current" style="float:right">
                                        <%=PageHtml%>
                                    </li>
                                </ul>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
