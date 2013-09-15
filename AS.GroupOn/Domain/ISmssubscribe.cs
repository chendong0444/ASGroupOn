using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：短信订阅
    /// </summary>
    public interface ISmssubscribe:IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 手机号
        /// </summary>
        string Mobile { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        int City_id { get; set; }
        /// <summary>
        /// 验证码
        /// </summary>
        string Secret { get; set; }
        /// <summary>
        /// 激活状态
        /// </summary>
        string Enable { get; set; }
        /// <summary>
        /// 返回城市
        /// </summary>
        ICategory getCityName { get; }
    }
}
