<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="AlipayClass.alipayReceive" %>

<script runat="server">
    /// <summary>
    /// 功能：页面跳转同步通知页面
    /// 版本：3.2
    /// 日期：2011-03-11
    /// 说明：
    /// 以下代码只是为了方便商户测试而提供的样例代码，商户可以根据自己网站的需要，按照技术文档编写,并非一定要使用该代码。
    /// 该代码仅供学习和研究支付宝接口使用，只是提供一个参考。
    /// 
    /// ///////////////////////页面功能说明///////////////////////
    /// 该页面可在本机电脑测试
    /// 该页面称作“页面跳转同步通知页面”
    /// 可放入HTML等美化页面的代码和订单交易完成后的数据库更新程序代码
    /// 该页面可以使用ASP.NET开发工具调试，也可以使用写文本函数Log_result进行调试，该函数已被默认关闭
    /// </summary>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        System.Collections.Generic.SortedDictionary<string, string> sArrary = GetRequestPost();

        if (sArrary.Count > 0)//判断是否有带返回参数
        {
            Notify aliNotify = new Notify(sArrary, Request.Form["notify_id"]);

            //获取远程服务器ATN结果，验证是否是支付宝服务器发来的请求
            string responseTxt = aliNotify.ResponseTxt;
            //获取支付宝反馈回来的sign结果
            string sign = Request.Form["sign"];
            //获取通知返回后计算后（验证）的签名结果
            string mysign = aliNotify.Mysign;

            //写日志记录（若要调试，请取消下面两行注释）
            //string sWord = "responseTxt=" + responseTxt + "\n return_url_log:sign=" + Request.Form["sign"] + "&mysign=" + mysign + "\n return回来的参数：" + aliNotify.PreSignStr;
            //Function.LogResult(sWord);

            //判断responsetTxt是否为ture，生成的签名结果mysign与获得的签名结果sign是否一致
            //responsetTxt的结果不是true，与服务器设置问题、合作身份者ID、notify_id一分钟失效有关
            //mysign与sign不等，与安全校验码、请求时的参数格式（如：带自定义参数等）、编码格式有关
            if (responseTxt == "true" && sign == mysign)//验证成功
            {
                /////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //请在这里加上商户的业务逻辑程序代码

                //——请根据您的业务逻辑来编写程序（以下代码仅作参考）——
                //获取支付宝的通知返回参数，可参考技术文档中页面跳转同步通知参数列表
                //支付宝用户id
                string user_id = Request.Form["user_id"];
                //用户选择的收货地址
                string receive_address = Request.Form["receive_address"];


                string address = "";
                string fullname = "";
                if (receive_address != null && receive_address != "")
                {
                    //对receive_address做XML解析，获得各节点信息
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml(receive_address);

                    //获取地址
                    if (xmlDoc.SelectSingleNode("/receiveAddress/address") != null)
                    {
                        address = xmlDoc.SelectSingleNode("/receiveAddress/address").InnerText;
                    }
                    //获取收货人名称
                    if (xmlDoc.SelectSingleNode("/receiveAddress/fullname") != null)
                    {
                        fullname = xmlDoc.SelectSingleNode("/receiveAddress/fullname").InnerText;
                    }
                }

                //执行商户的业务程序

                //可美化该页面
                Response.Write("验证成功<br />receive_address:" + address + fullname);

                //——请根据您的业务逻辑来编写程序（以上代码仅作参考）——

                /////////////////////////////////////////////////////////////////////////////////////////////////////////////
            }
            else//验证失败
            {
                //可美化该页面
                Response.Write("验证失败");
            }
        }
        else
        {
            //可美化该页面
            Response.Write("无返回参数");
        }
    }
    /// <summary>
    /// 获取支付宝POST过来通知消息，并以“参数名=参数值”的形式组成数组
    /// </summary>
    /// <returns>request回来的信息组成的数组</returns>
    public System.Collections.Generic.SortedDictionary<string, string> GetRequestPost()
    {
        int i = 0;
        System.Collections.Generic.SortedDictionary<string, string> sArray = new System.Collections.Generic.SortedDictionary<string, string>();
        NameValueCollection coll;

        coll = Request.Form;


        String[] requestItem = coll.AllKeys;

        for (i = 0; i < requestItem.Length; i++)
        {
            sArray.Add(requestItem[i], Request.Form[requestItem[i]]);
        }

        return sArray;
    }
</script>
