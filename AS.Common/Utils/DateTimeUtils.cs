using System;
using System.Collections.Generic;
using System.Text;

namespace AS.Common.Utils
{
   public class DateTimeUtils
    {
        /// <summary>
        /// 返回距离1970年的时间戳
        /// </summary>
        /// <param name="datetime"></param>
        /// <returns></returns>
        public static long GetTimeFix(DateTime datetime)
        {
            DateTime mysqltime = DateTime.Parse("1970-1-1 0:0:0");
            TimeSpan ts = datetime.AddHours(-8) - mysqltime;
            return ts.Ticks / 10000000;
        }

       /// <summary>
       /// 根据时间戳返回时间
       /// </summary>
       /// <param name="fix"></param>
       /// <returns></returns>
        public static DateTime GetWindowsTime(object fix)
        {
            DateTime mysqltime = DateTime.Parse("1970-1-1 0:0:0");
            long time = Utils.Helper.GetLong(fix, 0);
            mysqltime = mysqltime.AddTicks(time * 10000000);
            return mysqltime.AddHours(8);
        }
    }
}
