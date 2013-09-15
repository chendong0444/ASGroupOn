using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
namespace AS.GroupOn.Domain
{
   public interface ITeam:IObj
    {
       /// <summary>
        /// 项目ID
       /// </summary>
       int Id { get; set; }
       /// <summary>
       /// 管理员ID
       /// </summary>
       int User_id { get; set; }
       /// <summary>
       /// 项目名称
       /// </summary>
       string Title { get; set; }
       /// <summary>
       /// 项目简介
       /// </summary>
       string Summary { get; set; }
       /// <summary>
       /// 城市ID
       /// </summary>
       int City_id { get; set; }
       /// <summary>
       /// API分类ID
       /// </summary>
       int Group_id { get; set; }
       /// <summary>
       /// 商户ID
       /// </summary>
       int Partner_id { get; set; }

       string System { get; set; }
       /// <summary>
       /// 团购价
       /// </summary>
       decimal Team_price { get; set; }
       /// <summary>
       /// 市场价
       /// </summary>
       decimal Market_price { get; set; }
       /// <summary>
       /// 产品名称
       /// </summary>
       string Product { get; set; }
       /// <summary>
       /// 每人限购数量
       /// </summary>
       int Per_number { get; set; }
       /// <summary>
       /// 最小成团人数
       /// </summary>
       int Min_number { get; set; }
       /// <summary>
       /// 最大购买人数
       /// </summary>
       int Max_number { get; set; }
       /// <summary>
       /// 当前购买人数
       /// </summary>
       int Now_number { get; set; }
       /// <summary>
       /// 是否允许手动更新人数(0不允许，1允许)为1时 后台修改了当前购买人数 保存时 进行更新
       /// </summary>
       int Manualupdate { get; set; }
       /// <summary>
       /// 商品图片
       /// </summary>
       string Image { get; set; }
       /// <summary>
       /// 商品图片1
       /// </summary>
       string Image1 { get; set; }
       /// <summary>
       /// 商品图片2
       /// </summary>
       string Image2 { get; set; }
       /// <summary>
       /// 手机商品图片
       /// </summary>
       string PhoneImg { get; set; }
       /// <summary>
       /// 视频地址
       /// </summary>
       string Flv { get; set; }
        /// <summary>
        /// 手机号码
        /// </summary>
       string Mobile { get; set; }

       /// <summary>
       /// 优惠券(消费返利金额)
       /// </summary>
       int Credit { get; set; }
       /// <summary>
       /// 代金券使用(可使用代金券最大面额)
       /// </summary>
       int Card { get; set; }
       /// <summary>
       /// 快递费
       /// </summary>
       int Fare { get; set; }
       /// <summary>
       /// 免单数量
       /// </summary>
       int Farefree { get; set; }
       /// <summary>
       /// 邀请返利(邀请好友参与本单商品购买时的返利金额)
       /// </summary>
       int Bonus { get; set; }

       /// <summary>
       /// 地址
       /// </summary>
       string Address { get; set; }

       /// <summary>
       /// 本单详情
       /// </summary>
       string Detail { get; set; }
       /// <summary>
       /// 团购网站推广辞
       /// </summary>
       string Systemreview { get; set; }
       /// <summary>
       /// 他们说
       /// </summary>
       string Userreview { get; set; }
       /// <summary>
       /// 特别提示
       /// </summary>
       string Notice { get; set; }
       /// <summary>
       /// 配送说明
       /// </summary>
       string Express { get; set; }
       /// <summary>
       /// 快递方式优惠券:coupon,快递:express,站外券:pcoupon抽奖:draw pickup default ‘coupon’ not null
       /// </summary>
       string Delivery { get; set; }
       /// <summary>
       /// 项目状态
       /// </summary>
       string State { get; set; }
       /// <summary>
       /// 购买人数或产品购买数量成团(为N以产品购买数量成团)为Y以购买人数成团
       /// </summary>
       string Conduser { get; set; }
       /// <summary>
       /// 只允许购买一次
       /// </summary>
       string Buyonce { get; set; }
       /// <summary>
       /// 项目类型
       /// </summary>
       string Team_type { get; set; }
       /// <summary>
       /// 排序
       /// </summary>
       int Sort_order { get; set; }

       /// <summary>
       /// 优惠卷开始时间
       /// </summary>
       DateTime? start_time { get; set; }

       /// <summary>
       /// 优惠券结束时间
       /// </summary>
       DateTime Expire_time { get; set; }
       /// <summary>
       /// 项目开始时间
       /// </summary>
       DateTime Begin_time { get; set; }
       /// <summary>
       /// 项目结束时间
       /// </summary>
       DateTime End_time { get; set; }
       /// <summary>
       /// 达到成功团购人数的时间
       /// </summary>
       DateTime? Reach_time { get; set; }
       /// <summary>
       /// 项目卖光时间
       /// </summary>
       DateTime? Close_time { get; set; }
       /// <summary>
       /// 产品规格属性
       /// </summary>
       string bulletin { get; set; }
       /// <summary>
       /// 每次加油数量
       /// </summary>
       int update_value { get; set; }
       /// <summary>
       /// 每次加油间隔时间
       /// </summary>
       int time_state { get; set; }
       /// <summary>
       /// 倒计时剩余时间
       /// </summary>
       int time_interval { get; set; }
       /// <summary>
       /// 加油人数上限
       /// </summary>
       int autolimit { get; set; }
       /// <summary>
       /// 运费计算方式0代表在项目中直接输入了快递费,>0代表在项目中选择快递模版ID
       /// </summary>
       int freighttype { get; set; }
      
       /// <summary>
       /// 库存总数量
       /// </summary>
       int inventory { get; set; }
       /// <summary>
       /// 库存报警数量
       /// </summary>
       int invent_war { get; set; }
       /// <summary>
       /// 库存规格数量 字符串拼接 如果有规格,总数量=规格数量之和
       /// </summary>
       string invent_result { get; set; }
       /// <summary>
       /// 项目消耗积分数字段
       /// </summary>
       int teamscore { get; set; }
       /// <summary>
       /// 购买一个项目所返积分
       /// </summary>
       int score { get; set; }
       /// <summary>
       /// SEO标题
       /// </summary>
       string seotitle { get; set; }
       /// <summary>
       /// SEO关键字
       /// </summary>
       string seokeyword { get; set; }
       /// <summary>
       /// SEO描述
       /// </summary>
       string seodescription { get; set; }
       /// <summary>
       /// 品牌ID
       /// </summary>
       int brand_id { get; set; }
       /// <summary>
       /// 是否开启库存功能 0关闭 1开启
       /// </summary>
       int open_invent { get; set; }
       /// <summary>
       /// 是否开启库存报警功能 0关闭 1开启
       /// </summary>
       int open_war { get; set; }
       /// <summary>
       /// 库存报警电话
       /// </summary>
       string warmobile { get; set; }

       /// <summary>
       /// 最小购买数量
       /// </summary>
       int Per_minnumber { get; set; }

       /// <summary>
       /// 商户模式(0老模式，1新模式)
       /// </summary>
       int shanhu { get; set; }

       /// <summary>
       /// 抽奖活动是否开启短信验证,yes开启 no不开启
       /// </summary>
       string codeswitch { get; set; }
       /// <summary>
       /// 买家评论返利金额
       /// </summary>
       decimal commentscore { get; set; }
       /// <summary>
       /// 项目输出到其他城市ID 用,分开
       /// </summary>
       string othercity { get; set; }
       /// <summary>
       /// 网站分类ID
       /// </summary>
       int cataid { get; set; }
       /// <summary>
       ///首页推荐商品 0否 1是
       /// </summary>
       int teamhost { get; set; }
       /// <summary>
       /// 首页新品 0否 1是
       /// </summary>
       int teamnew { get; set; }
       /// <summary>
       /// 关键字
       /// </summary>
       string catakey { get; set; }
       /// <summary>
       /// 是否api输出
       /// </summary>
       int apiopen { get; set; }
       /// <summary>
       /// 产品ID 为0时表示不关联产品库
       /// </summary>
       int productid { get; set; }
       /// <summary>
       /// 成本价
       /// </summary>
       decimal cost_price { get; set; }
       /// <summary>
       ///优惠券结算方式 Y按实际购买数量结算 N按实际消费数量结算
       /// </summary>
       string teamway { get; set; }
       /// <summary>
       /// 0代表抽奖项目随机生成抽奖号码,1代表
       /// </summary>
       int drawType { get; set; }
       /// <summary>
       /// 项目上下架状态,此字段通过产品表进行关联,不可直接操作 1为上架 8为下架
       /// </summary>
       int status { get; set; }

       /// <summary>
       /// 销售人员ID.为销售后台项目统计用
       /// </summary>
       int sale_id { get; set; }

       /// <summary>
       ///  是否开启团购预告
       /// </summary>
       int isPredict { get; set; }

       /// <summary>
       /// 项目种类（0：团购1：商城）
       /// </summary>
       int teamcata { get; set; }

       /// <summary>
       /// 二级城市id
       /// </summary>
       int level_cityid { get; set; }
       /// <summary>
       /// 商城项目状态（1显示，0隐藏）
       /// </summary>
       int mallstatus { get; set; }
       /// <summary>
       /// 区域id
       /// </summary>
       int areaid { get; set; }
       /// <summary>
       /// 商圈id
       /// </summary>
       int circleid { get; set; }

       /// <summary>
       /// 是否支持7天退款和过期退款（Y:支持,N:不支持）
       /// </summary>
       string isrefund { get; set; }

       /// <summary>
       /// 项目开启货到付款（0 是未开启 1 是开启）
       /// </summary>
       string cashOnDelivery { get; set; }

       /// <summary>
       /// 分店id
       /// </summary>
       int branch_id { get; set; }

       /// <summary>
       /// 关联Catagory表
       /// </summary>
       string Name { get; set; }

       //关联user表|userreview表
       string Username { get; set; }
       decimal totalamount { get; set; }
       string comment { get; set; }
       DateTime create_time { get; set; }

       /////////////////////////////////////////////
       /// <summary>
       /// 返回当前项目是否允许购买
       /// </summary>
       bool CanBuy { get; }
       /// <summary>
       /// 返回折扣
       /// </summary>
       string Discount { get; }
       /// <summary>
       /// 返回价格整数部分
       /// </summary>
       string TeamPriceZhengShu { get; }
       /// <summary>
       /// 返回价格小数部分
       /// </summary>
       string TeamPriceXiaoShu { get; }
       /// <summary>
       /// 返回结束的剩余时间
       /// </summary>
       TimeSpan ShengYuTime { get; }
       /// <summary>
       /// 节省金额
       /// </summary>
       decimal TeamJieSheng { get; }
       /// <summary>
       /// 此项目商家
       /// </summary>
       IPartner Partner { get; }
       /// <summary>
       /// 返回当前有库存的规格名称
       /// </summary>
       List<string> PropertyName { get; }

       /// <summary>
       /// 根据规格名称返回库存数量
       /// </summary>
       /// <param name="PropertyNames">数组 每个单元如格式：颜色-红色</param>
       /// <returns></returns>
       int GetInventory(string[] PropertyNames);

       /// <summary>
       /// 运费模版
       /// </summary>
       IFareTemplate FareTemplate { get; }
       /// <summary>
       /// 项目状态
       /// </summary>
       TeamState Teamstate { get; }
       /// <summary>
       /// 返回catalogs
       /// </summary>
       ICatalogs TeamCatalogs { get; }
       /// <summary>
       /// 返回Category
       /// </summary>
       ICategory TeamCategory { get; }
       /// <summary>
       /// 项目所属的产品
       /// </summary>
       IProduct Products { get; }
       /// <summary>
       /// 返回Category
       /// </summary>
       ICategory TeamCategoryInfo { get; }

       ICategory TeamCategorys { get; }

    }

   public enum TeamState
   {
       /// <summary>
       /// 未开始
       /// </summary>
       None=1,
       /// <summary>
       /// 成功项目
       /// </summary>
       success=2,
       /// <summary>
       /// 失败项目
       /// </summary>
       failure=4,
       /// <summary>
       /// 正在进行
       /// </summary>
       Nowing=8,
       /// <summary>
       /// 未开始
       /// </summary>
       Weikaishi = 10,
       /// <summary>
       /// 已成功未过期还可以购买
       /// </summary>
       successbuy = 12,
       /// <summary>
       /// 已成功未过期不可以购买已卖光
       /// </summary>
       successnobuy = 14,
       /// <summary>
       /// 已成功已过期
       /// </summary>
       successtimeover = 18,
       /// <summary>
       /// 未成功已过期
       /// </summary>
       fail = 16,
       /// <summary>
       /// 下架
       /// </summary>
       xiajia=19,

      
   }
}
