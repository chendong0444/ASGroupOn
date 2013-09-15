<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>

<script runat="server">
    ISystem systemModel = null;
    //必要的交易信息
    protected string v_amount;       // 订单金额
    protected string v_moneytype;    // 币种
    protected string v_md5info;      // 对拼凑串MD5私钥加密后的值
    protected string v_mid;		 // 商户号
    protected string v_url;		 // 返回页地址
    protected string v_oid;		 // 推荐订单号构成格式为 年月日-商户号-小时分钟秒

    //收货信息
    protected string v_rcvname;      // 收货人
    protected string v_rcvaddr;      // 收货地址
    protected string v_rcvtel;       // 收货人电话
    protected string v_rcvpost;      // 收货人邮编
    protected string v_rcvemail;     // 收货人邮件
    protected string v_rcvmobile;    // 收货人手机号

    //订货人信息
    protected string v_ordername;    // 订货人姓名
    protected string v_orderaddr;    // 订货人地址
    protected string v_ordertel;     // 订货人电话
    protected string v_orderpost;    // 订货人邮编
    protected string v_orderemail;   // 订货人邮件
    protected string v_ordermobile;  // 订货人手机号
    protected string pmode_id;
    //两个备注
    protected string remark1;
    protected string remark2;

    protected void Page_Load(object sender, EventArgs e)
    {
        NeedLogin();
        setValue();
    }
    /// <summary>
    /// 设置提交信息
    /// </summary>
    private void setValue()
    {
        string key = "";
        // 商户号，这里为测试商户号1001，替换为自己的商户号即可
        // MD5密钥要跟订单提交页相同，如Send.asp里的 key = "test" ,修改""号内 test 为您的密钥
        // 如果您还没有设置MD5密钥请登陆我们为您提供商户后台，地址：https://merchant3.chinabank.com.cn/
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            systemModel = session.System.GetByID(1);
        }
        if (systemModel != null)
        {
            if (systemModel.chinabankmid != "")
            {
                //设置商户号
                v_mid = systemModel.chinabankmid;
                //设置商户密钥
                key = systemModel.chinabanksec;
            }
        }

        //设置返回地址
        v_url = WWWprefix + "pay/chinabank/notify.aspx";

        //设置交易单号
        if (Request.Form["out_trade_no"] != null && Request.Form["out_trade_no"].ToString() != "")
        {
            v_oid = Request.Form["out_trade_no"].ToString();
        }
        //设置金额
        if (Request.Form["total_fee"] != null && Request.Form["total_fee"].ToString() != "")
        {
            v_amount = Request.Form["total_fee"];                                    //订单总金额，显示在支付宝收银台里的“应付总额”里
            //if (OrderMethod.GetPayType(v_oid))
            //    v_amount = OrderMethod.GetPayPrice(v_oid).ToString();

        }
        //设置提交的时间
        if (v_oid == null || v_oid.Equals(""))
        {
            DateTime dt = DateTime.Now;
            string v_ymd = dt.ToString("yyyyMMdd"); // yyyyMMdd
            string timeStr = dt.ToString("HHmmss"); // HHmmss
            v_oid = v_ymd + v_mid + timeStr;
        }
        if (Request.Form["subject"] != null && Request.Form["subject"].ToString() != "")
        {
            //备注网站名称和订单编号
            remark1 = StringUtils.SubString(Request.Form["subject"].ToString(), 140);
        }
        remark2 = String.Format("[url:={0}]", WWWprefix + "pay/chinabank/receive.aspx");
        v_moneytype = "CNY";

        string text = v_amount + v_moneytype + v_oid + v_mid + v_url + key; // 拼凑加密串

        v_md5info = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(text, "md5").ToUpper();

        //收货信息
        v_rcvname = Request["v_rcvname"];
        v_rcvaddr = Request["v_rcvaddr"];
        v_rcvtel = Request["v_rcvtel"];
        v_rcvpost = Request["v_rcvpost"];
        v_rcvemail = Request["v_rcvemail"];
        v_rcvmobile = Request["v_rcvmobile"];

        //订货人信息
        v_ordername = Request["v_ordername"];
        v_orderaddr = Request["v_orderaddr"];
        v_ordertel = Request["v_ordertel"];
        v_orderpost = Request["v_orderpost"];
        v_orderemail = Request["v_orderemail"];
        v_ordermobile = Request["v_ordermobile"];

    }
</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>订单提交</title>
</head>
<body >
<body onLoad="javascript:document.E_FORM.submit()" >
     <form    action="https://pay3.chinabank.com.cn/PayGate"  method="post" name="E_FORM">
    
      <input type="hidden" name="v_md5info"    value="<%=v_md5info%>" size="100" />
      <input type="hidden" name="v_mid"        value="<%=v_mid%>" />
      <input type="hidden" name="v_oid"        value="<%=v_oid%>" />
      <input type="hidden" name="v_amount"     value="<%=v_amount%>" />
      <input type="hidden" name="v_moneytype"  value="<%=v_moneytype%>" />
      <input type="hidden" name="v_url"        value="<%=v_url%>" />


<!--以下几项项为网上支付完成后，随支付反馈信息一同传给信息接收页-->
    
  <input type="hidden"  name="remark1" value="<%=HttpUtility.UrlEncode(remark1, System.Text.Encoding.UTF8)%>" />
  <input type="hidden"  name="remark2" value="<%=remark2%>" />
    
  <!--以下几项只是用来记录客户信息，可以不用，不影响支付 -->

	<input type="hidden"  name="v_rcvname"      value="<%=v_rcvname%>" />
	<input type="hidden"  name="v_rcvaddr"      value="<%=v_rcvaddr%>" />
	<input type="hidden"  name="v_rcvtel"       value="<%=v_rcvtel%>" />
	<input type="hidden"  name="v_rcvpost"      value="<%=v_rcvpost%>" />
	<input type="hidden"  name="v_rcvemail"     value="<%=v_rcvemail%>" />
	<input type="hidden"  name="v_rcvmobile"    value="<%=v_rcvmobile%>" />

	<input type="hidden"  name="v_ordername"    value="<%=v_ordername%>" />
	<input type="hidden"  name="v_orderaddr"    value="<%=v_orderaddr%>" />
	<input type="hidden"  name="v_ordertel"     value="<%=v_ordertel%>" />
	<input type="hidden"  name="v_orderpost"    value="<%=v_orderpost%>" />
	<input type="hidden"  name="v_orderemail"   value="<%=v_orderemail%>" />
	<input type="hidden"  name="v_ordermobile"  value="<%=v_ordermobile%>" />
    </form>
</body>
</html>
