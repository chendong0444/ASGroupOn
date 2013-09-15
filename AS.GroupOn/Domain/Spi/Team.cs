using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using System.Data;
using AS.Common.Utils;
using System.Text.RegularExpressions;
namespace AS.GroupOn.Domain.Spi
{
    public class Team : Obj,ITeam
    {
        /// <summary>
        /// 项目ID
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 管理员ID
        /// </summary>
        public virtual int User_id { get; set; }
        /// <summary>
        /// 项目名称
        /// </summary>
        public virtual string Title { get; set; }
        /// <summary>
        /// 项目简介
        /// </summary>
        public virtual string Summary { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        public virtual int City_id { get; set; }
        /// <summary>
        /// API分类ID
        /// </summary>
        public virtual int Group_id { get; set; }
        /// <summary>
        /// 商户ID
        /// </summary>
        public virtual int Partner_id { get; set; }

        public virtual string System { get; set; }
        /// <summary>
        /// 团购价
        /// </summary>
        public virtual decimal Team_price { get; set; }
        /// <summary>
        /// 市场价
        /// </summary>
        public virtual decimal Market_price { get; set; }
        /// <summary>
        /// 产品名称
        /// </summary>
        public virtual string Product { get; set; }
        /// <summary>
        /// 每人限购数量
        /// </summary>
        public virtual int Per_number { get; set; }
        /// <summary>
        /// 最小成团人数
        /// </summary>
        public virtual int Min_number { get; set; }
        /// <summary>
        /// 最大购买人数
        /// </summary>
        public virtual int Max_number { get; set; }
        /// <summary>
        /// 当前购买人数
        /// </summary>
        public virtual int Now_number { get; set; }
        /// <summary>
        /// 是否允许手动更新人数(0不允许，1允许)为1时 后台修改了当前购买人数 保存时 进行更新
        /// </summary>
        public virtual int Manualupdate { get; set; }
        /// <summary>
        /// 商品图片
        /// </summary>
        public virtual string Image { get; set; }
        /// <summary>
        /// 商品图片1
        /// </summary>
        public virtual string Image1 { get; set; }
        /// <summary>
        /// 商品图片2
        /// </summary>
        public virtual string Image2 { get; set; }
        /// <summary>
        /// 手机商品图片
        /// </summary>
        public virtual string PhoneImg { get; set; }
        /// <summary>
        /// 视频地址
        /// </summary>
        public virtual string Flv { get; set; }
        /// <summary>
        /// 手机
        /// </summary>
        public virtual string Mobile { get; set; }

        /// <summary>
        /// 优惠券(消费返利金额)
        /// </summary>
        public virtual int Credit { get; set; }
        /// <summary>
        /// 代金券使用(可使用代金券最大面额)
        /// </summary>
        public virtual int Card { get; set; }
        /// <summary>
        /// 快递费
        /// </summary>
        public virtual int Fare { get; set; }
        /// <summary>
        /// 免单数量
        /// </summary>
        public virtual int Farefree { get; set; }
        /// <summary>
        /// 邀请返利(邀请好友参与本单商品购买时的返利金额)
        /// </summary>
        public virtual int Bonus { get; set; }
        /// <summary>
        /// 地址
        /// </summary>
        public virtual string Address { get; set; }
        /// <summary>
        /// 本单详情
        /// </summary>
        public virtual string Detail { get; set; }
        /// <summary>
        /// 团购网站推广辞
        /// </summary>
        public virtual string Systemreview { get; set; }
        /// <summary>
        /// 他们说
        /// </summary>
        public virtual string Userreview { get; set; }
        /// <summary>
        /// 特别提示
        /// </summary>
        public virtual string Notice { get; set; }
        /// <summary>
        /// 配送说明
        /// </summary>
        public virtual string Express { get; set; }
        /// <summary>
        /// 快递方式优惠券:coupon,快递:express,站外券:pcoupon抽奖:draw pickup default ‘coupon’ not null
        /// </summary>
        public virtual string Delivery { get; set; }
        /// <summary>
        /// 项目状态
        /// </summary>
        public virtual string State { get; set; }
        /// <summary>
        /// 购买人数或产品购买数量成团(为N以产品购买数量成团)为Y以购买人数成团
        /// </summary>
        public virtual string Conduser { get; set; }
        /// <summary>
        /// 只允许购买一次
        /// </summary>
        public virtual string Buyonce { get; set; }
        /// <summary>
        /// 项目类型
        /// </summary>
        public virtual string Team_type { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        public virtual int Sort_order { get; set; }

        /// <summary>
        /// 优惠卷开始时间
        /// </summary>
        public virtual DateTime? start_time { get; set; }
        /// <summary>
        /// 优惠券结束时间
        /// </summary>
        public virtual DateTime Expire_time { get; set; }
        /// <summary>
        /// 项目开始时间
        /// </summary>
        public virtual DateTime Begin_time { get; set; }
        /// <summary>
        /// 项目结束时间
        /// </summary>
        public virtual DateTime End_time { get; set; }
        /// <summary>
        /// 达到成功团购人数的时间
        /// </summary>
        public virtual DateTime? Reach_time { get; set; }
        /// <summary>
        /// 项目卖光时间
        /// </summary>
        public virtual DateTime? Close_time { get; set; }
        /// <summary>
        /// 产品规格属性
        /// </summary>
        public virtual string bulletin { get; set; }
        /// <summary>
        /// 每次加油数量
        /// </summary>
        public virtual int update_value { get; set; }
        /// <summary>
        /// 每次加油间隔时间
        /// </summary>
        public virtual int time_state { get; set; }
        /// <summary>
        /// 倒计时剩余时间
        /// </summary>
        public virtual int time_interval { get; set; }
        /// <summary>
        /// 加油人数上限
        /// </summary>
        public virtual int autolimit { get; set; }
        /// <summary>
        /// 运费计算方式0代表在项目中直接输入了快递费,>0代表在项目中选择快递模版ID
        /// </summary>
        public virtual int freighttype { get; set; }

        /// <summary>
        /// 库存总数量
        /// </summary>
        public virtual int inventory { get; set; }
        /// <summary>
        /// 库存报警数量
        /// </summary>
        public virtual int invent_war { get; set; }

        private string _invent_result = String.Empty;
        /// <summary>
        /// 库存规格数量 字符串拼接 如果有规格,总数量=规格数量之和
        /// </summary>
        public virtual string invent_result
        {
            get
            {
                return _invent_result;
            }
            set
            {
                _invent_result = value;
                inventoryTable = AS.Common.Utils.WebUtils.GetSpecifications(_invent_result);
            }
        }
        /// <summary>
        /// 项目消耗积分数字段
        /// </summary>
        public virtual int teamscore { get; set; }
        /// <summary>
        /// 购买一个项目所返积分
        /// </summary>
        public virtual int score { get; set; }
        /// <summary>
        /// SEO标题
        /// </summary>
        public virtual string seotitle { get; set; }
        /// <summary>
        /// SEO关键字
        /// </summary>
        public virtual string seokeyword { get; set; }
        /// <summary>
        /// SEO描述
        /// </summary>
        public virtual string seodescription { get; set; }
        /// <summary>
        /// 品牌ID
        /// </summary>
        public virtual int brand_id { get; set; }
        /// <summary>
        /// 是否开启库存功能 0关闭 1开启
        /// </summary>
        public virtual int open_invent { get; set; }
        /// <summary>
        /// 是否开启库存报警功能 0关闭 1开启
        /// </summary>
        public virtual int open_war { get; set; }
        /// <summary>
        /// 库存报警电话
        /// </summary>
        public virtual string warmobile { get; set; }

        /// <summary>
        /// 最小购买数量
        /// </summary>     
        public virtual int Per_minnumber { get; set; }

        /// <summary>
        /// 商户模式(0老模式，1新模式)
        /// </summary>
        public virtual int shanhu { get; set; }
        /// <summary>
        /// 抽奖活动是否开启短信验证,yes开启 no不开启
        /// </summary>
        public virtual string codeswitch { get; set; }
        /// <summary>
        /// 买家评论返利金额
        /// </summary>
        public virtual decimal commentscore { get; set; }
        /// <summary>
        /// 项目输出到其他城市ID 用,分开
        /// </summary>
        public virtual string othercity { get; set; }
        /// <summary>
        /// 网站分类ID
        /// </summary>
        public virtual int cataid { get; set; }
        /// <summary>
        /// 首页推荐商品 0否 1是
        /// </summary>
        public virtual int teamhost { get; set; }
        /// <summary>
        /// 首页新品 0否 1是
        /// </summary>
        public virtual int teamnew { get; set; }
        /// <summary>
        /// 关键字
        /// </summary>
        public virtual string catakey { get; set; }
        /// <summary>
        /// 是否api输出
        /// </summary>
        public virtual int apiopen { get; set; }

        /// <summary>
        /// 产品ID 为0时表示不关联产品库
        /// </summary>
        public virtual int productid { get; set; }

        /// <summary>
        /// 成本价
        /// </summary>
        public virtual decimal cost_price { get; set; }
        /// <summary>
        ///优惠券结算方式 Y按实际购买数量结算 N按实际消费数量结算
        /// </summary>
        public virtual string teamway { get; set; }
        /// <summary>
        /// 0代表抽奖项目随机生成抽奖号码,1代表
        /// </summary>
        public virtual int drawType { get; set; }
        /// <summary>
        /// 项目上下架状态,此字段通过产品表进行关联,不可直接操作 1为上架 8为下架
        /// </summary>
        public virtual int status { get; set; }

        /// <summary>
        /// 销售人员ID.为销售后台项目统计用
        /// </summary>
        public virtual int sale_id { get; set; }

        /// <summary>
        ///  是否开启团购预告
        /// </summary>
        public virtual int isPredict { get; set; }

        /// <summary>
        /// 项目种类（0：团购1：商城）
        /// </summary>
        public virtual int teamcata { get; set; }

        /// <summary>
        /// 二级城市id
        /// </summary>
        public virtual int level_cityid { get; set; }
        /// <summary>
        /// 商城项目状态（1显示，0隐藏）
        /// </summary>
        public virtual int mallstatus { get; set; }
        /// <summary>
        /// 区域id
        /// </summary>
        public virtual int areaid { get; set; }
        /// <summary>
        /// 商圈id
        /// </summary>
        public virtual int circleid { get; set; }

        /// <summary>
        /// 是否支持7天退款和过期退款（Y:支持,N:不支持）
        /// </summary>
        public virtual string isrefund { get; set; }

        /// <summary>
        /// 项目开启货到付款（0 是未开启 1 是开启）
        /// </summary>
        public virtual string cashOnDelivery { get; set; }

        /// <summary>
        /// 分店id
        /// </summary>
        public virtual int branch_id { get; set; }

        /// <summary>
        /// 关联Catagory表
        /// </summary>
        public virtual string Name { get; set; }

        //关联user表|userreview表
        public virtual string Username { get; set; }
        public virtual decimal totalamount { get; set; }
        public virtual string comment { get; set; }
        public virtual DateTime create_time { get; set; }
        /////////////////////////////////////////////
        /// <summary>
        /// 返回当前项目是否允许购买
        /// </summary>
        public virtual bool CanBuy
        {
            get
            {
                if (this.Begin_time <= DateTime.Now && this.End_time >= DateTime.Now && this.status == 1 && (this.Max_number == 0 || (this.Max_number < this.Now_number)))
                {
                    return true;
                }
                return false;
            }
        }
        /// <summary>
        /// 返回折扣
        /// </summary>
        public virtual string Discount
        {
            get
            {
                if (Market_price != 0)
                {
                    return (Team_price / Market_price * 10).ToString("0.00");
                }
                else
                {
                    return (Team_price * 10).ToString("0.00");
                }
            }
        }

        /// <summary>
        /// 返回价格整数部分
        /// </summary>
        public virtual string TeamPriceZhengShu
        {
            get
            {
                string val = Team_price.ToString("0.00");
                int pos = val.IndexOf(".");
                return val.Substring(0, pos);
            }
        }
        /// <summary>
        /// 返回价格小数部分
        /// </summary>
        public virtual string TeamPriceXiaoShu
        {
            get
            {

                string val = Team_price.ToString("0.00");
                int pos = val.IndexOf(".");
                return val.Substring(pos);
            }
        }

        /// <summary>
        /// 找不到，返回一个默认的实例化项目,防止发生null异常
        /// </summary>
        /// <returns></returns>
        public static ITeam GetDefault()
        {
            Team t = new Team();
            t.Title = "??????????????";
            t.Id = 0;
            t.Image = "";
            return t;
        }

        private TimeSpan _shengytime = TimeSpan.MinValue;
        /// <summary>
        /// 返回结束的剩余时间
        /// </summary>
        public virtual TimeSpan ShengYuTime
        {
            get
            {
                if (_shengytime == TimeSpan.MinValue)
                {
                    _shengytime = End_time - DateTime.Now;
                }
                return _shengytime;
            }
        }

        /// <summary>
        /// 节省金额
        /// </summary>
        public virtual decimal TeamJieSheng
        {
            get
            {
                return Market_price - Team_price;
            }
        }

        IPartner _partner = null;
        /// <summary>
        /// 此项目商家
        /// </summary>
        public virtual IPartner Partner
        {
            get
            {
                if (_partner == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _partner = session.Partners.GetByID(this.Partner_id);
                    }
                    if (_partner == null)
                        _partner = AS.GroupOn.Domain.Spi.Partner.GetDefault();
                }
                return _partner;
            }
        }


        /// <summary>
        /// 返回当前有库存的规格名称
        /// </summary>
        public virtual List<string> PropertyName
        {
            get
            {
                List<string> values = new List<string>();
                for (int i = 0; i < inventoryTable.Columns.Count; i++)
                {
                    values.Add(inventoryTable.Columns[i].ColumnName);
                }
                return values;
            }
        }

        private DataTable inventoryTable = new DataTable();//规格表
        /// <summary>
        /// 根据规格名称返回库存数量
        /// </summary>
        /// <param name="PropertyNames">数组 每个单元如格式：颜色-红色</param>
        /// <returns></returns>
        public virtual int GetInventory(string[] PropertyNames)
        {
            DataTable resultTable = inventoryTable;
            int num = 0;
            string wheresql = String.Empty;
            for (int i = 0; i < PropertyNames.Length; i++)
            {
                wheresql = wheresql + " and " + Helper.GetString(PropertyNames[i], String.Empty).Replace("-", "='") + "'";
            }
            if (wheresql.Length > 0)
            {
                wheresql = wheresql.Substring(4);
                inventoryTable.DefaultView.RowFilter = wheresql;
                resultTable = inventoryTable.DefaultView.ToTable();
            }
            for (int i = 0; i < resultTable.Rows.Count; i++)
            {
                DataRow row = resultTable.Rows[i];
                num = num + Helper.GetInt(row["数量"], 0);
            }
            return num;
        }

        private IFareTemplate _faretemplate = null;
        /// <summary>
        /// 运费模版
        /// </summary>
        public virtual IFareTemplate FareTemplate
        {
            get
            {
                if (freighttype > 0 && _faretemplate == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _faretemplate = session.FareTemplate.GetByID(freighttype);
                    }
                }
                return _faretemplate;
            }
        }

        /// <summary>
        /// 项目状态
        /// </summary>
        public virtual TeamState Teamstate
        {
            get
            {
                if (Begin_time > DateTime.Now)
                    return TeamState.None;
                if (Begin_time < DateTime.Now && DateTime.Now <= End_time && status == 1)
                    return TeamState.Nowing;
                return TeamState.success;
            }
        }

        /// <summary>
        /// 返回catalogs
        /// </summary>
        private ICatalogs _catalogs = null;
        public virtual ICatalogs TeamCatalogs
        {
            get
            {
                if (_catalogs == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _catalogs = session.Catalogs.GetByID(this.cataid);
                    }                    
                }
                return _catalogs;
            }
        }
        /// <summary>
        /// 返回category
        /// </summary>
        private ICategory _catagory = null;
        public virtual ICategory TeamCategory
        {
            get
            {
                if (_catagory == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _catagory = session.Category.GetByID(this.Group_id);
                    }
                }
                return _catagory;
            }
        }
        private IProduct _products = null;
        /// <summary>
        /// 项目所属的产品
        /// </summary>
        public virtual IProduct Products
        {
            get
            {
                if (_products == null)
                {
                    using (IDataSession session=App.Store.OpenSession(false))
                    {
                        _products = session.Product.GetByID(this.productid);
                    }
                }
                return _products;
            }
        }

        /// <summary>
        /// 返回category
        /// </summary>
        private ICategory _catagoryinfo = null;
        public virtual ICategory TeamCategoryInfo
        {
            get
            {
                if (_catagoryinfo == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _catagoryinfo = session.Category.GetByID(this.City_id);
                    }
                }
                return _catagoryinfo;
            }
        }

        /// <summary>
        /// 返回category
        /// </summary>
        private ICategory _categorybid = null;
        public virtual ICategory TeamCategorys
        {
            get
            {
                if (_categorybid == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _categorybid = session.Category.GetByID(this.brand_id);
                    }
                }
                return _categorybid;
            }
        }
       
    }
}
