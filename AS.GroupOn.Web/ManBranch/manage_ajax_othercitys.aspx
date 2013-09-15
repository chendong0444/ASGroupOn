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
        string levelcity = Helper.GetString(Request["lcity"], "x");
        string type = Helper.GetString(Request["type"], String.Empty);
        string othercity = Helper.GetString(Request["othercityid"], String.Empty);
        string str = String.Empty;
        CategoryFilter categoryft = new CategoryFilter();

        if (type == "edit")
        {
            if (cityid == "0" && levelcity == "x")
            {
                str = "<input type='checkbox' name='cityall' id='cityall' onclick='checkallcity()' value=''  disabled/>&nbsp;全选<br>";
            }
            else
            {
                str = "<input type='checkbox' name='cityall' id='cityall' onclick='checkallcity()' value=''  />&nbsp;全选<br>";
            }
        }
        else
        {
            if (cityid == "0" && levelcity == "x")
            {
                str = "<input type='checkbox' name='cityall' id='cityall' onclick='checkallcity()' value='' disabled  />&nbsp;全选<br>";
            }
            else
            {
                str = "<input type='checkbox' name='cityall' id='cityall' onclick='checkallcity()' value=''  />&nbsp;全选<br>";
            }
        }
        categoryft.Zone = "city";
        IList<ICategory> listcategory = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listcategory = session.Category.GetList(categoryft);
        }
        foreach (ICategory item in listcategory)
        {

            if (cityid != item.Id.ToString() && levelcity != item.Id.ToString())
            {
                if (type == "edit")
                {
                    string[] strcity = othercity.Split(',');
                    bool bres = false;
                    for (int i = 0; i < strcity.Length; i++)
                    {
                        if (item.Id.ToString() == strcity[i].ToString())
                        {
                            bres = true;
                        }
                    }
                    if (bres)
                    {
                        if (cityid == "0" && levelcity == "x")
                        {
                            str = str + "<input type='checkbox' name='city_id' value='" + item.Id + "' checked  disabled/>&nbsp;" + item.Name + "&nbsp;&nbsp;";
                        }
                        else
                        {
                            str = str + "<input type='checkbox' name='city_id' value='" + item.Id + "' checked />&nbsp;" + item.Name + "&nbsp;&nbsp;";
                        }
                    }
                    else
                    {
                        if (cityid == "0" && levelcity == "x")
                        {
                            str = str + "<input type='checkbox' name='city_id' value='" + item.Id + "'  disabled/>&nbsp;" + item.Name + "&nbsp;&nbsp;";
                        }
                        else
                        {
                            str = str + "<input type='checkbox' name='city_id' value='" + item.Id + "'  />&nbsp;" + item.Name + "&nbsp;&nbsp;";
                        }

                    }
                }
                else
                {

                    if (cityid == "0" && levelcity == "x")
                    {
                        str = str + "<input type='checkbox' name='city_id' value='" + item.Id + "'  disabled/>&nbsp;" + item.Name + "&nbsp;&nbsp;";
                    }
                    else
                    {
                        str = str + "<input type='checkbox' name='city_id' value='" + item.Id + "'  />&nbsp;" + item.Name + "&nbsp;&nbsp;";
                    }

                }
            }
        }
        Response.Write(str);
        Response.End();
    }
    
</script>
