<%@ Page Language="C#" AutoEventWireup="true" Inherits ="AS.GroupOn.Controls.AdminPage"%>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat="server">
    protected IPagers<IBranch> pager = null;
    protected IList<IBranch> ilistPartner = null;
    protected BranchFilter filter = new BranchFilter();
    protected string PageHtml = String.Empty;
    protected string pagePar = String.Empty;  
    public int partner_id = 0;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "分店管理";
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Branch_List))
        {
            SetError("你没有查看商户分店的权限");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request["update"] == "true")
        {
            SetSuccess("修改成功");
            Response.Redirect("ShangHuBranch.aspx?bid=" + Request["bid"]);
            Response.End();
            return;
        }
        else if (Request["update"] == "false")
        {
            SetSuccess("修改失败");
            Response.Redirect("ShangHuBranch.aspx?bid=" + Request["bid"]);
            Response.End();
            return;
        }
       int id =AS.Common.Utils.Helper.GetInt(Request["remove"],0);
       int count=0;
       if (id > 0)
       {
           if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Branch_Delete))
           {
               SetError("你没有删除分店信息的权限");
               Response.Redirect("index_index.aspx");
               Response.End();
               return;
           }
           else
           {

               using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
               {
                   count = session.Branch.Delete(id);
               }
               if (count > 0)
               {
                   SetSuccess("删除成功");
               }
               else
               {
                   SetError("删除失败");
               }
               string pid = Request["bid"];
               Response.Redirect("ShangHuBranch.aspx?bid=" + pid);
               Response.End();
               return;
           }
       }

       if (!string.IsNullOrEmpty(Request["bname"])) 
       {
           filter.branchname = Request["bname"];
           pagePar = pagePar + "&branchname=" + Request["bname"];
           filter.AddSortOrder("branchname");
       }
        pagePar = pagePar+"&page={0}" + pagePar;
        pagePar = "ShangHuBranch.aspx?" + pagePar;
        filter.PageSize = 30;
        partner_id = Convert.ToInt32(Request.QueryString["bid"]);
        filter.partnerid = partner_id;
        filter.AddSortOrder(BranchFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request["page"], 1);
        
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
        {
            pager = session.Branch.GetPager(filter);
        }
        ilistPartner = pager.Objects;
        PageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, pagePar);
        
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
            <div id="bd" class="cf">
             <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                <div class="box-content">
                
                    <div class="head">
                        <h2>
                            分店管理</h2>
<div class="search"> 分店名称：<input type="text" class="h-input" name="bname" id="bname" CssClass="h-input" value="<%=Request["bname"]%>" />&nbsp;
                                <input id="saixuan" type="submit" value="筛选" class="formbutton" name="btnselect" style="padding: 1px 6px;"/>
                            </div>
                       
                        
                    </div><ul class="filter">
                            <li >
                               <a href="ShangHuBranch_Create.aspx?partnerid=<%=partner_id %>" style="text-align:right">新建分店</a>
                            |
                            <a href="ShangHu.aspx">返回商户列表</a>
                            </li>
                        </ul>
                    <div class="sect">
                        <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table" style="width: 100%; height: 21px">
                            <tr>
                                <th width="25%">总店名称</th>
                                <th width="25%">分店名称</th>
                                <th width="25%">已消费优惠券数量</th>
                                <th width="25%">操作</th>
                            </tr>
                            <%foreach (IBranch item in ilistPartner)
	                            {%>
		                            <tr>
                                        <%if (item.getPartnerTitle != null)
                                          {%>
                                             <td><%= item.getPartnerTitle.Title%></td>
                                          <%}
                                          else
                                          { %>
                                             <td></td>
                                           <% }%>
                                        <td><%=item.branchname %></td>
                                        <td><%=item.GetYXJbyGroup %></td>
                                        <td>
                                            <a ask="你确定要删除吗?" href="ShangHuBranch.aspx?remove=<%=item.id %>&bid=<%=item.getPartnerTitle.Id%>">删除</a> | 
                                            <a href="ShangHuBranch_Bianji.aspx?bid=<%=item.getPartnerTitle.Id %>&branch_id=<%=item.id %>">编辑</a>
                                        </td>
                                    </tr>
	                            <%} %>
                                <tr>
                                    <td colspan="4">
                                      <%=PageHtml %>
                                    </td>
                                </tr>
                        </table>
                    </div>
                  
                </div></div></div></div>
            </div>
            </div>
         </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
