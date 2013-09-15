<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected string pagenum = "1";
    protected ITopic topicmodel = AS.GroupOn.App.Store.CreateTopic();
    protected int topic_id = 0;
    protected IPagers<ITopic> page = null;
    protected TopicFilter filter = new TopicFilter();
    protected IList<ITopic> topiclist = null;
    protected string PageHtml = String.Empty;
    protected IUser usermodel = null;
    protected IUser User_Model = AS.GroupOn.App.Store.CreateUser();
    private string levelname = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        //base.OnLoad(e);
        Form.Action = GetUrl("城市讨论区", "forum_topic.aspx");
        if (CurrentCity != null)
        {
            AS.GroupOn.Controls.PageValue.Title = CurrentCity.Name + "讨论区";
        }
        else
        {
            AS.GroupOn.Controls.PageValue.Title = "全部城市讨论区";
        }
        if (!IsPostBack && Request.QueryString["sta"]!="true") 
        {
            topic_id = AS.Common.Utils.Helper.GetInt(Request.QueryString["id"], 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int log_userid = AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("userid", AS.Common.Utils.FileUtils.GetKey()), 0);
                if (log_userid == 0)
                {
                    NeedLogin();
                }
                User_Model = session.Users.GetByID(log_userid);
            }
            ITopic tmodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
            {
                tmodel = session.Topic.GetByID(topic_id);
            }
            if (tmodel == null) 
            {
                Response.Redirect(GetUrl("讨论区所有", "forum_index.aspx"));
                Response.End();
                return;
            }
        }
        if (topic_id > 0)
        {
            //得到发帖的用户名
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                topicmodel = session.Topic.GetByID(topic_id);
            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                usermodel = session.Users.GetByID(topicmodel.User_id);
            }
            //修改帖子阅读数
            string sql = "update topic set View_number=View_number+1 where id= " + topic_id;
            List<Hashtable> table = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                table = session.GetData.GetDataList(sql.ToString());
            }
            //查询帖子下面回复的内容
            filter.Parent_id = topic_id;
            filter.PageSize = 30;
            filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
            filter.AddSortOrder(TopicFilter.Create_Time_ASC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                page = session.Topic.GetPager(filter);
            }
            if (page != null)
            {
                topiclist = page.Objects;
            }
            if (topiclist.Count > 30)
            {
                PageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, page.TotalRecords, page.CurrentPage, null);
            }


        }
        //对帖子置顶或取消置顶
        if (Request["type"] == "zhiding")
        {
            int id = AS.Common.Utils.Helper.GetInt(Request["id"], 0);
            TopicFilter topfilter = new TopicFilter();
            ITopic topicmodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                topicmodel = session.Topic.GetByID(id);
            }
            if (topicmodel.Head != 0)
            {
                topicmodel.Head = 0;
                int count = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    count = session.Topic.Update(topicmodel);
                }
                if (count > 0)
                {

                    SetSuccess("置顶已取消");
                }
            }
            else
            {
                int count = 0;
                topicmodel.Head = 1;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    count = session.Topic.Update(topicmodel);
                }
                if (count > 0)
                {
                    SetSuccess("话题已置顶");
                }
            }
        }
        //删除话题
        if (!string.IsNullOrEmpty(Request["remove"]))
        {
            int id = AS.Common.Utils.Helper.GetInt(Request["remove"], 0);
            //避免数据冗余，先删除回复，才能删除话题
            TopicFilter tfilter = new TopicFilter();
            IList<ITopic> t = null;
            tfilter.Parent_id = id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                t = session.Topic.GetList(tfilter);
            }
            if (t.Count > 0)
            {
                SetError("先删除回复才能删除话题");
                Response.Redirect(GetUrl("城市讨论区", "forum_topic.aspx?id=" + id));
                Response.End();
                return;
            }
            else
            {

                int count = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    count = session.Topic.Delete(id);
                }
                if (count > 0)
                {
                    SetSuccess("删除话题成功");
                    Response.Redirect(WebRoot + "template/default/forum_index.aspx");
                    Response.End();
                    return;
                }
                else
                {
                    SetError("删除话题失败");
                    Response.Redirect(WebRoot + "template/default/forum_index.aspx");
                    Response.End();
                    return;
                }
            }
        }
        //删除回复
        if (!string.IsNullOrEmpty(Request["del"]) && !string.IsNullOrEmpty(Request["partnerid"]))
        {
            int Partner_id = AS.Common.Utils.Helper.GetInt(Request["partnerid"], 0);
            int count = 0;
            int id = AS.Common.Utils.Helper.GetInt(Request["del"], 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                count = session.Topic.Delete(id);
            }
            if (count > 0)
            {
                SetSuccess("已刪除回复");
                Response.Redirect(GetUrl("城市讨论区", "forum_topic.aspx?id=" + Partner_id));
                Response.End();
                return;
            }
        }
        if (Request.HttpMethod == "POST")
        {
            ITopic topicmodel = null;
            int topid = AS.Common.Utils.Helper.GetInt(Request["tid"], 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                topicmodel = session.Topic.GetByID(topid);
            }
            if (topicmodel != null)
            {
                int log_userid = 0;
                topicmodel.Title = "";
                topicmodel.Parent_id = topid;
                topicmodel.Content = AS.Common.Utils.Helper.GetString(Request["content"], String.Empty);
                topicmodel.Last_time = DateTime.Now;
                topicmodel.create_time = DateTime.Now;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    log_userid = AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("userid", AS.Common.Utils.FileUtils.GetKey()), 0);
                    if (log_userid == 0)
                    {
                        NeedLogin();//登陆才能回复
                    }
                    User_Model = session.Users.GetByID(log_userid);
                }
                topicmodel.User_id = User_Model.Id;
                int tid = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    tid = session.Topic.Insert(topicmodel);
                }
                if (tid > 0)
                {
                    //修改帖子回复数
                    ITopic topmodel = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        topmodel = session.Topic.GetByID(topid);
                    }
                    topmodel.Reply_number = topmodel.Reply_number + 1;
                    topmodel.Last_time = DateTime.Now;
                    topmodel.Last_user_id = log_userid;
                    int count = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        count = session.Topic.Update(topmodel);
                    }
                    if (count > 0)
                    {
                        SetSuccess("回复成功");
                        Response.Redirect(GetUrl("城市讨论区", "forum_topic.aspx?id=" + topid));
                    }
                }
            }
        }
    }
    protected int TongCount(int i)
    {
        return (Convert.ToInt32(pagenum) - 1) * 30 + 1 + i;
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form1" runat="server" method="post">
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="forum">
        <input type="hidden" value="<%=topic_id %>" name="tid" id="tid" />
            <div class="dashboard" id="dashboard">
                <ul>
                    <li class="current"><a href="<%=GetUrl("讨论区所有","forum_index.aspx")%>">所有</a><span></span></li>
                    <li><a href="<%=GetUrl("讨论区城市", "forum_city.aspx")%>">
                        <%if (CurrentCity != null)
                          { %>
                         <%=CurrentCity.Name%>讨论区
                        <% }
                          else
                          {%>
                        公共讨论区
                        <% }%>
                    </a><span></span></li>
                    <li><a href="<%=GetUrl("公共讨论区", "forum_aspublic.aspx")%>">公共讨论区</a><span></span></li></ul>
            </div>
            <div id="content-old" class="coupons-box clear">
                <div class="box clear">
                    <div class="box-content">
                        <div class="head">
                            <h2>
                                <%=topicmodel.Title%></h2>
                            <ul class="filter" style="position: absolutely; bottom: 0px; clear: both; float: none;">
                                <li><a href="#reply">回复</a></li>
                                <%if (User_Model.Manager == "Y")
                                  { %>
                                <li><a href="<%=GetUrl("城市讨论区", "forum_topic.aspx?remove="+Request["id"]+"&sta=true")%>" ask="确定删除本话题吗？">
                                    删除</a></li><li><a href="<%=GetUrl("城市讨论区", "forum_topic.aspx?id="+Request["id"]+"&type=zhiding")%>">
                                        置顶</a></li>
                                <% }%>
                            </ul>
                        </div>
                        <div class="sect">
                            <table id="replies-list" cellspacing="0" width="98%" cellpadding="0" border="0" class="coupons-table">
                                <% if (topicmodel != null)
                                   { %>
                                <tr>
                                    <% 
                                        if (usermodel != null)
                                        {%>
                                    <td width="48" valign="top">
                                        <div class="avatar">
                                            <img src="<%=usermodel.Avatar %>" width="48" height="48" /></div>
                                    </td>
                                    <td width="660">
                                        <div class="author">
                                            <span style="float: right;">
                                                <%=topicmodel.create_time%>
                                                <%if (User_Model.Manager == "Y")
                                                  { %>
                                                &nbsp;<a href="<%=GetUrl("城市讨论区", "forum_topic.aspx?remove="+topicmodel.id+"&sta=true")%>" ask="确定删除本话题吗？">－删除</a>
                                                <% }%>

                                                <% 
                                            
                                                    if (usermodel.LeveName!=null&&usermodel.LeveName.Name!=null)
                                                    {
                                                        levelname = usermodel.LeveName.Name;
                                                    }
                                           %>
                                            </span><b>
                                                <%if (levelname != String.Empty) { Response.Write(levelname + ":"); }%>
                                                <%=usermodel.Username%></b><div class="clear">
                                                </div>
                                        </div>
                                        <div class="topic-content">
                                            <%=topicmodel.Content%>
                                        </div>
                                    </td>
                                    <% }%>
                                </tr>
                                <% }
                                   int i = 0;
                                %>
                                <%foreach (ITopic topmodel in topiclist)
                                  {
                                      IUser UseModel = null;
                                      using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                      {
                                          UseModel = session.Users.GetByID(topmodel.User_id);
                                      }
                                %>
                                <tr>
                                    <%if (UseModel != null)
                                      { %>
                                    <td width="48" valign="top">
                                        <div class="avatar">
                                            <img src="<%=UseModel.Avatar %>" width="48" height="48" /></div>
                                    </td>
                                    <td width="660">
                                        <div class="author">
                                            <span style="float: right;">
                                                <%=topmodel.create_time %>
                                                <%if (User_Model.Manager == "Y")
                                                  { %>
                                                &nbsp;<a href="<%=GetUrl("城市讨论区", "forum_topic.aspx?del="+topmodel.id+"&partnerid="+topmodel.Parent_id+"&sta=true")%>"
                                                    ask="确定删除回复吗？">－删除</a>
                                                <% }%>
                                            </span>
                                            <%=TongCount(i)%>楼 <b>
                                                <%=UseModel.Username%></b><div class="clear">
                                                </div>
                                        </div>
                                        <div class="topic-content">
                                            <%=topmodel.Content%>
                                        </div>
                                    </td>
                                    <% }%>
                                </tr>
                                <% i++;%>
                                <% }%>
                                <tr>
                                    <td colspan="2">
                                        <%=PageHtml%>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="head" id="reply">
                            <h2>
                                我要回复</h2>
                        </div>
                        <div class="sect consult-form">
                            <textarea style="width: 480px; height: 240px;" name="content" group="a" id="forum-new-content"
                                class="f-textarea" require="true" datatype="require">
                    
                    </textarea>
                            <p class="commit">
                                <input type="submit" value="发布" name="commit" group="a" id="leader-submit" class="formbutton validator" />
                            </p>
                            <%if (IsLogin == false)
                              { %>
                            请先<a href="<%= GetUrl("用户登录", "account_login.aspx")%>">登录</a>或<a href="<%=GetUrl("用户注册","account_loginandreg.aspx")%>">注册</a>再提问
                            <% }%>
                            <div class="clear">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <%--<div id="sidebar">
                <% LoadUserControl(WebRoot + "UserControls/blocksubscribe.ascx", null); %>
            </div>--%>
        </div>
    </div>
</div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
