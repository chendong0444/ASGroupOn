using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using System.IO;

namespace AlipayClass.alipayReceive
{
    /// <summary>
    /// 类名：Notify
    /// 功能：支付宝通知处理类
    /// 详细：处理支付宝各接口通知返回
    /// 版本：3.2
    /// 修改日期：2011-03-17
    /// '说明：
    /// 以下代码只是为了方便商户测试而提供的样例代码，商户可以根据自己网站的需要，按照技术文档编写,并非一定要使用该代码。
    /// 该代码仅供学习和研究支付宝接口使用，只是提供一个参考。
    /// 
    /// //////////////////////注意/////////////////////////////
    /// 调试通知返回时，可查看或改写log日志的写入TXT里的数据，来检查通知返回是否正常 
    /// </summary>
    public class Notify
    {
        #region 字段
        private string _transport = "";             //访问模式
        private string _partner = "";               //合作身份者ID
        private string _key = "";                   //交易安全校验码
        private string _input_charset = "";         //编码格式
        private string _sign_type = "";             //签名方式
        private string _veryfy_url = "";            //通知校验地址
        private Dictionary<string, string> sPara = new Dictionary<string, string>();//要签名的参数组

        //HTTPS支付宝通知路径
        private string Https_veryfy_url = "https://www.alipay.com/cooperate/gateway.do?service=notify_verify&";
        //HTTP支付宝通知路径
        private string Http_veryfy_url = "http://notify.alipay.com/trade/notify_query.do?";

        private string preSignStr = "";             //待签名的字符串
        private string mysign = "";                 //签名结果
        private string responseTxt = "";            //服务器ATN结果
        #endregion

        /// <summary>
        /// 获取通知返回后计算后（验证）的签名结果
        /// </summary>
        public string Mysign
        {
            get { return mysign; }
        }

        /// <summary>
        /// 获取验证是否是支付宝服务器发来的请求结果
        /// </summary>
        public string ResponseTxt
        {
            get { return responseTxt; }
        }

        /// <summary>
        /// 获取待签名的字符串（调试用）
        /// </summary>
        public string PreSignStr
        {
            get { return preSignStr; }
        }

        /// <summary>
        /// 构造函数
        /// 从配置文件中初始化变量
        /// </summary>
        /// <param name="inputPara">通知返回参数数组</param>
        /// <param name="notify_id">通知验证ID</param>
        public Notify(SortedDictionary<string, string> inputPara, string notify_id)
        {
            //初始化基础配置信息
            _partner = Config.Partner.Trim();
            _key = Config.Key.Trim().ToLower();
            _input_charset = Config.Input_charset.Trim().ToLower();
            _sign_type = Config.Sign_type.Trim().ToUpper();
            _transport = Config.Transport.Trim().ToLower();
            _veryfy_url = _transport == "https" ? Https_veryfy_url : Http_veryfy_url;
            _veryfy_url += "partner=" + _partner + "&notify_id=" + notify_id;

            //过滤空值、sign与sign_type参数
            sPara = Function.FilterPara(inputPara);

            //获取待签名字符串（调试用）
            preSignStr = Function.CreateLinkString(sPara);

            //获得签名结果
            mysign = Function.BuildMysign(sPara, _key, _sign_type, _input_charset);

            //获取远程服务器ATN结果，验证是否是支付宝服务器发来的请求
            responseTxt = Get_Http(_veryfy_url, 120000);
        }

        /// <summary>
        /// 获取远程服务器ATN结果
        /// </summary>
        /// <param name="strUrl">指定URL路径地址</param>
        /// <param name="timeout">超时时间设置</param>
        /// <returns>服务器ATN结果</returns>
        private string Get_Http(string strUrl, int timeout)
        {
            string strResult;
            try
            {
                HttpWebRequest myReq = (HttpWebRequest)HttpWebRequest.Create(strUrl);
                myReq.Timeout = timeout;
                HttpWebResponse HttpWResp = (HttpWebResponse)myReq.GetResponse();
                Stream myStream = HttpWResp.GetResponseStream();
                StreamReader sr = new StreamReader(myStream, Encoding.Default);
                StringBuilder strBuilder = new StringBuilder();
                while (-1 != sr.Peek())
                {
                    strBuilder.Append(sr.ReadLine());
                }

                strResult = strBuilder.ToString();
            }
            catch (Exception exp)
            {
                strResult = "错误：" + exp.Message;
            }

            return strResult;
        }
    }
}
