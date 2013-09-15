<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
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
    protected int request_time = -1;
    protected string request_firstTime = String.Empty;
    protected string request_endTime = String.Empty;
    protected int request_express = 0;
    protected int request_selecttype = -1;
    protected int request_date = -1;
    protected string request_content = String.Empty;

    private string url = String.Empty;
    public string GetUrl()
    {
        return url;
    }

    private int partnerId;

    public int PartnerId
    {
        get { return partnerId; }
        set { partnerId = value; }
    }

    private string express = String.Empty;
    public string Express
    {
        get
        {
            if (express == String.Empty)
            {
                IList<Hashtable> table = null;
                TeamFilter teamfilter = new TeamFilter();
                teamfilter.branch_id = Helper.GetInt(CookieUtils.GetCookieValue("pbranch"), 0);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    table = session.Teams.GetpBranch1(teamfilter);
                }
                express = express + "<option value='0'></option>";
                foreach (Hashtable ht in table)
                {
                    express = express + "<option value='" + ht["Express_id"] + "'>" + ht["Category_name"] + "(" + ht["num"] + ")</option>";
                }
            }
            return express;
        }

    }


    private bool searchexpress = false;
    public bool SearchExpress
    {
        get
        {
            return searchexpress;
        }
        set
        {
            searchexpress = value;
        }
    }
    /// <summary>
    /// 订单查询
    /// </summary>
    /// <returns></returns>
    public string GetWhereString()
    {
        int key = Helper.GetInt(Request["key"], 1);
        url = url + "&key=" + key;
        string wherestring = String.Empty;
        if (Request.HttpMethod == "POST")
        {
            request_time = Helper.GetInt(Request.Form["time"], -1);
            request_selecttype = Helper.GetInt(Request.Form["selecttype"], -1);
            request_date = Helper.GetInt(Request.Form["date"], -1);
            request_firstTime = Helper.GetString(Request.Form["firstTime"], String.Empty);
            request_endTime = Helper.GetString(Request.Form["endTime"], String.Empty);
            request_content = Helper.GetString(Request.Form["searchcontent"], String.Empty);
            if (SearchExpress)
            {
                request_express = Helper.GetInt(Request.Form["express"], 0);
            }
        }
        else
        {
            request_time = Helper.GetInt(Request.QueryString["time"], -1);
            request_selecttype = Helper.GetInt(Request.QueryString["selecttype"], -1);
            request_date = Helper.GetInt(Request.QueryString["date"], -1);
            request_firstTime = Helper.GetString(Request.QueryString["firstTime"], String.Empty);
            request_endTime = Helper.GetString(Request.QueryString["endTime"], String.Empty);
            request_content = Helper.GetString(Request.QueryString["searchcontent"], String.Empty);
            if (SearchExpress)
            {
                request_express = Helper.GetInt(Request.QueryString["express"], 0);
            }
        }
        if (1 == 1)
        {
            if (Helper.GetDateTime(request_firstTime, DateTime.MinValue) != DateTime.MinValue)
            {

                if (request_time > -1 && request_time < 24)
                {
                    url = url + "&firstTime=" + request_firstTime + "&time=" + request_time;
                    wherestring = wherestring + " and Pay_time>='" + Helper.GetDateTime(request_firstTime, DateTime.Now).ToString("yyyy-MM-dd " + request_time + ":0:0") + "'";
                }
                else
                {
                    url = url + "&firstTime=" + request_firstTime;
                    wherestring = wherestring + " and Pay_time>='" + Helper.GetDateTime(request_firstTime, DateTime.Now).ToString("yyyy-MM-dd 0:0:0") + "'";
                }
            }
            if (Helper.GetDateTime(request_endTime, DateTime.MinValue) != DateTime.MinValue)
            {
                if (request_time > -1 && request_time < 24)
                {
                    url = url + "&endTime=" + request_endTime;
                    wherestring = wherestring + " and Pay_time<='" + Helper.GetDateTime(request_endTime, DateTime.Now).ToString("yyyy-MM-dd " + request_time + ":59:59") + "'";
                }
                else
                {
                    url = url + "&endTime=" + request_endTime;
                    wherestring = wherestring + " and Pay_time<='" + Helper.GetDateTime(request_endTime, DateTime.Now).ToString("yyyy-MM-dd 23:59:59") + "'";
                }
            }
        }
        if (request_content.Length > 0)
        {
            switch (request_selecttype)
            {
                case 1:
                    wherestring = wherestring + " and user_id in(select id from [user] where Username like '" + request_content + "%')";
                    break;
                case 2:
                    wherestring = wherestring + " and user_id in(select id from [user] where email like '" + request_content + "%')";
                    break;
                case 3:
                    wherestring = wherestring + " and id=" + Helper.GetInt(request_content, 0);
                    break;
                case 4:
                    wherestring = wherestring + " and (team_id=" + Helper.GetInt(request_content, 0) + " or id in(select order_id from orderdetail where teamid=" +Helper.GetInt(request_content, 0) + "))";
                    break;
                case 5:
                    string[] temp = request_content.Split(new string[] { "as" }, StringSplitOptions.RemoveEmptyEntries);
                    if (temp.Length >= 3)
                    {
                        wherestring = wherestring + " and pay_id like '" + temp[0] + "as" + temp[1] + "as" + temp[2] + "as" + "%'";
                    }
                    break;
                case 6:
                    wherestring = wherestring + " and Express_no='" + request_content + "'";
                    break;
                case 7:
                    wherestring = wherestring + " and mobile like '" + request_content + "%'";
                    break;
                case 8:
                    wherestring = wherestring + " and address like '%" + request_content + "%'";
                    break;
            }
            url = url + "&selecttype=" + request_selecttype;
            url = url + "&searchcontent=" + Server.UrlEncode(request_content);

        }
        if (SearchExpress)
        {
            express = String.Empty;
            url = url + "&express=" + request_express;
            
            IList<Hashtable> table = null;
            TeamFilter tfilter = new TeamFilter();
            tfilter.branch_id = Helper.GetInt(CookieUtils.GetCookieValue("pbranch"), 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                table = session.Teams.GetpBranch1(tfilter);
            }
            express = express + "<option value='0'></option>";
            foreach (Hashtable ht in table)
            {
                if (Helper.GetInt(ht["Express_id"], 0) == request_express)
                    express = express + "<option selected value='" + ht["Express_id"] + "'>" + ht["Category_name"] + "(" + ht["num"] + ")</option>";
                else
                    express = express + "<option value='" + ht["Express_id"] + "'>" + ht["Category_name"] + "(" + ht["num"] + ")</option>";
            }
            if (request_express > 0)
                wherestring = wherestring + " and express_id=" + request_express;
        }
        url = url + "&page={0}";
        url = "?" + url.Substring(1);
        if (Request.Url.Query.Length > 0)
            url = Request.Url.AbsoluteUri.Replace(Request.Url.Query, "") + url;
        else
            url = Request.Url.AbsoluteUri + url;

        return wherestring;
    }
</script>
<li>日期:
    <input name="firstTime" id="firstTime" datatype="date" value="<%=request_firstTime %>"
        class="h-input" style="width: 70px;" type="text">
    &nbsp;至
    <input name="endTime" id="endTime" datatype="date" value="<%=request_endTime %>"
        class="h-input" style="width: 70px;" type="text">
    <select name="time" class="h-input" style="width:50px;">
        <option value=""></option>
        <option value="0" <%if(request_time==0){%> selected<%}%>>0</option>
        <option value="1" <%if(request_time==1){%> selected<%}%>>1</option>
        <option value="2" <%if(request_time==2){%> selected<%}%>>2</option>
        <option value="3" <%if(request_time==3){%> selected<%}%>>3</option>
        <option value="4" <%if(request_time==4){%> selected<%}%>>4</option>
        <option value="5" <%if(request_time==5){%> selected<%}%>>5</option>
        <option value="6" <%if(request_time==6){%> selected<%}%>>6</option>
        <option value="7" <%if(request_time==7){%> selected<%}%>>7</option>
        <option value="8" <%if(request_time==8){%> selected<%}%>>8</option>
        <option value="9" <%if(request_time==9){%> selected<%}%>>9</option>
        <option value="10" <%if(request_time==10){%> selected<%}%>>10</option>
        <option value="11" <%if(request_time==11){%> selected<%}%>>11</option>
        <option value="12" <%if(request_time==12){%> selected<%}%>>12</option>
        <option value="13" <%if(request_time==13){%> selected<%}%>>13</option>
        <option value="14" <%if(request_time==14){%> selected<%}%>>14</option>
        <option value="15" <%if(request_time==15){%> selected<%}%>>15</option>
        <option value="16" <%if(request_time==16){%> selected<%}%>>16</option>
        <option value="17" <%if(request_time==17){%> selected<%}%>>17</option>
        <option value="18" <%if(request_time==18){%> selected<%}%>>18</option>
        <option value="19" <%if(request_time==19){%> selected<%}%>>19</option>
        <option value="20" <%if(request_time==20){%> selected<%}%>>20</option>
        <option value="21" <%if(request_time==21){%> selected<%}%>>21</option>
        <option value="2" <%if(request_time==22){%> selected<%}%>>22</option>
        <option value="23" <%if(request_time==23){%> selected<%}%>>23</option>
    </select>时&nbsp;
    <%if (SearchExpress)
      { %>
    物流公司:
    <select name="express" id="express" class="h-input">
        <%=Express%>
    </select>
    <%} %>
    &nbsp;筛选条件：
    <select name="selecttype" id="selecttype" class="h-input">
        <option value=""></option>
        <option value="1" <%if(request_selecttype==1){%> selected<%}%>>用户名</option>
        <option value="2" <%if(request_selecttype==2){%> selected<%}%>>Email</option>
        <option value="3" <%if(request_selecttype==3){%> selected<%}%>>订单编号</option>
        <option value="4" <%if(request_selecttype==4){%> selected<%}%>>项目ID</option>
        <option value="5" <%if(request_selecttype==5){%> selected<%}%>>交易单号</option>
        <option value="6" <%if(request_selecttype==6){%> selected<%}%>>快递单号</option>
        <option value="7" <%if(request_selecttype==7){%> selected<%}%>>手机号</option>
        <option value="8" <%if(request_selecttype==8){%> selected<%}%>>派送地址</option>
    </select>
    &nbsp;内容：<input name="searchcontent" id="searchcontent" value="<%=request_content %>"
        type="text" class="h-input">
    <input name="btnSelect" type="submit" class="formbutton" style="padding: 1px 6px;
        width: 60px;" value="筛选">
    <%if (SearchExpress && request_express > 0)
      { %>
    <input type="button" class="formbutton" value="批量打印" style="padding: 1px 6px; width: 60px;"
        onclick="print()" id="printall" name="printall">
    <%} %>
</li>
