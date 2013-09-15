<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerBranchPage" %>


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
    public int partnerid = 0;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (CookieUtils.GetCookieValue("pbranch", key) == null || CookieUtils.GetCookieValue("pbranch", key) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=pbranch");
        }

        if (!Page.IsPostBack)
        {

            if (CookieUtils.GetCookieValue("pbranch", key) != null)
            {
                getContent(Helper.GetInt(CookieUtils.GetCookieValue("pbranch", key), 0));
            }
        }
    }

    //得到数据库的信息
    private void getContent(int id)
    {
        IBranch branch = Store.CreateBranch();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            branch = session.Branch.GetByID(id);
        }
        if (branch != null)
        {
            Hid.Value = id.ToString();
            Hpartnerid.Value = branch.partnerid.ToString();
            username.Value = branch.username;
            HidUsername.Value = branch.username;//用户名同时赋值给隐藏域
            branchname.Value = branch.branchname;
            //settingspwd.Value = branch.userpwd;
            //settingspasswordconfirm.Value = branch.userpwd;
            hfPwd.Value = branch.userpwd;
            secret.Value = branch.secret;
        }
    }
    protected void submit_ServerClick(object sender, EventArgs e)
    {

        IBranch mBr = Store.CreateBranch();
        mBr.id = Helper.GetInt(Hid.Value, 0);
        mBr.partnerid = Helper.GetInt(Hpartnerid.Value, 0);
        mBr.branchname = Helper.GetString(branchname.Value, string.Empty);
        mBr.secret = Helper.GetString(secret.Value, string.Empty);
        if (username.Value == HidUsername.Value)//判断是否修改过用户名（当前为未修改）
        {
            mBr.username = username.Value;
        }
        else
        {
            BranchFilter branchfilter = new BranchFilter();
            int count = 0;
            branchfilter.username = username.Value;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                count = session.Branch.GetCount(branchfilter);
            }
            if (count > 0)
            {
                SetError("已有此用户名");
                Response.Redirect(Request.Url.AbsoluteUri);
            }
            else
            {
                mBr.username = username.Value;
            }
        }

        if (settingspwd.Value == "")
        {
            mBr.userpwd = hfPwd.Value;
        }
        else
        {
            if (settingspwd.Value != settingspasswordconfirm.Value)
            {
                SetError("两次密码不一样！");
                Response.Redirect(Request.Url.AbsoluteUri);
            }
            else
            {
                mBr.userpwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(settingspwd.Value + PassWordKey, "md5");
            }
        }

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int result = session.Branch.Update(mBr);
        }
        SetSuccess("更新成功！");
        Response.Redirect(Request.Url.AbsoluteUri);
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    $(function () {
        $("#phone").blur(function (event) {
            var p = $("#phone").val();
            var k = p.split("-");
            if (p != "") {
                for (var i = 0; i < k.length; i++) {
                    if (k[i].match(/^(-|\+)?\d+$/) == null) {
                        //不是数字类型
                        $("#phone").attr("class", "f-input errorInput");
                        return false;
                    }
                    else {
                        $("#phone").attr("class", "f-input");

                    }
                }
            }
            else {
                $("#phone").attr("class", "f-input");
            }


        });
        $("#submit").click(function (event) {
            var p = $("#phone").val();
            var k = p.split("-");
            if (p != "") {
                for (var i = 0; i < k.length; i++) {
                    if (k[i].match(/^(-|\+)?\d+$/) == null) {
                        //不是数字类型
                        $("#phone").attr("class", "f-input errorInput");
                        return false;
                    }
                    else {
                        $("#phone").attr("class", "f-input");

                    }
                }
            }
            else {
                $("#phone").attr("class", "f-input");
            }

        });
    });

</script>
<body>
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
                                    <form id="form1" enctype="multipart/form-data" class="validator" runat="server">
                                    <div class="wholetip clear">
                                        <h3>
                                            1. 登陆信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            用户名</label>
                                        <input type="text" size="30" name="username" id="username" class="f-input" value=""
                                            group="a" require="true" datatype="require" runat="server" />
                                       
                                    </div>
                                    <div class="field">
                                        <label>
                                            新密码</label>
                                       <input type="password" size="30" name="password3" id="settingspwd" runat="server"
                                            class="f-input" />
                                        <span class="hint">如果不想修改密码，请保持空白</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            确认新密码</label>
                                        <input type="password" size="30" name="password2" id="settingspasswordconfirm" class="f-input"
                                            runat="server" />
                                    </div>
                                    <input type="hidden" size="30" name="Hid" id="Hid" class="f-input" value="" datatype="require"
                                        group="a" require="true" runat="server" />
                                    <input type="hidden" size="30" name="Hpartnerid" id="Hpartnerid" class="f-input"
                                        value="" datatype="require" group="a" require="true" runat="server" />
                                    <input type="hidden" size="30" name="branchname" id="branchname" class="f-input"
                                        group="a" require="true" datatype="require" runat="server" />
                                    <input type="hidden" size="30" name="secret" id="secret" class="f-input" value=""
                                        group="a" runat="server" />
                                         <input type="hidden" id="HidUsername" runat="server" />
                                    <div class="act">
                                        <input id="hdPartnerid" type="hidden" runat="server" />
                                        <input type="submit" value="编缉" name="commit" id="submit" class="formbutton validator"
                                            runat="server" group="a" onserverclick="submit_ServerClick" />
                                        <input type="hidden" id="hfPwd" runat="server" />
                                    </div>
                                    </form>
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
</body>
<%LoadUserControl("_footer.ascx", null); %>
