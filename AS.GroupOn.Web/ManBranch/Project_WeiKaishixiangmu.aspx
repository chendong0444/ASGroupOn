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

    protected IPagers<ITeam> pager = null;
    protected IList<ITeam> teamlist = null;
    protected IList<ITeam> teamlist2 = null;
    protected IList<ICatalogs> catalogslist = null;
    protected CouponFilter couponfilter = new CouponFilter();
    protected IList<ICatalogs> iListCatalogs = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected CategoryFilter categoryfilter = new CategoryFilter();
    protected IList<ICategory> iListCategory = null;
    protected CatalogsFilter catalogsfilter = new CatalogsFilter();
    protected System.Data.DataTable catalogsdt = null;
    protected int count = 0;
    protected string style = null;
    protected string style1 = null;
    protected string style2 = null;
    protected string style3 = null;
    protected ITeam teamodel = null;
    protected ICategory categorymodel = null;
    private string href = "";
    private NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        TeamFilter filter2 = new TeamFilter();
        _system = AS.Common.Utils.WebUtils.GetSystem();   
        if (Request.QueryString["remove"] != null)
        {
            delProject(int.Parse(Request.QueryString["remove"].ToString()));
        }
        if (Request.QueryString["downloadid"] != null)
        {
            xiazai(Request.QueryString["downloadid"]);
        }
        if (Request["btnselect"] == "筛选" && ddlhost.SelectedValue == "" && this.ddlparent.SelectedValue == "" && this.ddlstate.SelectedValue == "")
        {
            Response.Redirect("Project_DangqianXiangmu.aspx");
        }
        #region 根据项目标题查询模糊查询
        if (Request["btnselect"] == "筛选" || Request.QueryString["teamhost"] != null || Request.QueryString["CataID"] != null || Request.QueryString["teamhost"] != null || Request.QueryString["teamID"] != null || Request.QueryString["TitleLike"] != null || Request.QueryString["cityidIn"] != null || Request.QueryString["Partner_id"] != null)
        {
            
            if (ddlhost.SelectedValue == "1" || Request.QueryString["teamhost"] == "1")
            {
                filter2.teamhost = 1;
                url = url + "&teamhost=1";
            }
            else if (ddlhost.SelectedValue == "2" || Request.QueryString["teamhost"] == "2")
            {
                filter2.teamhost = 2;
                url = url + "&teamhost=2";
            }
            if (this.ddlparent.SelectedValue != "0" || Request.QueryString["CataID"] != null)
            {
                if (Request.QueryString["CataID"] != null)
                {
                    this.ddlparent.SelectedValue = Request.QueryString["CataID"].ToString();
                }

                filter2.CataID = Convert.ToInt32(this.ddlparent.SelectedValue);
                url = url + "&CataID=" + this.ddlparent.SelectedValue;
            }
            //if (this.ddlstate.SelectedValue != "0")
            //{
            if (this.ddlstate.SelectedValue == "1" || Request.QueryString["teamID"] != null)//项目ID
            {
                if (Request.QueryString["teamID"] != null)
                {
                    this.ddlstate.SelectedValue = "1";
                    this.txtteam.Text = Request.QueryString["teamID"].ToString();
                }

                filter2.Id = AS.Common.Utils.Helper.GetInt(this.txtteam.Text, 0);
                url = url + "&teamID=" + AS.Common.Utils.Helper.GetInt(this.txtteam.Text, 0);
            }
            else if (this.ddlstate.SelectedValue == "2" || Request.QueryString["TitleLike"] != null)//项目标)//项目标题
            {
                if (Request.QueryString["TitleLike"] != null)
                {
                    this.ddlstate.SelectedValue = "2";
                    this.txtteam.Text = Request.QueryString["TitleLike"].ToString();
                }
                if (this.txtteam.Text != null)
                {
                    filter2.TitleLike = this.txtteam.Text;
                    url = url + "&TitleLike=" + AS.Common.Utils.Helper.GetInt(this.txtteam.Text, 0);
                }
            }
            else if (this.ddlstate.SelectedValue == "3" || Request.QueryString["cityidIn"] != null)//城)//城市
            {
                if (Request.QueryString["cityidIn"] != null)
                {
                    this.ddlstate.SelectedValue = "3";
                    this.txtteam.Text = Request.QueryString["cityidIn"].ToString();
                }
                if (this.txtteam.Text != null)
                {
                    filter2.cityidIn = this.txtteam.Text;
                    url = url + "&cityidIn=" + this.txtteam.Text;
                }
            }
            else if (this.ddlstate.SelectedValue == "4" || Request.QueryString["Partner_id"] != null)//商)//商户
            {
                if (Request.QueryString["Partner_id"] != null)
                {
                    this.ddlstate.SelectedValue = "4";
                    this.txtteam.Text = Request.QueryString["Partner_id"].ToString();
                }
                if (this.txtteam.Text != null && this.txtteam.Text != "")
                {
                    filter2.Partner_id = AS.Common.Utils.Helper.GetInt(this.txtteam.Text, 0);
                    url = url + "&Partner_id=" + AS.Common.Utils.Helper.GetInt(this.txtteam.Text, 0);
                }
            }
            //}

        }
        #endregion

        #region 复制项目
        if (Request["add"] != null)
        {
            AddTeam(Convert.ToInt32(Request["add"]));
        }
        #endregion
        #region 复制到商城项目
        if (Request["addmall"] != null && Request["teamcata"] != null)
        {
            AddMallTeam(Convert.ToInt32(Request["addmall"].ToString()), Convert.ToInt32(Request["teamcata"].ToString()));
        }
        #endregion

        url = url + "&page={0}";
        url = "Project_WeiKaishixiangmu.aspx?" + url.Substring(1);

        filter2.PageSize = 30;
        filter2.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        if (Request.QueryString["team_type"] != null)
        {
            switch (Request.QueryString["team_type"].ToString())
            {
                case "normal":
                    style1 = "current";
                    break;
                case "seconds":
                    style2 = "current";
                    break;
                case "goods":
                    style3 = "current";
                    break;
            }
            filter2.Team_type = Request.QueryString["team_type"].ToString();
        }
        else
        {
            style = "current";
        }
        filter2.AddSortOrder(TeamFilter.Sort_Order_DESC);
        filter2.AddSortOrder(TeamFilter.ID_DESC);
        filter2.teamcata = 0;
        filter2.unpoint = "point";
        //filter2.State = TeamState.None;
        filter2.FromBegin_time = DateTime.Now;
        filter2.City_id = AsAdmin.City_id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(filter2);
        }
        teamlist2 = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);


        //分类
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        //分类
        catalogsfilter.type = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catalogslist = session.Catalogs.GetList(catalogsfilter);
        }
        catalogsdt = AS.Common.Utils.Helper.ToDataTable(catalogslist.ToList());
        if (!IsPostBack)
        {
            this.ddlparent.Items.Add(new ListItem("请选择", "0"));
            BindData(catalogsdt, "0", "", "parent_id", this.ddlparent, "catalogname", "id");
        }

    }



    #region 复制项目
    public void AddTeam(int teamid)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(teamid);
        }

        if (teamodel.autolimit <= 0)
        {
            teamodel.autolimit = 0;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int id = session.Teams.Insert(teamodel);
        }
        SetSuccess("友情提示：复制成功");
        Response.Redirect("Project_WeiKaishixiangmu.aspx");
    }
    #endregion

    #region 复制为商城项目
    public void AddMallTeam(int teamid, int teamcata)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(teamid);
        }
        if (teamodel.autolimit <= 0)
        {
            teamodel.autolimit = 0;
        }
        teamodel.Now_number = 0;//复制到商城购买人数变为0
        teamodel.Per_number = 0;//商城不限制购买人数
        teamodel.Conduser = "N";
        teamodel.teamcata = teamcata;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int id = session.Teams.Insert(teamodel);
        }
        SetSuccess("友情提示：复制成功");
        Response.Redirect("Project_WeiKaishixiangmu.aspx");
    }
    #endregion

    private void delProject(int id)
    {
        bool result = false;
        result = isExist(id);
        if (result)
        {
            SetError("项目已成交 , 不可删除！");
        }
        else
        {
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                session.Teams.Delete(id);
                //teams.Delete(id, AsUser.Id);
            }
            SetSuccess("删除成功");
            string key = AS.Common.Utils.FileUtils.GetKey();
            AS.AdminEvent.ConfigEvent.AddOprationLog(AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0), "删除项目", "删除项目 ID:" + Request.QueryString["remove"].ToString(), DateTime.Now);
        }
    }
    public bool isExist(int id)
    {
        OrderFilter orderfilter = new OrderFilter();
        OrderDetailFilter orderdetailfilter = new OrderDetailFilter();

        IList<IOrderDetail> orderdetaillist = null;
        IList<IOrder> orderlist = null;
        bool result = false;
        orderdetailfilter.TeamidOrder = id;
        orderfilter.Team_id = id;
        orderfilter.State = "pay";

        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            orderdetaillist = session.OrderDetail.GetList(orderdetailfilter);
            orderlist = session.Orders.GetList(orderfilter);
        }

        if (orderlist.Count > 0 || orderdetaillist.Count > 0)
        {
            result = true;
        }
        return result;
    }
    /// <summary>
    /// 下载
    /// </summary>
    /// <param name="teamid"></param>
    //属于购物车的项目名称
    public string[] GteamName;
    //属于购物车的项目ID
    public int[] GteamID;
    //属于购物车项目的商品名称
    public string[] Product;
    //属于购物车的购买数量
    public int[] GNum;
    //属于购物车的规格
    public string[] GResult;
    public bool blag = true;
    public System.Data.DataTable dt = null;
    private void xiazai(string teamid)
    {
        StringBuilder sb1 = new StringBuilder();
        IOrder order = null;
        IUser usermodel = null;
        //不属于购物车的项目名称
        string teamName;
        //不属于购物车的项目ID
        int teamID;
        //记录是否属于购物车,如果是false就不属于购物车，否则属于购物车
        bool result = false;
        string where = " 1=1  ";
        string orderby = "[order].create_time";
        if (teamid != "0")
        {
            where = where + " and (Team_id=" + teamid + " or teamid=" + teamid + ")";
        }
        where = where + " and state='pay'";
        List<Hashtable> halis = null;
        //select [order].Id,[order].Pay_id ,[order].Express,[order].State,[order].Service,[order].Price,[order].Fare,[order].Origin,[order].Money,[order].Credit,[order].fromdomain ,[order].adminremark,[order].IP_Address,[order].Realname,[order].Address,[order].Zipcode,[order].Mobile,[order].User_id,  orderdetail.Order_id,[order].Card  ,orderdetail.result as bb , User_id , Admin_id, State, Quantity from [order] left join orderdetail on [order].Id=orderdetail.order_id left join [user] on User_id=[user].Id  where  1=1   and (Team_id=3959 or teamid=3959) and state='pay' order by [order].create_time
        //select *,orderdetail.result as bb  ,[order].result as aa , from [order] left join orderdetail on [order].Id=orderdetail.order_id left join [user] on User_id=[user].Id  where " + where + " order by " + orderby



        using (IDataSession sesssion = AS.GroupOn.App.Store.OpenSession(false))
        {
            halis = sesssion.GetData.GetDataList("select [order].Id,[order].Pay_id ,[order].Express,[order].State,[order].Service,[order].Price,[order].Fare,[order].Origin,[order].Money,[order].Credit,[order].fromdomain ,[order].adminremark,[order].IP_Address,[order].Realname,[order].Address,[order].Zipcode,[order].Mobile,[order].User_id,  orderdetail.Order_id,[order].Card  , [order].Team_id,orderdetail.result,[order].Pay_time,[order].Remark,[order].Express_id,Quantity ,[User].Username,[User].Email from [order] left join orderdetail on [order].Id=orderdetail.order_id left join [user] on User_id=[user].Id  where " + where + " order by " + orderby);
        }


        sb1.Append("<html>");
        sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
        sb1.Append("<body><table border=\'1\'>");
        sb1.Append("<tr>");
        sb1.Append("<td>ID</td>");
        sb1.Append("<td align='left'>订单号</td>");
        sb1.Append("<td>支付方式</td>");
        sb1.Append("<td>单价</td>");
        sb1.Append("<td>运费</td>");
        sb1.Append("<td>总金额</td>");
        sb1.Append("<td>支付款</td>");
        sb1.Append("<td>余额付款</td>");
        sb1.Append("<td>支付状态</td>");
        sb1.Append("<td>支付日期</td>");
        sb1.Append("<td>备注</td>");
        sb1.Append("<td>快递信息</td>");
        sb1.Append("<td>用户名</td>");
        sb1.Append("<td>用户邮箱</td>");
        sb1.Append("<td>用户手机</td>");
        sb1.Append("<td>收件人</td>");
        sb1.Append("<td>邮政编码</td>");
        sb1.Append("<td>送货地址</td>");
        sb1.Append("<td>支付号</td>");
        sb1.Append("</tr>");
        //AS.Common.Utils.Helper.ConvertDataTable
        //AS.Common.Utils.Helper.ToDataTable
        dt = AS.Common.Utils.Helper.ConvertDataTable(halis);
        if (dt != null && dt.Rows.Count > 0)
        {
            int num = 0;
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (num != Convert.ToInt32(dt.Rows[i]["Id"].ToString()))
                {
                    num = Convert.ToInt32(dt.Rows[i]["Id"].ToString());
                    sb1.Append("<tr>");
                    sb1.Append("<td>");
                    sb1.Append(dt.Rows[i]["Id"]);
                    sb1.Append("</td>");

                    //是否属于购物车
                    if (Convert.ToInt32(dt.Rows[i]["Team_id"].ToString()) == 0)
                    {
                        result = true;
                        OrderDetailFilter orderft = new OrderDetailFilter();
                        IList<IOrderDetail> orderlis = null;
                        orderft.Order_ID = AS.Common.Utils.Helper.GetInt(dt.Rows[i]["Id"], 0);
                        orderft.Teamid = AS.Common.Utils.Helper.GetInt(teamid, 0); //3959;
                        orderft.AddSortOrder(OrderDetailFilter.Order_ID_DESC);
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            orderlis = session.OrderDetail.GetList(orderft);
                        }
                        //属于购物车就查找购物车表并查找用户表

                        GteamID = new int[orderlis.Count];
                        GteamName = new string[orderlis.Count];
                        Product = new string[orderlis.Count];
                        GNum = new int[orderlis.Count];
                        GResult = new string[orderlis.Count];
                        if (orderlis != null && orderlis.Count > 0)
                        {
                            for (int j = 0; j < orderlis.Count; j++)
                            {
                                IOrderDetail order1 = orderlis[j];
                                //把项目ID，添加到数组中
                                int s = order1.Teamid;

                                GteamID[j] = order1.Teamid;
                                //把项目名称，添加到数组中
                                GteamName[j] = order1.Team.Title;
                                //把项目的商品名称，添加到数组中
                                Product[j] = order1.Product;
                                //把订单的数量，添加到数组中
                                GNum[j] = order1.Num;
                                //把规格添加到数组中
                                GResult[j] = order1.result;
                            }
                        }
                    }
                    else
                    {
                        result = false;
                        //不属于购物车
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            teamodel = session.Teams.GetByID(AS.Common.Utils.Helper.GetInt(dt.Rows[i]["Team_id"], 0));
                        }
                        if (teamodel != null)
                        {
                            //添加项目ID
                            teamID = teamodel.Id;
                            //项目名称
                            teamName = teamodel.Title;
                        }
                    }
                    //订单号
                    sb1.Append("<td>");
                    if (result)
                    {
                        for (int j = 0; j < GteamID.Length; j++)
                        {
                            sb1.Append(Product[j]);

                            if (GteamName[j] != null && GteamName[j].ToString() != "")
                            {
                                sb1.Append(GteamName[j].ToString());
                            }
                            if (GResult[j] != null && GResult[j].ToString() != "")
                            {
                                sb1.Append(GResult[j].ToString());
                            }
                            else
                            {
                                sb1.Append("[" + GNum[j].ToString() + "件] ");
                            }
                        }

                    }
                    else
                    {
                        if (teamodel != null)
                        {
                            sb1.Append(teamodel.Product);
                            if (dt.Rows[i]["result"] != null && dt.Rows[i]["result"].ToString() != "")
                            {
                                sb1.Append(dt.Rows[i]["result"].ToString());
                            }
                            else
                            {
                                sb1.Append("[" + dt.Rows[i]["Quantity"].ToString() + "件]");
                            }
                        }

                    }
                    sb1.Append("</td>");
                    //支付方式
                    sb1.Append("<td>");
                    switch (dt.Rows[i]["Service"].ToString())
                    {
                        case "yeepay":
                            sb1.Append("易宝");
                            break;
                        case "alipay":
                            sb1.Append("支付宝");
                            break;
                        case "tenpay":
                            sb1.Append("财付通");
                            break;
                        case "chinamobilepay":
                            sb1.Append("移动支付");
                            break;
                        case "chinabank":
                            sb1.Append("网银在线");
                            break;
                        case "credit":
                            sb1.Append("余额付款");
                            break;
                        case "allinpay":
                            sb1.Append("通联支付");
                            break;
                        case "cash":
                            sb1.Append("线下支付");
                            break;
                        default:
                            sb1.Append("");
                            break;
                    }
                    sb1.Append("</td>");
                    //单价
                    sb1.Append("<td>" + dt.Rows[i]["Price"].ToString() + "</td>");
                    //运费
                    sb1.Append("<td>" + dt.Rows[i]["Fare"] + "</td>");
                    //总金额
                    sb1.Append("<td>" + dt.Rows[i]["Origin"] + "</td>");
                    //支付款
                    sb1.Append("<td>" + dt.Rows[i]["Money"] + "</td>");
                    //余额付款
                    sb1.Append("<td>" + dt.Rows[i]["Credit"] + "</td>");
                    //支付状态
                    sb1.Append("<td>" + dt.Rows[i]["State"] + "</td>");
                    //支付日期
                    sb1.Append("<td>" + dt.Rows[i]["Pay_time"] + "</td>");
                    //备注
                    if (dt.Rows[i]["Remark"].ToString() != "")
                    {
                        sb1.Append("<td>" + dt.Rows[i]["Remark"] + "</td>");
                    }
                    else
                    {
                        sb1.Append("<td>&nbsp;</td>");
                    }

                    //快递信息
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        categorymodel = session.Category.GetByID(AS.Common.Utils.Helper.GetInt(dt.Rows[i]["Express_id"], 0));
                    }

                    sb1.Append("<td>");
                    if (categorymodel != null)
                    {
                        sb1.Append(categorymodel.Name);
                    }
                    else
                    {
                        sb1.Append("&nbsp;");
                    }
                    sb1.Append("</td>");
                    //用户名
                    sb1.Append("<td>" + dt.Rows[i]["Username"].ToString() + "</td>");
                    //用户邮箱
                    sb1.Append("<td>" + dt.Rows[i]["Email"].ToString() + "</td>");
                    //用户手机
                    sb1.Append("<td>" + dt.Rows[i]["Mobile"].ToString() + "</td>");
                    //收件人
                    sb1.Append("<td>" + dt.Rows[i]["Realname"] + "</td>");
                    //邮政编码
                    sb1.Append("<td>" + dt.Rows[i]["Zipcode"].ToString() + "</td>");
                    //送货地址
                    sb1.Append("<td>" + dt.Rows[i]["Address"].ToString() + "</td>");
                    //支付号
                    sb1.Append("<td>" + dt.Rows[i]["Pay_id"].ToString() + "</td>");
                    sb1.Append("</tr>");
                }

            }
        }
        else
        {
            SetError("没有数据，请重新选择条件下载！");
            Response.Redirect("YingXiao_ShujuXiazai_Team.aspx");
            Response.End();
        }

        sb1.Append("</table></body></html>");
        Response.ClearHeaders();
        Response.Clear();
        Response.Expires = 0;
        Response.Buffer = true;
        Response.AddHeader("Accept-Language", "zh-tw");
        //文件名称
        Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("team_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
        Response.ContentType = "Application/octet-stream";
        //文件内容
        Response.Write(sb1.ToString());
        Response.End();

    }
    /// <summary>
    /// 绑定下拉框列表
    /// </summary>
    /// <param name="dt"></param>
    /// <param name="id">ID 值 </param>
    /// <param name="blank">是否需要加符号?不加为null</param>
    /// <param name="sqlvalue">筛选为 ID值 的数据</param>
    /// <param name="listName"> 这里是需要绑定的下拉列表控件ID</param>
    private void BindData(System.Data.DataTable dt, string id, string blank, string sqlvalue, DropDownList listName, string name, string value)
    {

        if (dt != null && dt.Rows.Count > 0)
        {
            System.Data.DataView dv = new System.Data.DataView(dt);
            if (sqlvalue != null && sqlvalue != "")
            {
                dv.RowFilter = sqlvalue + "= " + id;
            }

            if (id != "0" && blank != null)
            {
                blank += "|─";
            }
            foreach (System.Data.DataRowView drv in dv)
            {
                listName.Items.Add(new ListItem(blank + "" + drv[name].ToString(), drv[value].ToString()));
                BindData(dt, drv[value].ToString(), blank, sqlvalue, listName, name, value);
            }
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
                                    <h2>
                                        未开始项目</h2>
                                    <div class="search">
                                        属性：<asp:DropDownList CssClass="h-input" ID="ddlhost" runat="server">
                                            <asp:ListItem Value="0">请选择</asp:ListItem>
                                            <asp:ListItem Value="2">推荐</asp:ListItem>
                                            <asp:ListItem Value="1">新品</asp:ListItem>
                                        </asp:DropDownList>
                                        分类：
                                        <asp:DropDownList CssClass="h-input" ID="ddlparent" runat="server">
                                        </asp:DropDownList>
                                        <asp:DropDownList CssClass="h-input" ID="ddlstate" runat="server">
                                            <asp:ListItem Value="0">请选择</asp:ListItem>
                                            <asp:ListItem Value="1">项目编号</asp:ListItem>
                                            <asp:ListItem Value="2">项目标题</asp:ListItem>
                                            
                                            <asp:ListItem Value="4">商户编号</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:TextBox CssClass="h-input" ID="txtteam" runat="server"></asp:TextBox>
                                        <input type="submit"  id="btnselect" group="goto" value="筛选" class="formbutton" name="btnselect"
                                            style="padding: 1px 6px;" />
                                        <ul class="filter">
                                            <li class="<%=style %>"><a href="Project_WeiKaishixiangmu.aspx">全部</a></li>
                                            <li class="<%=style1 %>"><a href="Project_WeiKaishixiangmu.aspx?team_type=normal">团购</a></li>
                                            <li class="<%=style2 %>"><a href="Project_WeiKaishixiangmu.aspx?team_type=seconds">秒杀</a></li>
                                            <li class="<%=style3 %>"><a href="Project_WeiKaishixiangmu.aspx?team_type=goods">热销</a></li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='8%'>
                                                ID
                                            </th>
                                            <th width='20%'>
                                                项目名称
                                            </th>
                                            <th width='10%'>
                                                属性
                                            </th>
                                            <th width='15%'>
                                                类别
                                            </th>
                                            <th width='8%'>
                                                排序
                                            </th>
                                            <th width='12%'>
                                                日期
                                            </th>
                                            <th width='5%'>
                                                成交
                                            </th>
                                            <th width='7%'>
                                                价格
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (teamlist2 != null && teamlist2.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (ITeam teamInfo in teamlist2)
                                              {
                                                  href = getTeamPageUrl(teamInfo.Id);
                                                  if (i%2 != 0)
                                                  {%>
                                                      <tr>
                                                 <% }
                                                  else
                                                  {%>
                                                      <tr class = "alt">
                                                 <% }
                                                  i++;
                                        %>
                                        
                                            <td>
                                                <%=teamInfo.Id%>
                                            </td>
                                            <% if (teamInfo.Team_type == "normal")
                                               {%>
                                            <td>
                                                [团购] <a href="<%= href %>" target="_blank" class="deal-title">
                                                    <%=teamInfo.Title%>
                                                </a>
                                            </td>
                                            <% }
                                               else if (teamInfo.Team_type == "seconds")
                                               {%>
                                            <td>
                                                [秒杀]<a href="<%= href %>" target="_blank" class="deal-title">
                                                    <%=teamInfo.Title%>
                                                </a>
                                            </td>
                                            <%}
                                               else if (teamInfo.Team_type == "goods")
                                               {%>
                                            <td>
                                                [热销] 
                                                <a href="<%= href %>" target="_blank" class="deal-title">
                                                    <%=teamInfo.Title%>
                                               
                                                </a>
                                            </td>
                                            <% }
                                               else
                                               { %>
                                            <td>
                                                <a href="<%= href %>" target="_blank" class="deal-title">
                                                    <%=teamInfo.Title%></a>
                                            </td>
                                            <%
                                                } %>
                                            <%if (teamInfo.teamhost == 1)
                                              {
                                            %>
                                            <td>
                                                <a>新品</a>
                                            </td>
                                            <%}
                                              else if (teamInfo.teamhost == 2)
                                              {%>
                                            <td>
                                                <a>推荐</a>
                                            </td>
                                            <% }
                                              else
                                              {%>
                                            <td>
                                                <a>&nbsp;</a>
                                            </td>
                                            <%} %>
                                             <%ICategory cate = null;
                                                  using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                  {
                                                      cate = session.Category.GetByID(teamInfo.City_id);
                                                  }%>
                                                <td>
                                                    <%if (cate != null)
                                                      {%>
                                                    <%=cate.Name %>
                                                    <%}
                                                      else if (teamInfo.City_id == 0)
                                                  {%>
                                                <a>全部城市</a>
                                                <% }
                                                  else
                                                  {%>
                                                <a>城市不存在</a>
                                                <%}%>
                                                <br />
                                                <% if (teamInfo.cataid != null)
                                                   {
                                                       catalogsfilter.id = teamInfo.cataid;
                                                       using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                       {
                                                           iListCatalogs = session.Catalogs.GetList(catalogsfilter);
                                                       }
                                                       foreach (ICatalogs catalogs in iListCatalogs)
                                                       {
                                                           if (catalogs.catalogname != null)
                                                           { %>
                                                <a>[<%= catalogs.catalogname %>]</a>
                                                <% }%>
                                                <%else
{%>
                                                <a></a>
                                                <%}
                                                       }
                                                   }
                                                   else
                                                   {%>
                                                <a></a>
                                                <%}%>
                                                <br />
                                                <%if (teamInfo.Group_id != null)
                                                  {
                                                      categoryfilter.Id = teamInfo.Group_id;
                                                      using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                      {
                                                          iListCategory = session.Category.GetList(categoryfilter);
                                                      }
                                                      foreach (ICategory category in iListCategory)
                                                      {
                                                          if (category.Name != null)
                                                          { %>
                                                <a>[<%= category.Name %>](API)</a>
                                                <% }
                                                          else
                                                          {%>
                                                <a></a>
                                                <%}
                                                      }
                                                  }%>
                                            </td>
                                            <td>
                                                <%=teamInfo.Sort_order %>
                                            </td>
                                            <td>
                                                <%=teamInfo.Begin_time%>
                                                <br />
                                                <%=teamInfo.End_time %>
                                            </td>
                                            <td>
                                                <a>
                                                    <%=teamInfo.Now_number%>/<%=teamInfo.Min_number%></a>
                                            </td>
                                            <td>
                                                <span class='money'>￥</span><%=teamInfo.Market_price%><br />
                                                <span class='money'>￥</span><%=teamInfo.Team_price%>
                                            </td>
                                            <td class="op">
                                                <a class="ajaxlink" href="ajax_manage.aspx?action=teamdetail&id=<%=teamInfo.Id%>">详情</a>｜
                                                <a class="deal-title" href="Project_BianjiXiangmu.aspx?id=<%=teamInfo.Id%>">编辑</a>｜
                                                <a class="deal-title" href="Project_WeiKaishixiangmu.aspx?remove=<%= teamInfo.Id%>"
                                                    ask="确定删除本项目吗?">删除</a>｜ <a class="deal-title" href="Project_WeiKaishixiangmu.aspx?add=<%= teamInfo.Id %>"
                                                        ask="确定复制本项目吗？">复制</a>
                                                <%
                                                    if (teamInfo.productid == 0)//没有绑定产品的才有出入库操作
                                                    {
                                                        if (teamInfo.Delivery == "express")
                                                        {%>
                                                <br />
                                                <a class="ajaxlink" href="ajax_coupon.aspx?action=invent&p=&inventid=<%= teamInfo.Id %>"
                                                    target='_blank'>出入库</a>
                                                <%   }
                                                    }
                                                    if (teamInfo.Delivery.ToString() == "draw")
                                                    {%>
                                                <br />
                                                <a href="Project_DrawList.aspx?id=<%=teamInfo.Id %>" target="_blank">抽奖信息</a>");
                                                <%}


                                                    if (teamInfo.Delivery.ToString() == "pcoupon")
                                                    {%>
                                                <br />
                                                <a href="PcouponFile.aspx?teamid=<%=teamInfo.Id%>" target='_blank'>导入站外券</a>(剩：<a
                                                    href="Youhui_pcoupon.aspx?states=nobuy&&teamid=<%=teamInfo.Id  %>">
                                                    <%
                                                        couponfilter.Consume = "N";
                                                        couponfilter.Team_id = teamInfo.Id;
                                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                        {
                                                            count = session.Coupon.GetCount(couponfilter);
                                                        } %>
                                                    <%=count %></a> / 总：<a href="Youhui_pcoupon.aspx?teamid=<%= teamInfo.Id %>"><% couponfilter.Team_id = teamInfo.Id;
                                                                                                                                   using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                                                                                                   {
                                                                                                                                       count = session.Coupon.GetCount(couponfilter);
                                                                                                                                   } %>
                                                        <%=count %></a>)
                                                <%}%>
                                                <br />
                                                <a href="Project_WeiKaishixiangmu.aspx?downloadid=<%= teamInfo.Id %>">下载</a>
                                                <%if (teamInfo.Delivery.ToString() == "express")
                                                  {%>
                                                | <a href="Project_WeiKaishixiangmu.aspx?addmall=<%=teamInfo.Id  %>&teamcata=1"  ask="确定将本项目复制到商城吗?">
                                                    复制到商城</a>
                                                <% }
                                                  
                                                %>
                                            </td>
                                        </tr>
                                        <%
                                            }
                                          } %>
                                        <tr>
                                            <td colspan="10">
                                                <%=pagerHtml %>
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
<%LoadUserControl("_footer.ascx", null); %>
