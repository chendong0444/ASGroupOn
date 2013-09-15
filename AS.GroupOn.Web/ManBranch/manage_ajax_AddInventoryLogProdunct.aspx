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
    protected IProduct promodel =null;
    protected ProductFilter proft= new ProductFilter();
    protected IOrder ordermodel = AS.GroupOn.App.Store.CreateOrder();
    protected Iinventorylog inventlogmodel = null;
    protected InventorylogFilter inventlogft = new InventorylogFilter();
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
                promodel = session.Product.GetByID(AS.Common.Utils.Helper.GetInt(Request["id"].ToString(), 0));
            }            
            inventory = promodel.inventory;
            Teamid = Convert.ToInt32(Request["id"]);
            p = Request["p"];
            bulletin = AS.GroupOn.Controls.Utilys.GetTestProduct(0, ordermodel, Convert.ToInt32(Request["id"]), 1);

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

        var falg = "";
        var str = "";
        var j = 0;
        var bull = $("select[name=rule0]");  // 这里也可以写成var obj = document.getElementByName("n1");
        var insertnum = document.getElementsByName("insertnum0");
        var deletenum = document.getElementsByName("deletenum0");
        var arrText = new Array();
        var bmoney = document.getElementsByName("bmoney0");
        str += "";
        str += "{";
        falg = "";
        for (var i = 0; i < bull.length; i++) {
            if (falg == bull[i].value.split(":")[0]) {
                str += "价格:[" + bmoney[j].value + "],";
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
        str += "价格:[" + bmoney[j].value + "],";
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
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:900px;">
<h3><span id="Span1" class="close" onclick="return X.boxClose();">关闭</span>请输入库存<font style="color:red">(初始化时，为当前项目剩余库存数量。如果要增加5个，请增加库存5.如果要减少5，请减少库存为5，最后点击提交)</font></h3>
<p id="coupon-dialog-display-id1" style="color:Red;"></p>
<br />    
     <%
         if (bulletin != "")
          {
          %>
       <table id="tb" style="margin-left:10px;">
       <%=bulletin%>
       </table>      
	<p class="act">	<input type="button" value="提交"  class="formbutton"  name="query"  onclick="X.coupon.pinvent(<%=Teamid %>,encodeURIComponent(selectInput()),'<%=p %>');return false;"  />
       <% }
          else
          {%>
         库存数量：<%=inventory%>&nbsp;&nbsp;&nbsp;&nbsp;增加库存<input id="inserttory" type="text" name="inserttory"   value="0"  />减少库存<input id="deletetory" type="text" name="deletetory"  value="0" />
         <br />
         </p>

	<p class="act">	<input type="button" value="提交"  class="formbutton"  name="query"  onclick="X.coupon.pinvent(<%=Teamid %>,Getinventory(),'<%=p%>');return false;"  />
       <% }%>     
     </p>
</div>

