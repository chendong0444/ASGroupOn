using System;
using System.Collections.Generic;
using System.Text;

namespace Ucenter
{
    /// <summary>
    /// 各种Ucenter返回的验证内容并返回字符串。
    /// </summary>
    public class Message
    {
        /// <summary>
        /// 返回过来的错误的登录信息
        /// </summary>
        /// <param name="value">传入整型ID</param>
        /// <returns>返回错误信息，如果没有，说明登录成功!</returns>
        public static string LoginMessage(int value)
        {
            string str = "";
            switch (value)
            {
                case -1:
                    str = "用户不存在，或者被删除!";
                    break;
                case -2:
                    str = "密码错";
                    break;
                case -3:
                    str = "安全提问错";
                    break;
            }
            return str;
        }
        /// <summary>
        /// 返回过来的错误的注册信息
        /// </summary>
        /// <param name="userid">传入ID</param>
        /// <returns>返回注册以后的错误信息，如果没有说明注册成功。</returns>
        public static string RegesterMessage(int id)
        {
            string str = "";
            switch (id)
            {
                case -1:
                    str = "用户名不合法";
                    break;
                case -2:
                    str = "包含不允许注册的词语";
                    break;
                case -3:
                    str = "用户名已经存在";
                    break;
                case -4:
                    str = "Email 格式有误";
                    break;
                case -5:
                    str = "Email 不允许注册";
                    break;
                case -6:
                    str = "该 Email 已经被注册";
                    break;
            }
            return str;
        }
        /// <summary>
        /// 返回过来的更新错误信息
        /// </summary>
        /// <param name="id">传入ID</param>
        /// <returns>返回更新以后的错误信息，如果没有说明更新成功</returns>
        public static string updateMessage(int id)
        {
            string s = "";
            switch (id)
            {
                case -1:
                    s = "旧密码不正确";
                    break;
                case -4:
                    s = "Email 格式有误";
                    break;
                case -5:
                    s = "Email 不允许注册";
                    break;
                case -6:
                    s = "该 Email 已经被注册";
                    break;
                case -7:
                    s = "没有做任何修改";
                    break;
                case -8:
                    s = "该用户受保护无权限更改";
                    break;
            }
            return s;
        }
    }
}
