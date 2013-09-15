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
<%@ Import Namespace="System.Data" %>

<script runat="server">

    
    protected string actionstring = String.Empty; //命令代码
    private string Action = String.Empty;
    protected string printdata = String.Empty;
    protected IList<IOrderDetail> list_orderDetail = null;
   
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        
        
        
         Action = Helper.GetString(Request["action"], String.Empty);
            if (Action == "add")
                actionstring = "add";
            else if(Action=="edit")//更新
            {
               int id = Helper.GetInt(Request["id"], 0);
               actionstring = "edit|"+id.ToString();
            }
            else if (Action == "print")//打印
            {
                int oid = Helper.GetInt(Request["oid"], 0);
                
                IOrder order=Store.CreateOrder();



                List<object> orderlist = new List<object>();
                
                if (oid > 0)
                {
                    #region 打印单一订单
                    
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        order = session.Orders.GetByPrint(oid);
                    }
                    
                    if (order !=null)
                    {
                        actionstring = "print|" +  oid;
                        OrderedDictionary values = new OrderedDictionary();
                        values.Add("orderid",  oid);
                        if(order.Express_no!=null && order.Express_no !="")
                        values.Add("express_no", order.Express_no.ToString());
                        if(order.Realname !=null &&　order.Realname !="")
                        values.Add("textBlock6", order.Realname.ToString() + " ");
                        if(order.Remark !=null &&　order.Remark !="")
                        values.Add("textBlock10",order.Remark.ToString() + " ");
                        if(order.Zipcode !=null &&　order.Zipcode !="")
                        values.Add("textBlock9", order.Zipcode.ToString() + " ");
                        if(order.Address !=null && order.Address !="")
                        values.Add("textBlock8", order.Address.ToString() + " ");
                        if(order.Mobile !=null && order.Mobile !="")
                        values.Add("textBlock7", order.Mobile.ToString() + " ");
                        NameValueCollection sysconfig = WebUtils.GetSystem();
                        values.Add("textBlock5", sysconfig["zipcode"] + " ");
                        values.Add("textBlock11", sysconfig["remark"] + " ");
                        values.Add("textBlock4", sysconfig["address"] + " ");
                        values.Add("textBlock3", sysconfig["danwei"] + " ");
                        values.Add("textBlock2", sysconfig["mobile"] + " "); 
                        values.Add("textBlock1", sysconfig["sendname"] + " ");

                        if (Convert.ToInt32(order.Team_id) > 0) //不是购物车
                        {
                            values.Add("textBlock12", "订单编号:" + order.Id.ToString() + ",产品(ID:" + order.Team_id.ToString() + "," + Getbulletin(order.result.ToString(),1) + ",数量:" + order.Quantity + ")");
                        }
                        else //购物车
                        {
                            string text = "订单编号:" + oid;
                            
                            using (IDataSession session =AS.GroupOn.App.Store.OpenSession(false))
                            {
                                list_orderDetail = session.OrderDetail.GetByOrder_ID(oid);
                                
                            }
                            if(list_orderDetail !=null && list_orderDetail.Count>0)
                            {
                                foreach(IOrderDetail Otail in list_orderDetail)
                                {
                                 text = text + ",产品(ID:" + Otail.Teamid + ",总数量:" + Otail.Num + "," + Getbulletin(Otail.result,1) + " )";
                                }
                                values.Add("textBlock12", text);
                                
                                  orderlist.Add(values);
                                 OrderedDictionary dict = new OrderedDictionary();
                                 dict.Add("order", orderlist);
                                printdata = JsonUtils.GetJsonFromObject(dict);
                                
                                
                            }
                          
                        }
                    }
                    #endregion
                }
                else
                {
                    //#region 打印全部订单
                    //string where = Helper.GetString(Request["where"], String.Empty);
                    //if (where.Length > 0)
                    //{
                    //    where = HttpUtility.UrlDecode(Convert.FromBase64String(where), System.Text.Encoding.UTF8);
                    //    //替换传过来的sql字段
                    //    where = where.Replace("order_address", "[order].address");
                    //    where = where.Replace("order_mobile", "[order].mobile");
                    //    where = where.Replace("order_id", "[order].id");

                    //    string sql = "select order_realname as realname,t.order_mobile as mobile,order_zipcode as zipcode,order_address as address,t.Remark,t.result,template_print.template_value,template_print.id,express_no,order_id as orderid,t.Team_id as teamid,t.Quantity as quantity from (select t.*,Category.Ename from (select [Order].Id as order_id,User_id,Email,Username,Quantity,Origin,Service,Credit,[order].Money as order_money,Express,[Order].Create_time as order_create_time,Pay_time,[user].mobile as user_mobile,state,team_id,pay_id,Express_no,[order].mobile as order_mobile,Express_id,[order].Address as order_address,express_xx,[order].Realname as order_realname,[order].Zipcode as order_zipcode,Remark,result from [Order] inner join [User] on([Order].User_id=[User].Id) where " + where + ")t left join Category on([t].Express_id=Category.Id))t left join template_print on(t.Ename=template_print.template_name) order by pay_time asc";
                    //    DataTable orders = Maticsoft.DBUtility.DbHelperSQL.Query(sql).Tables[0];
                    //    List<object> orderlist = new List<object>();
                    //    for (int j = 0; j < orders.Rows.Count; j++)
                    //    {
                    //        DataRow row = orders.Rows[j];
                    //        actionstring = "print|" + row["id"].ToString();
                    //        OrderedDictionary values = new OrderedDictionary();
                    //        values.Add("orderid", row["orderid"].ToString());
                    //        values.Add("express_no", row["express_no"].ToString());//快递单号
                    //        values.Add("textBlock6", row["realname"].ToString() + " ");
                    //        values.Add("textBlock10", row["remark"].ToString() + " ");
                    //        values.Add("textBlock9", row["zipcode"].ToString() + " ");
                    //        values.Add("textBlock8", row["address"].ToString() + " ");
                    //        values.Add("textBlock7", row["mobile"].ToString() + " ");
                    //        NameValueCollection sysconfig = WebUtils.GetSystem();
                    //        values.Add("textBlock5", sysconfig["zipcode"] + " ");
                    //        values.Add("textBlock11", sysconfig["remark"] + " ");
                    //        values.Add("textBlock4", sysconfig["address"] + " ");
                    //        values.Add("textBlock3", sysconfig["danwei"] + " ");
                    //        values.Add("textBlock2", sysconfig["mobile"] + " ");
                    //        values.Add("textBlock1", sysconfig["sendname"] + " ");
                    //        if (Convert.ToInt32(row["teamid"]) > 0) //不是购物车
                    //        {
                    //            values.Add("textBlock12", "订单编号:" + row["orderid"].ToString() + ",产品(ID:" + row["teamid"].ToString() + "," + Getbulletin(order.result.ToString(), 1) + ",数量:" + order.Quantity + ")");
                    //        }
                    //        else //购物车
                    //        {
                    //            string text = "订单编号:" + row["orderid"].ToString();
                    //            DataTable product = Maticsoft.DBUtility.DbHelperSQL.SelectByFilter("teamid,num,result", "order_id=" + row["orderid"], "teamid asc", "orderdetail");
                    //            for (int i = 0; i < product.Rows.Count; i++)
                    //            {
                    //                DataRow p = product.Rows[i];
                    //                text = text + ",产品(ID:" + p["teamid"] + ",总数量:" + p["num"] + "," + Maticsoft.BLL.Order.Getbulletin(p["result"].ToString(), 1) + ")";
                    //            }
                    //            values.Add("textBlock12", text);
                    //        }
                    //        orderlist.Add(values);



                    //    }
                    //    OrderedDictionary dict = new OrderedDictionary();
                    //    dict.Add("order", orderlist);
                    //    printdata = JsonUtils.GetJsonFromObject(dict);
                    //}
                    //#endregion
                }
            }
        }
      
         #region 显示订单中所选项目的格式
        /// <summary>
        /// 
        /// </summary>
        /// <param name="bulletin"></param>
        /// <param name="showhtml">是否显示html格式 0显示 1不显示</param>
        /// <returns></returns>
        public static string Getbulletin(string bulletin, int showhtml = 0)
        {
            string str = "";
            if (bulletin != "")
            {
                str = "<font style='color: rgb(153, 153, 153);'>";
                string strs = "<br><b style='color: red;'>[规格]</b>";
                if (showhtml == 1)
                {
                    str = String.Empty;
                    strs = String.Empty;
                }
                string[] strArray = bulletin.Split('|');

                for (int i = 0; i < strArray.Length; i++)
                {
                    if (bulletin != "" && bulletin != null)
                    {
                        str += strs + strArray[i].Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "") + "";
                    }

                }
                if (showhtml == 0)
                    str = str + "</font><br><br>";
                //str = str.Substring(0, str.LastIndexOf("<br>"));
            }

            return str;
        }

        public static string Getbulletin(string bulletin)
        {
            return Getbulletin(bulletin, 0);
        }
        #endregion
    


   
</script>
<script src="/upfile/js/Silverlight.js" type="text/javascript"></script>
    <script type="text/javascript">
        function onSilverlightError(sender, args) {
            var appSource = "";
            if (sender != null && sender != 0) {
                appSource = sender.getHost().Source;
            }

            var errorType = args.ErrorType;
            var iErrorCode = args.ErrorCode;

            if (errorType == "ImageError" || errorType == "MediaError") {
                return;
            }

            var errMsg = "Silverlight 应用程序中未处理的错误 " + appSource + "\n";

            errMsg += "代码: " + iErrorCode + "    \n";
            errMsg += "类别: " + errorType + "       \n";
            errMsg += "消息: " + args.ErrorMessage + "     \n";

            if (errorType == "ParserError") {
                errMsg += "文件: " + args.xamlFile + "     \n";
                errMsg += "行: " + args.lineNumber + "     \n";
                errMsg += "位置: " + args.charPosition + "     \n";
            }
            else if (errorType == "RuntimeError") {
                if (args.lineNumber != 0) {
                    errMsg += "行: " + args.lineNumber + "     \n";
                    errMsg += "位置: " + args.charPosition + "     \n";
                }
                errMsg += "方法名称: " + args.methodName + "     \n";
            }

            alert(errMsg);
        }

        function printaction() {
            return  "<%=actionstring %>";
        }
        <%if(printdata.Length>0){ %>
        var printdata=<%=printdata %>;
        <%} %>
    </script>
    
  <div style="width: 900px;" class="order-pay-dialog-c" id="order-pay-dialog"><h3><span onclick="return X.boxClose();" class="close" id="order-pay-dialog-close">关闭</span></h3><div style="overflow-x: hidden; padding: 10px;">
	
    <object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="900" height="600">
		  <param name="source" value="<%=PageValue.WebRoot%>manage/silverlight/SilverlightApplication1.swf?id=<%=AS.Common.Utils.Helper.GetRandomString(4) %>"/>
		  <param name="onError" value="onSilverlightError" />
		  <param name="background" value="white" />
		  <param name="minRuntimeVersion" value="4.0.50826.0" />
		  <param name="autoUpgrade" value="true" />
		  <a href="http://go.microsoft.com/fwlink/?LinkID=149156&v=4.0.50826.0" style="text-decoration:none">
 			  <img src="http://go.microsoft.com/fwlink/?LinkId=161376" alt="获取 Microsoft Silverlight" style="border-style:none"/>
		  </a>
	    </object><iframe id="_sl_historyFrame" style="visibility:hidden;height:0px;width:0px;border:0px"></iframe>
	
	</div>
</div>