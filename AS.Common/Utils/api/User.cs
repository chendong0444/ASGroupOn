using System;
using System.Collections.Generic;
using System.Text;
using AS.Common.Utils.Objects;

namespace AS.Common.Utils.api
{
    /// <summary>
    /// 与帐户相关的接口实现
    /// </summary>
    public class User
        : RequestBase
    {
        /// <summary>
        /// 根据授权对象实例化
        /// </summary>
        /// <param name="oauth"></param>
        public User(OAuth oauth)
            : base(oauth)
        { }

        #region 获取自己的资料
        /// <summary>
        /// 采用默认API请求地址获取用户本人帐号信息
        /// </summary>
        /// <returns>本人帐号信息.</returns>
        public UserProfileData<UserProfile> GetProfile(string openid)
        {
            return this.GetProfile("http://openapi.qzone.qq.com/user/get_user_info", openid);
        }
        /// <summary>
        /// 获取用户本人帐号信息
        /// </summary>
        /// <param name="requestUrl">API请求地址</param>
        /// <returns>本人帐号信息.</returns>
        public UserProfileData<UserProfile> GetProfile(string requestUrl, string openid)
        {
            Parameters parameters = new Parameters();
            parameters.Add("format", this.ResponseDataFormat.ToString().ToLower());
            return this.GetResponseData<UserProfileData<UserProfile>>(requestUrl, parameters, openid);
        }
        #endregion




    }
}
