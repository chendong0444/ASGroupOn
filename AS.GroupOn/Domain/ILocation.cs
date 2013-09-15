using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public interface ILocation:IObj
    {

        #region 广告位接口成员
        /// <summary>
        /// ID号
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 广告内容
        /// </summary>
        string locationname { get; set; }
        /// <summary>
        /// 链接地址
        /// </summary>
        string pageurl { get; set; }
        /// <summary>
        /// 广告图片
        /// </summary>
        string image { get; set; }
        /// <summary>
        /// 显示位置 1首页 2右侧
        /// </summary>
        int location { get; set; }
        /// <summary>
        /// 添加时间
        /// </summary>
        DateTime createdate { get; set; }
        /// <summary>
        /// 是否显示 0隐藏 1显示
        /// </summary>
        int visibility { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        int type { get; set; }
        /// <summary>
        /// 广告名称
        /// </summary>
        string width { get; set; }
        /// <summary>
        /// 
        /// </summary>
        string height { get; set; }
        /// <summary>
        /// 广告开始时间
        /// </summary>
        DateTime begintime { get; set; }
        /// <summary>
        /// 广告结束时间
        /// </summary>
        DateTime endtime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        string decpriction { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        string cityid { get; set; }

        /// <summary>
        /// 返回城市
        /// </summary>
        string City { get; }

        #endregion
    }
}
