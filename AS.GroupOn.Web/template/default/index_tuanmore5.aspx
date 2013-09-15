<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<body>
<script language="javascript" type="text/javascript">
    function checksub_email() {
        var str = document.getElementById("sub_email").value;
        if (!str.match(/^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/)) {
            document.getElementById("sub_email").value = "";
            return false;
        }
        else {
            window.location.href = '<%=GetUrl("邮件订阅", "help_Email_Subscribe.aspx")%>' + '?email=' + str;
        }
    }
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
    function show(obj) {
        $(obj).children('.adre_widtd').css("display", "block");
    }
    function hide(obj) {
        $(obj).children('.adre_widtd').css("display", "none");
    }
    $(document).ready(function () {
        var SysSecond = parseInt(jQuery('div.deal-timeleft').attr('diff')) / 1000;
        var InterValObj = window.setInterval(SetRemainTime, 1000);
        function SetRemainTime() {
            if (SysSecond > 0) {
                SysSecond = SysSecond - 1;
                var second = Math.floor(SysSecond % 60);
                var minite = Math.floor((SysSecond / 60) % 60);
                var hour = Math.floor((SysSecond / 3600) % 24);
                var day = Math.floor((SysSecond / 3600) / 24);
                if (day > 0) {
                    $("#counter").html("<span>" + day + "</span>天<span>" + hour + "</span>时<span>" + minite + "</span>分<span>" + second + "</span>秒");
                }
                else {
                    $("#counter").html("<span>" + hour + "</span>时<span>" + minite + "</span>分<span>" + second + "</span>秒");
                }
            } else {
                window.clearInterval(InterValObj);
            }
        }
    });
</script>

<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <!--广告位开始-->
        <%LoadUserControl(WebRoot + "UserControls/admid.ascx", null); %>
        <!--广告位结束-->
        <div id="deal-default">
            <%LoadUserControl("_tuan5lefttop.ascx", null); %>
            <div id="sidebar">
                <%LoadUserControl(WebRoot + "UserControls/adleft.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blockSign.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blockinvite.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blockcomment.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blockbulletin.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blockflv.ascx", CurrentTeam); %>
                <%LoadUserControl(WebRoot + "UserControls/blockask.ascx", CurrentTeam); %>
                <%LoadUserControl(WebRoot + "UserControls/blockqq.ascx", CurrentTeam); %>
                <%
                    if (WebUtils.config["newgao"] != null)
                    {
                        if (WebUtils.config["newgao"] == "1")
                        { %>
                <%LoadUserControl(WebRoot + "UserControls/uc_NewList.ascx", null); %>
                <%}
                    }%>
            </div>
            <!--一日多团4-->
            <%LoadUserControl("_tuan5leftbottom.ascx", null); %>
            <!-- bd end -->
        </div>
    </div>
</div>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
