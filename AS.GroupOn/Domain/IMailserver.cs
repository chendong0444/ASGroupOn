using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public interface IMailserver:IObj
    {
        #region 邮件服务商列表接口
        int id { get; set; }
        /// <summary>
        /// SMTP主机
        /// </summary>
        string smtphost { get; set; }
        /// <summary>
        /// SMTP端口
        /// </summary>
        int smtpport { get; set; }
        /// <summary>
        /// SSL方式 0代表不启用ssl,1代表启用ssl
        /// </summary>
        int ssl { get; set; }
        /// <summary>
        /// 用户名 
        /// </summary>
        string mailuser { get; set; }
        /// <summary>
        /// 用户别名
        /// </summary>
        string realname { get; set; }
        /// <summary>
        /// 密码
        /// </summary>
        string mailpass { get; set; }
        /// <summary>
        /// 发信地址
        /// </summary>
        string sendmail { get; set; }
        /// <summary>
        /// 回信地址
        /// </summary>
        string receivemail { get; set; }
        /// <summary>
        /// 一次最多发送数量
        /// </summary>
        int sendcount { get; set; }
        #endregion
    }
}
