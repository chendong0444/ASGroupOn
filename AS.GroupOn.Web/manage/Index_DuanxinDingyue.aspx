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
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_SmsSubscribe_ListView)) 
        {
            SetError("您不具备查看短信订阅列表的权限!");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        id = AS.Common.Utils.Helper.GetInt(Request["remove"], 0);
       
        int delete = 0;
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_SmsSubscribe_Delete))
        {
            SetError("您不具备删除短信订阅列表的权限!");
            Response.Redirect("index_index.aspx");
        }
        else
        {
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
        }
        //批量删除短信订阅
        if (!string.IsNullOrEmpty(Request.QueryString["str"])) 
        {
            int num = AS.Common.Utils.Helper.GetInt(Request.QueryString["num"],0);
            string strs = AS.Common.Utils.Helper.GetString(Request.QueryString["str"], String.Empty);
            string[] strall = strs.Split(',');
            int count = 0;
            bool states = false;
            foreach (string  item in strall){
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                {
                    count = session.Smssubscribe.Delete(AS.Common.Utils.Helper.GetInt(item, 0));
                    states = true;
                }
            }
            if (states)
            {
                SetSuccess("删除成功,共删除" + num + "条记录");
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
            pagepar = pagepar + "&txtcity=" + Request["txtcity"];
        }
        if (!string.IsNullOrEmpty(Request["txtmobile"])) 
        {
            filter.Mobile = Request["txtmobile"];
            pagepar = pagepar + "&txtmobile=" + Request["txtmobile"];
        }
        pagepar = pagepar + "&page={0}";
        pagepar = "Index_DuanxinDingyue.aspx?" + pagepar.Substring(1);
        filter.PageSize = 30;
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        filter.AddSortOrder(SmssubscribeFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Smssubscribe.GetPager(filter);
        }
        ilistSmssubscribe = pager.Objects;
        PageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, pagepar);
    }
</script>
<%LoadUserControl("_header.ascx", null);%>

<script type="text/javascript" language="javascript">
    $(function () {
        $("#checkall").click(function () {
            $("input[id='check']").attr("checked", $("#checkall").attr("checked"));
        });
    });

    function Deldingyue() {
        var s = ""; //拼接ID
        var num = 0;
        $("input[id='check']:checked").each(function () {
            s += $(this).val() + ",";
            num += 1;
        })
        if (num > 0) {
            if(confirm("确定删除所选?")){
                window.location="/manage/Index_DuanxinDingyue.aspx?str=" + s + "&num=" + num;
            }
         }
     
     }

</script>

<body>
    <form id="form1">
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
                            短信订阅列表
                            
                        </h2>
                        <div class="search">城市ID:
                                    <input type="text" maxlength="10" class="h-input" id="txtcity" name="txtcity"  value="<%=Request["txtcity"] %>" />
                                    &nbsp;手机号:
                                    <input type="text" datatype="mobile" class="h-input" id="txtmobile" name="txtmobile" value="<%=Request["txtmobile"] %>" />
                                    &nbsp;
                                    <input type="submit" value="筛选" class="formbutton" style="padding: 1px 6px;" /></div>
                        
                    </div><ul style="text-align:right">
                                <li>
                                </li>
                            </ul>
                    <div class="sect">
                        <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                            <tr>
                                <th><input type="checkbox" name="checkall" id="checkall" />全选</th>
                                <th width="20%">手机号</th>
                                <th width="20%">城市</th>
                                <th width="20%">密钥</th>
                                <th width="20%">操作</th>
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
                                    <td><input type="checkbox" value="<%=item.Id %>" name="check" id="check"/></td>
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
                               <tr>
                               <% if(PageHtml!=""){ %>
                                    <td>
                                    <input type="button" value="删除订阅" onclick="javascript:Deldingyue()" class="formbutton" />
                                    </td>
                                    <td colspan="4">
                                    <%=PageHtml %>
                                    </td>
                                    <%} %>
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

