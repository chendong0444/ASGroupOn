<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AlipayClass.alipay_oauth.alipayrecive" %>
<%@ Import Namespace="System.Xml" %>

<script runat="server">
    ISystem sysmodel = null;
    NameValueCollection configs;
    protected void Page_Load(object sender, EventArgs e)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            sysmodel = session.System.GetByID(1);
        }
        configs = WebUtils.GetSystem();
        string token = Request.QueryString["token"];	//授权令牌
        //用户选择的收货地址
        string[] keyvalue = Request.Form.AllKeys;
        for (int i = 0; i < keyvalue.Length; i++)
        {
            string k = keyvalue[i];
        }
        //string address = Request.Form["receive_address"];
        //是否开通收获地址并且收获地址是否为空值，如果为空就不进入此方法
        if (configs["IsalipayAddress"] != null && configs["IsalipayAddress"] == "1")
        {
            if (Request.HttpMethod == "POST")
            {
                recieveMessage(token);
            }
            else
            {
                sendMessage(token);
            }
        }

    }
    protected void sendMessage(string token)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            sysmodel = session.System.GetByID(1);
        }
        System.Collections.Generic.SortedDictionary<string, string> sParaTemp = new System.Collections.Generic.SortedDictionary<string, string>();
        sParaTemp.Add("token", token);
        //构造快捷登录用户物流地址查询接口表单提交HTML数据，无需修改
        Config.Partner = sysmodel.alipaymid;
        Config.Key = sysmodel.alipaysec;
        Config.Return_url = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "oauth/alipay/receiveAddress.aspx";
        Service ali = new Service();
        string htmltext = ali.User_logistics_address_query(sParaTemp);
        Response.Write(htmltext);
    }
    protected void recieveMessage(string token)
    {
        System.Collections.Generic.SortedDictionary<string, string> sPara = new System.Collections.Generic.SortedDictionary<string, string>();
        sPara.Add("token", token);
        Config.Partner = sysmodel.alipaymid;
        Config.Key = sysmodel.alipaysec;
        sPara = GetRequestPost();
        if (sPara.Count > 0)//判断是否有带返回参数
        {
            sPara.Add("token", token);
            Notify aliNotify = new Notify();
            bool verifyResult = aliNotify.Verify(sPara, Request.Form["notify_id"], Request.Form["sign"]);

            if (verifyResult)//验证成功
            {
                /////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //请在这里加上商户的业务逻辑程序代码

                //——请根据您的业务逻辑来编写程序（以下代码仅作参考）——
                //获取支付宝的通知返回参数，可参考技术文档中页面跳转同步通知参数列表

                //用户选择的收货地址
                string receive_address = Request.Form["receive_address"];
                //获取收获地址
                string address = "";
                //获取手机号码
                string mobile_phone = "";
                //获取邮编
                string post = "";
                //获取真实姓名
                string fullname = "";
                if (!String.IsNullOrEmpty(receive_address))
                {
                    //对receive_address做XML解析，获得各节点信息
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml(receive_address);
                    //获取地址
                    if (xmlDoc.SelectSingleNode("/receiveAddress/address") != null)
                    {
                        address = xmlDoc.SelectSingleNode("/receiveAddress/address").InnerText;
                        CookieUtils.SetCookie("address", address);
                    }
                    //获取手机号
                    if (xmlDoc.SelectSingleNode("/receiveAddress/mobile_phone") != null)
                    {
                        mobile_phone = xmlDoc.SelectSingleNode("/receiveAddress/mobile_phone").InnerText;
                        CookieUtils.SetCookie("mobile_phone", mobile_phone);
                    }
                    //获取邮编
                    if (xmlDoc.SelectSingleNode("/receiveAddress/post") != null)
                    {
                        post = xmlDoc.SelectSingleNode("/receiveAddress/post").InnerText;
                        CookieUtils.SetCookie("post", post);
                    }
                    //获取真实姓名
                    if (xmlDoc.SelectSingleNode("/receiveAddress/fullname") != null)
                    {
                        fullname = xmlDoc.SelectSingleNode("/receiveAddress/fullname").InnerText;
                        CookieUtils.SetCookie("fullname", fullname);
                    }

                }
                //执行商户的业务程序

                //可美化该页面
                Response.Redirect(GetRefer());
                Response.End();
                return;
                //——请根据您的业务逻辑来编写程序（以上代码仅作参考）——

                /////////////////////////////////////////////////////////////////////////////////////////////////////////////
            }
            else//验证失败
            {
                Response.Write("验证失败");
            }
        }
        else
        {
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
        //Load Form variables into NameValueCollection variable.
        coll = Request.Form;

        // Get names of all forms into a string array.
        String[] requestItem = coll.AllKeys;

        for (i = 0; i < requestItem.Length; i++)
        {
            sArray.Add(requestItem[i], Request.Form[requestItem[i]]);
        }

        return sArray;
    }
</script>
