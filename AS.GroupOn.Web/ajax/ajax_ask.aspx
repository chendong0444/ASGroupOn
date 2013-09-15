<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        NeedLogin();
        if (!string.IsNullOrEmpty(Request.Params["action"]))
        {
            string action = Helper.GetString(Request.Params["action"], String.Empty);
            int userid = Helper.GetInt(Request.Params["askuserid"], 0);
            int teamid = Helper.GetInt(Request.Params["teamid"], 0);
            int cityid = Helper.GetInt(Request.Params["cityid"], 0);
            string content = Helper.GetString(Request.Params["content"], String.Empty);
            if (action == "askproblem")
            {
                string error = String.Empty;
                if (content.Trim().Length > 0)
                {
                    IUser user = null;
                    ITeam team = null;
                    IAsk ask = Store.CreateAsk();
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        user = session.Users.GetByID(userid);
                    }
                    if (user == null)
                        error = "非法提交信息";
                    else
                    {
                        using (IDataSession session = Store.OpenSession(false))
                        {
                            team = session.Teams.GetByID(teamid);
                        }
                        if (team == null)
                            error = "不存在此项目";
                        else
                        {
                            ask.Team_id = teamid;
                            ask.City_id = cityid;
                            ask.Content = content;
                            ask.User_id = userid;
                            ask.Create_time = DateTime.Now;
                            int i = 0;
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                i = session.Ask.Insert(ask);
                            }
                            if (i > 0) error = "您的问题已成功提交，客服很快就会回复的，稍等一会儿再来看吧。";
                        }
                    }
                }
                else
                {
                    error = "咨询内容不能为空";
                }
                Response.Clear();
                Response.Write(error);
                Response.End();
            }
        }
    }
</script>
