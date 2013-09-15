<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    protected IPagers<ISales_promotion> pager = null;
    protected IList<ISales_promotion> iListSales_promotion = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_CXHD_List))
        {
            SetError("你不具有查看促销活动列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (Request["delId"] != null && Request["delId"].ToString() != "")
        {
            Del();
        }
        if (Request.QueryString["item"] != null && Request.QueryString["item"] != "")
        {
            BulkDel();//批量删除
        }
        InitData();
    }

    /// <summary>
    /// 绑定促销活动数据列表
    /// </summary>
    protected void InitData()
    {
        url = url + "&page={0}";
        url = "YingXiao_CuXiaoHuoDong.aspx?" + url.Substring(1);
        Sales_promotionFilter filter = new Sales_promotionFilter();
        filter.PageSize = 30;
        filter.AddSortOrder(Sales_promotionFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Sales_promotion.GetPager(filter);
        }
        iListSales_promotion = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
    /// <summary>
    /// 删除
    /// </summary>
    protected void Del()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_CXHD_Delete))
        {
            SetError("你不具有删除促销活动列表的权限！");
            Response.Redirect("YingXiao_CuXiaoHuoDong.aspx");
            Response.End();
            return;

        }
        else
        {
            int del_id = 0;
            int strid = Helper.GetInt(Request["delId"], 0);
            if (strid > 0)
            {
                Promotion_rulesFilter filter = new Promotion_rulesFilter();
                IList<IPromotion_rules> iListPromotionRules = null;
                filter.activtyid = strid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iListPromotionRules = session.Promotion_rules.GetList(filter);
                }
                if (iListPromotionRules != null)
                {
                    foreach (IPromotion_rules iprInfo in iListPromotionRules)
                    {
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int r = session.Promotion_rules.Delete(iprInfo.id); //删除活动规则
                        }
                    }

                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    del_id = session.Sales_promotion.Delete(strid);  //删除活动
                }
                if (del_id > 0)
                {
                    SetSuccess("删除成功");
                }
                Response.Redirect("YingXiao_CuXiaoHuoDong.aspx");
                Response.End();
                return;
            }
        }
    }
    /// <summary>
    /// 批量删除
    /// </summary>
    protected void BulkDel()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_CXHD_Delete))
        {
            SetError("你不具有删除促销活动列表的权限！");
            Response.Redirect("YingXiao_CuXiaoHuoDong.aspx");
            Response.End();
            return;
        }
        else
        {
            int del_id = 0;
            string items = Request.QueryString["item"];
            string[] item = items.Split(';');
            foreach (string ids in item)
            {
                int strid = Helper.GetInt(ids, 0);
                
                Promotion_rulesFilter filter = new Promotion_rulesFilter();
                IList<IPromotion_rules> iListPromotionRules = null;
                filter.activtyid = strid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iListPromotionRules = session.Promotion_rules.GetList(filter);
                }
                if (iListPromotionRules != null)
                {
                    foreach (IPromotion_rules iprInfo in iListPromotionRules)
                    {
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int r = session.Promotion_rules.Delete(iprInfo.id); //删除活动规则
                        }
                    }

                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    del_id = session.Sales_promotion.Delete(strid);  //删除活动
                }
                if (del_id > 0)
                {
                    SetSuccess("删除选中成功");
                }
                else
                {
                    SetError("删除选中失败！");
                }
            }
            Response.Redirect("YingXiao_CuXiaoHuoDong.aspx?page=" + Helper.GetInt(Request.QueryString["url"], 1));
        }
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
                                <div class="head" style="height:35px;">
                                    <h2>
                                        促销活动</h2>
                                    <ul class="filter">
                                        <li>
                                            <a href="Addcuxiaohuodong.aspx">添加促销活动</a>
                                        </li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='5%'>
                                                <input type='checkbox' id='checkall' name='checkall' /> 全选
                                            </th>
                                            <th width='5%'>
                                                ID
                                            </th>
                                            <th width='20%'>
                                                活动名称
                                            </th>
                                            <th width='5%'>
                                                发布状态
                                            </th>
                                            <th width='8%'>
                                                起始时间
                                            </th>
                                            <th width='8%'>
                                                结束时间
                                            </th>
                                            <th width='5%'>
                                                排序
                                            </th>
                                            <th width='29%'>
                                                详细描述
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListSales_promotion != null && iListSales_promotion.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (ISales_promotion isales_promotionInfo in iListSales_promotion)
                                              {
                                                  if (i % 2 != 0)
                                                  {
                                        %>
                                        <tr>
                                        <%
                                                  }
                                                  else
                                                  {
                                        %>
                                        <tr class='alt'>
                                        <%
                                                  }
                                            i++;
                                        %>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <input type='checkbox' id='check' name='check' value="<%=isales_promotionInfo.id%>" />
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=isales_promotionInfo.id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=isales_promotionInfo.name%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                   <% if (isales_promotionInfo.enable == 1)
                                                       { 
                                                    %>
                                                        是
                                                    <%
                                                        }
                                                       else
                                                       { 
                                                    %>
                                                        否
                                                    <%
                                                       }   
                                                    %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=isales_promotionInfo.start_time.ToShortDateString()%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=isales_promotionInfo.end_time.ToShortDateString()%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=isales_promotionInfo.sort%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=isales_promotionInfo.description%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <a href="YingXiao_CuXiaoHuoDong.aspx?delId=<%=isales_promotionInfo.id%>" ask="删除本条信息将会删除该信息下的所有促销规则，是否要删除此信息?">删除</a>|
                                                    <a href="Addcuxiaohuodong.aspx?updateId=<%=isales_promotionInfo.id%>">编辑</a>|
                                                    <a href="ajax_manage.aspx?action=cuxiaodetial&id=<%=isales_promotionInfo.id%>" class="ajaxlink">详情</a>|
                                                    <a href="YingXiao_CuXiaoGuiZe.aspx?salid=<%=isales_promotionInfo.id%> ">促销活动规则</a>
                                                </div>
                                            </td>
                                        </tr>
                                        <%       
                                            }
                                          } %>
                                        <tr>
                                            <td colspan="9">
                                                <input id="items" type="hidden" />
                                                <input value="删除选中" type="button" class="formbutton" style="padding: 1px 6px;" onClick='javascript:GetDeleteItem(<%= Helper.GetInt(Request.QueryString["page"], 1) %>);' />
                                                <%=pagerHtml %>
                                            </td>
                                        </tr>
                                    </table>
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

<script type="text/javascript">
    $(function () {

        $("#checkall").click(function () {
            $("input[id='check']").attr("checked", $("#checkall").attr("checked"));
        });
    })
    function GetDeleteItem(url) {
        var str = "";
        var urls = url;
        $("input[id='check']:checked").each(function () {
            str += $(this).val() + ";";
        });

        $("#items").val(str.substring(0, str.length - 1));

        if (str.length > 0) {
            var istrue = window.confirm("删除选中项将会删除该选中项下的所有促销规则，是否要删除选中信息？");
            if (istrue) {
                window.location = "YingXiao_CuXiaoHuoDong.aspx?item=" + $("#items").val() + "&url=" + urls;
            }
        }
        else {
            alert("你还没有选择删除项！ ");
        }
    }
</script>