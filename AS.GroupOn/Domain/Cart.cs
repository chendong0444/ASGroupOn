using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using System.Data;
using AS.Common.Utils;
namespace AS.GroupOn.Domain
{
    public class CartTeam
    {

        private int _teamid = 0;
        public int TeamID
        {
            get
            {
                return _teamid;
            }
            set
            {
                _teamid = value;
            }
        }

        private ITeam _team = null;
        public ITeam Team
        {
            get
            {
                if (_team == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _team = session.Teams.GetByID(TeamID);
                    }
                }
                return _team;
            }
        }

        private int _teamnum = 1;
        /// <summary>
        /// 项目数量
        /// </summary>
        public int TeamNum
        {
            get
            {
                return _teamnum;
            }
            set
            {
                _teamnum =value;
            }
        }

        private string _bllin = String.Empty;
        /// <summary>
        /// 项目规格
        /// </summary>
        public string Bllin
        {
            get
            {
                return _bllin;
            }
            set
            {
                _bllin = value;
            }
        }
        /// <summary>
        /// 项目总金额
        /// </summary>
        public decimal TeamTotalPrice
        {
            get
            {
                return Team.Team_price * TeamNum;
            }
        }
    }

    public class Cart
    {
        private string _mobile = String.Empty;
        /// <summary>
        /// 手机号
        /// </summary>
        public string Mobile
        {
            get
            {
                return _mobile;
            }
            set
            {
                _mobile = value;
            }
        }

        private string _paytype = String.Empty;
        /// <summary>
        /// 付款方式
        /// </summary>
        public string PayType
        {
            get
            {
                return _paytype;
            }
            set
            {
                _paytype = value;
            }
        }

        private string _remark = String.Empty;
        /// <summary>
        /// 备注
        /// </summary>
        public string Remark
        {
            get
            {
                return _remark;
            }
            set
            {
                _remark = value;
            }
        }

        private string _realname = String.Empty;
        /// <summary>
        /// 收货人
        /// </summary>
        public string RealName
        {
            get
            {
                return _realname;
            }
            set
            {
                _realname = value;
            }
        }

        private string _address = String.Empty;
        /// <summary>
        /// 收货地址
        /// </summary>
        public string Address
        {
            get
            {
                return _address;
            }
            set
            {
                _address = value;
            }
        }

        private string _region = String.Empty;
        /// <summary>
        /// 省-市-区
        /// </summary>
        public string Region
        {
            get
            {
                return _region;
            }
            set
            {
                _region = value;
            }
        }
        


        private string _zip = String.Empty;
        /// <summary>
        /// 邮编
        /// </summary>
        public string Zip
        {
            set
            {
                _zip = value;
            }
            get
            {
                return _zip;
            }
        }

        private string _cardid = String.Empty;
        /// <summary>
        /// 代金券号
        /// </summary>
        public string CardID
        {
            get
            {
                return _cardid;
            }
            set
            {
                _cardid = value;
            }
        }

        private ICard _card = null;
        /// <summary>
        /// 代金券
        /// </summary>
        public ICard Card
        {
            get
            {
                if (_card == null&&CardID.Length>0)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _card = session.Card.GetByID(CardID);
                    }
                }
                return _card;
            }
        }

        private decimal _price = 0;//可待金额
        /// <summary>
        /// 根据订单金额返回代金券的可待金额
        /// </summary>
        /// <returns></returns>
        public decimal GetCardPrice
        {
            get
            {
                if (_price == 0)
                {
                    if (!String.IsNullOrEmpty(CardID) && Card != null)
                    {
                        if (Card.Credit <= this.TotalPrice)
                        {
                            _price = Card.Credit;
                          
                        }
                    }
                }
                return _price;
            }
        }



        private List<CartTeam> _teamlist = new List<CartTeam>();
        /// <summary>
        /// 购物车项目
        /// </summary>
        public List<CartTeam> TeamList
        {
            get
            {
                return _teamlist;
            }
            set
            {
                _teamlist = value;
            }
        }

        private decimal _totalprice = -1;
        /// <summary>
        /// 购物车总金额
        /// </summary>
        public decimal TotalPrice
        {
            get
            {
                if (_totalprice == -1)
                {
                    _totalprice = 0;
                    for (int i = 0; i < TeamList.Count; i++)
                    {
                        _totalprice += TeamList[i].TeamTotalPrice;
                    }
                }
                return _totalprice;
            }
        }

        private decimal _payprice = -1;
        /// <summary>
        /// 还需在线支付的金额
        /// </summary>
        public  decimal NeedPayPrice
        {
            get
            {
                //在线支付金额=订单金额+快递费-代金券金额
                if (_payprice == -1)
                {
                   _payprice= TotalPrice;
                   if (!String.IsNullOrEmpty(this.Region))
                   {
                       _payprice = _payprice + Fare(this.Region.Split('-')[0]);
                   }
                   else
                   {
                       _payprice = _payprice + Fare("");
                   }
                   _payprice = TotalPrice - GetCardPrice;
                   //如果在线支付金额小于0，则在线金额为0
                    if (_payprice < 0)
                   {
                       _payprice = 0;
                   }

                }
                return _payprice;
            }
        }




        private decimal _fare = -1;
        /// <summary>
        /// 运费
        /// </summary>
        public decimal Fare(string cityname)
        {
            if (_fare == -1)
            {
                _fare = 0;
                List<TeamFare> fares=new List<TeamFare>();
                for (int i = 0; i < TeamList.Count; i++)
                {
                    CartTeam ct = TeamList[i];
                    TeamFare teamfare=new TeamFare();
                    teamfare.BuyNum = ct.TeamNum;
                    teamfare.FareFree = ct.Team.Farefree;
                    teamfare.PartnerID = ct.Team.Partner_id;
                    if (ct.Team.freighttype == 0)
                    {
                        teamfare.OneFare = ct.Team.Fare;
                        teamfare.TwoFare = 0;
                    }
                    else
                    {
                        if (ct.Team.FareTemplate != null)
                        {
                            Dictionary<string, object> obj = JsonUtils.JsonToObject(ct.Team.FareTemplate.value);
                            List<object> objarr = (List<object>)obj["fare"];
                            for (int j = 0; j < objarr.Count; j++)
                            {
                                Dictionary<string, object> o = (Dictionary<string, object>)objarr[j];
                                string tempcityname = o["cityname"].ToString();
                                if (tempcityname == "默认城市")
                                {
                                    teamfare.OneFare = Helper.GetDecimal(o["one"], 0);
                                    teamfare.TwoFare = Helper.GetDecimal(o["two"], 0);
                                }
                                else if (cityname.Length > 0 && tempcityname.IndexOf(cityname) >= 0) //找到了对应的城市
                                {
                                    teamfare.OneFare = Helper.GetDecimal(o["one"], 0);
                                    teamfare.TwoFare = Helper.GetDecimal(o["two"], 0);
                                    break;
                                }
                            }
                        }
                        else
                        {
                            teamfare.OneFare = 0;
                            teamfare.TwoFare = 0;
                        }
                    }
                    fares.Add(teamfare);
                }
                if (fares.Count > 0)
                {
                    SortedList<int, ExpressFare> expressFares = new SortedList<int, ExpressFare>();//运费
                    for (int i = 0; i < fares.Count; i++)
                    {
                        TeamFare teamfare=fares[i];
                        if (CacheUtils.Config["sameseller_spanprojectems"] == "1")//开启了相同商家的项目才跨项目包邮
                        {
                            if (expressFares.IndexOfKey(teamfare.PartnerID) >= 0)
                            {
                                ExpressFare fare = expressFares[teamfare.PartnerID];
                                if (teamfare.OneFare > fare.OneFare)
                                {
                                    fare.Fare = fare.Fare - fare.OneFare + fare.TwoFare + teamfare.OneFare;
                                    fare.OneFare = teamfare.OneFare;
                                    fare.TwoFare = teamfare.TwoFare;
                                }
                                if (teamfare.FareFree > fare.MaxFareFree) fare.MaxFareFree = teamfare.FareFree;
                                fare.Max = fare.Max + teamfare.FareFree;
                                expressFares[teamfare.PartnerID] = fare;
                            }
                            else
                            {
                                ExpressFare fare = new ExpressFare();
                                fare.Fare = teamfare.OneFare;
                                fare.Max = teamfare.BuyNum;
                                fare.MaxFareFree = teamfare.FareFree;
                                fare.OneFare = teamfare.OneFare;
                                fare.PartnerID = teamfare.PartnerID;
                                fare.TwoFare = teamfare.TwoFare;
                                expressFares.Add(fare.PartnerID, fare);
                            }
                        }
                        else
                        {
                            if (expressFares.Count == 0)
                            {
                                ExpressFare fare = new ExpressFare();
                                fare.Fare = teamfare.OneFare;
                                fare.Max = teamfare.BuyNum;
                                fare.MaxFareFree = teamfare.FareFree;
                                fare.OneFare = teamfare.OneFare;
                                fare.PartnerID = teamfare.PartnerID;
                                fare.TwoFare = teamfare.TwoFare;
                                expressFares.Add(0, fare);
                            }
                            else
                            {
                                ExpressFare fare = expressFares[0];
                                if (teamfare.OneFare > fare.OneFare)
                                {
                                    fare.Fare = fare.Fare - fare.OneFare + fare.TwoFare + teamfare.OneFare;
                                    fare.OneFare = teamfare.OneFare;
                                    fare.TwoFare = teamfare.TwoFare;
                                }
                                if (teamfare.FareFree > fare.MaxFareFree) fare.MaxFareFree = teamfare.FareFree;
                                fare.Max = fare.Max + teamfare.FareFree;
                                expressFares[0] = fare;
                            }
                        }
                    }

                    for (int i = 0; i < expressFares.Count; i++)
                    {
                        ExpressFare fare = expressFares.Values[i];
                        if (fare.Max < fare.MaxFareFree) _fare = _fare + fare.Fare;
                    }
                    
                }


            }
            return _fare;

        }

    }

    public struct TeamFare
    {
        public decimal OneFare;
        public decimal TwoFare;
        public int FareFree;
        public int PartnerID;
        public int BuyNum;
    }

    public struct ExpressFare
    {
        /// <summary>
        /// 最大包邮数量条件
        /// </summary>
        public int MaxFareFree;
        /// <summary>
        /// 实际包邮数量
        /// </summary>
        public int Max;
        /// <summary>
        /// 首件运费
        /// </summary>
        public decimal OneFare;
        /// <summary>
        /// 对应的次件运费
        /// </summary>
        public decimal TwoFare;
        /// <summary>
        /// 当前运费
        /// </summary>
        public decimal Fare;
        /// <summary>
        /// 商户ID
        /// </summary>
        public int PartnerID;


    }
}
