using System;
using AS.GroupOn.DataAccess.Accessor;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using IBatisNet.DataMapper;
using System.Collections.Generic;
using System.Collections;
using AS.Common.Utils;
using System.Data;
namespace AS.GroupOn.DataAccess.Spi
{
    public class DataSession : IDataSession, IUserAccessor, ICategoryAccessor, IBranchAccessor, IAuthorAccessor, IAreaAccessor, IAdjunctAccessor, ICityAccessor, IPartnerAccessor, IBrandAccessor, IMailerAccessor, ITeamAccessor, IOrderAccessor, IOrderDetailAccessor, ICustomAccessor, IUserReivewAccessor, IAskAccessor, IPageAccessor, IFriendLinkAccessor, ICouponAccessor
        , ICardAccessor, IInviteAccessor, IFlowAccessor, ISystemAccessor
        , ICatalogsAccessor, IGuidAccessor, IPayAccessor
        , IFareTemplateAccessor, ICpsAccessor, IMenuAccessor, IInventorylogAccessor, IDrawAccessor, IExpressnocitysAccessor, IExpresspriceAccessor, IFarecitysAccessor, IFeedbackAccessor, IMenuRelationAccessor, INewsAccessor, IPacketAccessor, IPartner_DetailAccessor, ISmssubscribedetailAccessor
         , IPcouponAccessor, IProductAccessor, IRefundsAccessor, IPromotion_rulesAccessor, IRefunds_detailAccessor, IRoleAccessor, ISales_promotionAccessor, IScorelogAccessor, ISmstemplateAccessor, ISmsLogAccessor, ITemplate_printAccessor, ISmssubscribeAccessor, ITopicAccessor
        , ILocationAccessor, ImailserviceproviderAccessor, IMailserverAccessor, IMailtasksAccessor, IUserlevelrelusAccessor, IVote_FeedbackAccessor, IVote_OptionsAccessor, IVote_QuestionAccessor, IVote_Feedback_InputAccessor, IVote_Feedback_QuestionAccessor, IYizhantongAccessor, ISubscribeAccessor, ISalesAccessor, IAuthorityAccessor, IRoleAuthorityAccessor, IGetDataAccessor, IOprationLogAccessor
    {
        #region 数据库
        private ISqlMapper mapper = null;
        private bool _istransaction = false;
        public DataSession(bool istransaction)
        {
            mapper = Mapper.Get();
            if (istransaction)
            {
                mapper.BeginTransaction();
                _istransaction = true;
            }
            else
                mapper.OpenConnection();

        }

        public void Dispose()
        {
            mapper.CloseConnection();
        }

        public void Commit()
        {
            if (_istransaction)
            {
                try
                {
                    mapper.CommitTransaction(false);
                }
                catch (Exception ex)
                {
                    mapper.RollBackTransaction(false);
                    throw ex;
                }
            }
        }
        #endregion


        #region IUserAccessor 成员

        int IUserAccessor.Insert(IUser user)
        {
            return Convert.ToInt32(mapper.Insert("UserMap.insert", user));
        }

        int IUserAccessor.Update(IUser user)
        {
            return mapper.Update("UserMap.update", user);
        }

        int IUserAccessor.Delete(int id)
        {
            return mapper.Delete("UserMap.delete", id);
        }

        IUser IUserAccessor.Get(UserFilter filter)
        {
            return mapper.QueryForObject<IUser>("UserMap.gettop1byfilter", filter);
        }

        IList<IUser> IUserAccessor.GetList(UserFilter filter)
        {
            return mapper.QueryForList<IUser>("UserMap.getbyfilter", filter);
        }

        IPagers<IUser> IUserAccessor.GetPager(UserFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("UserMap.getcount", filter));
            Pagers<IUser> pagers = PagersHelper.InitPager<IUser>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IUser>("UserMap.getbypage", filter);
            return pagers;
        }

        IUser IUserAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IUser>("UserMap.getbyid", id);
        }

        int IUserAccessor.UpdateUserInfo(IUser user)
        {
            return mapper.Update("UserMap.updateuserinfo", user);
        }
        int IUserAccessor.UpdateUser(IUser user)
        {
            return mapper.Update("UserMap.updateusere", user);
        }

        int IUserAccessor.UpdateNewBie(IUser user)
        {
            return mapper.Update("UserMap.updatenewbie", user);
        }
        int IUserAccessor.UpdateUserScore(IUser user)
        {
            return mapper.Update("UserMap.updateuserscore", user);
        }
        int IUserAccessor.UpdateMoneys(IUser user)
        {
            return mapper.Update("UserMap.updatemoneys", user);
        }

        int IUserAccessor.UpdateMoney(IUser user)
        {
            return mapper.Update("UserMap.updatemoney", user);
        }

        int IUserAccessor.UpdateUcsyc(IUser user)
        {
            return mapper.Update("UserMap.updateUcsyc", user);
        }

        int IUserAccessor.UpdateEnable(IUser user)
        {
            return mapper.Update("UserMap.updateEnable", user);
        }


        IUser IUserAccessor.GetByName(UserFilter filter)
        {
            return mapper.QueryForObject<IUser>("UserMap.getbyname", filter);
        }
        IUser IUserAccessor.GetbyUName(string UserName)
        {
            return mapper.QueryForObject<IUser>("UserMap.getbyuname", UserName);
        }
        IUser IUserAccessor.GetByEmail(UserFilter filter)
        {
            return mapper.QueryForObject<IUser>("UserMap.getbyemail", filter);
        }

        int IUserAccessor.GetCountByCityId(UserFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("UserMap.getcount", filter));
        }

        int IUserAccessor.UpdateAuth(IUser user)
        {
            return mapper.Update("UserMap.updateauth", user);
        }

        int IUserAccessor.UpdateBuy(IUser user)
        {
            return mapper.Update("UserMap.updatebuy", user);
        }

        int IUserAccessor.UpdateIpTime(IUser user)
        {
            return mapper.Update("UserMap.updateIptime", user);
        }

        int IUserAccessor.GetMaxId(UserFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("UserMap.getmaxid", filter));
        }

        int IUserAccessor.UpdateSecret(IUser user)
        {
            return mapper.Update("UserMap.updatesecret",user);
        }

        int IUserAccessor.UpdatePassword(IUser user)
        {
            return mapper.Update("UserMap.updatepassword", user);
        }

        #endregion

        #region IPartnerAccessor 成员
        int IPartnerAccessor.Insert(IPartner partner)
        {
            return Convert.ToInt32(mapper.Insert("PartnerMap.insert", partner));
        }

        int IPartnerAccessor.Update(IPartner partner)
        {
            return mapper.Update("PartnerMap.update", partner);
        }

        int IPartnerAccessor.Delete(int id)
        {
            return mapper.Delete("PartnerMap.delete", id);
        }

        IPartner IPartnerAccessor.Get(PartnerFilter filter)
        {
            return mapper.QueryForObject<IPartner>("PartnerMap.gettop1byfilter", filter);
        }

        IList<IPartner> IPartnerAccessor.GetList(PartnerFilter filter)
        {
            return mapper.QueryForList<IPartner>("PartnerMap.getbyfilter", filter);
        }

        IPagers<IPartner> IPartnerAccessor.GetPager(PartnerFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("PartnerMap.getcount", filter));
            Pagers<IPartner> pagers = PagersHelper.InitPager<IPartner>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IPartner>("PartnerMap.getbypage", filter);
            return pagers;
        }

        IPartner IPartnerAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IPartner>("PartnerMap.getbyid", id);
        }
        int IPartnerAccessor.UpdateSaleid(IPartner partner)
        {
            return mapper.Update("PartnerMap.updatesaleid", partner);
        }
        int IPartnerAccessor.GetSaleid(PartnerFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("PartnerMap.getsaleid", filter), 0);
        }

        int IPartnerAccessor.GetCount(PartnerFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("PartnerMap.getcount", filter));
        }
        int IPartnerAccessor.Count(PartnerFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("PartnerMap.count", filter));
        }
        IPagers<IPartner> IPartnerAccessor.Page(PartnerFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("PartnerMap.count", filter));
            Pagers<IPartner> pagers = PagersHelper.InitPager<IPartner>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IPartner>("PartnerMap.page", filter);
            return pagers;
        }
        int IPartnerAccessor.UpdateImage1(IPartner partner)
        {
            return mapper.Update("PartnerMap.updateImage1", partner);
        }
        int IPartnerAccessor.UpdateImage2(IPartner partner)
        {
            return mapper.Update("PartnerMap.updateImage2", partner);
        }
        #endregion

        #region IDataSession 成员
        public IUserAccessor Users
        {
            get { return this; }
        }
        public ICityAccessor Citys
        {
            get { return this; }
        }

        public IPartnerAccessor Partners
        {
            get { return this; }
        }
        public ITeamAccessor Teams
        {
            get { return this; }
        }

        public IOrderAccessor Orders
        {
            get { return this; }
        }
        public IOrderDetailAccessor OrderDetail
        {
            get { return this; }
        }

        public IBrandAccessor Brand
        {
            get { return this; }
        }

        public ICustomAccessor Custom
        {
            get { return this; }
        }

        public IAskAccessor Ask
        {
            get { return this; }
        }


        public IPageAccessor Page
        {
            get { return this; }
        }
        public IFriendLinkAccessor FriendLink
        {
            get { return this; }
        }
        public ICouponAccessor Coupon
        {
            get { return this; }
        }
        public ICardAccessor Card
        {
            get
            {
                return this;
            }
        }
        public IFlowAccessor Flow
        {
            get { return this; }
        }
        public ISystemAccessor System
        {
            get { return this; }
        }

        public ICatalogsAccessor Catalogs
        {
            get { return this; }
        }

        public IPayAccessor Pay
        {
            get { return this; }
        }
        public IFareTemplateAccessor FareTemplate
        {
            get { return this; }
        }

        public ICpsAccessor Cps
        {
            get { return this; }
        }
        public IDrawAccessor Draw
        {
            get { return this; }
        }
        public IExpressnocitysAccessor Expressnocitys
        {
            get { return this; }
        }
        public IExpresspriceAccessor Expressprice
        {
            get { return this; }
        }
        public IFarecitysAccessor Farecitys
        {
            get { return this; }
        }
        public IFeedbackAccessor Feedback
        {
            get { return this; }
        }
        public IMenuRelationAccessor MenuRelation
        {
            get { return this; }
        }
        public INewsAccessor News
        {
            get { return this; }
        }
        public IPacketAccessor Packet
        {
            get { return this; }
        }
        public IPartner_DetailAccessor Partner_Detail
        {
            get { return this; }
        }

        public ISmssubscribedetailAccessor Smssubscribedetail
        {
            get { return this; }
        }

        public ISmstemplateAccessor Smstemplate
        {

            get { return this; }
        }

        public ISmsLogAccessor SmsLog
        {
            get { return this; }
        }

        public ITemplate_printAccessor Template_print
        {
            get { return this; }
        }

        public ITopicAccessor Topic
        {
            get { return this; }
        }

        public ISubscribeAccessor Subscribe
        {
            get { return this; }
        }

        public ISalesAccessor Sales
        {
            get { return this; }
        }

        public IAuthorityAccessor Authority
        {
            get { return this; }

        }

        public IRoleAuthorityAccessor RoleAuthority
        {
            get { return this; }
        }

        public IGetDataAccessor GetData
        {
            get { return this; }
        }

        public IOprationLogAccessor OprationLog
        {
            get { return this; }
        }


        #region zlj
        public IGuidAccessor Guid
        {
            get { return this; }
        }

        public IMenuAccessor Menu
        {
            get { return this; }
        }

        public IInventorylogAccessor Inventorylog
        {
            get { return this; }
        }

        public ILocationAccessor Location
        {
            get { return this; }
        }

        public IMailerAccessor Mailers
        {
            get { return this; }
        }

        public ImailserviceproviderAccessor Mailserviceprovider
        {
            get { return this; }
        }

        public IMailserverAccessor Mailserver
        {
            get { return this; }
        }

        public IMailtasksAccessor Mailtasks
        {
            get { return this; }
        }

        public IInviteAccessor Invite
        {
            get { return this; }
        }

        #endregion

        #region drl
        public IPcouponAccessor Pcoupon
        {
            get { return this; }
        }

        public IProductAccessor Product
        {
            get { return this; }
        }

        public IRefundsAccessor Refunds
        {
            get { return this; }
        }
        public IPromotion_rulesAccessor Promotion_rules
        {
            get { return this; }
        }
        public IRefunds_detailAccessor Refunds_detail
        {
            get { return this; }
        }
        public IRoleAccessor Role
        {
            get { return this; }
        }
        public ISales_promotionAccessor Sales_promotion
        {
            get { return this; }
        }
        public IScorelogAccessor Scorelog
        {
            get { return this; }
        }
        public ISmssubscribeAccessor Smssubscribe
        {
            get { return this; }
        }


        #endregion

        #region Author  By  lzmj
        public IUserReivewAccessor UserReview
        {
            get { return this; }
        }
        public IUserlevelrelusAccessor Userlevelrelus
        {
            get { return this; }
        }
        public IVote_FeedbackAccessor Vote_Feedback
        {
            get { return this; }
        }
        public IVote_Feedback_InputAccessor Vote_Feedback_Input
        {
            get { return this; }
        }
        public IVote_Feedback_QuestionAccessor Vote_Feedback_Question
        {
            get { return this; }
        }
        public IVote_OptionsAccessor Vote_Options
        {
            get { return this; }
        }
        public IVote_QuestionAccessor Vote_Question
        {
            get { return this; }
        }
        public IYizhantongAccessor Yizhantong
        {
            get { return this; }
        }
        #endregion

        #region zjq

        public IAdjunctAccessor Adjunct
        {
            get { return this; }
        }

        public IAreaAccessor Area
        {
            get { return this; }
        }

        public IAuthorAccessor Author
        {
            get { return this; }
        }

        public IBranchAccessor Branch
        {
            get { return this; }
        }

        public ICategoryAccessor Category
        {
            get { return this; }
        }

        #endregion

        #endregion

        #region ITeamAccessor 成员
        int ITeamAccessor.Insert(ITeam team)
        {
            return Convert.ToInt32(mapper.Insert("TeamMap.insert", team));
        }

        int ITeamAccessor.Update(ITeam team)
        {
            return mapper.Update("TeamMap.update", team);
        }
        int ITeamAccessor.UpdateCloseTime(ITeam team)
        {
            return mapper.Update("TeamMap.updateclosetime", team);
        }

        int ITeamAccessor.UpdateReachTime(ITeam team)
        {
            return mapper.Update("TeamMap.updatereachtime", team);
        }
        int ITeamAccessor.Delete(int id)
        {
            return mapper.Delete("TeamMap.delete", id);
        }

        ITeam ITeamAccessor.Get(TeamFilter filter)
        {
            return mapper.QueryForObject<ITeam>("TeamMap.gettop1byfilter", filter);
        }

        IList<ITeam> ITeamAccessor.GetList(string filter)
        {
            return mapper.QueryForList<ITeam>("TeamMap.getteamlists", filter);
        }

        IList<ITeam> ITeamAccessor.GetList(TeamFilter filter)
        {
            return mapper.QueryForList<ITeam>("TeamMap.getbyfilter", filter);
        }

        IPagers<ITeam> ITeamAccessor.GetPager(TeamFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("TeamMap.getcount", filter));
            Pagers<ITeam> pagers = PagersHelper.InitPager<ITeam>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ITeam>("TeamMap.getbypage", filter);
            return pagers;
        }

        ITeam ITeamAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ITeam>("TeamMap.getbyid", id);
        }

        int ITeamAccessor.GetCount(TeamFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("TeamMap.getcount", filter), 0);
        }
        int ITeamAccessor.GetSumId(TeamFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("TeamMap.getsumid", filter), 0);
        }


        IList<ITeam> ITeamAccessor.GetByCurrentTeam(TeamFilter filter)
        {
            return mapper.QueryForList<ITeam>("TeamMap.getbyCurrentTeam", filter);
        }

        IList<ITeam> ITeamAccessor.GetByCurrentOtherTeam(TeamFilter filter)
        {
            return mapper.QueryForList<ITeam>("TeamMap.getbyCurrentotherTeam", filter);
        }
        int ITeamAccessor.UpdateSaleid(ITeam team)
        {
            return mapper.Update("TeamMap.updatesaleid", team);
        }

        IList<ITeam> ITeamAccessor.GetBlockOthers(TeamFilter filter)
        {
            return mapper.QueryForList<ITeam>("TeamMap.getblockothers", filter);
        }

        IList<ITeam> ITeamAccessor.GetBrandId(TeamFilter filter)
        {
            return mapper.QueryForList<ITeam>("TeamMap.getBrandId", filter);
        }
        IList<ITeam> ITeamAccessor.GetBrandAll(TeamFilter filter)
        {
            return mapper.QueryForList<ITeam>("TeamMap.getbrandall", filter);
        }
        IPagers<ITeam> ITeamAccessor.GetPagerTeambuy(TeamFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("TeamMap.getcount", filter));
            Pagers<ITeam> pagers = PagersHelper.InitPager<ITeam>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ITeam>("TeamMap.getbypageteambuy", filter);
            return pagers;
        }

        IPagers<ITeam> ITeamAccessor.GetDetailPager(TeamFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("TeamMap.getdetailcount", filter));
            Pagers<ITeam> pagers = PagersHelper.InitPager<ITeam>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ITeam>("TeamMap.getbydetailpage", filter);
            return pagers;
        }

        IList<ITeam> ITeamAccessor.GetPingLun(TeamFilter filter)
        {
            return mapper.QueryForList<ITeam>("TeamMap.getpinglun", filter);
        }

        IList<ITeam> ITeamAccessor.GetTeamOper(TeamFilter filter)
        {
            return mapper.QueryForList<ITeam>("TeamMap.getteamoper", filter);
        }
        IList<ITeam> ITeamAccessor.GetTeamDto(TeamFilter filter)
        {
            return mapper.QueryForList<ITeam>("TeamMap.getteamdto", filter);
        }
        IList<Hashtable> ITeamAccessor.GetpBranch(TeamFilter filter)
        {
            return mapper.QueryForList<Hashtable>("TeamMap.getpbranch", filter);
        }
        IList<Hashtable> ITeamAccessor.GetpBranch1(TeamFilter filter)
        {
            return mapper.QueryForList<Hashtable>("TeamMap.getpbranch1", filter);
        }
        int ITeamAccessor.GetDetailCount(TeamFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("TeamMap.getdetailcount", filter), 0);
        }
        int ITeamAccessor.GetSum(TeamFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("TeamMap.getsum", filter), 0);
        }
        #endregion

        #region IOrderAccessor 成员

        int IOrderAccessor.GetMaxId()
        {
            return Helper.GetInt(mapper.QueryForObject("OrderMap.GetMaxid", null), 0);
        }

        int IOrderAccessor.Insert(IOrder order)
        {
            return Convert.ToInt32(mapper.Insert("OrderMap.insert", order));
        }

        int IOrderAccessor.Update(IOrder order)
        {
            return mapper.Update("OrderMap.update", order);
        }

        int IOrderAccessor.UpdateExpress_id(IOrder order)
        {
            return mapper.Update("OrderMap.updateExpress_id", order);
        }

        int IOrderAccessor.UpdateExpress_id_all(IOrder order)
        {
            return mapper.Update("OrderMap.updateExpress_id_all", order);
        }

        int IOrderAccessor.UpdateUpload(IOrder order)
        {
            return mapper.Update("OrderMap.updateUpload", order);
        }

        int IOrderAccessor.UpdatePayTime(IOrder order)
        {
            return mapper.Update("OrderMap.updatepaytime", order);
        }

        int IOrderAccessor.UpdateState(IOrder order)
        {
            return mapper.Update("OrderMap.updatestate", order);
        }

        int IOrderAccessor.UpdateFare(IOrder order)
        {
            return mapper.Update("OrderMap.updatefare", order);
        }

        int IOrderAccessor.UpdateOrigin(IOrder order)
        {
            return mapper.Update("OrderMap.updateorigin", order);
        }

        int IOrderAccessor.Delete(int id)
        {
            return mapper.Delete("OrderMap.delete", id);
        }
        //lsm添加
        int IOrderAccessor.GetCount(OrderFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("OrderMap.getcount", filter), 0);
        }
        decimal IOrderAccessor.GetSum(OrderFilter filter)
        {
            return Helper.GetDecimal(mapper.QueryForObject("OrderMap.getsumOrigin", filter), 0);
        }

        IOrder IOrderAccessor.Get(OrderFilter filter)
        {
            return mapper.QueryForObject<IOrder>("OrderMap.gettop1byfilter", filter);
        }

        IList<IOrder> IOrderAccessor.GetList(OrderFilter filter)
        {
            return mapper.QueryForList<IOrder>("OrderMap.getbyfilter", filter);
        }

        IPagers<IOrder> IOrderAccessor.GetPager(OrderFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("OrderMap.getcount", filter));
            Pagers<IOrder> pagers = PagersHelper.InitPager<IOrder>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IOrder>("OrderMap.getbypage", filter);
            return pagers;
        }

        IOrder IOrderAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IOrder>("OrderMap.getbyid", id);
        }

        IOrder IOrderAccessor.GetByPrint(int id)
        {
            return mapper.QueryForObject<IOrder>("OrderMap.orderbyprint", id);
        }

        int IOrderAccessor.UpdateTotalamount(IOrder order)
        {
            return mapper.Update("OrderMap.updatetotalamount", order);
        }

        IList<IOrder> IOrderAccessor.GetYx_TeamDown(OrderFilter filter)
        {
            return mapper.QueryForList<IOrder>("OrderMap.GetYx_TeamDown", filter);
        }

        int IOrderAccessor.GetUnpay(OrderFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("OrderMap.getunpay", filter));
        }

        IList<Hashtable> IOrderAccessor.SelById1(OrderFilter filter)
        {
            return mapper.QueryForList<Hashtable>("OrderMap.selbyid1", filter);
        }
        IList<Hashtable> IOrderAccessor.SelById2(OrderFilter filter)
        {
            return mapper.QueryForList<Hashtable>("OrderMap.selbyid2", filter);
        }
        IList<Hashtable> IOrderAccessor.SelById3(OrderFilter filter)
        {
            return mapper.QueryForList<Hashtable>("OrderMap.selbyid3", filter);
        }

        int IOrderAccessor.UpdateUnpayOrder(OrderFilter filter)
        {
            return mapper.Update("OrderMap.UpdateUnpayOrder", filter);
        }

        int IOrderAccessor.UpdateFare(OrderFilter filter)
        {
            return mapper.Update("OrderMap.updatefare", filter);
        }

        int IOrderAccessor.UpdateOrigin(OrderFilter filter)
        {
            return mapper.Update("OrderMap.updateorigin", filter);
        }

        int IOrderAccessor.UpdateOrder(IOrder order)
        {
            return mapper.Update("OrderMap.UpdateOrder", order);
        }

        int IOrderAccessor.GetBuyCount1(OrderFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("OrderMap.GetBuyCount1", filter), 0);
        }
        IList<Hashtable> IOrderAccessor.SelOrder(OrderFilter filter)
        {
            return mapper.QueryForList<Hashtable>("OrderMap.selorder", filter);
        }

        //int IOrderAccessor.GetBuyCount1(OrderFilter filter)
        //{
        //    return Helper.GetInt(mapper.QueryForObject("OrderMap.GetBuyCount1", filter), 0);
        //}
        IPagers<IOrder> IOrderAccessor.GetPager2(OrderFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("OrderMap.getcount2", filter));
            Pagers<IOrder> pagers = PagersHelper.InitPager<IOrder>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IOrder>("OrderMap.getbypage2", filter);
            return pagers;
        }
        IList<Hashtable> IOrderAccessor.Sel(OrderFilter filter)
        {
            return mapper.QueryForList<Hashtable>("OrderMap.sel", filter);
        }
        int IOrderAccessor.Count(OrderFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("OrderMap.count", filter), 0);
        }
        int IOrderAccessor.SellNumber(OrderFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("OrderMap.sellnumber", filter), 0);
        }
        int IOrderAccessor.SendNumber(OrderFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("OrderMap.sendnumber", filter), 0);
        }

        IList<IOrder> IOrderAccessor.OrderTongji(OrderFilter filter)
        {
            return mapper.QueryForList<IOrder>("OrderMap.ordertongji", filter);
        }

        IPagers<IOrder> IOrderAccessor.GetBranchPage(OrderFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("OrderMap.getbranchcount", filter));
            Pagers<IOrder> pagers = PagersHelper.InitPager<IOrder>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IOrder>("OrderMap.getbranchpage", filter);
            return pagers;
        }
        int IOrderAccessor.SelCountBranch(OrderFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("OrderMap.selcountbranch", filter), 0);
        }
        IOrder IOrderAccessor.GetPayPrice(OrderFilter filter)
        {
            return mapper.QueryForObject<IOrder>("OrderMap.getpayprice", filter);
        }
        int IOrderAccessor.GetBranchCount(OrderFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("OrderMap.getbranchcount", filter), 0);
        }
        IPagers<IOrder> IOrderAccessor.GetPagerPartner(OrderFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("OrderMap.getpartnercount", filter));
            Pagers<IOrder> pagers = PagersHelper.InitPager<IOrder>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IOrder>("OrderMap.getpartner", filter);
            return pagers;
        }
        IPagers<IOrder> IOrderAccessor.GetPagerPLTeam(OrderFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("OrderMap.getplteamcount", filter));
            Pagers<IOrder> pagers = PagersHelper.InitPager<IOrder>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IOrder>("OrderMap.getplteam", filter);
            return pagers;
        }

        #endregion

        #region IOrderDetailAccessor 成员
        int IOrderDetailAccessor.Insert(IOrderDetail orderdetail)
        {
            return Convert.ToInt32(mapper.Insert("OrderDetailMap.insert", orderdetail));
        }

        int IOrderDetailAccessor.Update(IOrderDetail orderdetail)
        {
            return mapper.Update("OrderDetailMap.update", orderdetail);
        }
        int IOrderDetailAccessor.UpdateOrderScore(IOrderDetail orderdetail)
        {
            return mapper.Update("OrderDetailMap.updateorderscore", orderdetail);
        }
        int IOrderDetailAccessor.Delete(int id)
        {
            return mapper.Delete("OrderDetailMap.delete", id);
        }

        IOrderDetail IOrderDetailAccessor.Get(OrderDetailFilter filter)
        {
            return mapper.QueryForObject<IOrderDetail>("OrderDetailMap.gettop1byfilter", filter);
        }

        IList<IOrderDetail> IOrderDetailAccessor.GetList(OrderDetailFilter filter)
        {
            return mapper.QueryForList<IOrderDetail>("OrderDetailMap.getbyfilter", filter);
        }

        IPagers<IOrderDetail> IOrderDetailAccessor.GetPager(OrderDetailFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("OrderDetailMap.getcount", filter));
            Pagers<IOrderDetail> pagers = PagersHelper.InitPager<IOrderDetail>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IOrderDetail>("OrderDetailMap.getbypage", filter);
            return pagers;
        }

        IOrderDetail IOrderDetailAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IOrderDetail>("OrderDetailMap.getbyid", id);
        }
        int IOrderDetailAccessor.GetByOrderid_team(int id)
        {
            return mapper.QueryForObject<int>("OrderDetailMap.getbyorderid_team", id);
        }

        IList<IOrderDetail> IOrderDetailAccessor.GetByOrder_ID(int id)
        {
            return mapper.QueryForList<IOrderDetail>("OrderDetailMap.getbyorderid", id);
        }

        IList<IOrderDetail> IOrderDetailAccessor.GetDetailTeam(OrderDetailFilter filter)
        {
            return mapper.QueryForList<IOrderDetail>("OrderDetailMap.GetDetailTeam", filter);
        }

        int IOrderDetailAccessor.GetDetailCount(OrderDetailFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("OrderDetailMap.getdetailcount", filter));
        }

        int IOrderDetailAccessor.GetBuyCount2(OrderDetailFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("OrderDetailMap.GetBuyCount2", filter), 0);
        }
        IList<Hashtable> IOrderDetailAccessor.GetPartnerNum(OrderDetailFilter filter)
        {
            return mapper.QueryForList<Hashtable>("OrderDetailMap.getpartnernum", filter);
        }
        #endregion

        #region ICityAccessor 成员

        int ICityAccessor.Insert(ICity city)
        {
            return Convert.ToInt32(mapper.Insert("CityMap.insert", city));
        }

        int ICityAccessor.Update(ICity city)
        {
            return mapper.Update("CityMap.update", city);
        }

        int ICityAccessor.Delete(int id)
        {
            return mapper.Delete("CityMap.delete", id);
        }

        ICity ICityAccessor.Get(CityFilter filter)
        {
            return mapper.QueryForObject<ICity>("CityMap.gettop1byfilter", filter);
        }

        IList<ICity> ICityAccessor.GetList(CityFilter filter)
        {
            return mapper.QueryForList<ICity>("CityMap.getbyfilter", filter);
        }

        IPagers<ICity> ICityAccessor.GetPager(CityFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("CityMap.getcount", filter));
            Pagers<ICity> pagers = PagersHelper.InitPager<ICity>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ICity>("CityMap.getbypage", filter);
            return pagers;
        }

        ICity ICityAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ICity>("CityMap.getbyid", id);
        }

        #endregion

        #region IBrandAccessor 成员
        int IBrandAccessor.Insert(IBrand brand)
        {
            return Convert.ToInt32(mapper.Insert("BrandMap.insert", brand));
        }


        int IBrandAccessor.Update(IBrand brand)
        {
            return mapper.Update("BrandMap.update", brand);
        }

        int IBrandAccessor.Delete(int id)
        {
            return mapper.Delete("BrandMap.delete", id);
        }

        IBrand IBrandAccessor.Get(BrandFilter filter)
        {
            return mapper.QueryForObject<IBrand>("BrandMap.gettop1byfilter", filter);
        }

        IList<IBrand> IBrandAccessor.GetList(BrandFilter filter)
        {
            return mapper.QueryForList<IBrand>("BrandMap.getbyfilter", filter);
        }

        IPagers<IBrand> IBrandAccessor.GetPager(BrandFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("BrandMap.getcount", filter));
            Pagers<IBrand> pagers = PagersHelper.InitPager<IBrand>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IBrand>("BrandMap.getbypage", filter);
            return pagers;
        }

        IBrand IBrandAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IBrand>("BrandMap.getbyid", id);
        }
        #endregion

        #region ICustomAccessor 成员
        int ICustomAccessor.GetTeamCount(int? cataid, int? cityid, int? typeid)
        {
            Hashtable hashTable = new Hashtable();
            if (cataid.HasValue)
                hashTable.Add("CatID", cataid);
            if (cityid.HasValue)
                hashTable.Add("CityID", cityid);
            if (typeid.HasValue)
                hashTable.Add("TypeID", typeid);

            return mapper.QueryForObject<int>("CustomMap.selectTeamCount", hashTable);
        }

        /// <summary>
        ///修改自动修改项目购买人数
        /// </summary>
        void ICustomAccessor.UpdateTeamNowNumber()
        {
            DateTime now_time=DateTime.Now;
           
            Hashtable hashTable = new Hashtable();

            hashTable.Add("Begin_time", now_time);
            hashTable.Add("End_time", now_time);

            mapper.Update("CustomMap.updateTeamInterval", hashTable);
            mapper.Update("CustomMap.updateTeamNowNumber", hashTable);
        }
        /// <summary>
        /// 得到短信订阅用户信息
        /// </summary>
        /// <param name="nowTime">当前时间</param>
        /// <returns></returns>
        List<System.Collections.Hashtable> ICustomAccessor.GetSMSSubscribe(DateTime nowTime)
        {
            return (List<Hashtable>)mapper.QueryForList<Hashtable>("CustomMap.selectSMSSubscribe", nowTime);
        }
        /// <summary>
        /// 提前查询到期的项目
        /// </summary>
        /// <param name="Days">天数（提前多少天查询）</param>
        /// <returns></returns>
        List<System.Collections.Hashtable> ICustomAccessor.GetTeamIsEndTime( int Days)
        {
            return (List<Hashtable>)mapper.QueryForList<Hashtable>("CustomMap.selectTeamIsEndTime", Days);
        }

        /// <summary>
        /// 修改项目的结束时间
        /// </summary>
        /// <param name="hashtable"></param>
        void ICustomAccessor.UpdateTeamEndTime(Hashtable hashtable)
        {
            mapper.Update("CustomMap.updateTeamEndTime", hashtable);

        }


        /// <summary>
        /// 查询某个表的数据（selectFilds:查询字段;tableName:表名;WhereString：查询条件;SortOrderString：排序规则）
        /// </summary>
        /// <param name="selectHash">上面参数的hash信息</param>
        /// <returns></returns>
        List<Hashtable> ICustomAccessor.SelectTableWithParameter(Hashtable selectHash)
        {
            return (List<Hashtable>)mapper.QueryForList<Hashtable>("CustomMap.selectTable", selectHash);
        }

        /// <summary>
        /// 执行某个查询语句
        /// </summary>
        /// <param name="selectSql">执行的sql</param>
        /// <returns></returns>
        List<Hashtable> ICustomAccessor.Query(string selectSql)
        {
            return (List<Hashtable>)mapper.QueryForList<Hashtable>("CustomMap.Query", selectSql);
        }

        /// <summary>
        /// 更新某个表的信息
        /// </summary>
        /// <param name="updateHash">更新sql</param>
        void ICustomAccessor.Update(string updateSql)
        {
            mapper.Update("CustomMap.updateTable", updateSql);
        }
        #endregion

        #region IAskAccessor 成员
        int IAskAccessor.Insert(IAsk ask)
        {
            return Convert.ToInt32(mapper.Insert("AskMap.insert", ask));
        }

        int IAskAccessor.Update(IAsk ask)
        {
            return mapper.Update("AskMap.update", ask);
        }

        int IAskAccessor.Delete(int id)
        {
            return mapper.Delete("AskMap.delete", id);
        }

        IAsk IAskAccessor.Get(AskFilter filter)
        {
            return mapper.QueryForObject<IAsk>("AskMap.gettop1byfilter", filter);
        }

        IList<IAsk> IAskAccessor.GetList(AskFilter filter)
        {
            return mapper.QueryForList<IAsk>("AskMap.getbyfilter", filter);
        }

        IPagers<IAsk> IAskAccessor.GetPager(AskFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("AskMap.getcount", filter));
            Pagers<IAsk> pagers = PagersHelper.InitPager<IAsk>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IAsk>("AskMap.getbypage", filter);
            return pagers;
        }
        IPagers<IAsk> IAskAccessor.GetPagerTm(AskFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("AskMap.getcounttm", filter));
            Pagers<IAsk> pagers = PagersHelper.InitPager<IAsk>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IAsk>("AskMap.getbypagetm", filter);
            return pagers;
        }

        IAsk IAskAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IAsk>("AskMap.getbyid", id);
        }

        int IAskAccessor.GetCount(AskFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("AskMap.getcount", filter));
        }

        int IAskAccessor.UpdateBat(SqlBat.AskBat Params)
        {
            return Convert.ToInt32(mapper.Update("AskMap.updatebat", Params));
        }

        int IAskAccessor.DeleteBat(AskFilter filter)
        {
            return Convert.ToInt32(mapper.Delete("AskMap.deletebat", filter));
        }
        #endregion

        #region IPageAccessor成员
        void IPageAccessor.Insert(IPage page)
        {
            mapper.Insert("PageMap.insert", page);
        }

        int IPageAccessor.Update(IPage page)
        {
            return mapper.Update("PageMap.update", page);
        }

        int IPageAccessor.Delete(int id)
        {
            return mapper.Delete("PageMap.delete", id);
        }

        IPage IPageAccessor.Get(PageFilter filter)
        {
            return mapper.QueryForObject<IPage>("PageMap.gettop1byfilter", filter);
        }

        IList<IPage> IPageAccessor.GetList(PageFilter filter)
        {
            return mapper.QueryForList<IPage>("PageMap.getbyfilter", filter);
        }

        IPagers<IPage> IPageAccessor.GetPager(PageFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("PageMap.getcount", filter));
            Pagers<IPage> pagers = PagersHelper.InitPager<IPage>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IPage>("PageMap.getbypage", filter);
            return pagers;
        }
        IPagers<IPage> IPageAccessor.GetPagerTm(PageFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("PageMap.getcounttm", filter));
            Pagers<IPage> pagers = PagersHelper.InitPager<IPage>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IPage>("PageMap.getbypagetm", filter);
            return pagers;
        }

        IPage IPageAccessor.GetByID(string id)
        {
            return mapper.QueryForObject<IPage>("PageMap.getbyid", id);
        }
        #endregion

        #region ICouponAccessor成员
        int ICouponAccessor.Insert(ICoupon coupon)
        {
           return  Convert.ToInt32( mapper.Insert("CouponMap.insert", coupon));
        }

        int ICouponAccessor.Update(ICoupon coupon)
        {
            return mapper.Update("CouponMap.update", coupon);
        }

        int ICouponAccessor.Delete(string id)
        {
            return mapper.Delete("CouponMap.delete", id);
        }

        int ICouponAccessor.Delete(CouponFilter filter)
        {
            return mapper.Delete("CouponMap.deletes", filter);
        }

        ICoupon ICouponAccessor.Get(CouponFilter filter)
        {
            return mapper.QueryForObject<ICoupon>("CouponMap.gettop1byfilter", filter);
        }

        IList<ICoupon> ICouponAccessor.GetList(CouponFilter filter)
        {
            return mapper.QueryForList<ICoupon>("CouponMap.getbyfilter", filter);
        }

        IPagers<ICoupon> ICouponAccessor.GetPager(CouponFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("CouponMap.getcount", filter));
            Pagers<ICoupon> pagers = PagersHelper.InitPager<ICoupon>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ICoupon>("CouponMap.getbypage", filter);
            return pagers;
        }

        ICoupon ICouponAccessor.GetByID(string id)
        {
            return mapper.QueryForObject<ICoupon>("CouponMap.getbyid", id);
        }

        int ICouponAccessor.GetCount(CouponFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("CouponMap.getcount", filter));
        }

        int ICouponAccessor.SelectCount(CouponFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("CouponMap.selectcount", filter));
        }
        int ICouponAccessor.SelById1(CouponFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("CouponMap.selbyid1", filter));
        }
        int ICouponAccessor.SelById2(CouponFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("CouponMap.selbyid2", filter));
        }
        int ICouponAccessor.SelById3(CouponFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("CouponMap.selbyid3", filter));
        }
        IPagers<ICoupon> ICouponAccessor.GetPager2(CouponFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("CouponMap.getcount2", filter));
            Pagers<ICoupon> pagers = PagersHelper.InitPager<ICoupon>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ICoupon>("CouponMap.getbypage2", filter);
            return pagers;
        }
        int ICouponAccessor.CouponNumber(CouponFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("CouponMap.couponnumber", filter));
        }
        
        int ICouponAccessor.UpCoupon(ICoupon coupon)
        {
            return mapper.Update("CouponMap.upcoupon", coupon);
        }

        IPagers<ICoupon> ICouponAccessor.PagerCoupon(CouponFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("CouponMap.countcoupon", filter));
            Pagers<ICoupon> pagers = PagersHelper.InitPager<ICoupon>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ICoupon>("CouponMap.pagercoupon", filter);
            return pagers;
        }
        int ICouponAccessor.UpdateCoupon(ICoupon coupon)
        {
            return mapper.Update("CouponMap.updatecoupon", coupon);
        }
        int ICouponAccessor.UpdateShoptypes(ICoupon coupon)
        {
            return mapper.Update("CouponMap.updateShoptypes", coupon);
        }

        #endregion

        #region ICardAccessor成员
        int ICardAccessor.Insert(ICard card)
        {
            return Convert.ToInt32(mapper.Insert("CardMap.insert", card));
        }

        int ICardAccessor.Update(ICard card)
        {
            return mapper.Update("CardMap.update", card);
        }

        int ICardAccessor.Delete(string id)
        {
            return mapper.Delete("CardMap.delete", id);
        }

        ICard ICardAccessor.Get(CardFilter filter)
        {
            return mapper.QueryForObject<ICard>("CardMap.gettop1byfilter", filter);
        }

        IList<ICard> ICardAccessor.GetList(CardFilter filter)
        {
            return mapper.QueryForList<ICard>("CardMap.getbyfilter", filter);
        }

        IPagers<ICard> ICardAccessor.GetPager(CardFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("CardMap.getcount", filter));
            Pagers<ICard> pagers = PagersHelper.InitPager<ICard>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ICard>("CardMap.getbypage", filter);
            return pagers;
        }

        ICard ICardAccessor.GetByID(string id)
        {
            return mapper.QueryForObject<ICard>("CardMap.getbyid", id);
        }

        Hashtable ICardAccessor.CardDown(CardFilter filter)
        {
            return mapper.QueryForObject<Hashtable>("CardMap.selectCardDown", filter);
        }
        IPagers<ICard> ICardAccessor.GetPagerHBShaiXuan(CardFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("CardMap.getcount2", filter));
            Pagers<ICard> pagers = PagersHelper.InitPager<ICard>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ICard>("CardMap.getbypage2", filter);
            return pagers;
        }
        IPagers<ICard> ICardAccessor.GetPagerHBShaiXuanTid(CardFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("CardMap.getcount3", filter));
            Pagers<ICard> pagers = PagersHelper.InitPager<ICard>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ICard>("CardMap.getbypage3", filter);
            return pagers;
        }

        IList<ICard> ICardAccessor.GetList(string filter)
        {
            return mapper.QueryForList<ICard>("CardMap.getcardlists", filter);
        }

        IPagers<ICard> ICardAccessor.GetMobilCard(CardFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("CardMap.getcount4", filter));
            Pagers<ICard> pagers = PagersHelper.InitPager<ICard>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ICard>("CardMap.getbypage4", filter);
            return pagers;
        }

        #endregion

        #region ISystemAccessor成员
        int ISystemAccessor.Insert(ISystem system)
        {
            return Convert.ToInt32(mapper.Insert("SystemMap.insert", system));
        }

        int ISystemAccessor.Update(ISystem system)
        {
            return mapper.Update("SystemMap.update", system);
        }

        int ISystemAccessor.Delete(int id)
        {
            return mapper.Delete("SystemMap.delete", id);
        }

        ISystem ISystemAccessor.Get(SystemFilter filter)
        {
            return mapper.QueryForObject<ISystem>("SystemMap.gettop1byfilter", filter);
        }

        IList<ISystem> ISystemAccessor.GetList(SystemFilter filter)
        {
            return mapper.QueryForList<ISystem>("SystemMap.getbyfilter", filter);
        }

        IPagers<ISystem> ISystemAccessor.GetPager(SystemFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("SystemMap.getcount", filter));
            Pagers<ISystem> pagers = PagersHelper.InitPager<ISystem>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ISystem>("SystemMap.getbypage", filter);
            return pagers;
        }

        ISystem ISystemAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ISystem>("SystemMap.getbyid", id);
        }


        #endregion

        #region ICatalogsAccessor成员
        int ICatalogsAccessor.Insert(ICatalogs catalogs)
        {
            return Convert.ToInt32(mapper.Insert("CatalogsMap.insert", catalogs));
        }

        int ICatalogsAccessor.Update(ICatalogs catalogs)
        {
            return mapper.Update("CatalogsMap.update", catalogs);
        }

        int ICatalogsAccessor.Delete(int id)
        {
            return mapper.Delete("CatalogsMap.delete", id);
        }

        ICatalogs ICatalogsAccessor.Get(CatalogsFilter filter)
        {
            return mapper.QueryForObject<ICatalogs>("CatalogsMap.gettop1byfilter", filter);
        }

        IList<ICatalogs> ICatalogsAccessor.GetList(CatalogsFilter filter)
        {
            return mapper.QueryForList<ICatalogs>("CatalogsMap.getbyfilter", filter);
        }

        IPagers<ICatalogs> ICatalogsAccessor.GetPager(CatalogsFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("CatalogsMap.getcount", filter));
            Pagers<ICatalogs> pagers = PagersHelper.InitPager<ICatalogs>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ICatalogs>("CatalogsMap.getbypage", filter);
            return pagers;
        }

        ICatalogs ICatalogsAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ICatalogs>("CatalogsMap.getbyid", id);
        }

        IList<ICatalogs> ICatalogsAccessor.GetDetail(CatalogsFilter filter)
        { 
            return mapper.QueryForList<ICatalogs>("CatalogsMap.getdetail", filter);
        }

        #endregion

        #region IPayAccessor成员
        void IPayAccessor.Insert(IPay pay)
        {
            mapper.Insert("PayMap.insert", pay);
        }

        int IPayAccessor.Update(IPay pay)
        {
            return mapper.Update("PayMap.update", pay);
        }

        int IPayAccessor.UpdateMoney(IPay pay)
        {
            return mapper.Update("PayMap.updatemoney", pay);
        }




        int IPayAccessor.Delete(int id)
        {
            return mapper.Delete("PayMap.delete", id);
        }

        IPay IPayAccessor.Get(PayFilter filter)
        {
            return mapper.QueryForObject<IPay>("PayMap.gettop1byfilter", filter);
        }

        IList<IPay> IPayAccessor.GetList(PayFilter filter)
        {
            return mapper.QueryForList<IPay>("PayMap.getbyfilter", filter);
        }

        IPagers<IPay> IPayAccessor.GetPager(PayFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("PayMap.getcount", filter));
            Pagers<IPay> pagers = PagersHelper.InitPager<IPay>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IPay>("PayMap.getbypage", filter);
            return pagers;
        }

        IPay IPayAccessor.GetByID(string id)
        {
            return mapper.QueryForObject<IPay>("PayMap.getbyid", id);
        }

        IPay IPayAccessor.GetByBank(PayFilter filter)
        {
            return mapper.QueryForObject<IPay>("PayMap.getbybank", filter);
        }

        #endregion

        #region IMenuRelationAccessor 成员

        int IMenuRelationAccessor.Insert(IMenuRelation menuRelation)
        {
            return Convert.ToInt32(mapper.Insert("MenuRelationMap.insert", menuRelation));
        }

        int IMenuRelationAccessor.Update(IMenuRelation menuRelation)
        {
            return mapper.Update("MenuRelationMap.update", menuRelation);
        }

        int IMenuRelationAccessor.Delete(int id)
        {
            return mapper.Delete("MenuRelationMap.delete", id);
        }

        IMenuRelation IMenuRelationAccessor.Get(MenuRelationFilter filter)
        {
            return mapper.QueryForObject<IMenuRelation>("MenuRelationMap.gettop1byfilter", filter);
        }

        IList<IMenuRelation> IMenuRelationAccessor.GetList(MenuRelationFilter filter)
        {
            return mapper.QueryForList<IMenuRelation>("MenuRelationMap.getbyfilter", filter);
        }

        IPagers<IMenuRelation> IMenuRelationAccessor.GetPager(MenuRelationFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("MenuRelationMap.getcount", filter));
            Pagers<IMenuRelation> pagers = PagersHelper.InitPager<IMenuRelation>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IMenuRelation>("MenuRelationMap.getbypage", filter);
            return pagers;
        }

        IMenuRelation IMenuRelationAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IMenuRelation>("MenuRelationMap.getbyid", id);
        }

        #endregion

        #region INewsAccessor 成员

        int INewsAccessor.Insert(INews news)
        {
            return Convert.ToInt32(mapper.Insert("NewsMap.insert", news));
        }

        int INewsAccessor.Update(INews news)
        {
            return mapper.Update("NewsMap.update", news);
        }

        int INewsAccessor.Delete(int id)
        {
            return mapper.Delete("NewsMap.delete", id);
        }

        INews INewsAccessor.Get(NewsFilter filter)
        {
            return mapper.QueryForObject<INews>("NewsMap.gettop1byfilter", filter);
        }

        IList<INews> INewsAccessor.GetList(NewsFilter filter)
        {
            return mapper.QueryForList<INews>("NewsMap.getbyfilter", filter);
        }

        IPagers<INews> INewsAccessor.GetPager(NewsFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("NewsMap.getcount", filter));
            Pagers<INews> pagers = PagersHelper.InitPager<INews>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<INews>("NewsMap.getbypage", filter);
            return pagers;
        }

        INews INewsAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<INews>("NewsMap.getbyid", id);
        }

        #endregion

        #region IPacketAccessor 成员

        int IPacketAccessor.Insert(IPacket packet)
        {
            return Convert.ToInt32(mapper.Insert("PacketMap.insert", packet));
        }

        int IPacketAccessor.InsertPfdjq(IPacket packet)
        {
            return Convert.ToInt32(mapper.Insert("PacketMap.insertpfdjq", packet));
        }

        int IPacketAccessor.InsertHBCZ(IPacket packet)
        {
            return Convert.ToInt32(mapper.Insert("PacketMap.inserthbcz", packet));
        }

        int IPacketAccessor.Update(IPacket packet)
        {
            return mapper.Update("PacketMap.update", packet);
        }

        int IPacketAccessor.Delete(int id)
        {
            return mapper.Delete("PacketMap.delete", id);
        }

        IPacket IPacketAccessor.Get(PacketFilter filter)
        {
            return mapper.QueryForObject<IPacket>("PacketMap.gettop1byfilter", filter);
        }

        IList<IPacket> IPacketAccessor.GetList(PacketFilter filter)
        {
            return mapper.QueryForList<IPacket>("PacketMap.getbyfilter", filter);
        }

        IPagers<IPacket> IPacketAccessor.GetPager(PacketFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("PacketMap.getcount", filter));
            Pagers<IPacket> pagers = PagersHelper.InitPager<IPacket>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IPacket>("PacketMap.getbypage", filter);
            return pagers;
        }

        IPacket IPacketAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IPacket>("PacketMap.getbyid", id);
        }

        #endregion

        #region IPartner_DetailAccessor 成员

        int IPartner_DetailAccessor.Insert(IPartner_Detail partner_datail)
        {
            return Convert.ToInt32(mapper.Insert("Partner_DetailMap.insert", partner_datail));
        }

        int IPartner_DetailAccessor.Update(IPartner_Detail partner_datail)
        {
            return mapper.Update("Partner_DetailMap.update", partner_datail);
        }

        int IPartner_DetailAccessor.Delete(int id)
        {
            return mapper.Delete("Partner_DetailMap.delete", id);
        }

        IPartner_Detail IPartner_DetailAccessor.Get(Partner_DetailFilter filter)
        {
            return mapper.QueryForObject<IPartner_Detail>("Partner_DetailMap.gettop1byfilter", filter);
        }

        IList<IPartner_Detail> IPartner_DetailAccessor.GetList(Partner_DetailFilter filter)
        {
            return mapper.QueryForList<IPartner_Detail>("Partner_DetailMap.getbyfilter", filter);
        }

        IPagers<IPartner_Detail> IPartner_DetailAccessor.GetPager(Partner_DetailFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("Partner_DetailMap.getcount", filter));
            Pagers<IPartner_Detail> pagers = PagersHelper.InitPager<IPartner_Detail>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IPartner_Detail>("Partner_DetailMap.getbypage", filter);
            return pagers;
        }

        IPartner_Detail IPartner_DetailAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IPartner_Detail>("Partner_DetailMap.getbyid", id);
        }
        int IPartner_DetailAccessor.GetCount(Partner_DetailFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("Partner_DetailMap.getcount", filter));
        }
        //获得应结算值
        decimal IPartner_DetailAccessor.exts_sp_GetPMoney(int partner_id)
        {
            return Convert.ToDecimal(mapper.QueryForObject("Partner_DetailMap.exts_sp_GetPMoney", partner_id));
        }
        //实际卖出
        decimal IPartner_DetailAccessor.GetActualPMoney(int parid)
        {
            return Convert.ToDecimal(mapper.QueryForObject("Partner_DetailMap.GetActualPMoney", parid));
        }
        //实际结算
        decimal IPartner_DetailAccessor.getRealSettle(Partner_DetailFilter filter) 
        {
            return Convert.ToDecimal(mapper.QueryForObject("Partner_DetailMap.getRealSettle", filter));
        }
        //已结算金额
        decimal IPartner_DetailAccessor.getYjsMenory(Partner_DetailFilter filter) 
        {
            return Convert.ToDecimal(mapper.QueryForObject("Partner_DetailMap.GetYjsMenory", filter));
        }
        IList<Hashtable> IPartner_DetailAccessor.Seljiesuan(Partner_DetailFilter filter)
        {
            return mapper.QueryForList<Hashtable>("Partner_DetailMap.seljiesuan", filter);
        }
        #endregion

        #region ISmssubscribedetailAccessor 成员

        int ISmssubscribedetailAccessor.Insert(ISmssubscribedetail Smssubscribedetail)
        {
            return Convert.ToInt32(mapper.Insert("SmssubscribedetailMap.insert", Smssubscribedetail));
        }

        int ISmssubscribedetailAccessor.Update(ISmssubscribedetail Smssubscribedetail)
        {
            return mapper.Update("SmssubscribedetailMap.update", Smssubscribedetail);
        }

        int ISmssubscribedetailAccessor.Delete(int id)
        {
            return mapper.Delete("SmssubscribedetailMap.delete", id);
        }

        ISmssubscribedetail ISmssubscribedetailAccessor.Get(SmssubscribedetailFilter filter)
        {
            return mapper.QueryForObject<ISmssubscribedetail>("SmssubscribedetailMap.gettop1byfilter", filter);
        }

        IList<ISmssubscribedetail> ISmssubscribedetailAccessor.GetList(SmssubscribedetailFilter filter)
        {
            return mapper.QueryForList<ISmssubscribedetail>("SmssubscribedetailMap.getbyfilter", filter);
        }

        IPagers<ISmssubscribedetail> ISmssubscribedetailAccessor.GetPager(SmssubscribedetailFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("SmssubscribedetailMap.getcount", filter));
            Pagers<ISmssubscribedetail> pagers = PagersHelper.InitPager<ISmssubscribedetail>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ISmssubscribedetail>("SmssubscribedetailMap.getbypage", filter);
            return pagers;
        }

        ISmssubscribedetail ISmssubscribedetailAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ISmssubscribedetail>("SmssubscribedetailMap.getbyid", id);
        }

        int ISmssubscribedetailAccessor.GetCount(SmssubscribedetailFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("SmssubscribedetailMap.getcount", filter));
        }

        #endregion

        #region ISmstemplateAccessor 成员

        int ISmstemplateAccessor.Insert(ISmstemplate Smstemplate)
        {
            return Convert.ToInt32(mapper.Insert("SmstemplateMap.insert", Smstemplate));
        }

        int ISmstemplateAccessor.Update(ISmstemplate Smstemplate)
        {
            return mapper.Update("SmstemplateMap.update", Smstemplate);
        }

        int ISmstemplateAccessor.Delete(int id)
        {
            return mapper.Delete("SmstemplateMap.delete", id);
        }

        ISmstemplate ISmstemplateAccessor.Get(SmstemplateFilter filter)
        {
            return mapper.QueryForObject<ISmstemplate>("SmstemplateMap.gettop1byfilter", filter);
        }

        IList<ISmstemplate> ISmstemplateAccessor.GetList(SmstemplateFilter filter)
        {
            return mapper.QueryForList<ISmstemplate>("SmstemplateMap.getbyfilter", filter);
        }

        IPagers<ISmstemplate> ISmstemplateAccessor.GetPager(SmstemplateFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("SmstemplateMap.getcount", filter));
            Pagers<ISmstemplate> pagers = PagersHelper.InitPager<ISmstemplate>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ISmstemplate>("SmstemplateMap.getbypage", filter);
            return pagers;
        }


        int ISmstemplateAccessor.GetCount(SmstemplateFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("SmstemplateMap.getcount", filter));
        }

        ISmstemplate ISmstemplateAccessor.GetByName(string name)
        {
            return mapper.QueryForObject<ISmstemplate>("SmstemplateMap.getbyname", name);
        }
        #endregion

        #region ITemplate_printAccessor 成员

        int ITemplate_printAccessor.Insert(ITemplate_print Template_print)
        {
            return Convert.ToInt32(mapper.Insert("Template_printMap.insert", Template_print));
        }

        int ITemplate_printAccessor.Update(ITemplate_print Template_print)
        {
            return mapper.Update("Template_printMap.update", Template_print);
        }

        int ITemplate_printAccessor.Delete(int id)
        {
            return mapper.Delete("Template_printMap.delete", id);
        }

        ITemplate_print ITemplate_printAccessor.Get(Template_printFilter filter)
        {
            return mapper.QueryForObject<ITemplate_print>("Template_printMap.gettop1byfilter", filter);
        }

        IList<ITemplate_print> ITemplate_printAccessor.GetList(Template_printFilter filter)
        {
            return mapper.QueryForList<ITemplate_print>("Template_printMap.getbyfilter", filter);
        }


        IPagers<ITemplate_print> ITemplate_printAccessor.GetPager(Template_printFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("Template_printMap.getcount", filter));
            Pagers<ITemplate_print> pagers = PagersHelper.InitPager<ITemplate_print>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ITemplate_print>("Template_printMap.getbypage", filter);
            return pagers;
        }

        ITemplate_print ITemplate_printAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ITemplate_print>("Template_printMap.getbyid", id);
        }

        int ITemplate_printAccessor.GetCount(Template_printFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("Template_printMap.getcount", filter));
        }

        #endregion

        #region ITopicAccessor 成员
        int ITopicAccessor.Insert(ITopic Topic)
        {
            return Convert.ToInt32(mapper.Insert("TopicMap.insert", Topic));
        }

        int ITopicAccessor.Update(ITopic Topic)
        {
            return mapper.Update("TopicMap.update", Topic);
        }

        int ITopicAccessor.Delete(int id)
        {
            return mapper.Delete("TopicMap.delete", id);
        }

        ITopic ITopicAccessor.Get(TopicFilter filter)
        {
            return mapper.QueryForObject<ITopic>("TopicMap.gettop1byfilter", filter);
        }

        IList<ITopic> ITopicAccessor.GetList(TopicFilter filter)
        {
            return mapper.QueryForList<ITopic>("TopicMap.getbyfilter", filter);
        }

        IPagers<ITopic> ITopicAccessor.GetPager(TopicFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("TopicMap.getcount", filter));
            Pagers<ITopic> pagers = PagersHelper.InitPager<ITopic>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ITopic>("TopicMap.getbypage", filter);
            return pagers;
        }
        IPagers<ITopic> ITopicAccessor.GetByPage(TopicFilter filter) 
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("TopicMap.getcount", filter));
            Pagers<ITopic> pagers = PagersHelper.InitPager<ITopic>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ITopic>("TopicMap.getpages", filter);
            return pagers;
        }
        IPagers<ITopic> ITopicAccessor.GetByPageS(TopicFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("TopicMap.getcounta", filter));
            Pagers<ITopic> pagers = PagersHelper.InitPager<ITopic>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ITopic>("TopicMap.getbypages", filter);
            return pagers;
        }
        int ITopicAccessor.GetCounts(TopicFilter filter) 
        {
            return Convert.ToInt32(mapper.QueryForObject("TopicMap.getcounta", filter));
        }
        ITopic ITopicAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ITopic>("TopicMap.getbyid", id);
        }

        int ITopicAccessor.GetCount(TopicFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("TopicMap.getcount", filter));
        }
        #endregion

        #region ISubscribeAccessor 成员
        int ISubscribeAccessor.Insert(ISubscribe Subscribe)
        {
            return Convert.ToInt32(mapper.Insert("SubscribeMap.insert", Subscribe));
        }

        int ISubscribeAccessor.Update(ISubscribe Subscribe)
        {
            return mapper.Update("SubscribeMap.update", Subscribe);
        }

        int ISubscribeAccessor.Delete(int id)
        {
            return mapper.Delete("SubscribeMap.delete", id);
        }

        ISubscribe ISubscribeAccessor.Get(SubscribeFilter filter)
        {
            return mapper.QueryForObject<ISubscribe>("SubscribeMap.gettop1byfilter", filter);
        }

        IList<ISubscribe> ISubscribeAccessor.GetList(SubscribeFilter filter)
        {
            return mapper.QueryForList<ISubscribe>("SubscribeMap.getbyfilter", filter);
        }

        IPagers<ISubscribe> ISubscribeAccessor.GetPager(SubscribeFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("SubscribeMap.getcount", filter));
            Pagers<ISubscribe> pagers = PagersHelper.InitPager<ISubscribe>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ISubscribe>("SubscribeMap.getbypage", filter);
            return pagers;
        }

        ISubscribe ISubscribeAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ISubscribe>("SubscribeMap.getbyid", id);
        }

        int ISubscribeAccessor.GetCount(SubscribeFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("SubscribeMap.getcount", filter));
        }

        #endregion

        #region zlj

        #region IInviteAccessor成员
        int IInviteAccessor.Insert(IInvite invite)
        {
            return Helper.GetInt(mapper.Insert("InviteMap.insert", invite),0);
        }

        int IInviteAccessor.Update(IInvite invite)
        {
            return mapper.Update("InviteMap.update", invite);
        }

        int IInviteAccessor.UpdatePayTime(IInvite invite)
        {
            return mapper.Update("InviteMap.updatepaytime", invite);
        }
        int IInviteAccessor.Delete(int id)
        {
            return mapper.Delete("InviteMap.delete", id);
        }

        int IInviteAccessor.GetCount(InviteFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("InviteMap.getcount", filter),0);    
        }

        IInvite IInviteAccessor.Get(InviteFilter filter)
        {
            return mapper.QueryForObject<IInvite>("InviteMap.gettop1byfilter", filter);
        }

        IList<IInvite> IInviteAccessor.GetList(InviteFilter filter)
        {
            return mapper.QueryForList<IInvite>("InviteMap.getbyfilter", filter);
        }

        IPagers<IInvite> IInviteAccessor.GetPager(InviteFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Helper.GetInt(mapper.QueryForObject("InviteMap.getcount", filter),0);
            Pagers<IInvite> pagers = PagersHelper.InitPager<IInvite>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IInvite>("InviteMap.getbypage", filter);
            return pagers;
        }

        IPagers<IInvite> IInviteAccessor.GetPager2(InviteFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Helper.GetInt(mapper.QueryForObject("InviteMap.getcount2", filter),0);
            Pagers<IInvite> pagers = PagersHelper.InitPager<IInvite>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IInvite>("InviteMap.getbypage2", filter);
            return pagers;
        }

        IInvite IInviteAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IInvite>("InviteMap.getbyid", id);
        }

        IInvite IInviteAccessor.GetByOther_Userid(int id)
        {
            return mapper.QueryForObject<IInvite>("InviteMap.getbyother_userid", id);
        }

        int IInviteAccessor(IInvite invite)
        {
            return mapper.Update("InviteMap.updatepaytime", invite);
        }

        IList<IInvite> IInviteAccessor.GetYaoqingTongji(InviteFilter filter)
        {
            return mapper.QueryForList<IInvite>("InviteMap.GetYaoqingTongji", filter);
        }
        #endregion

        #region IGuidAccessor成员
        int IGuidAccessor.Insert(IGuid guid)
        {
            return Helper.GetInt(mapper.Insert("GuidMap.insert", guid),0);
        }

        int IGuidAccessor.Update(IGuid guid)
        {
            return mapper.Update("GuidMap.update", guid);
        }

        int IGuidAccessor.Delete(int id)
        {
            return mapper.Delete("GuidMap.delete", id);
        }

        IGuid IGuidAccessor.Get(GuidFilter filter)
        {
            return mapper.QueryForObject<IGuid>("GuidMap.gettop1byfilter", filter);
        }

        IList<IGuid> IGuidAccessor.GetList(GuidFilter filter)
        {
            return mapper.QueryForList<IGuid>("GuidMap.getbyfilter", filter);
        }

        IPagers<IGuid> IGuidAccessor.GetPager(GuidFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Helper.GetInt(mapper.QueryForObject("GuidMap.getcount", filter),0);
            Pagers<IGuid> pagers = PagersHelper.InitPager<IGuid>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IGuid>("GuidMap.getbypage", filter);
            return pagers;
        }

        IGuid IGuidAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IGuid>("GuidMap.getbyid", id);
        }
        #endregion

        #region IMenuAccessor成员

        int IMenuAccessor.Insert(IMenu menu)
        {
            return Helper.GetInt(mapper.Insert("MenuMap.insert", menu),0);
        }

        int IMenuAccessor.Update(IMenu menu)
        {
            return mapper.Update("MenuMap.update", menu);
        }

        int IMenuAccessor.Delete(int id)
        {
            return mapper.Delete("MenuMap.delete", id);
        }

        IMenu IMenuAccessor.Get(MenuFilter filter)
        {
            return mapper.QueryForObject<IMenu>("MenuMap.gettop1byfilter", filter);
        }

        IList<IMenu> IMenuAccessor.GetList(MenuFilter filter)
        {
            return mapper.QueryForList<IMenu>("MenuMap.getbyfilter", filter);
        }

        IPagers<IMenu> IMenuAccessor.GetPager(MenuFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Helper.GetInt(mapper.QueryForObject("MenuMap.getcount", filter),0);
            Pagers<IMenu> pagers = PagersHelper.InitPager<IMenu>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IMenu>("MenuMap.getbypage", filter);
            return pagers;
        }
        IMenu IMenuAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IMenu>("MenuMap.getbyid", id);
        }

        int IMenuAccessor.GetCount(MenuFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("MenuMap.getcount", filter),0);
        }

        #endregion

        #region IInventorylogAccessor成员

        int IInventorylogAccessor.Insert(Iinventorylog Inventorylog)
        {
            return Helper.GetInt(mapper.Insert("InventorylogMap.insert", Inventorylog),0);
        }
        int IInventorylogAccessor.Update(Iinventorylog Inventorylog)
        {
            return mapper.Update("InventorylogMap.update", Inventorylog);
        }
        int IInventorylogAccessor.Delete(int id)
        {
            return mapper.Delete("InventorylogMap.delete", id);
        }
        Iinventorylog IInventorylogAccessor.Get(InventorylogFilter filter)
        {
            return mapper.QueryForObject<Iinventorylog>("InventorylogMap.gettop1byfilter", filter);
        }
        IList<Iinventorylog> IInventorylogAccessor.GetList(InventorylogFilter filter)
        {
            return mapper.QueryForList<Iinventorylog>("InventorylogMap.getbyfilter", filter);
        }
        IPagers<Iinventorylog> IInventorylogAccessor.GetPager(InventorylogFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Helper.GetInt(mapper.QueryForObject("InventorylogMap.getcount", filter),0);
            Pagers<Iinventorylog> pagers = PagersHelper.InitPager<Iinventorylog>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<Iinventorylog>("InventorylogMap.getbypage", filter);
            return pagers;
        }
        Iinventorylog IInventorylogAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<Iinventorylog>("InventorylogMap.getbyid", id);
        }
        int IInventorylogAccessor.GetCount(InventorylogFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("InventorylogMap.getcount", filter),0);
        }

        #endregion

        #region ILocationAccessor成员
        int ILocationAccessor.Insert(ILocation Location)
        {
            return Helper.GetInt(mapper.Insert("LocationMap.insert", Location),0);
        }
        int ILocationAccessor.Update(ILocation Location)
        {
            return mapper.Update("LocationMap.update", Location);
        }
        int ILocationAccessor.Delete(int id)
        {
            return mapper.Delete("LocationMap.delete", id);
        }
        ILocation ILocationAccessor.Get(LocationFilter filter)
        {
            return mapper.QueryForObject<ILocation>("LocationMap.gettop1byfilter", filter);
        }
        IList<ILocation> ILocationAccessor.GetList(LocationFilter filter)
        {
            return mapper.QueryForList<ILocation>("LocationMap.getbyfilter", filter);
        }
        IPagers<ILocation> ILocationAccessor.GetPager(LocationFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Helper.GetInt(mapper.QueryForObject("LocationMap.getcount", filter),0);
            Pagers<ILocation> pagers = PagersHelper.InitPager<ILocation>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ILocation>("LocationMap.getbypage", filter);
            return pagers;
        }
        ILocation ILocationAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ILocation>("LocationMap.getbyid", id);
        }
        int ILocationAccessor.GetCount(LocationFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("LocationMap.getcount", filter));
        }

        #endregion

        #region IMailerAccessor 成员
        int IMailerAccessor.Insert(IMailer mailer)
        {
            return Helper.GetInt(mapper.Insert("MailerMap.insert", mailer),0);
        }

        int IMailerAccessor.Update(IMailer mailer)
        {
            return mapper.Update("MailerMap.update", mailer);
        }

        int IMailerAccessor.Delete(int id)
        {
            return mapper.Delete("MailerMap.delete", id);
        }
        IMailer IMailerAccessor.Get(MailerFilter filter)
        {
            return mapper.QueryForObject<IMailer>("MailerMap.gettop1byfilter", filter);
        }

        IList<IMailer> IMailerAccessor.GetList(MailerFilter filter)
        {
            return mapper.QueryForList<IMailer>("MailerMap.getbyfilter", filter);
        }

        IPagers<IMailer> IMailerAccessor.GetPager(MailerFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Helper.GetInt(mapper.QueryForObject("MailerMap.getcount", filter),0);
            Pagers<IMailer> pagers = PagersHelper.InitPager<IMailer>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IMailer>("MailerMap.getbypage", filter);
            return pagers;
        }

        IMailer IMailerAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IMailer>("MailerMap.getbyid", id);
        }

        public int GetCountByCityId(MailerFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("MailerMap.getcount", filter),0);
        }
        #endregion

        #region ImailserviceproviderAccessor成员
        int ImailserviceproviderAccessor.Insert(Imailserviceprovider mailer)
        {
            return Helper.GetInt(mapper.Insert("MailserviceproviderMap.insert", mailer),0);
        }

        int ImailserviceproviderAccessor.Update(Imailserviceprovider mailer)
        {
            return mapper.Update("MailserviceproviderMap.update", mailer);
        }

        int ImailserviceproviderAccessor.Delete(int id)
        {
            return mapper.Delete("MailserviceproviderMap.delete", id);
        }

        Imailserviceprovider ImailserviceproviderAccessor.Get(MailserviceproviderFilter filter)
        {
            return mapper.QueryForObject<Imailserviceprovider>("MailserviceproviderMap.gettop1byfilter", filter);
        }

        IList<Imailserviceprovider> ImailserviceproviderAccessor.GetList(MailserviceproviderFilter filter)
        {
            return mapper.QueryForList<Imailserviceprovider>("MailserviceproviderMap.getbyfilter", filter);
        }

        IPagers<Imailserviceprovider> ImailserviceproviderAccessor.GetPager(MailserviceproviderFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Helper.GetInt(mapper.QueryForObject("MailserviceproviderMap.getcount", filter),0);
            Pagers<Imailserviceprovider> pagers = PagersHelper.InitPager<Imailserviceprovider>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<Imailserviceprovider>("MailserviceproviderMap.getbypage", filter);
            return pagers;
        }

        Imailserviceprovider ImailserviceproviderAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<Imailserviceprovider>("MailserviceproviderMap.getbyid", id);
        }
        int ImailserviceproviderAccessor.GetCount(MailserviceproviderFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("MailserviceproviderMap.getcount", filter),0);
        }
        int ImailserviceproviderAccessor.DeleteWhere(int mailtasks_id)
        {
            return mapper.Delete("MailserviceproviderMap.deleteWhere", mailtasks_id);
        }
        #endregion

        #region IMailserverAccessor成员

        int IMailserverAccessor.Insert(IMailserver Mailserver)
        {
            return Helper.GetInt(mapper.Insert("MailserverMap.insert", Mailserver),0);
        }
        int IMailserverAccessor.Update(IMailserver Mailserver)
        {
            return mapper.Update("MailserverMap.update", Mailserver);
        }
        int IMailserverAccessor.Delete(int id)
        {
            return mapper.Delete("MailserverMap.delete", id);
        }
        IMailserver IMailserverAccessor.Get(MailserverFilter filter)
        {
            return mapper.QueryForObject<IMailserver>("MailserverMap.gettop1byfilter", filter);
        }
        IList<IMailserver> IMailserverAccessor.GetList(MailserverFilter filter)
        {
            return mapper.QueryForList<IMailserver>("MailserverMap.getbyfilter", filter);
        }
        IPagers<IMailserver> IMailserverAccessor.GetPager(MailserverFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Helper.GetInt(mapper.QueryForObject("MailserverMap.getcount", filter),0);
            Pagers<IMailserver> pagers = PagersHelper.InitPager<IMailserver>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IMailserver>("MailserverMap.getbypage", filter);
            return pagers;
        }
        IMailserver IMailserverAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IMailserver>("MailserverMap.getbyid", id);
        }

        #endregion

        #region IMailtasksAccessor成员
        int IMailtasksAccessor.Insert(IMailtasks Mailtasks)
        {
            return Helper.GetInt(mapper.Insert("MailtasksMap.insert", Mailtasks),0);
        }
        int IMailtasksAccessor.Update(IMailtasks Mailtasks)
        {
            return mapper.Update("MailtasksMap.update", Mailtasks);
        }
        int IMailtasksAccessor.Delete(int id)
        {
            return mapper.Delete("MailtasksMap.delete", id);
        }
        IMailtasks IMailtasksAccessor.Get(MailtasksFilter filter)
        {
            return mapper.QueryForObject<IMailtasks>("MailtasksMap.gettop1byfilter", filter);
        }
        IList<IMailtasks> IMailtasksAccessor.GetList(MailtasksFilter filter)
        {
            return mapper.QueryForList<IMailtasks>("MailtasksMap.getbyfilter", filter);
        }
        IPagers<IMailtasks> IMailtasksAccessor.GetPager(MailtasksFilter filter)
        {
            if (!filter.PageSize.HasValue || !filter.CurrentPage.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Helper.GetInt(mapper.QueryForObject("MailtasksMap.getcount", filter),0);
            Pagers<IMailtasks> pagers = PagersHelper.InitPager<IMailtasks>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IMailtasks>("MailtasksMap.getbypage", filter);
            return pagers;
        }
        IMailtasks IMailtasksAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IMailtasks>("MailtasksMap.getbyid", id);
        }
        int IMailtasksAccessor.GetCount(MailtasksFilter filter)
        {
            return Helper.GetInt(mapper.QueryForObject("MailtasksMap.getcount", filter),0);
        }
        int IMailtasksAccessor.GetMaxID()
        {
            return Helper.GetInt(mapper.QueryForObject("MailtasksMap.getmaxid", null),0);
        }
        #endregion

        #endregion

        #region drl
        #region IPcouponAccessor成员
        int IPcouponAccessor.Insert(IPcoupon pcoupon)
        {
            return Convert.ToInt32(mapper.Insert("PcouponMap.insert", pcoupon));
        }

        int IPcouponAccessor.Update(IPcoupon pcoupon)
        {
            return mapper.Update("PcouponMap.update", pcoupon);
        }

        int IPcouponAccessor.Delete(int id)
        {
            return mapper.Delete("PcouponMap.delete", id);
        }

        IPcoupon IPcouponAccessor.Get(PcouponFilter filter)
        {
            return mapper.QueryForObject<IPcoupon>("PcouponMap.gettop1byfilter", filter);
        }

        IList<IPcoupon> IPcouponAccessor.GetList(PcouponFilter filter)
        {
            return mapper.QueryForList<IPcoupon>("PcouponMap.getbyfilter", filter);
        }

        IPagers<IPcoupon> IPcouponAccessor.GetPager(PcouponFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("PcouponMap.getcount", filter));
            Pagers<IPcoupon> pagers = PagersHelper.InitPager<IPcoupon>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IPcoupon>("PcouponMap.getbypage", filter);
            return pagers;
        }

        IPcoupon IPcouponAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IPcoupon>("PcouponMap.getbyid", id);
        }

        int IPcouponAccessor.GetCount(PcouponFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("PcouponMap.getcount", filter));
        }

        int IPcouponAccessor.SelectCount(PcouponFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("PcouponMap.selectcount", filter));
        }
        int IPcouponAccessor.SelById1(PcouponFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("PcouponMap.selbyid1", filter));
        }
        int IPcouponAccessor.SelById2(PcouponFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("PcouponMap.selbyid2", filter));
        }
        int IPcouponAccessor.SelById3(PcouponFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("PcouponMap.selbyid3", filter));
        }
        IPagers<IPcoupon> IPcouponAccessor.GetPager2(PcouponFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("PcouponMap.getcount2", filter));
            Pagers<IPcoupon> pagers = PagersHelper.InitPager<IPcoupon>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IPcoupon>("PcouponMap.getbypage2", filter);
            return pagers;
        }

        IPagers<IPcoupon> IPcouponAccessor.PagerPcoupon(PcouponFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("PcouponMap.countpcoupon", filter));
            Pagers<IPcoupon> pagers = PagersHelper.InitPager<IPcoupon>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IPcoupon>("PcouponMap.pagerpcoupon", filter);
            return pagers;
        }
        #endregion

        #region IProductAccessor成员
        int IProductAccessor.Insert(IProduct product)
        {
            return Convert.ToInt32(mapper.Insert("ProductMap.insert", product));
        }

        int IProductAccessor.Update(IProduct product)
        {
            return mapper.Update("ProductMap.update", product);
        }

        int IProductAccessor.Delete(int id)
        {
            return mapper.Delete("ProductMap.delete", id);
        }

        IProduct IProductAccessor.Get(ProductFilter filter)
        {
            return mapper.QueryForObject<IProduct>("ProductMap.gettop1byfilter", filter);
        }

        IList<IProduct> IProductAccessor.GetList(ProductFilter filter)
        {
            return mapper.QueryForList<IProduct>("ProductMap.getbyfilter", filter);
        }

        IPagers<IProduct> IProductAccessor.GetPager(ProductFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("ProductMap.getcount", filter));
            Pagers<IProduct> pagers = PagersHelper.InitPager<IProduct>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IProduct>("ProductMap.getbypage", filter);
            return pagers;
        }

        IProduct IProductAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IProduct>("ProductMap.getbyid", id);
        }

        int IProductAccessor.GetCount(ProductFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("ProductMap.getcount", filter));
        }
        int IProductAccessor.SelMaxId(ProductFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("ProductMap.selmaxid", filter));
        }

        #endregion

        #region IRefundsAccessor成员
        int IRefundsAccessor.Insert(IRefunds refunds)
        {
            return Convert.ToInt32(mapper.Insert("RefundsMap.insert", refunds));
        }

        int IRefundsAccessor.Update(IRefunds refunds)
        {
            return mapper.Update("RefundsMap.update", refunds);
        }

        int IRefundsAccessor.Delete(int id)
        {
            return mapper.Delete("RefundsMap.delete", id);
        }

        IRefunds IRefundsAccessor.Get(RefundsFilter filter)
        {
            return mapper.QueryForObject<IRefunds>("RefundsMap.gettop1byfilter", filter);
        }

        IList<IRefunds> IRefundsAccessor.GetList(RefundsFilter filter)
        {
            return mapper.QueryForList<IRefunds>("RefundsMap.getbyfilter", filter);
        }

        IPagers<IRefunds> IRefundsAccessor.GetPager(RefundsFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("RefundsMap.getcount", filter));
            Pagers<IRefunds> pagers = PagersHelper.InitPager<IRefunds>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IRefunds>("RefundsMap.getbypage", filter);
            return pagers;
        }

        IRefunds IRefundsAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IRefunds>("RefundsMap.getbyid", id);
        }

        int IRefundsAccessor.GetCount(RefundsFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("RefundsMap.getcount", filter));
        }

        int IRefundsAccessor.SelectByPartid(RefundsFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("RefundsMap.selectbypartid", filter));
        }

        #endregion

        #region IPromotion_rulesAccessor成员
        int IPromotion_rulesAccessor.Insert(IPromotion_rules promotion_rules)
        {
            return Convert.ToInt32(mapper.Insert("Promotion_rulesMap.insert", promotion_rules));
        }

        int IPromotion_rulesAccessor.Update(IPromotion_rules promotion_rules)
        {
            return mapper.Update("Promotion_rulesMap.update", promotion_rules);
        }

        int IPromotion_rulesAccessor.Delete(int id)
        {
            return mapper.Delete("Promotion_rulesMap.delete", id);
        }

        IPromotion_rules IPromotion_rulesAccessor.Get(Promotion_rulesFilter filter)
        {
            return mapper.QueryForObject<IPromotion_rules>("Promotion_rulesMap.gettop1byfilter", filter);
        }

        IList<IPromotion_rules> IPromotion_rulesAccessor.GetList(Promotion_rulesFilter filter)
        {
            return mapper.QueryForList<IPromotion_rules>("Promotion_rulesMap.getbyfilter", filter);
        }

        IPagers<IPromotion_rules> IPromotion_rulesAccessor.GetPager(Promotion_rulesFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("Promotion_rulesMap.getcount", filter));
            Pagers<IPromotion_rules> pagers = PagersHelper.InitPager<IPromotion_rules>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IPromotion_rules>("Promotion_rulesMap.getbypage", filter);
            return pagers;
        }

        IPromotion_rules IPromotion_rulesAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IPromotion_rules>("Promotion_rulesMap.getbyid", id);
        }

        int IPromotion_rulesAccessor.GetCount(Promotion_rulesFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("Promotion_rulesMap.getcount", filter));
        }
        #endregion

        #region IRefunds_detailAccessor成员
        int IRefunds_detailAccessor.Insert(IRefunds_detail refunds_detail)
        {
            return Convert.ToInt32(mapper.Insert("Refunds_detailMap.insert", refunds_detail));
        }

        int IRefunds_detailAccessor.Update(IRefunds_detail refunds_detail)
        {
            return mapper.Update("Refunds_detailMap.update", refunds_detail);
        }

        int IRefunds_detailAccessor.Delete(int id)
        {
            return mapper.Delete("Refunds_detailMap.delete", id);
        }

        IRefunds_detail IRefunds_detailAccessor.Get(Refunds_detailFilter filter)
        {
            return mapper.QueryForObject<IRefunds_detail>("Refunds_detailMap.gettop1byfilter", filter);
        }

        IList<IRefunds_detail> IRefunds_detailAccessor.GetList(Refunds_detailFilter filter)
        {
            return mapper.QueryForList<IRefunds_detail>("Refunds_detailMap.getbyfilter", filter);
        }

        IPagers<IRefunds_detail> IRefunds_detailAccessor.GetPager(Refunds_detailFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("Refunds_detailMap.getcount", filter));
            Pagers<IRefunds_detail> pagers = PagersHelper.InitPager<IRefunds_detail>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IRefunds_detail>("Refunds_detailMap.getbypage", filter);
            return pagers;
        }

        IRefunds_detail IRefunds_detailAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IRefunds_detail>("Refunds_detailMap.getbyid", id);
        }

        int IRefunds_detailAccessor.GetCount(Refunds_detailFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("Refunds_detailMap.getcount", filter));
        }
        #endregion

        #region IRoleAccessor成员
        int IRoleAccessor.Insert(IRole role)
        {
            return Convert.ToInt32(mapper.Insert("RoleMap.insert", role));
        }

        int IRoleAccessor.Update(IRole role)
        {
            return mapper.Update("RoleMap.update", role);
        }

        int IRoleAccessor.Delete(int id)
        {
            return mapper.Delete("RoleMap.delete", id);
        }

        IRole IRoleAccessor.Get(RoleFilter filter)
        {
            return mapper.QueryForObject<IRole>("RoleMap.gettop1byfilter", filter);
        }

        IList<IRole> IRoleAccessor.GetList(RoleFilter filter)
        {
            return mapper.QueryForList<IRole>("RoleMap.getbyfilter", filter);
        }

        IPagers<IRole> IRoleAccessor.GetPager(RoleFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("RoleMap.getcount", filter));
            Pagers<IRole> pagers = PagersHelper.InitPager<IRole>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IRole>("RoleMap.getbypage", filter);
            return pagers;
        }

        IRole IRoleAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IRole>("RoleMap.getbyid", id);
        }

        int IRoleAccessor.GetCount(RoleFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("RoleMap.getcount", filter));
        }
        IList<Hashtable> IRoleAccessor.SelectByCode(string code)
        {
            return mapper.QueryForList<Hashtable>("RoleMap.selectbycode", code);
        }
        int IRoleAccessor.DelByCode(string code)
        {
            return mapper.Delete("RoleMap.delbycode", code);
        }
        IRole IRoleAccessor.SelectId(string code)
        {
            return mapper.QueryForObject<IRole>("RoleMap.selectid", code);
        }
        IRole IRoleAccessor.SelectCode(int id)
        {
            return mapper.QueryForObject<IRole>("RoleMap.selectcode", id);
        }
        #endregion

        #region ISales_promotionAccessor成员
        int ISales_promotionAccessor.Insert(ISales_promotion sales_promotion)
        {
            return Convert.ToInt32(mapper.Insert("Sales_promotionMap.insert", sales_promotion));
        }

        int ISales_promotionAccessor.Update(ISales_promotion sales_promotion)
        {
            return mapper.Update("Sales_promotionMap.update", sales_promotion);
        }

        int ISales_promotionAccessor.Delete(int id)
        {
            return mapper.Delete("Sales_promotionMap.delete", id);
        }

        ISales_promotion ISales_promotionAccessor.Get(Sales_promotionFilter filter)
        {
            return mapper.QueryForObject<ISales_promotion>("Sales_promotionMap.gettop1byfilter", filter);
        }

        IList<ISales_promotion> ISales_promotionAccessor.GetList(Sales_promotionFilter filter)
        {
            return mapper.QueryForList<ISales_promotion>("Sales_promotionMap.getbyfilter", filter);
        }

        IPagers<ISales_promotion> ISales_promotionAccessor.GetPager(Sales_promotionFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("Sales_promotionMap.getcount", filter));
            Pagers<ISales_promotion> pagers = PagersHelper.InitPager<ISales_promotion>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ISales_promotion>("Sales_promotionMap.getbypage", filter);
            return pagers;
        }

        ISales_promotion ISales_promotionAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ISales_promotion>("Sales_promotionMap.getbyid", id);
        }

        int ISales_promotionAccessor.GetCount(Sales_promotionFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("Sales_promotionMap.getcount", filter));
        }
        #endregion

        #region IScorelogAccessor成员
        int IScorelogAccessor.Insert(IScorelog scorelog)
        {
            return Convert.ToInt32(mapper.Insert("ScorelogMap.insert", scorelog));
        }

        int IScorelogAccessor.Update(IScorelog scorelog)
        {
            return mapper.Update("ScorelogMap.update", scorelog);
        }

        int IScorelogAccessor.Delete(int id)
        {
            return mapper.Delete("ScorelogMap.delete", id);
        }

        IScorelog IScorelogAccessor.Get(ScorelogFilter filter)
        {
            return mapper.QueryForObject<IScorelog>("ScorelogMap.gettop1byfilter", filter);
        }

        IList<IScorelog> IScorelogAccessor.GetList(ScorelogFilter filter)
        {
            return mapper.QueryForList<IScorelog>("ScorelogMap.getbyfilter", filter);
        }

        IPagers<IScorelog> IScorelogAccessor.GetPager(ScorelogFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("ScorelogMap.getcount", filter));
            Pagers<IScorelog> pagers = PagersHelper.InitPager<IScorelog>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IScorelog>("ScorelogMap.getbypage", filter);
            return pagers;
        }

        IScorelog IScorelogAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IScorelog>("ScorelogMap.getbyid", id);
        }

        int IScorelogAccessor.GetCount(ScorelogFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("ScorelogMap.getcount", filter));
        }
        #endregion

        #region ISmssubscribeAccessor成员
        int ISmssubscribeAccessor.Insert(ISmssubscribe smssubscribe)
        {
            return Convert.ToInt32(mapper.Insert("SmssubscribeMap.insert", smssubscribe));
        }

        int ISmssubscribeAccessor.Update(ISmssubscribe smssubscribe)
        {
            return mapper.Update("SmssubscribeMap.update", smssubscribe);
        }

        int ISmssubscribeAccessor.UpdateEnable(ISmssubscribe smssubscribe)
        {
            return mapper.Update("SmssubscribeMap.updateEnable", smssubscribe);
        }

        int ISmssubscribeAccessor.UpdateSecret(ISmssubscribe smssubscribe)
        {
            return mapper.Update("SmssubscribeMap.updateSecret", smssubscribe);
        }

        int ISmssubscribeAccessor.Delete(int id)
        {
            return mapper.Delete("SmssubscribeMap.delete", id);
        }

        ISmssubscribe ISmssubscribeAccessor.Get(SmssubscribeFilter filter)
        {
            return mapper.QueryForObject<ISmssubscribe>("SmssubscribeMap.gettop1byfilter", filter);
        }

        IList<ISmssubscribe> ISmssubscribeAccessor.GetList(SmssubscribeFilter filter)
        {
            return mapper.QueryForList<ISmssubscribe>("SmssubscribeMap.getbyfilter", filter);
        }

        IPagers<ISmssubscribe> ISmssubscribeAccessor.GetPager(SmssubscribeFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("SmssubscribeMap.getcount", filter));
            Pagers<ISmssubscribe> pagers = PagersHelper.InitPager<ISmssubscribe>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ISmssubscribe>("SmssubscribeMap.getbypage", filter);
            return pagers;
        }

        ISmssubscribe ISmssubscribeAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ISmssubscribe>("SmssubscribeMap.getbyid", id);
        }

        int ISmssubscribeAccessor.GetCount(SmssubscribeFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("SmssubscribeMap.getcount", filter));
        }

        int ISmssubscribeAccessor.deleteBymobile(SmssubscribeFilter filter)
        {
            return   mapper.Delete("SmssubscribeMap.deleteBymobile", filter);
        }

        #endregion



        #endregion

        #region  Author  By  lzmj

        #region IUserReivewAccessor 成员
        int IUserReivewAccessor.Insert(IUserReview userReview)
        {
            return Convert.ToInt32(mapper.Insert("UserReviewMap.insert", userReview));
        }

        int IUserReivewAccessor.Update(IUserReview userReview)
        {
            return mapper.Update("UserReviewMap.update", userReview);
        }

        int IUserReivewAccessor.Delete(int id)
        {
            return mapper.Delete("UserReviewMap.delete", id);
        }

        IUserReview IUserReivewAccessor.Get(UserReviewFilter filter)
        {
            return mapper.QueryForObject<IUserReview>("UserReviewMap.gettop1byfilter", filter);
        }

        IList<IUserReview> IUserReivewAccessor.GetList(UserReviewFilter filter)
        {
            return mapper.QueryForList<IUserReview>("UserReviewMap.getbyfilter", filter);
        }

        IPagers<IUserReview> IUserReivewAccessor.GetPager(UserReviewFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("UserReviewMap.getcount", filter));
            Pagers<IUserReview> pagers = PagersHelper.InitPager<IUserReview>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IUserReview>("UserReviewMap.getbypage", filter);
            return pagers;
        }
        IPagers<IUserReview> IUserReivewAccessor.GetPager2(UserReviewFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("UserReviewMap.getcount2", filter));
            Pagers<IUserReview> pagers = PagersHelper.InitPager<IUserReview>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IUserReview>("UserReviewMap.getbypage2", filter);
            return pagers;
        }

        IUserReview IUserReivewAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IUserReview>("UserReviewMap.getbyid", id);
        }

        IList<IUserReview> IUserReivewAccessor.GetByContent(UserReviewFilter filter)
        {
            return mapper.QueryForList<IUserReview>("UserReviewMap.getbycontent", filter);
        }

        int IUserReivewAccessor.GetTop1Id(UserReviewFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("UserReviewMap.gettop1id", filter));
        }

        IPagers<IUserReview> IUserReivewAccessor.GetPager3(UserReviewFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("UserReviewMap.getcount3", filter));
            Pagers<IUserReview> pagers = PagersHelper.InitPager<IUserReview>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IUserReview>("UserReviewMap.getbypage3", filter);
            return pagers;
        }

        #endregion

        #region IUserlevelrelusAccessor 成员
        int IUserlevelrelusAccessor.Insert(IUserlevelrules userlevelrules)
        {
            return Convert.ToInt32(mapper.Insert("UserlevelrulesMap.insert", userlevelrules));
        }

        int IUserlevelrelusAccessor.Update(IUserlevelrules userlevelrules)
        {
            return mapper.Update("UserlevelrulesMap.update", userlevelrules);
        }

        int IUserlevelrelusAccessor.Delete(int id)
        {
            return mapper.Delete("UserlevelrulesMap.delete", id);
        }

        IUserlevelrules IUserlevelrelusAccessor.Get(UserlevelrulesFilters filter)
        {
            return mapper.QueryForObject<IUserlevelrules>("UserlevelrulesMap.gettop1byfilter", filter);
        }

        IList<IUserlevelrules> IUserlevelrelusAccessor.GetList(UserlevelrulesFilters filter)
        {
            return mapper.QueryForList<IUserlevelrules>("UserlevelrulesMap.getbyfilter", filter);
        }
        IPagers<IUserlevelrules> IUserlevelrelusAccessor.GetPager(UserlevelrulesFilters filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("UserlevelrulesMap.getcount", filter));
            Pagers<IUserlevelrules> pagers = PagersHelper.InitPager<IUserlevelrules>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IUserlevelrules>("UserlevelrulesMap.getbypage", filter);
            return pagers;
        }

        IUserlevelrules IUserlevelrelusAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IUserlevelrules>("UserlevelrulesMap.getbyid", id);
        }
        int IUserlevelrelusAccessor.DelByLevelid(int levelid)
        {
            return mapper.Delete("UserlevelrulesMap.delbylevelid", levelid);
        }
        IList<IUserlevelrules> IUserlevelrelusAccessor.GetdataByMinmoney(UserlevelrulesFilters filter)
        {
            return mapper.QueryForList<IUserlevelrules>("UserlevelrulesMap.getdatabyminmoney", filter);
        }
        #endregion

        #region IVote_FeedbackAccessor 成员
        int IVote_FeedbackAccessor.Insert(IVote_Feedback vote_Feedback)
        {
            return Convert.ToInt32(mapper.Insert("Vote_FeedbackMap.insert", vote_Feedback));
        }

        int IVote_FeedbackAccessor.Update(IVote_Feedback vote_Feedback)
        {
            return mapper.Update("Vote_FeedbackMap.update", vote_Feedback);
        }

        int IVote_FeedbackAccessor.Delete(int Id)
        {
            return mapper.Delete("Vote_FeedbackMap.delete", Id);
        }

        IVote_Feedback IVote_FeedbackAccessor.Get(Vote_FeedbackFilters filter)
        {
            return mapper.QueryForObject<IVote_Feedback>("Vote_FeedbackMap.gettop1byfilter", filter);
        }

        IList<IVote_Feedback> IVote_FeedbackAccessor.GetList(Vote_FeedbackFilters filter)
        {
            return mapper.QueryForList<IVote_Feedback>("Vote_FeedbackMap.getbyfilter", filter);
        }

        IPagers<IVote_Feedback> IVote_FeedbackAccessor.GetPager(Vote_FeedbackFilters filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("Vote_FeedbackMap.getcount", filter));
            Pagers<IVote_Feedback> pagers = PagersHelper.InitPager<IVote_Feedback>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IVote_Feedback>("Vote_FeedbackMap.getbypage", filter);
            return pagers;
        }

        IVote_Feedback IVote_FeedbackAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IVote_Feedback>("Vote_FeedbackMap.getbyid", id);
        }


        #endregion

        #region IVote_OptionsAccessor 成员
        int IVote_OptionsAccessor.Insert(IVote_Options vote_Options)
        {
            return Convert.ToInt32(mapper.Insert("Vote_OptionsMap.insert", vote_Options));
        }

        int IVote_OptionsAccessor.Update(IVote_Options vote_options)
        {
            return mapper.Update("Vote_OptionsMap.update", vote_options);
        }

        int IVote_OptionsAccessor.Delete(int Id)
        {
            return mapper.Delete("Vote_OptionsMap.delete", Id);
        }

        IVote_Options IVote_OptionsAccessor.Get(Vote_OptionsFilters filter)
        {
            return mapper.QueryForObject<IVote_Options>("Vote_OptionsMap.gettop1byfilter", filter);
        }

        IList<IVote_Options> IVote_OptionsAccessor.GetList(Vote_OptionsFilters filter)
        {
            return mapper.QueryForList<IVote_Options>("Vote_OptionsMap.getbyfilter", filter);
        }

        IPagers<IVote_Options> IVote_OptionsAccessor.GetPager(Vote_OptionsFilters filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("Vote_OptionsMap.getcount", filter));
            Pagers<IVote_Options> pagers = PagersHelper.InitPager<IVote_Options>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IVote_Options>("Vote_OptionsMap.getbypage", filter);
            return pagers;
        }

        IVote_Options IVote_OptionsAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IVote_Options>("Vote_OptionsMap.getbyid", id);
        }



        #endregion

        #region IVote_QuestionAccessor 成员
        int IVote_QuestionAccessor.Insert(IVote_Question vote_Question)
        {
            return Convert.ToInt32(mapper.Insert("Vote_QuestionMap.insert", vote_Question));
        }

        int IVote_QuestionAccessor.Update(IVote_Question vote_Question)
        {
            return mapper.Update("Vote_QuestionMap.update", vote_Question);
        }

        int IVote_QuestionAccessor.Delete(int Id)
        {
            return mapper.Delete("Vote_QuestionMap.delete", Id);
        }

        IVote_Question IVote_QuestionAccessor.Get(Vote_QuestionFilters filter)
        {
            return mapper.QueryForObject<IVote_Question>("Vote_QuestionMap.gettop1byfilter", filter);
        }

        IList<IVote_Question> IVote_QuestionAccessor.GetList(Vote_QuestionFilters filter)
        {
            return mapper.QueryForList<IVote_Question>("Vote_QuestionMap.getbyfilter", filter);
        }

        IPagers<IVote_Question> IVote_QuestionAccessor.GetPager(Vote_QuestionFilters filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("Vote_QuestionMap.getcount", filter));
            Pagers<IVote_Question> pagers = PagersHelper.InitPager<IVote_Question>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IVote_Question>("Vote_QuestionMap.getbypage", filter);
            return pagers;
        }

        IVote_Question IVote_QuestionAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IVote_Question>("Vote_QuestionMap.getbyid", id);
        }


        #endregion

        #region IVote_Feedback_InputAccessor 成员

        int IVote_Feedback_InputAccessor.Insert(IVote_Feedback_Input vote_feedback_input)
        {
            return Convert.ToInt32(mapper.Insert("Vote_Feedback_InputMap.insert", vote_feedback_input));
        }

        int IVote_Feedback_InputAccessor.Update(IVote_Feedback_Input vote_feedback_input)
        {
            return mapper.Update("Vote_Feedback_InputMap.update", vote_feedback_input);
        }

        int IVote_Feedback_InputAccessor.Delete(int Id)
        {
            return mapper.Delete("Vote_Feedback_InputMap.delete", Id);
        }

        IVote_Feedback_Input IVote_Feedback_InputAccessor.Get(Vote_Feedback_InputFilters filter)
        {
            return mapper.QueryForObject<IVote_Feedback_Input>("Vote_Feedback_InputMap.gettop1byfilter", filter);
        }

        IList<IVote_Feedback_Input> IVote_Feedback_InputAccessor.GetList(Vote_Feedback_InputFilters filter)
        {
            return mapper.QueryForList<IVote_Feedback_Input>("Vote_Feedback_InputMap.getbyfilter", filter);
        }

        IPagers<IVote_Feedback_Input> IVote_Feedback_InputAccessor.GetPager(Vote_Feedback_InputFilters filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("Vote_Feedback_InputMap.getcount", filter));
            Pagers<IVote_Feedback_Input> pagers = PagersHelper.InitPager<IVote_Feedback_Input>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IVote_Feedback_Input>("Vote_Feedback_InputMap.getbypage", filter);
            return pagers;
        }

        IVote_Feedback_Input IVote_Feedback_InputAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IVote_Feedback_Input>("Vote_Feedback_InputMap.getbyid", id);
        }


        #endregion

        #region IVote_Feedback_QuestionAccessor 成员

        int IVote_Feedback_QuestionAccessor.Insert(IVote_Feedback_Question vote_Feedback_Question)
        {
            return Convert.ToInt32(mapper.Insert("Vote_Feedback_QuestionMap.insert", vote_Feedback_Question));
        }

        int IVote_Feedback_QuestionAccessor.Update(IVote_Feedback_Question vote_Feedback_Question)
        {
            return mapper.Update("Vote_Feedback_QuestionMap.update", vote_Feedback_Question);
        }

        int IVote_Feedback_QuestionAccessor.Delete(int id)
        {
            return mapper.Delete("Vote_Feedback_QuestionMap.delete", id);
        }

        IVote_Feedback_Question IVote_Feedback_QuestionAccessor.Get(Vote_Feedback_QuestionFilters filter)
        {
            return mapper.QueryForObject<IVote_Feedback_Question>("Vote_Feedback_QuestionMap.gettop1byfilter", filter);
        }

        IList<IVote_Feedback_Question> IVote_Feedback_QuestionAccessor.GetList(Vote_Feedback_QuestionFilters filter)
        {
            return mapper.QueryForList<IVote_Feedback_Question>("Vote_Feedback_QuestionMap.getbyfilter", filter);
        }

        IPagers<IVote_Feedback_Question> IVote_Feedback_QuestionAccessor.GetPager(Vote_Feedback_QuestionFilters filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("Vote_Feedback_QuestionMap.getcount", filter));
            Pagers<IVote_Feedback_Question> pagers = PagersHelper.InitPager<IVote_Feedback_Question>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IVote_Feedback_Question>("Vote_Feedback_QuestionMap.getbypage", filter);
            return pagers;
        }

        IVote_Feedback_Question IVote_Feedback_QuestionAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IVote_Feedback_Question>("Vote_Feedback_QuestionMap.getbyid", id);
        }


        #endregion

        #region IYizhantongAccessor 成员
        int IYizhantongAccessor.Insert(IYizhantong yizhantong)
        {
            return Convert.ToInt32(mapper.Insert("YizhantongMap.insert", yizhantong));
        }
        
        int IYizhantongAccessor.InsertYZT(IYizhantong yizhantong)
        {
            return Convert.ToInt32(mapper.Insert("YizhantongMap.insertyzt", yizhantong));
        }

        int IYizhantongAccessor.Update(IYizhantong yizhantong)
        {
            return mapper.Update("YizhantongMap.update", yizhantong);
        }

        int IYizhantongAccessor.Delete(int Id)
        {
            return mapper.Delete("YizhantongMap.delete", Id);
        }

        IYizhantong IYizhantongAccessor.Get(YizhantongFilters filter)
        {
            return mapper.QueryForObject<IYizhantong>("YizhantongMap.gettop1byfilter", filter);
        }

        IList<IYizhantong> IYizhantongAccessor.GetList(YizhantongFilters filter)
        {
            return mapper.QueryForList<IYizhantong>("YizhantongMap.getbyfilter", filter);
        }

        IPagers<IYizhantong> IYizhantongAccessor.GetPager(YizhantongFilters filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("YizhantongMap.getcount", filter));
            Pagers<IYizhantong> pagers = PagersHelper.InitPager<IYizhantong>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IYizhantong>("YizhantongMap.getbypage", filter);
            return pagers;
        }

        IYizhantong IYizhantongAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IYizhantong>("YizhantongMap.getbyid", id);
        }


        #endregion

        #endregion

        #region zjq

        #region IAdjunctAccessor成员
        int IAdjunctAccessor.Insert(IAdjunct Adjunct)
        {
            return Convert.ToInt32(mapper.Insert("AdjunctMap.insert", Adjunct));
        }

        int IAdjunctAccessor.Update(IAdjunct Adjunct)
        {
            return mapper.Update("AdjunctMap.update", Adjunct);
        }

        int IAdjunctAccessor.Delete(int id)
        {
            return mapper.Delete("AdjunctMap.delete", id);
        }

        IAdjunct IAdjunctAccessor.Get(AdjunctFilter filter)
        {
            return mapper.QueryForObject<IAdjunct>("AdjunctMap.gettop1byfilter", filter);
        }

        IList<IAdjunct> IAdjunctAccessor.GetList(AdjunctFilter filter)
        {
            return mapper.QueryForList<IAdjunct>("AdjunctMap.getbyfilter", filter);
        }

        IPagers<IAdjunct> IAdjunctAccessor.GetPager(AdjunctFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("AdjunctMap.getcount", filter));
            Pagers<IAdjunct> pagers = PagersHelper.InitPager<IAdjunct>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IAdjunct>("AdjunctMap.getbypage", filter);
            return pagers;
        }

        IAdjunct IAdjunctAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IAdjunct>("AdjunctMap.getbyid", id);
        }
        #endregion

        #region IAreaAccessor 成员
        int IAreaAccessor.Insert(IArea Area)
        {
            return Convert.ToInt32(mapper.Insert("AreaMap.insert", Area));
        }

        int IAreaAccessor.Update(IArea Area)
        {
            return mapper.Update("AreaMap.update", Area);
        }

        int IAreaAccessor.Delete(int id)
        {
            return mapper.Delete("AreaMap.delete", id);
        }

        IArea IAreaAccessor.Get(AreaFilter filter)
        {
            return mapper.QueryForObject<IArea>("AreaMap.gettop1byfilter", filter);
        }

        IList<IArea> IAreaAccessor.GetList(AreaFilter filter)
        {
            return mapper.QueryForList<IArea>("AreaMap.getbyfilter", filter);
        }

        IPagers<IArea> IAreaAccessor.GetPager(AreaFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("AreaMap.getcount", filter));
            Pagers<IArea> pagers = PagersHelper.InitPager<IArea>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IArea>("AreaMap.getbypage", filter);
            return pagers;
        }

        IArea IAreaAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IArea>("AreaMap.getbyid", id);
        }
        #endregion

        #region  IAuthorAccessor 成员
        int IAuthorAccessor.Insert(IAuthor Author)
        {
            return Convert.ToInt32(mapper.Insert("AuthorMap.insert", Author));
        }

        int IAuthorAccessor.Update(IAuthor Author)
        {
            return mapper.Update("AuthorMap.update", Author);
        }

        int IAuthorAccessor.Delete(int id)
        {
            return mapper.Delete("AuthorMap.delete", id);
        }

        IAuthor IAuthorAccessor.Get(AuthorFilter filter)
        {
            return mapper.QueryForObject<IAuthor>("AuthorMap.gettop1byfilter", filter);
        }

        IList<IAuthor> IAuthorAccessor.GetList(AuthorFilter filter)
        {
            return mapper.QueryForList<IAuthor>("AuthorMap.getbyfilter", filter);
        }

        IPagers<IAuthor> IAuthorAccessor.GetPager(AuthorFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("AuthorMap.getcount", filter));
            Pagers<IAuthor> pagers = PagersHelper.InitPager<IAuthor>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IAuthor>("AuthorMap.getbypage", filter);
            return pagers;
        }

        IAuthor IAuthorAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IAuthor>("AuthorMap.getbyid", id);
        }
        #endregion

        #region  IBranchAccessor 成员
        int IBranchAccessor.Insert(IBranch Branch)
        {
            return Convert.ToInt32(mapper.Insert("BranchMap.insert", Branch));
        }

        int IBranchAccessor.Update(IBranch Branch)
        {
            return mapper.Update("BranchMap.update", Branch);
        }

        int IBranchAccessor.Delete(int id)
        {
            return mapper.Delete("BranchMap.delete", id);
        }

        IBranch IBranchAccessor.Get(BranchFilter filter)
        {
            return mapper.QueryForObject<IBranch>("BranchMap.gettop1byfilter", filter);
        }

        IList<IBranch> IBranchAccessor.GetList(BranchFilter filter)
        {
            return mapper.QueryForList<IBranch>("BranchMap.getbyfilter", filter);
        }

        IPagers<IBranch> IBranchAccessor.GetPager(BranchFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("BranchMap.getcount", filter));
            Pagers<IBranch> pagers = PagersHelper.InitPager<IBranch>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IBranch>("BranchMap.getbypage", filter);
            return pagers;
        }

        IBranch IBranchAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IBranch>("BranchMap.getbyid", id);
        }
        int IBranchAccessor.GetCount(BranchFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("BranchMap.getcount", filter));
        }
        IPagers<IBranch> IBranchAccessor.Page(BranchFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("BranchMap.count", filter));
            Pagers<IBranch> pagers = PagersHelper.InitPager<IBranch>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IBranch>("BranchMap.page", filter);
            return pagers;
        }
        int IBranchAccessor.Count(BranchFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("BranchMap.count", filter));
        }
        #endregion

        #region  ICategoryAccessor 成员
        int ICategoryAccessor.Insert(ICategory Category)
        {
            return Convert.ToInt32(mapper.Insert("CategoryMap.insert", Category));
        }

        int ICategoryAccessor.Update(ICategory Category)
        {
            return mapper.Update("CategoryMap.update", Category);
        }

        int ICategoryAccessor.Delete(int id)
        {
            return mapper.Delete("CategoryMap.delete", id);
        }

        ICategory ICategoryAccessor.Get(CategoryFilter filter)
        {
            return mapper.QueryForObject<ICategory>("CategoryMap.gettop1byfilter", filter);
        }

        IList<ICategory> ICategoryAccessor.GetList(CategoryFilter filter)
        {
            return mapper.QueryForList<ICategory>("CategoryMap.getbyfilter", filter);
        }

        IList<ICategory> ICategoryAccessor.GetletterList(CategoryFilter filter)
        {
            return mapper.QueryForList<ICategory>("CategoryMap.getletterbyfilter", filter);
        }

        IPagers<ICategory> ICategoryAccessor.GetPager(CategoryFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("CategoryMap.getcount", filter));
            Pagers<ICategory> pagers = PagersHelper.InitPager<ICategory>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ICategory>("CategoryMap.getbypage", filter);
            return pagers;
        }


        ICategory ICategoryAccessor.GetByID(int id)
        {

            return mapper.QueryForObject<ICategory>("CategoryMap.getbyid", id);
        }

        IList<ICategory> ICategoryAccessor.GetByExpress(CategoryFilter filter)
        {
            return mapper.QueryForList<ICategory>("CategoryMap.getbyexpress", filter);
        }

        IList<ICategory> ICategoryAccessor.GetByCashExpress(CategoryFilter filter)
        {
            return mapper.QueryForList<ICategory>("CategoryMap.getbycashexpress", filter);
        }


        bool ICategoryAccessor.getCount1(int id)
        {
            if (mapper.QueryForObject<ICategory>("CategoryMap.getbyid", id) != null)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        IList<ICategory> ICategoryAccessor.SelsectByzd(CategoryFilter filter)
        {
            return mapper.QueryForList<ICategory>("CategoryMap.selsectbyzd", filter);
        }

        int ICategoryAccessor.UpByCzone(ICategory Category)
        {
            return mapper.Update("CategoryMap.upbyczone", Category);
        }

        ICategory ICategoryAccessor.SelectById(int id)
        {

            return mapper.QueryForObject<ICategory>("CategoryMap.selectbyid", id);
        }

        int ICategoryAccessor.exts_proc_del_api(int id)
        {
            return Convert.ToInt32(mapper.QueryForObject("CategoryMap.exts_proc_del_api", id));
        }
        #endregion


        #endregion

        #region  耿丹

        #region ISalesAccessor成员

        int ISalesAccessor.Insert(ISales sales)
        {
            return Convert.ToInt32(mapper.Insert("SalesMap.insert", sales));
        }

        int ISalesAccessor.Update(ISales sales)
        {
            return mapper.Update("SalesMap.update", sales);
        }

        int ISalesAccessor.Delete(int id)
        {
            return mapper.Delete("SalesMap.delete", id);
        }

        ISales ISalesAccessor.Get(SalesFilter filter)
        {
            return mapper.QueryForObject<ISales>("SalesMap.gettop1byfilter", filter);
        }

        IList<ISales> ISalesAccessor.GetList(SalesFilter filter)
        {
            return mapper.QueryForList<ISales>("SalesMap.getbyfilter", filter);
        }

        IPagers<ISales> ISalesAccessor.GetPager(SalesFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("SalesMap.getcount", filter));
            Pagers<ISales> pagers = PagersHelper.InitPager<ISales>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ISales>("SalesMap.getbypage", filter);
            return pagers;
        }

        ISales ISalesAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ISales>("SalesMap.getbyid", id);
        }
        #endregion

        #region IExpressnocitysAccessor成员

        int IExpressnocitysAccessor.Insert(IExpressnocitys expressnocitys)
        {
            return Convert.ToInt32(mapper.Insert("ExpressnocitysMap.insert", expressnocitys));
        }

        int IExpressnocitysAccessor.Update(IExpressnocitys expressnocitys)
        {
            return mapper.Update("ExpressnocitysMap.update", expressnocitys);
        }

        int IExpressnocitysAccessor.Delete(int id)
        {
            return mapper.Delete("ExpressnocitysMap.delete", id);
        }

        IExpressnocitys IExpressnocitysAccessor.Get(ExpressnocitysFilter filter)
        {
            return mapper.QueryForObject<IExpressnocitys>("ExpressnocitysMap.gettop1byfilter", filter);
        }

        IList<IExpressnocitys> IExpressnocitysAccessor.GetList(ExpressnocitysFilter filter)
        {
            return mapper.QueryForList<IExpressnocitys>("ExpressnocitysMap.getbyfilter", filter);
        }

        IPagers<IExpressnocitys> IExpressnocitysAccessor.GetPager(ExpressnocitysFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("ExpressnocitysMap.getcount", filter));
            Pagers<IExpressnocitys> pagers = PagersHelper.InitPager<IExpressnocitys>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IExpressnocitys>("ExpressnocitysMap.getbypage", filter);
            return pagers;
        }

        IExpressnocitys IExpressnocitysAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IExpressnocitys>("ExpressnocitysMap.getbyid", id);
        }

        int IExpressnocitysAccessor.UpdateNocitys(IExpressnocitys expressnocitys)
        {
            return mapper.Update("ExpressnocitysMap.updatenocitys", expressnocitys);
        }
        #endregion

        #region IDrawAccessor成员

        int IDrawAccessor.Insert(IDraw draw)
        {
            return Convert.ToInt32(mapper.Insert("DrawMap.insert", draw));
        }

        int IDrawAccessor.Update(IDraw draw)
        {
            return mapper.Update("DrawMap.update", draw);
        }

        int IDrawAccessor.Delete(int id)
        {
            return mapper.Delete("DrawMap.delete", id);
        }

        IDraw IDrawAccessor.Get(DrawFilter filter)
        {
            return mapper.QueryForObject<IDraw>("DrawMap.gettop1byfilter", filter);
        }

        IList<IDraw> IDrawAccessor.GetList(DrawFilter filter)
        {
            return mapper.QueryForList<IDraw>("DrawMap.getbyfilter", filter);
        }

        IPagers<IDraw> IDrawAccessor.GetPager(DrawFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("DrawMap.getcount", filter));
            Pagers<IDraw> pagers = PagersHelper.InitPager<IDraw>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IDraw>("DrawMap.getbypage", filter);
            return pagers;
        }
        IPagers<IDraw> IDrawAccessor.GetSumPager(DrawFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("DrawMap.getcount", filter));
            Pagers<IDraw> pagers = PagersHelper.InitPager<IDraw>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IDraw>("DrawMap.sumgetbypage", filter);
            return pagers;
        }
        IDraw IDrawAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IDraw>("DrawMap.getbyid", id);
        }
        int IDrawAccessor.GetCount(DrawFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("DrawMap.getcount", filter));
        }
        int IDrawAccessor.GetChou(DrawFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("DrawMap.getchou", filter));
        }
        IPagers<IDraw> IDrawAccessor.GetPageChou(DrawFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("DrawMap.getchou", filter));
            Pagers<IDraw> pagers = PagersHelper.InitPager<IDraw>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IDraw>("DrawMap.getpagechou", filter);
            return pagers;
        }
        #endregion

        #region IFeedbackAccessor成员
        int IFeedbackAccessor.Insert(IFeedback feedback)
        {
            return Convert.ToInt32(mapper.Insert("FeedbackMap.insert", feedback));
        }

        int IFeedbackAccessor.Update(IFeedback feedback)
        {
            return mapper.Update("FeedbackMap.update", feedback);
        }

        int IFeedbackAccessor.Delete(int id)
        {
            return mapper.Delete("FeedbackMap.delete", id);
        }

        IFeedback IFeedbackAccessor.Get(FeedbackFilter filter)
        {
            return mapper.QueryForObject<IFeedback>("FeedbackMap.gettop1byfilter", filter);
        }

        IList<IFeedback> IFeedbackAccessor.GetList(FeedbackFilter filter)
        {
            return mapper.QueryForList<IFeedback>("FeedbackMap.getbyfilter", filter);
        }

        IPagers<IFeedback> IFeedbackAccessor.GetPager(FeedbackFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("FeedbackMap.getcount", filter));
            Pagers<IFeedback> pagers = PagersHelper.InitPager<IFeedback>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IFeedback>("FeedbackMap.getbypage", filter);
            return pagers;
        }

        IFeedback IFeedbackAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IFeedback>("FeedbackMap.getbyid", id);
        }
        #endregion

        #region ICpsAccessor成员
        int ICpsAccessor.Insert(ICps cps)
        {
            return Convert.ToInt32(mapper.Insert("CpsMap.insert", cps));
        }

        int ICpsAccessor.Update(ICps cps)
        {
            return mapper.Update("CpsMap.update", cps);
        }

        int ICpsAccessor.Delete(int id)
        {
            return mapper.Delete("CpsMap.delete", id);
        }

        ICps ICpsAccessor.Get(CpsFilter filter)
        {
            return mapper.QueryForObject<ICps>("CpsMap.gettop1byfilter", filter);
        }

        IList<ICps> ICpsAccessor.GetList(CpsFilter filter)
        {
            return mapper.QueryForList<ICps>("CpsMap.getbyfilter", filter);
        }

        IPagers<ICps> ICpsAccessor.GetPager(CpsFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("CpsMap.getcount", filter));
            Pagers<ICps> pagers = PagersHelper.InitPager<ICps>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ICps>("CpsMap.getbypage", filter);
            return pagers;
        }

        ICps ICpsAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<ICps>("CpsMap.getbyid", id);
        }

        int ICpsAccessor.GetCount(CpsFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("CpsMap.getcount", filter));
        }
        #endregion

        #region IFareTemplateAccessor成员

        int IFareTemplateAccessor.Insert(IFareTemplate faretemplate)
        {
            return Convert.ToInt32(mapper.Insert("FareTemplateMap.insert", faretemplate));
        }

        int IFareTemplateAccessor.Update(IFareTemplate faretemplate)
        {
            return mapper.Update("FareTemplateMap.update", faretemplate);
        }

        int IFareTemplateAccessor.Delete(int id)
        {
            return mapper.Delete("FareTemplateMap.delete", id);
        }

        IFareTemplate IFareTemplateAccessor.Get(FareTemplateFilter filter)
        {
            return mapper.QueryForObject<IFareTemplate>("FareTemplateMap.gettop1byfilter", filter);
        }

        IList<IFareTemplate> IFareTemplateAccessor.GetList(FareTemplateFilter filter)
        {
            return mapper.QueryForList<IFareTemplate>("FareTemplateMap.getbyfilter", filter);
        }

        IPagers<IFareTemplate> IFareTemplateAccessor.GetPager(FareTemplateFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("FareTemplateMap.getcount", filter));
            Pagers<IFareTemplate> pagers = PagersHelper.InitPager<IFareTemplate>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IFareTemplate>("FareTemplateMap.getbypage", filter);
            return pagers;
        }

        IFareTemplate IFareTemplateAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IFareTemplate>("FareTemplateMap.getbyid", id);
        }

        int IFareTemplateAccessor.GetCount(FareTemplateFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("FareTemplateMap.getcount", filter));
        }
        #endregion

        #region IExpresspriceAccessor成员

        int IExpresspriceAccessor.Insert(IExpressprice iexpressprice)
        {
            return Convert.ToInt32(mapper.Insert("ExpresspriceMap.insert", iexpressprice));
        }

        int IExpresspriceAccessor.Update(IExpressprice iexpressprice)
        {
            return mapper.Update("ExpresspriceMap.update", iexpressprice);
        }

        int IExpresspriceAccessor.Delete(int id)
        {
            return mapper.Delete("ExpresspriceMap.delete", id);
        }

        IExpressprice IExpresspriceAccessor.Get(ExpresspriceFilter filter)
        {
            return mapper.QueryForObject<IExpressprice>("ExpresspriceMap.gettop1byfilter", filter);
        }

        IList<IExpressprice> IExpresspriceAccessor.GetList(ExpresspriceFilter filter)
        {
            return mapper.QueryForList<IExpressprice>("ExpresspriceMap.getbyfilter", filter);
        }

        IPagers<IExpressprice> IExpresspriceAccessor.GetPager(ExpresspriceFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("ExpresspriceMap.getcount", filter));
            Pagers<IExpressprice> pagers = PagersHelper.InitPager<IExpressprice>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IExpressprice>("ExpresspriceMap.getbypage", filter);
            return pagers;
        }

        IExpressprice IExpresspriceAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IExpressprice>("ExpresspriceMap.getbyid", id);
        }

        IExpressprice IExpresspriceAccessor.GetByExpressID(int expressid)
        {
            return mapper.QueryForObject<IExpressprice>("ExpresspriceMap.getbyexpressid", expressid);
        }

        #endregion

        #region IFarecitysAccessor成员

        int IFarecitysAccessor.Insert(IFarecitys farecitys)
        {
            return Convert.ToInt32(mapper.Insert("FarecitysMap.insert", farecitys));
        }

        int IFarecitysAccessor.Update(IFarecitys farecitys)
        {
            return mapper.Update("FarecitysMap.update", farecitys);
        }

        int IFarecitysAccessor.Delete(int id)
        {
            return mapper.Delete("FarecitysMap.delete", id);
        }

        IFarecitys IFarecitysAccessor.Get(FarecitysFilter filter)
        {
            return mapper.QueryForObject<IFarecitys>("FarecitysMap.gettop1byfilter", filter);
        }

        IList<IFarecitys> IFarecitysAccessor.GetList(FarecitysFilter filter)
        {
            return mapper.QueryForList<IFarecitys>("FarecitysMap.getbyfilter", filter);
        }

        IPagers<IFarecitys> IFarecitysAccessor.GetPager(FarecitysFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("FarecitysMap.getcount", filter));
            Pagers<IFarecitys> pagers = PagersHelper.InitPager<IFarecitys>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IFarecitys>("FarecitysMap.getbypage", filter);
            return pagers;
        }

        IFarecitys IFarecitysAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IFarecitys>("FarecitysMap.getbyid", id);
        }

        IList<Hashtable> IFarecitysAccessor.GetByPid(FarecitysFilter filter)
        {
            return mapper.QueryForList<Hashtable>("FarecitysMap.getbypid", filter);
        }

        #endregion

        #region IFlowAccessor成员
        int IFlowAccessor.Insert(IFlow flow)
        {
            return Convert.ToInt32(mapper.Insert("FlowMap.insert", flow));
        }

        int IFlowAccessor.Update(IFlow flow)
        {
            return mapper.Update("FlowMap.update", flow);
        }

        int IFlowAccessor.Delete(int id)
        {
            return mapper.Delete("FlowMap.delete", id);
        }
        int IFlowAccessor.GetCount(FlowFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("FlowMap.getcount", filter));
        }

        IFlow IFlowAccessor.Get(FlowFilter filter)
        {
            return mapper.QueryForObject<IFlow>("FlowMap.gettop1byfilter", filter);
        }

        IList<IFlow> IFlowAccessor.GetList(FlowFilter filter)
        {
            return mapper.QueryForList<IFlow>("FlowMap.getbyfilter", filter);
        }

        IPagers<IFlow> IFlowAccessor.GetPager(FlowFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("FlowMap.getcount", filter));
            Pagers<IFlow> pagers = PagersHelper.InitPager<IFlow>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IFlow>("FlowMap.getbypage", filter);
            return pagers;
        }

        IFlow IFlowAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IFlow>("FlowMap.getbyid", id);
        }
        #endregion

        #region IFriendLinkAccessor成员
        int IFriendLinkAccessor.Insert(IFriendLink friendLink)
        {
            return Convert.ToInt32(mapper.Insert("FriendLinkMap.insert", friendLink));
        }

        int IFriendLinkAccessor.Update(IFriendLink friendLink)
        {
            return mapper.Update("FriendLinkMap.update", friendLink);
        }

        int IFriendLinkAccessor.Delete(int id)
        {
            return mapper.Delete("FriendLinkMap.delete", id);
        }

        IFriendLink IFriendLinkAccessor.Get(FriendLinkFilter filter)
        {
            return mapper.QueryForObject<IFriendLink>("FriendLinkMap.gettop1byfilter", filter);
        }

        IList<IFriendLink> IFriendLinkAccessor.GetList(FriendLinkFilter filter)
        {
            return mapper.QueryForList<IFriendLink>("FriendLinkMap.getbyfilter", filter);
        }

        IPagers<IFriendLink> IFriendLinkAccessor.GetPager(FriendLinkFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("FriendLinkMap.getcount", filter));
            Pagers<IFriendLink> pagers = PagersHelper.InitPager<IFriendLink>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IFriendLink>("FriendLinkMap.getbypage", filter);
            return pagers;
        }

        IFriendLink IFriendLinkAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IFriendLink>("FriendLinkMap.getbyid", id);
        }
        #endregion

        #endregion


        #region IAuthorityAccessor 成员
        int IAuthorityAccessor.Insert(IAuthority Authority)
        {
            return Convert.ToInt32(mapper.Insert("AuthorityMap.insert", Authority));
        }


        int IAuthorityAccessor.Delete(int ID)
        {
            return mapper.Delete("AuthorityMap.delete", ID);
        }

        IList<IAuthority> IAuthorityAccessor.GetList(AuthorityFilter filter)
        {
            return mapper.QueryForList<IAuthority>("AuthorityMap.getbyfilter", filter);
        }


        IAuthority IAuthorityAccessor.GetByID(int ID)
        {
            return mapper.QueryForObject<IAuthority>("AuthorityMap.getbyid", ID);
        }

        int IAuthorityAccessor.GetCount(AuthorityFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("AuthorityMap.getcount", filter));
        }

        #endregion


        #region IRoleAuthorityAccessor 成员

        int IRoleAuthorityAccessor.Insert(IRoleAuthority RoleAuthority)
        {
            return Convert.ToInt32(mapper.Insert("RoleAuthorityMap.insert", RoleAuthority));
        }

        int IRoleAuthorityAccessor.Update(IRoleAuthority RoleAuthority)
        {
            return mapper.Update("RoleAuthorityMap.update", RoleAuthority);
        }

        int IRoleAuthorityAccessor.Delete(int id)
        {
            return mapper.Delete("RoleAuthorityMap.delete", id);
        }

        int IRoleAuthorityAccessor.DelByRoleID(int id)
        {
            return mapper.Delete("RoleAuthorityMap.delbyroleid", id);
        }

        IRoleAuthority IRoleAuthorityAccessor.Get(RoleAuthorityFilter filter)
        {
            return mapper.QueryForObject<IRoleAuthority>("RoleAuthorityMap.gettop1byfilter", filter);
        }

        IList<IRoleAuthority> IRoleAuthorityAccessor.GetList(RoleAuthorityFilter filter)
        {
            return mapper.QueryForList<IRoleAuthority>("RoleAuthorityMap.getbyfilter", filter);
        }

        IPagers<IRoleAuthority> IRoleAuthorityAccessor.GetPager(RoleAuthorityFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("MenuRelationMap.getcount", filter));
            Pagers<IRoleAuthority> pagers = PagersHelper.InitPager<IRoleAuthority>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IRoleAuthority>("MenuRelationMap.getbypage", filter);
            return pagers;
        }

        IRoleAuthority IRoleAuthorityAccessor.GetByID(int id)
        {
            return mapper.QueryForObject<IRoleAuthority>("RoleAuthorityMap.getbyid", id);
        }

        #endregion


        #region IGetDataAccessor 成员

        public List<Hashtable> GetDataList(string sql)
        {
            return (List<Hashtable>)mapper.QueryForList<Hashtable>("GetDataMap.selectsql", sql);
        }

        #endregion

        #region IOprationLogAccessor 成员
        int IOprationLogAccessor.Insert(IOprationLog oprationlog)
        {
            return Convert.ToInt32(mapper.Insert("OprationLogMap.insert", oprationlog));
        }

        int IOprationLogAccessor.Update(IOprationLog oprationlog)
        {
            return mapper.Update("OprationLogMap.update", oprationlog);
        }

        int IOprationLogAccessor.Delete(int id)
        {
            return mapper.Delete("OprationLogMap.delete", id);
        }

        IOprationLog IOprationLogAccessor.Get(OprationLogFilter filter)
        {
            return mapper.QueryForObject<IOprationLog>("OprationLogMap.gettop1byfilter", filter);
        }

        IList<IOprationLog> IOprationLogAccessor.GetList(OprationLogFilter filter)
        {
            return mapper.QueryForList<IOprationLog>("OprationLogMap.getbyfilter", filter);
        }

        IPagers<IOprationLog> IOprationLogAccessor.GetPager(OprationLogFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("OprationLogMap.getcount", filter));
            Pagers<IOprationLog> pagers = PagersHelper.InitPager<IOprationLog>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<IOprationLog>("OprationLogMap.getbypage", filter);
            return pagers;
        }

        #endregion


        #region ISmsLogAccessor 成员

        int ISmsLogAccessor.Insert(ISmsLog SmsLog)
        {
            return Convert.ToInt32(mapper.Insert("SmsLogMap.insert", SmsLog));
        }

        int ISmsLogAccessor.Update(ISmsLog SmsLog)
        {
            return mapper.Update("SmsLogMap.update", SmsLog);
        }

        int ISmsLogAccessor.Delete(int id)
        {
            return mapper.Delete("SmsLogMap.delete", id);
        }

        ISmsLog ISmsLogAccessor.Get(SmsLogFilter filter)
        {
            return mapper.QueryForObject<ISmsLog>("SmsLogMap.gettop1byfilter", filter);
        }

        IList<ISmsLog> ISmsLogAccessor.GetList(SmsLogFilter filter)
        {
            return mapper.QueryForList<ISmsLog>("SmsLogMap.getbyfilter", filter);
        }

        IPagers<ISmsLog> ISmsLogAccessor.GetPager(SmsLogFilter filter)
        {
            if (!filter.CurrentPage.HasValue || !filter.PageSize.HasValue || filter.SortOrderString.Length == 0)
                throw new Exception("参数不完整");
            int TotalRecords = Convert.ToInt32(mapper.QueryForObject("SmsLogMap.getcount", filter));
            Pagers<ISmsLog> pagers = PagersHelper.InitPager<ISmsLog>(filter, TotalRecords);
            pagers.Objects = mapper.QueryForList<ISmsLog>("SmsLogMap.getbypage", filter);
            return pagers;
        }


        int ISmsLogAccessor.GetCount(SmsLogFilter filter)
        {
            return Convert.ToInt32(mapper.QueryForObject("SmsLogMap.getcount", filter));
        }

        ISmsLog ISmsLogAccessor.GetByName(string name)
        {
            return mapper.QueryForObject<ISmsLog>("SmsLogMap.getbyname", name);
        }
        #endregion




    }
}