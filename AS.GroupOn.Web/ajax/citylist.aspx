<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace=" System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected string type = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        type = Helper.GetString(Request["type"], String.Empty);
        int pid = Helper.GetInt(Request["pid"], 0);
        IList<IFarecitys> listfarecity = null;
        FarecitysFilter ff = new FarecitysFilter();
        ff.pid = pid;
        using (IDataSession seion = Store.OpenSession(false))
        {
            listfarecity = seion.Farecitys.GetList(ff);
        }
        if (type != String.Empty && type == "mobile")
        {
            string html = "<select pid='" + pid + "' onchange='changecity(" + pid + ")' required";
            if (pid == 0)
                html = html + " name='province'";
            html = html + " ><option value=''>请选择</option>";
            string option = String.Empty;

            if (listfarecity != null && listfarecity.Count > 0)
            {
                foreach (IFarecitys farecity in listfarecity)
                {
                    option = option + "<option oid='" + farecity.id + "' value='" + farecity.id + "," + farecity.name + "" + "'>" + farecity.name + "</option>";
                }
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
        else
        {
            string html = "<select pid='" + pid + "' datatype='require' require='true' msg='请选择省市区' msgid='errorcitylist' group='a' onchange='changecity(" + pid + ")'";
            if (pid == 0)
                html = html + " name='province'";
            html = html + " ><option value=''>请选择</option>";
            string option = String.Empty;

            if (listfarecity != null && listfarecity.Count > 0)
            {
                foreach (IFarecitys farecity in listfarecity)
                {
                    option = option + "<option oid='" + farecity.id + "' value='" + farecity.name + "'>" + farecity.name + "</option>";
                }
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
    }
    
</script>
