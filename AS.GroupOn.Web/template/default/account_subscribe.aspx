<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    IPagers<ISmssubscribedetail> pager = null;  
    System.Collections.Generic.IList<ISmssubscribedetail> Smssubscribedetaillist = null;
    protected string pagerhtml = String.Empty;
    int page = 1;
    public NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "subscribe";
        _system = PageValue.CurrentSystemConfig;// 得到系统配置表信息
        page = Helper.GetInt(Request.QueryString["page"], 1);
        if (!Page.IsPostBack)
        {

            initText();

        }
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int smssubdetail = session.Smssubscribedetail.Delete(Convert.ToInt32(Request["id"]));
                if (smssubdetail > 0)
                {
                    SetSuccess("取消订阅成功！");
                    Response.Redirect(GetUrl("我的订阅", "account_subscribe.aspx"));
                    Response.End();
                }
            }
        }
    }

    private void initText()
    {
        //判断用户失效！
        NeedLogin();

        initList();
    }


    private void initList()
    {
        SmssubscribedetailFilter Smssubscribedetailfil = new SmssubscribedetailFilter();
        Smssubscribedetailfil.Mobile = AsUser.Mobile;
        Smssubscribedetailfil.AddSortOrder(SmssubscribedetailFilter.ID_DESC);

        Smssubscribedetailfil.PageSize = 30;
        Smssubscribedetailfil.CurrentPage = page;

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Smssubscribedetail.GetPager(Smssubscribedetailfil);
        }
        Smssubscribedetaillist = pager.Objects;
        if (pager.TotalRecords >= 30)
        {
            pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, page, GetUrl("我的订阅", "account_subscribe.aspx?page={0}"));
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
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
                    <div id="referrals">
                        <div class="menu_tab" id="dashboard">
                            <%LoadUserControl("_MyWebside.ascx", Ordertype); %>
                        </div>
                        <div id="tabsContent" class="coupons-box">

                            <div class="box-content1 tab">
                                <div class="head">
                                    <h2>我的订阅</h2>
                                    <div class="clear"></div>

                                    <ul class="filter">
                                    </ul>
                                </div>
                                <div class="clear"></div>
                                <div class="sect">

                                    <div class="clear"></div>
                                    <table cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th class="style1">序号
                                            </th>
                                            <th class="style1">项目
                                            </th>
                                            <th width="200">发送时间
                                            </th>
                                            <th width="200">操作
                                            </th>
                                        </tr>
                                     <%
                                                StringBuilder sb = new StringBuilder();
                                                if (Smssubscribedetaillist != null)
                                                {
                                                    if (Smssubscribedetaillist.Count > 0)
                                                    {
                                                        if (Smssubscribedetaillist.Count > 0)
                                                        {
                                                            for (int i = 0; i < Smssubscribedetaillist.Count; i++)
                                                            {
                                                                //显示的数据
                                                                if (i % 2 != 0)
                                                                {
                                                                    sb.Append("<tr  id='team-list-id-" + Smssubscribedetaillist[i].id + "'>");
                                                                }
                                                                else
                                                                {
                                                                    sb.Append("<tr class=\"alt\"  id='team-list-id-" + Smssubscribedetaillist[i].id + "'>");
                                                                }


                                                                sb.Append("<td>" + Smssubscribedetaillist[i].id.ToString() + "</td>");
                                                                ITeam item1 = null;
                                                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                                {
                                                                    if (Smssubscribedetaillist[i].teamid != 0)
                                                                    {
                                                                        item1 = session.Teams.GetByID(Convert.ToInt32(Smssubscribedetaillist[i].teamid));
                                                                    }

                                                                }
                                                                if (item1 != null)
                                                                {
                                                                    sb.Append("<td class=\"style1\">");
                                                                    sb.Append("<a href='" + getTeamPageUrl(item1.Id) + "' target='_blank'>");
                                                                    if (item1.Image != "")
                                                                    {
                                                                        sb.Append("<img src='" + AS.Common.Utils.ImageHelper.getSmallImgUrl(item1.Image) + "' title='" + item1.Title + "' width='110' height='70'  border='0'/>");
                                                                    }
                                                                    else
                                                                    {
                                                                        sb.Append(item1.Title);
                                                                    }
                                                                    sb.Append("</a>");
                                                                    sb.Append("</td >");
                                                                }
                                                                else
                                                                {
                                                                    sb.Append("<td class=\"style1\"></td>");
                                                                }

                                                                if (Smssubscribedetaillist[i].sendtime.ToString() == "9")
                                                                {
                                                                    sb.Append("<td>早上" + Smssubscribedetaillist[i].sendtime.ToString() + "点</td>");
                                                                }
                                                                else
                                                                {
                                                                    sb.Append("<td>凌晨" + Smssubscribedetaillist[i].sendtime.ToString() + "点</td>");
                                                                }

                                                                sb.Append("<td><a href='subscribe.html?id=" + Smssubscribedetaillist[i].id + "'>取消订阅</a></td>");
                                                                sb.Append("</tr>");
                                                            }
                                                        }
                                                    }

                                                }
                                                Response.Write(sb.ToString());
                                            %>
                                        <tr>
                                            <td></td>
                                            <td></td>
                                            <td>
                                                <div>
                                                    <ul class="paginator" style="margin-bottom: 20px; *margin-bottom: 4px;">
                                                        <li class="current">
                                                            <%= pagerhtml %>
                                                        </li>
                                                    </ul>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
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
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>   