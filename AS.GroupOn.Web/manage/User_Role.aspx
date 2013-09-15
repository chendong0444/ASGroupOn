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
    
    protected IList<IAuthority> iListAuthority = null;
    protected IRole role = null;
    protected IList<IRoleAuthority> iListRoleAuthority = null;
    protected IList<Hashtable> table = null;
    protected int id = 0;
    AuthorityFilter authorityfilter = new AuthorityFilter();
    RoleAuthorityFilter roleauthorityfilter = new RoleAuthorityFilter();
    IList<IRole> ilistrole = null;
    RoleFilter filter = new RoleFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Role_Author))
        {
            SetError("你不具有查看分配权限的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        id = Helper.GetInt(Request["id"], 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            role = session.Role.GetByID(id);
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            string a = role.code;
            table = session.Role.SelectByCode(role.code);
            iListRoleAuthority = session.RoleAuthority.GetList(roleauthorityfilter);
            iListAuthority = session.Authority.GetList(authorityfilter);
        }

    }
    /// <summary>
    /// 确认授权权限
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TrueBtn_Click(object sender, EventArgs e)
    {
        if (role.code != "")
        {
            Session["role"] = role.code;  //授权成功后，下拉列表框依旧显示此角色
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int i = session.Role.DelByCode(role.code);//授权前删除此角色所有权限
            }
        }
        
        if (Request.Form["page_id"] != null && Request.Form["page_id"].ToString() != "")
        {
            string pagesid = Request.Form["page_id"].ToString();
            string[] pageid = pagesid.Split(',');
            for (int i = 0; i < pageid.Length; i++)
            {
                if (pageid[i].ToString() != "")
                {
                    int roleid = 0;
                   
                    IRole ro = Store.CreateRole();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        ro = session.Role.SelectId(role.code);
                    }
                    roleid = ro.Id;
                    IRoleAuthority roleauthority = Store.CreateRoleAuthority() ;
                     roleauthority.RoleID=roleid;
                     roleauthority.AuthorityID = Convert.ToInt32( pageid[i]);
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int j = session.RoleAuthority.Insert(roleauthority);
                    }
                }
            }

            SetSuccess("授权成功！");
          
            //Response.Redirect("User_Role.aspx?&id=" + id+"");
        }
        else if (string.IsNullOrEmpty(Request.Form["page_id"]))
        {
            SetError("没有选择任何页面进行授权");
        }
        Response.Redirect("User_Roles.aspx");
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
                                        <%=role.rolename %>&nbsp;&nbsp;角色权限授权页</h2>
                                        <input type="hidden" name="id" value="<%=id %>" />
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>
                                            角色：
                                        </label>
                                        <div>
                                            <%=role.rolename %>
                                            <script type="text/javascript">

                                                function checkallpage() {
                                                    var str = $("#allselect").attr('checked');

                                                    if (str) {

                                                        $('[name=page_id]').attr('checked', true);
                                                    }
                                                    else {

                                                        $('[name=page_id]').attr('checked', false);
                                                    }

                                                }

                                            </script>
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="checkbox" value="" onClick="checkallpage()" id="allselect" />&nbsp;选择全部
                                        </div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            页面：
                                        </label>
                                        <div class="city-box">
                                            <% foreach (IAuthority authority in iListAuthority)
                                               {%>
                                            <li style="width: 160px; float: left">
                                                <input type="checkbox" id="<%=authority.ID %>" name="page_id" value="<%=authority.ID %>" />&nbsp;<%=authority.AuthorityName%>&nbsp;&nbsp;</li>
                                            <%
                                               }%>
                                            <%foreach (Hashtable ht in table)
                                              {%>
                                            <li style="width: 160px; float: left; display: none">
                                                <input type="checkbox" id="<%=ht["ID"]%>" name="pageid1" checked="checked" />&nbsp;<%=ht["AuthorityName"]%>&nbsp;&nbsp;</li>
                                            <script type="text/javascript">
                                                $(document).ready(function () {
                                                    $('#<%=ht["ID"]%>').attr("checked", "true");
                                                })
                                            </script>
                                            <%} %>
                                        </div>
                                    </div>
                                    <div class="act">
                                      
                                        <input type="button" runat="server" class="formbutton" value="确认授权" onserverclick="TrueBtn_Click" />
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

