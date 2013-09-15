using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    public class SmsLog : Obj, ISmsLog
    {
        /// <summary>
        /// 编号
        /// </summary>
        public virtual int Id { get; set; }

        public virtual string Mobiles { get; set; }

        public virtual DateTime SendTime { get; set; }

        public virtual int Points { get; set; }

        /// <summary>
        /// 短信内容
        /// </summary>
        public virtual string Content { get; set; }

    }
}
