<%@ Page Language="C#" AutoEventWireup="true"  Inherits="AS.GroupOn.Controls.AdminPage"  %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
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
        if(AdminPage.IsAdmin && AdminPage .CheckUserOptionAuth(PageValue.CurrentAdmin,ActionEnum.Option_EmailSubscribe_ListView))
        {
            SetError("没有查看邮件订阅列表的权限");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        id = AS.Common.Utils.Helper.GetInt(Request["remove"], 0);

        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_EmailSubscribe_Delete))
        {
            SetError("没有删除邮件订阅列表的权限");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        else
        {
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
                }
                else
                {
                    SetError("删除失败");
                }
                Response.Redirect("Index-youjiandingyue.aspx");
                Response.End();
                return;
            }

        }
        if (!string.IsNullOrEmpty(Request.QueryString["Delstr"]))
        {
            bool state = false;
            int num = AS.Common.Utils.Helper.GetInt(Request.QueryString["num"],0);
            string str = AS.Common.Utils.Helper.GetString(Request.QueryString["Delstr"], String.Empty);
            int count = 0;
            string[] strall = str.Split(',');   
             foreach (string ss in strall)
	            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    count = session.Mailers.Delete(AS.Common.Utils.Helper.GetInt(ss, 0));
                    state = true;
                }
            }
            if (state)
            {
                SetSuccess("删除成功,共删除" + num + "条记录");
            }
            else 
            {
                SetError("删除失败");
            }
            Response.Redirect(WebRoot + "manage/Index-youjiandingyue.aspx");
            Response.End();
            return;
        }
        if (!string.IsNullOrEmpty(Request.Form["city_id"]))
        {
            filter.cityid = AS.Common.Utils.Helper.GetInt(Request.Form["city_id"], 0);
            pagepar = pagepar + "&city_id=" + AS.Common.Utils.Helper.GetInt(Request.Form["city_id"], 0);
        }
        else if (!string.IsNullOrEmpty(Request.QueryString["city_id"]) && Request.Form["city_id"] != String.Empty)
        {
            filter.cityid = AS.Common.Utils.Helper.GetInt(Request.QueryString["city_id"], 0);
            pagepar = pagepar + "&city_id=" + AS.Common.Utils.Helper.GetInt(Request.QueryString["city_id"], 0);
        }
        if (!string.IsNullOrEmpty(Request.Form["txtemail"]))
        {
            filter.Email = AS.Common.Utils.Helper.GetString(Request.Form["txtemail"], "");
            pagepar = pagepar + "&txtemail=" + AS.Common.Utils.Helper.GetString(Request.Form["txtemail"], "");
        }
        else if (!string.IsNullOrEmpty(Request.QueryString["txtemail"]) && Request.Form["txtemail"] != String.Empty)
        {
            filter.Email = AS.Common.Utils.Helper.GetString(Request.QueryString["txtemail"], "");
            pagepar = pagepar + "&txtemail=" + AS.Common.Utils.Helper.GetString(Request.QueryString["txtemail"], "");
        }
        pagepar = pagepar+"&page={0}";
        pagepar = "Index-youjiandingyue.aspx?" + pagepar.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(MailerFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using(IDataSession session = AS.GroupOn .App .Store .OpenSession(false))
        {
            pager = session .Mailers .GetPager(filter);
        }
        ilistMailer = pager.Objects;
        PageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, pagepar);
        
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    $(function () {
        $("#checkall").click(function () {
            $("input[id='check']").attr("checked", $("#checkall").attr("checked"));
        });
    })
    function GetAllId() {
        var s = "";
        var num = 0;
        $("input[id='check']:checked").each(function () {
            s += $(this).val() + ","
            num += 1;
        });
        if (num > 0) {
            if (confirm("确定删除所选中的邮件?")) {
                window.location = "/manage/Index-youjiandingyue.aspx?Delstr=" + s + "&num=" + num;
            }
        }
    }

</script>
<head>
    <title></title>
</head>
<body>
    <form id="form1" action=""  class="validator" method="post">
     <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
    <div id="bdw" class="bdw">
    <div id="bd" class="cf">
    <div id="coupons">
    <input type="hidden" name="action" value="DelYoujian" />
    <div id="content" class="coupons-box clear mainwide">
		<div class="box clear">            
            <div class="box-content">
                <div class="head">
                    <h2>邮件订阅列表</h2>
					<ul class="search">
						<li>城市ID:      
                            <input type="text" class="h-input" id="city_id" name="city_id" datatype="number"  value="<%=Request.Form["city_id"]==null?Request.QueryString["city_id"]:Request.Form["city_id"]%>"/>
                        &nbsp;邮件:                                    
                          <input type="text" class="h-input" id="txtemail" name="txtemail"  value="<%=Request.Form["txtemail"]==null?Request.QueryString["txtemail"]:Request.Form["txtemail"]%>"  />
                        &nbsp;<input type="submit" value="筛选" class="formbutton validator" group="a"  style="padding:1px 6px;"/></li>
					</ul>
				</div>
                <div class="sect">
                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                        <tr style="text-align:center">
                            <th width="10%"><input type="checkbox" name="checkall" id="checkall"/>全选</th>
                            <th width="20%">邮件地址</th>
                            <th width="15%">城市</th>
                            <th width="20%">密钥</th>
                            <th width="10%">操作</th>
                        </tr>
                        <%
                            if (ilistMailer != null)
                            {
                                int i = 0;
                                foreach (IMailer item in ilistMailer)
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
                                <td><input type="checkbox" name="check" id="check" value="<%=item.Id %>"/></td>

                                  <td><%=item.Email%></td>
                                 <td>
                                  <%if (item.GetCityName != null)
                                    {
                                    %>
                                     <%=item.GetCityName.Name%>

                                    <%}
                                    else
                                    { %> 
                                    全国
                                    <%} %>
                                 </td>
                                  <td><%=item.Secret%></td>
                                  <td><a ask="确认删除吗？" href="Index-youjiandingyue.aspx?remove=<%=item.Id %>">删除</a></td>

                              </tr> 
                            <%}
                            }
                         %>
                            <tr>
                            <td colspan="5">
                                <% if (!PageHtml.Equals(""))
                                   {%>
                                    <input type="button" name="selectall" value="删除邮件" class="formbutton" onclick="javascript:GetAllId()" />
                                   <%=PageHtml%>
                                   <%}%>
                            </td>
                        </tr>
                    </table>
                </div>
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
