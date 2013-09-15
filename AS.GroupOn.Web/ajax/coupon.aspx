<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace=" System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
     
    public IUser usermodel = Store.CreateUser();
    public ICoupon couponmodel = Store.CreateCoupon();
    public IOrder ordermodel = Store.CreateOrder();
    public IPartner partnermodel = Store.CreatePartner();
    public ITeam teammodel = Store.CreateTeam();
    public IBranch branchmodel = Store.CreateBranch();
    public IUser uimodel = Store.CreateUser();
    public System.Collections.Generic.IList<IBranch> listbranch = null;
    public System.Collections.Generic.IList<ICoupon> listcoupon = null;
    private NameValueCollection _system = new NameValueCollection();
    string result = String.Empty;
    public string res = "0";
    protected int orderid = 0;
    protected int detailid = 0;
    IProduct productmodel = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {


        _system = WebUtils.GetSystem();
        string action = Helper.GetString(Request["action"], String.Empty);
        int teamid = Helper.GetInt(Request["teamid"], 0);
        string cid = Helper.GetString(Request["id"], String.Empty);
        string shangjiasec = Helper.GetString(Request["shangjiasecret"], String.Empty);
        string shownum = Helper.GetString(Request["shownum"], String.Empty);
        int count = Helper.GetInt(Request["count"], 0);
        orderid = Helper.GetInt(Request["orderid"], 0);
        detailid = Helper.GetInt(Request["detailid"], 0);
        string sec = Helper.GetString(Request["secret"], String.Empty);
        string html = String.Empty;
        if (action == "shopcar")
        {
            
                html = WebUtils.LoadPageString(PageValue.WebRoot + "ajaxpage/ajax_dialog_shopcar.aspx?ty=jd&teamid=" + teamid + "&count=" + count + "&result=" + Request["result"] + "");
               Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
            return;
        }
        else if (action == "buy")
        {

            html = WebUtils.LoadPageString(PageValue.WebRoot + "ajaxpage/ajax_dialog_buy.aspx?teamid=" + teamid + "&count=" + count + "&result=" + Request["result"] + "");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
            return;   
        }
        else if ("card" == action)
        {
            html = WebUtils.LoadPageString(WebRoot + "ajaxpage/ajax_dialog_shopcard.aspx?order_id=" + orderid + "&detailid=" + detailid + "&ty=" + Request["ty"]);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
            return;
        }
        else if (action == "bizdialog")
        {
            html = WebUtils.LoadPageString(PageValue.WebRoot + "ajaxpage/ajax_dialog_bizcoupon.aspx");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "sign")
        {
            html = WebUtils.LoadPageString(WebRoot + "ajaxpage/ajax_dialog_sign.aspx");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "signlogin")
        {
            int userid = detailid;
            string resultsign = "恭喜签到成功，成功领取";
            //签到送积分和金额
            using (IDataSession session=Store.OpenSession(false))
            {
                uimodel = session.Users.GetByID(userid);
            }

            if (uimodel != null)
            {
                bool ss = uimodel.Sign_time.HasValue;
                //判断是否是当天第一次登录
                if (!uimodel.Sign_time.HasValue || (uimodel.Sign_time.HasValue && uimodel.Sign_time.Value.Date != DateTime.Now.Date))
                {
                    int ires = 0; //标志签到奖励金额
                    int type = 0; //标志签到的积分
                    if (WebUtils.config["loginmoney"] != null && WebUtils.config["loginmoney"].ToString() != "" && WebUtils.config["loginmoney"].ToString() != "0")
                    {
                        uimodel.Money = uimodel.Money + decimal.Parse(WebUtils.config["loginmoney"].ToString());
                        ires = 1;

                        resultsign = resultsign + WebUtils.config["loginmoney"].ToString() + "元";
                    }
                    if (WebUtils.config["loginscore"] != null && WebUtils.config["loginscore"].ToString() != "" && WebUtils.config["loginscore"].ToString() != "0")
                    {
                        uimodel.userscore = uimodel.userscore + int.Parse(WebUtils.config["loginscore"].ToString());
                        type = 1;
                        resultsign = resultsign + WebUtils.config["loginscore"].ToString() + "积分";
                    }
                    if (ires == 1 || type == 1)
                    {
                        uimodel.Sign_time = DateTime.Now;
                        using (IDataSession session=Store.OpenSession(false))
                        {
                            session.Users.Update(uimodel);
                        }
                        //金额消费记录
                        if (ires == 1)
                        {
                            IFlow flowmodel = Store.CreateFlow();
                            flowmodel.Direction = "income";
                            flowmodel.Money = decimal.Parse(WebUtils.config["loginmoney"].ToString());
                            flowmodel.Detail_id = "0";
                            flowmodel.User_id = userid;
                            flowmodel.Create_time = DateTime.Now;
                            flowmodel.Action = "sign";
                            using (IDataSession session=Store.OpenSession(false))
                            {
                                session.Flow.Insert(flowmodel);
                            }
                        }

                        //积分消费记录
                        if (type == 1)
                        {
                            IScorelog scoremodel = Store.CreateScorelog();
                            scoremodel.action = "签到";
                            scoremodel.score = int.Parse(WebUtils.config["loginscore"].ToString());
                            scoremodel.user_id = userid;
                            scoremodel.adminid = 0;
                            scoremodel.create_time = DateTime.Now;
                            scoremodel.key = "0";
                            using (IDataSession session=Store.OpenSession(false))
                            {
                                session.Scorelog.Insert(scoremodel);
                            }
                        }
                        Response.Write(JsonUtils.GetJson("alert('" + resultsign + "');location.reload();", "eval"));
                        Response.End();
                        return;
                    }
                }

            }
        }

        else if (action == "dialog")
        {
            html = WebUtils.LoadPageString(PageValue.WebRoot + "ajaxpage/ajax_dialog_coupon.aspx");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }


        else if (action == "query")
        {
            //找出优惠券表中id字段为cid值的记录 a记录
            CouponFilter cf = new CouponFilter();
            cf.Id = cid;
            using (IDataSession seion = Store.OpenSession(false))
            {
                couponmodel = seion.Coupon.Get(cf);
            }

            //根据id为a记录中的Partner_id的字段的值 找出对应的商家 b记录
            if (couponmodel != null)
            {

                PartnerFilter pf = new PartnerFilter();
                pf.Id = couponmodel.Partner_id;

                using (IDataSession seion = Store.OpenSession(false))
                {
                    partnermodel = seion.Partners.Get(pf);
                }

                //根据优惠券表的记录找出对应的项目

                TeamFilter tf = new TeamFilter();
                tf.Id = couponmodel.Team_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    teammodel = seion.Teams.Get(tf);
                }

                //得到team表中优惠券的有效期 并格式化为 年月日

                string strpart = "";
                if (partnermodel != null)
                {
                    strpart = "商家：" + partnermodel.Title + "<br/>";
                }

                CouponFilter cof = new CouponFilter();
                cof.Id = cid;
                cof.Consume = "N";
                int noconsumenum = 0;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    noconsumenum = seion.Coupon.GetCount(cof);
                }

                if (noconsumenum <= 0)
                { //如果优惠券已使用
                    result = strpart + "券号：[" + couponmodel.Id + "]" + "无效";
                    result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                    result = result + "<br>该优惠券已消费";
                }
                else
                {
                    if (isTime(couponmodel.Expire_time) == false)
                    { //如果使用时间小于今天日期
                        result = strpart + "券号：[" + cid + "]&nbsp;已过期";
                        result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                        result = result + "<br>" + "过期日期：" + "[" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                    }
                    else if (couponmodel.start_time.HasValue && getStart_time(couponmodel.start_time.Value))
                    {
                        //如果使用时间小于今天日期
                        result = strpart + " 券号：[" + cid + "]&nbsp;未开始";
                        result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                        result = result + "<br>" + "有效期：" + "[" + couponmodel.start_time.Value.ToString("yyyy-MM-dd") + "至" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                    }
                    else
                    {
                        res = "1";
                        result = strpart + " 券号：[" + cid + "]&nbsp;有效(" + noconsumenum + ")";
                        result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                        result = result + "<br>" + "有效期：[";
                        if (couponmodel.start_time.HasValue)
                            result = result + couponmodel.start_time.Value.ToString("yyyy-MM-dd");
                        result = result + "至" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                    }

                }
            }
            else
            {
                result = "#[" + cid + "]&nbsp;无效";
            }
            OrderedDictionary list = new OrderedDictionary();
            list.Add("html", result);

            list.Add("id", "coupon-dialog-display-id");
            if (res == "1")
            {
                //$(\"#coupon-dialog-query\").hide();
                //根据总店ID查询是否存在分店
                BranchFilter bf = new BranchFilter();
                bf.partnerid = couponmodel.Partner_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    branchmodel = seion.Branch.Get(bf);
                }

                if (branchmodel != null)
                {
                    string str = "";
                    str = str + "<option value=\"0\">总店</option>";

                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        listbranch = seion.Branch.GetList(bf);
                    }

                    foreach (IBranch br in listbranch)
                    {
                        str = str + "<option value=\"" + br.id + "\">" + br.branchname + "</option>";
                    }
                    str = str + "";

                    Response.Write(JsonUtils.GetJson("$('#selectid').html('" + str + "');$('#coupon-dialog-display-id').html('" + result + "');$(\"[vname='couponid']\").hide();$(\"#coupon-dialog-query\").hide();$(\"#couponbranch\").show();$(\"[vname='couponpwd']\").show();$(\"[vname='shanghupwd']\").show();$(\"#coupon-dialog-consume\").show(); $(\"#coupon_dialog_back\").show();", "eval"));

                }

                else
                {
                    Response.Write(JsonUtils.GetJson("$('#coupon-dialog-display-id').html('" + result + "');$(\"[vname='couponid']\").hide();$(\"#coupon-dialog-query\").hide();$(\"[vname='couponpwd']\").show();$(\"#coupon-dialog-consume\").show();$(\"#coupon_dialog_back\").show();", "eval"));
                }
            }
            else
            {
                Response.Write(JsonUtils.GetJson("$('#coupon-dialog-display-id').html('" + result + "');", "eval"));
            }
        }
        else if (action == "bizquery")
        {
            //找出优惠券表中id字段为cid值的记录 a记录

            CouponFilter cf = new CouponFilter();
            cf.Id = cid;
            using (IDataSession seion = Store.OpenSession(false))
            {
                couponmodel = seion.Coupon.Get(cf);
            }

            //根据id为a记录中的Partner_id的字段的值 找出对应的商家 b记录
            if (couponmodel != null)
            {

                string strUrl = Request.UrlReferrer.AbsoluteUri;
                if (strUrl.IndexOf("/biz/") > 0)
                {


                    string strPartnerID = CookieUtils.GetCookieValue("partner",key).ToString();
                    if (strPartnerID == couponmodel.Partner_id.ToString())
                    {
                        PartnerFilter pf = new PartnerFilter();
                        pf.Id = couponmodel.Partner_id;

                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            partnermodel = seion.Partners.Get(pf);
                        }
                        //根据优惠券表的记录找出对应的项目
                        TeamFilter tf = new TeamFilter();
                        tf.Id = couponmodel.Team_id;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            teammodel = seion.Teams.Get(tf);
                        }

                        //得到team表中优惠券的有效期 并格式化为 年月日

                        string strpart = "";
                        if (partnermodel != null)
                        {
                            strpart = "商家：" + partnermodel.Title + "<br/>";
                        }

                        CouponFilter cof = new CouponFilter();
                        cof.Id = cid;
                        cof.Consume = "N";
                        int noconsumenum = 0;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            noconsumenum = seion.Coupon.GetCount(cof);
                        }

                        if (noconsumenum <= 0)
                        { //如果优惠券已使用
                            result = strpart + "券号：[" + couponmodel.Id + "]" + "无效";
                            result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                            result = result + "<br>该优惠券已消费";
                        }
                        else
                        {
                            if (isTime(couponmodel.Expire_time) == false)
                            { //如果使用时间小于今天日期
                                result = strpart + "券号：[" + cid + "]&nbsp;已过期";
                                result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                                result = result + "<br>" + "过期日期：" + "[" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                            }
                            else if (couponmodel.start_time.HasValue && getStart_time(couponmodel.start_time.Value))
                            {
                                //如果使用时间小于今天日期
                                result = strpart + " 券号：[" + cid + "]&nbsp;未开始";
                                result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                                result = result + "<br>" + "有效期：" + "[" + couponmodel.start_time.Value.ToString("yyyy-MM-dd") + "至" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                            }
                            else
                            {
                                res = "1";
                                result = strpart + " 券号：[" + cid + "]&nbsp;有效";
                                result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                                result = result + "<br>" + "有效期：[";
                                if (couponmodel.start_time.HasValue)
                                    result = result + couponmodel.start_time.Value.ToString("yyyy-MM-dd");
                                result = result + "至" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                            }

                        }
                    }
                    else
                    {
                        result = "该券不属于该商户！！";
                    }
                }
                else
                {

                    PartnerFilter pf = new PartnerFilter();
                    pf.Id = couponmodel.Partner_id;

                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        partnermodel = seion.Partners.Get(pf);
                    }

                    //根据优惠券表的记录找出对应的项目
                    TeamFilter tf = new TeamFilter();
                    tf.Id = couponmodel.Team_id;
                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        teammodel = seion.Teams.Get(tf);
                    }

                    //得到team表中优惠券的有效期 并格式化为 年月日

                    string strpart = "";
                    if (partnermodel != null)
                    {
                        strpart = "商家：" + partnermodel.Title + "<br/>";
                    }
                    CouponFilter cof = new CouponFilter();
                    cof.Id = cid;
                    cof.Consume = "N";
                    int noconsumenum = 0;
                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        noconsumenum = seion.Coupon.GetCount(cof);
                    }

                    if (noconsumenum <= 0)
                    { //如果优惠券已使用
                        result = strpart + "券号：[" + couponmodel.Id + "]" + "无效";
                        result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                        result = result + "<br>该优惠券已消费";
                    }
                    else
                    {
                        if (isTime(couponmodel.Expire_time) == false)
                        { //如果使用时间小于今天日期
                            result = strpart + "券号：[" + cid + "]&nbsp;已过期";
                            result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                            result = result + "<br>" + "过期日期：" + "[" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                        }
                        else if (couponmodel.start_time.HasValue && getStart_time(couponmodel.start_time.Value))
                        {
                            //如果使用时间小于今天日期
                            result = strpart + " 券号：[" + cid + "]&nbsp;未开始";
                            result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                            result = result + "<br>" + "有效期：" + "[" + couponmodel.start_time.Value.ToString("yyyy-MM-dd") + "至" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                        }
                        else
                        {
                            res = "1";
                            result = strpart + " 券号：[" + cid + "]&nbsp;有效";
                            result = result + "<br>项目：" + "[" + teammodel.Product + "]";
                            result = result + "<br>" + "有效期：[";
                            if (couponmodel.start_time.HasValue)
                                result = result + couponmodel.start_time.Value.ToString("yyyy-MM-dd");
                            result = result + "至" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                        }

                    }
                }
            }
            else
            {
                result = "#[" + cid + "]&nbsp;无效";
            }

            OrderedDictionary list = new OrderedDictionary();
            list.Add("html", result);

            list.Add("id", "coupon-dialog-display-bizid");
            if (res == "1")
            {
                //$(\"#coupon-dialog-query\").hide();
                //根据总店ID查询是否存在分店
                BranchFilter bf = new BranchFilter();
                bf.partnerid = couponmodel.Partner_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    branchmodel = seion.Branch.Get(bf);
                }

                if (branchmodel != null)
                {
                    string str = "";
                    str = str + "<option value=\"0\">总店</option>";

                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        listbranch = seion.Branch.GetList(bf);
                    }

                    foreach (IBranch br in listbranch)
                    {
                        str = str + "<option value=\"" + br.id + "\">" + br.branchname + "</option>";
                    }
                    str = str + "";

                    Response.Write(JsonUtils.GetJson("$('#selectid').html('" + str + "');$('#coupon-dialog-display-bizid').html('" + result + "');$(\"[vname='bizcouponid']\").hide();$(\"#coupon-dialog-bizquery\").hide();$(\"[vname='bizcouponpwd']\").show();$(\"#coupon-dialog-bizconsume\").show(); $(\"#bizcouponbranch\").show();$(\"[vname='bizshanghupwd']\").show();$(\"#coupon_dialog_bizback\").show();", "eval"));
                }
                else
                {

                    Response.Write(JsonUtils.GetJson("$('#coupon-dialog-display-bizid').html('" + result + "');$(\"[vname='bizcouponid']\").hide();$(\"#coupon-dialog-bizquery\").hide();$(\"[vname='bizcouponpwd']\").show();$(\"#coupon-dialog-bizconsume\").show();$(\"#coupon_dialog_bizback\").show();", "eval"));
                }

            }
            else
            {
                Response.Write(JsonUtils.GetJson("$('#coupon-dialog-display-bizid').html('" + result + "');", "eval"));
            }
        }
        else if (action == "consume")
        {
            int id = Helper.GetInt(Request["selectpart"], 0);
            //找到id值为cid的优惠券记录
            CouponFilter cf = new CouponFilter();
            cf.Id = cid;
            cf.Secret = sec;
            using (IDataSession seion = Store.OpenSession(false))
            {
                couponmodel = seion.Coupon.Get(cf);
            }
            //通过传入的id获取密码
            IBranch br = Store.CreateBranch();
            BranchFilter bf = new BranchFilter();
            bf.id = id;
            if (id != 0)
            {
                using (IDataSession seion = Store.OpenSession(false))
                {
                    br = seion.Branch.Get(bf);
                }
            }
            //找到商家
            if (couponmodel != null)
            {
                PartnerFilter pf = new PartnerFilter();
                pf.Id = couponmodel.Partner_id;

                using (IDataSession seion = Store.OpenSession(false))
                {
                    partnermodel = seion.Partners.Get(pf);
                }
                //找到项目
                BranchFilter brf = new BranchFilter();
                brf.partnerid = couponmodel.Partner_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    branchmodel = seion.Branch.Get(brf);
                }
                TeamFilter tf = new TeamFilter();
                tf.Id = couponmodel.Team_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    teammodel = seion.Teams.Get(tf);
                }

                if (couponmodel.Secret.ToUpper() != sec.ToUpper())
                { //如果优惠券密码不等于sec
                    result = result + "<br>" + "[" + cid + "]" + "编号密码不正确";
                    result = result + "<br>本次消费失败";
                }
                else if (isEnable(cid, couponmodel.Secret))
                {//如果优惠券已使用
                    result = result + "<br>#[" + cid + "]&nbsp;已消费";
                    result = result + "<br>消费于：" + "[" + couponmodel.Consume_time + "]";
                    result = result + "<br>本次消费失败";
                }
                else if (isTime(couponmodel.Expire_time) == false)
                { //优惠券到期时间小于今天 精确到日
                    result = "#[" + cid + "]&nbsp;已过期";
                    result = result + "<br>过期时间：" + "[" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                    result = result + "<br>本次消费失败";
                }
                else if (branchmodel != null && (br == null && id != 0))
                {//有分店但是没有选择
                    result = result + "<br>" + "[" + cid + "]" + "请选择所在店铺";
                    result = result + "<br>本次消费失败";
                }
                else if (branchmodel != null && id > 0 && br.secret.ToUpper() != shangjiasec.ToUpper())
                {//分店消费密码不正确
                    result = result + "<br>" + "[" + cid + "]" + "商家密码不正确";
                    result = result + "<br>本次消费失败";
                }
                else if (branchmodel != null && id == 0 && partnermodel != null && partnermodel.Secret.ToUpper() != shangjiasec.ToUpper())
                {//总店消费密码不正确
                    result = result + "<br>" + "[" + cid + "]" + "商家密码不正确";
                    result = result + "<br>本次消费失败";
                }
                else
                {
                    #region
                    if (couponmodel.start_time.HasValue && getStart_time(couponmodel.start_time.Value)) //如果优惠券不等于未使用
                    {
                        //如果使用时间小于今天日期
                        result = "#[" + cid + "]&nbsp;未开始";
                        result = result + "<br>" + "有效期：" + "[" + couponmodel.start_time.Value.ToString("yyyy-MM-dd") + "至" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                    }
                    else
                    {

                        //credit to user'money'
                        //更新优惠券 ip，使用时间 使用状态
                        ICoupon icou = Store.CreateCoupon();
                        icou.Id = cid;
                        icou.Secret = couponmodel.Secret;
                        icou.IP = WebUtils.GetClientIP;
                        icou.Consume_time = DateTime.Now;
                        icou.Consume = "Y";
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            seion.Coupon.UpCoupon(icou);
                        }
                        //更新优惠券shoptype
                        if (branchmodel != null && id != 0)
                        {
                            icou.shoptypes = id;

                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                seion.Coupon.UpdateShoptypes(icou);
                            }

                        }
                        //写入消费记录表 

                        OrderFilter of = new OrderFilter();
                        of.Id = couponmodel.Order_id;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            ordermodel = seion.Orders.Get(of);
                        }

                        if (couponmodel.Credit > 0)
                        {

                            IFlow flowmodel = Store.CreateFlow();
                            flowmodel.User_id = couponmodel.User_id;
                            flowmodel.Detail_id = couponmodel.Id;
                            flowmodel.Direction = "income";
                            flowmodel.Money = couponmodel.Credit;
                            flowmodel.Action = "coupon";
                            flowmodel.Create_time = DateTime.Now;
                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                seion.Flow.Insert(flowmodel);
                            }
                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                usermodel = seion.Users.GetByID(couponmodel.User_id);
                            }
                            if (usermodel != null)
                            {
                                Updatemoney(couponmodel.User_id, couponmodel.Credit, usermodel.Money); //如果用户的余额可以支付，那么修改用户里面的余额并跳转到支付成功页面
                            }

                        }

                        CouponFilter couf = new CouponFilter();
                        couf.Id = cid;
                        couf.Secret = couponmodel.Secret;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            listcoupon = seion.Coupon.GetList(couf);
                        }

                        //修改用户表的里面的账户余额
                        result = "【" + cid + "】" + "有效";
                        if (listcoupon != null && listcoupon.Count > 0)
                        {
                            result = result + "<br>消费时间：" + "【" + listcoupon[0].Consume_time + "】";
                        }
                        result = result + "本次消费成功";

                        if (_system != null)
                        {
                            if (_system["opencoupon"] != null)
                            {
                                if (_system["opencoupon"] == "1")//开启优惠券打印提醒
                                {
                                    #region 发送短信
                                    System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
                                    if (ordermodel != null)
                                    {
                                        if (ordermodel.Mobile != "")
                                        {
                                            phone.Add(ordermodel.Mobile);
                                        }
                                        else
                                        {
                                            if (usermodel != null)
                                            {
                                                phone.Add(usermodel.Mobile);
                                            }
                                        }

                                        //优惠券消费提醒
                                        NameValueCollection values = new NameValueCollection();
                                        values.Add("网站简称", ASSystem.abbreviation);
                                        if (usermodel != null)
                                        {
                                            values.Add("用户名", usermodel.Username);

                                        }
                                        else
                                        {
                                            values.Add("用户名", "");
                                        }

                                        values.Add("券号", couponmodel.Id);
                                        values.Add("消费时间", couponmodel.Consume_time.ToString());

                                        string message = ReplaceStr("consumption", values);

                                        EmailMethod.SendSMS(phone, message);
                                        //提示尊敬的{网站简称}用户{用户名}您的券号{券号}已于{消费时间}被消费。

                                    }
                                    #endregion
                                }
                            }
                        }
                    }
                    #endregion
                }
            }
            else
            {
                result = "#[" + cid + "]&nbsp;无效";
                result = result + "<br>本次消费失败";
            }
            OrderedDictionary list = new OrderedDictionary();
            list.Add("html", result);
            list.Add("id", "coupon-dialog-display-id");
            Response.Write(JsonUtils.GetJson(list, "updater"));
        }
        else if (action == "consume2")
        {
            int id = Helper.GetInt(Request["selectpart"], 0);

            //找到id值为cid的优惠券记录

            using (IDataSession seion = Store.OpenSession(false))
            {
                couponmodel = seion.Coupon.GetByID(cid);
            }


            //通过传入的id获取密码
            IBranch br = Store.CreateBranch();
            BranchFilter bf = new BranchFilter();
            bf.id = id;
            if (id != 0)
            {
                using (IDataSession seion = Store.OpenSession(false))
                {
                    br = seion.Branch.Get(bf);
                }
            }
            //找到商家
            if (couponmodel != null)
            {
                PartnerFilter pf = new PartnerFilter();
                pf.Id = couponmodel.Partner_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    partnermodel = seion.Partners.Get(pf);
                }
                //找到项目
                BranchFilter brf = new BranchFilter();
                brf.partnerid = couponmodel.Partner_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    branchmodel = seion.Branch.Get(brf);
                }
                TeamFilter tf = new TeamFilter();
                tf.Id = couponmodel.Team_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    teammodel = seion.Teams.Get(tf);
                }

                if (isTime(couponmodel.Expire_time) == false)
                { //优惠券到期时间小于今天 精确到日
                    result = "#[" + cid + "]&nbsp;已过期";
                    result = result + ",过期时间：" + "[" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                    result = result + ",本次消费失败";
                }
                else if (branchmodel != null && (br == null && id != 0))
                {//有分店但是没有选择
                    result = result + "<br>" + "[" + cid + "]" + "请选择所在店铺";
                    result = result + ",本次消费失败";
                }

                else
                {
                    #region
                    if (couponmodel.start_time.HasValue && getStart_time(couponmodel.start_time.Value)) //如果优惠券不等于未使用
                    {
                        //如果使用时间小于今天日期
                        result = "#[" + cid + "]&nbsp;未开始";
                        result = result + "<br>" + "有效期：" + "[" + couponmodel.start_time.Value.ToString("yyyy-MM-dd") + "至" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                    }
                    else
                    {
                        string[] secret = sec.Split(',');
                        string[] num = shownum.Split(',');
                        if (sec.Replace(",", "") != "")
                        {
                            result = result + "<br>当前优惠券号码：" + cid + "<br>";
                            for (int i = 0; i < secret.Length - 1; i++)
                            {
                                if (secret[i].ToString() != "")
                                {
                                    CouponFilter cf = new CouponFilter();
                                    cf.Id = cid;
                                    cf.Secret = secret[i].ToString();
                                    using (IDataSession seion = Store.OpenSession(false))
                                    {
                                        couponmodel = seion.Coupon.Get(cf);
                                    }

                                    string consumeorno = "";
                                    string consumetime = "";
                                    if (couponmodel != null)
                                    {
                                        consumeorno = couponmodel.Consume;
                                        consumetime = couponmodel.Consume_time.ToString();
                                    }
                                    if (branchmodel != null && id > 0 && br.secret.ToUpper() != shangjiasec.ToUpper())
                                    {//分店消费密码不正确
                                        result = result + "<br>商家密码不正确";
                                        result = result + ",本次消费失败";
                                        OrderedDictionary list1 = new OrderedDictionary();
                                        list1.Add("html", result);
                                        list1.Add("id", "coupon-dialog-display-id");
                                        Response.Write(JsonUtils.GetJson(list1, "updater"));
                                        return;
                                    }
                                    else if (branchmodel != null && id == 0 && partnermodel != null && partnermodel.Secret.ToUpper() != shangjiasec.ToUpper())
                                    {//总店消费密码不正确
                                        result = result + "<br>商家密码不正确";
                                        result = result + ",本次消费失败";
                                        OrderedDictionary list2 = new OrderedDictionary();
                                        list2.Add("html", result);
                                        list2.Add("id", "coupon-dialog-display-id");
                                        Response.Write(JsonUtils.GetJson(list2, "updater"));
                                        return;
                                    }
                                    if (!Exists(cid, secret[i].ToUpper()))
                                    { //优惠券密码是否存在
                                        result = result + "<br>密码" + num[i] + ":[" + secret[i] + "]" + "不正确";
                                    }
                                    else if (consumeorno == "Y")
                                    {//如果优惠券已使用
                                        result = result + "<br>密码" + num[i] + ":[" + secret[i] + "]&nbsp;已消费";
                                        result = result + ",消费于：" + "[" + consumetime + "]";
                                    }
                                    else
                                    {
                                        //credit to user'money'
                                        //更新优惠券 ip，使用时间 使用状态
                                        ICoupon icou = Store.CreateCoupon();
                                        icou.Id = cid;
                                        icou.Secret = couponmodel.Secret;
                                        icou.IP = WebUtils.GetClientIP;
                                        icou.Consume_time = DateTime.Now;
                                        icou.Consume = "Y";
                                        using (IDataSession seion = Store.OpenSession(false))
                                        {
                                            seion.Coupon.UpCoupon(icou);
                                        }

                                        //更新优惠券shoptype
                                        if (branchmodel != null && id != 0)
                                        {
                                            icou.shoptypes = id;

                                            using (IDataSession seion = Store.OpenSession(false))
                                            {
                                                seion.Coupon.UpdateShoptypes(icou);
                                            }

                                        }

                                        //写入消费记录表 

                                        CouponFilter cof = new CouponFilter();
                                        cof.Id = cid;
                                        cof.Secret = couponmodel.Secret;

                                        using (IDataSession seion = Store.OpenSession(false))
                                        {
                                            couponmodel = seion.Coupon.Get(cof);
                                        }
                                        OrderFilter of = new OrderFilter();
                                        of.Id = couponmodel.Order_id;
                                        using (IDataSession seion = Store.OpenSession(false))
                                        {
                                            ordermodel = seion.Orders.Get(of);
                                        }

                                        if (couponmodel.Credit > 0)
                                        {

                                            IFlow flowmodel = Store.CreateFlow();
                                            flowmodel.User_id = couponmodel.User_id;
                                            flowmodel.Detail_id = couponmodel.Id;
                                            flowmodel.Direction = "income";
                                            flowmodel.Money = couponmodel.Credit;
                                            flowmodel.Action = "coupon";
                                            flowmodel.Create_time = DateTime.Now;
                                            using (IDataSession seion = Store.OpenSession(false))
                                            {
                                                seion.Flow.Insert(flowmodel);
                                            }

                                            using (IDataSession seion = Store.OpenSession(false))
                                            {
                                                usermodel = seion.Users.GetByID(couponmodel.User_id);
                                            }
                                            if (usermodel != null)
                                            {
                                                Updatemoney(couponmodel.User_id, couponmodel.Credit, usermodel.Money); //如果用户的余额可以支付，那么修改用户里面的余额并跳转到支付成功页面
                                            }
                                        }

                                        if (_system != null)
                                        {
                                            if (_system["opencoupon"] != null)
                                            {
                                                if (_system["opencoupon"] == "1")//开启优惠券打印提醒
                                                {
                                                    #region 发送短信
                                                    System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
                                                    if (ordermodel != null)
                                                    {

                                                        using (IDataSession seion = Store.OpenSession(false))
                                                        {
                                                            uimodel = seion.Users.GetByID(couponmodel.User_id);
                                                        }

                                                        if (ordermodel.Mobile != "")
                                                        {
                                                            phone.Add(ordermodel.Mobile);
                                                        }
                                                        else
                                                        {
                                                            phone.Add(uimodel.Mobile);
                                                        }

                                                        //优惠券消费提醒
                                                        NameValueCollection values = new NameValueCollection();
                                                        values.Add("网站简称", ASSystem.abbreviation);
                                                        if (uimodel != null)
                                                        {

                                                            values.Add("用户名", uimodel.Username);

                                                        }
                                                        else
                                                        {
                                                            values.Add("用户名", "");
                                                        }

                                                        values.Add("券号", couponmodel.Id);
                                                        values.Add("消费时间", couponmodel.Consume_time.ToString());


                                                        string message = ReplaceStr("consumption", values);

                                                        EmailMethod.SendSMS(phone, message);
                                                        //提示尊敬的{网站简称}用户{用户名}您的券号{券号}已于{消费时间}被消费。


                                                    }
                                                    #endregion
                                                }
                                            }
                                        }
                                        result = result + "<br>密码" + num[i] + ":[" + secret[i] + "]&nbsp;消费成功";
                                    }
                                }
                            }
                        }
                        else
                        {
                            result = result + "<br>当前优惠券号码：" + cid + "<br>";
                            result = result + "<br>密码不能为空！<br>";
                        }
                    }
                    #endregion
                }
            }
            else
            {
                result = "#[" + cid + "]&nbsp;无效";
                result = result + "<br>本次消费失败";

            }
            OrderedDictionary list = new OrderedDictionary();
            list.Add("html", result);
            list.Add("id", "coupon-dialog-display-id");
            Response.Write(JsonUtils.GetJson(list, "updater"));
        }
        else if (action == "sms")
        {
            string txt = "";
            string csecret = Helper.GetString(Request["csecret"], String.Empty);
            CouponFilter couponfil = new CouponFilter();
            System.Collections.Generic.IList<ICoupon> couponmodel = null;
            couponfil.Id = cid;
            couponfil.Secret = csecret;
            ISystem sysmodel = Store.CreateSystem();
            AS.GroupOn.Domain.IUser user = null;
            AS.GroupOn.Domain.ISystem system = null;
            int id=0;
            string key = FileUtils.GetKey();
            if (CookieUtils.GetCookieValue("username",key)!=""||CookieUtils.GetCookieValue("username",key)!=null)
	        {
                id = Helper.GetInt(CookieUtils.GetCookieValue("userid", key), 0);
	        }
            
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                user = session.Users.GetByID(id);
            }
            using (IDataSession session = Store.OpenSession(false))
            {
                system = session.System.GetByID(1);
                couponmodel = session.Coupon.GetList(couponfil);
            }
            
            if (couponmodel != null)
            {
                if (user == null)
                {
                    Response.Write("<script>window.top.location.href='" + this.Page.ResolveUrl(GetUrl("用户登录", "account_login.aspx")) + "'</" + "script>");
                    Response.End();
                }
                #region
                //得到优惠券 根据cid

                if (couponmodel[0].Sms >= 5 && user != null)
                {  //如果短信发送量>=5并且当前用户是管理员的话
                    txt = JsonUtils.GetJson("短信发送优惠券最多5次", "alert");
                    Response.Write(txt);
                    return;
                }
                //得到系统表短信发送间隔时间
                //
                //找到项目
                ITeam teammodel = null;
                using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(couponmodel[0].Team_id);
                }
                //【lefttime】 = 【间隔时间】 + 【发送短信的时间】 - 【当前时间】;
                //发送短信的日期
                DateTime smstime;
                int lefttime = 0;
                if (couponmodel[0].Sms_time.HasValue)
                {
                    smstime = DateTime.Parse(couponmodel[0].Sms_time.ToString());
                    if (ASSystem.smsinterval != 0)
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

                //if (【当前优惠券为空】||【没有登录】||(【优惠券中的用户id不等于当前登录用户的id】&&【没有管理权限】)) {
                //    json('非法下载', 'alert'); 调用websitehelper.json
                //}
                IUser usermodel = null;
                using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    //usermodel = session.Users.GetByID(Convert.ToInt32(CookieUtils.GetCookieValue("username")));
                    usermodel = session.Users.GetByID(Helper.GetInt(CookieUtils.GetCookieValue("userid", key), 0));
                }
                if (couponmodel == null || CookieUtils.GetCookieValue("username",key).Length == 0 || (couponmodel[0].User_id != usermodel.Id && user != null))
                {
                    txt = JsonUtils.GetJson("非法下载", "alert");// 调用websitehelper.json
                    Response.Write(txt);
                    return;
                }
                // SendSMS
                //【flag】 =【发送优惠券  调用websitehelper .sendsms】
                System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
                using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    usermodel = session.Users.GetByID(couponmodel[0].User_id);
                }
                phone.Add(usermodel.Mobile);
                string tuangou = "";

                if (sysmodel != null)
                {
                    tuangou = sysmodel.abbreviation;
                }
                //txt = "您好，你在" + ASSystem.abbreviation + "获得" + teammodel.Product + "的优惠券：" + couponmodel.Id + "密码: " + couponmodel.Secret + " 有效期至: " + couponmodel.Expire_time.ToString("yyyy年MM月dd日") + " 请及时使用";


                //txt = ASSystem.abbreviation + "项目：" + teammodel.Product + "，编号：" + couponmodel.Id + "，密码：" + couponmodel.Secret + "，有效期至：" + couponmodel.Expire_time.ToString("yyyy年MM月dd日");
                //txt = "已发送--【" + tuangou + "项目：" + teammodel.Product + "，编号：" + couponmodel.Id + "，密码：" + couponmodel.Secret + "，有效期至：" + couponmodel.Expire_time.ToString("yyyy年MM月dd日") + "】";
                IPartner partnermodel = null;
                using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
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
                values.Add("券号", couponmodel[0].Id);
                values.Add("密码", couponmodel[0].Secret);
                values.Add("优惠券结束时间", couponmodel[0].Expire_time.ToString("yyyy年MM月dd日"));
                if (couponmodel[0].start_time.HasValue && couponmodel[0].start_time.Value.ToString() != "")
                {
                    values.Add("优惠券开始时间", couponmodel[0].start_time.Value.ToString("yyyy年MM月dd日"));
                }
                else
                {
                    values.Add("优惠券开始时间", "");
                }
                values.Add("商户名称", partnername);
                values.Add("联系方式", partnermobile);
                txt = ReplaceStr("couponsms", values);


                if (EmailMethod.SendSMS(phone, txt))//Utils.WebSiteHelper.SendSms(sysbll.GetModel(1).smsuser, sysbll.GetModel(1).smspass, userbll.GetModel(couponmodel.User_id).Mobile, "手机短信发送成功，请及时查收"))
                {

                    txt = JsonUtils.GetJson(txt, "alert");  //调用websitehelper.json方法
                    //couponmodel[0].Sms = 
                    //couponmodel[0].Sms_time = DateTime.Now;
                    ICoupon couponmodels = couponmodel[0];
                    couponmodels.Sms = couponmodel[0].Sms + 1;
                    couponmodels.Sms_time = DateTime.Now;
                    int ii = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        ii = session.Coupon.Update(couponmodels);
                    }
                    if (ii > 0)
                    {
                        Response.Write(txt);
                    }

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
            else
            {
                #region
                IPcoupon pcoumodel = null;
                using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    pcoumodel = session.Pcoupon.GetByID(Helper.GetInt(cid, 0));
                }
                //找到项目
                ITeam teammodel = null;
                using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(pcoumodel.teamid);
                }
                //【lefttime】 = 【间隔时间】 + 【发送短信的时间】 - 【当前时间】;
                //发送短信的日期
                DateTime smstime;
                int lefttime = 0;
                if (pcoumodel.buy_time != null)
                {
                    smstime = DateTime.Parse(pcoumodel.buy_time.ToString());
                    if (ASSystem.smsinterval != 0)
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

                //if (【当前优惠券为空】||【没有登录】||(【优惠券中的用户id不等于当前登录用户的id】&&【没有管理权限】)) {
                //    json('非法下载', 'alert'); 调用websitehelper.json
                //}

                if (pcoumodel == null || CookieUtils.GetCookieValue("username",key).Length == 0 || (couponmodel[0].User_id != usermodel.Id && user != null))
                {
                    txt = JsonUtils.GetJson("非法下载", "alert");// 调用websitehelper.json
                    Response.Write(txt);
                    return;
                }
                // SendSMS
                //【flag】 =【发送优惠券  调用websitehelper .sendsms】
                System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
                using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    usermodel = session.Users.GetByID(couponmodel[0].User_id);
                }
                phone.Add(usermodel.Mobile);
                string tuangou = "";
                if (sysmodel != null)
                {
                    tuangou = sysmodel.abbreviation;
                }
                //txt = "您好，你在" + ASSystem.abbreviation + "获得" + teammodel.Product + "的优惠券：" + couponmodel.Id + "密码: " + couponmodel.Secret + " 有效期至: " + couponmodel.Expire_time.ToString("yyyy年MM月dd日") + " 请及时使用";
                // txt = ASSystem.abbreviation + "项目：" + teammodel.Product + "，编号：" + pcoumodel.number + "，有效期至：" + pcoumodel.expire_time.ToString("yyyy年MM月dd日");
                //txt = "已发送--【" + tuangou + "项目：" + teammodel.Product + "，编号：" + couponmodel.Id + "，密码：" + couponmodel.Secret + "，有效期至：" + couponmodel.Expire_time.ToString("yyyy年MM月dd日") + "】";

                IPartner partnermodel = null;
                using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
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
                values.Add("券号", couponmodel[0].Id);
                values.Add("密码", couponmodel[0].Secret);
                values.Add("优惠券结束时间", couponmodel[0].Expire_time.ToString("yyyy年MM月dd日"));
                if (couponmodel[0].start_time.Value != null && couponmodel[0].start_time.Value.ToString() != "")
                {
                    values.Add("优惠券开始时间", couponmodel[0].start_time.Value.ToString("yyyy年MM月dd日"));
                }
                else
                {
                    values.Add("优惠券开始时间", "");
                }
                values.Add("商户名称", partnername);
                values.Add("联系方式", partnermobile);
                txt = ReplaceStr("couponsms", values);


                if (EmailMethod.SendSMS(phone, txt))//Utils.WebSiteHelper.SendSms(sysbll.GetModel(1).smsuser, sysbll.GetModel(1).smspass, userbll.GetModel(couponmodel.User_id).Mobile, "手机短信发送成功，请及时查收"))
                {

                    txt = JsonUtils.GetJson(txt, "alert");  //调用websitehelper.json方法
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
        else if (action == "psms")
        {
            string txt = "";
            IPcoupon pcoumodel = null;
            using (IDataSession session = Store.OpenSession(false))
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
                    if (ASSystem.smsinterval != null)
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
                        using (IDataSession session = Store.OpenSession(false))
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

        else if (action == "bizconsume")
        {
            int id = Helper.GetInt(Request["selectpart"], 0);
            //通过传入的id获取密码
            IBranch br = Store.CreateBranch();
            BranchFilter bf = new BranchFilter();
            bf.id = id;
            if (id != 0)
            {
                using (IDataSession seion = Store.OpenSession(false))
                {
                    br = seion.Branch.Get(bf);
                }
            }

            //找到id值为cid的优惠券记录
            CouponFilter cf = new CouponFilter();
            cf.Id = cid;
            cf.Secret = sec;
            using (IDataSession seion = Store.OpenSession(false))
            {
                couponmodel = seion.Coupon.Get(cf);
            }

            //找到商家
            if (couponmodel != null)
            {



                PartnerFilter pf = new PartnerFilter();
                pf.Id = couponmodel.Partner_id;

                using (IDataSession seion = Store.OpenSession(false))
                {
                    partnermodel = seion.Partners.Get(pf);
                }
                //找到项目
                BranchFilter brf = new BranchFilter();
                brf.partnerid = couponmodel.Partner_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    branchmodel = seion.Branch.Get(brf);
                }
                TeamFilter tf = new TeamFilter();
                tf.Id = couponmodel.Team_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    teammodel = seion.Teams.Get(tf);
                }
                if (couponmodel.Secret.ToUpper() != sec.ToUpper())
                { //如果优惠券密码不等于sec
                    result = result + "<br>" + "[" + cid + "]" + "编号密码不正确";
                    result = result + "<br>本次消费失败";
                }

                else if (isEnable(cid, couponmodel.Secret))
                {//如果优惠券已使用
                    result = result + "<br>#[" + cid + "]&nbsp;已消费";
                    result = result + "<br>消费于：" + "[" + couponmodel.Consume_time + "]";
                    result = result + "<br>本次消费失败";
                }
                else if (isTime(couponmodel.Expire_time) == false)
                { //优惠券到期时间小于今天 精确到日
                    result = "#[" + cid + "]&nbsp;已过期";
                    result = result + "<br>过期时间：" + "[" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                    result = result + "<br>本次消费失败";
                }
                else if (branchmodel != null && (br == null && id != 0))
                {//有分店但是没有选择
                    result = result + "<br>" + "[" + cid + "]" + "请选择所在店铺";
                    result = result + "<br>本次消费失败";
                }
                else if (branchmodel != null && id > 0 && br.secret.ToUpper() != shangjiasec.ToUpper())
                {
                    result = result + "<br>" + "[" + cid + "]" + "商家密码不正确";
                    result = result + "<br>本次消费失败";
                }
                else if (branchmodel != null && id == 0 && partnermodel != null && partnermodel.Secret.ToUpper() != shangjiasec.ToUpper())
                {
                    result = result + "<br>" + "[" + cid + "]" + "商家密码不正确";
                    result = result + "<br>本次消费失败";
                }
                else
                {
                    #region
                    if (couponmodel.start_time.HasValue && getStart_time(couponmodel.start_time.Value)) //如果优惠券不等于未使用
                    {
                        //如果使用时间小于今天日期
                        result = "#[" + cid + "]&nbsp;未开始";
                        result = result + "<br>" + "有效期：" + "[" + couponmodel.start_time.Value.ToString("yyyy-MM-dd") + "至" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                    }
                    else
                    {

                        //credit to user'money'
                        //更新优惠券 ip，使用时间 使用状态
                        ICoupon icou = Store.CreateCoupon();
                        icou.Id = cid;
                        icou.Secret = couponmodel.Secret;
                        icou.IP = WebUtils.GetClientIP;
                        icou.Consume_time = DateTime.Now;
                        icou.Consume = "Y";
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            seion.Coupon.UpCoupon(icou);
                        }
                        //更新优惠券shoptype
                        if (branchmodel != null && id != 0)
                        {
                            icou.shoptypes = id;

                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                seion.Coupon.UpdateShoptypes(icou);
                            }

                        }

                        //写入消费记录表 

                        OrderFilter of = new OrderFilter();
                        of.Id = couponmodel.Order_id;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            ordermodel = seion.Orders.Get(of);
                        }

                        if (couponmodel.Credit > 0)
                        {

                            IFlow flowmodel = Store.CreateFlow();
                            flowmodel.User_id = couponmodel.User_id;
                            flowmodel.Detail_id = couponmodel.Id;
                            flowmodel.Direction = "income";
                            flowmodel.Money = couponmodel.Credit;
                            flowmodel.Action = "coupon";
                            flowmodel.Create_time = DateTime.Now;
                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                seion.Flow.Insert(flowmodel);
                            }

                            using (IDataSession seion = Store.OpenSession(false))
                            {
                                usermodel = seion.Users.GetByID(couponmodel.User_id);
                            }
                            if (usermodel != null)
                            {
                                Updatemoney(couponmodel.User_id, couponmodel.Credit, usermodel.Money); //如果用户的余额可以支付，那么修改用户里面的余额并跳转到支付成功页面
                            }
                        }
                        CouponFilter couf = new CouponFilter();
                        couf.Id = cid;
                        couf.Secret = couponmodel.Secret;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            listcoupon = seion.Coupon.GetList(couf);
                        }

                        //修改用户表的里面的账户余额
                        result = "【" + cid + "】" + "有效";
                        if (listcoupon != null && listcoupon.Count > 0)
                        {
                            result = result + "<br>消费时间：" + "【" + listcoupon[0].Consume_time + "】";
                        }
                        result = result + "本次消费成功";


                        if (_system != null)
                        {
                            if (_system["opencoupon"] != null)
                            {
                                if (_system["opencoupon"] == "1")//开启优惠券打印提醒
                                {
                                    #region 发送短信
                                    System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
                                    if (ordermodel != null)
                                    {
                                        using (IDataSession seion = Store.OpenSession(false))
                                        {
                                            uimodel = seion.Users.GetByID(couponmodel.User_id);
                                        }

                                        if (ordermodel.Mobile != "")
                                        {
                                            phone.Add(ordermodel.Mobile);

                                        }
                                        else
                                        {

                                            phone.Add(uimodel.Mobile);
                                        }

                                        //优惠券消费提醒
                                        NameValueCollection values = new NameValueCollection();
                                        values.Add("网站简称", ASSystem.abbreviation);
                                        if (uimodel != null)
                                        {

                                            values.Add("用户名", uimodel.Username);
                                        }
                                        else
                                        {
                                            values.Add("用户名", "");
                                        }
                                        values.Add("券号", couponmodel.Id);
                                        values.Add("消费时间", couponmodel.Consume_time.ToString());


                                        string message = ReplaceStr("consumption", values);

                                        EmailMethod.SendSMS(phone, message);
                                        //提示尊敬的{网站简称}用户{用户名}您的券号{券号}已于{消费时间}被消费。


                                    }
                                    #endregion
                                }
                            }
                        }
                    }
                    #endregion
                }
            }

            else
            {
                result = "#[" + cid + "]&nbsp;无效";
                result = result + "<br>本次消费失败";

            }

            OrderedDictionary list = new OrderedDictionary();
            list.Add("html", result);
            list.Add("id", "coupon-dialog-display-bizid");
            Response.Write(JsonUtils.GetJson(list, "updater"));
        }
        else if (action == "preinvent")
        {
            IProduct productmodel = null;
            int userid = 0;
            string key = string.Empty;
            key = FileUtils.GetKey();
            if (CookieUtils.GetCookieValue("partner", key) != null && CookieUtils.GetCookieValue("partner", key).ToString() != "")
            {
                userid = int.Parse(CookieUtils.GetCookieValue("partner", key).ToString());
            }
            else
            {
                userid = AdminPage.AsAdmin.Id;
            }
            try
            {
                string results = Request["result"];
                results = Server.UrlDecode(results);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    productmodel = session.Product.GetByID(Convert.ToInt32(Request["resultid"]));
                }
                if (AS.GroupOn.Controls.Utilys.Getbulletin(productmodel.bulletin) != "")
                {
                    if (productmodel.invent_result != null && productmodel.invent_result != "")
                    {
                        if (AS.GroupOn.Controls.Utilys.Getrule(results) == false)
                        {   
                            string re = productmodel.invent_result;
                            productmodel.invent_result = AS.GroupOn.Controls.Utilys.Getrule(results, productmodel.invent_result, 0, 2);
                            productmodel.inventory = AS.GroupOn.Controls.Utilys.Getrulenum(results, re, 1, 2);
                            if (productmodel.inventory > 0)
                            {
                                if (productmodel.status > 0 && productmodel.status!=8)
                                {
                                    productmodel.status = productmodel.status;
                                }
                                else
                                {
                                    productmodel.status = 4;
                                }
                            }
                            else
                            {
                                productmodel.status = 8;
                                productmodel.inventory = 0;
                            }
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id = session.Product.Update(productmodel);
                            }
                            AdminPage.intoorder(0, AS.GroupOn.Controls.Utilys.Getnum(results), 1, Convert.ToInt32(Request["resultid"]), userid, results, 1);

                            //更新项目的库存信息
                            System.Collections.Generic.IList<ITeam> teammodels = null;
                            TeamFilter teamft = new TeamFilter();
                            teamft.productid = productmodel.id;

                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                            {
                                teammodels = session.Teams.GetList(teamft);
                            }
                            if (teammodels != null && teammodels.Count > 0)
                            {
                                foreach (var team in teammodels)
                                {
                                    if (team.invent_result != null && team.invent_result != "")
                                    {
                                        team.invent_result = Utilys.Getrule(results, productmodel.invent_result, 0, 2);
                                        team.inventory = Utilys.Getrulenum(results, re, 1, 2);
                                        if (!String.IsNullOrEmpty(productmodel.invent_result) && productmodel.invent_result.Contains("价格"))
                                        {
                                            string[] bullteam = productmodel.invent_result.Replace("{", "").Replace("}", "").Split('|');
                                            string money = bullteam[0].Substring(0, bullteam[0].LastIndexOf(','));
                                            money = money.Substring(money.LastIndexOf(','), money.Length - money.LastIndexOf(',')).Replace(",", "").Replace("价格", "").Replace(":", "").Replace("[", "").Replace("]", "");
                                            team.Team_price = Helper.GetDecimal(money, 0);
                                        }
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            int counta = session.Teams.Update(team);
                                        }
                                        AdminPage.intoorder(0, Utilys.Getnum(results), 1, team.Id, userid, results, 0);
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

                        if (AS.GroupOn.Controls.Utilys.Getrule(results) == false)
                        {

                            productmodel.invent_result = results;
                            productmodel.inventory = AS.GroupOn.Controls.Utilys.Getrulenum(results, productmodel.invent_result, 0, 2);
                            if (productmodel.inventory > 0)
                            {
                                if (productmodel.status > 0 && productmodel.status != 8)
                                {
                                    productmodel.status = productmodel.status;
                                }
                                else
                                {
                                    productmodel.status = 4;
                                }                                
                            }
                            else
                            {
                                productmodel.inventory = 0;
                                productmodel.status = 8;
                            }
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id = session.Product.Update(productmodel);
                            }

                            AdminPage.intoorder(0, AS.GroupOn.Controls.Utilys.Getnum(results), 1, Convert.ToInt32(Request["resultid"]), userid, results, 1);

                            //更新项目的库存信息
                            System.Collections.Generic.IList<ITeam> teammodels = null;
                            TeamFilter teamft = new TeamFilter();
                            teamft.productid = productmodel.id;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                teammodels = session.Teams.GetList(teamft);
                            }
                            if (teammodels != null && teammodels.Count > 0)
                            {
                                for (int i = 0; i < teammodels.Count; i++)
                                {
                                    teammodel = teammodels[i];
                                    teammodel.invent_result = results;
                                    teammodel.inventory = AS.GroupOn.Controls.Utilys.Getrulenum(results, teammodel.invent_result, 0, 2);
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        int id = session.Teams.Update(teammodel);
                                    }
                                    AdminPage.intoorder(0, AS.GroupOn.Controls.Utilys.Getnum(results), 1, teammodel.Id, userid, Request["result"], 0);
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
                    string txt = results;
                    productmodel.inventory = productmodel.inventory + Convert.ToInt32(results);
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


                    AdminPage.intoorder(0, Convert.ToInt32(txt), 1, Convert.ToInt32(Request["resultid"]), userid, results, 1);

                    //更新项目的库存信息                    
                    System.Collections.Generic.IList<ITeam> teammodels = null;
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
                                teammodel.inventory = teammodel.inventory + Convert.ToInt32(results);
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

                            AdminPage.intoorder(0, Convert.ToInt32(txt), 1, teammodel.Id, userid, results, 0);
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
                result = "友情提示：发生了异常操作，请重新打开页面操作" + ex.ToString();
                OrderedDictionary list = new OrderedDictionary();
                list.Add("html", result);
                list.Add("id", "coupon-dialog-display-id1");
                Response.Write(JsonUtils.GetJson(list, "updater"));
            }
        }

        else if (action == "reinvent")
        {
            try
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(Convert.ToInt32(Request["resultid"]));
                }
                string results = Request["result"];
                results = Server.UrlDecode(results);
                if (AS.GroupOn.Controls.Utilys.Getbulletin(teammodel.bulletin) != "")
                {
                    if (AS.GroupOn.Controls.Utilys.Getbulletin(teammodel.invent_result) != "")//有规格
                    {
                        if (AS.GroupOn.Controls.Utilys.Getrule(results) == false)
                        {
                            string result = results;
                            string re = teammodel.invent_result;
                            teammodel.invent_result = AS.GroupOn.Controls.Utilys.Getrule(results, teammodel.invent_result, 0, 1);
                            teammodel.inventory = AS.GroupOn.Controls.Utilys.Getrulenum(results, re, 1, 1);
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id2 = session.Teams.Update(teammodel);
                            }
                            //记录库存更变记录
                            AdminPage.intoorder(0, AS.GroupOn.Controls.Utilys.Getnum(results), 1, Convert.ToInt32(Request["resultid"]), AdminPage.AsAdmin.Id, results, 0);


                            //处理产品库存

                            IProduct promodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                promodel = session.Product.GetByID(teammodel.productid);
                            }

                            if (promodel != null)
                            {
                                string strpre = promodel.invent_result;
                                promodel.invent_result = AS.GroupOn.Controls.Utilys.Getrule(results, promodel.invent_result, 0, 2);
                                promodel.inventory = AS.GroupOn.Controls.Utilys.Getrulenum(results, strpre, 1, 2);

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
                                AdminPage.intoorder(0, AS.GroupOn.Controls.Utilys.Getnum(results), 1, Convert.ToInt32(Request["resultid"]), AdminPage.AsAdmin.Id, results, 1);

                            }
                            #region 如果启动的报警开关，同时项目处于报警的状态，那么给管理员发送短信
                            if (Helper.GetString(teammodel.warmobile, "") != "")
                            {
                                if (teammodel.open_war == 1)//开启库存报警功能
                                {
                                    if (AS.GroupOn.Controls.Utilys.IsWar(teammodel))
                                    {
                                        System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
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
                        if (AS.GroupOn.Controls.Utilys.Getrule(results) == false)
                        {

                            teammodel.invent_result = results;
                            teammodel.inventory = AS.GroupOn.Controls.Utilys.Getrulenum(results, teammodel.invent_result, 0, 2);
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id2 = session.Teams.Update(teammodel);
                            }

                            AdminPage.intoorder(0, AS.GroupOn.Controls.Utilys.Getnum(results), 1, Convert.ToInt32(Request["resultid"]), AdminPage.AsAdmin.Id, results, 0);


                            //处理产品库存                            
                            IProduct promodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                promodel = session.Product.GetByID(teammodel.productid);
                            }
                            if (promodel != null)
                            {

                                promodel.invent_result = results;
                                promodel.inventory = AS.GroupOn.Controls.Utilys.Getrulenum(results, promodel.invent_result, 0, 2);
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
                                AdminPage.intoorder(0, AS.GroupOn.Controls.Utilys.Getnum(results), 1, Convert.ToInt32(Request["resultid"]), AdminPage.AsAdmin.Id, results, 1);

                            }

                            // result = "恭喜您，项目库存添加成功";

                            #region 如果启动的报警开关，同时项目处于报警的状态，那么给管理员发送短信
                            if (Helper.GetString(teammodel.warmobile, "") != "")
                            {
                                if (teammodel.open_war == 1)//开启库存报警功能
                                {
                                    if (AS.GroupOn.Controls.Utilys.IsWar(teammodel))
                                    {
                                        System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
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
                    string txt = results;
                    teammodel.inventory = teammodel.inventory + Convert.ToInt32(results);
                    if (teammodel.inventory < 0)
                    {
                        teammodel.inventory = 0;
                        txt = "0";
                    }
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int id2 = session.Teams.Update(teammodel);
                    }

                    AdminPage.intoorder(0, Convert.ToInt32(txt), 1, Convert.ToInt32(Request["resultid"]), AdminPage.AsAdmin.Id, results, 0);


                    //处理产品库存

                    IProduct promodel = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        promodel = session.Product.GetByID(teammodel.productid);
                    }
                    if (promodel != null)
                    {
                        promodel.inventory = promodel.inventory + Convert.ToInt32(results);
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
                            promodel.status = 8;
                        }
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int id2 = session.Product.Update(promodel);
                        }

                        //退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                        AdminPage.intoorder(0, Convert.ToInt32(txt), 1, Convert.ToInt32(Request["resultid"]), AdminPage.AsAdmin.Id, results, 1);

                    }




                    #region 如果启动的报警开关，同时项目处于报警的状态，那么给管理员发送短信
                    if (Helper.GetString(teammodel.warmobile, "") != "")
                    {
                        if (teammodel.open_war == 1)//开启库存报警功能
                        {
                            if (AS.GroupOn.Controls.Utilys.IsWar(teammodel))
                            {
                                System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
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

                result = "友情提示：发生了异常操作，请重新打开页面操作1"+ex.ToString();
                OrderedDictionary list = new OrderedDictionary();
                list.Add("html", result);
                list.Add("id", "coupon-dialog-display-id1");
                Response.Write(JsonUtils.GetJson(list, "updater"));
            }

        }

        else if (action == "bizconsume2")
        {
            int id = Helper.GetInt(Request["selectpart"], 0);
            //通过传入的id获取密码
            IBranch br = Store.CreateBranch();
            BranchFilter bf = new BranchFilter();
            bf.id = id;
            if (id != 0)
            {
                using (IDataSession seion = Store.OpenSession(false))
                {
                    br = seion.Branch.Get(bf);
                }
            }

            //找到id值为cid的优惠券记录

            using (IDataSession seion = Store.OpenSession(false))
            {
                couponmodel = seion.Coupon.GetByID(cid);
            }

            //找到商家
            if (couponmodel != null)
            {
                PartnerFilter pf = new PartnerFilter();
                pf.Id = couponmodel.Partner_id;

                using (IDataSession seion = Store.OpenSession(false))
                {
                    partnermodel = seion.Partners.Get(pf);
                }
                //找到项目
                BranchFilter brf = new BranchFilter();
                brf.partnerid = couponmodel.Partner_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    branchmodel = seion.Branch.Get(brf);
                }
                TeamFilter tf = new TeamFilter();
                tf.Id = couponmodel.Team_id;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    teammodel = seion.Teams.Get(tf);
                }

                if (isTime(couponmodel.Expire_time) == false)
                { //优惠券到期时间小于今天 精确到日
                    result = "#[" + cid + "]&nbsp;已过期";
                    result = result + ",过期时间：" + "[" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                    result = result + ",本次消费失败";
                }
                else if (branchmodel != null && (br == null && id != 0))
                {//有分店但是没有选择
                    result = result + "<br>" + "[" + cid + "]" + "请选择所在店铺";
                    result = result + ",本次消费失败";
                }

                else
                {
                    #region
                    if (couponmodel.start_time.HasValue && getStart_time(couponmodel.start_time.Value)) //如果优惠券不等于未使用
                    {
                        //如果使用时间小于今天日期
                        result = "#[" + cid + "]&nbsp;未开始";
                        result = result + "," + "有效期：" + "[" + couponmodel.start_time.Value.ToString("yyyy-MM-dd") + "至" + couponmodel.Expire_time.ToString("yyyy-MM-dd") + "]";
                    }
                    else
                    {
                        string[] secret = sec.Split(',');
                        string[] num = shownum.Split(',');
                        if (sec.Replace(",", "") != "")
                        {
                            result = result + "<br>当前优惠券号码：" + cid + "<br>";
                            for (int i = 0; i < secret.Length - 1; i++)
                            {
                                CouponFilter cf = new CouponFilter();
                                cf.Id = cid;
                                cf.Secret = secret[i].ToString();
                                using (IDataSession seion = Store.OpenSession(false))
                                {
                                    couponmodel = seion.Coupon.Get(cf);
                                }
                                string consumeorno = "";
                                string consumetime = "";
                                if (couponmodel != null)
                                {
                                    consumeorno = couponmodel.Consume;
                                    consumetime = couponmodel.Consume_time.ToString();
                                }
                                if (secret[i].ToString() != "")
                                {
                                    if (branchmodel != null && id > 0 && br.secret.ToUpper() != shangjiasec.ToUpper())
                                    {//分店消费密码不正确
                                        result = result + "<br>商家密码不正确";
                                        result = result + ",本次消费失败";
                                        OrderedDictionary list1 = new OrderedDictionary();
                                        list1.Add("html", result);
                                        list1.Add("id", "coupon-dialog-display-id");
                                        Response.Write(JsonUtils.GetJson(list1, "updater"));
                                        return;
                                    }
                                    else if (branchmodel != null && id == 0 && partnermodel != null && partnermodel.Secret.ToUpper() != shangjiasec.ToUpper())
                                    {//总店消费密码不正确
                                        result = result + "<br>商家密码不正确";
                                        result = result + ",本次消费失败";
                                        OrderedDictionary list2 = new OrderedDictionary();
                                        list2.Add("html", result);
                                        list2.Add("id", "coupon-dialog-display-id");
                                        Response.Write(JsonUtils.GetJson(list2, "updater"));
                                        return;
                                    }
                                    if (!Exists(cid, secret[i].ToUpper()))
                                    { //优惠券密码是否存在
                                        result = result + "<br>密码" + num[i] + ":[" + secret[i] + "]" + "不正确";
                                    }
                                    else if (consumeorno == "Y")
                                    {//如果优惠券已使用
                                        result = result + "<br>密码" + num[i] + ":[" + secret[i] + "]&nbsp;已消费";
                                        result = result + ",消费于：" + "[" + consumetime + "]";
                                    }

                                    else
                                    {
                                        //credit to user'money'
                                        //更新优惠券 ip，使用时间 使用状态


                                        ICoupon icou = Store.CreateCoupon();
                                        icou.Id = cid;
                                        icou.Secret = couponmodel.Secret;
                                        icou.IP = WebUtils.GetClientIP;
                                        icou.Consume_time = DateTime.Now;
                                        icou.Consume = "Y";
                                        using (IDataSession seion = Store.OpenSession(false))
                                        {
                                            seion.Coupon.UpCoupon(icou);
                                        }
                                        //更新优惠券shoptype
                                        if (branchmodel != null && id != 0)
                                        {
                                            icou.shoptypes = id;
                                            using (IDataSession seion = Store.OpenSession(false))
                                            {
                                                seion.Coupon.UpdateShoptypes(icou);
                                            }
                                        }


                                        //写入消费记录表 
                                        CouponFilter cof = new CouponFilter();
                                        cof.Id = cid;
                                        cof.Secret = couponmodel.Secret;

                                        using (IDataSession seion = Store.OpenSession(false))
                                        {
                                            couponmodel = seion.Coupon.Get(cof);
                                        }


                                        OrderFilter of = new OrderFilter();
                                        of.Id = couponmodel.Order_id;
                                        using (IDataSession seion = Store.OpenSession(false))
                                        {
                                            ordermodel = seion.Orders.Get(of);
                                        }

                                        if (couponmodel.Credit > 0)
                                        {

                                            IFlow flowmodel = Store.CreateFlow();
                                            flowmodel.User_id = couponmodel.User_id;
                                            flowmodel.Detail_id = couponmodel.Id;
                                            flowmodel.Direction = "income";
                                            flowmodel.Money = couponmodel.Credit;
                                            flowmodel.Action = "coupon";
                                            flowmodel.Create_time = DateTime.Now;
                                            using (IDataSession seion = Store.OpenSession(false))
                                            {
                                                seion.Flow.Insert(flowmodel);
                                            }

                                            using (IDataSession seion = Store.OpenSession(false))
                                            {
                                                usermodel = seion.Users.GetByID(couponmodel.User_id);
                                            }
                                            if (usermodel != null)
                                            {
                                                Updatemoney(couponmodel.User_id, couponmodel.Credit, usermodel.Money); //如果用户的余额可以支付，那么修改用户里面的余额并跳转到支付成功页面
                                            }
                                        }

                                        if (_system != null)
                                        {
                                            if (_system["opencoupon"] != null)
                                            {
                                                if (_system["opencoupon"] == "1")//开启优惠券打印提醒
                                                {
                                                    #region 发送短信
                                                    System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
                                                    if (ordermodel != null)
                                                    {

                                                        using (IDataSession seion = Store.OpenSession(false))
                                                        {
                                                            uimodel = seion.Users.GetByID(couponmodel.User_id);
                                                        }

                                                        if (ordermodel.Mobile != "")
                                                        {
                                                            phone.Add(ordermodel.Mobile);
                                                        }
                                                        else
                                                        {
                                                            phone.Add(uimodel.Mobile);
                                                        }
                                                        //优惠券消费提醒
                                                        NameValueCollection values = new NameValueCollection();
                                                        values.Add("网站简称", ASSystem.abbreviation);
                                                        if (uimodel != null)
                                                        {

                                                            values.Add("用户名", uimodel.Username);
                                                        }
                                                        else
                                                        {
                                                            values.Add("用户名", "");
                                                        }

                                                        values.Add("券号", couponmodel.Id);
                                                        values.Add("消费时间", couponmodel.Consume_time.ToString());


                                                        string message = ReplaceStr("consumption", values);

                                                        EmailMethod.SendSMS(phone, message);
                                                        //提示尊敬的{网站简称}用户{用户名}您的券号{券号}已于{消费时间}被消费。

                                                    }
                                                    #endregion
                                                }
                                            }
                                        }
                                        result = result + "<br>密码" + num[i] + ":[" + secret[i] + "]&nbsp;消费成功";
                                    }
                                }
                            }
                        }
                        else
                        {
                            result = result + "<br>当前优惠券号码：" + cid + "<br>";
                            result = result + "<br>密码不能为空！<br>";
                        }
                    }
                    #endregion

                }

            }

            else
            {
                result = "#[" + cid + "]&nbsp;无效";
                result = result + "<br>本次消费失败";

            }

            OrderedDictionary list = new OrderedDictionary();
            list.Add("html", result);
            list.Add("id", "coupon-dialog-display-bizid");
            Response.Write(JsonUtils.GetJson(list, "updater"));
        }


    }

    #region 判断优惠券是否已经被使用
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
    #endregion


    #region 判断优惠券的到期日期是否大于当前日期，如果大于，返回true
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
    #endregion


    #region 判断优惠券的到期日期是否大于当前日期，如果大于，返回true
    public bool getStart_time(DateTime start_time)
    {
        bool result = false;
        if (start_time >= DateTime.Now)
            //优惠券的使用时间已到
            result = true;
        return result;
    }
    #endregion

    #region 修改用户的余额
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

    #endregion


    /// <summary>
    /// 是否存在券号+密码 相同的记录
    /// </summary>
    public bool Exists(string Id, string secret)
    {
        CouponFilter cf = new CouponFilter();
        cf.Id = Id;
        cf.Secret = secret;
        int cnt = 0;
        using (IDataSession seion = Store.OpenSession(false))
        {
            cnt = seion.Coupon.GetCount(cf);
        }

        if (cnt > 0)
        {
            return true;
        }

        return false;

    }
    
</script>
