<%@ Page Language="C#"   AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">
    // Debug="true" EnableEventValidation="false" ViewStateEncryptionMode="Never"
    
    protected ProductFilter productft = new ProductFilter();
    protected int id = 0;
    protected IProduct productmodel;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        id = Helper.GetInt(Request["id"], 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            productmodel = session.Product.GetByID(id);
        }
        //if (Request.HttpMethod == "POST")
        //{
        //    //if (Request.Form["button"] == "提交")
        //    //{
        //        UserFilter userft = new UserFilter();
        //        productmodel.Status = Helper.GetInt(Request["ddlproductstatus"], 1);
        //        productmodel.ramark = Helper.GetString(Request["remark"], String.Empty);
        //        productmodel.adminid = AdminPage.AsAdmin.Id;
        //        productmodel.Operatortype = 0;

        //        TeamFilter teamft = new TeamFilter();
        //        IList<ITeam> listteam = null;
        //        int ires = 0;
        //        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        //        {
        //            ires = session.Product.Update(productmodel);
        //        }

        //        if (ires > 0)
        //        {
        //            System.Data.DataTable dt = null;
        //            teamft.productid = id;
        //            ITeam team = null;
        //            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        //            {
        //                listteam = session.Teams.GetList(teamft);
        //                team = session.Teams.Get(teamft);
        //            }
        //            dt = AS.Common.Utils.Helper.ToDataTable(listteam.ToList());
        //            if (dt != null)
        //            {
        //                if (dt.Rows.Count > 0)
        //                {
        //                    for (int i = 0; i < dt.Rows.Count; i++)
        //                    {
        //                        if (productmodel.Status == 8)
        //                        {
        //                            //下架  当产品有项目手动设置下架的时候，项目status 应该设置为下架状态
        //                            team.status = 8;
        //                            team.productid = id;
        //                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        //                            {
        //                                int id2 = session.Teams.Update(team);
        //                            }

        //                        }
        //                        else if (productmodel.Status == 1)
        //                        {
        //                            //上架  当产品有项目手动设置下架的时候，项目status 应该设置为下架状态
        //                            team.status = 1;
        //                            team.productid = id;
        //                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        //                            {
        //                                int id2 = session.Teams.Update(team);
        //                            }
        //                        }


        //                    }
        //                }
        //            }


        //            SetSuccess("产品审核成功！");
        //        }
        //        else
        //        {
        //            SetError("产品审核失败！");
        //        }
        //        Response.Redirect(Request.UrlReferrer.AbsoluteUri);
        //        Response.End();
        //        return;
        //    //}
        //}
    }
   
</script>
<script src="../upfile/js/index.js" type="text/javascript"></script>
<form id="form1" runat="server">
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>产品审核</h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <input type="hidden" name="id" value="<%=id %>" />
        <table class="coupons-table-xq">
            <tr>
                <td>
                    <b>状态：</b>
                </td>
                <td>
                    <select id="ddlproductstatus" name="ddlproductstatus">
                        <%if (productmodel != null)
                          { %>
                        <option value="1" <%if(productmodel.status==1){%>selected <% } %>>上架</option>
                        <%if (productmodel.status != 1 && productmodel.status != 8)
                          { %>
                        <option value="2" <%if(productmodel.status==2){%>selected <% } %>>拒绝</option>
                        <%} %>
                        <option value="8" <%if(productmodel.status==8){%>selected <% } %>>下架</option>
                        <%} %>
                    </select>
                </td>
            </tr>
            <tr>
                <td>
                    <b>备注：</b>
                </td>
                <td>
                    <textarea id="remark" cols="40" rows="5" name="remark"></textarea>
                </td>
            </tr>
            <tr>
                <td colspan="2" height="10">
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td>
                    &nbsp;
                </td>
                <td>
                    <%--<input type="submit" name="button" id="button" group="product" class="validator formbutton"
                        action="manage_ajax_ProductReview.aspx" value="提交" />--%>
                        <input type="hidden" name="action" value="check" />
                       <%-- <input type="submit" id="save" class="validator formbutton"
                     value="提交" runat="server" onserverclick="Save"  />--%>
                     <input id="Submit1" type="submit" value="提交" name="commit" class="validator formbutton"
                                            group="g" />
                </td>
            </tr>
        </table>
    </div>
</div>
</form>
<script type="text/javascript">
    window.x_init_hook_validator();
</script>
