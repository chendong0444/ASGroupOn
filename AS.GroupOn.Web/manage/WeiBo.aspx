<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
<%@ Import Namespace="NetDimension.Weibo.Interface" %>
<%@ Import Namespace="NetDimension.Weibo.Interface.Entity" %>
<%@ Import Namespace="NetDimension.Json" %>
<%@ Import Namespace="NetDimension.Json.Linq" %>
<%@ Import Namespace="NetDimension.Weibo.Entities" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="NetDimension.Weibo" %>




<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        //if (AdminPage.IsAdmin)//&& AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TJ_ProblemFeedBack)
        //{
        //    SetError("你没有权限！");
        //    Response.Redirect("index_index.aspx");
        //    Response.End();
        //    return;

        //}



        NetDimension.Weibo.OAuth oauth = new NetDimension.Weibo.OAuth("3865183130", "e19d5813236a8aea4132cf1135dacacc", "http://zzdtuan.com.cn/manage/weibo.aspx");

        string code = Request.QueryString["code"] ?? "";
        if (string.IsNullOrEmpty(code))
        {
            //第一步获取新浪授权页面的地址
            var authUrl = oauth.GetAuthorizeURL();

            Response.Redirect(authUrl);
        }
        else
        {
            var accessToken = oauth.GetAccessTokenByAuthorizationCode(code);
            if (!string.IsNullOrEmpty(accessToken.Token))
            {
                NetDimension.Weibo.Client Sina = new NetDimension.Weibo.Client(oauth);
                var uid = Sina.API.Account.GetUID(); //调用API中获取UID的方法
                var rateLimitStatus = Sina.API.Account.RateLimitStatus();

                var users = Sina.API.Friendships.Friends(uid, "",200, 0, false);
                Update(Sina, users.Users);


                int total = 200;
                while (true)
                {
                    int nextCursor = 0;
                    int.TryParse(users.NextCursor, out nextCursor);
                    users = Sina.API.Friendships.Friends(uid, "", 200, nextCursor, false);
                    Update(Sina, users.Users);

                    total += 200;
                    if (users.TotalNumber <= total)
                        break;
                }

            }
        }

    }

    private void Update(NetDimension.Weibo.Client Sina,IEnumerable<NetDimension.Weibo.Entities.user.Entity> users)
    {
        List<string> list = new List<string>();
        StringBuilder sb = new StringBuilder();
        foreach (var user in users)
        {
            sb.Append("@").Append(user.ScreenName);
            if (sb.Length > 100)        //微博内容不能超过140个文字
            {
                list.Add(sb.ToString());
                sb.Clear();
                break;
            }
        }

        foreach (string str in list)
        {
            Sina.API.Statuses.Update("如有兴趣帮我的团购网站做推广请留联系方式" + str);
            System.Threading.Thread.Sleep(300 * 1000);
        }
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head" style="height: 35px;">
                                    <h2>
                                        微博
                                    </h2>
                                </div>
                                <div class="sect">
                                    <div class="wholetip clear">
                                        <h3>
                                            发送成功</h3>
                                    </div>
                                    <asp:Literal ID="Literal1" runat="server"></asp:Literal>
<%--                                    <div class="wholetip clear">
                                        <h3>
                                            问题数据</h3>
                                    </div>
                                    <asp:Literal ID="Literal2" runat="server"></asp:Literal>
--%>                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
<%LoadUserControl("_footer.ascx", null); %>
