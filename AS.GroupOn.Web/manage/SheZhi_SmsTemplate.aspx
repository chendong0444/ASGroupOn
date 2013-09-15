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
    protected ISmstemplate smstemplate = Store.CreateSmstemplate();
    protected IList<ISmstemplate> pages = null;
    SmstemplateFilter filter = new SmstemplateFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Sms_Template))
        {
            SetError("你不具有查看短信模版的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (!IsPostBack)
        {
            setPage();

        }
    }


    private void setPage()
    {
        DropDownList1.Items.Clear();
        div1.Visible = false;
        ListItem li = new ListItem();
        li.Text = "-----";
        li.Value = "-1";
        DropDownList1.Items.Add(li);

        //Maticsoft.BLL.System systems = new Maticsoft.BLL.System();
        //Maticsoft.Model.System system = new Maticsoft.Model.System();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pages = session.Smstemplate.GetList(filter);
        }

        if (pages != null)
        {

            foreach (ISmstemplate item in pages)
            {

                ListItem li1 = new ListItem();
                string name = item.name.ToString().ToLower().Trim();

                string text = "";

                switch (name)
                {
                    case "couponsms":
                        text = "站内优惠券短信";

                        break;
                    case "bizcouponsms":
                        text = "站外优惠券短信";

                        break;
                    case "orderpay":
                        text = "订单付款成功给用户发短信";
                        break;
                    case "orderpartner":
                        text = "订单付款成功给商家发短信";
                        break;
                    case "delivery":
                        text = "发货提醒";
                        break;
                    case "overtime":
                        text = "优惠券到期提醒";
                        break;
                    case "consumption":
                        text = "优惠券消费提醒";
                        break;
                    case "drawcode":
                        text = "抽奖认证码";
                        break;
                    case "subscribe":
                        text = "短信订阅认证码";
                        break;
                    case "qxsubscribe":
                        text = "短信取消订阅认证码";
                        break;
                    case "inventory":
                        text = "库存提醒";
                        break;
                    case "nowteam":
                        text = "今日团购";
                        break;
                    case "usersign":
                        text = "用户签到";
                        break;
                    case "orderteam":
                        text = "项目上线提醒";
                        break;
                    case "mobilecode":
                        text = "注册短息验证";
                        break;
                    default:
                        text = "";
                        break;

                }

                if (text != "")
                {
                    li1.Text = text;
                    li1.Value = name;
                    DropDownList1.Items.Add(li1);
                }
            }
        }


        DropDownList1.DataBind();


    }

    protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e)
    {

        string name = DropDownList1.SelectedItem.Value;

        div1.Visible = true;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pages = session.Smstemplate.GetList(filter);
            filter.Name = DropDownList1.SelectedItem.Value;
            foreach (ISmstemplate items in session.Smstemplate.GetList(filter))
            {
                pageContent.Value = items.value;
            }
        }

        string strmsg = "在编辑模板用到";

        switch (name)
        {
            case "couponsms":

                strmsg = strmsg + "<font color='red'><strong>[ 券号,密码,网站简称,优惠券开始时间,优惠券结束时间,商品名称,商户名称，商户电话,团购电话 ]</strong></font>";
                break;
            case "bizcouponsms":

                strmsg = strmsg + "<font color='red'><strong>[ 商户优惠券,网站简称,优惠券开始时间,优惠券结束时间,商品名称,商户名称，商户电话,团购电话 ]</strong></font>";
                break;
            case "orderpay":
                strmsg = strmsg + "<font color='red'><strong>[ 订单号,订单总金额,网站简称,用户名,购买数量,收货人,收货地址,联系电话,订单备注 ]</strong></font>";
                break;
            case "orderpartner":
                strmsg = strmsg + "<font color='red'><strong>[ 订单备注,订单号,商品名称,收货地址,联系电话,收货人,购买数量,网站简称 ]</strong></font>";
                break;
            case "delivery":
                strmsg = strmsg + "<font color='red'><strong>[ 订单号，快递单号，快递公司，网站简称，收货人姓名，用户名 ]</strong></font>";
                break;
            case "overtime":
                strmsg = strmsg + "<font color='red'><strong>[ 网站简称，优惠券号，到期时间，商品名称 ]</strong></font>";
                break;
            case "consumption":
                strmsg = strmsg + "<font color='red'><strong>[ 网站简称，券号，消费时间,用户名 ]</strong></font>";
                break;
            case "drawcode":
                strmsg = strmsg + "<font color='red'><strong>[ 网站简称,认证码，商品名称，用户名 ]</strong></font>";
                break;
            case "subscribe":
                strmsg = strmsg + "<font color='red'><strong>[ 网站简称,认证码 ]</strong></font>";
                break;
            case "qxsubscribe":
                strmsg = strmsg + "<font color='red'><strong>[ 网站简称,认证码 ]</strong></font>";
                break;
            case "inventory":
                strmsg = strmsg + "<font color='red'><strong>[ 项目编号 ]</strong></font>";
                break;
            case "nowteam":
                strmsg = strmsg + "<font color='red'><strong>[ 网站简称，商品名称 ]</strong></font>";
                break;
            case "usersign":
                strmsg = strmsg + "<font color='red'><strong>[ 网站简称, 手机号码, 绑定码 ]</strong></font>";
                break;
            case "orderteam":
                strmsg = strmsg + "<font color='red'><strong>[ 网站简称, 商品名称 ]</strong></font>";
                break;
            case "mobilecode":
                strmsg = strmsg + "<font color='red'><strong>[网站名称，认证码]</strong></font>";
                break;
            default:
                strmsg = strmsg + "";
                break;


        }
        strmsg = strmsg + "这些词的时候，请加上‘｛｝’，以便程序替换。";
        msg.Text = strmsg;


    }


    private void updatePage(string name)
    {
        if (name == "-1")
        {
            SetError("您没有选择项，请选择!");
        }
        else
        {
            ISmstemplate page = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {

                page = session.Smstemplate.GetByName(DropDownList1.SelectedItem.Value.ToString());

                page.value = pageContent.Value;
                int i = session.Smstemplate.Update(page);
                if (i > 0)
                {
                    SetSuccess("设置成功");
                }
                else
                {
                    SetSuccess("设置失败");
                }
            }
        }

    }


    protected void submit_Click1(object sender, EventArgs e)
    {
        if (DropDownList1.SelectedItem != null && div1.Visible == true)
        {
            updatePage(DropDownList1.SelectedItem.Value);
        }
        setPage();
        SetSuccess("设置成功");
        System.Web.HttpContext.Current.Cache.Remove("smstemplate");//清空缓存
        Response.Redirect("SheZhi_SmsTemplate.aspx");

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
                        <div class="box clear  ">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        短信模板编辑</h2>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>
                                            模板选择</label>
                                        <asp:DropDownList ID="DropDownList1" CssClass="f-input" Width="200px" runat="server" AutoPostBack="True"
                                            OnSelectedIndexChanged="DropDownList1_SelectedIndexChanged">
                                        </asp:DropDownList>
                                    </div>
                                    <div id="div1" runat="server">
                                        <div class="field">
                                            <label>
                                                模板编缉:</label><textarea id="pageContent" class="f-textarea" runat="server" cols="80"
                                                    name="S1" rows="20"></textarea>
                                        </div>
                                        <div class="field">
                                            <label>
                                                提示:</label>
                                            <asp:Literal ID="msg" runat="server"></asp:Literal>
                                        </div>
                                    </div>
                                    <div class="act">
                                        <asp:Button ID="save" runat="server" CssClass="formbutton" Text="保存" OnClick="submit_Click1" />
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