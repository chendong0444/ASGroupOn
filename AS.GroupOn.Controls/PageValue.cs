using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using AS.GroupOn.Domain;
using System.Collections;
using AS.GroupOn.DataAccess;
using AS.Common.Utils;
using System.Text.RegularExpressions;
using System.Collections.Specialized;
using System.Xml;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.Controls
{

    public class PageValue
    {
        /// <summary>
        /// 页面标题
        /// </summary>
        public static string Title
        {
            get
            {
                if (HttpContext.Current.Items["Title"] != null)
                    return HttpContext.Current.Items["Title"].ToString();
                return String.Empty;
            }
            set
            {
                HttpContext.Current.Items["Title"] = value;
            }
        }
        /// <summary>
        /// SEO关键词
        /// </summary>
        public static string KeyWord
        {
            get
            {
                if (HttpContext.Current.Items["KeyWord"] != null)
                    return HttpContext.Current.Items["KeyWord"].ToString();
                return String.Empty;
            }
            set
            {
                HttpContext.Current.Items["KeyWord"] = value;
            }
        }
        /// <summary>
        /// SEO描述
        /// </summary>
        public static string Description
        {
            get
            {
                if (HttpContext.Current.Items["Description"] != null)
                    return HttpContext.Current.Items["Description"].ToString();
                return String.Empty;
            }
            set
            {
                HttpContext.Current.Items["Description"] = value;
            }
        }


        /// <summary>
        /// 当前城市
        /// </summary>
        public static ICity CurrentCity
        {
            get
            {
                IList<ICity> citys = null;
                ICity city = null;
                CityFilter categoryfilter = new CityFilter();
                if (HttpContext.Current.Items["CurrentCity"] == null)
                {
                    string cityid = Helper.GetString(CookieUtils.GetCookieValue("cityid"), String.Empty);
                    if (HttpContext.Current.Request["city"] != null && HttpContext.Current.Request["city"].ToString() != "")
                    {
                        categoryfilter.Ename = Helper.GetString(HttpContext.Current.Request["city"], String.Empty);
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            citys = session.Citys.GetList(categoryfilter);
                        }
                        if (citys != null && citys.Count > 0)
                        {
                            cityid = citys[0].Id.ToString();
                        }
                        else
                        {
                            cityid = String.Empty;
                        }
                    }
                    if (cityid == String.Empty)
                    {
                        citys = null;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            citys = session.Citys.GetList(categoryfilter);
                        }
                        if (!AS.GroupOn.Controls.BaseUserControl.GetAddress(Helper.GetString(Utility.GetCity(), ""), citys, out cityid))//根据用户所在的城市，打开相应城市下的团购项目
                        {
                            HttpContext.Current.Items["CurrentCity"] = AS.GroupOn.Domain.Spi.City.GetDefault();
                            CookieUtils.SetCookie("cityid", "0");
                        }
                        else
                        {
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                HttpContext.Current.Items["CurrentCity"] = session.Citys.GetByID(Helper.GetInt(cityid, 0));
                            }
                        }
                    }
                    else
                    {
                        if (cityid == "0")
                            HttpContext.Current.Items["CurrentCity"] = AS.GroupOn.Domain.Spi.City.GetDefault();
                        else
                        {
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                city = session.Citys.GetByID(Helper.GetInt(cityid, 0));
                                if (city != null)
                                    HttpContext.Current.Items["CurrentCity"] = city;
                                else
                                    HttpContext.Current.Items["CurrentCity"] = AS.GroupOn.Domain.Spi.City.GetDefault();
                            }
                        }
                    }
                }
                return HttpContext.Current.Items["CurrentCity"] as ICity;
            }
            set
            {
                HttpContext.Current.Items["CurrentCity"] = value;
            }
        }
        /// <summary>
        /// 当前登录用户
        /// </summary>
        public static IUser CurrentUser
        {
            get
            {
                if (HttpContext.Current.Items["CurrentUser"] != null)
                    return HttpContext.Current.Items["CurrentUser"] as IUser;
                return null;
            }
            set
            {
                HttpContext.Current.Items["CurrentUser"] = value;
            }
        }

        /// <summary>
        /// 得到数据库连接信息
        /// </summary>
        /// <returns></returns>
        public static string GetConnectString()
        {
            string strConnct = String.Empty;
            XmlDocument xmldoc = new XmlDocument();
            xmldoc.Load(HttpContext.Current.Server.MapPath(PageValue.WebRoot + "bin/mybatis/mssql/DataMap.config"));
            XmlNode node = xmldoc.SelectSingleNode("//propertys/property[@key='masterSqlserver']");
            if (node != null && node.Attributes["value"].Value != "")
            {
                strConnct = node.Attributes["value"].Value;
            }
            return strConnct;
        }
        /// <summary>
        /// 当前系统配置
        /// </summary>
        public static ISystem CurrentSystem
        {
            get
            {
                if (HttpContext.Current != null || HttpContext.Current.Items["CurrentSystem"] != null)
                    return HttpContext.Current.Items["CurrentSystem"] as ISystem;
                return null;
            }
            set
            {
                HttpContext.Current.Items["CurrentSystem"] = value;
            }
        }
        private static object obj = new object();
        private static NameValueCollection _system = null;
        /// <summary>
        /// 当前系统配置文件中配置
        /// </summary>
        public static NameValueCollection CurrentSystemConfig
        {
            get
            {

                lock (obj)
                {

                    if (HttpContext.Current == null || HttpContext.Current.Cache == null || HttpContext.Current.Items["CurrentSystemConfig"] == null)
                    {
                        //read xml
                        string path = AppDomain.CurrentDomain.BaseDirectory + "config\\data.config";
                        WebUtils.initSystemConfig();
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
                return _system;
            }

        }

        /// <summary>
        /// 返回网站根目录
        /// </summary>
        public static string WebRoot
        {
            get
            {
                string rpath = CurrentSystemConfig["rootpath"];
                if (!String.IsNullOrEmpty(rpath))
                {
                    return rpath;
                }
                return "/";
            }
        }

        /// <summary>
        /// 当前登录的管理员
        /// </summary>
        public static IUser CurrentAdmin
        {
            get
            {
                if (HttpContext.Current.Items["CurrentAdmin"] != null)
                    return HttpContext.Current.Items["CurrentAdmin"] as IUser;
                return null;
            }
            set
            {
                HttpContext.Current.Items["CurrentAdmin"] = value;
            }
        }


        /// <summary>
        /// 返回模板路径
        /// </summary>
        public static string TemplatePath
        {
            get
            {
                return PageValue.WebRoot + "template/default/";
            }
        }
        /// <summary>
        /// 返回手机模板路径
        /// </summary>
        public static string MobileTemplatePath
        {
            get
            {
                return PageValue.WebRoot + "template/mobile/";
            }
        }
        /// <summary>
        /// 团购CSS路径
        /// </summary>
        public static string CssPath
        {
            get
            {
                if (CurrentSystem != null && CurrentSystem.skintheme != null && CurrentSystem.skintheme != "")
                {
                    string[] theme = CurrentSystem.skintheme.Split('|');
                    return TemplatePath + "theme/" + theme[0];
                }
                else
                    return TemplatePath + "theme/default";
            }
        }
        /// <summary>
        /// 商城CSS路径
        /// </summary>
        public static string MallCssPath
        {
            get
            {
                if (CurrentSystem != null && CurrentSystem.skintheme != null && CurrentSystem.skintheme != "")
                {
                    string[] theme = CurrentSystem.skintheme.Split('|');
                    if (theme.Length > 1)
                    {
                        return TemplatePath + "theme/" + theme[1];
                    }
                    else
                    {
                        return TemplatePath + "theme/default";
                    }
                   
                }
                else
                    return TemplatePath + "theme/default";
            }
        }
        /// <summary>
        /// 手机端团购CSS路径
        /// </summary>
        public static string MobileCssPath
        {
            get
            {
                if (CurrentSystem != null && CurrentSystem.skintheme != null && CurrentSystem.skintheme != "")
                {
                    string[] theme = CurrentSystem.skintheme.Split('|');
                    if (theme.Length > 2)
                    {
                        return MobileTemplatePath + "theme/" + theme[2];
                    }
                    else
                    {
                        return MobileTemplatePath + "theme/default";
                    }
                   
                }
                else
                    return MobileTemplatePath + "theme/default";
            }
        }
        /// <summary>
        /// 页面标识 参考urlmapper文件中的ID
        /// </summary>
        public static string CurrentPageID
        {
            get
            {
                if (HttpContext.Current.Items["CurrentPageID"] != null)
                    return HttpContext.Current.Items["CurrentPageID"].ToString();
                return String.Empty;
            }
            set
            {
                HttpContext.Current.Items["CurrentPageID"] = value;
            }
        }
        /// <summary>
        /// 返回请求的原始Url
        /// </summary>
        public static string Url
        {
            get
            {
                if (HttpContext.Current.Items["Url"] != null)
                    return HttpContext.Current.Items["Url"].ToString();
                return String.Empty;
            }
            set
            {
                HttpContext.Current.Items["Url"] = value;
            }
        }
        /// <summary>
        /// 返回请求原始的Uri
        /// </summary>
        public static Uri Uri
        {
            get
            {
                if (HttpContext.Current.Items["Uri"] != null)
                    return HttpContext.Current.Items["Uri"] as Uri;
                return null;
            }
            set
            {
                HttpContext.Current.Items["Uri"] = value;
            }
        }


        /// <summary>
        /// 返回表单提交前的信息
        /// </summary>
        /// <param name="name">表单name</param>
        /// <returns></returns>
        public static string GetErrorData(string name)
        {
            if (HttpContext.Current.Items["ErrorData"] == null)
            {
                return String.Empty;
            }

            Hashtable hashTable = HttpContext.Current.Items["ErrorData"] as Hashtable;
            if (hashTable[name] == null)
                return String.Empty;
            else
                return hashTable[name].ToString();
        }
        /// <summary>
        /// 设置表单错误信息
        /// </summary>
        /// <param name="name">表单name</param>
        /// <param name="value">表单值</param>
        public static void SetErrorData(string name, object value)
        {
            Hashtable hashTable = new Hashtable();
            if (HttpContext.Current.Items["ErrorData"] == null)
            {
                HttpContext.Current.Items["ErrorData"] = hashTable;
            }
            else
            {
                hashTable = HttpContext.Current.Items["ErrorData"] as Hashtable;
            }
            hashTable[name] = value;
        }


        /// <summary>
        /// 设置提示信息
        /// </summary>
        /// <param name="value"></param>
        public static void SetMessage(ShowMessageResult showMessageResult)
        {
            HttpContext.Current.Session["SuccessMessage"] = showMessageResult;
        }

        /// <summary>
        /// 返回提示信息
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        public static ShowMessageResult GetMessage()
        {
            ShowMessageResult msg = null;
            if (HttpContext.Current.Session["SuccessMessage"] != null)
            {
                HttpContext.Current.Items["SuccessMessage"] = HttpContext.Current.Session["SuccessMessage"];
                HttpContext.Current.Session.Remove("SuccessMessage");
            }
            if (HttpContext.Current.Items["SuccessMessage"] != null)
                msg = HttpContext.Current.Items["SuccessMessage"] as ShowMessageResult;
            return msg;
        }

        ///// <summary>
        ///// 优惠券购物车
        ///// </summary>
        public static Cart CouponCart
        {
            get
            {
                if (HttpContext.Current.Items["couponcart"] == null)
                {
                    HttpContext.Current.Items["couponcart"] = new Cart();
                    if (HttpContext.Current.Request.Cookies[CookieUtils.couponcart] != null)
                    {
                        string cookie = CookieUtils.GetCookieValue(CookieUtils.couponcart); //HttpContext.Current.Request.Cookies["couponcart"].Value;
                        if (cookie.Length > 0)
                        {
                            HttpContext.Current.Items["couponcart"] = JsonUtils.GetObjectFromJson<Cart>(cookie);
                        }


                    }
                }
                return HttpContext.Current.Items["couponcart"] as Cart;
            }
        }

        ///// <summary>
        ///// 实物购物车
        ///// </summary>
        public static Cart DeliveryCart
        {
            get
            {
                if (HttpContext.Current.Items["deliverycart"] == null)
                {
                    HttpContext.Current.Items["deliverycart"] = new Cart();
                    if (HttpContext.Current.Request.Cookies[CookieUtils.deliverycart] != null)
                    {
                        string cookie = CookieUtils.GetCookieValue(CookieUtils.deliverycart);
                        if (cookie.Length > 0)
                        {
                            HttpContext.Current.Items["deliverycart"] = JsonUtils.GetObjectFromJson<Cart>(cookie);
                        }
                    }
                }
                return HttpContext.Current.Items["deliverycart"] as Cart;
            }
        }


        /// <summary>
        /// 返回网站地址,此方法只在请求上下文中有效
        /// </summary>
        public static string WWWprefix
        {
            get
            {
                if (HttpContext.Current.Items["WWWprefix"] == null)
                {
                    Regex regex = new Regex(@"http://(.+?)/");
                    HttpContext.Current.Items["WWWprefix"] = regex.Match(Url).Value;
                }
                return HttpContext.Current.Items["WWWprefix"] as string;
            }
        }
        private static string _wapbodyid = "index";
        /// <summary>
        /// 返回手机端BodyID值
        /// </summary>
        public static string WapBodyID
        {
            get { return _wapbodyid; }
            set { _wapbodyid = value; }
        }

        private static string _meta = String.Empty;
        /// <summary>
        /// 自定义
        /// </summary>
        public static string Meta 
        {
            get { return _meta; }
            set { _meta = value; }
        }

        #region 分解字符串
        public static string GetSpilt(string userreview)
        {
            string str = "";

            string[] num = new string[] { "\r\n" };

            //System.Text.RegularExpressions.Regex regex = new System.Text.RegularExpressions.Regex(@"\r\n");

            //MatchCollection regmatch = regex.Matches(userreview);

            string[] regmatch = userreview.Split(num, StringSplitOptions.RemoveEmptyEntries);

            str = "<ul>";
            for (int i = 0; i < regmatch.Length; i++)
            {
                string[] value = regmatch[i].Split('|');

                str += "<div><img src='" + WebRoot + "upfile/css/i/quote.gif'/>&nbsp&nbsp";
                // str += "<li>";
                if (0 < value.Length)
                {
                    if (value[0] != null)
                    {
                        str += value[0];
                    }
                }
                if (2 < value.Length)
                {
                    if (value[2] != null)
                    {
                        str += "<span>--<a target='blank' href=" + value[2] + ">";
                    }
                }
                if (1 < value.Length)
                {
                    if (value[1] != null)
                    {
                        str += value[1] + "</a>";
                    }
                }
                if (3 < value.Length)
                {
                    if (value[3] != null)
                    {
                        str += "（" + value[3] + "）";
                    }
                }

                str += "</span></div>";
                //str += "<li>"+value[0]+"<span>－－<a target='blank' href="+value[2]+">"+value[1]+"</a>（"+value[3]+"）</span></li>";

            }
            str += "</ul>";
            return str;
        }
        #endregion




    }
}
