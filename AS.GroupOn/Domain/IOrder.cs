using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
   public interface IOrder:IObj
    {
       /// <summary>
       /// 订单ID
       /// </summary>
       int Id { get; set; }
       /// <summary>
       /// 交易单号
       /// </summary>
       string Pay_id { get; set; }
       /// <summary>
       /// 付款方式(yeepay:易宝，alipay:支付宝,tenpay:财付通,chinabank:网银在线,credit:余额付款,cash:线下支付)
       /// </summary>
       string Service { get; set; }
       /// <summary>
       /// 会员ID
       /// </summary>
       int User_id { get; set; }
       /// <summary>
       /// 管理员ID
       /// </summary>
       int Admin_id { get; set; }
       /// <summary>
       /// 项目ID 如果项目ID为0则说明走购物车了应到orderdetail表查询项目
       /// </summary>
       int Team_id { get; set; }
       /// <summary>
       /// 城市ID 如果是快递项目则应记录用户下单所在的城市，如果是优惠券项目则应记录项目所在城市
       /// </summary>
       int City_id { get; set; }
       /// <summary>
       /// 代金券号(如果使用了代金券，此字段存储代金券编号) 
       /// </summary>
       string Card_id { get; set; }
       /// <summary>
       /// 支付状态(已支付:pay,未支付:unpay,已退款refund,用户已取消:cancel 未支付的积分订单:scoreunpay,已支付的积分订单:scorepay,已退单的积分订单：scorrefund)
       /// </summary>
       string State { get; set; }
       /// <summary>
       /// 数量 如果走购物车此处记录所有项目的总数量。
       /// </summary>
       int Quantity { get; set; }
       /// <summary>
       /// 真实姓名
       /// </summary>
       string Realname { get; set; }
       /// <summary>
       /// 移动电话
       /// </summary>
       string Mobile { get; set; }
       /// <summary>
       /// 邮编
       /// </summary>
       string Zipcode { get; set; }
       /// <summary>
       /// 地址
       /// </summary>
       string Address { get; set; }
       /// <summary>
       /// 递送方式（快递或券）Y快递 N券 D抽奖 P站外券 
       /// </summary>
       string Express { get; set; }
       /// <summary>
       /// 是否已打印
       /// </summary>
       string Express_xx { get; set; }
       /// <summary>
       /// 快递公司ID
       /// </summary>
       int Express_id { get; set; }
       /// <summary>
       /// 快递单号
       /// </summary>
       string Express_no { get; set; }
       /// <summary>
       /// 商品单价
       /// </summary>
       decimal Price { get; set; }
       /// <summary>
       /// 在线支付费用
       /// </summary>
       decimal Money { get; set; }
       /// <summary>
       /// 总款(含运费)
       /// </summary>
       decimal Origin { get; set; }
       /// <summary>
       /// 余额付款
       /// </summary>
       decimal Credit { get; set; }
       /// <summary>
       /// 代金券费
       /// </summary>
       decimal Card { get; set; }
       /// <summary>
       /// 快递费
       /// </summary>
       decimal Fare { get; set; }
       /// <summary>
       /// 订单附言
       /// </summary>
       string Remark { get; set; }
       /// <summary>
       /// 生成时间
       /// </summary>
       DateTime Create_time { get; set; }
       /// <summary>
       /// 支付时间
       /// </summary>
       DateTime? Pay_time { get; set; }
       /// <summary>
       /// 记录下订单时的来源地址
       /// </summary>
       string IP_Address { get; set; }
       /// <summary>
       /// 产品规格
       /// </summary>
       string result { get; set; }
       /// <summary>
       /// 订单时的来源域名
       /// </summary>
       string fromdomain { get; set; }
       /// <summary>
       /// 退款方式 1代表退款到余额 2代表退款到其他地方
       /// </summary>
       int refundtype { get; set; }
       /// <summary>
       /// 管理员备注
       /// </summary>
       string adminremark { get; set; }
       /// <summary>
       /// 订单返还的总积分数,如果是非积分项目则为返还值，如果是积分项目则为0
       /// </summary>
       int orderscore { get; set; }
       /// <summary>
       /// 折扣率????
       /// </summary>
       double discount { get; set; }
       /// <summary>
       /// 订单花费总积分
       /// </summary>
       int totalscore { get; set; }
       /// <summary>
       /// 抽奖项目的短信认证码 4位
       /// </summary>
       string checkcode { get; set; }
       /// <summary>
       /// 参加活动后的应减去的优惠金额 不能为空
       /// </summary>
       decimal disamount { get; set; }
       /// <summary>
       /// 参加活动的优惠信息
       /// </summary>
       string disinfo { get; set; }
       /// <summary>
       /// 如果此订单是被拆分后的子订单，则保存父订单ID,否则为0 不能为空
       /// </summary>
       int Parent_orderid { get; set; }
       /// <summary>
       /// 如果启用订单拆分，此处保存拆分后的商户ID 不能为空
       /// </summary>
       int Partner_id { get; set; }
       /// <summary>
       /// 货到付款金额,不能为空,默认为0
       /// </summary>
       decimal cashondelivery { get; set; }
       /// <summary>
       /// 促销活动返给用户的金额,不能为空,默认为0
       /// </summary>
       decimal Returnmoney { get; set; }
       /// <summary>
       /// 订单退款的状态
       /// </summary>
       int rviewstate { get; set; }
       /// <summary>
       /// 管理员审核备注
       /// </summary>
       string rviewremarke { get; set; }
       /// <summary>
       /// 用户申请退款备注
       /// </summary>
       string userremarke { get; set; }
       /// <summary>
       /// 启用订单拆分，当前订单给商户结算的运费（计算方式为：当前订单中的最大运费金额的项目运费）
       /// </summary>
       decimal Partnerfare { get; set; }
       /// <summary>
       /// 货到付款，记录同属于一订单的订单编号
       /// </summary>
       int CashParent_orderid { get; set; }
       /// <summary>
       /// 退款时间
       /// </summary>
       DateTime? refundTime { get; set; }
       /////////////////////////////////////////////////////////////////
       /// <summary>
       /// 订单中参加活动的优惠信息
       /// </summary>
       string Disinfos { get; }
       /// <summary>
       /// 订单中的项目列表
       /// </summary>
       IList<ITeam> Teams { get; }
       /// <summary>
       /// 订单详情
       /// </summary>
       IList<IOrderDetail> OrderDetail { get; }
       /// <summary>
       /// 返回订单是否还允许付款。true 允许 false 不允许
       /// </summary>
       bool CanPay { get; }

       /// <summary>
       /// 不走购物车得到的项目
       /// </summary>
       ITeam Team { get; }
       /// <summary>
       /// 订单下面的用户
       /// </summary>
       IUser User { get; }
       /// <summary>
       /// 订单下面所属的商户
       /// </summary>
       IPartner Partner { get; }
       /// <summary>
       /// 临时订单号 不需要存入数据库
       /// </summary>
       string TempID { get; set; }

       ICategory Category { get; }

       IUserReview UserReview { get; }

       string all_id { get; set; }

       int printid { get; set; }
       int orderid { get; set; }
       int teamid { get; set; }

       /*--关联user表字段--*/
       string Username { get; set; }
       string Email { get; set; }

       int vtid { get; set; }
       int urid { get; set; }
       DateTime ur_create_time { get; set; }

       int tid { get; set; }
       string ttitle { get; set; }
       int tpartnerid { get; set; }
       string ptitle { get; set; }
       int urevid { get; set; }
       int uPartner_id { get; set; }
       DateTime urecreate_time { get; set; }
       string urtype { get; set; }

    }
}
