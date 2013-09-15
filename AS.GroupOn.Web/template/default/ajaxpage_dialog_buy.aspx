<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script type="text/javascript" language="javascript">
    var num = 0;
    var txt;
    var sum = 0;

    function additem(obj,id, rule, obj, txt, teamid) {
        rows=rows+1;
        var texts = $("input[num_tid='" + teamid + "'][type='text']");
        var td = $("td[tid='" + teamid + "']");
        var nownumber = 0;
        var totalnumber = 0;
        totalnumber = parseInt($(td).html());

        for (var i = 0; i < $(texts).length; i++) {
            if (parseInt($(texts).eq(i).val()) <= 0) {
                alert("数量应大于0");
                return false;
            }
            nownumber = nownumber + parseInt($(texts).eq(i).val());
        }
        var row, cell, str;
        row = document.getElementById(id).insertRow(-1);
        if (row != null) {
            cell = row.insertCell(-1);
            cell.innerHTML = document.getElementById(rule).innerHTML.replace(/rows="(\d+)"/g, "rows=\"" + rows.toString() + "\"");
            cell.className = "deal-buy-desc";
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


    function selectInput() {

        var falg = "";
        var str = "";
        var j = 0;
        var bull = $("select[name=rule0]");  // 这里也可以写成var obj = document.getElementByName("n1");
        var num = document.getElementsByName("num0");
      
        var arrText = new Array();
        str += "";
        str += "{";
        falg = "";
        for (var i = 0; i < bull.length; i++) {
            if (falg == bull[i].value.split(":")[0]) {

                str += "数量:[" +num[j].value + "]";
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

        str += "数量:[" + num[j].value + "]";
        str += "}";
      
        return str;

    }

    function checkintory(obj) {
       var objs= $("select[name='" + $(obj).attr("name") + "'][rows='"+$(obj).attr("rows")+"']");
       var vals="";
       for(var i=0;i<objs.length;i++) {
           var val = objs.eq(i).val();
           val=val.replace(/(.+):(.+)/,"$1:[$2]");
           vals = vals + val+",";
            //val=val+"{大小:[L],颜色:[蓝],数量:[100]}";
       }
       vals="{"+vals+"数量:["+$("input[type='text'][rows='"+$(obj).attr("rows")+"']").val()+"]"+"}";
           X.coupon.checkshopcar(<%=Teamid %>,encodeURIComponent(vals));

    }
  
</script>
<script runat="server">
    
    public ITeam teammodel = Store.CreateTeam();

    public string bulletin = "";
    public int sum = 0;
    public int Teamid = 0;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (Request["teamid"] != null && Request["count"] != null)
        {

            using (AS.GroupOn.DataAccess.IDataSession seion = Store.OpenSession(false))
            {
                teammodel = seion.Teams.GetByID(Convert.ToInt32(Request["teamid"].ToString()));
            }
            string txt = Request["result"];
            Teamid = Convert.ToInt32(Request["teamid"]);
            bulletin = Getfont(0, Convert.ToInt32(Request["teamid"]), Convert.ToInt32(Request["count"]), Helper.GetString(Request["result"].Replace("-", "|").Replace(".", ","), ""));
        }
    }

    #region 显示颜色或者尺寸  back参数：判断显示在前台，和后台 0：前台，1：后台------------buy
    public static string Getfont(int num, int teamid, int count, string oldresult)
    {
        string str = "";
        string bulletin = "";

        ITeam teammodel = Store.CreateTeam();
        string sum = "0";
        using (AS.GroupOn.DataAccess.IDataSession seion = Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(teamid);
        }
        if (teammodel != null)
        {
            bulletin = teammodel.bulletin;
            if (Utilys.Getbulletin(bulletin) != "")
            {
                #region
                string[] bulletinteam = bulletin.Replace("{", "").Replace("}", "").Split(',');
                string[] bullteam = teammodel.invent_result.Replace("{", "").Replace("}", "").Split('|');
                string[] oldteam = oldresult.Replace("{", "").Replace("}", "").Split('|');
                #region

                int rows = 0; //规格行数初始数量
                if (oldresult == "")
                {
                    str += "<table id='tb" + num + "'>";
                    str += "<tr>";
                    str += " <td colspan='7' bgcolor='#E4E4E4' class='deal-buy-desc' id='rule" + num + "'>";

                    for (int i = 0; i < bulletinteam.Length; i++)
                    {
                        if (bulletinteam[i].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                        {
                            str += "<b>" + bulletinteam[i].Split(':')[0] + ":</b>";
                            string[] bull = bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                            str += "<select name='rule" + num + "' rows='" + rows + "' onchange='checkintory(this)'>";
                            for (int j = 0; j < bull.Length; j++)
                            {
                                str += "<option value='" + bulletinteam[i].Split(':')[0] + ":" + bull[j] + "'>" + bull[j] + "</option>";
                            }
                            str += "</select>";
                        }
                    }
                    str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;数量<input id='textfield' num_tid='" + teamid + "' rows='" + rows + "' name='num" + num + "' type='text'   value='" + count + "' size='5' require='true' datatype='number' group='a' />&nbsp;&nbsp;&nbsp;&nbsp;";
                    str += "<input type='button' name='button' id='button' rows='" + rows + "' value='其他规格' onclick=\"additem(this,'tb" + num + "','rule" + num + "','" + count + "',document.getElementById('textfield').value," + teamid + ")\" />";
                    str += "<input type='button' value='删除' onclick=\"deleteitem(this,'tb" + num + "'," + teamid + ",'" + count + "')\"/>";
                    str += "</td>";
                    str += "</tr>";
                    StringBuilder sb = new StringBuilder();
                    sb.Append("</table><script>var rows=" + rows + ";</");
                    sb.Append("script>");
                    str += sb.ToString();
                }
                else
                {
                    #region

                    str += "<table id='tb" + num + "'>";
                    for (int i = 0; i < oldteam.Length; i++)
                    {
                        rows = rows + 1;
                        str += "<tr>";
                        str += " <td colspan='7' bgcolor='#E4E4E4' class='deal-buy-desc' id='rule" + num + "'>";
                        sum = oldteam[i].Substring(oldteam[i].LastIndexOf(','), oldteam[i].Length - oldteam[i].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", "");
                        #region
                        for (int k = 0; k < bulletinteam.Length; k++)
                        {
                            str += "<b>" + bulletinteam[k].Split(':')[0] + ":</b>";
                            if (bulletinteam[k].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                            {
                                string[] bull = bulletinteam[k].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                                str += "<select name='rule" + num + "' onchange='checkintory(this)' rows='" + rows + "'>";
                                for (int h = 0; h < bull.Length; h++)
                                {
                                    string txt6 = oldteam[i];
                                    if (oldteam[i].Contains(bull[h]))
                                    {
                                        str += "<option value='" + bulletinteam[k].Split(':')[0] + ":" + bull[h] + "' selected='selected'>" + bull[h] + "</option>";
                                    }
                                    else
                                    {

                                        str += "<option value='" + bulletinteam[k].Split(':')[0] + ":" + bull[h] + "'>" + bull[h] + "</option>";
                                    }
                                }
                                str += "</select>";
                            }
                        }
                        #endregion
                        str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;数量<input id='textfield' num_tid='" + teamid + "' name='num" + num + "' rows='" + rows + "' type='text'  size='5'  value='" + sum + "'  require='true' datatype='number' group='a'/>&nbsp;&nbsp;&nbsp;&nbsp;";
                        str += "<input type='button' name='button' id='button' value='其他规格' rows='" + rows + "' onclick=\"additem(this,'tb" + num + "','rule" + num + "','" + sum + "',document.getElementById('textfield').value," + teamid + ")\" /> ";
                        str += "<input type='button' value='删除' onclick=\"deleteitem(this,'tb" + num + "'," + teamid + ",'" + sum + "')\"/>";
                        str += "</td>";
                        StringBuilder sb = new StringBuilder();
                        sb.Append("</tr><script>var rows=" + rows + ";</");
                        sb.Append("script>");

                        str += sb.ToString();
                    }
                    #endregion
                }

            }
                #endregion



                #endregion

        }

        return str;
    }
    #endregion
    

    
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 500px;">
    <input type="hidden" name="totalNumber" value="" />
    <h3>
        <span id="Span1" class="close" onclick="return X.boxClose();">关闭</span>请选择规格<font
            style="color: red"></font></h3>
    <p id="coupon-dialog-display-id1" style="color: Red;">
    </p>
    <table id="tb">
        <%=bulletin%>
    </table>
    <br />
    <p class="act">
        <input type="submit" value="提交" group="a" class="formbutton validator" name="query"
            onclick="X.coupon.buy(<%=Teamid %>,encodeURIComponent(selectInput()));return false;" />
    </p>
</div>
