using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface ISystem:IObj
    {
        /// <summary>
        /// 主键
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 网站名称
        /// </summary>
        string sitename { get; set; }
        /// <summary>
        /// 网站标题
        /// </summary>
        string sitetitle { get; set; }
        /// <summary>
        /// 网站简称
        /// </summary>
        string abbreviation { get; set; }
        /// <summary>
        /// 优惠券名称
        /// </summary>
        string couponname { get; set; }
        /// <summary>
        /// 货币符号
        /// </summary>
        string currency { get; set; }
        /// <summary>
        /// 货币代码
        /// </summary>
        string currencyname { get; set; }
        /// <summary>
        /// 邀请返利(邀请一次返利多少元)
        /// </summary>
        decimal invitecredit { get; set; }
        /// <summary>
        /// 侧栏团购数
        /// </summary>
        int sideteam { get; set; }
        /// <summary>
        /// 网站头部logo
        /// </summary>
        string headlogo { get; set; }
        /// <summary>
        /// 网站底部logo
        /// </summary>
        string footlogo { get; set; }
        /// <summary>
        /// 邮件订阅的logo
        /// </summary>
        string emaillogo { get; set; }
        /// <summary>
        /// 打印页logo
        /// </summary>
        string printlogo { get; set; }
        /// <summary>
        /// 成团条件1 以成功付款人数为限 0 以成交产品数量为限
        /// </summary>
        int conduser { get; set; }
        /// <summary>
        /// 优惠券下载(1 商户可下载编号及密码，0 商户仅可下载编号)
        /// </summary>
        int partnerdown { get; set; }
        /// <summary>
        /// 客服QQ
        /// </summary>
        string kefuqq { get; set; }
        /// <summary>
        /// 客服MSN
        /// </summary>
        string kefumsn { get; set; }
        /// <summary>
        /// ICP编号
        /// </summary>
        string icp { get; set; }
        /// <summary>
        /// 统计代码
        /// </summary>
        string statcode { get; set; }
        /// <summary>
        /// 导航栏是否显示品牌商户0不显示1显示 
        /// </summary>
        int Navpartner { get; set; }
        /// <summary>
        /// 导航栏是否显示秒杀抢购0不显示1显示
        /// </summary>
        int navseconds { get; set; }
        /// <summary>
        /// 导航栏是否显示热销商品0不显示1显示
        /// </summary>
        int navgoods { get; set; }
        /// <summary>
        /// 导航栏是否显示讨论区 0不显示 1显示
        /// </summary>
        int navforum { get; set; }
        /// <summary>
        /// 失败团购显示(在往期团购中，是否显示失败的团购)0不显示1显示
        /// </summary>
        int Displayfailure { get; set; }
        /// <summary>
        /// 全部答疑显示(本单答疑栏目中，是否显示全部团购项目答疑)0不显示1显示
        /// </summary>
        int teamask { get; set; }
        /// <summary>
        /// 仅余额可秒杀(是否，秒杀项目是否仅允许余额付款)0否1是
        /// </summary>
        int creditseconds { get; set; }
        /// <summary>
        /// 开启短信订阅(是否开启短信订阅团购信息功能)0否 1是
        /// </summary>
        int smssubscribe { get; set; }
        /// <summary>
        /// 简体繁体转换(是否显示在线简体繁体转换链接) 0否 1是
        /// </summary>
        int trsimple { get; set; }
        /// <summary>
        /// 用户节省钱数(在团购列表页显示共为用户节省多少钱)0否 1是
        /// </summary>
        int moneysave { get; set; }
        /// <summary>
        /// 项目详情通栏(团购项目详情和商户信息通栏显示，不分左右两栏) 0不分 1分
        /// </summary>
        int teamwhole { get; set; }
        /// <summary>
        /// 整站混淆编号(将所有数字ID编码后显示) 0不混淆 1混淆
        /// </summary>
        int encodeid { get; set; }
        /// <summary>
        /// 往期团购(是否项目分类显示？) 0否 1是
        /// </summary>
        int cateteam { get; set; }
        /// <summary>
        /// 品牌商户1(是否商户分类显示？) 0否 1是
        /// </summary>
        int catepartner { get; set; }
        /// <summary>
        /// 品牌商户2(是否商户按城市显示) 0否 1是
        /// </summary>
        int citypartner { get; set; }
        /// <summary>
        /// 秒杀抢团(是否项目分类显示？)0否 1是
        /// </summary>
        int cateseconds { get; set; }
        /// <summary>
        /// 热销商品(是否项目分类显示？) 0否 1是
        /// </summary>
        int categoods { get; set; }
        /// <summary>
        /// 邮箱验证(用户注册时，是否必须进行邮箱验证) 0否 1是
        /// </summary>
        int emailverify { get; set; }
        /// <summary>
        /// 手机号码必填(用户注册时，是否必须必须输入合法的手机号码)0 否 1是
        /// </summary>
        int needmobile { get; set; }
        /// <summary>
        /// 全局公告
        /// </summary>
        string gobalbulletin { get; set; }
        /// <summary>
        /// 城市公告(此处需要格式处理，暂不考虑)
        /// </summary>
        string bulletin { get; set; }
        /// <summary>
        /// 支付宝商户ID号
        /// </summary>
        string alipaymid { get; set; }
        /// <summary>
        /// 交易密钥
        /// </summary>
        string alipaysec { get; set; }
        /// <summary>
        /// 支付宝邮箱
        /// </summary>
        string alipayacc { get; set; }
        /// <summary>
        /// 易宝商户ID号
        /// </summary>
        string yeepaymid { get; set; }
        /// <summary>
        /// 支付宝商户密钥
        /// </summary>
        string yeepaysec { get; set; }
        /// <summary>
        /// 网银在线商户ID
        /// </summary>
        string chinabankmid { get; set; }
        /// <summary>
        /// 网银在线交易密钥
        /// </summary>
        string chinabanksec { get; set; }
        /// <summary>
        /// 财付通商户ID
        /// </summary>
        string tenpaymid { get; set; }
        /// <summary>
        /// 财付通交易密钥
        /// </summary>
        string tenpaysec { get; set; }
        /// <summary>
        /// 快钱商户ID
        /// </summary>
        string billmid { get; set; }
        /// <summary>
        /// 快钱交易密钥
        /// </summary>
        string billsec { get; set; }
        /// <summary>
        /// Paypal商户ID
        /// </summary>
        string paypalmid { get; set; }
        /// <summary>
        /// Paypal交易密钥
        /// </summary>
        string paypalsec { get; set; }
        /// <summary>
        /// Smtp主机
        /// </summary>
        string mailhost { get; set; }
        /// <summary>
        /// Smtp端口
        /// </summary>
        string mailport { get; set; }
        /// <summary>
        /// Smtp用户名
        /// </summary>
        string mailuser { get; set; }
       
        /// <summary>
        /// Smtp密码
        /// </summary>
        string mailpass { get; set; }
        /// <summary>
        /// Smtp发信地址
        /// </summary>
        string mailfrom { get; set; }
        /// <summary>
        /// Smtp回信地址
        /// </summary>
        string mailreply { get; set; }

        /// <summary>
        /// 是否启用ssl加密方式发送
        /// </summary>
        int mailssl { get; set; }
        /// <summary>
        /// 发信频率
        /// </summary>
        int? mailinterval { get; set; }
        /// <summary>
        /// 订阅设置（发送邮件订阅时邮件内容中的联系方式）
        /// </summary>
        string subscribehelpphone { get; set; }
        /// <summary>
        /// 联系邮箱
        /// </summary>
        string subscribehelpemail { get; set; }
        /// <summary>
        /// 短信用户
        /// </summary>
        string smsuser { get; set; }
        /// <summary>
        /// 短信密码
        /// </summary>
        string smspass { get; set; }
        /// <summary>
        /// 点发频率
        /// </summary>
        int smsinterval { get; set; }
        /// <summary>
        /// 主题路径
        /// </summary>
        string skintheme { get; set; }
        /// <summary>
        /// 网站版本号
        /// </summary>
        decimal siteversion { get; set; }

        /// <summary>
        /// 腾讯微博客里链接
        /// </summary>
        string qqblog { get; set; }
        /// <summary>
        /// 新浪微博客链接
        /// </summary>
        string sinablog { get; set; }

        /// <summary>
        /// 工作时间
        /// </summary>
        string jobtime { get; set; }

        int freepost { get; set; }
        string sohuloginkey { get; set; }
        int enablesohulogin { get; set; }
        string title { get; set; }
        string keyword { get; set; }
        string description { get; set; }
        int gouwuche { get; set; }
        int needmoretuan { get; set; }
        int guowushu { get; set; }

        /// <summary>
        /// 团购电话
        /// </summary>
        string tuanphone { get; set; }
        /// <summary>
        /// 网站域名
        /// </summary>
        string domain { get; set; }
        /// <summary>
        /// iPhone桌面图标
        /// </summary>
        string iphone_icon { get; set; }
        /// <summary>
        /// iPhone桌面图标(高清)
        /// </summary>
        string iphone_retina_icon { get; set; }
        /// <summary>
        /// iPad桌面图标
        /// </summary>
        string ipad_icon { get; set; }
        /// <summary>
        /// iPad桌面图标(高清)
        /// </summary>
        string ipad_retina_icon { get; set; }
        /// <summary>
        /// iPhone4/4s启动画面
        /// </summary>
        string iphone4_startup { get; set; }
        /// <summary>
        /// iPhone5启动画面
        /// </summary>
        string iphone5_startup { get; set; }

    }
}
