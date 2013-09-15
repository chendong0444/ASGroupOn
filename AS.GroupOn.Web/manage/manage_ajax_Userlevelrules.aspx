<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage"%>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<script runat="server">
    protected int userid = 0;
    protected int leveid = 0;
    protected string zone = String.Empty;
    protected IUserlevelrules user =null;
    protected ICategory category = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack) 
        {
            userid = AS.Common.Utils.Helper.GetInt(Request["userida"], 0);
            zone = Request["zone"];
            if (userid != null && userid > 0)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    user = session.Userlevelrelus.GetByID(userid);
                }
                leveid = user.levelid;
                if (leveid != null)
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        category = session.Category.GetByID(leveid);
                    }
                }
            }
        }
        if (Request.HttpMethod == "POST") 
        {
            if (Request["update"] == "true") 
            {
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_UserLeve_Edit))
                {
                    SetError("没有编辑用户等级的权限");
                    Response.Redirect(WebRoot + "manage/Type_YonghuDengji.aspx");
                    Response.End();
                    return;
                }
                else 
                {
                    IUserlevelrules userlevelrule = new AS.GroupOn.Domain.Spi.Userlevelrules();
                    userlevelrule.maxmoney = AS.Common.Utils.Helper.GetDecimal(Request["maxmoney"], 0);
                    userlevelrule.minmoney = AS.Common.Utils.Helper.GetDecimal(Request["minmoney"], 0);
                    userlevelrule.discount = AS.Common.Utils.Helper.GetDouble(Request["discount"], 0);
                    userlevelrule.id = AS.Common.Utils.Helper.GetInt(Request["userleveid"], 0);
                    userlevelrule.levelid = AS.Common.Utils.Helper.GetInt(Request["leveid"], 0);
                    int ids = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        ids = session.Userlevelrelus.Update(userlevelrule);
                    }
                    if (ids > 0)
                    {
                        ICategory cfilters = new AS.GroupOn.Domain.Spi.Category();
                        cfilters.Id = AS.Common.Utils.Helper.GetInt(Request["leveid"], 0) ;
                        cfilters.Name = AS.Common.Utils.Helper.GetString(Request["leveName"], "");
                        cfilters.Sort_order = AS.Common.Utils.Helper.GetInt(Request["sort_order"],0);
                        cfilters.Zone = "grade";
                        cfilters.Display = "Y";
                        int counts = 0;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            counts = session.Category.Update(cfilters);
                        }
                        if (counts > 0)
                        {
                            SetSuccess("修改成功");
                        }
                        else
                        {
                            SetError("修改失败");
                        }
                        Response.Redirect(WebRoot + "manage/Type_YonghuDengji.aspx");
                        Response.End();
                        return;
                    }
                }
                
            }else if(Request["add"]=="true")
            {
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_UserLeve_Add))
                {
                    SetError("没有创建用户等级的权限");
                    Response.Redirect(WebRoot + "manage/Type_YonghuDengji.aspx");
                    Response.End();
                    return;
                }
                else 
                {
                    ICategory cgory = null;
                    CategoryFilter cfilter = new CategoryFilter();
                    cfilter.Name = AS.Common.Utils.Helper.GetString(Request["leveName"], ""); ;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        cgory = session.Category.Get(cfilter);
                    }
                    if (cgory != null)
                    {
                        if ( AS.Common.Utils.Helper.GetString(Request["leveName"], "") == cgory.Name)
                        {
                            SetError("等级已存在或格式不正确");
                            Response.Redirect(WebRoot + "manage/Type_YonghuDengji.aspx");
                            Response.End();
                            return;
                        }
                    }
                    ICategory category = new AS.GroupOn.Domain.Spi.Category();
                    category.Name = AS.Common.Utils.Helper.GetString(Request["leveName"], ""); ;
                    category.Zone = "grade";
                    category.Display = "Y";
                    category.Sort_order = AS.Common.Utils.Helper.GetInt(Request["sort_order"], 0);
                    int leveid = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        leveid = session.Category.Insert(category);
                    }
                    if (leveid > 0)
                    {
                        IUserlevelrules userlevelrules = new AS.GroupOn.Domain.Spi.Userlevelrules();
                        userlevelrules.levelid = AS.Common.Utils.Helper.GetInt(leveid, 0);
                        userlevelrules.maxmoney = AS.Common.Utils.Helper.GetDecimal(Request["maxmoney"], 0);
                        userlevelrules.minmoney = AS.Common.Utils.Helper.GetDecimal(Request["minmoney"], 0);
                        userlevelrules.discount = AS.Common.Utils.Helper.GetDouble(Request["discount"], 0);

                        int userleveid = 0;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            userleveid = session.Userlevelrelus.Insert(userlevelrules);
                        }
                        if (userleveid > 0)
                        {
                            SetSuccess("添加成功");
                        }
                        else
                        {
                            SetError("添加失败");
                        }
                        Response.Redirect(WebRoot + "manage/Type_YonghuDengji.aspx");
                        Response.End();
                        return;
                    }
                
                }
            
            }
        }
    }
</script>
<%if (zone != null && zone != String.Empty)
  { %>
<form  method="post" action="<%=WebRoot %>manage/manage_ajax_Userlevelrules.aspx?add=true" >
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">
	<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>新建用户等级<span id="mingcheng"  ></span></h3>
	<div style="overflow-x:hidden;padding:10px;">
	<p>中文名称要求分类唯一性</p>
	<table width="96%" class="coupons-table-xq">
		<tr>
            <td width="80" nowrap><b>中文名称：</b></td>
            <td><input group="city" type="text" name="leveName"  require="true" datatype="require" class="f-input"   /></td>
        </tr>
		<tr>
            <td width="80" nowrap><b>消费上限：</b></td>
            <td><input group="city" type="text" name="maxmoney"  require="true" datatype="money" class="f-input"    /></td>
        </tr>
		<tr>
            <td nowrap><b>消费下限：</b></td>
            <td><input type="text" group="city" name="minmoney"  require="true" datatype="money"  class="f-input" style="text-transform:lowercase;"   /></td>
        </tr>
		<tr>
            <td nowrap><b>购买商品折扣：</b></td>
            <td><input type="text" group="city" name="discount" maxlength="4"  require="true" datatype="require" class="f-input" style="text-transform:uppercase;"  value="1"   /></td>
        </tr>
        <tr>
            <td colspan="2"><font style="color:Red">例如：(输入1代表不打折,输入0.95代表9.5折)</font></td>
        </tr>
		<tr>
            <td nowrap><b>排序(降序)：</b></td>
            <td>
                <input type="text" group="city" name="sort_order" id="sort_order" require="true" datatype="number" value="0"  class="f-input"   />
            </td>
        </tr>
		<tr>
            <td></td>
            <td><input type="submit"  name="but"  group="user" class="validator  formbutton"  value="确定"  /></td>
        </tr>
	</table>
	</div>
</div>
</form>
<script type="text/javascript">
    $(function () { window.x_init_hook_validator(); });
</script>
    <%}
  else
  { %>
<form method="post" action="<%=WebRoot %>manage/manage_ajax_Userlevelrules.aspx?update=true">
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">
    <h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>编辑用户等级<span id="mingcheng"></span></h3>
	<div style="overflow-x:hidden;padding:10px;">
	<p>中文名称要求分类唯一性</p>
	<table width="96%" class="coupons-table-xq">
		<tr>
            <input type="hidden" name="userleveid" value="<%=userid %>" />
            <input type="hidden" name="leveid" value="<%=leveid %>" />
            <td width="80" nowrap><b>中文名称：</b></td>
            <td><input group="city" type="text" name="leveName" value="<%=category.Name %>"  require="true" datatype="require" class="f-input"   /></td>
        </tr>
		<tr>
            <td width="80" nowrap><b>消费上限：</b></td>
            <td><input group="city" type="text" name="maxmoney" value="<%=user.maxmoney %>"  require="true" datatype="require" class="f-input"    /></td>
        </tr>
		<tr>
            <td nowrap><b>消费下限：</b></td>
            <td><input type="text" group="city" name="minmoney" value="<%=user.minmoney %>"  require="true" datatype="require"  class="f-input" style="text-transform:lowercase;"   /></td>
        </tr>
		<tr>
            <td nowrap><b>购买商品折扣：</b></td>
            <td><input type="text" group="city" name="discount" value="<%=user.discount %>" require="true" datatype="require" class="f-input" style="text-transform:uppercase;"  value="1"   /></td>
        </tr>
        <tr>
            <td colspan="2"><font style="color:Red">例如：(输入1代表不打折,输入0.95代表9.5折)</font></td>
        </tr>
		<tr>
            <td nowrap><b>排序(降序)：</b></td>
            <td>
                <input type="text" group="city" name="sort_order" value="<%=category.Sort_order %>" require="true" datatype="number" value="0"  class="f-input"   />
            </td>
        </tr>
		<tr>
            <td></td>
            <td><input type="submit"  name="but"  group="user" class="validator  formbutton"  value="确定"  /></td>
        </tr>
	</table>
	</div>
</div>
</form>
<script type="text/javascript">
    $(function () { window.x_init_hook_validator(); });
</script>
    <%} %>
