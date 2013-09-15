using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.App;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.Controls;
using AS.Common.Utils;
using System.Data;
using System.Web;

namespace AS.AdminEvent
{
    /// <summary>
    /// 营销事件
    /// </summary>
    public class MarketingEvent
    {
        private static RedirctResult result = null;
        #region 友情链接
        /// <summary>
        /// 添加友情链接
        /// </summary>
        /// <param name="strTitle">网站名称</param>
        /// <param name="strUrl">网站网址</param>
        /// <param name="strLog">LOGO地址</param>
        /// <param name="strSort">排序(降序)</param>
        /// <returns></returns>
        public static RedirctResult AddFriendLink(string strTitle, string strUrl, string strLog, int strSort)
        {
            IFriendLink friendlink = Store.CreateFriendLink();
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                friendlink.Title = strTitle;
                friendlink.url = strUrl;
                friendlink.Logo = strLog;
                friendlink.Sort_order = strSort;
                i = session.FriendLink.Insert(friendlink);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
            result = new RedirctResult("Index-YouqingLianjie.aspx", true);
            return result;
        }

        /// <summary>
        /// 修改友情链接
        /// </summary>
        /// <param name="strTitle">网站名称</param>
        /// <param name="strUrl">网站网址</param>
        /// <param name="strLog">LOGO地址</param>
        /// <param name="strSort">排序(降序)</param>
        /// <param name="strId">Id</param>
        /// <returns></returns>
        public static RedirctResult UpdateFriendLink(string strTitle, string strUrl, string strLog, int strSort, int strId)
        {
            IFriendLink friendlink = Store.CreateFriendLink();
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                friendlink.Title = strTitle;
                friendlink.url = strUrl;
                friendlink.Logo = strLog;
                friendlink.Sort_order = strSort;
                friendlink.Id = strId;
                i = session.FriendLink.Update(friendlink);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("更新成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("更新失败", false, false));
            result = new RedirctResult("Index-YouqingLianjie.aspx", true);
            return result;
        }
        #endregion

        #region 代金劵
        /// <summary>
        /// 新建代金劵
        /// </summary>
        /// <param name="strPartnerId">商户ID</param>
        /// <param name="strTeamId">项目ID</param>
        /// <param name="strCredit">代金券面额</param>
        /// <param name="strQuantity">生成数量</param>
        /// <param name="strBeginTime">开始日期</param>
        /// <param name="strEndTime">结束日期</param>
        /// <param name="strCode">行动代号</param>
        /// <param name="strConsume">是否已使用</param>
        /// <param name="strIp">IP</param>
        /// <returns></returns>
        public static RedirctResult AddDaiJinQuan(int strPartnerId, int strTeamId, int strCredit, int strQuantity, string strBeginTime, string strEndTime, string strCode, string strConsume, string strIp)
        {
            if (strQuantity <= 1000)
            {
                for (int j = 0; j < strQuantity; j++)
                {
                    ICard card = Store.CreateCard();
                    card.Partner_id = strPartnerId;
                    card.Team_id = strTeamId;
                    card.Credit = strCredit;
                    card.Begin_time = Convert.ToDateTime(strBeginTime);
                    card.End_time = Convert.ToDateTime(strEndTime + " 23:59:59");
                    card.Code = strCode;
                    string couponNum = GetRandomString(16); //代金券规则
                    string NewcouponNum = "";
                    getCouponID(couponNum, 16, ref NewcouponNum);
                    card.Id = NewcouponNum;
                    card.Ip = strIp;
                    card.consume = strConsume;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.Card.Insert(card);
                    }
                }
                PageValue.SetMessage(new ShowMessageResult("生成" + strQuantity + "张代金券成功", true, true));
            }
            else
            {
                PageValue.SetMessage(new ShowMessageResult("代金券每次只能生产1-1000张", false, false));
            }
            result = new RedirctResult("Youhui_WeiDaijinquan.aspx", true);
            return result;
        }

        /// <summary>
        /// //代金券规则
        /// </summary>
        public static string GetRandomString(int bit)
        {
            System.Random ran = new Random();
            string val = ran.Next(1, 10).ToString();


            for (int i = 1; i < bit; i++)
            {
                val = val + ran.Next(0, 10).ToString();
            }

            return val;

        }

        /// <summary>
        /// 得到一个不重复的优惠券号
        /// </summary>
        /// <param name="couponNum">需要验证的优惠券id</param>
        /// <param name="length">优惠券长度</param>
        /// <param name="newcouponid">有效的优惠券id</param>
        public static void getCouponID(string couponNum, int length, ref string newcouponid)
        {
            ICard icoupon = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                icoupon = session.Card.GetByID(couponNum);
            }
            if (icoupon == null)
            {
                newcouponid = couponNum;
                return;
            }
            else
            {
                getCouponID(GetRandomString(16), length, ref newcouponid);
                return;
            }

        }
        #endregion

        #region api分类
        /// <summary>
        /// 新建api分类|子分类
        /// </summary>
        /// <param name="strZone">类别</param>
        /// <param name="strCzone">自定义分组</param>
        /// <param name="strName">中文名称</param>
        /// <param name="strEname">英文名称</param>
        /// <param name="strLetter">首字母</param>
        /// <param name="strSort_order">排序(降序)</param>
        /// <param name="strDisplay">导航显示(Y/N)</param>
        /// <param name="strContent">城市公告</param>
        /// <param name="strCity_pid">二级城市Id</param>
        /// <returns></returns>
        public static RedirctResult AddApiClass(string strZone, string strCzone, string strName, string strEname, string strLetter, int strSort_order, string strDisplay, string strContent, int strCity_pid)
        {
            ICategory category = Store.CreateCategory();
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                category.Zone = strZone;
                category.Czone = strCzone;
                category.Name = strName;
                category.Ename = strEname;
                category.Letter = strLetter;
                category.Sort_order = strSort_order;
                category.Display = strDisplay;
                category.content = strContent;
                category.City_pid = strCity_pid;

                i = session.Category.Insert(category);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
            result = new RedirctResult("Type_XiangmuFenlei.aspx", true);
            return result;
        }

        /// <summary>
        /// 修改api分类|子分类
        /// </summary>
        /// <param name="strZone">类别</param>
        /// <param name="strCzone">自定义分组</param>
        /// <param name="strName">中文名称</param>
        /// <param name="strEname">英文名称</param>
        /// <param name="strLetter">首字母</param>
        /// <param name="strSort_order">排序(降序)</param>
        /// <param name="strDisplay">导航显示(Y/N)</param>
        /// <param name="strContent">城市公告</param>
        /// <param name="strCity_pid">二级城市Id</param>
        /// <param name="strId">Id</param>
        /// <returns></returns>
        public static RedirctResult UpdateApiClass(string strZone, string strCzone, string strName, string strEname, string strLetter, int strSort_order, string strDisplay, string strContent, int strCity_pid, int strId)
        {
            ICategory category = Store.CreateCategory();
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                category.Zone = strZone;
                category.Czone = strCzone;
                category.Name = strName;
                category.Ename = strEname;
                category.Letter = strLetter;
                category.Sort_order = strSort_order;
                category.Display = strDisplay;
                category.content = strContent;
                category.City_pid = strCity_pid;
                category.Id = strId;
                i = session.Category.Update(category);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
            result = new RedirctResult("Type_XiangmuFenlei.aspx", true);
            return result;
        }
        #endregion

        #region 邮件
        /// <summary>
        /// 新增群发邮件
        /// </summary>
        /// <param name="strSubject">网站名称</param>
        /// <param name="strUrl">邮件地址</param>
        /// <param name="strGbk">utf-8|gb2312</param>
        /// <param name="strCityall">全部城市ID</param>
        /// <param name="strSeCity">选择的城市ID</param>
        /// <param name="strNostartteam">包含未开始项目</param>
        /// <returns></returns>
        public static RedirctResult AddMailtasks(string strSubject, string strUrl, string strGbk, string strCityall, string strSeCity, string strNostartteam)
        {
            string cityid = strCityall + "," + Helper.GetString(strSeCity, String.Empty);
            cityid = cityid.TrimStart(',').TrimEnd(',');
            string strContent = "";

            if (strUrl != "" && strUrl != null)
            {
                strContent = Helper.GetHtml(strUrl, strGbk);
            }
            else
            {
                strContent = WebUtils.LoadPageString(PageValue.WebRoot + "MailTemplate/mail.aspx?cityid=" + cityid + "&nostartteam=" + strNostartteam);
                string str = PageValue.WWWprefix;
                strContent = strContent.Replace("../", "" + PageValue.WWWprefix + "");
                strContent = strContent.Replace("..", "");
            }
            EmailMethod.Manager_CreateMailTask(strSubject, (strContent), PageValue.CurrentAdmin.Id, cityid);
            PageValue.SetMessage(new ShowMessageResult("创建成功", true, true));
            result = new RedirctResult("MailtasksList.aspx", true);
            return result;
        }

        /// <summary>
        /// 修改群发邮件
        /// </summary>
        /// <param name="strSubject">网站名称</param>
        /// <param name="strUrl">邮件地址</param>
        /// <param name="strGbk">utf-8|gb2312</param>
        /// <param name="strCityall">全部城市ID</param>
        /// <param name="strSeCity">选择的城市ID</param>
        /// <param name="strNostartteam">包含未开始项目</param>
        /// <param name="strId">Id</param>
        /// <returns></returns>
        public static RedirctResult UpdateMailtasks(string strSubject, string strUrl, string strGbk, string strCityall, string strSeCity, string strNostartteam, int strId)
        {
            string cityid = strCityall + "," + Helper.GetString(strSeCity, String.Empty);
            cityid = cityid.TrimStart(',').TrimEnd(',');
            string strContent = "";
            if (strUrl != "" && strUrl != null)
            {
                strContent = Helper.GetHtml(strUrl, strGbk);
            }
            else
            {
                strContent = WebUtils.LoadPageString(PageValue.WebRoot + "MailTemplate/mail.aspx?cityid=" + cityid + "&nostartteam=" + strNostartteam);
                string str = PageValue.WWWprefix;
                WebUtils.LogWrite("群发邮箱日志记录", "str=" + str);
                if (str.IndexOf("http://") >= 0)
                {
                    str = str.Substring(7);
                }
                WebUtils.LogWrite("群发邮箱日志记录", "str1=" + str);
                WebUtils.LogWrite("群发邮箱日志记录", "WWWprefix=" + str.Substring(0, str.IndexOf('/')) + PageValue.WebRoot);
                strContent = strContent.Replace("../", "http://" + str.Substring(0, str.IndexOf('/')) + PageValue.WebRoot + "");
                strContent = strContent.Replace("..", "");

            }
            IMailtasks imailtasks = Store.CreateMailtasks();
            int s = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                imailtasks = session.Mailtasks.GetByID(strId);

                imailtasks.subject = strSubject;
                imailtasks.content = strContent;
                imailtasks.cityid = cityid.ToString();
                s = session.Mailtasks.Update(imailtasks);
            }
            if (s > 0)
                PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
            result = new RedirctResult("MailtasksList.aspx", true);
            return result;
        }

        /// <summary>
        /// 新增邮件服务
        /// </summary>
        /// <param name="strMailHost">SMTP主机</param>
        /// <param name="strMailPort">SMTP端口{</param>
        /// <param name="strMailSSL">SSL方式</param>
        /// <param name="strMailUser">验证用户名</param>
        /// <param name="strMailUserName">用户别名</param>
        /// <param name="strMailPass">验证密码</param>
        /// <param name="strMailFrom">发信地址</param>
        /// <param name="strMailReply">回信地址</param>
        /// <param name="strSendCount">最多发送数量</param>
        /// <returns></returns>
        public static RedirctResult AddMailserver(string strMailHost, int strMailPort, string strMailSSL, string strMailUser, string strMailUserName, string strMailPass, string strMailFrom, string strMailReply, int strSendCount)
        {
            IMailserver imailserver = Store.CreateMailserver();
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                imailserver.smtphost = strMailHost;
                imailserver.smtpport = strMailPort;
                imailserver.mailuser = strMailUser;
                imailserver.realname = strMailUserName;
                imailserver.receivemail = strMailReply;
                imailserver.sendmail = strMailFrom;
                imailserver.ssl = Convert.ToInt32(strMailSSL);
                imailserver.mailpass = strMailPass;
                imailserver.sendcount = strSendCount;

                i = session.Mailserver.Insert(imailserver);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
            result = new RedirctResult("MailServerList.aspx", true);
            return result;
        }

        /// <summary>
        /// 修改邮件服务
        /// </summary>
        /// <param name="strMailHost">SMTP主机</param>
        /// <param name="strMailPort">SMTP端口{</param>
        /// <param name="strMailSSL">SSL方式</param>
        /// <param name="strMailUser">验证用户名</param>
        /// <param name="strMailUserName">用户别名</param>
        /// <param name="strMailPass">验证密码</param>
        /// <param name="strMailFrom">发信地址</param>
        /// <param name="strMailReply">回信地址</param>
        /// <param name="strSendCount">最多发送数量</param>
        /// <param name="strId">Id</param>
        /// <returns></returns>
        public static RedirctResult UpdateMailserver(string strMailHost, int strMailPort, string strMailSSL, string strMailUser, string strMailUserName, string strMailPass, string strMailFrom, string strMailReply, int strSendCount, int strId)
        {
            IMailserver imailserver = Store.CreateMailserver();
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                imailserver.smtphost = strMailHost;
                imailserver.smtpport = strMailPort;
                imailserver.mailuser = strMailUser;
                imailserver.realname = strMailUserName;
                imailserver.receivemail = strMailReply;
                imailserver.sendmail = strMailFrom;
                if (strMailSSL == "1")
                {
                    imailserver.ssl = Convert.ToInt32(strMailSSL);
                }
                else
                {
                    imailserver.ssl = 0;
                }
                imailserver.mailpass = strMailPass;
                imailserver.sendcount = strSendCount;
                imailserver.id = strId;

                i = session.Mailserver.Update(imailserver);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
            result = new RedirctResult("MailServerList.aspx", true);
            return result;
        }
        #endregion

        #region 新闻公告
        /// <summary>
        /// 新闻公告（添加）
        /// </summary>
        /// <param name="strTitle">标题</param>
        /// <param name="strContent">内容</param>
        /// <param name="strLink">新闻外链地址</param>
        /// <param name="strSeoTitle">新闻SEO标题</param>
        /// <param name="strSeoKeyword">SEO关键字</param>
        /// <param name="strSeoDescription">SEO描述</param>
        /// <param name="strCreateTime">发布时间</param>
        /// <param name="strAdminid">管理员ID</param>
        /// <param name="strType">类型</param>
        /// <returns></returns>
        public static RedirctResult AddNews(string strTitle, string strContent, string strLink, string strSeoTitle, string strSeoKeyword, string strSeoDescription, string strCreateTime, int strAdminid, int strType)
        {
            INews news = Store.CreateNews();
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                news.title = strTitle;
                news.content = strContent;
                news.link = strLink;
                news.seotitle = strSeoTitle;
                news.seokeyword = strSeoKeyword;
                news.seodescription = strSeoDescription;
                news.create_time = Convert.ToDateTime(strCreateTime);
                news.adminid = strAdminid;
                news.type = strType;
                i = session.News.Insert(news);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
            result = new RedirctResult("NewList.aspx", true);
            return result;
        }


        /// <summary>
        /// 新闻公告（修改）
        /// </summary>
        /// <param name="strTitle">标题</param>
        /// <param name="strContent">内容</param>
        /// <param name="strLink">新闻外链地址</param>
        /// <param name="strSeoTitle">新闻SEO标题</param>
        /// <param name="strSeoKeyword">SEO关键字</param>
        /// <param name="strSeoDescription">SEO描述</param>
        /// <param name="strCreateTime">发布时间</param>
        /// <param name="strAdminid">管理员ID</param>
        /// <param name="strType">类型</param>
        /// <param name="strId">Id</param>
        /// <returns></returns>
        public static RedirctResult UpdateNews(string strTitle, string strContent, string strLink, string strSeoTitle, string strSeoKeyword, string strSeoDescription, string strCreateTime, int strAdminid, int strType, int strId)
        {
            INews news = Store.CreateNews();
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                news.title = strTitle;
                news.content = strContent;
                news.link = strLink;
                news.seotitle = strSeoTitle;
                news.seokeyword = strSeoKeyword;
                news.seodescription = strSeoDescription;
                news.create_time = Convert.ToDateTime(strCreateTime);
                news.adminid = strAdminid;
                news.type = strType;
                news.id = strId;
                i = session.News.Update(news);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
            result = new RedirctResult("NewList.aspx", true);
            return result;
        }
        #endregion

        #region 促销活动|规则
        /// <summary>
        /// 促销活动（添加）
        /// </summary>
        /// <param name="strName">促销活动名称</param>
        /// <param name="strEnable">是否发布</param>
        /// <param name="strStartTime">开始时间</param>
        /// <param name="strEndTime">结束时间</param>
        /// <param name="strSort">排序</param>
        /// <param name="strDescription">促销活动描述</param>
        /// <returns></returns>
        public static RedirctResult AddCuXiaoHuoDong(string strName, int strEnable, string strStartTime, string strEndTime, int strSort, string strDescription)
        {
            ISales_promotion sale_promotion = Store.CreateSales_promotion();
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                sale_promotion.name = strName;
                sale_promotion.enable = strEnable;
                sale_promotion.start_time = Convert.ToDateTime(strStartTime);
                sale_promotion.end_time = Convert.ToDateTime(strEndTime);
                sale_promotion.sort = strSort;
                sale_promotion.description = strDescription;
                i = session.Sales_promotion.Insert(sale_promotion);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
            result = new RedirctResult("YingXiao_CuXiaoHuoDong.aspx", true);
            return result;
        }

        /// <summary>
        /// 促销活动（修改）
        /// </summary>
        /// <param name="strName">促销活动名称</param>
        /// <param name="strEnable">是否发布</param>
        /// <param name="strStartTime">开始时间</param>
        /// <param name="strEndTime">结束时间</param>
        /// <param name="strSort">排序</param>
        /// <param name="strDescription">促销活动描述</param>
        /// <param name="strId">Id</param>
        /// <returns></returns>
        public static RedirctResult UpdateCuXiaoHuoDong(string strName, int strEnable, string strStartTime, string strEndTime, int strSort, string strDescription, int strId)
        {
            ISales_promotion sale_promotion = Store.CreateSales_promotion();
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                sale_promotion.name = strName;
                sale_promotion.enable = strEnable;
                sale_promotion.start_time = Convert.ToDateTime(strStartTime);
                sale_promotion.end_time = Convert.ToDateTime(strEndTime);
                sale_promotion.sort = strSort;
                sale_promotion.description = strDescription;
                sale_promotion.id = strId;
                i = session.Sales_promotion.Update(sale_promotion);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
            result = new RedirctResult("YingXiao_CuXiaoHuoDong.aspx", true);
            return result;
        }


        /// <summary>
        /// 促销规则（添加）
        /// </summary>
        /// <param name="strTypeId">促销活动类别</param>
        /// <param name="strFullmoney">订单优惠条件</param>
        /// <param name="strStartTime">活动规则开始时间</param>
        /// <param name="strEndTime">活动规则结束时间</param>
        /// <param name="strSort">排序</param>
        /// <param name="strFreeShipping">是否免运费</param>
        /// <param name="strEnable">是否启用</param>
        /// <param name="strDeduction">请输入减少的金额</param>
        /// <param name="strFeedingAmount">请输入返回余额的金额</param>
        /// <param name="strDescription">规则描述</param>
        /// <param name="strActivtyid">活动编号</param>
        /// <returns></returns>
        public static RedirctResult AddCuXiaoGuize(int strTypeId, decimal strFullmoney, string strStartTime, string strEndTime, int strSort, int strFreeShipping, int strEnable, string strDeduction, string strFeedingAmount, string strDescription, int strActivtyid)
        {
            if (strTypeId == 0)
            {
                PageValue.SetMessage(new ShowMessageResult("请您选择促销规则后添加", false, false));
                result = new RedirctResult("YingXiao_CuXiaoHuoDong.aspx", true);
                return result;
            }
            else
            {
                IPromotion_rules promotionrules = Store.CreatePromotion_rules();
                int i = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    promotionrules.typeid = strTypeId;
                    promotionrules.full_money = strFullmoney;
                    promotionrules.sort = strSort;
                    promotionrules.enable = strEnable;
                    promotionrules.rule_description = strDescription;
                    promotionrules.activtyid = strActivtyid;

                    #region 条件判断
                    if (Convert.ToDateTime(strStartTime) > Convert.ToDateTime(strEndTime))
                    {
                        promotionrules.start_time = DateTime.Now;
                        promotionrules.end_time = DateTime.Now;
                    }
                    else
                    {
                        promotionrules.start_time = Convert.ToDateTime(strStartTime);
                        promotionrules.end_time = Convert.ToDateTime(strEndTime);
                    }

                    if (strFreeShipping == 1)
                    {
                        promotionrules.deduction = 0;
                        promotionrules.feeding_amount = 0;
                        promotionrules.free_shipping = strFreeShipping;
                    }
                    if (strFeedingAmount != null && strFeedingAmount != "")
                    {
                        promotionrules.free_shipping = 0;
                        promotionrules.deduction = 0;
                        promotionrules.feeding_amount = Convert.ToDecimal(strFeedingAmount);
                    }

                    if (strDeduction != null && strDeduction != "")
                    {
                        promotionrules.free_shipping = 0;
                        promotionrules.feeding_amount = 0;
                        promotionrules.deduction = Convert.ToDecimal(strDeduction);
                    }
                    #endregion

                    i = session.Promotion_rules.Insert(promotionrules);
                }
                if (i > 0)
                    PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
                else
                    PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
                result = new RedirctResult("YingXiao_CuXiaoGuiZe.aspx?salid=" + promotionrules.activtyid, true);
                return result;
            }
        }

        /// <summary>
        /// 促销规则（修改）
        /// </summary>
        /// <param name="strTypeId">促销活动类别</param>
        /// <param name="strFullmoney">订单优惠条件</param>
        /// <param name="strStartTime">活动规则开始时间</param>
        /// <param name="strEndTime">活动规则结束时间</param>
        /// <param name="strSort">排序</param>
        /// <param name="strFreeShipping">是否免运费</param>
        /// <param name="strEnable">是否启用</param>
        /// <param name="strDeduction">请输入减少的金额</param>
        /// <param name="strFeedingAmount">请输入返回余额的金额</param>
        /// <param name="strDescription">规则描述</param>
        /// <param name="strActivtyid">活动编号</param>
        /// <param name="strId">Id</param>
        /// <returns></returns>
        public static RedirctResult UpdateCuXiaoGuize(int strTypeId, decimal strFullmoney, string strStartTime, string strEndTime, int strSort, int strFreeShipping, int strEnable, string strDeduction, string strFeedingAmount, string strDescription, int strActivtyid, int strId)
        {
            if (strTypeId == 0)
            {
                PageValue.SetMessage(new ShowMessageResult("请您选择促销规则后修改", false, false));
                result = new RedirctResult("YingXiao_CuXiaoHuoDong.aspx", true);
                return result;
            }
            else
            {
                IPromotion_rules promotionrules = Store.CreatePromotion_rules();
                int i = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    promotionrules.typeid = strTypeId;
                    promotionrules.full_money = strFullmoney;
                    promotionrules.sort = strSort;
                    promotionrules.enable = strEnable;
                    promotionrules.rule_description = strDescription;
                    promotionrules.activtyid = strActivtyid;
                    promotionrules.id = strId;

                    #region 条件判断
                    if (Convert.ToDateTime(strStartTime) > Convert.ToDateTime(strEndTime))
                    {
                        promotionrules.start_time = DateTime.Now;
                        promotionrules.end_time = DateTime.Now;
                    }
                    else
                    {
                        promotionrules.start_time = Convert.ToDateTime(strStartTime);
                        promotionrules.end_time = Convert.ToDateTime(strEndTime);
                    }

                    if (strFreeShipping != null && strFeedingAmount != "")
                    {
                        promotionrules.free_shipping = strFreeShipping;
                    }
                    if (strFeedingAmount != null && strFeedingAmount != "")
                    {
                        promotionrules.feeding_amount = Convert.ToDecimal(strFeedingAmount);
                    }

                    if (strDeduction != null && strDeduction != "")
                    {
                        promotionrules.deduction = Convert.ToDecimal(strDeduction);
                    }
                    #endregion

                    i = session.Promotion_rules.Update(promotionrules);
                }
                if (i > 0)
                    PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
                else
                    PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
                result = new RedirctResult("YingXiao_CuXiaoGuiZe.aspx?salid=" + promotionrules.activtyid, true);
                return result;
            }
        }
        #endregion

        #region 红包
        /// <summary>
        /// 红包充值
        /// </summary>
        /// <param name="strMoney">充值金额</param>
        /// <param name="strUserId">用户ID</param>
        /// <param name="strCode">代金券代号</param>
        /// <param name="strCount">派发数量</param>
        /// <param name="strSelPacket">红包类型</param>
        /// <param name="strOk">确认派发</param>
        /// <param name="strAdminId">管理员Id</param>
        /// <returns></returns>
        public static RedirctResult AddHBChongZhi(string strMoney, string strUserId, string strCode, string strCounts, string strCardCounts, string strSelPacket, string strOk, int strAdminId)
        {
            AS.GroupOn.Controls.BasePage bp = new BasePage();
            decimal money = 0; //充值金额
            string userId = ""; //派发用户id

            int strCount = 0;
            int strCardCount = 0;
            if (strCounts != "")
            {
                strCount = Helper.GetInt(strCounts, 0);
            }
            if (strCardCounts != "")
            {
                strCardCount = Helper.GetInt(strCardCounts, 0);
            }

            #region 充值
            if (strMoney != "" && strUserId != "")
            {
                if (strSelPacket == "money")
                {
                    money = Convert.ToDecimal(strMoney);
                    money = System.Decimal.Round(money, 2);
                    userId = strUserId;
                    if (money == 0)
                    {
                        PageValue.SetMessage(new ShowMessageResult("充值金额不能为0", false, false));
                        result = new RedirctResult("YingXiao_Packet.aspx", true);
                        return result;
                    }
                    if (strOk == "true")
                    {
                        #region 充值
                        //用户id
                        if (userId.IndexOf("\r\n") >= 0)
                        {
                            userId = userId.Replace("\r\n", ",");
                        }

                        //将用户id存储到dt中
                        string[] s = userId.Split(' ', ',');
                        DataTable dt = new DataTable();
                        dt.Columns.Add("id", typeof(int));
                        for (int i = 0; i < s.Length; i++)
                        {
                            DataRow dr = dt.NewRow();
                            if (s[i] != "")
                            {
                                //判断是否为数字
                                if (NumberUtils.IsNum(s[i]))
                                {
                                    dr["id"] = s[i];
                                }
                                else
                                {
                                    PageValue.SetMessage(new ShowMessageResult("您输入的用户ID非法", false, false));
                                    result = new RedirctResult("YingXiao_Packet.aspx", true);
                                    return result;
                                }
                                //查询用户是否存在
                                IUser iuserInfo = null;
                                int strId = int.Parse(dr["id"].ToString());
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    iuserInfo = session.Users.GetByID(strId);
                                }
                                if (iuserInfo == null)
                                {
                                    PageValue.SetMessage(new ShowMessageResult("用户ID：" + dr["id"] + "不存在，请重新选择", false, false));
                                    result = new RedirctResult("YingXiao_Packet.aspx", true);
                                    return result;
                                }
                                dt.Rows.Add(dr);
                            }
                        }

                        //开始充值
                        for (int k = 0; k < dt.Rows.Count; k++)
                        {
                            //获取用户id
                            int id = int.Parse(dt.Rows[k]["id"].ToString());
                            IPacket packet = Store.CreatePacket();
                            int i = 0;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                //用户id
                                packet.User_id = id;
                                packet.Money = money;
                                packet.Admin_Id = strAdminId;
                                packet.Type = "money";
                                packet.State = 0;
                                packet.Send_Time = DateTime.Now;
                                i = session.Packet.InsertHBCZ(packet);
                            }
                        }
                        //清空session与cookie
                        HttpContext.Current.Session.Remove("getUserId");
                        HttpContext.Current.Request.Cookies.Remove("getCardCookie");
                        HttpContext.Current.Request.Cookies.Remove("getMoneyCookie");
                        PageValue.SetMessage(new ShowMessageResult("充值成功，共充值" + dt.Rows.Count + "个用户,充值金额为" + money + "元", true, true));
                        result = new RedirctResult("YingXiao_Packet.aspx", true);
                        return result;
                        #endregion
                    }
                }
            }
            #endregion
            #region 代金券
            if (strCode != "" && strCount.ToString() != "" && strUserId != "")
            {
                //代金券
                if (strSelPacket == "card")
                {
                    userId = strUserId;
                    if (strCardCount == 0)
                    {
                        PageValue.SetMessage(new ShowMessageResult("代金券数量不能为0", false, false));
                        result = new RedirctResult("YingXiao_Packet.aspx", true);
                        return result;
                    }
                    if (strCount == 0)
                    {
                        PageValue.SetMessage(new ShowMessageResult("派发数量不能为0", false, false));
                        result = new RedirctResult("YingXiao_Packet.aspx", true);
                        return result;
                    }
                    if (strCount > strCardCount)
                    {
                        PageValue.SetMessage(new ShowMessageResult("派发数量不能大于代金券数量", false, false));
                        result = new RedirctResult("YingXiao_Packet.aspx", true);
                        return result;
                    }
                    if (strOk == "true")
                    {
                        #region 代金劵
                        //用户id
                        if (userId.IndexOf("\r\n") >= 0)
                        {
                            userId = userId.Replace("\r\n", ",");
                        }

                        //将用户id存储到dt中
                        string[] s = userId.Split(',');
                        DataTable dt = new DataTable();
                        dt.Columns.Add("id", typeof(int));
                        for (int i = 0; i < s.Length; i++)
                        {
                            DataRow dr = dt.NewRow();
                            if (s[i] != "")
                            {
                                dr["id"] = s[i];
                                //查询用户是否存在
                                IUser iuserInfo = null;
                                int strId = int.Parse(dr["id"].ToString());
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    iuserInfo = session.Users.GetByID(strId);
                                }
                                if (iuserInfo == null)
                                {
                                    PageValue.SetMessage(new ShowMessageResult("用户ID：" + dr["id"] + "不存在，请重新选择", false, false));
                                    result = new RedirctResult("YingXiao_Packet.aspx", true);
                                    return result;
                                }
                                dt.Rows.Add(dr);
                            }
                        }

                        //代金券数量、派发数量、派发用户数量都要大于0
                        if (strCardCount > 0 && strCount > 0 && dt.Rows.Count > 0)
                        {

                            if (strCount <= strCardCount)
                            {
                                //代金券代号
                                CardFilter cardfilter = new CardFilter();
                                cardfilter.consume = "N";
                                cardfilter.user_id = 0;
                                cardfilter.FromEnd_time = DateTime.Now;
                                cardfilter.Code = strCode;
                                IList<ICard> ds = null;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    ds = session.Card.GetList(cardfilter);
                                }
                                //可派发数量
                                strCardCount = ds.Count;
                                //代金券数量要大于等于派发数量*派发用户数
                                if (strCardCount >= dt.Rows.Count * strCount)
                                {
                                    //从dt表中获取所有用户id，将所有id存储到dtAllId中，
                                    DataTable dtAllId = new DataTable();
                                    dtAllId.Columns.Add("id", typeof(int));
                                    for (int j = 0; j < strCount; j++)
                                    {
                                        for (int n = 0; n < dt.Rows.Count; n++)
                                        {
                                            DataRow drAllId = dtAllId.NewRow();
                                            drAllId["id"] = dt.Rows[n]["id"];
                                            dtAllId.Rows.Add(drAllId);
                                        }
                                    }
                                    //开始派发
                                    for (int k = 0; k < (dtAllId.Rows.Count); k++)
                                    {
                                        //获取代金券id
                                        string cardId = ds[k].Id.ToString();
                                        //获取用户id
                                        int id = int.Parse(dtAllId.Rows[k]["id"].ToString());
                                        ICard card = null;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            card = session.Card.GetByID(cardId);
                                        }
                                        card.user_id = id;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Card.Update(card);
                                        }
                                        IPacket packet = Store.CreatePacket();
                                        packet.User_id = id;
                                        packet.Number = cardId;
                                        packet.Admin_Id = bp.AsUser.Id;
                                        packet.Type = "card";
                                        packet.State = 0;
                                        packet.Send_Time = DateTime.Now;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Packet.InsertPfdjq(packet);
                                        }
                                    }
                                    //清空session与cookie
                                    HttpContext.Current.Session.Remove("getUserId");
                                    HttpContext.Current.Request.Cookies.Remove("getCardCookie");
                                    HttpContext.Current.Request.Cookies.Remove("getMoneyCookie");
                                    PageValue.SetMessage(new ShowMessageResult("代金券派发成功，共派发代金券" + dtAllId.Rows.Count + "张", true, true));
                                    result = new RedirctResult("YingXiao_Packet.aspx", true);
                                    return result;
                                }
                                else
                                {
                                    PageValue.SetMessage(new ShowMessageResult("代金券数量要大于等于派发数量与用户数的乘积", false, false));
                                    result = new RedirctResult("YingXiao_Packet.aspx", true);
                                    return result;
                                }
                            }
                            else
                            {
                                PageValue.SetMessage(new ShowMessageResult("派发数量不能大于代金券数量", false, false));
                                result = new RedirctResult("YingXiao_Packet.aspx", true);
                                return result;
                            }
                        }
                        else
                        {
                            PageValue.SetMessage(new ShowMessageResult("代金券数量要大于等于派发数量与用户数的乘积", false, false));
                            result = new RedirctResult("YingXiao_Packet.aspx", true);
                            return result;
                        }
                        #endregion
                    }

                }
            }
            #endregion

            return result;
        }
        #endregion
    }
}