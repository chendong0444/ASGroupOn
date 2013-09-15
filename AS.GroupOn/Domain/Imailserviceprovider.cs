using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建时间 2012-10-25
    /// 创建人   郑立军
    /// </summary>
    public interface Imailserviceprovider:IObj
    {
        #region 邮件服务商域名列表接口
        /// <summary>
        /// ID号
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 邮件任务ID
        /// </summary>
        int mailtasks_id { get; set; }
        /// <summary>
        /// 域名服务商邮件域名 
        /// </summary>
        string serviceprovider { get; set; }
        #endregion
    }
}
