using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess;


namespace AS.GroupOn.Domain.Spi
{
    
    public class Userlevelrules:Obj,IUserlevelrules
    {
        #region 用户等级表
        /// <summary>
        /// 用户ID
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 等级ID
        /// </summary>
        public virtual int levelid { get; set; }
        /// <summary>
        /// 消费上限
        /// </summary>
        public virtual decimal maxmoney { get; set; }
        /// <summary>
        /// 消费下限
        /// </summary>
        public virtual decimal minmoney { get; set; }
        /// <summary>
        /// 折扣
        /// </summary>
        public virtual double discount { get; set; }
        #endregion 

        private ICategory _category = null;
        /// <summary>
        /// 返回组对象
        /// </summary>
        public virtual ICategory Category
        {
            get
            {
                if (_category == null)
                {
                    using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                    {
                        _category = session.Category.GetByID(this.levelid);
                    }
                }
                return _category;
            }
        }
    }
}
