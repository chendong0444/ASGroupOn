<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    
    protected IList<ICategory> iListCategory = null;
    protected IList<IUser> iListUser = null;
    protected string strHtml = "";
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_Download_Order))
        {
            SetError("你不具有项目订单下载的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request.HttpMethod == "POST")
        {

            if (Request.Form["state[]"] != null && Request.Form["service[]"] != null)
            {
                string teamid = "";
                if (Request.Form["team_id"] != null && Request.Form["team_id"].ToString() != "")
                {
                    teamid = Request.Form["team_id"].ToString();
                }
                else
                {
                    teamid = "0";
                }
                string partnerid = "";
                if (Request.Form["partnerid"] != null && Request.Form["partnerid"].ToString() != "")
                {
                    partnerid = Request.Form["partnerid"].ToString();
                }
                else
                {
                    partnerid = "0";
                }
                if (Request.Form["txtstart"] == null)//日期必须选上
                {
                    SetError("-ERR ERR_NO_DATA");
                    Response.Redirect("YingXiao_ShujuXiazai_Team.aspx");
                    return;
                }
                string state = Helper.GetString(Request.Form["state[]"], String.Empty);//支付状态
                string service = Helper.GetString(Request.Form["service[]"], String.Empty); //处理支付渠道
                string receive = Helper.GetString(Request.Form["receive"], String.Empty);//发货状态
                xiazai(teamid, state, service, receive, partnerid);
            }
            else
            {
                SetError("-ERR ERR_NO_DATA");
                Response.Redirect("YingXiao_ShujuXiazai_Team.aspx");
                return;
            }
        }
    }

    //属于购物车的项目名称
    string[] GteamName;
    //属于购物车的项目ID
    int[] GteamID;
    //属于购物车项目的商品名称
    string[] Product;
    //属于购物车的购买数量
    int[] GNum;
    //属于购物车的规格
    string[] GResult;
    //不属于购物车的项目名称
    string teamName;
    //不属于购物车的项目ID
    int teamID;
    //记录是否属于购物车,如果是false就不属于购物车，否则属于购物车
    bool result = false;
    protected void xiazai(string teamid, string state, string service, string receive, string partnerid)
    {
        StringBuilder sb1 = new StringBuilder();
        OrderFilter orderfilter = new OrderFilter();
        IList<IOrder> IListIorder = null;
        //Hashtable hashtable1 = null;

        TeamFilter teamfilter = new TeamFilter();
        ITeam iteam = null;

        CategoryFilter categoryfilter = new CategoryFilter();
        ICategory icategory = null;
        
        if (service == "")//||  by whipk state == "" ||
        {
            SetError("-ERR ERR_NO_DATA");
            Response.Redirect("YingXiao_ShujuXiazai_Team.aspx");
            return;
        }
        else
        {
            //string where = " 1=1  ";

            //事件类型 默认下单时间
            bool timetype = true;

            //支付状态
            string tempwhere = String.Empty;
            string[] states = state.Split(',');
            for (int i = 0; i < states.Length; i++)
            {
                if (states[i] == "pay")
                {
                    timetype = false;
                }
                if (states[i] == "pay")//也包括积分订单
                {
                    //tempwhere = tempwhere + "or [order].State='pay' or [order].State='scorepay' ";
                    tempwhere = tempwhere + "or o.State='pay' or o.State='scorepay' ";
                }
                else if (states[i] == "unpay")//未支付的货到付款订单
                {
                    tempwhere = tempwhere + "or o.State='unpay' or o.State='nocod' ";
                }
                else
                {
                    tempwhere = tempwhere + "or o.State='" + states[i].ToString() + "' ";
                }
            }
            if (tempwhere.Length > 0)
            {
                //orderfilter.where1 = "(" + tempwhere.Substring(3) + ")";
                orderfilter.where1 = tempwhere.Substring(3);
                //where = where + " and (" + tempwhere.Substring(3) + ") ";
            }
            //项目ID
            bool isCoupon = false;
            if (teamid != "0")
            {
                orderfilter.strTeam_id = Convert.ToInt32(teamid);
                //where = where + " and (Team_id=" + teamid + " or teamid=" + teamid + ")";

                //Maticsoft.BLL.Team teambll = new BLL.Team();
                //Maticsoft.Model.Team teammodel = teambll.GetModel(int.Parse(teamid), false);

                TeamFilter filter = new TeamFilter();
                ITeam iteams = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iteams = session.Teams.GetByID(Convert.ToInt32(teamid));
                }

                if (iteams != null)
                {
                    if (iteams.Delivery == "coupon")
                    {
                        isCoupon = true;
                    }
                }
            }
            //时间
            if (Request.Form["txtstart"] != null && Request.Form["txtend"] != null && Request.Form["txtstart"].ToString() != "" && Request.Form["txtend"].ToString() != "")
            {
                if (!timetype)
                {
                    orderfilter.sPay_time = Helper.GetDateTime(Request.Form["txtstart"], DateTime.Now).ToString("yyyy-MM-dd 0:0:0");
                    orderfilter.ePay_time = Helper.GetDateTime(Request.Form["txtend"], DateTime.Now).ToString("yyyy-MM-dd 23:59:59");

                    //where = where + " and (Pay_time between '" + Helper.GetDateTime(Request.Form["txtstart"], DateTime.Now).ToString("yyyy-MM-dd 0:0:0") + "' and '" + Helper.GetDateTime(Request.Form["txtend"], DateTime.Now).ToString("yyyy-MM-dd 23:59:59") + "') ";
                }
                else
                {
                    orderfilter.sCreate_Time = Helper.GetDateTime(Request.Form["txtstart"], DateTime.Now).ToString("yyyy-MM-dd 0:0:0");
                    orderfilter.eCreate_Time = Helper.GetDateTime(Request.Form["txtend"], DateTime.Now).ToString("yyyy-MM-dd 23:59:59");
                    
                    //where = where + " and ([order].create_Time between '" + Helper.GetDateTime(Request.Form["txtstart"], DateTime.Now).ToString("yyyy-MM-dd 0:0:0") + "' and '" + Helper.GetDateTime(Request.Form["txtend"], DateTime.Now).ToString("yyyy-MM-dd 23:59:59") + "') ";
                }
            }

            if (!isCoupon)
            {
                //发货状态
                if (receive.Length > 0)
                {
                    string[] r = receive.Split(',');
                    tempwhere = String.Empty;
                    for (int i = 0; i < r.Length; i++)
                    {
                        if (r[i] == "0")
                        {
                            //tempwhere = tempwhere + "or ( [order].Express='Y' and (Express_id=0 or len(Express_no)=0)) ";
                            tempwhere = tempwhere + "or ( o.Express='Y' and (Express_id=0 or len(Express_no)=0)) ";
                        }
                        else if (r[i] == "1")
                        {
                            //tempwhere = tempwhere + "or ([order].Express='Y' and Express_id>0 and len(Express_no)>0) ";
                            tempwhere = tempwhere + "or (o.Express='Y' and Express_id>0 and len(Express_no)>0) ";
                        }
                        else if (r[i] == "2")
                        {

                            //tempwhere = tempwhere + "or ( [order].Express='Y' and Express_id=0 and [order].state='pay') ";
                            tempwhere = tempwhere + "or ( o.Express='Y' and Express_id=0 and o.state='pay') ";

                        }
                        else if (r[i] == "3")
                        {
                            //tempwhere = tempwhere + "or (  [order].state='pay' and [order].Express='Y' and Express_id>0 and isnull(express_xx,'')<>'已打印') ";
                            tempwhere = tempwhere + "or (  o.state='pay' and o.Express='Y' and Express_id>0 and isnull(express_xx,'')<>'已打印') ";
                            // and state='pay' and Express='Y' and Express_id>0 and isnull(express_xx,'')<>'已打印'
                        }

                    }
                    if (tempwhere.Length > 0)
                    {
                        orderfilter.where2 = tempwhere.Substring(3);
                        //where = where + " and(" + tempwhere.Substring(3) + ")";
                    }
                }
            }
            //处理支付渠道
            if (service.Length > 0)
            {
                string[] services = service.Split(',');
                tempwhere = String.Empty;
                for (int i = 0; i < services.Length; i++)
                {
                    tempwhere = tempwhere + "or service='" + services[i] + "' ";
                }
                if (tempwhere.Length > 0)
                {
                    orderfilter.where3 = tempwhere.Substring(3);
                    //where = where + " and(" + tempwhere.Substring(3) + ")";//把or截取掉                  
                }
            }

            //商户id
            if (partnerid != "0")
            {
                orderfilter.sPartner_id = Convert.ToInt32(partnerid);
                //where += " and team.partner_id = " + partnerid;
            }

            sb1.Append("<html>");
            sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
            sb1.Append("<body><table border=\'1\'>");
            sb1.Append("<tr>");
            sb1.Append("<td>ID</td>");
            sb1.Append("<td align='left'>订单号</td>");
            sb1.Append("<td>支付方式</td>");
            sb1.Append("<td>单价</td>");
            sb1.Append("<td>运费</td>");
            sb1.Append("<td>总金额</td>");
            sb1.Append("<td>支付款</td>");
            sb1.Append("<td>余额付款</td>");
            sb1.Append("<td>支付积分</td>");
            sb1.Append("<td>支付状态</td>");
            sb1.Append("<td>支付日期</td>");
            sb1.Append("<td>备注</td>");
            sb1.Append("<td>快递信息</td>");
            sb1.Append("<td>用户名</td>");
            sb1.Append("<td>用户邮箱</td>");
            sb1.Append("<td>用户手机</td>");
            sb1.Append("<td>收件人</td>");
            sb1.Append("<td>邮政编码</td>");
            sb1.Append("<td>送货地址</td>");
            sb1.Append("<td>支付号</td>");
            sb1.Append("</tr>");
            //string orderby = "[order].create_time";
            if (!timetype)
            {
                orderfilter.AddSortOrder(OrderFilter.Pay_time_ASC);
                //orderby = "pay_time";
            }
            else
            {
                orderfilter.AddSortOrder(OrderFilter.OCreate_time_ASC);
            }

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                IListIorder = session.Orders.GetYx_TeamDown(orderfilter);
                //hashtable1 = session.Orders.GetYx_TeamDown(orderfilter);

                //DataTable dt = Maticsoft.DBUtility.DbHelperSQL.SelectByFilter("*", "" + where + "", orderby, "[order] left join orderdetail on [order].Id=orderdetail.order_id left join [user] on User_id=[user].Id left join team on ISNULL(Teamid,Team_id)=team.id");
                //if (hashtable1 != null && hashtable1.Count > 0)
                if (IListIorder != null && IListIorder.Count > 0)
                {
                    int num = 0;
                    foreach (IOrder iorderInfo in IListIorder) 
                    //for (int i = 0; i < hashtable1.Count; i++)
                    {
                        if (num != iorderInfo.Id)
                        {
                            num = iorderInfo.Id;
                            sb1.Append("<tr>");
                            sb1.Append("<td>");
                            sb1.Append(iorderInfo.Id);
                            sb1.Append("</td>");

                            //是否属于购物车
                            if (iorderInfo.Team_id == 0)
                            {
                                result = true;
                                //属于购物车就查找购物车表并查找用户表
                                IList<IOrderDetail> ilistIOrderDetail = null;
                                //Hashtable hashtable = null;
                                OrderDetailFilter orderdetailfilter = new OrderDetailFilter();
                                orderdetailfilter.Order_ID = Convert.ToInt32(iorderInfo.Id);
                                orderdetailfilter.AddSortOrder(OrderDetailFilter.Order_ID_ASC);
                                //hashtable = session.OrderDetail.GetDetailTeam(iorderInfo.Id);
                                ilistIOrderDetail = session.OrderDetail.GetDetailTeam(orderdetailfilter);
                                
                                //DataTable dt1 = Maticsoft.DBUtility.DbHelperSQL.SelectByFilter("*", "Order_id=" + dt.Rows[i]["Id"] + "", "Order_id", "orderdetail left join team on orderdetail.Teamid=team.Id");

                                GteamID = new int[ilistIOrderDetail.Count];
                                GteamName = new string[ilistIOrderDetail.Count];
                                Product = new string[ilistIOrderDetail.Count];
                                GNum = new int[ilistIOrderDetail.Count];
                                GResult = new string[ilistIOrderDetail.Count];
                                if (ilistIOrderDetail != null && ilistIOrderDetail.Count > 0)
                                {
                                    foreach(IOrderDetail iorderdetail in ilistIOrderDetail)
                                        //for (int j = 0; j < hashtable.Count; j++)
                                        {
                                            int j = 0;
                                            //把项目ID，添加到数组中
                                            int s = iorderdetail.Teamid;

                                            GteamID[j] = iorderdetail.Teamid;
                                            //把项目名称，添加到数组中
                                            GteamName[j] = iorderdetail.Title;
                                            //把项目的商品名称，添加到数组中
                                            Product[j] = iorderdetail.Product;
                                            //把订单的数量，添加到数组中
                                            GNum[j] =iorderdetail.Num;
                                            //把规格添加到数组中
                                            GResult[j] = iorderdetail.result;
                                            j++;
                                        }
                                    
                                }
                            }
                            else
                            {
                                result = false;
                                //不属于购物车
                                
                                //teamModel = teambll.GetModel(Convert.ToInt32(dt.Rows[i]["Team_id"].ToString()), false);
                                //TeamFilter teamfilter = new TeamFilter();
                                teamfilter.Id = Convert.ToInt32(iorderInfo.Team_id);
                                iteam = session.Teams.Get(teamfilter);
                                if (iteam != null)
                                {
                                    //添加项目ID
                                    teamID = iteam.Id;
                                    //项目名称
                                    teamName = iteam.Title;
                                }
                            }
                            //订单号
                            sb1.Append("<td>");
                            if (result)
                            {
                                for (int j = 0; j < GteamID.Length; j++)
                                {
                                    sb1.Append(Product[j]);
                                    if (GResult[j] != null && GResult[j].ToString() != "")
                                    {
                                        sb1.Append(GResult[j].ToString());
                                    }
                                    else
                                    {
                                        sb1.Append("[" + GNum[j].ToString() + "件] ");
                                    }
                                }

                            }
                            else
                            {
                                if (iteam != null)
                                {
                                    sb1.Append(iteam.Product);
                                    if (iorderInfo.result != null && iorderInfo.result != "")
                                    {
                                        sb1.Append(iorderInfo.result);
                                    }
                                    else
                                    {
                                        sb1.Append("[" + iorderInfo.Quantity + "件]");
                                    }
                                }

                            }
                            sb1.Append("</td>");
                            //支付方式
                            sb1.Append("<td>");
                            switch (iorderInfo.Service)
                            {
                                case "yeepay":
                                    sb1.Append("易宝");
                                    break;
                                case "alipay":
                                    sb1.Append("支付宝");
                                    break;
                                case "tenpay":
                                    sb1.Append("财付通");
                                    break;
                                case "chinamobilepay":
                                    sb1.Append("移动支付");
                                    break;
                                case "chinabank":
                                    sb1.Append("网银在线");
                                    break;
                                case "cashondelivery":
                                    sb1.Append("货到付款");
                                    break;
                                case "credit":
                                    sb1.Append("余额付款");
                                    break;
                                case "allinpay":
                                    sb1.Append("通联支付");
                                    break;
                                case "cash":
                                    sb1.Append("线下支付");
                                    break;
                                default:
                                    sb1.Append("");
                                    break;
                            }
                            sb1.Append("</td>");
                            //单价
                            sb1.Append("<td>" + iorderInfo.Price + "</td>");
                            //运费
                            sb1.Append("<td>" + iorderInfo.Fare + "</td>");
                            //总金额
                            sb1.Append("<td>" + iorderInfo.Origin + "</td>");
                            //支付款
                            if (iorderInfo.Service == "cashondelivery")
                            {
                                sb1.Append("<td>" + iorderInfo.cashondelivery + "</td>");
                            }
                            else
                            {
                                sb1.Append("<td>" + iorderInfo.Money + "</td>");
                            }
                            //余额付款
                            sb1.Append("<td>" + iorderInfo.Credit+ "</td>");
                            //支付积分
                            sb1.Append("<td>" + iorderInfo.totalscore + "</td>");
                            //支付状态
                            sb1.Append("<td>" + iorderInfo.State + "</td>");
                            //支付日期
                            sb1.Append("<td>" + iorderInfo.Pay_time.ToString() + "</td>");
                            //备注
                            if (iorderInfo.Remark != "")
                            {
                                sb1.Append("<td>" + iorderInfo.Remark + "</td>");
                            }
                            else
                            {
                                sb1.Append("<td>&nbsp;</td>");
                            }

                            //快递信息
                            //categorymodel = categoryBll.GetModel(iorderInfo.Express_id);
                            categoryfilter.Id = Convert.ToInt32(iorderInfo.Express_id);
                            icategory = session.Category.Get(categoryfilter);
                            sb1.Append("<td>");
                            if (icategory != null)
                            {
                                sb1.Append(icategory.Name);
                            }
                            else
                            {
                                sb1.Append("&nbsp;");
                            }
                            sb1.Append("</td>");
                            //用户名
                            sb1.Append("<td>" + iorderInfo.Username + "</td>");
                            //用户邮箱
                            sb1.Append("<td>" + iorderInfo.Email + "</td>");
                            //用户手机
                            sb1.Append("<td>" + iorderInfo.Mobile + "</td>");
                            //收件人
                            sb1.Append("<td>" + iorderInfo.Realname+ "</td>");
                            //邮政编码
                            sb1.Append("<td>" + iorderInfo.Zipcode + "</td>");
                            //送货地址
                            sb1.Append("<td>" + iorderInfo.Address + "</td>");
                            //支付号
                            sb1.Append("<td>" + iorderInfo.Pay_id + "</td>");
                            sb1.Append("</tr>");
                        }

                    }
                }
                else
                {
                    SetError("没有数据，请重新选择条件下载！");
                    Response.Redirect("YingXiao_ShujuXiazai_Team.aspx");
                    Response.End();
                }
            }

        }
        sb1.Append("</table></body></html>");
        Response.ClearHeaders();
        Response.Clear();
        Response.Expires = 0;
        Response.Buffer = true;
        Response.AddHeader("Accept-Language", "zh-tw");
        //文件名称
        Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("team_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
        Response.ContentType = "Application/octet-stream";
        //文件内容
        Response.Write(sb1.ToString());
        Response.End();

    }

</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>订单下载</h2>
                                    <h4 style=" color:Red;">如果不输入项目ID，默认为下载所选日期内所有项目的订单</h4>
                                </div>
                                <div class="sect">
                                    <div>
                                        <label>项目ID</label>
						                <input type="text" name="team_id" group="a"  datatype="number" class="number" />
                                        <label>商户ID</label>
						                <input type="text" name="partnerid" group="a"  datatype="number" class="number" />
						                日期：<input type="text" name="txtstart" require="true" datatype="date" group="a"  class="date" value="<%=DateTime.Now.ToString("yyyy-MM-dd") %>" />-<input type="text" group="a" name="txtend" require="true" datatype="date"  class="date" value="<%=DateTime.Now.ToString("yyyy-MM-dd") %>" />
                                    </div>

                                    <div class="field">
                                        <label>支付状态</label>
						                <div style=""><input type="checkbox" name="state[]" value="pay" checked />&nbsp;已支付&nbsp;&nbsp;<input type="checkbox" name="state[]" value="unpay" checked>&nbsp;未支付&nbsp;&nbsp;<input type="checkbox" name="state[]" value="refund" checked>&nbsp;已退款&nbsp;&nbsp;<input type="checkbox" name="state[]" value="cancel" checked>&nbsp;已取消</div>
					                </div>

                                    <div class="field">
                                    <label>发货状态</label>
                                    <div style=""> <input type="checkbox" name="receive" value="0"  />未发货 <input type="checkbox" name="receive" value="1"  />已发货 <input type="checkbox" name="receive" value="2"  />未选择快递 <input type="checkbox" name="receive" value="3"  />未打印</div>
                                    </div>
                                    <div class="field">
                                        <label>支付渠道</label>
						                <div style="">
                            
                                        <input type="checkbox" name="service[]" value="yeepay"  checked />&nbsp;易宝&nbsp;&nbsp;<input type="checkbox" name="service[]" value="alipay" checked />&nbsp;支付宝&nbsp;&nbsp;<input type="checkbox" name="service[]" value="tenpay" checked />&nbsp;财付通&nbsp;&nbsp;<input type="checkbox" name="service[]" value="cash" checked />&nbsp;现金支付&nbsp;&nbsp;<input type="checkbox" name="service[]" value="credit" checked>&nbsp;余额支付&nbsp;&nbsp;<input type="checkbox" name="service[]" value="chinabank" checked>&nbsp;网银在线&nbsp;&nbsp;<input type="checkbox" name="service[]" value="cashondelivery" checked>&nbsp;货到付款
                            
                                        </div>
					                </div>

                                    <div class="act">
                                        <input type="submit" value="下载" name="commit" group="a" class="formbutton validator"/>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- bd end -->
    </div>
    <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>