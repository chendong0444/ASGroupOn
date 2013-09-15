<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        string type = Request["n"];
        string value = Helper.GetString(Request["v"], String.Empty);
        string uid = String.Empty;
        if (CookieUtils.GetCookieValue("userid").Length > 0)
            uid = DESEncrypt.Decrypt(CookieUtils.GetCookieValue("userid"), FileUtils.GetKey());
        string email = "";
        string username = "";
        if (uid != null && uid != "" && CookieUtils.GetCookieValue("ucenter") == "ucenter")
        {
            //启用ucenter，并且是普通用户登录
            if (type == "signupemail")//验证邮箱
            {
                AS.Common.Utils.Json js = new AS.Common.Utils.Json("", "");
                //如果使用ucenter还需要去ucenter验证
                email = getEmail(value.Trim(), uid);
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
            if (type == "signupusername")//验证用户名
            {
                AS.Common.Utils.Json js = new AS.Common.Utils.Json("", "");
                username = getUsername(value.Trim(), uid);
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
        }
        else
        {
            //启用ucenter，并且是一站通用户登录
            if (type == "signupemail")//验证邮箱
            {
                AS.Common.Utils.Json js = new AS.Common.Utils.Json("", "");
                //如果使用ucenter还需要去ucenter验证
                email = getEmail(value.Trim());
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
            if (type == "signupusername")//验证用户名
            {
                AS.Common.Utils.Json js = new AS.Common.Utils.Json("", "");
                username = getUsername(value.Trim());
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
        }


    }
    /// <summary>
    /// 邮箱验证,一站通
    /// </summary>
    /// <param name="email"></param>
    /// <returns></returns>
    private string getEmail(string email)
    {
        string value = "";
        int ucentervalue = 0;
        //数据库里是否存在邮箱
        List<Hashtable> hs = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            hs = session.Custom.Query("select * from [user] where email='" + email + "' or username='" + email + "'");
        }
        if (hs != null && hs.Count > 0)
        {
            value = "邮箱已存在";
            return value;
        }
        //判断ucenter邮箱是否存在,如果存在就提示错误信息
        ucentervalue = AS.Ucenter.getValue.getEmail(email);
        if (ucentervalue > 0)
            value = AS.Ucenter.getValue.getEmail(ucentervalue);
        return value;
    }
    /// <summary>
    /// 邮箱验证
    /// </summary>
    /// <param name="email">邮箱</param>
    /// <param name="uid">用户Id</param>
    /// <returns></returns>
    private string getEmail(string email, string uid)
    {
        string value = "";
        int ucentervalue = 0;
        List<Hashtable> hs = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            hs = session.Custom.Query("select * from [user] where Id!=" + uid + " and (email='" + email + "' or username='" + email + "') ");
        }
        //判断数据库里的除了当前用户的邮箱外是否还有其他邮箱
        if (hs != null && hs.Count > 0)
        {
            value = "邮箱已存在";
            return value;
        }
        //判断ucenter邮箱是否存在,如果存在就提示错误信息
        ucentervalue = AS.Ucenter.getValue.getEmail(email);
        if (ucentervalue > 0)
            value = AS.Ucenter.getValue.getEmail(ucentervalue);
        return value;
    }
    /// <summary>
    /// 用户名验证,一站通
    /// </summary>
    /// <param name="username"></param>
    /// <returns></returns>
    private string getUsername(string username)
    {
        string value = "";
        int ucentervalue = 0;
        //数据库里是否存在用户名
        List<Hashtable> hs = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            hs = session.Custom.Query("select * from [user] where  username='" + username + "' or email='" + username + "' ");
        }
        if (hs != null && hs.Count > 0)
        {
            value = "用户名已存在";
            return value;
        }
        //判断ucenter用户名是否存在,如果存在就提示错误信息
        ucentervalue = AS.Ucenter.getValue.getUsername(username);
        if (ucentervalue > 0)
            value = AS.Ucenter.getValue.getUsername(ucentervalue);
        return value;
    }
    /// <summary>
    /// 用户名验证
    /// </summary>
    /// <param name="username">用户名</param>
    /// <param name="uid">用户ID</param>
    /// <returns></returns>
    private string getUsername(string username, string uid)
    {
        string value = "";
        int ucentervalue = 0;
        List<Hashtable> hs = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            hs = session.Custom.Query("select * from [user] where Id!=" + uid + " and (username='" + username + "' or email='" + username + "')");
        }
        if (hs != null && hs.Count > 0)
        {
            value = "用户名已存在";
            return value;
        }
        //判断ucenter用户名是否存在,如果存在就提示错误信息

        ucentervalue = AS.Ucenter.getValue.getUsername(username);
        if (ucentervalue > 0)
        {
            value = AS.Ucenter.getValue.getUsername(ucentervalue);
        }
        return value;
    }
</script>
