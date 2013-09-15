<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
    protected int orderid = 0;
    protected int detailid = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        string action = Helper.GetString(Request["action"], String.Empty);
        string cid = Helper.GetString(Request["id"], String.Empty);
        int teamid = Helper.GetInt(Request["teamid"], 0);
        int count = Helper.GetInt(Request["count"], 0);
        string sec = Helper.GetString(Request["secret"], String.Empty);
        string shownum = Helper.GetString(Request["shownum"], String.Empty);
        string shangjiasec = Helper.GetString(Request["shangjiasecret"], String.Empty);
        int inventid = Helper.GetInt(Request["inventid"], 0);
        orderid = Helper.GetInt(Request["orderid"], 0);
        detailid = Helper.GetInt(Request["detailid"], 0);
        string p = Helper.GetString(Request["p"], String.Empty);
        string pattern = Helper.GetString(Request["pattern"], String.Empty);
        string html = String.Empty;
        string result = String.Empty;
        string res = "0";
        ITeam teammodel = null;
        TeamFilter teamfilter = new TeamFilter();
        ProductFilter proft = new ProductFilter();
        
        if (action == "sms")
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Coupon_SendSms))
            {
                Response.Write(JsonUtils.GetJson("你不具有站内券发送短信的权限", "alert"));
                return;
            }
            string txt = "";
            string csecret = Helper.GetString(Request["csecret"], String.Empty);
            System.Collections.Generic.IList<ICoupon> couponlist = null;
            ICoupon couponmodel = null;
            CouponFilter filter = new CouponFilter();
            filter.Id = cid;
            filter.Secret = csecret;
            ITeam team = null;
            IOrder ordermodel = null;
            IPartner partnermodel = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                couponlist = session.Coupon.GetList(filter);
            }
            int num = Helper.GetInt(PageValue.CurrentSystemConfig["couponSmsNum"], 5);
            EmailMethod sms = new EmailMethod();
            if (couponlist != null)
            {
                couponmodel = couponlist[0];
                //得到优惠券 根据cid
                if (couponmodel.Sms >= num && !IsAdmin)
                {  //如果短信发送量>=5并且当前用户是管理员的话
                    txt = JsonUtils.GetJson("短信发送优惠券最多" + num + "次", "alert");
                    Response.Write(txt);
                    return;
                }
                //得到系统表短信发送间隔时间
                //
                //找到项目
                team = couponmodel.Team;
                //【lefttime】 = 【间隔时间】 + 【发送短信的时间】 - 【当前时间】;
                //发送短信的日期
                DateTime smstime;
                int lefttime = 0;
                if (couponmodel.Sms_time.HasValue)
                {
                    smstime = DateTime.Parse(couponmodel.Sms_time.ToString());
                    if (ASSystem.smsinterval.ToString() != "")
                        lefttime = (smstime.AddSeconds(double.Parse(ASSystem.smsinterval.ToString())) - DateTime.Now).Seconds;
                    else
                    {
                        lefttime = (smstime - DateTime.Now).Seconds;
                    }
                }
                if (lefttime > 0)
                {
                    txt = JsonUtils.GetJson("你好，请在" + lefttime + "秒后，再次尝试短信发送优惠券", "alert");
                    Response.Write(txt);
                    return;
                }
                if (couponmodel == null || AsUser.Id == 0 || (couponmodel.User_id != AsUser.Id && !IsAdmin))
                {
                    txt = JsonUtils.GetJson("非法下载", "alert");// 调用websitehelper.json
                    Response.Write(txt);
                    return;
                }
                // SendSMS
                //【flag】 =【发送优惠券  调用websitehelper .sendsms】
                System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
                //得到下单的时候手机号码，并发送优惠券，如果订单中手机号码不存在，则给用户信息中的手机号码发优惠券
                ordermodel = couponmodel.Order;
                if (ordermodel != null && ordermodel.Mobile != "")
                    phone.Add(ordermodel.Mobile);
                else
                    phone.Add(couponmodel.User.Mobile);
                string tuangou = "";
                string tuanphone = "";
                if (ASSystem != null)
                {
                    tuangou = ASSystem.abbreviation;
                    tuanphone = ASSystem.tuanphone;
                }
                partnermodel = team.Partner;
                string partnername = "";
                string partnermobile = "";
                if (partnermodel != null)
                {
                    partnername = partnermodel.Title;
                    partnermobile = partnermodel.Phone;
                }
                NameValueCollection values = new NameValueCollection();
                values.Add("网站简称", ASSystem.abbreviation);
                values.Add("商品名称", couponmodel.Team.Product);
                values.Add("券号", couponmodel.Id);
                values.Add("密码", couponmodel.Secret);
                values.Add("优惠券结束时间", couponmodel.Expire_time.ToString("yyyy年MM月dd日"));
                if (couponmodel.start_time.HasValue && couponmodel.start_time.Value.ToString() != "")
                {
                    values.Add("优惠券开始时间", couponmodel.start_time.Value.ToString("yyyy年MM月dd日"));
                }
                else
                {
                    values.Add("优惠券开始时间", "");
                }
                values.Add("商户名称", partnername);
                values.Add("商户电话", partnermobile);
                values.Add("团购电话", tuanphone);
                txt = ReplaceStr("couponsms", values);
                if (EmailMethod.SendSMS(phone, txt))//Utils.WebSiteHelper.SendSms(sysbll.GetModel(1).smsuser, sysbll.GetModel(1).smspass, userbll.GetModel(couponmodel.User_id).Mobile, "手机短信发送成功，请及时查收"))
                {
                    txt = JsonUtils.GetJson(txt, "alert");  //调用websitehelper.json方法
                    couponmodel.Sms = couponmodel.Sms + 1;
                    couponmodel.Sms_time = DateTime.Now;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        session.Coupon.Update(couponmodel);
                    }
                    Response.Write(txt);
                    return;
                }
                else
                {
                    txt = JsonUtils.GetJson("短信发送失败", "alert");  //调用websitehelper.json方法
                    Response.Write(txt);
                    return;
                }
            }
            else
            {
                IPcoupon pcoumodel = null;
                ITeam pteam = null;
                IOrder porder = null;
                IPartner ppartner = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    pcoumodel = session.Pcoupon.GetByID(Helper.GetInt(cid, 0));
                }
                if (pcoumodel != null)
                {
                    pteam = pcoumodel.Team;
                }
                //找到项目
                //【lefttime】 = 【间隔时间】 + 【发送短信的时间】 - 【当前时间】;
                //发送短信的日期
                DateTime smstime;
                int lefttime = 0;
                if (pcoumodel.buy_time != null)
                {
                    smstime = DateTime.Parse(pcoumodel.buy_time.ToString());
                    if (ASSystem.smsinterval.ToString() != "")
                    {
                        lefttime = (smstime.AddSeconds(double.Parse(ASSystem.smsinterval.ToString())) - DateTime.Now).Seconds;
                    }
                    else
                    {
                        lefttime = (smstime - DateTime.Now).Seconds;
                    }
                }
                if (lefttime > 0)
                {
                    txt = JsonUtils.GetJson("你好，请在" + lefttime + "秒后，再次尝试短信发送优惠券", "alert");
                    Response.Write(txt);
                    return;
                }
                if (pcoumodel == null || AsUser.Id == 0 || (couponmodel.User_id != AsUser.Id && !IsAdmin))
                {
                    txt = JsonUtils.GetJson("非法下载", "alert");// 调用websitehelper.json
                    Response.Write(txt);
                    return;
                }
                // SendSMS
                //【flag】 =【发送优惠券  调用websitehelper .sendsms】
                System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
                //得到下单的时候手机号码，并发送优惠券，如果订单中手机号码不存在，则给用户信息中的手机号码发优惠券
                porder = pcoumodel.Order;
                if (ordermodel != null && ordermodel.Mobile != "")
                {
                    phone.Add(ordermodel.Mobile);
                }
                else
                {
                    phone.Add(pcoumodel.User.Mobile);
                }
                string tuangou = "";
                string tuanphone = "";
                if (ASSystem != null)
                {
                    tuangou = ASSystem.abbreviation;
                    tuanphone = ASSystem.tuanphone;
                }
                ppartner = pteam.Partner;
                string partnername = "";
                string partnermobile = "";
                if (partnermodel != null)
                {
                    partnername = partnermodel.Title;
                    partnermobile = partnermodel.Phone;
                }
                NameValueCollection values = new NameValueCollection();
                values.Add("网站简称", ASSystem.abbreviation);
                values.Add("商品名称", couponmodel.Team.Product);
                values.Add("券号", couponmodel.Id);
                values.Add("密码", couponmodel.Secret);
                values.Add("优惠券结束时间", couponmodel.Expire_time.ToString("yyyy年MM月dd日"));
                if (couponmodel.start_time.Value != null && couponmodel.start_time.Value.ToString() != "")
                {
                    values.Add("优惠券开始时间", couponmodel.start_time.Value.ToString("yyyy年MM月dd日"));
                }
                else
                {
                    values.Add("优惠券开始时间", "");
                }
                values.Add("商户名称", partnername);
                values.Add("商户电话", partnermobile);
                values.Add("团购电话", tuanphone);
                txt = ReplaceStr("couponsms", values);
                if (EmailMethod.SendSMS(phone, txt))//Utils.WebSiteHelper.SendSms(sysbll.GetModel(1).smsuser, sysbll.GetModel(1).smspass, userbll.GetModel(couponmodel.User_id).Mobile, "手机短信发送成功，请及时查收"))
                {
                    txt = JsonUtils.GetJson(txt, "alert");  //调用websitehelper.json方法
                    Response.Write(txt);
                    return;
                }
                else
                {
                    txt = JsonUtils.GetJson("短信发送失败", "alert");  //调用websitehelper.json方法
                    Response.Write(txt);
                    return;
                }
            }
        }
        else if (action == "psms")
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_CouponP_SendSms))
            {
                Response.Write(JsonUtils.GetJson("你不具有站外券发送短信的权限", "alert"));
                return;
            }
            string txt = "";
            IPcoupon pcoumodel = null;
            using (IDataSession session=Store.OpenSession(false))
            {
                pcoumodel = session.Pcoupon.GetByID(Helper.GetInt(cid, 0));
            }
            int num = Helper.GetInt(PageValue.CurrentSystemConfig["couponSmsNum"], 5);
            if (pcoumodel != null)
            {
                if (pcoumodel.sms >= num)
                {  //如果短信发送量>=5并且当前用户是管理员的话
                    txt = JsonUtils.GetJson("短信发送站外券最多" + num + "次", "alert");
                    Response.Write(txt);
                    return;
                }
                teammodel = pcoumodel.Team;
                //【lefttime】 = 【间隔时间】 + 【发送短信的时间】 - 【当前时间】;
                //发送短信的日期
                DateTime smstime;
                int lefttime = 0;
                if (pcoumodel.sms_time.HasValue)
                {
                    smstime = DateTime.Parse(pcoumodel.sms_time.ToString());
                    if (ASSystem.smsinterval!= null)
                    {
                        lefttime = (smstime.AddSeconds(double.Parse(ASSystem.smsinterval.ToString())) - DateTime.Now).Seconds;
                    }
                    else
                    {
                        lefttime = (smstime - DateTime.Now).Seconds;
                    }
                }
                if (lefttime > 0)
                {
                    txt = JsonUtils.GetJson("你好，请在" + lefttime + "秒后，再次尝试短信发送优惠券", "alert");
                    Response.Write(txt);
                    return;
                }

                if (teammodel != null)
                {
                    if (pcoumodel == null || AsUser.Id == 0 || (pcoumodel.userid != AsUser.Id && !IsAdmin))
                    {
                        txt = JsonUtils.GetJson("非法下载", "alert");// 调用websitehelper.json
                        Response.Write(txt);
                        return;
                    }
                    #region
                    System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();

                    //得到下单的时候手机号码，并发送优惠券，如果订单中手机号码不存在，则给用户信息中的手机号码发优惠券
                    if (pcoumodel.Order != null && pcoumodel.Order.Mobile != "")
                    {
                        phone.Add(pcoumodel.Order.Mobile);
                    }
                    else
                    {
                        phone.Add(pcoumodel.User.Mobile);
                    }


                    string tuangou = "";
                    string tuanphone = "";
                    if (ASSystem != null)
                    {
                        tuangou = ASSystem.abbreviation;
                        tuanphone = ASSystem.tuanphone;
                    }
                    string partnername = "";
                    string partnermobile = "";
                    if (teammodel.Partner != null)
                    {
                        partnername = teammodel.Partner.Title;
                        partnermobile = teammodel.Partner.Phone;
                    }
                    NameValueCollection values = new NameValueCollection();
                    values.Add("网站简称", ASSystem.abbreviation);
                    values.Add("商品名称", teammodel.Product);
                    values.Add("商户优惠券", pcoumodel.number);


                    if (pcoumodel.start_time.Value != null && pcoumodel.start_time.Value.ToString() != "")
                    {
                        values.Add("优惠券开始时间", pcoumodel.start_time.Value.ToString("yyyy年MM月dd日"));
                    }
                    if (pcoumodel.expire_time != null && pcoumodel.expire_time.ToString() != "")
                    {
                        values.Add("优惠券结束时间", pcoumodel.expire_time.ToString("yyyy年MM月dd日"));
                    }
                    values.Add("商户名称", partnername);
                    values.Add("商户电话", partnermobile);
                    values.Add("团购电话", tuanphone);
                    txt = ReplaceStr("bizcouponsms", values);

                    if (EmailMethod.SendSMS(phone, txt))
                    {
                        txt = JsonUtils.GetJson(txt, "alert");  //调用websitehelper.json方法
                        pcoumodel.sms = pcoumodel.sms + 1;
                        pcoumodel.sms_time = DateTime.Now;
                        using (IDataSession session=Store.OpenSession(false))
                        {
                            session.Pcoupon.Update(pcoumodel);
                        }
                        Response.Write(txt);
                        return;
                    }
                    else
                    {
                        txt = JsonUtils.GetJson("短信发送失败", "alert");  //调用websitehelper.json方法
                        Response.Write(txt);
                        return;
                    }
                    #endregion
                }
            }
        }
        else if (action == "invent")
        {
            html = WebUtils.LoadPageString("WebPage_Addinventorylog.aspx?id=" + inventid + "&p=" + p + "");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            return;
        }
        else if ("pinvent" == action)
        {
            html = WebUtils.LoadPageString("manage_ajax_AddInventoryLogProdunct.aspx?id=" + inventid + "&p=" + p + "");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
            return;
        }                

        else
        {
            Response.Write("对不起，没有此优惠券");
        }
    }


</script>
