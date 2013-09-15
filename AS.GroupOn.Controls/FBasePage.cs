using System;
using System.Collections.Generic;
using System.Text;
using System.Collections.Specialized;
using AS.Common.Utils;
using System.Web;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.Domain.Spi;
using AS.GroupOn.App;
using AS.ucenter;
using System.Collections;

namespace AS.GroupOn.Controls
{
    public class FBasePage : BasePage
    {
        NameValueCollection _system = new NameValueCollection();
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            _system = PageValue.CurrentSystemConfig;
            if (_system != null)
            {
                //网站授权判断
                if (_system["record"] != null && _system["record"].ToString() != String.Empty && _system["record"] == "0")
                {
                    Response.Redirect(PageValue.WebRoot + "record.html");
                    Response.End();
                }
                //网站关闭开关
                if (_system["isCloseSite"] != null && _system["isCloseSite"].ToString() != String.Empty && _system["isCloseSite"] == "1")
                {
                    Response.Redirect(GetUrl("网站关闭", "closeweb.aspx"));
                    Response.End();
                }

            }
            if (Request["r"] != null && CookieUtils.GetCookieValue("invitor") == String.Empty)
            {
                int uid = Helper.GetInt(Request["r"], 0);
                if (uid > 0)
                {
                    IUser user = null;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        user = session.Users.GetByID(uid);
                    }
                    if (user != null) CookieUtils.SetCookie("invitor", user.Id.ToString());
                }
            }

            if (CookieUtils.GetCookieValue("gourl").Length == 0)//来源URL
            {
                CookieUtils.SetCookie("gourl", Helper.GetString(Request.ServerVariables["HTTP_REFERER"], "直接输入网址"));
            }
            if (CookieUtils.GetCookieValue("fromdomain").Length == 0)
            {
                string domain = WebUtils.GetDomain(Helper.GetString(Request.ServerVariables["HTTP_REFERER"], "直接输入网址"));
                if (Helper.GetString(Request["tn"], String.Empty).Length > 0 && Helper.GetString(Request["baiduid"], String.Empty).Length > 0) //百度cps参数
                {
                    HttpCookie cookie = new HttpCookie("baidu");
                    cookie.Values.Add("tn", Helper.GetString(Request["tn"], String.Empty));
                    cookie.Values.Add("baiduid", Helper.GetString(Request["baiduid"], String.Empty));
                    Response.Cookies.Add(cookie);
                }
                CookieUtils.SetCookie("fromdomain", domain);
            }
            bool response = false; //是否跳转
            //是否选择了城市
            string url = String.Empty;
            response = isselectcity();
            if (response)
            {
                url = Request.Url.AbsoluteUri.Replace("ename=", "n=");
                if (url.IndexOf("city.aspx") >= 0)
                {
                    string striswrite = Helper.GetString(_system["isrewrite"], "0");
                    if (striswrite == "1")
                    {
                        if (_system["setmallindex"] == "1")
                            url = geturl(url);
                        else
                            url = PageValue.WebRoot + Request["ename"];
                    }
                    else
                    {
                        if (_system["setmallindex"] == "1")
                            url = geturl(url);
                        else
                            url = PageValue.WebRoot + "index.aspx";
                    }
                }
            }
            if (url.Length > 0)
            {
                Response.Redirect(url);
                Response.End();
                return;
            }

            //response = Auth360Login();//360一站通验证
            if (response)
            {
                Response.Redirect(Request.Url.AbsoluteUri);
                Response.End();
                return;
            }
        }
        /// <summary>
        /// 选择城市名称
        /// </summary>
        /// <returns></returns>
        protected bool isselectcity()
        {
            string ename = Helper.GetString(Request["ename"], String.Empty);
            if (ename != String.Empty)
            {
                IList<ICity> citys = null;
                CityFilter filter = new CityFilter();
                filter.Ename = ename;
                using (IDataSession session = Store.OpenSession(false))
                {
                    citys = session.Citys.GetList(filter);
                }
                if (citys != null && citys.Count > 0)
                {
                    PageValue.CurrentCity = citys[0];
                    CookieUtils.SetCookie("cityid", citys[0].Id.ToString(), DateTime.Now.AddYears(1));
                    return true;
                }
                else
                {
                    PageValue.CurrentCity = City.GetDefault();
                    CookieUtils.SetCookie("cityid", "0", DateTime.Now.AddYears(1));
                    return true;
                }
            }
            return false;
        }
        private string geturl(string url)
        {
            _system = PageValue.CurrentSystemConfig;
            if (_system != null)
            {
                if (_system["moretuan"] == "0")
                    url = GetUrl("一日多团一", "index_tuanmore.aspx");
                else if (_system["moretuan"] == "1")
                    url = GetUrl("一日多团二", "index_tuanmore2.aspx");
                else if (_system["moretuan"] == "2")
                    url = GetUrl("一日多团三", "index_tuanmore3.aspx");
                else if (_system["moretuan"] == "3")
                    url = GetUrl("一日多团四", "index_tuanmore4.aspx");
                else if (_system["moretuan"] == "4")
                    url = GetUrl("一日多团五", "index_tuanmore5.aspx");
                else if (_system["moretuan"] == "5")
                    url = GetUrl("一日多团六", "index_tuanmore6.aspx");
            }
            else
            {
                url = "UserControls/team_view.aspx";
            }
            return url;
        }
        private void getFromdomain(string str)
        {
            string fromdomain = "";
            if (str != null)
            {
                string[] s = str.Split('/');
                fromdomain = s[2];

            }
            CookieUtils.SetCookie("fromdomain", Helper.GetString(fromdomain, "直接输入网址"));
        }
        /// <summary>
        /// 用户中心右侧导航
        /// </summary>
        private string ordertype = "";
        public string Ordertype
        {
            get
            {
                return ordertype;
            }
            set
            {
                ordertype = value;
            }
        }
    }
}
