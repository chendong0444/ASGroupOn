<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script language="C#" runat="server">
    //人人折 cps入口
    protected string from = String.Empty;       //返利网网站标识
    protected int u_id = 0;                     //用户在人人折用户ID
    protected string go_url = "~/index.aspx";   //跳转目标网址
    protected bool sync = false;                //如果本字段是false，则以下字段全部为空，不需接收以下所有字段
    protected string code = String.Empty;       //采用MD5加密(32位)
    protected string uname = String.Empty;      //联合登陆的用户名
    protected string uskey = String.Empty;      //联合登陆的用户安全码
    protected string actime = String.Empty;     //时间戳
    protected string ss = WebUtils.config["rrzsecret"]; //人人折返利商户密钥
    protected NameValueCollection request = new NameValueCollection();
    protected string backurl = "来自人人折返利";
    protected int redir_type = 0;
    protected void Page_Load(Object Src, EventArgs E)
    {
        request = HttpUtility.ParseQueryString(Request.Url.Query);
        sync = Helper.GetBool(request["sync"], false);
        go_url = Helper.GetString(request["go_url"], "");
        if (go_url != String.Empty)
        {
            go_url = Helper.GetString(request["go_url"], go_url);
        }
        actime = request["actime"];
        uname = Helper.GetString(request["uname"], String.Empty);
        uskey = Helper.GetString(request["uskey"], String.Empty);
        u_id = Helper.GetInt(request["u_id"], 0);
        string yizhantongkey = uname + "_来自人人折返利";
        CookieUtils.SetCookie("go_url", backurl);
        CookieUtils.SetCookie("fromdomain", backurl);
        CookieUtils.SetCookie("yizhantong", "yizhantong");
        CookieUtils.SetCookie("uskey", uskey);
        CookieUtils.SetCookie("ss", ss);
        DateTime actiontime = Helper.GetWindowsTime(actime);
        HttpCookie cookies = new HttpCookie("cps");
        NameValueCollection values = new NameValueCollection();
        values.Add("name", "renrenzhe"); //这是名称是标识哪家cps的 是必须的 以下是不同商家cps要求的不同的参数。
        values.Add("u_id", Helper.GetString(Request["u_id"], String.Empty));
        values.Add("uname", uname);
        values.Add("from", from);
        values.Add("uskey", uskey);
        values.Add("sk", WebUtils.config["renrenzhe"]);          //网站识别码
        values.Add("ss", WebUtils.config["rrzsecret"]);          //网站密钥
        cookies.Values.Add(values);
        cookies.Expires = DateTime.Now.AddMonths(1);                        //设置cookie过期时间为1个月
        Response.Cookies.Add(cookies);
        if (sync)
        {
            code = request["code"];
            if (code == Helper.MD5(uname + ss + actime))
            {
                if (redir_type == 0)
                {
                    int userid = 0;
                    string _uskey = String.Empty;
                    IUser user = Store.CreateUser();
                    IUser usermodel = Store.CreateUser();
                    UserFilter uf = new UserFilter();
                    uf.Username = uname;
                    uf.Fromdomain = "来自人人折返利";
                    using (IDataSession session=Store.OpenSession(false))
                    {
                        user = session.Users.Get(uf);
                    }
                    List<Hashtable> hs = null;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        hs = session.Custom.Query("select userid,safekey from yizhantong where name='" + Helper.GetString(yizhantongkey, String.Empty) + "'");
                    }
                    if (user != null) userid = user.Id;
                    if (userid == 0)
                    {
                        if (hs != null)
                        {
                            userid = Helper.GetInt(hs[0]["userid"], 0);
                            _uskey = hs[0]["safekey"].ToString();
                        }
                    }
                    else
                    {
                        if (hs != null) _uskey = hs[0]["safekey"].ToString();
                    }
                    if (userid == 0)//不存在用户
                    {
                        usermodel.Username = uname;
                        usermodel.Email = Helper.GetRandomString(4);
                        usermodel.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Helper.GetRandomString(6) + BasePage.PassWordKey, "md5");
                        usermodel.Gender = "M";
                        usermodel.Create_time = DateTime.Now;
                        usermodel.IP = Page.Request.UserHostAddress;
                        usermodel.Newbie = "N";
                        usermodel.Avatar = PageValue.WebRoot + "upfile/img/user-no-avatar.gif";
                        usermodel.IP_Address = backurl;
                        usermodel.fromdomain = "来自人人折返利";
                        while (true)
                        {
                            using (IDataSession session=Store.OpenSession(false))
                            {
                                userid = session.Users.Insert(usermodel);
                            }
                            if (userid > 0)
                            {
                                CookieUtils.SetCookie("username", usermodel.Username);
                                CookieUtils.SetCookie("userid", usermodel.Id.ToString(), FileUtils.GetKey(), null);
                                IYizhantong yizhantong = Store.CreateYizhantong();
                                yizhantong.name = yizhantongkey;
                                yizhantong.userid = userid;
                                yizhantong.safekey = uskey;
                                using (IDataSession session=Store.OpenSession(false))
                                {
                                    session.Yizhantong.Insert(yizhantong);
                                }
                                break;
                            }
                            else
                            {
                                usermodel.Username = usermodel.Username + Helper.GetRandomString(4);
                                usermodel.Email = usermodel.Email + Helper.GetRandomString(4);
                            }
                        }
                    }
                    else
                    {
                        usermodel = null;
                        using (IDataSession session=Store.OpenSession(false))
                        {
                            usermodel = session.Users.GetByID(Helper.GetInt(userid, 0));
                        }
                        if (usermodel != null)
                        {
                            if (_uskey == uskey)
                            {
                                usermodel.IP_Address = backurl;
                                usermodel.fromdomain = "来自人人折返利";
                                using (IDataSession session=Store.OpenSession(false))
                                {
                                    session.Users.Update(usermodel);
                                }
                                CookieUtils.SetCookie("username", usermodel.Username);
                                CookieUtils.SetCookie("userid", usermodel.Id.ToString(), FileUtils.GetKey(), null);
                            }
                            else
                            {
                                SetError("用户安全码不正确！");
                                string redictUrl = "<script>window.location.href='" + go_url + "';</";
                                HttpContext.Current.Response.Write(redictUrl + "script>");
                                HttpContext.Current.Response.End();
                                return;
                            }
                        }
                    }
                    SetSuccess("登录成功");
                    Response.Redirect(go_url);
                    Response.End();
                    return;
                }
            }
        }
        Response.Redirect(go_url);
        Response.End();
        return;
    }
</script>
