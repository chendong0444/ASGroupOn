using System;
using System.Collections.Generic;
using AS.GroupOn.DataAccess.Accessor;

namespace AS.GroupOn.DataAccess
{
    public interface IDataSession : IDisposable
    {
        IUserAccessor Users { get; }

        IPartnerAccessor Partners { get; }

        ITeamAccessor Teams { get; }

        IOrderAccessor Orders { get; }

        IOrderDetailAccessor OrderDetail { get; }

        ICityAccessor Citys { get; }

        ICustomAccessor Custom { get; }

     

        IBrandAccessor Brand { get; }

        IAskAccessor Ask { get; }

        IPageAccessor Page { get; }

        IFriendLinkAccessor FriendLink { get; }

        ICouponAccessor Coupon { get; }

        ICardAccessor Card { get; }

        IFlowAccessor Flow { get; }

        ISystemAccessor System { get; }

        ICatalogsAccessor Catalogs { get; }

        IPayAccessor Pay { get; }

        IFareTemplateAccessor FareTemplate { get; }

        ICpsAccessor Cps { get; }

        IDrawAccessor Draw { get; }

        IExpressnocitysAccessor Expressnocitys { get; }

        IExpresspriceAccessor Expressprice { get; }

        IFarecitysAccessor Farecitys { get; }

        IFeedbackAccessor Feedback { get; }

        IMenuRelationAccessor MenuRelation { get; }

        INewsAccessor News { get; }

        IPacketAccessor Packet { get; }

        IPartner_DetailAccessor Partner_Detail { get; }


        ISmssubscribedetailAccessor Smssubscribedetail { get; }

        ISmstemplateAccessor Smstemplate { get; }

        ISmsLogAccessor SmsLog { get; }

        ITemplate_printAccessor Template_print { get; }

        ITopicAccessor Topic { get; }

        ISubscribeAccessor Subscribe { get; }

        #region 郑立军
        IGuidAccessor Guid { get; }

        IMenuAccessor Menu {get; }

        IInventorylogAccessor Inventorylog{get; }

        ILocationAccessor Location{get; }

        IMailerAccessor Mailers{ get; }

        ImailserviceproviderAccessor Mailserviceprovider{get ; }

        IMailserverAccessor Mailserver{get; }
       
        IMailtasksAccessor Mailtasks{get; }

        IInviteAccessor Invite{get ; }

        #endregion

        #region drl
        IPcouponAccessor Pcoupon { get; }

        IProductAccessor Product { get; }

        IRefundsAccessor Refunds { get; }

        IPromotion_rulesAccessor Promotion_rules { get; }

        IRefunds_detailAccessor Refunds_detail { get; }

        IRoleAccessor Role { get; }

        ISales_promotionAccessor Sales_promotion { get; }

        IScorelogAccessor Scorelog { get; }

        ISmssubscribeAccessor Smssubscribe { get; }

        #endregion

        #region Author By lzmj
        IUserReivewAccessor UserReview { get; }

        IUserlevelrelusAccessor Userlevelrelus { get; }

        IVote_FeedbackAccessor Vote_Feedback { get; }

        IVote_Feedback_InputAccessor Vote_Feedback_Input { get; }

        IVote_Feedback_QuestionAccessor Vote_Feedback_Question { get; }

        IVote_OptionsAccessor Vote_Options { get; }

        IVote_QuestionAccessor Vote_Question { get; }

        IYizhantongAccessor Yizhantong { get; }

        
        #endregion
       
        #region  zjq

        IAdjunctAccessor Adjunct { get; }

        IAreaAccessor Area { get; }

        IAuthorAccessor Author { get; }

        IBranchAccessor Branch { get; }

        ICategoryAccessor Category { get; }

        #endregion

        ISalesAccessor Sales { get; }

        IRoleAuthorityAccessor RoleAuthority { get; }
        IAuthorityAccessor Authority { get; }

        IGetDataAccessor GetData { get; }

        IOprationLogAccessor OprationLog { get; }

        void Commit();

    }
}
