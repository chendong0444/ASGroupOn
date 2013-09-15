<%@ Page Language="C#" AutoEventWireup="true" CodePage="65001" %>
<script language="C#" runat="server">
    //yotao cps入口
protected void Page_Load(Object Src, EventArgs E)
{
    HttpCookie cookies = new HttpCookie("cps");
    NameValueCollection values = new NameValueCollection();
    values.Add("name", "yotao"); //这是名称是标识哪家cps的 是必须的 以下是不同商家cps要求的不同的参数。根据接口文档要求做调整
    values.Add("uid", AS.Common.Utils.Helper.GetString(Request["uid"], String.Empty));
    values.Add("aid", AS.Common.Utils.Helper.GetString(Request["aid"], String.Empty));
    values.Add("yid", AS.Common.Utils.Helper.GetString(Request["yid"], String.Empty));
    values.Add("sid", AS.Common.Utils.WebUtils.config["yotaokey"]);//网站在yotao的ID;
    values.Add("key", AS.Common.Utils.WebUtils.config["yotaosecret"]);//网站key
    cookies.Values.Add(values);
    cookies.Expires = DateTime.Now.AddMonths(1);//设置cookie过期时间为1个月。这是cps商家要求的
    Response.Cookies.Add(cookies);
    string gourl = String.Empty;//跳转地址 主要是接收cps传过来的url参数。进行跳转。每个cps商家的url参数名称不一样。
    gourl = AS.Common.Utils.Helper.GetString(Request["purl"], String.Empty);//yotao的参数名是purl
    if (gourl == String.Empty) gourl = Page.ResolveUrl(AS.GroupOn.Controls.PageValue.WebRoot + "index.aspx"); //做一个安全处理，如果url为空字符串则跳转首页
    AS.Common.Utils.CookieUtils.SetCookie("fromdomain", "来自yotaocps");
    Response.Write("<script>window.location.href='" + gourl + "'<" + "/script>"); //跳转到指定页面
}
</script>
