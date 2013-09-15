<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<script runat="server">
    protected AS.GroupOn.Domain.ITeam t = null;
    protected NameValueCollection myteam = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        myteam = AS.Common.Utils.Helper.GetObjectProtery(t);
        
        
    }
    public void UpdateView(AS.GroupOn.Domain.ITeam team)
    {
        t = team;
        myteam = AS.Common.Utils.Helper.GetObjectProtery(team);
    }
    public override void UpdateView()
    {

        t = Params as AS.GroupOn.Domain.ITeam;
        if (t != null)
        {
            myteam = AS.Common.Utils.Helper.GetObjectProtery(t);
        }
    }
    public override string CacheKey
    {
        get
        {
            string key = "cacheusercontrol-blockshare";
            if (t != null)
                key = key + "-" + t.Id;
            return key;
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
<div id="deal-share">
    <%if (HttpContext.Current.Request.Url.AbsoluteUri.ToString().Contains("invite.aspx"))
      {%>
    <div class="deal-share-links">
        <h4>
            分享到：</h4>
        <ul class="cf">
            <li><a class="sina" href="<%=Share_sina(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                target="_blank">新浪微博</a></li><li><a class="qq" href="<%=Share_QQ(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                    target="_blank">腾讯微博</a></li><li><a class="renren" href="<%=Share_renren(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                        target="_blank">人人</a></li><li><a class="kaixin" href="<%=Share_kaixin(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                            target="_blank">开心</a></li><li><a class="douban" href="<%=Share_douban(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                                target="_blank">豆瓣</a></li><li><a class="email" href="<%=Share_mail(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                                    id="A2">邮件</a></li></ul>
    </div>
    <%}
      else
      {%>
    <div class="deal-share-top">
        <div class="deal-share-links">
            <h4>
                分享到：</h4>
            <ul class="cf">
                <li><a class="sina" href="<%=Share_sina(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                    target="_blank">新浪微博</a></li><li><a class="qq" href="<%=Share_QQ(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                        target="_blank">腾讯微博</a></li><li><a class="renren" href="<%=Share_renren(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                            target="_blank">人人</a></li><li><a class="kaixin" href="<%=Share_kaixin(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                                target="_blank">开心</a></li><li><a class="douban" href="<%=Share_douban(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                                    target="_blank">豆瓣</a></li><li><a class="im" href="javascript:void(0);" id="deal-share-im">
                                        MSN/QQ</a></li><li><a class="email" href="<%=Share_mail(t,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                                            id="A3">邮件</a></li></ul>
        </div>
    </div>
    <div class="deal-share-fix">
    </div>
    <%} %>
    <%string urlvalue = "";
      if (myteam["teamcata"] == "0")
          urlvalue = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + getTeamPageUrl(int.Parse(myteam["id"].ToString())) + "&r=" + ASUserArr["id"];
      else
          urlvalue = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + getTeamPageUrl(int.Parse(myteam["id"].ToString())) + "&r=" + ASUserArr["id"];   
    %>
    <div id="deal-share-im-c">
        <div class="deal-share-im-b">
            <h3>
                复制下面的内容后通过 MSN 或 QQ 发送给好友：</h3>
            <p>
                <input id="share-copy-text" type="text" value="<%=urlvalue%>" size="30" class="f-input"
                    tip="复制成功，请粘贴到你的MSN或QQ上推荐给您的好友" />
                <input id="share-copy-button" type="button" value="复制" class="formbutton" /></p>
        </div>
    </div>
    <div class="clear">
    </div>
</div> 
