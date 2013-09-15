
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
    protected IGuid guid = null;
    public string guidstate = "";
    protected int id = 0;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (Request.QueryString["state"] == "addguid")
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_SetTg_Guid_Add))
            {
                SetError("你不具有添加团购导航的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;

            }
        }
        if (Request.QueryString["state"] == "updateguid")
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_SetTg_Guid_Edit))
            {
                SetError("你不具有编辑团购导航的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;

            }
        }
        
       
        if (!string.IsNullOrEmpty(Request.QueryString["id"]))
        {
            id = Helper.GetInt(Request.QueryString["id"],0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                guid = session.Guid.GetByID(id);
            }
        }

        if (!object.Equals(Request.QueryString["state"], null))
        {
            guidstate = Request.QueryString["state"].ToString();
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
                                <%if (id > 0)
                                  {%>
                                <h2>
                                        编辑导航栏目</h2>
                                        <%}
                                  else
                                  {%>
                                  <h2>
                                        添加导航栏目</h2>
                                 <% } %>
                                    <table>
                                        <tbody>
                                            <tr>
                                                <td height="40px" width="">
                                                    <ul class="filter" style="width: 150px;">
                                                        <li class="label">分类: </li>
                                                        <li><a href="Shezhi_GuidList.aspx">导航栏目显示</a></li>
                                                    </ul>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                                <div class="sect">
                                    <%if (id > 0)
                                      {%>
                                      <input type="hidden" name="action" value="updatetgguid" />
                                      <input type="hidden" name="id" value="<%=guid.id %>" />
                                    <div class="wholetip clear">
                                       
                                    </div>

                                    <div class="field">
                                        <label>
                                            导航标题</label>
                                        <input type="text" size="30" name="title" id="Text4" class="f-input" size="15" value="<%=guid.guidtitle %>"
                                            group="g" require="true" datatype="require"><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            导航url</label>
                                        <input type="text" size="30" name="url" id="Text6" class="f-input" size="15" value="<%=guid.guidlink %>"
                                            group="g" require="true" datatype="require">
                                        <span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            排序：</label>
                                        <input type="text" class="number" size="30" group="g" datatype="number" name="guidsort" id="Text8" value="<%=guid.guidsort %>" />
                                        <span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否显示：</label>
                                        <select id="Select1" name="openguid">
                                            <%if (guid.guidopen == 0)
                                              {%>
                                            <option value="0" selected="selected">是</option>
                                            <option value="1">否</option>
                                            <%}
                                              else
                                              {%>
                                            <option value="0">是</option>
                                            <option value="1" selected="selected">否</option>
                                            <%} %>
                                        </select>
                                        <span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否打开新窗口：</label>
                                        <select id="Select2" name="openparent">
                                            <%if (guid.guidparent == 0)
                                              {%>
                                            <option value="0" selected="selected">否</option>
                                            <option value="1">是</option>
                                            <%}
                                              else
                                              {%>
                                            <option value="0">否</option>
                                            <option value="1" selected="selected">是</option>
                                            <%} %>
                                        </select>
                                        <span class="inputtip"></span>
                                    </div>
                                    <%}
                                      else
                                      {%>
                                      <input type="hidden" name="action" value="addtgguid" />
                                    <div class="wholetip clear">
                                        
                                    </div>
                                    <div class="field">
                                        <label>
                                            导航标题</label>
                                        <input type="text" size="30" name="title" id="Text1" class="f-input" size="15" group="g"
                                            require="true" datatype="require"><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            导航url</label>
                                        <input type="text" size="30" name="url" id="Text2" class="f-input" size="15" group="g"
                                            require="true" datatype="require">
                                        <span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            排序：</label>
                                        <input type="text" class="number" value="0"  size="30" group="g" datatype="number" name="guidsort" id="Text3" />
                                        <span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否显示：</label>
                                        <select id="openguid" name="openguid">
                                            <option value="0" selected="selected">是</option>
                                            <option value="1">否</option>
                                        </select>
                                        <span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否打开新窗口：</label>
                                        <select id="openparent" name="openparent">
                                            <option value="0" selected="selected">否</option>
                                            <option value="1" >是</option>
                                        </select>
                                        <span class="inputtip"></span>
                                        <input type="hidden" name="teamormall" value="0" />
                                    </div>
                                    <% }%>
                                    <div class="act">
                                        <input id="Submit1" type="submit" value="保存" name="commit" class="validator formbutton"
                                            group="g" />
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