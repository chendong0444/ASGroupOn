using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：退款
    /// </summary>
    public class Refunds : Obj, IRefunds
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 状态字段1 客服申请2 商户审核通过 4等待财务接受 8财务接受 16 财务处理完毕
        /// </summary>
        public virtual int State { get; set; }
        /// <summary>
        /// 申请退款时间
        /// </summary>
        public virtual DateTime? Create_Time { get; set; }
        /// <summary>
        /// 商户查看时间
        /// </summary>
        public virtual DateTime? PartnerViewTime { get; set; }
        /// <summary>
        /// 订单ID
        /// </summary>
        public virtual int Order_ID { get; set; }
        /// <summary>
        /// In Order.id where city_id
        /// </summary>
        public virtual int inorder_id { get; set; }
        /// <summary>
        /// 退款金额
        /// </summary>
        public virtual decimal Money { get; set; }
        /// <summary>
        /// 商户ID 
        /// </summary>
        public virtual int PartnerID { get; set; }
        /// <summary>
        /// 等待财务接受时间
        /// </summary>
        public virtual DateTime? FinanceBeginTime { get; set; }
        /// <summary>
        /// 财务处理时间
        /// </summary>
        public virtual DateTime? FinanceEndTime { get; set; }
        /// <summary>
        /// 1余额退款 2其他方式退款
        /// </summary>
        public virtual int RefundMeans { get; set; }
        /// <summary>
        /// 由客服填写 退款原因
        /// </summary>
        public virtual string Reason { get; set; }
        /// <summary>
        /// 由财务填写 退款结果
        /// </summary>
        public virtual string Result { get; set; }
        /// <summary>
        /// 申请退款的管理员ID
        /// </summary>
        public virtual int CreateUserID { get; set; }
        /// <summary>
        /// 处理的管理员ID
        /// </summary>
        public virtual int AdminID { get; set; }

        ///////////////////////////////

        private IList<IRefunds_detail> _refunds_details = null;
        /// <summary>
        /// 退款详情
        /// </summary>
        public virtual IList<IRefunds_detail> Refunds_details
        {
            get
            {
                if (_refunds_details == null)
                {
                    Refunds_detailFilter filter = new Refunds_detailFilter();
                    filter.refunds_id = this.Id;
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _refunds_details = session.Refunds_detail.GetList(filter);
                    }
                }
                return _refunds_details;
            }
        }
        private IOrder _order = null;
        /// <summary>
        /// 订单详情
        /// </summary>
        public virtual IOrder Order
        {
            get
            {
                
                    if (_order == null)
                    {
                        using (IDataSession session = App.Store.OpenSession(false))
                        {
                            _order = session.Orders.GetByID(this.Order_ID);
                        }
                    }
                
                return _order;
            }
        }
        private IPartner _partner = null;
        /// <summary>
        /// 所属商户
        /// </summary>
        public IPartner Partner
        {
            get
            {
                if (_partner == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _partner = session.Partners.GetByID(this.PartnerID);
                    }
                }
                return _partner;
            }
        }
        private string _statename = String.Empty;
        /// <summary>
        /// 状态中文名称
        /// </summary>
        public string StateName
        {
            get
            {
                if (_statename == String.Empty)
                {
                    switch (State)
                    {
                        case 1:
                            _statename = "等待商户确认";
                            break;
                        case 4:
                            _statename = "等待财务接受";
                            break;
                        case 8:
                            _statename = "财务正在处理";
                            break;
                        case 16:
                            _statename = "财务处理完毕";
                            break;
                    }
                }
                return _statename;
            }
        }
        string _refundmeansname = String.Empty;
        /// <summary>
        /// 退款方式
        /// </summary>
        public string RefundMeansName
        {
            get
            {
                if (_refundmeansname.Length == 0)
                {
                    switch (RefundMeans)
                    {
                        case 1:
                            return "余额退款";
                        case 2:
                            return "其他途径退款";
                    }
                }
                return _refundmeansname;
            }
        }

    }
}
