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
    protected IList<IPage> pages = null;
    protected ISystem system = null;
    PageFilter pagefilter = new PageFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Page))
        {
            SetError("你不具有查看编辑网站页面的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (!IsPostBack)
        {
            setPage();

        }
    }
    SystemFilter systemfilter = new SystemFilter();
    private void setPage()
    {
        DropDownList1.Items.Clear();
        div1.Visible = false;
        ListItem li = new ListItem();
        li.Text = "-----";
        li.Value = "-1";
        DropDownList1.Items.Add(li);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pages = session.Page.GetList(pagefilter);

            foreach (IPage item in pages)
            {

                system = session.System.GetByID(1);
                ListItem li1 = new ListItem();
                if (item.Id == "help_tour")
                {
                    if (system != null)
                    {
                        li1.Text = "玩转" + system.abbreviation;
                    }
                    else
                    {
                        li1.Text = "玩转";
                    }
                    li1.Value = item.Id;

                }
                if (item.Id == "help_faqs")
                {
                    li1.Value = item.Id;
                    li1.Text = "常见问题";
                }
                if (item.Id == "help_asdht")
                {

                    if (system != null)
                    {
                        li1.Text = "什么是" + system.abbreviation;
                    }
                    else
                    {
                        li1.Text = "什么是";
                    }
                    li1.Value = item.Id;
                }
                if (item.Id == "help_api")
                {
                    li1.Value = item.Id;
                    li1.Text = "开发API";

                }
                if (item.Id == "about_contact")
                {
                    li1.Value = item.Id;
                    li1.Text = "联系方式";
                }
                if (item.Id == "about_job")
                {
                    li1.Value = item.Id;
                    li1.Text = "工作机会";
                }
                if (item.Id == "about_us")
                {
                    if (system != null)
                    {
                        li1.Text = "关于" + system.abbreviation;
                    }
                    else
                    {
                        li1.Text = "关于";
                    }
                    li1.Value = item.Id;

                }
                if (item.Id == "about_terms")
                {
                    li1.Value = item.Id;
                    li1.Text = "用户协议";
                }
                if (item.Id == "about_privacy")
                {
                    li1.Value = item.Id;
                    li1.Text = "隐私声明";
                }

                DropDownList1.Items.Add(li1);

            }

            DropDownList1.DataBind();
        }

    }

    protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e)
    {

        div1.Visible = true;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pages = session.Page.GetList(pagefilter);
            pagefilter.Id = DropDownList1.SelectedItem.Value;
            foreach (IPage item in session.Page.GetList(pagefilter))
            {
                pageContent.Value = item.Value;
            }
        }

    }


    private void updatePage(string id)
    {
        if (id == "-1")
        {
            SetError("您没有选择项，请选择!");
        }
        else
        {


            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                IPage page = null;
                page = session.Page.GetByID(DropDownList1.SelectedItem.Value.ToString());

                page.Value = pageContent.Value;
                int i = session.Page.Update(page);
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
                        <div class="box clear ">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        页面编辑</h2>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>
                                            页面选择</label>
                                        <asp:DropDownList ID="DropDownList1" CssClass="f-input" runat="server" Width="200px"
                                            AutoPostBack="True" OnSelectedIndexChanged="DropDownList1_SelectedIndexChanged">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="field">
                                        <div id="div1" runat="server">
                                            <label>
                                                页面编缉:</label><textarea id="pageContent" class="f-textarea xheditor {upImgUrl:'/upload.aspx?immediate=1',urlType:'abs',height:400}"
                                                    runat="server" cols="80" name="S1" rows="20"></textarea>
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