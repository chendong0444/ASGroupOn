<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerBranchPage" %>

<script runat="server">
    protected AS.GroupOn.Domain.ISystem system = null;
    protected int id = 0;
    protected AS.GroupOn.Domain.IBranch branch = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        string key = AS.Common.Utils.FileUtils.GetKey();
        id = AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("pbranch", key), 0);
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
            branch = session.Branch.GetByID(id);
        }
    }
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>商户分站管理后台头部</title>
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
                    <li id="dh1" class="dangqian"><a href="javascript:tiaozhuan2('shouye','Index_Index.aspx','1')">
                        首页</a></li>
                    <li id="dh2"><a href="javascript:tiaozhuan2('project','project.aspx','2')">项目</a></li>
                    <li id="dh3"><a href="javascript:tiaozhuan2('orders','OrderList.aspx','3')">订单</a></li>
                    <li id="dh5"><a href="javascript:tiaozhuan2('youhuiquan','coupon.aspx','5')">优惠券</a></li>
                    <li id="dh9"><a href="javascript:tiaozhuan2('kuaidi','orderList_WeiXuanZe.aspx','9')">
                        快递</a></li>
                    <li id="dh10"><a href="javascript:tiaozhuan2('fenzhan','subbranchupdate.aspx','10')">
                        分站</a></li>
                </ul>
                <div class="vcoupon">
                    <div class="change">
                     
                      <%-- <a href="javascript:tiaozhuan1('shouye','PbranchInfo.aspx','12')">商家分站信息</a>&nbsp;|&nbsp;<a
                            href="javascript:tiaozhuan1('shouye','ChangePWD.aspx','12')">修改密码</a>&nbsp;|&nbsp;--%>[<a
                                id="A1" href="javascript:tiaozhuan('shouye','Index_Index.aspx','12')"><%=system.couponname %>验证消费</a>&nbsp;|&nbsp;<a href="loginout.aspx" target="_top">退出</a>]
                    </div>
                    <div class="username">商家分站后台: <%=branch.username %></div>
                </div>
            </div>
        </div>
    </div>
</body>
</html> 