<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    
    private NameValueCollection _system = new NameValueCollection();
    public string sendname = "";
    public string mobile = "";
    public string address = "";
    public string remark = "";
    public string zipcode = "";
    public string danwei = "";
    public string tuosu = "";
    public string kefu = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_PrintTemplate_UserSend))
        {

            SetError("你不具有编辑发件人设置的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request["commit"] == "保存")
        {
            UpdateSend();
        }

        GetSend();


    }
    //显示发信人的信息
    public void GetSend()
    {
        _system = WebUtils.GetSystem();
        if (_system != null)
        {
            sendname = _system["sendname"];
            mobile = _system["mobile"];
            address = _system["address"];
            remark = _system["remark"];
            zipcode = _system["zipcode"];
            danwei = _system["danwei"];
            tuosu = _system["tuosu"];
            kefu = _system["kefu"];

        }

    }

    // 修改发信人的信息
    public void UpdateSend()
    {

        string txt = Request["sendname"];
        _system.Add("sendname", Request["sendname"]);//发信人姓名
        _system.Add("mobile", Request["mobile"]);//发信人手机
        _system.Add("address", Request["address"]);//发信人的地址
        _system.Add("zipcode", Request["zipcode"]);//发信人的邮政编码
        _system.Add("remark", Request["remark"]);//发信人的备注
        _system.Add("danwei", Request["danwei"]);//发信人的单位
        _system.Add("tuosu", Request["tuosu"]);//投诉电话
        _system.Add("kefu", Request["kefu"]);//客服电话

        WebUtils.CreateSystemByNameCollection1(_system);

        SetSuccess("友情提示：修改成功");

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
                                        发件人设置
                                    </h2>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>
                                            发信人姓名</label>
                                        <input type="text" size="30" name="sendname" id="sendname" class="f-input" value="<%=sendname %>" /><span
                                            class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            移动电话</label>
                                        <input type="text" name="mobile" maxlength="30" datatype="mobile" id="mobile" class="f-input"
                                            value="<%=mobile %>" /><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            地址</label>
                                        <input type="text" size="100" name="address" id="Text1" class="f-input" value="<%=address %>" /><span
                                            class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            单位</label>
                                        <input type="text" size="30" name="danwei" id="Text4" class="f-input" value="<%=danwei %>" /><span
                                            class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            客服电话</label>
                                        <input type="text" size="30" name="kefu" id="Text5" datatype="number" class="f-input"
                                            value="<%=kefu %>" />
                                        <span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            投诉电话</label>
                                        <input type="text" size="30" name="tuosu" id="Text6" datatype="number" class="f-input"
                                            value="<%=tuosu %>" /><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            邮政编码</label>
                                        <input type="text" size="30" name="zipcode" datatype="number" id="Text2" class="f-input"
                                            value="<%=zipcode %>" /><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            备注</label>
                                        <input type="text" size="30" name="remark" id="Text3" class="f-input" value="<%=remark %>" /><span
                                            class="inputtip"></span>
                                    </div>
                                    <div class="act">
                                        <input id="Submit1" type="submit" value="保存" name="commit" class="validator formbutton"
                                            onclick="return Submit1_onclick()" />
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
<% LoadUserControl("_footer.ascx", null); %>