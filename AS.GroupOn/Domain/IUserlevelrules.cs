using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IUserlevelrules:IObj
    {
        #region 用户等级规则
        
        /// <summary>
        ///主键自增id
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 用户等级ID 如果表中存在对应的id值 则更新，否则创建
        /// </summary>
        int levelid { get; set; }
        /// <summary>
        /// 消费上限
        /// </summary>
        decimal maxmoney { get; set; }
        /// <summary>
        /// 消费下限
        /// </summary>
        decimal minmoney { get; set; }
        /// <summary>
        /// 购买商品折扣 1为不打折 0.95为95折
        /// </summary>
        double discount { get; set; }

        /// <summary>
        /// 返回分类
        /// </summary>
        ICategory Category { get; }

        #endregion
    }
}
