<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    protected string headlogo = String.Empty;
    protected string curcityid = String.Empty;
    protected bool trsimple = false; //开启繁简转换
    protected string couponname = String.Empty;//优惠券名称
    protected string abbreviation = String.Empty;//网站简称
    protected bool opensmssubscribe = false; //是否开启短信订阅
    protected string url = String.Empty;
    protected string menuhtml = String.Empty;
    protected bool isPacket = false;
    protected IList<IGuid> iListGuid = null;
    protected IUser iuser = null;
    protected IList<IPacket> iListPacket = null;


    public override void UpdateView()
    {
        ShowMessage();
        GetGuid();
        //提取用户的相关信息
        UserFilter userfilter = new UserFilter();
        userfilter.Username = AsUser.Username;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iuser = session.Users.Get(userfilter);
            if (iuser != null)
            {

                PacketFilter packetfilter = new PacketFilter();
                packetfilter.State = "0";
                packetfilter.User_id = iuser.Id;

                iListPacket = session.Packet.GetList(packetfilter);
                if (iListPacket.Count > 0)
                {
                    isPacket = true;
                }
            }
        }
        if (CurrentCity != null)
        {
            curcityid = CurrentCity.Id.ToString();
        }
        if (ASSystem != null)
        {
            if (ASSystem.trsimple > 0) trsimple = true;
            couponname = ASSystem.couponname;
            abbreviation = ASSystem.abbreviation;

            if (PageValue.CurrentSystemConfig["mallheadlogo"] != null && PageValue.CurrentSystemConfig["mallheadlogo"].ToString() != "")
            {
                headlogo = PageValue.CurrentSystemConfig["mallheadlogo"];
            }
            else
            {
                headlogo = "/upfile/img/mall_logo.png";
            }
            opensmssubscribe = Convert.ToBoolean(ASSystem.smssubscribe);
        }
    }
    /// <summary>
    /// 显示导航栏目
    /// </summary>
    public void GetGuid()
    {

        GuidFilter guidfilter = new GuidFilter();
        guidfilter.teamormall = 1;
        guidfilter.AddSortOrder(GuidFilter.guidsort_desc);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListGuid = session.Guid.GetList(guidfilter);
        }
    }
</script>
<div id="hdw">
    <div id="hd">
        <div id="logo">
            <a href="<%=GetUrl("商城首页","mall_index.aspx")%>" class="link">
                <img height="58" src="<%=headlogo %>">
            </a>
        </div>
        <script type="text/javascript">
            $(document).ready(function () {
                $("#submit").click(function () {
                    var keyword = $("#keyword").val();
                    if (keyword.indexOf('<script>') >= 0) {

                        alert("非法字符！");
                        return;
                    }
                    if (keyword != "" && keyword != "请输入产品关键词...") {
                        window.location.href = webroot + "mall/catalist/0/0/0/0/0.html?keyword=" + encodeURIComponent(keyword);
                    }

                });

            });

            $(document).ready(function () {
                $("#keyword").keypress(function (event) {
                    if (event.keyCode == 13) {

                        var keyword = $("#keyword").val();

                        if (keyword.indexOf('<script>') >= 0) {

                            alert("非法字符！");
                            event.preventDefault();
                            return;
                        }

                        if (keyword != "" && keyword != "请输入产品关键词...") {

                            window.location.href = webroot + "mall/catalist/0/0/0/0/0.html?keyword=" + encodeURIComponent(keyword);
                            //window.location.href = webroot + "mall/categorylist.aspx?keyword=" + encodeURIComponent(keyword);
                            event.preventDefault();
                        }

                        event.preventDefault();

                    }

                });
            });
            $(document).ready(function () {
                $("#left_email").keypress(function (event) {
                    if (event.keyCode == 13) {

                        event.preventDefault();

                    }
                });

                $("#keyword").focus(function () {
                    var keyword = $("#keyword").val();
                    if (keyword == "请输入产品关键词...") {
                        $("#keyword").val("");
                    }
                }).blur(function () {
                    var keyword = $("#keyword").val();
                    if (keyword == "") {
                        $("#keyword").val("请输入产品关键词...");
                    }
                });
            });

     
        </script>
        <div class="ss">
            <input type="text" value="请输入产品关键词..." xtip="请输入产品关键词..." id="keyword" class="goinput" />
            <input type="button" class="goimg" value="" id="submit" name="submit" />
        </div>
        <% System.Collections.Generic.List<Car> carlist = new System.Collections.Generic.List<Car>();
           carlist = CookieUtils.GetCarData();
        %>
        <div class="cart">
            <a href="<%=GetUrl("购物车列表","shopcart_show.aspx")%>">购物车<span>
                <% if (carlist != null)
                   {%>
                <%=carlist.Count%>
                <% }
                   else
                   {%>
                0
                <% }%>
            </span>件<font class="qjs"></font></a>
        </div>
        <div id="menu2" class="menu">
            <ul>
                <%
                    bool click = false;
                    url = Request.Url.PathAndQuery;
                    string url1 = Request.RawUrl.ToString();
                    foreach (IGuid model in iListGuid)
                    {
                        if (model.guidopen == 0)
                        {
                            string target = "";
                            if (model.guidparent == 1)
                            {
                                target = "target=_blank";
                            }
                            if (url1 == model.guidlink || url == model.guidlink)
                            {
                                menuhtml = menuhtml + "<li class=\"dangqian\"><a href=\"" + model.guidlink + "\" " + target + ">" + model.guidtitle + "</a></li>";
                            }
                            else
                            {
                                menuhtml = menuhtml + "<li><a href=\"" + model.guidlink + "\"  " + target + ">" + model.guidtitle + "</a></li>";
                            }
                        }
                    }
                %>
                <%=menuhtml %></ul>
        </div>
        <!--邮件订阅-开始-->
        <div id="header-subscribe-body" class="subscribe">
     
            <script language="javascript" type="text/javascript">
                function checkEmail() {
                    var str = document.getElementById("header-subscribe-email").value;

                    //对电子邮件的验证
                    if (!str.match(/^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/)) {
                        document.getElementById("header-subscribe-email").value = "输入Email，订阅每日团购信息...";
                        return false;
                    }
                    else {
                        window.location.href = '<%=GetUrl("邮件订阅", "help_Email_Subscribe.aspx")%>' + '?email=' + str;
                    }
                }
                $(function () {
                    $("#header-subscribe-email").focus(function () {
                        $("#header-subscribe-email").val("");
                    }).blur(function () {
                        var str = $("#header-subscribe-email").val();
                        if (!str.match(/^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/)) {
                            $("#header-subscribe-email").val("输入Email，订阅每日团购信息...");
                        }
                        else {
                            window.location.href = '<%=GetUrl("邮件订阅", "help_Email_Subscribe.aspx")%>' + '?email=' + str;
                        }
                    });
                })
               
            </script>
            <input id="header-subscribe-email" type="text" xtip="输入Email，订阅每日团购信息..." value="输入Email，订阅每日团购信息..."
                class="f-text" name="head_email" />
            <input type="hidden" value="<%=curcityid %>" name="cityid" />
            <input id="Button2" type="button" class="commit validator" value="订阅" onclick="checkEmail()" />
            <%if (opensmssubscribe)
              { %>
            <span><a class="sms" onclick="X.miscajax('sms','subscribe');">&raquo; 短信订阅，免费！</a>&nbsp;
                <a class="sms" onclick="X.miscajax('sms','unsubscribe');">&raquo; 取消手机订阅</a></span>
            <%} %>
        </div>
        <!--邮件订阅-结束-->
        <div class="logins">
            <ul class="links">
                <%if (trsimple)
                  { %>
                <li><a href="<%=PageValue.WebRoot %>ajax/system.aspx?action=locale">简繁转换</a><em>|</em></li>
                <%} %>
                <%if (IsLogin && AsUser.Username != "")
                  { %>
                <% if (AsUser.Realname != null && AsUser.Realname != "")
                   {%>
                <li class="username">
                    <%=AsUser.Realname%>！欢迎您<em>|</em></li>
                <li class="account"><a href="<%=GetUrl("我的订单", "order_index.aspx")%>">我的订单</a><em>|</em></li>
                <%if (isPacket == true)
                  {%>
                <li class="account"><a href="<%=GetUrl("我的红包", "order_packet.aspx")%>">我的红包</a><span><b
                    style="color: Red;">(<%=iListPacket.Count %>)</b></span><em>|</em></li><%} %>
                <li class="logout"><a href="<%=PageValue.WebRoot %>loginout.aspx">退出</a></li>
                <%}
                   else
                   { %>
                <li class="username">
                    <%=AsUser.Username %>！欢迎您</li>
                <li class="account"><a href="<%=GetUrl("我的订单", "order_index.aspx")%>">我的<%=abbreviation%></a><em>|</em></li>
                <li class="logout"><a href="<%=PageValue.WebRoot %>account/logout.aspx">退出</a></li>
                <%} %>
                <%}
                  else
                  { %>
                <li class="login"><a href="<%=GetUrl("用户登录", "account_login.aspx")%>">登录</a><em>|</em></li>
                <li class="signup"><a href="<%=GetUrl("用户注册", "account_loginandreg.aspx")%>">注册</a></li>
                <%} %>
            </ul>
            <div class="line islogin">
            </div>
        </div>
    </div>
</div>
<%if (suctext != String.Empty)
  { %>
<div class="sysmsgw" id="sysmsg-success">
    <div class="sysmsg">
        <p>
            <%=suctext %></p>
        <span class="close">关闭</span></div>
</div>
<%} %>
<%if (errtext != String.Empty)
  { %>
<div class="sysmsgw" id="sysmsg-error">
    <div class="sysmsg">
        <p>
            <%=errtext %></p>
        <span class="close">关闭</span></div>
</div>
<%} %>
<%if (WebUtils.config["slowimage"] == "1")
  { %>
<script type="text/javascript">
    jQuery(function () {
        function b() {

            d.each(function () {
                typeof $(this).attr("original") != "undefined" && $(this).offset().top < $(document).scrollTop() + $(window).height() && $(this).attr("src", $(this).attr("original")).removeAttr("original")
            })
        }
        var d = $(".dynload");
        $(window).scroll(function () {
            b();

            jQuery('img[w]').each(function () {
                try {

                    var w = parseInt(jQuery(this).attr("w"));
                    var width = jQuery(this).width();
                    if (width > w) {
                        jQuery(this).css("width", w);
                    }
                }
                catch (e) { }
            });
        });
        b();
    });
</script>
<%} %>