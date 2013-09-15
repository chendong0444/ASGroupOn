namespace com.yeepay.bankutils
{
    using com.yeepay.bank;
    using System;
    using System.IO;
    using System.Text;
    using System.Web;
    using System.Configuration;
    public abstract class Buy
    {
        //private static string keyValue = ConfigurationManager.AppSettings["keyValue"];
        //private static string merchantId = ConfigurationManager.AppSettings["merhantId"];
        //private static string nodeAuthorizationURL = ConfigurationManager.AppSettings["authorizationURL"];
        //private static string queryRefundReqURL = ConfigurationManager.AppSettings["queryRefundReqURL"];

        public static string CreateBuyUrl(string p2_Order, string p3_Amt, string p4_Cur, string p5_Pid, string p6_Pcat, string p7_Pdesc, string p8_Url, string p9_SAF, string pa_MP, string pd_FrpId, string pr_NeedRespone, string partnerGatewayID, string partnerKey, string AuthorizationURL)
        {
            string aValue = "";
            aValue = ((((((aValue + "Buy") + partnerGatewayID + p2_Order) + p3_Amt + p4_Cur) + p5_Pid + p6_Pcat) + p7_Pdesc + p8_Url) + p9_SAF + pa_MP) + pd_FrpId + pr_NeedRespone;
            string hmac = Digest.HmacSign(aValue, partnerKey);
            logstr(p2_Order, aValue, hmac);
            string str3 = "";
            return ((((((((((((((str3 + AuthorizationURL + "?p0_Cmd=Buy") + "&p1_MerId=" + partnerGatewayID) + "&p2_Order=" + HttpUtility.UrlEncode(p2_Order, Encoding.GetEncoding("gb2312"))) + "&p3_Amt=" + p3_Amt) + "&p4_Cur=" + p4_Cur) + "&p5_Pid=" + HttpUtility.UrlEncode(p5_Pid, Encoding.GetEncoding("gb2312"))) + "&p6_Pcat=" + HttpUtility.UrlEncode(p6_Pcat, Encoding.GetEncoding("gb2312"))) + "&p7_Pdesc=" + HttpUtility.UrlEncode(p7_Pdesc, Encoding.GetEncoding("gb2312"))) + "&p8_Url=" + HttpUtility.UrlEncode(p8_Url, Encoding.GetEncoding("gb2312"))) + "&p9_SAF=" + p9_SAF) + "&pa_MP=" + HttpUtility.UrlEncode(pa_MP, Encoding.GetEncoding("gb2312"))) + "&pd_FrpId=" + pd_FrpId) + "&pr_NeedResponse=" + pr_NeedRespone) + "&hmac=" + hmac);
        }

        public static void logstr(string orderid, string str, string hmac)
        {
            try
            {
                StreamWriter writer = new StreamWriter(HttpContext.Current.Server.MapPath("YeePay_HTMLCommon.log"), true);
                writer.BaseStream.Seek(0L, SeekOrigin.End);
                writer.WriteLine(DateTime.Now.ToString() + "[" + orderid + "][" + str + "][" + hmac + "]");
                writer.Flush();
                writer.Close();
            }
            catch (Exception exception)
            {
                Console.WriteLine(exception);
            }
        }

        public static BuyQueryOrdDetailResult QueryOrdDetail(string p2_Order,string partnerGatewayID,string partnerKey,string queryGatewayOrderUrl)
        {
            string aValue = "";
            aValue = (aValue + "QueryOrdDetail") + partnerGatewayID + p2_Order;
            string hmac = Digest.HmacSign(aValue, partnerKey);
            logstr(p2_Order, aValue, hmac);
            string para = "";
            para = (((para + "?p0_Cmd=QueryOrdDetail") + "&p1_MerId=" + partnerGatewayID) + "&p2_Order=" + p2_Order) + "&hmac=" + hmac;
            string strUrl = HttpUtils.SendRequest(queryGatewayOrderUrl, para);
            string str5 = FormatQueryString.GetQueryString("r0_Cmd", strUrl, '\n');
            string str6 = FormatQueryString.GetQueryString("r1_Code", strUrl, '\n');
            string str7 = FormatQueryString.GetQueryString("r2_TrxId", strUrl, '\n');
            string str8 = FormatQueryString.GetQueryString("r3_Amt", strUrl, '\n');
            string str9 = FormatQueryString.GetQueryString("r4_Cur", strUrl, '\n');
            string str10 = FormatQueryString.GetQueryString("r5_Pid", strUrl, '\n');
            string str11 = FormatQueryString.GetQueryString("r6_Order", strUrl, '\n');
            string str12 = FormatQueryString.GetQueryString("r8_MP", strUrl, '\n');
            string str13 = FormatQueryString.GetQueryString("rb_PayStatus", strUrl, '\n');
            string str14 = FormatQueryString.GetQueryString("rc_RefundCount", strUrl, '\n');
            string str15 = FormatQueryString.GetQueryString("rd_RefundAmt", strUrl, '\n');
            return new BuyQueryOrdDetailResult(str5, str6, str7, str8, str9, str10, str11, str12, str13, str14, str15, FormatQueryString.GetQueryString("hmac", strUrl, '\n'));
        }

        public static BuyRefundOrdResult RefundOrd(string pb_TrxId, string p3_Amt, string p4_Cur, string p5_Desc,string partnerGateID,string partnerKey,string queryGatewayOrderUrl)
        {
            string aValue = "";
            aValue = ((aValue + "RefundOrd" + partnerGateID) + pb_TrxId + p3_Amt) + p4_Cur + p5_Desc;
            string hmac = Digest.HmacSign(aValue, partnerKey);
            logstr(pb_TrxId, aValue, hmac);
            string para = "";
            para = ((((((para + "?p0_Cmd=RefundOrd") + "&p1_MerId=" + partnerGateID) + "&pb_TrxId=" + pb_TrxId) + "&p3_Amt=" + p3_Amt) + "&p4_Cur=" + p4_Cur) + "&p5_Desc=" + HttpUtility.UrlEncode(p5_Desc, Encoding.GetEncoding("gb2312"))) + "&hmac=" + hmac;
            string strUrl = HttpUtils.SendRequest(queryGatewayOrderUrl, para);
            string str5 = FormatQueryString.GetQueryString("r0_Cmd", strUrl, '\n');
            string str6 = FormatQueryString.GetQueryString("r1_Code", strUrl, '\n');
            string str7 = FormatQueryString.GetQueryString("r2_TrxId", strUrl, '\n');
            string str8 = FormatQueryString.GetQueryString("r3_Amt", strUrl, '\n');
            string str9 = FormatQueryString.GetQueryString("r4_Cur", strUrl, '\n');
            return new BuyRefundOrdResult(str5, str6, str7, str8, str9, FormatQueryString.GetQueryString("hmac", strUrl, '\n'));
        }

        public static BuyCallbackResult VerifyCallback(string p1_MerId, string r0_Cmd, string r1_Code, string r2_TrxId, string r3_Amt, string r4_Cur, string r5_Pid, string r6_Order, string r7_Uid, string r8_MP, string r9_BType, string rp_PayDate, string hmac,string partnerKey)
        {
            string aValue = "";
            aValue = (((((aValue + p1_MerId) + r0_Cmd + r1_Code) + r2_TrxId + r3_Amt) + r4_Cur + r5_Pid) + r6_Order + r7_Uid) + r8_MP + r9_BType;
            string str2 = Digest.HmacSign(aValue, partnerKey);
            logstr(r6_Order, aValue, str2);
            if (str2 == hmac)
            {
                return new BuyCallbackResult(p1_MerId, r0_Cmd, r1_Code, r2_TrxId, r3_Amt, r4_Cur, r5_Pid, r6_Order, r7_Uid, r8_MP, r9_BType, rp_PayDate, hmac, "");
            }
            return new BuyCallbackResult(p1_MerId, r0_Cmd, r1_Code, r2_TrxId, r3_Amt, r4_Cur, r5_Pid, r6_Order, r7_Uid, r8_MP, r9_BType, rp_PayDate, hmac, "交易签名被篡改");
        }
    }
}

