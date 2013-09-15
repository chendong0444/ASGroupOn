<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="com.yeepay.bank" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {

        string _partnerGatewayID = String.Empty;
        string _partnerKey = String.Empty;
        string notifyUrl = String.Empty;

        #region 记录支付通知结果
        try
        {
            string drec = Server.MapPath(WebRoot + "yeepaylog");
            object locker = new object();
            object filelocker = new object();
            lock (locker)
            {
                if (!System.IO.Directory.Exists(drec))
                    System.IO.Directory.CreateDirectory(drec);
            }
            string filepath = Server.MapPath(WebRoot + "yeepaylog/" + DateTime.Now.ToString("yyyyMMdd") + ".config");
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            for (int i = 0; i < Request.QueryString.Count; i++)
            {
                sb.Append("&" + Request.QueryString.Keys[i] + "=" + Request.QueryString[i]);

            }

            lock (filelocker)
            {
                System.IO.File.AppendAllText(filepath, sb.ToString());
            }
        }
        catch { }
        #endregion

        if (ASSystem != null)
        {
            _partnerGatewayID = ASSystem.yeepaymid;
            _partnerKey = ASSystem.yeepaysec;
        }



        if (!IsPostBack)
        {
            // 校验返回数据包
            BuyCallbackResult result = Buy.VerifyCallback(FormatQueryString.GetQueryString("p1_MerId"), FormatQueryString.GetQueryString("r0_Cmd"), FormatQueryString.GetQueryString("r1_Code"), FormatQueryString.GetQueryString("r2_TrxId"),
            FormatQueryString.GetQueryString("r3_Amt"), FormatQueryString.GetQueryString("r4_Cur"), FormatQueryString.GetQueryString("r5_Pid"), FormatQueryString.GetQueryString("r6_Order"), FormatQueryString.GetQueryString("r7_Uid"),
            FormatQueryString.GetQueryString("r8_MP"), FormatQueryString.GetQueryString("r9_BType"), FormatQueryString.GetQueryString("rp_PayDate"), FormatQueryString.GetQueryString("hmac"), _partnerKey);

            if (string.IsNullOrEmpty(result.ErrMsg))
            {
                //在接收到支付结果通知后，判断是否进行过业务逻辑处理，不要重复进行业务逻辑处理
                if (result.R1_Code == "1")
                {

                    OrderMethod.Updateorder(result.R6_Order, result.R3_Amt, "yeepay", null);//修改订单状态
                    if (result.R9_BType == "1")
                    {
                        Response.Redirect(GetUrl("支付通知", "order_success.aspx?id=" + result.R6_Order));//id传payid
                        Response.End();
                        return;
                    }
                    else if (result.R9_BType == "2")
                    {
                        // * 如果是服务器返回则需要回应一个特定字符串'SUCCESS',且在'SUCCESS'之前不可以有任何其他字符输出,保证首先输出的是'SUCCESS'字符串

                        Response.Clear();
                        Response.Write("SUCCESS");
                        Response.End();
                        return;
                    }
                }
                else
                {
                    Response.Write("支付失败!");
                }
            }
            else
            {
                Response.Write("交易签名无效!");
            }
        }

    }
</script>
