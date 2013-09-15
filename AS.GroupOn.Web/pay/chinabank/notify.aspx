<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>

<script runat="server">
    protected string v_oid;		// 订单号
    protected string v_pstatus;	// 支付状态码
    //20（支付成功，对使用实时银行卡进行扣款的订单）；
    //30（支付失败，对使用实时银行卡进行扣款的订单）；

    protected string v_pstring;	//支付状态描述
    protected string v_pmode;	//支付银行
    protected string v_amount;	//支付金额
    protected string v_moneytype;	//币种		
    protected string remark1;	// 备注1
    protected string remark2;	// 备注1
    protected string v_md5str;
    protected string status_msg;
    protected string str;	// 备注1
    protected override void OnLoad(EventArgs e)
    {
        // MD5密钥要跟订单提交页相同，如Send.asp里的 key = "test" ,修改""号内 test 为您的密钥
        //string key = "test";	// 如果您还没有设置MD5密钥请登陆我们为您提供商户后台，地址：https://merchant3.chinabank.com.cn/
        // 登陆后在上面的导航栏里可能找到“B2C”，在二级导航栏里有“MD5密钥设置”
        // 建议您设置一个16位以上的密钥或更高，密钥最多64位，但设置16位已经足够了
        string key = ASSystemArr["chinabanksec"];
        v_oid = Request["v_oid"];
        v_pstatus = Request["v_pstatus"];
        v_pstring = Request["v_pstring"];
        v_pmode = Request["v_pmode"];
        v_md5str = Request["v_md5str"];
        v_amount = Request["v_amount"];
        v_moneytype = Request["v_moneytype"];
        remark1 = Request["remark1"];
        remark2 = Request["remark2"];

        string str = v_oid + v_pstatus + v_amount + v_moneytype + key;
        //Response.Write(v_md5str + "<br>");
        //Response.Write();
        //Response.End();
        str = Helper.MD5(str).ToUpper();

        if (str == v_md5str)
        {
            log("校验成功" + str + "\r\n");
            if (v_pstatus.Equals("20"))
            {
                //支付成功
                //在这里商户可以写上自己的业务逻辑
                if (v_oid != null && v_amount != null && v_oid != "" && v_amount != "")
                {
                    OrderMethod.Updateorder(v_oid, v_amount, "chinabank", null);//修改订单状态
                    Response.Redirect(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + GetUrl("支付通知", "order_success.aspx?id=" + v_oid));
                }
            }
        }
        else
        {
            //status_msg = "校验失败，数据可疑";
            log("校验失败" + str + "\r\n");
            Response.Redirect(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + GetUrl("支付通知", "order_success.aspx?id=" + v_oid));
        }
    }



    private void log(string result)
    {
        #region 记录支付通知结果
        try
        {
            string drec = Server.MapPath(WebRoot + "chinabanklog");
            object locker = new object();
            object filelocker = new object();
            lock (locker)
            {
                if (!System.IO.Directory.Exists(drec))
                    System.IO.Directory.CreateDirectory(drec);
            }
            string filepath = Server.MapPath(WebRoot + "chinabanklog/" + DateTime.Now.ToString("yyyyMMdd") + ".config");
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            for (int i = 0; i < Request.Form.Count; i++)
            {
                sb.Append("&" + Request.Form.Keys[i] + "=" + Request.Form[i]);

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