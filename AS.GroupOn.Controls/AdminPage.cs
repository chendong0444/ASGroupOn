using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.Common.Utils;
using AS.GroupOn.Domain.Spi;
using System.Collections.Specialized;

namespace AS.GroupOn.Controls
{
   public class AdminPage :BasePage
    {
       protected override void OnLoad(EventArgs e)
       {
           base.OnLoad(e);
           if (!IsAdmin && !PartnerPage.IsPartnerAdmin&&!SalePage.IsSaleAdmin&&!PartnerBranchPage.IsPartnerBranchAdmin)
           {
               Response.Write("<script>alert('管理员帐号已失效，请重新登录！');window.parent.location.href='" + GetUrl("后台管理", "Login.aspx") + "';</script>");
               Response.End();
               
           }
           
       }
    

       /// <summary>
       /// 判断管理员是否拥有此操作权限
       /// </summary>
       /// <param name="userModel"></param>
       /// <param name="actionEnum"></param>
       /// <returns></returns>
       public static bool CheckUserOptionAuth(IUser user, ActionEnum actionEnum)
       {
          //如果返回true表示没有当前的页面的操作权限
           bool ok = true;
           if (user.Id == 1)
           {
               return false;
           }
           foreach (IRole role in user.Role)
           {
               IRoleAuthority roleauthority = null;
               RoleAuthorityFilter raf = new RoleAuthorityFilter();
               raf.RoleID = role.Id;
               raf.AuthorityID = AS.Common.Utils.Helper.GetInt(actionEnum, 0);
               using (IDataSession session = App.Store.OpenSession(false))
               {
                   roleauthority = session.RoleAuthority.Get(raf);
               }
               if (roleauthority != null)
               {
                   ok = false;
                  return ok;
               }

           }
         
           return ok;
       }

       /// <summary>
       /// 判断当前管理员是否登录
       /// </summary>
       public static bool IsAdmin
       {
           get
           {
               if (AS.Common.Utils.WebUtils.GetLoginAdminID() > 0)
               {
                   return true;
               }
               else
               {
                   return false;
               }

           }
       }
       private static IUser _asadmin = null;
       /// <summary>
       /// 返回当前管理员
       /// </summary>
       public static IUser AsAdmin
       {
           get
           {
               if (_asadmin == null)
               {
                   if (WebUtils.GetLoginAdminID() > 0)
                   {
                       using (IDataSession session = App.Store.OpenSession(false))
                       {
                           _asadmin = session.Users.GetByID(WebUtils.GetLoginAdminID());
                       }
                   }
               }
               return _asadmin;
           }
       }
       /// <summary>
       /// 判断管理员页面访问权限
       /// </summary>
       /// <param name="userRole">用户角色代码</param>
       public static bool CheckUserAuth(string userRole)
       {
           bool ok = false;
           if (PageValue.CurrentAdmin != null)
           {
               if (PageValue.CurrentAdmin.auth.IndexOf("{" + userRole + "}") >= 0)
               {
                   ok = true;
               }
               if (IsAdmin) ok = true;
           }
           return ok;
       }

       /// <summary>
       /// 根据订单递送方式字段返回中文信息
       /// </summary>
       /// <param name="express">N or Y</param>
       /// <returns></returns>
       public static string GetOrderExpress(IOrder order)
       {
           string html = "";
           if (order != null)
           {
               if (order.Express.ToString() == "Y")
                   html = "快递";
               else if (order.Express.ToString() == "N")
                   html = "优惠券";
               else if (order.Express.ToString() == "D")//抽奖的类型
                   html = "抽奖";
               else if (order.Express.ToString() == "P")//商户优惠券
                   html = "商户优惠券";
               if (order.State.ToString() == "pay" || order.State.ToString() == "nocod")
               {
                   if (order.Category != null && order.Category.Name.ToString() != String.Empty)
                       html = html + "<br>" + order.Category.Name;
                   if (order.Express_no != null && order.Express_no.ToString() != String.Empty)
                       html = html + "<br>" + order.Express_no;
                   if (order.Express_xx != null && order.Express_xx.ToString() != String.Empty)
                       html = html + "<br>" + order.Express_xx;
               }
           }
           return html;
       }
     

       #region 1管理员入库 2管理员出库 3下单出库 4下单入库
       public static void intoorder(int orderid, int num, int state, int teamid, int userid, string guige, int type)
       {
           Iinventorylog logmodel = AS.GroupOn.App.Store.CreateInventorylog();
           logmodel.teamid = teamid;
           logmodel.orderid = orderid;
           logmodel.num = num;
           if (state == 1)
           {
               logmodel.remark = "管理员入库" + guige;
           }
           else if (state == 2)
           {
               logmodel.remark = "管理员出库" + guige;
           }
           else if (state == 3)
           {
               logmodel.remark = "下单出库" + guige;
           }
           else if (state == 4)
           {
               logmodel.remark = "退单入库" + guige;
           }
           logmodel.teamid = teamid;
           logmodel.state = state;
           logmodel.adminid = userid;
           logmodel.create_time = DateTime.Now;
           logmodel.type = type;
           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
           {
               int id2 = session.Inventorylog.Insert(logmodel);
           }
       }
       #endregion

       #region Flow表操作
       public static int Flow_Insert(int user_id, int admin_id, string detail_id, string detail, ActionHelper.Flow_Direction direction, decimal money, ActionHelper.Flow_Action action)
       {
           string error = String.Empty;
           string direction_str = null;
           switch (direction)
           {
               case ActionHelper.Flow_Direction.expense:
                   direction_str = "expense";
                   break;
               case ActionHelper.Flow_Direction.income:
                   direction_str = "income";
                   break;
           }
           string action_str = null;
           switch (action)
           {
               case ActionHelper.Flow_Action.buy:
                   action_str = "buy";
                   break;
               case ActionHelper.Flow_Action.cash:
                   action_str = "cash";
                   break;
               case ActionHelper.Flow_Action.charge:
                   action_str = "charge";
                   break;
               case ActionHelper.Flow_Action.coupon:
                   action_str = "coupon";
                   break;
               case ActionHelper.Flow_Action.invite:
                   action_str = "invite";
                   break;
               case ActionHelper.Flow_Action.refund:
                   action_str = "refund";
                   break;
               case ActionHelper.Flow_Action.store:
                   action_str = "store";
                   break;
               case ActionHelper.Flow_Action.withdraw:
                   action_str = "withdraw";
                   break;
           }
           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
           {
               IFlow flowfil = AS.GroupOn.App.Store.CreateFlow();
               flowfil.User_id = user_id;
               flowfil.Admin_id = admin_id;
               flowfil.Detail_id = detail_id;
               flowfil.Direction = direction_str;
               flowfil.Action = action_str;
               flowfil.Detail=detail;
               flowfil.Money = money;
               flowfil.Create_time = DateTime.Now;
               int i = 0;
           }
            List<Hashtable> hashtable = null;
            DataTable table = new DataTable();
           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
           {
               hashtable = session.GetData.GetDataList("select isnull(@@IDENTITY,0) as id");
           }
           table = Helper.ConvertDataTable(hashtable);
           DataRowObject dro = null;
           if (table.Rows.Count > 0)
           {
               if (table.Rows.Count > 0)
               {
                   dro = new DataRowObject(table.Rows[0]);
               }
           }
           return dro.ToInt("id");
       }

       #endregion
      
    }
}
