<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<script runat="server">
    protected bool isOpera = false;
    protected int isid = 0;
    protected int pid = 0;
    protected override void OnLoad(EventArgs e)
    {
        if (AS.Common.Utils.Helper.GetString(Request["opera"], String.Empty) == "1")
        {
            isOpera = true;
        }
        if (AS.Common.Utils.Helper.GetString(Request["id"], String.Empty) != null)
        {
            isid = AS.Common.Utils.Helper.GetInt(Request["id"], 0);
        }
        if (AS.Common.Utils.Helper.GetString(Request["id"], String.Empty) != null)
        {
            pid = AS.Common.Utils.Helper.GetInt(Request["id"], 0);
        }
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
                    <!--<div class="dashboard" id="dashboard">
	</div>-->
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        首页</h2>
                                </div>
                                <div class="sect">
                                    <div style="margin-left: 20px; margin-top: 20px;">
                                        <%
      
                                            Response.Write("服务器操作系统:" + Environment.OSVersion + "<br>");
                                            Response.Write("服务器CPU处理器数量：" + Environment.ProcessorCount + "<br>");
                                            Response.Write(".NET 运行版本:" + Environment.Version + "<br>");
                            
                                        %>
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
    <%if (isOpera)
      { %>
    <script type="text/javascript">
        jQuery(document).ready(function () {
            X.get('/ajax/coupon.aspx?action=bizdialog&a=' + Math.random());
        });
    </script>
    <%} %>
    <%if (isid > 0)
      { %>
    <script type="text/javascript">
        jQuery(document).ready(function () {
            X.get('/manage/PersonalInfo.aspx?id=<%=isid %>');
        });
    </script>
    <%} %>
    <%if (pid > 0)
      { %>
    <script type="text/javascript">
        jQuery(document).ready(function () {
            X.get('/manage/ChangePWD.aspx?id=<%=pid %>');
        });
    </script>
    <%} %>
</body>
<%LoadUserControl("_footer.ascx", null); %>