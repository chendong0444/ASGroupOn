using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 订单详情表只显示快递项目
    /// </summary>
    public class OrderDetail : Obj, IOrderDetail
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 订单ID
        /// </summary>
        public virtual int Order_id { get; set; }
        /// <summary>
        /// 数量
        /// </summary>
        public virtual int Num { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        public virtual int Teamid { get; set; }
        /// <summary>
        /// 单价
        /// </summary>
        public virtual decimal Teamprice { get; set; }
        /// <summary>
        /// 规格
        /// </summary>
        public virtual string result { get; set; }
        /// <summary>
        /// 券号
        /// </summary>
        public virtual string carno { get; set; }
        private int _Credit = 0;
        /// <summary>
        /// 代金券金额
        /// </summary>
        public virtual int Credit
        {
            get
            {
                return _Credit;
            }
            set
            {
                _Credit = value;
            }
        }
        private int _Discount = 0;
        /// <summary>
        /// 折扣率
        /// </summary>
        public virtual int discount
        {
            get
            {
                return _Discount;
            }
            set
            {
                _Discount = value;
            }
        }

        private int _TotalScore = 0;
        /// <summary>
        /// 项目花费积分/个
        /// </summary>
        public virtual int totalscore
        {
            get
            {
                return _TotalScore;
            }
            set
            {
                _TotalScore = value;
            }
        }
        private int _orderscore = 0;
        /// <summary>
        /// 订单返积分明细
        /// </summary>
        public virtual int orderscore
        {
            get
            {
                return _orderscore;
            }
            set
            {
                _orderscore = value;
            }
        }
        private IOrder _order = null;
        /// <summary>
        /// 订单
        /// </summary>
        public virtual IOrder Order
        {
            get
            {
                if (_order == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _order = session.Orders.GetByID(this.Order_id);
                    }
                }
                return _order;
            }
        }

        private ITeam _team = null;
        /// <summary>
        /// 项目
        /// </summary>
        public virtual ITeam Team
        {
            get
            {
                if (_team == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _team = session.Teams.GetByID(Teamid);
                    }
                    if (_team == null)
                        _team = AS.GroupOn.Domain.Spi.Team.GetDefault();
                }
                return _team;
            }
        }

        /// <summary>
        /// 临时订单号 不需要存入数据库
        /// </summary>
        public virtual string TempOrderID { get; set; }

        /*--关联Team表--*/
        public virtual string Title { get; set; }
        public virtual string Product { get; set; }
    }
}
