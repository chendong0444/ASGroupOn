using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public class Flow:Obj,IFlow
    {
        /// <summary>
        /// 主键
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 用户ID
        /// </summary>
       public virtual int User_id { get; set; }
        /// <summary>
        /// 如果此记录是后台充值记录，则此字段保存为用户充值的管理员的UserID
        /// </summary>
       public virtual int Admin_id { get; set; }
        /// <summary>
        /// 记录订单交易号(如果是在线支付格式为：项目IDas用户idas订单idashhmmss，如果是在线充值为0as用户IDas0ashhmmss，如果是管理员人工充值则为0，如果是优惠券返利则记录的是优惠券表的ID，如果是邀请返利则为0)
        /// </summary>
       public virtual string Detail_id { get; set; }
        /// <summary>
        /// 描述
        /// </summary>
       public virtual string Detail { get; set; }
        /// <summary>
        /// 消费类型( 收益:income, 花费:expense)
        /// </summary>
       public virtual string Direction { get; set; }
        /// <summary>
        /// 收益或消费金额
        /// </summary>
       public virtual decimal Money { get; set; }
        /// <summary>
        /// 消费方式(购买:buy,在线充值 charge,优惠券返利:coupon,邀请好友:invite,store:线下充值,withdraw:提现,cash:现金支付,refund:退款,review:到货评价)
        /// </summary>
    public virtual string Action { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
      public virtual  DateTime Create_time { get; set; }


      private ITeam _team = null;

      public virtual ITeam Team
      {
          get {

              if (_team == null)
              {
                  
                  ////直接得到订单号，根据订单号去退款表查项目
                  //if (!Detail_id.ToString().Contains("as"))
                  //{
                  //    IOrder order = AS.GroupOn.App.Store.CreateOrder();

                  //}
                  //if (Detail_id.ToString().Substring(0,1) == "0")
                  //{
                   
                  //}
                  if (Detail_id.ToString().Contains("as") && Detail_id.ToString().Substring(0, 1) != "0")
                  {
                      string str = Detail_id.ToString().Replace("as", ",");
                      string[] strq=str.Split(',');
                      using (IDataSession session = App.Store.OpenSession(false))
                      {
                          _team  = session.Teams.GetByID(Convert.ToInt32(strq[0]));
                      }

                  }
              
              }

              return _team;
          
          }
      }
  
      private IPay _pay = null;

      public virtual  IPay Pay
      {
          get {

              if (_pay == null)
              {
                  using (IDataSession session = App.Store.OpenSession(false))
                  {
                      _pay = session.Pay.GetByID(Detail_id);
                  }
              }
              return _pay;
          }
      }


      private IUser _user = null;
      /// <summary>
      /// 订单下面的用户
      /// </summary>
      public virtual IUser User
      {
          get
          {
              if (_user == null)
              {
                  using (IDataSession session = App.Store.OpenSession(false))
                  {
                      _user = session.Users.GetByID(User_id);
                  }
              }
              return _user;
          }

      }
       /// <summary>
       /// 得到操作员
       /// </summary>
      private IUser _userAdmin = null;

      public virtual  IUser UserAdmin
      {
          get {

              if (_userAdmin == null)
              {
                  using (IDataSession session = App.Store.OpenSession(false))
                  {
                      _userAdmin = session.Users.GetByID(Admin_id);
                  }
              }

              return _userAdmin;
          
          }
          
      }


    }
}
