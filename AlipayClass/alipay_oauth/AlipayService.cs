using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace AlipayClass.alipay_oauth
{
    /// <summary>
    /// 类名：Service
    /// 功能：支付宝各接口构造类
    /// 详细：构造支付宝各接口请求参数
    /// 版本：3.2
    /// 修改日期：2011-03-17
    /// 说明：
    /// 以下代码只是为了方便商户测试而提供的样例代码，商户可以根据自己网站的需要，按照技术文档编写,并非一定要使用该代码。
    /// 该代码仅供学习和研究支付宝接口使用，只是提供一个参考
    /// 
    /// 要传递的参数要么不允许为空，要么就不要出现在数组与隐藏控件或URL链接里。
    /// </summary>
    public class AlipayService
    {
        #region 字段
        //合作者身份ID
        private string _partner = "";
        //编码格式
        private static string _input_charset = "";
        //支付宝网关地址（新）
        private string GATEWAY_NEW = "https://mapi.alipay.com/gateway.do?";
        //支付宝网关地址（旧）
        private string GATEWAY_OLD = "https://www.alipay.com/cooperate/gateway.do?";
        #endregion

        /// <summary>
        /// 构造函数
        /// 从配置文件及入口文件中初始化变量
        /// </summary>
        public AlipayService()
        {
            _partner = Config.Partner.Trim();
            _input_charset = Config.Input_charset.Trim().ToLower();
        }

        /// <summary>
        /// 构造快捷登录接口
        /// </summary>
        /// <param name="anti_phishing_key">防钓鱼时间戳</param>
        /// <param name="exter_invoke_ip">买家本地电脑的IP地址</param>
        /// <returns>表单提交HTML信息</returns>
        public string Alipay_auth_authorize(
            string anti_phishing_key,
            string exter_invoke_ip)
        {
            //临时请求参数数组
            SortedDictionary<string, string> sParaTemp = new SortedDictionary<string, string>();
            //确认按钮显示文字
            string strButtonValue = "支付宝快捷登录";
            //表单提交HTML数据
            string strHtml = "";

            //构造请求参数数组
            sParaTemp.Add("service", "alipay.auth.authorize");
            sParaTemp.Add("target_service", "user.auth.quick.login");
            sParaTemp.Add("partner", _partner);
            sParaTemp.Add("_input_charset", _input_charset);
            sParaTemp.Add("return_url", Config.Return_url);
            sParaTemp.Add("anti_phishing_key", anti_phishing_key);
            sParaTemp.Add("exter_invoke_ip", exter_invoke_ip);

            //构造表单提交HTML数据
            strHtml = Submit.BuildFormHtml(sParaTemp, GATEWAY_NEW, "get", strButtonValue);

            return strHtml;
        }
        /// <summary>
        /// 构造快捷登录接口拼接URL
        /// </summary>
        /// <param name="anti_phishing_key">防钓鱼时间戳</param>
        /// <param name="exter_invoke_ip">买家本地电脑的IP地址</param>
        /// <returns>表单提交HTML信息</returns>
        public string Alipay_auth_authorizeURL(
            string anti_phishing_key,
            string exter_invoke_ip)
        {
            //临时请求参数数组
            SortedDictionary<string, string> sParaTemp = new SortedDictionary<string, string>();
            //确认按钮显示文字
            string strButtonValue = "支付宝快捷登录";
            //表单提交HTML数据
            string strHtml = "";

            //构造请求参数数组
            sParaTemp.Add("service", "alipay.auth.authorize");
            sParaTemp.Add("target_service", "user.auth.quick.login");
            sParaTemp.Add("partner", _partner);
            sParaTemp.Add("_input_charset", _input_charset);
            sParaTemp.Add("return_url", Config.Return_url);
            sParaTemp.Add("anti_phishing_key", anti_phishing_key);
            sParaTemp.Add("exter_invoke_ip", exter_invoke_ip);

            //构造表单提交HTML数据
            strHtml = Submit.BuildFormURL(sParaTemp, GATEWAY_NEW, "get", strButtonValue);
            return strHtml;
        }

        /// <summary>
        /// 用于防钓鱼，调用接口query_timestamp来获取时间戳的处理函数
        /// 注意：远程解析XML出错，与IIS服务器配置有关
        /// </summary>
        /// <returns>时间戳字符串</returns>
        public string Query_timestamp()
        {
            string url = GATEWAY_NEW + "service=query_timestamp&partner=" + Config.Partner;
            string encrypt_key = "";

            XmlTextReader Reader = new XmlTextReader(url);
            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.Load(Reader);

            encrypt_key = xmlDoc.SelectSingleNode("/alipay/response/timestamp/encrypt_key").InnerText;

            return encrypt_key;
        }




        //******************若要增加其他支付宝接口，可以按照下面的格式定义******************//
        /// <summary>
        /// 构造(支付宝接口名称)接口
        /// </summary>
        /// <param name="para1">请求参数1</param>
        /// <param name="para2">请求参数2</param>
        /// <param name="paraN">请求参数N</param>
        /// <returns>表单提交HTML文本或者支付宝返回XML处理结果</returns>
        public string AlipayInterface(
            string para1,
            string para2,
            string paraN)
        {
            //临时请求参数数组变量

            //确认按钮显示文字变量

            //表单提交HTML数据变量
            string strHtml = "";


            //构造请求参数数组


            //构造给支付宝处理的请求
            //请求方式有以下三种：
            //1.构造表单提交HTML数据:Submit.BuildFormHtml()
            //2.构造模拟远程HTTP的POST请求，获取支付宝的返回XML处理结果:Submit.SendPostInfo()
            //3.构造模拟远程HTTP的GET请求，获取支付宝的返回XML处理结果:Submit.SendGetInfo()
            //请根据不同的接口特性三选一


            return strHtml;
        }
    }
}
