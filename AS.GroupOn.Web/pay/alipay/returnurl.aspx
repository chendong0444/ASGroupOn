<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AlipayClass.alipay" %>
<%@ Import Namespace="System.Xml" %>

<script runat="server">
    protected string url = String.Empty;
    protected string trade_no = String.Empty;
    protected string order_no = String.Empty;
    protected string total_fee = String.Empty;
    protected string trade_status = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection configs = WebUtils.GetSystem();
        trade_no = Request.QueryString["trade_no"];
        order_no = Request.QueryString["out_trade_no"];
        total_fee = Request.QueryString["price"];
        trade_status = Request.QueryString["trade_status"];
        IOrder ordermodel = null;
        if (order_no != String.Empty && order_no != "")
        {
            string order = order_no.Replace("as", ",");
            string[] str = order.Split(',');
            if (str[2] == "0")
            {
                if (updateorder(order_no, total_fee, "alipay", null))
                {
                    WebUtils.LogWrite("访问日志", "returnurl充值成功" + trade_status);
                }
                else
                {
                    WebUtils.LogWrite("访问日志", "returnurl充值失败" + trade_status);
                }
            }
            else
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ordermodel = session.Orders.GetByID(Convert.ToInt32(str[2]));

                }
                if (ordermodel != null)
                {
                    if (ordermodel.State == "pay" && ordermodel.Service == "alipay")
                    {
                        if (configs["alipay_Manual_SecuredTransactions"] == "1" && Request["trade_status"] == "WAIT_BUYER_CONFIRM_GOODS")//等待买家收货
                        {
                            url = "https://lab.alipay.com/consume/queryTradeDetail.htm?tradeNo=" + trade_no;
                            return;
                        }
                        Response.Redirect(GetUrl("支付通知","order_success.aspx?id=" + order_no));
                        Response.End();
                    }
                    else
                    {
                        notnotify();
                        WebUtils.LogWrite("访问日志", "returnurls" + Request.Form["trade_status"]);
                    }
                }
            }
        }
        Response.Redirect(GetUrl("支付通知","order_success.aspx?id=" + order_no));
        Response.End();
    }
    private void notnotify()
    {
        System.Collections.Generic.SortedDictionary<string, string> sPara = GetRequestGet();
        NameValueCollection configs = WebUtils.GetSystem();
        ///////////////////////以下参数是需要设置的相关配置参数，设置后不会更改的//////////////////////
        string partner = ASSystem.alipaymid;
        string key = ASSystem.alipaysec;
        if (sPara.Count > 0)
        {

            Notify alinotify = new Notify();

            bool verifyResult = alinotify.Verify(sPara, Request.QueryString["notify_id"], Request.QueryString["sign"]);
            if (verifyResult)//验证成功
            {
                if (trade_status == "TRADE_FINISHED" || trade_status == "TRADE_SUCCESS" || trade_status == "WAIT_SELLER_SEND_GOODS" || trade_status == "WAIT_BUYER_CONFIRM_GOODS" || configs["alipay_Manual_SecuredTransactions"] == "0")
                {
                    if (updateorder(order_no, total_fee, "alipay", null))
                    {
                        WebUtils.LogWrite("访问日志", "returnurl" + trade_status + "订单更新成功");
                    }
                    else
                    {
                        WebUtils.LogWrite("访问日志", "returnurl订单更新失败");
                    }
                }
                if (configs["alipay_Manual_SecuredTransactions"] == "1" && trade_status == "WAIT_BUYER_CONFIRM_GOODS")//等待买家收货
                {
                    url = "https://lab.alipay.com/consume/queryTradeDetail.htm?tradeNo=" + trade_no;
                    return;
                }

                if (trade_status == "WAIT_SELLER_SEND_GOODS" && configs["autodeliver"] != "1")//等待卖家发货
                {
                    string transport_type = "EXPRESS";
                    System.Collections.Generic.SortedDictionary<string, string> sParaTemp = new System.Collections.Generic.SortedDictionary<string, string>();
                    sParaTemp.Add("trade_no", trade_no);
                    sParaTemp.Add("logistics_name", trade_no);
                    sParaTemp.Add("invoice_no", trade_no);
                    sParaTemp.Add("transport_type", transport_type);

                    Service ali = new Service();
                    XmlDocument xmlDoc = ali.Send_goods_confirm_by_platform(sParaTemp);
                    StringBuilder sbxml = new StringBuilder();
                    string nodeIs_success = xmlDoc.SelectSingleNode("/alipay/is_success").InnerText;
                    if (nodeIs_success != "T")//请求不成功的错误信息
                    {
                        WebUtils.LogWrite("访问日志", "发货失败" + trade_no);
                        //sbxml.Append("错误：" + xmlDoc.SelectSingleNode("/alipay/error").InnerText);
                        //Utils.WebSiteHelper.LogWrite("访问日志", "参数" + sbxml.ToString());
                    }
                    else//请求成功的支付返回宝处理结果信息
                    {
                        WebUtils.LogWrite("访问日志", "发货成功" + trade_no);
                        //sbxml.Append(xmlDoc.SelectSingleNode("/alipay/response").InnerText);
                        //Utils.WebSiteHelper.LogWrite("访问日志", "参数" + sbxml.ToString());
                    }
                }
                else
                {
                    string str = Request.Form["trade_status"] + "----" + configs["alipay_Manual_SecuredTransactions"];
                    WebUtils.LogWrite("访问日志", "担保方式接口出错" + str);
                }
                Response.Redirect(GetUrl("支付通知","order_success.aspx?id=" + order_no));
                Response.End();
            }
            else//验证失败
            {
                WebUtils.LogWrite("访问日志", "returnurl验证失败");
            }
        }
        else
        {
            WebUtils.LogWrite("访问日志", "无返回参数");
        }
        Response.Redirect(GetUrl("支付通知","order_success.aspx?id=" + order_no));
        Response.End();
    }
    /// <summary>
    /// 获取支付宝GET过来通知消息，并以“参数名=参数值”的形式组成数组
    /// </summary>
    /// <returns>request回来的信息组成的数组</returns>
    public System.Collections.Generic.SortedDictionary<string, string> GetRequestGet()
    {
        int i = 0;
        System.Collections.Generic.SortedDictionary<string, string> sArray = new System.Collections.Generic.SortedDictionary<string, string>();
        NameValueCollection coll;
        //Load Form variables into NameValueCollection variable.
        coll = Request.QueryString;

        // Get names of all forms into a string array.
        String[] requestItem = coll.AllKeys;

        for (i = 0; i < requestItem.Length; i++)
        {
            sArray.Add(requestItem[i], Request.QueryString[requestItem[i]]);
        }

        return sArray;
    }
    private bool updateorder(string order_no, string total_fee, string service, DateTime? pay_time)
    {
        bool ok = false;
        if (order_no.Length > 0)
        {
            OrderMethod.Updateorder(order_no, total_fee, service, pay_time);
            ok = true;
        }
        return ok;
    }
    private void log(ArrayList sArrary, string result)
    {
        #region 记录支付通知结果
        try
        {
            string drec = Server.MapPath(WebRoot + "alipaylog");
            object locker = new object();
            object filelocker = new object();
            lock (locker)
            {
                if (!System.IO.Directory.Exists(drec))
                    System.IO.Directory.CreateDirectory(drec);
            }
            string filepath = Server.MapPath(WebRoot + "alipaylog/" + DateTime.Now.ToString("yyyyMMdd") + ".config");
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            for (int i = 0; i < sArrary.Count; i++)
            {
                sb.Append("&" + sArrary[i]);

            }

            lock (filelocker)
            {
                System.IO.File.AppendAllText(filepath, sb.ToString() + result);
            }
        }
        catch { }
        #endregion
    }
</script>
<%LoadUserControl(PageValue.TemplatePath+"_htmlheader.ascx", null); %>
<%LoadUserControl(PageValue.TemplatePath + "_header.ascx", null); %>
<div id="bdw" class="bdw">
<div id="bd" class="cf">
<div id="content">
    <div id="order-pay-return" class="box">
        
        <div class="box-content">

     <div class="success"><h2>提示信息！</h2> </div>
            <div class="sect">
                <p>
                支付还没有完成，请您先确认收货，之后系统便会自动完成本次交易！<br /> 2  秒后自动跳转到相关页面。
   点击<a href="<%=url %>">此处</a>手动跳转
                </p>
            </div>
		</div>
	</div>
</div>
<div id="side">
</div>
</div> 
</div> 
<script>
    function gourl() {
        location.href = '<%=url %>';
        }
        setTimeout("gourl()", 2000);
</script>
<%LoadUserControl(PageValue.TemplatePath + "_footer.ascx", null); %>
<%LoadUserControl(PageValue.TemplatePath + "_htmlfooter.ascx", null); %>
