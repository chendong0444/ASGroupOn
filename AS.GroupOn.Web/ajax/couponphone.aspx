<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace=" System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public ICoupon couponmodel = null;
    public IPartner partnermodel = null;
    public ITeam teammodel = Store.CreateTeam();
    public IOrder ordermodel = null;
    public IUser usermodel = null;
    protected override void OnLoad(EventArgs e)
    {
        string action = Helper.GetString(Request["action"], String.Empty); //请求类型
        string secret = Helper.GetString(Request["secret"], String.Empty); //消费密码
        string verifymobile = Helper.GetString(Request["callerid"], String.Empty); //商家验证电话
        string result = String.Empty;//结果字符串
        string cid = Helper.GetString(Request["num"], String.Empty);//券号

        Response.ContentType = "text/xml";
        result = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n";
        if (action == "query")
        {
            //找出优惠券表中id字段为cid值的记录 a记录
            using (IDataSession session = Store.OpenSession(false))
            {
                couponmodel = session.Coupon.GetByID(cid);
            }
            //根据id为a记录中的Partner_id的字段的值 找出对应的商家 b记录
            if (couponmodel != null && couponmodel.Team != null)
            {
                partnermodel = couponmodel.Partner;
                //根据优惠券表的记录找出对应的项目
                teammodel = couponmodel.Team;
                //得到team表中优惠券的有效期 并格式化为 年月日

                string strpart = "";
                if (partnermodel != null)
                {
                    strpart = "商家：" + partnermodel.Title + "<br/>";
                }
                if (IsEnableCoupon(cid))
                { //如果优惠券已使用
                    result = result + "<coupon>\r\n	<result>1</result>\r\n	<id>" + teammodel.Id + "</id>\r\n	<product></product>\r\n	<price>" + teammodel.Team_price + "</price>\r\n</coupon>";
                }
                else
                {
                    if (isTime(couponmodel.Expire_time) == false)
                    { //如果使用时间小于今天日期
                        result = result + "<coupon>\r\n	<result>2</result>\r\n	<id>" + teammodel.Id + "</id>\r\n	<product></product>\r\n	<price>" + teammodel.Team_price + "</price>\r\n</coupon>";
                    }
                    else if (couponmodel.start_time.HasValue && getStart_time(couponmodel.start_time.Value))
                    {
                        //如果使用时间小于今天日期
                        result = result + "<coupon>\r\n	<result>2</result>\r\n	<id>" + teammodel.Id + "</id>\r\n	<product></product>\r\n	<price>" + teammodel.Team_price + "</price>\r\n</coupon>";
                    }
                    else
                    {
                        result = result + "<coupon>\r\n	<result>3</result>\r\n	<id>" + teammodel.Id + "</id>\r\n	<product></product>\r\n	<price>" + teammodel.Team_price + "</price>\r\n</coupon>";
                    }

                }
            }
            else
            {
                result = result + "<coupon>\r\n	<result>0</result>\r\n	<id>" + teammodel.Id + "</id>\r\n	<product></product>\r\n	<price>" + teammodel.Team_price + "</price>\r\n</coupon>";
            }

        }
        else if (action == "consume")
        {
            //找到id值为cid的优惠券记录
            CouponFilter cf = new CouponFilter();
            cf.Id = cid;
            cf.Secret = secret;
            using (IDataSession seion = Store.OpenSession(false))
            {
                couponmodel = seion.Coupon.Get(cf);
            }
            //找到商家
            if (couponmodel != null)
            {
                partnermodel = couponmodel.Partner;
                teammodel = couponmodel.Team;
                if (couponmodel.Secret.ToUpper() != secret.ToUpper())
                { //如果优惠券密码不等于sec

                    result = result + "<coupon>\r\n<result>false</result>\r\n</coupon>";
                }
                else if (isEnable(cid, couponmodel.Secret))
                {//如果优惠券已使用

                    result = result + "<coupon>\r\n<result>false</result>\r\n</coupon>";

                }
                else if (isTime(couponmodel.Expire_time) == false)
                { //优惠券到期时间小于今天 精确到日

                    result = result + "<coupon>\r\n<result>false</result>\r\n</coupon>";

                }
                else
                {
                   
                    if (couponmodel.start_time.HasValue && getStart_time(couponmodel.start_time.Value)) //如果优惠券不等于未使用
                    {
                        result = result + "<coupon>\r\n<result>false</result>\r\n</coupon>";
                    }
                    else
                    {
                        ICoupon icou = Store.CreateCoupon();
                        couponmodel.Id = cid;
                        couponmodel.Secret = couponmodel.Secret;
                        couponmodel.IP = WebUtils.GetClientIP;
                        couponmodel.Consume_time = DateTime.Now;
                        couponmodel.Consume = "Y";
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            seion.Coupon.UpCoupon(couponmodel);
                        }
                        //credit to user'money'
                        //更新优惠券 ip，使用时间 使用状态
                        //couponbll.updatebycid(cid, couponmodel.Secret, WebUtils.GetClientIP, DateTime.Now, "Y");

                        //更新分店消费信息
                        if (verifymobile != String.Empty)
                        {
                            string sql = "select  top 1 * from Branch where verifymobile=" + verifymobile;
                            List<Hashtable> hs = new List<Hashtable>();
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                hs = session.Custom.Query(sql);
                            }
                            //更新优惠券shoptype
                            if (hs.Count > 0 && Helper.GetInt(hs[0]["id"].ToString(), 0) > 0)
                            {
                                couponmodel.shoptypes = Helper.GetInt(hs[0]["id"].ToString(), 0);
                                using (IDataSession session = Store.OpenSession(false))
                                {
                                    session.Coupon.UpdateShoptypes(couponmodel);
                                }
                            }
                        }
                        CouponFilter coupon = new CouponFilter();
                        coupon.Id = cid;
                        coupon.Secret = couponmodel.Secret;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            couponmodel = seion.Coupon.Get(cf);
                        }
                        //写入消费记录表 
                        if (couponmodel.Credit > 0)
                        {
                            IFlow flowmodel = Store.CreateFlow();
                            flowmodel.User_id = couponmodel.User_id;
                            flowmodel.Detail_id = couponmodel.Id;
                            flowmodel.Direction = "income";
                            flowmodel.Money = couponmodel.Credit;
                            flowmodel.Action = "coupon";
                            flowmodel.Create_time = DateTime.Now;
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                session.Flow.Insert(flowmodel);
                            }
                            Updatemoney(couponmodel.User_id, couponmodel.Credit, couponmodel.User.Money); //如果用户的余额可以支付，那么修改用户里面的余额并跳转到支付成功页面

                        }
                        //修改用户表的里面的账户余额
                        //result = result+"<coupon>\r\n<result>true</result>\r\n<product>" + teammodel.Product + "</product>\r\n<price>" + teammodel.Team_price + "</price>\r\n</coupon>";
                        result = result + "<coupon>\r\n<result>true</result>\r\n</coupon>";

                        if (PageValue.CurrentSystemConfig["opencoupon"] == "1")//开启优惠券打印提醒
                        {
                            #region 发送短信
                            List<string> phone = new List<string>();
                            if (ordermodel != null)
                            {
                                if (couponmodel.User != null)
                                {
                                    phone.Add(couponmodel.User.Mobile);

                                    //优惠券消费提醒
                                    NameValueCollection values = new NameValueCollection();
                                    values.Add("网站简称", ASSystem.abbreviation);
                                    values.Add("用户名", couponmodel.User.Username);
                                    values.Add("券号", couponmodel.Id);
                                    values.Add("消费时间", couponmodel.Consume_time.ToString());


                                    string message = ReplaceStr("consumption", values);

                                    EmailMethod.SendSMS(phone, message);
                                    //提示尊敬的{网站简称}用户{用户名}您的券号{券号}已于{消费时间}被消费。
                                }
                            }
                            #endregion
                        }
                    }
                 
                }
            }
            else
            {
                result = result + "<coupon>\r\n<result>false</result>\r\n</coupon>";
            }

        }
        Response.Write(result);
        Response.End();

    }
    /// <summary>
    /// 修改用户余额
    /// </summary>
    /// <param name="userid">ID</param>
    /// <param name="summoeny">余额</param>
    /// <param name="yumongy">+ -金额</param>
    public void Updatemoney(int userid, decimal summoeny, decimal yumongy)
    {
        decimal result = yumongy + summoeny;

        if (result < 0)
        {
            result = 0;
        }

        IUser uer = Store.CreateUser();
        uer.Money = result;
        uer.Id = userid;
        using (IDataSession seion = Store.OpenSession(false))
        {
            seion.Users.UpdateMoney(uer);
        }
    }
    public bool isTime(DateTime Consume_time)
    {
        if (Convert.ToDateTime(Consume_time.ToString("yyyy-MM-dd 23:59:59")) > DateTime.Now)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    public bool getStart_time(DateTime start_time)
    {
        bool result = false;
        if (start_time >= DateTime.Now)
            //优惠券的使用时间已到
            result = true;
        return result;
    }
    public bool isEnable(string id, string secret)
    {
        ICoupon couponmodel = Store.CreateCoupon();
        CouponFilter cf = new CouponFilter();
        cf.Id = id;
        cf.Secret = secret;
        using (IDataSession seion = Store.OpenSession(false))
        {
            couponmodel = seion.Coupon.Get(cf);
        }

        if (couponmodel != null)
        {
            if (couponmodel.Consume == "Y")//已使用
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        else
        {
            return false;
        }

    }
    /// <summary>
    /// 判断优惠券是否有效
    /// </summary>
    /// <param name="cid">券号</param>
    /// <returns>false:未消费 true:已消费</returns>
    private bool IsEnableCoupon(string cid)
    {
        bool isenable = false;
        if (cid != "")
        {
            string sql = "select count(*) as sum FROM Coupon where Consume='N' and Id='" + cid + "' ";
            List<Hashtable> hs = new List<Hashtable>();
            using (IDataSession session = Store.OpenSession(false))
            {
                hs = session.Custom.Query(sql);
            }
            if (hs.Count > 0 && Helper.GetInt(hs[0]["sum"].ToString(), 0) > 0)
            {
                isenable = false;
            }
            else
            {
                isenable = true;
            }
        }
        return isenable;

    }
</script>
