<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        int ddlvalue = Helper.GetInt(Request["ddlvalue"], 0);
        int hids = Helper.GetInt(Request["hids"], 0);
        
        ICategory icategory = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            icategory = session.Category.GetByID(ddlvalue);

        }
        
        string str = "0";
        if (icategory != null)
        {
            if (icategory.Ename == "Free_shipping")
            {
                str = "Free_shipping";
            }
            else if (icategory.Ename == "Deduction")
            {
                str = "Deduction";
            }
            else if (icategory.Ename == "Feeding_amount")
            {
                str = "Feeding_amount";
            }
        }
        Response.Write(str);
        Response.End();
    }

    
</script>