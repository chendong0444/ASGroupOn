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

    protected IPromotion_rules ipromotionrules = null;
    protected IList<ICategory> iListCategory = null;

    protected int strSalid = 0;//活动编号
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_CXHD_RuleAdd))
        {
            SetError("你不具有添加促销活动规则信息的权限！");
            Response.Redirect("YingXiao_CuXiaoGuiZe.aspx");
            Response.End();
            return;
        }
        teamTitle();
        strSalid = Helper.GetInt(Request["salid"], 0);

        if (Request["updateId"] != null && Request["updateId"].ToString() != "")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_CXHD_RuleEdit))
            {
                SetError("你不具有编辑活动规则信息的权限！");
                Response.Redirect("YingXiao_CuXiaoGuiZe.aspx");
                Response.End();
                return;
            }
            else
            {
                Update();
            }
        }
    }

    /// <summary>
    /// 绑定下拉框列表
    /// </summary>
    protected void teamTitle()
    {
        CategoryFilter filter = new CategoryFilter();
        filter.Zone = "activity";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCategory = session.Category.GetList(filter);
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
                ipromotionrules = session.Promotion_rules.GetByID(strid);
            }
        }
    }

    
</script>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    function GuiZe() {
        var ddlvalue = $("#ddlparent").val();
        var hids = $("#hid").val();
        alert
        $.ajax({
            type: "POST",
            url: "CuxiaoGuze.aspx",
            data: { "ddlvalue": ddlvalue, "hids": hids },
            success: function (msg) {
                if (msg == "Free_shipping") {
                    $("#reduces").hide();
                    $("#back").hide();
                    $("#freight").show();
                }
                else if (msg == "Feeding_amount") {
                    $("#freight").hide();
                    $("#reduces").hide();
                    $("#back").show();
                }
                else if (msg == "Deduction") {
                    $("#back").hide();
                    $("#freight").hide();
                    $("#reduces").show();
                }
            }
        });
    }
    //    $("#ddlparent").blur(function () {
    //        var ddlparent = $("#ddlparent").val();
    //        if (parseInt(ddlparent) == 0) {
    //            alert("请您选择促销规则！");
</script>

<body class="newbie" onload="GuiZe();">
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
                                        <%if (ipromotionrules != null)
                                      {
                                    %>
                                        <h2>编辑促销规则</h2>
                                    <%}
                                      else
                                      {
                                    %>
                                        <h2>添加促销规则</h2>
                                    <%}%>
                                    
                                    <ul class="filter">
                                        <li></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <%if (ipromotionrules != null)
                                      {
                                    %>
                                    <input type='hidden' name='action' value='updatecuxiaoguize' />
                                    <input type='hidden' name="activtyid" value="<%=ipromotionrules.activtyid %>" />
                                    <input type="hidden" name="id" id="id" value="<%=ipromotionrules.id %>" />
                                    <div class="field">
                                        <label>促销规则选择</label>
                                        <select name="ddlparent" id="ddlparent" onChange="GuiZe();">
                                                <option value="0">促销规则选择</option>
                                            <% foreach (ICategory icategoryInfo in iListCategory)
                                               {
                                            %>
                                                <option value="<%=icategoryInfo.Id %>" <%if(ipromotionrules.typeid == icategoryInfo.Id){%> selected="selected" <%} %> > <%=icategoryInfo.content %></option>
                                            <%
                                               }
                                            %>
                                        </select>

                                    </div>
                                    <div class="field">
                                        <label>订单优惠条件</label>
                                        <input type="text" name="fullmoney" style="float:left;" class ="h-input" value="<%=ipromotionrules.full_money %>"/> 
                                        <label id="lbljine2" style="width:92px;line-height:20px;">&le;订单金额&le;</label> 
                                        <input type="text" name="max" class ="h-input" value="9999999" readonly="readonly"/>
                                    </div>
                                    <div class="field">
                                        <label>活动规则开始时间</label>
                                        <input name="starttime" id="Text3" datatype="date" value="<%=ipromotionrules.start_time.ToString("yyyy-MM-dd") %>" class="h-input" style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});"/>
                                    </div>
                                    <div class="field">
                                        <label>活动规则结束时间</label>
                                        <input name="endTime" id="Text4" datatype="date" value="<%=ipromotionrules.end_time.ToString("yyyy-MM-dd") %>" class="h-input" style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});"/>
                                    </div>
                                    <div class="field">
                                        <label>排序</label>
                                        <input id="Text5" type="text" name="sort" class ="h-input" value="<%=ipromotionrules.sort %>"  datatype="number" require="true" onkeyup= "value=value.replace(/[^\d\.-]/g, ' ') "/>
                                    </div>
                                    <div class="field" id="freight" style="display:none">
                                        <label>是否免运费</label>
                                        <select name="free_shipping">
                                            <option value="1" <%if(ipromotionrules.free_shipping == 1){%> selected="selected" <%} %>>是
                                            </option>
                                            <option value="0" <%if(ipromotionrules.free_shipping == 0){%> selected="selected" <%} %>>否
                                            </option>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>是否启用</label>
                                        <select name="enable">
                                            <option value="1" <%if(ipromotionrules.enable == 1){%> selected="selected" <%} %>>是
                                            </option>
                                            <option value="0" <%if(ipromotionrules.enable == 0){%> selected="selected" <%} %>>否
                                            </option>
                                        </select>
                                    </div>
                                    <div class="field" id="reduces" style="display:none">
                                        <label>请输入减少的金额</label>
                                        <input type="text" name="deduction" class ="h-input"  datatype="number" value="<%=ipromotionrules.deduction %>" />
                                    </div>
                                    <div class="field" id="back" style="display:none">
                                        <label>请输入返回余额的金额</label>
                                        <input type="text" name="feeding_amount" class ="h-input" value="<%=ipromotionrules.feeding_amount %>"  datatype="number" />
                                    </div>
                                    <div class="field">
                                        <label>规则描述</label>
                                        <textarea name="description" style="width: 400px; height: 100px;"  id="Textarea1"><%=ipromotionrules.rule_description %></textarea>
                                    </div>
                                    <%
                                        }
                                      else
                                      {
                                    %>
                                    <input type='hidden' name='action' value='addcuxiaoguize' />
                                    <input type='hidden' name="activtyid" value="<%=strSalid %>" />
                                    <div class="field">
                                        <label>促销规则选择</label>
                                        <select name="ddlparent" id="ddlparent" onChange="GuiZe();">
                                                <option value="0">促销规则选择</option>
                                            <% foreach (ICategory icategoryInfo in iListCategory)
                                               {
                                            %>
                                                <option value="<%=icategoryInfo.Id %>"><%=icategoryInfo.content %></option>
                                            <%
                                               }
                                            %>
                                        </select>

                                    </div>
                                    <div class="field">
                                        <label>订单优惠条件</label>
                                        <input id="fullmoney" type="text" name="fullmoney" style="float:left" group="g" require="true" datatype="require" class ="h-input"/> 
                                        <label id="lbljine" style="width:92px;line-height:20px;">&le;订单金额&le;</label> 
                                        <input id="max" type="text" name="max" class ="h-input" value="9999999" readonly="readonly"/>
                                    </div>
                                    <div class="field">
                                        <label>活动规则开始时间</label>
                                        <input name="starttime" id="starttime" group="g" require="true" datatype="require" value="" class="h-input" style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});"/>
                                    </div>
                                    <div class="field">
                                        <label>活动规则结束时间</label>
                                        <input name="endTime" id="endtime" group="g" require="true" datatype="require" value="" class="h-input" style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});"/>
                                    </div>
                                    <div class="field">
                                        <label>排序</label>
                                        <input id="sort" type="text" name="sort" class ="h-input"  datatype="number" require="true" value="0" onkeyup= "value=value.replace(/[^\d\.-]/g, ' ') "/>
                                    </div>
                                    <div class="field" id="freight" style="display:none">
                                        <label>是否免运费</label>
                                        <select name="free_shipping">
                                            <option value="1" selected="selected">是
                                            </option>
                                            <option value="0">否
                                            </option>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>是否启用</label>
                                        <select name="enable">
                                            <option value="1" selected="selected">是
                                            </option>
                                            <option value="0">否
                                            </option>
                                        </select>
                                    </div>
                                    <div class="field" id="reduces" style="display:none">
                                        <label>请输入减少的金额</label>
                                        <input id="deduction" type="text" name="deduction" class ="h-input"  datatype="number" />
                                    </div>
                                    <div class="field" id="back" style="display:none">
                                        <label>请输入返回余额的金额</label>
                                        <input id="feeding_amount" type="text" name="feeding_amount" class ="h-input"  datatype="number" />
                                    </div>
                                    <div class="field">
                                        <label>规则描述</label>
                                        <textarea name="description" style="width: 400px; height: 100px;"  id="description"></textarea>
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