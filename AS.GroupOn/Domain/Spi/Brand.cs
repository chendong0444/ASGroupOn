using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
namespace AS.GroupOn.Domain.Spi
{
   public class Brand:Obj,IBrand
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 中文名称
        /// </summary>
        public virtual string Name { get; set; }
        /// <summary>
        /// 英文名称
        /// </summary>
        public virtual string Ename { get; set; }
        /// <summary>
        /// 首字母
        /// </summary>
        public virtual string Letter { get; set; }
        /// <summary>
        /// 排列序号
        /// </summary>
        public virtual int Sort_order { get; set; }
        /// <summary>
        /// 是否显示  Y显示 N不显示
        /// </summary>
        public virtual string Display { get; set; }


        private int _teamcount = 0;
        public virtual int TeamCount(ICity city)
        {
            if (_teamcount == 0)
            {
                int cityid = 0;
                if (city != null) cityid = city.Id;
                using (IDataSession session = App.Store.OpenSession(false))
                {
                    _teamcount = session.Custom.GetTeamCount(Id, cityid, 1);
                }
            }
            return _teamcount;
        }
    }
}
