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
        IProduct productmodel = null;
        if (action == "sms")
        {
            string txt = "";
            string csecret = Helper.GetString(Request["csecret"], String.Empty);
            IList<ICoupon> couponlist = null;
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
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(Helper.GetInt(couponmodel.Team_id, 0));
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

                if (couponmodel == null || AsAdmin.Id == 0 || (couponmodel.User_id != AsAdmin.Id && !IsAdmin))
                {
                    txt = JsonUtils.GetJson("非法下载", "alert");// 调用websitehelper.json
                    Response.Write(txt);
                    return;
                }
                // SendSMS
                //【flag】 =【发送优惠券  调用websitehelper .sendsms】
                List<string> phone = new List<string>();
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
                values.Add("商品名称", teammodel.Product);
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
                List<string> phone = new List<string>();
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
                values.Add("商品名称", teammodel.Product);
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
            
            string txt = "";
            IPcoupon pcoumodel = null;
            using (IDataSession session=AS.GroupOn.App.Store.OpenSession(false))
            {
                pcoumodel = session.Pcoupon.GetByID(Helper.GetInt(cid, 0));
            }   
            if (pcoumodel != null)
            {
                if (pcoumodel.sms >= 5 && !IsAdmin)
                {  //如果短信发送量>=5并且当前用户是管理员的话
                    txt =JsonUtils.GetJson("短信发送站外券最多5次", "alert");
                    Response.Write(txt);
                    return;
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(Helper.GetInt(pcoumodel.teamid, 0));
                }  
                //【lefttime】 = 【间隔时间】 + 【发送短信的时间】 - 【当前时间】;
                //发送短信的日期
                DateTime smstime;
                int lefttime = 0;
                if (pcoumodel.sms_time.HasValue)
                {
                    smstime = DateTime.Parse(pcoumodel.sms_time.ToString());
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

                if (teammodel != null)
                {
                    IUser usermode = null; 
                    string key = AS.Common.Utils.FileUtils.GetKey();
                    using (IDataSession session =AS.GroupOn.App.Store.OpenSession(false))
                    {
                        usermode = session.Users.GetbyUName(CookieUtils.GetCookieValue("username", key));
                    }
                    if (pcoumodel == null || CookieUtils.GetCookieValue("username", key).Length == 0 || (pcoumodel.userid != usermode.Id && !IsAdmin))
                    {
                        txt = JsonUtils.GetJson("非法下载", "alert");// 调用websitehelper.json
                        Response.Write(txt);
                        return;
                    }
                    #region
                    List<string> phone = new List<string>();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        usermode = session.Users.GetByID(pcoumodel.userid);
                    }
                    phone.Add(usermode.Mobile);
                    string tuangou = "";
                    if (ASSystem != null)
                    {
                        tuangou = ASSystem.abbreviation;
                    }
                    IPartner partnermodel = null;
                    using (IDataSession session=AS.GroupOn.App.Store.OpenSession(false))
                    {
                        partnermodel = session.Partners.GetByID(teammodel.Partner_id);
                    }
                    
                    string partnername = "";
                    string partnermobile = "";
                    if (partnermodel != null)
                    {
                        partnername = partnermodel.Title;
                        partnermobile = partnermodel.Phone;
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
                    values.Add("联系方式", partnermobile);
                    txt = ReplaceStr("bizcouponsms", values);

                    if (EmailMethod.SendSMS(phone, txt))//Utils.WebSiteHelper.SendSms(sysbll.GetModel(1).smsuser, sysbll.GetModel(1).smspass, userbll.GetModel(couponmodel.User_id).Mobile, "手机短信发送成功，请及时查收"))
                    {

                        txt = JsonUtils.GetJson(txt, "alert");  //调用websitehelper.json方法
                        pcoumodel.sms = pcoumodel.sms + 1;
                        pcoumodel.sms_time = DateTime.Now;
                        using (IDataSession session =AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int i = 0;
                            i = session.Pcoupon.Update(pcoumodel);
                        }
                        
                        Response.Write(txt);
                        return;
                    }
                    else
                    {
                        // json(短信发送失败, 'alert');//调用websitehelper.json方法
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
        else if (action == "reinvent")
        {
            try
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(Convert.ToInt32(Request["resultid"]));
                }

                if (Getbulletin(teammodel.bulletin) != "")
                {
                    if (Getbulletin(teammodel.invent_result) != "")//有规格
                    {
                        if (Getrule(Request["result"]) == false)
                        {
                            string re = teammodel.invent_result;
                            teammodel.invent_result = Getrule(Request["result"], teammodel.invent_result, 0, 2);
                            teammodel.inventory = Getrulenum(Request["result"], re, 1, 2);
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id2 = session.Teams.Update(teammodel);
                            }
                            //记录库存更变记录
                            intoorder(0, Getnum(Request["result"]), 1, Convert.ToInt32(Request["resultid"]), 0, Request["result"], 0);


                            //处理产品库存

                            IProduct promodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                promodel = session.Product.GetByID(teammodel.productid);
                            }

                            if (promodel != null)
                            {
                                string strpre = promodel.invent_result;
                                promodel.invent_result = Getrule(Request["result"], promodel.invent_result, 0, 2);
                                promodel.inventory = Getrulenum(Request["result"], strpre, 1, 2);

                                if (promodel.inventory > 0)
                                {
                                    promodel.status = 1;
                                }
                                else
                                {
                                    promodel.status = 0;
                                }
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int id2 = session.Product.Update(promodel);
                                }

                                //退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                                intoorder(0, Getnum(Request["result"]), 1, Convert.ToInt32(Request["resultid"]), 0, Request["result"], 1);

                            }
                            #region 如果启动的报警开关，同时项目处于报警的状态，那么给管理员发送短信
                            if (Helper.GetString(teammodel.warmobile, "") != "")
                            {
                                if (teammodel.open_war == 1)//开启库存报警功能
                                {
                                    if (IsWar(teammodel))
                                    {
                                        List<string> phone = new List<string>();
                                        phone.Add(teammodel.warmobile);
                                        //SendSMS(phone, "库存提醒，项目编号：" + teammodel.Id + ".库存已不足，请及时入库");
                                    }
                                }
                            }
                            #endregion

                            string url = Request.UrlReferrer.AbsoluteUri;
                            if (Helper.GetString(Request["p"], "") == "p")
                            {
                                SetSuccess("入库成功");
                                Response.Write(JsonUtils.GetJson("location.href='Project_PointXiangmu.aspx'", "eval"));
                            }
                            else if (Helper.GetString(Request["p"], "") == "d")
                            {
                                SetSuccess("入库成功");
                                Response.Write(JsonUtils.GetJson("location.href='Project_DangqianXiangmu.aspx'", "eval"));
                            }
                            else
                            {
                                SetSuccess("入库成功");
                                Response.Write(JsonUtils.GetJson("location.href=''", "eval"));
                            }


                        }
                        else
                        {
                            result = "您选择的规格重复，请重新选择";

                            OrderedDictionary list = new OrderedDictionary();
                            list.Add("html", result);
                            list.Add("id", "coupon-dialog-display-id1");
                            Response.Write(JsonUtils.GetJson(list, "updater"));
                        }
                    }
                    else
                    {
                        if (Getrule(Request["result"]) == false)
                        {

                            teammodel.invent_result = Request["result"];
                            teammodel.inventory = Getrulenum(Request["result"], teammodel.invent_result, 0, 2);
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id2 = session.Teams.Update(teammodel);
                            }

                            intoorder(0, Getnum(Request["result"]), 1, Convert.ToInt32(Request["resultid"]), 0, Request["result"], 0);


                            //处理产品库存                            
                            IProduct promodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                promodel = session.Product.GetByID(teammodel.productid);
                            }
                            if (promodel != null)
                            {

                                promodel.invent_result = Request["result"];
                                promodel.inventory = Getrulenum(Request["result"], promodel.invent_result, 0, 2);
                                if (promodel.inventory > 0)
                                {
                                    promodel.status = 1;
                                }
                                else
                                {
                                    promodel.status = 0;
                                }
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int id2 = session.Product.Update(promodel);
                                }

                                //退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                                intoorder(0, Getnum(Request["result"]), 1, Convert.ToInt32(Request["resultid"]), 0, Request["result"], 1);

                            }

                            // result = "恭喜您，项目库存添加成功";

                            #region 如果启动的报警开关，同时项目处于报警的状态，那么给管理员发送短信
                            if (Helper.GetString(teammodel.warmobile, "") != "")
                            {
                                if (teammodel.open_war == 1)//开启库存报警功能
                                {
                                    if (IsWar(teammodel))
                                    {
                                        List<string> phone = new List<string>();
                                        phone.Add(teammodel.warmobile);
                                        //SendSMS(phone, "库存提醒，项目编号：" + teammodel.Id + ".库存已不足，请及时入库");
                                    }
                                }
                            }
                            #endregion

                            string url = Request.UrlReferrer.AbsoluteUri;
                            if (Helper.GetString(Request["p"], "") == "p")
                            {
                                SetSuccess("入库成功");
                                Response.Write(JsonUtils.GetJson("location.href='Project_PointXiangmu.aspx'", "eval"));
                            }
                            else if (Helper.GetString(Request["p"], "") == "d")
                            {
                                SetSuccess("入库成功");
                                Response.Write(JsonUtils.GetJson("location.href='Project_DangqianXiangmu.aspx'", "eval"));
                            }
                            else
                            {
                                SetSuccess("入库成功");
                                Response.Write(JsonUtils.GetJson("location.href=''", "eval"));
                            }


                        }
                        else
                        {
                            result = "您选择的规格重复，请重新选择";
                            OrderedDictionary list = new OrderedDictionary();
                            list.Add("html", result);
                            list.Add("id", "coupon-dialog-display-id1");
                            Response.Write(JsonUtils.GetJson(list, "updater"));
                        }
                    }

                }
                else//项目没有规格
                {
                    string txt = Request["result"];
                    teammodel.inventory = teammodel.inventory + Convert.ToInt32(Request["result"]);
                    if (teammodel.inventory < 0)
                    {
                        teammodel.inventory = 0;
                        txt = "0";
                    }
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int id2 = session.Teams.Update(teammodel);
                    }

                    intoorder(0, Convert.ToInt32(txt), 1, Convert.ToInt32(Request["resultid"]), 0, Request["result"], 0);


                    //处理产品库存

                    IProduct promodel = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        promodel = session.Product.GetByID(teammodel.productid);
                    }
                    if (promodel != null)
                    {
                        promodel.inventory = promodel.inventory + Convert.ToInt32(Request["result"]);
                        if (promodel.inventory < 0)
                        {
                            promodel.inventory = 0;
                            txt = "0";
                        }
                        if (promodel.inventory > 0)
                        {
                            promodel.status = 1;
                        }
                        else
                        {
                            promodel.status = 0;
                        }
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int id2 = session.Product.Update(promodel);
                        }

                        //退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                        intoorder(0, Convert.ToInt32(txt), 1, Convert.ToInt32(Request["resultid"]), 0, Request["result"], 1);

                    }




                    #region 如果启动的报警开关，同时项目处于报警的状态，那么给管理员发送短信
                    if (Helper.GetString(teammodel.warmobile, "") != "")
                    {
                        if (teammodel.open_war == 1)//开启库存报警功能
                        {
                            if (IsWar(teammodel))
                            {
                                List<string> phone = new List<string>();
                                phone.Add(teammodel.warmobile);
                                //SendSMS(phone, "库存提醒，项目编号：" + teammodel.Id + ".库存已不足，请及时入库");
                            }
                        }
                    }
                    #endregion
                    //result = "恭喜您，项目库存添加成功";
                    if (Helper.GetString(Request["p"], "") == "p")
                    {
                        SetSuccess("入库成功");
                        Response.Write(JsonUtils.GetJson("location.href='Project_PointXiangmu.aspx'", "eval"));
                    }
                    else if (Helper.GetString(Request["p"], "") == "d")
                    {
                        SetSuccess("入库成功");
                        Response.Write(JsonUtils.GetJson("location.href='Project_DangqianXiangmu.aspx'", "eval"));
                    }
                    else
                    {
                        SetSuccess("入库成功");
                        Response.Write(JsonUtils.GetJson("location.href=''", "eval"));
                    }
                }
            }
            catch (Exception ex)
            {
                result = "友情提示：发生了异常操作，请重新打开页面操作";
                OrderedDictionary list = new OrderedDictionary();
                list.Add("html", result);
                list.Add("id", "coupon-dialog-display-id1");
                Response.Write(JsonUtils.GetJson(list, "updater"));
            }



        }
        else if (action == "preinvent")
        {
            try
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    productmodel = session.Product.GetByID(Convert.ToInt32(Request["resultid"]));
                }
                if (Getbulletin(productmodel.bulletin) != "")
                {
                    if (Getbulletin(productmodel.invent_result) != "")
                    {
                        if (Getrule(Request["result"]) == false)
                        {
                            string re = productmodel.invent_result;
                            productmodel.invent_result = Getrule(Request["result"], productmodel.invent_result, 0, 2);
                            productmodel.inventory = Getrulenum(Request["result"], re, 1, 2);
                            if (productmodel.inventory > 0)
                            {
                                productmodel.status = 1;
                            }
                            else
                            {
                                productmodel.status = 0;
                            }
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id = session.Product.Update(productmodel);
                            }
                            intoorder(0, Getnum(Request["result"]), 1, Convert.ToInt32(Request["resultid"]), 0, Request["result"], 1);

                            //更新项目的库存信息
                            IList<ITeam> teammodels = null;
                            TeamFilter teamft = new TeamFilter();
                            teamft.productid = productmodel.id;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                teammodels = session.Teams.GetList(teamft);
                            }
                            if (teammodels != null)
                            {
                                if (teammodels.Count > 0)
                                {
                                    for (int i = 0; i < teammodels.Count; i++)
                                    {
                                        teammodel = teammodels[i];

                                        string tre = teammodel.invent_result;
                                        teammodel.invent_result = Getrule(Request["result"], teammodel.invent_result, 0, 2);
                                        teammodel.inventory = Getrulenum(Request["result"], tre, 1, 2);
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            int id = session.Teams.Update(teammodel);
                                        }
                                        //管理员u信息的记录 号 为0 ; 记得修改!!!!!!!!!!!!
                                        intoorder(0, Getnum(Request["result"]), 1, teammodel.Id, 0, Request["result"], 0);
                                    }
                                }
                            }

                            if (Helper.GetString(Request["p"], "") == "p")
                            {
                                SetSuccess("入库成功");
                                Response.Write(JsonUtils.GetJson("location.href='ProductList.aspx'", "eval"));
                            }
                            else if (Helper.GetString(Request["p"], "") == "biz")
                            {
                                SetSuccess("入库成功");
                                Response.Write(JsonUtils.GetJson("location.href='ProductList.aspx'", "eval"));
                            }
                            else
                            {
                                SetSuccess("入库成功");
                                Response.Write(JsonUtils.GetJson("location.href=''", "eval"));
                            }


                        }
                        else
                        {

                            result = "您选择的规格重复，请重新选择";
                            OrderedDictionary list = new OrderedDictionary();
                            list.Add("html", result);
                            list.Add("id", "coupon-dialog-display-id1");
                            Response.Write(JsonUtils.GetJson(list, "updater"));
                        }

                    }
                    else
                    {

                        if (Getrule(Request["result"]) == false)
                        {

                            productmodel.invent_result = Request["result"];
                            productmodel.inventory = Getrulenum(Request["result"], productmodel.invent_result, 0, 2);
                            if (productmodel.inventory > 0)
                            {
                                productmodel.status = 1;
                            }
                            else
                            {
                                productmodel.status = 0;
                            }
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id = session.Product.Update(productmodel);
                            }

                            intoorder(0, Getnum(Request["result"]), 1, Convert.ToInt32(Request["resultid"]), 0, Request["result"], 1);

                            //更新项目的库存信息
                            IList<ITeam> teammodels = null;
                            TeamFilter teamft = new TeamFilter();
                            teamft.productid = productmodel.id;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                teammodels = session.Teams.GetList(teamft);
                            }
                            if (teammodels != null)
                            {
                                if (teammodels.Count > 0)
                                {
                                    for (int i = 0; i < teammodels.Count; i++)
                                    {
                                        teammodel = teammodels[i];

                                        teammodel.invent_result = Request["result"];
                                        teammodel.inventory = Getrulenum(Request["result"], teammodel.invent_result, 0, 2);
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            int id = session.Teams.Update(teammodel);
                                        }
                                        intoorder(0, Getnum(Request["result"]), 1, teammodel.Id, 0, Request["result"], 0);
                                    }
                                }
                            }

                            if (Helper.GetString(Request["p"], "") == "p")
                            {
                                SetSuccess("入库成功");
                                Response.Write(JsonUtils.GetJson("location.href='ProductList.aspx'", "eval"));
                            }
                            else
                            {
                                SetSuccess("入库成功");
                                Response.Write(JsonUtils.GetJson("location.href=''", "eval"));
                            }


                        }
                        else
                        {
                            result = "您选择的规格重复，请重新选择";
                            OrderedDictionary list = new OrderedDictionary();
                            list.Add("html", result);
                            list.Add("id", "coupon-dialog-display-id1");
                            Response.Write(JsonUtils.GetJson(list, "updater"));
                        }
                    }

                }
                else
                {
                    string txt = Request["result"];
                    productmodel.inventory = productmodel.inventory + Convert.ToInt32(Request["result"]);
                    if (productmodel.inventory < 0)
                    {
                        productmodel.inventory = 0;
                        txt = "0";
                    }

                    productmodel.status = 4;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int id = session.Product.Update(productmodel);
                    }


                    intoorder(0, Convert.ToInt32(txt), 1, Convert.ToInt32(Request["resultid"]), 0, Request["result"], 1);




                    //更新项目的库存信息                    
                    IList<ITeam> teammodels = null;
                    TeamFilter teamft = new TeamFilter();
                    teamft.productid = productmodel.id;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        teammodels = session.Teams.GetList(teamft);
                    }
                    if (teammodels != null)
                    {
                        if (teammodels.Count > 0)
                        {
                            for (int i = 0; i < teammodels.Count; i++)
                            {
                                teammodel = teammodels[i];
                                teammodel.inventory = teammodel.inventory + Convert.ToInt32(Request["result"]);
                                if (teammodel.inventory < 0)
                                {
                                    teammodel.inventory = 0;
                                    txt = "0";
                                }
                            }
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id = session.Teams.Update(teammodel);
                            }

                            intoorder(0, Convert.ToInt32(txt), 1, teammodel.Id, 0, Request["result"], 0);
                        }
                    }

                    if (Helper.GetString(Request["p"], "") == "p")
                    {
                        SetSuccess("入库成功");
                        Response.Write(JsonUtils.GetJson("location.href='ProductList.aspx'", "eval"));
                    }
                    else
                    {
                        SetSuccess("入库成功");
                        Response.Write(JsonUtils.GetJson("location.href=''", "eval"));
                    }
                }
            }
            catch (Exception ex)
            {
                result = "友情提示：发生了异常操作，请重新打开页面操作";
                OrderedDictionary list = new OrderedDictionary();
                list.Add("html", result);
                list.Add("id", "coupon-dialog-display-id1");
                Response.Write(JsonUtils.GetJson(list, "updater"));
            }
        }

        else
        {
            Response.Write("对不起，没有此优惠券");
        }
    }

    #region 项目替换
    public static string Getbulletin(string bulletin)
    {
        string str = bulletin.Replace("{", "").Replace(":", "").Replace("[", "").Replace("]", "").Replace("}", "");
        return str;
    }
    #endregion

    #region 规格数量的变化 back 0,代表入库,1,代表出库,state 1代表后台，2代表前台
    public static bool Getrule(string newrule)
    {
        string result = string.Empty;
        bool falg = false;
        int sum = 0;
        if (newrule != null)
        {
            if (newrule.IndexOf('|') > 0)
            {
                string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
                //项目规格的原有的数量

                for (int j = 0; j < newrulemo.Length; j++)
                {
                    string txt3 = newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','));
                    if (result.Contains(newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','))))
                    {
                        falg = true;
                    }
                    result += "{" + newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(',')) + ",数量:[" + sum + "]}|";
                }
            }
        }
        return falg;

    }
    #endregion


    #region 规格数量的变化 back 0,代表入库,1,代表出库,state 1代表后台，2代表前台
    public static string Getrule(string newrule, string oldrule, int back, int state)
    {
        string result = string.Empty;
        string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
        string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('|');
        int newnum = 0;
        int oldnum = 0;
        int sum = 0;
        string bottom = "";

        bool falg = false;

        //项目规格的原有的数量
        for (int j = 0; j < newrulemo.Length; j++)
        {
            //新规格的数量
            newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
            string str = "";
            if (j < oldrulemo.Length)
            {
                string txt1 = oldrulemo[j];
                str = oldrulemo[j].Substring(0, oldrulemo[j].LastIndexOf(','));
                oldnum = Convert.ToInt32(oldrulemo[j].Substring(oldrulemo[j].LastIndexOf(','), oldrulemo[j].Length - oldrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
            }
            else
            {
                oldnum = 0;
            }
            if (newrulemo[j].Contains(str))
            {
                string txt = newrulemo[j];
                txt = newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','));
            }
            string txt3 = newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','));
            sum = newnum + oldnum;
            result += "{" + newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(',')) + ",数量:[" + sum + "]}|";
        }
        result = result.Remove(result.LastIndexOf('|'));
        return result;
    }
    #endregion

    #region 规格数量的变化 back 0,代表添加,1,代表修改,state 1代表后台，2代表前台
    public static int Getrulenum(string newrule, string oldrule, int back, int state)
    {
        string result = string.Empty;
        string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
        string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('|');
        int newnum = 0;
        int oldnum = 0;
        int sum = 0;


        //项目规格的原有的数量

        for (int j = 0; j < newrulemo.Length; j++)
        {

            newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
            string str = "";
            if (j < oldrulemo.Length)
            {
                string txt1 = oldrulemo[j];
                str = oldrulemo[j].Substring(0, oldrulemo[j].LastIndexOf(','));
                oldnum = Convert.ToInt32(oldrulemo[j].Substring(oldrulemo[j].LastIndexOf(','), oldrulemo[j].Length - oldrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
            }
            else
            {
                oldnum = 0;
            }
            if (newrulemo[j].Contains(str))
            {
                string txt = newrulemo[j];
                txt = newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','));
            }
            if (back == 0)
            {
                if (newnum > 0)
                {
                    sum += newnum;
                }
            }
            else if (back == 1)
            {
                if ((newnum + oldnum) > 0)
                {
                    sum += (newnum + oldnum);
                }
            }

        }

        return sum;
    }
    #endregion

    #region 统计出入库的数量
    public static int Getnum(string newrule)
    {
        int newnum = 0;
        int sum = 0;
        if (AS.Common.Utils.Helper.GetString(newrule, "") != "")
        {
            string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
            for (int j = 0; j < newrulemo.Length; j++)
            {
                newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                sum += newnum;
            }
        }
        return sum;
    }
    #endregion
    #region 判断是否报警
    public static bool IsWar(ITeam model)
    {
        bool falg = false;
        if (model.inventory < model.invent_war)
        {
            falg = true;
        }
        return falg;
    }
    #endregion
    
</script>
