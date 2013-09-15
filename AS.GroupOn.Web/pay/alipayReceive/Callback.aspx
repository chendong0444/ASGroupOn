<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AlipayClass.alipayReceive" %>

<script runat="server">
    /// <summary>
    /// 功能：快捷登录物流地址查询接口接入页
    /// 版本：3.2
    /// 日期：2011-03-11
    /// 说明：
    /// 以下代码只是为了方便商户测试而提供的样例代码，商户可以根据自己网站的需要，按照技术文档编写,并非一定要使用该代码。
    /// 该代码仅供学习和研究支付宝接口使用，只是提供一个参考。
    /// 
    /// /////////////////注意///////////////////////////////////////////////////////////////
    /// 如果您在接口集成过程中遇到问题，可以按照下面的途径来解决
    /// 1、商户服务中心（https://b.alipay.com/support/helperApply.htm?action=consultationApply），提交申请集成协助，我们会有专业的技术工程师主动联系您协助解决
    /// 2、商户帮助中心（http://help.alipay.com/support/232511-16307/0-16307.htm?sh=Y&info_type=9）
    /// 3、支付宝论坛（http://club.alipay.com/read-htm-tid-8681712.html）
    /// 
    /// 如果不想使用扩展功能请把扩展功能参数赋空值。
    /// </summary>
    
    ISystem systemmodel = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {
            callbackUrl();
        }
    }
    /// <summary>
    /// 发起请求
    /// </summary>
    protected void callbackUrl()
    {
        //////////////////////////////////////////请求参数////////////////////////////////////////////////////

        //必填参数//

        //授权令牌，该参数的值由快捷登录接口(alipay.auth.authorize)的页面跳转同步通知参数中获取
        string token = CookieUtils.GetCookieValue("alipay_token");
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            systemmodel = session.System.GetByID(1);

        }
        Config.Partner = systemmodel.alipaymid;
        Config.Key = systemmodel.alipaysec;
        Config.Return_url = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "pay/alipayReceive/return_url.aspx";
        //注意：
        //token的有效时间为30分钟，过期后需重新执行快捷登录接口(alipay.auth.authorize)获得新的token

        /////////////////////////////////////////////////////////////////////////////////////////////////////

        //构造快捷登录接口表单提交HTML数据，无需修改
        Service ali = new Service();
        string sHtmlText = ali.User_logistics_address_queryURL(token);
        Response.Redirect(sHtmlText);

    }
</script>
