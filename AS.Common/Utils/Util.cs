using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using AS.Common.Utils.Objects;

namespace AS.Common.Utils
{
    public class Util
    {
        /// <summary>
        /// 用于计算时间戳的时间值
        /// </summary>
        private static DateTime UnixTimestamp = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
        /// <summary>
        /// 生成一个时间戳
        /// </summary>
        /// <returns></returns>
        public static long GenerateTimestamp()
        {
            return GenerateTimestamp(DateTime.Now);
        }
        /// <summary>
        /// 生成一个时间戳
        /// </summary>
        /// <param name="time"></param>
        /// <returns></returns>
        public static long GenerateTimestamp(DateTime time)
        {
            return (long)(time.ToUniversalTime() - UnixTimestamp).TotalSeconds;
        }

        /// <summary>
        /// 随机种子
        /// </summary>
        private static Random RndSeed = new Random();
        /// <summary>
        /// 生成一个随机码
        /// </summary>
        /// <returns></returns>
        public static string GenerateRndNonce()
        {
            return string.Concat(
            Util.RndSeed.Next(1, 99999999).ToString("00000000"),
            Util.RndSeed.Next(1, 99999999).ToString("00000000"),
            Util.RndSeed.Next(1, 99999999).ToString("00000000"),
            Util.RndSeed.Next(1, 99999999).ToString("00000000"));
        }
        /// <summary>
        /// UrlEncode
        /// </summary>
        /// <param name="text"></param>
        /// <returns></returns>
        public static string UrlEncode(string text)
        {
            if (string.IsNullOrEmpty(text)) return string.Empty;
            StringBuilder buffer = new StringBuilder(text.Length);
            byte[] data = Encoding.UTF8.GetBytes(text);
            foreach (byte b in data)
            {
                char c = (char)b;
                if (!(('0' <= c && c <= '9') || ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z'))
                    && "-_.~".IndexOf(c) == -1)
                {
                    buffer.Append('%' + Convert.ToString(c, 16).ToUpper());
                }
                else
                {
                    buffer.Append(c);
                }
            }
            return buffer.ToString();
        }

        /// <summary>
        /// 获取XML节点的值
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="node"></param>
        /// <returns></returns>
        public static T GetXmlNodeValue<T>(XmlNode node)
        {
            if (node == null) return default(T);

            Type type = typeof(T);

            if (Type.GetTypeCode(type) != TypeCode.Object)
            {
                string value = node.InnerText;
                if (string.IsNullOrEmpty(value)) return default(T);
                try
                {
                    return (T)Convert.ChangeType(value, type);
                }
                catch
                {
                    return default(T);
                }
            }
            else
            {
                //尝试建立ResponseObject对象
                return ResponseObject.CreateInstance<T>(node);
            }
        }
    }
}
