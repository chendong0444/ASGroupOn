using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.Common.Utils;
using AS.GroupOn.Domain.Spi;
using System.Web;
using System.Collections.Specialized;
using System.Text.RegularExpressions;
using System.Collections;
using System.IO;
namespace AS.GroupOn.Controls
{
    public class BaseUserControl : System.Web.UI.UserControl, IUserControl
    {
        public string errtext = String.Empty;
        public string suctext = String.Empty;
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            ShowMessage();

        }

        public virtual void UpdateView()
        {
           
        }

        //显示错误信息
        public void ShowMessage()
        {
            if (Session["err"] != null)
            {
                int type = AS.Common.Utils.Helper.GetInt(Session["type"], 1);
                if (type == 1) errtext = Session["err"].ToString();
                if (type == 2) suctext = Session["err"].ToString();
                Session.Remove("err");
                Session.Remove("type");
            }
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
        public virtual object Params { get; set; }

        public virtual bool CanCache
        {
            get { return false; }
        }

        public virtual string CacheKey
        {
            get { return String.Empty; }
        }


        /// <summary>
        /// 分享到开心网
        /// </summary>
        /// <param name="team"></param>
        /// <param name="title"></param>
        /// <param name="content"></param>
        /// <returns></returns>
        public static string Share_kaixin(ITeam team, string WWWprefix, string userid, NameValueCollection ASSystemArr)
        {

            string url = String.Empty;
            url = "http://www.kaixin001.com/repaste/share.php?rurl=";
            if (team != null)
            {
                url = url + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + getTeamPageUrl(team.Id, userid));
                url = url + "&rtitle=" + HttpUtility.UrlEncode(team.Title);
                url = url + "&rcontent=" + HttpUtility.UrlEncode(team.Summary);
            }
            else
            {
                url = url + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + PageValue.WebRoot + "r.aspx?r=" + userid);
                url = url + "&rtitle=" + HttpUtility.UrlEncode(ASSystemArr["sitename"] + "(" + WWWprefix + ")");
                url = url + "&rcontent=" + HttpUtility.UrlEncode(ASSystemArr["sitename"] + "(" + WWWprefix + ")");
            }

            return url;
        }


        /// <summary>
        /// 分享到豆瓣网
        /// </summary>
        /// <param name="team"></param>
        /// <returns></returns>
        public static string Share_douban(ITeam team, string WWWprefix, string userid, NameValueCollection ASSystemArr)
        {
            string url = String.Empty;
            url = "http://www.douban.com/recommend/?";
            if (team != null)
            {
                url = url + "url=" + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + getTeamPageUrl(team.Id, userid));
                url = url + "&title=" + HttpUtility.UrlEncode(WWWprefix + team.Title);
            }
            else
            {
                url = url + "url=" + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + PageValue.WebRoot + "r.aspx?r=" + userid);
                url = url + "&title=" + HttpUtility.UrlEncode(ASSystemArr["sitename"] + "(" + WWWprefix + ")");
            }
            return url;
        }

        public static string Share_renren(ITeam team, string WWWprefix, string userid, NameValueCollection ASSystemArr)
        {
            string url = String.Empty;
            if (team != null)
            {
                url = "link=" + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + getTeamPageUrl(team.Id, userid));
                url = url + "&title=" + HttpUtility.UrlEncode(team.Title);
            }
            else
            {
                url = "link=" + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + PageValue.WebRoot + "r.aspx?id=" + userid);
                url = url + "&title=" + HttpUtility.UrlEncode(ASSystemArr["sitename"] + "(" + WWWprefix + ")");


            }

            return "http://share.renren.com/share/buttonshare.do?" + url;
        }


        /// <summary>
        /// 分享到新浪
        /// </summary>
        /// <param name="team"></param>
        /// <returns></returns>
        public static string Share_sina(ITeam team, string WWWprefix, string userid, NameValueCollection ASSystemArr)
        {

            string url = String.Empty;
            url = "http://v.t.sina.com.cn/share/share.php?";
            if (team != null)
            {
                url = url + "url=" + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + getTeamPageUrl(team.Id,userid));
                url = url + "&title=" + HttpUtility.UrlEncode(WWWprefix + team.Title);
            }
            else
            {
                url = url + "url=" + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + PageValue.WebRoot + "r.aspx?r=" + userid);
                url = url + "&title=" + HttpUtility.UrlEncode(ASSystemArr["sitename"] + "(" + WWWprefix + ")");
            }
            return url;
        }



        /// <summary>
        /// 分享到腾讯微博
        /// </summary>
        /// <param name="team"></param>
        /// <param name="WWWprefix"></param>
        /// <param name="userid"></param>
        /// <param name="ASSystemArr"></param>
        /// <returns></returns>
        public static string Share_QQ(ITeam team, string WWWprefix, string userid, NameValueCollection ASSystemArr)
        {

            string url = String.Empty;
            url = "http://v.t.qq.com/share/share.php?appkey=appkey&";
            if (team != null)
            {
                url = url + "url=" + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + getTeamPageUrl(team.Id, userid));
                url = url + "&title=" + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + PageValue.WebRoot + team.Title);
                url = url + "&pic=" + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + PageValue.WebRoot + team.Image.Substring(1));
            }
            else
            {
                url = url + "url=" + HttpUtility.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + PageValue.WebRoot + "r.aspx?r=" + userid);
                url = url + "&title=" + HttpUtility.UrlEncode(ASSystemArr["sitename"] + "(" + WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + PageValue.WebRoot + ")");
            }
            return url;
        }

        public static string Share_mail(ITeam team, string WWWprefix, string userid, NameValueCollection ASSystemArr)
        {
            string title = String.Empty;
            string body = String.Empty;
            if (team == null)
            {
                title = ASSystemArr["sitename"] + "(" + WWWprefix + ")";
                string[] bodys = new string[]{
                "发现一好网站--"+ASSystemArr["sitename"]+"，他们每天组织一次团购，超值!",
            };
                body = String.Join("\r\n", bodys);
            }
            else
            {
                title = "有兴趣吗：" + team.Title;
                string[] bodys = new string[]{
                "发现一好网站--"+ASSystemArr["sitename"]+"，他们每天组织一次团购，超值!",
		 "今天的团购是："+team.Title,
		"我想你会感兴趣的：",
		 WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + getTeamPageUrl(team.Id,userid)
            };
                body = String.Join("\r\n", bodys);

            }
            WebUtils w = new WebUtils();
            title = w.UTF8ToGB2312(title);
            body = w.UTF8ToGB2312(body);
            return "mailto:?subject=" + title + "&body=" + body;
        }
        public virtual HtmlTextWriter HTW { get; set; }
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

        private NameValueCollection _asuserarr = null;
        public NameValueCollection ASUserArr
        {
            get
            {
                if (_asuserarr == null)
                {
                    _asuserarr = Helper.GetObjectProtery(AsUser);
                    if (_asuserarr == null) _asuserarr = new NameValueCollection();
                }
                return _asuserarr;
            }
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
        /// 返回当前城市
        /// </summary>
        public ICity CurrentCity
        {
            get
            {
                return PageValue.CurrentCity;
            }
        }

        /// <summary>
        /// 根据后台url重写开关，商城品牌地址
        /// </summary>
        /// <param name="isRewrite"></param>
        /// <returns></returns>
        public static string getBrandPageUrl(string isRewrite)
        {

            string strNewUrl = PageValue.WebRoot + "mall/brand/list.html";
            
            return strNewUrl;
        }

        /// <summary>
        /// 根据后台url重写开关，得到项目详情页面路径
        /// </summary>
        /// <param name="isRewrite">重写开关</param>
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
        /// 分享详情地址
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public static string getTeamPageUrl(int id,string userid)
        {
            ITeam mteam = null;
            NameValueCollection _system = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mteam = session.Teams.GetByID(id);
            }
            string strNewUrl = "";
            int userids = Helper.GetInt(userid,0);
            if (mteam != null)
            {
                if (mteam.teamcata == 0)
                {
                    if (userids == 0)
                        strNewUrl = PageValue.WebRoot + "team/" + id + ".html";
                    else
                        strNewUrl = PageValue.WebRoot + "team/" + userid + "/" + id + ".html";
                }
                else if (mteam.teamcata == 1)
                {
                    _system = WebUtils.GetSystem();
                    if (_system != null && _system["MallTemplate"] != null && _system["MallTemplate"].ToString() == "1")
                    {
                        if (userids == 0)
                            strNewUrl = PageValue.WebRoot + "mall/product/" + id + ".html";
                        else
                            strNewUrl = PageValue.WebRoot + "mall/product/" + userid + "/" + id + ".html";
                    }
                    else
                    {
                        if (userids == 0)
                            strNewUrl = PageValue.WebRoot + "mall/goods/" + id + ".html";
                        else
                            strNewUrl = PageValue.WebRoot + "mall/goods/" + userid + "/" + id + ".html";
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
        /// 根据后台url重写开关，得到分类详情页面路径
        /// </summary>
        /// <param name="isRewrite">重写开关</param>
        /// <param name="catalogid"></param>
        /// <param name="brandid"></param>
        /// <param name="sort"></param>
        /// <param name="keyword"></param>
        /// <returns></returns>
        public static string getTeamDetailPageUrl(int catalogid, int brandid, int sort, int areaid)
        {
            string strNewUrl = string.Format(PageValue.WebRoot + "team/list/{0}/{1}/{2}/{3}.html", catalogid, brandid, sort, areaid);
            return strNewUrl;
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

        #region 得到当前项目状态

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
                if ((t.Now_number >= t.Max_number && t.Max_number != 0 && t.Now_number != 0) || (Helper.GetInt(t.open_invent, 0) == 1 && Helper.GetInt(t.inventory, 0) == 0) || t.State == "8")
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

                if ((t.Now_number >= t.Max_number && t.Max_number != 0 && t.Now_number != 0) || (Helper.GetInt(t.open_invent, 0) == 1 && Helper.GetInt(t.inventory, 0) == 0) || t.State == "8")
                {

                    return AS.Enum.TeamState.successnobuy; //已成功未过期不可以购买已卖光
                }
                else
                    if (t.Now_number < t.Min_number)
                    {
                        if (t.Now_number >= t.Min_number)//当前人数 大于最小成团人数
                        {
                            return AS.Enum.TeamState.successbuy;//已成功未过期可以购买   //成功项目:if(项目结束时间>=当前时间>= 项目开始时间 && 项目最大购买人数>0&& 最小成团人数<=项目当前人数)
                        }

                        else
                            return AS.Enum.TeamState.begin;//正在进行   //正在进行项目:if(项目结束时间>=当前时间>= 项目开始时间 && 项目最大购买人数>0&& 最小成团人数>项目当前人数)
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
            return AS.Enum.TeamState.none;  //未开始项目
        }

        #endregion

        #region 用户所在城市的团购
        public static bool GetAddress(string city, IList<ICity> list, out string cityid)
        {
            cityid = String.Empty;
            bool falg = false;
            try
            {
                if (city != "")
                {
                    for (int i = 0; i < list.Count; i++)
                    {
                        ICity c = list[i];
                        if (city.Contains(c.Name.ToString()) || c.Name.ToString().Contains(city))
                        {
                            CookieUtils.SetCookie("cityid", c.Id.ToString(), DateTime.Now.AddYears(1));
                            cityid = c.Id.ToString();
                            falg = true;
                            break;
                        }
                    }
                }
            }
            catch (Exception ex)
            { }
            return falg;
        }
        #endregion

        private NameValueCollection _assystemarr = null;
        public NameValueCollection ASSystemArr
        {
            get
            {
                if (_assystemarr == null)
                {
                    _assystemarr = Helper.GetObjectProtery(ASSystem);
                    if (_assystemarr == null) _assystemarr = new NameValueCollection();
                }
                return _assystemarr;
            }
        }
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
        /// 返回前台皮肤图片路径
        /// </summary>
        /// <returns></returns>
        public string ImagePath()
        {
            return PageValue.CssPath + "/css/i/";
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
            set
            {
                Page.Items["CurrentTeam"] = value;
            }
        }
        /// <summary>
        /// 返回系统设置
        /// </summary>
        private static ISystem _assystem = null;
        public static ISystem ASSystem
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
        /// 根据后台url重写开关，得到分类详情页面路径
        /// </summary>
        /// <param name="isRewrite">重写开关</param>
        /// <param name="catalogid"></param>
        /// <param name="brandid"></param>
        /// <param name="sort"></param>
        /// <param name="keyword"></param>
        /// <returns></returns>
        public static string getGoodsCatalistPageUrl(string isRewrite, int catalogid, int brandid, int sort, string discount, string price)
        {
            string strNewUrl;
             NameValueCollection _system = null;
             _system = WebUtils.GetSystem();
            if (_system != null && _system["MallTemplate"] != null && _system["MallTemplate"].ToString() == "1")
            {
                strNewUrl = PageValue.WebRoot + "mall/catalistjd/" + catalogid + "/" + brandid + "/" + sort + "/" + discount + "/" + price + ".html";
            }
            else
            {
                strNewUrl = PageValue.WebRoot + "mall/catalist/" + catalogid + "/" + brandid + "/" + sort + "/" + discount + "/" + price + ".html";
            }
            
            return strNewUrl;
        }

        /// <summary>
        ///根据后台url重写开关， 得到商城项目地址
        /// </summary>
        /// <param name="isRewrite"></param>
        /// <param name="id"></param>
        /// <returns></returns>
        public static string getGoodsPageUrl(string isRewrite, int id)
        {
            string strNewUrl = PageValue.WebRoot + "mall/goods/" + id + ".html";
            
            return strNewUrl;
        }

        /// <summary>
        /// 根据后台url重写开关，商城首页地址
        /// </summary>
        /// <param name="isRewrite"></param>
        /// <returns></returns>
        public static string getMallPageUrl(string isRewrite)
        {

            string strNewUrl = UrlMapper.GetUrl("商城首页", "mall_index.aspx");
            
            return strNewUrl;
        }

        public void LoadUserControl(string userControlVirtualPath, object obj)
        {
            Control c = Page.LoadControl(userControlVirtualPath);
            IUserControl uc = c as IUserControl;
            if (uc != null)
            {
                uc.Params = obj;
                uc.UpdateView();
                c.RenderControl(HTW);
            }
        }





    }
}
