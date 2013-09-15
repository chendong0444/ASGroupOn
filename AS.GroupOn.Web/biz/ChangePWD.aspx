<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>


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
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!Page.IsPostBack)
        {
            initPage();
        }
    }

    private void initPage()
    {
        if (CookieUtils.GetCookieValue("partner", key) == null || CookieUtils.GetCookieValue("partner", key) == "")
        {
            Response.Redirect(GetUrl("后台管理", "Login.aspx?type=merchant"));
            Response.End();
        }
        string strPartnerID = CookieUtils.GetCookieValue("partner", key).ToString();

        IPartner mpartner = Store.CreatePartner();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            mpartner = session.Partners.GetByID(Helper.GetInt(strPartnerID, 0));
        }
        if (mpartner != null)
        {

            partnercreateusername.Value = mpartner.Username;
            settingspassword.Value = mpartner.Password;
            settingspasswordconfirm.Value = mpartner.Password;
            hfPwd.Value = mpartner.Password;
            id.Value = mpartner.Id.ToString();
        }
    }



    public void submit_ServerClick(object sender, EventArgs e)
    {
        IPartner mpartner = Store.CreatePartner();
        if (CookieUtils.GetCookieValue("partner", key) != null && CookieUtils.GetCookieValue("partner", key) != "")
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mpartner = session.Partners.GetByID(Helper.GetInt(CookieUtils.GetCookieValue("partner", key).ToString(), 0));
            }
            if (settingspassword.Value == "")
            {
                mpartner.Password = hfPwd.Value;
            }
            else
            {
                if (settingspassword.Value != settingspasswordconfirm.Value)
                {
                    SetError("两次密码不一样！");
                    Response.Redirect("ChangePWD.aspx");
                }
                else
                {
                    mpartner.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(settingspassword.Value + PassWordKey, "md5");
                }
            }
            if (true)
            {

            }
            if (partnercreateusername.Value != "")
            {
                int nameResult = 0;
                PartnerFilter partfilter = new PartnerFilter();
                partfilter.NotId = Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0);
                partfilter.Username = Helper.GetString(partnercreateusername.Value, String.Empty);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    nameResult = session.Partners.GetCount(partfilter);
                }
                
                
                if (nameResult>0)
                {
                    //说明除了此用户外其他用户也有这个用户名
                    SetError("用户名已存在,请重新输入！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                    return;
                }
                mpartner.Username = partnercreateusername.Value;
            }
            else
            {
                SetError("商户用户名不能为空！");
                Response.Redirect("ChangePWD.aspx");
            }
            mpartner.Id =Helper.GetInt(id.Value,0) ;

            int result = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                result = session.Partners.Update(mpartner);
            }
            
            if (result > 0)
            {
                SetSuccess("修改信息成功！");
                Response.Redirect("ChangePWD.aspx");
            }
            else
            {
                SetSuccess("修改信息失败！");
                Response.Redirect("ChangePWD.aspx");
            }
        }
        else
        {
            Response.Redirect(WebRoot + "login.aspx?action=merchant");
        }
    }
</script>
<script src="../upfile/js/index.js" type="text/javascript"></script>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    $(function () {
        $("#partnercreatephone").blur(function (event) {
            var p = $("#partnercreatephone").val();
            var k = p.split("-");
            if (p != "") {
                for (var i = 0; i < k.length; i++) {
                    if (k[i].match(/^(-|\+)?\d+$/) == null) {
                        //不是数字类型
                        $("#partnercreatephone").attr("class", "f-input errorInput");
                        return false;
                    }
                    else {
                        $("#partnercreatephone").attr("class", "f-input");

                    }
                }
            }
            else {
                $("#partnercreatephone").attr("class", "f-input");
            }


        });
        $("#partnersubmit").click(function (event) {
            var p = $("#partnercreatephone").val();
            var k = p.split("-");
            if (p != "") {
                for (var i = 0; i < k.length; i++) {
                    if (k[i].match(/^(-|\+)?\d+$/) == null) {
                        //不是数字类型
                        $("#partnercreatephone").attr("class", "f-input errorInput");
                        return false;
                    }
                    else {
                        $("#partnercreatephone").attr("class", "f-input");

                    }
                }
            }
            else {
                $("#partnercreatephone").attr("class", "f-input");
            }

        });
    });

</script>
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
                                        修改密码</h2>
                                </div>
                                <div class="sect">
                                    <div class="wholetip clear">
                                        <h3>
                                            1、登录信息</h3>
                                    </div>
                                    <div class="field">
                                    <input type="hidden" id="id" name="id" runat="server" />
                                        <label>
                                            用户名</label>
                                        <input type="text" size="30" name="username" id="partnercreateusername" class="f-input"
                                            runat="server" readonly />
                                    </div>
                                    <div class="field password">
                                        <label>
                                            新密码</label>
                                        <input type="password" size="30" name="password" id="settingspassword" runat="server"
                                            class="f-input" />
                                        <span class="hint">如果不想修改密码，请保持空白</span>
                                    </div>
                                    <div class="field password">
                                        <label>
                                            确认新密码</label>
                                        <input type="password" size="30" name="password2" id="settingspasswordconfirm" class="f-input"
                                            runat="server" />
                                    </div>
                                
                                    <div class="act">
                                        <input type="submit" value="编辑" name="commit" id="partnersubmit" group="a" runat="server"
                                            class="formbutton validator" onserverclick="submit_ServerClick" />
                                        <input type="hidden" id="hfPwd" runat="server" />
                                    </div>
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