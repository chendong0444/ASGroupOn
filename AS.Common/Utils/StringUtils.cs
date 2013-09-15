using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Security.Cryptography;
using System.Web;
using System.Text.RegularExpressions;
using System.Collections.Specialized;
using System.Data;
namespace AS.Common.Utils
{
   public class StringUtils
    {
        /// <summary>
        /// 字符串截取
        /// </summary>
        /// <param name="str">需要截取的字符串</param>
        /// <param name="num">截取长度</param>
        /// <returns></returns>
        public static string SubString(string str, int num)
        {
            return SubString(str, num, false);
        }

        /// <summary>
        /// 字符串截取
        /// </summary>
        /// <param name="str">需要截取的字符串</param>
        /// <param name="num">截取长度</param>
        /// <param name="defaultchar">需要以......返回</param>
        /// <returns></returns>
        public static string SubString(string str, int num, bool defaultchar)
        {
            if (num < 1)
            {
                return "";
            }
            int i = str.Length;
            if (i == 0)
            {
                return "";
            }
            string tempstr = "";
            string temptempstr = "";
            int x = 0;
            int j = 0;
            while (x < i)
            {
                char c = str[x];
                if ((int)c > 256)
                {
                    j = j + 2;
                    if (j > num)
                    {
                        if (defaultchar && x + 1 < i)
                            return temptempstr + "......";
                        return tempstr;
                    }
                    else if (j == num)
                    {
                        if (defaultchar && x + 1 < i)
                            return temptempstr + "......";
                        tempstr = tempstr + c.ToString();
                        return tempstr;
                    }
                }
                else
                {
                    j = j + 1;
                    if (j == num)
                    {
                        if (defaultchar && x + 1 < i)
                            return temptempstr + "......";
                        tempstr = tempstr + c.ToString();
                        return tempstr;
                    }
                }
                tempstr = tempstr + c.ToString();
                if (defaultchar && j < num - 6)
                    temptempstr = temptempstr + c.ToString();
                else
                    temptempstr = tempstr;
                x = x + 1;
            }
            return tempstr;

        }


        /// <summary>
        /// 字符串截取
        /// </summary>
        /// <param name="str"></param>
        /// <param name="num"></param>
        /// <returns></returns>
        public static string SubString(string str, int startnum, string ensstr)
        {

            if (str.IndexOf(ensstr) > 0)
            {

                str = str.Substring(startnum, str.LastIndexOf(ensstr));
            }

            return str;

        }

        private static System.Random ran = new Random();
        /// <summary>
        /// 返回指定的随机数字字符
        /// </summary>
        /// <param name="bit"></param>
        /// <returns></returns>
        public static string GetRandomString(int bit)
        {
            string val = ran.Next(1, 10).ToString();
            for (int i = 1; i < bit; i++)
            {
                val = val + ran.Next(0, 10).ToString();
            }
            return val;

        }


        /// <summary>
        /// MD5加密
        /// </summary>
        /// <param name="str">需要加密的字符串</param>
        /// <returns></returns>
        public static string MD5(string input)
        {
            System.Security.Cryptography.MD5CryptoServiceProvider md5Hasher = new System.Security.Cryptography.MD5CryptoServiceProvider();
            byte[] data = md5Hasher.ComputeHash(Encoding.UTF8.GetBytes(input));
            StringBuilder sBuilder = new StringBuilder();
            for (int i = 0; i < data.Length; i++)
            {
                sBuilder.Append(data[i].ToString("x2"));
            }
            return sBuilder.ToString();

        }


        /// <summary>
        /// 使用gb2312编码方式进行url解码
        /// </summary>
        /// <param name="gb2312urlcode">gb2312的url编码</param>
        /// <returns></returns>
        public static string GB2312UrlDecode(string gb2312urlcode)
        {
            return System.Web.HttpUtility.UrlDecode(gb2312urlcode, System.Text.Encoding.GetEncoding("GB2312"));
        }


        /// <summary>
        /// 加密方法
        /// </summary>
        /// <param name="input">要加密的字符串</param>
        /// <param name="key">密钥</param>
        /// <returns></returns>
        public static string EncryptData(string input, string key)
        {
            byte[] key_byte = System.Text.Encoding.UTF8.GetBytes(key);
            byte[] iv = new byte[] { 12, 34, 54, 23, 66, 128, 243, 221 };
            MemoryStream ms = new MemoryStream();
            DES des = new DESCryptoServiceProvider();
            CryptoStream encStream = new CryptoStream(ms, des.CreateEncryptor(key_byte, iv), CryptoStreamMode.Write);
            StreamWriter sw = new StreamWriter(encStream);
            sw.Write(input);
            sw.Close();
            encStream.Close();
            byte[] buffer = ms.ToArray();
            ms.Close();
            return HttpServerUtility.UrlTokenEncode(buffer);
        }

        /// <summary>
        /// 解密
        /// </summary>
        /// <param name="input">要解密的字符串</param>
        /// <param name="key">密钥</param>
        /// <returns></returns>
        public static string DecryptData(string input, string key)
        {
            byte[] key_byte = System.Text.Encoding.UTF8.GetBytes(key);
            byte[] iv = new byte[] { 12, 34, 54, 23, 66, 128, 243, 221 };
            byte[] buffer = HttpServerUtility.UrlTokenDecode(input);
            MemoryStream ms = new MemoryStream(buffer);
            DES des = new DESCryptoServiceProvider();
            CryptoStream decStream = new CryptoStream(ms, des.CreateDecryptor(key_byte, iv), CryptoStreamMode.Read);
            StreamReader sr = new StreamReader(decStream);
            string val = sr.ReadLine();
            ms.Close();
            decStream.Close();
            sr.Close();
            return val;
        }

        ///   <summary>  
        ///   去除HTML标记  
        ///   </summary>  
        ///   <param   name="NoHTML">包括HTML的源码   </param>  
        ///   <returns>已经去除后的文字</returns>  
        public static string NoHTML(string Htmlstring)
        {
            //删除脚本  
            Htmlstring = Regex.Replace(Htmlstring, @"<script[^>]*?>.*?</script>", "", RegexOptions.IgnoreCase);
            //删除HTML  
            Htmlstring = Regex.Replace(Htmlstring, @"<(.[^>]*)>", "", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"([\r\n])[\s]+", "", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"-->", "", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"<!--.*", "", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"&(quot|#34);", "\"", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"&(amp|#38);", "&", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"&(lt|#60);", "<", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"&(gt|#62);", ">", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"&(nbsp|#160);", "   ", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"&(iexcl|#161);", "\xa1", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"&(cent|#162);", "\xa2", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"&(pound|#163);", "\xa3", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"&(copy|#169);", "\xa9", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, @"&#(\d+);", "", RegexOptions.IgnoreCase);
            Htmlstring = Regex.Replace(Htmlstring, "\\s+", "");
            Htmlstring.Replace("<", "");
            Htmlstring.Replace(">", "");
            Htmlstring.Replace("\r\n", "");
            Htmlstring = HttpContext.Current.Server.HtmlEncode(Htmlstring).Trim();

            return Htmlstring;
        }

        /// <summary>
        /// 验证数据格式
        /// </summary>
        /// <param name="data">字符串</param>
        /// <param name="datatype">验证类型</param>
        /// <returns>true验证成功,false失败</returns>
        public static bool ValidateString(string data, string datatype)
        {
            bool ok = false;//返回结果 
            if (datatype == String.Empty)
                return ok;
            Regex regex = null;
            datatype = datatype.ToLower();
            switch (datatype)
            {
                case "email":  //email格式
                    regex = new Regex(@"\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*");
                    break;
                case "domain"://域名格式
                    regex = new Regex(@"^\w+([-.]\w+)*\.\w+([-.]\w+)*$");
                    break;
                case "phone"://座机电话格式
                    regex = new Regex(@"^((\(\d{2,3}\))|(\d{3}\-))?(\(0\d{2,3}\)|0\d{2,3}-)?[1-9]\d{6,7}(\-\d{1,4})?$");
                    break;
                case "mobile"://手机格式
                    //  regex = new Regex(@"^13\d{9}$|^15\d{9}$|^18\d{9}$|^0\d{9,10}$");
                    regex = new Regex(@"^13\d{9}$|^15\d{9}$|^14\d{9}$|^18\d{9}$|^0\d{9,10}$");
                    break;
                case "url"://url格式
                    regex = new Regex("^http:\\/\\/[A-Za-z0-9]+\\.[A-Za-z0-9]+[\\/=\\?%\\-&_~`@[\\]\':+!]*([^<>\"\"])*$");
                    break;
                case "money"://货币
                    regex = new Regex(@"^\d+(\.\d+)?$");
                    break;
                case "number"://正整数
                    regex = new Regex(@"^\d+$");
                    break;
                case "zip"://邮编
                    regex = new Regex(@"^\d{6}$");
                    break;
                case "ip"://IP地址
                    regex = new Regex(@"^[\d\.]{7,15}$");
                    break;
                case "qq"://QQ号
                    regex = new Regex(@"^[1-9]\d{4,11}$");
                    break;
                case "integer"://整型
                    regex = new Regex(@"^[-\+]?\d+$");
                    break;
                case "double"://浮点数
                    regex = new Regex(@"^[-\+]?\d+(\.\d+)?$");
                    break;
                case "english"://英文
                    regex = new Regex(@"^[A-Za-z]+$");
                    break;
                case "chinese"://中文
                    regex = new Regex(@"^[\u0391-\uFFE5]+$");
                    break;
                case "enandcn"://中文和英文
                    regex = new Regex(@"^[\w\u0391-\uFFE5][\w\u0391-\uFFE5\-\.]+$");
                    break;
                case "username"://用户名 可以为中文,英文字符,数字
                    regex = new Regex(@"^[\w\u0391-\uFFE5][\w\u0391-\uFFE5\-\.A-Za-z]+$");
                    break;
            }
            if (regex != null)
            {
                ok = regex.IsMatch(data);
            }
            return ok;
        }

        /// <summary>
        /// 删除指定字符串两端的字符和重复的字符
        /// </summary>
        /// <param name="str"></param>
        /// <param name="c"></param>
        /// <returns></returns>
        public static string DelSideChar(string str, char c)
        {
            str = str.Replace(",,", ",");
            if (str.Length > 0 && str[0] == c)
                str = str.Substring(1);
            if (str.Length > 0 && str[str.Length - 1] == c)
            {
                str = str.Substring(0, str.Length - 1);
            }
            return str;
        }

        /// <summary>
        /// 将字符串转换为可以在url中传输的base64编码
        /// </summary>
        /// <param name="srcStr"></param>
        /// <returns></returns>
        public static string GetUrlBase64(string srcStr)
        {
            byte[] bytes = System.Text.Encoding.UTF8.GetBytes(srcStr);
            return HttpServerUtility.UrlTokenEncode(bytes);
        }
       /// <summary>
        /// 将可以在url中传输的base64编码转换为正常字符
       /// </summary>
       /// <param name="base64Str"></param>
       /// <returns></returns>
        public static string GetUrlFromBase64(string base64Str)
        {
            try
            {
                byte[] bytes = HttpServerUtility.UrlTokenDecode(base64Str);
                return System.Text.Encoding.UTF8.GetString(bytes);
            }
            catch { return String.Empty; }
        }

       /// <summary>
       /// 返回字符串的字节长度
       /// </summary>
       /// <param name="str">字符串</param>
       /// <returns></returns>
        public static int GetStringByteLength(string str)
        {
            if (String.IsNullOrEmpty(str))
            {
                return 0;
            }
            int i = str.Length;
            int x = 0;
            int j = 0;
            while (x < i)
            {
                char c = str[x];
                if ((int)c > 256)
                {
                    j = j + 2;
                }
                else
                {
                    j = j + 1;
                }
                x = x + 1;
            }
            return j;
        }

        /// <summary>
        /// 返回分页代码
        /// </summary>
        /// <param name="pagesize">每页记录数</param>
        /// <param name="recordcount">总记录数</param>
        /// <param name="currentpage">当前页码</param>
        /// <param name="urlformat"><![CDATA[格式化的url 例如:index.aspx?a=3&b=4&page={0} {0}代表将要替换的页码]]></param>
        /// <returns></returns>
        public static string GetPagerHtml(int pagesize, int recordcount, int currentpage, string urlformat)
        {
            StringBuilder html = new StringBuilder();
            html.Append("<ul class=\"paginator\"> ");
            if (recordcount > 0)
            {

                int totalpage = recordcount / pagesize + ((recordcount % pagesize > 0) ? 1 : 0);
                if (currentpage < 1) currentpage = 1;
                if (currentpage > totalpage) currentpage = totalpage;
                html.Append("<li><a>共" + recordcount + "条</a></li>");
                if (currentpage > 1)
                {
                    html.Append("<li><a href=\"" + String.Format(urlformat, 1) + "\">首页</a></li><li><a href=\"" + String.Format(urlformat, currentpage - 1) + "\">上一页</a></li>");
                }
                int i = currentpage - 4;
                if (i < 1) i = 1;
                int j = 1;
                while (i <= totalpage && j <= 9)
                {
                    if (i == currentpage)
                        html.AppendFormat("<li style=\" margin: 0 6px;\" ><font style=\"color:red;\">" + i + "</font></li>");
                    else
                        html.AppendFormat("<li><a href=\"" + String.Format(urlformat, i) + "\">" + i + "</a></li>");
                    i = i + 1;
                    j = j + 1;
                }
                if (currentpage < totalpage)
                {
                    html.Append("<li><a href=\"" + String.Format(urlformat, currentpage + 1) + "\">下一页</a></li><li><a href=\"" + String.Format(urlformat, totalpage) + "\">末页</a></li>");
                }

            }
            html.Append("</ul>");
            return html.ToString();
        }

        /// <summary>
        /// 返回需要变更分页的链接查询字符串
        /// </summary>
        /// <param name="oldUrl">原始链接</param>
        /// <param name="name">参数名称</param>
        /// <param name="value">参数值</param>
        /// <returns></returns>
        public static string GetQueryUrl(string oldUrl,string name,string value)
        {
            Regex regex = new Regex(name + "=(.+?)&");
            Match match = regex.Match(oldUrl);
            if (match.Success)
            {
                oldUrl = regex.Replace(oldUrl, name+"="+value+"&");
                return oldUrl;
            }
            regex = new Regex(name + "=(.+)");
            match = regex.Match(oldUrl);
            if (match.Success)
            {
                oldUrl = regex.Replace(oldUrl, name + "=" + value);
                return oldUrl;
            }
            else
            {
                if (oldUrl.IndexOf("?")<0)
                {
                    oldUrl = "?"+name+"="+value;
                }
                else
                {
                    oldUrl = oldUrl + "&"+name+"="+value;
                }
            }
            return oldUrl;
        }
       /// <summary>
       /// 返回清除指定参数后的url
       /// </summary>
       /// <param name="oldUrl">原始url</param>
       /// <param name="querys">要清除的参数</param>
       /// <returns></returns>
        public static string RemoveQueryUrl(string oldUrl, string[] querys)
        {
            for (int i = 0; i < querys.Length; i++)
            {
                Regex regex = new Regex("&"+querys[i]+"=(.+)&"); //1
                Match match = regex.Match(oldUrl);
                if (match.Success)
                {
                    oldUrl = oldUrl.Replace(match.Value, "&");
                    break;
                }
                regex = new Regex("\\?" + querys[i] + "=(.+)&"); //2
                match = regex.Match(oldUrl);
                if (match.Success)
                {
                    oldUrl = oldUrl.Replace(match.Value, "?");
                    break;
                }
                regex = new Regex("&" + querys[i] + "=(.+)"); //3
                match = regex.Match(oldUrl);
                if (match.Success)
                {
                    oldUrl = oldUrl.Replace(match.Value,"");
                    break;
                }
                regex = new Regex("\\?" + querys[i] + "=(.+)"); //4
                match = regex.Match(oldUrl);
                if (match.Success)
                {
                    oldUrl = oldUrl.Replace(match.Value, "");
                    break;
                }
            }
            return oldUrl;
        }


        



    }
}
