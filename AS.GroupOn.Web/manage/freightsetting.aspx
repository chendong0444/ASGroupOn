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
    protected NameValueCollection _system = new NameValueCollection();
   
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_BagMail_Set))
        {
            SetError("你不具有查看包邮选项的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        _system = WebUtils.GetSystem();
       
    }
    public void UpdateInfo(object sender, EventArgs e)
    {
        WebUtils systemmodel = new WebUtils();
        _system["spanprojectems"] = Helper.GetInt(Request["spanprojectems"], 0).ToString();
        _system["samefreight_spanprojectems"] = Helper.GetInt(Request["samefreight_spanprojectems"], 0).ToString();
        _system["sameseller_spanprojectems"] = Helper.GetInt(Request["sameseller_spanprojectems"], 0).ToString();
        _system["samenumber_spanprojectems"] = Helper.GetInt(Request["samenumber_spanprojectems"], 0).ToString();
        _system["computemode"] = Helper.GetInt(Request["computemode"], 1).ToString();
        _system["payselectexpress"] = Helper.GetInt(Request["payselectexpress"], 2).ToString();
        _system["baoyoushuliang"] = Helper.GetInt(Request["baoyoushuliang"], 0).ToString();

        systemmodel.CreateSystemByNameCollection(_system);
        for (int i = 0; i < _system.Count; i++)
        {
            string strKey = _system.Keys[i];
            string strValue = _system[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
        SetSuccess("更新成功");
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<script>
    function changecontent() {
        if ($("#spanprojectems").attr("checked")) {
            $("#conrcontent").css("display", "block");
        }
        else {

            $("#conrcontent").css("display", "none");
        }

    }
</script>
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
                                        包邮选项</h2>
                                    <ul class="filter">
                                        
                                    </ul>
                                </div>
                               <div class="sect">
                <div class="wholetip clear"><h3>跨项目包邮功能设置</h3></div>
                
                        <div class="field_kd" style="margin-left:20px" >
                        <label class="label_kd"><input type="checkbox" name="spanprojectems" value="1" <%if(_system["spanprojectems"]=="1"){ %>checked="checked"<%} %> id="spanprojectems" onClick="changecontent()" /></label><span class="inputtip"></span>
                            <div>启用跨项目包邮</div><span class="hint_kd">(如单独勾选此项，则所有快递项目都能混合包邮，不受其它条件限制)</span>
						</div>
                        <div class="field_kd" id="conrcontent" <%if(_system["spanprojectems"]!="1"){ %>style="display:none; margin-left:20px;"<%} %>>
                        <div class="field_kd" >
                        <label class="label_kd"><input type="checkbox" name="samefreight_spanprojectems" value="1" <%if(_system["samefreight_spanprojectems"]=="1"){ %>checked="checked"<%} %> id="samefreight_spanprojectems" /></label><span class="inputtip"></span>
                            <div>相同运费的项目才可跨项目包邮<span class="hint_kd">(项目A:5元运费,项目B:5元运费 则如果买了项目A,B并且免单数量满足 则项目A,B进行包邮)</span></div>
						</div>
                       <div class="field_kd" >
                       <label class="label_kd"><input type="checkbox" name="sameseller_spanprojectems" value="1" <%if(_system["sameseller_spanprojectems"]=="1"){ %>checked="checked"<%} %> id="sameseller_spanprojectems" /></label><span class="inputtip"></span>
                            <div>相同商家的项目才可跨项目包邮 <span class="hint_kd">(项目A:属于商家a:项目B属于商家a.勾选后 如果订单中买了项目A,项目B并且免单数量满足 则项目A,B进行包邮)</span></div>
					   </div>
				
                    <div class="field_kd">
                    <label class="label_kd"><input type="checkbox" name="samenumber_spanprojectems" value="1" <%if(_system["samenumber_spanprojectems"]=="1"){ %>checked="checked"<%} %> id="samenumber_spanprojectems" /></label><span class="inputtip"></span>
                            <div>相同免单数量的项目才可跨项目包邮<span class="hint_kd">(项目A:2件包邮.项目B:2件包邮。勾选后 如果项目A买一件，项目B买一件。则订单中项目A,B将被免运费 )</span></div>
				    </div>
                    </div>
                   
                    
                </div>
                <div class="sect">
                <div class="wholetip clear"><h3>包邮数量计算方式</h3></div>
                <div class="field_kd" style="margin-left:20px" >
                        <label class="label_kd"><input type="radio" name="baoyoushuliang" value="0" <%if(Helper.GetInt(_system["baoyoushuliang"],0)==0){ %>checked="checked"<%} %> id="baoyoushuliang1" /></label><span class="inputtip"></span>
                            <div>满足最大包邮数量才包邮</div><span class="hint_kd"></span>
						</div>
                <div class="field_kd" style="margin-left:20px" >
                        <label class="label_kd"><input type="radio" name="baoyoushuliang" value="1" <%if(_system["baoyoushuliang"]=="1"){ %>checked="checked"<%} %> id="baoyoushuliang2" /></label><span class="inputtip"></span>
                            <div>满足最小数量才包邮</div><span class="hint_kd"></span>
						</div>
                <div class="field_kd" style="margin-left:20px" >
                        <label class="label_kd"><input type="radio" name="baoyoushuliang" value="2" <%if(_system["baoyoushuliang"]=="2"){ %>checked="checked"<%} %> id="baoyoushuliang3" /></label><span class="inputtip"></span>
                            <div>满足平均数才包邮</div><span class="hint_kd"></span>
						</div>

                </div>

                <div class="sect">
                <div class="wholetip clear"><h3>项目运费合并方式</h3></div>
                        <div class="field_kd" style="margin-left:20px">
                        <label class="label_kd"><input type="radio" name="computemode" <%if(_system["computemode"]=="1"||_system["computemode"]==""){ %>checked="checked"<%} %> id="computemode1" value="1" /></label>
                            <div>订单运费=各个项目的运费相加</div>
						</div>
                        <div class="field_kd" style="margin-left:20px">
                        <label class="label_kd"><input type="radio" name="computemode" <%if(_system["computemode"]=="2"){ %>checked="checked"<%} %> id="computemode2" value="2" /></label>
                            <div>订单运费=运费最高的项目运费+其他项目的次件运费 <span class="hint_kd">(次件运费指每增加几件加几元的运费)</span></div>
						</div>
                </div>

                 <div class="sect">
                <div class="wholetip clear"><h3>其他设置</h3></div>
                        <div class="field_kd" style="margin-left:20px">
                        <label class="label_kd"><input type="checkbox" <%if(_system["payselectexpress"]=="1"){ %>checked="checked"<%} %> value="1" name="payselectexpress" id="payselectexpress" /></label>
                            <div>是否允许用户付款时选择快递公司 <span class="hint_kd">(开启此功能后，用户下单选择送货地区时，会自动过滤掉不能送到此地区的快递公司.您需要到后台》配置》快递设置》未送达区域里进行设置 勾选的城市代表不能送到)</span></div>
                            <span class="inputtip"></span>
						</div>
                </div>

                <div class="act">
                <input id="Submit1" type="submit" group="a" runat="server" value="保存" name="commit" class="validator formbutton" onserverclick="UpdateInfo" />
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