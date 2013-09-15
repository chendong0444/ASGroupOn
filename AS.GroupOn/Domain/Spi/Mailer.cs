using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   zhenglijun
    /// </summary>
    public class Mailer:Obj,IMailer
    {
        #region 邮件订阅表
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 邮件地址
        /// </summary>
       public virtual string Email { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
       public virtual int City_id { get; set; }
        /// <summary>
        /// 退订验证码
        /// </summary>
       public virtual string Secret { get; set; }
        /// <summary>
        /// 记录已发送邮件任务id名
        /// </summary>
       public virtual string sendmailids { get; set; }
        /// <summary>
        /// 记录当前邮件地址订阅邮件的总阅读数
        /// </summary>
       public virtual int readcount { get; set; }
       /// <summary>
       /// 记录邮箱的后缀名
       /// </summary>
       public virtual string provider { get; set; }
        #endregion

       protected ICategory cityname = null;
       public virtual ICategory GetCityName 
       {
           get 
           {
               using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
               {
                   cityname = session.Category.GetByID(int.Parse(this.City_id.ToString()));
               }
               return cityname;
           }
       }

    }
}
