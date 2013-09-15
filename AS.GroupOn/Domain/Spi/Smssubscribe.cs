using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：短信订阅
    /// </summary>
    public class Smssubscribe:Obj,ISmssubscribe
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 手机号
        /// </summary>
        public virtual string Mobile { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        public virtual int City_id { get; set; }
        /// <summary>
        /// 验证码
        /// </summary>
        public virtual string Secret { get; set; }
        /// <summary>
        /// 激活状态
        /// </summary>
        public virtual string Enable { get; set; }
        /// <summary>
        /// 返回城市
        /// </summary>
        private ICategory Category = null;
        public virtual ICategory getCityName 
        {
            get{

                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                {
                    Category = session.Category.GetByID(this.City_id);
                }
                return Category;
            }
        }

    }
}
