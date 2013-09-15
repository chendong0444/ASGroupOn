<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace=" System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (Request["term"] != null)
        {
            Getkey(Helper.GetString(Request["term"].ToString(), ""));
        }
    }
    public void Getkey(string key)
    {
        string str = "";
        DataSet ds = new DataSet();
        IList<ICatalogs> list = null;
        CatalogsFilter cf = new CatalogsFilter();
        cf.keywordLike = key.Trim();
        using (IDataSession session = Store.OpenSession(false))
        {
            list = session.Catalogs.GetList(cf);
        }
        str = "[";
        if (list != null && list.Count > 0)
        {
            for (int i = 0; i < list.Count; i++)
            {
                string[] num = list[i].keyword.ToString().Split(',');
                for (int j = 0; j < num.Length; j++)
                {
                    if (num[j].IndexOf(key) >= 0 && str.IndexOf("\"" + key + "\"") < 0)
                        str += "{ \"id\":\"" + i.ToString() + "-" + j.ToString() + "\",\"label\":\"" + num[j] + "\",\"value\":\"" + num[j] + "\"},";
                }
            }
        }
        if (str.Length > 1)
        {
            str = str.Substring(0, str.Length - 1);
        }
        str += "]";
        Response.Write(str);
        Response.End();
    }
</script>
