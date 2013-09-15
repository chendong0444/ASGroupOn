using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Web.UI;
using AS.Common.Utils;
using AS.GroupOn.Controls;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess;
using System.Text.RegularExpressions;
using System.Web;
using System.Collections.Specialized;
using AS.Enum;
using AS.GroupOn.DataAccess.Filters;
using System.Collections;
using AS.GroupOn.App;
using System.Xml;
using AS.Ucenter;

namespace AS.GroupOn.Controls
{
    /// <summary>
    /// 页面基类
    /// </summary>
    public class BasePage : System.Web.UI.Page
    {
        /// <summary>
        /// md5混合加密用的值
        /// </summary>
        public const string PassWordKey = "@4!@#$%@";
        public string Key = FileUtils.GetKey();//cookie加密密钥
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            Response.AddHeader("P3P", "CP=CAO PSA OUR");
            Response.AddHeader("Cache-Control", "no-cache");
            PageInit();
        }
        public virtual void PageInit()
        {
            string nowUrl = Request.RawUrl;
            if (nowUrl.Contains("/newlist"))
            {
                #region 新闻页面的seo信息
                if (Request["id"] != null && Request["id"].ToString() != "")
                {
                    INews newsmodel = null;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        newsmodel = session.News.GetByID(Helper.GetInt(Request["id"].ToString(), 0));
                    }
                    if (newsmodel != null)
                    {
                        if (!String.IsNullOrEmpty(newsmodel.seotitle))
                        {
                            PageValue.Title = newsmodel.seotitle;
                        }
                        else if (!String.IsNullOrEmpty(ASSystem.title))
                        {
                            PageValue.Title = ASSystem.title;
                        }
                        else
                        {
                            PageValue.Title = newsmodel.title + "-" + ASSystem.title;
                        }
                        if (!String.IsNullOrEmpty(newsmodel.seokeyword))
                        {
                            PageValue.KeyWord = newsmodel.seokeyword;
                        }
                        else if (!String.IsNullOrEmpty(ASSystem.keyword))
                        {
                            PageValue.KeyWord = ASSystem.keyword;
                        }
                        else
                        {
                            PageValue.KeyWord = newsmodel.title + "-" + ASSystem.title;
                        }
                        if (!String.IsNullOrEmpty(newsmodel.seodescription))
                        {
                            PageValue.Description = newsmodel.seodescription;
                        }
                        else if (!String.IsNullOrEmpty(ASSystem.description))
                        {
                            PageValue.Description = ASSystem.description;
                        }
                        else
                        {
                            PageValue.Description = newsmodel.title + "-" + ASSystem.title;
                        }
                    }
                }
                #endregion 新闻页面的seo信息
            }
            else if (nowUrl.Contains("/team") || nowUrl.Contains("/PointsShop") || nowUrl.Contains("deal"))
            {
                #region 项目页面的seo信息
                if (Request["id"] != null && Request["id"].ToString() != "")
                {
                    ITeam team = null;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        team = session.Teams.GetByID(Helper.GetInt(Request["id"].ToString(), 0));
                    }
                    if (team != null)
                    {
                        if (!String.IsNullOrEmpty(team.seotitle))
                        {
                            PageValue.Title = team.seotitle;
                        }
                        else if (!String.IsNullOrEmpty(ASSystem.title))
                        {
                            PageValue.Title = ASSystem.title;
                        }
                        else
                        {
                            PageValue.Title = team.seotitle + "-" + ASSystem.title;
                        }
                        if (!String.IsNullOrEmpty(team.seokeyword))
                        {
                            PageValue.KeyWord = team.seokeyword;
                        }
                        else if (!String.IsNullOrEmpty(ASSystem.keyword))
                        {
                            PageValue.KeyWord = ASSystem.keyword;
                        }
                        else
                        {
                            PageValue.KeyWord = team.seotitle + "-" + ASSystem.title;
                        }
                        if (!String.IsNullOrEmpty(team.seodescription))
                        {
                            PageValue.Description = team.seodescription;
                        }
                        else if (!String.IsNullOrEmpty(ASSystem.description))
                        {
                            PageValue.Description = ASSystem.description;
                        }
                        else
                        {
                            PageValue.Description = team.seotitle + "-" + ASSystem.title;
                        }
                    }
                }
                else
                {
                    if (!String.IsNullOrEmpty(ASSystem.title))
                    {
                        PageValue.Title = ASSystem.title;
                    }
                    if (!String.IsNullOrEmpty(ASSystem.keyword))
                    {
                        PageValue.KeyWord = ASSystem.keyword;
                    }
                    if (!String.IsNullOrEmpty(ASSystem.description))
                    {
                        PageValue.Description = ASSystem.description;
                    }
                }
                #endregion 项目页面的seo信息
            }
            else if (nowUrl.Contains("/mall"))
            {
                NameValueCollection _system = new NameValueCollection();
                _system = PageValue.CurrentSystemConfig;
                if (nowUrl.Contains("/mall/goods") || nowUrl.Contains("/mall/product"))
                {
                    #region 商城项目页面的seo信息
                    if (Request["id"] != null && Request["id"].ToString() != "")
                    {
                        ITeam team = null;
                        using (IDataSession session = Store.OpenSession(false))
                        {
                            team = session.Teams.GetByID(Helper.GetInt(Request["id"].ToString(), 0));
                        }
                        if (team != null)
                        {
                            if (!String.IsNullOrEmpty(team.seotitle))
                            {
                                PageValue.Title = team.seotitle;
                            }
                            else if (_system["malltitle"] != null && _system["malltitle"].ToString() != "")
                            {
                                PageValue.Title = _system["malltitle"];
                            }
                            else
                            {
                                PageValue.Title = team.Title + "-" + _system["mallsitename"];
                            }
                            if (!String.IsNullOrEmpty(team.seokeyword))
                            {
                                PageValue.KeyWord = team.seokeyword;
                            }
                            else if (_system["mallkeyword"] != null && _system["mallkeyword"].ToString() != "")
                            {
                                PageValue.KeyWord = _system["mallkeyword"].ToString();
                            }
                            else
                            {
                                PageValue.KeyWord = team.Title + "-" + _system["mallsitename"];
                            }
                            if (!String.IsNullOrEmpty(team.seodescription))
                            {
                                PageValue.Description = team.seodescription;
                            }
                            else if (_system["malldescription"] != null && _system["malldescription"].ToString() != "")
                            {
                                PageValue.Description = _system["malldescription"].ToString();
                            }
                            else
                            {
                                PageValue.Description = team.Title + "-" + _system["mallsitename"];
                            }
                        }
                    }
                    #endregion 项目页面的seo信息
                }
                else
                {
                    #region 系统商城设置的SEO项开始
                    if (!String.IsNullOrEmpty(_system["malltitle"]))
                    {
                        PageValue.Title = _system["malltitle"].ToString();
                    }
                    else
                    {
                        PageValue.Title = _system["mallsitename"];
                    }
                    if (!String.IsNullOrEmpty(_system["mallkeyword"]))
                    {
                        PageValue.KeyWord = _system["mallkeyword"].ToString();
                    }
                    else
                    {
                        PageValue.KeyWord = "艾尚团购，打折，商城，打折，精品消费，购物指南，消费指南";
                    }
                    if (!String.IsNullOrEmpty(_system["malldescription"]))
                    {
                        PageValue.Description = _system["malldescription"].ToString();
                    }
                    #endregion 系统商城设置的SEO项结束
                }
            }
            else
            {
                #region 系统设置的SEO项开始
                string cityname = "全国";
                if (PageValue.CurrentCity != null && PageValue.CurrentCity.Name != null)
                {
                    cityname = PageValue.CurrentCity.Name;
                }
                if (!String.IsNullOrEmpty(ASSystem.sitetitle))
                {
                    PageValue.Title = ASSystem.sitetitle;
                }
                else
                {
                    PageValue.Title = ASSystem.sitetitle + ", " + cityname + ", " + cityname + ASSystem.sitename + "，" + cityname + "购物，" + cityname + "团购，" + cityname + "打折，团购，打折，精品消费，购物指南，消费指南";
                }
                if (!String.IsNullOrEmpty(ASSystem.keyword))
                {
                    PageValue.KeyWord = ASSystem.keyword;
                }
                else
                {
                    PageValue.KeyWord = ASSystem.sitetitle + ", " + cityname + ", " + cityname + ASSystem.sitename + "，" + cityname + "购物，" + cityname + "团购，" + cityname + "打折，团购，打折，精品消费，购物指南，消费指南";
                }
                if (!String.IsNullOrEmpty(ASSystem.description))
                {
                    PageValue.Description = ASSystem.description;
                }
                #endregion 系统设置的SEO项结束
            }
        }
        /// <summary>
        /// 返回系统设置
        /// </summary>
        private ISystem _assystem = null;
        public ISystem ASSystem
        {
            get
            {
                if (_assystem == null)
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        _assystem = session.System.GetByID(1);
                    }
                }
                return _assystem;
            }
            set
            {
                _assystem = value;
            }
        }

        /// <summary>
        /// 返回用户名 只适用于普通会员 如果没有登录 返回空
        /// </summary>
        public string UserName
        {
            get
            {
                string username = String.Empty;
                if (CookieUtils.GetCookieValue("username",Key) != String.Empty)
                {
                    username = CookieUtils.GetCookieValue("username",Key);
                }
                return username;
            }
        }

        public static object locker = new object();
        public void LoadUserControl(string userControlVirtualPath, object obj)
        {
            StringWriter sw = new StringWriter();
            HtmlTextWriter htw = new HtmlTextWriter(sw);
            Control c = Page.LoadControl(userControlVirtualPath);
            IUserControl uc = c as IUserControl;
            if (uc != null)
            {
                uc.HTW = htw;
                uc.Params = obj;
                if (CacheUtils.Config["pagecache"] == "1" && uc.CanCache)//如果可以缓存
                {
                    if (uc.CacheKey.Length > 0)
                    {
                        //判断是否被缓存了
                        if (Cache[uc.CacheKey] == null)
                        {
                            uc.UpdateView();
                            c.RenderControl(htw);
                            lock (locker)
                            {
                                if (Cache[uc.CacheKey] == null)
                                    Cache.Add(uc.CacheKey, sw, null, DateTime.Now.AddMinutes(5), System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Normal, null);
                            }
                        }
                        else
                        {
                            sw = Cache[uc.CacheKey] as StringWriter;
                        }

                    }
                    else
                    {
                        uc.UpdateView();
                        c.RenderControl(htw);
                    }
                }
                else
                {
                    uc.UpdateView();
                    c.RenderControl(htw);
                }
            }
            Response.Output.Write(sw.GetStringBuilder().ToString());
        }
        /// <summary>
        /// 替换
        /// </summary>
        /// <param name="name"></param>
        /// <param name="values"></param>
        /// <returns></returns>
        public static string ReplaceStr(string name, NameValueCollection values)
        {
            NameValueCollection templates = new NameValueCollection();
            if (System.Web.HttpContext.Current.Cache["smstemplate"] == null)
            {
                IList<ISmstemplate> smslist = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    smslist = session.Smstemplate.GetList(null);
                }
                if (smslist != null)
                {
                    foreach (var row in smslist)
                    {
                        templates.Add(row.name, row.value);
                    }
                    System.Web.HttpContext.Current.Cache.Add("smstemplate", templates, null, System.Web.Caching.Cache.NoAbsoluteExpiration, System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Normal, null);
                }
            }
            else
            {
                templates = (NameValueCollection)System.Web.HttpContext.Current.Cache["smstemplate"];
            }
            string content = Helper.GetString(templates[name], String.Empty);
            if (content != "")
            {
                for (int i = 0; i < values.Keys.Count; i++)
                {
                    content = content.Replace("{" + values.Keys[i] + "}", values[values.Keys[i]]);
                }
            }
            return content;
        }
        public string LoadUserControlHtml(string userControlVirtualPath, object obj)
        {
            StringWriter sw = new StringWriter();
            HtmlTextWriter htw = new HtmlTextWriter(sw);
            Control c = Page.LoadControl(userControlVirtualPath);
            IUserControl uc = c as IUserControl;
            if (uc != null)
            {
                uc.HTW = htw;
                uc.Params = obj;
                if (CacheUtils.Config["pagecache"] == "1" && uc.CanCache)//如果可以缓存
                {
                    if (uc.CacheKey.Length > 0)
                    {
                        //判断是否被缓存了
                        if (Cache[uc.CacheKey] == null)
                        {
                            uc.UpdateView();
                            c.RenderControl(htw);
                            lock (locker)
                            {
                                if (Cache[uc.CacheKey] == null)
                                    Cache.Add(uc.CacheKey, sw, null, DateTime.Now.AddMinutes(5), System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Normal, null);
                            }
                        }
                        else
                        {
                            sw = Cache[uc.CacheKey] as StringWriter;
                        }

                    }
                    else
                    {
                        uc.UpdateView();
                        c.RenderControl(htw);
                    }
                }
                else
                {
                    uc.UpdateView();
                    c.RenderControl(htw);
                }
            }
            return sw.GetStringBuilder().ToString();
        }
        /// <summary>
        /// 检测当前用户是否登录 只适用于普通会员
        /// </summary>
        public bool IsLogin
        {
            get
            {
                bool login = false;
                if (WebUtils.GetLoginUserName().Length > 0)
                    login = true;
                return login;
            }
        }
        private IUser _user = null;
        /// <summary>
        /// 返回当前用户(默认不为null,默认ID是0)
        /// </summary>
        public IUser AsUser
        {
            get
            {
                if (_user == null)
                {
                    if (WebUtils.GetLoginUserName().Length > 0)
                    {
                        using (IDataSession session = App.Store.OpenSession(false))
                        {
                            _user = session.Users.GetByID(Helper.GetInt(WebUtils.GetLoginUserID(), 0));
                        }
                    }
                    if (_user == null) _user = AS.GroupOn.Domain.Spi.User.GetDefault();
                }
                return _user;
            }
        }
        private NameValueCollection _ASUserArr = null;
        public NameValueCollection ASUserArr
        {
            get
            {
                if (AsUser.Id != 0) _ASUserArr = Helper.GetObjectProtery(AsUser);
                else _ASUserArr = new NameValueCollection();
                return _ASUserArr;
            }
        }
        /// <summary>
        /// 返回前台皮肤图片路径
        /// </summary>
        /// <returns></returns>
        public string ImagePath()
        {
            return PageValue.CssPath + "/css/i/";
        }
        /// <summary>
        /// 得到项目详情页面路径
        /// </summary>
        /// <param name="id">项目id</param>
        /// <returns></returns>
        public static string getTeamPageUrl(int id)
        {
            ITeam mteam = null;
            NameValueCollection _system = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mteam = session.Teams.GetByID(id);
            }
            string strNewUrl = "";
            if (mteam != null)
            {
                if (mteam.teamcata == 0)
                {
                    strNewUrl = PageValue.WebRoot + "team/" + id + ".html";
                }
                else if (mteam.teamcata == 1)
                {
                    _system = WebUtils.GetSystem();
                    if (_system != null && _system["MallTemplate"] != null && _system["MallTemplate"].ToString() == "1")
                    {
                        strNewUrl = PageValue.WebRoot + "mall/product/" + id + ".html";
                    }
                    else
                    {
                        strNewUrl = PageValue.WebRoot + "mall/goods/" + id + ".html";
                    }
                }
            }
            else
            {
                strNewUrl = "#";
            }
            return strNewUrl;
        }
        /// <summary>
        /// 获取手机端项目详情地址
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public static string GetMobilePageUrl(int id)
        {
            ITeam mteam = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mteam = session.Teams.GetByID(id);
            }
            string strNewUrl = "";
            if (mteam != null)
            {
                if (mteam.teamcata == 0)
                {
                    strNewUrl = PageValue.WebRoot + "wap/deal/" + id + ".html";
                }
            }
            else
            {
                strNewUrl = "#";
            }
            return strNewUrl;
        }
        private NameValueCollection _assytemarr = null;
        public NameValueCollection ASSystemArr
        {
            get
            {
                if (ASSystem != null) _assytemarr = Helper.GetObjectProtery(ASSystem);
                else _assytemarr = new NameValueCollection();
                return _assytemarr;
            }
        }
        /// <summary>
        /// 当前城市
        /// </summary>
        public ICity CurrentCity
        {
            get
            {
                return PageValue.CurrentCity;
            }
        }
        /// <summary>
        /// 得到伪静态Url
        /// </summary>
        /// <param name="id">页面名称,参考urlmapper.config文件</param>
        /// <param name="url">原始url地址</param>
        /// <returns></returns>
        public string GetUrl(string id, string url)
        {
            return UrlMapper.GetUrl(id, url);
        }

        /// <summary>
        /// 表单提交失败后。返回此表单元素之前输入的值
        /// </summary>
        /// <param name="name">元素名称</param>
        /// <returns></returns>
        public string GetErrorData(string name)
        {
            return PageValue.GetErrorData(name);
        }
        /// <summary>
        /// 设置错误信息
        /// </summary>
        /// <param name="errtext"></param>
        public void SetError(string errtext)
        {
            Session["err"] = errtext;
            Session["type"] = 1;
        }
        /// <summary>
        /// 设置成功信息
        /// </summary>
        /// <param name="successtext"></param>
        public void SetSuccess(string successtext)
        {
            Session["err"] = successtext;
            Session["type"] = 2;
        }

        #region 一站通
        public bool Auth360Login()
        {
            NameValueCollection configs = new NameValueCollection();
            configs = PageValue.CurrentSystemConfig;
            string from = Request["from"];//来源

            #region 360一站通
            if (CookieUtils.GetCookieValue("username") == String.Empty && configs["is360login"] == "1" && from == "hao360")//启用了360验证
            {
                //判断签名是否正确
                string sign = Request["sign"];//签名
                string qid = Request["qid"];//用户ID
                string qname = Server.UrlDecode(Request["qname"]);//用户名
                string qmail = Server.UrlDecode(Request["qmail"]);//邮箱
                string key = configs["login360key"];//系统key值
                string secret = configs["login360secret"];//校验码
                string code = Helper.MD5(qid + "|" + qname + "|" + qmail + "|" + from + "|" + key + "|" + secret);
                string v = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(qid + "|" + qname + "|" + qmail + "|" + from + "|" + key + "|" + secret, "md5");
                if (code == sign)
                {//验证通过
                    CookieUtils.SetCookie("360_qid", qid);//通过此值可判断是360一站通登录用户
                    CookieUtils.SetCookie("360_qname", qname);
                    if (String.IsNullOrEmpty(qmail)) qmail = qname + "@hao360.cn";
                    //如果有则直接调取该用户信息 设置为已登录状态
                    SetRefer();
                    YizhantongVerifier.YizhantongLogin(qid + "_" + YizhantongState.来自360一站通, qname, qmail, YizhantongState.来自360一站通, String.Empty, configs["UC_Islogin"], this, Request.Url.AbsoluteUri);
                    return true;
                }
            }
            #endregion

            #region 2345一站通
            if (configs["is2345login"] == "1" && from == "tuan2345")//启用了360验证
            {
                //判断签名是否正确
                string sign = Request["sign"];//签名
                string qid = Request["qid"];//用户ID
                string qname = Request["qname"];//用户名
                string qmail = Request["qmail"];//邮箱
                string key = configs["login2345key"];//系统key值
                string secret = configs["login2345secret"];//校验码
                string gurl = Helper.GetString(Request["gurl"], String.Empty);
                string code = Helper.MD5(qid + "|" + qname + "|" + qmail + "|" + from + "|" + gurl + "|" + key + "|" + secret);
                if (Helper.MD5(qid + "|" + qname + "|" + qmail + "|" + from + "|" + gurl + "|" + key + "|" + secret) == sign)
                {//验证通过
                    if (CookieUtils.GetCookieValue("username").Length > 0)
                        Response.Redirect(Request.QueryString["gurl"]);

                    CookieUtils.SetCookie("2345_qid", qid);
                    CookieUtils.SetCookie("2345_qname", qname);
                    if (String.IsNullOrEmpty(qmail)) qmail = qname + "@tuan.2345.com";
                    //如果有则直接调取该用户信息 设置为已登录状态
                    string url = Helper.GetString(Request.QueryString["gurl"], String.Empty);
                    SetRefer(url);
                    YizhantongVerifier.YizhantongLogin(qid + "_" + YizhantongState.来自2345一站通, qname, qmail, YizhantongState.来自2345一站通, String.Empty, configs["UC_Islogin"], this, url);
                    return true;
                }
            }

            #endregion

            #region Tuan800一站通
            if (CookieUtils.GetCookieValue("username") == String.Empty && configs["istuan800login"] == "1" && from == "tuan800")//启用了360验证
            {
                //判断签名是否正确
                string sign = Request["sign"];//签名
                string qid = Request["qid"];//用户ID
                string qname = Server.UrlDecode(Request["qname"]);//用户名
                string qmail = Server.UrlDecode(Request["qmail"]);//邮箱
                string key = configs["logintuan800key"];//系统key值
                string secret = configs["logintuan800secret"];//校验码
                string gurl = Helper.GetString(Request["gurl"], String.Empty);
                string code = Helper.MD5(qid + "|" + qname + "|" + qmail + "|" + from + "|" + key + "|" + secret);
                if (Helper.MD5(qid + "|" + qname + "|" + qmail + "|" + from + "|" + key + "|" + secret) == sign)
                {//验证通过
                    CookieUtils.SetCookie("tuan800_qid", qid);//通过此值可判断是360一站通登录用户
                    CookieUtils.SetCookie("tuan800_qname", qname);
                    qmail = qname + "@tuan800.com";
                    //如果有则直接调取该用户信息 设置为已登录状态
                    SetRefer();
                    YizhantongVerifier.YizhantongLogin(qmail + "_" + YizhantongState.来自团800一站通, qname, qmail, YizhantongState.来自团800一站通, String.Empty, configs["UC_Islogin"], this, Request.Url.AbsoluteUri);
                    return true;
                }
            }

            #endregion

            #region 启用搜狐一站通
            if (CookieUtils.GetCookieValue("username") == String.Empty && Request.QueryString["passport"] != null && Request.QueryString["time"] != null && Request.QueryString["sign"] != null)//启用一站通
            {
                configs = System.Web.HttpUtility.ParseQueryString(Request.Url.Query, System.Text.Encoding.GetEncoding("gb2312"));
                DateTime time = Helper.GetWindowsTime(configs["time"]);
                if (System.Math.Abs((time - DateTime.Now).Days) < 1)
                {
                    string txt = Helper.MD5(configs["passport"] + "|" + configs["nick"] + "|" + Helper.GetWindowsTime(configs["time"]).ToString("yyyy-MM-dd HH:mm:ss") + "|" + ASSystem.sohuloginkey);

                    if (Request["sign"] == txt)
                    {
                        //4:如果等于则 检查user表是否有email=passport 或者 username=passport  
                        //如果有则直接调取该用户信息 设置为已登录状态
                        string key = Request["passport"] + "_" + YizhantongState.来自搜狐一站通;
                        CookieUtils.SetCookie("sohu_qid", key);
                        YizhantongVerifier.YizhantongLogin(key, String.Empty, configs["passport"], YizhantongState.来自搜狐一站通, String.Empty, WebUtils.config["UC_Islogin"], this, Request.Url.AbsoluteUri);

                    }
                    return true;
                }
            }
            #endregion

            return false;
        }
        #endregion

        #region 如果没有存在install.ok这个文件，那么跳转到安装页面
        public bool GetRedirect()
        {
            string folter = Server.MapPath(PageValue.WebRoot + "db/");
            string installfile = folter + "install.ok";
            if (!File.Exists(installfile))
            {
                Response.Redirect("install.aspx");

                Response.End();
                return false;
            }
            return true;
        }
        #endregion

        /// <summary>
        /// 网站根路径
        /// </summary>
        public string WebRoot
        {
            get
            {
                return PageValue.WebRoot;
            }
        }

        public string TemplatePath
        {
            get
            {
                return PageValue.TemplatePath;
            }
        }
        public ITeam CurrentTeam
        {
            get
            {
                if (!Page.Items.Contains("CurrentTeam"))
                {
                    List<Hashtable> hs = new List<Hashtable>();
                    ITeam team = null;
                    if (CurrentCity == null)
                    {
                        string sql = "select top 1 id from team where (Team_type='normal' or Team_type='draw')  and teamcata=0 and Begin_time<='" + DateTime.Now.ToString() + "' and End_time>='" + DateTime.Now.ToString() + "'  order by  sort_order desc,Begin_time desc,id desc";
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            hs = session.GetData.GetDataList(sql);
                        }
                    }
                    else
                    {
                        string sql = "select top 1 id from team where (Team_type='normal' or Team_type='draw')  and teamcata=0 and ((City_id=" + CurrentCity.Id + " or city_id=0) or  ','+othercity+',' like '%," + CurrentCity.Id + ",%') and  Begin_time<='" + DateTime.Now.ToString() + "' and End_time>='" + DateTime.Now.ToString() + "'  order by  sort_order desc,Begin_time desc,id desc";
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            hs = session.GetData.GetDataList(sql);
                        }

                    }
                    if (hs.Count > 0)
                    {
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            team = session.Teams.GetByID(Helper.GetInt(hs[0]["id"], 0));
                        }
                        Page.Items["CurrentTeam"] = team;
                    }
                }
                return Page.Items["CurrentTeam"] as ITeam;
            }
        }

        /// <summary>
        /// 设置返回地址
        /// </summary>
        /// <param name="url"></param>
        public void SetRefer(string url)
        {
            CookieUtils.SetCookie("refer", url);
        }
        /// <summary>
        /// 设置返回地址为当前地址
        /// </summary>
        public void SetRefer()
        {
            CookieUtils.SetCookie("refer", PageValue.Url);
        }

        /// <summary>
        /// 得到返回地址
        /// </summary>
        /// <returns></returns>
        public static string GetRefer()
        {
            string url = CookieUtils.GetCookieValue("refer");
            if (url == String.Empty) url = PageValue.WebRoot + "Index.aspx";
            CookieUtils.ClearCookie("refer");
            return url;
        }


        /// <summary>
        /// 得到网站地址
        /// </summary>
        public string WWWprefix
        {
            get
            {
                Regex regex = new Regex(@"http://(.+?)/");
                return regex.Match(Request.Url.AbsoluteUri).Value;
            }
        }
        /// <summary>
        /// 检测是否开启简繁转换
        /// </summary>
        public bool IsTotw
        {
            get
            {
                bool isok = false;
                string locale = CookieUtils.GetCookieValue("totw");
                {
                    if (locale != String.Empty && locale == "zh_tw")
                        isok = true;
                    else
                        isok = false;
                }
                return isok;
            }
        }
        /// <summary>
        /// 得到当前项目状态
        /// </summary>
        /// <param name="t"></param>
        /// <returns></returns>
        public AS.Enum.TeamState GetState(ITeam t)
        {
            NameValueCollection _system = new NameValueCollection();
            _system = PageValue.CurrentSystemConfig;
            if (t.Begin_time > DateTime.Now) //未开始
                return AS.Enum.TeamState.none;
            //1未开始 2 4 8
            if (t.Begin_time > DateTime.Now) //未开始
                return AS.Enum.TeamState.none;
            if (t.End_time < DateTime.Now)//结束时间小于当前时间，结束时间已过
            {
                //项目已结束，并且当前购买人数，并且已卖光状态
                if ((t.Now_number >= t.Max_number && t.Max_number != 0 && t.Now_number != 0) || (Helper.GetInt(t.open_invent, 0) == 1 && Helper.GetInt(t.inventory, 0) == 0) || t.status == 8)
                {
                    return AS.Enum.TeamState.successnobuy; //已结束不可以购买已卖光
                }
                else
                {
                    if (t.Now_number < t.Min_number)//购买人数小于最小成团人数
                    {
                        return AS.Enum.TeamState.fail;  //失败项目： if(当前时间> 项目结束时间 && 最小成团人数>项目当前人数)
                    }
                    else
                    {
                        return AS.Enum.TeamState.successtimeover; //成功项目 if(当前时间> 项目结束时间 && 最小成团人数<=项目当前人数)
                    }
                }

            }
            else if (DateTime.Now <= t.End_time)//当前时间小于等于项目结束时间
            {

                if ((t.Now_number >= t.Max_number && t.Max_number != 0 && t.Now_number != 0) || (Helper.GetInt(t.open_invent, 0) == 1 && Helper.GetInt(t.inventory, 0) == 0) || t.status == 8)
                {

                    return AS.Enum.TeamState.successnobuy; //已成功未过期不可以购买已卖光
                }
                else
                {
                    if (t.Now_number < t.Min_number)
                    {
                        if (t.Now_number >= t.Min_number)//当前人数 大于最小成团人数
                        {
                            return AS.Enum.TeamState.successbuy;//已成功未过期可以购买   //成功项目:if(项目结束时间>=当前时间>= 项目开始时间 && 项目最大购买人数>0&& 最小成团人数<=项目当前人数)
                        }
                        else
                        {
                            return AS.Enum.TeamState.begin;//正在进行   //正在进行项目:if(项目结束时间>=当前时间>= 项目开始时间 && 项目最大购买人数>0&& 最小成团人数>项目当前人数)
                        }
                    }
                    else
                    {

                        if (t.Now_number < t.Min_number)
                        {
                            return AS.Enum.TeamState.begin;//正在进行   //正在进行项目:if(项目结束时间>=当前时间>= 项目开始时间 && 项目最大购买人数=0&& 最小成团人数>项目当前人数)
                        }
                        else
                        {
                            if (t.Max_number == 0 && t.Now_number == 0)
                            {
                                return AS.Enum.TeamState.begin;
                            }
                            else
                            {
                                return AS.Enum.TeamState.successbuy;//已成功未过期可以购买      //成功项目:if(项目结束时间>=当前时间>= 项目开始时间 && 项目最大购买人数=0&& 最小成团人数<=项目当前人数)
                            }
                        }
                    }
                }
            }
            return AS.Enum.TeamState.none;  //未开始项目
        }
        public string GetMoney(object price)
        {
            string money = String.Empty;
            if (price != null)
            {
                Regex regex = new Regex(@"^(\d+)$|^(\d+.[1-9])0$|^(\d+).00$");
                Match match = regex.Match(price.ToString());
                if (match.Success)
                {
                    money = regex.Replace(match.Value, "$1$2$3");
                }
                else
                {
                    money = price.ToString();
                    if (money.IndexOf(".00") > 0)
                    {
                        money = money.Substring(0, money.IndexOf(".00"));
                    }
                }
            }
            return money;
        }
        public void ClearCookie()
        {

            HttpCookie cookie1 = new HttpCookie("username");
            cookie1.Expires = DateTime.Now.AddYears(-2);
            if (HttpContext.Current != null && HttpContext.Current.Request != null && HttpContext.Current.Request.Url != null)
                cookie1.Domain = AS.Common.Utils.WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
            HttpContext.Current.Response.AppendCookie(cookie1);
            HttpCookie cookie2 = new HttpCookie("admin");
            if (HttpContext.Current != null && HttpContext.Current.Request != null && HttpContext.Current.Request.Url != null)
                cookie2.Domain = AS.Common.Utils.WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
            cookie2.Expires = DateTime.Now.AddYears(-2);
            HttpContext.Current.Response.AppendCookie(cookie2);
            HttpCookie cookie3 = new HttpCookie("partnerid");
            if (HttpContext.Current != null && HttpContext.Current.Request != null && HttpContext.Current.Request.Url != null)
                cookie3.Domain = AS.Common.Utils.WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
            cookie3.Expires = DateTime.Now.AddYears(-2);
            HttpContext.Current.Response.AppendCookie(cookie3);
            HttpCookie cookie4 = new HttpCookie("saleIdCookie");
            if (HttpContext.Current != null && HttpContext.Current.Request != null && HttpContext.Current.Request.Url != null)
                cookie4.Domain = AS.Common.Utils.WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
            cookie4.Expires = DateTime.Now.AddYears(-2);
            HttpContext.Current.Response.AppendCookie(cookie4);
            HttpCookie cookie5 = new HttpCookie("branchIdCookie");
            if (HttpContext.Current != null && HttpContext.Current.Request != null && HttpContext.Current.Request.Url != null)
                cookie5.Domain = AS.Common.Utils.WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
            cookie5.Expires = DateTime.Now.AddYears(-2);
            HttpContext.Current.Response.AppendCookie(cookie5);
            HttpCookie cookie6 = new HttpCookie("userid");
            cookie6.Expires = DateTime.Now.AddYears(-2);
            if (HttpContext.Current != null && HttpContext.Current.Request != null && HttpContext.Current.Request.Url != null)
                cookie6.Domain = AS.Common.Utils.WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
            HttpContext.Current.Response.AppendCookie(cookie6);
        }

        /// <summary>
        /// url重写，得到分类详情页面路径
        /// </summary>
        /// <param name="catalogid"></param>
        /// <param name="brandid"></param>
        /// <param name="sort"></param>
        /// <param name="areaid"></param>
        /// <param name="keyword"></param>
        /// <returns></returns>
        public static string getTeamDetailPageUrl(int catalogid, int brandid, int sort, int areaid, string keyword)
        {
            string strNewUrl = string.Format(PageValue.WebRoot + "team/list/{0}/{1}/{2}/{3}.html", catalogid, brandid, sort, areaid);
            if (Helper.GetString(keyword, String.Empty) != String.Empty)
            {
                strNewUrl = string.Format(PageValue.WebRoot + "team/list/{0}/{1}/{2}/{3}.html?keyword={4}", catalogid, brandid, sort, areaid, keyword);
            }
            return strNewUrl;
        }
       /// <summary>
       /// 京东分类Url重写
       /// </summary>
       /// <param name="bigid">顶级分类ID</param>
       /// <param name="smallid">二级分类ID</param>
       /// <param name="endid">三级分类ID</param>
       /// <param name="brandid">品牌分类ID</param>
       /// <param name="Team_price">价格排序</param>
       /// <param name="discount">折扣排序</param>
       /// <param name="sort">人气排序</param>
       /// <param name="keyword">搜索关键字</param>
       /// <returns></returns>
        public static string GetTeamListPageUrl(int bigid, int smallid, int endid, int brandid, int Team_price, int discount, int sort, string keyword)
        {
            string strNewUrl = string.Format(PageValue.WebRoot + "list/{0}-{1}-{2}-{3}-{4}-{5}-{6}.html", bigid, smallid, endid, brandid, Team_price, discount, sort);
            if (Helper.GetString(keyword, String.Empty) != String.Empty)
            {
                strNewUrl = string.Format(PageValue.WebRoot + "list/{0}-{1}-{2}-{3}-{4}-{5}-{6}.html?keyword={7}", bigid, smallid, endid, brandid, Team_price, discount, sort, keyword);
            }
            return strNewUrl;
        }

        #region 查询用户的等级 用户表的totalamount 用户累计消费金额.
        public static string GetUserLevel(decimal totalamount)
        {
            string result = string.Empty;
            IList<IUserlevelrules> list = null;
            UserlevelrulesFilters filter = new UserlevelrulesFilters();
            filter.totalamount = totalamount;
            ICategory category = Store.CreateCategory();
            ICategory category1 = Store.CreateCategory();
            using (IDataSession sion = AS.GroupOn.App.Store.OpenSession(false))
            {
                list = sion.Userlevelrelus.GetList(filter);
            }
            if (list != null && list.Count > 0)
            {
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    category = seion.Category.GetByID(list[0].id);
                }
                if (category != null)
                {
                    result = category.Name;
                }

            }

            UserlevelrulesFilters ulf = new UserlevelrulesFilters();
            ulf.AddSortOrder(UserlevelrulesFilters.MAXMONEY_DESC);
            IUserlevelrules Userlevelrules = Store.CreateUserlevelrules();
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                Userlevelrules = seion.Userlevelrelus.Get(ulf);
            }
            if (Userlevelrules != null)
            {
                if (totalamount > Convert.ToDecimal(Userlevelrules.maxmoney))
                {
                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        category1 = seion.Category.GetByID(Userlevelrules.levelid);
                    }

                    if (category1 != null)
                    {
                        result = category1.Name;
                    }
                }
            }

            return result;
        }
        #endregion


        /// <summary>
        /// 需要登录，没有登录则跳转到登录页面
        /// </summary>
        public void NeedLogin()
        {
            if (CookieUtils.GetCookieValue("username") == String.Empty) //没有登录
            {
                SetRefer();
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                Response.End();
                return;
            }
        }
        /// <summary>
        /// 手机端需要登录，没有登录则跳转到登录页面
        /// </summary>
        public void MobileNeedLogin()
        {
            if (CookieUtils.GetCookieValue("username") == String.Empty) //没有登录
            {
                SetRefer();
                Response.Redirect(GetUrl("手机版登录", "account_login.aspx"));
                Response.End();
                return;
            }
        }

        #region 管理员信息保存cash缓冲里面
        /// <summary>
        /// 加密密钥
        /// </summary>
        /// <returns></returns>
        public static string GetKey()
        {

            string CacheKey = "loginkey";

            object objModel = HttpContext.Current.Cache[CacheKey];
            if (objModel == null)
            {
                try
                {
                    objModel = Getfile();
                    if (objModel != null)
                    {
                        HttpContext.Current.Cache.Add(CacheKey, objModel, new System.Web.Caching.CacheDependency(HttpContext.Current.Server.MapPath("~/loginkey.config")), System.Web.Caching.Cache.NoAbsoluteExpiration, System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Normal, null);
                    }
                }
                catch { }
            }
            return objModel.ToString();


        }
        #endregion

        private static string Getfile()
        {
            string loginkey = "";
            if (File.Exists(HttpContext.Current.Server.MapPath(PageValue.WebRoot + "loginkey.config")))//文件存在
            {
                try
                {
                    XmlDocument xmldoc = new XmlDocument();
                    xmldoc.Load(HttpContext.Current.Server.MapPath(PageValue.WebRoot + "loginkey.config"));
                    XmlNode node = xmldoc.SelectSingleNode("//appSettings/add[@key='login']");
                    if (node != null)
                    {
                        loginkey = node.Attributes["value"].Value;
                        if (loginkey.Length != 8)  //如果key 长度不等于8，那么重新生成8位key值，写入到loginkey.config里面
                        {
                            loginkey = Helper.GetRandomString(8);
                            node.Attributes["value"].Value = loginkey;
                            xmldoc.Save(HttpContext.Current.Server.MapPath(PageValue.WebRoot + "loginkey.config"));
                        }
                    }
                }
                catch (Exception ex)
                {

                    FileStream fs = File.Create(HttpContext.Current.Server.MapPath(PageValue.WebRoot + "loginkey.config"));
                    fs.Close();
                    loginkey = Helper.GetRandomString(8);
                    StreamWriter sr = new StreamWriter(HttpContext.Current.Server.MapPath(PageValue.WebRoot + "loginkey.config"), false, System.Text.Encoding.UTF8);
                    try
                    {

                        sr.Write("<?xml version='1.0'?>");
                        sr.Write("<appSettings>");
                        sr.Write("<add key='login' value='" + loginkey + "' />");
                        sr.Write("</appSettings>");
                        sr.Close();

                    }
                    catch
                    {

                    }
                }
            }

            else  //文件不存在
            {
                //写入文本 
                FileStream fs = File.Create(HttpContext.Current.Server.MapPath(PageValue.WebRoot + "loginkey.config"));
                fs.Close();
                loginkey = Helper.GetRandomString(8);
                StreamWriter sr = new StreamWriter(HttpContext.Current.Server.MapPath(PageValue.WebRoot + "loginkey.config"), false, System.Text.Encoding.UTF8);
                try
                {

                    sr.Write("<?xml version='1.0'?>");
                    sr.Write("<appSettings>");
                    sr.Write("<add key='login' value='" + loginkey + "' />");
                    sr.Write("</appSettings>");
                    sr.Close();

                }
                catch
                {
                }
            }
            return loginkey;
        }


        /// <summary>
        /// 登陆成功后执行的方法
        /// </summary>
        /// <param name="userid"></param>
        public virtual void LoginOK(int userid)
        {
            #region 判断Session是否保存了邀请信息，有则写入邀请信息中
            if (CookieUtils.GetCookieValue("invitor") != String.Empty && userid != int.Parse(CookieUtils.GetCookieValue("invitor")))
            {
                IInvite invitemodel = null;
                InviteFilter invitefilter = new InviteFilter();
                invitefilter.Other_user_id = userid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    invitemodel = session.Invite.Get(invitefilter);
                }
                if (invitemodel == null)
                {
                    IInvite mInvite = Store.CreateInvite();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        mInvite.Create_time = DateTime.Now;
                        mInvite.User_id = int.Parse(CookieUtils.GetCookieValue("invitor"));
                        mInvite.Other_user_id = userid;
                        mInvite.Other_user_ip = WebUtils.GetClientIP;
                        mInvite.Pay = "N";
                        session.Invite.Insert(mInvite);
                    }
                }
            }
            CookieUtils.ClearCookie("invitor");
            #endregion
        }

        /// <summary>
        /// 根据后台url重写开关，得到商家详情页面路径
        /// </summary>
        /// <param name="isRewrite">重写开关</param>
        /// <param name="id">项目id</param>
        /// <returns></returns>
        public static string getPartnerPageUrl(string isRewrite, int id)
        {
            string strNewUrl = PageValue.WebRoot + "partner/view.html?id=" + id;
            return strNewUrl;
        }
        /// <summary>
        /// 获取订单跳转路径
        /// </summary>
        /// <param name="orderid"></param>
        /// <returns></returns>
        public static string GetPayPageUrl(string orderid)
        {
            string strNewUrl = String.Empty;
            IOrder order = null;
            using (IDataSession session=Store.OpenSession(false))
            {
                order = session.Orders.GetByID(Helper.GetInt(orderid, 0));
            }
            if (order!=null)
            {
                if (order.Team_id != 0)
                    strNewUrl = UrlMapper.GetUrl("优惠卷确认", "order_check.aspx?orderid=" + orderid);
                else
                    strNewUrl = UrlMapper.GetUrl("购物车订单", "shopcart_confirmation.aspx?orderid=" + orderid);
            }
            return strNewUrl;
        }

        #region 判断认证码和session里面的是否一样
        public bool isverifycode(string verifycode, string code)
        {
            bool falg = false;
            if (verifycode.ToUpper() == code.ToUpper())
            {
                falg = true;
            }
            else
            {
                falg = false;
            }

            return falg;
        }
        #endregion


        #region 登陆方法
        /// <summary>
        /// 登陆方法
        /// </summary>
        protected void Login(string strUserOrEmail, string strPwd)
        {
            //查找数据库是否同步
            if (WebUtils.config["UC_Islogin"] == "1") //启用了ucenter
            {
                strUserOrEmail = Helper.GetString(strUserOrEmail, String.Empty);
                AS.ucenter.RetrunClass retrunclass = null;
                IUser userinfo = Store.CreateUser();
                UserFilter uf = new UserFilter();
                uf.LoginName = strUserOrEmail;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    userinfo = seion.Users.Get(uf);
                }
                if (userinfo != null)//存在这个名字或邮箱的用户
                {
                    if (userinfo.ucsyc.ToString() == "yessyc")//这个用户已经通过到ucenter了
                    {
                        string username = String.Empty;
                        username = userinfo.Username.ToString();
                        retrunclass = Ucenter.setValue.setLogin(username, strPwd, false, false);
                        if (retrunclass != null)
                        {
                            if (retrunclass.Uid > 0)
                            {
                                //同步登录成功
                                //去查找用户名的消费金额
                                //创建保存的数据对象
                                CookieUtils.SetCookie("userid", userinfo.Id.ToString(), Key, null);
                                WebUtils.SetLoginUserCookie(userinfo.Username.ToString(),true);
                                Response.Write(Ucenter.setValue.getsynlogin(retrunclass.Uid));
                                if (userinfo.Manager.ToString().ToUpper() == "Y" || userinfo.Id.ToString() == "1")
                                {
                                    CookieUtils.SetCookie("admin", userinfo.Id.ToString(),Key,null);
                                }
                                LoginOK(Helper.GetInt(userinfo.Id, 0));//执行登录成功的方法
                                SetSuccess("登录成功！");
                                Response.Write("<script>window.location.href='" + Page.ResolveUrl(GetRefer()) + "';</script>");
                                Response.End();
                            }
                            else
                            {
                                //同步登录失败,提示错误信息
                                SetError(Ucenter.setValue.getLogin(retrunclass.Uid));
                                Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                                Response.End();
                                return;
                            }


                        }
                        else
                        {
                            FileUtils.SetConfig("UC_Islogin", "0");
                            SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。");
                            Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                            Response.End();
                            return;
                        }
                    }
                    else //没有同步
                    {
                        //可以登录本网站
                        string email = Ucenter.getValue.getEmail(Ucenter.getValue.getEmail(userinfo.Email.ToString()));
                        string username = Ucenter.getValue.getUsername(Ucenter.getValue.getUsername(userinfo.Username.ToString()));
                        //验证ucenter是否有用户名和邮箱
                        if (email != "" || username != "")
                        {
                            //说明有邮箱和用户名重名,跳转到重置页面
                            CookieUtils.SetCookie("key", DESEncrypt.Encrypt(userinfo.Username.ToString(),FileUtils.GetKey()));
                            CookieUtils.SetCookie("ucenter", "ucenter");
                            CookieUtils.SetCookie("ucError", "本站已启用Ucenter用户中心，请重置您个人信息");
                            CookieUtils.SetCookie("userid", DESEncrypt.Encrypt(userinfo.Id.ToString(), FileUtils.GetKey()));
                            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                            Response.End();
                            return;

                        }
                        else
                        {
                            //没有重名，可以注册
                            int ucenterRegester = Ucenter.setValue.setRegester(userinfo.Username.ToString(), strPwd, userinfo.Email.ToString(), false);
                            if (ucenterRegester > 0)
                            {
                                //创建保存的数据对象
                                WebUtils.SetLoginUserCookie(userinfo.Username.ToString(),true);
                                LoginOK(Helper.GetInt(userinfo.Id, 0));//执行登录成功的方法
                                int result = 0;
                                IUser usermodel = Store.CreateUser();
                                usermodel.ucsyc = "yessyc";
                                usermodel.Id = userinfo.Id;
                                using (IDataSession seion = Store.OpenSession(false))
                                {
                                    result = seion.Users.UpdateUcsyc(usermodel);
                                }

                                if (result > 0)
                                {

                                    retrunclass = Ucenter.getValue.getLogin(userinfo.Username.ToString(), false);
                                    if (retrunclass == null)
                                    {
                                        SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录");
                                        FileUtils.SetConfig("UC_Islogin", "0");
                                        Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                                    }
                                    if (userinfo.Manager.ToString().ToUpper() == "Y" || userinfo.Id.ToString() == "1")
                                    {
                                        CookieUtils.SetCookie("admin", userinfo.Id.ToString(),Key,null);
                                    }
                                    CookieUtils.SetCookie("userid", userinfo.Id.ToString(), Key, null);
                                    WebUtils.SetLoginUserCookie(userinfo.Username.ToString(), true);
                                    Response.Write(Ucenter.setValue.getsynlogin(retrunclass.Uid));
                                    SetSuccess("登录成功！");
                                    Response.Write("<script>window.location.href='" + Page.ResolveUrl(GetRefer()) + "'</script>");
                                    Response.End();
                                    return;
                                }


                            }
                            else if (ucenterRegester == -10)
                            {
                                //配置信息错误
                                SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。");
                                FileUtils.SetConfig("UC_Islogin", "0");
                                Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                                Response.End();
                                return;
                            }
                            else
                            {

                                //注册失败
                                //说明有邮箱和用户名重名,跳转到重置页面
                                WebUtils.SetLoginUserCookie(userinfo.Username.ToString(), true);
                                CookieUtils.SetCookie("userid", userinfo.Id.ToString(), Key, null);
                                CookieUtils.SetCookie("ucenter", "ucenter");
                                CookieUtils.SetCookie("ucError", "本站已启用Ucenter用户中心，请重置您个人信息");
                                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                                Response.End();
                                return;

                            }
                        }
                    }
                    //已经同步,通过ucenter进行登录验证

                }
                else  //网站上不存在此用户 直接去ucenter验证
                {
                    retrunclass = Ucenter.setValue.setLogin(strUserOrEmail, strPwd, false, false);
                    if (retrunclass.Uid > 0)
                    {
                        IUser usermodel = Store.CreateUser();
                        usermodel.Username = retrunclass.UserName;
                        usermodel.ucsyc = "yessyc";
                        usermodel.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(strPwd + PassWordKey, "md5"); ;
                        usermodel.Email = retrunclass.Email;
                        usermodel.fromdomain = "ucenter同步";
                        usermodel.IP_Address = "ucenter同步";
                        usermodel.Enable = "Y";
                        usermodel.Gender = "M";
                        usermodel.IP = WebUtils.GetClientIP;
                        usermodel.Newbie = "N";
                        usermodel.Manager = "N";
                        usermodel.userscore = 0;
                        usermodel.totalamount = 0;
                        usermodel.Score = 0;
                        usermodel.Money = 0;
                        usermodel.Login_time = DateTime.Now;
                        usermodel.Create_time = DateTime.Now;
                        usermodel.Avatar = PageValue.WebRoot + "upfile/css/i/man.jpg";
                        int userid = 0;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            userid = seion.Users.Insert(usermodel);
                        }
                        CookieUtils.SetCookie("userid", userid.ToString(), Key, null);
                        WebUtils.SetLoginUserCookie(usermodel.Username.ToString(), true);
                        LoginOK(userid);//执行登录成功的方法
                        SetSuccess("登陆成功");
                        Response.Write(Ucenter.setValue.getsynlogin(retrunclass.Uid));
                        Response.Write("<script>window.location.href='" + Page.ResolveUrl(GetRefer()) + "'</script>");
                    }
                    else
                    {
                        if (retrunclass.Uid == -1)
                        {
                            SetError("您输入的用户名不存在");
                        }
                        else if (retrunclass.Uid == -2)
                        {
                            SetError("您输入的密码不正确");
                        }
                    }
                }
            }
            else  //没有启用ucenter
            {
                IList<IUser> listuser = null;
                UserFilter uf = new UserFilter();
                uf.LoginName = strUserOrEmail;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    listuser = seion.Users.GetList(uf);
                }
                if (listuser != null && listuser.Count > 0)
                {

                    if (listuser.Count == 1)
                    {
                        string str_User = listuser[0].Username.ToString();
                        string str_Pwd = listuser[0].Password.ToString();
                        string userid = listuser[0].Id.ToString();
                        string Manager = listuser[0].Manager.ToString();
                        string Enable = listuser[0].Enable.ToString();
                        string str_Email = listuser[0].Email.ToString();
                        decimal totalamount = decimal.Parse(listuser[0].totalamount.ToString());
                        if (str_Pwd == System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(strPwd + PassWordKey, "md5"))
                        {
                            if (ASSystem != null)
                            {
                                if (ASSystem.emailverify == 1)
                                {
                                    //没有激活的用户跳转到
                                    if (Enable == "N")
                                    {
                                        Session["useremail"] = str_Email;
                                        Response.Redirect(GetUrl("验证邮件", "account_verify.aspx"));
                                        return;
                                    }
                                }
                            }

                            //创建保存的数据对象
                            if (Request["auto-login"] == "1")
                                CookieUtils.SetCookie("username", str_User, Key, DateTime.Now.AddDays(30));
                            else
                                CookieUtils.SetCookie("username", str_User, Key, null);
                            CookieUtils.SetCookie("userid", userid, Key, null);
                            LoginOK(Helper.GetInt(userid, 0));//执行登录成功的方法
                            //修改登录时间和IP

                            IUser users = Store.CreateUser();
                            users.Id = int.Parse(userid);
                            users.IP = WebUtils.GetClientIP;
                            users.Login_time = DateTime.Now;

                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                seion.Users.UpdateIpTime(users);
                            }

                            if (Manager.ToUpper() == "Y" || userid == "1")
                            {
                                //不需要保存管理员登录状态
                                CookieUtils.SetCookie("admin", userid, Key, null);
                            }
                            string strlevel = Utilys.GetUserLevel(totalamount);
                            float fDiscount = ActionHelper.GetUserLevelMoney(totalamount);
                            string message = "";
                            if (strlevel.Length > 0) //如果存在此等级
                            {
                                if (fDiscount < 1)
                                    message = str_User + "您好：你现在是" + strlevel + "，购买商品全部" + fDiscount * 10 + "折。";
                                else
                                    message = str_User + "您好：你现在是" + strlevel + "，不能享受打折优惠活动。";
                                List<Hashtable> hs = new List<Hashtable>();
                                string sql = "select top 1 name,Category.id,minmoney,discount from userlevelrules inner join Category on(userlevelrules.levelid=Category.id) where " + totalamount + "<minmoney order by minmoney asc";

                                using (IDataSession seion = Store.OpenSession(false))
                                {
                                    hs = seion.GetData.GetDataList(sql);
                                }

                                if (hs != null && hs.Count > 0)
                                {
                                    message = message + "您只需要再消费" + ASSystem.currency + (Convert.ToDecimal(hs[0]["minmoney"]) - totalamount).ToString() + "，即可达到" + hs[0]["name"];
                                    if (Helper.GetFloat(hs[0]["discount"], 1) < 1)
                                    {
                                        message = message + "，购买商品全部" + Helper.GetFloat(hs[0]["discount"], 1) * 10 + "折。";
                                    }
                                }
                                message = message + "点击此处查看\"<a href='" + GetUrl("我的积分", "pointsshop_pointscore.aspx") + "'>我的积分</a>\"";
                                if (WebUtils.config["MallTemplate"] != null && WebUtils.config["MallTemplate"].ToString() != "1")
                                {
                                    SetSuccess(message);
                                }
                            }
                            else
                            {
                                if (WebUtils.config["MallTemplate"] != null && WebUtils.config["MallTemplate"].ToString() != "1")
                                {
                                    SetSuccess("登录成功");
                                }
                            }
                            Response.Redirect(GetRefer());
                            Response.End();
                            return;
                        }
                        else
                        {
                            SetError("你输入的密码错误！");
                            Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                        }
                    }
                    else
                    {
                        SetError("该用户不存在！");
                        Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                    }
                }
                else
                {
                    SetError("该用户不存在！");
                    Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                }
            }
        }

        #endregion

        #region 手机端登陆方法
        /// <summary>
        /// 手机端登陆方法
        /// </summary>
        protected void LoginWap(string strUserOrEmailorMobile, string strPwd,string strcode)
        {
            IList<IUser> listuser = null;
            UserFilter uf = new UserFilter();
            uf.LoginName = strUserOrEmailorMobile;
            using (IDataSession seion = Store.OpenSession(false))
            {
                listuser = seion.Users.GetList(uf);
            }
            if (listuser != null && listuser.Count > 0)
            {
                if (listuser.Count == 1)
                {
                    string str_User = listuser[0].Username.ToString();
                    string str_Pwd = string.Empty;
                    string str_code = string.Empty;
                    if (listuser[0].Password != null && listuser[0].Password != "")
                    {
                       str_Pwd = listuser[0].Password.ToString();
                    }
                    string userid = listuser[0].Id.ToString();
                    string Manager = listuser[0].Manager.ToString();
                    string Enable = listuser[0].Enable.ToString();
                    string str_Email = listuser[0].Email.ToString();
                    decimal totalamount = decimal.Parse(listuser[0].totalamount.ToString());
                    string str_mobile = listuser[0].Mobile.ToString();
                    if (Session["mobilecode"] != null && Session["mobilecode"] != "")
                    {
                        str_code = Session["mobilecode"].ToString();
                    }
                   if (str_Pwd == System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(strPwd + PassWordKey, "md5") || strcode==str_code && strcode!="")
                    {
                        if (ASSystem != null)
                        {
                            if (ASSystem.emailverify == 1)
                            {
                                //没有激活的用户跳转到
                                if (Enable == "N" && strcode=="")
                                {
                                    Session["useremail"] = str_Email;
                                    Response.Redirect(GetUrl("验证邮件", "account_verify.aspx"));
                                    return;
                                }
                            }
                        }

                        //创建保存的数据对象
                        if (Request["auto-login"] == "1")
                            CookieUtils.SetCookie("username", str_User, Key, DateTime.Now.AddDays(30));
                        else
                            CookieUtils.SetCookie("username", str_User, Key, null);
                        CookieUtils.SetCookie("userid", userid, Key, null);
                        LoginOK(Helper.GetInt(userid, 0));//执行登录成功的方法
                        //修改登录时间和IP

                        IUser users = Store.CreateUser();
                        users.Id = int.Parse(userid);
                        users.IP = WebUtils.GetClientIP;
                        users.Login_time = DateTime.Now;

                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            seion.Users.UpdateIpTime(users);
                        }
                        string strlevel = Utilys.GetUserLevel(totalamount);
                        float fDiscount = ActionHelper.GetUserLevelMoney(totalamount);
                        string message = "";
                        if (strlevel.Length > 0) //如果存在此等级
                        {
                            if (fDiscount < 1)
                                message = str_User + "您好：你现在是" + strlevel + "，购买商品全部" + fDiscount * 10 + "折。";
                            else
                                message = str_User + "您好：你现在是" + strlevel + "，不能享受打折优惠活动。";
                            List<Hashtable> hs = new List<Hashtable>();
                            string sql = "select top 1 name,Category.id,minmoney,discount from userlevelrules inner join Category on(userlevelrules.levelid=Category.id) where " + totalamount + "<minmoney order by minmoney asc";

                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                hs = seion.GetData.GetDataList(sql);
                            }

                            if (hs != null && hs.Count > 0)
                            {
                                message = message + "您只需要再消费" + ASSystem.currency + (Convert.ToDecimal(hs[0]["minmoney"]) - totalamount).ToString() + "，即可达到" + hs[0]["name"];
                                if (Helper.GetFloat(hs[0]["discount"], 1) < 1)
                                {
                                    message = message + "，购买商品全部" + Helper.GetFloat(hs[0]["discount"], 1) * 10 + "折。";
                                }
                            }
                            SetSuccess(message);
                        }
                        else
                        {
                            SetSuccess("登录成功");
                        }
                        Response.Write("2");
                    }
                    else
                    {
                        if (str_Pwd != System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(strPwd + PassWordKey, "md5") && strPwd!="")
                       {
                        SetError("你输入的密码错误！");
                        Response.Write("3");
                       }
                       else
                       {
                           SetError("你输入的验证码错误！");
                           Response.Write("4");
                       }
                    }
                }
                else
                {
                    SetError("该用户不存在！");
                    Response.Write("0");
                }
            }
            else
            {
                SetError("该用户不存在！");
                Response.Write("1");
                
            }
            Response.End();
            return;
        }
        #endregion
    }
}
