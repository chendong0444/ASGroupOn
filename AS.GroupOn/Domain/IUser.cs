using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 用户表
    /// </summary>
    public interface IUser:IObj
    {
        /// <summary>
        /// 用户ID
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 用户邮箱
        /// </summary>
        string Email { get; set; }
        /// <summary>
        /// 用户名
        /// </summary>
        string Username { get; set; }
        /// <summary>
        /// 真实姓名
        /// </summary>
        string Realname { get; set; }
        /// <summary>
        /// 密码
        /// </summary>
        string Password { get; set; }
        /// <summary>
        /// 头像路径
        /// </summary>
        string Avatar { get; set; }
        /// <summary>
        /// 性别 (男或女)
        /// </summary>
        string Gender { get; set; }

        string Newbie { get; set; }

        /// <summary>
        /// 手机号
        /// </summary>
        string Mobile { get; set; }
        /// <summary>
        /// QQ号
        /// </summary>
        string Qq { get; set; }
        /// <summary>
        /// msn
        /// </summary>
        string msn { get; set; }
        /// <summary>
        /// 账户余额
        /// </summary>
        decimal Money { get; set; }
        /// <summary>
        /// 用户积分
        /// </summary>
        int Score { get; set; }
        /// <summary>
        /// 邮编
        /// </summary>
        string Zipcode { get; set; }
        /// <summary>
        /// 地址
        /// </summary>
        string Address { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        int City_id { get; set; }
        /// <summary>
        /// 激活状态
        /// </summary>
        string Enable { get; set; }
        /// <summary>
        /// 管理状态
        /// </summary>
        string Manager { get; set; }
        /// <summary>
        /// 是否是管理员分站管理员
        /// </summary>
        string IsManBranch { get; set; }
        /// <summary>
        /// 邮件验证码
        /// </summary>
        string Secret { get; set; }
        /// <summary>
        /// 激活码
        /// </summary>
        string Recode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        string Sns { get; set; }

        /// <summary>
        /// 注册IP
        /// </summary>
        string IP { get; set; }
        /// <summary>
        /// 登陆时间
        /// </summary>
        DateTime? Login_time { get; set; }
        /// <summary>
        /// 注册时间
        /// </summary>
        DateTime Create_time { get; set; }
       
        /// <summary>
        /// 权限
        /// </summary>
        string auth { get; set; }
        /// <summary>
        /// 注册来源地址
        /// </summary>
        string IP_Address { get; set; }
        /// <summary>
        /// 注册来源域名
        /// </summary>
        string fromdomain { get; set; }
        /// <summary>
        /// 用户积分
        /// </summary>
        int userscore { get; set; }
        /// <summary>
        /// 总消费金额
        /// </summary>
        decimal totalamount { get; set; }
     
        /// <summary>
        /// 是否uc同步
        /// </summary>
        string ucsyc { get; set; }
        /// <summary>
        /// 保存一站通标识,中间用|分隔
        /// </summary>
        string yizhantong { get; set; }

        /// <summary>
        /// 用户绑定的手机号码，此手机号一担绑定不可更改
        /// </summary>
        string Signmobile { get; set; }

        /// <summary>
        /// 每日签到的签到时间
        /// </summary>
        DateTime? Sign_time { get; set; }
       
        /// <summary>
        /// 得到用户等级
        /// </summary>
        ICategory LeveName { get; }
        /// <summary>
        /// 得到购买次数
        /// </summary>
        int BuyNum { get; }
        /// <summary>
        /// 得到消费总额
        /// </summary>
        decimal GetTotalamount { get; }
        /// <summary>
        /// 返回城市
        /// </summary>
        ICategory Category { get; }

        /// <summary>
        /// 用户角色
        /// </summary>
        IList<IRole> Role { get; }

    }
}
