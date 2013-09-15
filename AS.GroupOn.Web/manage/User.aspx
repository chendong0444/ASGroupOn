<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage"%>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    protected IPagers<IUser> pager = null;
    protected IList<IUser> iListUsers = null;
    protected string pagerHtml = String.Empty;
    protected IList<ICategory> Icategorylist = null;
    protected string pagePar = "";
    protected string orders = "";
    protected List<Hashtable> categoryModel = null;
    protected int countpage = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "商户列表";
   
        //判断管理员是否有此操作
        if (!IsPostBack)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_User_ListView))
            {
                SetError("你不具有查看会员列表的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
        }
        //用户等级
        string sql1 = "select u.*,c.Name,c.Display,c.Zone from userlevelrules u left join Category c on u.levelid =c.Id  ";

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            categoryModel = session.GetData.GetDataList(sql1.ToString());
        }
        CategoryFilter filt = new CategoryFilter();
        filt.Zone = "city";
        //所有城市
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
        {
            Icategorylist = session.Category.GetList(filt);
        }
        UserFilter filter = new UserFilter();
        if (!string.IsNullOrEmpty(Request["txtuser"]))
        { //用户ID
            if(Request["suser"]=="1")
            {
                filter.ID=AS.Common.Utils.Helper.GetInt(Request["txtuser"],0);
                pagePar = pagePar + "&txtuser=" + Request["txtuser"];
            }else if(Request["suser"]=="2")
            {
                filter.Username=Request["txtuser"];
                pagePar = pagePar + "&txtuser=" + Request["txtuser"];
            }
        }
        if (!string.IsNullOrEmpty(Request["sleve"]))
        {
            //按用户等级排序
            IUserlevelrules userulemodel = null;
            int leveid = AS.Common.Utils.Helper.GetInt(Request["sleve"], 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                userulemodel = session.Userlevelrelus.GetByID(leveid);
            }
            if (userulemodel != null)
            {
                filter.tototalamount = userulemodel.maxmoney;
                filter.fromtotalamount = userulemodel.minmoney;
                pagePar = pagePar + "&sleve=" + userulemodel.id;
            }
        }
        if (!string.IsNullOrEmpty(Request["Enable"]))
        {
            //用户状态
            filter.Enable = AS.Common.Utils.Helper.GetString(Request["Enable"],String.Empty);
            pagePar = pagePar + "&Enable="+AS.Common.Utils.Helper.GetString(Request["Enable"],String.Empty);
        }
        if (!string.IsNullOrEmpty(Request["txtemail"])) 
        {
            filter.Email =AS.Common.Utils.Helper.GetString(Request["txtemail"],String.Empty);
            pagePar = pagePar + "&txtemail =" + Request["txtemail"];
        }
        if (!string.IsNullOrEmpty(Request["scity"]) && AS.Common.Utils.Helper.GetInt(Request["scity"],0)!=0)
        {
            filter.City_id =AS.Common.Utils.Helper.GetString(Request["scity"],String.Empty);
            pagePar = pagePar + "&scity=" + AS.Common.Utils.Helper.GetString(Request["scity"], String.Empty);
        }
        if (Request["sSort"] == "1")
        {
            orders = " Money desc ";
            pagePar = pagePar + "&sSort=1";
        }
        else if (Request["sSort"] == "2")
        {
            orders = "( select COUNT(*) from [Order] as roders where State='pay' and User_id = [User] .Id ) desc";
            pagePar = pagePar + "&sSort=2";
        }
        else if (Request["sSort"] == "3")
        {
            orders = " userscore desc ";
            pagePar = pagePar + "&sSort=3";
        }
        else 
        {
            orders = " Id desc ";
        }
        IList<IUserlevelrules> usersleve = null;
        UserlevelrulesFilters filters = new UserlevelrulesFilters();
        filters.AddSortOrder(UserlevelrulesFilters.ID_ASC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            usersleve = session.Userlevelrelus.GetList(filters);
        }
        pagePar = pagePar + "&page={0}";
        pagePar = "User.aspx?" + pagePar.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(orders);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Users.GetPager(filter);
        }
        countpage = pager.TotalPage;
        iListUsers = pager.Objects;
        pagerHtml =  AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, pagePar);
 
        if (AS.Common.Utils.Helper.GetInt(Request["del"], 0) > 0)
        {
            int delid = 0;
            IUser user = Store.CreateUser();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                user = session.Users.GetByID(AS.Common.Utils.Helper.GetInt(Request["del"],0));
                delid = session.Users.Delete(AS.Common.Utils.Helper.GetInt(Request["del"], 0));
            }
            if (delid > 0)
            {
                SetSuccess("删除成功！");
                string key = AS.Common.Utils.FileUtils.GetKey();
                AS.AdminEvent.ConfigEvent.AddOprationLog(AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin",key),0),"删除用户","删除会员 ID:"+user.Id,DateTime.Now);
                Response.Redirect(PageValue.WebRoot+"manage/User.aspx");
                Response.End();
                return;
            }
            else
            {
                SetError("删除失败！");
                Response.End();
                return;
            }
        }
    }
    private static bool GetUsrOrder(int id)
    {
        bool isok = false;
        IList<IOrder> list = null;
        OrderFilter filter = new OrderFilter();
        filter.User_id = id;
        using (IDataSession session = Store.OpenSession(false))
        {
            list = session.Orders.GetList(filter);
        }
        if (list == null || list.Count == 0)
        {
            isok = true;
        }
        return isok; 
    }
</script>
<%LoadUserControl("_header.ascx", null); %> 
<body class="newbie">
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
                                <div class="head">
                                    <h2>
                                        用户列表</h2>
                                        <div class="search">
                                        <select id="suser" name="suser" class="h-input">
                                            <option value="1"
                                            <%if(Request["suser"]=="1"){ %>
                                            selected="selected"<%} %>>用户名ID</option>
                                          
                                            <option value="2"
                                               <%if(Request["suser"]=="2"){ %>
                                            selected="selected"<%} %>>用户名</option>
                                        </select>
                                        :<input type="text" class="h-input" id="txtuser" name="txtuser" value="<%=Request["txtuser"] %>"/>
                                        <input type="hidden" value="<%=countpage %>" id="countpage" name="countpage" />
                                            &nbsp;用户等级: 
                                            <select id="sleve" name="sleve" class="h-input">
                                                <option value="">选择等级</option>
                                                <%if (categoryModel != null)
                                                  { %>
                                                  <% foreach (Hashtable items in categoryModel)
                                                     {%>
                                                     <option value="<%=items["id"] %>" 
                                                     <%if(AS.Common.Utils.Helper.GetInt(Request["sleve"],0)==AS.Common.Utils.Helper.GetInt(items["id"],0)){ %>
                                                     selected="selected" <%} %>><%=items["Name"] %></option>
                                                     <%}%>                                                     
                                                       <%} %>
                                            </select>
                                            &nbsp;用户状态: 
                                            <select id="Enable" name="Enable" class="h-input">
                                            <option value=""
                                             <%if(Request["Enable"] ==""){ %>
                                            selected="selected"<%} %> >选择状态</option>
                                             <option value="Y"
                                             <%if(Request["Enable"]=="Y"){ %>
                                             selected="selected"<%} %>>已激活</option>
                                              <option value="N"
                                              <%if(Request["Enable"]=="N"){ %>
                                             selected="selected"<%} %> >未激活</option>
                                            </select>
                                          
                                            &nbsp;邮件: <input type="text" class="h-input" name="txtemail" value="<%=Request["txtemail"] %>" id="txtemail"/>
                                            &nbsp;城市: <select name="scity" id="scity" class="h-input">
                                                <option value="0"
                                                    <%if(Convert.ToInt32(Request["scity"])==0) {%>
                                                selected="selected"<%} %> >全部城市</option>
                                                 <% foreach (ICategory item in Icategorylist)
                                                    {%>
                                                       <option value="<%=item.Id %>"
                                                        <%
                                                         if(Convert.ToInt32(Request["scity"])==item.Id)
                                                         {
                                                         %>
                                                         selected="selected"<%} %>><%=item.Name %></option> 
                                                    <%} %>
                                            </select>
                                            &nbsp;排序: <select id="sSort" name="sSort" class="h-input">
                                                <option value="0"
                                                <%if(Request["sSort"]=="0"){ %>
                                                
                                                selected="selected"<%} %>>默认排序</option>
                                                <option value="1"
                                                  <%if(Request["sSort"]=="1"){ %>
                                                selected="selected"<%} %>>余额排序</option>
                                                <option value="2"
                                                  <%if(Request["sSort"]=="2"){ %>
                                                selected="selected"<%} %>>购买次数排序</option>
                                                <option value="3"
                                                  <%if(Request["sSort"]=="3"){ %>
                                                selected="selected"<%} %>>积分排序</option>
                                            </select>
                                           
                                            <input id="saixuan" type="submit" value="筛选" class="formbutton" name="btnselect" style="padding: 1px 5px;"  />
                                       
                                    <ul class="filter">
                                        <li>
                                        
                                            </li>
                                    </ul></div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                    <tr style="text-align:center">
                                        <th width="10%">ID</th>
                                        <th width='10%'>Email/用户名</th>
                                        <th width='10%'>姓名/城市</th>
                                        <th width='7%'>余额</th>
                                        <th width='10%'>等级</th>
                                        <th width='8%'>积分</th>
                                        <th width='13%'>注册时间</th>
                                        <th width='7%'>购买次数</th>
                                        <th width='10%'>联系电话</th>
                                        <th width='15%'>操作</th>
                                    </tr>
                                    <% int i = 2; %>
                                    <% foreach (IUser user in iListUsers)
                                       {
                                               if (i % 2 == 0)
                                               {
                                      %>
                                       <tr class="alt">     
                                       <%}
                                               else
                                               {%>
                                       <tr>
                                       <%} i++; %>
                                            <td><%=user.Id%></td>
                                            <td><%=user.Email%><br />
                                                <%=user.Username%>
                                            </td>
                                            <td><%=user.Realname%><br />
                                             <%
                                            if (user.Category != null)
                                            {%>
                                               <%=user.Category.Name%>
                                               <%}
                                                else
                                                {%>
                                                  全部城市
                                               <%}%>
                                            </td>
                                            <td><%=user.Money%></td>
                                            <td>
                                               <!--获取用户等级-->
                                                <%
                                                if (user.LeveName != null)
                                                { %>
                                                <%=user.LeveName.Name%>
                                                <%}%>
                                            </td>
                                            <td><%=user.userscore%></td>

                                            <td><%=user.Create_time%></td>
                                            <%
                                            if (user.BuyNum != null)
                                            { %>
                                            <td><%=user.BuyNum%></td>
                                            <%} %>
                                            <td><%=user.Mobile%></td>
                                            <td class='op'>
                                                <a class='ajaxlink' href='ajax_manage.aspx?action=userview&Id=<%=user.Id %>'>详情</a>｜ 
                                                <a href='Update_User.aspx?update=<%=user.Id %>'>编辑</a><%if (GetUsrOrder(user.Id)) {%>
                                               ｜<a href="User.aspx?del=<%=user.Id %>" ask="确定删除吗？">删除</a> <%}%>
                                            </td>
                                         </tr>
                                        
                                       <%} %>
                                        <tr>
                                            <td colspan="11" >
                                                 <%=pagerHtml%>
                                            </td>
                                        </tr>
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