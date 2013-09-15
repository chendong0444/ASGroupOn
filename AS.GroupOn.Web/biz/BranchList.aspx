<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>


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

<script runat="server">
    protected int type = 0;
    protected string pagerhtml = String.Empty;
    string where = "1=1";
    public NameValueCollection _system = new NameValueCollection();
    protected IBranch branchmodel = null;
    protected IList<IBranch> ilistbranch = null;
    protected BranchFilter branchfilter = new BranchFilter();
    protected IPagers<IBranch> pager = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        _system = WebUtils.GetSystem();
        if (Request["del"] != null && Request["del"].ToString() != "")
        {
            int delId = Convert.ToInt32(Request["del"]);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int i = session.Branch.Delete(delId);
            }
            SetSuccess("删除分站成功");
            Response.Redirect("BranchList.aspx");
        }

        GetReview();
    }

    private void GetReview()
    {
        StringBuilder stBTitle = new StringBuilder();
        stBTitle.Append("<tr>");
        stBTitle.Append("<th width='10%' >ID</th>");
        stBTitle.Append("<th width='10%'>用户名</th>");
        stBTitle.Append("<th width='15%'>分站名称</th>");
        stBTitle.Append("<th width='15%'>联系人</th>");
        stBTitle.Append("<th widht='12%'>联系电话</th>");
        stBTitle.Append("<th width='15%'>联系地址</th>");
        stBTitle.Append("<th width='10%'>已消费优惠券数量</th>");
        stBTitle.Append("<th width='13%' >操作</th>");
        stBTitle.Append("</tr>");
        Literal1.Text = stBTitle.ToString();

        int page = 1;
        if (Request.QueryString["page"] != null)
        {
            page = Helper.GetInt(Request.QueryString["page"], 1);
        }
       
        using(IDataSession session=AS.GroupOn.App.Store.OpenSession(false))
        {
         branchmodel=session.Branch.GetByID(1);   
        }
        _system = WebUtils.GetSystem();

        if (txtBranchName.Text != "")
        {
            branchfilter.branchname = Helper.GetString(txtBranchName.Text, string.Empty);
        }

        
        branchfilter.partnerid = Helper.GetInt(CookieUtils.GetCookieValue("partner",key), 0);
        branchfilter.AddSortOrder(BranchFilter.ID_DESC);
        branchfilter.PageSize = 30;
        branchfilter.CurrentPage = page;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Branch.GetPager(branchfilter);
        }
        ilistbranch = pager.Objects;
        
        StringBuilder stBContent = new StringBuilder();
        if (ilistbranch != null && ilistbranch.Count > 0)
        {
            int i = 0;
            foreach(IBranch branch in ilistbranch)
            {
                if (i % 2 == 0)
                {
                    stBContent.Append("<tr class='alt'>");
                }
                else
                {
                    stBContent.Append("<tr>");
                }
                stBContent.Append("<td >" + branch.id + "</td>");
                stBContent.Append("<td >" + branch.username + "</td>");
                stBContent.Append("<td >" + branch.branchname + "</td>");
                stBContent.Append("<td >" + branch.contact+ "</td>");
                stBContent.Append("<td >" + branch.phone + "</td>");
                stBContent.Append("<td >" + branch.address + "</td>");
                stBContent.Append("<td >" + branch.GetYXJbyGroup + "</td>");
                stBContent.Append("<td ><a href=\"" + WebRoot + "manage/ajax_partner.aspx?action=branchview&id=" + branch.id.ToString() + "\" class=\"ajaxlink\">详情</a>&nbsp;|&nbsp;<a href='BranchAdd.aspx?id=" + branch.id + "'>修改</a>&nbsp;|&nbsp;<a href='BranchList.aspx?del=" + branch.id + "' onclick=\"return confirm('确认删除?')\">删除</a></td>");
                i++;
            }
            string url = "BranchList.aspx?page={0}";

            pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        }
        Literal2.Text = stBContent.ToString();
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
                    
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
        
                                    <h2>
                                        分站信息
                                        
                                        </h2>
                                    <ul class="contact-filter">
                                        <li>分站名称
                                            <asp:TextBox ID="txtBranchName" runat="server" CssClass="h-input" datatype="number" />
                                            &nbsp;
                                            <input type="submit" value="筛选" name="btnselect" class="formbutton" style="padding: 1px 6px;" /></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="9">
                                            <ul class="paginator">
                                                    <li class="current">
                                                        <%= pagerhtml %>
                                                    </li>
                                                </ul>
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

