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
    protected IPagers<IPromotion_rules> pager = null;
    protected IList<IPromotion_rules> iListPromotion_rules = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected int strSalid = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_CXHD_RuleList))
        {
            SetError("你不具有查看促销活动规则列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        strSalid = Helper.GetInt(Request["salid"], 0);
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
        url = "YingXiao_CuXiaoGuiZe.aspx?" + url.Substring(1);
        Promotion_rulesFilter filter = new Promotion_rulesFilter();
        filter.activtyid = Helper.GetInt(Request["salid"], 0);
        filter.PageSize = 30;
        filter.AddSortOrder(Promotion_rulesFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Promotion_rules.GetPager(filter);
        }
        iListPromotion_rules = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
    /// <summary>
    /// 删除
    /// </summary>
    protected void Del()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_CXHD_RuleDelete))
        {
            SetError("你不具有删除促销活动规则信息的权限！");
            Response.Redirect("YingXiao_CuXiaoGuiZe.aspx");
            Response.End();
            return;
        }
        else
        {
            int strid = Helper.GetInt(Request["delId"], 0);
            if (strid > 0)
            {
                int del_id = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    del_id = session.Promotion_rules.Delete(strid);
                }
                if (del_id > 0)
                {
                    SetSuccess("删除成功");
                }
                Response.Redirect("YingXiao_CuXiaoGuiZe.aspx?salid=" + strSalid);
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
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_CXHD_RuleDelete))
        {
            SetError("你不具有删除促销活动规则信息的权限！");
            Response.Redirect("YingXiao_CuXiaoGuiZe.aspx");
            Response.End();
            return;
        }
        else
        {
            string items = Request.QueryString["item"];
            string[] item = items.Split(';');
            foreach (string ids in item)
            {
                int strid = Helper.GetInt(ids, 0);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int i = 0;
                    i = session.Promotion_rules.Delete(strid);
                    if (i > 0)
                    {
                        SetSuccess("删除选中成功！");
                    }
                    else
                    {
                        SetError("删除选中失败！");
                    }
                }
            }
            Response.Redirect("YingXiao_CuXiaoGuiZe.aspx?page=" + Helper.GetInt(Request.QueryString["url"], 1) + "&salid=" + strSalid);
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
                                    
                                </div><ul class="filter">
                                        <li>
                                            <a href="Addcuxiaoguize.aspx?salid=<%=strSalid %>">添加促销规则</a>
                                        </li>
                                    </ul>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='5%'>
                                                <input type='checkbox' id='checkall' name='checkall' /> 全选
                                            </th>
                                            <th width='8%'>
                                                ID
                                            </th>
                                            <th width='12%'>
                                                起始时间
                                            </th>
                                            <th width='12%'>
                                                结束时间
                                            </th>
                                            <th width='12%'>
                                                是否启用
                                            </th>
                                            <th width='5%'>
                                                排序
                                            </th>
                                            <th width='31%'>
                                                规则描述
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListPromotion_rules != null && iListPromotion_rules.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (IPromotion_rules ipromotionrulesInfo in iListPromotion_rules)
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
                                                    <input type='checkbox' id='check' name='check' value="<%=ipromotionrulesInfo.id%>" />
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=ipromotionrulesInfo.id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=ipromotionrulesInfo.start_time.ToShortDateString()%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=ipromotionrulesInfo.end_time.ToShortDateString()%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                   <% if (ipromotionrulesInfo.enable == 1)
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
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=ipromotionrulesInfo.sort %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=ipromotionrulesInfo.rule_description %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <a href="YingXiao_CuXiaoGuiZe.aspx?delId=<%=ipromotionrulesInfo.id%>&salid=<%=ipromotionrulesInfo.activtyid %>" ask="是否要删除此信息?">删除</a>|
                                                    <a href="Addcuxiaoguize.aspx?updateId=<%=ipromotionrulesInfo.id%>">编辑</a>|
                                                    <a href="ajax_manage.aspx?action=guizedetail&id=<%=ipromotionrulesInfo.id%>&typeid=<%=ipromotionrulesInfo.typeid %>" class="ajaxlink">详情</a>
                                                </div>
                                            </td>
                                        </tr>
                                        <%       
                                            }
                                          } %>
                                        <tr>
                                            <td colspan="8">
                                                <input id="hidsalid" type="hidden" value="<%=strSalid %>" />
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
            var istrue = window.confirm("是否删除选中项？");
            if (istrue) {
                window.location = "YingXiao_CuXiaoGuiZe.aspx?item=" + $("#items").val() + "&url=" + urls + "&salid=" + $("#hidsalid").val();
            }
        }
        else {
            alert("你还没有选择删除项！ ");
        }
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>