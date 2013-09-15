<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace=" System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    public ITeam teammodel = Store.CreateTeam();
    public int num = 0;
    public bool invent = false;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!Page.IsPostBack)
        {
            OrderMethod.ClearCar();
            if (Request["id"] != null)
            {
                int num = num = Utility.Getnum(Request["result"]);
                judge(Helper.GetInt(Request["id"], 0), num, Request["result"]);

            }
        }
    }
    #region
    public void judge(int teamid, int num, string carresult)
    {
        string result = "";
        bool isExistrule = false;

        using (IDataSession seion = Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(teamid);
        }
        if (teammodel != null)
        {
            if (teammodel.open_invent == 1)//开启库存
            {
                invent = Utility.isinvent(Helper.GetString(carresult, ""), Helper.GetString(teammodel.invent_result, ""));
                isExistrule = Utility.GetNewOld(carresult, teammodel.invent_result);
            }

            if (Utility.Getrule(carresult))
            {
                result = "友情提示：您不可以选择一样的规格，请重新选择";
            }
            else if (isExistrule)
            {
                result = "友情提示:您选择了此项目所没有的规格，请重新选择";
            }
            else if (invent)
            {
                result = "友情提示:您购买的数量超过了库存数量，请减少一些";
            }
            else if (teammodel.teamcata == 0 && Utility.Getnum(carresult) > teammodel.Per_number && teammodel.Per_number > 0)
            {
                result = "友情提示:您最多可以购买" + teammodel.Per_number + "个";
            }
            else if (Utility.Getnum(carresult) < teammodel.Per_minnumber && teammodel.Per_minnumber > 0)
            {
                result = "友情提示:您最低必须购买" + teammodel.Per_minnumber + "个";
            }

            if (result != "")
            {
                OrderedDictionary list = new OrderedDictionary();
                list.Add("html", result);
                list.Add("id", "coupon-dialog-display-id1");
                Response.Write(JsonUtils.GetJson(list, "updater"));
            }
            else if (Request["action"] == "check")
            {
                OrderedDictionary list = new OrderedDictionary();
                list.Add("html", String.Empty);
                list.Add("id", "coupon-dialog-display-id1");
                Response.Write(JsonUtils.GetJson(list, "updater"));
            }
            else
            {
                AddCar(Request["id"].ToString(), Server.UrlEncode(Request["result"].Replace("|", "-").Replace(",", ".")));
            }
        }

    }
    #endregion
    /// <summary>
    /// 把选中的商品添加到临时购物车
    /// </summary>
    /// <param name="teamid"></param>
    /// <param name="result"></param>
    public void AddCar(string teamid, string result)
    {

        OrderMethod.AddProductToCar(teamid, result);
        Response.Write(JsonUtils.GetJson("location.href='" + GetUrl("优惠卷购买", "team_buy.aspx?id=" + Helper.GetInt(teamid, 0)) + "'", "eval"));
    }
</script>

