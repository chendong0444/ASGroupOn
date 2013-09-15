<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AlipayClass" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {

        NameValueCollection configs = WebUtils.GetSystem();
        ArrayList sArrary = GetRequestPost();
        ///////////////////////以下参数是需要设置的相关配置参数，设置后不会更改的//////////////////////
        string partner = ASSystem.alipaymid;                //合作身份者ID
        string key = ASSystem.alipaysec;    //安全检验码
        string input_charset = "utf-8";                     //字符编码格式 目前支持 gb2312 或 utf-8
        string sign_type = "MD5";                           //加密方式 不需修改
        string transport = "https";                         //访问模式,根据自己的服务器是否支持ssl访问，若支持请选择https；若不支持请选择http
        //////////////////////////////////////////////////////////////////////////////////////////////
        if (sArrary.Count > 0)//判断是否有带返回参数
        {
            AlipayNotify aliNotify = new AlipayNotify(sArrary, Request.Form["notify_id"], partner, key, input_charset, sign_type, transport);
            string responseTxt = aliNotify.ResponseTxt; //获取远程服务器ATN结果，验证是否是支付宝服务器发来的请求
            string sign = Request.Form["sign"];         //获取支付宝反馈回来的sign结果
            string mysign = aliNotify.Mysign;           //获取通知返回后计算后（验证）的加密结果

            //写日志记录（若要调试，请取消下面两行注释）
            //string sWord = "responseTxt=" + responseTxt + "\n notify_url_log:sign=" + Request.Form["sign"] + "&mysign=" + mysign + "\n notify回来的参数：" + AlipayFunction.Create_linkstring(sArrary);
            //AlipayFunction.log_result(Server.MapPath("log/" + DateTime.Now.ToString().Replace(":", "")) + ".txt", sWord);

            //判断responsetTxt是否为ture，生成的签名结果mysign与获得的签名结果sign是否一致
            //responsetTxt的结果不是true，与服务器设置问题、合作身份者ID、notify_id一分钟失效有关
            //mysign与sign不等，与安全校验码、请求时的参数格式（如：带自定义参数等）、编码格式有关
            try
            {
                if (sign == mysign)//验证成功  //总是提示无法连接到远程服务器,所以注释掉responseTxt == "true" &&
                {
                    //获取支付宝的通知返回参数
                    string trade_no = Request.Form["trade_no"];         //支付宝交易号
                    string order_no = Request.Form["out_trade_no"];     //获取订单号
                    string total_fee = Request.Form["total_fee"];       //获取总金额
                    string subject = Request.Form["subject"];           //商品名称、订单名称
                    string body = Request.Form["body"];                 //商品描述、订单备注、描述
                    string buyer_email = Request.Form["buyer_email"];   //买家支付宝账号
                    string trade_status = Request.Form["trade_status"]; //交易状态
                    //int sOld_trade_status = 1;							//获取商户数据库中查询得到该笔交易当前的交易状态

                    //假设：
                    //sOld_trade_status="0"	表示订单未处理；
                    //sOld_trade_status="1"	表示交易成功（TRADE_FINISHED/TRADE_SUCCESS）

                    if (Request.Form["trade_status"] == "TRADE_FINISHED" || Request.Form["trade_status"] == "TRADE_SUCCESS" || Request.Form["trade_status"] == "WAIT_SELLER_SEND_GOODS" || Request.Form["trade_status"] == "WAIT_BUYER_CONFIRM_GOODS")
                    {
                        if ((Request.Form["trade_status"] == "TRADE_FINISHED" || Request.Form["trade_status"] == "TRADE_SUCCESS") || configs["alipay_Manual_SecuredTransactions"] == "0")
                        {
                            if (updateorder(order_no, total_fee, "alipay", null))
                            {
                                Response.Write("success");
                                log(sArrary, "\r\n通知成功,responseTxt=" + responseTxt + ",sign=" + sign + ",mysign=" + mysign + "\r\n");
                            }

                        }

                        if (Request.Form["trade_status"] == "WAIT_SELLER_SEND_GOODS" && configs["autodeliver"] != "1")//等待卖家发货
                        {
                            AlipayClass.AlipayService_Send sendservice = new AlipayClass.AlipayService_Send(partner, trade_no, trade_no, trade_no, "EXPRESS", String.Empty, key, "utf-8", "md5");
                            string url = sendservice.Create_url();

                            System.Xml.XmlTextReader Reader = new System.Xml.XmlTextReader(url);
                            System.Xml.XmlDocument xmlDoc = new System.Xml.XmlDocument();
                            xmlDoc.Load(Reader);

                            string nodeIs_success = xmlDoc.SelectSingleNode("/alipay/is_success").InnerText;//解析XML，获取XML返回的数据，如：请求处理是否成功、商家网站唯一订单号、支付宝交易号、发货时间等
                            if (nodeIs_success == "T")
                            {
                                Response.Write("success");
                                log(sArrary, "\r\n通知成功,发货也成功responseTxt=" + responseTxt + ",sign=" + sign + ",mysign=" + mysign + "\r\n");
                            }
                            else
                            {
                                log(sArrary, "\r\n通知成功,发货失败" + url + xmlDoc.OuterXml + "responseTxt=" + responseTxt + ",sign=" + sign + ",mysign=" + mysign + "\r\n");
                            }
                        }
                    }
                    else
                    {
                        WebUtils.LogWrite("访问日志", Request.Form["trade_status"]);
                        Response.Write("success");  //其他状态判断。普通即时到帐中，其他状态不用判断，直接打印success。
                    }
                }
                else//验证失败
                {
                    log(sArrary, "\r\n通知失败,responseTxt=" + responseTxt + ",sign=" + sign + ",mysign=" + mysign + "\r\n");
                    Response.Write("fail");
                }
            }
            catch (Exception ex)
            {
                WebUtils.LogWrite("访问日志", ex.Message);
            }
        }
        else
        {
            WebUtils.LogWrite("访问日志", "无通知参数");
        }
        Response.End();
    }

    private bool updateorder(string order_no, string total_fee, string service, DateTime? pay_time)
    {
        bool ok = false;
        if (order_no.Length > 0)
        {
            //根据订单号更新订单，把订单状态处理成交易成功
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
    
    /// <summary>
    /// 获取支付宝POST过来通知消息，并以“参数名=参数值”的形式组成数组
    /// </summary>
    /// <returns>request回来的信息组成的数组</returns>
    public ArrayList GetRequestPost()
    {
        int i = 0;
        ArrayList sArray = new ArrayList();
        NameValueCollection coll;
        //Load Form variables into NameValueCollection variable.
        coll = Request.Form;

        // Get names of all forms into a string array.
        String[] requestItem = Request.Form.AllKeys;
        for (i = 0; i < requestItem.Length; i++)
        {
            sArray.Add(requestItem[i] + "=" + Request.Form[requestItem[i]]);
        }
        return sArray;
    }
</script>