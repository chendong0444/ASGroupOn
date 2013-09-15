<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
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
    NameValueCollection _system = new NameValueCollection();
    protected string week = String.Empty;
    protected string logincss = String.Empty;
    protected string strRes = "0";
    protected int userid = 0;
    public override void UpdateView()
    {
        _system = PageValue.CurrentSystemConfig;
        week = DateTime.Now.DayOfWeek.ToString();
        if (!IsLogin)
        {
            logincss = "info";
        }
        else
        {
            if (AsUser.Id != 0)
            {
                if (!AsUser.Sign_time.HasValue || (AsUser.Sign_time.HasValue && AsUser.Sign_time.Value.Date != DateTime.Now.Date))
                {
                    logincss = "info";
                }
                else
                {
                    logincss = "yqd";
                }
                userid = AsUser.Id;
                if (AsUser.Signmobile != "" && AsUser.Signmobile != null)
                {
                    strRes = "1";
                }
            }
        }
    } 
</script>
<%if (_system["opensign"] != null && _system["opensign"].ToString() != "" && _system["opensign"].ToString() == "1")
  { %>
<div class="deal-consult sbox">
    <script type="text/javascript">
        $(document).ready(function () {
            jQuery('#checkinspan').click(function () {
                var result = $("#checkinspan").attr("vresult");
                if (result == "0") {
                    X.get(webroot + 'ajax/coupon.aspx?action=sign');
                }
                else if (result == "1") {
                    var userid = $("#checkinspan").attr("vuser");
                    X.get(webroot + 'ajax/coupon.aspx?action=signlogin&&detailid=' + userid);
                }
            });
        });
        function addToFavorite() {
            var sURL = "<%=PageValue.WWWprefix%>";
            var sTitle = "<%=ASSystem.sitename %>";
            try {
                window.external.addFavorite(sURL, sTitle);
            }
            catch (e) {
                try {
                    window.sidebar.addPanel(sTitle, sURL, "");
                }
                catch (e) {
                    alert("\u5bf9\u4e0d\u8d77\uff0c\u60a8\u7684\u6d4f\u89c8\u5668\u4e0d\u652f\u6301\u6b64\u64cd\u4f5c!\n\u8bf7\u60a8\u4f7f\u7528\u83dc\u5355\u680f\u6216Ctrl+D\u6536\u85cf\u672c\u7ad9\u3002");
                }
            }
        }
</script>
    <div class="sbox-content">
        <div class="r-top">
        </div>
        <h3>
            每日签到</h3>
        <div class="qiandao-box">
            <!--<h2>签到</h2>-->
            <div class="sign-board">
                <div id="board" <%if(logincss=="info" ){%>class="info" <%}else if(logincss=="yqd"){%>class="yqd"
                    <%} %>>
                    <div id="weekday" class="<%=week.ToLower() %>">
                    </div>
                    <%if (logincss == "info")
                      {%>
                    <a title="点击此处签到" class="checkin_text" href="#" id="checkinspan" vresult="<%=strRes %>"
                        vuser="<%=userid %>">签到</a>
                    <%} %>
                    <%if (logincss == "info")
                      {%>
                    <div class="signtip">
                        今天没有签到！</div>
                    <%}
                      else if (logincss == "yqd")
                      { %>
                    <div class="signtip_yqd">
                        已签到！</div>
                    <%} %>
                </div>
                <%if (logincss == "info")
                  {
                      if (!IsLogin)
                      {
                    %>
                <p>
                    您还没有登录哦，要<a href="<%=GetUrl("用户登录","account_login.aspx")%>">登录</a>才能签到！</p>
                <%
}
                      else
                      {
                         %>
                <p>
                    <a href="<%=GetUrl("账户余额","credit_index.aspx")%>">查看金额 </a><a href="<%=GetUrl("我的积分","pointsshop_pointscore.aspx")%>">
                        查看积分！</a>
                </p>
                <%
}
                    %>
                <%}
                  else if (logincss == "yqd")
                  { %>
                <p>
                    <a href="<%=GetUrl("账户余额","credit_index.aspx")%>">查看金额 </a><a href="<%=GetUrl("我的积分","pointsshop_pointscore.aspx")%>">
                        查看积分！</a>
                </p>
                <%} %>
            </div>
            <ul class="list">
                <li>•每日签到可赚取<font class="qiandao-text">
                    <%if (_system != null && _system["loginmoney"].ToString() != "" && _system["loginmoney"].ToString() != "0")
                      { %>
                    &nbsp;
                    <%=ASSystemArr["Currency"]%><%=_system["loginmoney"]%><%} %>
                    <%if (_system["loginscore"] != null && _system["loginscore"].ToString() != "" && _system["loginscore"].ToString() != "0")
                      { %>
                    &nbsp;<%=_system["loginscore"]%>积分
                    <%} %>
                </font></li>
                <li>• 通过以下途径访问可&lt;快捷签到&gt;</li>
            </ul>
            <div class="reward">
                <div class="link">
                    <div class="fl desk">
                        <a href="<%=PageValue.TemplatePath %>usercontrols_shorturl.aspx" style="color: green;">桌面图标</a></div>
                    <div class="fl favorite" onclick="this.style.behavior='url(#default#homepage)';this.setHomePage('<%=PageValue.WWWprefix %>');">
                        设为首页</div>
                    <div class="fl webIndex">
                        <a href="javascript:addToFavorite()">加入收藏夹</a></div>
                    <p class="clear">
                    </p>
                </div>
            </div>
        </div>
        <div class="r-bottom">
        </div>
    </div>
</div>
<%} %>