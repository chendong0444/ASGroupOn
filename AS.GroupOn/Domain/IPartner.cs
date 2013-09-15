using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 商户表
    /// </summary>
    public interface IPartner : IObj
    {
        /// <summary>
        /// 商户ID
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 商户用户名
        /// </summary>
        string Username { get; set; }
        /// <summary>
        /// 密码
        /// </summary>
        string Password { get; set; }
        /// <summary>
        /// 商户名称
        /// </summary>
        string Title { get; set; }
        /// <summary>
        /// 分类ID
        /// </summary>
        int Group_id { get; set; }
        /// <summary>
        /// 商户主页
        /// </summary>
        string Homepage { get; set; }
        /// <summary>
        /// 所属城市
        /// </summary>
        int City_id { get; set; }
        /// <summary>
        /// 开户行
        /// </summary>
        string Bank_name { get; set; }
        /// <summary>
        /// 银行账号
        /// </summary>
        string Bank_no { get; set; }
        /// <summary>
        /// 开户名
        /// </summary>
        string Bank_user { get; set; }
        /// <summary>
        /// 位置信息
        /// </summary>
        string Location { get; set; }
        /// <summary>
        /// 联系人
        /// </summary>
        string Contact { get; set; }
        /// <summary>
        /// 商户图片
        /// </summary>
        string Image { get; set; }
        /// <summary>
        /// 商户图片1
        /// </summary>
        string Image1 { get; set; }
        /// <summary>
        /// 商户图片2
        /// </summary>
        string Image2 { get; set; }
        /// <summary>
        /// 联系电话
        /// </summary>
        string Phone { get; set; }
        /// <summary>
        /// 地址
        /// </summary>
        string Address { get; set; }
        /// <summary>
        /// 其他信息
        /// </summary>
        string Other { get; set; }
        /// <summary>
        /// 手机号码
        /// </summary>
        string Mobile { get; set; }
        /// <summary>
        /// 商户秀 (为Y则在导航品牌商户里显示)
        /// </summary>
        string Open { get; set; }
        /// <summary>
        /// 是否激活 (如果不激活则不应该出现在所有的商户列表中)
        /// </summary>
        string Enable { get; set; }
        /// <summary>
        /// 置顶(值越大越靠前显示)
        /// </summary>
        int Head { get; set; }
        /// <summary>
        /// 会员ID(创建这条记录的管理员ID)
        /// </summary>
        int User_id { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        DateTime Create_time { get; set; }
        /// <summary>
        /// 商圈信息,多个之间用半角逗号分隔如(中关村,三里屯)
        /// </summary>
        string area { get; set; }
        /// <summary>
        /// 经纬度
        /// </summary>
        string point { get; set; }
        /// <summary>
        /// 商家消费密码
        /// </summary>
        string Secret { get; set; }
        /// <summary>
        /// 记录此商户是由哪个销售人员维护的销售人员ID
        /// </summary>
        string sale_id { get; set; }
        /// <summary>
        /// 记录是哪个销售人员id
        /// </summary>
        string saleid { get; set; }
        /// <summary>
        /// 400验证电话
        /// </summary>
        string verifymobile { get; set; }

        /// <summary>
        /// 销售人员
        /// </summary>
        ISales Sale { get; set; }
        /// <summary>
        /// 所属分类
        /// </summary>
        ICategory getTypeNameByGroupID { get; }

        ICategory getTypeNameByCityID { get; }
        /// <summary>
        /// 销售人员
        /// </summary>
        string getRealName { get; }
        /// <summary>
        /// 得到商户状态为待审核的count
        /// </summary>
        int getPartnerState { get; }

        /// <summary>
        /// 父商户id
        /// </summary>
        int parentId { get; set; }
    }
}
