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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        string action = Helper.GetString(Request["action"], String.Empty);
        int id = Helper.GetInt(Request["id"], 0);
        int expressId = Helper.GetInt(Request["expressId"], 0);
        string order_refund = Helper.GetString(Request["order_refund"], string.Empty);
        string order_view = Helper.GetString(Request["orderview"], String.Empty);
        if (action == "refundview")//退款确认
        {
            string html = WebUtils.LoadPageString("partner_ViewRefund.aspx");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
        }
            
        else if (action == "refund1")//客服申请退款
        {    
            string type = Helper.GetString(Request.Form["type"], String.Empty);//请求类型（1是订单详情2审核订单）
            string remark = Helper.GetString(Request.Form["remark"], String.Empty);//审核备注
            int state = Helper.GetInt(Request.Form["state"], 0);     //退款状态1 2 4 8
            int orderid = Helper.GetInt(Request.Form["orderid"], 0);
            decimal refundmoney = Helper.GetDecimal(Request.Form["refundmoney"], 0);
            string reason = Helper.GetString(Request.Form["reason"], String.Empty);
            int refundtype = Helper.GetInt(Request.Form["refundtype"], 0);
            if ((type != "" && type == "1") || (type != "" && type == "2"))
            {
                if (refundtype != 0 && refundmoney != 0)
                {
                    string refundteamstr = Helper.GetString(Request.Form["refundteams"], String.Empty);
                    string[] refundteams = refundteamstr.Split(new string[] { "\n" }, StringSplitOptions.RemoveEmptyEntries);
                    List<RefundTeams> listrefundteams = new List<RefundTeams>();
                    string teamids = ",";
                    for (int i = 0; i < refundteams.Length; i++)
                    {
                        string[] refunds = refundteams[i].Split('-');
                        if (refunds.Length == 2)
                        {
                            int teamid = Helper.GetInt(refunds[0], 0);
                            if (teamids.IndexOf("," + teamid + ",") >= 0)
                            {
                                Response.Write(JsonUtils.GetJson("退款申请时，不能填写重复的项目", "alert"));
                                Response.End();
                                return;
                            }
                            teamids = teamids + teamid + ",";
                            int teamnum = Helper.GetInt(refunds[1], 0);
                            RefundTeams rt = new RefundTeams();
                            rt.teamid = teamid;
                            rt.teamnum = teamnum;
                            listrefundteams.Add(rt);
                        }
                    }
                    string result = AS.AdminEvent.OrderEvent.Refund_Apply(orderid, listrefundteams, refundmoney, reason, AsAdmin.Id, DateTime.Now, refundtype);
                    if (result.Length > 0)
                        Response.Write(JsonUtils.GetJson("alert('" + result + "');", "eval"));
                    else
                    {
                        if (type == "2")
                        {
                            IOrder order = null;
                            using (IDataSession session=Store.OpenSession(false))
                            {
                                order = session.Orders.GetByID(orderid);
                            }
                            order.rviewstate = state;
                            order.rviewremarke = remark;
                            order.refundTime = DateTime.Now;
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                int i = session.Orders.Update(order);
                                if (i > 0)
                                {
                                    Response.Write(JsonUtils.GetJson("退款申请成功!", "alert"));
                                  
                                }
                                else
                                {
                                    Response.Write(JsonUtils.GetJson("订单更新失败!", "alert"));
                                    
                                }
                                Response.End();
                                return;
                            }
                        }
                        Response.Write(JsonUtils.GetJson("退款申请成功!", "alert"));
                       
                    }
                }
                else
                {
                    IOrder ordermodel = null;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        ordermodel = session.Orders.GetByID(orderid);
                    }
                    if (ordermodel == null)
                    {
                        Response.Write(JsonUtils.GetJson("alert('订单不存在！');", "eval"));
                    }
                    else
                    {
                        ordermodel.rviewstate = state;
                        ordermodel.rviewremarke = remark;
                        ordermodel.refundTime = DateTime.Now;
                        using (IDataSession session = Store.OpenSession(false))
                        {
                            session.Orders.Update(ordermodel);
                        }
                        Response.Write(JsonUtils.GetJson("alert('退款状态保存成功!');window.location.reload();", "eval"));
                    }
                }
            }
        }
        else if (action == "conform")//商户确认退款
        {
            id = Helper.GetInt(Request.QueryString["id"], 0);//退款记录ID
            int partnerid = Helper.GetInt(CookieUtils.GetCookieValue("partner"), 0);
            string result = AS.AdminEvent.OrderEvent.Refund_View(id, DateTime.Now, partnerid);
            if (result.Length > 0)
            {
                Response.Write(JsonUtils.GetJson(result, "alert('" + result + "');"));
            }
            else
            {
                Response.Write(JsonUtils.GetJson("alert('处理成功!');$(\"input[rd='" + id + "']\").attr('value','已同意');$(\"input[rd='" + id + "']\").attr('disabled',true);", "eval"));
            }
        }
        //结算详情
        else if (action == "PartnerXiangQing")
        {
            string ids = AS.Common.Utils.Helper.GetString(Request["Id"], String.Empty);
            string html = WebUtils.LoadPageString(PageValue.WebRoot+"manage/ajaxpage/PartnerXiangQing.aspx?Id=" + ids);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "PmoneyEdit")
        {
            string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/ajax_PmoneyEdit.aspx?id=" + Helper.GetInt(id, 0));
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        if (action == "orderview"&&id>0)
        {
            string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/manage_ajax_orderview.aspx?id=" + id);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "order_refund"&&id>0)
        {
            string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/manage_ajax_orderview.aspx?id=" + id+ "&action=order_refund");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if ("shmoney" == action)
        {

            string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/ajax_shmoney.aspx?Id=" + id);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "getteam")//得到结算项目
        {
            DateTime end_date = Helper.GetDateTime(Request.QueryString["end_date"], DateTime.Now);
            int pid = Helper.GetInt(Request["pid"], 0);//商户ID
            if (pid == 0) pid = Helper.GetInt(CookieUtils.GetCookieValue("partner"), 0);
            int tid = Helper.GetInt(Request["tid"], 0);//项目ID
            //已结算数量，已结算金额，应结算数量，应结算金额，结算方式,项目成本价,卖出数量,实际消费数量
            //DataRowObject teamrow = null;//
            //DataRowObject jiesuan = null;//
            //DataRowObject sellnumber = null;//卖出数量
            //DataRowObject sendnumber = null;//发货数量
            //DataRowObject couponnumber = null;//实际消费数量
               //teamrow = db.SqlExecDataRow("select id,teamway,delivery,cost_price from team where id=" + tid);
               ITeam teamrow = Store.CreateTeam();
               TeamFilter teamfilter = new TeamFilter();
               using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
               {
                   teamrow = session.Teams.GetByID(tid);
               }
                //jiesuan = db.SqlExecDataRow("select sum(num) as num,sum(money) as money from partner_detail where partnerid=" + pid + " and team_id=" + tid + " and settlementstate=8 ");
                IList<Hashtable> table = null;
                Partner_DetailFilter pdefilter = new Partner_DetailFilter();
                pdefilter.partnerid = Helper.GetInt(CookieUtils.GetCookieValue("partner"), 0);
                pdefilter.team_id = tid;
                pdefilter.settlementstate = 8;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    table = session.Partner_Detail.Seljiesuan(pdefilter);
                }
            
            //sellnumber = db.SqlExecDataRow("select sum(isnull(num,quantity)) as num from [order] left join orderdetail on([order].id=orderdetail.order_id) where state='pay' and (team_id=" + tid + " or teamid=" + tid + ") and pay_time<='" + end_date.ToString("yyyy-MM-dd") + "' ");

            OrderFilter orfilter = new OrderFilter();
            //orfilter.Team_id =Helper.GetInt(tid, 0);
            //orfilter.ToPay_time = Helper.GetDateTime(end_date.ToString("yyyy-MM-dd"),DateTime.Now);
            orfilter.Wheresql1 = "state='pay' and (team_id="+tid+" or teamid="+tid+") and pay_time<='" + Helper.GetDateTime(end_date.ToString("yyyy-MM-dd"), DateTime.Now) + "'";
            int sellnumber=0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                sellnumber = session.Orders.SellNumber(orfilter);
            }

            string sendnumber = string.Empty;
            int couponnumber = 0;
            OrderFilter orderfilter = new OrderFilter();
            orderfilter.Wheresql1 = "state='pay' and express_id>0 and isnull(express_no,'')<>'' and (team_id=" + tid + " or teamid=" + tid + ") and pay_time<='" + Helper.GetDateTime(end_date.ToString("yyyy-MM-dd"), DateTime.Now) + "'";
            if (teamrow != null)
                {
                    if (teamrow.teamway == "S")
                    {
                        //sendnumber = db.SqlExecDataRow("select sum(isnull(num,quantity)) as num from [order] left join orderdetail on([order].id=orderdetail.order_id) where state='pay' and express_id>0 and isnull(express_no,'')<>'' and (team_id=" + tid + " or teamid=" + tid + ") and pay_time<='" + end_date.ToString("yyyy-MM-dd") + "' ");
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            sendnumber = session.Orders.SendNumber(orderfilter).ToString();
                        }
                    }
                    else if (teamrow.teamway == "N")
                    {
                        CouponFilter coufilter = new CouponFilter();
                        coufilter.Team_ids = tid;
                        coufilter.Partner_id = Helper.GetInt(CookieUtils.GetCookieValue("partner"), 0);
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            couponnumber = session.Coupon.CouponNumber(coufilter);
                        }
                    }
                        //couponnumber = db.SqlExecDataRow("select count(*) as num from coupon where consume='Y' and Consume_time<='" + end_date.ToString("yyyy-MM-dd") + "' and team_id=" + tid + " and partner_id=" + pid);
                }
          

            string script = String.Empty;
            if (teamrow != null)
            {
                if (teamrow.teamway == "N" && couponnumber != null)
                {
                    script = script + "yingjienumber=" +Helper.GetInt(couponnumber,0) + ";";
                }
                else if (teamrow.teamway == "Y" && sellnumber != null)
                {
                    script = script + "yingjienumber=" + Helper.GetInt(sellnumber,0) + ";";
                }
                else if (teamrow.teamway == "S" && sendnumber != null)
                {
                    script = script + "yingjienumber=" + Helper.GetInt(sendnumber, 0) + ";";
                }
                foreach (Hashtable jiesuan in table)
                {
                    
               
                if (jiesuan != null)
                {
                    script = script + "yijienumber=" +Helper.GetInt(jiesuan["num"], 0) + ";";
                    script = script + "yijiemoney=" + Helper.GetInt(jiesuan["money"], 0) + ";";
                } 
                }
                script = script + "costprice=" +Helper.GetDecimal(teamrow.cost_price,0) + ";";//成本
                if (teamrow.teamway == "Y") script = script + "jiesuantype='按实际卖出数量';";
                else if (teamrow.teamway == "S") script = script + " jiesuantype='按实际发货数量';";
                else if (teamrow.teamway == "N") script = script + "jiesuantype='按实际消费数量';";

                script = script + "sellnumber=" + Helper.GetInt(sellnumber, 0) + ";";
                //script = script + "$('#jiesuantxt').html('应结算数量'+yingjienumber+'份,已结算数量'+yijienumber+'份,已结算金额'+yijiemoney+'元,实际卖出数量'+sellnumber+'份,成本'+costprice+'元,结算方式'+jiesuantype);";
                if (teamrow.Delivery == "express")
                {
                    script = script + "$('#jiesuantxt').html('应结算数量'+yingjienumber+'份,已结算数量'+yijienumber+'份,已结算金额'+yijiemoney+'元,实际卖出数量'+sellnumber+'份,成本'+costprice+'元,结算方式'+jiesuantype);";
                }
                else
                {
                    script = script + "$('#jiesuantxt').html('应结算数量'+yingjienumber+'份,已结算数量'+yijienumber+'份,已结算金额'+yijiemoney+'元,成本'+costprice+'元,结算方式'+jiesuantype);";
                }
            }
            Response.Write(JsonUtils.GetJson(script, "eval"));
            Response.End();
        }
        else if (action == "branchview" && id > 0)
        {
            Response.Write(JsonUtils.GetJson(WebUtils.LoadPageString(WebRoot + "manage/ajaxpage/manage_ajax_dialog_branchview.aspx?id=" + id), "dialog"));
        }
        
    }
</script>
