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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">

    protected System.Data.DataTable table = new System.Data.DataTable();
    protected System.Data.DataTable table1 = new System.Data.DataTable();
    protected string html = String.Empty;
    protected string html1 = String.Empty;
    protected CategoryFilter category = new CategoryFilter();
    protected IList<ICategory> listCategory = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        string strLetter = AS.Common.Utils.Helper.GetString(Request["letter"], String.Empty);
        string id = AS.Common.Utils.Helper.GetString(Request["pid"], String.Empty);
        if (id != String.Empty)
        {
            GetcityList(id);
        }
        string cityid = AS.Common.Utils.Helper.GetString(Request["cityid"], String.Empty);
        string citypid = AS.Common.Utils.Helper.GetString(Request["citypid"], String.Empty);
        if (cityid != "" && citypid != "")//初始化二级城市
        {
            initData(cityid, citypid);
        }
        else if (strLetter != "")//初始化弹出层
        {
            initData(strLetter);
        }
        else
        {
            initData(cityid);
        }

    }
    private void initData(string strLetter)
    {
        if (IsNum(strLetter))
        {            
            category.Zone = "city";
            category.Display = "Y";
            category.City_pid = 0;
            category.Id =Convert.ToInt32(strLetter);

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                listCategory = session.Category.GetList(category);
            }
            table = AS.Common.Utils.Helper.ToDataTable(listCategory.ToList());
            
            html = GetCitys(table, strLetter);
             
            Response.Write(html + html1);
        }
        else
        {
            string str = String.Empty;
            CategoryFilter catbll = new CategoryFilter();
            System.Data.DataTable dt = null;
            CategoryFilter category = new CategoryFilter();
            IList<ICategory> listCategory = null;
            category.Zone = "city";
            category.Display = "Y";            
            category.Letter= strLetter.Trim().ToLower().ToString();
            category.AddSortOrder(CategoryFilter.Sort_Order_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                listCategory = session.Category.GetList(category);
            }
            dt = AS.Common.Utils.Helper.ToDataTable(listCategory.ToList());
            
           
            str = str + "<span id=\"cityfilter\">";
            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    str = str + "<a title=\"" + dt.Rows[i]["name"] + "团购\" >" + dt.Rows[i]["Ename"] + "</a>";
                }
            }
            str = str + "</span>";
            Response.Write(str);
            Response.End();
        }

    }
    private void initData(string id, string pid)
    {
        System.Data.DataTable table = new System.Data.DataTable();
        System.Data.DataTable table1 = new System.Data.DataTable();
        string html = String.Empty;
        string html1 = String.Empty;
        CategoryFilter category = new CategoryFilter();
        IList<ICategory> listCategory = null;
        category.Zone = "city";
        category.Display = "Y";
        category.City_pid = 0;
        category.Id = AsAdmin.City_id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listCategory = session.Category.GetList(category);
        }
        table = AS.Common.Utils.Helper.ToDataTable(listCategory.ToList());

        html = GetCitys(table, id);
        CategoryFilter category1 = new CategoryFilter();
        IList<ICategory> listCategory1 = null;
        category1.Zone = "city";
        category1.Display = "Y";
        category1.City_pid = Convert.ToInt32(id);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listCategory1 = session.Category.GetList(category1);
        }
        table1 = AS.Common.Utils.Helper.ToDataTable(listCategory1.ToList());

        html1 = GetCitys(table1, pid);

        Response.Write(html + html1);

    }
    private string GetCitys(System.Data.DataTable dt, string id)
    {
        string html = "<select pid='" + id + "' datatype='require' require='true' msg='请选择省市区' msgid='errorcitylist' group='a' onchange='changecity(" + id + ")'";
        html = html + " ><option value=''>请选择</option>";
        string option = String.Empty;
        for (int i = 0; i < dt.Rows.Count; i++)
        {            
            if (dt.Rows[i]["id"].ToString() == id)
            {
                option = option + "<option selected='selected'" + " oid='" + dt.Rows[i]["id"] + "' value='" + dt.Rows[i]["name"] + "'>" + dt.Rows[i]["name"] + "</option>";
            }
            else
            {
                option = option + "<option oid='" + dt.Rows[i]["id"] + "' value='" + dt.Rows[i]["name"] + "'>" + dt.Rows[i]["name"] + "</option>";
            }
        }
        html = html + option + "</select>";
        return html;
    }
    private void GetcityList(string id)
    {
        int pid = Convert.ToInt32(id);

        System.Data.DataTable table = new System.Data.DataTable();

        CategoryFilter category1 = new CategoryFilter();
        IList<ICategory> listCategory1 = null;
        category1.Zone = "city";
        category1.Display = "Y";
        category1.City_pid = pid;
        if (id=="0")
        {
            category1.Id = AsAdmin.City_id;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listCategory1 = session.Category.GetList(category1);
        }
        table = AS.Common.Utils.Helper.ToDataTable(listCategory1.ToList());
        
        string html = "<select id='selecitys' pid='" + pid + "' datatype='require' require='true' msg='请选择省市区' msgid='errorcitylist' group='a' onchange='changecity(" + pid + ")'";
        if (pid == 0)
            html = html + " name='province'";
        html = html + " ><option value=''>请选择</option>";
        string option = String.Empty;
        for (int i = 0; i < table.Rows.Count; i++)
        {

            option = option + "<option oid='" + table.Rows[i]["id"] + "' value='" + table.Rows[i]["name"] + "'>" + table.Rows[i]["name"] + "</option>";

        }
        html = html + option + "</select>";
        if (option != String.Empty)
        {
            Response.Write(html);
            Response.End();
        }
        else
        {
            Response.Write("");
            Response.End();
        }
    }
    public static bool IsNum(String str)
    {
        for (int i = 0; i < str.Length; i++)
        {
            if (!Char.IsNumber(str, i))
                return false;
        }
        return true;
    }
</script>
