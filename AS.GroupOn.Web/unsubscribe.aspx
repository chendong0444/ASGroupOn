<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        string code = Helper.GetString(Request["code"], String.Empty);
        if (code != String.Empty)
        {
            IList<IMailer> maillist = null;
            MailerFilter filter = new MailerFilter();
            filter.Secret = code;
            using (IDataSession session = Store.OpenSession(false))
            {
                maillist = session.Mailers.GetList(filter);
            }
            if (maillist != null && maillist.Count > 0)
            {
                using (IDataSession session=Store.OpenSession(false))
                {
                    session.Mailers.Delete(maillist[0].Id);
                }
            }
            SetSuccess("退订成功，您不会收到每日团购信息了");
            Response.Redirect("index.aspx");
            Response.End();
        }
    }  
</script>