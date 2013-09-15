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
    protected string strHtml = "";
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_Download_Mobile))
        {
            SetError("你不具有手机号码下载的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (!IsPostBack)
        {
            setUpload();
        }
        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["city_id"] != null)
            {
                string s = Request.Form["city_id"].ToString();
                xiazai(s);
            }
        }
    }

    protected void setUpload()
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

    protected void xiazai(string id)
    {
        StringBuilder sb1 = new StringBuilder();
        int count = 0;
        UserFilter filter = new UserFilter();
        filter.City_ids = id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            count = session.Users.GetCountByCityId(filter);
        }
        if (count > 0)
        {
            sb1.Append("<html>");
            sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
            sb1.Append("<body><table border=\'1\'>");

            sb1.Append("<tr class='alt'>");
            sb1.Append("<td>ID</td>");
            sb1.Append("<td>用户Email</td>");
            sb1.Append("<td>真实姓名</td>");
            sb1.Append("<td>手机号码</td>");
            sb1.Append("</tr>");
            int i = 0;
            
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iListUser = session.Users.GetList(filter);
            }
            
            foreach (IUser iuserInfo in iListUser)
            {
                if (i % 2 == 0)
                {
                    sb1.Append("<tr>");
                }
                else
                {
                    sb1.Append("<tr class='alt'>");
                }
                i++;
                sb1.Append("<td align='left'>" + iuserInfo.Id + "</td>");
                sb1.Append("<td align='left'>" + iuserInfo.Email + "</td>");
                sb1.Append("<td align='left'>" + iuserInfo.Realname + "</td>");
                sb1.Append("<td align='left'>" + iuserInfo.Mobile + "</td>");
                sb1.Append("</tr>");
            }
            sb1.Append("</table></body></html>");
            Response.ClearHeaders();
            Response.Clear();
            Response.Expires = 0;
            Response.Buffer = true;
            Response.AddHeader("Accept-Language", "zh-tw");
            //文件名称
            Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("mobile_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
            Response.ContentType = "Application/octet-stream";
            //文件内容
            Response.Write(sb1.ToString());
            Response.End();
        }
        else
        {
            SetError("没有数据，请重新选择其他用户范围！");
            Response.Redirect("YingXiao_ShujuXiazai.aspx");
            Response.End();
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
                                    <h2>手机号码</h2>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>用户范围</label>
					                    <div class="city-box">
                                            <%=strHtml %><input type="checkbox" name="city_id" value="0" checked>&nbsp;其他
                                        </div>
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