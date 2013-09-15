using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Net;
using System.IO;
using System.Text.RegularExpressions;
using System.Collections.Specialized;
using System.Reflection;
using System.Web;
using System.Data.OleDb;
using System.Data;

namespace AS.Common.Utils
{
    public class Helper
    {
        public static DateTime GetDateTime(object obj, DateTime def)
        {
            if (obj != null)
            {
                try
                {
                    def = Convert.ToDateTime(obj);
                }
                catch { }
            }
            return def;
        }
        public static DateTime? GetDateTime(object obj)
        {
            DateTime? def = null;
            if (obj != null)
            {
                try
                {
                    def = DateTime.Parse(obj.ToString());
                }
                catch { }
            }
            return def;
        }


        /// <summary>
        /// 返回当前时间字符串
        /// </summary>
        /// <returns></returns>
        public static string GetCurrentDateString()
        {
            return DateTime.Now.ToString("yyyyMMddHHmmss");
        }



        public static int GetInt(object obj, int def)
        {
            if (obj != null)
            {
                try
                {
                    def = Convert.ToInt32(obj);
                }
                catch
                { }

            }
            return def;
        }

        public static Guid GetGuid(object obj, Guid def)
        {
            if (obj != null)
            {
                try
                {

                    def = new Guid(obj.ToString());
                }
                catch { }

            }
            return def;
        }

        public static decimal GetDecimal(object obj, decimal def)
        {
            if (obj != null)
            {
                try
                {
                    def = Convert.ToDecimal(obj);
                }
                catch
                { }
            }
            return def;
        }

        public static double GetDouble(object obj, double def)
        {
            if (obj != null)
            {
                try
                {
                    def = Convert.ToDouble(obj);
                }
                catch
                { }
            }
            return def;
        }

        public static float GetFloat(object obj, float def)
        {
            if (obj != null)
            {
                try
                {
                    def = Convert.ToSingle(obj);
                }
                catch
                { }
            }
            return def;
        }

        public static string GetString(object obj, string def)
        {
            if (obj != null)
            {
                def = obj.ToString().Replace("'", "''");
            }
            return def;

        }
        public static long GetLong(object obj, long def)
        {
            if (obj != null)
            {
                try
                {
                    def = Convert.ToInt32(obj);
                }
                catch
                { }

            }
            return def;
        }
        public static bool GetBool(object obj, bool def)
        {
            if (obj != null)
            {
                try
                {
                    string o = obj.ToString().ToLower();
                    if (o == "true" || o == "false")
                        def = Convert.ToBoolean(obj);
                    else
                        def = Convert.ToBoolean(Convert.ToInt32(obj));
                }
                catch { }
            }
            return def;

        }
        /// <summary>
        /// 返回距离1970年的时间戳不带
        /// </summary>
        /// <param name="datetime"></param>
        /// <returns></returns>
        public static long GetTimeFix(DateTime datetime)
        {
            DateTime mysqltime = DateTime.Parse("1970-1-1 0:0:0");
            TimeSpan ts = datetime.AddHours(-8) - mysqltime;
            return ts.Ticks / 10000000;
        }
        /// <summary>
        /// 根据时间戳返回windows时间
        /// </summary>
        /// <param name="fix"></param>
        /// <returns></returns>
        public static DateTime GetWindowsTime(object fix)
        {
            DateTime mysqltime = DateTime.Parse("1970-1-1 0:0:0");
            long time = Utils.Helper.GetLong(fix, 0);
            mysqltime = mysqltime.AddTicks(time * 10000000);
            return mysqltime.AddHours(8);
        }
        /// <summary>
        /// list 转 table
        /// </summary>
        /// <param name="list"></param>
        /// <returns></returns>
        public static System.Data.DataTable ToDataTable(IList list)
        {
            System.Data.DataTable result = new System.Data.DataTable();
            if (list.Count > 0)
            {
                System.Reflection.PropertyInfo[] propertys = list[0].GetType().GetProperties();
                foreach (System.Reflection.PropertyInfo pi in propertys)
                {
                    Type colType = pi.PropertyType;
                    if ((colType.IsGenericType) && (colType.GetGenericTypeDefinition() == typeof(System.Nullable<>)))
                    {

                        colType = colType.GetGenericArguments()[0];

                    }
                    result.Columns.Add(pi.Name, colType);

                }
                for (int i = 0; i < list.Count; i++)
                {
                    ArrayList tempList = new ArrayList();
                    foreach (System.Reflection.PropertyInfo pi in propertys)
                    {
                        object obj = pi.GetValue(list[i], null);
                        tempList.Add(obj);
                    }
                    object[] array = tempList.ToArray();
                    result.LoadDataRow(array, true);
                }
            }
            return result;
        }

        private static System.Random ran = new Random();
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
                case "domain"://域名格式"(^\w+(-\w+)*)(\.(\w+(-\w+)*))*(\?\S*)?$" //^\w+([-.]\w+)*\.\w+([-.]\w+)*$
                    regex = new Regex(@"(^\w+(-\w+)*)(\.(\w+(-\w+)*))*(\?\S*)?$");
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
                    regex = new Regex(@"^[1-9]\d{4,9}$");
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
            }
            if (regex != null)
            {
                ok = regex.IsMatch(data);
            }
            return ok;
        }




        /// <summary>
        /// 返回指定url的html代码
        /// </summary>
        /// <param name="url">完整的url路径 如http://www.xxx.com/a.aspx</param>
        /// <param name="encode">页面编码 如utf-8 或gb2312</param>
        /// <returns></returns>
        public static string GetHtml(string url, string encode)
        {
            string html = String.Empty;
            //处理代码 读取指定的url的html代码并返回 
            string css = "";
            Uri uri = new Uri(url);

            HttpWebRequest hwReq = (HttpWebRequest)WebRequest.Create(uri);
            HttpWebResponse hwRes = (HttpWebResponse)hwReq.GetResponse();

            hwReq.Method = "Get";
            hwReq.KeepAlive = false;


            url = GetDomain(url);
            url = "http://" + url;
            StreamReader reader = new StreamReader(hwRes.GetResponseStream(), System.Text.Encoding.GetEncoding(encode));
            html = reader.ReadToEnd();
            Regex reg = new Regex(@"(?is)(?<=src=(['""]?))(?!http://)(?=[^'""\s>]+\1)");
            Regex reg1 = new Regex(@"(?is)(?<=href=(['""]?))(?!http://)(?=[^'""\s>]+\1)");
            string result = reg.Replace(html, url);
            result = reg1.Replace(result, url);

            Regex regexp = new Regex(@"<\s*link\b(?![^<>]*?(javascript|__doPostBack))[^<>]+?href=(['""]?)(?<url>[^*#<>()]*?)\2[^>]*>");
            MatchCollection mc = regexp.Matches(result);
            foreach (Match m in mc)
            {
                if (m.Value.Contains("stylesheet"))
                {
                    css += m.Groups["url"].Value + "";
                }
            }
            result = "<style type='text/css'>" + GetCss(css, "utf-8") + "</style>" + result;

            return result;
            //return 
        }

        /// <summary>
        /// 返回指定URL的域名信息
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        public static string GetDomain(string url)
        {
            Regex regex = new Regex(@"http(s)?://(.+?)/");
            return regex.Replace(regex.Match(url).Value, "$2");
        }

        /// 返回指定url的html代码
        /// </summary>
        /// <param name="url">完整的url路径 如http://www.xxx.com/a.aspx</param>
        /// <param name="encode">页面编码 如utf-8 或gb2312</param>
        /// <returns></returns>
        public static string GetCss(string url, string encode)
        {
            string html = String.Empty;
            //处理代码 读取指定的url的html代码并返回 

            Uri uri = new Uri(url);

            HttpWebRequest hwReq = (HttpWebRequest)WebRequest.Create(uri);
            HttpWebResponse hwRes = (HttpWebResponse)hwReq.GetResponse();

            hwReq.Method = "Get";
            hwReq.KeepAlive = false;

            StreamReader reader = new StreamReader(hwRes.GetResponseStream(), System.Text.Encoding.GetEncoding(encode));
            html = reader.ReadToEnd();
            html = html.Replace("url(i", "url(" + url.Replace("index.css", "") + "i");

            return html;
            //return 

        }

        public static NameValueCollection GetObjectProtery(object obj)
        {
            NameValueCollection values = new NameValueCollection();

            if (obj != null)
            {
                Type type = obj.GetType();
                foreach (PropertyInfo info in type.GetProperties())
                {
                    object proobj = info.GetValue(obj, null);
                    if (proobj != null)
                        values.Add(info.Name, info.GetValue(obj, null).ToString());
                    else
                        values.Add(info.Name, String.Empty);
                }
            }
            return values;
        }

        public static System.Data.DataTable ConvertDataTable(List<Hashtable> list)
        {
            System.Data.DataTable dt = new System.Data.DataTable();
            if (list.Count == 0)
                return dt;

            foreach (string name in list[0].Keys)
                dt.Columns.Add(name);

            foreach (Hashtable item in list)
                dt.Rows.Add(new ArrayList(item.Values).ToArray());

            return dt;
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
        /// 判断是否为空
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public static bool isEmpity(string str)
        {
            bool falg = false;
            string[] num = str.Split(',');
            for (int i = 0; i < num.Length; i++)
            {
                if (num[i] == "0")
                {
                    falg = true;
                }
            }
            return falg;
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
        /// 截取字符串 一个汉字按2个字符算
        /// </summary>
        public static string GetSubString(string str, int length)
        {
            string temp = str;
            int j = 0;
            int k = 0;
            for (int i = 0; i < temp.Length; i++)
            {
                if (System.Text.RegularExpressions.Regex.IsMatch(temp.Substring(i, 1), @"[\u4e00-\u9fa5]+"))
                {
                    j += 2;
                }
                else
                {
                    j += 1;
                }
                if (j <= length)
                {
                    k += 1;
                }
                if (j >= length)
                {
                    return temp.Substring(0, k);
                }
            }
            return temp;
        }
        private static object lockerlogwrite = new object();
        public static void LogWrite(string logname, string content)
        {
            try
            {
                lock (lockerlogwrite)
                {
                    string path = AppDomain.CurrentDomain.BaseDirectory + "log";
                    string fullpath = path + "\\" + logname + ".log";
                    if (!System.IO.Directory.Exists(path))
                        Directory.CreateDirectory(path);
                    File.AppendAllText(fullpath, content + "      -----" + DateTime.Now + "\r\n");
                }
            }
            catch { }
        }
        /// <summary>
        /// 集合转换DataSet
        /// </summary>
        /// <param name="list">集合</param>
        /// <returns></returns>
        public static DataSet ToDataSet(IList p_List)
        {
            DataSet result = new DataSet();
            DataTable _DataTable = new DataTable();
            if (p_List.Count > 0)
            {
                PropertyInfo[] propertys = p_List[0].GetType().GetProperties();
                foreach (PropertyInfo pi in propertys)
                {
                    Type colType = pi.PropertyType; if ((colType.IsGenericType) && (colType.GetGenericTypeDefinition() == typeof(Nullable<>)))
                    {
                        colType = colType.GetGenericArguments()[0];
                    }
                    _DataTable.Columns.Add(new DataColumn(pi.Name, colType));
                }
                for (int i = 0; i < p_List.Count; i++)
                {
                    ArrayList tempList = new ArrayList();
                    foreach (PropertyInfo pi in propertys)
                    {
                        object obj = pi.GetValue(p_List[i], null);
                        tempList.Add(obj);
                    }
  
                    object[] array = tempList.ToArray();
                    _DataTable.LoadDataRow(array, true);
                }
            }
            result.Tables.Add(_DataTable);
            return result;
        }

    }
}
