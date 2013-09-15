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
    TeamFilter teamft = new TeamFilter();
    ITeam team_model = null;
    SalesFilter salesft = new SalesFilter();
    protected override void OnLoad(EventArgs e)
    {
        string str = String.Empty;
        string str1 = String.Empty;
        string team_id = "";
        base.OnLoad(e);
        string partnerid = Helper.GetString(Request["partnerid"], String.Empty);
        team_id = Helper.GetString(Request["team_id"], String.Empty);


        //一个商户对应多个销售人员
        PartnerFilter parft = new PartnerFilter();
        IPartner parmodel = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            parmodel = session.Partners.GetByID(Helper.GetInt(partnerid,0));
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            team_model = session.Teams.GetByID(Helper.GetInt(team_id,0));
        }  
        
        if (parmodel != null)
        {
            string[] saleids = parmodel.saleid.ToString().Split(',');

            for (int ii = 0; ii < saleids.Length; ii++)
            {
                if (saleids[ii].ToString() != "" && saleids[ii] != null && saleids[ii] != "0")
                {

                    ISales salname = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        salname = session.Sales.GetByID(int.Parse(saleids[ii]));
                    }
                    
                    if (salname != null)
                    {
                        if (team_id != "" && team_id != String.Empty )
                        {
                            if (team_model != null)
                            {

                                if ((Helper.GetInt(saleids[ii], 0) == team_model.sale_id))
                                {
                                    str1 += "<option selected='selected' value='" + saleids[ii].ToString() + "'>" + salname.username + "</option>";

                                }
                                else
                                {
                                    str1 += "<option value='" + saleids[ii].ToString() + "'>" + salname.username + "</option>";
                                }

                            }
                            else
                            {
                                str1 += "<option value='" + saleids[ii].ToString() + "'>" + salname.username + "</option>";
                            }
                        }
                        else
                        {
                            str1 += "<option value='" + saleids[ii].ToString() + "'>" + salname.username + "</option>";
                        }
                    }

                }
            }
        }

        str += "<select class=\"f-input\" name=\"xiaoshou\" id=\"xiaoid\" style=\"width:30%\">";
        str += " <option value='0'>===========请选择销售人员============</option>";
        str += str1;
        str += "</select>";

        Response.Write(str);
        Response.End();
    }

 </script>