<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

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

    protected override void OnLoad(EventArgs e)
    {
        string action = AS.Common.Utils.Helper.GetString(Request["action"], String.Empty);
        string detailid = AS.Common.Utils.Helper.GetString(Request["detailid"], String.Empty);
        string Id = AS.Common.Utils.Helper.GetString(Request["Id"], string.Empty);
        string userlevel = AS.Common.Utils.Helper.GetString(Request["userruleid"], string.Empty);
        string pageIndex = AS.Common.Utils.Helper.GetString(Request["pageIndex"], string.Empty);
        string id = AS.Common.Utils.Helper.GetString(Request["id"], String.Empty);
        string orderview = AS.Common.Utils.Helper.GetString(Request["orderview"], String.Empty);
        string rid = AS.Common.Utils.Helper.GetString(Request["rid"], String.Empty);
        string nid = AS.Common.Utils.Helper.GetString(Request["nid"], String.Empty);
        string orderid = AS.Common.Utils.Helper.GetString(Request["orderid"], String.Empty);
        string sid = AS.Common.Utils.Helper.GetString(Request["cid"], String.Empty);
        if (rid != String.Empty) rid = rid.ToLower();
        string sale_id = AS.Common.Utils.Helper.GetString(Request["saleid"], String.Empty);
        int role_id = AS.Common.Utils.Helper.GetInt(Request["roleid"], 0);
        string couponsecret = AS.Common.Utils.Helper.GetString(Request["couponsecret"], String.Empty);
        SystemFilter sysft = new SystemFilter();
        ISystem sysmodel = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            sysmodel = session.System.GetByID(1);
        }
        if ("noticesms" == action) //短信发券
        {

            //nid=第几条
            //id项目id
            int page = Helper.GetInt(nid, 0) + 1;
            ITeam teammodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teammodel = session.Teams.GetByID(Helper.GetInt(id, 0));
            }
            if (teammodel.Delivery == "pcoupon")
            {

                //1:得到下单项目的数量
                OrderFilter orderft = new OrderFilter();
                System.Collections.Generic.IList<IOrder> orderlist = null;
                orderft.Team_id = Helper.GetInt(id, 0);
                orderft.State = "pay";
                int quanty = 0;
                string strOrdercount = string.Empty;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    orderlist = session.Orders.GetList(orderft);
                }
                foreach (IOrder item in orderlist)
                {
                    if (item.Quantity != null)
                    {
                        quanty = quanty + item.Quantity;
                    }
                }
                strOrdercount = quanty.ToString();

                //2:得到已购买的站外券的数量
                string strPcouponCount = "0";
                PcouponFilter pcouponft = new PcouponFilter();
                System.Collections.Generic.IList<IPcoupon> pcouponlist = null;
                pcouponft.teamid = Helper.GetInt(id, 0);
                pcouponft.state = "buy";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    pcouponlist = session.Pcoupon.GetList(pcouponft);
                }
                strPcouponCount = pcouponlist.Count.ToString();

                //3：判断订单中的数量strOrdercount与站外券strPcouponCount的大小，strOrdercount>strPcouponCount,则需要自动发券
                if (Helper.GetInt(strOrdercount, 0) > Helper.GetInt(strPcouponCount, 0))
                {
                    //4：找出未发券的订单
                    if (orderlist != null)
                    {
                        System.Data.DataTable dt = Helper.ToDataTable(orderlist.ToList());
                        if (dt.Rows.Count > 0)
                        {
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                string strUserId = dt.Rows[i]["User_id"].ToString();
                                string strQuantity = dt.Rows[i]["Quantity"].ToString();
                                string strOrderId = dt.Rows[i]["id"].ToString();
                                string strOrderMobile = dt.Rows[i]["Mobile"].ToString();

                                //5:查询该订单已发的优惠券
                                PcouponFilter pcouponft2 = new PcouponFilter();
                                System.Collections.Generic.IList<IPcoupon> pcouponlist2 = null;
                                pcouponft2.orderid = Helper.GetInt(strOrderId, 0);
                                pcouponft2.state = "buy";
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    pcouponlist2 = session.Pcoupon.GetList(pcouponft2);
                                }
                                if (pcouponlist2 != null)
                                {
                                    System.Data.DataTable dt2 = Helper.ToDataTable(pcouponlist2.ToList());
                                    if (dt2.Rows.Count > 0)
                                    {
                                        int num = Helper.GetInt(dt2.Rows[0]["num"], 0);
                                        if (Helper.GetInt(strQuantity, 0) > num)
                                        {

                                            //得到需要发送的站外券的数量
                                            int num_nobuy = int.Parse(strQuantity) - num;

                                            string tuanphone = "";
                                            if (sysmodel != null)
                                            {
                                                tuanphone = sysmodel.tuanphone;
                                            }
                                            PcouponFilter pcouponft3 = new PcouponFilter();
                                            IList<IPcoupon> dsOrderPcoupon_nobuy = null;
                                            pcouponft3.teamid = Helper.GetInt(id, 0);
                                            pcouponft3.state = "nobuy";
                                            pcouponft3.Top = num_nobuy;
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                dsOrderPcoupon_nobuy = session.Pcoupon.GetList(pcouponft3);
                                            }

                                            if (dsOrderPcoupon_nobuy != null)
                                            {
                                                System.Data.DataTable dt3 = Helper.ToDataTable(dsOrderPcoupon_nobuy.ToList());
                                                for (int j = 0; j < dt3.Rows.Count; j++)
                                                {
                                                    System.Data.DataRow drOrderPcoupon = dt3.Rows[j];
                                                    IPartner partnermodel = null;
                                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
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

                                                    //6：发送站外券
                                                    NameValueCollection values = new NameValueCollection();
                                                    values.Add("网站简称", ASSystem.abbreviation);
                                                    values.Add("商品名称", teammodel.Product);
                                                    values.Add("商户优惠券", drOrderPcoupon["number"].ToString());
                                                    if (drOrderPcoupon["start_time"] != null && drOrderPcoupon["start_time"].ToString() != "")
                                                    {
                                                        values.Add("优惠券开始时间", DateTime.Parse(drOrderPcoupon["start_time"].ToString()).ToString("yyyy年MM月dd日"));
                                                    }
                                                    if (drOrderPcoupon["expire_time"] != null && drOrderPcoupon["expire_time"].ToString() != "")
                                                    {
                                                        values.Add("优惠券结束时间", DateTime.Parse(drOrderPcoupon["expire_time"].ToString()).ToString("yyyy年MM月dd日"));
                                                    }
                                                    values.Add("商户名称", partnername);
                                                    values.Add("商户电话", partnermobile);
                                                    values.Add("团购电话", tuanphone);
                                                    string txt = ReplaceStr("bizcouponsms", values);
                                                    List<string> phone = new List<string>();
                                                    phone.Add(strOrderMobile);
                                                    EmailMethod.SendSMS(phone, txt);

                                                    //修改站外券状态
                                                    IPcoupon pcounponm = null;
                                                    pcounponm.id = Helper.GetInt(drOrderPcoupon["id"], 0);
                                                    pcounponm.userid = Helper.GetInt(strUserId, 0);
                                                    pcounponm.orderid = Helper.GetInt(strOrderId, 0);
                                                    pcounponm.state = "buy";
                                                    using (IDataSession sesion = AS.GroupOn.App.Store.OpenSession(false))
                                                    {
                                                        int idd = sesion.Pcoupon.Update(pcounponm);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }


                }
                else
                {

                    Response.Write(JsonUtils.GetJson("发送完毕", "alert"));
                    return;

                }


            }
            else
            {


                //得到当前项目的优惠券

                OrderFilter orderft = new OrderFilter();
                IList<IOrder> orderlis = null;
                IList<ICoupon> couponlis = null;
                orderft.Incoupon = Helper.GetInt(id, 0);
                orderft.State = "pay";
                orderft.AddSortOrder(OrderFilter.Create_time_ASC);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    orderlis = session.Orders.GetList(orderft);
                }
                if (page <= orderlis.Count)
                {
                    NameValueCollection _system = new NameValueCollection();
                    ISystem sysmodel1 = null;
                    _system = AS.Common.Utils.WebUtils.GetSystem();
                    System.Data.DataTable octable = Helper.ToDataTable(orderlis.ToList());//优惠券和订单集合
                    CouponFilter couponft = new CouponFilter();
                    System.Data.DataRow row = octable.Rows[0];

                    couponft.Order_id = Helper.GetInt(row["Id"], 0);
                    couponft.AddSortOrder(CouponFilter.Create_time_ASC);
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        couponlis = session.Coupon.GetList(couponft);
                    }
                    System.Data.DataTable coctable = Helper.ToDataTable(couponlis.ToList());//优惠券和订单集合
                    CouponFilter couponft2 = new CouponFilter();
                    System.Data.DataRow row2 = coctable.Rows[0];

                    if (row2["Id"].ToString() == String.Empty)//如果当前订单优惠券号为空则创建优惠券
                    {
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            teammodel = session.Teams.GetByID(Helper.GetInt(row["Team_id"], 0));
                        }

                        int Quantity = Helper.GetInt(row["Quantity"], 0);//购买数量
                        string tuanphone = "";
                        if (sysmodel != null)
                        {
                            tuanphone = sysmodel.tuanphone;
                        }
                        for (int j = 0; j < Quantity; j++)
                        {
                            ICoupon couponmodel = AS.GroupOn.App.Store.CreateCoupon();
                            couponmodel.Team_id = Helper.GetInt(row["Team_id"], 0);
                            couponmodel.Order_id = Helper.GetInt(row["id"], 0);
                            couponmodel.Type = "consume";
                            couponmodel.Credit = teammodel.Credit; //teammodel.Credit;
                            couponmodel.Consume = "N";
                            couponmodel.User_id = Helper.GetInt(row["User_id"], 0);
                            couponmodel.Create_time = DateTime.Now;
                            couponmodel.Expire_time = teammodel.Expire_time;
                            couponmodel.Partner_id = teammodel.Partner_id;
                            if (_system["couponlength"] != null && _system["couponlength"] != "")
                            {
                                int n = int.Parse(_system["couponlength"]);
                                couponmodel.Id = Helper.GetRandomString(n);//获取优惠券号码
                            }
                            else
                            {
                                couponmodel.Id = Helper.GetRandomString(12);//获取优惠券号码
                            }
                            couponmodel.Secret = Helper.GetRandomString(6);//获取优惠券密码
                            couponmodel.Sms = couponmodel.Sms + 1;
                            couponmodel.Sms_time = DateTime.Now;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int idd = session.Coupon.Insert(couponmodel);
                            }
                            List<string> mobile = new List<string>();
                            mobile.Add(row["mobile"].ToString());

                            IPartner partnermodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
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
                            string message = ReplaceStr("couponsms", values);

                            EmailMethod.SendSMS(mobile, message);
                            page = page + 1;
                        }
                    }
                    else //不为空则重复发送一遍
                    {

                        string tuanphone = "";
                        if (sysmodel != null)
                        {
                            tuanphone = sysmodel.tuanphone;
                        }
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            teammodel = session.Teams.GetByID(Helper.GetInt(row["Team_id"], 0));
                        }
                        ICoupon couponmodel = null;

                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            couponmodel = session.Coupon.GetByID(row2["Id"].ToString());
                        }

                        couponmodel.Sms = couponmodel.Sms + 1;
                        couponmodel.Sms_time = DateTime.Now;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int idd2 = session.Coupon.Update(couponmodel);
                        }
                        List<string> mobile = new List<string>();
                        mobile.Add(row["mobile"].ToString());
                        //string txt = "您好，你在" + ASSystem.abbreviation + "获得" + teammodel.Product + "的优惠券：" + couponmodel.Id + "密码: " + couponmodel.Secret + " 有效期至: " + couponmodel.Expire_time.ToString("yyyy年MM月dd日") + " 请及时使用";
                        //string txt = ASSystem.abbreviation + "项目：" + teammodel.Product + "，编号：" + couponmodel.Id + "，密码：" + couponmodel.Secret + "，有效期至：" + couponmodel.Expire_time.ToString("yyyy年MM月dd日");
                        IPartner partnermodel = null;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
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
                        string message = ReplaceStr("couponsms", values);

                        EmailMethod.SendSMS(mobile, message);
                        page = page + 1;

                    }
                    Response.Write(JsonUtils.GetJson("X.misc.noticesms(" + id + "," + (page - 1) + ");", "eval"));
                }

                else
                {
                    Response.Write(JsonUtils.GetJson("发送完毕", "alert"));
                    return;
                }
            }
        }
        else if ("noticesmssubscribe" == action)
        {
            IPagers<ISmssubscribe> pagers = null;
            ITeam myteam = null;
            SmssubscribeFilter smssft = new SmssubscribeFilter();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                myteam = session.Teams.GetByID(Helper.GetInt(id, 0));
            }

            int page = Helper.GetInt(nid, 0);
            if (page == 0)
                page = 1;
            else
            {
                if (page % 20 > 0)
                    page = page / 20 + 1;
                else
                    page = page / 20;
                page = page + 1;
            }
            if (page > 0)
            {
                smssft.City_id = myteam.City_id;
                if (Helper.GetInt(myteam.City_id, 0) == 0)
                {
                    smssft.Enable = "Y";
                }
                smssft.CurrentPage = page;
                smssft.PageSize = 20;
                smssft.AddSortOrder(SmssubscribeFilter.ID_ASC);
                if (Helper.GetInt(myteam.City_id, 0) == 0)
                {
                    smssft.Enable = "Y";
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    pagers = session.Smssubscribe.GetPager(smssft);
                }
                if (page > pagers.TotalPage)
                {
                    Response.Write(JsonUtils.GetJson("订阅短信发送完毕", "alert"));
                    return;
                }
                else
                {
                    System.Data.DataTable smstable = Helper.ToDataTable(pagers.Objects.ToList());

                    nid = ((pagers.CurrentPage - 1) * 20 + smstable.Rows.Count).ToString(); //(int.Parse(nid) + 1).ToString();

                    List<string> tomobiles = new List<string>();
                    for (int i = 0; i < smstable.Rows.Count; i++)
                    {
                        tomobiles.Add(smstable.Rows[i]["Mobile"].ToString());
                    }

                    NameValueCollection values = new NameValueCollection();
                    values.Add("网站简称", ASSystem.abbreviation);
                    values.Add("商品名称", myteam.Product);


                    string message = ReplaceStr("nowteam", values);

                    bool ok = EmailMethod.SendSMS(tomobiles, message);
                    //bool ok = SendSMS(tomobiles, ASSystemArr["sitename"] + "今日团购:" + myteam.Product);
                    if (ok)
                        Response.Write(JsonUtils.GetJson("X.misc.noticenextsms(" + id + "," + nid + ");", "eval"));
                    else
                        Response.Write(JsonUtils.GetJson("短信发送失败请检查设置", "alert"));

                    return;
                }
            }
        }
        else if ("noticesubscribe" == action)
        {


            if (Session["time"] == null)
            {
                Session.Add("time", DateTime.Now.AddMinutes(-10));
            }
            DateTime time = (DateTime)Session["time"];

            ITeam myteam = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                myteam = session.Teams.GetByID(Helper.GetInt(id, 0));
            }

            int interval = 0;
            if (ASSystem.mailinterval.HasValue)
            {
                interval = ASSystem.mailinterval.Value;
            }
            int page = Helper.GetInt(nid, 0);
            page = page + 1; //因为从零开始
            if (page > 0)
            {
                MailerFilter mailer = new MailerFilter();
                IList<IMailer> mailerlis = null;
                string strWhere = " 1=1 ";
                if (myteam != null && myteam.City_id != 0)
                {
                    mailer.City_id = myteam.City_id;
                }
                
                mailer.AddSortOrder(MailerFilter.ID_ASC);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mailerlis = session.Mailers.GetList(mailer);
                }
                if (page > mailerlis.Count)
                {
                    Response.Write(JsonUtils.GetJson("clearTimeout(outtime);alert('订阅邮件发送完毕');", "eval"));
                    return;
                }
                else
                {
                    System.Data.DataTable mailtable = Helper.ToDataTable(mailerlis.ToList());
                    TimeSpan ts = DateTime.Now - time;
                    int cid = int.Parse(nid);
                    nid = (cid + 1).ToString();
                    if (ts.Seconds - interval < 0)
                    {
                        System.Threading.Thread.Sleep((interval - ts.Seconds) * 1000);
                        List<string> tomails = new List<string>();
                        tomails.Add(mailtable.Rows[page-1]["Email"].ToString());
                        string sendemailerror = String.Empty;
                        bool ok = EmailMethod.SendMail(tomails, ASSystemArr["sitename"] + "今日团购:" + myteam.Product, WebUtils.LoadPageString(PageValue.WebRoot + "/template/default/mail_subscribe_team.aspx?mailid=" + mailtable.Rows[page-1]["id"] + "&teamid=" + myteam.Id), out sendemailerror);
                        Response.Write(JsonUtils.GetJson("X.misc.noticenext(" + id + "," + nid + ");", "eval"));
                    }
                    else
                    {
                        List<string> tomails = new List<string>();
                        string sendemailerror = String.Empty;
                        tomails.Add(mailtable.Rows[page - 1]["Email"].ToString());
                        bool ok = EmailMethod.SendMail(tomails, ASSystemArr["sitename"] + "今日团购:" + myteam.Product, WebUtils.LoadPageString(PageValue.WebRoot + "/template/default/mail_subscribe_team.aspx?mailid=" + mailtable.Rows[0]["id"] + "&teamid=" + myteam.Id), out sendemailerror);
                        Response.Write(JsonUtils.GetJson("X.misc.noticenext(" + id + "," + nid + ");", "eval"));
                    }
                    Session["time"] = DateTime.Now;
                    return;
                }
            }
        }

        else if (action == "teamcoupon")//自动发券
        {



            //nid=第几条
            //id项目id
            ITeam teamm = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teamm = session.Teams.GetByID(AS.Common.Utils.Helper.GetInt(id, 0));
            }

            if (teamm.Delivery == "pcoupon")
            {

                //1:得到下单项目的数量
                IOrder orderm = null;
                OrderFilter orderft = new OrderFilter();
                IList<IOrder> orderlis = null;
                string strOrdercount = "";
                orderft.State = "pay";
                orderft.Team_id = AS.Common.Utils.Helper.GetInt(id, 0);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    orderlis = session.Orders.GetList(orderft);
                }
                if (orderlis != null)
                {
                    foreach (IOrder item in orderlis)
                    {
                        strOrdercount += item.Quantity;
                    }
                }

                //2:得到已购买的站外券的数量
                string strPcouponCount = "0";
                IPcoupon pcouponm = null;
                IList<IPcoupon> pcoupponlis = null;
                PcouponFilter pcouponft = new PcouponFilter();
                pcouponft.teamid = AS.Common.Utils.Helper.GetInt(id, 0);
                pcouponft.state = "buy";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    pcoupponlis = session.Pcoupon.GetList(pcouponft);
                }

                if (pcoupponlis != null)
                {
                    strPcouponCount = pcoupponlis.Count.ToString();
                }

                //3：判断订单中的数量strOrdercount与站外券strPcouponCount的大小，strOrdercount>strPcouponCount,则需要自动发券
                if (Helper.GetInt(strOrdercount, 0) > Helper.GetInt(strPcouponCount, 0))
                {
                    //4：找出未发券的订单
                    if (orderlis != null)
                    {
                        foreach (IOrder item in orderlis)
                        {
                            string strUserId = item.User_id.ToString();
                            string strQuantity = item.Quantity.ToString();
                            int strOrderId = item.Id;
                            string strOrderMobile = item.Mobile.ToString();

                            //5:查询该订单已发的优惠券
                            PcouponFilter pcouponft2 = new PcouponFilter();
                            pcouponft2.state = "buy";
                            pcouponft2.orderid = strOrderId;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                pcoupponlis = session.Pcoupon.GetList(pcouponft2);
                            }
                            if (pcoupponlis != null)
                            {
                                if (pcoupponlis.Count > 0)
                                {
                                    int num = pcoupponlis.Count;
                                    if (Helper.GetInt(strQuantity, 0) > num)
                                    {

                                        //得到需要发送的站外券的数量
                                        int num_nobuy = int.Parse(strQuantity) - num;
                                        string tuanphone = "";
                                        if (sysmodel != null)
                                        {
                                            tuanphone = sysmodel.tuanphone;
                                        }
                                        pcouponft.state = "nobuy";
                                        pcouponft.teamid = AS.Common.Utils.Helper.GetInt(id, 0);
                                        pcouponft.Top = num_nobuy;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            pcoupponlis = session.Pcoupon.GetList(pcouponft);
                                        }
                                        if (pcoupponlis != null)
                                        {
                                            foreach (IPcoupon pcoupon in pcoupponlis )
                                            {
                                                IPartner partnermodel = null;
                                                using (IDataSession session  = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    partnermodel = session.Partners.GetByID(teamm.Partner_id);
                                                } 
                                                string partnername = "";
                                                string partnermobile = "";
                                                if (partnermodel != null)
                                                {
                                                    partnername = partnermodel.Title;
                                                    partnermobile = partnermodel.Phone;
                                                }
                                                //6：发送站外券
                                                NameValueCollection values = new NameValueCollection();
                                                values.Add("网站简称", ASSystem.abbreviation);
                                                values.Add("商品名称", teamm.Product);
                                                values.Add("商户优惠券", pcoupon.number);
                                                if (pcoupon.start_time != null && pcoupon.start_time.ToString() != "")
                                                {
                                                    values.Add("优惠券开始时间", DateTime.Parse(pcoupon.start_time.ToString()).ToString("yyyy年MM月dd日"));
                                                }
                                                if (pcoupon.expire_time != null && pcoupon.expire_time.ToString() != "")
                                                {
                                                    values.Add("优惠券结束时间", DateTime.Parse(pcoupon.expire_time.ToString()).ToString("yyyy年MM月dd日"));
                                                }
                                                values.Add("商户名称", partnername);
                                                values.Add("商户电话", partnermobile);
                                                values.Add("团购电话", tuanphone);
                                                string txt = ReplaceStr("bizcouponsms", values);
                                                List<string> phone = new List<string>();
                                                phone.Add(strOrderMobile);
                                                EmailMethod.SendSMS(phone, txt);

                                                //修改站外券状态
                                                IPcoupon pcoum = null;
                                                pcoum.id = pcoupon.id;
                                                pcoum.userid = pcoupon.userid;
                                                pcoum.orderid = strOrderId;
                                                pcoum.state = "buy ";
                                                using (IDataSession session =AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    int idd = session.Pcoupon.Update(pcoum);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                    }
                }

            }
            else
            {

                //得到当前项目未发送或发送未完的优惠券
                string tuanphone = "";
                if (sysmodel != null)
                {
                    tuanphone = sysmodel.tuanphone;
                }
                List<Hashtable> hs = new List<Hashtable>();
                string sql = "select * from (select * from (select id,quantity,isnull(num,0) as num,mobile,user_id  from [order] left join (select count(*) as num,order_id from coupon where team_id=" + id + " group by order_id)t on([order].id=[t].order_id) where team_id=" + id + " and state='pay')t where quantity>num)t  order by id asc";//优惠券和订单集合
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                   hs= session.GetData.GetDataList(sql);
                }
                for (int i = 0; i < hs.Count; i++)
                {
                    NameValueCollection _system = new NameValueCollection();
                    ISystem systemm = null;
                    _system = AS.Common.Utils.WebUtils.GetSystem();

                    IUser usermodel = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        usermodel = session.Users.GetByID(AS.Common.Utils.Helper.GetInt(hs[i]["user_id"],0));
                    }
                    ICoupon couponm = AS.GroupOn.App.Store.CreateCoupon();
                    int Quantity = Convert.ToInt32(hs[i]["Quantity"]);//购买数量
                    for (int j = Convert.ToInt32(hs[i]["num"]); j < Quantity; j++)
                    {
                        couponm.Team_id = Convert.ToInt32(id);
                        couponm.Order_id = Convert.ToInt32(hs[i]["id"]);
                        couponm.Type = "consume";
                        couponm.Credit = teamm.Credit; //teammodel.Credit;
                        couponm.Consume = "N";
                        couponm.User_id = Convert.ToInt32(hs[i]["User_id"]);
                        couponm.Create_time = DateTime.Now;
                        couponm.Expire_time = teamm.Expire_time;
                        couponm.Partner_id = teamm.Partner_id;
                        if (_system["couponlength"] != null && _system["couponlength"] != "")
                        {
                            int n = Helper.GetInt(_system["couponlength"],0);
                            couponm.Id = Helper.GetRandomString(n);//获取优惠券号码
                        }
                        else
                        {
                            couponm.Id = Helper.GetRandomString(12);//获取优惠券号码
                        }
                        couponm.Secret = Helper.GetRandomString(6);//获取优惠券密码
                        couponm.Sms = couponm.Sms + 1;
                        couponm.start_time = teamm.start_time;
                        couponm.Sms_time = DateTime.Now;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int coupid = session.Coupon.Insert(couponm);
                        }                        
                        List<string> mobile = new List<string>();
                        mobile.Add(usermodel.Mobile);
                        IPartner partnermodel = null;
                        using(IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            partnermodel = session.Partners.GetByID(teamm.Partner_id);
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
                        values.Add("商品名称", teamm.Product);
                        values.Add("券号", couponm.Id);
                        values.Add("密码", couponm.Secret);
                        values.Add("优惠券结束时间", couponm.Expire_time.ToString("yyyy年MM月dd日"));
                        if (couponm.start_time.Value != null && couponm.start_time.Value.ToString() != "")
                        {
                            values.Add("优惠券开始时间", couponm.start_time.Value.ToString("yyyy年MM月dd日"));
                        }
                        else
                        {
                            values.Add("优惠券开始时间", "");
                        }
                        values.Add("商户名称", partnername);
                        values.Add("商户电话", partnermobile);
                        values.Add("团购电话", tuanphone);
                        string message = ReplaceStr("couponsms", values);
                        EmailMethod. SendSMS(mobile, message);
                    }
                }
            }

            SetSuccess("自动发券完毕");
            return;

        }
    }    
    
</script>
