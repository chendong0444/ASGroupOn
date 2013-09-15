<%@ Page Language="C#" AutoEventWireup="true"  Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    protected IList<ICategory> iListCategory = null;
    protected StringBuilder sb2 = new StringBuilder();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Api_List))
        {
            SetError("你不具有查看API分类列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        getTypeFenlei();

        if (Request["delId"] != null && Request["delId"].ToString() != "")
        {
            Del();
        }
        if (Request.QueryString["item"] != null && Request.QueryString["item"] != "")
        {
            BulkDel();//批量删除
        }
    }


    private void getTypeFenlei()
    {
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<th width='5%'><input type='checkbox' id='checkall' name='checkall' />全选</th>");
        sb1.Append("<th width='5%'>ID</th>");
        sb1.Append("<th width='15%'>中文名称</th>");
        sb1.Append("<th width='15%'>英文名称</th>");
        sb1.Append("<th width='10%'>API父ID</th>");
        sb1.Append("<th width='10%'>首字母</th>");
        sb1.Append("<th width='10%'>自定义分组</th>");
        sb1.Append("<th width='10%' nowrap>导航</th>");
        sb1.Append("<th width='5%' nowrap>排序</th>");
        sb1.Append("<th width='15%'>操作</th>");
        sb1.Append("</tr>");

        CategoryFilter filter = new CategoryFilter();
        filter.Zone = "group"; //项目分类
        filter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCategory = session.Category.GetList(filter);
        }
        if (iListCategory != null)
        {
            DataTable dtClass = ToDataTable(iListCategory);
            BindData(dtClass, 0, "");
        }
        Literal1.Text = sb1.ToString();
        
    }

    private void BindData(DataTable dt, int id, string blank)
    {

        if (dt != null && dt.Rows.Count > 0)
        {
            DataView dv = new DataView(dt);
            dv.RowFilter = "City_pid = " + id.ToString();
            if (id != 0)
            {
                blank += "|─";
            }
            int i = 0;
            foreach (DataRowView dr in dv)
            {
                if (dr["City_pid"].ToString() == "0")
                {
                    sb2.Append("<tr class='alt'>");
                }
                else
                {
                    sb2.Append("<tr>");
                }
                sb2.Append("<td><input type='checkbox' id='check' name='check' value=" + dr["Id"] + " /></td>");
                sb2.Append("<td>" + dr["Id"] + "</td>");
                sb2.Append("<td>" + blank + dr["Name"] + "</td>");
                sb2.Append("<td>" + dr["Ename"] + "</td>");
                sb2.Append("<td>" + dr["City_pid"] + "</td>");
                sb2.Append("<td>" + dr["Letter"] + "</td>");
                sb2.Append("<td>" + dr["Czone"] + "</td>");
                if (dr["Display"].ToString().Trim().ToUpper() == "Y")
                {
                    sb2.Append("<td>显示</td>");
                }
                else
                {
                    sb2.Append("<td>隐藏</td>");
                }
                sb2.Append("<td>" + dr["Sort_order"] + "</td>");
                sb2.Append("<td class='op'>");
                sb2.Append("<a href='Type_ApiClassAdd.aspx?addPid=" + dr["Id"] + "'>新建子分类</a>｜");
                sb2.Append("<a href='Type_ApiClassAdd.aspx?updateId=" + dr["Id"] + "'>编辑</a>｜");
                sb2.Append("<a class=\"remove-record\" ask='确定要删除吗?' href='Type_XiangmuFenlei.aspx?delId=" + dr["Id"] + "'>删除</a>");
                sb2.Append("</td>");
                sb2.Append("</tr>");
                i++;
                BindData(dt, Convert.ToInt32(dr["Id"]), blank);
            }
            Literal2.Text = sb2.ToString();
        }
    }

    public DataTable ToDataTable(IList<ICategory> list)
    {
        System.Data.DataTable result = new System.Data.DataTable();
        if (list.Count > 0)
        {
            System.Reflection.PropertyInfo[] propertys = list[0].GetType().GetProperties();
            foreach (System.Reflection.PropertyInfo pi in propertys)
            {
                result.Columns.Add(pi.Name, pi.PropertyType);
            }
            for (int i = 0; i < list.Count; i++)
            {
                ArrayList tempList = new ArrayList();
                foreach (System.Reflection.PropertyInfo pi in propertys)
                {
                    object obj = pi.GetValue(list[i], null);
                    tempList.Add(obj);
                }
                object[] array = tempList.ToArray();
                result.LoadDataRow(array, true);
            }
        }
        return result;
    }

    /// <summary>
    /// 删除
    /// </summary>
    protected void Del()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Api_Delete))
        {
            SetError("你不具有删除API分类列表的权限！");
            Response.Redirect("Type_XiangmuFenlei.aspx");
            Response.End();
            return;

        }
        else
        {
            int strid = Helper.GetInt(Request["delId"], 0);
            if (strid > 0)
            {
                int del_id = 0;

                IList<ICategory> iListCategory = null;
                CategoryFilter categoryfiler = new CategoryFilter();
                categoryfiler.City_pid = strid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iListCategory = session.Category.GetList(categoryfiler);
                }
                if (iListCategory.Count > 0)
                {
                    SetError("友情提示：此类下面有子类，请先删除子类在删除父类");
                }
                else
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        del_id = session.Category.Delete(strid);//.exts_proc_del_api(strid);
                    }
                    if (del_id > 0)
                    {
                        SetSuccess("删除成功");
                    }
                }
                Response.Redirect("Type_XiangmuFenlei.aspx");
                Response.End();
                return;
            }
        }
    }

    /// <summary>
    /// 批量删除
    /// </summary>
    protected void BulkDel()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Api_Delete))
        {
            SetError("你不具有删除API分类列表的权限！");
            Response.Redirect("Type_XiangmuFenlei.aspx");
            Response.End();
            return;
        }
        else
        {
            string items = Request.QueryString["item"];
            string[] item = items.Split(';');
            foreach (string ids in item)
            {
                int strid = Helper.GetInt(ids, 0);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int i = 0;
                    i = session.Category.Delete(strid);
                    if (i > 0)
                    {
                        SetSuccess("删除选中成功！");
                    }
                    else
                    {
                        SetError("删除选中失败！");
                    }
                }
            }
            Response.Redirect("Type_XiangmuFenlei.aspx?page=" + Helper.GetInt(Request.QueryString["url"], 1));
        }
    }
    
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head" style="height:35px;">
                                    <h2>
                                        API分类</h2>
                                    
                                </div><ul class="filter">
                                        <li>
                                            <a href="Type_ApiClassAdd.aspx">新建api分类</a>
                                        </li>
                                    </ul>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                    
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
					                    <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="10">
                                                <input id="items" type="hidden" />
                                                <input value="删除选中" type="button" class="formbutton" style="padding: 1px 6px;" onClick='javascript:GetDeleteItem(<%= Helper.GetInt(Request.QueryString["page"], 1) %>);' />
                                                
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>

<script type="text/javascript">
    $(function () {

        $("#checkall").click(function () {
            $("input[id='check']").attr("checked", $("#checkall").attr("checked"));
        });
    })
    function GetDeleteItem(url) {
        var str = "";
        var urls = url;
        $("input[id='check']:checked").each(function () {
            str += $(this).val() + ";";
        });

        $("#items").val(str.substring(0, str.length - 1));

        if (str.length > 0) {
            var istrue = window.confirm("是否删除选中项？");
            if (istrue) {
                window.location = "Type_XiangmuFenlei.aspx?item=" + $("#items").val() + "&url=" + urls;
            }
        }
        else {
            alert("你还没有选择删除项！ ");
        }
    }
</script>