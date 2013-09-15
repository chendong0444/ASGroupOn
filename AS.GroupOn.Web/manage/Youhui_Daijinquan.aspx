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
    protected IPagers<ICard> pager = null;
    protected IList<ICard> iListCard = null;
    protected CardFilter filter = new CardFilter();
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Card_List))
        {
            SetError("你不具有查看已消费代金劵的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (!IsPostBack)
        {
            SelectWhere();
        }
        if (Request["delId"] != null && Request["delId"].ToString() != "")
        {
            Del(); //删除
        }
        if (Request.QueryString["item"] != null && Request.QueryString["item"] != "")
        {
            BulkDel();//批量删除
        }
        if (Request["saiXuan"] == "筛选")
        {
            SelectWhere();
        }
        if (Request["download"] == "下载")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Card_Down))
            {
                SetError("你不具有下载代金劵的权限！");
                Response.Redirect("Youhui_Daijinquan.aspx");
                Response.End();
                return;
            }
            else
            {
                downCard();
            }
        }
        if (Request["txtdown"] == "txt下载")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Card_DownToTxt))
            {
                SetError("你不具有txt下载代金劵的权限！");
                Response.Redirect("Youhui_Daijinquan.aspx");
                Response.End();
                return;
            }
            else
            {
                string strteamid = "";
                string strpartnerid = "";
                string strcode = "";
                if (!string.IsNullOrEmpty(Request.QueryString["ddlcard"]))
                {
                    string ddlcard = Request.QueryString["ddlcard"];
                    if (ddlcard == "1")//项目ID
                    {
                        strteamid = Helper.GetInt(Request.QueryString["txtcontent"], 0).ToString(); ;
                    }
                    if (ddlcard == "2")//商户ID
                    {
                        strpartnerid = Helper.GetInt(Request.QueryString["txtcontent"], 0).ToString();
                    }
                    if (ddlcard == "3")//代号
                    {
                        strcode = Request.QueryString["txtcontent"];
                    }
                }
                downCardtxt(strteamid, strpartnerid, strcode, "");
            }
        }
        InitData();
    }
    
    /// <summary>
    /// 绑定代金劵数据列表(已消费)
    /// </summary>
    protected void InitData()
    {
        url = url + "&page={0}";
        url = "Youhui_Daijinquan.aspx?" + url.Substring(1);
        filter.consume = "Y"; //已消费
        filter.PageSize = 10;
        filter.AddSortOrder(CardFilter.Id_Desc);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Card.GetPager(filter);
        }
        iListCard = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }

    /// <summary>
    /// 删除
    /// </summary>
    protected void Del()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Card_Delete))
        {
            SetError("你不具有删除代金劵的权限！");
            Response.Redirect("Youhui_Daijinquan.aspx");
            Response.End();
            return;
        }
        else
        {
            string strid = Helper.GetString(Request["delId"], String.Empty);
            if (strid != "" && strid != null)
            {
                int del_id = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    del_id = session.Card.Delete(strid.ToString());
                }
                if (del_id > 0)
                {
                    SetSuccess("删除成功");
                }
                string key = AS.Common.Utils.FileUtils.GetKey();
                AS.AdminEvent.ConfigEvent.AddOprationLog(AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0), "删除代金券", "删除代金券 ID:" + Request.QueryString["delId"].ToString(), DateTime.Now);
                Response.Redirect("Youhui_Daijinquan.aspx");
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
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Card_Delete))
        {
            SetError("你不具有删除代金劵的权限！");
            Response.Redirect("Youhui_Daijinquan.aspx");
            Response.End();
            return;
        }
        else
        {
            string items = Request.QueryString["item"];
            string[] item = items.Split(';');
            foreach (string ids in item)
            {
                string strid = Helper.GetString(ids, String.Empty);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int i = 0;
                    i = session.Card.Delete(strid);
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
            Response.Redirect("Youhui_Daijinquan.aspx?page=" + Helper.GetInt(Request.QueryString["url"], 1));
        }
    }


    /// <summary>
    /// 筛选条件
    /// </summary>
    public void SelectWhere()
    {
        filter.consume = "Y";
        if (!string.IsNullOrEmpty(Request.QueryString["ddlcard"]))
        {
            url = url + "&ddlcard=" + Request.QueryString["ddlcard"];
            string ddlcard = Request.QueryString["ddlcard"];

            if (ddlcard == "1")//项目ID
            {
                filter.Team_id = Helper.GetInt(Request.QueryString["txtcontent"], 0);
            }
            if (ddlcard == "2")//商户ID
            {
                filter.Partner_id = Helper.GetInt(Request.QueryString["txtcontent"], 0);
            }
            if (ddlcard == "3")//代号
            {
                filter.Code = Request.QueryString["txtcontent"];
            }
            if (ddlcard == "4")//派发的代号
            {
                filter.Code = Request.QueryString["txtcontent"];
                filter.WhereUser_id = 1;
            }
            url = url + "&txtcontent=" + Request.QueryString["txtcontent"];
        }
    }

    /// <summary>
    /// 下载
    /// </summary>
    protected void downCard()
    {
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<html>");
        sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
        sb1.Append("<body><table border=\'1\'>");
        sb1.Append("<tr>");
        sb1.Append("<td>ID</td>");
        sb1.Append("<td>编号</td>");
        sb1.Append("<td>代号</td>");
        sb1.Append("<td>面额</td>");
        sb1.Append("<td>实际抵用金额</td>");
        sb1.Append("</tr>");

        SelectWhere();
        IList<ICard> iListCardAll = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCardAll = session.Card.GetList(filter);
        }
        if (iListCardAll.Count > 0)
        {
            foreach (ICard cardInfo in iListCardAll)
            {
                int i = 0;
                sb1.Append("<tr>");
                sb1.Append("<td>" + (i + 1).ToString() + "</td>");
                sb1.Append("<td>'" + cardInfo.Id + "'</td>");
                sb1.Append("<td>" + cardInfo.Code + "</td>");
                sb1.Append("<td>" + cardInfo.Credit + "</td>");
                if (cardInfo.Order_id == null || cardInfo.Order_id.ToString() == "" || cardInfo.Order_id == 0)
                {
                    sb1.Append("<td>未使用</td>");
                }
                else
                {
                    float credit = float.Parse(cardInfo.Credit.ToString());
                    if (cardInfo.Order != null)
                    {
                        float price = float.Parse(cardInfo.Order.Price.ToString());
                        if (price >= credit)
                        {
                            sb1.Append("<td>" + credit + "</td>");
                        }
                        else
                        {
                            sb1.Append("<td>" + (credit - price).ToString() + "</td>");
                        }
                    }
                    else
                    {
                        sb1.Append("<td>未找到订单</td>");
                    }
                }
                sb1.Append("</tr>");
                i++;
            }
        }
        sb1.Append("</table></body></html>");
        Response.ClearHeaders();
        Response.Clear();
        Response.Expires = 0;
        Response.Buffer = true;
        Response.AddHeader("Accept-Language", "zh-tw");
        //文件名称
        Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("card_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
        Response.ContentType = "Application/octet-stream";
        //文件内容
        Response.Write(sb1.ToString());//-----------
        Response.End();
    }

    /// <summary>
    /// txt下载
    /// </summary>
    /// <param name="teamid"></param>
    /// <param name="partnerid"></param>
    /// <param name="code"></param>
    /// <param name="state"></param>
    private void downCardtxt(string teamid, string partnerid, string code, string state)
    {
        filter.consume = "Y";
        StringBuilder sb1 = new StringBuilder();
        
        if (teamid != "")
        {
            filter.Team_id = Convert.ToInt32(teamid);
        }
        if (partnerid != "")
        {
            filter.Partner_id = Convert.ToInt32(partnerid);
        }
        if (code != "")
        {
            filter.Code = code;
        }

        IList<ICard> iListCardInfo = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCardInfo = session.Card.GetList(filter);
        }
        if (iListCardInfo.Count > 0)
        {
            foreach (ICard cardInfo in iListCardInfo)
            {
                sb1.Append(PageValue.CurrentSystem.sitename + "|");
                sb1.Append(cardInfo.Id + "|");
                sb1.Append(cardInfo.Credit + "|");

                CardFilter filter2 = new CardFilter();
                if (partnerid != "" && code != "")
                {
                    filter2.Partner_id = Convert.ToInt32(partnerid);
                    filter2.Code = code;
                }
                else if (partnerid != "" && code == "")
                {
                    filter2.Partner_id = Convert.ToInt32(partnerid);
                }
                else if (partnerid == "" && code != "")
                {
                    filter2.Code = code;
                }
                if (teamid != "")
                {
                    sb1.Append(PageValue.WWWprefix.Substring(0, PageValue.WWWprefix.LastIndexOf("/")) + getTeamPageUrl(int.Parse(teamid)) + "" + "");
                }
                else
                {
                    Hashtable hashtable = null;
                    filter2.FromEnd_time = DateTime.Now;
                    filter2.ToBegin_time = DateTime.Now;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        hashtable = session.Card.CardDown(filter2);
                    }
                    if (hashtable != null)
                    {
                        if (hashtable["Team_id"] != null && hashtable["Team_id"] != "")
                        {
                            sb1.Append(PageValue.WWWprefix.Substring(0, PageValue.WWWprefix.LastIndexOf("/")) + getTeamPageUrl(int.Parse(hashtable["Team_id"].ToString())) + "");
                        }
                        else
                        {
                            sb1.Append(PageValue.WWWprefix.Substring(0, PageValue.WWWprefix.LastIndexOf("/")) + getTeamPageUrl(int.Parse(hashtable["Id"].ToString())) + "");
                        }
                    }
                }
                sb1.Append("\r\n");
            }

        }
        Response.ClearHeaders();
        Response.Clear();
        Response.Expires = 0;
        Response.Buffer = true;
        Response.ContentType = "text/plain";//文本类型的mime
        Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("card_" + DateTime.Now.ToString("yyyy-MM-dd") + ".txt", System.Text.Encoding.UTF8) + "");

        //文件内容
        Response.Write(sb1.ToString());//-----------
        Response.End();

    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server" method="get">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons" >
                    
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        已消费代金劵</h2> 
                                        <div class="search">
                                        <select name="ddlcard">
                                                <option value="0">请选择</option>
                                                <option value="1" <%if(Request.QueryString["ddlcard"] == "1"){ %>selected="selected" <%} %>>项目ID</option>
                                                <option value="2" <%if(Request.QueryString["ddlcard"] == "2"){ %>selected="selected" <%} %>>商户ID</option>
                                                <option value="3" <%if(Request.QueryString["ddlcard"] == "3"){ %>selected="selected" <%} %>>代号</option>
                                                <option value="4" <%if(Request.QueryString["ddlcard"] == "4"){ %>selected="selected" <%} %>>派发的代号</option>
                                            </select>
                                            <input type="text" name="txtcontent" id="txtcontent" class="f-input" style="width: 120px;"
                                            <%if(!string.IsNullOrEmpty(Request.QueryString["txtcontent"])){ %>value="<%=Request.QueryString["txtcontent"] %>" <%} %> 
                                             />
                                            &nbsp;
                                            <input type="submit" value="筛选" name="saiXuan" group="goto" class="formbutton validator"
                                                style="padding: 1px 6px;" />&nbsp;
                                            <input type="submit" name="download" value="下载" group="goto" class="formbutton validator"
                                                style="padding: 1px 6px;" />
                                            <input type="submit" name="txtdown" value="txt下载" group="goto" class="formbutton validator"
                                                style="padding: 1px 6px;" />
                                    <ul class="filter">
                                        <li>
                                           
                                        </li>
                                    </ul></div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='5%'>
                                                <input type='checkbox' id='checkall' name='checkall' /> 全选
                                            </th>
                                            <th width='12%'>
                                                ID
                                            </th>
                                            <th width='5%'>
                                                面额
                                            </th>
                                            <th width='10%'>
                                                代号
                                            </th>
                                            <th width='12%'>
                                                有效期限
                                            </th>
                                            <th width='6%'>
                                                状态
                                            </th>
                                            <th width='10%'>
                                                商户名称
                                            </th>
                                            <th width='10%'>
                                                派发的用户
                                            </th>
                                            <th width='25%'>
                                                项目名称
                                            </th>
                                            <th width='5%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListCard != null && iListCard.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (ICard cardInfo in iListCard)
                                              {
                                                  if (i % 2 != 0)
                                                  {
                                        %>
                                        <tr>
                                        <%
                                                  }
                                                  else
                                                  {
                                        %>
                                        <tr class='alt'>
                                        <%
                                                  }
                                            i++;
                                        %>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <input type='checkbox' id='check' name='check' value="<%=cardInfo.Id%>" />
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=cardInfo.Id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=cardInfo.Credit%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=cardInfo.Code%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=cardInfo.Begin_time.ToString()%>
                                                </div>
                                            </td>
                                            <%if (cardInfo.consume == "Y")
                                              { 
                                            %>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    已消费
                                                </div>
                                            </td>
                                            <%
                                                }
                                              else if (cardInfo.consume == "N" && Convert.ToDateTime(cardInfo.End_time) < DateTime.Now)
                                              { 
                                            %>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    已过期
                                                </div>
                                            </td>
                                            <% }
                                              else if (cardInfo.consume == "N" && Convert.ToDateTime(cardInfo.End_time) >= DateTime.Now)
                                              { 
                                            %>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    未消费
                                                </div>
                                            </td>
                                            <%
                                                }
                                              else
                                              { 
                                            %>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    &nbsp;
                                                </div>
                                            </td>
                                            <% }
                                            %>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <% if (cardInfo.Partner != null)
                                                       { 
                                                    %>
                                                    <%=cardInfo.Partner.Username%>
                                                    <!--商户名称-->
                                                    <%
                                                        }
                                                       else
                                                       {
                                                    %>
                                                        暂未商户
                                                    <%
                                                       }   
                                                    %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <% if (cardInfo.User != null)
                                                       { 
                                                    %>
                                                    <%=cardInfo.User.Email%>
                                                    <br />
                                                    <%=cardInfo.User.Username%>
                                                    <!--派发用户-->
                                                    <%
                                                        }
                                                       else
                                                       { }   
                                                    %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <% if (cardInfo.Team != null)
                                                       { 
                                                    %>
                                                    <%=cardInfo.Team.Title%>
                                                    <!--项目名称-->
                                                    <%
                                                        }
                                                       else
                                                       { 
                                                    %>
                                                        暂未项目
                                                    <%
                                                       }   
                                                    %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <a class="remove-record" href="Youhui_Daijinquan.aspx?delId=<%=cardInfo.Id %>"  ask='确定要删除吗?'>删除</a>
                                                </div>
                                            </td>
                                        </tr>
                                        <%       
                                            }
                                          } %>
                                        <tr>
                                            <td colspan="10">
                                                <input id="items" type="hidden" />
                                                <%if (pagerHtml != "")
                                                  { %>
                                                <input value="删除选中" type="button" class="formbutton" style="padding: 1px 6px;" onClick='javascript:GetDeleteItem(<%= Helper.GetInt(Request.QueryString["page"], 1) %>);' />
                                                <%} %><%=pagerHtml %>
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
                window.location = "Youhui_Daijinquan.aspx?item=" + $("#items").val() + "&url=" + urls;
            }
        }
        else {
            alert("你还没有选择删除项！ ");
        }
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>