<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">


  
    public string strTitle = "意见反馈";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Form.Action = GetUrl("意见反馈", "feedback_suggest.aspx");
        if (!Page.IsPostBack)
        {
            initPage();
        }
    }

    private void initPage()
    {

        NeedLogin();

        string strEmail = "";

        string strUserName = CookieUtils.GetCookieValue("username", Key);
        IUser user = null;
        UserFilter uf = new UserFilter();
        uf.Username = strUserName;
        using (IDataSession seion = Store.OpenSession(false))
        {
            user = seion.Users.GetByName(uf);
        }


        if (user != null)
        {

            hfUID.Value = user.Id.ToString();
            hfCityID.Value = user.City_id.ToString();
            strEmail = user.Email.ToString();
        }

        feedbackfullname.Value = strUserName;
        feedbackemailaddress.Value = strEmail;

    }

    protected void submit_ServerClick(object sender, EventArgs e)
    {
        int UID = int.Parse(hfUID.Value);
        int city_id = int.Parse(hfCityID.Value);


        string strTitle = feedbackfullname.Value;
        string strContract = feedbackemailaddress.Value;
        string strContent = feedbacksuggest.Value;

        if (strTitle == "" || strContract == "" || strContent == "")
        {
            SetError("请完成信息后再提交!");
            Response.Redirect(GetUrl("意见反馈", "feedback_suggest.aspx"));
        }
        if (strContent.Length >= 500)
        {
            SetError("内容不能超过500个汉字提交!");
            Response.Redirect(GetUrl("意见反馈", "feedback_suggest.aspx"));
        }
        IFeedback m_feedback = Store.CreateFeedback();
        m_feedback.Contact = HttpUtility.HtmlEncode(strContract);
        m_feedback.Content = HttpUtility.HtmlEncode(strContent);
        m_feedback.Create_time = DateTime.Now;
        m_feedback.title = HttpUtility.HtmlEncode(strTitle);
        m_feedback.Category = "suggest";
        m_feedback.City_id = city_id;

        using (IDataSession seion = Store.OpenSession(false))
        {
            seion.Feedback.Insert(m_feedback);
        }
        Response.Redirect(GetUrl("商务合作成功", "feedback_success.aspx"));
    }

    private void ShowMsg(string Msg)
    {
        Response.Write("<script type=\"text/javascript\">");
        Response.Write("alert(\"" + Msg + "\");");

        StringBuilder sb = new StringBuilder();
        sb.Append("</");
        sb.Append("script>");
        Response.Write(sb);

    }

    
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server" class="validator">

        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="feedback">
                    <div id="content" class="help">
                        <div class="box">

                            <div class="box-content">
                                <div class="head">
                                    <h2>意见反馈</h2>
                                </div>
                                <div class="sect">
                                    <p class="notice">请在这里留下您的宝贵意见，也可以给我们推荐您希望团购的商家。</p>

                                    <div class="field fullname">
                                        <label for="feedback-fullname">您的称呼</label>
                                        <input type="text" size="30" name="title" id="feedbackfullname" class="f-input" require="true" datatype="require" runat="server" />
                                    </div>
                                    <div class="field email">
                                        <label for="feedback-email-address">联系方式</label>
                                        <input type="text" size="30" name="contact" id="feedbackemailaddress" class="f-input" require="true" datatype="require" runat="server" />
                                        <span class="hint">请留下您的 Email 或 QQ 号，方便我们回复</span>
                                    </div>
                                    <div class="field suggest">
                                        <label for="feedback-suggest">内容</label>
                                        <textarea cols="30" rows="5" name="content" id="feedbacksuggest" class="f-textarea" require="true" datatype="require" runat="server"></textarea>
                                    </div>
                                    <div class="clear"></div>
                                    <div class="act">
                                        <input type="submit" value="提交" name="commit" id="feedbacksubmit" class="formbutton" runat="server" onserverclick="submit_ServerClick" />
                                        <asp:HiddenField ID="hfUID" runat="server" />
                                        <asp:HiddenField ID="hfCityID" runat="server" />
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
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>

