using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
   public interface IFeedback:IObj
    {
       /// <summary>
       /// 主键
       /// </summary>
       int Id { get; }
       /// <summary>
       /// 城市ID
       /// </summary>
       int City_id { get; set; }
       /// <summary>
       /// 用户ID(如果用户没有登录则为0）
       /// </summary>
       int User_id { get; set; }
       /// <summary>
       /// 意见反馈类型
       /// </summary>
       string Category { get; set; }
       /// <summary>
       /// 称呼
       /// </summary>
       string title { get; set; }
       /// <summary>
       /// 联系方式
       /// </summary>
       string Contact { get; set; }
       /// <summary>
       /// 内容
       /// </summary>
       string Content { get; set; }
       /// <summary>
       /// 提交时间
       /// </summary>
       DateTime Create_time { get; set; }

       /// <summary>
       /// 返回用户
       /// </summary>
       IUser User { get; }
    }
}
