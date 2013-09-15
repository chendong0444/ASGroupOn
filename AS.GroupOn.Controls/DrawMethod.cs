using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using AS.GroupOn.Domain;
using System.Collections;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using AS.Common.Utils;
using AS.GroupOn.App;
using System.Collections.Specialized;
using AS.GroupOn.Domain.Spi;


namespace AS.GroupOn.Controls
{
    public class DrawMethod
    {
        #region 判断手机号是否参加过抽奖活动
        public static bool isUserMobile(string mobile, int teamid)
        {
            bool falg = false;
            OrderFilter of = new OrderFilter();
            of.Team_id = teamid;
            of.Mobile = mobile;
            of.State = "pay";
            IList<IOrder> list = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                list = session.Orders.GetList(of);
            }
            if (list != null && list.Count > 0)
                falg = true;
            return falg;
        }
        #endregion

        #region 判断认证码是否参加过抽奖活动
        public static bool ischeckcode(string checkcode, int userid)
        {
            bool falg = false;
            OrderFilter of = new OrderFilter();
            of.checkcode = checkcode;
            of.User_id = userid;
            IList<IOrder> list = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                list = session.Orders.GetList(of);
            }
            if (list != null && list.Count > 0)
                falg = true;
            return falg;
        }
        #endregion

        #region 判断此订单是否参加了抽奖
        public static bool isDraw(int orderid)
        {
            bool falg = false;
            IList<IDraw> list = null;
            DrawFilter df = new DrawFilter();
            df.orderid = orderid;
            using (IDataSession session = Store.OpenSession(false))
            {
                list = session.Draw.GetList(df);
            }
            if (list != null && list.Count > 0)
            {
                falg = true;
            }
            return falg;
        }
        #endregion

        #region 生成认证码的方法
        public static string GetCode(int Teamid)
        {
            string code = "";
            code = Utility.RndNum(4).ToString();
            return code;
        }
        #endregion

        #region 获取抽奖号码
        public static string GetDrawCode(int orderid)
        {
            string code = "";
            DrawFilter df = new DrawFilter();
            IDraw draw = null;
            df.orderid = orderid;
            using (IDataSession session = Store.OpenSession(false))
            {
                draw = session.Draw.Get(df);
            }
            if (draw != null)
                code = draw.number;
            return code;
        }
        #endregion
    }
}
