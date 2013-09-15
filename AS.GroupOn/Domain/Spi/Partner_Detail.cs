using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.Domain.Spi
{
    public class Partner_Detail : Obj, IPartner_Detail
    {
        /// <summary>
        /// 主键
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 商家ID
        /// </summary>
        public virtual int partnerid { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        public virtual DateTime createtime { get; set; }
        /// <summary>
        /// 管理员ID
        /// </summary>
        public virtual int adminid { get; set; }
        /// <summary>
        /// 结算金额
        /// </summary>
        public virtual decimal money { get; set; }
        /// <summary>
        /// 备注
        /// </summary>
        public virtual string remark { get; set; }
        /// <summary>
        /// 结算申请备注
        /// </summary>
        public virtual string settlementremark { get; set; }
        /// <summary>
        /// 结算状态--8代表已结算。1代表待审核. 2代表被拒绝 ,4代表正在结算
        /// </summary>
        public virtual int settlementstate { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        public virtual int team_id { get; set; }
        /// <summary>
        /// 数量
        /// </summary>
        public virtual int num { get; set; }

        private string AdminName = String.Empty;
        UserFilter  filter = new UserFilter();
        IUser user = new User();
        public virtual string GetAdminName 
        {
            get 
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                {
                    user = session.Users.GetByID(this.adminid);
                }
                if (user != null)
                {
                    AdminName = user.Username;
                }
                else 
                {
                    AdminName = "";
                }
                return AdminName;
            }
         }
    }
}
