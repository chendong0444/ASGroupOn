using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public class Mailserviceprovider : Obj, Imailserviceprovider
    {
        #region 邮件服务商域名列表
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 邮件任务ID
        /// </summary>
        public virtual int mailtasks_id { get; set; }
        /// <summary>
        /// 域名服务商邮件域名 
        /// </summary>
        public virtual string serviceprovider { get; set; }
        #endregion

    }
}
