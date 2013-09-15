<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<script runat="server">
    public string strInfo = "";
    protected List<Hashtable> tables = null;
    protected AS.GroupOn.Domain.IUser userlist = null;
    protected AS.GroupOn.DataAccess.Filters.UserFilter filter = new AS.GroupOn.DataAccess.Filters.UserFilter();
    protected override void OnLoad(EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            Response.ContentType = "text/xml";
            string WWWprefix = "";
            //获取网站地址
            WWWprefix = Request.Url.AbsoluteUri;
            WWWprefix = WWWprefix.Substring(7);
            WWWprefix = "http://" + WWWprefix.Substring(0, WWWprefix.IndexOf('/'));
            string cityname = AS.Common.Utils.Helper.GetString(Request["ename"], "quanguo");
            if (cityname != String.Empty)
            {
                cityname = " and ename='" + cityname + "' ";

            }
            string sql1 = "select * from (select * from(select team.*,isnull(Category.ename,'quanguo') as ename,isnull(Category.name,'全国') as cityname from Team left join Category on(Team.City_id=Category.Id) ) t3 where end_time>=GETDATE() and begin_time<=GETDATE()   )t4 order by BEGIN_TIME DESC";
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
            {
                tables = session.GetData.GetDataList(sql1.ToString());
                
            }
            DateTime time = DateTime.Now;
            if (tables != null && tables.Count > 0)
            {
                time = AS.Common.Utils.Helper.GetDateTime(tables[0]["begin_time"], DateTime.Now);
             
            }
            StringBuilder sb = new StringBuilder();
            sb.Append("<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n");
            sb.Append("<!-- generator=\"http://www.asdht.com/ Version " +AS.Common.Utils.Version.SiteVersion + " db " + ASSystemArr["siteversion"] + "\" -->\r\n");
            sb.Append("<?xml-stylesheet href=\"\" type=\"text/xsl\"?>\r\n");
            sb.Append("<rss version=\"2.0\">\r\n");
            sb.Append("<channel>\r\n");
            sb.Append("<title><![CDATA[" + ASSystem.sitetitle + "]]></title>\r\n");
            sb.Append("<description><![CDATA[" + ASSystem.abbreviation + "]]></description>\r\n");
            sb.Append("<link>" + WWWprefix + "</link>\r\n");
            sb.Append("<lastBuildDate>" + DateTime.Now.DayOfWeek.ToString() + "," + time.ToString() + "</lastBuildDate>\r\n");
            sb.Append("<generator>" + ASSystem.siteversion + "</generator>\r\n");


            sb.Append("<image>");
            sb.Append("<url>" + WWWprefix + ASSystem.headlogo + "</url>\r\n");
            sb.Append("<title><![CDATA[" + ASSystem.sitename + "]]></title>\r\n");
            sb.Append("<link>" + ASSystem.sitename + "</link>\r\n");
            sb.Append("<description>Feed provided by asdnt</description>\r\n");
            sb.Append("</image>\r\n");



            string sqlwhere = " Team_type='normal' ";

            if (Request["cityid"] != null && Request["cityid"].ToString() != "")
            {
                sqlwhere = sqlwhere + " and City_id=" + AS.Common.Utils.Helper.GetInt(Request["cityid"], 0);
            }
            
            
            
            if (tables.Count > 0)
            {
               foreach (Hashtable dr in tables)
	            {
                    sb.Append("<item>");
                    sb.Append("<title><![CDATA[" + dr["Title"].ToString() + "]]></title>\r\n");
                    sb.Append("<link>" + WWWprefix + WebRoot + "team.aspx?id=" + dr["Id"].ToString() + "</link>\r\n");
                    sb.Append("<description><![CDATA[" + dr["Summary"] + "<br/> <img src='" + WWWprefix + dr["Image"] + "'>" + dr["Detail"] + "<br/>" + "]]></description>\r\n");

                    filter.ID = AS.Common.Utils.Helper.GetInt(dr["User_id"], 0);
                    using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                    {
                        userlist = session.Users.Get(filter);
                    }
                    if (userlist != null)
                    {
                        sb.Append("<author>" + userlist.Realname + "</author>\r\n");
                    }

                    sb.Append("<city>" + dr["cityname"].ToString() + "</city>\r\n");

                    sb.Append("</item>\r\n");
                }
            }

            sb.Append("</channel>\r\n");
            sb.Append("</rss>\r\n");
            Response.Clear();
            Response.Write(sb.ToString());
            Response.End();
        }
    }
</script>