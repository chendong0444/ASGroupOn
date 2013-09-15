using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：产品库
    /// </summary>
    public class Product:Obj,IProduct
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 产品名称
        /// </summary>
        public virtual string productname { get; set; }
        /// <summary>
        /// 成本价
        /// </summary>
        public virtual decimal price { get; set; }
        /// <summary>
        /// 库存
        /// </summary>
        public virtual int inventory { get; set; }
        /// <summary>
        /// 产品图片
        /// </summary>
        public virtual string imgurl { get; set; }
        /// <summary>
        /// 产品详情
        /// </summary>
        public virtual string detail { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        public virtual int sortorder { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        public virtual DateTime createtime { get; set; }
        /// <summary>
        /// 上下架状态 1上架,2被拒绝,4待审核,8 下架
        /// </summary>
        public virtual int status { get; set; }
        /// <summary>
        /// 产品规格名称
        /// </summary>
        public virtual string bulletin { get; set; }
        /// <summary>
        /// 库存开关 0关闭 1开启
        /// </summary>
        public virtual int open_invent { get; set; }
        /// <summary>
        /// 商户ID
        /// </summary>
        public virtual int partnerid { get; set; }
        /// <summary>
        /// in partnerId
        /// </summary>
        public virtual int inpartnerId { get; set; }
        /// <summary>
        /// 产品库存规格
        /// </summary>
        public virtual string invent_result { get; set; }
        /// <summary>
        /// 销售价
        /// </summary>
        public virtual decimal team_price { get; set; }
        /// <summary>
        /// 品牌ID
        /// </summary>
        public virtual int brand_id { get; set; }
        /// <summary>
        /// 产品简介
        /// </summary>
        public virtual string summary { get; set; }
        /// <summary>
        /// 如果是管理员添加产品则为管理员ID,否则为0
        /// </summary>
        public virtual int adminid { get; set; }
        /// <summary>
        /// 代表操作员类型 0代表管理员操作。1代表商户操作
        /// </summary>
        public virtual int operatortype { get; set; }
        /// <summary>
        /// 备注信息比如：审核未通过原因等
        /// </summary>
        public virtual string ramark { get; set; }
        private IPartner _partner = null;
        /// <summary>
        /// 放回商户表对象
        /// </summary>
        public virtual IPartner Partner
        {
            get 
            {
                if (_partner == null)
                {
                    using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                    { 
                        _partner= session.Partners.GetByID(this.partnerid);
                    }
                }
                return _partner;
            }
        }
       
    }
}
