<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.SalePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    int strSaleId = 0;
    protected ISales sale = Store.CreateSales();
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        strSaleId = Helper.GetInt(CookieUtils.GetCookieValue("sale", key).ToString(), 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            sale = session.Sales.GetByID(strSaleId);
        }


        if (!IsPostBack)
        {
            initPage();
        }
    }
    private void initPage()
    {
        if (CookieUtils.GetCookieValue("sale", key) == null || CookieUtils.GetCookieValue("sale", key) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=sale");
            return;
        }
        else
        {
            if (sale != null)
            {
                username.Value = sale.username;
                realname.Value = sale.realname;
                telphone.Value = sale.contact;
            }
        }
    }
    /// <summary>
    /// 更新销售人员 
    /// </summary>
    private void UpdateUser()
    {
        ISales msale = Store.CreateSales();
        ISales a = Store.CreateSales();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            a = session.Sales.GetByID(strSaleId);
        }

        UserNameLength();
        msale.id = strSaleId;
        msale.username = username.Value;
        msale.realname = realname.Value;
        if (password.Value == "")//如果不想修改密码，密码保持空白
        {
            msale.password = a.password;
        }
        else
        {
            msale.password = password.Value;
        }
        msale.contact = telphone.Value;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int upresult = session.Sales.Update(msale);
        }
        SetSuccess("编辑用户信息成功");
        Response.Redirect(Request.UrlReferrer.AbsoluteUri);

        Response.End();
    }

    private void UserNameLength()
    {
        //判断用户名长度
        int lenth = System.Text.Encoding.Default.GetByteCount(username.Value);
        if (lenth < 4 || lenth > 16)
        {
            SetError("用户名长度为4-16个字符，一个汉字为两个字符！");
            Response.Redirect(Request.UrlReferrer.AbsoluteUri);
            Response.End();
            return;
        }
    }
    protected void submit_ServerClick(object sender, EventArgs e)
    {
        UpdateUser();
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server" method="post">
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
                                        销售人员资料</h2>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>
                                            用户名</label>
                                        <input type="text" size="30" name="username" group="a" require="true" datatype="require"
                                            maxlength="500" id="username" class="f-input" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            真实姓名</label>
                                        <input type="text" size="30" name="realname" id="realname" class="f-input" value=""
                                            runat="server" />
                                    </div>
                                    <input type="hidden" size="30" name="password" id="password" class="f-input" runat="server" />
                                    <div class="field">
                                        <label>
                                            联系电话</label>
                                        <input type="text" size="30" name="telphone" id="telphone" class="f-input" runat="server" />
                                    </div>
                                    <div class="act">
                                        <input type="submit" value="编辑" group="a" name="commit" id="salesubmit" class="formbutton validator"
                                            runat="server" onserverclick="submit_ServerClick" />
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
<script type="text/javascript">
    $(function () {
        $("#telphone").blur(function (event) {
            var p = $("#telphone").val();
            var k = p.split("-");
            if (p != "") {
                for (var i = 0; i < k.length; i++) {
                    if (k[i].match(/^(-|\+)?\d+$/) == null) {
                        //不是数字类型
                        $("#telphone").attr("class", "f-input errorInput");
                        return false;
                    }
                    else {
                        $("#telphone").attr("class", "f-input");
                    }
                }
            }
            else {
                $("#telphone").attr("class", "f-input");
            }
        });

        $("#username").blur(function (event) {
            var p = $("#username").val();
            if (p == "") {
                $("#username").attr("class", "f-input errorInput");
            }
            else {
                $("#username").attr("class", "f-input");
            }
        });

        $("#salesubmit").click(function (event) {
            var p = $("#telphone").val();
            var k = p.split("-");
            if (p != "") {
                for (var i = 0; i < k.length; i++) {
                    if (k[i].match(/^(-|\+)?\d+$/) == null) {
                        //不是数字类型
                        $("#telphone").attr("class", "f-input errorInput");
                        return false;
                    }
                    else {
                        $("#telphone").attr("class", "f-input");
                    }
                }
            }
            else {
                $("#telphone").attr("class", "f-input");
            }

        });
    });
</script>
<%LoadUserControl("_footer.ascx", null); %>
