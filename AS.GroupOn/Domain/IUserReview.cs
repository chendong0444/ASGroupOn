/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;
namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 购买评论
    /// </summary>
   public interface IUserReview:IObj//用户评论
    {

       // 评论ID  
       int id { get; set; }
  
       //用户ID
       int user_id { get; set; }

       //项目ID
       int team_id { get; set; }

       //评论时间
       DateTime create_time { get; set; }

       // 评价内容 限制字符2000
       string  comment { get; set; }

       // 评分
       int score { get; set; }

       //返利时间
       DateTime? rebate_time { get; set; }
      
       // 返利金额
       decimal rebate_price { get; set; }

       //评论状态 0为无效 1为有效,2为删除
       int state { get; set; }

       // 管理员ID 为0时表示系统自动处理
       int admin_id { get; set; }

       //是否愿意再去
       int ? isgo { get; set; }

       //商户Id
       int ? partner_id { get; set; }

       //评价类型
       string  type { get; set; }

       /// <summary>
       /// 返回用户
       /// </summary>
       IUser user { get; }

       /// <summary>
       /// 返回admin
       /// </summary>
       IUser aduser { get; }
       /// <summary>
       /// 返回项目
       /// </summary>
       ITeam team { get; }

       /// <summary>
       /// 返回商户
       /// </summary>
       IPartner partner { get; }

       int? review_teamid { get; set; }
       string username { get; set; }
       string Title { get; set; }
       string Image { get; set; }
       decimal? totalamount { get; set; }

    }
}
