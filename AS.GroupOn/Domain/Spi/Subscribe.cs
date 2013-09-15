using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    public class Subscribe : Obj, ISubscribe
    {

        /// <summary>
        /// ID号
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 邮箱
        /// </summary>
        public virtual string email { get; set; }
        /// <summary>
        /// 城市id
        /// </summary>
        public virtual int City_id { get; set; }
        /// <summary>
        /// 验证码
        /// </summary>
        public virtual string Secret { get; set; }


    }
}
