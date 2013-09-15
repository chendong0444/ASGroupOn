using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public interface IMailtasks:IObj
    {
        #region 邮件任务列表接口
        /// <summary>
        /// ID号
        /// </summary>
        int id { get; set; }
        /// <summary>
        ///邮件标题 不能出现特殊字符
        /// </summary>
        string subject { get; set; }
        /// <summary>
        /// 邮件正文 
        /// </summary>
        string content { get; set; }
        /// <summary>
        /// 已发送数量
        /// </summary>
        int sendcount { get; set; }
        /// <summary>
        /// 发送总数量
        /// </summary>
        int totalcount { get; set; }
        /// <summary>
        /// 已阅读的mailerid
        /// </summary>
        string readmailerid { get; set; }
        /// <summary>
        /// 已阅读的数量
        /// </summary>
        int readcount { get; set; }
        /// <summary>
        /// 0未发送 1正在发送 2发送完毕 3已暂停 4 已取消
        /// </summary>
        int state { get; set; }
        /// <summary>
        /// 城市编号
        /// </summary>
        string cityid { get; set; }
        /// <summary>
        /// 返回城市
        /// </summary>
        string City { get; }

        #endregion
    }
}
