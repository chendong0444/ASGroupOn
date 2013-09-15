using System.Web;
using System.Text;
using System.IO;
using System.Net;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
namespace AlipayClass
{
    /// <summary>
    /// 类名：alipay_service
    /// 功能：支付宝外部服务接口控制
    /// 详细：该页面是请求参数核心处理文件，不需要修改
    /// 版本：3.0
    /// 修改日期：2010-06-13
    /// 说明：
    /// 以下代码只是为了方便商户测试而提供的样例代码，商户可以根据自己网站的需要，按照技术文档编写,并非一定要使用该代码。
    /// 该代码仅供学习和研究支付宝接口使用，只是提供一个参考
    /// </summary>
    public class AlipayService
    {
        private string gateway = "";                //网关地址
        private string _key = "";                    //交易安全校验码
        private string _input_charset = "";         //编码格式
        private string _sign_type = "";              //加密方式（签名方式）
        private string mysign = "";                 //加密结果（签名结果）
        private ArrayList sPara = new ArrayList();  //需要加密的已经过滤后的参数数组

        /// <summary>
        /// 构造函数
        /// 从配置文件及入口文件中初始化变量
        /// </summary>
        /// <param name="partner">合作身份者ID</param>
        /// <param name="seller_email">签约支付宝账号或卖家支付宝帐户</param>
        /// <param name="return_url">付完款后跳转的页面 要用 以http开头格式的完整路径，不允许加?id=123这类自定义参数</param>
        /// <param name="notify_url">交易过程中服务器通知的页面 要用 以http开格式的完整路径，不允许加?id=123这类自定义参数</param>
        /// <param name="show_url">网站商品的展示地址，不允许加?id=123这类自定义参数</param>
        /// <param name="out_trade_no">请与贵网站订单系统中的唯一订单号匹配</param>
        /// <param name="subject">订单名称，显示在支付宝收银台里的“商品名称”里，显示在支付宝的交易管理的“商品名称”的列表里。</param>
        /// <param name="body">订单描述、订单详细、订单备注，显示在支付宝收银台里的“商品描述”里</param>
        /// <param name="total_fee">订单总金额，显示在支付宝收银台里的“应付总额”里</param>
        /// <param name="paymethod">默认支付方式，四个值可选：bankPay(网银); cartoon(卡通); directPay(余额); CASH(网点支付)</param>
        /// <param name="defaultbank">默认网银代号，代号列表见club.alipay.com/read.php?tid=8681379</param>
        /// <param name="encrypt_key">防钓鱼时间戳</param>
        /// <param name="exter_invoke_ip">买家本地电脑的IP地址</param>
        /// <param name="extra_common_param">自定义参数，可存放任何内容（除等特殊字符外），不会显示在页面上</param>
        /// <param name="buyer_email">默认买家支付宝账号</param>
        /// <param name="royalty_type">提成类型，该值为固定值：10，不需要修改</param>
        /// <param name="royalty_parameters">提成信息集，与需要结合商户网站自身情况动态获取每笔交易的各分润收款账号、各分润金额、各分润说明。最多只能设置10条</param>
        /// <param name="it_b_pay">超时时间，不填默认是15天。八个值可选：1h(1小时),2h(2小时),3h(3小时),1d(1天),3d(3天),7d(7天),15d(15天),1c(当天)</param>
        /// <param name="key">安全检验码</param>
        /// <param name="input_charset">字符编码格式 目前支持 gb2312 或 utf-8</param>
        /// <param name="sign_type">加密方式 不需修改</param>
        public AlipayService(string partner,
            string seller_email,
            string return_url,
            string notify_url,
            string show_url,
            string out_trade_no,
            string subject,
            string body,
            string total_fee,
            string paymethod,
            string defaultbank,
            string encrypt_key,
            string exter_invoke_ip,
            string extra_common_param,
            string buyer_email,
            string royalty_type,
            string royalty_parameters,
            string it_b_pay,
            string key,
            string input_charset,
            string sign_type)
        {
            //gateway = "https://www.alipay.com/cooperate/gateway.do?";
            //支付宝网关地址（新）
            gateway = "https://mapi.alipay.com/gateway.do?";
            _key = key.Trim();
            _input_charset = input_charset.ToLower();
            _sign_type = sign_type.ToUpper();

            //构造加密参数数组
            sPara.Add("service=create_direct_pay_by_user");
            sPara.Add("payment_type=1");
            sPara.Add("partner=" + partner);
            sPara.Add("seller_email=" + seller_email);
            sPara.Add("return_url=" + return_url);
            sPara.Add("notify_url=" + notify_url);
            sPara.Add("_input_charset=" + _input_charset);
            sPara.Add("show_url=" + show_url);
            sPara.Add("out_trade_no=" + out_trade_no);
            sPara.Add("subject=" + subject);
            sPara.Add("body=" + body);
            sPara.Add("total_fee=" + total_fee);
            sPara.Add("paymethod=" + paymethod);
            sPara.Add("defaultbank=" + defaultbank);
            sPara.Add("anti_phishing_key=" + encrypt_key);
            sPara.Add("exter_invoke_ip=" + exter_invoke_ip);
            sPara.Add("extra_common_param=" + extra_common_param);
            sPara.Add("extend_param=isv^as11");
            sPara.Add("buyer_email=" + buyer_email);
            sPara.Add("royalty_type=" + royalty_type);
            sPara.Add("royalty_parameters=" + royalty_parameters);
            sPara.Add("it_b_pay=" + it_b_pay);

            sPara = AlipayFunction.Para_filter(sPara);
            sPara.Sort();   //得到从字母a到z排序后的加密参数数组
            //获得签名结果
            mysign = AlipayFunction.Build_mysign(sPara, _key, _sign_type, _input_charset);
        }

        /// <summary>
        /// 构造请求URL（GET方式请求）
        /// </summary>
        /// <returns>请求url</returns>
        public string Create_url()
        {
            string strUrl = gateway;
            string arg = AlipayFunction.Create_linkstring_urlencode(sPara);	//把数组所有元素，按照“参数=参数值”的模式用“&”字符拼接成字符串
            strUrl = strUrl + arg + "sign=" + mysign + "&sign_type=" + _sign_type;
            return strUrl;
        }

        /// <summary>
        /// 构造Post表单提交HTML（POST方式请求）
        /// </summary>
        /// <returns>输出 表单提交HTML文本</returns>
        public string Build_postform()
        {
            StringBuilder sbHtml = new StringBuilder();
            sbHtml.Append("<form id=\"alipaysubmit\" name=\"alipaysubmit\" action=\"" + gateway + "_input_charset=" + _input_charset + "\" method=\"post\">");

            int nCount = sPara.Count;
            int i;
            for (i = 0; i < nCount; i++)
            {
                //把sArray的数组里的元素格式：变量名=值，分割开来
                int nPos = sPara[i].ToString().IndexOf('=');              //获得=字符的位置
                int nLen = sPara[i].ToString().Length;                    //获得字符串长度
                string itemName = sPara[i].ToString().Substring(0, nPos); //获得变量名
                string itemValue = "";                                    //获得变量的值
                if (nPos + 1 < nLen)
                {
                    itemValue = sPara[i].ToString().Substring(nPos + 1);
                }

                sbHtml.Append("<input type=\"hidden\" name=\"" + itemName + "\" value=\"" + itemValue + "\"/>");
            }

            sbHtml.Append("<input type=\"hidden\" name=\"sign\" value=\"" + mysign + "\"/>");
            sbHtml.Append("<input type=\"hidden\" name=\"sign_type\" value=\"" + _sign_type + "\"/></form>");

            sbHtml.Append("<input type=\"button\" name=\"v_action\" value=\"支付宝确认付款\" onClick=\"document.forms['alipaysubmit'].submit();\">");

            return sbHtml.ToString();
        }
    }

    /// <summary>
    /// 担保交易接口
    /// </summary>
    public class AlipaySecuredTransactionsService
    {
        private static string gateway = "";                //网关地址
        private static string _key = "";                   //交易安全校验码
        private static string _input_charset = "";         //编码格式
        private static string _sign_type = "MD5";             //签名方式
        private string mysign = "";                 //签名结果
        private static string sHtmlText = "";
        private Dictionary<string, string> sPara = new Dictionary<string, string>();//要签名的字符串


        /// <summary>
        /// 构造函数
        /// 从配置文件及入口文件中初始化变量
        /// </summary>
        /// <param name="partner">合作身份者ID</param>
        /// <param name="seller_email">签约支付宝账号或卖家支付宝帐户</param>
        /// <param name="return_url">付完款后跳转的页面 要用 以http开头格式的完整路径，不允许加?id=123这类自定义参数</param>
        /// <param name="notify_url">交易过程中服务器通知的页面 要用 以http开格式的完整路径，不允许加?id=123这类自定义参数</param>
        /// <param name="show_url">网站商品的展示地址，不允许加?id=123这类自定义参数</param>
        /// <param name="out_trade_no">请与贵网站订单系统中的唯一订单号匹配</param>
        /// <param name="subject">订单名称，显示在支付宝收银台里的“商品名称”里，显示在支付宝的交易管理的“商品名称”的列表里。</param>
        /// <param name="body">订单描述、订单详细、订单备注，显示在支付宝收银台里的“商品描述”里</param>
        /// <param name="price">订单总金额，显示在支付宝收银台里的“商品单价”里</param>
        /// <param name="logistics_fee">物流费用，即运费。</param>
        /// <param name="logistics_type">物流类型，三个值可选：EXPRESS（快递）、POST（平邮）、EMS（EMS）</param>
        /// <param name="logistics_payment">物流支付方式，三个值可选：SELLER_PAY（卖家承担运费）、BUYER_PAY（买家承担运费）</param>
        /// <param name="quantity">商品数量，建议默认为1，不改变值，把一次交易看成是一次下订单而非购买一件商品。</param>
        /// <param name="receive_name">收货人姓名，如：张三</param>
        /// <param name="receive_address">收货人地址，如：XX省XXX市XXX区XXX路XXX小区XXX栋XXX单元XXX号</param>
        /// <param name="receive_zip">收货人邮编，如：123456</param>
        /// <param name="receive_phone">收货人电话号码，如：0571-81234567</param>
        /// <param name="receive_mobile">收货人手机号码，如：13312341234</param>
        /// <param name="logistics_fee_1">第二组物流费用，即运费。</param>
        /// <param name="logistics_type_1">第二组物流类型，三个值可选：EXPRESS（快递）、POST（平邮）、EMS（EMS）</param>
        /// <param name="logistics_payment_1">第二组物流支付方式，三个值可选：SELLER_PAY（卖家承担运费）、BUYER_PAY（买家承担运费）</param>
        /// <param name="logistics_fee_2">第三组物流费用，即运费。</param>
        /// <param name="logistics_type_2">第三组物流类型，三个值可选：EXPRESS（快递）、POST（平邮）、EMS（EMS）</param>
        /// <param name="logistics_payment_2">第三组物流支付方式，三个值可选：SELLER_PAY（卖家承担运费）、BUYER_PAY（买家承担运费）</param>
        /// <param name="buyer_email">默认买家支付宝账号</param>
        /// <param name="discount">折扣，是具体的金额，而不是百分比。若要使用打折，请使用负数，并保证小数点最多两位数</param>
        /// <param name="key">安全检验码</param>
        /// <param name="input_charset">字符编码格式 目前支持 gbk 或 utf-8</param>
        /// <param name="sign_type">加密方式 不需修改</param>
        public AlipaySecuredTransactionsService(string partner,
            string seller_email,
            string return_url,
            string notify_url,
            string show_url,
            string out_trade_no,
            string subject,
            string body,
            string price,
            string logistics_fee,
            string logistics_type,
            string logistics_payment,
            string quantity,
            string receive_name,
            string receive_address,
            string receive_zip,
            string receive_phone,
            string receive_mobile,
            string logistics_fee_1,
            string logistics_type_1,
            string logistics_payment_1,
            string logistics_fee_2,
            string logistics_type_2,
            string logistics_payment_2,
            string buyer_email,
            string discount,
            string key,
            string input_charset,
            string sign_type)
        {
            gateway = "https://mapi.alipay.com/gateway.do?";
            _key = key.Trim();
            _input_charset = input_charset.ToLower();
            _sign_type = sign_type.ToUpper();
            SortedDictionary<string, string> sParaTemp = new SortedDictionary<string, string>();

            sParaTemp.Add("partner", partner);
            sParaTemp.Add("_input_charset", _input_charset);
            sParaTemp.Add("service", "create_partner_trade_by_buyer");
            sParaTemp.Add("payment_type", "1");
            sParaTemp.Add("notify_url", notify_url);
            sParaTemp.Add("return_url", return_url);
            sParaTemp.Add("seller_email", seller_email);
            sParaTemp.Add("out_trade_no", out_trade_no);
            sParaTemp.Add("subject", subject);
            sParaTemp.Add("price", price);
            sParaTemp.Add("quantity", quantity);
            sParaTemp.Add("logistics_fee", logistics_fee);
            sParaTemp.Add("logistics_type", logistics_type);
            sParaTemp.Add("logistics_payment", logistics_payment);
            sParaTemp.Add("body", body);
            sParaTemp.Add("show_url", show_url);
            sParaTemp.Add("receive_name", receive_name);
            sParaTemp.Add("receive_address", receive_address);
            sParaTemp.Add("receive_zip", receive_zip);
            sParaTemp.Add("receive_phone", receive_phone);
            sParaTemp.Add("receive_mobile", receive_mobile);
            sHtmlText = BuildRequest(sParaTemp, "get", "确认");
        }
        /// <summary>
        /// 建立请求，以表单HTML形式构造（默认）
        /// </summary>
        /// <param name="sParaTemp">请求参数数组</param>
        /// <param name="strMethod">提交方式。两个值可选：post、get</param>
        /// <param name="strButtonValue">确认按钮显示文字</param>
        /// <returns>提交表单HTML文本</returns>
        public static string BuildRequest(SortedDictionary<string, string> sParaTemp, string strMethod, string strButtonValue)
        {
            //待请求参数数组
            Dictionary<string, string> dicPara = new Dictionary<string, string>();
            dicPara = BuildRequestPara(sParaTemp);

            StringBuilder sbHtml = new StringBuilder();

            sbHtml.Append("<form id='alipaysubmit' name='alipaysubmit' action='" + gateway + "_input_charset=" + _input_charset + "' method='" + strMethod.ToLower().Trim() + "'>");

            foreach (KeyValuePair<string, string> temp in dicPara)
            {
                sbHtml.Append("<input type='hidden' name='" + temp.Key + "' value='" + temp.Value + "'/>");
            }

            //submit按钮控件请不要含有name属性
            sbHtml.Append("<input type='submit' value='" + strButtonValue + "' style='display:none;'></form>");

            sbHtml.Append("<script>document.forms['alipaysubmit'].submit();</script>");

            return sbHtml.ToString();
        }
        private static Dictionary<string, string> BuildRequestPara(SortedDictionary<string, string> sParaTemp)
        {
            //待签名请求参数数组
            Dictionary<string, string> sPara = new Dictionary<string, string>();
            //签名结果
            string mysign = "";

            //过滤签名参数数组
            sPara = FilterPara(sParaTemp);

            //获得签名结果
            mysign = BuildRequestMysign(sPara);

            //签名结果与签名方式加入请求提交参数组中
            sPara.Add("sign", mysign);
            sPara.Add("sign_type", _sign_type);

            return sPara;
        }
        /// <summary>
        /// 除去数组中的空值和签名参数并以字母a到z的顺序排序
        /// </summary>
        /// <param name="dicArrayPre">过滤前的参数组</param>
        /// <returns>过滤后的参数组</returns>
        public static Dictionary<string, string> FilterPara(SortedDictionary<string, string> dicArrayPre)
        {
            Dictionary<string, string> dicArray = new Dictionary<string, string>();
            foreach (KeyValuePair<string, string> temp in dicArrayPre)
            {
                if (temp.Key.ToLower() != "sign" && temp.Key.ToLower() != "sign_type" && temp.Value != "" && temp.Value != null)
                {
                    dicArray.Add(temp.Key, temp.Value);
                }
            }

            return dicArray;
        }
        /// <summary>
        /// 生成请求时的签名
        /// </summary>
        /// <param name="sPara">请求给支付宝的参数数组</param>
        /// <returns>签名结果</returns>
        private static string BuildRequestMysign(Dictionary<string, string> sPara)
        {
            //把数组所有元素，按照“参数=参数值”的模式用“&”字符拼接成字符串
            string prestr = CreateLinkString(sPara);
            //把最终的字符串签名，获得签名结果
            string mysign = "";
            switch (_sign_type)
            {
                case "MD5":
                    mysign = Sign(prestr, _key, _input_charset);
                    break;
                default:
                    mysign = "";
                    break;
            }

            return mysign;
        }
        /// <summary>
        /// 签名字符串
        /// </summary>
        /// <param name="prestr">需要签名的字符串</param>
        /// <param name="key">密钥</param>
        /// <param name="_input_charset">编码格式</param>
        /// <returns>签名结果</returns>
        public static string Sign(string prestr, string key, string _input_charset)
        {
            StringBuilder sb = new StringBuilder(32);

            prestr = prestr + key;

            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] t = md5.ComputeHash(Encoding.GetEncoding(_input_charset).GetBytes(prestr));
            for (int i = 0; i < t.Length; i++)
            {
                sb.Append(t[i].ToString("x").PadLeft(2, '0'));
            }

            return sb.ToString();
        }
        /// <summary>
        /// 把数组所有元素，按照“参数=参数值”的模式用“&”字符拼接成字符串
        /// </summary>
        /// <param name="sArray">需要拼接的数组</param>
        /// <returns>拼接完成以后的字符串</returns>
        public static string CreateLinkString(Dictionary<string, string> dicArray)
        {
            StringBuilder prestr = new StringBuilder();
            foreach (KeyValuePair<string, string> temp in dicArray)
            {
                prestr.Append(temp.Key + "=" + temp.Value + "&");
            }

            //去掉最後一個&字符
            int nLen = prestr.Length;
            prestr.Remove(nLen - 1, 1);

            return prestr.ToString();
        }
        /// <summary>
        /// 构造表单提交HTML
        /// </summary>
        /// <returns>输出 表单提交HTML文本</returns>
        public string Build_Form()
        {
            StringBuilder sbHtml = new StringBuilder();

            //GET方式传递
            sbHtml.Append("<form id=\"alipaysubmit\" name=\"alipaysubmit\" action=\"" + gateway + "_input_charset=" + _input_charset + "\" method=\"get\">");

            //POST方式传递（GET与POST二必选一）
            //sbHtml.Append("<form id=\"alipaysubmit\" name=\"alipaysubmit\" action=\"" + gateway + "_input_charset=" + _input_charset + "\" method=\"post\">");

            foreach (KeyValuePair<string, string> temp in sPara)
            {
                sbHtml.Append("<input type=\"hidden\" name=\"" + temp.Key + "\" value=\"" + temp.Value + "\"/>");
            }

            sbHtml.Append("<input type=\"hidden\" name=\"sign\" value=\"" + mysign + "\"/>");
            sbHtml.Append("<input type=\"hidden\" name=\"sign_type\" value=\"" + _sign_type + "\"/>");

            //submit按钮控件请不要含有name属性
            sbHtml.Append("<input type=\"submit\" value=\"支付宝确认付款\"></form>");

            sbHtml.Append("<script>document.forms['alipaysubmit'].submit();</script>");

            return sbHtml.ToString();
        }

        /// <summary>
        /// 构造请求URL（GET方式请求）
        /// </summary>
        /// <returns>请求url</returns>
        public string Create_url()
        {
            return sHtmlText;
        }
    }


    /// <summary>
    /// 双接口
    /// </summary>
    public class AlipayService_Dual
    {
        private string gateway = "";                //网关地址
        private string _key = "";                   //交易安全校验码
        private string _input_charset = "";         //编码格式
        private string _sign_type = "";             //签名方式
        private string mysign = "";                 //签名结果
        private Dictionary<string, string> sPara = new Dictionary<string, string>();//要签名的字符串


        /// <summary>
        /// 构造函数
        /// 从配置文件及入口文件中初始化变量
        /// </summary>
        /// <param name="partner">合作身份者ID</param>
        /// <param name="seller_email">签约支付宝账号或卖家支付宝帐户</param>
        /// <param name="return_url">付完款后跳转的页面 要用 以http开头格式的完整路径，不允许加?id=123这类自定义参数</param>
        /// <param name="notify_url">交易过程中服务器通知的页面 要用 以http开格式的完整路径，不允许加?id=123这类自定义参数</param>
        /// <param name="show_url">网站商品的展示地址，不允许加?id=123这类自定义参数</param>
        /// <param name="out_trade_no">请与贵网站订单系统中的唯一订单号匹配</param>
        /// <param name="subject">订单名称，显示在支付宝收银台里的“商品名称”里，显示在支付宝的交易管理的“商品名称”的列表里。</param>
        /// <param name="body">订单描述、订单详细、订单备注，显示在支付宝收银台里的“商品描述”里</param>
        /// <param name="price">订单总金额，显示在支付宝收银台里的“商品单价”里</param>
        /// <param name="logistics_fee">物流费用，即运费。</param>
        /// <param name="logistics_type">物流类型，三个值可选：EXPRESS（快递）、POST（平邮）、EMS（EMS）</param>
        /// <param name="logistics_payment">物流支付方式，三个值可选：SELLER_PAY（卖家承担运费）、BUYER_PAY（买家承担运费）</param>
        /// <param name="quantity">商品数量，建议默认为1，不改变值，把一次交易看成是一次下订单而非购买一件商品。</param>
        /// <param name="receive_name">收货人姓名，如：张三</param>
        /// <param name="receive_address">收货人地址，如：XX省XXX市XXX区XXX路XXX小区XXX栋XXX单元XXX号</param>
        /// <param name="receive_zip">收货人邮编，如：123456</param>
        /// <param name="receive_phone">收货人电话号码，如：0571-81234567</param>
        /// <param name="receive_mobile">收货人手机号码，如：13312341234</param>
        /// <param name="logistics_fee_1">第二组物流费用，即运费。</param>
        /// <param name="logistics_type_1">第二组物流类型，三个值可选：EXPRESS（快递）、POST（平邮）、EMS（EMS）</param>
        /// <param name="logistics_payment_1">第二组物流支付方式，三个值可选：SELLER_PAY（卖家承担运费）、BUYER_PAY（买家承担运费）</param>
        /// <param name="logistics_fee_2">第三组物流费用，即运费。</param>
        /// <param name="logistics_type_2">第三组物流类型，三个值可选：EXPRESS（快递）、POST（平邮）、EMS（EMS）</param>
        /// <param name="logistics_payment_2">第三组物流支付方式，三个值可选：SELLER_PAY（卖家承担运费）、BUYER_PAY（买家承担运费）</param>
        /// <param name="buyer_email">默认买家支付宝账号</param>
        /// <param name="discount">折扣，是具体的金额，而不是百分比。若要使用打折，请使用负数，并保证小数点最多两位数</param>
        /// <param name="key">安全检验码</param>
        /// <param name="input_charset">字符编码格式 目前支持 gbk 或 utf-8</param>
        /// <param name="token">大快捷登录需要传过来token值</param>
        /// <param name="sign_type">加密方式 不需修改</param>
        public AlipayService_Dual(string partner,
            string seller_email,
            string return_url,
            string notify_url,
            string show_url,
            string out_trade_no,
            string subject,
            string body,
            string price,
            string logistics_fee,
            string logistics_type,
            string logistics_payment,
            string quantity,
            string receive_name,
            string receive_address,
            string receive_zip,
            string receive_phone,
            string receive_mobile,
            string logistics_fee_1,
            string logistics_type_1,
            string logistics_payment_1,
            string logistics_fee_2,
            string logistics_type_2,
            string logistics_payment_2,
            string buyer_email,
            string discount,
            string key,
            string input_charset,
            string token,
            string sign_type)
        {
            gateway = "https://www.alipay.com/cooperate/gateway.do?";
            _key = key.Trim();
            _input_charset = input_charset.ToLower();
            _sign_type = sign_type.ToUpper();
            SortedDictionary<string, string> sParaTemp = new SortedDictionary<string, string>();
            //构造加密参数数组，以下顺序请不要更改（由a到z排序）
            sParaTemp.Add("_input_charset", _input_charset);
            sParaTemp.Add("body", body);
            sParaTemp.Add("buyer_email", buyer_email);
            sParaTemp.Add("discount", discount);
            sParaTemp.Add("extend_param", "isv^as11");
            sParaTemp.Add("logistics_fee", logistics_fee);
            sParaTemp.Add("logistics_fee_1", logistics_fee_1);
            sParaTemp.Add("logistics_fee_2", logistics_fee_2);
            sParaTemp.Add("logistics_payment", logistics_payment);
            sParaTemp.Add("logistics_payment_1", logistics_payment_1);
            sParaTemp.Add("logistics_payment_2", logistics_payment_2);
            sParaTemp.Add("logistics_type", logistics_type);
            sParaTemp.Add("logistics_type_1", logistics_type_1);
            sParaTemp.Add("logistics_type_2", logistics_type_2);
            sParaTemp.Add("notify_url", notify_url);
            sParaTemp.Add("out_trade_no", out_trade_no);
            sParaTemp.Add("partner", partner);
            sParaTemp.Add("payment_type", "1");
            sParaTemp.Add("price", price);
            sParaTemp.Add("quantity", quantity);
            sParaTemp.Add("receive_address", receive_address);
            sParaTemp.Add("receive_mobile", receive_mobile);
            sParaTemp.Add("receive_name", receive_name);
            sParaTemp.Add("receive_phone", receive_phone);
            sParaTemp.Add("receive_zip", receive_zip);
            sParaTemp.Add("return_url", return_url);
            sParaTemp.Add("seller_email", seller_email);
            sParaTemp.Add("service", "trade_create_by_buyer");
            sParaTemp.Add("show_url", show_url);
            sParaTemp.Add("subject", subject);
            sParaTemp.Add("token", token);
            //构造加密参数数组，以上顺序请不要更改（由a到z排序）
            sPara = AlipayFunction.Para_filter(sParaTemp);
            //获得签名结果
            mysign = AlipayFunction.Build_mysign(sPara, _key, _sign_type, _input_charset);
        }






        /// <summary>
        /// 构造函数
        /// 从配置文件及入口文件中初始化变量
        /// </summary>
        /// <param name="partner">合作身份者ID</param>
        /// <param name="seller_email">签约支付宝账号或卖家支付宝帐户</param>
        /// <param name="return_url">付完款后跳转的页面 要用 以http开头格式的完整路径，不允许加?id=123这类自定义参数</param>
        /// <param name="notify_url">交易过程中服务器通知的页面 要用 以http开格式的完整路径，不允许加?id=123这类自定义参数</param>
        /// <param name="show_url">网站商品的展示地址，不允许加?id=123这类自定义参数</param>
        /// <param name="out_trade_no">请与贵网站订单系统中的唯一订单号匹配</param>
        /// <param name="subject">订单名称，显示在支付宝收银台里的“商品名称”里，显示在支付宝的交易管理的“商品名称”的列表里。</param>
        /// <param name="body">订单描述、订单详细、订单备注，显示在支付宝收银台里的“商品描述”里</param>
        /// <param name="price">订单总金额，显示在支付宝收银台里的“商品单价”里</param>
        /// <param name="logistics_fee">物流费用，即运费。</param>
        /// <param name="logistics_type">物流类型，三个值可选：EXPRESS（快递）、POST（平邮）、EMS（EMS）</param>
        /// <param name="logistics_payment">物流支付方式，三个值可选：SELLER_PAY（卖家承担运费）、BUYER_PAY（买家承担运费）</param>
        /// <param name="quantity">商品数量，建议默认为1，不改变值，把一次交易看成是一次下订单而非购买一件商品。</param>
        /// <param name="receive_name">收货人姓名，如：张三</param>
        /// <param name="receive_address">收货人地址，如：XX省XXX市XXX区XXX路XXX小区XXX栋XXX单元XXX号</param>
        /// <param name="receive_zip">收货人邮编，如：123456</param>
        /// <param name="receive_phone">收货人电话号码，如：0571-81234567</param>
        /// <param name="receive_mobile">收货人手机号码，如：13312341234</param>
        /// <param name="logistics_fee_1">第二组物流费用，即运费。</param>
        /// <param name="logistics_type_1">第二组物流类型，三个值可选：EXPRESS（快递）、POST（平邮）、EMS（EMS）</param>
        /// <param name="logistics_payment_1">第二组物流支付方式，三个值可选：SELLER_PAY（卖家承担运费）、BUYER_PAY（买家承担运费）</param>
        /// <param name="logistics_fee_2">第三组物流费用，即运费。</param>
        /// <param name="logistics_type_2">第三组物流类型，三个值可选：EXPRESS（快递）、POST（平邮）、EMS（EMS）</param>
        /// <param name="logistics_payment_2">第三组物流支付方式，三个值可选：SELLER_PAY（卖家承担运费）、BUYER_PAY（买家承担运费）</param>
        /// <param name="buyer_email">默认买家支付宝账号</param>
        /// <param name="discount">折扣，是具体的金额，而不是百分比。若要使用打折，请使用负数，并保证小数点最多两位数</param>
        /// <param name="key">安全检验码</param>
        /// <param name="input_charset">字符编码格式 目前支持 gbk 或 utf-8</param>
        /// <param name="sign_type">加密方式 不需修改</param>
        public AlipayService_Dual(string partner,
            string seller_email,
            string return_url,
            string notify_url,
            string show_url,
            string out_trade_no,
            string subject,
            string body,
            string price,
            string logistics_fee,
            string logistics_type,
            string logistics_payment,
            string quantity,
            string receive_name,
            string receive_address,
            string receive_zip,
            string receive_phone,
            string receive_mobile,
            string logistics_fee_1,
            string logistics_type_1,
            string logistics_payment_1,
            string logistics_fee_2,
            string logistics_type_2,
            string logistics_payment_2,
            string buyer_email,
            string discount,
            string key,
            string input_charset,
            string sign_type)
        {
            //gateway = "https://www.alipay.com/cooperate/gateway.do?";
            //支付宝网关地址（新）
            gateway = "https://mapi.alipay.com/gateway.do?";
           
            _key = key.Trim();
            _input_charset = input_charset.ToLower();
            _sign_type = sign_type.ToUpper();
            SortedDictionary<string, string> sParaTemp = new SortedDictionary<string, string>();
            //sParaTemp.Add("_input_charset", "utf-8");
            //sParaTemp.Add("body", String.Empty);
            //sParaTemp.Add("buyer_email", String.Empty);
            //sParaTemp.Add("discount", String.Empty);
            //sParaTemp.Add("logistics_fee", "0.00");
            //sParaTemp.Add("logistics_fee_1", String.Empty);
            //sParaTemp.Add("logistics_fee_2", String.Empty);
            //sParaTemp.Add("logistics_payment", "SELLER_PAY");
            //sParaTemp.Add("logistics_payment_1", String.Empty);
            //sParaTemp.Add("logistics_payment_2", String.Empty);
            //sParaTemp.Add("logistics_type", "EXPRESS");
            //sParaTemp.Add("logistics_type_1", String.Empty);
            //sParaTemp.Add("logistics_type_2", String.Empty);
            //sParaTemp.Add("notify_url", "http://www.xxx.com/dj_vs2005_utf8/notify_url.aspx");
            //sParaTemp.Add("out_trade_no", "20110322181919");
            //sParaTemp.Add("partner", "2088102068786600");
            //sParaTemp.Add("payment_type", "1");
            //sParaTemp.Add("price", "0.01");
            //sParaTemp.Add("quantity", "1");
            //sParaTemp.Add("receive_address", "收货人地址");
            //sParaTemp.Add("receive_mobile", "13312341234");
            //sParaTemp.Add("receive_name", "收货人姓名");
            //sParaTemp.Add("receive_phone", "0571-81234567");
            //sParaTemp.Add("receive_zip", "123456");
            //sParaTemp.Add("return_url", "http://localhost:12099/dj_vs2005_utf8/return_url.aspx");
            //sParaTemp.Add("seller_email", "tao@kulihu.com");
            //sParaTemp.Add("service", "trade_create_by_buyer");
            //sParaTemp.Add("show_url", "http://www.xxx.com/myorder.aspx");
            //sParaTemp.Add("subject", "1");
            //构造加密参数数组，以下顺序请不要更改（由a到z排序）
            sParaTemp.Add("_input_charset", _input_charset);
            sParaTemp.Add("body", body);
            sParaTemp.Add("buyer_email", buyer_email);
            sParaTemp.Add("discount", discount);
            sParaTemp.Add("extend_param", "isv^as11");
            sParaTemp.Add("logistics_fee", logistics_fee);
            sParaTemp.Add("logistics_fee_1", logistics_fee_1);
            sParaTemp.Add("logistics_fee_2", logistics_fee_2);
            sParaTemp.Add("logistics_payment", logistics_payment);
            sParaTemp.Add("logistics_payment_1", logistics_payment_1);
            sParaTemp.Add("logistics_payment_2", logistics_payment_2);
            sParaTemp.Add("logistics_type", logistics_type);
            sParaTemp.Add("logistics_type_1", logistics_type_1);
            sParaTemp.Add("logistics_type_2", logistics_type_2);
            sParaTemp.Add("notify_url", notify_url);
            sParaTemp.Add("out_trade_no", out_trade_no);
            sParaTemp.Add("partner", partner);
            sParaTemp.Add("payment_type", "1");
            sParaTemp.Add("price", price);
            sParaTemp.Add("quantity", quantity);
            sParaTemp.Add("receive_address", receive_address);
            sParaTemp.Add("receive_mobile", receive_mobile);
            sParaTemp.Add("receive_name", receive_name);
            sParaTemp.Add("receive_phone", receive_phone);
            sParaTemp.Add("receive_zip", receive_zip);
            sParaTemp.Add("return_url", return_url);
            sParaTemp.Add("seller_email", seller_email);
            sParaTemp.Add("service", "trade_create_by_buyer");
            sParaTemp.Add("show_url", show_url);
            sParaTemp.Add("subject", subject);
            //构造加密参数数组，以上顺序请不要更改（由a到z排序）
            sPara = AlipayFunction.Para_filter(sParaTemp);
            //获得签名结果
            mysign = AlipayFunction.Build_mysign(sPara, _key, _sign_type, _input_charset);
        }

        public string Create_url()
        {
            string strUrl = gateway;
            string arg = AlipayFunction.Create_linkstring_urlencode(sPara);	//把数组所有元素，按照“参数=参数值”的模式用“&”字符拼接成字符串
            strUrl = strUrl + arg + "&sign=" + mysign + "&sign_type=" + _sign_type;
            return strUrl;
        }
    }


}