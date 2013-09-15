using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    public class MenuRelation : Obj, IMenuRelation
    {
        /// <summary>
        /// 主键
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public virtual int farthermenuid { get; set; }
        /// <summary>
        ///
        /// </summary>
        public virtual int childmenuid { get; set; }
    }
}
