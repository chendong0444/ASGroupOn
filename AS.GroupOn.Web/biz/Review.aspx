<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>


<%@ Register Src="~/UserControls/Order_PartnerSearch.ascx" TagName="Order_PartnerSearch" TagPrefix="uc5" %>
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
    protected string pagerhtml = String.Empty;
    string where = "1=1";
    public NameValueCollection _system = new NameValueCollection();
    //项目ID
    protected int teamid = 0;
    protected ISystem systemmodel = Store.CreateSystem();
    protected UserReviewFilter reviewfilter = new UserReviewFilter();
    protected IPagers<IUserReview> pager = null;
    protected IList<IUserReview> ilistreview = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        //点击筛选按钮
        //if (Request.HttpMethod == "POST")
        //{
            if (!string.IsNullOrEmpty(txtItemId.Value))
            {
                if (NumberUtils.IsNum(txtItemId.Value))
                {
                    where += " and Userreview.team_id=" + txtItemId.Value;
                    teamid = int.Parse(txtItemId.Value);
                }
                else
                {
                    SetError("您输入的参数非法");
                }
            }
        //}
        //分页
        else if (Request["teamid"] != null && Request["teamid"].ToString() != "")
        {
            if (NumberUtils.IsNum(Request["teamid"]))
            {
                where += " and Userreview.team_id=" + Request["teamid"].ToString();
                teamid = int.Parse(Request["teamid"].ToString());
                txtItemId.Value = Request["teamid"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }
        GetReview();
    }

    private void GetReview()
    {
        StringBuilder stBTitle = new StringBuilder();
        stBTitle.Append("<tr>");
        stBTitle.Append("<th width='10%'>项目ID</th>");
        stBTitle.Append("<th width='18%'>项目名称</th>");
        stBTitle.Append("<th width='17%'>用户名称</th>");
        stBTitle.Append("<th width='18%'>评价内容</th>");
        stBTitle.Append("<th width='17%'>评价时间</th>");
        stBTitle.Append("<th width='10%'>满意度</th>");
        stBTitle.Append("<th widht='10%'>再次购买</th>");
        stBTitle.Append("</tr>");
        Literal1.Text = stBTitle.ToString();

        where += " and Userreview.state='1' and Userreview.partner_id=" + CookieUtils.GetCookieValue("partner", key) + " and Userreview.[type]='partner'";
        int page = 1;
        page = Helper.GetInt(Request.QueryString["page"], 1);
          
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            systemmodel = session.System.GetByID(1);
        }
        _system = WebUtils.GetSystem();
        
        reviewfilter.wheresql = where;
        reviewfilter.AddSortOrder(UserReviewFilter.Create_Time_DESC1);
        
        reviewfilter.PageSize = 30;
        reviewfilter.CurrentPage = Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.UserReview.GetPager3(reviewfilter);
        }
        ilistreview = pager.Objects;
        StringBuilder stBContent = new StringBuilder();
        if (ilistreview != null && ilistreview.Count > 0)
        {
            int i = 0;
                foreach(IUserReview review in ilistreview)
            {
                if (i % 2 == 0)
                {
                    stBContent.Append("<tr class='alt'>");
                }
                else
                {
                    stBContent.Append("<tr>");
                }
                stBContent.Append("<td width='60'>" + review.team_id + "</td>");
                stBContent.Append("<td width='170'><a class='deal-title' href='" + getTeamPageUrl(Helper.GetInt(review.team_id.ToString(), 0)) + "' target='_blank' title='" + review.Title + "'>" + review.Title + "</td>");
                stBContent.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 130px;'>");
                stBContent.Append(review.user.Email + "<br>");
                stBContent.Append(review.username);
                stBContent.Append("</div></td>");
                stBContent.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 160px;'>" + review.comment.ToString() + "</div></td>");
                stBContent.Append("<td>" +review.create_time + "</td>");
                if (review.score.ToString() == "100")
                {
                    stBContent.Append("<td width='60'>满意</td>");
                }
                else if (review.score.ToString() == "50")
                {
                    stBContent.Append("<td width='60'>一般</td>");
                }
                else if (review.score.ToString() == "0")
                {
                    stBContent.Append("<td width='60'>失望</td>");
                }
                else
                {
                    stBContent.Append("<td></td>");
                }

                if (review.isgo.ToString() == "1")
                {
                    stBContent.Append("<td widht='60'>是</td>");
                }
                else if (review.isgo.ToString() == "0")
                {
                    stBContent.Append("<td widht='60'>否</td>");
                }
                else
                {
                    stBContent.Append("<td></td>");
                }
                    i++;
            }
            string url = "Review.aspx?page={0}";
            if (teamid > 0)
            {
                url = "Review.aspx?page={0}&teamid=" + teamid;
            }
            pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        }
        Literal2.Text = stBContent.ToString();
    }
</script>

<%LoadUserControl("_header.ascx", null); %>
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
<body class="newbie">
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
                                        商户评论</h2>
                                    <ul class="contact-filter">
                                        <li>项目ID：
                                            <%--<asp:TextBox ID="txtItemId" runat="server" CssClass="h-input" datatype="number" />--%>
                                            <input id="txtItemId" name="txtItemId" class="h-input" datatype="number" runat="server" />
                                            &nbsp;
                                            <input type="submit" value="筛选" name="btnselect" class="formbutton" style="padding: 1px 6px;" /></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="7">
                                                <%=pagerhtml %>
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
