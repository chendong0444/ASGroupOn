using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess;
using AS.GroupOn.App;

namespace AS.GroupOn.Domain.Spi
{
    public class User : Obj, IUser
    {
        /// <summary>
        /// 用户ID
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 用户邮箱
        /// </summary>
        public virtual string Email { get; set; }
        /// <summary>
        /// 用户名
        /// </summary>
        public virtual string Username { get; set; }
        /// <summary>
        /// 真实姓名
        /// </summary>
        public virtual string Realname { get; set; }
        /// <summary>
        /// 密码
        /// </summary>
        public virtual string Password { get; set; }
        private string _avatar = "/upfile/img/user-no-avatar.gif";
        /// <summary>
        /// 头像路径
        /// </summary>
        public virtual string Avatar
        {
            get
            {
                return _avatar;
            }
            set
            {
                _avatar = value;
            }
        }
        /// <summary>
        /// 性别 (男或女)
        /// </summary>
        public virtual string Gender { get; set; }

        public virtual string Newbie { get; set; }
        /// <summary>
        /// 手机号
        /// </summary>
        public virtual string Mobile { get; set; }
        /// <summary>
        /// QQ号
        /// </summary>
        public virtual string Qq { get; set; }

        /// <summary>
        /// MSN
        /// </summary>
        public virtual string msn { get; set; }
        /// <summary>
        /// 账户余额
        /// </summary>
        public virtual decimal Money { get; set; }
        /// <summary>
        /// 用户积分
        /// </summary>
        public virtual int Score { get; set; }
        /// <summary>
        /// 邮编
        /// </summary>
        public virtual string Zipcode { get; set; }
        /// <summary>
        /// 地址
        /// </summary>
        public virtual string Address { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        public virtual int City_id { get; set; }
        /// <summary>
        /// 激活状态
        /// </summary>
        public virtual string Enable { get; set; }
        /// <summary>
        /// 管理状态
        /// </summary>
        public virtual string Manager { get; set; }
        /// <summary>
        /// 是否是管理员分站管理员
        /// </summary>
        public virtual string IsManBranch { get; set; }
        /// <summary>
        /// 邮件验证码
        /// </summary>
        public virtual string Secret { get; set; }
        /// <summary>
        /// 激活码
        /// </summary>
        public virtual string Recode { get; set; }

        public virtual string Sns { get; set; }

        /// <summary>
        /// 注册IP
        /// </summary>
        public virtual string IP { get; set; }
        /// <summary>
        /// 登陆时间
        /// </summary>
        public virtual DateTime? Login_time { get; set; }
        /// <summary>
        /// 注册时间
        /// </summary>
        public virtual DateTime Create_time { get; set; }

        /// <summary>
        /// 权限
        /// </summary>
        public virtual string auth { get; set; }
        /// <summary>
        /// 注册来源地址
        /// </summary>
        public virtual string IP_Address { get; set; }
        /// <summary>
        /// 注册来源域名
        /// </summary>
        public virtual string fromdomain { get; set; }
        /// <summary>
        /// 用户积分
        /// </summary>
        public virtual int userscore { get; set; }
        /// <summary>
        /// 总消费金额
        /// </summary>
        public virtual decimal totalamount { get; set; }
        /// <summary>
        /// 是否uc同步
        /// </summary>
        public virtual string ucsyc { get; set; }

        /// <summary>
        /// 一站通
        /// </summary>
        public virtual string yizhantong { get; set; }
        /// <summary>
        /// 用户绑定的手机号码，此手机号一担绑定不可更改
        /// </summary>
        public virtual string Signmobile { get; set; }

        /// <summary>
        /// 每日签到的签到时间
        /// </summary>
        public virtual DateTime? Sign_time { get; set; }

        /// <summary>
        /// 找不到，返回一个默认的实例化的用户,防止发生null异常
        /// </summary>
        /// <returns></returns>
        public static IUser GetDefault()
        {
            User user = new User();
            user.Username = "????";
            user.Id = 0;
            return user;
        }


        //返回城市
        public ICategory cityname = null;
        public virtual ICategory Category
        {
            get
            {
                using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                {
                    cityname = session.Category.GetByID(this.City_id);
                }

                return cityname;
            }
        }

        /// <summary>
        /// 用户等级 
        /// </summary>
        private ICategory levename = null;
        public int levelid = 0;
        public virtual ICategory LeveName
        {
            get
            {
                IUserlevelrules Userlevelrules = null;
                UserlevelrulesFilters uf = new UserlevelrulesFilters();

                uf.totalamount = this.totalamount;

                ////1根据用户累计消金额到UserRule得到用户等级id
                using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                {
                    Userlevelrules = session.Userlevelrelus.Get(uf);

                }
                //得到Category表的ID
                if (Userlevelrules != null)
                {
                    levelid = Userlevelrules.levelid;
                }

                CategoryFilter cf = new CategoryFilter();
                cf.Id = levelid;
                //2：根据上面的 等级id得到用户等级ICategory对象，并返回既可
                using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                {

                    levename = session.Category.Get(cf);
                }
                return levename;
            }
        }

        //购买次数
        private int buynum = 0;
        public virtual int BuyNum
        {
            get
            {
                OrderFilter filter = new OrderFilter();
                filter.User_id = this.Id;
                filter.State = "pay";  //条件为已支付
                using (IDataSession session = App.Store.OpenSession(false))
                {
                    buynum = session.Orders.GetCount(filter);
                }
                return buynum;
            }
        }
        /// <summary>
        /// 消费总额
        /// </summary>
        private decimal count = 0;
        public virtual decimal GetTotalamount
        {
            get
            {
                OrderFilter filter = new OrderFilter();
                filter.State = "pay";
                filter.User_id = this.Id;
                using (IDataSession session = App.Store.OpenSession(false))
                {
                    count = session.Orders.GetSum(filter);
                }
                return count;
            }
        }


        private List<IRole> role = null;
        public virtual IList<IRole> Role
        {
            get
            {
                role = new List<IRole>();
                if (this.auth == null || this.auth == "")
                {
                    return role;
                }
                RoleFilter rf = new RoleFilter();
                string[] auths = this.auth.Replace("{","").Replace("}",",").Split(',');
                //string auths = this.auth.Replace("{", "").Replace("}", "");
                 IRole _role=new Role();
                for(int i=0;i<auths.Length;i++)
                {
                    if (auths[i] != null && auths[i]!="")
                    {
                        rf.code = auths[i];
                        using (IDataSession session = App.Store.OpenSession(false))
                        {
                          _role = session.Role.Get(rf);
                          if (_role != null)
                          {
                              role.Add(_role);
                          }
                        }
                    }
                   
                }
               
                return role;
            }
        }

        private IDraw draw = null;

        public virtual IDraw Draw
        {

            get
            {
                DrawFilter df = new DrawFilter();
                df.userid = this.Id;
                using (IDataSession session = App.Store.OpenSession(false))
                {
                    draw = session.Draw.Get(df);
                }
                return draw;
            }
        }

    }
}
