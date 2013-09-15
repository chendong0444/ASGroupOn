using System;
using System.Collections.Generic;
using System.Web;
using System.Security.Cryptography;
using AS.Common.Utils;
using AS.GroupOn.Controls;
namespace AS.Ucenter
{
    /// <summary>
    /// 解码类
    /// </summary>
    public class UcenterEncodeValue
    {
        /// <summary>
        /// AuthCode解码&编码
        /// </summary>
        /// <param name="sourceStr">原始字符串</param>
        /// <param name="operation">操作类型</param>
        /// <param name="keyStr">API KEY</param>
        /// <param name="expiry">过期时间 0代表永不过期</param>
        /// <returns></returns>
        public static string AuthCode(string sourceStr, AuthCodeMethod operation, string keyStr, int expiry = 0)
        {
            int ckeyLength = 4;
            byte[] source = System.Text.Encoding.GetEncoding(WebUtils.config["UC_CHARSET"]).GetBytes(sourceStr);
            byte[] key = System.Text.Encoding.GetEncoding(WebUtils.config["UC_CHARSET"]).GetBytes(keyStr);
            key = Md5(key);
            byte[] keya = Md5(SubBytes(key, 0, 0x10));
            byte[] keyb = Md5(SubBytes(key, 0x10, 0x10));
            byte[] keyc = (ckeyLength > 0)
                            ? ((operation == AuthCodeMethod.Decode)
                                    ? SubBytes(source, 0, ckeyLength)
                                    : RandomBytes(ckeyLength))
                            : new byte[0];
            byte[] cryptkey = AddBytes(keya, Md5(AddBytes(keya, keyc)));
            int keyLength = cryptkey.Length;
            if (operation == AuthCodeMethod.Decode)
            {
                while (source.Length % 4 != 0)
                {
                    source = AddBytes(source, System.Text.Encoding.GetEncoding(WebUtils.config["UC_CHARSET"]).GetBytes("="));
                }
                source = Convert.FromBase64String(BytesToString(SubBytes(source, ckeyLength)));
            }
            else
            {
                source =
                    AddBytes(
                        (expiry != 0
                                ? System.Text.Encoding.GetEncoding(WebUtils.config["UC_CHARSET"]).GetBytes((expiry + PhpTimeNow()).ToString())
                                : System.Text.Encoding.GetEncoding(WebUtils.config["UC_CHARSET"]).GetBytes("0000000000")),
                        SubBytes(Md5(AddBytes(source, keyb)), 0, 0x10), source);
            }
            int sourceLength = source.Length;
            int[] box = new int[256];
            for (int k = 0; k < 256; k++)
            {
                box[k] = k;
            }
            int[] rndkey = new int[256];
            for (int i = 0; i < 256; i++)
            {
                rndkey[i] = cryptkey[i % keyLength];
            }
            for (int j = 0, i = 0; i < 256; i++)
            {
                j = (j + box[i] + rndkey[i]) % 256;
                int tmp = box[i];
                box[i] = box[j];
                box[j] = tmp;
            }
            byte[] result = new byte[sourceLength];
            for (int a = 0, j = 0, i = 0; i < sourceLength; i++)
            {
                a = (a + 1) % 256;
                j = (j + box[a]) % 256;
                int tmp = box[a];
                box[a] = box[j];
                box[j] = tmp;
                result[i] = (byte)(source[i] ^ (box[(box[a] + box[j]) % 256]));
            }
            if (operation == AuthCodeMethod.Decode)
            {
                long time = long.Parse(BytesToString(SubBytes(result, 0, 10)));
                if ((time == 0 ||
                        time - PhpTimeNow() > 0) &&
                    BytesToString(SubBytes(result, 10, 16)) == BytesToString(SubBytes(Md5(AddBytes(SubBytes(result, 26), keyb)), 0, 16)))
                {
                    return BytesToString(SubBytes(result, 26));
                }
                return "";
            }
            return BytesToString(keyc) + Convert.ToBase64String(result).Replace("=", "");
        }
        /// <summary>
        /// Byte数组转字符串
        /// </summary>
        /// <param name="b">数组</param>
        /// <returns></returns>
        public static string BytesToString(byte[] b)
        {
            return new string(System.Text.Encoding.GetEncoding(WebUtils.config["UC_CHARSET"]).GetChars(b));
        }
        /// <summary>
        /// 计算Md5
        /// </summary>
        /// <param name="b">byte数组</param>
        /// <returns>计算好的字符串</returns>
        public static byte[] Md5(byte[] b)
        {
            MD5CryptoServiceProvider cryptHandler = new MD5CryptoServiceProvider();
            byte[] hash = cryptHandler.ComputeHash(b);
            string ret = "";
            foreach (byte a in hash)
            {
                if (a < 16)
                { ret += "0" + a.ToString("x"); }
                else
                { ret += a.ToString("x"); }
            }
            return System.Text.Encoding.GetEncoding(WebUtils.config["UC_CHARSET"]).GetBytes(ret);
        }
        /// <summary>
        /// Byte数组相加
        /// </summary>
        /// <param name="bytes">数组</param>
        /// <returns></returns>
        public static byte[] AddBytes(params byte[][] bytes)
        {
            int index = 0;
            int length = 0;
            foreach (byte[] b in bytes)
            {
                length += b.Length;
            }
            var result = new byte[length];
            foreach (byte[] bs in bytes)
            {
                foreach (byte b in bs)
                {
                    result[index++] = b;
                }
            }
            return result;
        }
        /// <summary>
        /// Byte数组分割
        /// </summary>
        /// <param name="b">数组</param>
        /// <param name="start">开始</param>
        /// <param name="length">结束</param>
        /// <returns></returns>
        public static byte[] SubBytes(byte[] b, int start, int length = int.MaxValue)
        {
            if (start >= b.Length) return new byte[0];
            if (start < 0) start = 0;
            if (length < 0) length = 0;
            if (length > b.Length || start + length > b.Length) length = b.Length - start;
            var result = new byte[length];
            var index = 0;
            for (int k = start; k < start + length; k++)
            {
                result[index++] = b[k];
            }
            return result;
        }
        /// <summary>
        /// 计算Php格式的当前时间
        /// </summary>
        /// <returns>Php格式的时间</returns>
        public static long PhpTimeNow()
        {
            return DateTimeToPhpTime(DateTime.UtcNow);
        }
        /// <summary>
        /// PhpTime转DataTime
        /// </summary>
        /// <returns></returns>
        public static DateTime PhpTimeToDateTime(long time)
        {
            DateTime timeStamp = new DateTime(1970, 1, 1); //得到1970年的时间戳
            long t = (time + 8 * 60 * 60) * 10000000 + timeStamp.Ticks;
            return new DateTime(t);
        }
        /// <summary>
        /// DataTime转PhpTime
        /// </summary>
        /// <param name="datetime">时间</param>
        /// <returns></returns>
        public static long DateTimeToPhpTime(DateTime datetime)
        {
            DateTime timeStamp = new DateTime(1970, 1, 1);  //得到1970年的时间戳
            return (datetime.Ticks - timeStamp.Ticks) / 10000000;  //注意这里有时区问题，用now就要减掉8个小时
        }
        /// <summary>
        /// 随机字符串
        /// </summary>
        /// <param name="lens">长度</param>
        /// <returns></returns>
        public static byte[] RandomBytes(int lens)
        {
            char[] chArray = new[]
                        {
                            'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q',
                            'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
                            'H', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
                            'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
                        };
            int length = chArray.Length;
            byte[] result = new byte[lens];
            Random random = new Random();
            for (var i = 0; i < lens; i++)
            {
                result[i] = (byte)chArray[random.Next(length)];
            }
            return result;
        }
        /// <summary>
        /// 操作类型
        /// </summary>
        public enum AuthCodeMethod
        {
            Encode,
            Decode,
        }
    }
}