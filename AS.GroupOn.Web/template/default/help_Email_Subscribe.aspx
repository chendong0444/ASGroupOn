<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat="server">
    protected string useremail = String.Empty;
    protected string curcityname = String.Empty;
    protected string cityname = String.Empty;
    protected string cityhtml = String.Empty;
    protected NameValueCollection _system = new NameValueCollection();
    protected System.Collections.Generic.IList<ICategory> CityList = null;
    protected CategoryFilter filter = new CategoryFilter();
    protected IMailer mailerList = null;
    protected IMailer mailer = new AS.GroupOn.Domain.Spi.Mailer();
    protected MailerFilter mailfilter = new MailerFilter();
    bool states = false;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {
            filter.Zone = "city";
            filter.AddSortOrder(" Display desc ");
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                CityList = session.Category.GetList(filter);
            }
            if (CurrentCity != null)
            {
                curcityname = CurrentCity.Id.ToString();
                cityname = CurrentCity.Name;
            }
        }

        if (AsUser.Id != 0)
        {
            useremail = AsUser.Email;
        }
        //从用户控件传来的邮件订阅
        if (!string.IsNullOrEmpty(Request["email"]) && Request.HttpMethod == "GET")
        {
            useremail = Request["email"].ToString();
            string email = AS.Common.Utils.Helper.GetString(Request["email"], String.Empty);
            if (!AS.Common.Utils.Helper.ValidateString(email, "email"))
            {
                SetError("邮箱格式不正确，请重新输入您的邮箱！");
                Response.Redirect(GetUrl("邮件订阅", "help_Email_Subscribe.aspx"));
                Response.End();
                return;
            }
            else if (email != String.Empty)
            {
                mailfilter.Email = email;
                mailfilter.AddSortOrder(MailerFilter.ID_ASC);

                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mailerList = session.Mailers.Get(mailfilter);
                }
                if (mailerList == null)
                {
                    mailer.City_id = CurrentCity.Id;
                    string code = Guid.NewGuid().ToString();
                    mailer.Secret = code.Substring(0, 32);
                    mailer.Email = email;
                    int count = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        count = session.Mailers.Insert(mailer);
                    }
                    if (count > 0)
                    {
                        SetSuccess("邮件订阅成功");
                    }
                }
                else
                {
                    ICategory catelist = null;
                    int c_id = mailerList.City_id;
                    if (c_id == 0)
                    {
                        IMailer mailer = null;
                        MailerFilter mfiler = new MailerFilter();
                        mfiler.City_id = c_id;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            mailer = session.Mailers.Get(mfiler);
                        }
                        if (mailer != null)
                        {
                            SetSuccess("邮件订阅成功");
                            states = true;

                        }
                    }
                    else
                    {
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            catelist = session.Category.GetByID(c_id);
                        }
                        if (catelist != null)
                        {
                            string _cityName = catelist.Name;
                            SetError("你已经订阅了" + _cityName + "的团购信息,如果需要用该邮箱订阅其他城市团购信息,请先取消");
                            states = true;
                        }
                    }

                }
            }
            else
            {
                SetError("邮件地址不能为空");
            }
        }
        //本页面提交的邮件订阅
        if (Request.HttpMethod == "POST" && Request["buttontype"] == "订  阅")
        {
            string email = AS.Common.Utils.Helper.GetString(Request["sub_email"], String.Empty);
            if (!AS.Common.Utils.Helper.ValidateString(email, "email"))
            {
                SetError("邮箱格式不正确，请重新输入您的邮箱！");
                Response.Redirect(GetUrl("邮件订阅", "help_Email_Subscribe.aspx"));
                Response.End();
                return;
            }
            else if (email != String.Empty)
            {
                mailfilter.Email = email;
                mailfilter.AddSortOrder(MailerFilter.ID_ASC);

                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mailerList = session.Mailers.Get(mailfilter);
                }
                if (mailerList == null)
                {
                    mailer.City_id = AS.Common.Utils.Helper.GetInt(Request["city"], 0);
                    string code = Guid.NewGuid().ToString();
                    mailer.Secret = code.Substring(0, 32);
                    mailer.Email = email;
                    int count = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        count = session.Mailers.Insert(mailer);
                    }
                    if (count > 0)
                    {
                        SetSuccess("邮件订阅成功");
                    }
                }
                else
                {
                    ICategory catelist = null;
                    int c_id = mailerList.City_id;
                    if (c_id == 0)
                    {
                        IMailer mailer = null;
                        MailerFilter mfiler = new MailerFilter();
                        mfiler.City_id = c_id;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            mailer = session.Mailers.Get(mfiler);
                        }
                        if (mailer != null)
                        {
                            SetSuccess("邮件订阅成功");
                            states = true;
                        }
                    }
                    else
                    {
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            catelist = session.Category.GetByID(c_id);
                        }
                        if (catelist != null)
                        {
                            string _cityName = catelist.Name;
                            SetError("你已经订阅了" + _cityName + "的团购信息,如果需要用该邮箱订阅其他城市团购信息,请先取消");
                            states = true;
                        }
                    }
                }
            }
            else
            {
                SetError("邮件地址不能为空");
            }
        }
        if (Request.HttpMethod == "GET" && Request.QueryString["state"] == "true")
        {
            //取消邮件订阅
            MailerFilter mfilter = new MailerFilter();
            int count = 0;
            mfilter.Email = AS.Common.Utils.Helper.GetString(Request.QueryString["email"], String.Empty);
            IMailer mailers = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mailers = session.Mailers.Get(mfilter);
            }
            int id = mailers.Id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                count = session.Mailers.Delete(id);
            }
            if (count > 0)
            {
                SetSuccess("已取消订阅");
                Response.Redirect(GetUrl("邮件订阅", "help_Email_Subscribe.aspx"));
            }
            else
            {
                SetError("取消邮件订阅失败");
                Response.Redirect(GetUrl("邮件订阅", "help_Email_Subscribe.aspx"));
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form1" method="post">
    <div id="bdw" class="bdw">
        <div id="bd" class="cf">
            <div id="maillist">
                <div id="content">
                    <div class="box">
                        <div class="box-content welcome">
                            <div class="head">
                                <h2>邮件订阅</h2>
                                &nbsp;
                                <% if (states == true)
                                   { %>
                                <h2><a href="<%=GetUrl("邮件订阅", "help_Email_Subscribe.aspx?state=true&email="+mailerList.Email)%>">取消邮件订阅</a> </h2>
                                <%} %>
                            </div>
                            <div class="sect">
                                <div class="lead">
                                    <h4>把<%=cityname%>每天最新的精品团购信息发到您的邮箱。</h4>
                                </div>
                                <div class="enter-address">
                                    <p>
                                        立即邮件订阅每日团购信息，不错过每一天的惊喜。
                                    </p>
                                    <div class="enter-address-c">
                                        <div class="mail">
                                            <label>
                                                邮件地址：</label>
                                            <input  type="text"  id="enter-address-mail" name="sub_email" require="true" datatype="email"
                                                class="f-input f-mail"value="<%=useremail %>" size="20"  />
                                            <span class="tip">请放心，我们和您一样讨厌垃圾邮件</span>
                                        </div>
                                        <div class="city">
                                            <label>
                                                &nbsp;</label>
                                            <select name="city" style="height: 23px; width: 150px;">
                                                <% foreach (ICategory item in CityList)
                                                   {%>
                                                <option value="<%=item.Id %>"
                                                    <% if (Convert.ToInt32(Request["city"]) == item.Id || item.Id.ToString() == curcityname)
                                                       { %>
                                                    selected="selected" <%} %>>
                                                    <%=item.Name %>
                                                </option>
                                                <%}%>
                                            </select>
                                            <input type="submit" group="a" class="formbutton validator" name="buttontype" value="订  阅" />
                                        </div>
                                    </div>
                                    <div class="clear">
                                    </div>
                                </div>
                                <div class="intro">
                                    <p>
                                        每日精品团购包括：
                                    </p>
                                    <p>
                                        餐厅、酒吧、KTV、SPA、美发、健身、瑜伽、演出、影院等。
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="sidebar">
                    <div class="side-pic">
                        <p>
                            <img src="<%=AS.GroupOn.Controls.PageValue.WebRoot%>upfile/img/subscribe-pic1.jpg" />
                        </p>
                        <p>
                            <img src="<%=AS.GroupOn.Controls.PageValue.WebRoot%>upfile/img/subscribe-pic2.jpg" />
                        </p>
                        <p>
                            <img src="<%=AS.GroupOn.Controls.PageValue.WebRoot%>upfile/img/subscribe-pic3.jpg" />
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>