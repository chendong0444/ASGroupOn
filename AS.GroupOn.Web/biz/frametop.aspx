<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>

<script runat="server">
    protected int id = 0;
    protected AS.GroupOn.Domain.IPartner partner = null;
    protected AS.GroupOn.Domain.ISystem system = null;
    protected int viewcount = 0;//需要商家同意退款的数量
    protected NameValueCollection value = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        value = AS.Common.Utils.WebUtils.GetSystem();
        string key = AS.Common.Utils.FileUtils.GetKey();
        id = AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("partner", key), 0);
        AS.GroupOn.DataAccess.Filters.RefundsFilter refilter = new AS.GroupOn.DataAccess.Filters.RefundsFilter();
        refilter.State=1;
        refilter.PartnerID=id;
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
            partner = session.Partners.GetByID(id);
            viewcount = session.Refunds.GetCount(refilter);
        }
    }
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>商户管理后台头部</title>
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
        function tiaozhuan3(name, url, num) {
            parent.frames[1].location.href = "frameleft.aspx?type=" + name;
            if (num == 15) {//退款审核
                parent.frames[3].location.href = url + "?refund=1";
            }
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
                    <li id="dh1" class="dangqian"><a href="javascript:tiaozhuan2('shouye','Index_Index.aspx','1')">首页</a></li>
                    <li id="dh4"><a href="javascript:tiaozhuan2('chanpin','ProductList.aspx','4')">产品</a></li>
                    <li id="dh2"><a href="javascript:tiaozhuan2('project','partner_index.aspx','2')">项目</a></li>
                    <li id="dh3"><a href="javascript:tiaozhuan2('orders','OrderList.aspx','3')">订单</a></li>
                    <li id="dh9"><a href="javascript:tiaozhuan2('kuaidi','OrderList_WeiXuanZe.aspx','9')">快递</a></li>
                    <li id="dh5"><a href="javascript:tiaozhuan2('youhuiquan','coupon.aspx','5')">优惠券</a></li>
                    <li id="dh7"><a href="javascript:tiaozhuan2('jiesuan','SHJieSuan.aspx','7')">结算</a></li>
                    <li id="dh6"><a href="javascript:tiaozhuan2('shanghu','Review.aspx','6')">商户</a></li>
                    <li id="dh8"><a href="javascript:tiaozhuan2('tongji','Tongji_Week_biz.aspx','8')">统计</a></li>
                        <%  
                            if (value["Shanghufz"]=="1")
                            {%>
                                <li id="dh10"><a href="javascript:tiaozhuan2('fenzhan','BranchList.aspx','10')">分店</a></li>
                            <%}
                             %>
                    
                </ul>
                <div class="vcoupon">
                  
                    <div class="change"> 
                        
                       <%-- <a href="javascript:tiaozhuan1('shouye','PartnerInfo.aspx','12')">
                            商家信息</a>&nbsp;|&nbsp;<a href="javascript:tiaozhuan1('shouye','ChangePWD.aspx','12')">修改密码</a>&nbsp;|&nbsp;退款审核<a href="javascript:tiaozhuan3('shouye','Index_Index.aspx','15')"><font
                            color="red">(<%=viewcount%>)</font></a> &nbsp;|&nbsp;--%>
                            [<%--<a id="biz-verify-coupon-id" href="javascript:tiaozhuan('shouye','Index_Index.aspx','12')"><%=system.couponname %>验证消费</a>&nbsp;|&nbsp;--%>
                            <a href="loginout.aspx" target="_top">退出</a>]
                    </div>
                    <div class="username">商家后台：<%=partner.Title %></div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
