using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Spi;
using AS.GroupOn.Domain;
using AS.GroupOn.Domain.Spi;
namespace AS.GroupOn.App
{
    public class Store
    {
        public static IDataSession OpenSession(bool istransaction)
        {
            return new DataSession(istransaction);
        }
        #region zjq
        public static IAdjunct CreateAdjunct()
        {
            return new Adjunct();
        }
        public static IArea CreateArea()
        {
            return new Area();
        }
        #endregion

        public static IAuthor CreateAuthor()
        {
            return new Author();
        }
        public static IUser CreateUser()
        {
            return new User();
        }
        public static ITeam CreateTeam()
        {
            return new Team();
        }

        public static IOrder CreateOrder()
        {
            return new Order();
        }

        public static IOrderDetail CreateOrderDetail()
        {
            return new OrderDetail();
        }

        public static ICoupon CreateCoupon()
        {
            return new Coupon();
        }

        public static IPay CreatePay()
        {
            return new Pay();
        }
        public static IFlow CreateFlow()
        {
            return new Flow();
        }


        public static IAsk CreateAsk()
        {
            return new Ask();
        }

        public static ICps CreateCps()
        {
            return new Cps();
        }


        public static IMenuRelation CreateMenuRelation()
        {
            return new MenuRelation();
        }

        public static INews CreateNews()
        {
            return new News();
        }

        public static IPacket CreatePacket()
        {
            return new Packet();
        }

        public static IPartner_Detail CreatePartner_Detail()
        {
            return new Partner_Detail();
        }
        #region 郑立军
        public static IGuid CreateGuid()
        {
            return new AS.GroupOn.Domain.Spi.Guid();
        }
        public static Iinventorylog CreateInventorylog()
        {
            return new Inventorylog();
        }
        public static ILocation CreateLocation()
        {
            return new Location();
        }
        public static IInvite CreateInvite()
        {
            return new Invite();
        }
        public static Imailserviceprovider CreateMailserviceprovider()
        {
            return new Mailserviceprovider();
        }
        public static IMailserver CreateMailserver()
        {
            return new Mailserver();
        }
        public static IMailtasks CreateMailtasks()
        {
            return new Mailtasks();
        }
        public static IMailer CreateMailer()
        {
            return new Mailer();
        }
        public static IMenu CreateMenu()
        {
            return new Menu();
        }

        #endregion
        public static IExpressnocitys CreateExpressnocitys()
        {
            return new Expressnocitys();
        }

        public static IExpressprice CreateExpresspric()
        {
            return new Expressprice();
        }

        public static IDraw CreateDraw()
        {
            return new Draw();
        }

        public static IFarecitys CreateFarecitys()
        {
            return new Farecitys();
        }

        public static IFareTemplate CreateFareTemplate()
        {
            return new FareTemplate();
        }

        public static IFeedback CreateFeedback()
        {
            return new Feedback();
        }

        public static IFriendLink CreateFriendLink()
        {
            return new FriendLink();
        }

        public static ISmssubscribedetail CreateSmssubscribedetail()
        {
            return new Smssubscribedetail();
        }

        public static ISmstemplate CreateSmstemplate()
        {
            return new Smstemplate();
        }

        public static ISmsLog CreateSmsLog()
        {
            return new SmsLog();
        }


        public static ISubscribe CreateSubscribe()
        {
            return new Subscribe();
        }

        public static ITemplate_print CreateTemplate_print()
        {
            return new Template_print();
        }

        public static ITopic CreateTopic()
        {
            return new Topic();
        }

        public static ISystem CreateSystem()
        {
            return new Systems();
        }

        public static IPage CreatePage()
        {
            return new Page();
        }
        public static ICatalogs CreateCatalogs()
        {
            return new Catalogs();
        }
        public static IPartner CreatePartner()
        {
            return new Partner();
        }

        #region Author By  lzmj

        public static IUserReview CreateUserReview()
        {
            return new UserReview();
        }
        public static IUserlevelrules CreateUserlevelrules()
        {
            return new Userlevelrules();
        }

        public static IVote_Feedback CreateVote_Feedback()
        {
            return new Vote_Feedback();
        }

        public static IVote_Feedback_Input CreateVote_Feedback_Input()
        {
            return new Vote_Feedback_Input();
        }
        public static IVote_Feedback_Question CreateVote_Feedback_Question()
        {
            return new Vote_Feedback_Question();
        }
        public static IVote_Options CreateVote_Options()
        {
            return new Vote_Options();
        }
        public static IVote_Question CreateVote_Question()
        {
            return new Vote_Question();
        }
        public static IYizhantong CreateYizhantong()
        {
            return new Yizhantong();
        }
        #endregion

        #region drl
        public static IPcoupon CreatePcoupon()
        {
            return new Pcoupon();
        }
        public static IProduct CreateProduct()
        {
            return new Product();
        }
        public static IPromotion_rules CreatePromotion_rules()
        {
            return new Promotion_rules();
        }
        public static IRefunds CreateRefunds()
        {
            return new Refunds();
        }
        public static IRefunds_detail CreateRefunds_detail()
        {
            return new Refunds_detail();
        }
        public static IRole CreateRole()
        {
            return new Role();
        }
        public static ISales_promotion CreateSales_promotion()
        {
            return new Sales_promotion();
        }
        public static IScorelog CreateScorelog()
        {
            return new Scorelog();
        }
        public static ISmssubscribe CreateSmssubscribe()
        {
            return new Smssubscribe();
        }


        #endregion

        public static ISales CreateSales()
        {
            return new Sales();
        }

        public static IUser CreateUserAdmin()
        {
            return new User();
        }

        public static ICard CreateCard()
        {
            return new Card();
        }
        public static ICategory CreateCategory()
        {
            return new Category();
        }
        public static IAuthority CreateAuthority()
        {
            return new Authority();
        }
        public static IRoleAuthority CreateRoleAuthority()
        {
            return new RoleAuthority();
        }
        public static IOprationLog CreateOprationLog()
        {
            return new OprationLog();
        }
        public static IBranch CreateBranch()
        {
            return new Branch();
        }
    }
}
