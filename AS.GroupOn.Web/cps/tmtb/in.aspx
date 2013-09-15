<%@ Page Language="C#" AutoEventWireup="true" CodePage="65001" %>

<script language="C#" runat="server">
    private string surl;
    private int totime = 30; //有效时间    
    protected void Page_Load(Object Src, EventArgs E)
    {
        if (MD5(!String.IsNullOrEmpty(AS.Common.Utils.WebUtils.config["tmtbkey"]) + Request.QueryString["uid"] + Request.QueryString["sid"]) == Request.QueryString["key"])
        {
            HttpCookie cps = new HttpCookie("cps");
            NameValueCollection values = new NameValueCollection();
            values.Add("name", "tuanmatuanba");
            values.Add("source_tmtb", AS.Common.Utils.Helper.GetString(Request.QueryString["source"], String.Empty));
            values.Add("uid_tmtb", AS.Common.Utils.Helper.GetString(Request.QueryString["uid"], String.Empty));
            values.Add("sid_tmtb", AS.Common.Utils.Helper.GetString(Request.QueryString["sid"], String.Empty));
            values.Add("o_key_tmtb", AS.Common.Utils.Helper.GetString(Request.QueryString["o_key"], String.Empty));
            values.Add("sitekey", AS.Common.Utils.Helper.GetString(AS.Common.Utils.WebUtils.config["tmtbkey"], String.Empty));
            cps.Values.Add(values);
            cps.Expires = DateTime.Now.AddMonths(1);
            Response.Cookies.Add(cps);
            AS.Common.Utils.CookieUtils.SetCookie("fromdomain", "来自团爸团妈cps", DateTime.Now.AddHours(2));
            surl = Request.QueryString["url"];
            Response.Write("<meta HTTP-EQUIV=refresh Content='0;url=" + surl + "'>");
        }

    }
    //C# md5加密
    private string MD5(string code)
    {
        if (!String.IsNullOrEmpty(code))
        {
            return System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(code, "MD5").ToLower();
        }
        else
        {
            return string.Empty;
        }
    }
</script>
