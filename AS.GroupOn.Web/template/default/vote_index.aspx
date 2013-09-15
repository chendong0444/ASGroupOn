<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">

    protected IVote_Question vote_Ques = Store.CreateVote_Question();
    protected string strAbbreviation = string.Empty;
    protected IList<IVote_Question> list = null;
    protected IList<IVote_Options> list_Options = null;
    protected int i = 0;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Form.Action = GetUrl("小调查", "vote_index.aspx");
        if (ASSystem != null)
        {
            strAbbreviation = ASSystem.abbreviation;
        }
        if (!Page.IsPostBack)
        {
            initList();
        }

    }

    private void initList()
    {

        NeedLogin();


        StringBuilder sb = new StringBuilder();
        Vote_QuestionFilters vf = new Vote_QuestionFilters();
        vf.IsShow = 1;
        vf.AddSortOrder(Vote_QuestionFilters.Order_DESC);
        using (IDataSession seion = Store.OpenSession(false))
        {
            list = seion.Vote_Question.GetList(vf);
        }


        if (list != null && list.Count > 0)
        {
            foreach (IVote_Question vote in list)
            {

                string Type = vote.Type.ToString();
                string Title = vote.Title.ToString();
                int QId = vote.id;
                sb.Append("<li id=\"vote-list-" + (i + 1).ToString() + "\">");
                sb.Append("<h4 id=\"title" + QId + "\">" + (i + 1).ToString() + "、" + Title + "<input type='hidden' id='q' name='q' value='" + QId + "'></h4>");
                sb.Append("<div class=\"choices\">");

                //得到该问题的选项

                Vote_OptionsFilters vof = new Vote_OptionsFilters();
                vof.Question_ID = QId;
                vof.is_show = 1;
                vof.AddSortOrder(Vote_OptionsFilters.Order_ASC);
                using (IDataSession seion = Store.OpenSession(false))
                {
                    list_Options = seion.Vote_Options.GetList(vof);
                }

                if (list_Options != null && list_Options.Count > 0)
                {
                    foreach (IVote_Options vote_option in list_Options)
                    {
                        string name = vote_option.name.ToString();
                        string is_br = vote_option.is_br.ToString();
                        string is_input = vote_option.is_input.ToString();
                        string OID = vote_option.id.ToString();

                        sb.Append("<input type=\"" + Type + "\" value=\"" + OID + "\"  name=\"op" + QId + "\" class=\"choice\"/>");
                        sb.Append("<label class=\"text\" for=\"label-" + QId + "-" + OID + "\">" + name + "</label>");
                        if (is_input == "1")
                        {
                            sb.Append("<input type=\"text\" class=\"f-text\" name=\"txt" + OID + "\" id=\"input" + OID + "\" onfocus=\"document.getElementById('label-" + QId + "-" + OID + "').checked = true;\" onblur=\"document.getElementById('label-" + QId + "-" + OID + "').checked = this.value ? true : false;\">");
                        }
                        if (is_br == "1")
                        {
                            sb.Append("<br>");
                        }

                    }
                }

                sb.Append("</div>");
                sb.Append("</li>");

                i++;

            }


        }

        else
        {
            sb.Append("暂无调查！");
            submit.Visible = false;
        }

        ltQuesstion.Text = sb.ToString();
    }

    bool result = false;
    protected void submit_ServerClick(object sender, EventArgs e)
    {
        int iUserID = 0;
        string strUserName = CookieUtils.GetCookieValue("username", Key);
        IUser user = Store.CreateUser();
        UserFilter uf = new UserFilter();
        uf.Username = strUserName;
        using (IDataSession seion = Store.OpenSession(false))
        {
            user = seion.Users.GetByName(uf);
        }

        if (user != null)
        {
            iUserID = user.Id;
        }
        string str = Request.Form["q"].ToString();
        string[] quesstion = str.Split(',');

        for (int i = 0; i < quesstion.Length; i++)
        {
            int QuesstionID = int.Parse(quesstion[i]);

            if (Request.Form["op" + QuesstionID + ""] != null)
            {
                IList<IVote_Feedback_Question> list_vfq = null;
                Vote_Feedback_QuestionFilters vfqf = new Vote_Feedback_QuestionFilters();
                vfqf.Feedback_ID = iUserID;
                vfqf.Question_ID = QuesstionID;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    list_vfq = seion.Vote_Feedback_Question.GetList(vfqf);
                }

                if (list_vfq != null && list_vfq.Count > 0)
                {
                    result = true;
                }
                if (!result)
                {
                    //得选项框的数目，并把数据存到暂时的数组里
                    string[] opptions = Request.Form["op" + QuesstionID + ""].ToString().Split(',');

                    //遍历选项框的内容，并查找文本框的内容

                    for (int j = 0; j < opptions.Length; j++)
                    {

                        #region 选择框
                        IVote_Feedback_Question mVoteFQ = Store.CreateVote_Feedback_Question();
                        mVoteFQ.question_id = QuesstionID;
                        mVoteFQ.feedback_id = iUserID;
                        mVoteFQ.options_id = Convert.ToInt32(opptions[j].ToString());

                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            seion.Vote_Feedback_Question.Insert(mVoteFQ);
                        }

                        #endregion
                        #region 文本框
                        if (Request.Form["txt" + opptions[j] + ""] != null && Request.Form["txt" + opptions[j] + ""].ToString() != "")
                        {
                            string txtValue = Request.Form["txt" + opptions[j] + ""].ToString();
                            IVote_Feedback_Input mvfi = Store.CreateVote_Feedback_Input();
                            mvfi.feedback_id = iUserID;
                            mvfi.options_id = Convert.ToInt32(opptions[j].ToString());
                            mvfi.value = HttpUtility.HtmlEncode(txtValue);

                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                seion.Vote_Feedback_Input.Insert(mvfi);
                            }
                        }
                        #endregion

                    }
                    IVote_Feedback mvf = Store.CreateVote_Feedback();
                    mvf.Addtime = DateTime.Now;

                    mvf.User_id = iUserID;
                    mvf.Username = strUserName;
                    mvf.Ip = WebUtils.GetClientIP;
                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        seion.Vote_Feedback.Insert(mvf);
                    }
                    SetSuccess("您的调查结果已提交！");

                    Response.Redirect(GetUrl("小调查", "vote_index.aspx"));
                }
                else
                {
                    SetError("您已经参与过调查!");
                    Response.Redirect(GetUrl("小调查", "vote_index.aspx"));
                }
            }
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
        <script type="text/javascript" src="<%=WebRoot%>upfile/js/vote.js"></script>
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="user-vote">
                    <div id="content">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>用户调查</h2>
                                </div>
                                <div class="sect">
                                    <p class="welcome">
                                        回答几个小问题，让<%=strAbbreviation%>更好的为您服务！
                                    </p>
                                    <ol class="vote-list">
                                        <asp:literal id="ltQuesstion" runat="server"></asp:literal>
                                    </ol>
                                    <div class="commit">
                                        <input type="submit" class="formbutton" id="submit" name="submit" value="提交" runat="server"
                                            onserverclick="submit_ServerClick" />
                                    </div>
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
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
