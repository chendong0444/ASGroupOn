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
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Form.Action = GetUrl("商务合作", "feedback_seller.aspx");

        if (!Page.IsPostBack)
        {
            if (PageValue.CurrentSystemConfig != null)
            {
                if (PageValue.CurrentSystemConfig["shop"] != null)
                {
                    if (PageValue.CurrentSystemConfig["shop"] == "1")//开启商务合作，必须登陆
                    {
                        initPage();
                    }
                    else
                    {
                        hfUID.Value = "0";
                        hfCityID.Value = "0";
                        reister();
                    }
                }
                else
                {
                    initPage();
                }
            }
            else
            {
                initPage();
            }
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
    public void reister()
    {

        if (CookieUtils.GetCookieValue("username", Key).Length > 0)
        {
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
            Response.Redirect(GetUrl("商务合作", "feedback_seller.aspx"));
        }
        if (strContent.Length >= 500)
        {
            SetError("内容不能超过500个汉字提交!");
            Response.Redirect(GetUrl("商务合作", "feedback_seller.aspx"));
        }

        IFeedback m_feedback = Store.CreateFeedback();
        m_feedback.Contact = HttpUtility.HtmlEncode(strContract);
        m_feedback.Content = HttpUtility.HtmlEncode(strContent);
        m_feedback.Create_time = DateTime.Now;
        m_feedback.title = HttpUtility.HtmlEncode(strTitle);
        //m_feedback.User_id = UID;
        m_feedback.Category = "seller";
        m_feedback.City_id = city_id;

        using (IDataSession seion = Store.OpenSession(false))
        {
            seion.Feedback.Insert(m_feedback);
        }
        SetSuccess("添加成功！");
        Response.Redirect(GetUrl("商务合作成功", "feedback_success.aspx"));
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form1" runat="server">
    <div id="pagemasker"></div>
    <div id="dialog"></div>
    <div id="doc">

        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="feedback">
                    <div id="content" class="clear">
                        <div class="box">

                            <div class="box-content">
                                <div class="head">
                                    <h2>提供团购信息</h2>
                                </div>
                                <div class="sect">
                                    <p class="notice">特别欢迎优质商家、淘宝大卖家提供团购信息。</p>

                                    <div class="field fullname">
                                        <label for="feedback-fullname">您的称呼</label>
                                        <input type="text" size="30" name="title" id="feedbackfullname" class="f-input" require="true" datatype="require" runat="server" />
                                    </div>
                                    <div class="field email">
                                        <label for="feedback-email-address">联系方式</label>
                                        <input type="text" size="30" name="contact" id="feedbackemailaddress" class="f-input" require="true" datatype="require" runat="server" />
                                        <span class="hint">请留下您的手机、QQ号或邮箱，方便联系</span>
                                    </div>
                                    <div class="field suggest">
                                        <label for="feedback-suggest">团购信息</label>
                                        <textarea cols="30" rows="5" name="content" id="feedbacksuggest" class="f-textarea" require="true" datatype="require" runat="server"></textarea>
                                    </div>
                                    <div class="clear"></div>
                                    <div class="act">
                                        <input type="submit" value="提交" name="commit" id="feedbacksubmit" class="formbutton" runat="server" onserverclick="submit_ServerClick" />
                                        <asp:hiddenfield id="hfUID" runat="server" />
                                        <asp:hiddenfield id="hfCityID" runat="server" />
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
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
