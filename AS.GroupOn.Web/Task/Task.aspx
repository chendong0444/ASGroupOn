<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        string mode = Request["mode"];
        if (mode == "teamnownumber")
        {
            try
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Custom.UpdateTeamNowNumber();
                }

            }
            catch (Exception ex)
            {
                AS.Common.Utils.WebUtils.LogWrite("自动更新购买人数日志", ex.Message);
            }
        }
        else if (mode == "sms")
        {
            GetCouptonTime();
        }
        else if (mode == "updateTeamEndtime")
        {
            updateTeamEndTime();
        }
        else if (mode == "sendMail")
        {
            sendMails();
        }
        else if (mode == "database")
        {
            updateBase();
        }
        
    }
    private void updateBase()
    {
        try
        {
            decimal version = AS.Common.Utils.Version.siteversion;
            decimal databaseversion = version;


            if (PageValue.CurrentSystem.siteversion.ToString() != String.Empty)
            {
                databaseversion = PageValue.CurrentSystem.siteversion;
            }
            if (databaseversion < version)//如果数据库版本号小于程序版本号
            {
                WebClient net = new WebClient();
                net.Encoding = System.Text.Encoding.UTF8;
                string update = net.DownloadString("http://update.asdht.com/db.aspx?old=" + databaseversion + "&new=" + version + "&domain=" + HttpUtility.UrlEncode(AS.Common.Utils.WebUtils.GetDomain(HttpContext.Current.Request.Url.ToString()), System.Text.Encoding.UTF8));

                if (AS.GroupOn.Controls.Utilys.Restore(update))
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.Custom.Update("update [system] set siteversion=" + version);
                    }

                }
            }

        }
        catch (Exception ex)
        {
            AS.Common.Utils.WebUtils.LogWrite("数据库升级日志", ex.Message);
        }
    }
    
    private static List<Hashtable> mailprovider = null; //保存邮件服务商。不用每次读取了
    public static Hashtable mailtask = null;//正在发送的邮件任务
    public static bool run = false;//邮件群发正在执行
    private void sendMails()
    {
        NameValueCollection _system = PageValue.CurrentSystemConfig;
        // System.IO.File.AppendAllText(AppDomain.CurrentDomain.BaseDirectory + "测试邮件群发.txt", "3333333333\r\n");
        if (!run)
        {
            run = true;
            try
            {
                double time = Helper.GetDouble(_system["time"], 0);
                int samesendcount = Helper.GetInt(_system["fucount"], 0);//同一邮件服务商的群发数量
                int sendmaxcount = Helper.GetInt(_system["maxcount"], -1);//每次最多发送数量
                if (time > 0 && samesendcount > 0 && sendmaxcount > -1)
                {
                    //设置计时器间隔时间
                    IMailtasks mailtask = null;
                    IList<Imailserviceprovider> mailprovider = null;
                    MailtasksFilter mf = new MailtasksFilter();
                    MailserviceproviderFilter mp = new MailserviceproviderFilter();
                    mf.Top = 1;
                    mf.state = 1;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        mailtask = session.Mailtasks.Get(mf);
                    }
                    if (mailtask != null)
                    {
                        if (mailprovider == null)//判断缓存里是否有用户的邮件服务商列表
                        {
                            mp.mailtasks_id = mailtask.id;
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                mailprovider = session.Mailserviceprovider.GetList(mp);
                            }
                        }
                        if (mailprovider == null || mailprovider.Count == 0)//如果邮件服务商列表里没有记录则删除数据库中邮件任务对应的服务商列表，并设置邮件任务为发送完毕状态。
                        {
                            mailtask.state = 2;
                            mailtask.sendcount = mailtask.totalcount;
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                session.Mailserviceprovider.Delete(mailtask.id);
                                session.Mailtasks.Update(mailtask);
                            }
                            //db.SqlExec("update mailer set sendmailids=REPLACE(sendmailids,'," + mailtask["id"] + ",','')");
                            mailprovider = null;
                            mailtask = null;
                        }
                    }
                    if (mailprovider != null && mailprovider.Count > 0) //邮件服务商列表不为空则执行发送任务
                    {
                        //执行发送功能
                        int sendcount = 0;//此轮已发送数量
                        string cityidin = String.Empty;
                        if (!Utility.isEmpity(mailtask.cityid)) cityidin = " and city_id in(" + mailtask.cityid + ")";
                        ISystem system = Store.CreateSystem();
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            system = session.System.GetByID(1);
                        }
                        List<Hashtable> maildto = new List<Hashtable>();
                        IList<IMailserver> mailserver = null;
                        var sum = 0;
                        using (IDataSession session = Store.OpenSession(false))
                        {
                            mailserver = session.Mailserver.GetList(null);
                        }
                        if (mailserver != null)
                        {
                            sum = (from p in mailserver select p.sendcount).Sum();
                        }
                        if (sum > 0)
                        {
                            for (int i = mailprovider.Count; i > 0; i--)
                            {
                                Imailserviceprovider provider = mailprovider[i - 1];
                                if (sendcount >= sendmaxcount && sendmaxcount > 0) break;
                                string sql = "select top " + sum + " Email,id from mailer where Email like '%" + provider.serviceprovider + "' " + cityidin + " and (sendmailids is null or sendmailids not like '%," + mailtask.id + ",%')";
                                using (IDataSession session = Store.OpenSession(false))
                                {
                                    maildto = session.Custom.Query(sql);
                                }
                                if (maildto.Count == 0)
                                {
                                    using (IDataSession session = Store.OpenSession(false))
                                    {
                                        session.Mailserviceprovider.Delete(provider.id);
                                    }
                                    mailprovider.Remove(provider);
                                }
                                else
                                {
                                    int servernumber = 0;//开始发送
                                    int s = 0;//已发送数量初始值
                                    for (int j = 0; j < maildto.Count; j++)
                                    {
                                        IMailer mailmodel = null;
                                        while (servernumber < mailserver.Count)
                                        {
                                            string updatemailerids = String.Empty;//记录更新已发送的订阅邮件的id
                                            if (mailserver.Count > servernumber && mailserver[servernumber].sendcount > s)
                                            {
                                                IMailserver mailserverrow = mailserver[servernumber];
                                                List<string> address = new List<string>();
                                                address.Add(maildto[j]["Email"].ToString());
                                                bool ok = false;
                                                bool ssl = false;
                                                if (mailserverrow.ssl == 1)
                                                {
                                                    ssl = true;
                                                }
                                                EmailMethod.sendMail(mailtask.subject, mailtask.content + "<img style='display:none' src='" + AS.GroupOn.UrlRewrite.HttpModule.domain + WebRoot + "mailview.aspx?taskid=" + mailtask.id + "&mailerid=" + maildto[j]["id"] + "' />", mailserverrow.sendmail, mailserverrow.realname, address, mailserverrow.smtphost, mailserverrow.smtpport, mailserverrow.mailuser, mailserverrow.mailpass, ssl, mailserverrow.receivemail, out ok);
                                                sendcount = sendcount + 1;
                                                s = s + 1;
                                                updatemailerids = maildto[j]["id"].ToString();
                                                using (IDataSession session = Store.OpenSession(false))
                                                {
                                                    mailmodel = session.Mailers.GetByID(Helper.GetInt(updatemailerids, 0));
                                                }
                                                if (mailmodel != null)
                                                {
                                                    mailmodel.sendmailids = mailmodel.sendmailids + "'," + mailtask.id + ",'";
                                                    using (IDataSession session = Store.OpenSession(false))
                                                    {
                                                        session.Mailers.Update(mailmodel);
                                                    }
                                                }
                                                break;
                                            }
                                            else
                                            {
                                                servernumber = servernumber + 1;
                                                s = 0;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else if (system.mailhost.Length > 0 && system.mailport.Length > 0 && system.mailuser.Length > 0 && system.mailpass.Length > 0 && system.mailfrom.Length > 0)
                        {
                            // System.IO.File.AppendAllText(AppDomain.CurrentDomain.BaseDirectory + "测试邮件群发.txt", "777777777\r\n");
                            for (int i = mailprovider.Count; i > 0; i--)
                            {
                                IMailer mailmodel = null;
                                Imailserviceprovider provider = mailprovider[i - 1];
                                if (sendcount >= sendmaxcount && sendmaxcount > 0) break;
                                string sql = "select top " + samesendcount + " Email,id from mailer where Email like '%" + provider.serviceprovider + "' " + cityidin + " and (sendmailids is null or sendmailids not like '%," + mailtask.id + ",%')";
                                using (IDataSession session = Store.OpenSession(false))
                                {
                                    maildto = session.Custom.Query(sql);
                                }
                                if (maildto.Count == 0)
                                {
                                    using (IDataSession session = Store.OpenSession(false))
                                    {
                                        session.Mailserviceprovider.Delete(provider.id);
                                    }
                                    mailprovider.Remove(provider);
                                }
                                else
                                {
                                    string updatemailerids = String.Empty;//记录更新已发送的订阅邮件的id
                                    for (int j = 0; j < maildto.Count; j++)
                                    {
                                        if (sendcount >= sendmaxcount && sendmaxcount > 0) break;
                                        List<string> address = new List<string>();
                                        if (maildto[j]["Email"] != null && maildto[j]["Email"].ToString() != "")
                                        {
                                            address.Add(maildto[j]["Email"].ToString());
                                            EmailMethod.sendMail(mailtask.subject, mailtask.content + "<img style='display:none' src='" + AS.GroupOn.UrlRewrite.HttpModule.domain + WebRoot + "mailview.aspx?taskid=" + mailtask.id + "&mailerid=" + maildto[j]["id"] + "' />", system.mailfrom, Helper.GetString(_system["mailname"], String.Empty), address, system.mailhost, system.mailuser, system.mailpass);
                                            sendcount = sendcount + 1;
                                            updatemailerids = updatemailerids + "," + maildto[j]["id"];
                                        }
                                    }
                                    if (updatemailerids.Length > 0)
                                    {
                                        updatemailerids = updatemailerids.Substring(1);
                                        using (IDataSession session = Store.OpenSession(false))
                                        {
                                            mailmodel = session.Mailers.GetByID(Helper.GetInt(updatemailerids, 0));
                                        }
                                        if (mailmodel != null)
                                        {
                                            mailmodel.sendmailids = mailmodel.sendmailids + "'," + mailtask.id + ",'";
                                            using (IDataSession session = Store.OpenSession(false))
                                            {
                                                session.Mailers.Update(mailmodel);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if (sendcount > 0)
                        {
                            IMailtasks mt = null;
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                mt = session.Mailtasks.GetByID(mailtask.id);
                            }
                            if (mt != null)
                            {
                                mt.sendcount = mt.sendcount + sendcount;
                                using (IDataSession session = Store.OpenSession(false))
                                {
                                    session.Mailtasks.Update(mt);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                WebUtils.LogWrite(DateTime.Now.ToString("yyyy-MM-dd") + "_senmail", ex.Message);
            }
            run = false;
        }
    }

    //批量更新下线商品
    private void updateTeamEndTime()
    {
     
        //1：判断后台是否开启该功能
        if (PageValue.CurrentSystemConfig != null && PageValue.CurrentSystemConfig["openUpdateTeam"] != null && PageValue.CurrentSystemConfig["openUpdateTeam"].ToString() == "1")
        {
            string selBeforeDay = AS.Common.Utils.Helper.GetString( PageValue.CurrentSystemConfig["UpdateBeforeDay"],"0");//项目下线前n天检测
            //2:判断当前时间是否为后台设置的项目更新时间
            if (PageValue.CurrentSystemConfig["UpdateTeamHour"] != null && PageValue.CurrentSystemConfig["UpdateTeamHour"].ToString() != "")
            {
                if (DateTime.Now.Hour == int.Parse(PageValue.CurrentSystemConfig["UpdateTeamHour"].ToString()))
                {
                    //3:查询满足条件的项目（也就是当天下线的项目）
                    
                    List<Hashtable> nowteams = new List<Hashtable>();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        nowteams = session.Custom.GetTeamIsEndTime(int.Parse(selBeforeDay));
                    }
                    if (nowteams != null && nowteams.Count > 0)
                    {
                        for (int i = 0; i < nowteams.Count; i++)
                        {
                            ITeam nowteam = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                nowteam = session.Teams.GetByID(int.Parse(nowteams[i]["id"].ToString()));
                            }
                            //4:修改项目的结束时间
                            if (nowteam != null)
                            {
                                if (PageValue.CurrentSystemConfig["openUpdateTeamAddDay"] != null && PageValue.CurrentSystemConfig["openUpdateTeamAddDay"].ToString() != "")
                                {
                                    DateTime newEndTime = nowteam.End_time.AddDays(int.Parse(PageValue.CurrentSystemConfig["openUpdateTeamAddDay"].ToString()));
                                    Hashtable hashtable = new Hashtable();
                                    hashtable.Add("ID", nowteam.Id);
                                    hashtable.Add("End_Time", newEndTime);
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        session.Custom.UpdateTeamEndTime(hashtable);
                                    }

                                }
                            }
                        }
                    }
                }
            }

        }



    }

    protected void GetCouptonTime()
    {
        try
        {
           
            //判断是否开启短信订阅，短信用户名密码是否设置，是否开启优惠券到期提醒，优惠券到期时间是否大于0
            if (PageValue.CurrentSystem != null && PageValue.CurrentSystem.smsuser != "" && PageValue.CurrentSystem.smspass != "" && PageValue.CurrentSystemConfig != null && PageValue.CurrentSystemConfig["displayCoupon"] == "1" && PageValue.CurrentSystemConfig["displayCouponDay"] != null && PageValue.CurrentSystemConfig["displayCouponDay"] != "" && Convert.ToInt32(PageValue.CurrentSystemConfig["displayCouponDay"]) > 0)
            {
                //提取提前日期
                int day = Convert.ToInt32(AS.Common.Utils.Helper.GetInt(PageValue.CurrentSystemConfig["displayCouponDay"], 1));
                //查询条件，开始时间<＝提前日期 并且 结束时间>＝当前时间 并且未使用。
                //DataTable dt = Maticsoft.DBUtility.DbHelperSQL.SelectByFilter("mobile", String.Empty, "mobile asc", "(select mobile from coupon inner join [user] on(coupon.user_id=[user].id) where DATEDIFF(day,getdate(),Expire_time)="+day+" and  Consume='N' group by mobile)t");

                List<Hashtable> smsList = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                     smsList= session.Custom.GetSMSSubscribe(DateTime.Now);
                }
                string mobiles = String.Empty;
                if (smsList.Count > 0)
                {
                    
                    for (int i = 0; i < smsList.Count; i++)
                    {
                       mobiles = smsList[i]["Mobile"].ToString();


                        string productname = "";
                        string couponid = "";
                        string couponexpirtime = "";
                        ICoupon couponmodel = null;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            couponmodel = session.Coupon.GetByID(smsList[i]["id"].ToString());
                        }
                      
                        if (couponmodel != null)
                        {
                            couponid = couponmodel.Id;
                            couponexpirtime = couponmodel.Expire_time.ToString();

                            ITeam teammodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                teammodel = session.Teams.GetByID(couponmodel.Team_id);
                            }
                          
                            if (teammodel != null)
                            {
                                productname = teammodel.Product;
                            }

                        }

                        if (mobiles.Length > 0)
                        {

                            //优惠券到期提醒
                            NameValueCollection values = new NameValueCollection();
                            values.Add("网站简称", PageValue.CurrentSystem.abbreviation);

                            values.Add("商品名称", productname);
                            values.Add("优惠券号", couponid);
                            values.Add("到期时间", couponexpirtime);

                            string message =ReplaceStr("overtime", values);
                            AS.GroupOn.Controls.EmailMethod.SendSms(PageValue.CurrentSystem.smsuser, PageValue.CurrentSystem.smspass, mobiles, message);
                        }
                    } 
                }
            

                
            }
        }
        catch (Exception ex)
        {
            AS.Common.Utils.WebUtils.LogWrite("优惠券到期提醒日志", ex.Message);

        }


    }
</script>
