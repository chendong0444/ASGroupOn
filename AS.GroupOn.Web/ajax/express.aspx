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
    protected List<Hashtable> hashtable = null;
    protected override void OnLoad(EventArgs e)
    {

        base.OnLoad(e);
        string name = Helper.GetString(Request["citys"], String.Empty);
        if (name.Length > 0)
        {
            string[] names = name.Split(',');
            string sql = String.Empty;
            for (int i = 0; i < names.Length; i++)
            {
                sql = sql + " and nocitys  not like '%," + names[i] + ",%'";
            }
            sql = sql.Substring(4);
            sql = "select * from (select Category.id,name,(','+nocitys+',') as nocitys,sort_order,Display from Category  left join expressnocitys on(category.id=expressnocitys.expressid)where zone='express')t where  Display='Y' and ((" + sql + ")or nocitys is null) order by sort_order desc";
            DataTable table = new DataTable();

            using (IDataSession seion = Store.OpenSession(false))
            {
                hashtable = seion.GetData.GetDataList(sql);
            }

            table = Helper.ConvertDataTable(hashtable);

            string html = "<label>快递公司</label>";
            for (int i = 0; i < table.Rows.Count; i++)
            {
                DataRowObject dro = new DataRowObject(table.Rows[i]);
                if (i == 0)
                    html = html + "<input type='radio' name='express' checked='checked' require='true' group='a' datatype='require' id='express" + i + "' msg='请选择快递公司' msgid='errorexpressarea' onchange='selectexpress(" + dro["id"] + ")' value='" + dro["id"] + "' />&nbsp;" + dro["name"] + "&nbsp;";
                else
                    html = html + "<input type='radio' name='express' require='true' group='a' datatype='require' id='express" + i + "' msg='请选择快递公司' msgid='errorexpressarea' onchange='selectexpress(" + dro["id"] + ")' value='" + dro["id"] + "' />&nbsp;" + dro["name"] + "&nbsp;";
            }
            Response.Write(html);
            Response.End();
        }


    }
</script>
