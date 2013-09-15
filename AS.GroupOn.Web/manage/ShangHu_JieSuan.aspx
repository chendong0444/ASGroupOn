<%@ Page Language="C#" AutoEventWireup="true"  Inherits ="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.GroupOn.Domain.Spi" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script  runat="server">
    
    protected IPagers<IPartner> pager = null;
    protected IList<IPartner> iListPartner = null;
    protected int Branch = 0;
    protected string pagerHtml = String.Empty;
    protected string pagePar = "";
    protected int id = 0;
    protected string selTxt = string.Empty;
    protected string select_type = string.Empty;
    protected string url = "";
    protected UserFilter uf = new UserFilter();
 
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);


        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Partner_JiesuanBasicInfo))
        {
            SetError("你不具有查看商户结算的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        PartnerFilter filter = new PartnerFilter();

        selTxt = Request.QueryString["memail"];
        select_type = Request.QueryString["select_type"];
       
        if (!string.IsNullOrEmpty(select_type))
        {
           
            if (!string.IsNullOrEmpty(selTxt))
            {
                //根据商户id查询
                if (select_type == "1")
                {
                    url=url+"&select_type="+Request.QueryString["select_type"];
                    filter.Id = Helper.GetInt(selTxt, 0);
                }
                //根据商户名称查询
                else if (select_type == "2")
                {
                     url=url+"&select_type="+Request.QueryString["select_type"];
                    filter.Title = selTxt;
                }
                //根据联系人查询
                else if (select_type == "3")
                {
                     url=url+"&select_type="+Request.QueryString["select_type"];
                    filter.Contact = selTxt;
                }
                
                url=url+"&memail="+Request.QueryString["memail"];
            }
            
        }
        
        url = url + "&page={0}";
        url = "ShangHu_JieSuan.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(PartnerFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Partners.GetPager(filter);
        }
        iListPartner = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);   
    }
</script>

<%LoadUserControl("_header.ascx", null); %>

<body class="newbie"> 
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
                                       商户结算</h2>
                                       <form id="form1" runat="server" method="get">
                                <div class="search">
                                   <select id="Select1" name="select_type">
                                                <option value="">请选择</option>
                                                <option value="1" <%if(Request.QueryString["select_type"] == "1"){%> selected="selected"<%} %>>商户ID</option>
                                                <option value="2" <%if(Request.QueryString["select_type"] == "2"){%> selected="selected"<%} %>>商户名称</option>
                                                <option value="3" <%if(Request.QueryString["select_type"] == "3"){%> selected="selected"<%} %>>联系人</option>
                                            </select>
                                            &nbsp;<input type="text" name="memail" <%if(!string.IsNullOrEmpty(Request.QueryString["memail"])){ %> value='<%=Request.QueryString["memail"] %>'<%} %> class="h-input" />&nbsp;
                                            <input type="submit" value="筛选" class="formbutton" name="btnselect" style="padding: 1px 6px;" />

                                <ul class="filter" >
                                <li>
                                         
                               </li>
                                    </ul>
                                </div>
                                </form>
                                </div>

                             
                                <div class="sect">

                                    <table id="Table1" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='15%'>
                                                商户ID
                                            </th>
                                            <th width='20%'>
                                                商户名称
                                            </th>
                                            <th width='15%'>
                                               联系人
                                            </th>
                                            <th width='15%'>
                                                销售人员
                                            </th>
                                            <th width='20%'>
                                                银行信息
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                       <%
                                            int i = 2;

                                            if (iListPartner != null && iListPartner.Count > 0)
                                            {
                                                foreach (IPartner partner in iListPartner)
                                                {
                                                    if (i % 2 != 0)
                                                    {
                                                  %>
                                               <tr >
                                                <%}
                                                    else
                                                    { %>
                                                <tr class="alt">
                                                <%} i++;%>
                                                <td><%=partner.Id%></td>

                                                <td><%=partner.Title%></td>

                                                <td><%=partner.Contact%></td>
                                         
                                                <!--销售人员-->
                                                <td><%=partner.getRealName%></td>
                                                <td>
                                                    开户行：<%=partner.Bank_name%><br>
                                                    银行账号：<%=partner.Bank_no%><br>
                                                    开户名：<%=partner.Bank_user%>
                                                
                                                </td>

                                                 <td >
                                                    <a href='JieSuan_ShenHe.aspx?Id=<%=partner.Id.ToString() %>'>详情</a>
                                                    <%
//状态为待审核的商户
if (partner.getPartnerState > 0)
{%>
                                                      (<a href='JieSuan_ShenHe.aspx?Id=<%=partner.Id %>&key=1'>待审核</a><%=partner.getPartnerState%>)
                                                     <%} %>
                                                    </td>
                                            </tr> 
                                          <%}
                                            }
                               %>
                    
                                        <tr>
                                            <td colspan="10">
                                                <%=pagerHtml%>
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
</body>
<%LoadUserControl("_footer.ascx", null); %>
