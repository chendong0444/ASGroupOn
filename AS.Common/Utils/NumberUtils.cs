using System;
using System.Collections.Generic;
using System.Text;

namespace AS.Common.Utils
{
    public class NumberUtils
    {
        private static Random random = new Random();
        /// <summary>
        /// 判断字符串是不是数字
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public static bool IsNum(String str)
        {
            for (int i = 0; i < str.Length; i++)
            {
                if (!Char.IsNumber(str, i))
                    return false;
            }
            return true;
        }
        /// <summary>
        /// 返回临时主键ID
        /// </summary>
        /// <returns></returns>
        public static int GetTempID()
        {
            return (0 - random.Next(1, 9999999));
        }
    }
}
