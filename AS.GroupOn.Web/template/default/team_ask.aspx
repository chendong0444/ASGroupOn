<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
    
    public string strAbbreviation = "";
    public string strTeamID = "";
    public string strTeamTitle = "";
    public ITeam m_team = Store.CreateTeam();
    protected NameValueCollection order = new NameValueCollection();
    public IList<IOrder> orderlist = null;
    public IList<IAsk> asklist = null;
    protected IPagers<IAsk> pager = null;
    protected string url = "";
    protected string strClassAll = "";
    protected string strClassMe = "";
    public string strpage;
    public string pagenum = "1";
    string strtype = "0";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection _system = new NameValueCollection();
        _system = WebUtils.GetSystem();

        if (Request["pgnum"] != null)
        {
            if (NumberUtils.IsNum(Request["pgnum"].ToString()))
            {
                pagenum = Request["pgnum"].ToString();
            }
        }
        if (Request["type"] != null)
        {
            strtype = Request["type"].ToString();
        }

        if (Request["id"] != null && Request["id"].ToString() != "" && Request["id"].ToString() != "0")
        {
            strTeamID = Request["id"].ToString();
            using (IDataSession seion = Store.OpenSession(false))
            {
                m_team = seion.Teams.GetByID(int.Parse(strTeamID));
            }

            if (m_team != null)
            {
                strTeamTitle = m_team.Title;
                team_id.Value = strTeamID;
            }
            else
            {
                SetError("该项目不存在！");
                Response.Redirect(GetUrl("首页", "/index.aspx")); 
            }
        }
        if (!Page.IsPostBack)
        {

            if (Request["type"] != null && Request["type"].ToString() != "")
            {
                strtype = Request["type"].ToString();
                if (Request["type"].ToString() == "0")
                {
                    strClassAll = "class=\"cur\"";
                }
                if (Request["type"].ToString() == "1")
                {
                    //未登录的情况
                    if (CookieUtils.GetCookieValue("username", Key) == String.Empty)
                    {
                        strtype = "0";
                        strClassAll = "class=\"cur\"";
                    }
                    else
                    {
                        strClassMe = "class=\"cur\"";
                    }
                }
            }
            else
            {
                strClassAll = "class=\"cur\"";
            }

            Form.Action = GetUrl("本单答疑", "team_ask.aspx?id=" + strTeamID + "&type=" + strtype + "&pgnum={0}");
            type.Value = strtype;

            initWebName();
            initPage(strtype);
        }
    }

    private void initPage(string type)
    {
        initList(strTeamID, type);
    }
    private void initList(string strTeamID, string type)
    {

        url = GetUrl("本单答疑", "team_ask.aspx?id=" + strTeamID + "&type=" + strtype + "&pgnum={0}");
        AskFilter af = new AskFilter();
        if (type == "1")
        {
            af.User_id = AsUser.Id;
        }
        if (ASSystem.teamask == 0 && strTeamID != "")
        {
            af.Team_ID = int.Parse(team_id.Value, 0);
        }
        af.IsComment = true;
        af.PageSize = 10;
        af.AddSortOrder(AskFilter.Create_Time_DESC);
        af.CurrentPage = Helper.GetInt(Request.QueryString["pgnum"], 1);

        using (IDataSession session = Store.OpenSession(false))
        {
            pager = session.Ask.GetPager(af);
        }

        asklist = pager.Objects;

        if (pager.TotalRecords >= 10)
        {
            strpage = WebUtils.GetPagerHtml(10, pager.TotalRecords, pager.CurrentPage, url);
        }

        StringBuilder sb = new StringBuilder();

        if (asklist != null && asklist.Count > 0)
        {

            foreach (IAsk ask in asklist)
            {

                if (ask.Comment != null && ask.Comment.ToString() != "")
                {

                    IUser item = Store.CreateUser();

                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        item = seion.Users.GetByID(ask.User_id);
                    }

                    if (item != null)
                    {
                        sb.Append("<li>");
                        if (item.Avatar != null && item.Avatar != "")
                        {
                            sb.Append("<div class=\"coll\"><img width=\"50\" height=\"50\" src=\"" + item.Avatar + "\" alt=\"\">");
                        }
                        else
                        {
                            sb.Append("<div class=\"coll\"><img width=\"50\" height=\"50\" src=\"" + PageValue.WebRoot + "upfile/css/i/man.jpg\" alt=\"\">");
                        }
                        sb.Append("<span class=\"gray\">" + DateTime.Parse(ask.Create_time.ToString()).ToString("yy-MM-dd") + "</span>");
                        sb.Append("</div>");
                        sb.Append("<div class=\"colr\">");
                        sb.Append("<p><label>" + item.Username + ":</label><span>" + ask.Content.ToString() + "</span></p>");
                        sb.Append(" <div class=\"bord-box\">");
                        sb.Append(" <div class=\"top\"></div>");
                        sb.Append(" <div class=\"inner\">");
                        if (ask.Comment != null && ask.Comment.ToString() != "")
                        {
                            sb.Append(" <p class=\"replay\"><span class=\"gray\">  " + ask.Comment + "</span></p>");
                        }
                        else
                        {
                            sb.Append(" <p class=\"replay\"><span class=\"gray\">管理员正在处理您的请求，请耐心等待...</span></p>");
                        }
                        sb.Append(" </div>");
                        sb.Append(" <div class=\"bottom\"></div>");
                        sb.Append("<div><span class=\"sjIcon\">&nbsp;</span></div>");
                        sb.Append("</div>");
                        sb.Append("</div>");
                        sb.Append("</li>");
                    }

                }
            }
        }
        ltAsk.Text = sb.ToString();

    }


    private void initWebName()
    {
        ISystem system = Store.CreateSystem();

        using (IDataSession seion = Store.OpenSession(false))
        {
            system = seion.System.GetByID(1);
        }
        if (system != null)
        {

            if (system.abbreviation == null || system.abbreviation.ToString() == "")
            {
                strAbbreviation = "艾尚团购";
            }
            else
            {
                strAbbreviation = system.abbreviation.ToString();
            }

        }

    }

    protected void pager_PageChanged(object sender, EventArgs e)
    {
        initPage(type.Value);
    }

    protected void submit_ServerClick(object sender, EventArgs e)
    {

        if (CookieUtils.GetCookieValue("username", Key) == String.Empty)
        {
            SetError("用户名失效,请重新登录！");
            string url = GetUrl("用户注册", "account_loginandreg.aspx?backurl=" + this.Page.Server.UrlEncode(this.Page.Request.Url.ToString()));
            Response.Redirect(url);
            return;
        }
        if (consult_content.Value == "" || consult_content.Value == "您可以在这里留言...")
        {
            SetError("问题不能为空，请输入您的问题！");
            Response.Redirect(GetUrl("本单答疑","team_ask.aspx?id=" + team_id.Value + "&type=" + type.Value));
            return;
        }
        IAsk mAsk = Store.CreateAsk();
        mAsk.Team_id = int.Parse(team_id.Value);
        string strUserName = CookieUtils.GetCookieValue("username", Key);
        UserFilter uf = new UserFilter();
        IUser user = Store.CreateUser();
        uf.Username = strUserName;

        using (IDataSession seion = Store.OpenSession(false))
        {
            user = seion.Users.GetByName(uf);
        }

        if (user != null)
        {
            mAsk.User_id = int.Parse(user.Id.ToString());
        }

        mAsk.Content = HttpUtility.HtmlEncode(consult_content.Value);
        mAsk.Create_time = DateTime.Now;
        int cityid = 0;
        if (CurrentCity != null)
            cityid = CurrentCity.Id;
        mAsk.City_id = cityid;
        using (IDataSession seion = Store.OpenSession(false))
        {
            seion.Ask.Insert(mAsk);
        }
        SetSuccess("本单答疑已提交成功！");
        Response.Redirect(GetUrl("本单答疑", "team_ask.aspx?id=" + team_id.Value + "&type=" + type.Value));
    }

</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server">
        <script type="text/javascript">
            $(document).ready(function () {

                jQuery("#consult_content").attr("style", "color: rgb(217, 216, 216);");
                jQuery("#consult_content").html("您可以在这里留言...");
                $("#consult_content").blur(function () {
                    jQuery("#consult_content").attr("style", "color: rgb(217, 216, 216);");
                    var str = jQuery("#consult_content").val();
                    //alert(str);
                    if (str == null || str == "") {
                        jQuery("#consult_content").val("您可以在这里留言...");
                    }

                });

                $("#consult_content").click(function () {
                    jQuery(this).attr("style", "color: rgb(51, 51, 51);");
                    var str = jQuery("#consult_content").val();
                    if (str == "您可以在这里留言...") {
                        jQuery(this).val("");
                    }

                });

            });
        </script>

        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="consult">
                    <div class="consult-hd">
                    </div>
                    <div class="consult-bd">
                        <div id="content">
                            <div class="box clear">

                                <div class="box-content">
                                    <div class="head">
                                        <h2><%=strAbbreviation%>答疑</h2>
                                    </div>

                                    <div class="sect consult-list">

                                        <div class="onlineDiscuss">
                                            <h3><a href="<%=getTeamPageUrl(int.Parse(strTeamID))%>">返回本次团购:<%=strTeamTitle%></a></h3>
                                            <h2>会员:<label><%if (AsUser != null)
                                                            { %><%=AsUser.Username%><%}
                                                            else
                                                            { %><%=strAbbreviation%>网友<%} %></label>
                                                <span>
                                                    <a href="<%=GetUrl("本单答疑","team_ask.aspx?type=0&id="+strTeamID)%>" id="id1" <%=strClassAll%>>全部</a>
                                                    <a href="<%=GetUrl("本单答疑","team_ask.aspx?type=1&id="+strTeamID) %>" id="id2" <%=strClassMe%>>我的提问</a>
                                                </span>
                                            </h2>
                                            <div class="myQuest">
                                                <div style="display: none">
                                                    <input type="hidden" name="team_id" id="team_id" runat="server" /><input type="hidden" name="type" id="type" runat="server" /></div>
                                                <span id="feedback" style="display: none"></span>
                                                <div class="sub-box">
                                                    <div class="top"></div>
                                                    <div class="inner">
                                                        <fieldset>
                                                            <textarea class="f-textarea" cols="60" rows="5" name="content" group="a" require="true" maxlen="200" id="consult_content" runat="server"></textarea>
                                                        </fieldset>
                                                    </div>
                                                    <div class="bottom"></div>
                                                </div>
                                                <p>
                                                    <input type="submit" value=" " class="tjBtn" runat="server"
                                                        onserverclick="submit_ServerClick" />
                                                </p>

                                            </div>
                                        </div>


                                        <ul class="questList">

                                            <!--循环开始-->
                                            <asp:Literal ID="ltAsk" runat="server"></asp:Literal>
                                            <!--循环结束-->
                                        </ul>

                                    </div>
                                    <div class="clear">
                                        <ul class="paginator" style="margin-bottom: 40px; margin-bottom: 24px;">
                                            <li class="current">
                                                <%=strpage %>
                                            </li>
                                        </ul>
                                    </div>
                                </div>

                            </div>


                        </div>
                        <div id="sidebar">
                            <%LoadUserControl("../../UserControls/blockinvite.ascx", null); %>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
