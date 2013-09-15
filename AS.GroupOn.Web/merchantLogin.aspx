<%@ Page Language="C#" AutoEventWireup="true" EnableViewState="false"  Inherits="AS.GroupOn.Controls.FrontPage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.Common.Utils" %>

<script runat="server">
    protected string type = string.Empty;
    protected string strUser = "";
    protected string strPwd = "";
    protected string checkcode = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        type = "merchant";// Helper.GetString(Request["type"], String.Empty);
        Form.Action = "/merchantLogin.aspx?type=" + type;// GetUrl("后台管理", type != String.Empty ? "merchantLogin.aspx?type=" + type : "merchantLogin.aspx");
        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["username"] != null && Request.Form["password"] != null)
                strUser = Helper.GetString(Request.Form["username"].ToString().Trim(), String.Empty);
            if (Request.Form["password"] != null && Request.Form["password"] != null)
                strPwd = Request.Form["password"].ToString().Trim();
            if (Request.Form["code"] != null && Request.Form["code"] != null)
                checkcode = Request.Form["code"].ToString().Trim();
            JavaScriptResult js = AS.UserEvent.Event.LoginAdminUser(strUser, strPwd, checkcode, type);
            js.Execute();
        }
       
    }
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta name="keywords" content="<%=PageValue.KeyWord %>" />
<meta name="description" content="<%=PageValue.Description %>" />
<%--<script type='text/javascript' src='<%=PageValue.TemplatePath %>js/index.js'></script>--%>
<script type='text/javascript' src='<%=PageValue.WebRoot %>upfile/js/index.js'></script>
<link rel="stylesheet" href="<%=PageValue.CssPath %>/css/index.css" type="text/css" media="screen" charset="utf-8" />
<title>登录<%=PageValue.CurrentSystem.abbreviation%>管理后台</title>
</head>

<body style="background:none;">
<form runat="server" class="validator">
<script type="text/javascript">
    $(document).ready(function (e) {
        $("#lgNav li").click(function () {
            $(this).addClass("now_select").siblings("li").removeClass("now_select");
        });
    });
    function checkvale() {
        if ($("#username").val() == "") {
            alert("请输入用户名！");
            return false;
        }
        if ($("#password").val() == "") {
            alert("请输入密码！");
            return false;
        }
        return true;
    }
</script>
<div id="login_bd">
	<div class="login_bd">
      <div class="login_hd">
        <div class="lg_logo">
        <a href="<%=PageValue.WebRoot%>index.aspx" class="link" target="_blank">
        	<img src="<%= PageValue.CurrentSystem.headlogo %>" width="264" height="58" /></a>
        </div>
        <div class="lgtit_mid">
        	<ul id="css">
            <li class="lg_lf <%if(type=="merchant" || type==""){%>now_select<%} %> "><a href="<%=GetUrl("后台管理","Login.aspx?type=merchant")%>">商家后台</a></li>
            	<li class="lg_lf <%if(type=="admin"){%>now_select<%} %>" ><%--<a href="<%=GetUrl("后台管理","Login.aspx?type=admin")%>">管理后台</a>--%></li>
            	<li class="lg_lf <%if(type=="sale"){%>now_select<%} %>"><%--<a href="<%=GetUrl("后台管理","Login.aspx?type=sale")%>">销售后台</a>--%></li>
            	<li  class="lg_lf <%if(type=="pbranch"){%>now_select<%} %>"><%--<a href="<%=GetUrl("后台管理","Login.aspx?type=pbranch")%>">分站后台</a>--%></li>
            </ul>
        </div>
        <div class="clear"></div>
      </div>
        <div class="clear"></div>
        <div class="lg_content">
        
        <!--管理员登录开始-->
                    <div id="adminLg" class="saleLg">
                <div><label class="lg_user">用户名：</label> <input class="lg_text" type="text" name="username" id="username"  /></div>
                <div><label class="lg_password">密&nbsp;&nbsp;码：</label> <input class="lg_text" type="password" name="password" id="password" /></div>
                   <%if (PageValue.CurrentSystemConfig["ischeckcode"] == null || PageValue.CurrentSystemConfig["ischeckcode"].ToString() != "0")
                     {%>
                <div class="identifying-code">
                <label class="lg_password">验证码：</label> 
                <input class="lg_yzm" id="code" name="code" runat="server"/> 
                <img height="20px" align="absmiddle" width="65px" id="chkimg" name="chkimg" src="<%=PageValue.WebRoot%>checkcode.aspx">
                                        <span style="cursor: pointer;" onClick="cimg()">看不清，换一张</span>
                                        <script>

                                            function cimg() {
                                                var changetime = new Date().getTime();
                                                document.getElementById('chkimg').src = webroot + 'checkcode.aspx?' + changetime;
                                            }
                                            cimg();

                                        </script>
                                        
                 </div>
                 <%}%>
                 <input type="hidden" name="type" value="<%=type %>" />
                <div class="btn_lg"><input type="submit" value="&nbsp;" name="loginuser" id="loginuser"  onclick="return checkvale();" /> </div>
            </div>
        </div>
    </div>
</div>

     </form>   
</body>
</html>
