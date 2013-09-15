<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    
    protected string sql = "";
    protected NameValueCollection _system = new NameValueCollection();
    protected IPagers<IDraw> pager = null;
    protected IList<IDraw> iListdraw = null;
    protected string pagerHtml = String.Empty;
    protected IDraw drawmodel = null;
    protected DrawFilter drawfilter = new DrawFilter();
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
      
        url = "Project_Drawlist.aspx?";
        if (Request["id"] != null)
        {
            drawfilter.teamid = Convert.ToInt32(Request["id"]);
            url = url + "&id=" + Request["id"];
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListdraw = session.Draw.GetList(drawfilter);
        }


        #region
        if (Request["sid"] != null)
        {
            url = url + "&sid=" + Request["sid"];
            Updatestate(AS.Common.Utils.Helper.GetInt(Request["sid"].ToString(), 0), AS.Common.Utils.Helper.GetInt(Request["id"].ToString(), 0));
           
        }
        #endregion


        if (Request["btnselect"] == "筛选")
        {
            if (this.ddlstate.SelectedValue == "0" && this.ddltype.SelectedValue == "0")
            {
                Response.Redirect("Project_DrawList.aspx");
            }
            if (this.ddlstate.SelectedValue == "Y" || Request["states"]!=null)//中奖
            {
                drawfilter.state = "Y";
                url = url + "&states=Y";
            }
            else if (this.ddlstate.SelectedValue == "N" ) //未中奖
            {
                drawfilter.state = "N";
                url = url + "&states=N";
            }
            if (Request["states"] != null)
            {
                if (Request["states"] == "Y")
                {
                    drawfilter.state = "Y";
                }else  if (Request["states"] == "N")
                {
                    drawfilter.state = "N";
                }
                
            }

            if (this.ddltype.SelectedValue == "1" || Request["numbers"] != null)//抽奖号码
            {
                drawfilter.number = this.txtbegin.Text;
                url = url + "&numbers=" + this.txtbegin.Text;
            }
            UserFilter userft = new UserFilter();
            IUser Userm = null;
            if (this.ddltype.SelectedValue == "2" || Request["Usernames"] != null)//用户名
            {
                userft.Username = this.txtbegin.Text;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    Userm = session.Users.Get(userft);
                }
                url = url + "&Usernames=" + this.txtbegin.Text;
                drawfilter.userid = Userm.Id;

            }
            if (this.ddltype.SelectedValue == "3" || Request["Emails"] != null)//Email
            {
                userft.Email = this.txtbegin.Text;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    Userm = session.Users.Get(userft);
                }
                url = url + "&Emails=" + this.txtbegin.Text;
                drawfilter.userid = Userm.Id;
            }
            if (this.ddltype.SelectedValue == "4" || Request["Emails"] != null)//手机
            {
                userft.Mobile = this.txtbegin.Text;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    Userm = session.Users.Get(userft);
                }
                url = url + "&Mobiles=" + this.txtbegin.Text;
                drawfilter.userid = Userm.Id;
            }
        }


        drawfilter.PageSize = 30;
        drawfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        url = url + "&page={0}";
        drawfilter.AddSortOrder(DrawFilter.CREATETIME_DESC);

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Draw.GetPager(drawfilter);
        }
        iListdraw = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

        GetTeamId();

    }

    #region 修改抽奖的状态
    public void Updatestate(int sid, int teamid)
    {
        IDraw draw = null;
        using (IDataSession session=AS.GroupOn.App.Store.OpenSession(false))
        {
            draw = session.Draw.GetByID(sid);
        }
        if (draw!=null)
        {
            if (draw.state == "Y")
                draw.state = "N";
            else if (draw.state == "N")
                draw.state = "Y";
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Draw.Update(draw);
            }
            if (i > 0)
                SetSuccess("友情提示：设置成功");
            else
                SetSuccess("友情提示：设置失败");
        }
        Response.Redirect("Project_DrawList.aspx"); 
    }
    #endregion
    public void GetTeamId()
    {
        int count;
        //数据类型
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<td width='100px'>抽奖号码</td>");
        sb1.Append("<td width='150px'>Email/用户名</td>");
        sb1.Append("<td width='90px' nowrap>姓名/城市</td>");
        sb1.Append("<td width='150px'>邀请人</td>");
        sb1.Append("<td width='120px'>邀请时间</td>");
        sb1.Append("<td width='100px'>联系电话</td>");
        sb1.Append("<td width='100px'>订单号</td>");
        sb1.Append("<td width='100px'>状态</td>");
        sb1.Append("<td width='120px'>操作</td>");
        sb1.Append("</tr>");
        int i = 0;
        foreach (IDraw draw in iListdraw)
        {
            //显示的数据
            if (i % 2 != 0)
                sb2.Append("<tr  id='team-list-id-" + i + "'>");
            else
                sb2.Append("<tr class=\"alt\"  id='team-list-id-" + i + "'>");
            sb2.Append("<td>" + draw.number + "</td>");
            if (draw.User != null)
                sb2.Append("<td>" + draw.User.Email + "<br/>" + draw.User.Username + "</td>");
            else
                sb2.Append("<td><br/></td>");
            if (draw.User != null)
            {
                if (draw.User.Category != null)
                {
                    sb2.Append("<td>" + draw.User.Realname + "<br/>" + draw.User.Category.Name + "</td>");//应该填入城市名称
                }
                else
                {
                    sb2.Append("<td>" + draw.User.Realname + "<br/>" + "全部城市" + "</td>");//应该填入城市名称

                }
            }
            else
            {
                sb2.Append("<td><span>&nbsp;</span></td>");
            }
            

            if (draw.User != null)
            {
                sb2.Append("<td><span>" + draw.User.Email + "<br/>" + draw.User.Username + "</span></td>");
            }
            else
            {
                sb2.Append("<td><span>暂未</span></td>");
            }
            sb2.Append("<td>" + draw.createtime + "</td>");
            if (draw.User != null)
            {
                sb2.Append("<td>" + draw.User.Mobile + "</td>");
            }
            else
            {
                sb2.Append("<td>&nbsp;</td>");
            }
            sb2.Append("<td>" + draw.orderid + "</td>");
            sb2.Append("<td>");

            if (draw.state == "Y")
            {
                sb2.Append("中奖");
            }
            else if (draw.state == "N")
            {
                sb2.Append("未中奖");
            }
            else
            {
                sb2.Append("-----");
            }
            sb2.Append("</a>&nbsp;</td>");
            sb2.Append("<td class='op'>");
            if (draw.User != null)
            {
                sb2.Append("<a class='ajaxlink' href='ajax_manage.aspx?action=userview&Id=" + draw.User.Id + "'>详情</a>｜");
                sb2.Append("<a href='" + WebRoot + "ajax/misc.aspx?action=sms&amp;v=" + draw.User.Mobile + "' class='ajaxlink'>短信</a>");
            }
            sb2.Append("<br>");

            if (draw.state == "Y")
            {
                sb2.Append("<a  style='color:red' href='Project_DrawList.aspx?sid=" + draw.id + "&id=" + draw.teamid + "' ask='是否取消中奖？'>");
                sb2.Append("取消中奖");
                sb2.Append("<a>");
            }
            else if (draw.state == "N")
            {
                sb2.Append("<a  style='color:red' href='Project_DrawList.aspx?sid=" + draw.id + "&id=" + draw.teamid + "' ask='是否设置为中奖？'>");
                sb2.Append("设置为中奖");
                sb2.Append("<a>");
            }
            sb2.Append("</td>");
            sb2.Append("</tr>");
            i++;
        }
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
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
                    <div id="content" class="box-content">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        抽奖项目</h2>
                                    <div class="search">
                                        <asp:DropDownList ID="ddlstate" runat="server">
                                            <asp:ListItem Value="0">请选择</asp:ListItem>
                                            <asp:ListItem Value="Y">中奖</asp:ListItem>
                                            <asp:ListItem Value="N">未中奖</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:DropDownList ID="ddltype" runat="server">
                                            <asp:ListItem Value="0">请选择</asp:ListItem>
                                            <asp:ListItem Value="1">抽奖号码</asp:ListItem>
                                            <asp:ListItem Value="2">用户名</asp:ListItem>
                                            <asp:ListItem Value="3">Email</asp:ListItem>
                                            <asp:ListItem Value="4">手机号</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:TextBox ID="txtbegin" runat="server" /><%--抽奖号码结束: <asp:TextBox ID="txtend" runat="server"></asp:TextBox>--%>
                                        <input type="submit" id="btnselect" group="goto" value="筛选" class="formbutton" name="btnselect"
                                            style="padding: 1px 6px;" />
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server" Text="6666"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                    </table>
                                    <%=pagerHtml %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- bd end -->
            </div>
            <!-- bdw end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
