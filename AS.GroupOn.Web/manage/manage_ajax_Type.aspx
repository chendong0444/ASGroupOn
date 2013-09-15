<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    
    protected string zone = String.Empty;
    protected int cid = 0;
    protected ICategory cate = null;
    protected override void OnLoad(EventArgs e)
    {
        cid = Helper.GetInt(Request["update"], 0);
        zone = Helper.GetString(Request["Zone"],String.Empty);
            
        if (!IsPostBack) 
        {
            if(cid !=null && cid !=0){
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Partner_Edit))
                {
                    SetError("没有编辑商户分类的权限");
                    Response.Redirect("Type_ShanghuFenlei.aspx");
                    Response.End();
                    return;
                }
                else 
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                    {
                        cate = session.Category.GetByID(cid);
                    }
                }
                
            }
            else if (zone != null && zone != String.Empty) 
            {
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Partner_Add)) 
                {
                    SetError("没有新建商户分类的权限");
                    Response.Redirect("Type_ShanghuFenlei.aspx");
                    Response.End();
                    return;
                }
            
            }
        }
    } 
</script>

<%if(zone!=null && zone !=String.Empty){ %>
<form method="post" class="validator" action="">
<input type="hidden" name="action" value="Add_ShangHu_Type" />
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 308px;">
     <h3>
         <span id="Span1" class="close" onclick="return X.boxClose();">关闭</span>
     </h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <p>
            中文名称,英文名称：均要求分类唯一性</p>
        <table style="width: 78%">
            <tr>
                <td width="80" nowrap>
                    <b>中文名称：</b>
                </td>
                <td>
                    <input group="city" type="text" name="name"  require="true" datatype="require"class="f-input"/>
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>英文名称：</b>
                </td>
                <td>
                    <input type="text" group="city" name="ename" require="true" datatype="english"
                        class="f-input" style="text-transform: lowercase;"/>
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>首字母：</b>
                </td>
                <td>
                    <input type="text" group="city" name="letter"  maxlength="1" require="true"
                        datatype="english" class="f-input" style="text-transform: uppercase;"/>
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>自定义分组：</b>
                </td>
                <td>
                    <input type="text" group="city" name="czone" class="f-input"  />
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>导航显示(Y/N)：</b>
                </td>
                <td>
                    <input type="text" group="city"datatype="english" maxlength="1" name="disp" class="f-input" style="text-transform: uppercase;"
                         />
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>排序(降序)：</b>
                </td>
                <td>
                    <input type="text" group="city" name="sortorder" require="true"
                        datatype="number" value="0" class="f-input"  />
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <input type="submit" name="button" id="button" group="city" class="validator formbutton" value="确定" />
                </td>
            </tr>
        </table>
    </div>
</div>
</form>
<%} else{%>
<form class="validator" method="post" action="">
<input type="hidden" name="action" value="Bianji_ShangHu_Type" />
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 307px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>
    </h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <p>
            中文名称,英文名称：均要求分类唯一性</p>
        <table style="width: 78%">
        <input type="hidden" value="<%=cid %>" name="categoryid" />
            <tr>
                <td width="80" nowrap>
                    <b>中文名称：</b>
                </td>
                <td>
                    <input group="city" type="text" name="name" value="<%=cate.Name %>" require="true" datatype="require"class="f-input"/>
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>英文名称：</b>
                </td>
                <td>
                    <input type="text" group="city" name="ename" value="<%=cate.Ename %>" require="true" datatype="english"
                        class="f-input" style="text-transform: lowercase;"/>
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>首字母：</b>
                </td>
                <td>
                    <input type="text" group="city" name="letter" value="<%=cate.Letter %>"   maxlength="1" require="true"
                        datatype="english" class="f-input" style="text-transform: uppercase;"/>
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>自定义分组：</b>
                </td>
                <td>
                    <input type="text" group="city" name="czone"  value="<%=cate.Czone %>"  class="f-input"  />
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>导航显示(Y/N)：</b>
                </td>
                <td>
                    <input type="text" group="city" name="disp" datatype="english" maxlength="1" value="<%=cate.Display %>"  class="f-input" style="text-transform: uppercase;"
                         />
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>排序(降序)：</b>
                </td>
                <td>
                    <input type="text" group="city" name="sortorder" require="true" value="<%=cate.Sort_order %>" datatype="number" value="0" class="f-input"  />
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <input type="submit" name="button" id="button" group="city" class="validator formbutton" value="确定" />
                </td>
            </tr>
        </table>
    </div>
</div>
</form>
<%} %>