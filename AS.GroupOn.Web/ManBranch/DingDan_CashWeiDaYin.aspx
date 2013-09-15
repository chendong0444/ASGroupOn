<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> list_order = null;
    protected IList<ICategory> list_category = null;
    protected OrderFilter filter = new OrderFilter();
    protected UserFilter uf = new UserFilter();
    protected string pagerHtml = String.Empty;
    protected string where = String.Empty;
    protected string wherestring = "1=1";
    protected bool result = true;
    protected string url = "";
    protected string type = "";
    protected int id = 0;
    protected string type_name = "";
    protected int expressid = 0;



    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);



        type = Helper.GetString(Request["type"], String.Empty);
        expressid = Helper.GetInt(Request.QueryString["express"], 0);

        //根据快递筛选
        if (expressid > 0)
        {
            url = url + "&express=" + expressid;
            filter.Express_id = expressid;
            wherestring = wherestring + "and Express_id=" + expressid;
        }
        

        if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
        {
            url = url + "&begintime=" + Request.QueryString["begintime"];
            filter.FromCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
            wherestring = wherestring + "and [Order].Create_time>='" + Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now) + "'";
        }
        if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
        {
            url = url + "&endtime=" + Request["endtime"];
            filter.ToCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
            wherestring = wherestring + "and [Order].Create_time<='" + Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now) + "'";
        }
        if (!string.IsNullOrEmpty(Request.QueryString["fromfinishtime"]))
        {
            url = url + "&fromfinishtime=" + Request["fromfinishtime"];
            filter.FromPay_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["fromfinishtime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
            wherestring = wherestring + "and [Order].Pay_time>='" + Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["fromfinishtime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now) + "'";
        }
        if (!string.IsNullOrEmpty(Request.QueryString["endfinishtime"]))
        {
            url = url + "&endfinishtime=" + Request.QueryString["endfinishtime"];
            filter.ToPay_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endfinishtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
            wherestring = wherestring + "and [Order].Pay_time<='" + Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endfinishtime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now) + "'";
        }
        if (!string.IsNullOrEmpty(Request.QueryString["select_type"]))
        {

            IUser uses = null;
            UserFilter u_filter = new UserFilter();
            url = url + "&select_type=" + Request.QueryString["select_type"];
            type_name = Request.QueryString["type_name"];
            if (Request.QueryString["select_type"] == "1")
            {
                u_filter.Username = type_name;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    uses = session.Users.Get(u_filter);
                }
                if (uses != null)
                    filter.User_id = uses.Id;
                wherestring = wherestring + "and User_id=" + uses.Id;
            }
            else if (Request.QueryString["select_type"] == "2")
            {
                u_filter.Email = type_name;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    uses = session.Users.Get(u_filter);
                }
                if (uses != null)
                    filter.User_id = uses.Id;
                wherestring = wherestring + "and User_id=" + uses.Id;
            }
            else if (Request.QueryString["select_type"] == "4")
            {
                filter.Id = Helper.GetInt(type_name, 0);
                wherestring = wherestring + "and [Order].Id=" + Helper.GetInt(type_name, 0);
            } 
            else if (Request.QueryString["select_type"] == "8")
            {
                filter.Team_In = Helper.GetInt(type_name, 0);
                wherestring = wherestring + "Team_id=" + Helper.GetInt(type_name, 0) + "or id in(select order_id from orderdetail where teamid=" + Helper.GetInt(type_name, 0) + ")";
            }
            else if (Request.QueryString["select_type"] == "16")
            {
                filter.Pay_id = Helper.GetString(type_name, String.Empty);
                wherestring = wherestring + "Pay_id=" + Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "32")
            {
                filter.Express_no = Helper.GetString(type_name, String.Empty);
                wherestring += "Express_no=" + Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "64")
            {
                filter.Mobile = Helper.GetString(type_name, String.Empty);
                wherestring += "Mobile=" + Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "128")
            {
                filter.Realname = Helper.GetString(type_name, String.Empty);
                wherestring += "Realname=" + Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "256")
            {
                filter.Address = Helper.GetString(type_name, String.Empty);
                wherestring += "Address=" + Helper.GetString(type_name, String.Empty);   
            }
            
            url = url + "&type_name=" + Request.QueryString["type_name"];

        }

        wherestring = wherestring + " and service='cashondelivery' and (state='nocod' or state='pay') and Express='Y' and Express_id>0 and isnull(express_xx,'')<>'已打印' ";
        where = Convert.ToBase64String(HttpUtility.UrlEncodeToBytes(wherestring, Encoding.UTF8));

        //添加快递名称
        CategoryFilter CF = new CategoryFilter();
        CF.Zone = "express";
        CF.AddSortOrder(CategoryFilter.Sort_Order_DESC);

        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            list_category = seion.Category.GetByCashExpress(CF);
        }

        url = url + "&page={0}";
        url = "DingDan_CashWeiDaYin.aspx?" + url.Substring(1);

        //if (type != String.Empty)
        //    filter.State = type

        filter.StateIn = "'nocod','pay'";
        filter.PageSize = 30;
        filter.Express = "Y";
        filter.Service = "cashondelivery";
        filter.No_Express_id = 0;
        filter.No_Express_xx = "已打印";

        filter.AddSortOrder(OrderFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Orders.GetPager(filter);
        }

        list_order = pager.Objects;

        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);


    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
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
                                    <h2>
                                        未打印</h2><form id="Form1" runat="server" method="get">
                                <div class="search">
                                    <%if (type == "")
                                      {%>
                                  订单状态：<select name="state">
                                        <option value="">全部</option>
                                        <option value="1" <%
                                        if(Request.QueryString["state"] == "1")
                                        {
                                         %>selected="selected" <%} %>>下单</option>
                                        <option value="2" <%if(Request.QueryString["state"] == "2"){ %>selected="selected"
                                            <%} %>>付款</option>
                                    </select>
                                    <%} %>
                                    &nbsp;&nbsp; 生成订单时间：<input type="text" class="h-input" style=" margin-right:0px;" datatype="date" name="begintime"
                                        <%if(!string.IsNullOrEmpty(Request.QueryString["begintime"])){ %>value="<%=Request.QueryString["begintime"] %>"
                                        <%} %> />--<input type="text" class="h-input" datatype="date" name="endtime" <%if(!string.IsNullOrEmpty(Request.QueryString["endtime"])){ %>value="<%=Request.QueryString["endtime"] %>"
                                            <%} %> />&nbsp;&nbsp; 完成订单时间：<input type="text" style=" margin-right:0px;" class="h-input" datatype="date" name="fromfinishtime"
                                                <%if(!string.IsNullOrEmpty(Request.QueryString["fromfinishtime"])){ %>value="<%=Request.QueryString["fromfinishtime"] %>"
                                                <%} %> />--<input type="text" class="h-input" datatype="date" name="endfinishtime"
                                                    <%if(!string.IsNullOrEmpty(Request.QueryString["endfinishtime"])){ %>value="<%=Request.QueryString["endfinishtime"] %>"
                                                    <%} %> />&nbsp;&nbsp;
                                                     物流公司:
                                                        <select name="express" id="express">
                                                              <option value="0">请选择</option>
                                                              <%
                                                                  if (list_category != null && list_category.Count > 0)
                                                                  {
                                                                      foreach (ICategory Category in list_category)
                                                                      { 
                                                                       
                                                                        %>
                                                                        <option value='<%=Category.Id%>'<%if(expressid ==Category.Id){ %> selected="selected"<%} %>><%=Category.Name%>(<%=Category.Num%>)</option>
                                                                        <%
                                                                      }
                                                                  }
                                                                   %>
                                                        </select>

                                                     筛选条件：<select name="select_type">
                                                        <option value="">全部</option>
                                                        <option value="1" <%if(Request.QueryString["select_type"] == "1"){ %>selected="selected"
                                                            <%} %>>用户名</option>
                                                        <option value="2" <%if(Request.QueryString["select_type"] == "2"){ %>selected="selected"
                                                            <%} %>>Email</option>
                                                        <option value="4" <%if(Request.QueryString["select_type"] == "4"){ %>selected="selected"
                                                            <%} %>>订单编号</option>
                                                        <option value="8" <%if(Request.QueryString["select_type"] == "8"){ %>selected="selected"
                                                            <%} %>>项目ID</option>
                                                        <option value="16" <%if(Request.QueryString["select_type"] == "16"){ %>selected="selected"
                                                            <%} %>>交易单号</option>
                                                        <option value="32" <%if(Request.QueryString["select_type"] == "32"){ %>selected="selected"
                                                            <%} %>>快递单号</option>
                                                        <option value="64" <%if(Request.QueryString["select_type"] == "64"){ %>selected="selected"
                                                            <%} %>>手机号</option>
                                                        <option value="128" <%if(Request.QueryString["select_type"] == "128"){ %>selected="selected"
                                                            <%} %>>收货人</option>
                                                        <option value="256" <%if(Request.QueryString["select_type"] == "256"){ %>selected="selected"
                                                            <%} %>>派送地址</option>
                                                    </select>&nbsp;&nbsp; 内容：<input type="text" style="width: 120px;" name="type_name"
                                                        <%if(!string.IsNullOrEmpty(Request.QueryString["type_name"])){ %>value="<%=Request.QueryString["type_name"] %>"
                                                        <%} %> />&nbsp;&nbsp;
                                    <input type="submit" value="查询" class="formbutton" />
                                                                        
                                      <%if (expressid > 0)
                                         { %>
                          <input type="button" class="formbutton" value="批量打印" style="padding: 1px 6px; width: 60px;"
                                onclick="javascript:print()" id="printall" name="printall">
                                            <%} %>
                                   
                                    </div>
                                </form>
                                </div>
                                
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width="10%">
                                                ID
                                            </th>
                                            <th class="xiangmu" width="20%">
                                                项目
                                            </th>
                                            <th width="20%">
                                                用户
                                            </th>
                                            <th width="20%">
                                                派送地址
                                            </th>
                                            <th width="10%">
                                                快递公司
                                            </th>
                                            <th width="20%">
                                                操作
                                            </th>
                                        </tr>
                                        <% 
                                            
                                            int i = 0;
                                            foreach (IOrder order in list_order)
                                            { %>
                                        <% 
             
                                            IList<ITeam> teamlist = null;
                                            IList<IOrderDetail> orderlist = null;
                                            IUser user = Store.CreateUser();
                                            ITeam team = Store.CreateTeam();
                                            ICategory category = Store.CreateCategory();
                                            user = order.User;
                                            team = order.Team;
                                            category = order.Category;
                                        %>
                                        <% 

    if (i % 2 != 0)
    {
                                        %>
                                        <tr>
                                            <% 
}
                                            %>
                                            <% 
else
{ %>
                                        <tr class='alt'>
                                            <%
}
                                            %>
                                            <% 
i++;
                                            %>
                                            <td width='40'>
                                                <%=order.Id%>
                                            </td>
                                            <td class='xiangmu'>
                                                <% 
if (order.Team_id == 0)
{
    teamlist = order.Teams;
    orderlist = order.OrderDetail;
                                                %>
                                                <% 
foreach (ITeam teams in teamlist)
{%>
                                                项目ID:<% =teams.Id%>
                                                (<a class="deal-title" href="<%=getTeamPageUrl( teams.Id) %>" target="_blank">
                                                    <% =StringUtils.SubString(teams.Title, 70) + "..."%>
                                                </a>)
                                                <%  }%>
                                                <%  }%>
                                                <%  
else
{%>
                                                项目ID:<% =order.Team_id%>
                                                (<a class="deal-title" href="<%=getTeamPageUrl( team.Id) %>" target="_blank"><% =StringUtils.SubString(team.Title, 70) + "..."%>
                                                </a>)
                                                <%   }%>
                                                <%  if (order.result != null) %>
                                                <% = StringUtils.SubString(AS.Common.Utils.WebUtils.Getbulletin(order.result), 0, "<br>")%>
                                            </td>
                                            <td width='140'>

                                            <% if (user != null)
                                               { %>
                                                <a class="ajaxlink" href="ajax_manage.aspx?action=userview&Id=<% =order.User_id %>">
                                                    <% =user.Email%><br>
                                                    <%=user.Username%></a>&nbsp;»&nbsp;<a class="ajaxlink" href="ajax_manage.aspx?action=sms&v=<%=user.Mobile %> ">短信</a>

                                              <%} %>
                                            </td>
                                            <td width='250'>
                                                <%=order.Address%>
                                            </td>

                                            <%if (category != null)
                                              {%>
                                            <td width='60'>
                                              快递公司: <%=category.Name%>
                                            </td>
                                            <%}
                                              else
                                              { %>
                                             <td width='60'>
                                            
                                            </td>
                                            <%} %>

                                            <td width='100'>
                                                 <a class="ajaxlink" href='ajax_print.aspx?action=print&amp;id=<%=order.Id %>'>
                                                        打印快递</a>｜ <a href='ajax_manage.aspx?action=orderview&amp;orderview=<%=order.Id%>' class="ajaxlink">详情</a>
                                            </td>
                                        </tr>
                                        <% 
}
                                           %>
                                        <tr>
                                            <td colspan="10">
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
</body>
<%LoadUserControl("_footer.ascx", null); %>

<script>
    function print() {

        X.get(webroot + "ajax_print.aspx?action=print&where=<%=where %>");

    }
    
</script>
