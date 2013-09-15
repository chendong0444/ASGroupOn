<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    
    protected IList<ICategory> iListCategory = null;
    protected IList<IUser> iListUser = null;
    protected IList<IMailer> iListMailer = null;
    
    protected string strHtml = "";
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_Download_Email))
        {
            SetError("你不具有邮件地址下载的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (!IsPostBack)
        {
            setEmail();
        }
        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["city_id"] != null && Request.Form["source[]"] != null)
            {
                string citys = Request.Form["city_id"].ToString();
                string type = Request.Form["source[]"].ToString();

                xiazai(citys, type);
            }
            else
            {
                SetError("-ERR ERR_NO_DATA");
                Response.Redirect("YingXiao_ShujuXiazai_Email.aspx");
                return;
            }
        }
    }

    protected void setEmail()
    {
        StringBuilder sb1 = new StringBuilder();
        CategoryFilter filter = new CategoryFilter();
        filter.Zone = "city";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCategory = session.Category.GetList(filter);
        }
        foreach (ICategory icategoryInfo in iListCategory)
        {
            sb1.Append("<input type='checkbox' name='city_id' value='" + icategoryInfo.Id + "' checked />&nbsp;" + icategoryInfo.Name + "&nbsp;&nbsp;");
        }
        strHtml = sb1.ToString();
    }


    private void xiazai(string citys, string type)
    {
        StringBuilder sb1 = new StringBuilder();
        int i = 1;

        if (citys == "" || type == "")
        {
            SetError("-ERR ERR_NO_DATA");
            Response.Redirect("YingXiao_ShujuXiazai_Email.aspx");
            return;
        }
        else
        {
            int countuser = 0;
            UserFilter userfilter = new UserFilter();
            userfilter.City_ids = citys;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                countuser = session.Users.GetCountByCityId(userfilter);
            }

            int countmail = 0;
            MailerFilter mailerflter = new MailerFilter();
            mailerflter.City_ids = citys;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                countmail = session.Mailers.GetCountByCityId(mailerflter);
            }
            
            if (countuser > 0 || countmail > 0)
            {
                sb1.Append("<html>");
                sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
                sb1.Append("<body><table border=\'1\'>");
                sb1.Append("<tr>");
                sb1.Append("<td>ID</td>");
                sb1.Append("<td>用户Email</td>");
                sb1.Append("</tr>");

                if (type.IndexOf("user") >= 0)
                {
                    //读取用户中的邮件地址
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        iListUser = session.Users.GetList(userfilter);
                    }
                    foreach (IUser iuserInfo in iListUser)
                    {
                        sb1.Append("<tr>");
                        sb1.Append("<td align='left'>" + (i++).ToString() + "</td>");
                        sb1.Append("<td align='left'>" + iuserInfo.Email + "</td>");
                        sb1.Append("</tr>");
                    }
                }

                if (type.IndexOf("subscribe") >= 0)
                {
                    //读取邮件订阅的地址
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        iListMailer = session.Mailers.GetList(mailerflter);
                    }
                    foreach (IMailer imailerInfo in iListMailer)
                    {
                        sb1.Append("<tr>");
                        sb1.Append("<td align='left'>" + (i++).ToString() + "</td>");
                        sb1.Append("<td align='left'>" + imailerInfo.Email + "</td>");
                        sb1.Append("</tr>");
                    }
                }

                sb1.Append("</table></body></html>");
                Response.ClearHeaders();
                Response.Clear();
                Response.Expires = 0;
                Response.Buffer = true;
                Response.AddHeader("Accept-Language", "zh-tw");
                //文件名称
                Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("Eamil_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
                Response.ContentType = "Application/octet-stream";

                //文件内容
                Response.Write(sb1.ToString());//-----------
                Response.End();
            }
            else
            {
                SetError("没有数据，请重新选择条件下载！");
                Response.Redirect("YingXiao_ShujuXiazai_Email.aspx");
                Response.End();
            }
        }
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                  
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>邮件地址</h2>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>城市范围</label>
						                <div class="city-box">
                                            <%=strHtml %><input type="checkbox" name="city_id" value="0" checked>&nbsp;其他
                                        </div>
					                </div>
                                    <div class="field">
                                        <label>邮件来源</label>
						                <div style=""><input type="checkbox" name="source[]" value="user" checked />&nbsp;注册用户&nbsp;&nbsp;<input type="checkbox" name="source[]" value="subscribe" checked>&nbsp;邮件订阅</div>
					                </div>

                                    <div class="act">
                                        <input type="submit" value="下载" name="commit" class="formbutton"/>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- bd end -->
    </div>
    <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>