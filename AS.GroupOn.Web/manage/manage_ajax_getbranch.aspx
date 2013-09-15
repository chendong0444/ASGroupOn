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
<%@ Import Namespace="System.Data" %>
<script runat="server">

    TeamFilter team_bll = new TeamFilter();
    ITeam team_model = null;
    protected override void OnLoad(EventArgs e)
    {
        string str = String.Empty;
        string str1 = String.Empty;
        string team_id = String.Empty;
        base.OnLoad(e);
        string partnerid = Helper.GetString(Request["partnerid"], String.Empty);
        team_id = Helper.GetString(Request["team_id"], String.Empty);
        //一个商户对应多个分站
        BranchFilter branchBll = new BranchFilter();
        IList<IBranch> lists = null;
        branchBll.partnerid = AS.Common.Utils.Helper.GetInt(partnerid,0);
        DataTable dt = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            lists = session.Branch.GetList(branchBll);            
        }
        dt = AS.Common.Utils.Helper.ToDataTable(lists.ToList());
        if (dt == null)
        {
            str += "<select name=\"fenzhan\" id=\"brfen\" Class=\"f-shinput\" style=\"width:30%\" runat=\"Server\">";
            str += " <option value='0'>===========请选择分站============</option>";
            str += "</select>";
            Response.Write(str);
            Response.End();
        }
        else
        {

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (dt.Rows[i]["branchname"].ToString() != "" && dt.Rows[i]["branchname"].ToString() != null && dt.Rows[i]["branchname"].ToString() != "0")
                {
                    if (team_id != "" && team_id != String.Empty)
                    {
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            team_model = session.Teams.GetByID(int.Parse(team_id));
                        }                        
                        if ((int.Parse(dt.Rows[i]["id"].ToString()) == team_model.branch_id) && team_model != null)
                        {
                            str1 += "<option selected='selected' value='" + dt.Rows[i]["id"].ToString() + "'>" + dt.Rows[i]["branchname"].ToString() + "</option>";
                        }
                        else
                        {
                            str1 += "<option value='" + dt.Rows[i]["id"].ToString() + "'>" + dt.Rows[i]["branchname"].ToString() + "</option>";
                        }

                    }
                    else
                    {
                        str1 += "<option value='" + dt.Rows[i]["id"].ToString() + "'>" + dt.Rows[i]["branchname"].ToString() + "</option>";

                    }


                }

            }
            str += "<select name=\"fenzhan\" id=\"brfen\"  class=\"f-input\" style=\"width:30%\" runat=\"Server\">";
            str += " <option value='0'>===========请选择分站============</option>";
            str += str1;
            str += "</select>";

            Response.Write(str);
            Response.End();
        }
    }
</script>