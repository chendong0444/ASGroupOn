<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
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
    
    //充值金额
    protected decimal money = 0;
    //代金券代号
    protected string code = "";
    //代金券数量
    protected int cardCount = 0;
    //派发数量
    protected int sendCount = 1;
    //派发用户id
    protected string userId = "";
    //用户是否重复
    protected bool boolExist = true;
    protected int strAdminId=0;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Flow_Money))
        {
            SetError("你不具有查看红包的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        } 
        if (!string.IsNullOrEmpty(PageValue.CurrentAdmin.ToString()))
        {
            strAdminId = PageValue.CurrentAdmin.Id;
        }
        else
        {
            SetError("没有检索到您的登录");
            Response.Redirect("Login.aspx");
        }
        string send = Request["send"];
        //筛选后跳回
        if (send == "true")
        {
            //session不为空
            if (Session["getUserId"] != null)
            {
                StringBuilder stB = new StringBuilder();
                stB.Append(Session["getUserId"].ToString());
                //session不为空并且txtId为空
                if (stB.ToString() != "" && stB != null && this.txtId.Value == "")
                {
                    this.txtId.Value = stB.ToString();
                }
                //获取派发类型
                string packetType = "";
                if (Request.Cookies["getTypeCookie"] != null)
                {
                    HttpCookie cookieType = Request.Cookies["getTypeCookie"];
                    packetType = cookieType.Value;
                    //getTypeCookie为充值
                    if (packetType == "money")
                    {
                        this.selPacket.Value = "money";
                        this.divMoney.Style.Add("display", "block");
                        this.divCode.Style.Add("display", "none");
                        this.divCount.Style.Add("display", "none");

                        if (Request.Cookies["getMoneyCookie"] != null && this.txtMoney.Value == "")
                        {
                            HttpCookie chongCookie = Request.Cookies["getMoneyCookie"];
                            this.txtMoney.Value = chongCookie.Value;
                        }
                    }
                    //getTypeCookie为代金券
                    if (packetType == "card")
                    {
                        this.selPacket.Value = "card";
                        this.divMoney.Style.Add("display", "none");
                        this.divCode.Style.Add("display", "block");
                        this.divCount.Style.Add("display", "block");

                        if (Request.Cookies["getCardCookie"] != null)
                        {
                            HttpCookie cookie = Request.Cookies["getCardCookie"];
                            string sendCookie = cookie.Value;
                            string[] s = sendCookie.Split(',');
                            if (this.txtCode.Value == "")
                            {
                                this.txtCode.Value = s[0];
                            }
                            if (this.hidCardCount.Value == "")
                            {
                                this.lblCardCount.InnerText = s[1];
                                this.hidCardCount.Value = s[1];
                            }
                            if (this.txtCount.Value == "")
                            {
                                this.txtCount.Value = s[2];
                            }
                        }
                    }
                }
            }
        }         
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript" language="javascript">
    function packetType() {
        var packetType = $("#selPacket").val();
        if (packetType.toString() == "money") {
            $("#divMoney").show();
            $("#divCode").hide();
            $("#divCount").hide();
        }
        if (packetType.toString() == "card") {
            $("#divMoney").hide();
            $("#divCode").show();
            $("#divCount").show();
        }
        var typeCookie = "getTypeCookie" + "=" + packetType;
        document.cookie = typeCookie;
    }
    function send() {
        var packetType = $("#selPacket").val();
        if (packetType.toString() == "money") {
            var money = $("#txtMoney").val();
            if (money.toString() == "" || money == null) {
                alert("充值金额不能为空");
                return;
            }

            var txtId = $("#txtId").val();
            if (txtId.toString() == "" || txtId == null) {
                alert("用户ID不能为空");
                return;
            }
        }
        if (packetType.toString() == "card") {
            var code = $("#txtCode").val();
            if (code.toString() == "" || code == null) {
                alert("代金券代号不能为空");
                return;
            }
            var sendCount = $("#txtCount").val();
            if (sendCount.toString() == "" || sendCount == null) {
                alert("派发数量不能为空");
                return;
            }
            var txtId = $("#txtId").val();
            if (txtId.toString() == "" || txtId == null) {
                alert("用户ID不能为空");
                return;
            }
        }
        if (window.confirm("确认派发么？")) {
            $("#hidOk").val("true");
        }
        else {
            $("#hidOk").val("false");
        }
    }
    function shaiXuan() {
        var packetType = $("#selPacket").val();
        var typeCookie = "getTypeCookie" + "=" + packetType;
        document.cookie = typeCookie;
        if (packetType.toString() == "money") {
            var money = $("#txtMoney").val();
            var valueCookie = "getMoneyCookie" + "=" + money;
            document.cookie = valueCookie;
        }
        if (packetType.toString() == "card") {
            var code = $("#txtCode").val();
            var cardCount = $("#hidCardCount").val();
            var sendCount = $("#txtCount").val();
            var valueCookie = "getCardCookie" + "=" + code + "," + cardCount + "," + sendCount;
            document.cookie = valueCookie;
        }
        X.get("card.aspx?action=user");
    }
    jQuery(document).ready(function () {
        jQuery("a.ajaxlink").unbind("click");
        jQuery("a[ask]").unbind("click");
        x_init_hook_validator();

        jQuery('a.ajaxlink').click(function () {
            if (jQuery(this).attr('no') == 'yes')
                return false;
            var link = jQuery(this).attr('href');
            var ask = jQuery(this).attr('ask');
            if (ask) {
                if (!confirm(ask)) {
                    return false;
                }

            } else if (ask && !confirm(ask)) {
                return false;
            }
            X.get(link);
            return false;
        });
    });
    function showCard() {
        var packetType = $("#selPacket").val();
        if (packetType.toString() == "money") {
            $("#divMoney").show();
            $("#divCode").hide();
            $("#divCount").hide();
        }
        if (packetType.toString() == "card") {
            $("#divMoney").hide();
            $("#divCode").show();
            $("#divCount").show();
        }
        var code = $("#txtCode").val();
        $.ajax({
            type: "POST",
            url:  "ajax_card.aspx?action=count",
            data: { "code": code },
            success: function (msg) {
                if (msg != null) {
                    $("#lblCardCount").text(msg);
                    $("#hidCardCount").val(msg);
                }
                else {
                    $("#lblCardCount").text();
                }
            }
        });
    };
 </script>
<body class="newbie" onload="showCard()">
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
                                        红包
                                    </h2>
                                </div>
                               <div class="sect">
                                    <ul class="yingxiao-packet">
                                        <li>
                                            <label>
                                                &nbsp;&nbsp;&nbsp;红包类型：
                                                <select id="selPacket" name="selPacket" onChange="packetType()"  runat="server">
                                                    <option value="money">充值</option>
                                                    <option value="card">代金券</option>
                                                </select>
                                            </label>
                                        </li>
                                        <li id="divMoney" runat="server">
                                            <div id="Div1" runat="server">
                                                &nbsp;&nbsp;&nbsp;充值金额：
                                                <input type="text" name="txtMoney" id="txtMoney" require="true" datatype="money" class="f-input"  runat="server"/>
                                                <span style="clear: both; color: #989898;">每个用户充值的金额</span>
                                            </div>
                                        </li>
                                        <li id="divCode" style="display: none" runat="server">
                                            <div id="Div2" runat="server">
                                                代金券代号：
                                                <input type="text" name="txtCode" id="txtCode" require="true" class="f-input" onKeyUp="showCard()"  runat="server"/>　共
                                                <label id="lblCardCount" runat="server">
                                                    0</label>
                                                张</div>
                                        </li>
                                        <li id="divCount" style="display: none" runat="server">
                                            <div id="Div3" runat="server">
                                                &nbsp;&nbsp;&nbsp;派发数量：
                                                <input type="text" name="txtCount" id="txtCount" require="true" datatype="number" class="f-input"  runat="server"/>
                                                <span style="clear: both; color: #989898;">每个用户派发的数量</span>
                                            </div>
                                        </li>
                                        <li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;用户ID：
                                            <input id="Button1" type="button" value="筛选" name="shaiXuan" group="goto" class="formbutton validator"
                                                style="padding: 1px 6px;" onClick="shaiXuan()" runat="server"  />
                                           </li>
                                        <li class="ht_auto" style="padding-left:74px;">
                                            <textarea name="txtId" id="txtId" style="width: 700px; height: 80px;" group="go" require="true" rows='8' runat="server"></textarea>
                                            <br />
                                            <span class="" style="text-align: left; clear: both; color: #989898;">用户ID，使用半角空格逗号或换行隔开多个ID</span>
                                        </li>
                                       
                                        <li style=" width:120px; text-align:right;">
                                         <input type="submit" value="派发" name="sendS" group="goto" class="formbutton validator"
                                                style="padding: 1px 6px;" onClick="send()" />
                                        </li>
                                    </ul>
                                </div>
                                <input type="hidden" name="action" value="addhbChongZhi" />
                                <input type="hidden" id="adminid" name="adminid" value="<%=strAdminId %>" />
                                <input type="hidden" id="hidCardCount" name="hidCardCount"  runat="server"/>
                                <input type="hidden" id="hidOk" name="hidOk"  value="false" />
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
<%LoadUserControl("_footer.ascx", null); %>