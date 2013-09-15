using System;
using System.Collections.Generic;
using System.Text;
using System.Collections.Specialized;
using System.Web;
using System.Collections;

namespace AS.Common.Utils
{
   public class CacheUtils
    {
       /// <summary>
       /// 返回缓存起来的配置文件。如果要设置配置文件调用FileUtils.SetConfig方法
       /// </summary>
       public static NameValueCollection Config
       {
           get
           {
               if (System.Web.HttpContext.Current.Cache["Config"] == null)
               {

                   System.Web.HttpContext.Current.Cache.Add("Config", FileUtils.GetConfig(), new System.Web.Caching.CacheDependency(AppDomain.CurrentDomain.BaseDirectory + "config\\data.config"), System.Web.Caching.Cache.NoAbsoluteExpiration, System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Normal, null);
               }
               return (System.Collections.Specialized.NameValueCollection)System.Web.HttpContext.Current.Cache["Config"];
           }
       }

       /// <summary>
       /// 清除页面缓存
       /// </summary>
       public static object locker = new object();
       public static void ClearPageCache()
       {
           lock (locker)
           {
               foreach (DictionaryEntry entry in HttpContext.Current.Cache)
               {
                   if (entry.Key.ToString().IndexOf("cacheusercontrol-") >= 0)
                   {
                       HttpContext.Current.Cache.Remove(entry.Key.ToString());
                   }
               }
           }
       }





    }
}
