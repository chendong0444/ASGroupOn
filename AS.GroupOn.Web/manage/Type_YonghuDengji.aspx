<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat ="server">
    protected List<Hashtable> categoryModel = null;
    protected override void  OnLoad(EventArgs e)
    {
 	     base.OnLoad(e);
         //判断管理员是否有此操作权限
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_UserLeve_List)) 
        {
             SetError("你没有查看会员等级的权限");
             Response.Redirect("index_index.aspx");
             Response.End();
             return;
        }
        int id = AS.Common.Utils.Helper.GetInt(Request["remove"], 0);
        if (id > 0) 
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_UserLeve_Delete))
            {
                SetError("没有删除用户等级的权限");
                Response.Redirect("Type_YonghuDengji.aspx");
                Response.End();
                return;
            }
            else 
            {
                int count = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                {
                    count = session.Userlevelrelus.Delete(id);
                }
                if (count > 0)
                {
                    //删除分类表的一条记录
                    int leveid = AS.Common.Utils.Helper.GetInt(Request["levelid"],0);
                    if(leveid>0){
                        int counta=0;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                        {
                            counta = session.Category.Delete(leveid);
                        }
                        if (counta > 0) 
                        {
                            SetSuccess("删除成功");
                        }
                    }
                }
                else 
                {
                    SetError("删除失败");
                }
                Response.Redirect("Type_YonghuDengji.aspx");
                Response.End();
                return;
            }
        }
        string sql1 = " select u.*,c.Name,c.Display,c.Zone,c.Sort_order from userlevelrules u left join Category c on u.levelid =c.Id order by c.Sort_order desc ";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
         {
             categoryModel = session.GetData.GetDataList(sql1.ToString());
            
         }
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1">
     <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
       
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head" style="height:35px;">
                                    <h2>会员等级</h2>
                                    <ul class="filter">
						                <li>
                                            <a class="ajaxlink" href="ajax_manage.aspx?action=userlevelrule&zone=grade">新建用户等级</a></li>
					                    </ul>
                    	        </div>
                                <div class="sect">
                                      <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width="15%">编号</th>
                                            <th width="15%">用户等级</th>
                                            <th width="15%">消费上限</th>
                                            <th width="15%">消费下限</th>
                                            <th width="10%">折扣率</th>
                                            <th width="10%">排序</th>
                                            <th width="15%">操作</th>
                                        </tr>
                                        <% int a = 0; %>
                                        <%if (categoryModel!=null){ %>
                                         <%foreach (Hashtable item in categoryModel)
                                             {%>
                                             <% if (a % 2 == 0)
                                                { %>
                                             <tr class="alt">
                                             <%}
                                                else
                                                { %>
                                                <tr>
                                             <%} a++; %>
                                                <td><%=item["id"] %></td>
                                                <td><%=item["Name"] %></td>
                                                <td><%=item["maxmoney"] %></td>
                                                <td><%=item["minmoney"] %></td>
                                                <td><%=item["discount"] %></td>
                                                <td><%=item["Sort_order"]%></td>
                                                <td  class='op'><a href="Type_YonghuDengji.aspx?remove=<%=item["id"] %>&levelid=<%=item["levelid"] %>" ask="确定要删除吗?">删除</a>｜<a class="ajaxlink" href="ajax_manage.aspx?action=userlevelrule&userid=<%=item["id"] %>">编辑</a></td>
                                             </tr>
                                            <%}%>
                                            <%} %>
                                      </table>
                                    </div>
                            </div>
                        </div> 
                    </div>
                </div>
            </div>
        </div>
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
