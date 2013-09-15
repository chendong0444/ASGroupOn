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
<script runat="server">
    protected IUser users = null;
    protected IList<ICategory> listcate = null;
    protected int id = 0;
    ICategory cacity = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        id = Helper.GetInt(Request.QueryString["adminfenzhanid"], 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            users = session.Users.GetByID(id);
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            cacity = session.Category.GetByID(users.City_id);
        }
        if (cacity!=null)
        {
            city.Items.Add(new ListItem(cacity.Name, cacity.Id.ToString()));
        }
        else
        {
            city.Items.Add(new ListItem("未选城市","0"));
        }
        CategoryFilter cf = new CategoryFilter();
        cf.Zone = WebUtils.GetCatalogName(CatalogType.city);
        using (IDataSession seion = Store.OpenSession(false))
        {
            listcate = seion.Category.GetList(cf);
        }

        if (listcate != null && listcate.Count > 0)
        {
            foreach (ICategory category in listcate)
            {

                city.Items.Add(new ListItem(category.Name.ToString(), category.Id.ToString()));

                if (Session["s_city"] != null && Session["s_city"].ToString() != "")
                {
                    city.Value = Session["s_city"].ToString();
                }

            }
        }
    }
  
</script>
<form id="form1" runat="server">
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>管理员分站</h3>
    <div style="overflow-x: hidden; padding: 10px;">
    <input  type="hidden" name="userid" value="<%=id %>" />
         <%if (users!=null)
           {
               if (users.IsManBranch=="Y")
               {
                   if (cacity!=null)
                   {
                   %>
                <h3 style="color:Red">
                   管理城市是：<b><%=cacity.Name%></b></h3>
                   重新选择城市：
             <% }
                   else
                   {
                       %>
                       <h3 style="color:Red">
                   管理城市是：<b>不存在,请重新选择</b></h3>
                   重新选择城市：
                   <%
                   }
               }
               else
               {%><h3 style="color:Red">
                  <b>还不是管理员分站管理员，请设定</b></h3>
              <% }%>
   <table>
                 <tr>
                                <td valign="top" height="45" align="right" style="font-size: 14px; padding-top: 2px">
                                    管理城市&nbsp;&nbsp;
                                </td>
                                <td valign="top" class="hzis">
                                    <select name="city" class="f-city" runat="server" id="city">
                                    </select>
                                </td>
                </tr>
           <%}
           else
           {
               SetError("出现错误，请关闭重新进入");
           } %>  
           <tr>
            <input id="action" type="hidden" name="action" value="null" />
           <td><input id="btn_qd" runat="server" class="formbutton" type="submit" value="确定" /></td><td><input id="btn_qx" runat="server" class="formbutton" type="submit" value="取消授权" /></td>
          </tr>
        </table>
        <script>
            $(function () {
                $("#btn_qd").mouseover(function () {
                    $("#action").val('qdadminfz');
                })
                $("#btn_qx").mouseover(function () {
                    $("#action").val('qxadminfz');
                })
            })
        </script>
    </div>
</div>
 
</form>

 
 
