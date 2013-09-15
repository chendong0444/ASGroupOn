<%@ Page Language="C#" AutoEventWireup="true" CodePage="65001" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Hashtable hs = new Hashtable();
        string msg = String.Empty;
        try
        {
            decimal version = AS.Common.Utils.Helper.GetDecimal(Request["db"], AS.Common.Utils.Version.siteversion);
            decimal databaseversion = version;
            ISystem sysmodel = null;
            using (IDataSession session=Store.OpenSession(false))
            {
                sysmodel = session.System.GetByID(1);
            }
            if (sysmodel != null && sysmodel.siteversion!=null)
            {
                databaseversion = Convert.ToDecimal(sysmodel.siteversion);
            }
            if (databaseversion < version)//如果数据库版本号小于程序版本号
            {
                System.Net.WebClient net = new System.Net.WebClient();
                net.Encoding = System.Text.Encoding.UTF8;
                string update = net.DownloadString("http://update.asdht.com/db.aspx?old=" + databaseversion + "&new=" + version + "&domain=" + HttpUtility.UrlEncode(WebUtils.GetDomain(HttpContext.Current.Request.Url.ToString()), System.Text.Encoding.UTF8));
                if (update.Length > 0)
                {
                    if (Utilys.Restore(update))
                    {
                        sysmodel.siteversion = version;
                        int i = 0;
                        using (IDataSession session=Store.OpenSession(false))
                        {
                            i = session.System.Update(sysmodel);
                        }
                        if (i > 0)
                        {
                            databaseversion = version;
                            msg = "升级成功,当前数据库版本为" + databaseversion;
                        }
                        else
                        {
                            msg = "升级失败,当前数据库版本为" + databaseversion;
                        }
                    }
                    else
                        msg = "升级失败,当前数据库版本为" + databaseversion;
                }
                else
                    msg = "升级失败,升级内容为空";
            }

        }
        catch (Exception ex)
        {
            Response.Write(ex.InnerException);
            Response.Write(ex.Message);
        }
        Response.Write(msg);
    }
</script>
