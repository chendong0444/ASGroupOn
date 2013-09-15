<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

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
    protected string strUser = string.Empty;
    protected string strPwd = string.Empty;
    protected string strcode = string.Empty;
    protected string logintype = string.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = PageValue.CurrentSystem.abbreviation;
        PageValue.WapBodyID = "account";
        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["username"] != null && Request.Form["password"] != null)
            {
                strUser = Helper.GetString(Request.Form["username"].ToString().Trim(), String.Empty);
                strPwd = Helper.GetString(Request.Form["password"].ToString().Trim(), String.Empty);
                logintype = "nomal";
            }

            if (Request.Form["mobile"] != null && Request.Form["code"] != null)
            {
                strcode = Helper.GetString(Request.Form["code"].ToString().Trim(), String.Empty);
                strUser = Helper.GetString(Request.Form["mobile"].ToString().Trim(), String.Empty);
                logintype = "mobile";
            }
            if (!string.IsNullOrEmpty(logintype))
            {
                LoginWap(strUser, strPwd, strcode);
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div class="errMsg" style="display: none;">
</div>
<div id="login" class="body account">
    <div class="wrapper">
        <nav class="login-tab cur-normal">
            <div id="normal-tab" class="normal-tab" ><%= PageValue.CurrentSystem.sitename%>账号登录</div>
            <div id="quick-tab" class="quick-tab" >手机验证登录</div>
            <div class="hilight-tab"></div>
        </nav>
        <div id="login-panel" class="panel" data-tab="normal">
            <div id="normal-panel" class="active-panel normal-panel">
                <form id="normal-login-form" autocomplete="off" method="post">
                <p>
                    <input id="username" class="common-text" type="text" placeholder="账户名/手机号/Email"
                        name="username" required="required"></p>
                <p>
                    <input id="password" class="common-text" type="password" placeholder="请输入您的密码" name="password"
                        required="required"></p>
                <p class="c-submit ">
                    <input type="submit" value="登录">
                </p>
                </form>
            </div>
            <div id="quick-panel" class="quick-panel">
                <form id="quick-login-form" autocomplete="off" method="post">
                <div class="number">
                    <input type="text" id="login-mobile" name="mobile" placeholder="请输入手机号" title="请输入正确的手机号"
                        pattern="[0-9]*" required="required" class="common-text">
                    <span id="smsCode" >发送验证码</span>
                </div>
                <div class="code">
                    <input class="common-text" id="code" name="code" type="text" pattern="[0-9]*" required="required"
                        placeholder="请输入手机短信中的验证码">
                </div>
                <p class="c-submit ">
                    <input type="submit" value="登录">
                </p>
                </form>
            </div>
        </div>
    </div>
</div>
<p class="sub-action">
    <a href="<%=GetUrl("手机版注册", "account_signup.aspx")%>">注册</a> <a href="<%=GetUrl("手机版找回密码", "account_repass.aspx")%>">
        找回密码</a></p>
<div id="mask" class="mask" style="display: none">
</div>
<div id="pop-wrapper" class="pop-wrapper" style="display: none;">
    <div id="content" class="content">
        <header>
            <h5>请输入验证码</h5>
        </header>
        <div class="main">
            <div>
                <input id="mobile-captcha" class="common-text mobile-captcha" type="text" autocomplete="off"
                    placeholder="请输入验证码" name="captcha">
                <div class="refresh">
                    <img id="captcha-box" src="" alt="加载中……" height="42" width="70">
                    <span>换一张</span>
                </div>
            </div>
            <div class="post-captcha">
                <a id="post-captcha" href="javascript:void(0);">确认</a></div>
        </div>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<script>
    /*
    * 切换tab
    */
    $(function () {
        var $loginTab = $('.login-tab'),
            $loginPanel = $('#login-panel');

        $loginTab.on(MT.util.tapOrClick, 'div', function (e) {
            var CUR_NORMAL = 'cur-normal',
                CUR_QUICK = 'cur-quick';

            if ((e.target.id.indexOf('quick') < 0) && !(~$loginTab.attr('class').indexOf('cur-quick'))) {
                $loginTab.removeClass(CUR_NORMAL).addClass(CUR_QUICK);
                $loginPanel.attr('data-tab', 'quick');
            } else if ((e.target.id.indexOf('normal') < 0) && !(~$loginTab.attr('class').indexOf('cur-normal'))) {
                $loginTab.removeClass(CUR_QUICK).addClass(CUR_NORMAL);
                $loginPanel.attr('data-tab', 'normal');
            }
        });
    });
    /*
    * 账号登录和快捷登录
    */
    $(function () {
        var $normalLoginForm = $('#normal-login-form'),
            $quickLoginForm = $('#quick-login-form'),
            $errMsg = $('#errMsg').length > 0 ? $('#errMsg') : $('.errMsg'),
            errMsgFadeIn = MT.util.errMsgFadeIn,
            uuid, hasPoped = false, reqCaptchaTimes = 0, timeId;

        var tapOrClick = MT.util.tapOrClick;

        $normalLoginForm.submit(function (e) {
            var params = $normalLoginForm.serialize();
            if (uuid) {
                params += '&uuid' + $.param({ uuid: uuid });
            }
            reqLogin(params);

            return false;
        });

        $('#smsCode').on(tapOrClick, function (e) {
            var ms = $('#login-mobile').val().toString().trim();
            if (ms == "") {
                alert("手机号不能为空");
                return false;
            }
            var $this = $(this),
                mobile = $('#login-mobile').val(),

                REGEX = /\d{11}/,
                waiting = $this.attr('class');

            if (waiting && waiting.indexOf('wait') > -1)
                return false;
            resetSMSBtn($this);
            $.ajax({
                type: "POST",
                url: "<%=PageValue.WebRoot %>ajax/sms.aspx?action=mobilecode&method=login",
                data: { "mobile": mobile },
                success: function (msg) {
                    if (msg == "1") {
                        alert("短信已发送至:" + mobile);
                        countSecond();
                    } else if (msg == "0") {
                        alert("短信已发送失败！");
                        return false;
                    }
                    else if (msg == "2") {
                        alert("该手机已发送最高次数5次，请明天再来!");
                        resetSMSBtn($this, true);
                        return false;
                    }
                    else if (msg == "3") {
                        alert("手机格式不正确!");
                        resetSMSBtn($this, true);
                        return false;
                    }
                    else if (msg == "4") {
                        alert("您的手机号还未注册,请先注册!");
                        location.href = '<%=GetUrl("手机版注册", "account_signup.aspx")%>';
                    }
                }
            });

        });
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
        $quickLoginForm.submit(function (e) {
            e.preventDefault();

            var params = $quickLoginForm.serialize();
            var loginBtn = $quickLoginForm.find('input[type=submit]').val('登录中...');
            $.ajax({
                url: '<%=GetUrl("手机版登录", "account_login.aspx") %>',
                type: 'POST',
                data: params,
                success: function (msg) {
                    loginBtn.val('登录');
                    if (msg == "2") {
                        location.href = '<%=GetUrl("手机版首页", "index.aspx") %>';
                    }
                    if (msg == "0" || msg == "1" || msg == "4") {
                        location.href = '<%=GetUrl("手机版登录", "account_login.aspx") %>';
                    }
                },
                error: function () {
                    loginBtn.val('登录');
                    errMsgFadeIn.call($errMsg, 'text', '抱歉，请求失败！');
                }
            });
        });

        function reqLogin(params) {
            var loginBtn = $normalLoginForm.find('input[type=submit]').val('登录中...');

            $.ajax({
                url: '<%=GetUrl("手机版登录", "account_login.aspx") %>',
                type: 'POST',
                data: params,
                success: function (msg) {
                    if (msg == "2") {
                        location.href = '<%=GetUrl("手机版首页", "index.aspx") %>';
                    }
                    if (msg == "0" || msg == "1" || msg == "3") {
                        location.href = '<%=GetUrl("手机版登录", "account_login.aspx") %>';
                    }
                },
                error: function () {
                    loginBtn.val('登录');
                    errMsgFadeIn.call($errMsg, 'text', '抱歉，请求失败！');
                }
            });
        }

        function popCaptcha(res) {
            var $pop = $('#pop-wrapper'),
                $img = $('#captcha-box'),
                $content = $pop.find('#pop-content'),
                $mask = $('#mask'),
                imgComplete = false, timeSpan = 1000,
                connection = navigator.connection || { type: '0' };

            isPoping = true;

            $img.attr('src', res.url).on('load', function () {
                if (!this.complete) {
                    $img.attr('src', res.url);
                } else {
                    imgComplete = true;
                }
            }).on('error', function () {
                if (reqCaptchaTimes < 3) {
                    $img.attr('src', res.url);
                    ++reqCaptchaTimes;
                }
            });

            $('#mobile-captcha').val('');

            switch (connection.type) {
                case connection.CELL_3G:
                case connection.WIFI:
                    timeSpan = 1500;
                    break;
                case connection.ETHERNET:
                    timeSpan = 1000;
                    break;
                default:
                    timeSpan = 3000;
            }
            setTimeout(function () {
                if (!imgComplete) {
                    $img.trigger('error');
                }
            }, timeSpan);

            if (!hasPoped) {
                $pop.find('.refresh').on(tapOrClick, function (e) {
                    e.preventDefault();

                    $img.attr('src', res.url);
                });

                $('#post-captcha').on(tapOrClick, function (e) {
                    e.preventDefault();

                    var captcha = $('#mobile-captcha').val();

                    if (captcha) {
                        removePop();
                        reqLogin($normalLoginForm.serialize() + '&' + $.param({ uuid: uuid, captcha: captcha }));
                    }
                });

                $pop.on(tapOrClick, function (e) {
                    e.preventDefault();

                    if (e.target.id === 'pop-wrapper') {
                        removePop();
                    } else {
                        return false;
                    }
                });

                window.addEventListener('resize', function (e) {
                    if (isPoping) {
                        resetPos($pop, $mask);
                    }
                });
            }

            resetPos($pop, $mask);
        }

        function resetPos($pop, $mask) {
            var docHeight = $(window).height(),
                maskHeight = document.height > docHeight ? document.height : docHeight;

            $normalLoginForm.find('input[type=password]').prop('disabled', 'disabled');

            if (!hasPoped) {
                $mask.css({ opacity: 0, display: '-webkit-box', height: maskHeight })
                        .animate({ opacity: 0.8 }, 150, 'ease-in');
                $pop.css({ opacity: 0, display: '-webkit-box', zIndex: 998, height: docHeight })
                        .animate({ opacity: 1 }, 150, 'ease-in');
            } else {
                $mask.css({ opacity: 0, display: '-webkit-box' })
                        .animate({ opacity: 0.8 }, 150, 'ease-in');
                $pop.css({ opacity: 0, display: '-webkit-box', zIndex: 998 })
                        .animate({ opacity: 1 }, 150, 'ease-in');
            }
        }

        function removePop() {
            var $pop = $('#pop-wrapper');

            if ($pop.length || isPoping) {
                isPoping = false;
                $pop.fadeOut();
                $('#mask').fadeOut();
                $normalLoginForm.find('input[type=password]').prop('disabled', '');
            }
        }

        function resetSMSBtn($btn, immediately) {
            $btn.addClass('wait-a-minute');
            var MINUTE = 60;

            if (immediately && timeId) {
                clearInterval(timeId);
                $btn.removeClass('wait-a-minute').text('发送验证码');
                return false;
            }

            timeId = setInterval(function () {
                if (MINUTE) {
                    $btn.text((MINUTE > 10 ? MINUTE : (' ' + MINUTE)) + '秒后重发');
                    MINUTE--;
                } else {
                    clearInterval(timeId);
                    $btn.removeClass('wait-a-minute').text('发送验证码');
                }
            }, 1000);
        }
    });
</script>
<%LoadUserControl("_htmlfooter.ascx", null); %>