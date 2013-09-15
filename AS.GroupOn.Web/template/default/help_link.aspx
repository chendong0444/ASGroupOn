<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected List<Hashtable> FriendlinkList = null;
    protected List<Hashtable> FriendlinkList1 = null;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {
            if (ASSystem.title == String.Empty)
            {
                AS.GroupOn.Controls.PageValue.Title = "团购达人";
            }
            AS.GroupOn.Controls.PageValue.Title = "友情链接";
            string sql1 = "select Id,Title,url,Logo,Sort_order FROM Friendlink  where  Logo !='' order by Sort_order desc";
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                FriendlinkList = session.GetData.GetDataList(sql1.ToString());
            }

            string sql2 = "select Id,Title,url,Logo,Sort_order FROM Friendlink  where title !='' order by Sort_order desc ";
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                FriendlinkList1 = session.GetData.GetDataList(sql2.ToString());
            }
        }

    }
    
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form1" runat="server">
    <div id="bdw" class="bdw">
        <div id="bd" class="cf">
            <div id="maillist">
                <div id="content">
                    <div class="box">

                        <div class="box-content welcome">
                            <div class="head">
                                <h2>友情链接</h2>
                            </div>
                            <div class="sect">
                                <div class="link">
                                    <ul class="link_img">
                                        <% foreach (Hashtable item in FriendlinkList)
                                           {%>
                                        <li>
                                            <a href="<%=item["url"] %>" title="<%=item["Title"] %>" target="_blank">
                                                <img src="<%=item["Logo"] %>" alt="<%=item["Title"] %>" />
                                            </a>
                                        </li>
                                        <%} %>
                                    </ul>

                                </div>
                                <div class="cl">
                                    <ul class="txt_link">
                                        <% foreach (Hashtable item1 in FriendlinkList1)
                                           {%>
                                        <li>
                                            <a href="<%=item1["url"]%>" target="_blank"><%=item1["Title"] %></a>
                                        </li>
                                        <%} %>
                                    </ul>
                                </div>


                                <div class="intro">
                                    <p>1、不链接有不良内容或提供不良内容链接的网站，以及网站名称或内容违反国家有关政策法规的网站；</p>
                                    <p>2、不链接含有病毒、木马，弹出插件或恶意更改他人电脑设置的网站、及有多个弹窗广告的网站；</p>
                                    <p>3、不链接网站名称和实际内容不符的网站，如贵站正在建设中，或尚未明确主题的网站，请不必现在申请收录，欢迎您在贵站建设完毕后再申请；</p>
                                    <p>4、不链接非顶级域名、挂靠其他站点、无实际内容，只提供域名指向的网站或仅有单页内容的网站；</p>
                                    <p>5、不链接在正常情况下无法访问的网站；</p>
                                    <p>6、注意：<a href="<%=GetUrl("意见反馈", "feedback_suggest.aspx")%>">提交申请</a>前请做好本站的链接，否则不予通过。</p>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
                <%--<div id="sidebar">
	<div class="side-pic">
	    <p><img src="<%=AS.GroupOn.Controls.PageValue.WebRoot%>upfile/css/i/subscribe-pic1.jpg" /></p>
        <p><img src="<%=AS.GroupOn.Controls.PageValue.WebRoot%>upfile/css/i/subscribe-pic2.jpg" /></p>
        <p><img src="<%=AS.GroupOn.Controls.PageValue.WebRoot%>upfile/css/i/subscribe-pic3.jpg" /></p>
	</div>
</div>--%>
            </div>
        </div>
    </div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
