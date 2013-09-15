<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace=" System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">

    public IUser usermodel = Store.CreateUser();
    protected NameValueCollection configs = new NameValueCollection();
    int regesterType = 0;//返回状态
    string regesterValue = "";//返回错误信息
    protected override void OnLoad(EventArgs e)
    {
        configs = WebUtils.GetSystem();
        string vname = Helper.GetString(Request["n"], String.Empty);
        string value = Helper.GetString(Request["v"], String.Empty);

        string app = Helper.GetString(Request["app"], String.Empty);//得到角色

        string email = "";
        string username = "";
        if (vname == "signupemail")//验证邮箱
        {
            Json js = new Json("", "");
            //如果使用ucenter还需要去ucenter验证
            email = GetEmail(value.Trim());
            if (email != "")
            {
                js.error = 1;

                js.data.data = email;
            }
            else
            {
                js.error = 0;
            }
            Response.Clear();
            Response.Write(JsonUtils.GetJson(js));
            Response.End();
            return;
        }
        if (vname == "signupusername")//验证用户名
        {
            Json js = new Json("", "");
            username = GetUserName(value.Trim());
            if (username != "")
            {
                js.error = 1;
                js.data.data = username;
            }
            else
            {
                js.error = 0;
            }
            Response.Clear();
            Response.Write(JsonUtils.GetJson(js));
            Response.End();
            return;
        }

        if (vname == "signupmobile")
        {
            Json js = new Json("", "");
            js.error = GetUserMobile(value.Trim());
            if (js.error == 1)
            {
                js.data.data = "此手机号已存在";
            }
            Response.Clear();
            Response.Write(JsonUtils.GetJson(js));
            Response.End();
            return;
        }
        if (vname == "editemail")
        {
            Json js = new Json("", "");
            email = GetEmail(value.Trim(), AsUser.Id);
            if (email != "")
            {
                js.error = 1;
                js.data.data = email;
            }
            else
            {
                js.error = 0;
            }
            Response.Clear();
            Response.Write(JsonUtils.GetJson(js));
            Response.End();
            return;
        }


        //添加或修改角色
        if ("addrole" == app)
        {
            int id = Helper.GetInt(Request["id"], 0);

            if (id > 0)
            {
                Response.Write(JsonUtils.GetJson(WebUtils.LoadPageString(WebRoot + "webpage/ajaxPage/ajax_addRole.aspx?id=" + id), "dialog"));
                Response.End();
                return;
            }
            else
            {
                Response.Write(JsonUtils.GetJson(WebUtils.LoadPageString(WebRoot + "webpage/ajaxPage/ajax_addRole.aspx"), "dialog"));
                Response.End();
                return;
            }
        }

    }

    #region 根据此邮箱是否被注册
    public string GetEmail(string email)
    {
        return GetEmail(email, 0);
    }


    public string GetEmail(string email, int userid)
    {
        regesterValue = "";

        UserFilter uf = new UserFilter();
        uf.LoginName = email;
        using (IDataSession seion = Store.OpenSession(false))
        {
            usermodel = seion.Users.Get(uf);
        }

        if (usermodel != null)
        {
            if (usermodel.Id != userid)
            {
                regesterValue = "邮箱已存在";
                return regesterValue;
            }
            if (configs["UC_Islogin"] == "1")//如果使用ucenter还需要去ucenter验证
            {
                regesterValue = AS.Ucenter.getValue.getEmail(AS.Ucenter.getValue.getEmail(email));
            }
        }
        return regesterValue;
    }

    #endregion


    #region 查询此用户名是否使用
    public string GetUserName(string name)
    {
        regesterValue = "";

        UserFilter uf = new UserFilter();
        uf.LoginName = name;
        using (IDataSession seion = Store.OpenSession(false))
        {
            usermodel = seion.Users.Get(uf);
        }

        //如果使用ucenter还需要去ucenter验证
        if (configs["UC_Islogin"] == "1")
        {
            if (usermodel != null)
            {
                return "用户名已存在"; //标志此用户已存在
            }
            else
            {
                regesterValue = (AS.Ucenter.getValue.getUsername(AS.Ucenter.getValue.getUsername(name)));

            }
        }
        else
        {
            if (usermodel != null)
            {
                return "用户名已存在"; //标志此用户已存在
            }
            else
            {
                return "";   //标志此用户没有使用，可以注册
            }
        }
        return regesterValue;

    }
    #endregion

    #region 查询此手机号是否使用
    public int GetUserMobile(string mobile)
    {
        IList<IUser> listuser = null;
        UserFilter uf = new UserFilter();
        uf.Mobile = mobile;
        using (IDataSession seion = Store.OpenSession(false))
        {
            listuser = seion.Users.GetList(uf);
        }
        if (listuser != null)
        {
            if (listuser.Count > 0)
            {
                return 1; //标志此手机号已存在
            }
            else
            {
                return 0;   //标志此手机号没有使用，可以注册
            }
        }
        else
        {
            return 0;   //标志此手机号没有使用，可以注册
        }
    }
        #endregion
    
</script>
