using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：产品库
    /// </summary>
    public interface IProduct:IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 产品名称
        /// </summary>
        string productname { get; set; }
        /// <summary>
        /// 成本价
        /// </summary>
        decimal price { get; set; }
        /// <summary>
        /// 库存
        /// </summary>
        int inventory { get; set; }
        /// <summary>
        /// 产品图片
        /// </summary>
        string imgurl { get; set; }
        /// <summary>
        /// 产品详情
        /// </summary>
        string detail { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        int sortorder { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        DateTime createtime { get; set; }
        /// <summary>
        /// 上下架状态 1上架,2被拒绝,4待审核,8 下架
        /// </summary>
        int status { get; set; }
        /// <summary>
        /// 产品规格名称
        /// </summary>
        string bulletin { get; set; }
        /// <summary>
        /// 库存开关 0关闭 1开启
        /// </summary>
        int open_invent { get; set; }
        /// <summary>
        /// 商户ID
        /// </summary>
        int partnerid { get; set; }
        /// <summary>
        /// in partnerId
        /// </summary>
        int inpartnerId { get; set; }
        /// <summary>
        /// 产品库存规格
        /// </summary>
        string invent_result { get; set; }
        /// <summary>
        /// 销售价
        /// </summary>
        decimal team_price { get; set; }
        /// <summary>
        /// 品牌ID
        /// </summary>
        int brand_id { get; set; }
        /// <summary>
        /// 产品简介
        /// </summary>
        string summary { get; set; }
        /// <summary>
        /// 如果是管理员添加产品则为管理员ID,否则为0
        /// </summary>
        int adminid { get; set; }
        /// <summary>
        /// 代表操作员类型 0代表管理员操作。1代表商户操作
        /// </summary>
        int operatortype { get; set; }
        /// <summary>
        /// 备注信息比如：审核未通过原因等
        /// </summary>
        string ramark { get; set; }
        /// <summary>
        /// 返回商户 对象
        /// </summary>
        IPartner Partner { get; }
    }
}
