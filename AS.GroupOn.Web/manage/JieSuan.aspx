<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    protected IPartner partner = null;
    protected string par_id = String.Empty;
    protected PartnerFilter filter = new PartnerFilter();
    protected decimal Money = 0; //应结算
    protected decimal num = 0; //实际卖出
    protected decimal shiji = 0;  //实际结算
    protected ISystem system = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {
            par_id = Request["Id"];
        }
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Partner_Jiesuan))
        {
            SetError("你没有查看商户结算的权限");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        filter.Id = Convert.ToInt32(par_id);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
        {
            partner = session.Partners.Get(filter);
        }
        int partnerid = AS.Common.Utils.Helper.GetInt(par_id, 0);
        //应结算
        if (!string.IsNullOrEmpty(par_id))
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                Money = session.Partner_Detail.exts_sp_GetPMoney(partnerid);
            }
        } 
        //实际结算
        if (!string.IsNullOrEmpty(par_id)) 
        {
            Partner_DetailFilter filter1 = new Partner_DetailFilter();
            filter1.Parid = partnerid;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
            {
                shiji = session.Partner_Detail.getRealSettle(filter1);
            }
        }
        //实际卖出
        if (!string.IsNullOrEmpty(par_id)) 
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                num = session.Partner_Detail.GetActualPMoney(partnerid);   
            }
        }
    }
</script>
<% LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" action="">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                 
                <input type="hidden"  name="partnerid" value="<%=par_id %>" />
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                 <div class="head" style="height:35px;">
                                    <div class="search"  >
                                         <ul class="filter">
                                            <li class="current" <%=Utility.GetStyle("JieSuan.aspx") %>>
                                              <a href="<%=WebRoot%>manage/JieSuan.aspx?Id=<%=par_id%>">结算信息</a><span></span>
                                            </li>
                                            <li class="" <%=Utility.GetStyle("JieSuan_ShenHe.aspx") %>>
                                             <a href="<%=WebRoot%>manage/JieSuan_ShenHe.aspx?Id=<%=par_id%>">结算详情</a><span></span>
                                            </li>
                                            <li <%=Utility.GetStyle("ShangHu.aspx") %>>
                                             <a class="" href="<%=WebRoot%>manage/ShangHu.aspx">返回</a><span></span>
                                             </li>
                                         </ul>
                                    </div>
                                </div>
                                <div class="sect">
                                    <div class="shjs_list">
                                        <div class="shjs_left">
                                            应 结 算:</div>
                                        <div class="shjs_right">
                                             <%=ASSystem.currency%> <%=AS.Common.Utils.Helper.GetDecimal(Money,0)%> 
                                        </div>
                                    </div>
                                    <div class="shjs_list">
                                        <div class="shjs_left">
                                            实际结算:</div>
                                        <div class="shjs_right">
                                         <%=ASSystem.currency%> <%=AS.Common.Utils.Helper.GetDecimal(shiji, 0)%>
                                           </div>
                                    </div>
                                    <div class="shjs_list">
                                        <div class="shjs_left">
                                            实际卖出:</div>
                                        <div class="shjs_right">
                                         <%=ASSystem.currency%> <%=AS.Common.Utils.Helper.GetDecimal(num, 0)%>
                                            </div>
                                    </div>
                                    <br/>
                                    <div  id="shjs_list2" class="shjs_list">
                                        <div class="shjs_left">
                                            开 户 行 :</div>
                                        <div class="shjs_right">
                                            <%=partner.Bank_name%></div>
                                    </div>
                                    <br/>
                                    <div  id="shjs_list2" class="shjs_list">
                                        <div class="shjs_left">
                                            开 户 名：</div>
                                        <div class="shjs_right">
                                            <%=partner.Bank_user%></div>
                                    </div>
                                    <br/>
                                    <div  id="shjs_list2" class="shjs_list">
                                        <div class="shjs_left">
                                            银行账号:</div>
                                        <div class="shjs_right">
                                            <%=partner.Bank_no%></div>
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
<% LoadUserControl("_footer.ascx", null); %>