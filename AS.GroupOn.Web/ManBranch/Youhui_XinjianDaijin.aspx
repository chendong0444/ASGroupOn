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
    protected string time = "";
    protected string strId = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
      
        time = System.DateTime.Now.Year.ToString() + System.DateTime.Now.Month.ToString() + System.DateTime.Now.Day.ToString() + "_AS";
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
                                        新建代金劵</h2>
                                       
                                    <ul class="filter">
                                        <li></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>商户ID</label>
                                        <input type="text"  name="partner_id" id="partner_id"  class="number" value="0" require="true" datatype="number"  /><span class="inputtip">商户ID可以在商户菜单中查询复制出来</span>
							            <span class="hint">0 表示站内所有商户通用代金券</span>
                                    </div>
                                    <div class="field">
                                        <label>项目ID</label>
                                        <input type="text"  name="team_id"  id="team_id" class="number" value="0" require="true" datatype="number"  /><span class="inputtip"></span>
							            <span class="hint">0 表示站内所有项目通用代金券</span>
                                    </div>
                                    <div class="field">
                                        <label>代金券面额</label>
                                        <input type="text"  name="money" id="money" class="number" value="10" datatype="number" require="true" /><span class="inputtip">面额单位为元CNY（人民币元）</span>
                                    </div>
                                    <div class="field">
                                        <label>生成数量</label>
                                        <input type="text"    name="quantity" id="quantity" class="number" value="10" datatype="number" require="true" /><span class="inputtip">一次最多生成1000张，可重复生成</span>
                                    </div>
                                    <div class="field">
                                        <label>开始日期</label>
                                        <input type="text"  name="begin_time" id="begin_time" class="date"  require="true"  datatype="date"  onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'});"  /><span class="inputtip">时间格式：2010-05-05</span>
                            
						            </div>
                                    <div class="field">
                                        <label>结束日期</label>
                                        <input type="text" name="end_time" id="end_time" class="date" group="g" require="true"   datatype="date"  onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'});" />
						            </div>
                                    <div class="field">
                                        <label>行动代号</label>
                                        <input type="text"  require="true" name="code" id="code" class="number" datatype="require" value="<%=time %>" /><span class="inputtip">只是一个代号，可用于对代金券，归档、汇总、查询</span>
                                    </div>
                                    <div class="act">
                                        <%--<input type="hidden" name="id" id="id" value="<%=strId %>" />--%>
                                        <input type="hidden" name="ip" id="ip" value="" />
                                        <input type='hidden' name='action' value='adddaijinquan' />
                                        <input type="submit" value="确定" name="commit" id="submit" class="formbutton validator" />
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