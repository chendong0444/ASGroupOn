using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using AS.GroupOn.Controls;


namespace AS.Common.Utils
{
    public class CookieUtils
    {
        /// <summary>
        /// 邮购类cookie名称
        /// </summary>
        public const string deliverycart = "deliverycart";

        /// <summary>
        /// 服务类cookie名称
        /// </summary>
        public const string couponcart = "couponcart";
        /// <summary>
        /// 来源地址
        /// </summary>
        public const string ip_address = "ipaddress";
        /// <summary>
        /// 来源域名
        /// </summary>
        public const string fromdomain = "fromdomain";
        /// <summary>
        /// cookie中的购物车
        /// </summary>
        public const string COOKIE_CAR = "Car";     
        /// <summary>
        /// 设定cookie
        /// </summary>
        /// <param name="cookiename">cookie名称</param>
        /// <param name="cookievalue">cookie值</param>
        public static void SetCookie(string cookiename, string cookievalue)
        {
            SetCookie(cookiename, cookievalue, null);
        }
        /// <summary>
        /// 设定cookie
        /// </summary>
        /// <param name="cookiename">cookie名称</param>
        /// <param name="cookievalue">cookie值</param>
        /// <param name="expires">过期时间</param>
        public static void SetCookie(string cookiename, string cookievalue, DateTime? expires)
        {
            SetCookie(cookiename, cookievalue, String.Empty, expires);
        }
        /// <summary>
        /// 设定cookie
        /// </summary>
        /// <param name="cookiename">cookie名称</param>
        /// <param name="cookievalue">cookie值</param>
        /// <param name="key">加密密钥</param>
        /// <param name="expires">过期时间</param>
        public static void SetCookie(string cookiename, string cookievalue,string key,  DateTime? expires)
        {
            if (cookiename != null && cookievalue != null)
            {
                HttpContext.Current.Response.Cookies.Remove(cookiename);
                HttpCookie cookie = new HttpCookie(cookiename);
                if (!String.IsNullOrEmpty(key))
                {
                    cookievalue = StringUtils.EncryptData(cookievalue, key);
                    cookie.Value = cookievalue;
                }
                else
                cookie.Value = (cookievalue.Length == 0) ? String.Empty : StringUtils.GetUrlBase64(cookievalue);
                if (expires.HasValue)
                    cookie.Expires = expires.Value;
                if (HttpContext.Current != null && HttpContext.Current.Request != null && HttpContext.Current.Request.Url != null)
                    cookie.Domain = WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
                HttpContext.Current.Response.Cookies.Add(cookie);
            }
            
        }

        /// <summary>
        /// 清除指定的cookie
        /// </summary>
        /// <param name="cookiename"></param>
        public static void ClearCookie(string cookiename)
        {
            HttpContext.Current.Response.Cookies.Remove(cookiename);
            HttpCookie cookie = HttpContext.Current.Request.Cookies[cookiename];
            if (cookie != null)
            {
                cookie.Expires = DateTime.Now.AddYears(-3);
                if (HttpContext.Current != null && HttpContext.Current.Request != null && HttpContext.Current.Request.Url != null)
                    cookie.Domain = WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
                HttpContext.Current.Response.Cookies.Add(cookie);
            }
        }

        /// <summary>
        /// 得到指定的Cookie值
        /// </summary>
        /// <param name="cookiename"></param>
        public static string GetCookieValue(string cookiename)
        {
            HttpCookie cookie = HttpContext.Current.Request.Cookies[cookiename];
            string cookievalue = String.Empty;
            string bs64cookie = String.Empty;
            if (cookie != null)
            {
                cookievalue = cookie.Value;
                bs64cookie = cookie.Value;
                if (bs64cookie != null && bs64cookie.Length > 0)
                {
                    bs64cookie = StringUtils.GetUrlFromBase64(bs64cookie);
                    if (bs64cookie != String.Empty) return bs64cookie;
                }
                if (bs64cookie == String.Empty && cookievalue!=String.Empty)
                    return cookievalue;
            }
            return cookievalue;
        }
        /// <summary>
        /// 返回cookie值
        /// </summary>
        /// <param name="cookiename">cookie名称</param>
        /// <param name="key">密钥</param>
        /// <returns></returns>
        public static string GetCookieValue(string cookiename,string key)
        {
            HttpCookie cookie = HttpContext.Current.Request.Cookies[cookiename];
            string cookievalue = String.Empty;
            if (cookie != null)
            {
                cookievalue = cookie.Value;
                if (cookievalue != null && cookievalue.Length > 0)
                {
                    if (!String.IsNullOrEmpty(key))
                    {
                        cookievalue = StringUtils.DecryptData(cookievalue, key);
                    }
                    else
                    {
                        cookievalue = StringUtils.GetUrlFromBase64(cookievalue);
                    }
                }
                    
            }
            return cookievalue;
        }
        /// <summary>
        /// 得到购物车
        /// </summary>
        /// <returns></returns>
        public static string GetCarInfo()
        {
            if (HttpContext.Current.Request.Cookies[COOKIE_CAR] != null)
            {
                string str = HttpContext.Current.Request.Cookies[COOKIE_CAR].Value.ToString();
                return HttpContext.Current.Request.Cookies[COOKIE_CAR].Value.ToString();
            }
            return "";
        }
        /// <summary>
        /// 得到购物车数据
        /// </summary>
        public static List<Car> GetCarData()
        {

            List<Car> carlist = new List<Car>();
            string carInfo = GetCarInfo();
            try
            {
                if (carInfo != "")
                {
                    string sql = "";
                    Car carmodel;

                    foreach (string product in carInfo.Split('|'))
                    {
                        carmodel = new Car();
                        string id = (product.Split(',')[0].ToString());
                        int quantitiy = int.Parse(product.Split(',')[1].ToString());
                        string goodname = product.Split(',')[2].ToString();
                        string money = product.Split(',')[3].ToString();

                        decimal price = decimal.Parse(product.Split(',')[3].ToString());
                        string pic = product.Split(',')[4].ToString();
                        string max = product.Split(',')[5].ToString();

                        string farefee = product.Split(',')[6].ToString();
                        string fee = product.Split(',')[7].ToString();
                        string result = product.Split(',')[8].ToString();
                        string min = product.Split(',')[9].ToString();

                        carmodel.Qid = id;
                        carmodel.Quantity = quantitiy;
                        carmodel.Pic = pic;
                        carmodel.Price = price;
                        carmodel.Goodname = goodname;
                        carmodel.Weight = max;
                        carmodel.min = min;
                        carmodel.Farfee = farefee;
                        carmodel.Fee = fee;
                        carmodel.Result = result;
                        carlist.Add(carmodel);


                    }
                    return carlist;
                }
                else
                {
                    return null;
                }
            }
            catch (Exception ex)
            {
                ClearCar();
                return null;
            }
            // return null;
        }
        /// <summary>
        /// 清空购物车
        /// </summary>
        public static void ClearCar()
        {
            AddCar("");
        }
        /// <summary>
        /// 加入购物车   
        /// </summary>
        public static void AddCar(string product)
        {
            HttpCookie car = new HttpCookie(COOKIE_CAR, product);
            car.Domain = WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
            HttpContext.Current.Response.Cookies.Add(car);
        }

        //保存浏览记录
        public static void AddCookie(string cookievalue)
        {
            //SetCookie("cookie_history", cookievalue);
            if (HttpContext.Current.Request.Cookies["Cookie_historys"] == null)
            {
                SetCookie("Cookie_historys", cookievalue);
            }
            else
            {
                if (cookievalue != "")
                {
                    string myvalue = GetCookieValue("Cookie_historys");
                    string[] allcookievalue;
                    allcookievalue = myvalue.Split(',');
                    //存在项目id了就不添加到cookie
                    for (int i = 0; i < allcookievalue.Length; i++)
                    {
                        if (allcookievalue[i] == cookievalue)
                        {
                            return;
                        }
                    }

                    myvalue = cookievalue + "," + myvalue;
                    SetCookie("Cookie_historys", myvalue);
                }
            }
        }
    }
}
