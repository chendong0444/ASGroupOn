<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>

<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_SMSMany_Send))
        {
            SetError("你不具有短信群发的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["phones"] != null && Request.Form["content"] != null)
            {
                bool result = setPhone(Request.Form["phones"].ToString(), Request.Form["content"].ToString());
                if (result == true)
                {
                    SetSuccess("发送成功");
                }
                else
                {
                    SetError("发送失败");
                }
            }
        }
    }

    /// <summary>
    /// 短信发送方法
    /// </summary>
    /// <param name="telNumber">短信号码</param>
    /// <param name="telContent">短信内容</param>
    protected bool setPhone(string telNumber, string telContent)
    {
        List<string> lists = new List<string>();
        string[] s = telNumber.Split(',');
        for (int i = 0; i < s.Length; i++)
        {
            lists.Add(s[i]);
        }
        //EmailMethod emailmethod = new EmailMethod();
        return EmailMethod.SendSMS(lists, telContent);
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
                                <div class="head"><h2>短信群发</h2></div>
                                <div class="sect">                  
                                    <div class="field">
                                        <label>手机号码</label>
						                <div style="float:left;"><textarea cols="45" rows="5"  name="phones" class="f-textarea" datatype="require" require="true"></textarea></div>
						                <span class="hint">使用半角逗号隔开多个手机号码，一次最多发送300个手机号码</span>
                                    </div>
                                    <div class="field">
                                        <label>短信内容</label>
						                <div style="float:left;"><textarea id="sms-content-id" cols="45" rows="5" name="content" class="f-textarea"  datatype="require" require="true" onkeyup='X.misc.smscount();'></textarea></div>
						                <span class="hint">长度70个字以内，1个字母和1个汉字都认为是1个字，当前&nbsp;<span id="span-sms-length-id" style="color:red;font-weight:bold;font-size:14px;">0</span>&nbsp;字符，拆分为&nbsp;<span id="span-sms-split-id" style="color:red;font-weight:bold;font-size:14px;">0</span>&nbsp;条短信</span>
                                    </div>
                                    <div class="act">
                                        <input type="submit" value="发送" name="commit" group="a" class="formbutton validator"/>
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