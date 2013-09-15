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
    protected string team_id = String.Empty;
    protected string[] kefumsn;
    protected string[] kefuqq;
    protected string sitename = String.Empty;
    protected int askcount = 0;
    protected IPagers<IAsk> pager = null;
    protected ITeam teammodel = null;
    protected AskFilter filter = new AskFilter();
    protected IList<IAsk> list_ask = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Init();
    }
    protected void Init()
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ASSystem = session.System.GetByID(1);
        }
        if (ASSystem != null)
        {
            if (!String.IsNullOrEmpty(ASSystem.kefumsn))
                kefumsn = ASSystem.kefumsn.Split(new char[] { ',' });
            if (!String.IsNullOrEmpty(ASSystem.kefuqq))
                kefuqq = ASSystem.kefuqq.Split(new char[] { ',' });
            sitename = ASSystem.sitename;
        }
    }

    public override void UpdateView()
    {
        Init();
    }
</script>
<div class="sbox side-vote-tip">
    <div class="sbox-content">
        <div class="r-top">
        </div>
        <div class="tip">
            <div class="text1">
                <p class="mark" style="margin-left: 15px;font-size: 14px;color:#000">
                    <%--客服热线:--%>
                    <%=ASSystem.tuanphone%></p>
                <p class="mark" style="margin-left: 15px;font-size: 14px;color:#000">
                    周一至周日<%=ASSystem.jobtime %></p>
            </div>
            <% if (kefuqq != null && kefuqq.Length>0){ %>
                <p class="link">
                    <%for (int i = 0; i < kefuqq.Length; i++)  {%>
                        <a target="_blank" href="http://wpa.qq.com/msgrd?v=3&uin=<%=kefuqq[i]%>&site=qq&menu=yes">
                        <img src="<%=ImagePath() %>button-custom-qq.gif" alt="" /></a>
                    <%}%>
<%--                    <%for (int i = 0; i < kefumsn.Length; i++)  {%>
                        <a target="_blank" href="msnim:chat?contact=<%=kefumsn[i]%>">
                        <img src="<%=ImagePath() %>button-custom-msn.gif" alt="" /></a>
                    <%}%>
--%>                </p>
            <%}%>
        </div>
        <div class="r-bottom">
        </div>
    </div>
</div>
