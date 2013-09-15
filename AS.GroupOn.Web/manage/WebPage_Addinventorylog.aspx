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
    
    protected ITeam teammodel = null;
    protected TeamFilter teamfilter = new TeamFilter();
    protected IOrder ordermodel = null;
    //protected IInventorylog inventlogmodel = null;
    protected InventorylogFilter inventlogfilter = new InventorylogFilter();
    protected bool isRedirect = false;
    protected string bulletin = "";
    protected int sum = 0;
    protected int Teamid = 0;
    protected int inventory = 0;
    protected string p = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (Request["id"] != null)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teammodel = session.Teams.GetByID(Convert.ToInt32(Request["id"]));
            }
            inventory = teammodel.inventory;
            Teamid = Helper.GetInt(Request["id"], 0);
            p = Request["p"];
            bulletin = Gettest(0, teammodel, Teamid, 1);

            string txt = addcolor();
        }

    }


    #region 添加颜色或者尺寸
    public string addcolor()
    {
        string str = "";
        string falg = "";
        string txt = "rule0";
        int j = 0;
        string[] num = new string[100];

        string aa = Request["num0"];
        if (Request["num0"] != null)
        {
            num = Request["num0"].Split(',');
            if (num == null || num[j] == "")
            {
                num[j] = "0";
            }
            for (int k = 0; k < num.Length; k++)
            {
                if (num[k] == "")
                {
                    isRedirect = true;
                }
                else
                {
                    sum += Convert.ToInt32(num[k]);
                }
            }
        }
        //if (sum>numcount)
        //{
        //    isRedirect = true;
        //}
        //else
        //{
        if (Request["rule0"] != null)
        {

            string[] bull = Request["rule0"].Split(',');
            str += "";
            str += "{";
            falg = "";
            for (int i = 0; i < bull.Length; i++)
            {
                if (falg == bull[i].Split(':')[0])
                {
                    str += "数量:[" + num[j] + "]";
                    str += "}|";
                    j++;
                    str += "{";
                    str += bull[i].Split(':')[0] + ":";
                    str += "[";
                    str += bull[i].Split(':')[1] + "],";
                }
                else
                {
                    str += bull[i].Split(':')[0] + ":";
                    str += "[";
                    str += bull[i].Split(':')[1] + "],";
                    if (falg == "")
                    {
                        falg = bull[i].Split(':')[0];
                    }
                }
            }
            str += "数量:[" + num[j] + "]";
            str += "}";

            str += "";


        }
        // }
        return str;

    }
    #endregion

    #region 显示颜色或者尺寸  back参数：判断显示在前台，和后台 0：前台，1：后台----------------项目用
    public static string Gettest(int num, ITeam model, int teamid, int back)
    {
        string str = "";
        string bulletin = "";
        decimal team_price = 0;
        IOrder ordermodel = null;
        OrderFilter orderdal = new OrderFilter();
        ITeam teammodel = null;
        TeamFilter teamdal = new TeamFilter();
        BasePage bp = new BasePage();

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(teamid);
        }

        bulletin = teammodel.bulletin;
        team_price = teammodel.Team_price;

        IOrderDetail detailmodel = null;

        OrderDetailFilter detaildal = new OrderDetailFilter();
        if (Getbulletin(bulletin) != "")
        {
            #region
            string[] bulletinteam = bulletin.Replace("{", "").Replace("}", "").Split(',');
            if (teammodel.invent_result == null)
            {
                teammodel.invent_result = "";
            }
            string[] bullteam = teammodel.invent_result.Replace("{", "").Replace("}", "").Split('|');
            #region
            if (Getbulletin(teammodel.invent_result) == "")
            {
                str += "<table id='tb" + num + "'>";
                str += "<tr>";
                str += " <td colspan='7' bgcolor='#E4E4E4' class='deal-buy-desc' id='rule" + num + "'>";
                for (int i = 0; i < bulletinteam.Length - 1; i++)
                {
                    if (bulletinteam[i].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                    {
                        str += "<b>" + bulletinteam[i].Split(':')[0] + ":</b>";
                        string[] bull = bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                        str += "<select name='rule" + num + "'>";
                        for (int j = 0; j < bull.Length; j++)
                        {
                            str += "<option value='" + bulletinteam[i].Split(':')[0] + ":" + bull[j] + "'>" + bull[j] + "</option>";
                        }
                        str += "</select>";
                    }
                }
                str += "<b>价格：</b><input type=\"text\" value='" + bp.GetMoney(team_price) + "' onkeyup=\"checkIsNum(this," + bp.GetMoney(team_price) + ")\" size='5' name=\"bmoney" + num + "\"/>&nbsp;&nbsp;";
                str += "总库存:" + teammodel.inventory;
                str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;增加库存<input id='textfield' num_tid='" + teamid + "' name='insertnum" + num + "' type='text'   value='0' size='5' onkeyup=\"clearNoNum(this)\" />&nbsp;";
                str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;减少库存<input id='textfield' num_tid='" + teamid + "' name='deletenum" + num + "' type='text'   value='0' size='5' onkeyup=\"clearNoNum(this)\" />&nbsp;&nbsp;&nbsp;&nbsp;";
                str += "<input type='button' name='button' id='button' value='其他规格' onclick=\"additem('tb" + num + "','rule" + num + "','" + teammodel.inventory + "',document.getElementById('textfield').value," + teamid + ")\" />";
                str += "<input type='button' value='删除' onclick=\"deleteitem(this,'tb" + num + "'," + teamid + ",'" + teammodel.inventory + "')\"/>";
                str += "</td>";
                str += "</tr>";
                str += "</table>";

            }
            #endregion

            #region
            else
            {
                str += "<table id='tb" + num + "'>";
                string sum = "";//选择的数量
                string money = "";//选择的价格

                for (int i = 0; i < bullteam.Length; i++)
                {

                    string txt3 = bullteam[i];
                    str += "<tr>";
                    str += " <td colspan='7' bgcolor='#E4E4E4' class='deal-buy-desc' id='rule" + num + "'>";
                    sum = bullteam[i].Substring(bullteam[i].LastIndexOf(','), bullteam[i].Length - bullteam[i].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", "");
                    if (bullteam[i].Contains("价格"))
                    {
                        money = bullteam[i].Substring(0, bullteam[i].LastIndexOf(','));
                        money = money.Substring(money.LastIndexOf(','), money.Length - money.LastIndexOf(',')).Replace(",", "").Replace("价格", "").Replace(":", "").Replace("[", "").Replace("]", "");
                    }
                    else
                    {
                        money = bp.GetMoney(team_price);
                    }
                    #region
                    for (int k = 0; k < bulletinteam.Length - 1; k++)
                    {
                        str += "<b>" + bulletinteam[k].Split(':')[0] + ":</b>";
                        if (bulletinteam[k].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                        {
                            string[] bull = bulletinteam[k].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                            str += "<select name='rule" + num + "'>";
                            for (int h = 0; h < bull.Length; h++)
                            {
                                string txt6 = bullteam[i];
                                if (bullteam[i].Contains("[" + bull[h] + "]"))
                                {
                                    str += "<option value='" + bulletinteam[k].Split(':')[0] + ":" + bull[h] + "' selected='selected'>" + bull[h] + "</option>";
                                }
                                else
                                {
                                    if (back == 1)
                                    {
                                        str += "<option value='" + bulletinteam[k].Split(':')[0] + ":" + bull[h] + "'>" + bull[h] + "</option>";
                                    }
                                }
                            }
                            str += "</select>";
                        }
                    }
                    #endregion

                    if (back == 1)
                    {
                        str += "<b>价格：</b><input type=\"text\" value='" + bp.GetMoney(money) + "' onkeyup=\"checkIsNum(this," + bp.GetMoney(money) + ")\" size='5' name=\"bmoney" + num + "\"/>&nbsp;&nbsp;";
                        str += "总库存:" + sum;
                        str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;增加库存<input id='textfield' num_tid='" + teamid + "' name='insertnum" + num + "' type='text'   value='0' size='5' onkeyup=\"clearNoNum(this)\" />&nbsp;";
                        str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;减少库存<input id='textfield' num_tid='" + teamid + "' name='deletenum" + num + "' type='text'   value='0' size='5' onkeyup=\"clearNoNum(this)\" />&nbsp;&nbsp;&nbsp;&nbsp;";
                        str += "<input type='button' name='button' id='button' value='其他规格' onclick=\"additem('tb" + num + "','rule" + num + "','" + sum + "',document.getElementById('textfield').value," + model.Id + ")\" /> ";
                        str += "<input type='button' value='删除' onclick=\"deleteitem(this,'tb" + num + "'," + teamid + ",'" + sum + "')\"/>";
                    }
                    else
                    {
                        str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;数量<input id='textfield'  num_tid='" + model.Id + "' name='num" + num + "' type='text'  size='5' value=''   onkeyup=\"clearNoNum(this)\"/>&nbsp;&nbsp;&nbsp;&nbsp;";
                    }
                    str += "</td>";
                    str += "</tr>";
                }
                str += "</table>";
            }
            #endregion

            #endregion

        }


        return str;
    }
    #endregion

    #region 项目替换
    public static string Getbulletin(string bulletin)
    {
        string str = bulletin.Replace("{", "").Replace(":", "").Replace("[", "").Replace("]", "").Replace("}", "");
        return str;
    }
    #endregion
    
</script>
<script type="text/javascript" language="javascript">
    var num = 0;
    var txt;
    var sum = 0;
    function additem(id, rule, obj, txt, teamid) {
        var texts = $("input[num_tid='" + teamid + "'][type='text']");
        var td = $("td[tid='" + teamid + "']");
        var nownumber = 0;
        var totalnumber = 0;
        totalnumber = parseInt($(td).html());
        //$(texts[0]).val(parseInt($(texts[0]).val()) - 1);
        var row, cell, str;
        row = document.getElementById(id).insertRow(-1);
        if (row != null) {
            cell = row.insertCell(-1);
            cell.innerHTML = document.getElementById(rule).innerHTML;
            cell.className = "deal-buy-desc";
            cell.style.backgroundColor = "#e4e4e4";
            cell.setAttribute("colspan", 6)
            cell.id = "rule";
        }
        num++
        document.getElementsByName("totalNumber")[0].value = num;
    }


    function deleteitem(obj, id, teamid, totalnumber) {
        var texts = $("input[num_tid='" + teamid + "'][type='text']");
        var rowNum, curRow, ce;
        curRow = obj.parentNode.parentNode;
        rowNum = document.getElementById(id).rows.length - 1;
        ce = document.getElementById(id).rows[rowNum].getElementsByTagName("input")[0].value;
        if (rowNum >= 1) {

            //             if (parseInt($(texts[0]).val()) + parseInt(ce) > totalnumber) {
            //                 alert("数量已满,不能增加");
            //                 document.getElementById(id).deleteRow(curRow.rowIndex);
            //                 return;
            //             }
            //             $(texts[0]).val(parseInt($(texts[0]).val()) + parseInt(ce));
            document.getElementById(id).deleteRow(curRow.rowIndex);

        }

    }


    function isNum() {
        if (event.keyCode < 48 || event.keyCode > 57) {
            event.keyCode = 0;
        }
    }

    function clearNoNum(obj) {
        if ((obj.value != "") && (isNaN(obj.value) || parseInt(obj.value) <= 0)) {
            obj.value = "1";
        }

    }
    function checkIsNum(obj, money) {
        if ((obj.value != "") && (isNaN(obj.value) || parseInt(obj.value) <= 0)) {
            obj.value = money;
        }

    }

    function selectInput() {
        var isok = GetNotPrice();
        var falg = "";
        var str = "";
        var j = 0;
        var bull = $("select[name=rule0]");  // 这里也可以写成var obj = document.getElementByName("n1");
        var num = document.getElementsByName("num0");
        var insertnum = document.getElementsByName("insertnum0");
        var deletenum = document.getElementsByName("deletenum0");
        var arrText = new Array();
        var bmoney = document.getElementsByName("bmoney0");


        str += "";
        str += "{";
        falg = "";
        for (var i = 0; i < bull.length; i++) {
            if (falg == bull[i].value.split(":")[0]) {
                if (isok) {
                    str += "价格:[" + bmoney[j].value + "],";
                }
                str += "数量:[" + parseInt((insertnum[j].value) - (deletenum[j].value)) + "]";
                str += "}|";
                j++;
                str += "{";
                str += bull[i].value.split(":")[0] + ":";
                str += "[";
                str += bull[i].value.split(":")[1] + "],";
            }
            else {
                str += bull[i].value.split(":")[0] + ":";
                str += "[";
                str += bull[i].value.split(":")[1] + "],";
                if (falg == "") {
                    falg = bull[i].value.split(":")[0];
                }

            }
        }
        if (isok) {
            str += "价格:[" + bmoney[j].value + "],";
        }
        str += "数量:[" + parseInt((insertnum[j].value) - (deletenum[j].value)) + "]";
        str += "}";
        return str;

    }
    function Getinventory() {
        var ad = document.getElementById("inserttory").value;
        var de = (document.getElementById('deletetory').value);
        var sum = parseInt(ad - de);
        return sum;
    }
    function GetNotPrice() {
        var isok = false;
        var bmoney = document.getElementsByName("bmoney0");
        if (bmoney.length > 0) {
            for (var i = 0; i < bmoney.length; i++) {
                if (bmoney[0].value != bmoney[i].value) {
                    isok = true;
                    break;
                }
            }
        }
        return isok;
    }
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 900px;">
    <h3>
        <span id="Span1" class="close" onclick="return X.boxClose();">关闭</span>请输入库存<font
            style="color: red">(初始化时，为当前项目剩余库存数量。如果要增加5个，请增加库存5.如果要减少5，请减少库存为5，最后点击提交)</font></h3>
    <p id="coupon-dialog-display-id1" style="color: Red;">
    </p>
    <%
        if (bulletin != "")
        {
    %>
    <table id="tb" style="margin-left: 10px;">
        <%=bulletin%>
    </table>
    <br />
    <p class="act">
        <input type="button" value="提交" class="formbutton" name="query" onclick="X.coupon.invent(<%=Teamid %>,encodeURIComponent(selectInput()),'<%=p %>');return false;" />
        <% }
         else
         {%>
        库存数量：<%=inventory%>&nbsp;&nbsp;&nbsp;&nbsp;增加库存<input id="inserttory" type="text"
            name="inserttory" value="0" />减少库存<input id="deletetory" type="text" name="deletetory"
                value="0" />
        <br />
    </p>
    <p class="act">
        <input type="button" value="提交" class="formbutton" name="query" onclick="X.coupon.invent(<%=Teamid %>,Getinventory(),'<%=p%>');return false;" />
        <% }%>
    </p>
</div>
