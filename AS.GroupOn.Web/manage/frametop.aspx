<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<script runat="server">
    protected int id = 0;
    protected AS.GroupOn.Domain.ISystem system = null;
    protected AS.GroupOn.Domain.IUser user = null;
    protected NameValueCollection configs = new NameValueCollection();
    protected bool IsTeamRole = false;
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        string key = AS.Common.Utils.FileUtils.GetKey();
        id = AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0);
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
            user = session.Users.GetByID(id);
        }
        if (user == null)
        {
            Response.Write("<script>window.parent.location.href='" + this.Page.ResolveUrl(AS.GroupOn.Controls.PageValue.WebRoot + "login.aspx") + "'</" + "script>");
                Response.End();
        }
        if (user.IsManBranch== "Y")
        {
            Response.Write("<script>alert('您不具有进入该页面的权限！');window.parent.location.href='" + AS.GroupOn.Controls.PageValue.WebRoot + "login.aspx" + "'</" + "script>");
            Response.End();
        }

        //判断用户是否商户
        foreach (IRole role in user.Role)
        {
            if (role.code == "team")
            {
                IsTeamRole = true;
                break;
            }
        }
    }
    
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>管理后台头部</title>
    <link href="css/index.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        var webroot = "/";
    </script>
    <script src="/upfile/js/index.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        function tiaozhuan(name, url, num) {
            parent.frames[1].location.href = "frameleft.aspx?type=" + name;
            if (num == 12) {//验证消费
                parent.frames[3].location.href = url + "?opera=1";
            }
          
            for (var i = 1; i <= 11; i++) {
                if (num == i) {
                    $("#dh" + i).attr('class', 'dangqian');
                } else {
                    $("#dh" + i).attr('class', '');

                }
            }
        }
        function tiaozhuan1(name, url, num) {
            parent.frames[1].location.href = "frameleft.aspx?type=" + name;
            if (num == 12) {
                parent.frames[3].location.href = url + "?id=<%=id %>";
            }
            for (var i = 1; i <= 11; i++) {
                if (num == i) {
                    $("#dh" + i).attr('class', 'dangqian');
                } else {
                    $("#dh" + i).attr('class', '');

                }
            }
        }
        function tiaozhuan2(name, url, num) {
            parent.frames[1].location.href = "frameleft.aspx?type=" + name;

            parent.frames[3].location.href = url;

            for (var i = 1; i <= 11; i++) {
                if (num == i) {
                    $("#dh" + i).attr('class', 'dangqian');
                } else {
                    $("#dh" + i).attr('class', '');

                }
            }
        }
    </script>
</head>
<body>
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="hdw">
        <div id="hd">
            <div class="menu" id="menu2">
                <ul>
                        <li id="logo"><a target="_blank" class="link" href="/index.aspx"><img width="160" src="<%=ASSystemArr["headlogo"] %>"/></a></li>
                    <% if (IsTeamRole)
                       { %>
                        <li id="Li1"><a href="javascript:tiaozhuan2('project','Project_DangqianXiangmu.aspx','2')">
                            项目</a></li>
                       <%}
                       else
                       { %>
                        <li id="dh1" class="dangqian"><a href="javascript:tiaozhuan2('shouye','Index_Index.aspx','1')">
                            首页</a></li>
                        <li id="dh2"><a href="javascript:tiaozhuan2('project','Project_DangqianXiangmu.aspx','2')">
                            项目</a></li>
                        <li id="dh3"><a href="javascript:tiaozhuan2('orders','Dingdan_DangqiDingdan.aspx','3')">
                            订单</a></li>
                        <li id="dh4"><a href="javascript:tiaozhuan2('shouhou','Index-XiangmuDabian.aspx','4')">
                            售后</a></li>
                        <li id="dh5"><a href="javascript:tiaozhuan2('caiwu','CaiWu_Store.aspx','5')">财务</a></li>
                        <li id="dh6"><a href="javascript:tiaozhuan2('tongji','Tongji_ASdht_Order.aspx','6')">
                            统计</a></li>
                        <li id="dh7"><a href="javascript:tiaozhuan2('huiyuan','User.aspx','7')">会员</a></li>
                        <li id="dh11"><a href="javascript:tiaozhuan2('online','ShangHu.aspx','11')">商户</a></li>
                        <li id="dh8"><a href="javascript:tiaozhuan2('kuaidi','DingDan_WeiXuanZe.aspx','8')">
                            快递</a></li>
                        <li id="dh9"><a href="javascript:tiaozhuan2('yingxiao','Youhui_Weixiaofei.aspx','9')">
                            营销</a></li>
                        <li id="dh10"><a href="javascript:tiaozhuan2('wangzhan','SheZhi_Jiben.aspx','10')">配置</a></li>
                    <%} %>
                </ul>
                <div class="vcoupon">
                 
                    <div class="change"> 
                  
                       <%-- <a href="javascript:tiaozhuan1('shouye','PersonalInfo.aspx','12')">个人信息</a>&nbsp;|&nbsp;<a
                            href="javascript:tiaozhuan1('shouye','ChangePWD.aspx','12')">修改密码</a>&nbsp;|&nbsp;--%>[<a
                                id="biz-verify-coupon-id" href="javascript:tiaozhuan('shouye','Index_Index.aspx','12')"><%=system.couponname %>验证消费</a>&nbsp;|&nbsp;<a
                                    href="<%=AS.GroupOn.Controls.PageValue.WebRoot %>loginout.aspx" target="_top">退出</a>]
                    </div>
                    <div class="username">管理员：<%=user.Username %></div>
                </div>
            </div>
            
        </div>
    </div>
</body>
</html>
