<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>

<script runat="server">
    protected NameValueCollection configs = new NameValueCollection();
    string strPwd = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection _system = new NameValueCollection();
        _system = WebUtils.GetSystem();


        SetRefer(GetRefer());
        if (!Page.IsPostBack)
        {
            initPage();
        }
    }
    private void initPage()
    {
        if (Request["code"] != null && Request["code"].ToString() != "")
        {
            List<Hashtable> list = new List<Hashtable>();
            string Secret = Request["code"].ToString();
            string sql = "select * from [User] where Secret='" + Helper.GetString(Secret, String.Empty) + "'";

            using (IDataSession seion = Store.OpenSession(false))
            {

                list = seion.GetData.GetDataList(sql);
            }

            DataTable dt = Helper.ConvertDataTable(list);
            DataSet ds = new DataSet();
            ds.Tables.Add(dt);
            configs = WebUtils.GetSystem();
            if (configs["UC_Islogin"] == "1")
            {
                ucenterIsReset(ds);
            }
            else
            {
                ucenterNoReset(ds);
            }
        }
    }
    /// <summary>
    /// 不启用ucenter的方法
    /// </summary>
    /// <param name="ds">DataSet</param>
    private void ucenterNoReset(DataSet ds)
    {
        if (ds != null)
        {
            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {
                    DataRow dr = ds.Tables[0].Rows[0];
                    string uid = dr["id"].ToString();
                    Random rand = new Random();
                    string pwd = "";
                    for (int i = 0; i < 8; i++)
                    {
                        pwd = pwd + rand.Next(0, 9).ToString();
                    }
                    strPwd = pwd;
                    pwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pwd + PassWordKey, "md5");

                    IUser usermodel = Store.CreateUser();
                    usermodel.Id = int.Parse(uid);
                    usermodel.Password = pwd;
                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        seion.Users.UpdatePassword(usermodel);
                    }

                    SetSuccess("您的密码已重置！新密码为" + strPwd);
                    Response.Redirect(WebRoot + "index.aspx");
                }
            }
        }
    }
    /// <summary>
    /// 启用ucenter的方法
    /// </summary>
    /// <param name="ds">DataSet</param>
    private void ucenterIsReset(DataSet ds)
    {
        if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        {
            DataRow dr = ds.Tables[0].Rows[0];
            //获取用户ID
            string uid = dr["id"].ToString();
            //获取用户邮箱
            string email = dr["email"].ToString();
            //获取用户名
            string username = dr["username"].ToString();
            //生成随机密码
            Random rand = new Random();
            string pwd = "";
            for (int i = 0; i < 8; i++)
            {
                pwd = pwd + rand.Next(0, 9).ToString();
            }
            strPwd = pwd;
            //判断ucenter是否同步
            if (dr["ucsyc"].ToString() == "yessyc")
            {
                //说明同步
                //判断ucenter里是否存用户名
                int usernameResult = AS.Ucenter.getValue.getUsername(username);
                if (usernameResult == 1)
                {
                    //说明用户存在，可以修改密码

                    int updateUserResult = AS.Ucenter.updateValue.updateUsername(username, "", strPwd, "", true);
                    if (updateUserResult >= 0 || updateUserResult == -7)
                    {
                        //更新成功或者没有做任何修改(提示：产生的随机密码和ucenter已有的密码相同时不做任何修改)
                        //修改数据库
                        //进行密码加密
                        pwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pwd + PassWordKey, "md5");

                        IUser usermodel = Store.CreateUser();
                        usermodel.Id = int.Parse(uid);
                        usermodel.Password = pwd;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            seion.Users.UpdatePassword(usermodel);
                        }
                        SetSuccess("您的密码已重置！新密码为" + strPwd);
                        Response.Redirect(WebRoot + "index.aspx");
                    }
                    else if (updateUserResult == -10)
                    {
                        //系统异常
                        //ucenter设置不正确
                        NameValueCollection values = new NameValueCollection();
                        values.Add("UC_Islogin", "0");

                        WebUtils.CreateSystemByNameCollection1(values);
                        SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。");
                        Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                        Response.End();
                        return;
                    }
                    else
                    {
                        //更新失败
                        SetError(AS.Ucenter.updateValue.updateUsername(updateUserResult));
                        Response.Redirect(GetRefer());
                        Response.End();
                        return;

                    }
                }
                else
                {
                    //说明用户不存在，无法修改密码,就需要进行ucenter注册
                    int ucenterRegester = AS.Ucenter.setValue.setRegester(username, strPwd, email, false);
                    if (ucenterRegester > 0)
                    {
                        //注册成功,需要修改数据库
                        //进行密码加密
                        pwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pwd + PassWordKey, "md5");
                        IUser usermodel = Store.CreateUser();
                        usermodel.Id = int.Parse(uid);
                        usermodel.Password = pwd;
                        using (IDataSession seion = Store.OpenSession(false))
                        {
                            seion.Users.UpdatePassword(usermodel);
                        }

                        SetSuccess("您的密码已重置！新密码为" + strPwd);
                        Response.Redirect(WebRoot + "index.aspx");
                    }
                    else if (ucenterRegester == -10)
                    {
                        //系统异常
                        //ucenter设置不正确
                        NameValueCollection values = new NameValueCollection();
                        values.Add("UC_Islogin", "0");
                        WebUtils.CreateSystemByNameCollection1(values);
                        SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。");
                        Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                        Response.End();
                        return;
                    }
                    else
                    {
                        //注册失败
                        SetError("密码重置失败");
                        Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                        Response.End();
                        return;
                    }

                }
            }
            else
            {
                //没有同步
                pwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pwd + PassWordKey, "md5");


                IUser usermodel = Store.CreateUser();
                usermodel.Id = int.Parse(uid);
                usermodel.Password = pwd;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    seion.Users.UpdatePassword(usermodel);
                }

                SetSuccess("您的密码已重置！新密码为" + strPwd);
                Response.Redirect(WebRoot + "index.aspx");
            }

        }
    }

</script>
<body>
    <form id="form1" runat="server">
        <div>
        </div>
    </form>
</body>
</html>
