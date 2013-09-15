<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="tenpay" %>

<script runat="server">
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
        MediPayResponse resHandler = new MediPayResponse(Context);

        resHandler.setKey(key);

        //判断签名
        if (resHandler.isTenpaySign())
        {
            ////商户号
            //string bargainor_id = resHandler.getParameter("buyer_id");
            ////交易单号
            //string transaction_id = resHandler.getParameter("transaction_id");
            ////金额金额,以分为单位
            //string total_fee = resHandler.getParameter("total_fee");
            ////支付结果
            //string pay_result = resHandler.getParameter("pay_result");


            //支付结果
            string retcode = resHandler.getParameter("retcode");

            //支付状态
            string status = resHandler.getParameter("status");

            //商户订单号
            string mch_vno = resHandler.getParameter("mch_vno");
            //交易金额以分为单位
            string mch_price = resHandler.getParameter("mch_price");

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


            if ("0".Equals(retcode))
            {
                if (status == "3")
                {
                    //------------------------------
                    //处理业务开始
                    //------------------------------ 
                    //string sp_billno = resHandler.getParameter("sp_billno");
                    //string money = resHandler.getParameter("total_fee");

                    if (mch_price != "")
                    {
                        OrderMethod.Updateorder(mch_vno, (Convert.ToDecimal(mch_price) / 100).ToString(), "tenpay", null);//修改订单状态                      
                    }

                    //------------------------------
                    //处理业务完毕
                    //------------------------------

                    resHandler.doShow();
                    //resHandler.doShow(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot+"order/success.html?id=" + sp_billno);
                }
            }
            else
            {
                //当做不成功处理
                Response.Write("支付失败");
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
