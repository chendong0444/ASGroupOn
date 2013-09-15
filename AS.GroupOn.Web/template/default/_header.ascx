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
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections" %>
<script runat="server">
    public IList<IGuid> guidlist = null;
    protected String url = String.Empty;
    protected string menuhtml = String.Empty;
    protected GuidFilter filter = new GuidFilter();
    protected string cityname = String.Empty;
    protected string curcityid = String.Empty;
    protected string cityshtml = String.Empty;
    public IList<ICategory> catelist = null;
    public IList<ICategory> catelists = null;
    public IList<ICategory> otherlist = null;
    protected int changecity = 0;
    protected ISystem ASSystem = null;
    IList<IPacket> packetlist01 = null;
    public override void UpdateView()
    {
        ShowMessage();
        if (CurrentCity != null)
        {
            cityname = CurrentCity.Name;
            curcityid = CurrentCity.Id.ToString();
        }
        else
        {
            cityname = "全部城市";
            curcityid = "0";
        }
        url = Request.RawUrl.ToString();
        filter.teamormall = 0;
        filter.AddSortOrder(GuidFilter.guidsort_desc);
        using (IDataSession session = Store.OpenSession(false))
        {
            guidlist = session.Guid.GetList(filter);
        }
        foreach (IGuid model in guidlist)
        {
            if (model.guidopen == 0)
            {
                string target = "";
                if (model.guidparent == 1)
                    target = "target=_blank";
                if (url == model.guidlink)
                    menuhtml = menuhtml + "<li class=\"dangqian\"><a href=\"" + model.guidlink + "\" " + target + ">" + model.guidtitle + "</a>" + GetMenuIcon(model) + "</li>";
                else
                    menuhtml = menuhtml + "<li><a href=\"" + model.guidlink + "\"  " + target + ">" + model.guidtitle + "</a>" + GetMenuIcon(model) + "</li>";
            }
        }
        CategoryFilter catefilter = new CategoryFilter();
        CategoryFilter cf = new CategoryFilter();
        catefilter.Zone = "citygroup";
        catefilter.Display = "Y";
        catefilter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
        CategoryFilter othercf = new CategoryFilter();
        othercf.Display = "Y";
        othercf.Czone = "0";
        othercf.Zone = "city";
        othercf.AddSortOrder(CategoryFilter.Sort_Order_DESC);
        using (IDataSession session = Store.OpenSession(false))
        {
            catelist = session.Category.GetList(catefilter);
            otherlist = session.Category.GetList(othercf);
        }
        if (catelist != null)
        {
            changecity = 1;
            for (int i = 0; i < catelist.Count; i++)
            {
                ICategory cate = catelist[i];
                cityshtml = cityshtml + "<dl>";
                cityshtml = cityshtml + "<dt><em>" + cate.Name + "</em></dt>";
                cityshtml = cityshtml + "<dd>";
                if (cate.Czone.ToString() != "0")
                {
                    cf.Zone = "";
                    cf.Display = "Y";
                    cf.Zone = WebUtils.GetCatalogName(CatalogType.city).ToString();
                    cf.Czone = cate.Id.ToString();
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        catelists = session.Category.GetList(cf);
                    }
                }
                if (catelists != null)
                {
                    for (int j = 0; j < catelists.Count; j++)
                    {
                        ICategory c = catelists[j];
                        if (c.Display.ToUpper() == "Y")
                        {
                            cityshtml = cityshtml + "<a title=\"" + c.Name + "团购\" href=\"" + PageValue.WebRoot + "city.aspx?ename=" + c.Ename + "\" >" + c.Name + "</a>";
                        }
                    }
                }
                cityshtml = cityshtml + "</dd>";
                cityshtml = cityshtml + "</dl>";
            }
        }

        cityshtml = cityshtml + "<dl>";
        cityshtml = cityshtml + "<dt><em>默认城市</em></dt>";
        cityshtml = cityshtml + "<dd>";
        if (otherlist != null)
        {
            for (int k = 0; k < otherlist.Count; k++)
            {
                ICategory c = otherlist[k];
                if (c.Display.ToUpper() == "Y")
                {
                    cityshtml = cityshtml + "<a title=\"" + c.Name + "团购\" href=\"" + PageValue.WebRoot + "city.aspx?ename=" + c.Ename + "\" >" + c.Name + "</a>";
                }
            }
        }
        cityshtml = cityshtml + "<a title=\"全部城市团购\" href=\"" + WebRoot + "city.aspx?ename=quanguo\" >全部城市</a></dd></dl>";
        cityshtml = cityshtml + "</dl>";

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ASSystem = session.System.GetByID(1);
        }
        if (AsUser != null)
        {

            PacketFilter packetfil = new PacketFilter();
            packetfil.User_id = AsUser.Id;
            packetfil.State = "0";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                packetlist01 = session.Packet.GetList(packetfil);
            }

        }
    }

    private string GetMenuIcon(IGuid model)
    {
        if (model.id == 21)//"通信"
        {
            return "<span class=\"i-hot\"></span>";
        }
        if (model.id == 25) //购物
        {
            return "<span class=\"i-new\"></span>";
        }
        return string.Empty;
    }
</script>
<div id="hdw">
    <div id="hd">
        <div id="logo">
            <a href="<%=PageValue.WebRoot%>index.aspx" class="link">
                <img height="58" src="<%=PageValue.CurrentSystem.headlogo %>"></a>
        </div>
        <div class="guides">
            <div class="city">
                <h2>
                    <%=cityname%></h2>
            </div>
            <%if (PageValue.CurrentSystemConfig["changecity"] == "0")
              { %><div class="change">
                  <a href="<%=GetUrl("城市列表", "city.aspx")%>">切换城市</a>
              </div>
            <%}
              else
              { %>
            <%if (changecity == 1)
              { %><div id="guides-city-change" class="change">
                  切换城市
              </div>
            <%} %>
            <div id="guides-city-list" class="city-list-1">
                <div class="cityhd">
                    <span class="coll">按市切换&nbsp;[<a href="<%=GetUrl("城市列表", "city.aspx")%>" target="_blank">其他城市</a>]</span>
                    <span class="colr" id="colsediv">关闭</span>
                </div>
                <div class="city-scroll">
                    <div class="major">
                        <%=cityshtml%>
                        <p class="clear">
                        </p>
                    </div>
                    <div class="all">
                        <em id="selectcity"><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "a")
                                                          {%>class="active" <%}
                                                          else
                                                          { %>class="" <% }%>>A</a><a <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "b")
                                             {%> class="active" <%}
                                             else
                                             { %>class="" <% }%> href="#">B</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "c")
                                                                   {%> class="active" <%}
                                                                   else
                                                                   { %>class="" <% }%>>C</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "d")
                                                              {%> class="active" <%}
                                                              else
                                                              { %>class="" <% }%>>D</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "e")
                                                                  {%> class="active" <%}
                                                                  else
                                                                  { %>class="" <% }%>>E</a> <a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "f")
                                                                       {%> class="active" <%}
                                                                       else
                                                                       { %>class="" <% }%>>F</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "g")
                                                                          {%> class="active" <%}
                                                                          else
                                                                          { %>class="" <% }%>>G</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "h")
                                                                              {%> class="active" <%}
                                                                              else
                                                                              { %>class="" <% }%>>H</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "j")
                                                                                  {%> class="active" <%}
                                                                                  else
                                                                                  { %>class="" <% }%>>J</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "k")
                                                                                      {%> class="active" <%}
                                                                                      else
                                                                                      { %>class="" <% }%>>K</a>
                            <a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "l")
                                          {%> class="active" <%}
                                          else
                                          { %>class="" <% }%>>L</a><a <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "m")
                                                 {%> class="active" <%}
                                                 else
                                                 { %>class="" <% }%> href="#">M</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "n")
                                                                       {%> class="active" <%}
                                                                       else
                                                                       { %>class="" <% }%>>N</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "p")
                                                                  {%> class="active" <%}
                                                                  else
                                                                  { %>class="" <% }%>>P</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "q")
                                                                      {%> class="active" <%}
                                                                      else
                                                                      { %>class="" <% }%>>Q</a> <a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "r")
                                                                           {%> class="active" <%}
                                                                           else
                                                                           { %>class="" <% }%>>R</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "s")
                                                                              {%> class="active" <%}
                                                                              else
                                                                              { %>class="" <% }%>>S</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "t")
                                                                                  {%> class="active" <%}
                                                                                  else
                                                                                  { %>class="" <% }%>>T</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "w")
                                                                                      {%> class="active" <%}
                                                                                      else
                                                                                      { %>class="" <% }%>>W</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "x")
                                                                                          {%> class="active" <%}
                                                                                          else
                                                                                          { %>class="" <% }%>>X</a>
                            <a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "y")
                                          {%> class="active" <%}
                                          else
                                          { %>class="" <% }%>>Y</a><a href="#" <%if (CurrentCity != null && CurrentCity.Letter.ToLower().ToString() == "z")
                                                          {%> class="active" <%}
                                                          else
                                                          { %>class="" <% }%>>Z</a> </em>
                        <script type="text/javascript">
                            $(document).ready(function () {

                                jQuery("#selectcity").find("a").click(function () {
                                    jQuery("#selectcity").find("a").attr("class", "");
                                    jQuery(this).attr("class", "active");
                                    var str = jQuery(this).html();
                                    $.ajax({
                                        type: "POST",
                                        url: webroot + "ajax/ajax_getcity.aspx",
                                        data: { "letter": str },
                                        success: function (msg) {
                                            $("#cityfilter").html(msg);

                                        }
                                    });
                                });

                                jQuery("#guides-city-change").click(function () {
                                    var str = jQuery("#filter").val();
                                    if (str != "") {
                                        $.ajax({
                                            type: "POST",
                                            url: webroot + "ajax/ajax_getcity.aspx",
                                            data: { "letter": str },
                                            success: function (msg) {

                                                $("#cityfilter").html(msg);

                                            }
                                        });
                                    }
                                });
                                jQuery("#colsediv").click(function () {
                                    $('#guides-city-list').css('display', 'none');

                                });

                            })
                        </script>
                        <label id="cityfilter">
                        </label>
                        <%if (CurrentCity != null)
                          { %>
                        <input type="hidden" value="<%=CurrentCity.Letter.ToLower().ToString() %>" id="filter" />
                        <%}
                          else
                          { %>
                        <input type="hidden" value="" id="Hidden1" />
                        <%} %>
                    </div>
                </div>
            </div>
            <% } %>
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
                        window.location.href = '<%=getTeamDetailPageUrl(0,0,0,0)%>' + '?keyword=' + encodeURIComponent(keyword);
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

                            window.location.href = '<%=getTeamDetailPageUrl(0,0,0,0)%>' + '?keyword=' + encodeURIComponent(keyword);
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
            });
        </script>
        <div class="ss">
            <input type="text" value="请输入产品关键词..." xtip="请输入产品关键词..." id="keyword" class="goinput"
                x-webkit-speech="" lang="zh-CN" autocomplete="off"><input type="button" class="goimg"
                    value="" id="submit" name="submit">
        </div>
        <% 
            NameValueCollection _system = new NameValueCollection();
            _system = WebUtils.GetSystem();

            if (_system["closeshopcar"] != null && _system["closeshopcar"].ToString() == "0")
            {
                System.Collections.Generic.List<Car> carlist = new System.Collections.Generic.List<Car>();
                carlist = AS.Common.Utils.CookieUtils.GetCarData();
        %>
        <div class="cart">
            <a href="<%=GetUrl("购物车列表", "shopcart_show.aspx")%>">购物车<span>
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
        <%} %>
        <div id="menu2" class="menu">
            <ul>
                <%=menuhtml %>
            </ul>
        </div>
        <!--邮件订阅-开始-->
        <div id="header-subscribe-body" class="subscribe">
            <script language="javascript" type="text/javascript">
                function checkEmail() {
                    var str = document.getElementById("header-subscribe-email").value;
                    if (!str.match(/^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/)) {
                        document.getElementById("header-subscribe-email").value = "输入Email，订阅每日团购信息...";
                        return false;
                    }
                    else {
                        window.location.href = '<%=GetUrl("邮件订阅", "help_Email_Subscribe.aspx")%>' + '?email=' + str;
                    }
                }
            </script>
            <input id="header-subscribe-email" type="text" xtip="输入Email，订阅每日团购信息..." value=""
                class="f-text" name="head_email" />
            <input type="hidden" value="834" name="cityid" />
            <input id="Button2" type="button" class="commit validator" value="订阅" onclick="checkEmail()" />
            <%
                if (ASSystem.smssubscribe > 0)
                {%>
            <span><a class="sms" onclick="X.miscajax('sms','subscribe');">&raquo; 短信订阅，免费！</a>&nbsp;
                <a class="sms" onclick="X.miscajax('sms','unsubscribe');">&raquo; 取消手机订阅</a></span>
            <% } %>
        </div>
        <!--邮件订阅-结束-->
        <div class="logins">
            <ul class="links">
                <%if (_system["verifycoupon"] != null && _system["verifycoupon"].ToString() == "1")
                  {%>
                <li><a id="verify-coupon-id" href="javascript:;">
                    <%=ASSystem.couponname%>验证</a><em>|</em></li>
                <%} %>
                <%if (ASSystem.trsimple > 0)
                  { %>
                <li><a href="<%=PageValue.WebRoot %>ajax/system.aspx?action=locale">简繁转换</a><em>|</em></li>
                <%}%>
                <%if (IsLogin && AsUser.Id != 0)
                  {%>
                <%if (AsUser.Realname != null && AsUser.Realname != "")
                  {%>
                <li class="username">
                    <%=AsUser.Realname %>！欢迎您<em>|</em></li>
                <li class="account"><a href="<%=GetUrl("我的订单", "order_index.aspx")%>">我的订单</a><em>|</em></li>
                <%if (packetlist01 != null)
                  {
                      if (packetlist01.Count > 0)
                      {
                %>
                <li class="account"><a href="<%=GetUrl("我的红包", "order_packet.aspx")%>">我的红包<b style="color: Red;">(<%=packetlist01.Count%>)</b></a><em>|</em></li>
                <%   }
                  } %>
                <li class="logout"><a href="<%=WebRoot%>loginout.aspx">退出</a></li>
                <%}
                  else
                  {%>
                <li class="username">
                    <%=AsUser.Username %>！欢迎您</li>
                <li class="account"><a href="<%=GetUrl("我的订单", "order_index.aspx")%>" id="myaccount">
                    我的订单</a><em>|</em></li>
                <%if (packetlist01 != null)
                  {
                      if (packetlist01.Count > 0)
                      {
                %>
                <li class="account"><a href="<%=GetUrl("我的红包", "order_packet.aspx")%>">我的红包<b style="color: Red;">(<%=packetlist01.Count %>)</b></a><em>|</em></li>
                <%   }
                  } %>
                <li class="logout"><a href="<%=WebRoot%>loginout.aspx">退出</a></li>
                <%}%>
                <%}
                  else
                  {%>
                <li class="login"><a href="<%=GetUrl("用户登录", "account_login.aspx")%>">登录</a><em>|</em></li>
                <li class="signup"><a href="<%=GetUrl("用户注册", "account_loginandreg.aspx")%>">注册</a></li>
                <%}%>
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
            <%=suctext %>
        </p>
        <span class="close">关闭</span>
    </div>
</div>
<%} %>
<%if (errtext != String.Empty)
  { %>
<div class="sysmsgw" id="sysmsg-error">
    <div class="sysmsg">
        <p>
            <%=errtext %>
        </p>
        <span class="close">关闭</span>
    </div>
</div>
<%}%>
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
