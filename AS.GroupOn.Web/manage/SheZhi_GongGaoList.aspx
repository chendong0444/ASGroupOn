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
    protected IPagers<ILocation> pager = null;
    protected IList<ILocation> iListLocation = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Add_List))
        {
            SetError("你不具有查看广告位列表的权限！");
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
    /// 绑定广告位列表
    /// </summary>
    protected void InitData()
    {
        url = url + "&page={0}";
        url = "SheZhi_GongGaoList.aspx?" + url.Substring(1);
        LocationFilter filter = new LocationFilter();
        filter.PageSize = 30;
        filter.AddSortOrder(LocationFilter.More_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Location.GetPager(filter);
        }
        iListLocation = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
    /// <summary>
    /// 删除
    /// </summary>
    protected void Del()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Add_Delete))
        {
            SetError("你不具有删除广告位的权限！");
            Response.Redirect("SheZhi_GongGaoList.aspx");
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
                    del_id = session.Location.Delete(strid);
                }
                if (del_id > 0)
                {
                    SetSuccess("删除成功");
                }
                Response.Redirect("SheZhi_GongGaoList.aspx");
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
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Add_Delete))
        {
            SetError("你不具有删除广告位的权限！");
            Response.Redirect("SheZhi_GongGaoList.aspx");
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
                    i = session.Location.Delete(strid);
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
            Response.Redirect("SheZhi_GongGaoList.aspx?page=" + Helper.GetInt(Request.QueryString["url"], 1));
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
                                        广告位列表</h2>
                                    <ul class="filter">
                                        <li>
                                            <a href="SheZhi_Guangao.aspx">添加首页广告位</a> <a href="SheZhi_Guangao_Right.aspx">添加右侧广告位</a>
                                        </li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='5%'>
                                                <input type='checkbox' id='checkall' name='checkall' /> 全选
                                            </th>
                                            <th width='8%'>
                                                ID
                                            </th>
                                            <th width='25%'>
                                                广告
                                            </th>
                                            <th width='20%'>
                                                城市
                                            </th>
                                            <th width='18%'>
                                                广告位置
                                            </th>
                                            <th width='7%'>
                                                状态
                                            </th>
                                            <th width='17%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListLocation != null && iListLocation.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (ILocation locationInfo in iListLocation)
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
                                                    <input type='checkbox' id='check' name='check' value="<%=locationInfo.id%>" />
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=locationInfo.id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=locationInfo.width%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=locationInfo.City%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <% if (locationInfo.location==1 && locationInfo.height=="0")
                                                       { 
                                                    %>
                                                        团购首页显示
                                                    <%
                                                        }
                                                       else if ((locationInfo.location == 1 && locationInfo.height == "1")||(locationInfo.location == 3 && locationInfo.height == "1"))
                                                       { 
                                                    %>
                                                        商城首页显示
                                                    <%
                                                       }   
                                                    %>
                                                    <% else if (locationInfo.location == 2 && locationInfo.height == "0")
                                                       { 
                                                    %>
                                                        团购右侧显示
                                                    <%
                                                        }
                                                        else if (locationInfo.location == 2 && locationInfo.height == "1")
                                                        { 
                                                    %>
                                                        商城右侧显示
                                                    <%
                                                        }
                                                        else
                                                        { 
                                                    %>
                                                        &nbsp;
                                                    <%
                                                        }  
                                                    %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <% if (locationInfo.visibility == 1)
                                                       { 
                                                    %>
                                                        显示
                                                    <%
                                                        }
                                                       else
                                                       { 
                                                    %>
                                                        隐藏
                                                    <%
                                                       }   
                                                    %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%if (locationInfo.location == 1 || locationInfo.location == 3)
                                                      {
                                                    %>
                                                        <a href="SheZhi_GuangaoEdit.aspx?updateId=<%=locationInfo.id%>" >编辑</a>｜
                                                    <%}
                                                      else
                                                      { 
                                                    %>
                                                        <a href="SheZhi_Guangao_RightEdit.aspx?updateId=<%=locationInfo.id%>" >编辑</a>｜ 
                                                    <%
                                                      } 
                                                    %>
                                                        <a href="SheZhi_GongGaoList.aspx?delId=<%=locationInfo.id%>" ask="是否删除此广告位?" >删除</a>

                                                </div>
                                            </td>
                                        </tr>
                                        <%       
                                            }
                                          } %>
                                        <tr>
                                            <td colspan="7">
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
                window.location = "SheZhi_GongGaoList.aspx?item=" + $("#items").val() + "&url=" + urls;
            }
        }
        else {
            alert("你还没有选择删除项！ ");
        }
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>