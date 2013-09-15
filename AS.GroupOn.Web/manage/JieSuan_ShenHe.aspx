<%@ Page Language="C#" AutoEventWireup="true" Inherits ="AS.GroupOn.Controls.AdminPage"%>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.Common.Utils" %>

<script runat="server">
    protected IPagers<IPartner_Detail> pages = null;
    protected System.Collections.Generic.IList<IPartner_Detail> PdList = null;
    protected Partner_DetailFilter filter = new Partner_DetailFilter();
    protected string partnerId = String.Empty;
    protected AS.GroupOn.Domain.Spi.Partner Partner = null;
    protected string PageHtml = String.Empty;
    protected string PagePar = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if(AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin,ActionEnum.Option_Partner_Jiesuan_Examine))
        {
            SetError("你没有权限查看商家结算信息");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (!IsPostBack)
        {
            partnerId = AS.Common.Utils.Helper.GetString(Request["Id"], String.Empty);
        }
        int id = AS.Common.Utils.Helper.GetInt(Request["remove"], 0);
        if (id > 0) 
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Partner_Jiesuan_Delete))
            {
                SetError("没有权限删除商家结算信息");
                Response.Redirect("JieSuan_ShenHe.aspx"); 
                Response.End();
                return;
            }
            else 
            {
                int count = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                {
                    count = session.Partner_Detail.Delete(id);
                }
                if (count > 0)
                {
                    SetSuccess("删除成功");
                }
                else 
                {
                    SetError("删除失败");
                }
                Response.Redirect("JieSuan_ShenHe.aspx?Id=" + Request.QueryString["partner_Id"] + "");
                Response.End();
                return;
            }
        }
        if (!string.IsNullOrEmpty(Request["teamid"])) 
        {
            filter.team_id = AS.Common.Utils.Helper.GetInt(Request["teamid"], 0);
            PagePar = PagePar + "&Team_id=" + AS.Common.Utils.Helper.GetInt(Request["teamid"], 0);
        }
        if (!string.IsNullOrEmpty(Request["ddlStatus"]))
        {
            filter.AddSortOrder(Partner_DetailFilter.Create_time_DESC);
            filter.settlementstate = AS.Common.Utils.Helper.GetInt(Request["ddlStatus"], 0);
            PagePar = PagePar + "&ddlStatus=" + AS.Common.Utils.Helper.GetInt(Request["ddlStatus"], 0);
        }
        PagePar = PagePar + "&page={0}";
        PagePar = "JieSuan_ShenHe.aspx?Id=" + Request["Id"] + "" + PagePar;
        filter.PageSize = 30;
        filter.AddSortOrder(Partner_DetailFilter.ID_DESC);
        filter.partnerid = AS.Common.Utils.Helper.GetInt(Request.QueryString["Id"], 0);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
        {
            pages = session.Partner_Detail.GetPager(filter);
        }
        PdList = pages.Objects;
        PageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pages.TotalRecords, pages.CurrentPage, PagePar); 
    }
    
</script>
<%LoadUserControl("_header.ascx", null); %>
 <script type="text/javascript">
     function btnclick() {
         var str = $("#commit").attr("vname");
         X.get(webroot+'manage/ajax_manage.aspx?action=pmoney&id=' + str);
     }
</script>
<body  class="newbie">
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
                                <div class="search">
                                   
                                    <input type="hidden" name="Id" value="<%=partnerId %>" />
                                     项目ID：
                                    <input type="text" size="6" name="teamid" id="teamid" class="number" value="<%=Request["teamid"] %>" group="goto" datatype="number" />
                                    结算状态：&nbsp;
                                          <select name="ddlStatus" class="h-input">
                                            <option value=""
                                                <%if(Request["ddlStatus"]==""){ %>
                                                selected="selected"
                                                <%} %>
                                            >请选择</option>
                                            <option value="1"
                                                <%if(Request["ddlStatus"]=="1"){ %>
                                                selected="selected"
                                                <%} %>
                                            >待审核</option>
                                            <option value="2"
                                                <%if(Request["ddlStatus"]=="2"){ %>
                                                selected="selected"
                                                <%} %>
                                            >拒绝</option>
                                            <option value="4"
                                                <%if(Request["ddlStatus"]=="4"){ %>
                                                selected="selected"
                                                <%} %>
                                            >正在结算</option>
                                            <option value="8"
                                                <%if(Request["ddlStatus"]=="8"){ %>
                                                selected="selected"
                                                <%} %>
                                            >已结算</option>
                                        </select>
                                    <input type="submit" id="btnselect" group="goto" value="筛选" class="formbutton" name="btnselect" style="padding: 1px 6px;"  />
                                    
                                            <input type="button" id="commit" name="commit" value="商户结算" vname="<%=partnerId %>" onClick="btnclick();"class="formbutton" style="padding: 1px 6px;" group="goto" />
                                       
                                   <ul class="filter">  
                                 
                    
                                    <li class="" <%=Utility.GetStyle("JieSuan.aspx") %>>
                                      <a href="<%=WebRoot%>manage/JieSuan.aspx?Id=<%=partnerId%>">结算信息</a><span></span>
                                    </li>
                                    <li  class="current" <%=Utility.GetStyle("JieSuan_ShenHe.aspx") %>>
                                     <a href="<%=WebRoot%>manage/JieSuan_ShenHe.aspx?Id=<%=partnerId%>">结算详情</a><span></span>
                                    </li>
                                    <li class="" <%=Utility.GetStyle("ShangHu.aspx") %>>
                                     <a href="<%=WebRoot%>manage/ShangHu.aspx">返回</a><span></span>
                                     </li>
                   
               
                                   </ul></div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" style="text-align:center" class="coupons-table">
                                            <tr>
                                                <td style="width:5%">ID</td>
                                                <td style="width:10%">结算状态</td>
                                                <td style="width:10%">结算金额</td>
                                                <td style="width:5%">项目ID</td>
                                                <td style="width:10%">结算数量</td>
                                                <td style="width:10%">管理员</td>
                                                <td style="width:10%">操作日期</td>
                                                <td style="width:10%">备注</td>
                                                <td style="width:15%">操作</td>
                                            </tr>
                                            <%int i = 0; %>
                                            <%foreach (IPartner_Detail item in PdList)
                                            { 
                                            if (i % 2 == 0)
                                            {%>
                                                <tr class="alt">
                                                <%}else{ %>
                                                </tr>
                                                <%}i++; %>

                                                    <td><%=item.id %></td>
                                                    <td>  
                                                     <% if(item.settlementstate == 1) {%>
                                                            <div class='sjjs_jsxq'><img src='<%=AS.GroupOn.Controls.PageValue.WebRoot %>upfile/css/i/dsh-bt.png'/></div>待审核 
                                                            <%}%>
                                                            <%else if (item.settlementstate == 2) 
                                                            {%>
                                                               <div class='sjjs_jsxq'><img src='<%=AS.GroupOn.Controls.PageValue.WebRoot %>upfile/css/i/jujue-bt.png'/></div>被拒绝
                                                            <%}else if(item.settlementstate ==4)
                                                            {%>
                                                               <div class='sjjs_jsxq'><img src='<%=AS.GroupOn.Controls.PageValue.WebRoot %>upfile/css/i/zzjs-bt.png' /></div>正在结算
                                                            <%}else if(item.settlementstate ==8)
                                                            {%>
                                                               <div class='sjjs_jsxq'><img src='<%=AS.GroupOn.Controls.PageValue.WebRoot %>upfile/css/i/yjs-bt.png' /></div>已结算
                                                            <%}%>
                                                        </td>
                                                    <td><%=ASSystem.currency%><%=item.money %></td>
                                                    <td><%=item.team_id  %></td>
                                                    <td><%=item.num %></td>
                                                    <!--获取管理员名字-->
                                                    <td><%=item.GetAdminName %></td>

                                                    <td><%=item.createtime %></td>
                                                    <td><%=item.settlementremark %></td>
                                                    <td>
                                                        <a href='JieSuan_ShenHe.aspx?remove=<%=item.id %>&partner_Id=<%=partnerId %>' ask='是否要删除此信息?'>删除</a> | 
                                                        <a class='ajaxlink' href='ajax_manage.aspx?action=partner_detailstate&Id=<%=item.id %>&state=<%=item.settlementstate %>&num=<%=item.num %>&teamid=<%=item.team_id%>&pid=<%=item.partnerid %>'>审核</a> | 
                                                        <a class='ajaxlink' href='ajax_manage.aspx?action=PartnerXiangQing&Id=<%=item.id %>'>详情</a>
                                                    </td>
                                                </tr>
                                            <%}%>
                                            <tr>
                                                <td colspan="9">
                                                 <%=PageHtml %>
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

