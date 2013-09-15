<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="ASDHTSMS.ASDHTSMSService" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected string html = String.Empty;
    protected int assmsuser = 0;
    protected string assmspoint = String.Empty;
    protected ISystem system = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_SMS_Charge)) 
        {
            SetError("你不具有短信充值的权限");
            Response.Redirect(WebRoot + "manage/index.aspx");
            Response.End();
            return;
        }
        string action = Helper.GetString(Request["action"], String.Empty);
        int id = Helper.GetInt(Request["id"], 0);
        string v = Helper.GetString(Request["v"], String.Empty);
        if ("smssend" == action)
        {
            string mobile = v;
            string content = Request["content"];
            List<string> phone = new List<string>();
            phone.Add(mobile);
            if (EmailMethod.SendSMS(phone, content))
            {
                Response.Write(JsonUtils.GetJson("call_succ()", "eval"));
            }
            else
            {
                Response.Write(JsonUtils.GetJson("call_fail('短信发送失败')", "eval"));
            }
        }
        if ("sms" == action)
        {
            string html = WebUtils.LoadPageString(WebRoot + "manage/manage_ajax_dialog_miscsms.aspx?v=" + v + "");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if ("SMS_rechargeable" == action)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_SMS_Charge))
            {
                Response.Write("<script type=\"text/javascript\">alert('你不具有短信充值的权限！');window.close();</" + "script>");
                return;
            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                system = session.System.GetByID(1);
            }
            if (system == null || system.smspass == null || system.smsuser == null)
            {
                Response.Write("<script type=\"text/javascript\">alert('请您先设置短信配置,然后进行充值');window.close();</" + "script>");
                return;
            }
            try
            {
                parametersOperate assms = new parametersOperate();
                html = assms.GetHtml(system.smsuser, system.smspass);
                if (system.smspass.Length > 0 && system.smsuser.Length > 0)
                {
                    assmsuser = assms.ASSMSUser(system.smsuser, system.smspass);
                    if (assmsuser == 2)
                    {
                        assmspoint = assms.SelectCredit(system.smsuser, system.smspass);
                        //Server.Transfer('http://sms.asdht.com/charge.aspx?user="+system.smsuser+"&pass="+system.smspass+');
                        Response.Redirect("http://sms.asdht.com/charge.aspx?user=" + system.smsuser + "&pass=" + system.smspass);
                    }
                    else
                    {
                        assmsuser = 1;
                        assmspoint = "您当前的账户还没有激活，不能正常使用。请与我们的客服联系";
                    }
                }
            }
            catch (Exception ex)
            {
                html = ex.Message;// "服务器访问失败";
            }
        }
    } 
</script>
