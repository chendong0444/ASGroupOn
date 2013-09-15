using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using AS.Common.Utils;
using AS.ucenter;


namespace AS.Ucenter
{
    /// <summary>
    /// 设置信息类
    /// </summary>
    public class setValue
    {
        static string setResult = "";
        /// <summary>
        /// 用户注册
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="password">密码</param>
        /// <param name="email">邮箱</param>
        /// <param name="questionid">密码提示索引</param>
        /// <param name="answer">密码提示问题</param>
        /// /// <param name="isuid">用户名是否重名</param>
        /// <returns>返回用户对象</returns>
        public static int setRegester(string username, string password, string email, bool isuid)
        {
            Hashtable ht = new Hashtable();
            ht.Add("username", username);
            ht.Add("password", password);
            ht.Add("email", email);
            ht.Add("isuid", isuid ? 1 : 0);
            ht.Add("checkques", 0);
            string result = client_php.uc_api_post("user", "register", ht);
            ht.Clear();
            try
            {
                int.Parse(result);
            }
            catch (Exception ex)
            {
                AS.Common.Utils.WebUtils.LogWrite("UC注册接口同步错误", ex.Message);
                return -10;
            }
            return int.Parse(result);
        }
        /// <summary>
        /// 返回错误信息
        /// </summary>
        /// <param name="returnid">返回的ID</param>
        /// <returns></returns>
        public static string getRegester(int returnid)
        {

            switch (returnid)
            {
                case -1:
                    setResult = "用户名不合法";
                    break;
                case -2:
                    setResult = "包含不允许注册的词语";
                    break;
                case -3:
                    setResult = "用户名已经存在";
                    break;
                case -4:
                    setResult = "Email 格式有误";
                    break;
                case -5:
                    setResult = "Email 不允许注册";
                    break;
                case -6:
                    setResult = "该 Email 已经被注册";
                    break;
            }
            return setResult;
        }
        /// <summary>
        /// 登录
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="password">密码</param>
        /// <param name="isuid">是否使用ID登录</param>
        /// <param name="checkques">是否验证安装提问</param>
        /// <returns></returns>
        public static RetrunClass setLogin(string username, string password, bool isuid, bool checkques)
        {
            Hashtable ht = new Hashtable();
            ht.Add("username", username);
            ht.Add("password", password);
            ht.Add("isuid", isuid ? 1 : 0);
            ht.Add("checkques", 0);
            string result = client_php.uc_api_post("user", "login", ht);
            ht.Clear();
            try
            {
                ht = client_php.uc_unserialize(result);
            }
            catch (Exception ex)
            {
                AS.Common.Utils.WebUtils.LogWrite("UC登录接口同步错误", ex.Message);
                return null;
            }
            return new RetrunClass(int.Parse((string)ht[0]), (string)ht[1], (string)ht[2], (string)ht[3], "0".Equals((string)ht[4]) ? false : true);
        }
        /// <summary>
        ///返回登录错误信息
        /// </summary>
        /// <param name="uid">登录的状态ID</param>
        /// <returns></returns>
        public static string getLogin(int uid)
        {
            switch (uid)
            {
                case -1:
                    setResult = "用户不存在，或者被删除";
                    break;
                case -2:
                    setResult = "您输入的密码错误！";
                    break;
                case -3:
                    setResult = "安全提问错";
                    break;
            }
            return setResult;

        }
        /// <summary>
        /// 设置同步登录信息
        /// </summary>
        /// <param name="uid">用户ID</param>
        /// <returns></returns>
        public static string getsynlogin(int uid)
        {
            Hashtable ht = new Hashtable();
            ht.Add("uid", uid);
            string result = client_php.uc_api_post("user", "synlogin", ht);
            ht.Clear();
            return result;
        }
        /// <summary>
        /// 设置同步退出信息
        /// </summary>
        public static string setlogout()
        {
            Hashtable ht = new Hashtable();
            string result = client_php.uc_api_post("user", "synlogout", ht);
            ht.Clear();
            return result;
        }
    }
}
