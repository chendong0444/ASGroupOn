<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


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
    protected IPagers<IRole> pager = null;
    protected IList<IRole> iListRole = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_UserData_Polymerization))
        {
            SetError("你不具有查看全局缓存的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        IOrder order = Store.CreateOrder();

        if (Request["buttontype"] == "用户消费总额聚合")
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int i = session.Orders.UpdateTotalamount(order);
            }
            SetSuccess("友情提示：执行成功");

        }
    }
    protected void Totalamount(object sender, EventArgs e)
    {
        IOrder order = Store.CreateOrder();

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int i = session.Orders.UpdateTotalamount(order);
        }
        SetSuccess("友情提示：用户消费总额聚合成功");
        Response.Redirect("Tongji_ASdht_sum.aspx");

    }

    protected void ClearCache(object sender, EventArgs e)
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_PageCache_Clear))
        {
            SetError("你不具有清除页面缓存的权限！");
            Response.Redirect("Tongji_ASdht_sum.aspx");
            Response.End();
            return;

        }
        AS.Common.Utils.CacheUtils.ClearPageCache();
        SetSuccess("友情提示：清除缓存成功");
        Response.Redirect("Tongji_ASdht_sum.aspx");
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        全局缓存</h2>
                                    <br />
                                </div>
                                <div class="sect">
                                    用户消费总额：<input id="Submit1" type="submit" value="聚合" name="commit" runat="server"
                                        onserverclick="Totalamount" class="validator formbutton" group="g" />
                                    <br />
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;页面缓存：<input id="Submit2" type="submit"
                                        value="清除" name="commit" runat="server" onserverclick="ClearCache" class="validator formbutton"
                                        group="g" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>