<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
    protected NameValueCollection _system = new NameValueCollection();
    protected int teamid = 0;
    protected string Currency;
    protected IList<ITeam> dt_pinglun = null;
    protected ITeam shopteam = null;
    protected ITeam ds = null;
    protected IList<ITeam> ds1 = null;
    protected IList<ITeam> dto = null;
    protected string myvalue = "";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        teamid = Helper.GetInt(Request["id"], 0);
        if (!IsPostBack)
        {
            setBuyTitle();
            if (teamid > 0)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    shopteam = session.Teams.GetByID(teamid);
                }
                //详情 加入购物车
                TeamFilter tfilter = new TeamFilter();
                tfilter.Id = teamid;
                tfilter.teamcata = 1;
                tfilter.mallstatus = 1;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ds = session.Teams.Get(tfilter);
                }
                //喜欢此产品的用户还喜欢
                TeamFilter tfilter2 = new TeamFilter();
                tfilter2.oper_teamid = teamid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ds1 = session.Teams.GetTeamOper(tfilter2);
                }
                //我浏览过的
                myvalue = CookieUtils.GetCookieValue("Cookie_historys");
                //浏览历史cookie
                CookieUtils.AddCookie(teamid.ToString());



                //同类热销排行
                int teamdetailnum = 0;
                if (_system["teamdetailnum"] != null && _system["teamdetailnum"].ToString() != "")
                {
                    teamdetailnum = Helper.GetInt(_system["teamdetailnum"], 0);
                }
                TeamFilter tfilter3 = new TeamFilter();
                tfilter3.Top = teamdetailnum;
                tfilter3.dto_teamid = teamid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    dto = session.Teams.GetTeamDto(tfilter3);
                }
            }
        }
    }

    /// <summary>
    /// 买家评论内容
    /// </summary>
    public void setBuyTitle()
    {
        TeamFilter teamfilter = new TeamFilter();
        teamfilter.pl_teamid = teamid.ToString();
        if (_system["navUserreview"] != null && _system["navUserreview"].ToString() == "1")
        {
            if (_system["UserreviewYN"] != null && _system["UserreviewYN"].ToString() == "1")
            {
                teamfilter.pl_state = 1;
            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                dt_pinglun = session.Teams.GetPingLun(teamfilter);
            }
        }

    }

    public void getCurrency()
    {
        if (ASSystem != null && ASSystem.currency != "")
        {
            Currency = ASSystem.currency;
        }
        else
        {
            Currency = "￥";
        }
    }

    /// <summary>
    /// 返回指定时间之差
    /// </summary>
    /// <param name="DateTime1">当前时间</param>
    /// <param name="DateTime2">之前时间</param>
    /// <returns></returns>
    public string returnTime(DateTime DateTime1, DateTime DateTime2)
    {
        string dateDiff = null;

        TimeSpan ts1 = new TimeSpan(DateTime1.Ticks);
        TimeSpan ts2 = new TimeSpan(DateTime2.Ticks);
        TimeSpan ts = ts1.Subtract(ts2).Duration();
        if (ts.Days > 0)
        {
            dateDiff += ts.Days.ToString() + "天";
        }
        if (ts.Hours > 0)
        {
            dateDiff += ts.Hours.ToString() + "小时";
        }
        if (ts.Minutes > 0)
        {
            dateDiff += ts.Minutes.ToString() + "分钟";
        }
        return dateDiff;

    }
     
</script>
<%LoadUserControl("_htmlheader_mall.ascx", null); %>
<%LoadUserControl("_header_mall.ascx", null); %>
<script src="/upfile/js/index.js" type="text/javascript"></script>
<script type="text/javascript">
    $(document).ready(function () {
        $('.nav-xq').mousemove(function () {
            $(this).find('.nav_filter').show();
            $(this).find('.border').addClass('hover');
        });
        $('.nav-xq').mouseleave(function () {
            $(this).find('.nav_filter').hide();
            $(this).find('.border').removeClass('hover');
        });
    });
</script>
<div class="bdw" id="bdw">
    <!--商城头部分类开始-->
    <%LoadUserControl("_malltopcata.ascx", null); %>
    <!--商城头部分类结束-->
    <%if (ds != null)
      { %>
    <div id="container">
        <div id="body">
            <div style="border-bottom: 1px solid #000; line-height: 18px; height: 24px; font-size: 12px;"
                class="lbrd_tab">
                您现在的位置:&nbsp;&nbsp;<a href="<%=BaseUserControl.getMallPageUrl(Helper.GetString(_system["isrewrite"], "0")) %>"><%=_system["mallsitename"]%></a>
                <% 
                    if (ds.TeamCatalogs != null)
                    {
                        if (ds.TeamCatalogs.catalogname != "")
                        {
                %>
                <em>›</em><a href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), Helper.GetInt(ds.cataid, 0), Helper.GetInt(ds.brand_id, 0), 0,"0","0") %>"><%=ds.TeamCatalogs.catalogname%></a>
                <%}
                    } %>
                <em>›</em><span class="lbrd_ltab"><%=Helper.GetSubString(ds.Title,80)%></span>
            </div>
            <%--  项目详情展示--%>
            <div class="lbrd_main">
                <div class="lbrd_mleft">
                    <img width="440" height="280" src="<%=ds.Image %>" alt="<%=ds.Title %>" />
                </div>
                <div class="lbrd_mright">
                    <div class="lbrd_tit">
                        <span style="font-size: 18px;">
                            <%=ds.Title%></span> <span id="lovenum"></span>
                    </div>
                    <div style="line-height: 30px;" class="lbrd_prcly">
                        <em class="lbrd_prcmq" id="show_price">
                            <%=ASSystemArr["Currency"]%><%=GetMoney(ds.Team_price)%></em></div>
                    <div style="color: #999;" class="lbrd_prcly">
                        市场价:&nbsp;&nbsp;<em style="color: #999; font-family: Arial,Helvetica,sans-serif;
                            text-decoration: line-through;"><%=ASSystemArr["Currency"]%><%=GetMoney(ds.Market_price)%></em>&nbsp;&nbsp;节省:&nbsp;&nbsp;<em
                                style="color: #999; font-family: Arial,Helvetica,sans-serif;"><%=ASSystemArr["Currency"]%><%=GetMoney(Helper.GetDecimal(ds.Market_price, 0) - Helper.GetDecimal(ds.Team_price, 0))%></em></div>
                    <div class="lbrd_prcly">
                        已售出<em><%=ds.Now_number%></em>件</div>
                    <div class="lbrd_buyly" style="height: auto; padding: 0; margin: 0;">
                        <%if (ds != null && ds.bulletin.ToString().Replace("{", "").Replace("}", "") != "")
                          {%>
                        <div class="lbrd_buygug" selectid="98" id="sl_format" style="margin-bottom: 15px;">
                            <%=Utilys.Getfont1(int.Parse(ds.Id.ToString()), ds.bulletin.ToString())%>
                            <div class="clear">
                            </div>
                        </div>
                        <div>
                            数量：<div style="margin: -20px 40px 7px;" id="teamtd_" class="bnum_iptly">
                                <span id="decreasenum"></span>
                                <input name="quantity__" class="bnum_ipt" style="ime-mode: disabled; margin: -3px 0px;
                                    *margin: 2px -25px;" onkeyup="checksum();" value="1" id="quantity-id" />
                                <span id="increasenum"></span>
                            </div>
                        </div>
                        <%}%>
                        <input type="hidden" value="0" id="pernum" />
                        <%if ((ds.open_invent.ToString() == "1" && Helper.GetInt(ds.inventory.ToString(), 0) > 0) || ds.open_invent.ToString() == "0")
                          { %>
                        <%if (ds.invent_result != null && ds.invent_result.Contains("价格"))//有规格多种价格
                          {%>
                        <div id="choose-btn-append" class="btn">
                            <a href="javascript:void(0)" class="lbrd_buyac" id="buynow"></a>
                        </div>
                        <%}
                          else if (ds.bulletin != null && ds.bulletin.ToString() != "" && ds.bulletin.ToString().Replace("{", "").Replace("}", "") != "")
                          { %>
                        <a href="javascript:void(0)" class='lbrd_gwaddbtn' id="shopcar"></a>
                        <%}
                          else
                          {%>
                        <div id="choose-btn-append" class="btn">
                            <a href="javascript:void(0)" class='lbrd_gwaddbtn' id="addshopcar"><b></b></a>
                        </div>
                        <%}%>
                        <%}%>
                        <input type="hidden" value="<%=teamid%>" id="hidteamid" />
                        <span style="padding: 0;" id="carttip"></span>
                    </div>
                    <script type="text/javascript">
           
                                       function  checksum()
                                       {
                                            var qsum=jQuery('#quantity-id').val();
                                            if(<%=ds.open_invent.ToString() %>=="1"&&qsum><%=ds.inventory.ToString()%> )
                                            { jQuery('#quantity-id').val(<%=ds.inventory.ToString()%>)
                                               jQuery('#carttip').text('当前库存'+<%=ds.inventory.ToString()%>+'个');this.value=<%=ds.inventory.ToString()%>;
                                            }
                                            else
                                            {
                                                jQuery('#carttip').text('');
                                            }
                                            var regNum = /^\d*$/;
                                            if (!regNum.test(qsum)) {
                                              if((<%=ds.open_invent.ToString()%>=="1"&&<%=ds.inventory.ToString()%>>0)||<%=ds.open_invent.ToString()%>=="0")
                                               jQuery('#quantity-id').val('1');
                                              else
                                                jQuery('#quantity-id').val('0');
                                               alert("请输入数字");
                                            }
                                    }

                                     var rule = "";
                                        var rule = "<%=GetMoney(ds.Team_price)%>";
                                        //attrnameid:规格id attrnanevalue:规格名称   attrvalueid：规格值id attrvalue:规格值
                                        function setattrvalue1(attrnameid, attrnanevalue, attrvalueid, attrvalue) {
                                            for(var i=0;i<attrnameid+1;i++)
                                            {
                                                 $("#greyspan0_"+attrnameid).attr("class", "");
                                            }
                                            $("#s_attr_name" + attrnameid).html(attrvalue);
                                            $("#attr_value_" + attrnameid).val(attrnanevalue);
                                            var redspan = $("#redspan" + attrnameid).val();
                                            if (redspan != null && redspan != "" && redspan != attrvalue) {
                                                $("[name='greyspan" + attrnameid + "']").attr("class", "td28");
                                            }
            
                                            $("#greyspan" + attrvalueid + "_" + attrnameid).attr("class", "lbrd_bycur");
                                            $("#redspan" + attrnameid).val(attrvalue);

                                            if (attrnanevalue != null) {

                                                var attrname = $("#hidattrname").val();
                                              //  alert(attrname);
                                                //处理规格字符串
                                                if (attrname.indexOf(attrnanevalue) >= 0) {

                                                    //找到规格，替换此规格值
                                                    var newattrnames = "";
                                                    var attrnames = attrname.split(",");
                                                    for (i = 0; i < attrnames.length; i++) {
                                                        if (attrnames[i] != "") {
                                                            if (attrnames[i].indexOf(attrnanevalue) >= 0) {

                                                                newattrnames = newattrnames + "," + attrnanevalue + ":[" + attrvalue + "]";
                                                            }
                                                            else {
                                                                newattrnames = newattrnames + "," + attrnames[i];
                                                            }
                                                        }
                                                    }
                                                    $("#hidattrname").val(newattrnames.substring(1));
                                                }
                                                else {
                                                    //不存在此规格，将规格添加到字符串中
                                                    var hidattrname = attrname + "," + attrnanevalue + ":[" + attrvalue + "]";
                                                    $("#hidattrname").val(hidattrname);

                                                }                    
                                            }
                                            //判断用户是否选择全了规格
                                            var attrvales = $("#hidattrvale").val();  
                                            var result = $("#hidattrname").val();
                                            var c_reslut=result.split(',');
                                            var falg="0";
                                            var c_str="";
                                            for(var i=0;i<c_reslut.length;i++)
                                            {
                                                c_str+=c_reslut[i].split(':')[0]+",";
                                            }
             
                                            if (c_str.indexOf(attrvales)>-1)
                                            {
                                                falg="1";
                                            }
                                            if(falg=="1")//选择全了规格
                                            {  
                                                if (result.substring(0, 1) == ",") {
                                                     result = result.substring(1);
                                                }
                                                if ('<%=shopteam.invent_result%>' != "" & result!= "")
                                                {
                                                    var oldrulemo=new Array();
                                                    oldrulemo = '<%=shopteam.invent_result%>'.replace("{", "").replace("}", "").split('|');
                                                    for (var i = 0; i < oldrulemo.length; i++)
                                                    {
                                                        if(oldrulemo[i].indexOf(result)>=0)
                                                        {
                                                            rule = oldrulemo[i];
                                                        }
                                                    }
                                                    if(rule.indexOf("价格")>=0)
                                                    {
                                                        rule=rule.substring(0,rule.lastIndexOf(','));
                       
                                                        rule=rule.substring(rule.lastIndexOf(',')).replace(",", "").replace("价格", "").replace(":", "").replace("[", "").replace("]", "");
                                                    }
                                                    else
                                                    {
                                                        rule='<%=shopteam.Team_price %>';
                                                    }
                                                }
                                                if(rule!="")
                                                {
                                                  var reg = /^(\d+)$|^(\d+.[1-9])0$|^(\d+).00$/;
                                                  reg.exec(rule);
                                                  rule = rule.replace(rule, RegExp.$1+RegExp.$2+RegExp.$3); 
                                                  $("#show_price").html("<%=ASSystemArr["Currency"]%>"+rule);
                                                }
                                            } 
                                        }

                                        $(document).ready(function () {
                            $("#buynow").click(function () { 
                                var result = $("#hidattrname").val();
                                var num = $("#quantity-id").val();
                                if (parseInt(num) < 1) {
                                    alert("数量不能小于1");
                                    $("#quantity-id").val("1");
                                    return;
                                }
                                if (result == "") {
                                    alert("请您选择规格");
                                    return;
                                }
                                if (result.substring(0, 1) == ",") {
                                    result = result.substring(1);
                                }
                                //判断用户选择的规格是否正确
                                var attrvales = $("#hidattrvale").val();
                                if (attrvales != "") {
                                    var _attrvales = attrvales.split(",");
                                    for (i = 0; i < _attrvales.length; i++) {
                                        if (_attrvales[i] != "") {
                                            if (result.indexOf(_attrvales[i]) < 0) {
                                                alert("请选择" + _attrvales[i]);
                                                return;
                                            }
                                        }
                                    }
                                }
                                var teamid = $("#hidteamid").val();
                                //{颜色:[1],大小:[4],数量:[1]}
                                var _result = "{" + result + ",数量:[" + num + "]}";
                                X.get(webroot + 'ajax/car.aspx?action=notprice&addteamid=' + teamid + "&num=" + num + "&result=" + encodeURIComponent(_result) + "&m_rule=" + rule + "");
                            });
                            $("#shopcar").click(function () {
                                    var result = $("#hidattrname").val();
                                var num = $("#quantity-id").val();
                                if (parseInt(num) < 1) {
                                    alert("数量不能小于1");
                                    $("#quantity-id").val("1");
                                    return;
                                }
                                if (result == "") {
                                    alert("请您选择规格");
                                    return;
                                }
                                if (result.substring(0, 1) == ",") {
                                    result = result.substring(1);
                                }
                                //判断用户选择的规格是否正确
                                var attrvales = $("#hidattrvale").val();
                                if (attrvales != "") {
                                    var _attrvales = attrvales.split(",");
                                    for (i = 0; i < _attrvales.length; i++) {
                                        if (_attrvales[i] != "") {
                                            if (result.indexOf(_attrvales[i]) < 0) {
                                                alert("请选择" + _attrvales[i]);
                                                return;
                                            }
                                        }
                                    }
                                }
                                var teamid = $("#hidteamid").val();
                                //{颜色:[1],大小:[4],数量:[1]}
                                var _result = "{" + result + ",数量:[" + num + "]}";
                                X.get(webroot + 'ajax/car.aspx?action=carinfo&addteamid=' + teamid + "&num=" + num + "&result=" + encodeURIComponent(_result) + "&a=" + Math.random());
                            });
                            $("#addshopcar").click(function () {
                               var teamid = $("#hidteamid").val();
                                $.ajax({
                                    type: "POST",
                                    url: webroot + "ajax/car.aspx?id=" + teamid + "&type=mall",
                                    success: function (msg) {
                                         location.href='<%=GetUrl("购物车列表","shopcart_show.aspx")%>';
                                    }
                                });
                            });
                        });
                                    $('#dialog').css({ position: 'absolute', top: 200, left: 1009, display: 'block' });

                    </script>
                    <div class="lbrd_share" style="margin: 0;">
                        <div id="ckepop">
                            <%if (Helper.GetInt(ds.Bonus.ToString(), 0) > 0)
                              {%>
                            <span class="jiathis_txt">推荐好友购买返<%=ds.Bonus.ToString()%>元&nbsp;&nbsp;</span>
                            <%} %>
                        </div>
                        <%LoadUserControl(WebRoot + "UserControls/blockshare.ascx", shopteam); %>
                    </div>
                </div>
            </div>
            <%--  项目详情展示--%>
            <%--喜欢此产品的用户还喜欢 --%>
            <%if (ds1 != null && ds1.Count > 0)
              {%>
            <script type="text/javascript" src="/upfile/js/jquery.js"></script>
            <script type="text/javascript">
                jQuery(document).ready(function () {
                    jQuery('#mycarousel').jcarousel();
                });
            </script>
            <div class="lbrd_likeother">
                <h2>
                    喜欢此产品的用户还喜欢</h2>
                <div class="lbrd_likepc">
                    <div id="wrap">
                        <div class=" jcarousel-skin-tango">
                            <div class="jcarousel-container jcarousel-container-horizontal">
                                <div class="jcarousel-prev jcarousel-prev-horizontal">
                                </div>
                                <div class="jcarousel-next jcarousel-next-horizontal">
                                </div>
                                <div class="jcarousel-clip jcarousel-clip-horizontal">
                                    <ul id="mycarousel" class="jcarousel-list jcarousel-list-horizontal">
                                        <%foreach (ITeam iteamInfo in ds1)
                                          {
                                        %>
                                        <li><a class="lbrd_lpc" href="<%=BasePage.getTeamPageUrl(iteamInfo.Id)%>" title="<%=iteamInfo.Title%>"
                                            target="_blank">
                                            <img class="dynload" width="176" height="112" <%=ashelper.getimgsrc(ImageHelper.good_getSmallImgUrl(iteamInfo.Image,176,112))%>
                                                alt="<%=iteamInfo.Title%>">
                                        </a></li>
                                        <%} %>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <%
                } %>
            <%--喜欢此产品的用户还喜欢 --%>
        </div>
        <%--<script src="../upfile/js/Mall.js" type="text/javascript"></script>--%>
        <style type="text/css">
            *
            {
                margin: 0;
                padding: 0;
            }
            #fixed
            {
                position: fixed;
                top: 0px;
                background: #fff;
                color: #000;
            }
        </style>
        <style type="text/css">
            *
            {
                margin: 0;
                padding: 0;
            }
            #fixed
            {
                position: fixed;
                top: 0px;
                background: #fff;
                color: #000;
            }
        </style>
        <!--[if lt IE 7]>
                         <script type=text/javascript>
                            jQuery(document).ready(function (){
    		                        $(window).scroll(function (){
	    		                        var offsetTop = 0 +"px";
	    		                        var y=jQuery('#deal_desc').offset().top;
	    		                        if($(window).scrollTop()>y){
	    			                        offsetTop = $(window).scrollTop() - y +"px";
	    		                        }
	    		                        $("#Float").css({top : offsetTop });
	    	                        }); 
	                           }); 	
                         </script>
                         <![endif]-->
        <div class="lbrd_more">
            <%--详情和评论 --%>
            <div id="deal_desc" class="deal_contents">
                <div id='fixed' class='fixed' style="display: none;">
                    <ul class="ndy_floatnav" style="position: absolute; top: 0;" id='Float'>
                        <li><a href="#shangpjs" id="detail-id">本单详情</a></li>
                        <li><a href="#coms" id="comments-id">买家评论</a></li>
                        <li style="width: 118px; border-right: 1px solid #ccc;">
                            <%if ((ds.open_invent.ToString() == "1" && Helper.GetInt(ds.inventory.ToString(), 0) > 0) || ds.open_invent.ToString() == "0")
                              { %>
                            <a href="<%=PageValue.WebRoot%>ajax/car.aspx?id=<%=ds.Id.ToString()%>&type=mall&go=show">
                                <img src="<%=ImagePath() %>nindy_buy.gif" style="margin: 2px;" /></a>
                            <%}
                              else
                              { %>
                            <img src="<%=ImagePath() %>nindy_buy.gif" style="margin: 2px;" />
                            <%} %>
                        </li>
                    </ul>
                </div>
                <div class="main2" id="no_try_record">
                    <%--本单详情开始 --%>
                    <dl>
                        <dt id="shangpjs">
                            <img style="display: block" src="<%=ImagePath() %>highlight.png" /></dt>
                        <dd>
                            <%=ds.Detail %>
                        </dd>
                    </dl>
                    <%--本单详情开始 --%>
                </div>
                <%--买家评论开始 --%>
                <div class="main2" id="comments-container" style="display: none; font-size: 12px;">
                    <dl style="f12">
                        <dd class="nidy_table">
                            <div class="pinkdiv">
                                其他用户评论:
                            </div>
                            <ul class="team_comments comments">
                                <% if (dt_pinglun != null && dt_pinglun.Count > 0)
                                   {
                                %>
                                <% 
                                    int i = 0;
                                    foreach (ITeam itInfo in dt_pinglun)
                                    {
                                        if (i <= 9)
                                        {
                                %>
                                <li>
                                    <div class="comment_content">
                                        <div class="desc">
                                            <b>
                                                <%=itInfo.Username%></b>:&nbsp;&nbsp;&nbsp;&nbsp;<%=itInfo.comment%>
                                        </div>
                                        <div class="pltitle">
                                            评论了在<%=ASSystem.abbreviation%>买到的&nbsp; <a href="<%=getTeamPageUrl(itInfo.Id)%>"
                                                title="<%=itInfo.Title%>">
                                                <%=Helper.GetSubString(itInfo.Title,56)%></a>
                                        </div>
                                        <div class="time">
                                            <% DateTime dt = System.DateTime.Now;
                                               DateTime dts = Convert.ToDateTime(itInfo.create_time.ToString());
                                               if (dts != null)
                                               {%>
                                            <%= returnTime(dt, dts)%>
                                            <%}
                                               else
                                               {%>
                                            &nbsp;
                                            <% }%>
                                        </div>
                                        <div class="clear">
                                        </div>
                                    </div>
                                </li>
                                <%
                                    i++;
                                        }
                                        else
                                        {
                                            break;
                                        }

                                    }
                                   }
                                   else
                                   {
                                %>
                                <div style="text-align: center;">
                                    暂无评论！</div>
                                <%} %>
                            </ul>
                            <div class="clear">
                            </div>
                            <% if (dt_pinglun != null && dt_pinglun.Count > 0)
                               {%>
                            <a href="<%=GetUrl("到货评价","buy_list_comments.aspx?catateam=1&idteam="+teamid)%>"
                                class="pink">查看更多评论</a>
                            <%} %>
                        </dd>
                    </dl>
                </div>
                <%--买家评论结束 --%>
            </div>
            <%--详情和评论 --%>
            <div class="lbrd_sider">
                <%--同类热销排行 --%>
                <%if (dto != null && dto.Count > 0)
                  {
                %>
                <div class="lbrd_sidebox" style="border-bottom: none;">
                    <h2>
                        同类热销排行</h2>
                    <ul class="lbrd_slist">
                        <%
                            int i = 0;
                            foreach (ITeam tInfo in dto)
                            {
                        %>
                        <li><span class="lbrd_slnum">
                            <%=(i+1)%></span><a class="lbrd_slname hpink" href="<%=BasePage.getTeamPageUrl(tInfo.Id)%>"
                                target="_blank"><%=Helper.GetSubString(tInfo.Title,28)%></a>
                            <%if (i == 0)
                              { %>
                            <div class="lbrd_slimg" id="frist">
                                <a href="<%=BasePage.getTeamPageUrl(tInfo.Id)%>" target="_blank">
                                    <img width="240" height="153" class="dynload" <%=ashelper.getimgsrc(ImageHelper.good_getSmallImgUrl(tInfo.Image,240,153))%>
                                        alt="<%=tInfo.Title%>"></a>
                                <h3>
                                    <%=Helper.GetSubString(tInfo.Title, 32)%>
                                </h3>
                                <span class="Price"><b>现价：<%=Currency%><%=GetMoney(tInfo.Team_price)%></b><span class="old_pr">原价：(<%=Currency%><%=GetMoney(tInfo.Market_price)%></span></span>
                            </div>
                            <%}
                              else
                              { %>
                            <div class="lbrd_slimg">
                                <a href="<%=BasePage.getTeamPageUrl(tInfo.Id)%>" target="_blank">
                                    <img width="240" height="153" class="dynload" <%=ashelper.getimgsrc(ImageHelper.good_getSmallImgUrl(tInfo.Image,240,153))%>
                                        alt="<%=tInfo.Title%>"></a>
                                <h3>
                                    <%=Helper.GetSubString(tInfo.Title, 32)%>
                                </h3>
                                <span class="Price"><b>现价：<%=Currency%><%=GetMoney(tInfo.Team_price)%></b><span class="old_pr">原价：<%=Currency%><%=GetMoney(tInfo.Market_price)%></span></span>
                            </div>
                            <%} %>
                        </li>
                        <% i++;
                            }
                        %>
                    </ul>
                </div>
                <%} %>
                <%--同类热销排行 --%>
                <%--最近浏览过的商品 --%>
                <%
                    string[] str = myvalue.Split(',');

                    if (myvalue != "" && str != null && str.Length > 0)
                    {
                %>
                <div class="lbrd_sidebox">
                    <h2>
                        最近浏览过的商品</h2>
                    <%

                        for (int i = 0; i < str.Length; i++)
                        {
                            if (i < 5)
                            {
                                TeamFilter tmfilter = new TeamFilter();
                                tmfilter.Id = Helper.GetInt(str[i], 0);
                                tmfilter.teamcata = 1;
                                ITeam ds_history = null;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    ds_history = session.Teams.Get(tmfilter);
                                }
                                //Maticsoft.BLL.Team bllteam = new Maticsoft.BLL.Team();
                                //ds_history = bllteam.GetList("id=" + Utils.Helper.GetInt(str[i], 0) + " and teamcata=1");
                                if (ds_history != null)
                                {
                    %>
                    <div class="lbrd_sdother">
                        <a class="lbrd_lpc" title="<%=ds_history.Title %>" href="<%=getTeamPageUrl(ds_history.Id)%>"
                            target="_blank">
                            <img title="<%=ds_history.Title %>" width="176" height="112" class="dynload" <%=ashelper.getimgsrc(ImageHelper.good_getSmallImgUrl(ds_history.Image,176,112))%> /></a>
                        <a class="lbrd_sdotit hpink" href="<%=BasePage.getTeamPageUrl(ds_history.Id)%>" target="_blank">
                            <%=Helper.GetSubString(ds_history.Title, 28)%></a> <span><em>
                                <%=ds_history.Team_price.ToString()%></em></span>
                    </div>
                    <%}
                            }
                        }

                    %>
                </div>
                <%} %>
                <%--最近浏览过的商品 --%>
            </div>
            <script type="text/javascript">

                                    jQuery(window).scroll(function () {
                                    jQuery('.fixed').css({display: 'block' });
                                        if (jQuery(window).scrollTop() >= jQuery('#deal_desc').offset().top) {
                                            jQuery('.fixed').attr('id', 'fixed');
                                        } else { jQuery('.fixed').attr('id', false); }
                                    });

                                    //初始化时让第一个显示，其他隐藏
                                    jQuery('.lbrd_slimg').each(function(){jQuery(this).hide();});
                                    jQuery('.lbrd_slist li').children('#frist').show();

                                    jQuery('.lbrd_slist li').hover(function(){
			                            jQuery('.lbrd_slimg').each(function(){jQuery(this).hide();});
			                            jQuery(this).children('.lbrd_slimg').show();
		                            },function(){

		                            });

                                    jQuery('#ndy_floatnav li a').click(function () {

                                        jQuery('#ndy_floatnav li').each(function () { jQuery(this).removeClass('lbrd_licurt'); });
                                        jQuery(this).parent('li').addClass('lbrd_licurt');
                                    });
                                    jQuery('#decreasenum').click(function () {
                                        var oldnum = parseInt(jQuery('#quantity-id').val());
                                        ////减
                                        if (oldnum <= 1) {
                                            return;
                                        }
                                        var newnum = oldnum - 1;
                                        jQuery('#quantity-id').val(newnum);
                                    });




                                     if((<%=ds.open_invent.ToString() %>=="1"&&<%=Helper.GetInt(ds.inventory.ToString(), 0) %> <= 0))
                                        {
                                        jQuery('#quantity-id').val("0");
                                        jQuery('#addshopcar').attr("class","lbrd_gwaddbtn2");
                                        }
                                        else
                                        {
                                          jQuery('#quantity-id').val("1");
                                        }



                                    jQuery('#increasenum').click(function () {
                                        var per_num = parseInt(jQuery('#pernum').val());
                                        var oldnum = parseInt(jQuery('#quantity-id').val());
                                        if (oldnum >= per_num && per_num) {
                                            return;
                                        }
                                        if(<%=ds.open_invent.ToString() %>=="1"&&<%=ds.inventory.ToString()%>=="0")
                                        {
                                            alert('库存不足！');
                                            return;
                                        }
                                        if (<%=ds.open_invent.ToString() %>=="1"&&oldnum >= <%=ds.inventory.ToString()%>) {
                                            alert('最大数量不超过'+ <%=ds.inventory.ToString()%>+'个');
                                            return;
                                        }
                                        var newnum = oldnum + 1;
                                        jQuery('#quantity-id').val(newnum);
                                    });
     
                                   jQuery('#vieww-tryrecord').click(function(){jQuery('#no_try_record').hide();jQuery('#comments-container').hide();jQuery('#try_record').show();});
		                            jQuery('#property-id').click(function(){if(jQuery('#no_try_record').css('display')=='none'){rcod();}});
		                            jQuery('#detail-id').click(function(){if(jQuery('#no_try_record').css('display')=='none'){rcod();}});
		                            jQuery('#shot-id').click(function(){if(jQuery('#no_try_record').css('display')=='none'){rcod();}});
		                            jQuery('#good-id').click(function(){if(jQuery('#no_try_record').css('display')=='none'){rcod();}});
		                            jQuery('#record-id').click(function(){if(jQuery('#try_record').css('display')=='none'){jQuery('#no_try_record').hide();jQuery('#comments-container').hide();jQuery('#try_record').show();}});
		                            jQuery('#comments-id').click(function(){jQuery('#try_record').hide();jQuery('#no_try_record').hide();jQuery('#comments-container').show();});
		                            function rcod (){
			                            jQuery('#try_record').hide();jQuery('#comments-container').hide();jQuery('#no_try_record').show();
		                            }
	
	
            </script>
        </div>
    </div>
    <%}
      else
      {%>
    <div style="text-align: center;">
        没有找到该商品，请看看别的商品吧！</div>
    <%} %>
</div>
<%LoadUserControl("_footer_mall.ascx", null); %>
<%LoadUserControl("_htmlfooter_mall.ascx", null); %>