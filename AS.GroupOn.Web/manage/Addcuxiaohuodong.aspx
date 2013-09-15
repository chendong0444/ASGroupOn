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
    
    protected ISales_promotion isalespromotion = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        
        if (Request["updateId"] != null && Request["updateId"].ToString() != "")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_CXHD_Edit))
            {
                SetError("你不具有编辑促销活动的权限！");
                Response.Redirect("YingXiao_CuXiaoHuoDong.aspx");
                Response.End();
                return;
            }
            else
            {
                Update();
            }
        }
        else
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_CXHD_Add))
            {
                SetError("你不具有添加促销活动的权限！");
                Response.Redirect("YingXiao_CuXiaoHuoDong.aspx");
                Response.End();
                return;
            }
        }
    }

    /// <summary>
    /// 修改
    /// </summary>
    protected void Update()
    {
        int strid = Helper.GetInt(Request["updateId"], 0);
        if (strid > 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                isalespromotion = session.Sales_promotion.GetByID(strid);
                    
            }
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
                                <div class="head">
                                    <%if (isalespromotion != null)
                                      {
                                    %>
                                        <h2>编辑促销活动</h2>
                                    <%}
                                      else
                                      {
                                    %>
                                        <h2>添加促销活动</h2>
                                    <%}%>
                                    <ul class="filter">
                                        <li></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <%if (isalespromotion != null)
                                      {
                                    %>
                                    <input type='hidden' name='action' value='updatecuxiaohuodong' />
                                    <input type="hidden" name="id" id="id" value="<%=isalespromotion.id %>" />
                                    <div class="field">
                                        <label>促销活动名称</label>
                                        <input id="Text2" type="text" name="cxname" class="h-input" style="width:120px; margin:0px 0px" value="<%=isalespromotion.name %>" group="g" require="true"  datatype="require"  />
                                    </div>
                                    <div class="field">
                                        <label>是否发布</label>
                                        <select name="enable">
                                            <option value="1" <%if(isalespromotion.enable == 1){%> selected="selected" <%} %>>是
                                            </option>
                                            <option value="0" <%if(isalespromotion.enable == 0){%> selected="selected" <%} %>>否
                                            </option>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>开始时间</label>
                                        <input name="startime" id="Text3" group="g" datatype="require" require="true" class="date"  value="<%=isalespromotion.start_time.ToString("yyyy-MM-dd") %>" style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});" />
                                    </div>
                                    <div class="field">
                                        <label>结束时间</label>
                                        <input name="endtime" id="Text4" group="g" datatype="require" require="true" class="date"  value="<%=isalespromotion.end_time.ToString("yyyy-MM-dd") %>" style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});" />
                                    </div>
                                    <div class="field">
                                        <label>排序</label>
                                        <input  type="text" id="Text5" name="sort" class="h-input" style="width:120px; margin:0px 0px" datatype="number" value="<%=isalespromotion.sort %>" onkeyup= "value=value.replace(/[^\d\.-]/g, ' ') " />
                                    </div>
                                    <div class="field">
                                        <label>促销活动描述</label>
                                        <textarea name="description" style="width: 400px; height: 100px;" id="Textarea1"><%=isalespromotion.description %></textarea>
                                    </div>
                                    <%
                                        }
                                      else
                                      {
                                    %>
                                    <input type='hidden' name='action' value='addcuxiaohuodong' />
                                    <div class="field">
                                        <label>促销活动名称</label>
                                        <input id="cxname" type="text" name="cxname" class="h-input" style="width:120px; margin:0px 0px" group="g" require="true"  datatype="require"  />
                                    </div>
                                    <div class="field">
                                        <label>是否发布</label>
                                        <select name="enable">
                                            <%--<option value="1" <%if(Request["newstype"] == "1"){%> selected="selected" <%} %>>是
                                            </option>
                                            <option value="0" <%if(Request["newstype"] == "0"){%> selected="selected" <%} %>>否
                                            </option>--%>
                                            <option value="1" selected="selected">是
                                            </option>
                                            <option value="0">否
                                            </option>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>开始时间</label>
                                        <input name="startime" id="startime"  group="g" datatype="require" require="true" class="date" style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});" />
                                    </div>
                                    <div class="field">
                                        <label>结束时间</label>
                                        <input name="endtime" id="endtime" group="g" datatype="require" require="true" class="date"  style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});" />
                                    </div>
                                    <div class="field">
                                        <label>排序</label>
                                        <input id="Text1" type="text" name="sort" class="h-input" style="width:120px; margin:0px 0px" datatype="number" onkeyup= "value=value.replace(/[^\d\.-]/g, ' ') " value="0" />
                                    </div>
                                    <div class="field">
                                        <label>促销活动描述</label>
                                        <textarea name="description" style="width: 400px; height: 100px;" id="description"></textarea>
                                    </div>
                                    <%  } %>
                                    <div class="act">
                                        <input type="submit" value="确定" name="commit" id="submit" class="formbutton validator" group="g" />
                                    </div>
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