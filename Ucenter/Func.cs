using System;
using System.Collections.Generic;
using System.Web;
using System.Collections;
using AS.ucenter;

namespace AS.Ucenter
{
    public class Func
    {
        /// <summary>
        /// 用户注册
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="password">密码</param>
        /// <param name="email">电子邮件</param>
        /// <returns>
        /// 大于 0:返回用户 ID，表示用户注册成功
        /// -1:用户名不合法
        /// -2:包含不允许注册的词语
        /// -3:用户名已经存在
        /// -4:Email 格式有误
        /// -5:Email 不允许注册
        /// -6:该 Email 已经被注册
        /// </returns>
        public static int uc_user_register(string username, string password, string email)
        {
            Hashtable ht = new Hashtable();
            ht.Add("username", username);
            ht.Add("password", password);
            ht.Add("email", email);
            string result = client_php.uc_api_post("user", "register", ht);
            ht.Clear();

            return int.Parse(result);
        }

        /// <summary>
        /// 用户登录
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="password">密码</param>
        /// <returns>
        /// integer [0]:大于 0:返回用户 ID，表示用户登录成功 -1:用户不存在，或者被删除 -2:密码错
        /// string [1]:用户名
        /// string [2]:密码
        /// string [3]:Email
        /// bool [4]:用户名是否重名
        /// </returns>
        public static RetrunClass uc_user_login(string username, string password)
        {
            return uc_user_login(username, password, false);
        }

        /// <summary>
        /// 用户登录
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="password">密码</param>
        /// <returns>
        /// integer [0]:大于 0:返回用户 ID，表示用户登录成功 -1:用户不存在，或者被删除 -2:密码错
        /// string [1]:用户名
        /// string [2]:密码
        /// string [3]:Email
        /// bool [4]:用户名是否重名
        /// </returns>
        public static RetrunClass uc_user_login(string username, string password, bool isuid)
        {
            Hashtable ht = new Hashtable();
            ht.Add("username", username);
            ht.Add("password", password);
            ht.Add("isuid", isuid ? 1 : 0);
            ht.Add("checkques", 0);
            ht.Add("questionid", 1);
            ht.Add("answer", "aaaa");
            string result = client_php.uc_api_post("user", "login", ht);
            ht.Clear();

            ht = client_php.uc_unserialize(result);
            return new RetrunClass(int.Parse((string)ht[0]), (string)ht[1], (string)ht[2], (string)ht[3], "0".Equals((string)ht[4]) ? false : true);
        }

        /// <summary>
        /// 更新用户资料
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="oldpw">旧密码</param>
        /// <param name="newpw">新密码，如不修改为空</param>
        /// <param name="email">Email，如不修改为空</param>
        /// <param name="ignoreoldpw">是否忽略旧密码 1:忽略，更改资料不需要验证密码 0:(默认值) 不忽略，更改资料需要验证密码
        /// <returns>
        /// 1:更新成功
        /// 0:没有做任何修改
        /// -1:旧密码不正确
        /// -4:Email 格式有误
        /// -5:Email 不允许注册
        /// -6:该 Email 已经被注册
        /// -7:没有做任何修改
        /// -8:该用户受保护无权限更改
        /// </returns>
        public static int uc_user_edit(string username, string oldpw, string newpw, string email, bool ignoreoldpw)
        {
            Hashtable ht = new Hashtable();
            ht.Add("username", username);
            ht.Add("oldpw", oldpw);
            ht.Add("newpw", newpw);
            ht.Add("email", email);
            ht.Add("ignoreoldpw", ignoreoldpw);
            string result = client_php.uc_api_post("user", "edit", ht);
            ht.Clear();

            return int.Parse(result);
        }
    }
}