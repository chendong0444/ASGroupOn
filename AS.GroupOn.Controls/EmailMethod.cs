using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.App;
using AS.Common.Utils;
using System.Collections;
using System.Xml;
using System.Web.Caching;
using Module;
namespace AS.GroupOn.Controls
{
    public class EmailMethod
    {
        #region 创建邮件群发任务
        /// <summary>
        /// 创建邮件群发任务
        /// </summary>
        /// <param name="subject">邮件标题</param>
        /// <param name="content">内容</param>
        /// <param name="adminid">管理员ID</param>
        /// <param name="cityid">城市ID 0代表全部</param>
        /// <returns></returns>
        public static string Manager_CreateMailTask(string subject, string content, int adminid, string cityid)
        {
            string error = String.Empty;
            IMailtasks mailtasks = Store.CreateMailtasks();
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mailtasks.subject = subject;
                mailtasks.content = content;
                if (("," + cityid + ",").IndexOf(",0,") < 0)
                {
                    mailtasks.cityid = cityid;
                }
                else
                {
                    mailtasks.cityid = "0";
                    cityid = "0"; //cityid为0代表全部城市发送
                }
                mailtasks.state = 0; //0未发送 1正在发送 2发送完毕 3已暂停 4 已取消
                i = session.Mailtasks.Insert(mailtasks);
                if (i > 0)
                {
                    error = "";
                    int mailtasks_id = session.Mailtasks.GetMaxID();
                    MailerFilter mailerfilter = new MailerFilter();
                    mailerfilter.City_ids = cityid;
                    string wherestr = String.Empty;
                    if (!Helper.isEmpity(cityid))
                        wherestr = " where City_id in(" + cityid + ")";
                    List<Hashtable> hashtable = new List<Hashtable>();
                    hashtable = session.Custom.Query(" select " + mailtasks_id + ",email from (select * from(select COUNT(*) as num,SUBSTRING(Email,CHARINDEX('@',email),LEN(email)) as email from Mailer " + wherestr + " group by SUBSTRING(Email,CHARINDEX('@',email),LEN(email)))t where email like '@%')tt");
                    if (hashtable.Count > 0)
                    {
                        for (int j = 0; j < hashtable.Count; j++)
                        {
                            Imailserviceprovider imailsp = Store.CreateMailserviceprovider();
                            imailsp.mailtasks_id = mailtasks_id;
                            imailsp.serviceprovider = hashtable[j]["email"].ToString();
                            session.Mailserviceprovider.Insert(imailsp); //插入记录
                        }
                    }
                    int totalcount = session.Mailers.GetCountByCityId(mailerfilter);
                    mailtasks.totalcount = totalcount;
                    mailtasks.id = mailtasks_id;
                    session.Mailtasks.Update(mailtasks); //修改发送数量
                }
                else
                {
                    error = "任务创建失败";
                }
            }
            return error;
        }
        #endregion

        #region 手机发送信息

        #region 手机发送信息
        public static bool SendSMS(List<string> mobiles, string content)
        {
            bool ok = false;
            if (PageValue.CurrentSystem.smsuser == String.Empty || PageValue.CurrentSystem.smspass == String.Empty) return false;
            string mobile = String.Empty;
            for (int i = 0; i < mobiles.Count; i++)
            {
                mobile = mobile + "," + mobiles[i];
            }
            if (mobile.Length > 0)
                mobile = mobile.Substring(1);
            ok = SendSms(PageValue.CurrentSystem.smsuser, PageValue.CurrentSystem.smspass, mobile, content);
            return ok;
        }
        #endregion

        #region 手机发送信息相关方法
        public static bool SendSms(string username, string password, string phone, string message)
        {
            bool ok = false;

            if (phone.Length > 0)
            {
                ISMS sms = SMSModule;
                if (sms != null)
                {
                    ok = sms.SendSMS(username, password, phone, message);
                }
            }
            return ok;

        }

        private static string cachefile = AppDomain.CurrentDomain.BaseDirectory + "module.config";
        public static ISMS SMSModule
        {
            get
            {
                ISMS sms = null;
                if (System.Web.HttpContext.Current == null || System.Web.HttpContext.Current.Cache["sms"] == null)
                {
                    XmlNode node = GetModuleNode("sms");
                    if (node != null)
                    {
                        string typename = node.Attributes["typename"].Value;
                        string assemblyname = node.Attributes["assemblyname"].Value;

                        sms = (ISMS)Activator.CreateInstance(assemblyname, typename).Unwrap();
                        if (System.Web.HttpContext.Current != null)
                            System.Web.HttpContext.Current.Cache.Add("sms", sms, new CacheDependency(cachefile), System.Web.Caching.Cache.NoAbsoluteExpiration, System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Normal, null);
                    }


                }
                else
                    sms = (ISMS)System.Web.HttpContext.Current.Cache["sms"];
                return sms;

            }
        }
        private static XmlNode GetModuleNode(string name)
        {
            XmlDocument xmldoc = new XmlDocument();
            xmldoc.Load(cachefile);
            XmlNode node = xmldoc.SelectSingleNode("//module[@name='" + name + "']");
            return node;
        }
        #endregion

        #endregion

        #region 发送邮件

        #region 发送邮件
        /// <summary>
        /// 发送邮件
        /// </summary>
        /// <param name="toMails">发往邮件地址</param>
        /// <param name="subject">主题</param>
        /// <param name="body">内容</param>
        /// <returns></returns>
        public static bool SendMail(List<string> toMails, string subject, string body, out string error)
        {

            //_system = sysmodel.GetSystem();
            bool sendOK = false;
            error = String.Empty;
            if (PageValue.CurrentSystem == null)
            {
                return sendOK;
            }
            if (PageValue.CurrentSystem.mailfrom == String.Empty || PageValue.CurrentSystem.mailhost == String.Empty || PageValue.CurrentSystem.mailpass == String.Empty || PageValue.CurrentSystem.mailuser == String.Empty)
            {
                return sendOK;
            }

            if (toMails.Count == 0 || subject == String.Empty || body == String.Empty) return sendOK;
            int port = Helper.GetInt(PageValue.CurrentSystem.mailport, 0);
            if (port == 0) port = 25;

            string mailFromName = "";
            if (PageValue.CurrentSystemConfig["mailname"] != null && PageValue.CurrentSystemConfig["mailname"].ToString() != "")
            {
                mailFromName = PageValue.CurrentSystemConfig["mailname"];
            }
            else
            {
                mailFromName = PageValue.CurrentSystem.mailfrom;
            }
            error = sendMail(subject, body, PageValue.CurrentSystem.mailfrom, mailFromName, toMails, PageValue.CurrentSystem.mailhost, port, PageValue.CurrentSystem.mailuser, PageValue.CurrentSystem.mailpass, Helper.GetBool(PageValue.CurrentSystem.mailssl,false), PageValue.CurrentSystem.mailreply, out sendOK);
            return sendOK;

        }
        #endregion

        #region 发送邮件相关方法
        public static string sendMail(string mailSubjct, string mailBody, string mailFrom, string mailFromName, List<string> mailAddress, string HostIP, int port, string username, string password, bool ssl, string replyTo, out bool sendOK) //发送邮件
        {
            sendOK = true;
            string error = "";
            try
            {
                System.Net.Mail.MailMessage mm = new System.Net.Mail.MailMessage();
                mm.IsBodyHtml = false;
                mm.Subject = mailSubjct;
                mm.Body = mailBody;
                mm.IsBodyHtml = true;
                if (!String.IsNullOrEmpty(mailFromName))
                    mm.From = new System.Net.Mail.MailAddress(mailFrom, mailFromName, Encoding.UTF8);
                else
                    mm.From = new System.Net.Mail.MailAddress(mailFrom);
                if (!String.IsNullOrEmpty(replyTo))
                {
                    System.Net.Mail.MailAddress replyToAddress = new System.Net.Mail.MailAddress(replyTo);
                    mm.ReplyTo = replyToAddress;
                }
                System.Text.RegularExpressions.Regex regex = new System.Text.RegularExpressions.Regex(@"\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*");

                for (int i = 0; i < mailAddress.Count; i++)
                {
                    if (regex.IsMatch(mailAddress[i]))
                        mm.To.Add(mailAddress[i]);
                }
                if (mm.To.Count == 0)
                {
                    return String.Empty;
                }
                System.Net.Mail.SmtpClient sc = new System.Net.Mail.SmtpClient();
                sc.EnableSsl = ssl;
                sc.UseDefaultCredentials = false;
                System.Net.NetworkCredential nc = new System.Net.NetworkCredential(username, password);
                sc.Credentials = nc;
                sc.DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network;
                sc.Host = HostIP;
                sc.Port = port;
                sc.Send(mm);
            }
            catch (Exception ex)
            {
                error = ex.Message;
                sendOK = false;
            }
            return error;
        }
        #endregion

        #endregion

        public static bool sendMail(string mailSubjct, string mailBody, string mailFrom, string mailFromName, List<string> mailAddress, string HostIP, string username, string password) //发送邮件
        {
            bool sendOK;
            string error = sendMail(mailSubjct, mailBody, mailFrom, mailFromName, mailAddress, HostIP, 25, username, password, false, String.Empty, out sendOK);
            return sendOK;
        }


        /// <summary>
        /// 返回登陆邮箱的网址
        /// </summary>
        /// <param name="email">邮箱地址</param>
        /// <returns></returns>
        public static string GetEMailLoginUrl(string email)
        {
            if (email == String.Empty || email.IndexOf("@") <= 0)
                return String.Empty;
            int pos = email.IndexOf("@");
            //谷歌邮箱
            if (email.Substring(pos + 1) == "gmail.com")
            {
                email = "http://mail.google.com";
            }
            else
            {
                email = "http://mail." + email.Substring(pos + 1);
            }
            return email;

        }
    }
}
