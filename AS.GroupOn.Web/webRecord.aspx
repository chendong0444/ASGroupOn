<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FrontPage" %>

<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (string.IsNullOrEmpty(Request["website"]) && Request["impower"] == "授 权")
        {
            SetError("请输入域名！");
        }

        if (!string.IsNullOrEmpty(Request["website"]) && Request["impower"] == "授 权")
        {
            string currentUrl = HttpContext.Current.Request.Url.AbsoluteUri;
            string website = currentUrl.Split('/')[2].Trim();
            if (website.IndexOf(":") > 0)
            {
                website = website.Substring(0, website.IndexOf(":"));
            }
            AS.Common.Utils.WebUtils.LogWrite("网站授权", "website=" + website);
            string siteOther = string.IsNullOrEmpty(Request["website"]) ? string.Empty : Request["website"].ToLower().Trim();
            if (!siteOther.Contains("http://"))
            {
                siteOther = "http://" + siteOther;
            }
            siteOther = siteOther.Split('/')[2].ToLower().Trim();
            AS.Common.Utils.WebUtils.LogWrite("网站授权", "siteOther=" + siteOther);

            if (!String.Equals(siteOther, website, StringComparison.OrdinalIgnoreCase))
            {
                SetError("当前网站域名与你输入域名的不一致,请确认！");
            }
            else
            {
                AS.Common.Utils.WebUtils.LogWrite("网站授权", "手动授权url=" + website);
                int record = AS.GroupOn.UrlRewrite.HttpModule.GetRecord(website);
                AS.Common.Utils.WebUtils.CheckRecord(record);
                if (record == 1)
                {
                    SetSuccess("网站授权已开启！");
                }
                else
                {
                    SetError("网站未被收录！");
                }
            }
        }
    }
</script>
<%LoadUserControl(PageValue.TemplatePath + "_htmlheader.ascx", null); %>
<%LoadUserControl(PageValue.TemplatePath + "_header.ascx", null); %>
<style type="text/css">
    #TextWeb
    {
        font-family: arial,helvetica,clean,sans-serif;
        font-size: 14px;
        padding: 3px 4px;
        border-color: #FF932C;
        border-style: solid;
        border-width: 1px;
        width: 250px;
        text-transform: none;
        text-indent: 0px;
        display: inline-block;
        text-align: -webkit-auto;
        font: -webkit-small-control;
        letter-spacing: normal;
        word-spacing: normal;
    }
</style>
<body class="bg-alt">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="maillist">
                    <div id="content">
                        <div class="box">
                            <div class="box-content welcome">
                                <div class="head" style="padding-top: 10px;">
                                    <h2>
                                        网站授权</h2>
                                </div>
                                <div class="sect">
                                    <div class="lead">
                                        <h4>
                                            把您的域名进行收录确认。</h4>
                                    </div>
                                    <div class="enter-address">
                                        <p>
                                            请确认你输入的域名与当前域名相一致。
                                        </p>
                                        <div class="enter-address-c">
                                            <div class="mail divcenter">
                                                <label>
                                                    域名地址：</label>
                                                <table style="text-align: center">
                                                    <tr>
                                                        <td>
                                                            <input id="TextWeb" name="website" require="true" group="a" type="text" value='<%=Request[" website"] %>'
                                                                size="20" require="true" />
                                                        </td>
                                                        <td>
                                                            <input id="subWeb" type="submit" group="a" class="formbutton validator" value="授 权"
                                                                name="impower" />
                                                        </td>
                                                    </tr>
                                                </table>
                                                <span class="tip"></span>
                                            </div>
                                            <div class="city">
                                                <label>
                                                    &nbsp;</label>
                                            </div>
                                        </div>
                                        <div class="clear">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="sidebar">
                        <div class="side-pic">
                            <p>
                                <img src="<%=WebRoot%>upfile/img/subscribe-pic1.jpg" /></p>
                            <p>
                                <img src="<%=WebRoot%>upfile/img/subscribe-pic2.jpg" /></p>
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
<%LoadUserControl(PageValue.TemplatePath + "_footer.ascx", null); %>
<%LoadUserControl(PageValue.TemplatePath + "_htmlfooter.ascx", null); %>
