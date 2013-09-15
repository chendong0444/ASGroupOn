<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected string upid = String.Empty;
    protected string cid = String.Empty;
    protected AreaFilter areabl = new AreaFilter();
    protected string cityid = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        cid = Helper.GetString(Request["add"], String.Empty);
        upid = Helper.GetString(Request["update"], String.Empty);

        if (Request.HttpMethod != "POST")
        {
            if (Request["add"] != null)
            {
                this.hid.Value = cid;
            }
            if (Request["update"] != null)
            {
                this.uphid.Value = upid;
                xin.Visible = false;
                setValue(int.Parse(Request["update"].ToString()));
            }

        }
        else
        {
            if (Request.Form["button"] == "确定")
            {
                if (this.hid.Value != String.Empty && this.hid.Value != "")
                {
                    insertValue();
                }
                else if (this.uphid.Value != String.Empty && this.uphid.Value != "")
                {
                    updateValue();
                }
                Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                Response.End();
                return;
            }
        }
    }
    private void setValue(int id)
    {
        IList<IArea> area = null;
        areabl.id = id;
        using(IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            area = session.Area.GetList(areabl);
        }
        foreach (IArea item in area)
        {
            name.Value = item.areaname;
            ename.Value = item.ename;
            if (item.display == "N")
            {
                display.Value = "";
                display.Value = "N";
            }
            else
            {
                display.Value = "";
                display.Value = "Y";
            }
            sort_order.Value = item.sort.ToString();
            cid = item.id.ToString();
        }

    }
    private void updateValue()
    {
        IArea cate = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            cate = session.Area.GetByID(int.Parse(this.uphid.Value));
        }        
        cate.areaname = name.Value;
        cate.ename = ename.Value;
        cate.type = "circle";
        cate.display = display.Value.ToUpper();
        cate.sort = int.Parse(sort_order.Value);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int id = session.Area.Update(cate); 
        }
    }
    private void insertValue()
    {
        IArea cate1 = AS.GroupOn.App.Store.CreateArea();
        cate1.areaname = name.Value;
        cate1.ename = ename.Value;
        cate1.cityid = int.Parse(this.hid.Value);
        cate1.type = "circle";
        cate1.display = display.Value.ToUpper();
        cate1.sort = int.Parse(sort_order.Value);
        cate1.circle_id = Convert.ToInt32(this.hid.Value);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int id  = session.Area.Insert(cate1);
        } 
    }
    </script>
<form id="Form1" runat="server">
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span><span
            id="bian" runat="server">编辑</span><span id="xin" runat="server">新建</span><span id="mingcheng"
                runat="server"></span></h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <p>
            中文名称：均要求分类唯一性</p>
        <asp:hiddenfield runat="server" id="hid"></asp:hiddenfield>
         <asp:hiddenfield runat="server" id="uphid"></asp:hiddenfield>
        <table width="96%" class="coupons-table-xq">
            <tr>
                <td width="80" nowrap>
                    <b>中文名称：</b>
                </td>
                <td>
                    <input group="city" type="text" name="name" id="name" require="true" datatype="require"
                        class="f-input" runat="server" />
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>英文名称：</b>
                </td>
                <td>
                    <input type="text" group="city" name="ename" id="ename" require="true" datatype="english"
                        class="f-input" style="text-transform: lowercase;" runat="server" />
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>显示(Y/N)：</b>
                </td>
                <td>
                    <input type="text" group="city" name="display" id="display" class="f-input" style="text-transform: uppercase;"
                        runat="server" />
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>排序(降序)：</b>
                </td>
                <td>
                    <input type="text" group="city" name="sort_order" id="sort_order" require="true"
                        datatype="number" value="0" class="f-input" runat="server" />
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <input type="submit" name="button" group="city" class="validator" action="manag_ajax_Area.aspx"
                        value="确定" />
                </td>
            </tr>
        </table>
    </div>
</div>
</form>
<script>
    window.x_init_hook_validator();
</script>
