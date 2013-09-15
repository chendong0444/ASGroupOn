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
    
    protected IFriendLink ifriendlink = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        
        if (Request["updateId"] != null && Request["updateId"].ToString() != "")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FriendLink_Edit))
            {
                SetError("你不具有编辑友情连接的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
            else
            {
                Update();
            }
        }
        else
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FriendLink_Add))
            {
                SetError("你不具有添加友情连接的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
        }
    }

    /// <summary>
    /// 修改
    /// </summary>
    protected void Update()
    {
        int strid = Helper.GetInt(Request["updateId"], 0);
        if (strid > 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ifriendlink = session.FriendLink.GetByID(strid);
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
                                    <%if (ifriendlink != null)
                                      {
                                    %>
                                        <h2>编辑友情链接</h2>
                                    <%}
                                      else
                                      {
                                    %>
                                        <h2>添加友情链接</h2>
                                    <%}%>
                                    <ul class="filter">
                                        <li></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <%if (ifriendlink != null)
                                      {
                                    %>
                                    <input type='hidden' name='action' value='updatefriendlink' />
                                    <input type="hidden" name="sid" id="sid" value="<%=ifriendlink.Id %>" />
                                    <div class="field">
                                        <label>网站名称</label>
                                        <input type="text" name="title" id="title" require="true" datatype="require" class="f-input" group="g"
                                            value="<%=ifriendlink.Title %>" style="width:400px"/>
                                    </div>
                                    <div class="field">
                                        <label>网站网址</label>
                                        <input type="text" name="url" id="url" maxlength="255" require="true" datatype="require" group="g"
                                            class="f-input" value="<%=ifriendlink.url %>" style="width:400px"/>
                                    </div>
                                    <div class="field">
                                        <label>LOGO地址</label>
                                        <input type="text" name="log" id="log" maxlength="255" require="true" datatype="require" 
                                            class="f-input" value="<%=ifriendlink.Logo %>" style="width:400px"/>
                                    </div>
                                    <div class="field">
                                        <label>排序(降序)</label>
                                        <input type="text" name="sort" id="sort" require="true" datatype="number" class="f-input" group="g"
                                            value="<%=ifriendlink.Sort_order %>" style="width:400px"/>
                                    </div>
                                    <%
                                        }
                                      else
                                      {
                                    %>
                                    <input type='hidden' name='action' value='addfriendlink' />
                                    <div class="field">
                                        <label>网站名称</label>
                                        <input type="text" name="title" id="Text1" require="true" datatype="require" class="f-input" group="g"
                                            value="" style="width:400px"/>
                                    </div>
                                    <div class="field">
                                        <label>网站网址</label>
                                        <input type="text" name="url" id="Text2" maxlength="255" require="true" datatype="require" group="g"
                                            class="f-input" style="width:400px"/>
                                    </div>
                                    <div class="field">
                                        <label>LOGO地址</label>
                                        <input type="text" name="log" id="Text3" maxlength="255" require="true" datatype="require"
                                            class="f-input" style="width:400px"/>
                                    </div>
                                    <div class="field">
                                        <label>排序(降序)</label>
                                        <input type="text" name="sort" id="Text4" require="true" datatype="number" class="f-input" group="g" style="width:400px"/>
                                    </div>
                                    <%  } %>
                                    <div class="act">
                                        <input type="submit" value="确定" name="commit" id="submit" class="formbutton validator" group="g" />
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