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
    //protected Maticsoft.BLL.UserInfo userinfo = null;//当前用户信息
    IPagers<IInvite> pager = null;
    public string strWebSite = "";
    public string strUserID = "";
    IList<IInvite> invitelist = null;
    //protected DataSet ds = null;//邀请记录
    int page = 1;
    protected string pagerhtml = String.Empty;
    string pays = string.Empty;
    protected override void OnLoad(EventArgs e)
    {

        Form.Action = GetUrl("我的邀请", "account_refer.aspx");
        pays = Request["Pay"];
        Ordertype = "refer";
        base.OnLoad(e);
        page = Helper.GetInt(Request.QueryString["page"], 1);
        if (!Page.IsPostBack)
        {
            initText();
        }
    }

    private void initText()
    {
        //判断用户失效！
        NeedLogin();
        UserFilter userfil = new UserFilter();
        //IList<IUser> userlist = null;
        IUser user = null;
        string uname = string.Empty; 
        string key = FileUtils.GetKey();
        if (!string.IsNullOrEmpty(CookieUtils.GetCookieValue("username")))
        {
            uname = CookieUtils.GetCookieValue("username",key).ToString();
        }

        string strUrl = Request.Url.AbsolutePath;
        userfil.Username = uname;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            user = session.Users.GetByName(userfil);
        }
        if (user != null)
        {
            //if (userlist.Count > 0)
            //{
            //    if (userlist.Count > 0)
            //    {
            //        strUserID = userlist[0].Id.ToString();
            //    }
            //}
            strUserID = user.Id.ToString();
        }
        //获取网站地址
        strWebSite = Request.Url.AbsoluteUri;
        strWebSite = strWebSite.Substring(7);
        strWebSite = "http://" + strWebSite.Substring(0, strWebSite.IndexOf('/'));


        initList(strUserID);
    }


    private void initList(string strUserID)
    {
        InviteFilter invitefil = new InviteFilter();
        invitefil.User_id = Helper.GetInt(strUserID, 0);
        invitefil.PageSize = 30;
        invitefil.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        invitefil.AddSortOrder(InviteFilter.Create_time_DESC);
        if (!string.IsNullOrEmpty(pays))
        {
             invitefil.Pay = pays;
        }
       
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Invite.GetPager(invitefil);
        }

        invitelist = pager.Objects;
        if (invitelist.Count >= 30)
        {
            pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, page, GetUrl("我的邀请", "account_refer.aspx?page={0}"));
        }
    }
     
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
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
                                <h2>我的邀请</h2>
                                <div class="clear"></div>
                                <div class="header_info">
                                    <strong>不同的状态都是什么意思？</strong>
                                    <p>未购买：您已邀请好友注册，但是好友尚未参加过团购</p>
                                    <p>已返利：恭喜，已经给您返利啦</p>
                                    <p>待返利：好友已团购，将会在 24 小时内返利，请稍候</p>
                                    <p>审核未通过：因为手机号重复等原因被判为无效邀请</p>
                                    <p>已过期：好友 7 天内未参加团购，邀请过期了</p>
                                    <strong>自己邀请自己也能获得返利吗？</strong>
                                    <p>不可以。我们会人工核查，对于查实的作弊行为，不返利，标记为“审核未通过”。</p>
                                </div>
                                <ul class="filter">
                                    <li class="label">分类: </li>
                                    <li <%if (string.IsNullOrEmpty(pays)){%>class="current"<%}%>><a href="<%=GetUrl("我的邀请", "account_refer.aspx")%>">所有</a><span></span></li>
                                    <li <%if (pays=="N"){%>class="current"<%}%>><a
                                        href="<%=GetUrl("我的邀请", "account_refer.aspx?Pay=N")%>">未购买</a><span></span></li>
                                    <li <%if (pays=="Y"){%>class="current"<%}%>><a href="<%=GetUrl("我的邀请", "account_refer.aspx?Pay=Y")%>">已返利</a><span></span></li>
                                </ul>
                            </div>
                            <div class="sect">
                                <div class="share-list">
                                    <div class="blk im">
                                        <div class="logo">
                                            <img src="<%=ImagePath() %>logo_qq.gif" />
                                        </div>
                                        <div class="info">
                                            <h4>这是您的专用邀请链接，请通过 MSN 或 QQ 发送给好友：</h4>
                                            <input id="share-copy-text" type="text" value="<%=strWebSite %><%=PageValue.WebRoot%>index.aspx?r=<%=strUserID %>"
                                                size="35" class="f-input" onfocus="this.select()" tip="复制成功，可以通过 MSN 或 QQ 发送给好友了" />
                                            <input id="share-copy-button" type="button" value="复制" class="formbutton" />
                                        </div>
                                    </div>
                                </div>
                                <div class="clear"></div>
                                <table cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                    <tr>
                                        <th class="style1">用户
                                        </th>
                                        <th width="200">邀请时间
                                        </th>
                                        <th width="200">状态
                                        </th>
                                    </tr>
                                    <%
                                        StringBuilder sb = new StringBuilder();
                                        if (invitelist != null)
                                        {
                                            if (invitelist.Count > 0)
                                            {
                                                if (invitelist.Count > 0)
                                                {
                                                    for (int i = 0; i < invitelist.Count; i++)
                                                    {
                                                        //显示的数据
                                                        if (i % 2 != 0)
                                                        {
                                                            sb.Append("<tr  id='team-list-id-" + invitelist[i].Id + "'>");
                                                        }
                                                        else
                                                        {
                                                            sb.Append("<tr class=\"alt\"  id='team-list-id-" + invitelist[i].Id + "'>");
                                                        }

                                                        IUser item1 = null;
                                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                        {
                                                            item1 = session.Users.GetByID(Helper.GetInt(invitelist[i].Other_user_id, 0));

                                                        }
                                                        if (item1 != null)
                                                        {
                                                            sb.Append("<td class=\"style1\">" + item1.Username + "</td>");
                                                        }
                                                        else
                                                        {
                                                            sb.Append("<td class=\"style1\"></td>");
                                                        }
                                                        sb.Append("<td>" + invitelist[i].Create_time.ToString() + "</td>");

                                                        if (int.Parse(invitelist[i].Credit.ToString()) != 0)
                                                        {
                                                            sb.Append("<td>已返利</td>");
                                                        }
                                                        else if (int.Parse(invitelist[i].Credit.ToString()) == 0 && invitelist[i].Pay.ToString() != "C" && invitelist[i].Pay.ToString() != "N")
                                                        {
                                                            sb.Append("<td>待返利</td>");
                                                        }
                                                        else if (int.Parse(invitelist[i].Credit.ToString()) == 0 && invitelist[i].Pay.ToString() == "N")
                                                        {
                                                            sb.Append("<td>未购买</td>");
                                                        }
                                                        else if (invitelist[i].Pay.ToString() == "C")
                                                        {

                                                            sb.Append("<td>审核未通过</td>");
                                                        }
                                                        else if (DateTime.Parse(invitelist[i].Create_time.ToString()).AddDays(7) < DateTime.Now)
                                                        {
                                                            sb.Append("<td>已过期</td>");
                                                        }
                                                        else
                                                        {
                                                            sb.Append("<td>未过期</td>");
                                                        }
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
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
