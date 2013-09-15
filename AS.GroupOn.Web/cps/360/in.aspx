<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected string url = String.Empty;
    protected string bid = String.Empty;
    protected string qihoo_id = String.Empty;
    protected string active_time = String.Empty;
    protected string ext = String.Empty;
    protected string sign = String.Empty;
    protected string pre_bid = String.Empty;
    protected string pre_active_time = String.Empty;
    protected string pre_sign = String.Empty;
    protected string qid = String.Empty;
    protected string qname = String.Empty;
    protected string qmail = String.Empty;
    protected string from_url = String.Empty;
    protected string from_ip = String.Empty;
    protected string cp_key = PageValue.CurrentSystemConfig["cps360appkey"];
    protected override void OnLoad(EventArgs e)
    {
        if (PageValue.CurrentSystemConfig["open360"] != null && PageValue.CurrentSystemConfig["open360"] == "1")
        {
            bid = Helper.GetString(Request["bid"], String.Empty);
            qihoo_id = Helper.GetString(Request["qihoo_id"], String.Empty);
            url = Helper.GetString(Request["url"], String.Empty);
            if (url == String.Empty)
            {
                url = PageValue.CurrentSystem.domain;
            }
            from_url = Helper.GetString(Request["from_url"], String.Empty);
            active_time = Helper.GetString(Request["active_time"], String.Empty);
            ext = Helper.GetString(Request["ext"], String.Empty);
            qid = Helper.GetString(Request["qid"], String.Empty);
            qmail = Helper.GetString(Request["qmail"], String.Empty);
            qname = Helper.GetString(Request["qname"], String.Empty);
            sign = Helper.GetString(Request["sign"], String.Empty);
            if (active_time == String.Empty)
            {
                Response.Redirect(UrlMapper.GetUrl("首页", "index.aspx"));
                return;
            }
            if (checkActiveTime(long.Parse(active_time)) && sign == Helper.MD5(bid + "#" + active_time + "#" + cp_key + "#" + qid + "#" + qmail + "#" + qname))
            {
                if (!String.IsNullOrEmpty(qid) && !String.IsNullOrEmpty(qname))
                {
                    CookieUtils.SetCookie("refer", url);
                    SaveCookie(bid, qihoo_id, url, from_url, active_time, ext, sign, qid, qmail, qname);
                    yizhantongLogin(qid + "_" + AS.Enum.YizhantongState.来自360一站通, qname, qmail, AS.Enum.YizhantongState.来自360一站通, String.Empty, "0", this, url, String.Empty, false);
                    SetSuccess("登录成功！");
                    Response.Redirect(url);
                }
                else
                {
                    SaveCookie(bid, qihoo_id, url, from_url, active_time, ext, sign, qid, qmail, qname);
                    Response.Redirect(url);
                }
            }
            else
            {
                long active = Helper.GetTimeFix(DateTime.Now);
                string signs = Helper.MD5(bid + "#" + active_time + "#" + cp_key);
                string from_ip = WebUtils.GetClientIP;
                HttpCookie cookie = new HttpCookie("cps");
                cookie.Values.Add("name", "360");
                cookie.Values.Add("bid", bid);
                cookie.Values.Add("qihoo_id", qihoo_id);
                cookie.Values.Add("active_time", active.ToString());
                cookie.Values.Add("ext", ext);
                cookie.Values.Add("sign", signs);
                cookie.Values.Add("pre_bid", bid);
                cookie.Values.Add("pre_active_time", active_time);
                cookie.Values.Add("pre_sign", sign);
                cookie.Values.Add("qid", qid);
                cookie.Values.Add("qname", qname);
                cookie.Values.Add("qmail", qmail);
                cookie.Values.Add("from_url", from_url);
                cookie.Values.Add("from_ip", from_ip);
                cookie.Domain = WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
                cookie.Path = "/";
                cookie.Expires = DateTime.Now.AddDays(30);
                CookieUtils.SetCookie("fromdomain", "360cps");
                Response.Cookies.Add(cookie);
                string post_url = "http://open.union.360.cn/gofailed";
                ASCIIEncoding encoding = new ASCIIEncoding();
                string postData = String.Join("&", new string[] { "bid=" +bid, 
                                                            "active_time=" + active.ToString(), 
                                                            "sign=" + signs, 
                                                            "pre_bid=" + bid, 
                                                            "pre_active_time=" + active_time, 
                                                            "pre_sign=" + sign, 
                                                            "qid=" + qid, 
                                                            "qname=" + qname, 
                                                            "qmail=" + qmail, 
                                                            "from_url=" + from_url, 
                                                            "from_ip=" + from_ip });

                byte[] data = encoding.GetBytes(postData);
                postRequest(post_url, data);
                Response.Redirect(url);
            }
        }
    }
    /// <summary>
    /// 发送POST数据
    /// </summary>
    /// <param name="url">目标url</param>
    /// <param name="data">post数据</param>
    public static void postRequest(string url, byte[] data)
    {
        System.Net.WebRequest webRequest = System.Net.WebRequest.Create(url);
        System.Net.HttpWebRequest httpRequest = webRequest as System.Net.HttpWebRequest;
        if (httpRequest == null)
        {
            throw new ApplicationException(
                string.Format("Invalid url string: {0}", url)
                );
        }

        httpRequest.UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1;360cps sdk;)";
        httpRequest.ContentType = "application/x-www-form-urlencoded";
        httpRequest.Method = "POST";

        httpRequest.ContentLength = data.Length;
        System.IO.Stream requestStream = httpRequest.GetRequestStream();
        requestStream.Write(data, 0, data.Length);
        requestStream.Close();
    }
    /// <summary>
    /// 检查超时
    /// </summary>
    /// <param name="active_time">请求时的UNIX时间戳</param>
    /// <param name="msg">提示信息</param>
    /// <returns>true：不超时，false：超时</returns>
    public static bool checkActiveTime(long active_time)
    {
        long currentTime = (DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000;
        long diffTime = Math.Abs(currentTime - active_time);   //时间差（s）

        if ((int)diffTime > 900)
        {
            return false;
        }
        return true;
    }
    /// <summary>
    /// 获取当前unix时间戳
    /// </summary>
    /// <returns></returns>
    public static long getCurrentTimestamp()
    {
        long time = (DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000;
        return time;
    }
    protected void SaveCookie(string bid, string qihoo_id, string url, string from_url, string active_time, string ext, string sign, string qid, string qmail, string qname)
    {
        if (Request.Cookies["cps"] == null || Request.Cookies["cps"].Values["name"] != "360")
        {
            HttpCookie cookie = new HttpCookie("cps");
            cookie.Values.Add("name", "360");
            cookie.Values.Add("bid", bid);
            cookie.Values.Add("qihoo_id", qihoo_id);
            cookie.Values.Add("url", url);
            cookie.Values.Add("from_url", from_url);
            cookie.Values.Add("active_time", active_time);
            cookie.Values.Add("ext", ext);
            cookie.Values.Add("sign", sign);
            cookie.Values.Add("qid", qid);
            cookie.Values.Add("qmail", qmail);
            cookie.Values.Add("qname", qname);
            cookie.Domain = WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
            cookie.Path = "/";
            cookie.Expires = DateTime.Now.AddDays(30);

            CookieUtils.SetCookie("fromdomain", "360cps");
            Response.Cookies.Add(cookie);
        }
    }

    public static void yizhantongLogin(string key, string username, string qmail, AS.Enum.YizhantongState yizhantong, string realname, string ucenter, BasePage pages, string referurl, string showMsg, bool redirect)
    {
        key = Helper.GetString(key, String.Empty);
        username = Helper.GetString(username, String.Empty);
        if (key == String.Empty)
        {
            pages.Response.Redirect(UrlMapper.GetUrl("首页", "index.aspx"));
            return;
        }
        qmail = Helper.GetString(qmail, String.Empty);
        CookieUtils.SetCookie("fromdomain", yizhantong.ToString());
        if (qmail == String.Empty) qmail = key;//如果qmail为空。则把key当成qmail
        if (username == String.Empty) username = key;
        //一站通标识
        CookieUtils.SetCookie("yizhantong", "yizhantong");
        //真实姓名
        CookieUtils.SetCookie("realname", realname);
        //查出一站通的用户信息
        IUser iuser = null;
        IYizhantong iyizhantong = null;
        YizhantongFilters yztfilter = new YizhantongFilters();
        yztfilter.Name = key;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iyizhantong = session.Yizhantong.Get(yztfilter);
        }
        if (iyizhantong != null)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iuser = session.Users.GetByID(iyizhantong.userid);
            }
        }
        //判断此用户名是否存在,如果存在就是老用户，否则是新用户
        if (iuser != null)
        {
            if (iyizhantong != null)//是通过key验证来的
            {
                //修改过的用户
                CookieUtils.SetCookie("userid", iuser.Id.ToString(), FileUtils.GetKey(), null);
                WebUtils.SetLoginUserCookie(iuser.Username.ToString(), true);
                pages.SetSuccess("登录成功");
                pages.LoginOK(Helper.GetInt(iuser.Id, 0)); //登陆成功后执行的方法
                CookieUtils.SetCookie("fromdomain", yizhantong.ToString());
                HttpContext.Current.Response.Redirect(((referurl == String.Empty) ? PageValue.CurrentSystem.domain : referurl));
                HttpContext.Current.Response.End();

            }
            else//不是通过key来的 并且是老用户
            {
                IYizhantong iyzt = Store.CreateYizhantong();
                iyzt.name = key;
                iyzt.userid = iuser.Id;
                int a = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    a = session.Yizhantong.InsertYZT(iyzt);
                }
                if (a > 0)
                {
                    CookieUtils.SetCookie("userid", iuser.Id.ToString(), FileUtils.GetKey(), null);
                    WebUtils.SetLoginUserCookie(iuser.Username.ToString(), true);
                    pages.LoginOK(Helper.GetInt(iuser.Id, 0)); //登陆成功后执行的方法
                    pages.SetSuccess("登录成功");
                    CookieUtils.SetCookie("fromdomain", yizhantong.ToString());
                    HttpContext.Current.Response.Redirect(((referurl == String.Empty) ? PageValue.CurrentSystem.domain : referurl));
                    HttpContext.Current.Response.End();
                    return;
                }
                else
                {
                    pages.SetError("登录失败,请重新登录");
                    HttpContext.Current.Response.Redirect(UrlMapper.GetUrl("用户登录", "account_login.aspx"));
                    HttpContext.Current.Response.End();
                    return;
                }
            }
        }
        else
        {

            IUser userinfoModel = Store.CreateUser();
            userinfoModel.Username = Helper.GetString(username, String.Empty);
            userinfoModel.Email = Helper.GetString(qmail, String.Empty);
            if (userinfoModel.Username == String.Empty)
            {
                userinfoModel.Username = key;
            }
            if (userinfoModel.Email == String.Empty)
            {
                userinfoModel.Email = key;
            }
            if (realname != null && realname != "")
                userinfoModel.Realname = realname;

            userinfoModel.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Helper.GetRandomString(10) + BasePage.PassWordKey, "md5");
            userinfoModel.fromdomain = yizhantong.ToString();
            userinfoModel.ucsyc = "nosyc";
            userinfoModel.Enable = "Y";
            userinfoModel.Avatar = PageValue.WebRoot + "upfile/img/man.jpg";
            userinfoModel.IP_Address = CookieUtils.GetCookieValue("gourl");
            userinfoModel.Create_time = DateTime.Now;
            userinfoModel.Newbie = "N";
            userinfoModel.Manager = "N";
            userinfoModel.IP = WebUtils.GetClientIP;
            userinfoModel.Login_time = DateTime.Now;
            userinfoModel.userscore = 0;
            userinfoModel.totalamount = 0;
            userinfoModel.City_id = Helper.GetInt(PageValue.CurrentCity.Id, 0);
            int userid = 0;
            while (true)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    userid = session.Users.Insert(userinfoModel);
                }
                if (userid > 0)
                {
                    IYizhantong iyzt = Store.CreateYizhantong();
                    iyzt.name = key;
                    iyzt.userid = userid;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.Yizhantong.InsertYZT(iyzt);
                    }
                    break;
                }
                else//没有注册成功 可能有重名的帐号或邮箱。随机一下
                {
                    userinfoModel.Username = userinfoModel.Username + Helper.GetRandomString(4);
                    userinfoModel.Email = userinfoModel.Email + Helper.GetRandomString(4);
                }
            }
            pages.SetSuccess("登陆成功!");
            //保存在cookie里面，设置为已登陆状态
            CookieUtils.SetCookie("userid", userinfoModel.Id.ToString(), FileUtils.GetKey(), null);
            WebUtils.SetLoginUserCookie(userinfoModel.Username.ToString(), true);
            pages.LoginOK(userinfoModel.Id); //登陆成功后执行的方法
            HttpContext.Current.Response.Redirect(((referurl == String.Empty) ? PageValue.CurrentSystem.domain : referurl));
            HttpContext.Current.Response.End();
        }
    }
</script>
