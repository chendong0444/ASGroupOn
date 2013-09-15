<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">

    public ICatalogs catamodel = null;
    public CatalogsFilter cataft = new CatalogsFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (Request["term"] != null)
        {
            Getkey(Helper.GetString(Request["term"].ToString(), ""));
        }
    }

    #region 根据项目分类的编号，查询项目分类的关键字
    public void Getkey(string key)
    {
        string str = "";
        cataft.visibility = 0;
        cataft.keywordLike = key.Trim();
        DataTable dt = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            dt = AS.Common.Utils.Helper.ToDataTable(session.Catalogs.GetList(cataft).ToList());
        }
        str = "[";
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            string[] num = dt.Rows[i]["keyword"].ToString().Split(',');
            for (int j = 0; j < num.Length; j++)
            {
                if (num[j].IndexOf(key) >= 0 && str.IndexOf("\"" + key + "\"") < 0)
                    str += "{ \"id\":\"" + i.ToString() + "-" + j.ToString() + "\",\"label\":\"" + num[j] + "\",\"value\":\"" + num[j] + "\"},";

                
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
    #endregion

    
</script>
