using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;

namespace AS.Ucenter
{
    /// <summary>
    /// 更新相关信息类
    /// </summary>
    public class updateValue
    {
        /// <summary>
        /// 保存错误信息
        /// </summary>
        static string updateResult = "";
        /// <summary>
        /// 更新相关的用户资料
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="oldpw">旧密码</param>
        /// <param name="newpw">新密码</param>
        /// <param name="email">用户email</param>
        /// <param name="ignoreoldpw">是否忽略旧密码(1:忽略-更改资料不需要验证密码,0:(默认值) 不忽略-更改资料需要验证密码)</param>
        public static int updateUsername(string username, string oldpw, string newpw, string email, bool ignoreoldpw)
        {
            Hashtable ht = new Hashtable();
            ht.Add("username", username);
            ht.Add("oldpw", oldpw);
            ht.Add("newpw", newpw);
            ht.Add("email", email);
            ht.Add("ignoreoldpw", ignoreoldpw);
            string result = client_php.uc_api_post("user", "edit", ht);
            ht.Clear();
            try
            {
                int.Parse(result);
            }
            catch (Exception)
            {

                return -10;
            }
            return int.Parse(result);
        }
        /// <summary>
        /// 返回修改个人资料的错误信息
        /// </summary>
        /// <param name="updateId">返回的ID</param>
        /// <returns></returns>
        public static string updateUsername(int updateId)
        {
            switch (updateId)
            {
                case -1:
                    updateResult = "旧密码不正确";
                    break;
                case -4:
                    updateResult = "Email 格式有误";
                    break;
                case -5:
                    updateResult = "Email 不允许注册";
                    break;
                case -6:
                    updateResult = "该 Email 已经被注册";
                    break;
                case -7:
                    updateResult = "没有做任何修改";
                    break;
                case -8:
                    updateResult = "该用户受保护无权限更改";
                    break;
            }
            return updateResult;
        }
    }
}
