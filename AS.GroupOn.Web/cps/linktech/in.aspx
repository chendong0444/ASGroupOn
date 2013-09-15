<%@ Page Language="C#" ContentType="text/html" ResponseEncoding="utf-8" %>

<script language="C#" runat="server">
    protected void Page_Load(Object Src, EventArgs E)
    {
        if (!IsPostBack) DataBind();

        string a_id = Request.QueryString["a_id"];
        string m_id = Request.QueryString["m_id"];
        string c_id = Request.QueryString["c_id"];
        string l_id = Request.QueryString["l_id"];
        string l_type1 = Request.QueryString["l_type1"];
        int rd = Convert.ToInt32(Request.QueryString["rd"]);
        string url = Request.QueryString["url"];

        if (a_id != null && m_id != null && c_id != null && l_id != null && l_type1.Length > 0 && a_id.Replace("'", "''").Length != 0 && m_id.Replace("'", "''").Length != 0 && c_id.Replace("'", "''").Length != 0 && l_id.Replace("'", "''").Length != 0 && l_type1.Replace("'", "''").Length != 0 && rd.ToString().Replace("'", "''").Length != 0 && url.Replace("'", "''").Length != 0)
        {
            string aid = a_id.Substring(1, 2);
            //Response.AppendHeader("P3P","CP=\"NOI DEVa TAIa OUR BUS UNI\"");
            DateTime dt = DateTime.Now; 					/*需要<%@Import Namespace="System"%>得到当前时间*/
            HttpCookie mycookie = new HttpCookie("cps");			//申明新的COOKIE变量
            NameValueCollection values = new NameValueCollection();
            values.Add("LTINFO", a_id + "|" + c_id + "|" + l_id + "|" + l_type1 + "|");
            values.Add("name", "linktech");
            mycookie.Values.Add(values);
            mycookie.Expires = Convert.ToDateTime(dt + TimeSpan.FromDays(rd));	//设定过期时间为rd天
            Response.Cookies.Add(mycookie);					//写入COOKIE
            AS.Common.Utils.CookieUtils.SetCookie("fromdomain", "来自林科特cps", DateTime.Now.AddHours(2));
            Response.Write("<script>window.location.href='" + url + "';</" + "script>");
        }
        else
        {
            string str = "<script language=\"javascript\">";
            str += "<!--alert('LTMS:参数传输不正确或者缺少参数，请咨询Linktech技术负责人！');history.go(-1);//-->";
            str += "</" + "script>";
            Response.Write(str);
        }
    }
</script>

