<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public int pid = 0;
    public string sql;
    public int state;
    public int page = 1;
    protected string pagerhtml = String.Empty;
    string url = String.Empty;
    string request_status = String.Empty;
    string request_teamid = null;
    private NameValueCollection _system = null;
    protected Partner_DetailFilter pdetailfilter = new Partner_DetailFilter();
    protected IList<IPartner_Detail> ilistpdetail = null;
    protected IPagers<IPartner_Detail> pager = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //if (Request.HttpMethod == "POST")
        //{
        //    request_status = ddlStatus.Value.ToString();
        //    request_teamid = Helper.GetString(Request.Form["teamid"], "0");
        //}
        //else
        //{
        if (Request["btnselect"] == "筛选")
        {
            request_status = Helper.GetString(Request.QueryString["ddlStatus"], "0");
            request_teamid = Helper.GetString(Request.QueryString["teamid"], "0");
            page = Helper.GetInt(Request.QueryString["page"], 1);
        }
        //}

        pid = Helper.GetInt(CookieUtils.GetCookieValue("partner"), 0);
        pdbshow();

    }

    /// <summary>
    /// 商户结算展示
    /// </summary>
    private void pdbshow()
    {
        ISystem system = Store.CreateSystem();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
        }
        switch (Request.QueryString["ddlStatus"])
        {
            case "0":
                break;
            case "1":
                pdetailfilter.settlementstate = 1;
                break;
            case "2":
                pdetailfilter.settlementstate = 2;
                break;
            case "4":
                pdetailfilter.settlementstate = 4;
                break;
            case "8":
                pdetailfilter.settlementstate = 8;
                break;
        }

        //if (request_teamid != String.Empty && request_teamid != "0")
        if (!string.IsNullOrEmpty(Request.QueryString["teamid"]))
        {
            pdetailfilter.team_id = Helper.GetInt(Request.QueryString["teamid"], 0);
        }

        //商户类型
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<th width='10%'>ID</th>");
        sb1.Append("<th width='10%'>结算状态</th>");
        sb1.Append("<th width='10%'>结算金额</th>");
        sb1.Append("<th width='10%'>项目ID</th>");
        sb1.Append("<th width='10%'>结算数量</th>");
        sb1.Append("<th width='10%'>管理员</th>");
        if (state == 1)
        {
            sb1.Append("<th width='10%'>申请日期</th>");
        }
        else
        {
            sb1.Append("<th width='10%'>操作日期</th>");
        }
        sb1.Append("<th width='10%'>备注</th>");
        sb1.Append("<th width='10%'>操作</th>");
        sb1.Append("</tr>");
        Literal5.Text = sb1.ToString();
        //商户数据
        StringBuilder sb2 = new StringBuilder();
        int i = 0;
        pdetailfilter.partnerid = Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0);
        pdetailfilter.AddSortOrder(Partner_DetailFilter.Create_time_DESC);
        pdetailfilter.PageSize = 30;
        pdetailfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Partner_Detail.GetPager(pdetailfilter);
        }
        ilistpdetail = pager.Objects;
        foreach (IPartner_Detail pdetail in ilistpdetail)
        {
            if (i % 2 != 0)
            {
                sb2.Append("<tr>");
            }
            else
            {
                sb2.Append("<tr class='alt'>");
            }
            i++;
            sb2.Append("<td>" + pdetail.id + "</td>");
            if (pdetail.settlementstate == 1)
            {
                sb2.Append("<td><div class='sjjs_jsxq'><img src='" + PageValue.WebRoot + "upfile/css/i/dsh-bt.png' /></div> 待审核</td>");
            }
            else if (pdetail.settlementstate == 2)
            {
                sb2.Append("<td ><div class='sjjs_jsxq'><img src='" + PageValue.WebRoot + "upfile/css/i/jujue-bt.png' /></div>拒绝</td>");
            }
            else if (pdetail.settlementstate == 4)
            {
                sb2.Append("<td><div class='sjjs_jsxq'><img src='" + PageValue.WebRoot + "upfile/css/i/zzjs-bt.png' /></div>正在结算</td>");
            }
            else if (pdetail.settlementstate == 8)
            {
                sb2.Append("<td><div class='sjjs_jsxq'><img src='" + PageValue.WebRoot + "upfile/css/i/yjs-bt.png' /></div>已结算</td>");
            }
            sb2.Append("<td style='text-align:left;'>");
            sb2.Append(system.currency + pdetail.money);
            sb2.Append("</td>");
            sb2.Append("<td style='text-align:left;'>" + pdetail.team_id + "</td>");
            sb2.Append("<td style='text-align:left;'>" + pdetail.num + "</td>");
            if (pdetail.settlementstate != 1)
            {
                //usermodel = userbll.GetModel(pat.Adminid);
                IUser usermodel = Store.CreateUser();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    usermodel = session.Users.GetByID(pdetail.adminid);
                }
                if (usermodel != null && pdetail.adminid != 0)
                {

                    sb2.Append("<td nowrap>" + usermodel.Username + "</td>");
                }
                else
                {
                    sb2.Append("<td ></td>");
                }
            }
            else
            {
                sb2.Append("<td nowrap></td>");
            }
            sb2.Append("<td nowrap>");
            sb2.Append(pdetail.createtime);
            sb2.Append("</td>");
            sb2.Append("<td>" + pdetail.settlementremark + "</td>");
            sb2.Append("<td>");
            sb2.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "manage/ajax_partner.aspx?action=PartnerXiangQing&Id=" + pdetail.id + "'>详情</a>");
            if (pdetail.settlementstate == 2)
            {

                sb2.Append(" | <a class='ajaxlink' href='" + PageValue.WebRoot + "manage/ajax_partner.aspx?action=PmoneyEdit&id=" + pdetail.id + "'>编辑</a>");
            }
            else
            {
                sb2.Append("<a class='ajaxlink' href=''></a>");
            }
            sb2.Append("</td>");
            sb2.Append("</tr>");
        }
        pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, PageValue.WebRoot + "biz/Pmoney.aspx?teamid=" + Request.QueryString["teamid"] + "&ddlStatus=" + Request.QueryString["ddlStatus"] + "&page={0}");
        Literal1.Text = sb2.ToString();
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server" method="get">
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
                                        结算详情</h2>
                                    <li>
                                        <%--<asp:Label ID="lblID" runat="server"> 项目ID：</asp:Label>--%>
                                        <label id="lblID">
                                            项目ID：</label>
                                        <input type="text" size="6" name="teamid" id="teamid" class="number" group="goto"
                                            datatype="number" <%if(!string.IsNullOrEmpty(Request.QueryString["teamid"])){ %>value="<%=Request.QueryString["teamid"] %>"
                                            <%} %> />
                                        结算状态：&nbsp;
                                        <select id="ddlStatus" name="ddlStatus">
                                            <option value="0">请选择</option>
                                            <option value="1" <%if(Request.QueryString["ddlStatus"] == "1"){ %>selected="selected"
                                                <%} %>>待审核</option>
                                            <option value="2" <%if(Request.QueryString["ddlStatus"] == "2"){ %>selected="selected"
                                                <%} %>>拒绝</option>
                                            <option value="4" <%if(Request.QueryString["ddlStatus"] == "4"){ %>selected="selected"
                                                <%} %>>正在结算</option>
                                            <option value="8" <%if(Request.QueryString["ddlStatus"] == "8"){ %>selected="selected"
                                                <%} %>>已结算</option>
                                        </select>&nbsp;&nbsp;
                                        <input type="submit" id="btnselect" name="btnselect" group="goto" value="筛选" class="formbutton"
                                            name="btnselect" style="padding: 1px 6px;" />
                                        <input type="button" id="commit" name="commit" value="申请结算" vname="<%=pid %>" onclick="btnclick();"
                                            class="formbutton" style="padding: 1px 6px;" /></li>
                                </div>
                                <div class="sect">
                                    <ul class="deals-list">
                                        <asp:Literal ID="ltTeam" runat="server"></asp:Literal>
                                    </ul>
                                    <div class="clear">
                                    </div>
                                    <div>
                                    </div>
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal5" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal><tr>
                                            <td colspan="9">
                                                <%=pagerhtml%>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<script type="text/javascript">
    function btnclick() {


        var str = $("#commit").attr("vname");


        X.get('<%=PageValue.WebRoot %>manage/ajax_partner.aspx?action=shmoney&id=' + str);
    }

 
</script>
