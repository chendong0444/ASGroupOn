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
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string strLetter = Helper.GetString(Request["letter"], String.Empty);
        if (strLetter != String.Empty)
        {
            initData(strLetter);
        }
        string citys = String.Empty;
        if (!string.IsNullOrEmpty(Request.Params["province"]))
        {
            string city = ",";
            string province = Request.Params["province"];
            IList<ICity> citylist = GetTable(province);
            if (citylist != null)
            {
                foreach (var item in citylist)
                {
                    citys = citys + city + item.Ename + "|" + item.Name;
                }
            }
            Response.Clear();
            Response.Write(citys.Substring(1));
            Response.End();
        }
    }
    private void initData(string strLetter)
    {
        string html = String.Empty;
        CityFilter cf = new CityFilter();
        cf.Display = "Y";
        cf.Letter = strLetter.ToUpper();
        IList<ICity> citylsit = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            citylsit = session.Citys.GetList(cf);
        }
        if (citylsit != null && citylsit.Count > 0)
        {
            html = "<span id=\"cityfilter\">";
            foreach (var item in citylsit)
            {
                html = html + "<a title=\"" + item.Name + "团购\" href=\"" + WebRoot + "city.aspx?ename=" + item.Ename + "\" >" + item.Name + "</a>";
            }
            html = html + "</span>";
        }
        Response.Write(html);
        Response.End();
    }
    protected IList<ICity> GetTable(string province)
    {
        IList<ICity> list = null;
        IList<ICity> lists = null;
        CityFilter cf = new CityFilter();
        CityFilter cfs = new CityFilter();
        cf.Name = province;
        using (IDataSession session=Store.OpenSession(false))
        {
            list = session.Citys.GetList(cf);
        }
        if (list!=null)
        {
            ICity c = list[0];
            cfs.City_pid = c.Id;
            using (IDataSession session=Store.OpenSession(false))
            {
                lists = session.Citys.GetList(cfs);
            }
            if (lists == null || lists.Count == 0)
            {
                return list;
            }
        }
        return lists;
    }
    </script>