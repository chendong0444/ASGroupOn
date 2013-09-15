<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    protected IPagers<IInvite> pager = null;
    protected IList<IInvite> iListInvite = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected InviteFilter filter = new InviteFilter();
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Invite_TongjiList))
        {
            SetError("你不具有查看邀请统计列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (Request["saiXuan"] == "筛选")
        {
            SelectWhere();
        }
        YaoqingTongji();
    }
    /// <summary>
    /// 邀请统计
    /// </summary>
    private void YaoqingTongji()
    {
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<th width='15%'>邀请用户</th>");
        sb1.Append("<th width='10%'>手机号</th>");
        sb1.Append("<th width='15%'>Email</th>");
        sb1.Append("<th width='10%'>城市</th>");
        sb1.Append("<th width='25%'>来源地址</th>");
        sb1.Append("<th width='15%'>邀请次数</th>");
        sb1.Append("<th width='10%'>操作</th>");
        sb1.Append("</tr>");

        /*---------------获取邀请统计记录---------begin-----------------------------------------*/
        url = url + "&page={0}";
        url = "Index-YaoqingTongJi.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(InviteFilter.Num_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Invite.GetPager2(filter);
        }
        iListInvite = pager.Objects;
        /*---------------获取邀请统计记录--------end------------------------------------------*/

        //Response.Write(iListInvite.Count);
        StringBuilder sb2 = new StringBuilder();
        int i = 0;
        foreach (IInvite iinviteInfo in iListInvite)
        {
            if (i % 2 != 0)
            {
                sb2.Append("<tr>");
            }
            else
            {
                sb2.Append("<tr class='alt'>");
            }
            i++;
            sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 260px;'><a class='ajaxlink' href='ajax_manage.aspx?action=userview&Id=" + iinviteInfo.Id + "'>" + iinviteInfo.Username + "</a></div></td>");
            if (iinviteInfo.Mobile != "" && iinviteInfo.Mobile != null)
            {
                sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width:260px;'>" + iinviteInfo.Mobile + "</div></td>");
            }
            else
            {
                sb2.Append("<td>暂无</td>");
            }
            if (iinviteInfo.Email != "" && iinviteInfo.Email!=null)
            {
                sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width:260px;'>" + iinviteInfo.Email + "</div></td>");
            }
            else
            {
                sb2.Append("<td>暂无</td>");
            }
            if (iinviteInfo.Name != "" && iinviteInfo.Name!=null)
            {
                sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width:260px;'>" + iinviteInfo.Name + "</div></td>");
            }
            else
            {
                sb2.Append("<td>暂无</td>");
            }
            if (iinviteInfo.IP_Address != "" && iinviteInfo.IP_Address!= null)
            {
                sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width:260px;'><a href='" + iinviteInfo.IP_Address + "' target='_blank'>" + iinviteInfo.IP_Address + "</a></div></td>");
            }
            else
            {
                sb2.Append("<td>自行输入网址</td>");
            }
            if (iinviteInfo.num.ToString() != "" && iinviteInfo.num != null)
            {
                sb2.Append("<td>" + iinviteInfo.num + "</td>");
            }
            else
            {
                sb2.Append("<td>0</td>");
            }
            sb2.Append("<td style=' color:red;'><a href='Index-FanliTongji_Xiangqing.aspx?action=InviteView&id=" + iinviteInfo.Id + "&pageIndex=1'>详情</a></td>");
            sb2.Append("</tr>");
        }
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
    }

    ///// <summary>
    ///// 筛选条件
    ///// </summary>
    public void SelectWhere()
    {
        if (!string.IsNullOrEmpty(Request["ddlState"]))
        {
            url = url + "&ddlState=" + Request["ddlState"];
            string ddlState = Request["ddlState"];

            if (ddlState == "1")//邀请人用户名
            {
                //filter.Team_id = Helper.GetInt(Request["txtcontent"], 0);
                filter.Username = Helper.GetString(Request["txtcontent"], String.Empty);
            }
            if (ddlState == "2")//手机号
            {
                filter.Mobile = Helper.GetString(Request["txtcontent"], String.Empty);
            }
            if (ddlState == "3")//E-mail
            {
                filter.email = Helper.GetString(Request["txtcontent"], String.Empty);
            }
            if (ddlState == "4")//城市
            {
                filter.Name = Helper.GetString(Request["txtcontent"], String.Empty);
            }
            if (ddlState == "5")//来源地址
            {
                filter.Ip_Address = Helper.GetString(Request["txtcontent"], String.Empty);
            }
            url = url + "&txtcontent=" + Request["txtcontent"];
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
                                    <h2>邀请统计</h2>
                                    <div class="search">
                                      <select name="ddlState">
                                                <option value="0">请选择</option>
                                                <option value="1" <%if(Request.QueryString["ddlState"] == "1"){ %>selected="selected" <%} %>>邀请人用户名</option>
                                                <option value="2" <%if(Request.QueryString["ddlState"] == "2"){ %>selected="selected" <%} %>>手机号</option>
                                                <option value="3" <%if(Request.QueryString["ddlState"] == "3"){ %>selected="selected" <%} %>>E-Mail</option>
                                                <option value="4" <%if(Request.QueryString["ddlState"] == "4"){ %>selected="selected" <%} %>>城市</option>
                                                <option value="5" <%if(Request.QueryString["ddlState"] == "5"){ %>selected="selected" <%} %>>来源地址</option>
                                            </select>&nbsp;&nbsp;
                                            <input type="text" name="txtcontent" class="h-input"
                                            <%if(!string.IsNullOrEmpty(Request.QueryString["txtcontent"])){ %>value="<%=Request.QueryString["txtcontent"] %>" <%} %>  />&nbsp;
                                            <input type="submit" value="筛选" class="formbutton" name="saiXuan" style="padding: 1px 6px;" />
                                    <ul class="filter">                                 
						                
					                </ul></div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table" style="table-layout:fixed;">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="8">
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
