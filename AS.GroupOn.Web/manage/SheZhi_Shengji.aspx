<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<script runat="server">

    protected string newversion = "是";//最新版
    protected string down = "";//远程升级信息
    protected string des = String.Empty;
    protected decimal serverversion = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if(AdminPage .IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin,ActionEnum.Option_Data_Escalate)){
            SetError("你不具有数据库升级的权限");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        try
        {
            System.Net.WebClient wc = new System.Net.WebClient();
            des = wc.DownloadString("http://update.asdht.com/db.aspx?cur=" + ASSystem.siteversion.ToString());
            serverversion = AS.Common.Utils.Helper.GetDecimal(des, 0);
        }
        catch (Exception ex) { down = ex.Message; }
    }
</script>
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
                <div id="help">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        艾尚团购软件 (ASdht_V<%=AS.Common.Utils.Version.SiteVersion%>)数据库:<%=ASSystemArr["siteversion"]%></h2>
                                </div>
                                <div class="sect">
                                    <div class="wholetip clear">
                                        <h3>
                                            关注我们 技术论坛<a target="_blank" href="http://bbs.asdht.com">bbs.asdht.com</a></h3>
                                    </div>
                                    <%
                                        if (serverversion > 0)
                                        { 
                                    %>
                                    <div class="wholetip clear">
                                        <h3>
                                            数据库最新版本&nbsp;[<span style="color: red"><%=serverversion%></span>] <a target="_blank"
                                                href="updatabase.aspx?db=<%=serverversion %>">
                                                点击此处升级</a></h3>
                                    </div>
                                    <%
                                        }
                   else
                   {
                       if (down.Length > 0)
                       {
                                    %>
                                    <div class="wholetip clear">
                                        <h3>
                                            <%=down %></h3>
                                    </div>
                                    <% 
                                        }
                   }     
                                    %>
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
<% LoadUserControl("_footer.ascx", null); %>