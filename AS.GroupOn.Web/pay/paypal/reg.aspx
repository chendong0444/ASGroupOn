<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    public ISystem systemmodel = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        NeedLogin();
        string strFormValues;
        string strNewValue;
        string strResponse;

        //创建回复的 request
        string strSandbox = "https://www.sandbox.paypal.com/cgi-bin/webscr";//sandbox测试开发用
        string strLive = "https://www.paypal.com/cgi-bin/webscr";
        HttpWebRequest req = (HttpWebRequest)WebRequest.Create(strLive);

        //设置 request 的属性
        req.Method = "POST";
        req.ContentType = "application/x-www-form-urlencoded";
        byte[] param = HttpContext.Current.Request.BinaryRead(
        HttpContext.Current.Request.ContentLength);
        strFormValues = Encoding.ASCII.GetString(param);

        //建议在此将接受到的信息记录到日志文件中以确认是否收到 IPN 信息
        WebUtils.LogWrite("paypal日志", "1:strFormValues=" + strFormValues);
        strNewValue = strFormValues + "&cmd=_notify-validate";
        req.ContentLength = strNewValue.Length;
        //发送 request
        StreamWriter stOut = new StreamWriter(req.GetRequestStream(),
        System.Text.Encoding.ASCII);
        stOut.Write(strNewValue);
        stOut.Close();

        //回复 IPN 并接受反馈信息
        StreamReader stIn = new StreamReader(req.GetResponse().GetResponseStream());
        strResponse = stIn.ReadToEnd();
        stIn.Close();
        string ordermsgs = Request.Form["item_number"].ToString();//商户邮箱和付款金额
        string[] ordermsg = ordermsgs.Split('|');
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            systemmodel = session.System.GetByID(1);

        }
        if (strResponse == "VERIFIED")  //IPN合法
        {
            decimal money = Helper.GetDecimal(Request.Form["mc_gross"], 0);//交易金额

            //确认“payment_status”为“Completed”，因为系统也会为其他结果（如“Pending”或“Failed”）发送 IPN。
            if (Request.Form["payment_status"].ToString() == "Completed" || Request.Form["payment_status"].ToString() == "Pending")
            {

                //检查“txn_id”是否未重复，以防止欺诈者重复使用旧的已完成的交易。
                OrderFilter orderfilter = new OrderFilter();
                orderfilter.Wheresql1 = "pay_id='" + ordermsg[0].ToString() + "' and (state='pay' or state='scorepay')";
                int result = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    result = session.Orders.GetCount(orderfilter);
                }
                string count = result.ToString();
                if (count != "0")
                {
                    return;
                }

                //验证“receiver_email”是已在您的PayPal账户中注册的电子邮件地址，以防止将付款发送到欺诈者的账户 。
                if (Request.Form["receiver_email"].ToString() != systemmodel.paypalmid)
                {
                    return;
                }
                decimal total_price = 0;
                if (OrderMethod.GetPayType(ordermsg[0].ToString()))
                {
                    total_price = OrderMethod.GetPayPrice(ordermsg[0].ToString());
                }
                else
                {
                    total_price = Convert.ToDecimal(ordermsg[2].ToString());
                }

                if (money != total_price || Request.Form["mc_currency"].ToString() != "CNY")
                //结束
                {
                    return;
                }

                //处理这次付款，改数据库
                if (Request.Form["mc_gross"].ToString() != "")
                {
                    OrderMethod.Updateorder(ordermsg[0].ToString(), money.ToString(), "paypal", null);//修改订单状态

                }
            }
        }
        else if (strResponse == "INVALID")//IPN不合法
        {
            WebUtils.LogWrite("paypal日志", "订单号：" + ordermsg[0].ToString() + "--ipn验证失败！\r\n");
            //System.IO.File.AppendAllText(AppDomain.CurrentDomain.BaseDirectory + "paypal支付ipn信息.txt", "订单号："+ordermsg[0].ToString()+"--ipn验证失败！\r\n");
        }
    }
</script>
