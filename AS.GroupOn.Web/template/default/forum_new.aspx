<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.Domain.Spi" %>
<script runat="server">
    protected bool falg = false;
    protected IList<ICategory> Categorylist = null;
    protected CategoryFilter filter = new CategoryFilter();
    protected IList<ICategory> catelist = null;
    protected CategoryFilter filter1 = new CategoryFilter();
    protected string Ename = "";
    protected string userid = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Form.Action = GetUrl("发表新话题", "forum_new.aspx");
        GetCategory();
        if (Request["ASNzY"] != null)
        {
            falg = true;
        }
        if (Request["commit"] == "成立")
        {
            NeedLogin();
            AddBBs();
        }
    }
    #region 查询讨论区的类别
    public void GetCategory()
    {
        if (CurrentCity != null)
        {
            Ename = AS.Common.Utils.Helper.GetString(CurrentCity.Ename, String.Empty);
        }
        filter.Ename = Ename;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            Categorylist = session.Category.GetList(filter);
        }
        filter1.Zone = "public";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catelist = session.Category.GetList(filter1);
        }
    }
    #endregion


    #region 讨论区添加帖子
    public void AddBBs()
    {
        ITopic topic = new Topic();
        topic.Public_id = AS.Common.Utils.Helper.GetInt(Request["category"], 0);
        topic.Title = AS.Common.Utils.Helper.GetString(Request["title"], String.Empty);
        topic.Content = AS.Common.Utils.Helper.GetString(Request["content"], String.Empty);
        topic.Parent_id = 0; //0代表帖子，大于0代表回复
        IUser user = null;
        UserFilter filte = new UserFilter();
        userid = AS.Common.Utils.CookieUtils.GetCookieValue("userid", AS.Common.Utils.FileUtils.GetKey());
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            user = session.Users.GetByID(AS.Common.Utils.Helper.GetInt(userid, 0));
        }
        if (user != null)
        {
            topic.User_id = user.Id;
            topic.Reply_number = 0;
            topic.View_number = 0;
            topic.create_time = DateTime.Now;
            topic.Last_time = DateTime.Now;
        }
        int topicid = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            topicid = session.Topic.Insert(topic);
        }
        if (topicid > 0)
        {
            SetSuccess("发表成功");
            Response.Redirect(GetUrl("城市讨论区", "forum_topic.aspx?id=" + topicid));
            Response.End();
        }

    }
    #endregion
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form1" runat="server">
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="forum">
            <div class="dashboard" id="dashboard">
                <ul>
                    <li class="current"><a href="<%=GetUrl("讨论区所有","forum_index.aspx")%>">
                        所有</a><span></span></li>
                    <li><a href="<%=GetUrl("讨论区城市", "forum_city.aspx")%>">
                        <%if (CurrentCity != null)
                          { %>
                        <%=CurrentCity.Name%>讨论区
                        <% }
                          else
                          {%>
                        全部城市讨论区
                        <% }%>
                    </a><span></span></li>
                    <li><a href="<%=GetUrl("公共讨论区", "forum_aspublic.aspx")%>">公共讨论区</a><span></span></li></ul>
            </div>
            <div id="content" class="coupons-box clear">
                <div class="box clear">
                    <div class="box-content">
                        <div class="head">
                            <h2>
                                发表新话题</h2>
                        </div>
                        <div class="sect">
                            <div class="field">
                                <label>
                                    讨论区</label>
                                <select name='category' style="margin-top: 3px;">
                                    <optgroup label="本地讨论区">
                                        <option value="0" selected="selected">全部城市讨论区</option>
                                        <%foreach (ICategory catemodel in Categorylist)
                                          { %>
                                        <option value="<%=catemodel.Id %>">
                                            <%=catemodel.Name%>讨论区</option>
                                        <% }%>
                                    </optgroup>
                                    <%if (falg)
                                      { %>
                                    <optgroup label="公共讨论区">
                                        <%foreach (ICategory catemodel in catelist)
                                          { %>
                                        <%if (Request["ASNzY"] == catemodel.Id.ToString())
                                          { %>
                                        <option value="<%=catemodel.Id %>" selected="selected">
                                            <%=catemodel.Name%>讨论区</option>
                                        <% }
                                          else
                                          {%>
                                        <option value="<%=catemodel.Id %>">
                                            <%=catemodel.Name%>讨论区</option>
                                        <% }%>
                                        <% }%>
                                        <%}
                                      else
                                      { %>
                                        <optgroup label="公共讨论区">
                                            <%foreach (ICategory catemodel in catelist)
                                              { %>
                                            <option value="<%=catemodel.Id %>">
                                                <%=catemodel.Name%>讨论区</option>
                                            <% }%>
                                            <% }%>
                                        </optgroup>
                                </select>
                            </div>
                            <div class="field">
                                <label>
                                    标题</label>
                                <input type="text" size="10" name="title" id="team-create-style" class="f-input"
                                    group="a" datatype="require" require="true" maxlength="50" />
                            </div>
                            <div class="field">
                                <label>
                                    内容</label>
                                <textarea style="width: 480px; height: 240px;" name="content" group="a" class="f-textarea"
                                    datatype="require" maxlen="500" require="true" lastvalue="">
                            </textarea>
                            </div>
                            <div class="act">
                                <input type="submit" value="成立" name="commit" id="leader-submit" group="a" class="formbutton validator" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="sidebar">
                <%LoadUserControl(WebRoot + "UserControls/blocksubscribe.ascx", null); %>
            </div>
        </div>
    </div>
</div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
