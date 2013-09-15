<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="Asdht.Wap.tenpay" %>
<script runat="server">
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
        WapPayPageResponseHandler resHandler = new WapPayPageResponseHandler(Context);
        resHandler.setKey(key);
        //判断签名
        if (resHandler.isTenpaySign())
        {
            //支付结果
            string pay_result = resHandler.getParameter("pay_result");
            //商户订单号
            string sp_billno = resHandler.getParameter("sp_billno");
            //财付通订单号
            string transaction_id = resHandler.getParameter("transaction_id");
            //金额,以分为单位
            string total_fee = resHandler.getParameter("total_fee");

            if ("0".Equals(pay_result))
            {
                //------------------------------
                //处理业务开始
                //------------------------------
                if (total_fee != String.Empty && transaction_id != String.Empty)
                {
                    OrderMethod.Updateorder(sp_billno, (Convert.ToDecimal(total_fee) / 100).ToString(), "tenpaywap", null);//修改订单状态  
                    Response.Write("success");
                }
                else
                {
                    Response.Write("fail");
                }
            }
            else
            {
                //当做不成功处理
                Response.Write("支付失败");
            }
            Response.Redirect(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + GetUrl("手机版支付通知", "return_credit.aspx") + sp_billno);
            Response.End();
        }
        else
        {
            Response.Write("认证签名失败");

        }
        Response.End();
    }
    private void log()
    {
        try
        {
            #region 记录支付通知结果
            string drec = Server.MapPath(WebRoot + "tenpayWaplog");
            object locker = new object();
            object filelocker = new object();
            lock (locker)
            {
                if (!System.IO.Directory.Exists(drec))
                    System.IO.Directory.CreateDirectory(drec);
            }
            string filepath = Server.MapPath(WebRoot + "tenpayWaplog/" + DateTime.Now.ToString("yyyyMMdd") + ".config");
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