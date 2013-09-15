<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
    protected NameValueCollection user = new NameValueCollection();
    protected NameValueCollection partner = new NameValueCollection();
    public BaseUserControl baseuser = new BaseUserControl();
    protected bool over = false;
    protected int teamid = 0;
    protected ITeam CurrentTeam = Store.CreateTeam();
    protected DateTime overtime = DateTime.Now;  //团购结束时间
    public int sortorder = 0;
    public NameValueCollection _system = new NameValueCollection();
    public string cityid = "0";
    protected NameValueCollection order = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        teamid = Helper.GetInt(Request["id"], 0);
        if (CurrentCity != null)
        {
            cityid = CurrentCity.Id.ToString();
        }
        if (teamid > 0)
        {
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                CurrentTeam = seion.Teams.GetByID(teamid);
            }
        }
        else
        {
            CurrentTeam = base.CurrentTeam;
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script language="javascript" type="text/javascript">
    function checksub_email() {
        var str = document.getElementById("sub_email").value;
        //对电子邮件的验证
        if (!str.match(/^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/)) {
            document.getElementById("sub_email").value = "";
            return false;
        }
        else {
            window.location.href = '<%=GetUrl("邮件订阅", "help_Email_Subscribe.aspx")%>' + '?email=' + str;
        }
    }
</script>
<script type="text/javascript">
    function fnOver(thisId) {
        var thisClass = thisId.className;
        var overCssF = thisClass;
        if (thisClass.length > 0) { thisClass = thisClass + " " };
        thisId.className = thisClass + overCssF + "hover";
    }
    function fnOut(thisId) {
        var thisClass = thisId.className;
        var thisNon = (thisId.className.length - 5) / 2;
        thisId.className = thisClass.substring(0, thisNon);
    }
</script>
<script type="text/javascript">
    function g(o) { return document.getElementById(o); }
    function hoverli(n) {
        for (var i = 1; i <= 2; i++) { g('tab_' + i).className = 'taa'; g('tbc_0' + i).className = 'map_undis'; } g('tbc_0' + n).className = 'map_list2'; g('tab_' + n).className = 'tbb';
    }
    function fun() {
        hoverli(2);
    }
    function hoverli2(n) {
        for (var i = 1; i <= 2; i++) { g('js_' + i).className = 'taa'; g('jsc_0' + i).className = 'map_undis'; } g('jsc_0' + n).className = 'map_list2'; g('js_' + n).className = 'tbb';
    }
    function fun2() {
        hoverli2(2);
    }
    function hoverli3(n) {
        for (var i = 1; i <= 2; i++) { g('be_' + i).className = 'taa'; g('bec_0' + i).className = 'map_undis'; } g('bec_0' + n).className = 'map_list2'; g('be_' + n).className = 'tbb';
    }
    function fun3() {
        hoverli2(2);
    }         
</script>
<div id="bdw" class="bdw">
  <!--左悬浮菜单-->
  <%LoadUserControl(WebRoot + "UserControls/leftmenu.ascx", null); %>
    <div id="bd" class="cf">
        <%LoadUserControl(PageValue.WebRoot + "UserControls/admid.ascx", null); %>
        <%if (over)
          { %>
        <div id="sysmsg-tip" class="sysmsg-tip-deal-close">
            <div class="sysmsg-tip-top">
            </div>
            <div class="sysmsg-tip-content">
                <div class="deal-close">
                    <div class="focus">
                        抱歉，您来晚了，<br />
                        团购已经结束啦。</div>
                    <div id="tip-deal-subscribe-body" class="body">
                        <table>
                            <tr>
                                <td>
                                    不想错过明天的团购？立刻订阅每日最新团购信息：&nbsp;
                                </td>
                                <td>
                                    <input id="sub_email" type="text" value="" class="f-text" name="sub_email" />
                                </td>
                                <td>
                                    &nbsp;
                                    <input id="Button3" type="button" class="commit validator" value="订阅" onclick="checksub_email()" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <span id="sysmsg-tip-close" class="sysmsg-tip-close">关闭</span></div>
            <div class="sysmsg-tip-bottom">
            </div>
        </div>
        <%} %>
        <%if (order.Count > 0)
          {
              if (CurrentTeam.Farefree == 0 || CurrentTeam.Delivery == "coupon")
              {
        %>
        <div id="sysmsg-tip">
            <div class="sysmsg-tip-top">
            </div>
            <div class="sysmsg-tip-content">
                您已经下过订单，但还没有付款。<a href="<%=GetUrl("优惠卷确认","order_check.aspx?orderid="+order["id"])%>">查看订单并付款</a>
                <span id="sysmsg-tip-close" class="sysmsg-tip-close">关闭</span></div>
            <div class="sysmsg-tip-bottom">
            </div>
        </div>
        <%}
          }%>
        <div id="deal-default">
            <%LoadUserControl(PageValue.WebRoot + "UserControls/blockshare.ascx", CurrentTeam); %>
            <!--加载项目信息-->
            <%LoadUserControl(PageValue.WebRoot + "UserControls/team_view.ascx", CurrentTeam); %>
        </div>
        <!-- bd end -->
    </div>
</div></div>
<!-- bdw end -->
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
