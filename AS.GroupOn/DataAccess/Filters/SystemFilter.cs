using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class SystemFilter : FilterBase
    {
        /// <summary>
        /// 主键
        /// </summary>
        public int? id { get; set; }
        /// <summary>
        /// 网站名称
        /// </summary>
        public string sitename { get; set; }
        /// <summary>
        /// 网站标题
        /// </summary>
        public string sitetitle { get; set; }
        /// <summary>
        /// 网站简称
        /// </summary>
        public string abbreviation { get; set; }
        /// <summary>
        /// 优惠券名称
        /// </summary>
        public string couponname { get; set; }
        /// <summary>
        /// 货币符号
        /// </summary>
        public string currency { get; set; }
        /// <summary>
        /// 货币代码
        /// </summary>
        public string currencyname { get; set; }
        /// <summary>
        /// 邀请返利(邀请一次返利多少元)
        /// </summary>
        public decimal invitecredit { get; set; }
        /// <summary>
        /// 侧栏团购数
        /// </summary>
        public int sideteam { get; set; }
        /// <summary>
        /// 网站头部logo
        /// </summary>
        public string headlogo { get; set; }
        /// <summary>
        /// 网站底部logo
        /// </summary>
        public string footlogo { get; set; }
        /// <summary>
        /// 邮件订阅的logo
        /// </summary>
        public string emaillogo { get; set; }
        /// <summary>
        /// 打印页logo
        /// </summary>
        public string printlogo { get; set; }
        /// <summary>
        /// 成团条件1 以成功付款人数为限 0 以成交产品数量为限
        /// </summary>
        public int conduser { get; set; }
        /// <summary>
        /// 优惠券下载(1 商户可下载编号及密码，0 商户仅可下载编号)
        /// </summary>
        public int partnerdown { get; set; }
        /// <summary>
        /// 客服QQ
        /// </summary>
        public string kefuqq { get; set; }
        /// <summary>
        /// 客服MSN
        /// </summary>
        public string kefumsn { get; set; }
        /// <summary>
        /// ICP编号
        /// </summary>
        public string icp { get; set; }
        /// <summary>
        /// 统计代码
        /// </summary>
        public string statcode { get; set; }
        /// <summary>
        /// 导航栏是否显示品牌商户0不显示1显示 
        /// </summary>
        public int Navpartner { get; set; }
        /// <summary>
        /// 导航栏是否显示秒杀抢购0不显示1显示
        /// </summary>
        public int? navseconds { get; set; }
        /// <summary>
        /// 导航栏是否显示热销商品0不显示1显示
        /// </summary>
        public int? navgoods { get; set; }
        /// <summary>
        /// 导航栏是否显示讨论区 0不显示 1显示
        /// </summary>
        public int? navforum { get; set; }
        /// <summary>
        /// 失败团购显示(在往期团购中，是否显示失败的团购)0不显示1显示
        /// </summary>
        public int? Displayfailure { get; set; }
        /// <summary>
        /// 全部答疑显示(本单答疑栏目中，是否显示全部团购项目答疑)0不显示1显示
        /// </summary>
        public int? teamask { get; set; }
        /// <summary>
        /// 仅余额可秒杀(是否，秒杀项目是否仅允许余额付款)0是1否
        /// </summary>
        public int? creditseconds { get; set; }
        /// <summary>
        /// 开启短信订阅(是否开启短信订阅团购信息功能)0否 1是
        /// </summary>
        public int? smssubscribe { get; set; }
        /// <summary>
        /// 简体繁体转换(是否显示在线简体繁体转换链接) 0否 1是
        /// </summary>
        public int? trsimple { get; set; }
        /// <summary>
        /// 用户节省钱数(在团购列表页显示共为用户节省多少钱)0否 1是
        /// </summary>
        public int? moneysave { get; set; }
        /// <summary>
        /// 项目详情通栏(团购项目详情和商户信息通栏显示，不分左右两栏) 0不分 1分
        /// </summary>
        public int? teamwhole { get; set; }
        /// <summary>
        /// 整站混淆编号(将所有数字ID编码后显示) 0不混淆 1混淆
        /// </summary>
        public int? encodeid { get; set; }
        /// <summary>
        /// 往期团购(是否项目分类显示？) 0否 1是
        /// </summary>
        public int? cateteam { get; set; }
        /// <summary>
        /// 品牌商户1(是否商户分类显示？) 0否 1是
        /// </summary>
        public int? catepartner { get; set; }
        /// <summary>
        /// 品牌商户2(是否商户按城市显示) 0否 1是
        /// </summary>
        public int? citypartner { get; set; }
        /// <summary>
        /// 秒杀抢团(是否项目分类显示？)0否 1是
        /// </summary>
        public int? cateseconds { get; set; }
        /// <summary>
        /// 热销商品(是否项目分类显示？) 0否 1是
        /// </summary>
        public int? categoods { get; set; }
        /// <summary>
        /// 邮箱验证(用户注册时，是否必须进行邮箱验证) 0否 1是
        /// </summary>
        public int? emailverify { get; set; }
        /// <summary>
        /// 手机号码必填(用户注册时，是否必须必须输入合法的手机号码)0 否 1是
        /// </summary>
        public int? needmobile { get; set; }
        /// <summary>
        /// 全局公告
        /// </summary>
        public string gobalbulletin { get; set; }
        /// <summary>
        /// 城市公告(此处需要格式处理，暂不考虑)
        /// </summary>
        public string bulletin { get; set; }
        /// <summary>
        /// 支付宝商户ID号
        /// </summary>
        public string alipaymid { get; set; }
        /// <summary>
        /// 交易密钥
        /// </summary>
        public string alipaysec { get; set; }
        /// <summary>
        /// 支付宝邮箱
        /// </summary>
        public string alipayacc { get; set; }
        /// <summary>
        /// 易宝商户ID号
        /// </summary>
        public string yeepaymid { get; set; }
        /// <summary>
        /// 支付宝商户密钥
        /// </summary>
        public string yeepaysec { get; set; }
        /// <summary>
        /// 网银在线商户ID
        /// </summary>
        public string chinabankmid { get; set; }
        /// <summary>
        /// 网银在线交易密钥
        /// </summary>
        public string chinabanksec { get; set; }
        /// <summary>
        /// 财付通商户ID
        /// </summary>
        public string tenpaymid { get; set; }
        /// <summary>
        /// 财付通交易密钥
        /// </summary>
        public string tenpaysec { get; set; }
        /// <summary>
        /// 快钱商户ID
        /// </summary>
        public string billmid { get; set; }
        /// <summary>
        /// 快钱交易密钥
        /// </summary>
        public string billsec { get; set; }
        /// <summary>
        /// Paypal商户ID
        /// </summary>
        public string paypalmid { get; set; }
        /// <summary>
        /// Paypal交易密钥
        /// </summary>
        public string paypalsec { get; set; }
        /// <summary>
        /// Smtp主机
        /// </summary>
        public string mailhost { get; set; }
        /// <summary>
        /// Smtp端口
        /// </summary>
        public string mailport { get; set; }
        /// <summary>
        /// Smtp用户名
        /// </summary>
        public string mailuser { get; set; }
        /// <summary>
        /// Smtp密码
        /// </summary>
        public string mailpass { get; set; }

        /// <summary>
        /// Smtp发信地址
        /// </summary>
        public string mailfrom { get; set; }
        /// <summary>
        /// Smtp回信地址
        /// </summary>
        public string mailreply { get; set; }

        /// <summary>
        /// 是否启用ssl加密方式发送
        /// </summary>
        public int mailssl { get; set; }
        /// <summary>
        /// 发信频率
        /// </summary>
        public int? mailinterval { get; set; }
        /// <summary>
        /// 订阅设置（发送邮件订阅时邮件内容中的联系方式）
        /// </summary>
        public string subscribehelpphone { get; set; }
        /// <summary>
        /// 联系邮箱
        /// </summary>
        public string subscribehelpemail { get; set; }
        /// <summary>
        /// 短信用户
        /// </summary>
        public string smsuser { get; set; }
        /// <summary>
        /// 短信密码
        /// </summary>
        public string smspass { get; set; }
        /// <summary>
        /// 点发频率
        /// </summary>
        public int smsinterval { get; set; }
        /// <summary>
        /// 主题路径
        /// </summary>
        public string skintheme { get; set; }
        /// <summary>
        /// 网站版本号
        /// </summary>
        public decimal? siteversion { get; set; }

        /// <summary>
        /// 腾讯微博客里链接
        /// </summary>
        public string qqblog { get; set; }

        /// <summary>
        /// 新浪微博客链接
        /// </summary>
        public string sinablog { get; set; }

        /// <summary>
        /// 工作时间
        /// </summary>
        public string jobtime { get; set; }

        public  int freepost { get; set; }
        public  string sohuloginkey { get; set; }
        public  int enablesohulogin { get; set; }
        public  string title { get; set; }
        public  string keyword { get; set; }
        public  string description { get; set; }
        public  int gouwuche { get; set; }
        public  int needmoretuan { get; set; }
        public  int guowushu { get; set; }

        /// <summary>
        /// 团购电话
        /// </summary>

        public string tuanphone { get; set; }
        /// <summary>
        ///网站域名 
        /// </summary>
        public string domain { get; set; }

    }


}
