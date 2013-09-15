<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>

<script language="c#" runat="server">
    protected string strNav = String.Empty;
    public override void UpdateView()
    {
        StringBuilder sb = new StringBuilder();
        string name = "";
        if (ASSystem != null)
        {
            name = ASSystem.abbreviation;
        }
		sb.Append("<ul><h3>使用帮助</h3>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("help_tour.aspx") + " ><a href=\"" + GetUrl("玩转东购团", "help_tour.aspx") + "\">玩转" + name + "</a></li>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("help_faqs.aspx") + " ><a href=\"" + GetUrl("常见问题", "help_faqs.aspx") + "\">常见问题</a></li>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("help_asdht.aspx") + "><a href=\"" + GetUrl("东购团概念", "help_asdht.aspx") + "\">什么是" + name + "</a></li>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("help_api.aspx") + "><a href=\"" + GetUrl("开发API", "help_api.aspx") + "\">开发api</a></li>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("help_pendant.aspx") + "><a href=\"" + GetUrl("团购挂件", "help_pendant.aspx") + "\">团购挂件</a></li>");
        sb.Append("<div class='dashboard_line'></div>");
		sb.Append("<h3>更新订阅</h3>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("subscribe.aspx") + " ><a href=\"" + GetUrl("邮件订阅", "help_Email_Subscribe.aspx") + "\">邮件订阅</a></li>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("help_RSS_feed.aspx") + " ><a href=\"" + GetUrl("RSS订阅", "help_RSS_feed.aspx") + "\">RSS订阅</a></li>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("subscribe.aspx") + " ><a href=\""+ASSystem.sinablog+"\">" + name + "新浪微博</a></li>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("feed.aspx") + " ><a href=\""+ASSystem.qqblog+"\">" + name + "腾讯微博</a></li>");
        sb.Append("<div class='dashboard_line'></div>");
		sb.Append("<h3>关于我们</h3>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("about_us.aspx") + " ><a href=\"" + GetUrl("关于东购团", "about_us.aspx") + "\">关于" + name + "</a></li>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("about_job.aspx") + " ><a href=\"" + GetUrl("工作机会", "about_job.aspx") + "\">工作机会</a></li>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("about_contact.aspx") + "><a href=\"" + GetUrl("联系方式", "about_contact.aspx") + "\">联系方式</a></li>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("about_terms.aspx") + "><a href=\"" + GetUrl("用户协议", "about_terms.aspx") + "\">用户协议</a></li>");
        sb.Append("<li  " + AS.Common.Utils.Utility.GetStyle("about_privacy.aspx") + "><a href=\"" + GetUrl("隐私声明", "about_privacy.aspx") + "\">隐私声明</a></li></ul>");
        strNav = sb.ToString(); 
    }
    
</script>
<%= strNav%>