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
<script runat="server">
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> list_order = null;
    protected OrderFilter filter = new OrderFilter();
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected string type = "";
    protected string strkey = "";
    protected int key;
    protected int id = 0;
    protected string type_name = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        key = Helper.GetInt(Request["key"], 3);
        //1.已发货 2.未发货
        if (key == 1)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_Express_DeliveryYes_Detail))
            {
                SetError("你不具有查看已发货记录的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
        }
        else if (key == 2)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_Express_DeliveryNo_ListView))
            {
                SetError("你不具有查看未发货记录的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
        }
        else
        {
            SetError("参数不对！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        id = Helper.GetInt(Request["delete"], 0);
        if (id > 0)
        {
            int del_id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                del_id = session.Orders.Delete(id);
            }
            if (del_id > 0)
            {
                WebUtils.LogWrite("管理员删除订单", "订单ID:" + id);
                SetSuccess("订单ID" + id + "删除成功");
            }
            Response.Redirect("Dingdan_YiFaHuo.aspx&key=" + Session["Key"]);
            Response.End();
            return;
        }

      

        strkey = key.ToString();

        type = Helper.GetString(Request["type"], String.Empty);
        if (!string.IsNullOrEmpty(Request.QueryString["state"]))
        {
            url = url + "&state=" + Request.QueryString["state"];
            if (Request["state"] == "1")
            {
                filter.State = "unpay";
            }
            else if (Request["state"] == "2")
            {
                filter.State = "pay";
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
        {
            url = url + "&begintime=" + Request.QueryString["begintime"];
            filter.FromCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
        {
            url = url + "&endtime=" + Request["endtime"];
            filter.ToCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["fromfinishtime"]))
        {
            url = url + "&fromfinishtime=" + Request["fromfinishtime"];
            filter.FromPay_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["fromfinishtime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["endfinishtime"]))
        {
            url = url + "&endfinishtime=" + Request.QueryString["endfinishtime"];
            filter.ToPay_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endfinishtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["select_type"]))
        {
            IUser uses = null;
            UserFilter u_filter = new UserFilter();
            url = url + "&select_type=" + Request.QueryString["select_type"];
            type_name = Request.QueryString["type_name"];
            if (Request.QueryString["select_type"] == "1" || Request.QueryString["select_type"] == "2")
            {
                if (Request.QueryString["select_type"] == "1")
                {
                    u_filter.Username = type_name;
                }
                else
                {
                    u_filter.Email = type_name;
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    uses = session.Users.Get(u_filter);
                }
                if (uses != null)
                    filter.User_id = uses.Id;
            }
            else if (Request.QueryString["select_type"] == "4")
            {
                filter.Id = Helper.GetInt(type_name, 0);
            }
            else if (Request.QueryString["select_type"] == "8")
            {
                filter.Pay_id = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "16")
            {
                filter.Pay_id = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "32")
            {
                filter.Express_no = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "64")
            {
                filter.Mobile = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "128")
            {
                filter.Realname = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "256")
            {
                filter.Address = Helper.GetString(type_name, String.Empty);
            }

            url = url + "&type_name=" + Request.QueryString["type_name"];
        }

        url = url + "&key=" + key;
        url = url + "&page={0}";
        url = "DingDan_YiFaHuo.aspx?" + url.Substring(1);


        //1.已发货 2.未发货  
        if (key == 1)
        {
            Session["Key"] = 1;
            filter.No_Service = "cashondelivery";
            filter.State = "pay";
            filter.Express = "Y";
            filter.No_Express_id = 0;
            filter.LenDa_Express_no = 0;
        }
        else if (key == 2)
        {
            Session["Key"] = 2;
            filter.No_Service = "cashondelivery";
            filter.StateOr = "pay";
            filter.Express = "Y";
        }

        filter.PageSize = 30;
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
                                    <%if (strkey == "1")
                                      {%>
                                    <h2>
                                        已发货</h2>
                                    <%}
                                      else if (strkey == "2")
                                      { %>
                                    <h2>
                                        未发货</h2>
                                    <%} 
                                    %><form id="Form1" runat="server" method="get">
                                <div class="search">
                                    生成订单时间：<input type="text" class="h-input" datatype="date" name="begintime"
                                        <%if(!string.IsNullOrEmpty(Request.QueryString["begintime"])){ %>value="<%=Request.QueryString["begintime"] %>"
                                        <%} %> />--<input type="text" class="h-input" datatype="date" name="endtime" <%if(!string.IsNullOrEmpty(Request.QueryString["endtime"])){ %>value="<%=Request.QueryString["endtime"] %>"
                                            <%} %> />&nbsp;&nbsp; 完成订单时间：<input type="text" class="h-input" datatype="date" name="fromfinishtime"
                                                style="margin-right: 0px;" <%if(!string.IsNullOrEmpty(Request.QueryString["fromfinishtime"])){ %>value="<%=Request.QueryString["fromfinishtime"] %>"
                                                <%} %> />--<input type="text" class="h-input" datatype="date" name="endfinishtime"
                                                    <%if(!string.IsNullOrEmpty(Request.QueryString["endfinishtime"])){ %>value="<%=Request.QueryString["endfinishtime"] %>"
                                                    <%} %> />&nbsp;&nbsp; 筛选条件：<select name="select_type">
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
                                                    </select>&nbsp;&nbsp; 内容：<input type="text" class="h-input" style="width: 120px;" name="type_name"
                                                        <%if(!string.IsNullOrEmpty(Request.QueryString["type_name"])){ %>value="<%=Request.QueryString["type_name"] %>"
                                                        <%} %> />&nbsp;&nbsp;
                                    <input type="submit" value="查询" class="formbutton" /></div>
                                </form>
                                </div>
                                
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='10%'>
                                                ID
                                            </th>
                                            <th width='17%'>
                                                项目
                                            </th>
                                            <th width='8%'>
                                                用户
                                            </th>
                                            <th width='10%'>
                                                数量
                                            </th>
                                            <th width='10%'>
                                                总款
                                            </th>
                                            <th width='10%'>
                                                余付
                                            </th>
                                            <th width='10%'>
                                                在线支付
                                            </th>
                                            <th width='10%'>
                                                支付方式
                                            </th>
                                            <th width='10%'>
                                                递送方式
                                            </th>
                                            <th width='5%'>
                                                操作
                                            </th>
                                        </tr>
                                        <% 
                                            IUser user = Store.CreateUser();
                                            ITeam team = Store.CreateTeam();
                                            IList<ITeam> teamlist = null;
                                            IList<IOrderDetail> orderlist = null;
                                            int i = 0;

                                            if (list_order != null && list_order.Count > 0)
                                            {
                                                foreach (IOrder order in list_order)
                                                {
                                                    user = order.User;
                                                    team = order.Team;
                                                    if (i % 2 != 0)
                                                    {%>
                                        <tr>
                                            <% }
                                                 else
                                                 { %>
                                            <tr class='alt'>
                                                <% 
}
                                                 i++;
                                                %>
                                                <td>
                                                    <%=order.Id%>
                                                </td>
                                                <td>
                                                    <% 
                                                        if (order.Team_id == 0)
                                                        {
                                                            teamlist = order.Teams;
                                                            orderlist = order.OrderDetail;
                                                            foreach (IOrderDetail teams in order.OrderDetail)
                                                            {%>
                                                    项目ID:<%=teams.Teamid%>
                                                    (<a class="deal-title" href='<%=getTeamPageUrl(teams.Teamid)%>' target="_blank"><%=StringUtils.SubString(teams.Team.Title, 70) + "..."%>
                                                    </a>) <%=StringUtils.SubString(AS.Common.Utils.WebUtils.Getbulletin(teams.result), 0, "<br>")%>
                                                    <%
                                                        }
}
else
{ %>
                                                    项目ID:<%=order.Team_id%>
                                                    <%if (team != null)
                                                      { %>
                                                    (<a class="deal-title" href='<%=getTeamPageUrl(order.Team_id)%>' target="_blank"><%=StringUtils.SubString(team.Title, 70) + "..."%>
                                                    </a>)
                                                    <% 
}
}

if (order.result != null)
    StringUtils.SubString(AS.Common.Utils.WebUtils.Getbulletin(order.result), 0, "<br>");
if (order.Parent_orderid != null && order.Parent_orderid != 0)
{%>
                                                    <br>
                                                    <font style="color: #0D6D00; font-weight: bold;">该订单父ID:<% =order.Parent_orderid%></font>
                                                    <%} %>
                                                </td>
                                                <%if (user != null)
                                                  { %>
                                                <td>
                                                    <a class="ajaxlink" href='ajax_manage.aspx?action=userview&Id=<%=order.User_id %>'>
                                                        <%=user.Email%>
                                                        <br>
                                                        <%=user.Username%></a>&nbsp;»&nbsp;<a class="ajaxlink" href='ajax_manage.aspx?action=sms&v=<%=user.Mobile %>'>短信</a>
                                                </td>
                                                <%}
                                                  else
                                                  {
                                                %>
                                                <td>
                                                </td>
                                                <%} %>
                                                <td>
                                                    <%=order.Quantity%>
                                                </td>
                                                <td>
                                                    <%=order.Origin%>
                                                </td>
                                                <td>
                                                    <%=order.Credit%>
                                                </td>
                                                <td>
                                                    <%=(order.Service == "cashondelivery" ? order.cashondelivery.ToString("0.00") : order.Money.ToString("0.00")) %>
                                                </td>
                                                <td>
                                                    <%=WebUtils.GetPayText(order.State, order.Service)%>
                                                </td>
                                                <td>
                                                    <%=GetOrderExpress(order) %>
                                                </td>
                                                <% 
                                                    if (order.State == "pay" || order.State == "scorepay")
                                                    {%>
                                                <td class="op">
                                                    <a class="ajaxlink" href='ajax_manage.aspx?action=orderview&orderview=<%=order.Id%>'>
                                                        详情</a>
                                                </td>
                                                <% 
                                                    }
else if (order.State == "cancel" || order.State == "nocod")
{%>
                                                <td class="op">
                                                    <a class="deal-title" href='DingDan_YiFaHuo.aspx?delete=<%=order.Id  %>' ask="确定删除本单吗？">
                                                        删除</a>｜<a class="ajaxlink" href='ajax_manage.aspx?action=orderview&orderview=<%= order.Id %>'>详情</a>
                                                </td>
                                                <%  }
else if (order.State == "unpay" || order.State == "scoreunpay")
{%>
                                                <td class="op">
                                                    <a class="deal-title" href='DingDan_YiFaHuo.aspx?id=<%=order.Id %>' ask="确定本单为现金付款?">
                                                        现金</a>｜<a class="deal-title" href='DingDan_YiFaHuo.aspx?delete=<%=order.Id %>' ask="确定删除本单吗？">删除</a>｜<a
                                                            class="ajaxlink" href='ajax_manage.aspx?action=orderview&orderview=<%=order.Id %>'>详情</a>
                                                </td>
                                                <%   }
else if (order.State == "refund" || order.State == "refunding")
{%>
                                                <td class="op">
                                                    <a class="ajaxlink" href='ajax_manage.aspx?action=orderview&type=refunding&orderview=<%= order.Id %>'>
                                                        详情</a>
                                                </td>
                                                <%  }%>
                                            </tr>
                                            <% }
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
