<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    string sql = " 1=1 ";
    protected IPagers<IPacket> pager = null;
    //public Maticsoft.BLL.Packet bllPacket = new Maticsoft.BLL.Packet();
    //public Maticsoft.Model.UserInfo userInfo = new Maticsoft.Model.UserInfo();
    //public Maticsoft.BLL.UserInfo bllUserInfo = new Maticsoft.BLL.UserInfo();
    PacketFilter file = new PacketFilter();
    IList<IPacket> packlist = null;

    public string strpage;
    public string page = "1";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "packet";

        //判断用户失效！
        NeedLogin();

        if (!Page.IsPostBack)
        {
            if (Request["page"] != null)
            {
                if (NumberUtils.IsNum(Request["page"].ToString()))
                {
                    page = Request["page"].ToString();
                }
                else
                {
                    SetError("非法参数");
                }
            }
            else
            {
                page = "1";
            }
        }
        if (Request["action"] == "delete")
        {
            DeletePacketById();
        }
        if (Request["action"] == "packet")
        {
            GetPacket();
        }
        GetPacketById();
    }

    /// <summary>
    /// 读取数据
    /// </summary>
    private void GetPacketById()
    {
        file.User_id = AsUser.Id;
        file.PageSize = 30;
        file.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        StringBuilder stBTitle = new StringBuilder();
        StringBuilder stBContent = new StringBuilder();
        stBTitle.Append("<tr >");
        stBTitle.Append("<th width='180'>类型</th>");
        stBTitle.Append("<th width='150'>金额</th>");
        stBTitle.Append("<th width='280'>管理员</th>");
        stBTitle.Append("<th width='300'>时间</th>");
        stBTitle.Append("<th width='200'>操作</th>");
        stBTitle.Append("</tr>");

        file.AddSortOrder(PacketFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Packet.GetPager(file);

        }
        packlist = pager.Objects;
        //  Maticsoft.DBUtility.Pagers pager = Maticsoft.DBUtility.DbHelperSQL.SelectByPager("*", sql, "id desc", Convert.ToInt32(page), 30, "Packet", "", "");

        if (pager != null)
        {
            if (packlist.Count > 0)
            {
                for (int i = 0; i < packlist.Count; i++)
                {

                    if (i % 2 != 0)
                    {
                        stBContent.Append("<tr class='alt'>");
                    }
                    else
                    {
                        stBContent.Append("<tr>");
                    }
                    IUser userInfo = null;

                    if (packlist[i].Type.ToString() == "money")
                    {
                        stBContent.Append("<td>现金</td>");
                        stBContent.Append("<td>" + ASSystem.currency + packlist[i].Money + "</td>");
                    }
                    else if (packlist[i].Type.ToString() == "card")
                    {
                        stBContent.Append("<td>代金券</td>");
                        ICard card = null;
                        string carid = string.Empty;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            if (packlist[i].Number!=null)
                            {
                                carid =packlist[i].Number.ToString();
                            }
                            card = session.Card.GetByID(carid);
                        }
                        if (card != null)
                        {
                            stBContent.Append("<td>" + ASSystem.currency + card.Credit + "</td>");
                        }
                        else
                        {
                            stBContent.Append("<td></td>");
                        }
                    }
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        userInfo = session.Users.GetByID(packlist[i].Admin_Id);
                    }
                    if (userInfo != null)
                    {
                        stBContent.Append("<td>" + userInfo.Username+ "</td>");
                    }
                    else
                    {
                        stBContent.Append("<td></td>");
                    }
                    stBContent.Append("<td>" + packlist[i].Send_Time.ToString() + "</td>");
                    if (packlist[i].State.ToString() == "1")
                    {
                        stBContent.Append("<td>已领取 | <a href='" + GetUrl("我的红包", "order_packet.aspx?page=" + page + "&action=delete&id=" + packlist[i].Id) + "' ask='确认删除吗？'>删除</a></td>");
                    }
                    else if (packlist[i].State.ToString() == "0")
                    {
                        stBContent.Append("<td><a href='" + GetUrl("我的红包", "order_packet.aspx?page=" + page + "&action=packet&id=" + packlist[i].Id) + "'>领取 </a>| <a href='" + GetUrl("我的红包", "order_packet.aspx?page=" + page + "&action=delete&id=" + packlist[i].Id )+ "' ask='确认删除吗？'>删除</a></td>");
                    }
                    else
                    {
                        stBContent.Append("<td></td>");
                    }

                    stBContent.Append("</tr>");
                }
            }
        }
        Literal1.Text = stBTitle.ToString();
        Literal2.Text = stBContent.ToString();

        if (pager.TotalRecords >= 30)
        {
            strpage = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, Convert.ToInt32(page), GetUrl("我的红包","order_packet.aspx?page={0}"));
        }
    }

    /// <summary>
    /// 删除红包
    /// </summary>
    private void DeletePacketById()
    {
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            if (NumberUtils.IsNum(Request["id"].ToString()))
            {
                int id = int.Parse(Request["id"].ToString());
                int user_id = AsUser.Id;
                StringBuilder stB = new StringBuilder();
                IPacket packet = null;

                //Maticsoft.Model.Packet packet = new Maticsoft.Model.Packet();
                //Maticsoft.BLL.Packet bllPacket = new Maticsoft.BLL.Packet();
                int result = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    result = session.Packet.Delete(id);
                }
                if (result > 0)
                {
                    SetSuccess("删除成功");
                    Response.Redirect(GetUrl("我的红包","order_packet.aspx?page=" + page));
                }
                else
                {
                    SetError("删除失败");
                    Response.Redirect(GetUrl("我的红包", "order_packet.aspx?page=" + page));
                }
            }
            else
            {
                SetError("非法参数");
            }
        }
    }

    /// <summary>
    /// 领取红包
    /// </summary>
    private void GetPacket()
    {
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            if (NumberUtils.IsNum(Request["id"].ToString()))
            {
                int id = int.Parse(Request["id"].ToString());
                int user_id =AsUser.Id;

                StringBuilder stB = new StringBuilder();
                IPacket packet = null;
                IPacket packetUpdate = null;
                //Maticsoft.Model.Packet packet = new Maticsoft.Model.Packet();
                //Maticsoft.Model.Packet packetUpdate = new Maticsoft.Model.Packet();
                //Maticsoft.BLL.Packet bllPacket = new Maticsoft.BLL.Packet();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    packet = session.Packet.GetByID(id);
                }
                if (packet == null)
                {
                    SetError("红包选择错误");
                }
                else
                {
                    //已领取
                    if (packet.State == 1)
                    {
                        SetError("红包已经领取过");
                    }
                    //未领取
                    if (packet.State == 0)
                    {

                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            packetUpdate = session.Packet.GetByID(id);
                        }
                        if (packet.Type == "money")
                        {
                           
                            //更新Packet表
                            packetUpdate.User_id = user_id;
                            packetUpdate.State = 1;
                            packetUpdate.Get_Time = DateTime.Now;
                            packetUpdate.Money = packet.Money;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int i = session.Packet.Update(packetUpdate);
                            }
                            //bllPacket.UpdatePacket(packetUpdate);
                            //更新用户表

                            IUser userInfo = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                userInfo = session.Users.GetByID(Helper.GetInt(user_id, 0));
                            }
                            //Maticsoft.Model.UserInfo userInfo = new Maticsoft.Model.UserInfo();
                            //Maticsoft.BLL.UserInfo bllUserInfo = new Maticsoft.BLL.UserInfo();
                            //userInfo = bllUserInfo.GetModel(user_id);
                            userInfo.Money = userInfo.Money + packet.Money;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int i = session.Users.Update(userInfo);
                            }

                            IPacket pmodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                pmodel = session.Packet.GetByID(id);
                            }
                            //更新消费记录表
                            IFlow flow = Store.CreateFlow();
                            int ii = 0;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                flow.User_id = user_id;
                                flow.Admin_id = packet.Admin_Id;
                                flow.Detail_id = "0";
                                flow.Direction = "income";
                                flow.Money = packet.Money;
                                flow.Action = "money";
                                if (pmodel.Get_Time.ToString() != "0001-1-1 0:00:00" && pmodel.Get_Time!=null)
                                {
                                    flow.Create_time = Helper.GetDateTime(pmodel.Get_Time,DateTime.Now);
                                }
                                ii = session.Flow.Insert(flow);
                            }
                            SetSuccess("领取成功，请到<a href='" + GetUrl("账户余额", "credit_index.aspx") + "'>账户余额</a>查看");
                            Response.Redirect(GetUrl("我的红包", "order_packet.aspx?page=" + page));
                        }
                        else if (packet.Type == "card")
                        {
                            ICard card = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                card = session.Card.GetByID(packet.Number);
                            }
                            //更新Packet表
                            packetUpdate.User_id = user_id;
                            packetUpdate.State = 1;
                            packetUpdate.Get_Time = DateTime.Now;
                            packetUpdate.Money = card.Credit;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int i = session.Packet.Update(packetUpdate);
                            }
                            //更新代金券表
                            if (card != null)
                            {
                                int i = 0;
                                card.isGet = 1;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    i = session.Card.Update(card);
                                }
                                if (i > 0)
                                {
                                    SetSuccess("领取成功，请到<a href='" + GetUrl("我的代金券", "order_card.aspx") + "'>我的代金券</a>查看");
                                    Response.Redirect(GetUrl("我的红包", "order_packet.aspx?page=" + page));
                                }

                            }
                            else
                            {
                                SetError("领取失败，代金券已经不存在");
                                Response.Redirect(GetUrl("我的红包", "order_packet.aspx?page=" + page));
                            }
                        }
                    }
                }
            }
            else
            {
                SetError("非法参数");
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div class="menu_tab" id="dashboard">
                        <%LoadUserControl("_MyWebside.ascx", Ordertype); %>
                    </div>
                    <div id="tabsContent" class="coupons-box">
                        <div class="box-content1 tab">
                            <div class="head">
                                <h2>我的红包</h2>
                            </div>
                            <div class="sect">
                                <div class="clear">
                                </div>
                                <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                    <asp:literal id="Literal1" runat="server"></asp:literal>
                                    <asp:literal id="Literal2"
                                        runat="server"></asp:literal>
                                    <tr>
                                        <td colspan="5">
                                            <ul class="paginator">
                                                <li class="current">
                                                    <%=strpage%>
                                                </li>
                                            </ul>
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
</form>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %> 