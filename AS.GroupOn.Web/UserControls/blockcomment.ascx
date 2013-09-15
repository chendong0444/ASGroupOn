<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
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
    public bool value = false;
    protected List<Hashtable> hs = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Init();
    }
    protected void Init()
    {
        if (WebUtils.config["navUserreview"] == "1")
        {
            this.Visible = true;
            string sql = "select team.Id,username,Title,Image,comment,t1.create_time from (select userreview.Id,userreview.state, user_id,team_id,username,userreview.create_time,comment  from userreview left join [User] on  userreview.user_id=[User].Id)t1 left join team on t1.team_id=team.Id where t1.state=1 and t1.state!=2 and teamcata=0  order by create_time desc";
            using (IDataSession session = Store.OpenSession(false))
            {
                hs = session.GetData.GetDataList(sql);
            }
            if (hs.Count > 0) value = true;
        }
        else
        {
            this.Visible = false;
        }
    }
    public override void UpdateView()
    {
        base.UpdateView();
        Init();
    }
    public override string CacheKey
    {
        get
        {
            return "cacheusercontrol-commentview";
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
<div class="buyer_say">
    <div class="r-top">
    </div>
    <h3>
        买家这样说</h3>
    <div id="scrollsay_nr">
        <div class="scroll_box" id="scroll_box">
            <% if (hs != null && hs.Count > 0)
               {
                   value = true;
            %>
            <% for (int i = 0; i < hs.Count; i++)
               {
            %>
            <div class="scroll_content">
                <%=hs[i]["username"]%>评论了TA在<%=ASSystem.abbreviation%>买到的<%if (hs[i]["Title"].ToString().Length > 10)
                                                                        {%><a href="<%=getTeamPageUrl(int.Parse(hs[i]["Id"].ToString())) %>"><%=hs[i]["Title"].ToString().Substring(0, 10)%></a>
                <%}
                                                                        else
                                                                        {%><a href="<%=getTeamPageUrl(int.Parse(hs[i]["Id"].ToString()))%>"><%=hs[i]["Title"].ToString()%></a>
                <%} %><br />
                <p class="quote">
                    <% if (hs[i]["comment"].ToString().Length > 20)
                       {%><%=hs[i]["comment"].ToString().Substring(0, 20)%>
                    <%}
                       else
                       {%><%=hs[i]["comment"].ToString()%>
                    <%} %></p>
            </div>
            <%} %>
            <%}
               else
               {%><div class="scroll_content">
                   <p class="quote">
                       暂无评论</p>
               </div>
            <%} %>
        </div>
    </div>
    <div class="ck_more">
        <a target="_blank" href="<%=GetUrl("到货评价","buy_list_comments.aspx")%>">去看看更多买家评论</a></div>
    <div class="r-bottom">
    </div>
</div>
<% if (value)
   {%>
<script type="text/javascript">
    $(document).ready(function () {
        var obj = $('#scroll_box');
        var per_move = 110;
        var num = obj.find('.scroll_content').length;
        var i = 1;
        obj.everyTime(5000, 'scroll_box', function () {

            obj.animate({ top: '-' + per_move * i }, 'fast');

            if (i == num) {
                i = 1;
            } else {
                i++;
            }
        });
    });
</script>
<%} %>
