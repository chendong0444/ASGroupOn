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
    protected string citys = String.Empty;
    protected string jsondata = String.Empty;
    protected bool isedit = false;
    protected int id = 0;
    protected string name = String.Empty;
    IFareTemplate faretemplate = Store.CreateFareTemplate();
    FarecitysFilter filter = new FarecitysFilter();
    IList<IFarecitys> ilistfarecitys = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        id = Helper.GetInt(Request["id"], 0);

       
        filter.pid = 0;
        filter.AddSortOrder(FarecitysFilter.ID_ASC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistfarecitys = session.Farecitys.GetList(filter);
        }
        if (id > 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                faretemplate = session.FareTemplate.GetByID(id);
            }
            if (faretemplate != null)
            {
                isedit = true;
                jsondata = faretemplate.value;
                name = faretemplate.name ;
            }
        }
        
        foreach(IFarecitys farecitysinfo in ilistfarecitys )
        {
            citys = citys + "," + farecitysinfo.name;
        }
        if (citys.Length > 0)
            citys = citys.Substring(1);
    }
</script>


<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:580px;">

	<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span></h3>
	<div style="overflow-x:hidden;padding:10px;">
    <div style="height: 38px;border-bottom-width: 1px;border-bottom-style: solid;border-bottom-color: #CCCCCC;"><b>模板名称：</b><input type="text" name="templatename" id="templatename" class="numberkdqt"></div>
    <div id="default" style="height: 48px;"><b>默认城市：<span class="hint_hui">（此项设置为所有城市快递费用都一样）</span></b><br />首件运费价格：<input type="text"  fare="one" size="5" name="one" id="one" class="numberkd">每增加：<input type="text" size="10" fare="number" size="5" name="number" id="number" class="numberkd">件，运费增加：<input fare="two" size="5" type="text" name="two" id="two" class="numberkd">元</div>
	<div style="height: 48px;"><input type="button" id="add" onclick="templateadd()" value="添加其他城市" class="validator formbutton"><b><span class="hint_hui">（此项设置为快递费不一样的城市）</span></b><br /><span class="hint_hui">(请从下方城市列表中复制城市名称，多个城市间用半角逗号分隔)</span></div>
    <div class="othercitys">
    <ul></ul>
    </div>
    <div style="height:48px;border-bottom-width: 1px;border-bottom-style: solid;border-bottom-color: #CCCCCC;"><input type="button" class="validator formbutton" name="button" id="button" onclick="templateaddsave()" value="保存"></div>

    <div class="citylist">
    <h2>城市列表</h2>
    <span><%=citys %></span>
    </div>
    
    </div>
</div>
<%if(id>0){ %>
<input type="hidden" name="id" id="edit" value="<%=id %>">
<%} %>
<%if(isedit){ %>
<script>
    function fare_templateinit() {
        $("#templatename").attr("value","<%=name %>");
        var jsdata = <%=jsondata %>;
        $("#default").find("input[fare='one']").attr("value",jsdata.fare[0].one);
        $("#default").find("input[fare='number']").attr("value",jsdata.fare[0].number);
        $("#default").find("input[fare='two']").attr("value",jsdata.fare[0].two);

        for(var i=1;i<jsdata.fare.length;i++)
        {
            add_id = add_id + 1;
            $(".othercitys").append("<li style='height: 55px;'>其他城市：<input type='text' value='"+jsdata.fare[i].cityname+"' fare='city' class='numberkdqt'><br>首件运费价格：<input type='text' value='"+jsdata.fare[i].one+"' fare='one' class='numberkd'>每增加：<input type='text' size='10' fare='number' value='"+jsdata.fare[i].number+"' size='10' class='numberkd'>件，运费增加：<input fare='two' size='10' value='"+jsdata.fare[i].two+"' type='text' class='numberkd'>元&nbsp;&nbsp;<input fare='del' href='javascript:void(0)'  id='add_" + add_id + "' value='删除' class='btn' type='button' onclick='templatedel(" + add_id + ")'></li>");
        }
    }
    fare_templateinit();
</script>
<%} %>
