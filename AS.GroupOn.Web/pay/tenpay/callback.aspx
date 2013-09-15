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

    protected override void OnLoad(EventArgs e)
    {
        log();
        getResult();
    }

    protected void getResult()
    {
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
        //创建PayResponseHandler实例
        ResponseHandler resHandler = new ResponseHandler(Context);

        resHandler.setKey(key);

        //判断签名
        if (resHandler.isTenpaySign())
        {
            ///通知id
            string notify_id = resHandler.getParameter("notify_id");
            WebUtils.LogWrite("财付通支付日志", "notify_id:" + notify_id);
            //商户订单号
            string out_trade_no = resHandler.getParameter("out_trade_no");
            WebUtils.LogWrite("财付通支付日志", "out_trade_no:" + out_trade_no);
            //财付通订单号
            string transaction_id = resHandler.getParameter("transaction_id");
            //金额,以分为单位
            string total_fee = resHandler.getParameter("total_fee");
            WebUtils.LogWrite("财付通支付日志", "total_fee:" + total_fee);
            //如果有使用折扣券，discount有值，total_fee+discount=原请求的total_fee
            string discount = resHandler.getParameter("discount");
            //支付结果
            string trade_state = resHandler.getParameter("trade_state");
            //交易模式，1即时到账，2中介担保
            string trade_mode = resHandler.getParameter("trade_mode");
            WebUtils.LogWrite("财付通支付日志", "trade_mode:" + trade_mode);
            ////商户号
            //string bargainor_id = resHandler.getParameter("partner");
            //////交易单号
            ////string transaction_id = resHandler.getParameter("transaction_id");
            ////金额金额,以分为单位
            //string total_fee = resHandler.getParameter("total_fee");
            ////支付结果
            //string pay_result = resHandler.getParameter("trade_state");

            ////2.28新添加
            ////交易模式，1即时到账，2中介担保
            //string trade_mode = resHandler.getParameter("trade_mode");
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

            if ("1".Equals(trade_mode))
            {       //即时到账 
                if ("0".Equals(trade_state))
                {
                    //------------------------------
                    //处理业务开始
                    //------------------------------ 

                    if (total_fee != "")
                    {
                        OrderMethod.Updateorder(out_trade_no, (Convert.ToDecimal(total_fee) / 100).ToString(), "tenpay", null);//修改订单状态

                    }

                    //------------------------------
                    //处理业务完毕
                    //------------------------------

                    //调用doShow, 打印meta值跟js代码,告诉财付通处理成功,并在用户浏览器显示$show页面.
                    resHandler.doShow(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + GetUrl("支付通知", "order_success.aspx?id=" + out_trade_no));
                }
                else
                {
                    //当做不成功处理
                    Response.Write("即时到账支付失败");
                }
            }
            else if ("2".Equals(trade_mode))
            {    //中介担保
                if ("0".Equals(trade_state))
                {
                    //------------------------------
                    //处理业务开始
                    //------------------------------ 
                    OrderFilter orderfilter = new OrderFilter();
                    orderfilter.Pay_id = out_trade_no;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        order = session.Orders.Get(orderfilter);
                    }

                    if (order != null)
                    {
                        string totalPrice = OrderMethod.GetPayPrice(out_trade_no).ToString();
                        OrderMethod.Updateorder(out_trade_no, totalPrice, "tenpay", null);//修改订单状态
                    }
                    else
                    {
                        Response.Write("订单更新失败~订单为:" + out_trade_no + "\r\n");
                    }



                    //------------------------------
                    //处理业务完毕
                    //------------------------------

                    //调用doShow, 打印meta值跟js代码,告诉财付通处理成功,并在用户浏览器显示$show页面.
                    resHandler.doShow(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + GetUrl("支付通知", "order_success.aspx?id=" + out_trade_no));

                }
                else
                {
                    Response.Write("trade_state=" + trade_state);
                }
            }

        }
        else
        {
            Response.Write("认证签名失败");

        }



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
