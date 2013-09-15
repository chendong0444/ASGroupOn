using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
   public interface IAsk:IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 会员ID
        /// </summary>
         int User_id { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
         int Team_id { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        int City_id { get; set; }
        /// <summary>
        /// 咨询内容
        /// </summary>
         string Content { get; set; }
        /// <summary>
        /// 回复
        /// </summary>
         string Comment { get; set; }
        /// <summary>
        /// 咨询时间
        /// </summary>
         DateTime Create_time { get; set; }
       ///////////////////////////
       /// <summary>
       /// 咨询用户
       /// </summary>
       IUser User { get; }
       ///////////////////////////
       /// <summary>
       /// 项目
       /// </summary>
       ITeam team { get; }
    }
}
