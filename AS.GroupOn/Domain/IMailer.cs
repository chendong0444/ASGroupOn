using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   zlj
    /// </summary>
   public interface IMailer:IObj
   {
       #region 邮件订阅表接口成员
       /// <summary>
       /// ID号
       /// </summary>
       int Id { get; set; }
       /// <summary>
       /// 邮件地址
       /// </summary>
       string Email { get; set; }
       /// <summary>
       /// 城市ID
       /// </summary>
       int City_id { get; set; }
       /// <summary>
       /// 退订验证码
       /// </summary>
       string Secret { get; set; }
       /// <summary>
       /// 记录已发送邮件任务id名
       /// </summary>
       string sendmailids { get; set; }
       /// <summary>
       /// 记录当前邮件地址订阅邮件的总阅读数
       /// </summary>
       int readcount { get; set; }
       /// <summary>
       /// 记录邮箱后缀名
       /// </summary>
       string provider { get; set; }
       /// <summary>
       /// 返回城市名称
       /// </summary>
       ICategory GetCityName { get; }
       #endregion
   }
}
