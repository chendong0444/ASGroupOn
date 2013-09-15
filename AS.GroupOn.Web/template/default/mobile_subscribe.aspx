<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    protected string useremobile = String.Empty;
    protected string curcityname = String.Empty;
    protected string cityname = String.Empty;
    protected string cityhtml = String.Empty;
    protected NameValueCollection _system = new NameValueCollection();
    protected ISystem sysmodel = null;
    protected string teamid = String.Empty;
    protected ITeam teamM = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!Page.IsPostBack)
        {
            _system = AS.Common.Utils.WebUtils.GetSystem();
            if (AsUser != null)
            {
                useremobile = AsUser.Mobile;
            }
            if (Request["id"] != null && Request["id"].ToString() != "")
            {

                TeamFilter teambl = new TeamFilter();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teamM = session.Teams.GetByID(AS.Common.Utils.Helper.GetInt(Request["id"].ToString(), 0));
                }

                teamid = Request["id"].ToString();
            }
        }
        if (Request["action"] != null && Request["action"].ToString() != "" && Request["action"].ToString() == "orderteam")
        {
            string strmobile = Request["mobile"];
            string strteamid = Request["id"];
            string will_send_hour = Request.Form["will_send_hour"];
            SmssubscribeFilter smsft = new SmssubscribeFilter();
            smsft.Mobile = strmobile;
            ISmssubscribe smsmodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                smsmodel = session.Smssubscribe.Get(smsft);
            }
            if (smsmodel != null)
            {
                SmssubscribedetailFilter smsDetailft = new SmssubscribedetailFilter();
                ISmssubscribedetail smsDetailmodel = null;
                smsDetailft.Mobile = strmobile;
                smsDetailft.Teamid = AS.Common.Utils.Helper.GetInt(strteamid, 0);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    smsDetailmodel = session.Smssubscribedetail.Get(smsDetailft);
                }
                if (smsDetailmodel != null)
                {
                    //Response.Write("<script language='javascript'>alert('该项目已经订阅，请订阅其他项目！');location.href='/mobile_subscribe.aspx?id=" + strteamid + "';<"+"/script>\r\n");
                    Response.Write("ssssss");
                }
                else
                {
                    ISmssubscribedetail smsDetail_model = AS.GroupOn.App.Store.CreateSmssubscribedetail();
                    smsDetail_model.mobile = strmobile;
                    smsDetail_model.teamid = AS.Common.Utils.Helper.GetInt(strteamid, 0);
                    //smsDetail_model.Sendtime = int.Parse( Request["sendtime"]);
                    int id = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        id = session.Smssubscribedetail.Insert(smsDetail_model);
                    }
                    if (id > 0)
                    {
                        SetSuccess("该项目已经订阅成功！");
                        Response.Redirect(GetUrl("手机订阅", "mobile_subscribe.aspx?id=" + strteamid));
                        Response.End();
                    }
                    else
                    {
                        SetError("该项目已经订阅失败！");
                        Response.Redirect(GetUrl("手机订阅", "mobile_subscribe.aspx?id=" + strteamid));
                        Response.End();
                    }

                }



            }
            else
            {
                SetError("该手机号码还未绑定，请先绑定手机号！");
                Response.Redirect(GetUrl("手机订阅", "mobile_subscribe.aspx?id=" + strteamid));
            }
        }

    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script>
    var x = 60;
    function countSecond() {
        if (x > 1) {
            x = x - 1;
            $("#mobile").attr("readonly", "readonly");
            $("#get_confirm_code").attr("disabled", "disabled");
            document.displaySec.get_confirm_code.value = x + "秒后重新发送";
            setTimeout("countSecond()", 1000);
        }
        else {
            x = 60;
            document.displaySec.get_confirm_code.value = "获取验证码";
            $("#mobile").attr("readonly", "");
            $("#get_confirm_code").attr("disabled", "");
        }
    }
</script>
<body class="bg-alt">
    <form id="form1" name="displaySec">
        <script type="text/javascript">
            $(document).ready(function () {
                $("#confirm").hide();
                $("#notice").hide();
                $("#will_send_hour").hide();
                $("#step2").hide();
                $("#get_confirm_code").click(function () {
                    var mobile = $("#mobile").val();
                    $("#bindmobile").html(mobile);
                    if (mobile != "") {
                        //发送短信；
                        $.ajax({
                            type: "POST",
                            url: webroot + "ajax/sms.aspx?action=m_subscribe",
                            data: { "mobile": mobile },
                            success: function (msg) {
                                if (msg == "1") {
                                    alert("短信已发送至:" + mobile);
                                    countSecond();
                                } else if (msg == "0") {
                                    alert("短信已发送失败！");
                                }
                                else if (msg == "2") {
                                    $("#confirm").show();
                                    $("#notice").show();
                                    $("#will_send_hour").show();
                                    $("#divmobile").hide();
                                    $("#divconfirmcode").hide();
                                    $("#bind").hide();
                                    $("#step2").show();
                                    $("#step1").hide();
                                    //$("#bindmobile").html(mobile);
                                    alert("该手机号码已绑定，请订阅项目");


                                } else if (msg == "3") {
                                    alert("手机格式不正确!");
                                }
                            }
                        });
                    }
                });

                $("#bind").click(function () {
                    var mobile = $('#mobile').val();
                    var secret = $('#confirm_code').val();
                    var teamid = $('#go_to_subscribe').val();
                    if (secret == "") {
                        alert("请输入验证码！");
                        return;
                    }
                    X.get(webroot + 'ajax/sms.aspx?action=bindmobile&mobile=' + mobile + '&secret=' + secret + '&id=' + teamid);

                });
                $("#aginsign").click(function () {
                    $("#confirm").hide();
                    $("#notice").hide();
                    $("#will_send_hour").hide();
                    $("#divmobile").show();
                    $("#divconfirmcode").show();
                    $("#bind").show();
                    $("#step2").hide();
                    $("#step1").show();

                });
                $("#subcribe").click(function () {

                    var mobile = $("#bindmobile").html();

                    var teamid = $('#go_to_subscribe').val();

                    var bsend_in_9 = $("#send_in_9").attr("checked");
                    var bsend_in_0 = $("#send_in_0").attr("checked");
                    if (bsend_in_9) {
                        sendtime = 9;
                    }
                    if (bsend_in_0) {
                        sendtime = 0;
                    }

                    if (mobile == "") {
                        alert("手机号失效");
                        return;
                    }

                    if (sendtime != 0 && sendtime != 9) {
                        alert("请选择发送时间！");
                        return;
                    }

                    if (teamid == "") {
                        alert("请重新选择项目，项目已失效！");
                        return;
                    }

                    X.get(webroot + 'ajax/sms.aspx?action=orderteam&mobile=' + mobile + '&id=' + teamid + '&sendtime=' + sendtime);
                });

            });
        </script>
        <div id="pagemasker">
        </div>
        <div id="dialog">
        </div>
        <div id="doc">
            <div id="bdw" class="bdw">
                <div id="bd" class="cf">
                    <div style="background-color: #FFFFFF; border: 1px solid #FF9966; margin: 0 auto; overflow: hidden; padding: 20px; width: 814px;">
                        <img id="step1" src="<%=ImagePath() %>step-1.gif">
                        <img id="step2" src="<%=ImagePath() %>step-2.gif">
                        <div style="border: 1px solid #CCCCCC; display: inline; float: left; height: 262px; overflow: hidden; padding: 10px 20px; width: 360px;">
                            <%if (AsUser != null)
                              {%>
                            <%if (AsUser.Realname != null)
                              {%>
                            <div class="nickname">
                                <%=AsUser.Realname %>
                            您好：
                            </div>
                            <% }
                              else
                              { %>
                            <div class="nickname">
                                <%=AsUser.Username %>
                            您好：
                            </div>
                            <% }
                              }%>
                        您准备订阅
                        <%if (teamM != null)
                          { %>
                            <a target="_blank" class="mb_name" href="<%=getTeamPageUrl(teamM.Id) %>">
                                <%=teamM.Title%></a>
                            <%} %>
                            <div id="desc">
                                我们将在开售当天以手机短信的形式通知您<br>
                                短信发送时间可以在 我的订阅列表 页面设置
                            </div>
                            <input type="hidden" value="<%=teamid %>" id="go_to_subscribe" />
                            <div class="mobile" id="divmobile">
                                <p>
                                    手机号：
                                </p>
                                <input type="text" class="input-mobile default_value" id="mobile" name="mobile" value="<%=useremobile %>" />
                                <input type="button" class="formbutton" value="获取验证码" id="get_confirm_code" name="get_confirm_code"
                                    style="_margin-top: 0" />
                            </div>
                            <div class="confirm-code" id="divconfirmcode">
                                <p>
                                    验证码：
                                </p>
                                <input type="text" class="input-confirm_code default_value" id="confirm_code" name="confirm_code" />
                            </div>
                            <input type="button" value="绑定手机" class="input-bind formbutton" id="bind" name="bind" />
                            <div class="will_send_hour" id="will_send_hour">
                                <div class="til">
                                    发送时间
                                </div>
                                <input type="radio" checked="checked" value="9" name="will_send_hour" id="send_in_9"/><label
                                    for="send_in_9">早上9点</label>
                                <input type="radio" value="0" name="will_send_hour" id="send_in_0"><label for="send_in_0"/>凌晨0点</label>
                                <div class="clear">
                                </div>
                            </div>
                            <div class="confirm" id="confirm">
                                <p>
                                    提示信息将发送到：<span id="bindmobile"></span>
                                </p>
                                <p>
                                    换号了？<a href="javascript:void(0)" id="aginsign">重新绑定手机号码</a>
                                </p>
                                <input type="button" id="subcribe" class="formbutton" name="subcribe" value="确认订阅" />
                            </div>
                            <ul class="notice" id="notice">
                                <li>1.您最多订阅<%if (_system != null && _system["orderteamnum"] != null)
                                             { %>
                                    <%=_system["orderteamnum"]%>
                                    <%}
                                             else
                                             {%>5<% } %>个产品，请仔细挑选好您喜欢的产品</li>
                            </ul>
                        </div>
                        <div style="border: 1px solid #CCCCCC; float: left; height: 282px; margin-left: 20px; overflow: hidden; width: 390px;">
                            <%if (teamM != null)
                              { %>
                            <a target="_blank" href="<%=getTeamPageUrl(teamM.Id) %>">
                                <img src="<%=teamM.Image %>" style="width: 390px; height: 282px;"></a>
                            <%} %>
                        </div>
                    </div>
                </div>
                <!-- bd end -->
            </div>
            <!-- bdw end -->
        </div>
    </form>
</body>
</html>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
