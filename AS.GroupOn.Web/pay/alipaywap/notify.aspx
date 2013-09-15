<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="Asdht.Wap.Alipay.Class" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        System.Collections.Generic.Dictionary<string, string> sPara = GetRequestPost();
        if (sPara.Count > 0)//判断是否有带返回参数
        {
            Notify aliNotify = new Notify();
            bool verifyResult = aliNotify.VerifyNotify(sPara, Request.Form["sign"]);
            if (verifyResult)//验证成功
            {
                try
                {
                    System.Xml.XmlDocument xmlDoc = new System.Xml.XmlDocument();
                    xmlDoc.LoadXml(sPara["notify_data"]);
                    //商户订单号
                    string out_trade_no = xmlDoc.SelectSingleNode("/notify/out_trade_no").InnerText;
                    //交易状态
                    string trade_status = xmlDoc.SelectSingleNode("/notify/trade_status").InnerText;

                    string total_fee = xmlDoc.SelectSingleNode("/notify/total_fee").InnerText;

                    if (trade_status == "TRADE_FINISHED" || trade_status == "TRADE_SUCCESS")
                    {
                        //判断该笔订单是否在商户网站中已经做过处理
                        //如果没有做过处理，根据订单号（out_trade_no）在商户网站的订单系统中查到该笔订单的详细，并执行商户的业务程序
                        //如果有做过处理，不执行商户的业务程序

                        //注意：
                        //该种交易状态只在两种情况下出现
                        //1、开通了普通即时到账，买家付款成功后。
                        //2、开通了高级即时到账，从该笔交易成功时间算起，过了签约时的可退款时限（如：三个月以内可退款、一年以内可退款等）后。
                        if (total_fee != String.Empty && out_trade_no != String.Empty)
                        {
                            OrderMethod.Updateorder(out_trade_no, total_fee, "alipaywap", null);//修改订单状态  
                            Response.Write("success");  //请不要修改或删除
                        }
                        else
                        {
                            Response.Write("fail");
                        }
                    }
                    else
                    {
                        Response.Write(trade_status);
                    }
                    Response.Redirect(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + GetUrl("手机版支付通知", "return_credit.aspx") + out_trade_no);
                    Response.End();

                }
                catch (Exception exc)
                {
                    Response.Write(exc.ToString());
                }
            }
            else//验证失败
            {
                Response.Write("fail");
            }
        }
        else
        {
            Response.Write("无通知参数");
        }

    }
    /// <summary>
    /// 获取支付宝POST过来通知消息，并以“参数名=参数值”的形式组成数组
    /// </summary>
    /// <returns>request回来的信息组成的数组</returns>
    public System.Collections.Generic.Dictionary<string, string> GetRequestPost()
    {
        string drec = Server.MapPath(WebRoot + "alipayWaplog");
        object locker = new object();
        object filelocker = new object();
        lock (locker)
        {
            if (!System.IO.Directory.Exists(drec))
                System.IO.Directory.CreateDirectory(drec);
        }
        string filepath = Server.MapPath(WebRoot + "alipayWaplog/" + DateTime.Now.ToString("yyyyMMdd") + ".config");
        int i = 0;
        System.Collections.Generic.Dictionary<string, string> sArray = new System.Collections.Generic.Dictionary<string, string>();
        NameValueCollection coll;
        //Load Form variables into NameValueCollection variable.
        coll = Request.Form;

        // Get names of all forms into a string array.
        String[] requestItem = coll.AllKeys;
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("开始");
        for (i = 0; i < requestItem.Length; i++)
        {
            sArray.Add(requestItem[i], Request.Form[requestItem[i]]);
            sb.Append(requestItem[i] + "〉〉〉" + Request.Form[requestItem[i]]);
        }
        sb.Append("结束");
        lock (filelocker)
        {
            System.IO.File.AppendAllText(filepath, sb.ToString());
        }
        return sArray;
    }
</script>
