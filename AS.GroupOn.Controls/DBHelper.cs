using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using AS.Common.Utils;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
using System.Collections;
using AS.GroupOn.App;
namespace AS.GroupOn.Controls
{
    public class DBHelper
    {
        #region 订单操作
        #region 判断订单总额含运费含折扣
        public static decimal GetTeamTotalPriceWithFare(int orderid)
        {
             
            decimal fare = 0;//运费
            decimal totalprice = 0;
            decimal totalamount = 0;
            int userid = 0;
            string sql = "select User_id,isnull(num,quantity) as num , isnull(teamprice,price) as price,ISNULL([orderdetail].Credit,Card) as cardprice from [order] left join [orderdetail] on([order].id=[orderdetail].order_id) where [order].id=" + orderid;
            DataTable table = new DataTable();
            //DataRowObject orderrow = null;//订单记录
            List<Hashtable> hashtable = null;
            IOrder order=Store.CreateOrder();
            IUser user = Store.CreateUser();

            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                  hashtable=  seion.GetData.GetDataList(sql);
            }

                table = Helper.ConvertDataTable(hashtable);

                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    order = seion.Orders.GetByID(orderid);
                }
                if (order != null && order.Fare != null)
                {
                    fare = order.Fare;

            for (int i = 0; i < table.Rows.Count; i++)
            {
                DataRowObject dro = new DataRowObject(table.Rows[i]);
                decimal tempprice = dro.ToInt("num") * dro.ToDecimal("price") ;
                if (dro.ToInt("cardprice") > 0)//当使用代金券后项目金额小于0时，将此代金券金额忽略
                {
                    tempprice = tempprice - dro.ToInt("cardprice");
                    if (tempprice < 0) tempprice = 0;
                }
                totalprice = totalprice + tempprice;
                userid = dro.ToInt("User_id");

               }

                     totalprice = totalprice - order.disamount;
               }


                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                  user =  seion.Users.GetByID(userid);
                }


            if (user !=null)
            {
                totalamount = user.totalamount;

            }

            if (ActionHelper.GetUserLevelMoney(totalamount) > 0)
            {
                totalprice = Convert.ToDecimal((totalprice * Convert.ToDecimal(ActionHelper.GetUserLevelMoney(totalamount))).ToString("f2"));
            }

            return totalprice+fare;
        }

        #endregion
        #endregion



    }
}
