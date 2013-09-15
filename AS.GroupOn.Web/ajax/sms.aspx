<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace=" System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">

    public ISmssubscribe smsmodel = Store.CreateSmssubscribe();
    public NameValueCollection _system = new NameValueCollection();
    public SmssubscribeFilter sf = new SmssubscribeFilter();
    public ISystem sysmodel = Store.CreateSystem();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        string action = Request["action"];
        string mobile = Helper.GetString(Request["mobile"], String.Empty);
        string verifycode = Helper.GetString(Request["verifycode"], String.Empty);
        int cityid = Helper.GetInt(Request["city_id"], 0);
        string secretcode = Helper.GetString(Request["secretcode"], String.Empty);
        string val = String.Empty;
        switch (action)
        {
            case "subscribe":
                val = WebUtils.LoadPageString(PageValue.WebRoot + "ajaxpage/ajax_dialog_smssub.aspx");
                Response.Write(JsonUtils.GetJson(val, "dialog"));
                break;

            case "sign":
                List<string> mobiles = new List<string>();
                mobiles.Add(mobile);
                string randnum = Helper.GetRandomString(6);
                if (mobile == "")
                {

                }
                int count = 0;
                //GetCountByCityId
                UserFilter uf = new UserFilter();
                uf.Signmobile = mobile;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    count = seion.Users.GetCountByCityId(uf);
                }

                if (count > 0)
                {
                    string result = "一个手机号只能绑定一个账号，" + mobile + "已绑定在其他账号";
                    Response.Write(JsonUtils.GetJson("$('#coupon-dialog-display-id').html('" + result + "');$(\"[vname='mobile']\").hide();$(\"[vname='secret']\").hide();$(\"#coupon-dialog-sign\").hide();", "eval"));
                }
                else
                {
                    //短信订阅
                    NameValueCollection values = new NameValueCollection();
                    values.Add("网站简称", ASSystem.abbreviation);
                    values.Add("手机号码", mobile);
                    values.Add("绑定码", randnum);

                    string msg = ReplaceStr("usersign", values);

                    // string msg = ASSystem.abbreviation + ",您的手机号：" + mobile + " 绑定号码：" + randnum + ".";
                    int sendsigncount = 0;
                    if (CookieUtils.GetCookieValue("sendsigncount") != null && CookieUtils.GetCookieValue("sendsigncount").ToString() != "")
                    {
                        sendsigncount = int.Parse(CookieUtils.GetCookieValue("sendsigncount").ToString());
                    }
                    DateTime now = DateTime.Now;
                    string strtime = now.ToShortDateString();
                    if (sendsigncount <= 5 && (DateTime.Parse(now.ToShortDateString() + " 00:00:00") <= now && DateTime.Parse(now.ToShortDateString() + " 23:59:59") >= now))
                    {

                        if (EmailMethod.SendSMS(mobiles, msg))
                        {
                            Session["signsecret"] = randnum;
                            sendsigncount = sendsigncount + 1;
                            CookieUtils.SetCookie("sendsigncount", sendsigncount.ToString(), DateTime.Now.AddDays(1));
                        }
                    }
                    OrderedDictionary list = new OrderedDictionary();
                    string result = "";
                    if (sendsigncount > 5)
                    {
                        result = "您好，已超过最高发送次数5次，请明天再来。";
                        list.Add("html", result);
                        list.Add("id", "coupon-dialog-display-id");
                        Response.Write(JsonUtils.GetJson("$('#coupon-dialog-display-id').html('" + result + "'); $('#sendsms').hide();", "eval"));
                    }
                    else
                    {
                        result = "验证码已发送到" + mobile + "，请注意查收。[" + Helper.GetInt(CookieUtils.GetCookieValue("sendsigncount"), 0) + "]";
                        list.Add("html", result);
                        list.Add("id", "coupon-dialog-display-id");
                        Response.Write(JsonUtils.GetJson("$('#coupon-dialog-display-id').html('" + result + "');", "eval"));
                    }
                }

                break;
            case "bindmobile":

                string _result = "";

                if (Session["m_subscribe"] == null || Session["m_subscribe"].ToString() == "" || Session["m_subscribe"].ToString() != Request["secret"].ToString())
                {
                    _result = "验证码错误！";
                    Response.Write(JsonUtils.GetJson(_result, "alert"));
                }
                else
                {

                    if (Request["mobile"] != null && Request["mobile"].ToString() != "" && Request["secret"] != null && Request["secret"].ToString() != "")
                    {
                        string strmobile = Request["mobile"];
                        string strsecret = Request["secret"];


                        if (Session["m_subscribe"] != null && Session["m_subscribe"].ToString() != "" && Session["m_subscribe"].ToString() == strsecret)
                        {

                            sf.Mobile = strmobile;
                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                smsmodel = seion.Smssubscribe.Get(sf);
                            }

                            if (smsmodel == null)
                            {
                                ISmssubscribe _smsmodel = Store.CreateSmssubscribe();
                                _smsmodel.Mobile = strmobile;
                                _smsmodel.Secret = strsecret;
                                _smsmodel.Enable = "Y";
                                if (CurrentCity != null)
                                {
                                    _smsmodel.City_id = CurrentCity.Id;
                                }
                                else
                                {
                                    _smsmodel.City_id = 0;
                                }

                                using (IDataSession seion = Store.OpenSession(false))
                                {
                                    seion.Smssubscribe.Insert(_smsmodel);
                                }

                                _result = "该手机号码订阅成功！";
                                Response.Write(JsonUtils.GetJson("alert('" + _result + "');$(\"#confirm\").show();$(\"#notice\").show();  $(\"#will_send_hour\").show();$(\"#divmobile\").hide();$(\"#divconfirmcode\").hide(); $(\"#bind\").hide();$(\"#step2\").show();$(\"#step1\").hide();", "eval"));
                            }
                            else
                            {
                                _result = "该手机号码已绑定，请订阅项目！";
                                Response.Write(JsonUtils.GetJson("alert('" + _result + "');$(\"#confirm\").show();$(\"#notice\").show(); $(\"#divmobile\").hide();$(\"#divconfirmcode\").hide(); $(\"#bind\").hide();$(\"#step2\").show();$(\"#step1\").hide();", "eval"));

                            }
                        }
                    }

                }

                break;
            case "m_unsubscribe":
                val = WebUtils.LoadPageString(WebRoot + "ajaxpage/ajax_dialog_smsunsub.aspx");
                Response.Write(JsonUtils.GetJson(val, "dialog"));
                break;
            case "m_subscribe":

                sf.Mobile = mobile;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    smsmodel = seion.Smssubscribe.Get(sf);
                }
                if (Helper.ValidateString(mobile, "mobile"))
                {
                    if (smsmodel != null)
                    {
                        Response.Write("2");
                        Response.End();

                    }
                    else
                    {
                        List<string> mobile_sub = new List<string>();
                        mobile_sub.Add(mobile);
                        string randnummobile = Helper.GetRandomString(6);

                        //短信订阅
                        NameValueCollection values = new NameValueCollection();
                        values.Add("网站简称", ASSystem.abbreviation);
                        values.Add("手机号码", mobile);
                        values.Add("认证码", randnummobile);


                        string message = ReplaceStr("subscribe", values);


                        //string msgmobile = "尊敬的用户您好,您在" + ASSystem.abbreviation + "手机验证码：" + randnummobile + ".";
                        if (Helper.GetInt(Session["m_subnum"], 0) == 0 || Helper.GetInt(Session["m_subnum"], 0) <= 3)
                        {
                            if (EmailMethod.SendSMS(mobile_sub, message))
                            {
                                Session["m_subscribe"] = randnummobile;
                                Session["m_subnum"] = Helper.GetInt(Session["m_subnum"], 0) + 1;
                                Response.Write("1");
                                Response.End();
                            }
                            else
                            {
                                Response.Write("0");
                                Response.End();
                            }
                        }
                    }
                }
                else
                {
                    Response.Write("3");
                    Response.End();
                }
                break;

            case "orderteam":


                string strteamid = Request["id"];

                sf.Mobile = mobile;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    smsmodel = seion.Smssubscribe.Get(sf);
                }

                if (smsmodel != null)
                {
                    SmssubscribedetailFilter sbf = new SmssubscribedetailFilter();
                    IList<ISmssubscribedetail> listsmsdetail = null;
                    sbf.Mobile = mobile;
                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        listsmsdetail = seion.Smssubscribedetail.GetList(sbf);
                    }

                    if (listsmsdetail != null)
                    {
                        int sendnum = 5;
                        if (_system != null && _system["orderteamnum"] != null)
                        {
                            sendnum = int.Parse(_system["orderteamnum"].ToString());
                        }
                        if (listsmsdetail.Count < sendnum)
                        {
                            SmssubscribedetailFilter sbbf = new SmssubscribedetailFilter();
                            ISmssubscribedetail smsDetailmodel = Store.CreateSmssubscribedetail();
                            sbbf.Mobile = mobile;
                            sbbf.Teamid = int.Parse(strteamid);

                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                smsDetailmodel = seion.Smssubscribedetail.Get(sbbf);
                            }
                            if (smsDetailmodel != null)
                            {
                                Response.Write(JsonUtils.GetJson("alert('该项目已经订阅，请订阅其他项目！');$(\"#confirm\").hide();$(\"#notice\").hide();  $(\"#will_send_hour\").hide();$(\"#divmobile\").show();$(\"#divconfirmcode\").show(); $(\"#bind\").show();document.displaySec.get_confirm_code.value = \"获取验证码\";$(\"#mobile\").attr(\"readonly\", \"\");$(\"#get_confirm_code\").attr(\"disabled\", \"\");$(\"#step2\").hide();$(\"#step1\").show();", "eval"));

                            }
                            else
                            {
                                ISmssubscribedetail smsDetail_model = Store.CreateSmssubscribedetail();
                                smsDetail_model.mobile = mobile;
                                smsDetail_model.teamid = int.Parse(strteamid);
                                smsDetail_model.sendtime = int.Parse(Request["sendtime"]);
                                int cnt = 0;
                                using (IDataSession seion = Store.OpenSession(false))
                                {
                                    cnt = seion.Smssubscribedetail.Insert(smsDetail_model);
                                }

                                if (cnt > 0)
                                {

                                    Response.Write(JsonUtils.GetJson("alert('该项目已经订阅成功！');$(\"#confirm\").hide();$(\"#notice\").hide();  $(\"#will_send_hour\").hide();$(\"#divmobile\").show();$(\"#divconfirmcode\").show(); $(\"#bind\").show();document.displaySec.get_confirm_code.value = \"获取验证码\";$(\"#mobile\").attr(\"readonly\", \"\");$(\"#get_confirm_code\").attr(\"disabled\", \"\");$(\"#step2\").hide();$(\"#step1\").show();", "eval"));


                                }
                                else
                                {

                                    Response.Write(JsonUtils.GetJson("alert('该项目已经订阅失败！');$(\"#confirm\").hide();$(\"#notice\").hide();  $(\"#will_send_hour\").hide();$(\"#divmobile\").show();$(\"#divconfirmcode\").show(); $(\"#bind\").show();document.displaySec.get_confirm_code.value = \"获取验证码\";$(\"#mobile\").attr(\"readonly\", \"\");$(\"#get_confirm_code\").attr(\"disabled\", \"\");$(\"#step2\").hide();$(\"#step1\").show();", "eval"));
                                }

                            }
                        }
                        else
                        {
                            Response.Write(JsonUtils.GetJson("alert('您好，您已经超出最高订阅项目个数" + sendnum + "个！');$(\"#confirm\").hide();$(\"#notice\").hide();  $(\"#will_send_hour\").hide();$(\"#divmobile\").show();$(\"#divconfirmcode\").show(); $(\"#bind\").show();document.displaySec.get_confirm_code.value = \"获取验证码\";$(\"#mobile\").attr(\"readonly\", \"\");$(\"#get_confirm_code\").attr(\"disabled\", \"\");$(\"#step2\").hide();$(\"#step1\").show();", "eval"));
                        }
                    }




                }
                else
                {
                    Response.Write(JsonUtils.GetJson("alert('该手机号码还未绑定，请先绑定手机号！');$(\"#confirm\").hide();$(\"#notice\").hide();  $(\"#will_send_hour\").hide();$(\"#divmobile\").show();$(\"#divconfirmcode\").show(); $(\"#bind\").show();", "eval"));

                }
                break;

            case "mobilecode":
                if (Helper.ValidateString(mobile, "mobile"))
                {
                    IList<IUser> userlist = null;
                    UserFilter ufilter = new UserFilter();
                    ufilter.Mobile = mobile;
                    using (IDataSession session=Store.OpenSession(false))
                    {
                        userlist = session.Users.GetList(ufilter);
                    }
                    if (userlist == null || userlist.Count == 0)
                    {
                        Response.Write("4");
                        Response.End();
                    }
                    List<string> mobile_sub = new List<string>();
                    mobile_sub.Add(mobile);
                    string randnummobile = Helper.GetRandomString(6);
                    NameValueCollection values = new NameValueCollection();
                    values.Add("手机号码", mobile);
                    values.Add("网站简称", ASSystem.abbreviation);
                    values.Add("认证码", randnummobile);
                    string message = string.Empty;
                    if (Request["method"] == "login")
                    {
                         message = ReplaceStr("logincode", values);
                    }
                    else
                    {
                        message = ReplaceStr("mobilecode", values);
                    }
                    int mobilecodecount = 0;
                    if (CookieUtils.GetCookieValue("mobilecodecount") != null && CookieUtils.GetCookieValue("mobilecodecount").ToString() != "")
                    {
                        mobilecodecount = int.Parse(CookieUtils.GetCookieValue("mobilecodecount").ToString());
                    }
                    DateTime now = DateTime.Now;
                    string strtime = now.ToShortDateString();
                    if (mobilecodecount <= 5 && (DateTime.Parse(now.ToShortDateString() + " 00:00:00") <= now && DateTime.Parse(now.ToShortDateString() + " 23:59:59") >= now))
                    {

                        if (EmailMethod.SendSMS(mobile_sub, message))
                        {

                            Session["mobilecode"] = randnummobile;
                            mobilecodecount = mobilecodecount + 1;
                            CookieUtils.SetCookie("mobilecodecount", mobilecodecount.ToString(), DateTime.Now.AddDays(1));
                            Response.Write("1");
                            Response.End();
                        }
                    }
                    if (mobilecodecount > 5)
                    {
                        Response.Write("2");
                        Response.End();
                    }
                    else
                    {
                        Response.Write("0");
                        Response.End();
                    }
                }
                else
                {
                    Response.Write("3");
                    Response.End();
                }

                break;
            case "unsubscribe":
                val = WebUtils.LoadPageString(PageValue.WebRoot + "ajaxpage/ajax_dialog_smsun.aspx?mobile=" + mobile);
                Response.Write(JsonUtils.GetJson(val, "dialog"));
                break;
            case "unsubscribecheck":
                if (Session["checkcode"] != null && verifycode != String.Empty && Session["checkcode"].ToString().ToUpper() == verifycode.ToUpper())
                {
                    sf.Mobile = mobile;
                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        smsmodel = seion.Smssubscribe.Get(sf);
                    }

                    if (smsmodel != null)
                    {

                        if (smsmodel.Enable == "N")
                        {
                            //"删除短信订阅表中手机号为mobile的记录"
                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                seion.Smssubscribe.deleteBymobile(sf);
                            }
                            val = WebUtils.LoadPageString(PageValue.WebRoot + "ajaxpage/ajax_dialog_smsunsuc.aspx?mobile=" + mobile);
                        }
                        else
                        {
                            //获得当前手机号的验证码
                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                smsmodel = seion.Smssubscribe.Get(sf);
                            }

                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                sysmodel = seion.System.GetByID(1);
                            }

                            val = WebUtils.LoadPageString(PageValue.WebRoot + "ajaxpage/ajax_dialog_smscode.aspx?mobile=" + mobile);
                            //发送短信验证码
                            List<string> m = new List<string>();
                            m.Add(mobile);


                            //取消订阅
                            NameValueCollection values = new NameValueCollection();
                            values.Add("网站简称", ASSystem.abbreviation);
                            values.Add("手机号码", mobile);
                            values.Add("认证码", smsmodel.Secret);


                            string message = ReplaceStr("qxsubscribe", values);

                            EmailMethod.SendSMS(m, message);


                        }
                        Response.Write(JsonUtils.GetJson(val, "dialog"));
                    }
                    else
                    {
                        val = WebUtils.LoadPageString(WebRoot + "ajaxpage/ajax_dialog_smsunsuc.aspx?mobile=" + mobile);
                        Response.Write(JsonUtils.GetJson(val, "dialog"));
                    }
                }
                else
                {
                    Response.Write(JsonUtils.GetJson("captcha_again();", "eval"));
                }
                break;
            case "subscribecheck":

                if (mobile != String.Empty)
                {
                    if (Session["checkcode"] != null && isverifycode(verifycode, Session["checkcode"].ToString()))//判断表单提交验证码是否输入正确
                    {

                        sf.Mobile = mobile;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            smsmodel = seion.Smssubscribe.Get(sf);
                        }

                        if (smsmodel == null)
                        {
                            smsmodel = Store.CreateSmssubscribe();
                            smsmodel.Mobile = mobile;
                            smsmodel.City_id = cityid;
                            smsmodel.Secret = Helper.GetRandomString(6);
                            smsmodel.Enable = "N";
                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                seion.Smssubscribe.Insert(smsmodel);
                            }

                        }
                        else
                        {

                            smsmodel.Secret = Helper.GetRandomString(6);
                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                seion.Smssubscribe.UpdateSecret(smsmodel);
                            }
                        }
                        val = WebUtils.LoadPageString(WebRoot + "ajaxpage/ajax_dialog_smscode.aspx?mobile=" + mobile);
                        List<string> m = new List<string>();
                        m.Add(mobile);

                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            sysmodel = seion.System.GetByID(1);
                        }

                        //短信订阅
                        NameValueCollection values = new NameValueCollection();
                        values.Add("网站简称", ASSystem.abbreviation);
                        values.Add("手机号码", mobile);
                        values.Add("认证码", smsmodel.Secret);


                        string message = ReplaceStr("subscribe", values);

                        if (Helper.GetInt(Session["smscheckcodenum"], 0) == 0 || Helper.GetInt(Session["smscheckcodenum"], 0) <= 3)
                        {
                            EmailMethod.SendSMS(m, message);
                            Session["smscheckcodenum"] = Helper.GetInt(Session["smscheckcodenum"], 0) + 1;

                            Response.Write(JsonUtils.GetJson(val, "dialog"));
                        }
                        else
                        {
                            Response.Write(JsonUtils.GetJson("alertmsg();", "eval"));
                        }

                    }
                    else
                    {
                        Response.Write(JsonUtils.GetJson("captcha_again();", "eval"));

                    }
                }

                break;

            case "codeyes":

                sf.Mobile = mobile;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    smsmodel = seion.Smssubscribe.Get(sf);
                }
                if (smsmodel != null)
                {
                    //根据手机号返回短信订阅表中的一条记录
                    if (Returnmobile(mobile) == false)//记录为空
                    {
                        Response.Write(JsonUtils.GetJson("非法访问！", "alert"));
                        Response.Write(JsonUtils.GetJson("X.boxClose();", "eval"));
                        return;
                    }
                    if (isSecret(secretcode, mobile) == false)
                    {//记录中的验证码不等于secretcode
                        Response.Write(JsonUtils.GetJson("短信认证码不正确，请重新输入！", "alert"));
                        return;
                    }
                    if (isState(mobile))//记录中的激活状态是Y//删除手机号为mobile的记录
                    {
                        sf.Mobile = mobile;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            seion.Smssubscribe.deleteBymobile(sf);
                        }
                        val = WebUtils.LoadPageString(WebRoot + "ajaxpage/ajax_dialog_smsunsuc.aspx");
                        Response.Write(JsonUtils.GetJson(val, "dialog"));
                        return;
                    }
                    else
                    {

                        //更改手机号为mobile的激活状态为Y。
                        ISmssubscribe sms = Store.CreateSmssubscribe();
                        sms.Enable = "Y";
                        sms.Mobile = mobile;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            seion.Smssubscribe.UpdateEnable(sms);
                        }
                        val = WebUtils.LoadPageString(WebRoot + "ajaxpage/ajax_dialog_smssuc.aspx");
                        Response.Write(JsonUtils.GetJson(val, "dialog"));
                        return;

                    }
                }

                break;


        }

    }



    #region 根据手机号返回记录
    public bool Returnmobile(string mobile)
    {
        sf.Mobile = mobile;
        using (IDataSession seion = Store.OpenSession(false))
        {
            smsmodel = seion.Smssubscribe.Get(sf);
        }

        if (smsmodel.Mobile != "")
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    #endregion

    #region 判断认证码和手机号里面认证码是否一致
    public bool isSecret(string secret, string mobile)
    {
        sf.Mobile = mobile;
        using (IDataSession seion = Store.OpenSession(false))
        {
            smsmodel = seion.Smssubscribe.Get(sf);
        }

        if (smsmodel.Secret == secret)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    #endregion


    #region 手机号的里面的状态是否是"Y"
    public bool isState(string mobile)
    {
        sf.Mobile = mobile;
        using (IDataSession seion = Store.OpenSession(false))
        {
            smsmodel = seion.Smssubscribe.Get(sf);
        }
        if (smsmodel.Enable == "Y")
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    #endregion
    
</script>
