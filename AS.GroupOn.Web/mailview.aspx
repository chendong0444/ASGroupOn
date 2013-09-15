<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

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
    IMailtasks taskmodel = null;
    IMailtasks taskbll = null;
    IMailer mailmodel = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["taskid"] != null && Request["mailerid"] != null)
        {
            GetTaskid(Convert.ToInt32(Request["taskid"]), Request["mailerid"]);
        }
    }

    #region 根据传过来的taskid参数，修改mailtasks表中readcount已经阅读的数量，同时把传过来的参数mailerid赋给mailtasks表中readmailerid（已经阅读的）mailerid（同时用分隔符隔开，比如1,2,3）
    public void GetTaskid(int taskid, string mailid)
    {
        using (IDataSession session=Store.OpenSession(false))
        {
            taskmodel = session.Mailtasks.GetByID(taskid);
        }
        taskmodel.readcount = taskmodel.readcount + 1;//修改邮件任务的阅读数量
        using (IDataSession session = Store.OpenSession(false))
        {
            session.Mailtasks.Update(taskmodel);
            mailmodel =session.Mailers.GetByID(Convert.ToInt32(mailid));
        }
        //(2)	根据穿过来的参数taskid，赋给给mailer表中的sendmailids（同时用分隔符隔开，比如1,2,3）

        mailmodel.readcount = mailmodel.readcount + 1;
        using (IDataSession session = Store.OpenSession(false))
        {
            session.Mailers.Update(mailmodel);
        }
    }
    #endregion

    </script>
