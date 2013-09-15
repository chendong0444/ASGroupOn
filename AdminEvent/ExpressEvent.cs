using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Controls;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess.Accessor;
using AS.Common.Utils;
using System.Web;
using AS.GroupOn.Domain.Spi;
using AS.GroupOn.DataAccess;
using AS.GroupOn.App;
using AS.Common;
using System.Collections.Specialized;
using System.Configuration;

namespace AS.AdminEvent
{
    /// <summary>
    /// 快递后台事件
    /// </summary>
    public class ExpressEvent
    { 
        private static RedirctResult result = null;
        public RedirctResult UpdateOrder(string express_no, string express_id, string hid)
        {
            OrderFilter orfilter = new OrderFilter();
            IOrder order = Store.CreateOrder();

            int id = Helper.GetInt(hid, 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                order = session.Orders.GetByID(id);
            }
            string expressId = express_id;//快递方式id
            string expressNo = express_no;//快递单号
            if (express_id == "0")
            {
                PageValue.SetMessage(new ShowMessageResult("请选择快递", false, false));
                result = new RedirctResult(HttpContext.Current.Request.UrlReferrer.AbsoluteUri, true);
            }
            else
            {
                if (expressNo == null || expressNo == "")
                {
                    expressNo = express_no;
                }
                order.Express_id = int.Parse(expressId);
                order.Express_no = expressNo;
                int ii = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ii = session.Orders.Update(order);
                }
                PageValue.SetMessage(new ShowMessageResult("修改快递信息成功", true, true));
                result = new RedirctResult(HttpContext.Current.Request.UrlReferrer.AbsoluteUri, true);
            }
            return result;
        }

        public RedirctResult UpdateKuaidi(string express_id, int hiId)
        {
            IOrder order = Store.CreateOrder();
            OrderFilter orderfilter = new OrderFilter();
            int id = Helper.GetInt(hiId, 0);
            int s = Helper.GetInt(express_id, 0);
            order.Id = id;
            order.Express_id = s;
            string key = FileUtils.GetKey();
            int branch_id = Helper.GetInt(CookieUtils.GetCookieValue("pbranch", key), 0);
            int existresult = 0;
            orderfilter.table = "[Order],orderdetail where [Order].Id=orderdetail.Order_id and [Order].Id=" + order.Id + " and orderdetail.Teamid in(select Id from Team where Team.branch_id=" + Helper.GetInt(CookieUtils.GetCookieValue("pbranch", key), 0) + ")";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                existresult = session.Orders.GetBranchCount(orderfilter);
            }
            if (existresult > 0)
            {
                if (order.Express_id == 0)
                {
                    PageValue.SetMessage(new ShowMessageResult("请选择快递！", false, false));
                    result = new RedirctResult(HttpContext.Current.Request.UrlReferrer.AbsoluteUri, true);
                }
                else
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        order = session.Orders.GetByID(order.Id);
                    }
                    if (order.Express_no == null)
                    {
                        order.Express_no = "";
                    }
                    order.Express_id = s;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int upresult = session.Orders.Update(order);
                    }
                    PageValue.SetMessage(new ShowMessageResult("修改快递信息成功", true, true));
                    result = new RedirctResult(HttpContext.Current.Request.UrlReferrer.AbsoluteUri, true);
                }
            }
            return result;
        }

        public RedirctResult UpKuaidi(string express_id, int hiId)
        {
            IOrder order = Store.CreateOrder();
            int id = Helper.GetInt(hiId, 0);
            int s = Helper.GetInt(express_id, 0);
            order.Id = id;
            order.Express_id = s;
            string key = FileUtils.GetKey();
            int partner_id = Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0);
            int b1 = 0;
            OrderFilter orfilter = new OrderFilter();
            orfilter.Id = id;
            orfilter.Partner_id = partner_id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                b1 = session.Orders.GetCount(orfilter);
            }
            if (b1 > 0)
            {
                if (order.Express_id == 0)
                {
                    PageValue.SetMessage(new ShowMessageResult("请选择快递！", false, false));
                    result = new RedirctResult(HttpContext.Current.Request.UrlReferrer.AbsoluteUri, true);
                }
                else
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        order = session.Orders.GetByID(order.Id);
                    }
                    if (order.Express_no == null)
                    {
                        order.Express_no = "";
                    }
                    order.Express_id = s;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int resultup = session.Orders.Update(order);
                    }
                    PageValue.SetMessage(new ShowMessageResult("修改快递信息成功", true, true));
                    result = new RedirctResult(HttpContext.Current.Request.UrlReferrer.AbsoluteUri, true);
                }
            }
            return result;
        }
    }
}
