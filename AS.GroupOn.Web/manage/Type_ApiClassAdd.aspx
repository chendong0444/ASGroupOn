<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    protected ICategory icategory = null;
    protected int strPid = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (Request["addPid"] != null && Request["addPid"].ToString() != "")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Api_AddChild))
            {
                SetError("你不具有新建子分类的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
            else
            {
                strPid = Helper.GetInt(Request["addPid"], 0);
            }
        }
        else
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Api_Add))
            {
                SetError("你不具有新建API分类的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
        }
        if (Request["updateId"] != null && Request["updateId"].ToString() != "")
        {
            Update();
        }
    }

    /// <summary>
    /// 修改
    /// </summary>
    protected void Update()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Api_Edit))
        {
            SetError("你不具有编辑API分类的权限！");
            Response.Redirect("Type_XiangmuFenlei.aspx");
            Response.End();
            return;
        }
        else
        {
            int strid = Helper.GetInt(Request["updateId"], 0);
            if (strid > 0)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    icategory = session.Category.GetByID(strid);
                }
            }
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
                                <div class="head">
                                    <%if (icategory != null)
                                      {
                                    %>
                                        <h2>编辑API分类</h2>
                                    <%}
                                      else
                                      {
                                    %>
                                        <h2>新建API分类</h2>
                                    <%}%>
                                    
                                </div><ul class="filter">
                                        <li></li>
                                    </ul>
                                <div class="sect">
                                    <%if (icategory != null)
                                      {
                                    %>
                                    <input type='hidden' name='action' value='updateapiclass' />
                                    <input type="hidden" name="sid" id="sid" value="<%=icategory.Id %>" />
                                    <input type='hidden' name='city_pid' id="Hidden1" value="<%=icategory.City_pid %>" />
                                    <div class="field">
                                        <label>中文名称</label>
                                        <input group="city" type="text" name="name" id="Text1" value="<%=icategory.Name %>"  require="true" datatype="require" class="f-input" style="width:200px"/>
                                    </div>
                                    <div class="field">
                                        <label>英文名称</label>
                                        <input type="text" group="city" name="ename" id="Text2" value="<%=icategory.Ename %>"  require="true" datatype="english" class="f-input" style="text-transform:lowercase; width:200px"/>
                                    </div>
                                    <div class="field">
                                        <label>首字母</label>
                                        <input type="text" group="city" name="letter" id="Text3" value="<%=icategory.Letter %>"  maxLength="1" require="true" datatype="english" class="f-input" style="text-transform:uppercase; width:200px" />
                                    </div>
                                    <div class="field">
                                        <label>自定义分组</label>
                                        <input type="text" group="city" name="czone" id="Text4" value="<%=icategory.Czone %>"  class="f-input"   style="width:200px" />
                                    </div>
                                    <div class="field">
                                        <label>导航显示(Y/N)</label>
                                        <input type="text" group="city" name="display" id="Text5" datatype="english" maxlength="1" value="<%=icategory.Display %>"  class="f-input" style="text-transform:uppercase; width:200px"  />
                                    </div>
                                    <div class="field">
                                        <label>排序(降序)</label>
                                        <input type="text" group="city" name="sort_order" id="Text6" value="<%=icategory.Sort_order %>" require="true" datatype="number"  class="f-input"  style="width:200px" />
                                    </div>
                                    <%
                                        }
                                      else
                                      {
                                    %>
                                    <input type='hidden' name='action' value='addapiclass' />
                                    <input type='hidden' name='city_pid' id="city_pid" value="<%=strPid %>" />
                                    <div class="field">
                                        <label>中文名称</label>
                                        <input type="text" group="city" name="name" id="name"  require="true" datatype="require" class="f-input" style="width:200px" />
                                    </div>
                                    <div class="field">
                                        <label>英文名称</label>
                                        <input type="text" group="city" name="ename" id="ename"  require="true" datatype="english" class="f-input" style="text-transform:lowercase; width:200px;"/>
                                    </div>
                                    <div class="field">
                                        <label>首字母</label>
                                        <input type="text" group="city" name="letter" id="letter"  maxLength="1" require="true" datatype="english" class="f-input" style="text-transform:uppercase; width:200px" />
                                    </div>
                                    <div class="field">
                                        <label>自定义分组</label>
                                        <input type="text" group="city" name="czone" id="czone"  class="f-input"  style="width:200px"  />
                                    </div>
                                    <div class="field">
                                        <label>导航显示(Y/N)</label>
                                        <input type="text" group="city" name="display" id="display"  class="f-input" datatype="english" maxlength="1" style="text-transform:uppercase; width:200px" value="N"   />
                                    </div>
                                    <div class="field">
                                        <label>排序(降序)</label>
                                        <input type="text" group="city" name="sort_order" id="sort_order" require="true" datatype="number" value="0"  class="f-input"  style="width:200px"  />
                                    </div>
                                    <%  } %>
                                    <div class="act">
                                        <input type="submit" value="确定" name="commit" id="submit" class="formbutton validator" group="city" />
                                    </div>
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