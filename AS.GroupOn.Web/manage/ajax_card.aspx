<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    protected int count;
    protected string strCity;
    protected string strLevel;
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        
        string action = Helper.GetString(Request["action"], String.Empty);
        string code = Helper.GetString(Request["code"], String.Empty);
        if (action == "count")
        {
            IList<ICard> Ilistcard = null;
            CardFilter cardfilter = new CardFilter();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                cardfilter.Code = code;
                cardfilter.FromEnd_time = DateTime.Now;
                cardfilter.consume = "N";
                cardfilter.user_id = 0;

                Ilistcard = session.Card.GetList(cardfilter);
            }
            count = Helper.GetInt(Ilistcard.Count, 0);
            Response.Write(count);
            Response.End();
        }
        if (action == "user")
        {
            SelectValue();
            StringBuilder stB1 = new StringBuilder();
            stB1.Append("<tr >");
            stB1.Append("<th width='70px'>ID</th>");
            stB1.Append("<th width='200px'>Email/用户名</th>");
            stB1.Append("<th width='90px' nowrap>姓名/城市</th>");
            stB1.Append("<th width='50px'>余额</th>");
            stB1.Append("<th width='80px'>等级</th>");
            stB1.Append("<th width='60px'>邮编</th>");
            stB1.Append("<th width='120px'>注册时间</th>");
            stB1.Append("<th width='60px'>购买次数</th>");
            stB1.Append("<th width='100px'>联系电话</th>");
            stB1.Append("</tr>");
            Literal1.Text = stB1.ToString();
        }
    }
    /// <summary>
    /// 城市/级别
    /// </summary>
    public void SelectValue()
    {
        //城市
        StringBuilder stBCity = new StringBuilder();
        stBCity.Append("<select name='ddlCity' id='ddlCity' style='width:150px;'>");
        stBCity.Append("<option value='0' >全部城市</option>");

        //级别
        StringBuilder stLevel = new StringBuilder();
        stLevel.Append("<select name='ddlLevel' id='ddlLevel' style='width:150px;'>");
        stLevel.Append("<option value='0' >选择等级</option>");

        
        IList<ICategory> IlistCategory = null;
        CategoryFilter categoryfilter = new CategoryFilter();
        IList<ICategory> IlistCategoryle = null;
        CategoryFilter categoryfilterle = new CategoryFilter();
        
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            categoryfilter.Zone = WebUtils.GetCatalogName(CatalogType.city);
            categoryfilter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
            IlistCategory = session.Category.GetList(categoryfilter);
            categoryfilterle.Zone = "grade";
            IlistCategoryle = session.Category.GetList(categoryfilterle);

            foreach (ICategory icategoryInfo in IlistCategory)
            {
                stBCity.Append("<option value='" + icategoryInfo.Id + "' >" + icategoryInfo.Name + "</option>");
            }
            foreach (ICategory icategoryInfole in IlistCategoryle)
            {
                stLevel.Append("<option value='" + icategoryInfole.Id + "' >" + icategoryInfole.Name + "</option>");
            }
            
        }
        stBCity.Append("</select>");
        stLevel.Append("</select>");
        strCity = stBCity.ToString();
        strLevel = stLevel.ToString();
    }
</script>

<script type="text/javascript" language="javascript">
    function saveUser() {
        //注册时间
        var firstTime = $("#hidFirstTime").val();
        var endTime = $("#hidEndTime").val();
        //付款订单数
        var orderCount = $("#hidOrderCount").val();
        //所在城市
        var city = $("#hidCity").val();
        //用户等级
        var level = $("#hidLevel").val();
        //购买指定项目ID
        var teamId = $("#hidTeamId").val();
        //付款时间
        var orderFirstTime = $("#hidOrderFirstTime").val();
        var orderEndTime = $("#hidOrderEndTime").val();
        //筛选后
        var shaiXuan = $("#hidShaiXuan").val();
        $.ajax({
            type: "POST",
            url: "ajax_cardUser.aspx?action=saveUser",
            data: {
                "firstTime": firstTime,
                "endTime": endTime,
                "orderCount": orderCount,
                "city": city,
                "level": level,
                "teamId": teamId,
                "orderFirstTime": orderFirstTime,
                "orderEndTime": orderEndTime,
                "shaiXuan": shaiXuan
            },
            success: function (message) {
                window.location.href = "YingXiao_Packet.aspx?send=true";
            }
        })
        //X.boxClose();
        //alert("aa");
        //location.href = "YingXiao_Packet.aspx?send=true";
    }
    function showUser(page) {
        //页数
        page = parseInt(page);
        //注册时间
        var firstTime = $("#txtFirstTime").val();
        $("#hidFirstTime").val(firstTime)
        var endTime = $("#txtEndTime").val();
        $("#hidEndTime").val(endTime);
        //付款订单数
        var orderCount = $("#txtOrderCount").val();
        $("#hidOrderCount").val(orderCount);
        //所在城市
        var city = $("#ddlCity").val();
        $("#hidCity").val(city);
        //用户等级
        var level = $("#ddlLevel").val();
        $("#hidLevel").val(level);
        //购买指定项目ID
        var teamId = $("#txtTeamId").val();
        $("#hidTeamId").val(teamId);
        //付款时间
        var orderFirstTime = $("#txtOrderFirstTime").val();
        $("#hidOrderFirstTime").val(orderFirstTime);
        var orderEndTime = $("#txtOrderEndTime").val();
        $("#hidOrderEndTime").val(orderEndTime);
        //筛选后
        var shaiXuan = "shaiXuan";
        $("#hidShaiXuan").val(shaiXuan);
        $.ajax({
            type: "POST",
            //url: webroot + "WebPage/ajaxPage/CardUser.aspx?action=userInfo",
            url: "ajax_cardUser.aspx?action=userInfo",
            data: { "firstTime": firstTime,
                "endTime": endTime,
                "orderCount": orderCount,
                "city": city,
                "level": level,
                "teamId": teamId,
                "orderFirstTime": orderFirstTime,
                "orderEndTime": orderEndTime,
                "shaiXuan": shaiXuan,
                "page": page
            },
            success: function (json) {
                var json = eval("(" + json + ")");
                //json长度
                var j = parseInt(json.myJson.length);
                if (j >= 2) {
                    //userId
                    var userId = json.myJson[j - 1].userId;
                    $("#lblNumm").text(userId);
                    //用户数量
                    $("#lblNum").text(json.myJson[j - 1].userCount);
                    //清空tbUser
                    $("#tbUser tbody").empty();
                    for (var i = 0; i < json.myJson.length - 1; i++) {
                        if (i % 2 != 0) {
                            $("#tbUser").append("<tr><td  style='width: 70px'>" + json.myJson[i].uId + "</td>" +
                    "<td width='200px'><div style='word-wrap: break-word;overflow: hidden; width: 150px;'>" + json.myJson[i].uEmail + "<br />" + json.myJson[i].uUserName + "</div></td>" +
                    "<td width='90px'>" + json.myJson[i].uRealname + "<br />" + json.myJson[i].city + "</td>" +
                    "<td width='50px'><span class='currency'>" + json.myJson[i].uMoney + "</td>" +
                    "<td width='80px'><span class='currency'>" + json.myJson[i].level + "</span></td>" +
                    "<td width='60px'>" + json.myJson[i].uZipcode + "</td>" +
                    "<td width='120px'>" + json.myJson[i].uCreate_time + "</td>" +
                    "<td width='60px'>" + json.myJson[i].oCount + "</td>" +
                    "<td width='100px'>" + json.myJson[i].uMobile + "</td></tr>");
                        }
                        else {
                            $("#tbUser").append("<tr class='alt'><td  style='width: 60px'>" + json.myJson[i].uId + "</td>" +
                    "<td width='200px'><div style='word-wrap: break-word;overflow: hidden; width: 150px;'>" + json.myJson[i].uEmail + "<br />" + json.myJson[i].uUserName + "</div></td>" +
                    "<td width='90px'>" + json.myJson[i].uRealname + "<br />" + json.myJson[i].city + "</td>" +
                    "<td width='50px'><span class='currency'>" + json.myJson[i].uMoney + "</td>" +
                    "<td width='80px'><span class='currency'>" + json.myJson[i].level + "</span></td>" +
                    "<td width='60px'>" + json.myJson[i].uZipcode + "</td>" +
                    "<td width='120px'>" + json.myJson[i].uCreate_time + "</td>" +
                    "<td width='60px'>" + json.myJson[i].oCount + "</td>" +
                    "<td width='100px'>" + json.myJson[i].uMobile + "</td></tr>");
                        }
                    }
                    //用户数量
                    var userCount = parseInt(json.myJson[j - 1].userCount);
                    //页数
                    var totalpage = json.myJson[j - 1].totalpage;
                    //清空ulPage
                    $("#ulPage").empty();
                    //分页
                    if (userCount > 0) {
                        if (page < 1) {
                            page = 1;
                        }
                        if (page > totalpage) {
                            page = totalpage;
                        }
                        $("#ulPage").append("<li class='current'></li><li><a>共" + userCount + "条</a></li> ");
                        if (page > 1) {
                            $("#ulPage").append("<li><a onclick='showUser(1)'style='cursor:pointer' >首页</a></li><li><a onclick='showUser(" + (page - 1) + ")' style='cursor:pointer'>上一页</a></li>");
                        }
                        var p = parseInt(page - 4);
                        if (p < 1) {
                            p = 1;
                        }
                        var pa = 1;
                        while (p <= totalpage && pa <= 9) {
                            if (p == page) {
                                $("#ulPage").append("<li style='margin: 0 6px;'><font style='color: red;'>" + p + "</font></li>");
                            }
                            else {
                                $("#ulPage").append("<li><a onclick='showUser(" + p + ")' style='cursor:pointer'>" + p + "</a></li>");
                            }
                            p = p + 1;
                            pa = pa + 1;
                        }
                        if (page < totalpage) {
                            $("#ulPage").append("<li><a onclick='showUser(" + (page + 1) + ")' style='cursor:pointer'>下一页</a></li><li><a onclick='showUser(" + totalpage + ")' style='cursor:pointer'>末页</a></li>");
                        }
                    }
                }
                else {
                    $("#tbUser tbody").empty();
                    $("#ulPage").empty();
                    $("#lblNumm").text("");
                    $("#lblNum").text("");
                }
            }
        })
    }
</script>
<head>
    <style type="text/css">
        .style1
        {
            text-align: left;
        }
    </style>
</head>
<body>
    <form id="Form2" runat="server">
    <div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 976px; left: 210px;">
        <h3>
            <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>
        </h3>
        <div style="overflow-x: hidden; padding: 10px;" id="dialog-order-id">
            <div class="head">
                <ul>
                    <li>
                        注册时间：
                        <input name="firstTime" id="txtFirstTime" datatype="date" value="" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'});" class="h-input" style="width: 70px;" type="text" />
                        至
                        <input name="endTime" id="txtEndTime"  datatype="date" value="" class="h-input"  onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'});" style="width: 70px;" type="text" />
                        付款订单数：
                        <input type="text"  id="txtOrderCount" name="txtOrderCount" group="goto" class="h-input" datatype="number"/>
                        购买指定项目ID：
                        <input type="text"  id="txtTeamId" name="txtTeamId" group="goto" class="h-input" datatype="number"/>
                    </li>
                    <li>
                        所在城市：<%=strCity %>
                        用户等级：<%=strLevel %>
                        <input type="button" value="筛选" name="shaiXuan" group="goto" class="formbutton validator"
                            onclick="showUser(1)" style="padding: 1px 6px;" />
                        <input type="button" value="确定" name="send" group="goto" class="formbutton validator"
                            style="padding: 1px 6px;" onclick="saveUser()" />
                    </li>
                </ul>
            </div>
            <div class="sect">
                <input type="hidden" id="hidFirstTime" runat="server" />
                <input type="hidden" id="hidEndTime" runat="server" />
                <input type="hidden" id="hidOrderCount" runat="server" />
                <input type="hidden" id="hidCity" runat="server" />
                <input type="hidden" id="hidLevel" runat="server" />
                <input type="hidden" id="hidTeamId" runat="server" />
                <input type="hidden" id="hidOrderFirstTime" runat="server" />
                <input type="hidden" id="hidOrderEndTime" runat="server" />
                <input type="hidden" id="hidShaiXuan" runat="server" />
                <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table"
                    style="width: 960px; height: 21px">
                    <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                    <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                    <table id="tbUser" class="coupons-table">
                    </table>
                    <tr>
                        <td colspan="11">
                            <ul class="paginator" id="ulPage">
                            </ul>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
    </form>
    <script type="text/javascript" language="javascript">
        jQuery(document).ready(function () {
            jQuery("a.ajaxlink").unbind("click");
            jQuery("a[ask]").unbind("click");
            x_init_hook_validator();

            jQuery('a.ajaxlink').click(function () {
                if (jQuery(this).attr('no') == 'yes')
                    return false;
                var link = jQuery(this).attr('href');
                var ask = jQuery(this).attr('ask');
                if (ask) {
                    if (!confirm(ask)) {
                        return false;
                    }
                } else if (ask && !confirm(ask)) {
                    return false;
                }
                X.get(link);
                return false;
            });
        });
    </script>
</body>
