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
        string strPartnerID = CookieUtils.GetCookieValue("partner", key).ToString();

        IPartner mpartner = Store.CreatePartner();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            mpartner = session.Partners.GetByID(Helper.GetInt(strPartnerID, 0));
        }
        if (mpartner != null)
        {

            partnercreateusername.Value = mpartner.Username;
            partnercreatetitle.Value = mpartner.Title;
            partnercreatehomepage.Value = mpartner.Homepage;
            partnercreatecontact.Value = mpartner.Contact;
            partnercreateaddress.Value = mpartner.Address;
            partnercreatephone.Value = mpartner.Phone;
            partnercreatemobile.Value = mpartner.Mobile;
            partnercreatelocation.Value = mpartner.Location;
            partnercreateother.Value = mpartner.Other;
            partnercreatebankname.Value = mpartner.Bank_name;
            partnercreatebankuser.Value = mpartner.Bank_user;
            partnercreatebankno.Value = mpartner.Bank_no;
            hfPwd.Value = mpartner.Password;
            verifymobile.Value = mpartner.verifymobile;
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
                Response.Redirect("settings.aspx");
            }

            mpartner.Title = partnercreatetitle.Value;
            mpartner.Homepage = partnercreatehomepage.Value;
            mpartner.Contact = partnercreatecontact.Value;
            mpartner.Address = partnercreateaddress.Value;
            mpartner.Phone = partnercreatephone.Value;
            mpartner.Mobile = partnercreatemobile.Value;
            mpartner.Location = partnercreatelocation.Value;
            mpartner.Other = partnercreateother.Value;
            mpartner.Bank_name = partnercreatebankname.Value;
            mpartner.Bank_user = partnercreatebankuser.Value;
            mpartner.Bank_no = partnercreatebankno.Value;
            mpartner.verifymobile = verifymobile.Value;
            mpartner.Id =Helper.GetInt(id.Value,0) ;

            int result = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                result = session.Partners.Update(mpartner);
            }
            
            if (result > 0)
            {
                SetSuccess("修改信息成功！");
                Response.Redirect("PartnerInfo.aspx");
            }
            else
            {
                SetSuccess("修改信息失败！");
                Response.Redirect("PartnerInfo.aspx");
            }
        }
        else
        {
            Response.Redirect(GetUrl("后台管理", "Login.aspx?type=merchant"));
            Response.End();
        }
    }
</script>
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
                                        商家信息</h2>
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
                                   
                                    <div class="wholetip clear">
                                        <h3>
                                            2、基本设置</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户名称</label>
                                        <input type="text" size="30" name="title" id="partnercreatetitle" class="f-input"
                                            runat="server" datatype="require" require="ture" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            网站地址</label>
                                        <input type="text" size="30" name="homepage" id="partnercreatehomepage" runat="server"
                                            class="f-input" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            联系人</label>
                                        <input type="text" size="30" name="contact" id="partnercreatecontact" runat="server"
                                            class="f-input" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            商家地址</label>
                                        <input type="text" size="30" name="address" id="partnercreateaddress" runat="server"
                                            class="f-input" value="" datatype="require" require="ture" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            联系电话</label>
                                        <input type="text" size="30" name="phone" id="partnercreatephone" runat="server"
                                            class="f-input" value="" maxlength="12" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            手机号码</label>
                                        <input type="text" size="30" name="mobile" id="partnercreatemobile" group="a" datatype="mobile"
                                            runat="server" class="f-input" value="" maxlength="11" />
                                    </div>
                                          <div class="field">
                                        <label>
                                            400验证电话</label>
                                             <input type="text" size="30" name="verifymobile" id="verifymobile" class="f-input" value="" runat="server" />
                                     
                                    </div>
                                    <div class="field">
                                        <label>
                                            位置信息</label>
                                        <div style="float: left;">
                                            <textarea cols="45" rows="5" name="location" id="partnercreatelocation" runat="server"
                                                class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"></textarea></div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            其他信息</label>
                                        <div style="float: left;">
                                            <textarea cols="45" rows="5" name="other" id="partnercreateother" runat="server"
                                                class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"></textarea></div>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            3、银行信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            开户行</label>
                                        <input type="text" size="30" name="bank_name" id="partnercreatebankname" runat="server"
                                            class="f-input" value="" readonly />
                                    </div>
                                    <div class="field">
                                        <label>
                                            开户名</label>
                                        <input type="text" size="30" name="bank_user" id="partnercreatebankuser" runat="server"
                                            class="f-input" value="" readonly />
                                    </div>
                                    <div class="field">
                                        <label>
                                            银行账户</label>
                                        <input type="text" size="30" name="bank_no" id="partnercreatebankno" runat="server"
                                            class="f-input" value="" readonly />
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