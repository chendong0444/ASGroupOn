<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="tenpay" %>
<script runat="server">
    IOrder order = null;
    ISystem system = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        log();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
        }
        //密钥
        string key = "";
        if (system != null)
        {
            key = system.tenpaysec.Trim();
        }
        //创建ResponseHandler实例
        ResponseHandler resHandler = new ResponseHandler(Context);
        resHandler.setKey(key);
        //判断签名
        if (resHandler.isTenpaySign())
        {
            ///通知id
            string notify_id = resHandler.getParameter("notify_id");
            //通过通知ID查询，确保通知来至财付通
            //创建查询请求
            RequestHandler queryReq = new RequestHandler(Context);
            queryReq.init();
            queryReq.setKey(key);
            queryReq.setGateUrl("https://gw.tenpay.com/gateway/simpleverifynotifyid.xml");
            queryReq.setParameter("partner", system.tenpaymid);
            queryReq.setParameter("notify_id", notify_id);
            //通信对象
            TenpayHttpClient httpClient = new TenpayHttpClient();
            httpClient.setTimeOut(5);
            //设置请求内容
            httpClient.setReqContent(queryReq.getRequestURL());
            //后台调用
            if (httpClient.call())
            {
                //设置结果参数
                ClientResponseHandler queryRes = new ClientResponseHandler();
                queryRes.setContent(httpClient.getResContent());
                queryRes.setKey(key);
                //判断签名及结果
                //只有签名正确,retcode为0，trade_state为0才是支付成功
                if (queryRes.isTenpaySign())
                {
                    string money = Helper.GetString(resHandler.getParameter("attach"),String.Empty);  
                    //取结果参数做业务处理
                    string out_trade_no = resHandler.getParameter("out_trade_no");
                    //财付通订单号
                    string transaction_id = resHandler.getParameter("transaction_id");
                    //金额,以分为单位
                    string total_fee = resHandler.getParameter("total_fee");
                    //如果有使用折扣券，discount有值，total_fee+discount=原请求的total_fee
                    string discount = resHandler.getParameter("discount");
                    //支付结果
                    string trade_state = resHandler.getParameter("trade_state");
                    //交易模式，1即时到帐 2中介担保
                    string trade_mode = resHandler.getParameter("trade_mode");
                    WebUtils.LogWrite("财付通支付日志", "=======================开始异步========================");
                    WebUtils.LogWrite("财付通支付日志", "money:" + money);
                    WebUtils.LogWrite("财付通支付日志", "out_trade_no:" + out_trade_no);
                    WebUtils.LogWrite("财付通支付日志", "transaction_id:" + transaction_id);
                    WebUtils.LogWrite("财付通支付日志", "trade_state:" + trade_state);
                    WebUtils.LogWrite("财付通支付日志", "trade_mode:" + trade_mode);
                    WebUtils.LogWrite("财付通支付日志", "money:" + money);
                    WebUtils.LogWrite("财付通支付日志", "========================结束异步=======================");

                    if ("0".Equals(trade_state))
                    {
                        if ("1".Equals(trade_mode))
                        {       //即时到账 
                            if ("0".Equals(trade_state))
                            {
                                if (total_fee != String.Empty)
                                {
                                    OrderMethod.Updateorder(out_trade_no, (Convert.ToDecimal(total_fee) / 100).ToString(), "tenpay", null);//修改订单状态  
                                    Response.Write("success");
                                }
                            }
                            else
                            {
                                Response.Write("即时到账支付失败");
                            }
                        }
                        else if ("2".Equals(trade_mode))
                        {
                            if (money != String.Empty)
                            {
                                OrderMethod.Updateorder(out_trade_no, (Convert.ToDecimal(money) / 100).ToString(), "tenpay", null);//修改订单状态
                                Response.Write("success");
                            }
                            else
                            {
                                Response.Write("担保交易支付失败");
                            }
                        }
                    }
                    else
                    {   //错误时，返回结果可能没有签名，写日志trade_state、retcode、retmsg看失败详情。
                        //通知财付通处理失败，需要重新通知
                        Response.Write("查询验证签名失败或id验证失败");
                        Response.Write("retcode:" + queryRes.getParameter("retcode"));
                         
                    }
                }
                else
                {
                    WebUtils.LogWrite("财付通支付日志", "通知ID查询签名验证失败");
                    Response.Write("通知ID查询签名验证失败");
                }
            }
            else
            {
                //通知财付通处理失败，需要重新通知
                WebUtils.LogWrite("财付通支付日志", "后台调用通信失败");
                Response.Write("后台调用通信失败");
                //写错误日志
                Response.Write("call err:" + httpClient.getErrInfo() + "<br>" + httpClient.getResponseCode() + "<br>");

            }
        }
        else
        {
            WebUtils.LogWrite("财付通支付日志", "签名验证失败");
            Response.Write("签名验证失败");
        }
        Response.End();
    }

    private void log()
    {
        try
        {
            #region 记录支付通知结果
            string drec = Server.MapPath(WebRoot + "tenpaylog");
            object locker = new object();
            object filelocker = new object();
            lock (locker)
            {
                if (!System.IO.Directory.Exists(drec))
                    System.IO.Directory.CreateDirectory(drec);
            }
            string filepath = Server.MapPath(WebRoot + "tenpaylog/" + DateTime.Now.ToString("yyyyMMdd") + ".config");
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            for (int i = 0; i < Request.QueryString.Count; i++)
            {
                sb.Append("&" + Request.QueryString.Keys[i] + "=" + Request.QueryString[i]);

            }

            lock (filelocker)
            {
                System.IO.File.AppendAllText(filepath, sb.ToString());
            }
            #endregion
        }
        catch { }
    }
</script>