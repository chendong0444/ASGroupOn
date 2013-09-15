<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    
    protected string sendemailerror = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_EmailGeneral_Send))
        {
            SetError("你不具有发送普通邮件的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }

        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["title"] != null && Request.Form["emails"] != null)
            {
                bool result = emailPay(Request.Form["emails"].ToString(), Request.Form["title"].ToString(), Request.Form["content"].ToString());
                if (result == true)
                {

                    SetSuccess("发送成功!");
                }
                else
                {
                    SetError("发送失败!" + sendemailerror);
                }
            }
        }
    }

    /// <summary>
    /// 邮件发送方法
    /// </summary>
    /// <param name="address">邮件地址</param>
    /// <param name="title">邮件标题</param>
    /// <param name="content">邮件内容</param>
    /// <returns></returns>
    private bool emailPay(string address, string title, string content)
    {

        if (address.IndexOf("\r\n") >= 0)
        {
            address = address.Replace("\r\n", ",");
        }
        string[] a = address.Split(',');
        List<string> sendAddress = new List<string>();
        for (int i = 0; i < a.Length; i++)
        {
            sendAddress.Add(a[i]);
        }
        //EmailMethod emailmethod = new EmailMethod();
        return EmailMethod.SendMail(sendAddress, title, content, out sendemailerror);
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
                                    <h2>邮件营销</h2>
					                <%--<ul class="filter">
                                        <li><a href="YingXiao_YoujianYingxiao.aspx">普通邮件</a><span></span></li>
                                        <li><a href="MailtasksList.aspx">群发邮件</a><span></span></li>
                                    </ul>--%>
                                </div>
                                <div class="sect">                   
					                <div class="field">
						                <label>邮件标题</label>
						                <input type="text" name="title" style="width:694px;"class="f-input" group="go" datatype="require" require="true"/>
					                </div>
					                <div class="field">
						                <label>收件邮箱</label>
						                <textarea name="emails"  style="width:700px;height:40px;" group="go" datatype="require" require="true"></textarea>
						                <span class="hint">收件人邮箱地址，使用半角空格逗号或换行隔开多个地址，建议在20个以内</span>
					                </div>
					                <div class="field">
						                <label>邮件内容</label>
						                <div style="float:left;"><textarea style="width:700px;height:450px;" group="go" datatype="require" class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1&t=2',urlType:'abs'}" name="content" require="true"></textarea></div>
					                </div>
                                    <div class="act">
                                        <input type="submit" group="go" value="发送" name="commit" class="formbutton validator"/>
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