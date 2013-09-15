#region 命名空间
using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using AS.Common.Utils;
using AS.GroupOn.App;
using AS.GroupOn.Controls;
using System.Xml;
using System.Reflection;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess.Accessor;
using System.IO;
using System.Collections.Specialized;
using System.Timers;
using System.Net;
using AS.Common;
using AS.GroupOn;
using AS.GroupOn.Domain;
using System.Linq;
using System.Collections;
using AS.GroupOn.DataAccess.Spi;
#endregion

namespace AS.GroupOn.UrlRewrite
{
    public class HttpModule : IHttpModule
    {

        public void Dispose()
        {

        }
        private static Timer timer = null;
        public static string domain = String.Empty;
        public static bool run = false;//邮件群发正在执行
        public static string url = String.Empty;
        public void Init(HttpApplication context)
        {
            //处理url路径
            context.BeginRequest += new EventHandler(context_BeginRequest);
            //处理session
            context.AcquireRequestState += new EventHandler(context_AcquireRequestState);
            if (PageValue.GetConnectString() != "")
            {
                ISystem system = null;
                domain = FileUtils.GetConfig()["domain"];
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    system = session.System.GetByID(1);
                }
                if (system != null && system.domain == null && domain != String.Empty)
                {
                    system.domain = domain;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.System.Update(system);
                    }
                }
                if (domain != String.Empty)
                {
                    UpdateDatabase();
                    if (timer == null)
                    {
                        timer = new Timer();
                        timer.Elapsed += new ElapsedEventHandler(timer_Elapsed);
                        timer.Interval = 60000;
                        timer.Enabled = true;
                        timer.Start();
                    }
                }
            }
        }

        void context_BeginRequest(object sender, EventArgs e)
        {
            HttpApplication app = sender as HttpApplication;
            HttpContext context = app.Context;
            PageValue.Url = context.Request.Url.AbsoluteUri;
            PageValue.Uri = context.Request.Url;
            url = UrlMapper.GetMapperUrl();
            if (url.Length > 0) app.Context.RewritePath(url);
        }


        #region 数据库升级
        /// <summary>
        /// 修改数据库信息
        /// </summary>
        private void UpdateDatabase()
        {
            try
            {

                WebClient wc = new WebClient();
                wc.DownloadStringCompleted += new DownloadStringCompletedEventHandler(wc_DownloadStringCompleted);
                wc.DownloadStringAsync(new Uri(domain + "/Task/Task.aspx?mode=database"));
                wc.Dispose();

            }
            catch (Exception ex)
            {
                AS.Common.Utils.WebUtils.LogWrite("计划任务", ex.Message + ex.Source + ex.StackTrace + ex.TargetSite.ToString());
            }
        }
        #endregion

        void timer_Elapsed(object sender, ElapsedEventArgs e)
        {
            //数据库升级


            #region 网站授权
            try
            {

                if (DateTime.Now.Day == 28 && DateTime.Now.Hour == 2 && DateTime.Now.Minute == 0)
                {
                    AS.Common.Utils.WebUtils.LogWrite("网站授权", "url=" + domain);
                    if (domain != "")
                    {
                        string webname = domain;
                        if (webname.Substring(webname.Length - 1, 1) == "/")
                        {
                            webname = webname.Substring(0, webname.Length - 1);
                        }

                        AS.Common.Utils.WebUtils.CheckRecord(GetRecord(webname));
                    }
                }
            }
            catch (Exception ex)
            {

                AS.Common.Utils.WebUtils.LogWrite("计划任务", ex.Message + ex.Source + ex.StackTrace + ex.TargetSite.ToString());
            }

            #endregion


            #region 群发邮件
            try
            {

                WebClient wc = new WebClient();
                wc.DownloadStringCompleted += new DownloadStringCompletedEventHandler(wc_DownloadStringCompleted);
                wc.DownloadStringAsync(new Uri(domain + "/Task/Task.aspx?mode=sendMail"));
                wc.Dispose();
            }
            catch (Exception ex)
            {
                AS.Common.Utils.WebUtils.LogWrite("计划任务", ex.Message + ex.Source + ex.StackTrace + ex.TargetSite.ToString());
            }

            #endregion

            #region 变更项目购买人数now_number
            try
            {

                //if (DateTime.Now.Hour == 0 && DateTime.Now.Minute == 0)
                //{

                    WebClient wc = new WebClient();
                    wc.DownloadStringCompleted += new DownloadStringCompletedEventHandler(wc_DownloadStringCompleted);
                    wc.DownloadStringAsync(new Uri(domain + "/Task/Task.aspx?mode=teamnownumber"), "teamnownumber");
                    wc.Dispose();

                //}
            }
            catch (Exception ex)
            {
                AS.Common.Utils.WebUtils.LogWrite("计划任务", ex.Message + ex.Source + ex.StackTrace + ex.TargetSite.ToString());
            }

            #endregion


            #region 短信提醒
            try
            {

                if (DateTime.Now.Hour == 12 && DateTime.Now.Minute == 10)
                {

                    WebClient wc = new WebClient();
                    wc.DownloadStringCompleted += new DownloadStringCompletedEventHandler(wc_DownloadStringCompleted);
                    wc.DownloadStringAsync(new Uri(domain + "/Task/Task.aspx?mode=sms"), "sms");
                    wc.Dispose();

                }
            }
            catch (Exception ex)
            {
                AS.Common.Utils.WebUtils.LogWrite("计划任务", ex.Message + ex.Source + ex.StackTrace + ex.TargetSite.ToString());
            }
            #endregion



            #region 批量更新项目结束时间
            try
            {

                WebClient wc = new WebClient();
                wc.DownloadStringCompleted += new DownloadStringCompletedEventHandler(wc_DownloadStringCompleted);
                wc.DownloadStringAsync(new Uri(domain + "/Task/Task.aspx?mode=updateTeamEndtime"), "updateTeamEndtime");
                wc.Dispose();
            }
            catch (Exception ex)
            {
                AS.Common.Utils.WebUtils.LogWrite("计划任务", ex.Message + ex.Source + ex.StackTrace + ex.TargetSite.ToString());
            }
            #endregion



        }

        #region 邮件群发
        private static void sendMail()
        {
            if (!run)
            {
                run = true;
                NameValueCollection _system = PageValue.CurrentSystemConfig;
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
                                                    EmailMethod.sendMail(mailtask.subject, mailtask.content + "<img style='display:none' src='" + url + "mailview.aspx?taskid=" + mailtask.id + "&mailerid=" + maildto[j]["id"] + "' />", mailserverrow.sendmail, mailserverrow.realname, address, mailserverrow.smtphost, mailserverrow.smtpport, mailserverrow.mailuser, mailserverrow.mailpass, ssl, mailserverrow.receivemail, out ok);
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
                                                EmailMethod.sendMail(mailtask.subject, mailtask.content + "<img style='display:none' src='" + url + "mailview.aspx?taskid=" + mailtask.id + "&mailerid=" + maildto[j]["id"] + "' />", system.mailfrom, Helper.GetString(_system["mailname"], String.Empty), address, system.mailhost, system.mailuser, system.mailpass);
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
        #endregion

        #region 异常日志

        void wc_DownloadStringCompleted(object sender, DownloadStringCompletedEventArgs e)
        {
            string userState = e.UserState as string;
            if (e.Error != null)
            {
                switch (userState)
                {
                    case "teamnownumber":
                        AS.Common.Utils.WebUtils.LogWrite("计划任务", e.Error.Message + e.Error.Source + e.Error.StackTrace + e.Error.TargetSite.ToString());
                        break;
                    case "sms":
                        AS.Common.Utils.WebUtils.LogWrite("计划任务", e.Error.Message + e.Error.Source + e.Error.StackTrace + e.Error.TargetSite.ToString());
                        break;
                }
            }
            else
            {

            }
        }
        #endregion

        #region   验证站点 是否收录
        /// <summary>
        /// 站点 验证
        /// </summary>
        /// <param name="website">站点</param>
        /// <returns>0未收录 ； 1收录</returns>
        public static int GetRecord(string website)
        {
            int result = 0;
            string lowerStr = website.ToLower();

            if (!lowerStr.Contains("http://"))
            {
                lowerStr = "http://" + lowerStr;
            }
            if (lowerStr.Contains("//www."))
            {
                lowerStr = lowerStr.Replace("www.", "");
            }
            bool validate = AS.Common.Utils.Helper.ValidateString(lowerStr, "url");
            AS.Common.Utils.WebUtils.LogWrite("网站授权", "手动授权validate=" + validate + ";url=" + lowerStr);
            if (lowerStr.Contains("http://127.0.0.1") || lowerStr.Contains("http://localhost") || lowerStr.Contains(".gotocdn.com"))
            {
                result = 1;
            }
            else
            {
                //bool validateIP = Regex.IsMatch(lowerStr, @"(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])", RegexOptions.IgnoreCase);
                if (validate)
                {
                    try
                    {
                        AS.GroupOn.UrlRewrite.WebCheckRecord.WSSelectUrl site = new WebCheckRecord.WSSelectUrl();

                        result = site.SelectUrl(lowerStr);
                    }
                    catch (Exception ex)
                    {

                        result = 0;
                        AS.Common.Utils.WebUtils.LogWrite("网站授权", "url=" + lowerStr + ";ex=" + ex.Message);
                    }
                }
                else
                {
                    result = 0;
                }
            }
            return result;
        }
        #endregion


        void context_AcquireRequestState(object sender, EventArgs e)
        {

            HttpApplication app = sender as HttpApplication;
            HttpContext context = app.Context;
            if (PageValue.GetConnectString() != "")
            {
                Init();
            }
            HttpRequest request = context.Request;
            if (request.HttpMethod == "POST")//如果是post请求
            {
                string action = request.Form["action"];
                if (!String.IsNullOrEmpty(action))//是提交动作
                {
                    XmlNode node = GetActionNode(action);
                    if (node != null)
                    {
                        string resulttype = node.Attributes["resulttype"].Value;
                        List<string> err = new List<string>();
                        XmlNodeList nodelist = node.ChildNodes;
                        object[] values = new object[nodelist.Count];
                        for (int i = 0; i < nodelist.Count; i++)
                        {
                            XmlNode childNode = nodelist[i];
                            string name = childNode.Attributes["name"].Value;
                            string datatype = childNode.Attributes["datatype"].Value;
                            bool require = Helper.GetBool(childNode.Attributes["require"].Value, false);
                            int length = Helper.GetInt(childNode.Attributes["length"].Value, 0);
                            string format = childNode.Attributes["format"].Value;
                            string errmsg = childNode.Attributes["errmsg"].Value;
                            string defaultvalue = childNode.Attributes["defaultvalue"].Value; //默认值
                            string htmlencode = childNode.Attributes["htmlencode"].Value;//是否需要html编码
                            /////
                            PageValue.SetErrorData(name, request.Form[name]);
                            if (datatype == "string")//字符串类型
                            {
                                string val = Helper.GetString(request.Form[name], String.Empty);
                                if (htmlencode == "true" && val.Length > 0)
                                {
                                    val = HttpContext.Current.Server.HtmlEncode(val);
                                }
                                if (require)
                                {
                                    if (String.IsNullOrEmpty(val))
                                    {
                                        err.Add(String.Format(errmsg, "为必填项，不能为空"));
                                    }
                                }
                                if (length > 0 && StringUtils.GetStringByteLength(val) > length)
                                {
                                    err.Add(String.Format(errmsg, "长度应小于" + length + "个字符,一个汉字为2个字符"));
                                }
                                if (val.Length > 0 && !String.IsNullOrEmpty(format))
                                {
                                    if (!StringUtils.ValidateString(val, format))
                                    {
                                        err.Add(String.Format(errmsg, "格式不正确"));
                                    }
                                }
                                if (defaultvalue != String.Empty && val == String.Empty)
                                {
                                    val = defaultvalue;
                                }
                                values[i] = val;
                            }
                            else if (datatype == "int")
                            {
                                int? val = null;
                                if (require)
                                {
                                    val = Helper.GetInt(request.Form[name], 0);
                                    if (val.Value.ToString() != request.Form[name])
                                    {
                                        err.Add(String.Format(errmsg, "格式不正确"));
                                    }
                                }
                                if (defaultvalue != String.Empty && !val.HasValue)
                                {
                                    val = Helper.GetInt(defaultvalue, 0);
                                }
                                values[i] = val;
                            }
                            else if (datatype == "long")
                            {
                                long? val = null;
                                if (require)
                                {
                                    val = Helper.GetLong(request.Form[name], 0);
                                    if (val.Value.ToString() != request.Form[name])
                                    {
                                        err.Add(String.Format(errmsg, "格式不正确"));
                                    }
                                }
                                if (defaultvalue != String.Empty && !val.HasValue)
                                {
                                    val = Helper.GetLong(defaultvalue, 0);
                                }
                                values[i] = val;
                            }
                            else if (datatype == "decimal")
                            {
                                decimal? val = null;
                                if (require)
                                {
                                    val = Helper.GetDecimal(request.Form[name], 0);
                                    if (val.Value.ToString() != request.Form[name])
                                    {
                                        err.Add(String.Format(errmsg, "格式不正确"));
                                    }
                                }
                                if (defaultvalue != String.Empty && !val.HasValue)
                                {
                                    val = Helper.GetDecimal(defaultvalue, 0);
                                }
                                values[i] = val;
                            }
                            else if (datatype == "datetime")
                            {
                                DateTime? val = null;
                                if (require)
                                {
                                    val = Helper.GetDateTime(request.Form[name], DateTime.MinValue);
                                    if (val.Value.ToString() != request.Form[name])
                                    {
                                        err.Add(String.Format(errmsg, "格式不正确"));
                                    }
                                }
                                if (defaultvalue != String.Empty && !val.HasValue)
                                {
                                    val = Helper.GetDateTime(defaultvalue, DateTime.Now);
                                }
                                values[i] = val;
                            }
                            else if (datatype == "float")
                            {
                                float? val = null;
                                if (require)
                                {
                                    val = Helper.GetFloat(request.Form[name], 0);
                                    if (val.Value.ToString() != request.Form[name])
                                    {
                                        err.Add(String.Format(errmsg, "格式不正确"));
                                    }
                                }
                                if (defaultvalue != String.Empty && !val.HasValue)
                                {
                                    val = Helper.GetFloat(defaultvalue, 0);
                                }
                                values[i] = val;
                            }
                            else if (datatype == "double")
                            {
                                double? val = null;
                                if (require)
                                {
                                    val = Helper.GetDouble(request.Form[name], 0);
                                    if (val.Value.ToString() != request.Form[name])
                                    {
                                        err.Add(String.Format(errmsg, "格式不正确"));
                                    }
                                }
                                if (defaultvalue != String.Empty && !val.HasValue)
                                {
                                    val = Helper.GetDouble(defaultvalue, 0);
                                }
                                values[i] = val;
                            }
                            else if (datatype == "bool")
                            {
                                bool? val = null;
                                if (require)
                                {
                                    val = Helper.GetBool(request.Form[name], false);
                                    if (val.Value.ToString() != request.Form[name])
                                    {
                                        err.Add(String.Format(errmsg, "格式不正确"));
                                    }
                                }
                                if (defaultvalue != String.Empty && !val.HasValue)
                                {
                                    val = Helper.GetBool(defaultvalue, false);
                                }
                                values[i] = val;
                            }
                        }
                        if (err.Count == 0)
                        {
                            object obj = Activator.CreateInstance(node.Attributes["assemblyName"].Value, node.Attributes["typeName"].Value).Unwrap();
                            MethodInfo method = obj.GetType().GetMethod(node.Attributes["methodName"].Value);
                            obj = method.Invoke(obj, values);
                            if (obj is JavaScriptResult)
                            {
                                JavaScriptResult result = obj as JavaScriptResult;
                                result.Execute();
                                PageValue.GetMessage();
                            }
                            else if (obj is JsonResult)
                            {
                                JsonResult result = obj as JsonResult;
                                result.Execute();
                                PageValue.GetMessage();
                            }
                            else if (obj is RedirctResult)
                            {
                                RedirctResult result = obj as RedirctResult;
                                result.Execute();
                                PageValue.GetMessage();
                            }
                        }
                        else
                        {
                            if (resulttype == "json")
                            {
                                JsonResult result = new JsonResult(err[0], "alert", false);
                                result.Execute();
                                PageValue.GetMessage();
                            }
                            else if (resulttype == "javascript")
                            {
                                JavaScriptResult result = new JavaScriptResult("alert('" + err[0] + "');", false);
                                result.Execute();
                                PageValue.GetMessage();
                            }
                            else if (resulttype == "showmessage")
                            {
                                ShowMessageResult result = new ShowMessageResult(err[0], false, false);
                                result.Execute();
                                PageValue.GetMessage();
                            }
                        }

                    }
                }
            }
        }

        private XmlNode GetActionNode(string action)
        {
            XmlNode node = null;

            XmlDocument xmldoc = new XmlDocument();
            StringBuilder builder = new StringBuilder();
            builder.Append(File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory + "bin\\post.config"));
            ////
            builder.Append(File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory + "bin\\post1.config"));//开始

            builder.Append(File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory + "bin\\postYX.config"));

            builder.Append(File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory + "bin\\AppPost.config"));

            builder.Append(File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory + "bin\\postend.config"));//结束
            ////
            xmldoc.LoadXml(builder.ToString());

            node = xmldoc.SelectSingleNode("descendant::action[@actionName='" + action + "']");
            //xmldoc.Load(AppDomain.CurrentDomain.BaseDirectory + "bin\\post.config");
            return node;
        }

        #region 初始化

        private void Init()
        {
            //设置登录用户信息
            string username = String.Empty;
            try
            {
                username = CookieUtils.GetCookieValue("username", FileUtils.GetKey());
            }
            catch
            {
                CookieUtils.ClearCookie("username");
            }
            if (username.Length > 0 && PageValue.CurrentUser == null)
            {
                UserFilter uf = new UserFilter();
                uf.LoginName = username;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    PageValue.CurrentUser = session.Users.Get(uf);
                }
                if (PageValue.CurrentUser != null && PageValue.CurrentUser.Manager.ToUpper() == "Y")
                {
                    PageValue.CurrentAdmin = PageValue.CurrentUser;
                }
            }
            if (WebUtils.GetLoginAdminID() > 0)
            {
                UserFilter uf = new UserFilter();
                uf.ID = Helper.GetInt(WebUtils.GetLoginAdminID(), 0);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    PageValue.CurrentAdmin = session.Users.Get(uf);
                }
            }
            //设置system
            if (PageValue.CurrentSystem == null)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    PageValue.CurrentSystem = session.System.GetByID(1);
                }
            }

            //设置system配置文件
            object obj = new object();
            NameValueCollection _system = null;
            if (PageValue.CurrentSystemConfig == null)
            {
                lock (obj)
                {

                    if (HttpContext.Current.Items["CurrentSystemConfig"] == null || HttpContext.Current.Cache == null || HttpContext.Current == null)
                    {
                        //read xml
                        string path = AppDomain.CurrentDomain.BaseDirectory + "config\\data.config";
                        WebUtils.initSystemConfig();
                        NameValueCollection nvc = new NameValueCollection();
                        XmlDocument Doc_Detail = new XmlDocument();
                        Doc_Detail.Load((path));
                        XmlNodeList NodeList = Doc_Detail.SelectNodes("/root/system/*");
                        if (NodeList.Count > 0)
                        {
                            for (int i = 0; i < NodeList.Count; i++)
                            {

                                if (NodeList[i] != null)
                                {
                                    nvc.Add(NodeList[i].Name, NodeList[i].InnerText);
                                }

                            }
                        }
                        _system = nvc;
                        if (HttpContext.Current != null)
                            HttpContext.Current.Cache.Add("CurrentSystemConfig", nvc, new System.Web.Caching.CacheDependency(HttpContext.Current.Server.MapPath("/config/data.config")), System.Web.Caching.Cache.NoAbsoluteExpiration, System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Default, null);
                    }
                    else
                    {
                        _system = (NameValueCollection)HttpContext.Current.Cache["CurrentSystemConfig"];

                    }
                }
            }
        }

        #endregion
    }
}
