<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<script runat="server">
    private NameValueCollection _system = new NameValueCollection();
    protected bool IsPC = true;
    protected override void OnLoad(EventArgs e)
    {
        GetRedirect();
        base.OnLoad(e);
    }
    protected string output()
    { 
        string UserAgent = Request.ServerVariables["HTTP_USER_AGENT"];
        bool isClickPCVersion = Request["PCVersion"] == "1";
        if (isClickPCVersion)
            CookieUtils.SetCookie("pcversion", "1");
        else
            isClickPCVersion = CookieUtils.GetCookieValue("pcversion") == "1";
        
        IsPC = WebUtils.isPC(UserAgent);
        if (!IsPC && !isClickPCVersion)
        {
            Response.Redirect(GetUrl("手机版首页", "index.aspx"));
            Response.End();
            return "1";
        }
        else
        {
            _system = PageValue.CurrentSystemConfig;
            if (_system["setmallindex"] == "1")//开启启用商城为首页
            {
                Response.Redirect(GetUrl("商城首页", "mall_index.aspx"));
                Response.End();
                return "1";
            }
            else
            {
                if (CurrentTeam != null)
                {
                    if (_system != null)
                    {
                        if (_system["moretuan"] == "0")//一日多团1
                            return WebUtils.LoadPageString(PageValue.TemplatePath + "index_tuanmore.aspx");
                        else if (_system["moretuan"] == "1") //一日多团2
                            return WebUtils.LoadPageString(PageValue.TemplatePath + "index_tuanmore2.aspx");
                        else if (_system["moretuan"] == "2")//一日多团3
                            return WebUtils.LoadPageString(PageValue.TemplatePath + "index_tuanmore3.aspx");
                        else if (_system["moretuan"] == "3")//一日多团4
                            return WebUtils.LoadPageString(PageValue.TemplatePath + "index_tuanmore4.aspx");
                        else if (_system["moretuan"] == "4")//一日多团5
                            return WebUtils.LoadPageString(PageValue.TemplatePath + "index_tuanmore5.aspx");
                        else if (_system["moretuan"] == "5")
                            return WebUtils.LoadPageString(PageValue.TemplatePath + "index_tuanmore6.aspx");
                        else
                            return WebUtils.LoadPageString(PageValue.TemplatePath + "team_view.aspx");
                    }
                    else
                    {
                        return WebUtils.LoadPageString(PageValue.TemplatePath + "team_view.aspx");
                    }
                }
                else
                {
                    return WebUtils.LoadPageString(PageValue.TemplatePath + "help_Email_Subscribe.aspx");
                }
            }
        }

    }
</script>
<%=output() %>
