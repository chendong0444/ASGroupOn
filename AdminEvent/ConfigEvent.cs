using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Controls;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess.Accessor;
using AS.Common.Utils;
using System.Web;
using AS.GroupOn.Domain.Spi;
using AS.GroupOn.DataAccess;
using AS.GroupOn.App;
using AS.Common;
using System.Collections.Specialized;
using System.Configuration;

namespace AS.AdminEvent
{
    /// <summary>
    /// 配置事件
    /// </summary>
    //string headlogodef,string footlogodef, string printlogodef, string emaillogodef,
    public class ConfigEvent
    {
        RedirctResult result = null;
        BasePage b = new BasePage();
        int i = 0;
        protected NameValueCollection configs = new NameValueCollection();
        /// <summary>
        /// 修改团购基本
        /// </summary>
        /// <param name="sitename"></param>
        /// <param name="sitetitle"></param>
        /// <param name="abbreviation"></param>
        /// <param name="title"></param>
        /// <param name="keyword"></param>
        /// <param name="description"></param>
        /// <param name="jobtime"></param>
        /// <param name="couponname"></param>
        /// <param name="currency"></param>
        /// <param name="currencyname"></param>
        /// <param name="invitecredit"></param>
        /// <param name="shanhu"></param>
        /// <param name="sideteam"></param>
        /// <param name="conduser"></param>
        /// <param name="partnerdown"></param>
        /// <param name="kefuqq"></param>
        /// <param name="kefumsn"></param>
        /// <param name="tuanphone"></param>
        /// <param name="icp"></param>
        /// <param name="statcode"></param>
        /// <param name="sinajiwai"></param>
        /// <param name="tencentjiwai"></param>
        /// <param name="drawimg"></param>
        /// <param name="ddlmore"></param>
        /// <param name="id"></param>
        /// <param name="more"></param>
        /// <param name="thost"></param>
        /// <param name="row"></param>
        /// <param name="indexteam"></param>
        /// <param name="teamdetailnum"></param>
        /// <param name="couponlength"></param>
        /// <param name="usedrawimg"></param>
        /// <param name="drawimgType"></param>
        /// <param name="drawfont"></param>
        /// <param name="drawsize"></param>
        /// <param name="drawmimgurl"></param>
        /// <param name="drawalpha"></param>
        /// <param name="watermarkstatus"></param>
        /// <returns></returns>
        public RedirctResult UpdateTuanJiBen(string sitename, string sitetitle, string abbreviation, string title, string keyword,
            string description, string jobtime, string couponname, string currency, string currencyname, decimal invitecredit, 
             int shanhu, int sideteam, int conduser, int partnerdown, string kefuqq, string kefumsn, string tuanphone, string icp,
            string statcode, string sinajiwai, string tencentjiwai, string drawimg, int ddlmore, int id, string more, string thost, string row, int indexteam,
            int teamdetailnum, string couponlength, string usedrawimg, string drawimgType, string drawfont, string drawsize, string drawmimgurl, string drawalpha, string watermarkstatus)
        {
            

            ISystem system = Store.CreateSystem();
            NameValueCollection values = new NameValueCollection();
            WebUtils systemmodel = new WebUtils();
            values.Add("drawimg", drawimg);
            values.Add("moretuan", more);
            values.Add("thost", thost);
            values.Add("row", row);
            values.Add("indexteam", indexteam.ToString());
            values.Add("teamdetailnum", teamdetailnum.ToString());
            values.Add("couponlength", couponlength);
            values.Add("usedrawimg", usedrawimg);
            values.Add("drawimgType", drawimgType);
            values.Add("drawfont", drawfont);
            values.Add("drawsize", drawsize);
            values.Add("dramimgurl", drawmimgurl);
            values.Add("drawalpha", drawalpha);
            values.Add("drawposition", watermarkstatus);
            
           
            systemmodel.CreateSystemByNameCollection(values);
            
            for (int i = 0; i < values.Count; i++)
            {
                string strKey = values.Keys[i];
                string strValue = values[strKey];
                FileUtils.SetConfig(strKey, strValue);
            }

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                system = session.System.GetByID(id);
            }

            if (system != null)
            {
                system.sitename = sitename;
                system.sitetitle = sitetitle;
                system.abbreviation = abbreviation;
                system.title = title;
                system.keyword = keyword;
                system.description = description;
                system.jobtime = jobtime;
                system.couponname = couponname;
                system.currency = currency;
                system.currencyname = currencyname;
                system.invitecredit = invitecredit;
                //system.headlogo = headlogodef;
                //system.footlogo = footlogodef;
                //system.printlogo = printlogodef;
                //system.emaillogo = emaillogodef;
                system.teamwhole = shanhu;
                system.sideteam = sideteam;
                system.conduser = conduser;
                system.partnerdown = partnerdown;
                system.kefuqq = kefuqq;
                system.kefumsn = kefumsn;
                system.tuanphone = tuanphone;
                system.icp = icp;
                system.statcode = statcode;
                system.sinablog = sinajiwai;
                system.qqblog = tencentjiwai;
                system.needmoretuan = ddlmore;
                system.id = id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    i = session.System.Update(system);
                }
            }
            if (i > 0)
            {
                b.SetSuccess("修改成功");
                result = new RedirctResult("SheZhi_XuanXiang.aspx", true);
            }
            else
            {
                b.SetError("修改失败");
                result = new RedirctResult("SheZhi_XuanXiang.aspx", true);
            }
            return result;
        }

        /// <summary>
        /// 修改选项设置
        /// </summary>
        /// <returns></returns>
        public RedirctResult UpdateXuanXiang(string ddlnew, int txtshu, string txtshuGood, string CloseShopcarEvent, string ddlisguige, string navUserreview, string UserreviewYesOrNo,
            decimal DetailMoney, string ddlOpenUserreviewPartner, string ddlDoUserreviewPartner, string ddlinventory, string ddlinven_war,string inventmobile, string coupon, string couponDay, string opencoupon, string ddlorder, string ddlorderpay,
            string orderpartner, string displayTitle, string displayInvite_Top, string closeLocationEvent, int displayfailure, int teamask, int creditseconds, int smssubscribe, int trsimple, int moneysave,
            string shoppar, int teamwhole, string CloseSite, string ischeckcode, string slowimage, string ddlchagecity, string DropDownListmail, string maptype, string mapkey, string kuaidikey, string ddlSplitOrder, string pagecache,
            string ddlTeamPredict, int cateteam, int catepartner, int citypartner, int cateseconds, int categoods, int emailverify, int needmobile, string mobileverify,
            string logintongbinduser, string opensign, string loginscore, string loginmoney, string ddlOpenOrderTeam, string orderteamnum, string ddlCouponPattern, string ddlsmsnum, string ddlVerifyCoupon, int id,
            string point, string regscore, string invitescore, string chargescore, string totalNumber, string irange, string Shanghufz, string openwapindex, string openwaplogin)
        {

            ISystem system = Store.CreateSystem();
            NameValueCollection values = new NameValueCollection();
            WebUtils systemmodel = new WebUtils();
            values.Add("newgao", ddlnew);
            values.Add("txtshuGood", txtshuGood);
            values.Add("closeshopcar", CloseShopcarEvent);
            values.Add("isguige", ddlisguige);
            values.Add("navUserreview", navUserreview);
            values.Add("UserreviewYN", UserreviewYesOrNo);
            values.Add("userreview_rebate", DetailMoney.ToString());
            values.Add("openUserreviewPartner", ddlOpenUserreviewPartner);
            values.Add("doUserreviewPartner", ddlDoUserreviewPartner);
            values.Add("inventory", ddlinventory);
            values.Add("invent_war", ddlinven_war);
            values.Add("inventmobile", inventmobile);
            values.Add("displayCoupon", coupon);
            values.Add("displayCouponDay", couponDay);
            values.Add("opencoupon", opencoupon);
            values.Add("printorder", ddlorder);
            values.Add("orderpay", ddlorderpay);
            values.Add("orderpartner", orderpartner);
            values.Add("displayTitle", displayTitle);
            values.Add("displayInvite_Top", displayInvite_Top);
            values.Add("closeLocation", closeLocationEvent);
            values.Add("shop", shoppar);
            values.Add("isCloseSite", CloseSite);
            values.Add("ischeckcode", ischeckcode);
            values.Add("slowimage", slowimage);
            values.Add("changecity", ddlchagecity);
            values.Add("orderemailvalid", DropDownListmail);
            values.Add("maptype", maptype);
            values.Add("mapkey", mapkey);
            values.Add("kuaidikey", kuaidikey);
            values.Add("opensplitorder", ddlSplitOrder);
            values.Add("pagecache", pagecache);
            //values.Add("isrewrite", isrewrite);
            values.Add("teamdpredict", ddlTeamPredict);
            values.Add("mobileverify", mobileverify);
            values.Add("logintongbinduser", logintongbinduser);
            values.Add("opensign", opensign);
            values.Add("loginscore", loginscore);
            values.Add("loginmoney", loginmoney);
            values.Add("orderteam", ddlOpenOrderTeam);
            values.Add("orderteamnum",orderteamnum);
            values.Add("couponPattern", ddlCouponPattern);
            values.Add("couponSmsNum", ddlsmsnum);
            values.Add("verifycoupon", ddlVerifyCoupon);
            values.Add("point", point);
            values.Add("Shanghufz", Shanghufz);
            values.Add("regscore",regscore);
            values.Add("invitescore",invitescore);
            values.Add("chargescore", chargescore);
            values.Add("irange", irange);
            values.Add("openwapindex", openwapindex);
            values.Add("openwaplogin", openwaplogin);
            systemmodel.CreateSystemByNameCollection(values);

            for (int i = 0; i < values.Count; i++)
            {
                string strKey = values.Keys[i];
                string strValue = values[strKey];
                FileUtils.SetConfig(strKey, strValue);
            }

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                system = session.System.GetByID(id);
            }

            if (system != null)
            {
                system.guowushu = txtshu;
                system.Displayfailure = displayfailure;
                system.teamask = teamask;
                system.creditseconds = creditseconds;
                system.smssubscribe = smssubscribe;
                system.trsimple = trsimple;
                system.moneysave = moneysave;
                system.teamwhole = teamwhole;
                system.cateteam = cateteam;
                system.catepartner = catepartner;
                system.citypartner = citypartner;
                system.cateseconds = cateseconds;
                system.categoods = categoods;
                system.emailverify = emailverify;
                system.needmobile = needmobile;
 
                system.id = id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    i = session.System.Update(system);
                }
            }
            if (i > 0)
            {
                b.SetSuccess("修改成功");
                result = new RedirctResult("SheZhi_XuanXiang.aspx", true);
            }
            else
            {
                b.SetError("修改失败");
                result = new RedirctResult("SheZhi_XuanXiang.aspx", true);
            }
            return result;
        }


        /// <summary>
        /// 修改支付设置
        /// </summary>
        /// <returns></returns>
        public RedirctResult UpdateZhifu(string alipaytype, string alipay_acc, string alipay_mid, string alipay_sec, string alipay_anti_phishing,
            string alipay_Manual_SecuredTransactions, string autodeliver, string yeepay_mid, string yeepay_sec,string chinabank_mid,
            string chinabank_sec, string ddltenpaytype, string tenpay_mid, string tenpay_sec, string paypal_mid, string paypal_sec,int id )
        {
            ISystem system = Store.CreateSystem();
            NameValueCollection values = new NameValueCollection();
            WebUtils systemmodel = new WebUtils();
            values.Add("alipay_SecuredTransactions", alipaytype);
            values.Add("alipay_anti_phishing", alipay_anti_phishing);
            values.Add("alipay_Manual_SecuredTransactions", alipay_Manual_SecuredTransactions);
            values.Add("autodeliver", autodeliver);
            values.Add("is_Certify_Tenpay", ddltenpaytype);
            
            systemmodel.CreateSystemByNameCollection(values);

            for (int i = 0; i < values.Count; i++)
            {
                string strKey = values.Keys[i];
                string strValue = values[strKey];
                FileUtils.SetConfig(strKey, strValue);
            }

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                system = session.System.GetByID(id);
            }

            if (system != null)
            {
                system.alipayacc = alipay_acc;
                system.alipaymid = alipay_mid;
                system.alipaysec = alipay_sec;
                system.yeepaymid = yeepay_mid;
                system.yeepaysec = yeepay_sec;
                system.chinabankmid = chinabank_mid;
                system.chinabanksec = chinabank_sec;
                system.tenpaymid = tenpay_mid;
                system.tenpaysec = tenpay_sec;
                system.paypalmid = paypal_mid;
                system.paypalsec = paypal_sec;
                system.id = id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    i = session.System.Update(system);
                }
            }
            if (i > 0)
            {
                b.SetSuccess("修改成功");
                result = new RedirctResult("SheZhi_Zhifu.aspx", true);
            }
            else
            {
                b.SetError("修改失败");
                result = new RedirctResult("SheZhi_Zhifu.aspx", true);
            }
            return result;
        }

        /// <summary>
        /// 修改短信设置
        /// </summary>
        /// <param name="user">短信用户</param>
        /// <param name="pass">短信密码</param>
        /// <param name="interval">点发频率</param>
        /// <param name="id">ID</param>
        /// <returns></returns>
        public RedirctResult UpdateSMS(string user, string pass, int interval, int id)
        {
            ISystem system = Store.CreateSystem();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                system = session.System.GetByID(id);
            }
            if(system!=null)
            {
            system.smsuser = user;
            system.smspass = pass;
            system.smsinterval = interval;
            system.id = id;
            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                 i = session.System.Update(system);
            }
            if (i > 0)
            {
                b.SetSuccess("修改成功");
                result = new RedirctResult("SheZhi_Duanxin.aspx", true);
            }
            else
            {
                b.SetError("修改失败");
                result = new RedirctResult("SheZhi_Duanxin.aspx", true);
            }
            return result;
        }

        public static int AddOprationLog(int adminid, string type, string logcontent, DateTime createtime)
        {
            int addresult = 0;
            IOprationLog oprationlog = Store.CreateOprationLog();
            oprationlog.adminid = adminid;
            oprationlog.type = type;
            oprationlog.logcontent = logcontent;
            oprationlog.createtime = createtime;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                addresult = session.OprationLog.Insert(oprationlog);
            }
            return addresult;
        }
    
    
    
    }
}
