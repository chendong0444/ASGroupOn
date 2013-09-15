<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
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
    public string check2 = "";
    private NameValueCollection _system = null;
    private NameValueCollection _system1 = null;
    public decimal DetailMoney;
    public string txtshuGood;
    protected bool closeshopcar = false;//关闭购物车
    public string bulletin = "";
    protected string loginscore = "0";
    protected string invitescore = "0";
    protected string regscore = "0";
    protected string chargescore = "0";
    protected string loginmoney = "0";
    protected string orderteamnum = "5";
    protected string irange = "";
    protected string str="";
    protected ISystem system = null;
    int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system1 = PageValue.CurrentSystemConfig;

        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_SetTg_XuanXiang))
        {
            SetError("你不具有查看选项的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        viewSystem();
    }
    private void viewSystem()
    {

        NameValueCollection _systemView = new NameValueCollection();
        _systemView = WebUtils.GetSystem();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
        }

        if (_systemView != null)
        {
            if (_systemView["maptype"] == "0")
            {
                maptype.Value = "0";
            }
            else
            {
                maptype.Value = "1";
            }
            //侧栏团购
            if (_systemView["displayTitle"] == "1")
            {

                displayTitle.Value = "1";
            }
            else
            {
                displayTitle.Value = "0";
            }

            //显示邀请排名
            if (_systemView["displayInvite_Top"] == "1")
            {
                displayInvite_Top.Value = "1";
            }
            else
            {
                displayInvite_Top.Value = "0";
            }

            //优惠券消费提醒
            if (_systemView["opencoupon"] == "1")
            {
                opencoupon.Value = "1";
            }
            else
            {
                opencoupon.Value = "0";
            }
            //开启新闻公告
            if (_systemView["newgao"] == "1")
            {
                ddlnew.Value = "1";
            }
            else
            {
                ddlnew.Value = "0";
            }

            //订单打印提醒
            if (_systemView["printorder"] == "1")
            {
                ddlorder.Value = "1";
            }
            else
            {
                ddlorder.Value = "0";
            }
            //订单付款成功提醒
            if (_systemView["orderpay"] == "1")
            {
                ddlorderpay.Value = "1";

            }
            else
            {
                ddlorderpay.Value = "0";
            }
            //订单付款成功提醒2
            if (_systemView["orderpartner"] == "1")
            {
                orderpartner.Value = "1";

            }
            else
            {
                orderpartner.Value = "0";
            }
            //显示开启优惠券到期提醒
            if (_systemView["displayCoupon"] == "1")
            {
                coupon.Value = "1";
            }
            else
            {
                coupon.Value = "0";
            }
            //设置提醒日期
            if (_systemView["displayCouponDay"] != null && _systemView["displayCouponDay"] != "")
            {
                couponDay.Value = _systemView["displayCouponDay"];
            }
            else
            {
                couponDay.Value = "0";
            }

            //设置库存报警电话
            if (_systemView["inventmobile"] != null && _systemView["inventmobile"] != "")
            {

                inventmobile.Value = _systemView["inventmobile"];
            }
            else
            {
                inventmobile.Value = "0";
            }

            if (_systemView["invent_war"] != null && _systemView["invent_war"] == "1" && _systemView["inventory"] != null && _systemView["inventory"] == "1")
            {
                inventmobile.Attributes.Add("require", "true");
            }
            //开启买家评论
            if (_systemView["navUserreview"] == "1")
            {
                navUserreview.Value = "1";
            }
            else
            {
                navUserreview.Value = "0";
            }
            //开启手动买家评论
            if (_systemView["UserreviewYN"] == "1")
            {

                UserreviewYesOrNo.Value = "1";
            }
            else
            {
                UserreviewYesOrNo.Value = "0";
            }

            //项目订阅开关
            if (_systemView["orderteam"] != null)
            {
                ddlOpenOrderTeam.Value = _systemView["orderteam"].ToString();
            }
            //项目订阅数
            if (_systemView["orderteamnum"] != null && _systemView["orderteamnum"] != "")
            {
                orderteamnum = _systemView["orderteamnum"].ToString();
            }
            //if (_systemView["orderteamnum"] == "" || _systemView["orderteamnum"] ==null)
            //{
            //    orderteamnum ="5";
            //}
            //签到送金额
            if (_systemView["loginmoney"] != null && _systemView["loginmoney"].ToString() != "")
            {
                loginmoney = _systemView["loginmoney"].ToString();
            }

            //积分
            if (_systemView["loginscore"] != null && _systemView["loginscore"].ToString() != "")
            {
                loginscore = _systemView["loginscore"].ToString();
            }
            //if (_systemView["bulletin"] != null && _systemView["bulletin"].ToString() != "") 
            //{
            //    bulletin = _systemView["bulletin"].ToString(); 
            //}

            //开启签到功能
            if (_systemView["opensign"] != null && _systemView["opensign"].ToString() != "")
            {
                opensign.Value = _systemView["opensign"].ToString();
            }

            //开启URL重写
            //if (_systemView["isrewrite"] != null && _systemView["isrewrite"].ToString() != "")
            //{
            //    isrewrite.Value = _systemView["isrewrite"].ToString();
            //}
            //else
            //{
            //    isrewrite.Value = "0";
            //}

            //开启订单邮箱
            if (_systemView["orderemailvalid"] == "1")
            {

                DropDownListmail.Value = "1";
            }
            else
            {
                DropDownListmail.Value = "0";
            }

            //设置买家评论返利金额
            if (_systemView["userreview_rebate"] != null && _systemView["userreview_rebate"].ToString().Trim() != "")
            {
                DetailMoney = Convert.ToDecimal(_systemView["userreview_rebate"].ToString());
            }
            else
            {
                DetailMoney = 0;
            }
            //设置购物车热销分页数目
            if (_systemView["txtshuGood"] != null && _systemView["txtshuGood"].ToString() != "")
            {
                txtshuGood = _systemView["txtshuGood"];

            }
            else
            {
                txtshuGood = "12";
            }

            //设置开启网站关闭功能
            if (_systemView["isCloseSite"] == null || _systemView["isCloseSite"].ToString() == "")
            {
                CloseSite.Value = "0";
            }
            else
            {
                CloseSite.Value = _systemView["isCloseSite"];
            }

            //关闭购物车
            if (_systemView["closeshopcar"] == "1")
            {
                CloseShopcarEvent.Value = "1";

            }
            else
            {
                CloseShopcarEvent.Value = _systemView["closeshopcar"];
            }
            //项目购物车开关
            if (_systemView["isguige"] == "1")
            {
                ddlisguige.Value = "1";
            }
            else
            {
                ddlisguige.Value = "0";
            }
            //设置开启图片延迟加载功能
            if (_systemView["slowimage"] == "1")
            {
                slowimage.Value = "1";
            }
            else
            {
                slowimage.Value = "0";
            }
            //开启友情链接
            if (_systemView["closeLocation"] == "1")
            {
                closeLocationEvent.Value = "1";
            }
            else
            {
                closeLocationEvent.Value = "0";
            }
            //开启验证码
            if (_systemView["ischeckcode"] == "1")
            {
                ischeckcode.Value = "1";
            }
            else
            {
                ischeckcode.Value = "0";
            }

            //切换城市开关
            if (_systemView["changecity"] != null && _systemView["changecity"].ToString() != "")
            {
                ddlchagecity.Value = _systemView["changecity"];
            }
            else
            {
                ddlchagecity.Value = "1";
            }

            //订单拆分
            if (_systemView["opensplitorder"] == "1")
            {
                ddlSplitOrder.Value = "1";
            }
            else
            {
                ddlSplitOrder.Value = "0";
            }
            //启用页面缓存
            if (_systemView["pagecache"] == "1")
            {
                pagecache.Value = "1";
            }
            else
            {
                pagecache.Value = "0";
            }
            //团购预告
            if (_systemView["teamdpredict"] == "1")
            {
                ddlTeamPredict.Value = "1";
            }
            else
            {
                ddlTeamPredict.Value = "0";
            }
            //手机验证码
            if (_systemView["mobileverify"] == "1")
            {
                mobileverify.Value = "1";
            }
            else
            {
                mobileverify.Value = "0";
            }
            //开启商户评论
            if (_systemView["openUserreviewPartner"] == "1")
            {
                ddlOpenUserreviewPartner.Value = "1";
            }
            else
            {
                ddlOpenUserreviewPartner.Value = "0";
            }
            //自动处理商户评论
            if (_systemView["doUserreviewPartner"] == "1")
            {
                ddlDoUserreviewPartner.Value = "1";
            }
            else
            {
                ddlDoUserreviewPartner.Value = "0";
            }

            //优惠券生成模式
            if (_systemView["couponPattern"] == "1")
            {
                ddlCouponPattern.Value = "1";//一对多
            }
            else
            {
                ddlCouponPattern.Value = "0";//多对多
            }
            if (_systemView["couponSmsNum"] != null)
            {
                ddlsmsnum.Value = _systemView["couponSmsNum"];
            }
            else
            {
                ddlsmsnum.Value = "5";
            }
            //是否开启库存

            if (_systemView["inventory"] == "1")
            {

                ddlinventory.Value = "1";
            }
            else
            {
                ddlinventory.Value = "0";
            }

            //库存报警

            if (_systemView["invent_war"] == "1")
            {
                ddlinven_war.Value = "1";
            }
            else
            {
                ddlinven_war.Value = "0";
            }

            //库存报警电话
            if (_systemView["inventmobile"] != null)
            {
                inventmobile.Value = _systemView["inventmobile"];
            }
            //失败团购显示
            if (system.Displayfailure == 1)
            {
                displayfailure.Value = "1";
            }
            else
            {
                displayfailure.Value = "0";
            }
            //全部答疑显示
            if (system.teamask == 1)
            {
                teamask.Value = "1";
            }
            else
            {
                teamask.Value = "0";
            }
            //仅余额可以秒杀
            if (system.creditseconds == 1)
            {
                creditseconds.Value = "1";
            }
            else
            {
                creditseconds.Value = "0";
            }
            //开启短信订阅
            if (system.smssubscribe == 1)
            {
                smssubscribe.Value = "1";
            }
            else
            {
                smssubscribe.Value = "0";
            }
            //简体繁体转换
            if (system.trsimple == 1)
            {
                trsimple.Value = "1";
            }
            else
            {
                trsimple.Value = "0";
            }
            //用户节省钱数
            if (system.moneysave == 1)
            {
                moneysave.Value = "1";
            }
            else
            {
                moneysave.Value = "0";
            }
            //项目详情通栏
            if (system.teamwhole == 1)
            {
                teamwhole.Value = "1";
            }
            else
            {
                teamwhole.Value = "0";
            }
            //往期团购
            if (system.cateteam == 1)
            {
                cateteam.Value = "1";
            }
            else
            {
                cateteam.Value = "0";
            }
            //品牌商户1
            if (system.catepartner == 1)
            {
                catepartner.Value = "1";
            }
            else
            {
                catepartner.Value = "0";
            }
            //品牌商户2
            if (system.citypartner == 1)
            {
                citypartner.Value = "1";
            }
            else
            {
                citypartner.Value = "0";
            }
            //秒杀抢团
            if (system.cateseconds == 1)
            {
                cateseconds.Value = "1";
            }
            else
            {
                cateseconds.Value = "0";
            }


            //热销商品2
            if (system.categoods == 1)
            {
                categoods.Value = "1";
            }
            else
            {
                categoods.Value = "0";
            }
            //邮箱验证
            if (system.emailverify == 1)
            {
                emailverify.Value = "1";
            }
            else
            {
                emailverify.Value = "0";
            }
            //手机验
            if (system.needmobile == 1)
            {
                needmobile.Value = "1";
            }
            else
            {
                needmobile.Value = "0";
            }
            //是否开启商务合作
            if (_systemView["shop"] == "1")
            {
                shoppar.Value = "1";
            }
            else
            {
                shoppar.Value = "0";
            }

            //一站通强制用户绑定
            if (_systemView["logintongbinduser"] == "1")
            {
                logintongbinduser.SelectedIndex = 1;
            }
            else
            {
                logintongbinduser.SelectedIndex = 0;
            }

            if (_systemView["verifycoupon"] == "1")
            {
                ddlVerifyCoupon.Value = "1";
            }
            else
            {
                ddlVerifyCoupon.Value = "0";
            }
            //是否开启积分商城
            if (_systemView["point"] == "1")
            {
                point.Value = "1";
            }
            else 
            {
                point.Value = "0";
            }
            if (_systemView["regscore"] != null) 
            {
                regscore = _systemView["regscore"].ToString();
            }
            if (_systemView["invitescore"] != null) 
            {
                invitescore = _systemView["invitescore"].ToString();
            }
            if (_systemView["chargescore"] != null) 
            {
                chargescore = _systemView["chargescore"].ToString();
            }
            if (_systemView["irange"] != null && _systemView["irange"] != "")
            {
                GetColor(_systemView["irange"]);
            }
            
            kuaidikey.Value = _systemView["kuaidikey"];
            if (_systemView["Shanghufz"] == "1")
            {
                Shanghufz.Value = "1";
            }
            else 
            {
                Shanghufz.Value = "0";
            }
            if (_systemView["openwapindex"] == "1")
            {
                openwapindex.Value = "1";
            }
            else
            {
                openwapindex.Value = "0";
            }
            if (_systemView["openwaplogin"] == "1")
            {
                openwaplogin.Value = "1";
            }
            else
            {
                openwaplogin.Value = "0";
            }
            
        }
    }
    //显示积分搜索的条件
    public void GetColor(string old)
    {

        for (int i = 0; i < old.Split('|').Length; i++)
        {
            string[] str = old.Split('|');
            if (str[i] != "" && str[i].Split(',')[0] != "")
            {
                bulletin += "<tr>";
                bulletin += "<td>";
                bulletin += "积分条件：<input type=\"text\" class=\"numberkd\" name=\"StuNamea" + i + "\" value='" + str[i].Split(',')[0] + "'>-<input type=\"text\" class=\"numberkd\" name=\"StuNamea" + i + "\" value='" + str[i].Split(',')[1] + "'><input type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
                bulletin += "</td>";
                bulletin += "</tr>";
            }
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
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        选项设置</h2>
                                </div>
                                <div class="sect">
                                    <input type="hidden" id="id" name="id" value="<%=system.id %>" />
                                    <div class="wholetip clear">
                                        <h3>
                                            1、导航栏显示</h3>
                                    </div>
                                    <div class="field" style="display: none;">
                                        <label>
                                            品牌商户</label>
                                        <select id="navpartner" runat="server">
                                        </select>
                                    </div>
                                    <div class="field" style="display: none;">
                                        <label>
                                            秒杀抢团</label>
                                        <select id="navseconds" runat="server">
                                        </select>
                                    </div>
                                    <div class="field" style="display: none;">
                                        <label>
                                            热销商品</label>
                                        <select id="navgoods" runat="server">
                                        </select>
                                    </div>
                                    <div class="field" style="display: none;">
                                        <label>
                                            讨论区</label>
                                        <select id="navforum" runat="server">
                                        </select>
                                    </div>
                                    <div class="field" style="display: none;">
                                        <label>
                                            购物车</label>
                                        <select id="gouwuChe" runat="server">
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>
                                            启用新闻公告</label>
                                        <select id="ddlnew" name="ddlnew" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否开启新闻公告</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            2、购物车</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            团购分页数量控制</label>
                                        <input id="txtshu" type="text" class="number" group="goto" datatype="number" name="txtshu" value="<%=system.guowushu %>" /><span
                                            class="inputtip">(填写数量最好是4的倍数,不然最后一行会显示不完整)</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            热销分页数量控制</label>
                                        <input id="txtshuGood" type="text" class="number" group="goto" datatype="number" name="txtshuGood" value="<%= txtshuGood %>" /><span
                                            class="inputtip">(填写数量最好是4的倍数,不然最后一行会显示不完整)</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            关闭购物车</label>
                                        <select id="CloseShopcarEvent" name="CloseShopcarEvent" runat="server" style="float: left">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">选择"是"，则所有商品均不能放入购物车</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            项目购物车开关</label>
                                        <select id="ddlisguige" name="ddlisguige" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">选择"是"，项目详情下显示购物车信息(满足条件：该项目必须是有规格的项目信息并且该项目没有设置多种价格)</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            3、到货评价设置</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否开启</label>
                                        <select id="navUserreview" name="navUserreview" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">如果开启，前台显示买家评论内容</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否自动返利</label>
                                        <select id="UserreviewYesOrNo" name="UserreviewYesOrNo" runat="server" style="float: left;">
                                            <option value="0">是</option>
                                            <option value="1">否</option>
                                        </select>
                                        <span class="inputtip">选择“是”则不需要管理员审核直接给用户返利，选择“否”需要管理员审核才能返利</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            返利金额</label>
                                        <input id="DetailMoney" type="text" class="number" group="goto" datatype="money" name="DetailMoney"
                                            value="<%= DetailMoney%>" /><span class="inputtip">设置买家每发表一个评论给他账户返利金额</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否开启商户评论</label>
                                        <select id="ddlOpenUserreviewPartner" name="ddlOpenUserreviewPartner" runat="server"
                                            style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">如果开启，前台显示商户评论内容</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            自动处理商户评论</label>
                                        <select id="ddlDoUserreviewPartner" name="ddlDoUserreviewPartner" runat="server"
                                            style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">选择“是”则不需要管理员审核直接显示，选择“否”需要管理员审核才能显示</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            4、库存设置</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            启用库存</label>
                                        <select id="ddlinventory" name="ddlinventory" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否开启库存功能</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            启用库存报警</label>
                                        <select id="ddlinven_war" name="ddlinven_war" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否开启库存报警功能</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            库存报警电话</label>
                                        <input id="inventmobile" type="text" class="number" name="inventmobile" value="0"
                                            runat="server" group="goto" />
                                        <span class="inputtip">当库存报警时，系统会自动给库存报警电话，发送短信信息</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            5、短信提醒</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            优惠券到期提醒</label>
                                        <select id="coupon" name="coupon" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否开启优惠期到期短信提醒功能</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            提醒日期</label>
                                        <input id="couponDay" type="text" class="number" name="txtshu" value="0" group="goto" datatype="number" runat="server" /><span
                                            class="inputtip">优惠券截至前多少天，系统自动发送短信至用户手机提醒。</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            优惠券消费提醒</label>
                                        <select id="opencoupon" name="opencoupon" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">当优惠券被消费时，系统自动给用户发送短信，提醒此优惠券被消费。</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            订单打印提醒</label>
                                        <select id="ddlorder" name="ddlorder" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">当订单被打印后，系统给用户手机发送快递单号信息。</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            订单付款成功</label>
                                        <select id="ddlorderpay" name="ddlorderpay" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">当订单付款成功后，系统给用户手机发送订单信息。</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            订单付款成功2</label>
                                        <select id="orderpartner" name="orderpartner" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">当订单付款成功后，系统给商户发送订单信息。</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            6、杂项设置</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            显示栏团购标题</label>
                                        <select id="displayTitle" name="displayTitle" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>
                                            显示邀请排名</label>
                                        <select id="displayInvite_Top" name="displayInvite_Top" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>
                                            开启底部友情链接</label>
                                        <select id="closeLocationEvent" name="closeLocationEvent" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">选中"是"，则底部友情链接将会显示</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            失败团购显示</label>
                                        <select id="displayfailure" name="displayfailure" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">在往期团购中，是否显示失败的团购</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            全部答疑显示</label>
                                        <select id="teamask" name="teamask" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">本单答疑栏目中，是否显示全部团购项目答疑</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            仅余额可秒杀</label>
                                        <select id="creditseconds" name="creditseconds" runat="server" style="float: left;">
                                            <option value="1">是</option>
                                            <option value="0">否</option>
                                        </select>
                                        <span class="inputtip">是否，秒杀项目是否仅允许余额付款</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            开启短信订阅</label>
                                        <select id="smssubscribe" name="smssubscribe" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否开启短信订阅团购信息功能</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            简体繁体转换</label>
                                        <select id="trsimple" name="trsimple" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否显示在线简体繁体转换链接</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            用户节省钱数</label>
                                        <select id="moneysave" name="moneysave" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">在团购列表页显示共为用户节省多少钱</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商务信息验证</label>
                                        <select id="shoppar" name="shoppar" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">商务合作信息提交是否需要登录</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            显示商户</label>
                                        <select id="teamwhole" name="teamwhole" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">项目详情里显示商户信息</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            网站关闭</label>
                                        <select id="CloseSite" name="CloseSite" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否开启网站关闭功能</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            验证码开关</label>
                                        <select id="ischeckcode" name="ischeckcode" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                            
                                        </select>
                                        <span class="inputtip">用户、商户登录注册时,是否开启验证码</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            开启图片延迟加载</label>
                                        <select id="slowimage" name="slowimage" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">选中"是"，则图片将会随着屏幕的拖动而逐步加载，极大减少带宽占用。</span>
                                        <br />
                                    </div>
                                    <div class="field">
                                        <label>
                                            切换城市开关</label>
                                        <select id="ddlchagecity" name="ddlchagecity" runat="server" style="float: left;">
                                            <option value="0">关闭</option>
                                            <option value="1">开启</option>
                                        </select>
                                        <span class="inputtip">开启时,弹出城市层;关闭则跳转城市页面。</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            下单需填写邮箱</label>
                                        <select id="DropDownListmail" name="DropDownListmail" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">开启时,用户填写的邮箱将更新到个人信息中</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否开启百度地图</label>
                                        <select id="maptype" name="maptype" runat="server">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>
                                            快递100接口key</label>
                                        <input type="text" size="30" id="kuaidikey" style="width: 300px;" name="kuaidikey"
                                            class="f-input" runat="server" value="" /><span id="getkey" style="width: 200px;
                                                float: left; padding-top: 10px;"><a target='_blank' href='http://www.kuaidi100.com/openapi/api_2_02.shtml?typeid=0'>点击获取KEY</a></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            开启订单拆分</label>
                                        <select id="ddlSplitOrder" name="ddlSplitOrder" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否开启订单拆分功能？</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            启用页面缓存</label>
                                        <select id="pagecache" name="pagecache" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">开启此功能，部分页面将被缓存。缓存时间为5分钟过期</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            优惠券验证</label>
                                        <select id="ddlVerifyCoupon" name="ddlVerifyCoupon" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">开启时，前台页面顶部显示此验证</span>
                                    </div>
<%--                                    <div class="field">
                                        <label>
                                            启用URL重写</label>
                                        <select id="isrewrite" name="isrewrite" runat="server" style="float: left;">
                                            <option value="0">关闭</option>
                                            <option value="1">开启</option>
                                        </select>
                                        <span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            &nbsp;</label>
                                        &nbsp; <span class="inputtip">此功能只支持IIS7以上版本，请先确认您空间或者服务器上IIS版本。注意：IIS6不支持此功能</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            &nbsp;</label>
                                        &nbsp; <span class="inputtip">且确认您服务器.net托管管道模式（集成模式-<a href="http://bbs.asdht.com/showtopic-7090.aspx"
                                            target="_blank">配置说明</a>）</span>
                                    </div>--%>
                                    <div class="field">
                                        <label>
                                            开启分站</label>
                                        <select id="Shanghufz" name="Shanghufz" runat="server" style="float:left">
                                            <option value="0" >否</option>
                                            <option value="1" >是</option>
                                        </select>
                                        <span class="inputtip">&nbsp;&nbsp;是否允许商户后台新建分站</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            7、分类显示</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            团购预告</label>
                                        <select id="ddlTeamPredict" name="ddlTeamPredict" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否项目分类显示？</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            往期团购</label>
                                        <select id="cateteam" name="cateteam" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否项目分类显示？</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            品牌商户1</label>
                                        <select id="catepartner" name="catepartner" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否商户分类显示？</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            品牌商户2</label>
                                        <select id="citypartner" name="citypartner" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否商户按城市显示？</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            秒杀抢团</label>
                                        <select id="cateseconds" name="cateseconds" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否项目分类显示？</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            热销商品</label>
                                        <select id="categoods" name="categoods" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">是否项目分类显示？</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            8、注册选项</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            邮箱验证</label>
                                        <select id="emailverify" name="emailverify" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">用户注册时，是否必须进行邮箱验证</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            手机号码必填</label>
                                        <select id="needmobile" name="needmobile" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">用户注册时，是否必须必须输入合法的手机号码</span>
                                        <br />
                                    </div>
                                    <div class="field">
                                        <label>
                                            手机验证码</label>
                                        <select id="mobileverify" name="mobileverify" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">用户注册时，是否必须进行获取手机验证码</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            9、一站通相关</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            强制用户绑定</label>
                                        <select id="logintongbinduser" name="logintongbinduser" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>
                                            &nbsp;</label>
                                        &nbsp; <span class="inputtip">用户首次通过一站通过来，是否需要绑定个人信息，如果选是则需要先绑定个人信息，如果选否则由系统自动创建用户信息。</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            &nbsp;</label>
                                        &nbsp; <span class="inputtip">但是如果开启ucenter则此设置无效，将会强制绑定</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            10、签到设置</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            启用签到</label>
                                        <select id="opensign" name="opensign" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">选择开启签到功能，前台首页侧栏显示用户签到</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            积分</label>
                                        <input id="loginscore" type="text" class="number" name="loginscore" group="goto" datatype="number" value="<%= loginscore %>" /><span
                                            class="inputtip">(用户签到送积分数)</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            金额</label>
                                        <input id="loginmoney" type="text" class="number" name="loginmoney" group="goto" datatype="money" value="<%= loginmoney %>" /><span
                                            class="inputtip">(用户签到送金额)</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            11、项目订阅设置</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            启用项目订阅</label>
                                        <select id="ddlOpenOrderTeam" name="ddlOpenOrderTeam" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">选择开启项目订阅，前台往期团购页面显示下次开售告诉我,进入订阅页面</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            订阅项目数</label>
                                        <input id="orderteamnum" type="text" class="number" name="orderteamnum" group="goto" datatype="number"
                                            value="<%= orderteamnum %>" /><span class="inputtip">(用户订阅项目的个数)</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            12、优惠券设置</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            优惠券生成模式</label>
                                        <select id="ddlCouponPattern" name="ddlCouponPattern" runat="server" style="float: left;">
                                            <option value="0">一对一</option>
                                            <option value="1">一对多</option>
                                        </select>
                                        <span class="inputtip">一对一：当一次购买多个产品时，生成多个优惠券号和多个优惠券密码。即：一个优惠券号对应一个密码
                                            <br />
                                            一对多：当一次购买多个产品时，生成一个优惠券号和多个优惠券密码。即：一个优惠券号对应多个密码 </span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            优惠券发送次数</label>
                                        <select id="ddlsmsnum" name="ddlsmsnum" runat="server" style="float: left;">
                                            <option value="5">5</option>
                                            <option value="4">4</option>
                                            <option value="3">3</option>
                                            <option value="2">2</option>
                                            <option value="1">1</option>
                                        </select>
                                        <span class="inputtip">设置用户购买优惠券项目时，最多可发送优惠券的次数(最多5次) </span>
                                    </div>
                                
                                    <div class="wholetip clear">
                                        <h3>
                                            13、积分规则</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            启用积分商城</label>
                                        <select id="point" name="point" runat="server" style="float:left">
                                            <option value="0" >否</option>
                                            <option value="1" >是</option>
                                        </select>
                                        <span class="inputtip">&nbsp;&nbsp;是否开启积分商城</span>
                                    </div>
                                     <div class="field">
                                        <label>
                                            用户注册</label>
                                        <input id="regscore" type="text" class="number" name="regscore" datatype="number" group="go"  value="<%= regscore%>" /><span
                                            class="inputtip">(用户注册送积分数)</span>
                                    </div>
                                  
                                        <div class="field">
                                        <label>
                                            邀请好友</label>
                                        <input id="invitescore" type="text" class="number" name="invitescore" datatype="number" group="go"  value="<%= invitescore %>" /><span
                                            class="inputtip">(邀请好友送积分数)</span>
                                    </div>
                      
                                        <div class="field">
                                        <label>
                                            充值返积分</label>
                                        <input id="chargescore" type="text" class="number" name="chargescore" datatype="number" group="go"  value="<%= chargescore %>" /><span
                                            class="inputtip">(用户充值后送积分数)</span>
                                    </div>
                                            <div class="field">
                                        <label>
                                            积分搜索间隔</label>
                                        <input type="button" name="btnAddFile" value="添加" onclick="additem('tb')" />
                                        <font style='color: red'>例如 500-1000</font>
                                        <input type="hidden" id="irange" name="irange" value="" />
                                        <input type="hidden" id="cont" name="cont" value="" />
                                    </div>
                                    <div class="field">
                                        <label>
                                        </label>
                                        <table id="tb">
                                            <%=bulletin%>
                                        </table>
                                        <input type="hidden" name="totalNumber" value="" />
                                    </div>    
                                    
                                   <div class="wholetip clear">
                                        <h3>
                                            14、手机端设置</h3>
                                    </div>                               
                                    <div class="field">
                                        <label>
                                            启用首页自动判断</label>
                                        <select id="openwapindex" name="openwapindex" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">选择启用首页自动判断功能，使用手机登录后会自动跳转到手机端页面</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            启用手机验证登录</label>
                                        <select id="openwaplogin" name="openwapindex" runat="server" style="float: left;">
                                            <option value="0">否</option>
                                            <option value="1">是</option>
                                        </select>
                                        <span class="inputtip">选择开启手机验证登录，在手机端可以使用手机号进行登陆</span>
                                    </div>
                                    <div class="act">
                                        <input type="hidden" name="action" value="upxuanxiang" />
                                        <input type="submit" id="commit" group="go" onclick="getScoreVal()"  class="formbutton" value="保存" /> &nbsp;
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
</body>
<script type="text/javascript">
    function packetType() {
        var packetType = $("#selPacket").val();
        if (packetType.toString() == "money") {
            $("#googlekey").show();
            $("#googlekeyname").show();
            $("#baidu").hide();
            $("#baiduname").hide();
        }
        if (packetType.toString() == "card") {
            $("#googlekey").hide();
            $("#googlekeyname").hide();
            $("#baidu").show();
            $("#baiduname").show();
        }
    }

    jQuery(function () {

        $("#DetailMoney").keyup(function (event) {

            if ($("#DetailMoney").val() < 0) {
                var arry = $("#DetailMoney").eq(0).val().split("-")[1];
                $("#DetailMoney").val(arry);

            }
        });

        $("#ddlinven_war").change(function (event) {

            if ($("#ddlinven_war").val() == 0 || $("#ddlinventory").val() == 0) {
                $("#inventtime").removeAttr("require");
                $("#inventmobile").removeAttr("require");
            }
            else {

                $("#inventtime").attr("require", "true");
                $("#inventmobile").attr("require", "true");
            }
        });
        $("#ddlinventory").change(function (event) {

            if ($("#ddlinven_war").val() == 0 || $("#ddlinventory").val() == 0) {
                $("#inventtime").removeAttr("require");
                $("#inventmobile").removeAttr("require");
            }
            else {

                $("#inventtime").attr("require", "true");
                $("#inventmobile").attr("require", "true");
            }
        });
    });

    var num = 0;
    function additem(id) {

        var row, cell, str;
        //row = eval("document.all["+'"'+id+'"'+"]").insertRow();
        row = document.getElementById(id).insertRow(-1);
        if (row != null) {
            cell = row.insertCell(-1);
            cell.innerHTML = "积分条件：<input type=\"text\" class=\"numberkd\" name=\"StuName" + num + "\">-<input type=\"text\" class=\"numberkd\" name=\"StuName" + num + "\"><input type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
        }
        num++
        document.getElementsByName("totalNumber")[0].value = num;

    }
    function deleteitem(obj, id) {
        var rowNum, curRow;
        curRow = obj.parentNode.parentNode;
        rowNum = document.getElementById(id).rows.length - 1;
        document.getElementById(id).deleteRow(curRow.rowIndex);
        //调用删除  记录删除的条数
        var cont = document.getElementById("cont").value;
        cont++;
        document.getElementById("cont").value = cont;
        
    }
    //提交按钮之前获取积分规则
    function getScoreVal() {
        var tab = document.getElementById("tb");
        var str = "";
            for (var i = 0; i < tab.rows.length; i++) {
                if ($("input[name='StuNamea'" + i + "]").val() != undefined) {
                    var row = document.getElementsByName("StuNamea" + i);
                    if (row.length != 0) {
                        if (row[1].value != "" && row[0].value != "") {

                            str += row[0].value + "," + row[1].value + "|";
                        }
                    }
                } else {break; }
            }
            var cont = 0;
            cont = document.getElementById("cont").value;

            for (var j = 0; j < tab.rows.length+cont; j++) {
                 val = document.getElementsByName("StuNamea" + j);
                 if (val.length != 0) {
                     ++cont;
                    if (val[0].value != "" && val[1].value != "") {
                        str += val[0].value + "," + val[1].value + "|";
                    }
                }
            }
            for (var s = 0; s < parseInt(tab.rows.length - cont); s++) {
    
                var nval = document.getElementsByName("StuName" + s);
                if (nval.length != 0) {
                    if (nval[0].value != "" && nval[1].value != "") {
                        str += nval[0].value + "," + nval[1].value + "|";
                }
            }
        }
        $("#irange").val(str);
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>