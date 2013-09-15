<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">
    protected string value;
    protected List<Hashtable> dtb;
    public override void UpdateView()
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ASSystem = session.System.GetByID(1);
        }
        if (WebUtils.config["displayInvite_Top"] == "1")
        {
            string sql = "select Username,num from(select top 10 User_id,COUNT(*) as num from Invite group by User_id order by num desc)t inner join [user] on(t.user_id=[user].id)";
            using (IDataSession session = Store.OpenSession(false))
            {
                dtb = session.GetData.GetDataList(sql);
            }
        }
    }
    public override string CacheKey
    {
        get
        {
            return "cacheusercontrol-invitetop";
        }
    }
    public override bool CanCache
    {
        get
        {
            return true;
        }
    }
</script>
<%if (ASSystem.invitecredit > 0)
  {
      %>
<div class="sbox side-invite-tip">
    <div class="sbox-content">
        <div class="r-top">
        </div>
        <h3>
            邀请有奖
        </h3>
        <div class="tip">
            <p class="text">
                每邀请一位好友首次购买，您将获<strong><span class="money"><%=ASSystemArr["Currency"]%></span><%=ASSystemArr["invitecredit"]%></strong>元返利</p>
            <%if (CurrentTeam != null)
              { %>
            <p class="link">
                <a href="<%=GetUrl("邀请有奖","account_invite.aspx?id="+CurrentTeam.Id )%>">&raquo;&nbsp;点击获取您的专用邀请链接</a></p>
            <%} %>
        </div>
        <div class="r-bottom">
        </div>
    </div>
</div>
<%} %>
<%if (AS.Common.Utils.WebUtils.config["displayInvite_Top"] == "1")
  {%>
<div class="sbox side-invite-tip">
    <div class="sbox-content">
        <div class="r-top">
        </div>
        <h3>
            邀请排名
        </h3>
        <div class="tip">
            <div id="top_title" style="height: 30px;">
                <div class="top_title_left">
                    排名</div>
                <div class="top_title_center">
                    用户名</div>
                <div class="top_title_right_Top">
                    邀请数</div>
            </div>
            <% if (dtb != null && dtb.Count > 0)
               {
                   int j = 1; %>
            <div id="andyscroll">
                <div id="scrollmessage">
                    <% for (int i = 0; i < dtb.Count; i++)
                       {  %>
                    <a>
                        <div class="top_title_left">
                            第<%=j %>名</div>
                        <div class="top_title_center">
                            <%=AS.Common.Utils.StringUtils.SubString(dtb[i]["Username"].ToString(),4)%>****</div>
                        <div class="top_title_right_Button">
                            <%=dtb[i]["num"].ToString()%>人</div>
                    </a>
                    <% 
                        j++;
                       }%>
                </div>
            </div>
            <%}  %>
        </div>
        <div class="r-bottom">
        </div>
    </div>
</div>
<%} %>