using System;
using System.Text.RegularExpressions;
using System.Web;
using System.Data;
using System.IO;
using System.Text;
using System.Collections.Specialized;
using System.Xml;
using System.Web.UI;
using AS.Common.Utils;
using System.Drawing.Imaging;
using System.Data.SqlClient;
namespace AS.Common.Utils
{
    public class WebUtils
    {

        static string[] _paycnnames = new string[]{
            "支付宝",
            "易宝",
            "财付通",
            "中国移动",
            "网银在线",
            "余额付款",
            "线下支付",
            "通联",
            "货到付款",
            "支付宝手机支付",
            "财付通手机支付",
            "",
        };
        /// <summary>
        /// 每周卖出数量
        /// </summary>
        public const string weeksell = "weeksell.xml";
        /// <summary>
        /// 每月卖出数量
        /// </summary>
        public const string monthsell = "monthsell.xml";

        /// <summary>
        /// 返回客户端的真实IP地址
        /// </summary>
        public static string GetClientIP
        {
            get
            {
                Regex regex = new Regex("([1-9]|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3}");
                string clientIp = Utils.Helper.GetString(HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"], String.Empty);
                if (HttpContext.Current.Request.ServerVariables["HTTP_CDN_SRC_IP"] != null && regex.IsMatch(HttpContext.Current.Request.ServerVariables["HTTP_CDN_SRC_IP"]))
                {
                    clientIp = Utils.Helper.GetString(HttpContext.Current.Request.ServerVariables["HTTP_CDN_SRC_IP"], String.Empty);
                }
                else if (HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"] != null && regex.IsMatch(HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"]))
                {
                    clientIp = Utils.Helper.GetString(HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"], String.Empty);
                }
                string[] ip = clientIp.Split(',');
                return ip[0];
            }

        }
        /// <summary>
        /// 设置用户登录信息
        /// </summary>
        /// <param name="userID"></param>
        /// <param name="save"></param>
        public static void SetLoginUserCookie(string userName, bool save)
        {
            string key = FileUtils.GetKey();//cookie加密密钥
            CookieUtils.SetCookie("username", userName, key, null);

        }

        public string UTF8ToGB2312(string body)
        {
            byte[] b = System.Text.Encoding.UTF8.GetBytes(body);
            byte[] gb = System.Text.Encoding.Convert(System.Text.Encoding.UTF8, System.Text.Encoding.GetEncoding("gb2312"), b);
            body = HttpUtility.UrlEncode(gb);
            return body;
        }
        /// <summary>
        /// 返回用户登录时的验证码,返回空代表不存在验证码
        /// </summary>
        /// <returns></returns>
        public static string GetCheckCode()
        {
            if (HttpContext.Current.Session["checkcode"] == null) return String.Empty;//checkcode
            return HttpContext.Current.Session["checkcode"].ToString().ToLower();
        }


        /// <summary>
        /// 读取模板文件
        /// </summary>
        /// <param name="controlurl"></param>
        /// <param name="values"></param>
        /// <returns></returns>
        public static string LoadTemplate(string controlurl, NameValueCollection values)
        {
            string content = System.IO.File.ReadAllText(HttpContext.Current.Server.MapPath(controlurl), Encoding.UTF8);
            Regex regex = new Regex(@"{(.+?)}");
            for (int i = 0; i < values.Keys.Count; i++)
            {
                content = content.Replace("{" + values.Keys[i] + "}", values[values.Keys[i]]);
            }
            return content;
        }

        private static NameValueCollection _system = null;
        /// <summary>
        /// 得到系统配置表信息
        /// </summary>
        /// <returns>NameValueCollection 对象</returns>
        public static NameValueCollection GetSystem()
        {
            lock (obj)
            {
                if (_system == null)
                {
                    if (HttpContext.Current == null || HttpContext.Current.Cache == null || HttpContext.Current.Cache["CurrentSystemConfig"] == null)
                    {
                        //read xml
                        string path = AppDomain.CurrentDomain.BaseDirectory + "config\\data.config";
                        initSystemConfig();
                        NameValueCollection nvc = new NameValueCollection();
                        XmlDocument Doc_Detail = new XmlDocument();
                        Doc_Detail.Load((path));
                        XmlNodeList NodeList = Doc_Detail.SelectNodes("/root/system/*");
                        if (NodeList.Count > 0)
                        {
                            for (int i = 0; i < NodeList.Count; i++)
                            {

                                if (NodeList[i] != null)
                                {
                                    nvc.Add(NodeList[i].Name, NodeList[i].InnerText);
                                }

                            }
                        }
                        _system = nvc;
                        if (HttpContext.Current != null)
                            HttpContext.Current.Cache.Add("CurrentSystemConfig", nvc, new System.Web.Caching.CacheDependency(HttpContext.Current.Server.MapPath("/config/data.config")), System.Web.Caching.Cache.NoAbsoluteExpiration, System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Default, null);
                    }
                    else
                    {
                        _system = (NameValueCollection)HttpContext.Current.Cache["CurrentSystemConfig"];

                    }
                }
            }
            return _system;
        }



        private static object obj = new object();
        /// <summary>
        /// 根据NameValueCollection对象的信息查询系统配置字段是否存在，存在则修改NameValueCollection对象中对应文件中的值，不存在则添加字段
        /// </summary>
        /// <param name="nvc">系统信息字段集合</param>
        public void CreateSystemByNameCollection(NameValueCollection nvc)
        {
            lock (obj)
            {
                if (nvc != null)
                {
                    string path = HttpContext.Current.Server.MapPath("/config/data.config");
                    initSystemConfig();

                    for (int i = 0; i < nvc.Count; i++)
                    {
                        string strKey = nvc.Keys[i];
                        string strValue = nvc[strKey];
                        XmlDocument Doc_Detail = new XmlDocument();
                        Doc_Detail.Load(path);
                        XmlNode Node1 = Doc_Detail.SelectSingleNode("root");
                        XmlNode NodeSys = Node1.SelectSingleNode("system");
                        XmlNodeList Node2 = Node1.SelectNodes("system");
                        for (int j = 0; j < Node2.Count; j++)
                        {

                            XmlNode nodeSitename = Node2[j].SelectSingleNode(strKey);
                            if (nodeSitename != null)
                            {
                                //存在这个节点就修改该节点信息
                                nodeSitename.InnerText = strValue;

                                Doc_Detail.Save(path);
                            }
                            else
                            {
                                //没有则添加该节点信息
                                XmlElement xmle = Doc_Detail.CreateElement(strKey);
                                xmle.InnerText = strValue;
                                NodeSys.AppendChild(xmle);
                                Doc_Detail.Save(path);
                            }


                        }
                    }
                }
                _system = null;
                HttpContext.Current.Cache.Remove("system");
            }

        }

        /// <summary>
        /// 根据NameValueCollection对象的信息查询系统配置字段是否存在，存在则修改NameValueCollection对象中对应文件中的值，不存在则添加字段
        /// </summary>
        /// <param name="nvc">系统信息字段集合</param>
        public static void CreateSystemByNameCollection1(NameValueCollection nvc)
        {
            lock (obj)
            {
                if (nvc != null)
                {
                    string path = HttpContext.Current.Server.MapPath("/config/data.config");
                    initSystemConfig();

                    for (int i = 0; i < nvc.Count; i++)
                    {
                        string strKey = nvc.Keys[i];
                        string strValue = nvc[strKey];
                        XmlDocument Doc_Detail = new XmlDocument();
                        Doc_Detail.Load(path);
                        XmlNode Node1 = Doc_Detail.SelectSingleNode("root");
                        XmlNode NodeSys = Node1.SelectSingleNode("system");
                        XmlNodeList Node2 = Node1.SelectNodes("system");
                        for (int j = 0; j < Node2.Count; j++)
                        {

                            XmlNode nodeSitename = Node2[j].SelectSingleNode(strKey);
                            if (nodeSitename != null)
                            {
                                //存在这个节点就修改该节点信息
                                nodeSitename.InnerText = strValue;

                                Doc_Detail.Save(path);
                            }
                            else
                            {
                                //没有则添加该节点信息
                                XmlElement xmle = Doc_Detail.CreateElement(strKey);
                                xmle.InnerText = strValue;
                                NodeSys.AppendChild(xmle);
                                Doc_Detail.Save(path);
                            }


                        }
                    }
                }
                _system = null;
                HttpContext.Current.Cache.Remove("system");
            }

        }

        /// <summary>
        /// 初始化文件信息
        /// </summary>
        public static void initSystemConfig()
        {
            string path1 = AppDomain.CurrentDomain.BaseDirectory + "config";
            if (!Directory.Exists(path1))
            {
                Directory.CreateDirectory(path1);

            }
            string path = AppDomain.CurrentDomain.BaseDirectory + "config\\data.config";
            FileInfo CreateFile = new FileInfo(path); //创建文件
            if (!CreateFile.Exists)
            {
                FileStream FS = CreateFile.Create();
                FS.Close();

                StreamWriter SW;
                SW = File.AppendText(path);
                SW.WriteLine("<?xml version=\"1.0\"?><root><system></system></root>");
                SW.Close();
            }
        }

        public static System.Collections.Specialized.NameValueCollection config
        {

            get
            {
                if (System.Web.HttpContext.Current.Cache["CurrentSystemConfig"] == null)
                {

                    System.Web.HttpContext.Current.Cache.Add("CurrentSystemConfig", GetSystem(), new System.Web.Caching.CacheDependency(AppDomain.CurrentDomain.BaseDirectory + "config\\data.config"), System.Web.Caching.Cache.NoAbsoluteExpiration, System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Normal, null);
                }
                return (System.Collections.Specialized.NameValueCollection)System.Web.HttpContext.Current.Cache["CurrentSystemConfig"];
            }

        }

        /// <summary>
        /// 将字符串用base64编码
        /// </summary>
        /// <param name="source"></param>
        /// <returns></returns>
        public static string Encoder(string source)
        {
            if (source == String.Empty)
                return source;
            byte[] b = Encoding.UTF8.GetBytes(source);
            return HttpServerUtility.UrlTokenEncode(b);

        }

        /// <summary>
        /// 将base64编码解码
        /// </summary>
        /// <param name="source"></param>
        /// <returns></returns>
        public static string Decoder(string source)
        {
            if (source == String.Empty)
                return source;
            byte[] b = HttpServerUtility.UrlTokenDecode(source);
            return Encoding.UTF8.GetString(b);

        }


        /// <summary>
        /// 设置管理员用户登录信息
        /// </summary>
        /// <param name="userID"></param>
        /// <param name="save"></param>
        public static void SetLoginAdminUserCookie(int userID, bool save)
        {
            string key = FileUtils.GetKey();//cookie加密密钥
            CookieUtils.SetCookie("admin", userID.ToString(), key, null);
        }
        /// <summary>
        /// 返回已登录的用户名,返回空字符串代表没有登录
        /// </summary>
        /// <returns></returns>
        public static string GetLoginUserName()
        {
            string key = FileUtils.GetKey();//cookie加密密钥
            string name = String.Empty;
            try
            {
                name = CookieUtils.GetCookieValue("username",key);
            }
            catch
            {
                CookieUtils.ClearCookie("username");
            }
            return name;
        }
        /// <summary>
        /// 返回已登录的用户ID
        /// </summary>
        /// <returns></returns>
        public static string GetLoginUserID()
        {
            string key = FileUtils.GetKey();//cookie加密密钥
            string name = String.Empty;
            try
            {
                name = CookieUtils.GetCookieValue("userid", key);
            }
            catch
            {
                CookieUtils.ClearCookie("userid");
            }
            return name;
        }
        /// <summary>
        /// 返回已登录的管理员ID,如果返回0则没有登录
        /// </summary>
        /// <returns></returns>
        public static int GetLoginAdminID()
        {
            string key = FileUtils.GetKey();//cookie加密密钥 
            int admin = 0;
            try
            {
                admin = Helper.GetInt(CookieUtils.GetCookieValue("admin", key), 0);
            }
            catch
            {
                CookieUtils.ClearCookie("admin");

            }
            return admin;
        }

        public static string GetPasswordByMD5(string pwd)
        {
            return System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pwd + PassWordKey(), "md5");
        }

   
     

        /// <summary>
        /// MD5加密的混合代码
        /// </summary>
        /// <returns></returns>
        public static string PassWordKey()
        {
            return "@4!@#$%@";
        }

        /// <summary>
        /// 返回域
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        public static string GetRootDomainName(string url)
        {
            string domain = String.Empty;
            if (url != null && url.Length > 0)
            {
                url = GetDomain(url);
                string[] roots = new string[] { ".gov.cn", ".net.cn", ".com.cn", ".com.cn", ".org.cn", ".com", ".cn", ".mobi", ".net", ".org", ".so", ".co", ".tel", ".tv", ".biz", ".cc", ".hk", ".name", ".info", ".asia", ".me" };
                for (int i = 0; i < roots.Length; i++)
                {
                    if (url.Length > roots[i].Length)
                    {
                        string temp = url.Substring(url.Length - roots[i].Length);


                        if (temp == roots[i])
                        {
                            domain = url.Substring(0, url.Length - roots[i].Length);

                            string[] doms = domain.Split('.');
                            if (doms.Length > 0)
                            {
                                return "." + doms[doms.Length - 1] + roots[i];
                            }
                        }
                    }
                }
            }
            return domain;
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
        /// <summary>
        /// 返回需要支付时用到的交易ID
        /// </summary>
        /// <param name="userid">用户ID</param>
        /// <param name="teamid">项目ID</param>
        /// <param name="orderid">订单ID</param>
        /// <returns></returns>
        public static string GetPayID(int userid, int teamid, int orderid)
        {
            return teamid + "as" + userid + "as" + orderid + "as" + StringUtils.GetRandomString(6);
        }
        /// <summary>
        /// 返回充值所用到的交易单号
        /// </summary>
        /// <param name="userid"></param>
        /// <returns></returns>
        public static string GetPayID(int userid)
        {
            return "0as" + userid + "as0as" + StringUtils.GetRandomString(6);
        }

        /// <summary>
        /// 返回项目规格的datatable类型 列名为规格名称  如颜色 数量 
        /// </summary>
        /// <param name="team_specification"></param>
        /// <returns></returns>
        public static DataTable GetSpecifications(string team_specification)
        {
            DataTable specifTable = new DataTable();
            if (String.IsNullOrEmpty(team_specification))
            {
                DataColumn col = new DataColumn("规格");
                col.DataType = typeof(String);
                specifTable.Columns.Add(col);
                DataRow row = specifTable.NewRow();
                row["规格"] = "无规格";
                specifTable.Rows.Add(row);
            }
            else
            {
                string[] arr1 = team_specification.Split('|');//分出规格来
                for (int i = 0; i < arr1.Length; i++)
                {
                    string temp = arr1[i].Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "");
                    string[] arr2 = temp.Split(',');//把规格名称和规格值进行分组
                    for (int j = 0; j < arr2.Length; j++)
                    {
                        string[] arr3 = arr2[j].Split(':');//把规格名称和规格值分开
                        if (arr3.Length == 2)
                        {
                            if (i == 0)//如果是第一行的话 把列名写进去
                            {
                                DataColumn col = new DataColumn(arr3[0]);
                                col.DataType = typeof(String);
                                specifTable.Columns.Add(col);
                                if (j == 0)//没有记录则新建
                                {
                                    DataRow row = specifTable.NewRow();
                                    row[arr3[0]] = arr3[1];
                                    specifTable.Rows.Add(row);
                                }
                                else//否则读取此记录
                                {
                                    DataRow row = specifTable.Rows[0];
                                    row[arr3[0]] = arr3[1];
                                }
                            }
                            else//不是第一行就不用建列了
                            {
                                if (j == 0)//没有记录则新建
                                {
                                    DataRow row = specifTable.NewRow();
                                    row[arr3[0]] = arr3[1];
                                    specifTable.Rows.Add(row);
                                }
                                else//否则读取此记录
                                {
                                    DataRow row = specifTable.Rows[i];
                                    row[arr3[0]] = arr3[1];
                                }
                            }
                        }
                    }
                }
            }
            return specifTable;
        }


        /// <summary>
        /// 添加或减少库存
        /// </summary>
        /// <param name="invent">要添加或减少的库存</param>
        /// <param name="totalinvent">总库存</param>
        /// <param name="type">0添加 1减少</param>
        public static string AddInventory(string invent, string totalinvent, int type)
        {

            if (invent.Length > 0)
            {
                string[] splitval = invent.Split('|');
                for (int i = 0; i < splitval.Length; i++)
                {
                    Regex regex1 = new Regex(@"{(.+?),数量:\[(\d+)\]}");
                    string regstr = regex1.Replace(splitval[i], "{$1,数量:[(\\d+)]}").Replace("[", "\\[").Replace("]", "\\]"); //得到匹配的正则
                    Regex regex2 = new Regex(regstr);
                    Match match = regex2.Match(totalinvent);
                    if (match.Success)
                    {
                        int thenum = Helper.GetInt(regex2.Replace(splitval[i], "$1"), 0);//得到当前项目当前规格卖出数量
                        int zongnum = Helper.GetInt(regex2.Replace(match.Value, "$1"), 0);//得到累计卖出数量
                        if (type == 0)
                            zongnum = zongnum + thenum; //得到新的累计卖出数量
                        else
                            zongnum = zongnum - thenum;
                        if (zongnum > 0)
                        {
                            string xin = regex1.Replace(match.Value, "{$1,数量:[" + zongnum + "]}");
                            totalinvent = totalinvent.Replace(match.Value, xin);
                        }
                        else
                        {
                            totalinvent = totalinvent.Replace(match.Value, "");
                            totalinvent = totalinvent.Replace("||", "|");
                        }

                    }
                    else
                    {
                        if (type == 0)
                        {
                            if (totalinvent.Length > 0)
                                totalinvent = totalinvent + "|" + splitval[i];
                            else
                                totalinvent = totalinvent + splitval[i];
                        }
                    }
                }
            }
            return totalinvent;
        }



        /// 将标记 收录 写入 data.config
        /// </summary>
        /// <param name="visitCount"></param>
        public static void CheckRecord(int visitCount)
        {

            string path = AppDomain.CurrentDomain.BaseDirectory + "config/data.config";
            XmlDocument doc = new XmlDocument();
            doc.Load(path);
            XmlNode record = doc.SelectSingleNode("/root/system/record");
            XmlNode node = doc.SelectSingleNode("root/system");
            if (record == null)
            {

                XmlElement element = doc.CreateElement("record");
                element.InnerText = visitCount.ToString();
                node.AppendChild(element);

            }
            else
            {
                record.InnerText = visitCount.ToString();
            }

            doc.Save(path);
        }


        /// <summary>

        /// <summary>
        /// 创建一个对象的副本
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static T GetObjectClone<T>(T obj)
        {
            Type type = obj.GetType();
            T newobj = (T)Activator.CreateInstance(type);
            System.Reflection.PropertyInfo[] propInfo = type.GetProperties();
            for (int i = 0; i < propInfo.Length; i++)
            {
                if (propInfo[i].CanWrite)
                    propInfo[i].SetValue(newobj, propInfo[i].GetValue(obj, null), null);
            }
            return newobj;
        }

        /// <summary>
        /// 返回付款方式
        /// </summary>
        /// <param name="service"></param>
        /// <returns></returns>
        public static string GetBank(string service)
        {
            string bank = "余额付款";
            switch (service)
            {
                case "yeepay":
                    bank = "易宝";
                    break;
                case "alipay":
                    bank = "支付宝";
                    break;
                case "cash":
                    bank = "余额付款";
                    break;
            }
            return bank;
        }
        /// <summary>
        /// 读取xml到datatable
        /// </summary>
        /// <param name="filename"></param>
        /// <returns></returns>
        public static DataTable ReadXmlFile(string filename)
        {
            DataTable dt = new DataTable();
            try
            {
                if (HttpContext.Current.Cache[filename] == null)
                {
                    string path = AppDomain.CurrentDomain.BaseDirectory + "xml\\" + filename;
                    dt.ReadXml(path);
                    HttpContext.Current.Cache.Add(filename, dt, new System.Web.Caching.CacheDependency(path), System.Web.Caching.Cache.NoAbsoluteExpiration, System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Normal, null);

                }
                else
                    dt = HttpContext.Current.Cache[filename] as DataTable;
            }
            catch { }
            return dt;
        }

        public static void WriteXmlFile(string filename, DataTable table)
        {

            if (table != null && table.Rows.Count > 0)
            {
                string path = AppDomain.CurrentDomain.BaseDirectory + "xml\\" + filename;
                table.WriteXml(path, XmlWriteMode.WriteSchema, true);
            }
        }
        /// <summary>
        /// 分享工具，直接调用加网的分享代码，省事 参考http://www.jiathis.com
        /// </summary>
        /// <param name="webid"></param>
        /// <param name="url">不需要编码，本方法会编码</param>
        /// <param name="title">不需要编码</param>
        /// <param name="pic">不需要编码</param>
        /// <returns></returns>
        public static string Share(string webid, string url, string title, string pic)
        {
            string share = String.Empty;
            switch (webid)
            {
                case "kaixin001":
                    share = "http://www.kaixin001.com/rest/records.php?content={0}&url={1}&pic={2}&starid=0&aid=0&style=11";
                    break;
                case "tsina":
                    share = "http://v.t.sina.com.cn/share/share.php?title={0}&url={1}&pic={2}";
                    break;
                case "qzone":
                    share = "http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url={1}&title={0}&pics={2}";
                    break;
                case "renren":
                    share = "http://share.renren.com/share/buttonshare.do?link={1}&title={0}";
                    break;
                case "tqq":
                    share = "http://share.v.t.qq.com/index.php?c=share&a=index&title={0}&url={1}&pic={2}";
                    break;
                case "t163":
                    share = "http://t.163.com/article/user/checkLogin.do?info={0}+{1}&images={2}";
                    break;
                case "douban":
                    share = "http://shuo.douban.com/!service/share?image={2}&href={1}&name={0}";
                    break;
            }
            share = String.Format(share, new string[] { HttpContext.Current.Server.UrlEncode(title), HttpContext.Current.Server.UrlEncode(url), HttpContext.Current.Server.UrlEncode(pic) });

            return share;
        }


        /// <summary>
        /// 返回分页代码
        /// </summary>
        /// <param name="pagesize">每页记录数</param>
        /// <param name="recordcount">总记录数</param>
        /// <param name="currentpage">当前页码</param>
        /// <param name="urlformat"><![CDATA[格式化的url 例如:index.aspx?a=3&b=4&page={0} {0}代表将要替换的页码]]></param>
        /// <returns></returns>
        public static string GetMBPagerHtml(int pagesize, int recordcount, int currentpage, string urlformat)
        {
            StringBuilder html = new StringBuilder();

            if (recordcount > 0)
            {               
                int totalpage = recordcount / pagesize + ((recordcount % pagesize > 0) ? 1 : 0);
                if (currentpage < 1) currentpage = 1;
                if (currentpage > totalpage) currentpage = totalpage;
                if (currentpage > 1)
                {
                    html.Append("<a class=\"nav-button\"  href=\"" + String.Format(urlformat, currentpage - 1) + "\">上一页</a>");
                }                               
                if (currentpage < totalpage)
                {
                    html.Append("<a class=\"nav-button\" href=\"" + String.Format(urlformat, currentpage + 1) + "\">下一页</a>");
                }               
            }

            return html.ToString();
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

            if (recordcount > 0)
            {
                html.Append("<ul class=\"paginator\"> ");
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
                        html.AppendFormat("<li style=\" margin: 5px; 6px;\" ><font style=\"color:red;\">" + i + "</font></li>");
                    else
                        html.AppendFormat("<li><a href=\"" + String.Format(urlformat, i) + "\">" + i + "</a></li>");
                    i = i + 1;
                    j = j + 1;
                }
                if (currentpage < totalpage)
                {
                    html.Append("<li><a href=\"" + String.Format(urlformat, currentpage + 1) + "\">下一页</a></li><li><a href=\"" + String.Format(urlformat, totalpage) + "\">末页</a></li>");
                }
                html.Append("</ul>");
            }
         
            return html.ToString();
        }

        /// <summary>
        /// 返回当前订单的文本信息
        /// </summary>
        /// <param name="state">订单状态</param>
        /// <param name="service">付款方式</param>
        /// <returns></returns>
        public static string GetPayText(string state, string service)
        {
            string html = String.Empty;
            if (state == "unpay")
            {
                html = "未支付";
            }
            else if (state == "scoreunpay")
            {
                html = "未支付";
            }
            else if (state == "cancel")
            {
                html = "已取消";
            }
            else if (state == "refund")
            {
                html = "已退款";
            }
            else if (state == "refunding")
            {
                html = "退款中";
            }
            else if (state == "nocod")
            {
                html = "未支付<p>货到付款</p>";
            }
            else if (state == "pay" || state == "scorepay")
            {
                if (service != null && service != "")
                    html = GetPayCnName(GetPayType(service));
            }
            return html;
        }
        /// <summary>
        /// 根据付款名称返回付款类型
        /// </summary>
        /// <param name="payname"></param>
        /// <returns></returns>
        public static PayType GetPayType(string payname)
        {
            payname = payname.ToLower();
            if (payname == "支付宝" || payname == "alipay")
            {
                return PayType.alipay;
            }
            else if (payname == "yeepay" || payname == "易宝")
                return PayType.yeepay;
            else if (payname == "财付通" || payname == "tenpay")
                return PayType.tenpay;
            else if (payname == "网银在线" || payname == "chinabank")
                return PayType.chinabank;
            else if (payname == "中国移动" || payname == "chinamobilepay")
                return PayType.chinamobilepay;
            else if (payname == "余额付款" || payname == "credit")
                return PayType.credit;
            else if (payname == "线下支付" || payname == "cash")
                return PayType.cash;
            else if (payname == "货到付款" || payname == "cashondelivery")
                return PayType.cashondelivery;
            else if (payname == "支付宝手机支付" || payname == "alipaywap")
                return PayType.alipaywap;
            else if (payname == "财付通手机支付" || payname == "tenpaywap")
                return PayType.tenpaywap;
            return PayType.none;
        }
        /// <summary>
        /// 返回付款方式中文名称
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public static string GetPayCnName(PayType type)
        {
            return _paycnnames[(int)type];
        }
        private static object lockerlogwrite = new object();
        /// <summary>
        /// 写入错误日志
        /// </summary>
        /// <param name="logname">日志文件名称</param>
        /// <param name="content">日志内容</param>
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
        public static string LoadPageString(string path)
        {
            System.IO.StringWriter sw = new System.IO.StringWriter();
            HttpContext.Current.Server.Execute(path, sw);

            return sw.GetStringBuilder().ToString();

        }
        /// <summary>
        /// 显示规格
        /// </summary>
        /// <param name="bulletin"></param>
        /// <param name="showhtml">是否显示html格式 0显示 1不显示</param>
        /// <returns></returns>
        public static string Getbulletin(string bulletin, int showhtml = 0)
        {
            string str = "";
            if (bulletin != null && bulletin!="")
            {
                str = "<font style='color: rgb(153, 153, 153);'>";
                string strs = "<br><b style='color: red;'>[规格]</b>";
                if (showhtml == 1)
                {
                    str = String.Empty;
                    strs = String.Empty;
                }
                string[] strArray = bulletin.Split('|');

                for (int i = 0; i < strArray.Length; i++)
                {
                    if (bulletin != "" && bulletin != null)
                    {
                        str += strs + strArray[i].Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "") + "";
                    }

                }
                if (showhtml == 0)
                    str = str + "</font><br><br>";
            }
            return str;
        }

        /// <summary>
        /// 返回折扣
        /// </summary>
        /// <param name="marketprice">市场价</param>
        /// <param name="mallprice">网站价</param>
        /// <returns></returns>
        public static string GetDiscount(decimal marketprice, decimal mallprice)
        {
            if (marketprice <= 0 || mallprice <= 0)
            {
                return "0折";
            }

            string discount = ((mallprice / marketprice) * 10).ToString("F1");
            if (discount.IndexOf(".0") > 0)
            {
                discount = discount.Substring(0, discount.IndexOf(".0"));
            }
            return discount + "折";
        }

        static string[] _catalognames = new string[]{
            "",
            "city",
            "group",
            "express",
            "partner",
            "public",
        };

        /// <summary>
        /// 返回图片路径
        /// </summary>
        /// <param name="src"></param>
        /// <returns></returns>
        public static string getimgsrc(object src)
        {
            if (config["slowimage"] == "1")
                return " original='" + src + "' ";// src='" + src + "' ";
            else
                return " src='" + src + "' ";
        }

        /// <summary>
        /// 根据类型返回存储在数据库中的分类类型英文
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public static string GetCatalogName(CatalogType type)
        {
            return _catalognames[(int)type];
        }

        /// <summary>
        /// 显示文件夹信息
        /// </summary>

        public static string setUpload()
        {

            string result1 = "/upfile/team/";
            string path = System.Web.HttpContext.Current.Server.MapPath("~/upfile/team/");
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            result1 = result1 + DateTime.Now.Year + "/";
            path = path + DateTime.Now.Year + "/";
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);
            path = path + DateTime.Now.ToString("MMdd");
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);
            result1 = result1 + DateTime.Now.ToString("MMdd") + "/";


            return result1;
        }


        /// <summary>
        /// 返回已登录的分站管理员ID,如果返回0则没有登录
        /// </summary>
        /// <returns></returns>
        public static int GetManBranchAdmin()
        {
            string key = FileUtils.GetKey();//cookie加密密钥 
            int ManBranchAdminid = 0;
            try
            {
                ManBranchAdminid = Helper.GetInt(CookieUtils.GetCookieValue("ManBranchAdminid", key), 0);
            }
            catch
            {
                CookieUtils.ClearCookie("ManBranchAdminid");

            }
            return ManBranchAdminid;
        }

        /// <summary>
        /// 返回已登录的商户管理员ID,如果返回0则没有登录
        /// </summary>
        /// <returns></returns>
        public static int GetPartnerAdminID()
        {
            string key = FileUtils.GetKey();//cookie加密密钥 
            int partneradmin = 0;
            try
            {
                partneradmin = Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0);
            }
            catch
            {
                CookieUtils.ClearCookie("partner");

            }
            return partneradmin;
        }

        /// <summary>
        /// 返回已登录的商户分站管理员ID,如果返回0则没有登录
        /// </summary>
        /// <returns></returns>
        public static int GetPartnerBranchAdminID()
        {
            string key = FileUtils.GetKey();//cookie加密密钥 
            int partnerbranchadmin = 0;
            try
            {
                partnerbranchadmin = Helper.GetInt(CookieUtils.GetCookieValue("pbranch", key), 0);
            }
            catch
            {
                CookieUtils.ClearCookie("pbranch");

            }
            return partnerbranchadmin;
        }

        /// <summary>
        /// 返回已登录的销售管理员ID,如果返回0则没有登录
        /// </summary>
        /// <returns></returns>
        public static int GetSaleAdminID()
        {
            string key = FileUtils.GetKey();//cookie加密密钥 
            int saleadmin = 0;
            try
            {
                saleadmin = Helper.GetInt(CookieUtils.GetCookieValue("sale", key), 0);
            }
            catch
            {
                CookieUtils.ClearCookie("sale");

            }
            return saleadmin;
        }

        public static string AppendSelectControl(string id, string name, string classname, DataTable options, string textname, string valname, string curvalue)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendFormat("<select id=\"{0}\" name=\"{1}\" class=\"{2}\" >", id, name, classname);

            for (int i = 0; i < options.Rows.Count; i++)
            {

                if (options.Rows[i][valname].ToString() == curvalue)
                    sb.AppendFormat("<option selected=\"selected\" value=\"" + options.Rows[i][valname] + "\">" + options.Rows[i][textname] + "</option>");
                else
                    sb.AppendFormat("<option value=\"" + options.Rows[i][valname] + "\">" + options.Rows[i][textname] + "</option>");
            }
            return sb.ToString();
        }

        /// <summary>
        /// 返回指定目录下的，*.sql的文件。按创建时间倒序排列
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static DataRow[] GetFilesByTime(string path)
        {
            if (Directory.Exists(path))
            {
                string[] files = Directory.GetFiles(path, "*.sql");
                if (files.Length > 0)
                {
                    DataTable filetable = new DataTable();
                    filetable.Columns.Add(new DataColumn("filename", Type.GetType("System.String")));
                    filetable.Columns.Add(new DataColumn("createtime", Type.GetType("System.DateTime")));
                    for (int i = 0; i < files.Length; i++)
                    {
                        DataRow row = filetable.NewRow();
                        DateTime createtime = File.GetCreationTime(files[i]);
                        string filename = Path.GetFileName(files[i]);
                        row["filename"] = filename;
                        row["createtime"] = createtime;
                        filetable.Rows.Add(row);
                    }
                    DataRow[] rows = filetable.Select(String.Empty, "createtime desc");
                    return rows;
                }
            }
            return new DataRow[] { };
        }
        /// <summary>
        /// 返回带http开头的项目图片链接地址
        /// </summary>
        /// <param name="teamImageUrl"></param>
        /// <returns></returns>
        public static string GetRealTeamImageUrl(string teamImageUrl)
        {
            if (teamImageUrl.IndexOf("http://") >= 0)
                return teamImageUrl;
            else
            {
                Regex regex = new Regex(@"http://(.+?)/");
                string url = regex.Match(HttpContext.Current.Request.Url.AbsoluteUri).Value;
                url = url.Substring(0, url.Length - 1);
                return url + teamImageUrl;
            }
        }

        public static bool IsSupper
        {
            get
            {
                return (Utils.Helper.GetInt(CookieUtils.GetCookieValue("admin",FileUtils.GetKey()), 0) == 1) ? true : false;
            }
        }
        /// <summary>
        /// 判断用户是手机访问还是PC访问
        /// </summary>
        /// <param name="uAgent">用户使用的系统类型</param>
        /// <returns></returns>
        public static bool isPC(string uAgent)
        {
            bool ok = false;
            string u = uAgent;
            if (u.Length >= 4)
            {
                Regex b = new Regex(@"(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino", RegexOptions.IgnoreCase | RegexOptions.Multiline);
                Regex v = new Regex(@"1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(di|rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-", RegexOptions.IgnoreCase | RegexOptions.Multiline);
                if (!(b.IsMatch(u) || v.IsMatch(u.Substring(0, 4))))
                {
                    ok = true;//pc
                }
            }
            return ok;
        }

        

    


    }
    public enum PayType
    {
        /// <summary>
        /// 支付宝
        /// </summary>
        alipay = 0,
        /// <summary>
        /// 易宝
        /// </summary>
        yeepay = 1,
        /// <summary>
        /// 财付通
        /// </summary>
        tenpay = 2,
        /// <summary>
        /// 中国移动
        /// </summary>
        chinamobilepay = 3,
        /// <summary>
        /// 网银在线
        /// </summary>
        chinabank = 4,
        /// <summary>
        /// 余额付款
        /// </summary>
        credit = 5,
        /// <summary>
        /// 线下支付
        /// </summary>
        cash = 6,
        /// <summary>
        /// 无
        /// </summary>
        none = 7,
        /// <summary>
        /// 货到付款
        /// </summary>
        cashondelivery = 8,
        /// <summary>
        /// 支付宝手机支付
        /// </summary>
        alipaywap = 9,
        /// <summary>
        /// 财付通手机支付
        /// </summary>
        tenpaywap = 10,
    }

    public enum CatalogType
    {
        none = 0,
        /// <summary>
        /// 城市分类
        /// </summary>
        city = 1,
        /// <summary>
        /// 商品类别如美食，娱乐等
        /// </summary>
        group = 2,
        /// <summary>
        /// 快递分类
        /// </summary>
        express = 3,
        /// <summary>
        /// 商户分类
        /// </summary>
        partner = 4,
        /// <summary>
        /// 讨论区分类
        /// </summary>
        aspublic = 5,

    }
}