<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerBranchPage" %>

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
    int page = 1;

    public NameValueCollection _system = new NameValueCollection();
    protected IBranch branchmodel = Store.CreateBranch();
    protected IPagers<ITeam> pager = null;
    protected IList<ITeam> ilistteam = null;
    protected TeamFilter teamfilter = new TeamFilter();
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        page = Helper.GetInt(Request.QueryString["page"], 1);

        _system = WebUtils.GetSystem(); ;
        if (CookieUtils.GetCookieValue("pbranch", key) == null || CookieUtils.GetCookieValue("pbranch", key) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=pbranch");
        }
        if (!Page.IsPostBack)
        {
            GetReview();
        }
        if (Request.HttpMethod == "POST" && Request.Form["downtxt"] != null)
        {
            type = 1;
            GetReview();
        }


    }

    private void GetReview()
    {
        StringBuilder stBTitle = new StringBuilder();

        stBTitle.Append("<tr>");
        stBTitle.Append("<th width='10%'>项目ID</th>");
        stBTitle.Append("<th width='23%'>项目名称</th>");
        stBTitle.Append("<th width='10%'>城市</th>");
        stBTitle.Append("<th width='13%'>日期</th>");
        stBTitle.Append("<th width='10%'>成交</th>");
        stBTitle.Append("<th width='12%' >团购价</th>");
        stBTitle.Append("<th width='12%'>操作</th>");
        stBTitle.Append("</tr>");
        Literal1.Text = stBTitle.ToString();

        int page = 1;
        if (Request.HttpMethod == "GET")
            if (Request.QueryString["page"] != null)
            {
                page = Helper.GetInt(Request.QueryString["page"], 1);
            }
        //branchmodel = branchbll.GetModel(1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            branchmodel = session.Branch.GetByID(1);
        }
        if (CookieUtils.GetCookieValue("pbranch", key) == null || CookieUtils.GetCookieValue("pbranch", key) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=branch");
        }

        string strPartnerID = CookieUtils.GetCookieValue("pbranch", key).ToString();

        _system = WebUtils.GetSystem();

        string a = CookieUtils.GetCookieValue("pbranch", key).ToString();
        where += " and branch_id =" + CookieUtils.GetCookieValue("pbranch", key) + "";

        if (type == 1)
        {
            if (Request.Form["begin_time"] != null && Request.Form["begin_time"].ToString() != "")
            {
                where += " and Begin_time>='" + Helper.GetDateTime(Request.Form["begin_time"], DateTime.Now).ToString("yyyy-MM-dd") + " 00:00:00' ";
            }
            if (Request.Form["endTime"] != null && Request.Form["endTime"].ToString() != "")
            {
                where += " and End_time<='" + Helper.GetDateTime(Request.Form["endTime"], DateTime.Now).ToString("yyyy-MM-dd") + " 23:59:59' ";
            }
            if (Request.Form["teamId"] != null && Request.Form["teamId"].ToString() != "")
            {
                where += " and Id=" + Helper.GetInt(Request.Form["teamId"], 0) + " ";
            }
            else
            {
                SetError("项目ID不能为空,请填写项目ID");
                Response.Redirect("project.aspx");
            }

        }
       
        teamfilter.where = where;
        teamfilter.PageSize = 30;
        teamfilter.CurrentPage = page;
        teamfilter.AddSortOrder(TeamFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(teamfilter);
        }
        StringBuilder stBContent = new StringBuilder();

        ilistteam = pager.Objects;
        if (ilistteam != null && ilistteam.Count > 0)
        {
            int i = 0;
           foreach(ITeam teaminfo in ilistteam)
            {
               
                if (i % 2 == 0)
                {
                    stBContent.Append("<tr class='alt'>");
                }
                else
                {
                    stBContent.Append("<tr>");
                }
                stBContent.Append("<td >" + teaminfo.Id + "</td>");
                stBContent.Append("<td >" + teaminfo.Title + "</td>");

                ICategory mcategory = Store.CreateCategory();
                CategoryFilter catefilter = new CategoryFilter();
               
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mcategory = session.Category.GetByID(Helper.GetInt(teaminfo.City_id, 0));
                }
                if (int.Parse(teaminfo.City_id.ToString()) != 0 && mcategory != null)
                {
                    stBContent.Append("<td>" + mcategory.Name + "</td>");
                }
                else
                {
                    stBContent.Append("<td>全部城市</td>");
                }
                stBContent.Append("<td>" + DateTime.Parse(teaminfo.Begin_time.ToString()).ToString("yyyy-MM-dd") + "<br/>" + DateTime.Parse(teaminfo.End_time.ToString()).ToString("yyyy-MM-dd") + "</td>");
                stBContent.Append("<td>" + teaminfo.Now_number.ToString() + "/" + teaminfo.Min_number + "</td>");

                string strCurrency = "";
                ISystem system = Store.CreateSystem();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    system = session.System.GetByID(1);
                }
                if (ASSystem != null)
                {
                    strCurrency = system.currency;

                }
                stBContent.Append("<td><span class=\"money\">" + strCurrency + "</span>" + teaminfo.Team_price.ToString() + "<br/><span class=\"money\">" + strCurrency + "</span>" + teaminfo.Market_price.ToString() + "</td>");

                stBContent.Append("<td class=\"op\" nowrap><a href=\"" + PageValue.WebRoot + "ajax/branch.aspx?action=teamdetail&id=" + teaminfo.Id.ToString() + "\" class=\"ajaxlink\">详情</a>");

                stBContent.Append("</td>");

                stBContent.Append("</tr>");
                i++;
            }


            string url = "project.aspx?page={0}";

            pagerhtml = WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
           
        }
        else
        {
            stBContent.Append("<tr><td colspan=\"6\">暂无数据！</td></tr>");
        }

        Literal2.Text = stBContent.ToString();
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server" method="post">
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
                                        项目信息
                                        
                                        </h2>
                                 <ul class="contact-filter">
                                        <li>开始时间:<input type="text" name="begin_time" class="h-input" group="a" datatype="date" />
                                            结束时间:<input name="endTime" class="date" group="a" datatype="date" onclick="WdatePicker();"
                                                type="text" />
                                            项目ID：<input type="text" name="teamId" class="h-input" group="a" require="true" onkeyup="clearNoNum(this)"
                                                value="" />&nbsp;
                                             <input datatype="number" name="downtxt" type="submit" group="a" value="筛选" class="formbutton" /></li></ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                           <td colspan="10">
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
<script type="text/javascript">
    function isNum() {
        if (event.keyCode < 48 || event.keyCode > 57) {
            event.keyCode = 0;
        }
    }
    function clearNoNum(obj) {
        obj.value = obj.value.replace(/[^\d.]/g, "");  //清除“数字”和“.”以外的字符 
        obj.value = obj.value.replace(/^\./g, "");  //验证第一个字符是数字而不是. 
        obj.value = obj.value.replace(/\.{2,}/g, "."); //只保留第一个. 清除多余的. 
        obj.value = obj.value.replace(".", "$#$").replace(/\./g, "").replace("$#$", ".");
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>
