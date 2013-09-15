using System;
using System.Collections.Generic;
using System.Text;
using AS.Common.Utils;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建时间  2012-10-24、
    /// 创建人    郑立军
    /// </summary>
    public class Location : Obj, ILocation
    {
        #region 广告位表
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 广告内容
        /// </summary>
        public virtual string locationname { get; set; }
        /// <summary>
        /// 链接地址
        /// </summary>
        public virtual string pageurl { get; set; }
        /// <summary>
        /// 广告图片
        /// </summary>
        public virtual string image { get; set; }
        /// <summary>
        /// 显示位置 1首页 2右侧
        /// </summary>
        public virtual int location { get; set; }
        /// <summary>
        /// 添加时间
        /// </summary>
        public virtual DateTime createdate { get; set; }
        /// <summary>
        /// 是否显示 0隐藏 1显示
        /// </summary>
        public virtual int visibility { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        public virtual int type { get; set; }
        /// <summary>
        /// 广告名称
        /// </summary>
        public virtual string width { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public virtual string height { get; set; }
        /// <summary>
        /// 广告开始时间
        /// </summary>
        public virtual DateTime begintime { get; set; }
        /// <summary>
        /// 广告结束时间
        /// </summary>
        public virtual DateTime endtime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public virtual string decpriction { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        public virtual string cityid { get; set; }

        /// <summary>
        /// 返回城市
        /// </summary>
        public string  City
        {
            get
            {
                ICategory category = null;
                string mailcitys = String.Empty;
                if (this.cityid.Length > 0)
                {
                    string[] mail = cityid.Split(',');

                    for (int j = 0; j < mail.Length; j++)
                    {
                        using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                        {
                            category = session.Category.GetByID(Helper.GetInt(mail[j],0));
                        }

                        if (category != null)
                        {
                            mailcitys = mailcitys + category.Name + ",";
                        }
                        else
                        {
                            if (mail[j] == "0")
                            {
                                mailcitys = mailcitys + "全部城市 ";
                            }
                        }
                    }
                }
                else
                {
                    mailcitys = "全部城市";
                }
                return mailcitys;
            }
        }

        #endregion
    }
}



