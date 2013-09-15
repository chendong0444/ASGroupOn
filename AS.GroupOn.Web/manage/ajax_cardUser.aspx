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

    protected int totalpage = 0;
    protected string url = "";
    
    protected string firstTime = "";
    protected string endTime = "";
    protected int time = -1;
    protected int orderCount = 0;
    protected string city = String.Empty;
    protected string level = "";
    protected int teamId = 0;
    string shaiXuan = "";
    protected int Listcount = 0;
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        
        //注册时间
        firstTime = Helper.GetString(Request["firstTime"], String.Empty);
        endTime = Helper.GetString(Request["endTime"], String.Empty);
        time = Helper.GetInt(Request["time"], -1);
        //付款订单数
        orderCount = Helper.GetInt(Request["orderCount"], 0);
        //所在城市
        city = Helper.GetString(Request["city"], String.Empty);
        //用户级别
        level = Helper.GetString(Request["level"], String.Empty);
        //购买指定项目ID
        teamId = Helper.GetInt(Request["teamId"], 0);
        ////付款时间
        //orderFirstTime = Utils.Helper.GetString(Request["orderFirstTime"], String.Empty);
        //orderEndTime = Utils.Helper.GetString(Request["orderEndTime"], String.Empty);
        //筛选后
        shaiXuan = Helper.GetString(Request["shaiXuan"], String.Empty);

        string action = Helper.GetString(Request["action"], String.Empty);
        if (action == "userInfo")
        {
            SelectUser();
        }
        if (action == "saveUser")
        {
            SaveUser();
        }
    }

    public void SelectUser()
    {
        CardFilter cardfilter = new CardFilter();
        IList<ICard> iListCard = null;
        IPagers<ICard> pager = null;
        
        #region 筛选条件
        if (Helper.GetDateTime(firstTime, DateTime.MinValue) != DateTime.MinValue)
        {
            if (time > -1 && time < 24)
            {
                cardfilter.FromuCreate_time = Helper.GetDateTime(firstTime, DateTime.Now);
            }
            else
            {
                cardfilter.FromuCreate_time = Helper.GetDateTime(firstTime, DateTime.Now);
            }
        }
        if (Helper.GetDateTime(endTime, DateTime.MinValue) != DateTime.MinValue)
        {
            if (time > -1 && time < 24)
            {
                cardfilter.TouCreate_time = Helper.GetDateTime(endTime, DateTime.Now);
            }
            else
            {
                cardfilter.TouCreate_time = Helper.GetDateTime(endTime, DateTime.Now);
            }
        }
        //付款订单数
        if (orderCount != 0)
        {
            cardfilter.FromoCount = orderCount;
        }
        //所在城市
        if (city != "")
        {
            if (city != "0")
            {
                cardfilter.uCity_id = city;
            }

        }
        //用户级别
        if (level != "")
        {
            IUserlevelrules iuserleve = null;
            UserlevelrulesFilters userlevefilter = new UserlevelrulesFilters();
            userlevefilter.levelid = int.Parse(level);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iuserleve = session.Userlevelrelus.Get(userlevefilter);
            }
            if (iuserleve != null)
            {
                cardfilter.TouTotalamount = iuserleve.maxmoney.ToString();
                cardfilter.FromuTotalamount = iuserleve.minmoney.ToString();
            }
        }
        if (teamId != 0)
        {
            url = url + "&page={0}";
            url = "Youhui_Daijinquan.aspx?" + url.Substring(1);
            cardfilter.teamid = teamId;
            cardfilter.PageSize = 5;
            cardfilter.AddSortOrder(CardFilter.uId_Desc);
            cardfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request["page"], 1);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pager = session.Card.GetPagerHBShaiXuanTid(cardfilter);
            }
            iListCard = pager.Objects;
            Listcount = pager.TotalRecords;
        }
        else
        {
            url = url + "&page={0}";
            url = "ajax_cardUser.aspx?" + url.Substring(1);
            cardfilter.PageSize = 5;
            cardfilter.AddSortOrder(CardFilter.uId_Desc);
            cardfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request["page"], 1);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pager = session.Card.GetPagerHBShaiXuan(cardfilter);
            }
            iListCard = pager.Objects;
            Listcount = pager.TotalRecords;
        }
        #endregion

        string printdata = "";
        string[] strCloName = { "uId", "uEmail", "uUserName", "uRealname", "city", "uMoney", "level", "uZipcode", "uCreate_time", "oCount", "uMobile" };
        //格式化的url
        printdata = DataTableToJson("myJson", iListCard, strCloName);
        Response.Write(printdata);
    }

    //将DataTable转换成Json
    public string DataTableToJson(string jsonName, IList<ICard> iListCards, string[] strCName)
    {
        int strtotalpage = Listcount / 5 + ((Listcount % 5 > 0) ? 1 : 0);
        StringBuilder Json = new StringBuilder();
        Json.Append("{\"" + jsonName + "\":[");
        if (iListCards.Count > 0)
        {
            foreach (ICard icardInfo in iListCards)
            {
                string struId = "";
                string struEmail = "";
                string struUserName = "";
                string struRealName = "";
                string strCityName = "";
                string struMoney = "";
                string strLeve = "";
                string struZipCode = "";
                string struCreateTime = "";
                string stroCount = "";
                string struMobile = "";

                Json.Append("{");
                if (icardInfo.uId != null && icardInfo.uId.ToString() != "")
                {
                    struId = icardInfo.uId.ToString();
                }
                if (icardInfo.uEmail != null && icardInfo.uEmail != "")
                {
                    struEmail = icardInfo.uEmail;
                }
                if (icardInfo.uUserName != null && icardInfo.uUserName != "")
                {
                    struUserName = icardInfo.uUserName;
                }
                if (icardInfo.uRealname != null && icardInfo.uRealname != "")
                {
                    struRealName = icardInfo.uRealname;
                }
                if (icardInfo.Category != null)
                {
                    if (icardInfo.Category.Name != null && icardInfo.Category.Name != "")
                    {
                        strCityName = icardInfo.Category.Name;
                    }
                }
                else
                {
                    strCityName = "全部城市";
                }
                if (icardInfo.uMoney != null && icardInfo.uMoney.ToString() != "")
                {
                    struMoney = icardInfo.uMoney.ToString();
                }
                if (icardInfo.uTotalamount != null && icardInfo.uTotalamount.ToString() != "")
                {
                    strLeve = Utilys.GetUserLevel(icardInfo.uTotalamount);
                }
                if (icardInfo.uZipcode != null && icardInfo.uZipcode != "")
                {
                    struZipCode = icardInfo.uZipcode;
                }
                if (icardInfo.uCreate_time != null && icardInfo.uCreate_time.ToString() != "")
                {
                    struCreateTime = icardInfo.uCreate_time.ToString();
                }
                if (icardInfo.oCount != null && icardInfo.oCount.ToString() != "")
                {
                    stroCount = icardInfo.oCount.ToString();
                }
                if (icardInfo.uMobile != null && icardInfo.uMobile != "")
                {
                    struMobile = icardInfo.uMobile;
                }

                Json.Append("\"" + strCName[0] + "\":\"" + struId + "\"" + ",");
                Json.Append("\"" + strCName[1] + "\":\"" + struEmail + "\"" + ",");
                Json.Append("\"" + strCName[2] + "\":\"" + struUserName + "\"" + ",");
                Json.Append("\"" + strCName[3] + "\":\"" + struRealName + "\"" + ",");
                Json.Append("\"" + strCName[4] + "\":\"" + strCityName + "\"" + ",");
                Json.Append("\"" + strCName[5] + "\":\"" + struMoney + "\"" + ",");
                Json.Append("\"" + strCName[6] + "\":\"" + strLeve + "\"" + ",");
                Json.Append("\"" + strCName[7] + "\":\"" + struZipCode + "\"" + ",");
                Json.Append("\"" + strCName[8] + "\":\"" + struCreateTime + "\"" + ",");
                Json.Append("\"" + strCName[9] + "\":\"" + stroCount + "\"" + ",");
                Json.Append("\"" + strCName[10] + "\":\"" + struMobile + "\"");

                Json.Append("}");
                Json.Append(",");
            }
            Json.Append("{");
            Json.Append("\"totalpage\":\"" + strtotalpage + "\",\"userCount\":\"" + Listcount + "\",\"firstTime\":\"" + firstTime + "\",\"endTime\":\"" + endTime + "\",\"time\":\"" + time + "\",\"orderCount\":\"" + orderCount + "\",\"city\":\"" + city + "\",\"teamId\":\"" + teamId + "\",\"orderFirstTime\":\"" + 1 + "\",\"orderEndTime\":\"" + 1 + "\"}");
        }
        Json.Append("]}");
        return Json.ToString();
    }

    public void SaveUser()
    {
        if (shaiXuan == "shaiXuan")
        {
            #region 筛选条件
            string sql = " 1=1 ";
            string teamkey = " ";
            if (Helper.GetDateTime(firstTime, DateTime.MinValue) != DateTime.MinValue)
            {
                if (time > -1 && time < 24)
                {
                    sql += " and uCreate_time>='" + Helper.GetDateTime(firstTime, DateTime.Now).ToString("yyyy-MM-dd " + time + ":0:0") + "' ";
                }
                else
                {
                    sql += "and uCreate_time>='" + Helper.GetDateTime(firstTime, DateTime.Now).ToString("yyyy-MM-dd 0:0:0") + "' ";
                }
            }
            if (Helper.GetDateTime(endTime, DateTime.MinValue) != DateTime.MinValue)
            {
                if (time > -1 && time < 24)
                {
                    sql += " and uCreate_time<='" + Helper.GetDateTime(endTime, DateTime.Now).ToString("yyyy-MM-dd " + time + ":59:59") + "' ";
                }
                else
                {
                    sql += " and uCreate_time<='" + Helper.GetDateTime(endTime, DateTime.Now).ToString("yyyy-MM-dd 23:59:59") + "' ";
                }
            }
            //付款订单数
            if (orderCount != 0)
            {
                sql += " and oCount>=" + orderCount + " ";
            }
            //所在城市
            if (city != "")
            {
                if (city != "0")
                {
                    sql += " and uCity_id=" + city + " ";
                }
            }

            //用户级别
            if (level != "")
            {
                IUserlevelrules iuserleve = null;
                UserlevelrulesFilters userlevefilter = new UserlevelrulesFilters();
                userlevefilter.levelid = int.Parse(level);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iuserleve = session.Userlevelrelus.Get(userlevefilter);
                }
                if (iuserleve != null)
                {
                    sql = sql + " and uTotalamount<=" + iuserleve.maxmoney.ToString() + " and  uTotalamount>" + iuserleve.minmoney.ToString();
                }
                
            }

            //查询字段
            string strFields = " uId ";
            //表名
            if (teamId != 0)
            {
                sql = sql + " and teamid=" + teamId;
                teamkey = " teamid, ";
            }

            //表名


            string strTable = " (select " + teamkey + "oCount,userid as uId,Username as uUsername,Email as uEmail,Zipcode as uZipcode ,Mobile as uMobile,Money as uMoney,totalamount as uTotalamount,Realname as uRealname,City_id as uCity_id,Create_time as uCreate_time  from ( select " + teamkey + "SUM(aa) as oCount,userid from ( select teamid ,COUNT(oid ) as aa,userid ";
            strTable = strTable + "  from(select ISNULL(Teamid,Team_id) as teamid,[Order].id as oid ,User_id  as userid from [Order] ";
            strTable = strTable + " left join orderdetail on([Order].Id=[orderdetail].Order_id)  ";
            strTable = strTable + " where state='pay' or State='scorepay' group by teamid,Team_id,[Order].id ,User_id   )t  ";
            strTable = strTable + " inner join Team on(Team.Id=t.teamid)   ";
            strTable = strTable + "  group by oid,teamid, userid ) tt group by " + teamkey + " userid) ttt,[User] where userid=[User].id ) tttt ";

            string strsql = "select " + strFields + " from " + strTable + " where " + sql+" order by uId desc";
            #endregion

            IList<ICard> iListCard = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iListCard = session.Card.GetList(strsql);
            }

            StringBuilder stbId = new StringBuilder();
            foreach (ICard iacardInfo in iListCard)
            {
                stbId.Append("," + iacardInfo.uId);
            }
            string userId = Helper.GetString(stbId.ToString().Substring(1), string.Empty);
            Session["getUserId"] = userId;
            Session.Timeout = 3;
            Response.Write(userId);
        }
        else
        {
            Session["getUserId"] = "";
        }
    }
    
</script>

