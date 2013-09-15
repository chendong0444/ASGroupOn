<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.WapBodyID = "feedback";
        PageValue.Title = "意见反馈";
        if (PageValue.CurrentSystemConfig != null && PageValue.CurrentSystemConfig["shop"] != null && PageValue.CurrentSystemConfig["shop"] == "1")
        {
            MobileNeedLogin();
        }
        if (Request.Form["btnadd"] == "提交")
        {
            int UID = AsUser.Id;
            int city_id = CurrentCity.Id;
            string strTitle = Request["username"];
            string strContract = Request["email"];
            string strContent = Request["content"];
            if (strTitle == "" || strContract == "" || strContent == "")
            {
                SetError("请完成信息后再提交!");
                Response.Redirect(GetUrl("手机版反馈意见", "help_feedback.aspx"));
            }
            if (strContent.Length >= 500)
            {
                SetError("内容不能超过500个汉字提交!");
                Response.Redirect(GetUrl("手机版反馈意见", "help_feedback.aspx"));
            }
            IFeedback m_feedback = Store.CreateFeedback();
            m_feedback.Contact = HttpUtility.HtmlEncode(strContract);
            m_feedback.Content = HttpUtility.HtmlEncode(strContent);
            m_feedback.Create_time = DateTime.Now;
            m_feedback.title = HttpUtility.HtmlEncode(strTitle);
            m_feedback.Category = "seller";
            m_feedback.City_id = city_id;

            using (IDataSession seion = Store.OpenSession(false))
            {
                seion.Feedback.Insert(m_feedback);
            }
            SetSuccess("添加成功！");
            Response.Redirect(GetUrl("手机版反馈意见", "help_feedback.aspx"));
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div class="body">
    <form method="post" action="<%=GetUrl("手机版反馈意见", "help_feedback.aspx") %>" id="form">
        <p>感谢您使用<%=PageValue.CurrentSystem.sitename%>手机版！</p>
        <p>
            <textarea class="common-text" style="height: 100px; padding: 10px;" name="content" placeholder="请填写您的宝贵意见"></textarea>
        </p>
        <p>请留下您的联系方式，以便联系:</p>
        <p>
            <input class="common-text" name="username" placeholder="您的称呼" value="<%if (AsUser.Id > 0) {%><%=AsUser.Username %><% } %>" />
            <input class="common-text" name="email" placeholder="联系方式" value="<%if (AsUser.Id > 0) {%><%=AsUser.Email %><% } %>" />
        </p>
        <p class="c-submit ">
            <input type="submit" value="提交" name="btnadd" id="btnadd" />
        </p>
    </form>
    <p>
        客服电话：<a href="tel:<%=PageValue.CurrentSystem.tuanphone %>"><%=PageValue.CurrentSystem.tuanphone %></a>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>