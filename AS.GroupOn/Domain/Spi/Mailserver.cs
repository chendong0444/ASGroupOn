using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public class Mailserver:Obj,IMailserver
    {

        #region 邮件服务商列表
        /// <summary>
        /// Id号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// SMTP主机
        /// </summary>
        public virtual string smtphost { get; set; }
        /// <summary>
        /// SMTP端口
        /// </summary>
        public virtual int smtpport { get; set; }
        /// <summary>
        /// SSL方式 0代表不启用ssl,1代表启用ssl
        /// </summary>
        public virtual int ssl { get; set; }
        /// <summary>
        /// 用户名 
        /// </summary>
        public virtual string mailuser { get; set; }
        /// <summary>
        /// 用户别名
        /// </summary>
        public virtual string realname { get; set; }
        /// <summary>
        /// 密码
        /// </summary>
        public virtual string mailpass { get; set; }
        /// <summary>
        /// 发信地址
        /// </summary>
        public virtual string sendmail { get; set; }
        /// <summary>
        /// 回信地址
        /// </summary>
        public virtual string receivemail { get; set; }
        /// <summary>
        /// 一次最多发送数量
        /// </summary>
        public virtual int sendcount { get; set; }
        #endregion
    }
}
