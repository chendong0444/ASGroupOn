<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<script runat="server">
    protected IList<ICategory> categoryList = null;
    protected CategoryFilter filter = new CategoryFilter();
    /// 商户信息
    protected Dictionary<string, object> lp = new Dictionary<string, object>();
    protected List<object> listpartner = new List<object>();
    protected IList<IPartner> partner = null;
    protected PartnerFilter pfilter = new PartnerFilter();
    protected string partnerid = String.Empty;
    protected List<Hashtable> list2 = null;
    protected string states = "1";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (CurrentCity.Name == "全国")
        {
            return;
        }
        if (Request.QueryString["ancuy"] != "true" || Request.QueryString["catalog"]=="0")
        {
            //查询partnerid
            string sql1 = "select partner_id from team where begin_time<='" + DateTime.Now + "' and end_time>='" + DateTime.Now + "' and team_type='normal' and ((open_invent=1 and inventory>0)or open_invent=0) and (city_id=" + CurrentCity.Id + " or ','+othercity+',' like '%," + CurrentCity.Id + ",%')";
            List<Hashtable> list1 = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                list1 = session.GetData.GetDataList(sql1.ToString());
            }
            StringBuilder sb1 = new StringBuilder();
            if (list1 != null)
            {

                foreach (Hashtable item in list1)
                {
                    sb1.Append(item["partner_id"].ToString());
                    sb1.Append(",");
                }
                if (sb1.ToString().Length > 0)
                {
                    partnerid = sb1.ToString().Remove(sb1.ToString().LastIndexOf(","), 1);
                }
                else
                {
                    partnerid = "0";
                }
            }
        }
        else
        {
            //通过分类表ID 查询商家id
            string str = null;
            if (!string.IsNullOrEmpty(Request.QueryString["catalog"]))
            {
                pfilter.Group_id = AS.Common.Utils.Helper.GetInt(Request.QueryString["catalog"], 0);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    partner = session.Partners.GetList(pfilter);
                }
                if (partner != null)
                {
                    foreach (IPartner item in partner)
                    {
                        str += item.Id + ",";
                    }
                }
            }
            if (str != null)
            {
                partnerid = str.Substring(0,str.Length-1);
            }
        }
        
        //查询商家
        string partnerName = String.Empty;
        if (partnerid != String.Empty)
        {
            string sql2 = "select title,point,group_id,id from partner where id in(" + partnerid + ") and isnull(point,'')<>'' 	";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                list2 = session.GetData.GetDataList(sql2.ToString());
            }
        }
        else 
        {
            states = "0";   
        }
        if (list2 != null)
        {
            foreach (Hashtable item in list2)
            {
                Dictionary<string, object> p = new Dictionary<string, object>();
                string[] pois = item["point"].ToString().Split(',');
                p.Add("jing", pois[0]);
                p.Add("wei", pois[1]);
                p.Add("title", item["title"]);
                p.Add("type", AS.Common.Utils.Helper.GetInt(item["Group_id"], 0));
                p.Add("teamhtml", "");
                p.Add("marker", "");

                string sql3 = "select id,image,now_number,title,team_price,market_price from team where begin_time<='" + DateTime.Now + "' and end_time>='" + DateTime.Now + "' and team_type='normal' and teamcata=0 and ((open_invent=1 and inventory>0)or open_invent=0) and (city_id=" + CurrentCity.Id + "  or ','+othercity+',' like '%," + CurrentCity.Id + ",%') and partner_id=" + item["id"];
                List<Hashtable> list3 = null;

                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list3 = session.GetData.GetDataList(sql3.ToString());
                }
                List<object> listteam = new List<object>();
                foreach (Hashtable itema in list3)
                {
                    Dictionary<string, object> team = new Dictionary<string, object>();
                    team.Add("id", AS.Common.Utils.Helper.GetInt(itema["id"], 0));
                    team.Add("image", itema["image"]);
                    team.Add("now_number", AS.Common.Utils.Helper.GetInt(itema["now_number"], 0));
                    team.Add("title", AS.Common.Utils.StringUtils.SubString(itema["title"].ToString(), 50, true));
                    team.Add("team_price", AS.Common.Utils.Helper.GetDouble(itema["team_price"], 0));
                    team.Add("market_price", AS.Common.Utils.Helper.GetDouble(itema["market_price"], 0));
                    team.Add("discount", AS.Common.Utils.WebUtils.GetDiscount(AS.Common.Utils.Helper.GetDecimal(itema["market_price"], 0), AS.Common.Utils.Helper.GetDecimal(itema["team_price"], 0)));
                    listteam.Add(team);
                }
                //如果总店有，那么分店也有此项目
                //如果有分店检索分店
                string sql4 = "select branchname,point,id from branch where partnerid=" + item["id"];
                List<Hashtable> list4 = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list4 = session.GetData.GetDataList(sql4.ToString());
                }
                if (list4 != null)
                {
                    foreach (Hashtable brachrow in list4)
                    {
                        if (brachrow["point"] != null && brachrow["point"].ToString() != "")
                        {
                            Dictionary<string, object> b = new Dictionary<string, object>();

                            string[] bpois = brachrow["point"].ToString().Split(',');
                            b.Add("jing", bpois[0]);
                            b.Add("wei", bpois[1]);
                            b.Add("title", AS.Common.Utils.Helper.GetString(brachrow["branchname"], String.Empty));
                            b.Add("type", AS.Common.Utils.Helper.GetInt(item["Group_id"], 0));
                            b.Add("teamhtml", "");
                            b.Add("marker", "");
                            b.Add("teams", listteam);

                            listpartner.Add(b);
                        }
                    }
                }
                p.Add("teams", listteam);
                listpartner.Add(p);
            }
        }
            filter.Zone = "partner";
            filter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
            filter.AddSortOrder(CategoryFilter.ID_ASC);
            filter.Display = "Y";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                categoryList = session.Category.GetList(filter);
            }
             lp.Add("partners", listpartner);
    }
    
</script>
<%LoadUserControl(WebRoot + "template/default/_htmlheader.ascx", null); %>
<%LoadUserControl(WebRoot + "template/default/_header.ascx", null); %>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="consult">
            <div class="consult-hd">
            </div>
            <div class="consult-bd">
                <div style="width: 960px;">
                    <%if (lp.Count == 0 || states=="0")
                      {%>
                    <div name="showmsg" id="showmsg" style="background-color: #F6F6F6; border: 1px dashed #89B4D7;
                        text-align: center; line-height: 30px">
                        对不起，没有找到正在团购的本地服务</div>
                    <%} %>
                    <!--百度地图容器-->
                    <div id="map" style="width: 741px; height: 600px; float: left; border: 1px solid #ccc;">
                    </div>
                    <div class="map_r">
                        <h1>
                            团购地图</h1>
                        <br />
                        商家分类<br />
                        <select name="catalog" id="catalog">
                            <option value="0" selected="selected">全部</option>
                            <% if (categoryList != null)
                               {
                                   foreach (ICategory item in categoryList)
                                   {%>
                            <option value="<%=item.Id %>" <%
                                                if(AS.Common.Utils.Helper.GetInt(Request["catalog"],0)==item.Id){
                                              %> selected="selected" <%} %>>
                                <%=item.Name %></option>
                            <% } %>
                            <%} %>
                        </select>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div id="mapteam" style="display: none;">
    <div class="map">
        <div class="map_bt">
            <a href="<%=AS.GroupOn.Controls.PageValue.WebRoot%>team/$id$.html" target="_blank">$title$</a></div>
        <div class="map_tujg">
            <div class="map_tuimg">
                <a href="<%=AS.GroupOn.Controls.PageValue.WebRoot%>team/$id$.html" target="_blank">
                    <img src="$image$" />
                </a>
                <div class="map_jgtext">
                    <p>
                        <strong>
                            <%=ASSystem.currency%>$team_price$</strong>
                    </p>
                    <span>$discount$</span> <span style="padding-right: 0px">
                        <%=ASSystem.currency%>$market_price$</span><br />
                    <span>$now_number$人购买</span>
                    <p>
                        <a class="map_gman" target="_blank" href="<%=AS.GroupOn.Controls.PageValue.WebRoot%>team/$id$.html">
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript" src="http://api.map.baidu.com/api?v=1.2"></script>
<script type="text/javascript">
          var mapData = new Array();
          var a=<%Response.Write(AS.Common.Utils.JsonUtils.GetJsonFromObject(lp));%>;
 
// 编写自定义函数,创建标注
function addMarker(point) {
    var marker = new BMap.Marker(point);
    map.addOverlay(marker);
}
         var map = new BMap.Map("map");    
          // 创建Map实例
          map.centerAndZoom(encodeURIComponent('<%=CurrentCity.Name %>'),10);
          map.enableScrollWheelZoom();
          map.enableDragging();
          // 向地图添加标注
          for(var i=0; i<a.partners.length; i++){
              var data = a.partners[i];
              var lng =data.wei;
              var lat =data.jing;
              var points = new BMap.Point(lng,lat);
              var marker = new BMap.Marker(points);
              map.addOverlay(marker);
              mapData[i] = data;
              setOpenWindow(points,i,marker);
              a.partners[i].marker = marker;
          }
          //点击标注弹出框的内容
          function setOpenWindow(points,i,marker)
          {
              var html = "<div class='mapbox'>";
              var teamcount =mapData[i].teams.length;
              for (var j = 0; j < teamcount; j++) { 
                  var team=mapData[i].teams[j];
                  html=html+$("#mapteam").html().replace().replace(/\$title\$/g,team.title).replace(/\$id\$/g,team.id).replace(/\$image\$/g,team.image).replace(/\$market_price\$/g,team.market_price).replace(/\$team_price\$/g,team.team_price).replace(/\$now_number\$/g,team.now_number).replace(/\$discount\$/g,team.discount);
              }
              html=html+"</div>";
              var infoWindow = new BMap.InfoWindow(html);  // 创建信息窗口对象
              marker.addEventListener("click", function(){                                        
                  this.openInfoWindow(infoWindow);
              });
          }
          $("#catalog").change(function(){
              var cid=parseInt($(this).val());
               window.location="<%=WebRoot %>team/maps.html?catalog="+cid+"&ancuy=true";
          });
    
</script>
<%LoadUserControl(WebRoot + "template/default/_footer.ascx", null); %>
<%LoadUserControl(WebRoot + "template/default/_htmlfooter.ascx", null); %>