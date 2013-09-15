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
    
    protected string cityHtml = "";
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_Download_UserInfo))
        {
            SetError("你不具有用户信息下载的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }

        if (!IsPostBack)
        {
            setUser();
        }
        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["city_id"] != null && Request.Form["newbie"] != null && Request.Form["gender"] != null)
            {
                string city = Request.Form["city_id"].ToString();
                string type = Request.Form["newbie"].ToString();
                string gender = Request.Form["gender"].ToString();
                string enable = Request.Form["enable"].ToString();
                downshuju(city, type, gender, enable);
            }
            else
            {
                SetError("-ERR ERR_NO_DATA");
                Response.Redirect("YingXiao_ShujuXiazai_User.aspx");
                return;
            }

        }

    }

    private void setUser()
    {
        IList<ICategory> iListCategory = null;
        CategoryFilter categoryfilter = new CategoryFilter();
        categoryfilter.Zone = "city";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCategory = session.Category.GetList(categoryfilter);
            StringBuilder sb1 = new StringBuilder();
            foreach (ICategory icategory in iListCategory)
            {
                sb1.Append("<input type='checkbox' name='city_id' value='" + icategory.Id + "' checked />&nbsp;" + icategory.Name + "&nbsp;&nbsp;");
            }
            cityHtml = sb1.ToString();
        }
    }

    private void downshuju(string city, string type, string gender, string enable)
    {

        StringBuilder sb1 = new StringBuilder();
        UserFilter userfilter = new UserFilter();
        IList<IUser> iListUser=null;
        
        if (city == "" || type == "" || gender == "")
        {

            SetError("-ERR ERR_NO_DATA");
            Response.Redirect("YingXiao_ShujuXiazai_User.aspx");
            return;
        }
        else
        {
            sb1.Append("<html>");
            sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
            sb1.Append("<body><table border=\'1\'>");
            sb1.Append("<tr>");
            sb1.Append("<td>ID</td>");
            sb1.Append("<td align='left'>用户ID</td>");
            sb1.Append("<td>邮件</td>");
            sb1.Append("<td>用户名</td>");
            sb1.Append("<td>真实姓名</td>");
            sb1.Append("<td>性别</td>");
            sb1.Append("<td>QQ号码</td>");
            sb1.Append("<td>手机号码</td>");
            sb1.Append("<td>邮编</td>");
            sb1.Append("<td>地址</td>");
            sb1.Append("<td>购买</td>");
            sb1.Append("</tr>");
            int num = 1;

            //处理购买状态开始
            string[] Newbies = type.Split(',');
            string str = "";
            for (int i = 0; i < Newbies.Length; i++)
            {
                str = str + "'" + Newbies[i] + "',";
            }
            str = str.Substring(0, str.Length - 1);
            //处理状态结束


            //处理性别开始
            string[] genders = gender.Split(',');
            string str1 = "";
            for (int i = 0; i < genders.Length; i++)
            {
                str1 = str1 + "'" + genders[i] + "',";
            }
            str1 = str1.Substring(0, str1.Length - 1);
            //处理性别结束


            //处理性别开始
            string[] enables = enable.Split(',');
            string strenable = "";
            for (int i = 0; i < enables.Length; i++)
            {
                strenable = strenable + "'" + enables[i] + "',";
            }
            strenable = strenable.Substring(0, strenable.Length - 1);
            //处理性别结束

            userfilter.City_ids = city;
            userfilter.Newbies = str;
            userfilter.Genders = str1;
            userfilter.Enables = strenable;

            int countuser = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                countuser = session.Users.GetCountByCityId(userfilter);
            }
            
            //Maticsoft.BLL.UserInfo user = new BLL.UserInfo();
            //string countuser = user.GetCount("count(*)", " City_id in (" + city + ") and Newbie in (" + str + ") and Gender in (" + str1 + ") and Enable in(" + strenable + ")");
            if (countuser > 0)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iListUser = session.Users.GetList(userfilter);
                }
                
                foreach (IUser iuserInfo in iListUser)
                {
                    sb1.Append("<tr>");
                    sb1.Append("<td>" + (num++).ToString() + "</td>");
                    sb1.Append("<td align='left'>" + iuserInfo.Id + "</td>");
                    sb1.Append("<td>" + iuserInfo.Email + "</td>");
                    sb1.Append("<td>" + iuserInfo.Username + "</td>");
                    sb1.Append("<td>" + iuserInfo.Realname + "</td>");
                    if (iuserInfo.Gender.ToUpper() == "M")
                    {
                        sb1.Append("<td>男</td>");
                    }
                    if (iuserInfo.Gender.ToUpper() == "F")
                    {
                        sb1.Append("<td>女</td>");
                    }
                    sb1.Append("<td>" + iuserInfo.Qq + "</td>");
                    sb1.Append("<td>" + iuserInfo.Mobile + "</td>");
                    sb1.Append("<td>" + iuserInfo.Zipcode + "</td>");
                    sb1.Append("<td>" + iuserInfo.Address + "</td>");
                    if (iuserInfo.Newbie.ToUpper() == "Y")
                    {
                        sb1.Append("<td>购买过</td>");
                    }
                    if (iuserInfo.Newbie.ToUpper() == "N")
                    {
                        sb1.Append("<td>未购买</td>");
                    }
                    sb1.Append("</tr>");
                }
            }
            else
            {
                SetError("没有数据，请重新选择条件下载！");
                Response.Redirect("YingXiao_ShujuXiazai_User.aspx");
                Response.End();
            }

            sb1.Append("</table></body></html>");
            Response.ClearHeaders();
            Response.Clear();
            Response.Expires = 0;
            Response.Buffer = true;
            Response.AddHeader("Accept-Language", "zh-tw");
            //文件名称
            Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("user_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
            Response.ContentType = "Application/octet-stream";
        }
        //文件内容
        Response.Write(sb1.ToString());//-----------
        Response.End();

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
                                    <h2>用户信息</h2>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>所在城市</label>
						                <div class="city-box">
                                            <%=cityHtml %><input type="checkbox" name="city_id" value="0" checked>&nbsp;其他</div>
					                </div>

                                    <div class="field">
                                        <label>曾经购买</label>
						                <div style=""><input type="checkbox" name="newbie" value="N" checked />&nbsp;未购买&nbsp;&nbsp;<input type="checkbox" name="newbie" value="Y,C" checked>&nbsp;购买过</div>
					                </div>

                                    <div class="field">
                                        <label>性别</label>
						                <div style=""><input type="checkbox" name="gender" value="M" checked />&nbsp;男性&nbsp;&nbsp;<input type="checkbox" name="gender" value="F" checked>&nbsp;女性</div>
					                </div>
                                        <div class="field">
                                        <label>状态</label>
						                <div style=""><input type="checkbox" name="enable" value="Y" checked />&nbsp;已激活&nbsp;&nbsp;<input type="checkbox" name="enable" value="N" checked>&nbsp;未激活</div>
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