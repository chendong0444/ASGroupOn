using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using AS.Common.Utils;
using AS.ucenter;

namespace AS.Ucenter
{
    /// <summary>
    /// 获取相关信息类
    /// </summary>
    public class getValue
    {
        /// <summary>
        /// 记录错误信息
        /// </summary>
        private static string result="";
        private static int resultValue = 0;
        /// <summary>
        /// 检查用户名
        /// </summary>
        /// <param name="username"></param>
        /// <returns></returns>
        public static int getUsername(string username)
        {
            resultValue = 0;
            Hashtable ht = new Hashtable();
            ht.Add("username", username);
           result = client_php.uc_api_post("user", "check_username", ht);
            ht.Clear();
            switch (result)
            {
                case "-1":
                    resultValue = 2;//用户名不合法
                    break;
                case "-2":
                    resultValue = 3;//包含要允许注册的词语
                    break;
                case "-3":
                    resultValue = 1;//用户名已经存在
                    break;
            }
            return resultValue;
        }
        /// <summary>
        /// 返回错误信息
        /// </summary>
        /// <param name="value">错误的ID</param>
        /// <returns></returns>
        public static string getUsername(int value)
        {
            result = "";
            switch (value)
            {
                case 1:
                    result = "用户名已存在";
                    break;
                case 2:
                    result = "用户名不合法";
                    break;
                case 3:
                    result = "包含不允许注册的词语";
                    break;
            }
            return result;
 
        }
        /// <summary>
        /// 检查Email
        /// </summary>
        /// <param name="email"></param>
        /// <returns></returns>
        public static int getEmail(string email)
        {
            resultValue = 0;
            Hashtable ht = new Hashtable();
            ht.Add("email", email);
             result = client_php.uc_api_post("user", "check_email", ht);
            ht.Clear();
            switch (result)
            {
                case "-4":
                    resultValue = 2;//Email 格式有误
                    break;
                case "-5":
                    resultValue = 3;//Email 不允许注册
                    break;
                case "-6":
                    resultValue = 1;//该 Email 已经被注册
                    break;
                    
            }
            return resultValue;
        }
        /// <summary>
        /// 邮箱验证错误信息
        /// </summary>
        /// <param name="value">错误ID</param>
        /// <returns></returns>
        public static string getEmail(int value)
        {
            result = "";
            switch (value)
            {
                case 1:
                    result = "该 Email 已经被注册";
                    break;
                case 2:
                    result = "Email 格式有误";
                    break;
                case 3:
                    result = "Email 不允许注册";
                    break;
            }
            return result;
 
        }
        /// <summary>
        /// 获取用户信息
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="isuid">是否用ID获取,1用ID获取（默认为0)</param>
        /// <returns></returns>
        public static RetrunClass getLogin(string username, bool isuid)
        {
            Hashtable ht = new Hashtable();
            ht.Add("username", username);
            ht.Add("isuid", isuid ? 1 : 0);
            string result = client_php.uc_api_post("user", "get_user", ht);
            ht.Clear();
            try
            {
                ht = client_php.uc_unserialize(result);
            }
            catch (Exception ex)
            {
                AS.Common.Utils.WebUtils.LogWrite("UC获取用户信息错误", ex.Message);
                return null;
            }
            return new RetrunClass(int.Parse((string)ht[0]), (string)ht[1],"" , (string)ht[2], "0".Equals((string)ht[4]) ? false : true);
        }
        /// <summary>
        /// 返回错误信息
        /// </summary>
        /// <param name="uid"></param>
        /// <returns></returns>
        public static string getLogin(int uid)
        {
            if (uid == 0)
                result = "用户不存在";
            return result;
        }
    }
}
