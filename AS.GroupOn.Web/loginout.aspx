<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<script runat="server">
    private NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        //是否启用了ucenter，如果启用了就执行同步退出方法
        _system = PageValue.CurrentSystemConfig;
       
        if (AS.Common.Utils.WebUtils.config["UC_Islogin"] == "1")
        {
            string str = "";
            try
            {
                str = AS.Ucenter.setValue.setlogout();
            }
            catch (Exception ex)
            {
                NameValueCollection values = new NameValueCollection();
                values.Add("UC_Islogin", "0");
                AS.Common.Utils.WebUtils.CreateSystemByNameCollection1(values);
                SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。" + ex.Message);
                Response.Redirect(GetUrl("首页", "index.aspx"));
                Response.End();
                return;
            }
            ClearCookie();
            if (str != null && str != "")
            {
                //SetSuccess("退出成功！");
                Response.Write(str);
                Response.Write("<script>window.location.href='" + this.Page.ResolveUrl(PageValue.WebRoot + "index.aspx") + "'</"+"script>");
                Response.End();
            }
            else
            {
                //SetError("退出失败");
                if (_system["setmallindex"] == "1")//开启启用商城为首页
                {
                    Response.Redirect(GetUrl("商城首页", "mall_index.aspx"));
                }
                else
                {
                    Response.Redirect(GetUrl("首页", "index.aspx"));
                }
                Response.End();
            }
        }
        else
        {
            ClearCookie();
            //SetSuccess("退出成功！");
            if (_system["setmallindex"] == "1")//开启启用商城为首页
            {
                Response.Redirect(GetUrl("商城首页", "mall_index.aspx"));
            }
            else
            {
                Response.Redirect(GetUrl("首页", "index.aspx"));
            }
            Response.End();
        }
    }
</script>
