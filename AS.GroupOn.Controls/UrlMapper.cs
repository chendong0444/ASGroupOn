using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Text.RegularExpressions;
using System.Web;
namespace AS.GroupOn.Controls
{
    public class UrlMapper
    {
        /// <summary>
        /// 得到伪静态Url
        /// </summary>
        /// <param name="id">页面名称,参考urlmapper.config文件</param>
        /// <param name="url">原始url地址</param>
        /// <returns></returns>
        public static string GetUrl(string id, string url)
        {
            //映射方法
            initUrlRewrite();
            XmlDocument xmlDoc = HttpContext.Current.Cache["urlmapper"] as XmlDocument;
            XmlNode node = xmlDoc.SelectSingleNode("//url[@id='" + id + "']");
            if (node != null)
            {
                Regex regex = new Regex(node.Attributes["remapper"].Value);
                url = regex.Replace(url, node.Attributes["reurl"].Value);
            }
            return url;
        }

        public static string GetMapperUrl()
        {
            string url = HttpContext.Current.Request.Url.PathAndQuery;
            initUrlRewrite();
            XmlDocument xmlDoc = HttpContext.Current.Cache["urlmapper"] as XmlDocument;
            XmlNodeList nodelist = xmlDoc.SelectNodes("/root/url");
            for (int i = 0; i < nodelist.Count; i++)
            {
                XmlNode node = nodelist[i];
                Regex regex = new Regex("^" + node.Attributes["url"].Value + "$");
                if (regex.IsMatch(url))
                {
                    if (url.ToLower().Contains("wap"))
                        url = regex.Replace(url, String.Format(node.Attributes["mapper"].Value, PageValue.MobileTemplatePath));
                    else
                        url = regex.Replace(url, String.Format(node.Attributes["mapper"].Value, PageValue.TemplatePath));
                    
                    AS.GroupOn.Controls.PageValue.CurrentPageID = node.Attributes["id"].Value;
                    return url;
                }
            }
            return String.Empty;
        }

        /// <summary>
        /// 初始化URL重写
        /// </summary>
        private static void initUrlRewrite()
        {
            if (HttpContext.Current.Cache["urlmapper"] == null)
            {
                string file = AppDomain.CurrentDomain.BaseDirectory +"bin\\urlmapper.config";
                XmlDocument xmldoc = new XmlDocument();
                xmldoc.Load(file);
                HttpContext.Current.Cache.Add("urlmapper", xmldoc, new System.Web.Caching.CacheDependency(file), System.Web.Caching.Cache.NoAbsoluteExpiration, System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Normal, null);
            }
        }
    }
}
