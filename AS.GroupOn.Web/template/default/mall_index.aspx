<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<script runat="server">
    private NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
    }
    protected string output()
    {
        _system = PageValue.CurrentSystemConfig;
        if (_system != null)
        {
            if (_system["MallTemplate"] == "0")//米奇模板
                return WebUtils.LoadPageString(PageValue.TemplatePath + "mall_miqi.aspx");
            else if (_system["MallTemplate"] == "1") //京东模板
                return WebUtils.LoadPageString(PageValue.TemplatePath + "mall_jindong.aspx");
        }
        return WebUtils.LoadPageString(PageValue.TemplatePath + "mall_miqi.aspx");
    }
</script>
<%=output() %>