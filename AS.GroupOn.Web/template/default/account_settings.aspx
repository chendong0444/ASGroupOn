<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    
    protected NameValueCollection configs = new NameValueCollection();

    protected string strImgavatar = "";
    protected StringBuilder stBCity = new StringBuilder();
    bool fileok = false;
    string email = "";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "settings";
        configs = WebUtils.GetSystem();
        Form.Action = GetUrl("账户设置", "account_settings.aspx");
        if (!Page.IsPostBack)
        {
            initDropdown();
            initPage();
        }

        if (Request["commit"] == "更改")
        {
            UpdateUserInfo();
        }

    }
    private void initDropdown()
    {
        IList<ICategory> iListCategory = null;
        CategoryFilter categoryfilter = new CategoryFilter();
        categoryfilter.Zone = WebUtils.GetCatalogName(AS.Common.Utils.CatalogType.city);
        categoryfilter.AddSortOrder(CatalogsFilter.Sort_Order_DESC);

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCategory = session.Category.GetList(categoryfilter);
        }
        int cityid = AsUser.City_id;
        //城市
        stBCity.Append("<select name='city_id' id='city' class='f-city'>");
        stBCity.Append("<option value='0' >全部城市</option>");
        if (iListCategory != null)
        {
            foreach (ICategory catagoryInfo in iListCategory)
            {
                if (catagoryInfo.Id == cityid)
                {
                    stBCity.Append("<option value='" + catagoryInfo.Id + "' selected='selected' >" + catagoryInfo.Name + "</option>");
                }
                else
                {
                    stBCity.Append("<option value='" + catagoryInfo.Id + "' >" + catagoryInfo.Name + "</option>");
                }
            }
        }
        stBCity.Append("</select>");
    }

    /// <summary>
    /// 初始化页面
    /// </summary>
    private void initPage()
    {
        //判断用户失效！
        NeedLogin();
        if (String.IsNullOrEmpty(AsUser.Avatar))
        {
            if (AsUser.Gender == "F")
            {
                strImgavatar = WebRoot + "upfile/img/girl.jpg";
            }
            else
            {
                strImgavatar = WebRoot + "upfile/img/man.jpg";
            }
        }
        else
        {
            strImgavatar = AsUser.Avatar;
        }
    }

    protected void UpdateUserInfo()
    {
        //判断用户失效！
        NeedLogin();
        IUser m_user = null;
        int uid = AsUser.Id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            m_user = session.Users.GetByID(uid);
        }
        #region 上传图片
        strImgavatar = AsUser.Avatar;
        //判断上传文件的大小
        if (upload_image.PostedFile.ContentLength > 512000)
        {
            SetError("请上传 512KB 以内的个人肖像图片!");
            Response.Redirect(GetUrl("账户设置", "account_settings.aspx"));
        }//如果文件大于512kb，则不允许上传

        string uploadName = upload_image.Value;//获取待上传图片的完整路径，包括文件名 
        string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
        string suffix = "";
        if (upload_image.Value != "")
        {
            int idx = uploadName.LastIndexOf(".");
            suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 
            pictureName = DateTime.Now.Ticks.ToString() + suffix;
        }
        try
        {
            if (uploadName != "")
            {
                string path = Server.MapPath(WebRoot + "upfile/headphoto/");
                if (!Directory.Exists(path))
                {
                    Directory.CreateDirectory(path);

                }
                string[] allowedExtensions = { ".gif", ".png", ".bmp", ".jpg", ".jpeg" };
                for (int i = 0; i < allowedExtensions.Length; i++)
                {
                    if (suffix == allowedExtensions[i])
                    {
                        fileok = true;
                    }
                }
                if (fileok)
                {
                    upload_image.PostedFile.SaveAs(path + pictureName);
                    strImgavatar = WebRoot + "upfile/headphoto/" + pictureName;
                }

            }
            else
            {
                fileok = true;
            }
        }
        catch (Exception ex)
        {
            Response.Write(ex);
        }
        #endregion

        if (fileok)
        {
            m_user.Avatar = strImgavatar;

            //设置默认的男女图像
            if (m_user.Avatar == "" || m_user.Avatar.IndexOf("user-no-avatar.gif") > 0 || m_user.Avatar.IndexOf("girl.jpg") > 0 || m_user.Avatar.IndexOf("man.jpg") > 0)
            {
                if (Request["gender"].ToLower() == "f")
                {
                    m_user.Avatar = WebRoot + "upfile/img/girl.jpg";
                }

                if (Request["gender"].ToLower() == "m")
                {
                    m_user.Avatar = WebRoot + "upfile/img/man.jpg";
                }
            }
            string strpassword = Helper.GetString(Request["password"], String.Empty);
            string strrepassword = Helper.GetString(Request["password2"], String.Empty);
            if (strpassword != String.Empty)
            {
                if (strpassword != strrepassword)
                {
                    SetError("两次密码输入的不一致，请重新输入!");
                    Response.Redirect(GetUrl("账户设置", "account_settings.aspx"));
                    Response.End();
                    return;
                }
                else
                {
                    m_user.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(strpassword + PassWordKey, "md5");
                }
            }
            email = Helper.GetString(Request.Form["email"], String.Empty);
            if (!String.IsNullOrEmpty(email))
            {
                if (!Helper.ValidateString(email, "email"))
                {
                    SetError("邮箱格式不正确");
                    Response.Redirect(Request.RawUrl);
                    Response.End();
                    return;
                }
                else
                {
                    int num = 0;
                    UserFilter userfilter = new UserFilter();
                    userfilter.IDNotEqual = AsUser.Id;
                    userfilter.LoginName = email;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        num = session.Users.GetCountByCityId(userfilter);
                    }
                    if (num > 0)
                    {
                        SetError("此邮箱已存在，请更换");
                        Response.Redirect(Request.RawUrl);
                        Response.End();
                        return;
                    }
                    else
                        m_user.Email = email;
                }
            }

            if (Server.HtmlEncode(Request.Form["mobile"]).Trim() != "" && !Helper.ValidateString(Server.HtmlEncode(Request.Form["mobile"]).Trim(), "mobile"))
            {
                SetError("手机号码输入的格式不正确");
                Response.Redirect(GetUrl("账户设置", "account_settings.aspx"));
                Response.End();
                return;
            }
            else
            {
                if (m_user.Mobile != Server.HtmlEncode(Request.Form["mobile"]))
                {
                    IList<IUser> uslist = null;
                    UserFilter usfilter = new UserFilter();
                    usfilter.Mobile = Server.HtmlEncode(Request.Form["mobile"]);
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        uslist = session.Users.GetList(usfilter);
                    }
                    if (uslist != null && uslist.Count == 1)
                    {
                        SetError("此手机号已存在，请重新输入！");
                        Response.Redirect(GetUrl("账户设置", "account_settings.aspx"));
                        Response.End();
                        return;
                    }
                    else
                    {
                        m_user.Mobile = Server.HtmlEncode(Request.Form["mobile"]);
                    }
                }
                else
                {
                    m_user.Mobile = Server.HtmlEncode(Request.Form["mobile"]);
                }
            }
            if (Server.HtmlEncode(Request.Form["qq"]).Trim() != "" && !Helper.ValidateString(Server.HtmlEncode(Request.Form["qq"]).Trim(), "qq"))
            {
                SetError("QQ号码输入的格式不正确");
                Response.Redirect(GetUrl("账户设置", "account_settings.aspx"));
                Response.End();
                return;
            }
            else
            {
                m_user.Qq = Server.HtmlEncode(Request.Form["qq"]);
            }
            if (Server.HtmlEncode(Request.Form["zipcode"]).Trim() != "" && !Helper.ValidateString(Server.HtmlEncode(Request.Form["zipcode"]).Trim(), "zip"))
            {
                SetError("邮政编码输入的格式不正确");
                Response.Redirect(GetUrl("账户设置", "account_settings.aspx"));
                Response.End();
                return;
            }
            else
            {
                m_user.Zipcode = Server.HtmlEncode(Request.Form["zipcode"]);
            }
            //说明启用了ucenter
            if (configs["UC_Islogin"] == "1")
            {

                string err = updateUcenterValue(m_user);
                if (err != "")
                {
                    SetError(err);
                    Response.Redirect(GetUrl("账户设置", "account_settings.aspx"));
                    Response.End();
                    return;
                }
            }
            m_user.Realname = Server.HtmlEncode(Request.Form["realname"]);
            m_user.Address = Server.HtmlEncode(Request.Form["address"]);
            m_user.City_id = Helper.GetInt(Request["city_id"], 0);
            m_user.Gender = Request["gender"];
            int r = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                r = session.Users.Update(m_user);
            }
            if (r > 0)
            {
                SetSuccess("修改成功！");
                Response.Redirect(GetUrl("账户设置", "account_settings.aspx"));
            }
            else
            {
                SetSuccess("修改失败！");
                Response.Redirect(GetUrl("账户设置", "account_settings.aspx"));
            }
        }
        else
        {
            SetError("友情提示：上传图片类型不合法");
            Response.Redirect(GetUrl("账户设置", "account_settings.aspx"));
        }
    }

    /// <summary>
    /// ucenter的方法
    /// </summary>
    /// <param name="usermodel">user对象</param>
    /// <returns>修改的错误信息</returns>
    private string updateUcenterValue(IUser usermodel)
    {
        string err = "";
        int updateUcenter = 0;
        //用户名和邮箱验证通过的情况下去ucenter修改用户信息
        updateUcenter = AS.Ucenter.updateValue.updateUsername(CookieUtils.GetCookieValue("username"), "", Request.Form["password"], email, true);
        if (updateUcenter < 0)
        {
            if (updateUcenter == -10)
            {
                //ucenter设置不正确
                NameValueCollection values = new NameValueCollection();
                values.Add("UC_Islogin", "0");
                WebUtils.CreateSystemByNameCollection1(values);
                err = "ucenter配置不正确,已自动关闭ucenter，请重新登录。";
            }
            else
            {
                err = AS.Ucenter.updateValue.updateUsername(updateUcenter);
            }

        }
        return err;

    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="from1" runat="server">
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="settings">
            <div class="menu_tab" id="dashboard">
                <%LoadUserControl("_MyWebside.ascx", Ordertype); %>
            </div>
            <div id="tabsContent" class="coupons-box">
                <div class="account_set tab">
                    <div class="head">
                        <h2>
                            账户设置</h2>
                        <%LoadUserControl(WebRoot + "UserControls/blockcredittip.ascx", null); %>
                    </div>
                    <div class="sect">
                        <div class="wholetip clear">
                            <h3>
                                1、基本信息</h3>
                        </div>
                        <div class="field email">
                            <label>
                                Email</label>
                            <input type="text" size="30" name="email" id="emails" require="true" datatype="email"
                                class="f-input" value="<%=AsUser.Email %>" />
                        </div>
                        <div class="field">
                            <label>
                                头像</label>
                            <img style="float: left; width: 50px; height: 50px; margin-right: 10px;" src="<%=strImgavatar %>"
                                id="avatar" />
                        </div>
                        <div class="field">
                            <label>
                                上传图像</label>
                            <input type="file" size="30" name="upload_image" id="upload_image" class="f-input"
                                runat="server" />
                            <span class="hint">请上传 512KB 以内的个人肖像图片，最佳尺寸50x50像素</span>
                        </div>
                        <div class="field username">
                            <label>
                                用户名</label>
                            <input type="text" size="30" name="username" id="username" readonly value="<%=AsUser.Username %>"
                                class="f-input readonly" require="true" datatype="limit" min="2" max="16" maxlength="16" />
                        </div>
                        <div class="field password">
                            <label>
                                更改密码</label>
                            <input type="password" size="30" name="password" id="password" class="f-input" value="" />
                            <span class="hint">如果您不想修改密码，请保持空白</span>
                        </div>
                        <div class="field password">
                            <label>
                                确认密码</label>
                            <input type="password" size="30" name="password2" id="passwordconfirm" class="f-input"
                                value="" />
                        </div>
                        <div class="field password">
                            <label>
                                性别</label>
                            <select name="gender" class="f-city" id="gender">
                                <option value="0">请选择</option>
                                <option value="F" <%if (AsUser.Gender == "F")
                                                        { %>selected="selected" <%} %>>女</option>
                                <option value="M" <%if (AsUser.Gender == "M")
                                                        { %>selected="selected" <%} %>>男</option>
                            </select>
                        </div>
                        <div class="wholetip clear">
                            <h3>
                                2、联系信息</h3>
                        </div>
                        <div class="field mobile">
                            <label>
                                手机号码</label>
                            <input type="text" size="30" name="mobile" id="mobile" group="edit" datatype="mobile"
                                class="number" value="<%=AsUser.Mobile %>" /><span class="inputtip">手机号码是我们联系您最重要的方式，请准确填写</span>
                        </div>
                        <div class="field password">
                            <label>
                                QQ</label>
                            <input type="text" size="30" name="qq" id="qq" class="number" group="edit" datatype="qq"
                                value="<%=AsUser.Qq %>" />
                        </div>
                        <div class="field city">
                            <label>
                                所在城市</label>
                            <%=stBCity%>
                        </div>
                        <div class="wholetip clear">
                            <h3>
                                3、派送信息</h3>
                        </div>
                        <div class="field username">
                            <label>
                                真实姓名</label>
                            <input type="text" size="30" name="realname" id="realname" class="f-input" value="<%=AsUser.Realname %>" />
                            <span class="hint">真实姓名请与有效证件姓名保持一致，便于收取物品</span>
                        </div>
                        <div class="field username">
                            <label>
                                街道地址</label>
                            <input type="text" size="30" name="address" id="address" class="f-input" value="<%=AsUser.Address %>" />
                            <span class="hint">为了能及时收到物品，请您详细填写街道信息（无须填写省市区信息）</span>
                        </div>
                        <div class="field">
                            <label>
                                邮政编码</label>
                            <input type="text" maxlength="6" size="10" name="zipcode" id="zipcode" require="true"
                                datatype="zip" class="f-input number" value="<%=AsUser.Zipcode %>" group="edit" />
                        </div>
                        <div class="act">
                            <%--<input id="Submit1" type="submit" value="保存" name="commit" class="validator formbutton" group="g" />--%>
                            <input type="submit" value="更改" name="commit" id="submit" class="formbutton  validator" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</form>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>
