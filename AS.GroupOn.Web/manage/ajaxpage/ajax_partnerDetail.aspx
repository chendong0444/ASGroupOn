<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected int pid = 0;               //商户ID
    protected int teamid = 0;            //项目ID
    protected decimal JieSuanMoney = 0;  //已结算金额
    protected int YjsNumber = 0;         //应结算数量
    protected int JieSuanNumber = 0;     //已结算数量
    protected string msg = String.Empty; //结算方式
    protected decimal chengben = 0;      //成本价
    protected string strs = String.Empty;//返回值
    protected int  sellnumber = 0;    //卖出数量
    protected int  sendnubmer = 0;    //发货数量
    protected int couponnumber = 0;  //实际消费数量
    protected DateTime end_date;
    string teamrow = String.Empty;
    string str = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {
            pid = AS.Common.Utils.Helper.GetInt(Request["pid"], 0);
            teamid = AS.Common.Utils.Helper.GetInt(Request["teamid"], 0);
            end_date = AS.Common.Utils.Helper.GetDateTime(Request["end_data"], DateTime.Now);
        }
        if (pid != 0)
        {
            if (teamid == 0)
            {
                msg = "请选择项目";
            }
            else
            {
                string sql1 = "select id,teamway,delivery,cost_price from team where id=" + teamid;
                List<Hashtable> list1 = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list1 = session.GetData.GetDataList(sql1);
                }
                if (list1 != null)
                {
                    foreach (Hashtable item in list1)
                    {
                        teamrow = item["teamway"].ToString();
                        str = item["delivery"].ToString();
                        chengben = AS.Common.Utils.Helper.GetDecimal(item["cost_price"], 0);
                    }
                }
                string sql2 = "select sum(num) as num,sum(money) as money from partner_detail where partnerid=" + pid + " and team_id=" + teamid + " and settlementstate=8 ";
                List<Hashtable> list2 = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list2 = session.GetData.GetDataList(sql2);
                }
                if (list2 != null)
                {
                    foreach (Hashtable item in list2)
                    {
                        JieSuanNumber = AS.Common.Utils.Helper.GetInt(item["num"], 0);
                        JieSuanMoney = AS.Common.Utils.Helper.GetDecimal(item["money"], 0);
                    }
                }
                string sql3 = "select sum(isnull(num,quantity)) as num from [order] left join orderdetail on([order].id=orderdetail.order_id) where state='pay' and (team_id=" + teamid + " or teamid=" + teamid + ") and pay_time<='" + end_date.ToString("yyyy-MM-dd") + "' ";
                List<Hashtable> list3 = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list3 = session.GetData.GetDataList(sql3);
                }
                if (list3 != null)
                {
                    foreach (Hashtable item in list3)
                    {
                        //实际卖出数量
                        sellnumber = AS.Common.Utils.Helper.GetInt(item["num"], 0);
                    }
                }
                if (teamrow != null)
                {
                    if (teamrow == "S")
                    {
                        string sql4 = "select sum(isnull(num,quantity)) as num from [order] left join orderdetail on([order].id=orderdetail.order_id) where state='pay' and express_id>0 and isnull(express_no,'')<>'' and (team_id=" + teamid + " or teamid=" + teamid + ") and pay_time<='" + end_date.ToString("yyyy-MM-dd") + "' ";

                        List<Hashtable> list4 = null;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            list4 = session.GetData.GetDataList(sql4);
                        }
                        if (list4 != null)
                        {
                            foreach (Hashtable item in list4)
                            {
                                sendnubmer = AS.Common.Utils.Helper.GetInt(item["num"], 0); //发货数量
                            }
                        }
                    }
                    else if (teamrow == "N")
                    {
                        string sql5 = "select count(*) as num from coupon where consume='Y' and Consume_time<='" + end_date.ToString("yyyy-MM-dd") + "' and team_id=" + teamid + " and partner_id=" + pid;

                        List<Hashtable> list5 = null;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            list5 = session.GetData.GetDataList(sql5);
                        }
                        if (list5 != null)
                        {
                            foreach (Hashtable item in list5)
                            {
                                couponnumber =AS.Common.Utils.Helper.GetInt(item["num"],0); //消费数量
                            }
                        }

                    }
                }
                //应结算数量
                if (teamrow != null)
                {
                    if (teamrow == "N" && couponnumber != null)
                    {
                        YjsNumber = couponnumber;
                        msg = "按实际消费数量";
                    }
                    else if (teamrow == "Y" && sellnumber != null)
                    {
                        YjsNumber = sellnumber;
                        msg = "按实际卖出数量";
                    }
                    else if (teamrow == "S" && sendnubmer != null)
                    {
                        YjsNumber = sendnubmer;
                        msg = "按实际发货数量";
                    }

                }
                // strs = "应结算数量" + YjsNumber + "份,已结算数量" + JieSuanNumber + "份,已结算金额" + JieSuanMoney + "元,实际卖出数量" + sellnumber + "份,成本" + chengben + "元,结算方式" + msg;
                   strs =str + "," + YjsNumber + "," + JieSuanNumber + "," + JieSuanMoney + "," + sellnumber + "," + chengben + "," + msg;
            }
            Response.Write(strs);
            Response.End();
        }

    }
</script>