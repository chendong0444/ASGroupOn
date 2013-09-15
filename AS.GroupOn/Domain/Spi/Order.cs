using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.Domain.Spi
{
    public class Order : Obj, IOrder
    {
        /// <summary>
        /// 订单ID
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 交易单号
        /// </summary>
        public virtual string Pay_id { get; set; }
        /// <summary>
        /// 付款方式(yeepay:易宝，alipay:支付宝,tenpay:财付通,chinabank:网银在线,credit:余额付款,cash:线下支付)
        /// </summary>
        public virtual string Service { get; set; }
        /// <summary>
        /// 会员ID
        /// </summary>
        public virtual int User_id { get; set; }
        /// <summary>
        /// 管理员ID
        /// </summary>
        public virtual int Admin_id { get; set; }
        /// <summary>
        /// 项目ID 如果项目ID为0则说明走购物车了应到orderdetail表查询项目
        /// </summary>
        public virtual int Team_id { get; set; }
        /// <summary>
        /// 城市ID 如果是快递项目则应记录用户下单所在的城市，如果是优惠券项目则应记录项目所在城市
        /// </summary>
        public virtual int City_id { get; set; }
        /// <summary>
        /// 代金券号(如果使用了代金券，此字段存储代金券编号) 
        /// </summary>
        public virtual string Card_id { get; set; }
        /// <summary>
        /// 支付状态(已支付:pay,未支付:unpay,已退款refund,用户已取消:cancel 未支付的积分订单:scoreunpay,已支付的积分订单:scorepay,已退单的积分订单：scorrefund)
        /// </summary>
        public virtual string State { get; set; }
        /// <summary>
        /// 数量 如果走购物车此处记录所有项目的总数量。
        /// </summary>
        public virtual int Quantity { get; set; }
        /// <summary>
        /// 真实姓名
        /// </summary>
        public virtual string Realname { get; set; }
        /// <summary>
        /// 移动电话
        /// </summary>
        public virtual string Mobile { get; set; }
        /// <summary>
        /// 邮编
        /// </summary>
        public virtual string Zipcode { get; set; }
        /// <summary>
        /// 地址
        /// </summary>
        public virtual string Address { get; set; }
        /// <summary>
        /// 递送方式（快递或券）Y快递 N券 D抽奖 P站外券 
        /// </summary>
        public virtual string Express { get; set; }
        /// <summary>
        /// 是否已打印
        /// </summary>
        public virtual string Express_xx { get; set; }
        /// <summary>
        /// 快递公司ID
        /// </summary>
        public virtual int Express_id { get; set; }
        /// <summary>
        /// 快递单号
        /// </summary>
        public virtual string Express_no { get; set; }
        /// <summary>
        /// 商品单价
        /// </summary>
        public virtual decimal Price { get; set; }
        /// <summary>
        /// 在线支付费用
        /// </summary>
        public virtual decimal Money { get; set; }
        /// <summary>
        /// 总款(含运费)
        /// </summary>
        public virtual decimal Origin { get; set; }
        /// <summary>
        /// 余额付款
        /// </summary>
        public virtual decimal Credit { get; set; }
        /// <summary>
        /// 代金券费
        /// </summary>
        public virtual decimal Card { get; set; }
        /// <summary>
        /// 快递费
        /// </summary>
        public virtual decimal Fare { get; set; }
        /// <summary>
        /// 订单附言
        /// </summary>
        public virtual string Remark { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        public virtual DateTime Create_time { get; set; }
        /// <summary>
        /// 支付时间
        /// </summary>
        public virtual DateTime? Pay_time { get; set; }
        /// <summary>
        /// 记录下订单时的来源地址
        /// </summary>
        public virtual string IP_Address { get; set; }
        /// <summary>
        /// 产品规格
        /// </summary>
        public virtual string result { get; set; }
        /// <summary>
        /// 订单时的来源域名
        /// </summary>
        public virtual string fromdomain { get; set; }
        /// <summary>
        /// 退款方式 1代表退款到余额 2代表退款到其他地方
        /// </summary>
        public virtual int refundtype { get; set; }
        /// <summary>
        /// 管理员备注
        /// </summary>
        public virtual string adminremark { get; set; }
        /// <summary>
        /// 订单返还的总积分数,如果是非积分项目则为返还值，如果是积分项目则为0
        /// </summary>
        public virtual int orderscore { get; set; }


        public string all_id { get; set; }


        /// <summary>
        /// 折扣率????
        /// </summary>
        public virtual double discount { get; set; }
        private int _totalscore = 0;
        /// <summary>
        /// 订单花费总积分
        /// </summary>
        public virtual int totalscore
        {
            get
            {
                return _totalscore;
            }
            set
            {
                _totalscore = value;
            }
        }
        /// <summary>
        /// 抽奖项目的短信认证码 4位
        /// </summary>
        public virtual string checkcode { get; set; }
        private decimal _disamount = 0;
        /// <summary>
        /// 参加活动后的应减去的优惠金额
        /// </summary>
        public virtual decimal disamount
        {
            get
            {
                return _disamount;
            }
            set
            {
                _disamount = value;
            }
        }
        /// <summary>
        /// 参加活动的优惠信息
        /// </summary>
        public virtual string disinfo { get; set; }
        private int _Parent_orderid = 0;
        /// <summary>
        /// 如果此订单是被拆分后的子订单，则保存父订单ID,否则为0
        /// </summary>
        public virtual int Parent_orderid
        {
            get
            {
                return _Parent_orderid;
            }
            set
            {
                _Parent_orderid = value;
            }
        }
        private int _Partner_id = 0;
        /// <summary>
        /// 如果启用订单拆分，此处保存拆分后的商户ID
        /// </summary>
        public virtual int Partner_id
        {
            get
            {
                return _Partner_id;
            }
            set
            {
                _Partner_id = value;
            }
        }
        private decimal _cashondelivery = 0;
        /// <summary>
        /// 货到付款金额
        /// </summary>
        public virtual decimal cashondelivery
        {
            get
            {
                return _cashondelivery;
            }
            set
            {
                _cashondelivery = value;
            }
        }
        private decimal _Returnmoney = 0;
        /// <summary>
        /// 促销活动返给用户的金额
        /// </summary>
        public virtual decimal Returnmoney
        {
            get
            {
                return _Returnmoney;
            }
            set
            {
                _Returnmoney = value;
            }
        }
        /// <summary>
        /// 订单退款的状态
        /// </summary>
        public virtual int rviewstate { get; set; }
        /// <summary>
        /// 管理员审核备注
        /// </summary>
        public virtual string rviewremarke { get; set; }
        /// <summary>
        /// 用户申请退款备注
        /// </summary>
        public virtual string userremarke { get; set; }
        /// <summary>
        /// 货到付款，记录同属于一订单的订单编号
        /// </summary>
        public int CashParent_orderid { get; set; }
        /// <summary>
        /// 退款时间
        /// </summary>
        public DateTime? refundTime { get; set; }
        private decimal _Partnerfare = 0;
        /// <summary>
        /// 此订单应给商户结算的运费
        /// </summary>
        public virtual decimal Partnerfare
        {
            get
            {
                return _Partnerfare;
            }
            set
            {
                _Partnerfare = value;
            }
        }
        /////////////////////////////////////////////////////////////////////////////
       
        /// <summary>
        /// 订单中参加活动的优惠信息
        /// </summary>
        public virtual string Disinfos
        {
            get
            {
                string str = String.Empty;
                if (disinfo != null)
                {
                    foreach (string dis in disinfo.Split('|'))
                    {
                        IPromotion_rules rule = null;
                        using (IDataSession session = App.Store.OpenSession(false))
                        {
                            rule = session.Promotion_rules.GetByID(AS.Common.Utils.Helper.GetInt(dis, 0));
                        }
                        if (rule != null) str = str + rule.rule_description + "</br>";
                    }
                }
                return str;
            }
        }
        private IList<ITeam> _teams = null;
        /// <summary>
        /// 订单中的项目列表
        /// </summary>
        public virtual IList<ITeam> Teams
        {
            get
            {
                if (_teams == null)
                {
                    TeamFilter tf = new TeamFilter();
                    tf.OrderID = this.Id;
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _teams = session.Teams.GetList(tf);
                    }
                }
                return _teams;
            }
        }

        private IList<IOrderDetail> _orderdetail = null;
        /// <summary>
        /// 订单详情
        /// </summary>
        public virtual IList<IOrderDetail> OrderDetail
        {
            get
            {
                if (_orderdetail == null)
                {
                    if (Team_id == 0)
                    {
                        OrderDetailFilter odf = new OrderDetailFilter();
                        odf.Order_ID = Id;
                        odf.AddSortOrder(OrderDetailFilter.ID_ASC);
                        using (IDataSession session = App.Store.OpenSession(false))
                        {
                            _orderdetail = session.OrderDetail.GetList(odf);
                        }
                    }
                    else
                    {
                        AS.GroupOn.Domain.Spi.OrderDetail orderdetail = new OrderDetail();
                        orderdetail.id = 0;
                        orderdetail.Num = Quantity;
                        orderdetail.Order_id = Id;
                        orderdetail.result = this.result;
                        orderdetail.Teamid = this.Team_id;
                        orderdetail.Teamprice = this.Price;
                        orderdetail.totalscore = this.totalscore / Quantity;
                        IOrderDetail iod = orderdetail;
                        List<IOrderDetail> os = new List<IOrderDetail>();
                        os.Add(iod);
                        _orderdetail = os;
                    }
                }
                return _orderdetail;

            }
        }


        /// <summary>
        /// 返回订单是否还允许付款。true 允许 false 不允许
        /// </summary>
        public virtual bool CanPay
        {
            get
            {
                if (State != "unpay")
                    return false;
                for (int i = 0; i < OrderDetail.Count; i++)
                {
                    IOrderDetail orderdetail = OrderDetail[i];
                    if (!orderdetail.Team.CanBuy)
                        return false;
                }
                return true;
            }
        }

        private ITeam _team = null;
        /// <summary>
        /// 不走购物车得到的项目
        /// </summary>
        public virtual ITeam Team
        {
            get
            {
                if (_team == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _team = session.Teams.GetByID(Team_id);
                    }
                }
                return _team;
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
                if (_user==null)
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
        /// 得到快递公司名称
        /// </summary>
        private ICategory _category = null;

        public ICategory Category
        {
            get {
                if (_category == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _category = session.Category.GetByID(Express_id);
                    }
                }
                return _category;
                   
            }
        } 



        private IPartner _partner = null;
        /// <summary>
        /// 订单下面所属的商户
        /// </summary>
        public virtual IPartner Partner
        {
            get
            {
                if (_partner == null)
                {
                    using (IDataSession session=App.Store.OpenSession(false))
                    {
                        _partner = session.Partners.GetByID(Partner_id);   
                    }
                }
                return _partner;
            }
        }

        private IUserReview _userreview = null;
        /// <summary>
        /// 订单下面所属的商户
        /// </summary>
        public virtual IUserReview UserReview
        {
            get
            {
                if (_userreview == null)
                {
                    UserReviewFilter urfilter = new UserReviewFilter();
                    urfilter.team_id = this.Team_id;
                    urfilter.user_id = this.User_id;
                    urfilter.wheresql = "(Userreview.Type is null or Userreview.Type = 'team')";
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _userreview = session.UserReview.Get(urfilter);
                    }
                }
                return _userreview;
            }
        }
        /// <summary>
        /// 临时订单号 不需要存入数据库
        /// </summary>
        public virtual string TempID { get; set; }

        public virtual int printid { get; set; }
        public virtual int orderid { get; set; }
        public virtual int teamid { get; set; }


        /*--关联user表字段--*/
        public virtual string Username { get; set; }
        public virtual string Email { get; set; }

        #region 显示订单中所选项目的格式
        /// <summary>
        /// 
        /// </summary>
        /// <param name="bulletin"></param>
        /// <param name="showhtml">是否显示html格式 0显示 1不显示</param>
        /// <returns></returns>
        public static string Getbulletin(string bulletin, int showhtml = 0)
        {
            string str = "";
            if (bulletin != "")
            {
                str = "<font style='color: rgb(153, 153, 153);'>";
                string strs = "<br><b style='color: red;'>[规格]</b>";
                if (showhtml == 1)
                {
                    str = String.Empty;
                    strs = String.Empty;
                }
                string[] strArray = bulletin.Split('|');

                for (int i = 0; i < strArray.Length; i++)
                {
                    if (bulletin != "" && bulletin != null)
                    {
                        str += strs + strArray[i].Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "") + "";
                    }

                }
                if (showhtml == 0)
                    str = str + "</font><br><br>";
                //str = str.Substring(0, str.LastIndexOf("<br>"));
            }

            return str;
        }

        public static string Getbulletin(string bulletin)
        {
            return Getbulletin(bulletin, 0);
        }
        #endregion



        public virtual int vtid { get; set; }
        public virtual int urid { get; set; }
        public virtual DateTime ur_create_time { get; set; }

        public virtual int tid { get; set; }
        public virtual string ttitle { get; set; }
        public virtual int tpartnerid { get; set; }
        public virtual string ptitle { get; set; }
        public virtual int urevid { get; set; }
        public virtual int uPartner_id { get; set; }
        public virtual DateTime urecreate_time { get; set; }
        public virtual string urtype { get; set; }
    }
}
