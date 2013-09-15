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
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        string cityid = Helper.GetString(Request["cityid"], String.Empty);
        string type = Helper.GetString(Request["type"], String.Empty);
        string areaid = Helper.GetString(Request["areaid"], String.Empty);
        string zone = Helper.GetString(Request["zone"], String.Empty);
        string str = String.Empty;
        AreaFilter areaft = new AreaFilter();

        if (zone == "area")
        {
            CategoryFilter catft = new CategoryFilter();            
            catft.Zone = "city";
            catft.City_pid = AS.Common.Utils.Helper.GetInt( cityid,0);
            DataTable dt = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                dt = AS.Common.Utils.Helper.ToDataTable(session.Category.GetList(catft).ToList());
            }
            if (dt != null && dt.Rows.Count > 0)//该城市有二级城市
            {
                str += "0&";
                str = str + " <select id=\"ddllevelcity\" name=\"ddllevelcity\" style=\"width:135px;\" class=\"f-input\" onchange=\"getlevelcity()\">";
                str = str + "<option value=\"0\" >请选择二级城市</option>";
                if (dt != null && dt.Rows.Count > 0)
                {
                    for (int j = 0; j < dt.Rows.Count; j++)
                    {
                        if (areaid == dt.Rows[j]["id"].ToString())
                        {
                            str = str + "<option selected value=\"" + dt.Rows[j]["id"].ToString() + "\" >" + dt.Rows[j]["name"].ToString() + "</option>";
                        }
                        else
                        {
                            str = str + "<option value=\"" + dt.Rows[j]["id"].ToString() + "\" >" + dt.Rows[j]["name"].ToString() + "</option>";
                        }
                    }
                }
                str = str + "</select>";
            }
            else
            {
                str += "1&";
                str = str + " <select id=\"ddlarea\" name=\"ddlarea\"  style=\"width:135px;\" class=\"f-input\" onchange=\"getcircle()\">";
                str = str + "<option value=\"0\" >请选择区域</option>";
                areaft.type = "area";
                areaft.cityid = Convert.ToInt32(cityid);
                DataTable dt2 = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    dt2 = AS.Common.Utils.Helper.ToDataTable(session.Area.GetList(areaft).ToList());
                }
                if (dt2 != null)
                {
                    for (int i = 0; i < dt2.Rows.Count; i++)
                    {
                        if (areaid == dt2.Rows[i]["id"].ToString())
                        {
                            str = str + "<option selected value=\"" + dt2.Rows[i]["id"].ToString() + "\" >" + dt2.Rows[i]["areaname"].ToString() + "</option>";
                        }
                        else
                        {
                            str = str + "<option value=\"" + dt2.Rows[i]["id"].ToString() + "\" >" + dt2.Rows[i]["areaname"].ToString() + "</option>";
                        }
                    }
                }
                str = str + "</select>";
            }
        }
        else if (zone == "levelcity")
        {
            str = str + " <select id=\"ddlarea\" name=\"ddlarea\" style=\"width:135px;\" class=\"f-input\" onchange=\"getcircle()\">";
            str = str + "<option value=\"0\" >请选择区域</option>";
            areaft.type = "area";
            areaft.cityid = AS.Common.Utils.Helper.GetInt(cityid,0);
            DataTable dt3 = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                dt3 = AS.Common.Utils.Helper.ToDataTable(session.Area.GetList(areaft).ToList());
            }
            if (dt3 != null)
            {
                for (int i = 0; i < dt3.Rows.Count; i++)
                {
                    if (areaid == dt3.Rows[i]["id"].ToString())
                    {
                        str = str + "<option selected value=\"" + dt3.Rows[i]["id"].ToString() + "\" >" + dt3.Rows[i]["areaname"].ToString() + "</option>";
                    }
                    else
                    {
                        str = str + "<option value=\"" + dt3.Rows[i]["id"].ToString() + "\" >" + dt3.Rows[i]["areaname"].ToString() + "</option>";
                    }
                }
            }
            str = str + "</select>";
        }
        else if (zone == "circle")
        {
            str = str + " <select id=\"ddlcircle\" name=\"ddlcircle\" style=\"width:135px;\" class=\"f-input\" >";
            str = str + "<option value=\"0\" >请选择商圈</option>";
            areaft.type = "circle";
            areaft.cityid = Convert.ToInt32(cityid);
            DataTable dt = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                dt = AS.Common.Utils.Helper.ToDataTable(session.Area.GetList(areaft).ToList());
            }
            if (dt != null)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    if (areaid == dt.Rows[i]["id"].ToString())
                    {
                        str = str + "<option selected value=\"" + dt.Rows[i]["id"].ToString() + "\" >" + dt.Rows[i]["areaname"].ToString() + "</option>";
                    }
                    else
                    {
                        str = str + "<option value=\"" + dt.Rows[i]["id"].ToString() + "\" >" + dt.Rows[i]["areaname"].ToString() + "</option>";
                    }
                }
            }
            str = str + "</select>";

        }


        Response.Write(str);
        Response.End();
    }


</script>