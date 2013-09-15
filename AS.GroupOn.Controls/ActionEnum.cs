using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Controls
{
    /// <summary>
    /// 管理员操作枚举
    /// </summary>
    public enum ActionEnum
    {

        /// <summary>
        /// 查看项目咨询列表权限
        /// </summary>
        Option_TeamAsk_ListView = 1,

        /// <summary>
        ///  编辑项目咨询列表权限
        /// </summary>
        Option_TeamAsk_Edit = 2,

        /// <summary>
        /// 回复项目咨询权限
        /// </summary>
        Option_TeamAsk_Reply = 3,


        /// <summary>
        /// 删除项目咨询权限
        /// </summary>
        Option_TeamAsk_Delete = 4,

        /// <summary>
        /// 查看反馈列表权限
        /// </summary>
        Option_FeedBack_ListView = 5,

        /// <summary>
        /// 处理反馈信息权限
        /// </summary>
        Option_FeedBack_Handle = 6,


        /// <summary>
        /// 删除反馈信息权限
        /// </summary>
        Option_FeedBack_Delete = 7,

        /// <summary>
        /// 查看商户合作列表权限
        /// </summary>
        Option_Business_ListView = 8,

        /// <summary>
        /// 处理商户合作信息权限
        /// </summary>
        Option_Business_Handle = 9,


        /// <summary>
        /// 删除商户合作信息权限
        /// </summary>
        Option_Business_Delete = 10,


        /// <summary>
        /// 查看产品评论权限
        /// </summary>
        Option_TeamComment_ListView = 11,

        /// <summary>
        /// 处理产品评论权限
        /// </summary>
        Option_TeamComment_Handle = 12,


        /// <summary>
        /// 删除产品评论权限
        /// </summary>
        Option_TeamComment_Delete = 13,


        /// <summary>
        /// 查看商户评论权限
        /// </summary>
        Option_PartnerComment_ListView = 14,

        /// <summary>
        /// 处理商户评论权限
        /// </summary>
        Option_PartnerComment_Handle = 15,

        /// <summary>
        /// 删除商户评论权限
        /// </summary>
        Option_PartnerComment_Delete = 16,

        /// <summary>
        /// 查看邮件订阅
        /// </summary>
        Option_EmailSubscribe_ListView = 17,

        /// <summary>
        /// 删除邮件订阅
        /// </summary>
        Option_EmailSubscribe_Delete = 18,

        /// <summary>
        /// 查看短信订阅列表
        /// </summary>
        Option_SmsSubscribe_ListView = 19,

        /// <summary>
        /// 删除短信订阅列表
        /// </summary>
        Option_SmsSubscribe_Delete = 20,

        /// <summary>
        /// 查看邀请记录列表
        /// </summary>
        Option_Invite_ListView = 21,

        /// <summary>
        /// 确认邀请信息
        /// </summary>
        Option_Invite_Handle = 22,

        /// <summary>
        /// 取消邀请信息
        /// </summary>
        Option_Invite_Cancle = 23,


        /// <summary>
        /// 查看返利日志列表信息
        /// </summary>
        Option_Rebate_ListView = 24,

        /// <summary>
        /// 查看违规记录
        /// </summary>
        Option_Invite_ErrorOperation = 25,

        /// <summary>
        /// 查看邀请统计列表
        /// </summary>
        Option_Invite_TongjiList = 26,

        /// <summary>
        /// 查看邀请统计详情
        /// </summary>
        Option_Invite_TongjiDetail = 27,

        /// <summary>
        /// 查看线下充值日志列表
        /// </summary>
        Option_Flow_ChargeLog_BelowLine_ListView = 28,

        /// <summary>
        /// 查看在线充值日志列表
        /// </summary>
        Option_Flow_ChargeLog_OnLine_ListView = 29,

        /// <summary>
        /// 查看现金支付
        /// </summary>
        Option_Flow_Cash_ListView = 30,

        /// <summary>
        /// 查看退款记录
        /// </summary>
        Option_Flow_Refund = 31,

        /// <summary>
        /// 签名记录
        /// </summary>
        Option_Flow_Sign = 32,

        /// <summary>
        /// 查看红包权限
        /// </summary>
        Option_Flow_Money = 33,

        /// <summary>
        /// 查看返余额权限
        /// </summary>
        Option_Flow_BackAmount = 34,

        /// <summary>
        /// 查看在线购买权限
        /// </summary>
        Option_Flow_Buy = 35,

        /// <summary>
        /// 查看优惠券返利权限
        /// </summary>
        Option_Flow_Coupon = 36,

        /// <summary>
        /// 查看提现日志权限
        /// </summary>
        Option_Flow_WithDraw = 37,

        /// <summary>
        /// 查看评价返利权限
        /// </summary>
        Option_Flow_Review = 38,

        /// <summary>
        /// 查看友情列表权限
        /// </summary>
        Option_FriendLink_ListView = 39,

        /// <summary>
        /// 添加友情连接权限
        /// </summary>
        Option_FriendLink_Add = 40,

        /// <summary>
        /// 编辑友情连接权限
        /// </summary>
        Option_FriendLink_Edit = 41,

        /// <summary>
        /// 删除友情连接权限
        /// </summary>
        Option_FriendLink_Delete = 42,

        /// <summary>
        /// 数据备份权限
        /// </summary>
        Option_Data_Backup = 43,

        /// <summary>
        /// 数据操作权限
        /// </summary>
        Option_Data_Recovery = 44,

        /// <summary>
        /// 查看产品列表信息
        /// </summary>
        Option_Product_ListView = 45,

        /// <summary>
        /// 查看产品详情
        /// </summary>
        Option_Product_DetailView = 46,

        /// <summary>
        /// 编辑产品权限
        /// </summary>
        Option_Product_Edit = 47,

        /// <summary>
        /// 删除产品权限
        /// </summary>
        Option_Product_Delete = 48,

        /// <summary>
        /// 审核产品权限
        /// </summary>
        Option_Product_Examine = 49,

        /// <summary>
        /// 产品出入库权限
        /// </summary>
        Option_Product_Storage = 50,

        /// <summary>
        /// 产品添加权限
        /// </summary>
        Option_Product_Add = 51,

        /// <summary>
        /// 查看当前项目列表
        /// </summary>
        Option_Team_CurrentListView = 52,

        /// <summary>
        /// 查看项目详情
        /// </summary>
        Option_Team_Detail = 53,

        /// <summary>
        /// 编辑项目权限
        /// </summary>
        Option_Team_Ediit = 54,

        /// <summary>
        /// 删除项目权限
        /// </summary>
        Option_Team_Delete = 55,

        /// <summary>
        /// 复制项目权限
        /// </summary>
        Option_Team_Copy = 56,

        /// <summary>
        /// 下载项目权限
        /// </summary>
        Option_Team_Down = 57,

        /// <summary>
        /// 复制项目到商城权限
        /// </summary>
        Option_Team_CopyToMall = 58,

        /// <summary>
        /// 项目出入库权限
        /// </summary>
        Option_Team_Storage = 59,

        /// <summary>
        /// 导入站外券的权限
        /// </summary>
        Option_Team_AddPCoupon = 60,

        /// <summary>
        /// 抽奖信息
        /// </summary>
        Option_Team_Draw = 61,

        /// <summary>
        /// 查看未开始的项目
        /// </summary>
        Option_Team_NoStart = 62,

        /// <summary>
        /// 查看成功项目列表
        /// </summary>
        Option_Team_Succes = 63,

        /// <summary>
        /// 查看失败项目列表
        /// </summary>
        Option_Team_Failure = 64,

        /// <summary>
        /// 新建项目权限
        /// </summary>
        Option_Team_Add = 65,

        /// <summary>
        /// 查看商城项目列表
        /// </summary>
        Option_MallTeam_ListView = 66,

        /// <summary>
        /// 查看商城项目详情
        /// </summary>
        Option_MallTeam_DetailView = 67,

        /// <summary>
        /// 编辑商城项目信息
        /// </summary>
        Option_MallTeam_Edit = 68,

        /// <summary>
        /// 删除商城项目权限
        /// </summary>
        Option_MallTeam_Delete = 69,

        /// <summary>
        /// 商城项目复制到团购
        /// </summary>
        Option_MallTeam_CopyToTuanGou = 70,

        /// <summary>
        /// 下载商城项目权限
        /// </summary>
        Option_MallTeam_Down = 71,

        /// <summary>
        /// 商场项目是否前台显示的权限
        /// </summary>
        Option_MallTeam_Display = 72,

        /// <summary>
        /// 商城项目出入库
        /// </summary>
        Option_MallTeam_Strage = 73,

        /// <summary>
        /// 商城项目新增权限
        /// </summary>
        Option_MallTeam_Add = 74,

        /// <summary>
        /// 查看商城设置
        /// </summary>
        Option_Mall_SetView = 75,

        /// <summary>
        /// 修改商城设置权限
        /// </summary>
        Option_Mall_SetEdit = 76,

        /// <summary>
        /// 查看商城项目分类列表
        /// </summary>
        Option_MallTeamCata_ListView = 77,

        /// <summary>
        /// 新建商城项目分类
        /// </summary>
        Option_MallTeamCata_Add = 78,

        /// <summary>
        /// 编辑商城项目分类
        /// </summary>
        Option_MallTeamCata_Edit = 79,

        /// <summary>
        /// 删除商城项目分类
        /// </summary>
        Option_MallTeamCata_Delete = 80,

        /// <summary>
        /// 查看商城导航列表信息
        /// </summary>
        Option_MallGuid_ViewList = 81,

        /// <summary>
        /// 新增商城导航信息
        /// </summary>
        Option_MallGuid_Add = 82,


        /// <summary>
        /// 编辑商城导航信息
        /// </summary>
        Option_MallGuid_Edit = 83,

        /// <summary>
        /// 删除商城导航信息
        /// </summary>
        Option_MallGuid_Delete = 84,

        /// <summary>
        /// 查看订单列表
        /// </summary>
        Option_Order_ListView = 85,

        /// <summary>
        /// 查看订单详情权限
        /// </summary>
        Option_Order_Detail = 86,

        /// <summary>
        /// 订单现金付款权限
        /// </summary>
        Option_Order_Cash = 87,

        /// <summary>
        /// 删除订单权限
        /// </summary>
        Option_Order_Delete = 88,

        /// <summary>
        /// 查看付款订单列表
        /// </summary>
        Option_Order_Pay_ListView = 89,

        /// <summary>
        /// 查看未付款订单列表
        /// </summary>
        Option_Order_UnPay_ListView = 90,

        /// <summary>
        /// 查看取消订单列表
        /// </summary>
        Option_Order_Cancle_ListView = 91,

        /// <summary>
        /// 查看审核退款订单列表
        /// </summary>
        Option_Order_RefundAudit_ListView = 92,

        /// <summary>
        /// 订单审核退款信息(订单管理员)
        /// </summary>
        Option_Order_RefundAudit_AdminAudit = 93,

        /// <summary>
        /// 查看退款(退款中)订单列表
        /// </summary>
        Option_Order_Refund_Refunding = 94,

        /// <summary>
        /// 查看退款订单详情
        /// </summary>
        Option_Order_Refund_Detail = 95,

        /// <summary>
        /// 查看处理订单列表
        /// </summary>
        Option_Order_Refund_Processing_ListView = 96,

        /// <summary>
        /// 财务处理退款订单
        /// </summary>
        Option_Order_Refund_ProcessingCaiwu = 97,

        /// <summary>
        /// 财务接受订单退款
        /// </summary>
        Option_Order_Refund_ProcessingCaiwu_Accept = 98,

        /// <summary>
        /// 查看财务处理订单详情
        /// </summary>
        Option_Order_Refund_ProcessingCaiwu_Detail = 99,

        /// <summary>
        /// 删除订单退款记录
        /// </summary>
        Option_Order_Refund_Delete = 100,


        /// <summary>
        /// 查看成功退款订单列表
        /// </summary>
        Option_Order_Refund_Success_ListView = 101,


        /// <summary>
        /// 查看未选择快递公司订单列表
        /// </summary>
        Option_Order_Express_ExpressCompany_NoSelectList = 102,

        /// <summary>
        /// 批量选择快递公司
        /// </summary>
        Option_Order_Express_ExpressCompany_SelectAll = 103,

        /// <summary>
        /// 选择快递公司
        /// </summary>
        Option_Order_Express_ExpressCompany_SelectOne = 104,

        /// <summary>
        /// 未打印快递订单列表
        /// </summary>
        Option_Order_Express_Print_NoPrintList = 105,

        /// <summary>
        /// 打印快递单
        /// </summary>
        Option_Order_Express_Print = 106,

        /// <summary>
        /// 发货：未打印订单详情中
        /// </summary>
        Option_Order_Express_NoPrintDetail_Delivery = 107,

        /// <summary>
        /// 已发货订单列表
        /// </summary>
        Option_Order_Express_DeliveryYes_ListView = 108,

        /// <summary>
        /// 查看已发货订单详情
        /// </summary>
        Option_Order_Express_DeliveryYes_Detail = 109,

        /// <summary>
        /// 未发货订单列表
        /// </summary>
        Option_Order_Express_DeliveryNo_ListView = 110,

        /// <summary>
        /// 未发货订单详情
        /// </summary>
        Option_Order_Express_DeliveryNo_Detail = 111,

        /// <summary>
        /// 批量上传快递单
        /// </summary>
        Option_Order_Express_UploadExpressCode = 112,


        /// <summary>
        /// 确认订单付款（货到付款）
        /// </summary>
        Option_Order_Express_OCD_ConfirmationCash = 113,

        /// <summary>
        /// 已完成订单列表（货到付款）
        /// </summary>
        Option_Order_Express_OCD_FinishOrderList = 114,

        /// <summary>
        /// 站内券列表
        /// </summary>
        Option_Coupon_ListView = 115,

        /// <summary>
        /// 发送短信（优惠券信息）
        /// </summary>
        Option_Coupon_SendSms = 116,

        /// <summary>
        /// 优惠券详情（站内券）
        /// </summary>
        Option_Coupon_Detail = 117,

        /// <summary>
        /// 站内券消费
        /// </summary>
        Option_Coupon_Consum = 118,

        /// <summary>
        /// 站外券列表
        /// </summary>
        Option_CouponP_Listview = 119,

        /// <summary>
        /// 站外券发送短信
        /// </summary>
        Option_CouponP_SendSms = 120,

        /// <summary>
        /// 站外券详情
        /// </summary>
        Option_CouponP_Detail = 121,

        /// <summary>
        /// 编辑站外券
        /// </summary>
        Option_CouponP_Edit = 122,

        /// <summary>
        /// 删除站外券
        /// </summary>
        Option_CouponP_Delete = 123,

        /// <summary>
        /// 代金券列表
        /// </summary>
        Option_Card_List = 124,

        /// <summary>
        /// 删除代金券
        /// </summary>
        Option_Card_Delete = 125,

        /// <summary>
        /// 下载代金券
        /// </summary>
        Option_Card_Down = 126,

        /// <summary>
        /// txt下载代金券
        /// </summary>
        Option_Card_DownToTxt = 127,

        /// <summary>
        /// 新增代金券
        /// </summary>
        Option_Card_Add = 128,

        /// <summary>
        /// 查看用户列表
        /// </summary>
        Option_User_ListView = 129,

        /// <summary>
        /// 用户详情
        /// </summary>
        Option_User_Detail = 130,

        /// <summary>
        /// 编辑用户
        /// </summary>
        Option_User_Edit = 131,
        /// <summary>
        /// 用户删除
        /// </summary>
        Option_User_Delete = 132,

        /// <summary>
        /// 管理员列表
        /// </summary>
        Option_Admin_List = 133,

        /// <summary>
        /// 编辑管理员
        /// </summary>
        Option_Admin_Edit = 134,

        /// <summary>
        /// 管理员授权
        /// </summary>
        Option_Admin_Author = 135,

        /// <summary>
        /// 销售人员列表
        /// </summary>
        Option_Sale_List = 136,


        /// <summary>
        /// 添加销售人员
        /// </summary>
        Option_Sale_Add = 137,


        /// <summary>
        /// 删除销售人员
        /// </summary>
        Option_Sale_Delete = 138,

        /// <summary>
        /// 编辑销售人员
        /// </summary>
        Option_Sale_Edit = 139,

        /// <summary>
        /// 绑定项目
        /// </summary>
        Option_Sale_BindTeam = 140,

        /// <summary>
        /// 角色授权
        /// </summary>
        Option_Role_Author = 141,

        /// <summary>
        /// 角色列表
        /// </summary>
        Option_Role_List = 142,

        /// <summary>
        /// 添加角色
        /// </summary>
        Option_Role_Add = 143,

        /// <summary>
        /// 编辑角色
        /// </summary>
        Option_Role_Edit = 144,

        /// <summary>
        /// 删除角色
        /// </summary>
        Option_Role_Delete = 145,

        /// <summary>
        /// 商户列表
        /// </summary>
        Option_Partner_List = 146,

        /// <summary>
        /// 编辑商户信息
        /// </summary>
        Option_Partner_Edit = 147,

        /// <summary>
        /// 删除商户
        /// </summary>
        Option_Partner_Delete = 148,

        /// <summary>
        /// 分店列表
        /// </summary>
        Option_Branch_List = 149,

        /// <summary>
        /// 编辑分店
        /// </summary>
        Option_Branch_Edit = 150,

        /// <summary>
        ///删除分店
        /// </summary>
        Option_Branch_Delete = 151,

        /// <summary>
        /// 添加分站
        /// </summary>
        Option_Branch_Add = 152,

        /// <summary>
        /// 商家结算解基本信息
        /// </summary>
        Option_Partner_JiesuanBasicInfo = 153,

        /// <summary>
        /// 商家结算详情列表
        /// </summary>
        Option_Partner_JiesuanDetailList = 154,

        /// <summary>
        /// 商户结算
        /// </summary>
        Option_Partner_Jiesuan = 155,

        /// <summary>
        /// 删除商家结算信息
        /// </summary>
        Option_Partner_Jiesuan_Delete = 156,

        /// <summary>
        /// 审核结算信息
        /// </summary>
        Option_Partner_Jiesuan_Examine = 157,

        /// <summary>
        /// 结算详情
        /// </summary>
        Option_Partnet_JiesuanDetail = 158,

        /// <summary>
        /// 新建商户
        /// </summary>
        Option_Partner_Add = 159,

        /// <summary>
        /// 发送普通邮件（营销）
        /// </summary>
        Option_YX_EmailGeneral_Send = 160,

        /// <summary>
        /// 群发邮件列表
        /// </summary>
        Option_YX_EmailMany_List = 161,

        /// <summary>
        /// 新建群发邮件
        /// </summary>
        Option_YX_EmailMany_Add = 162,

        /// <summary>
        /// 编辑群发邮件
        /// </summary>
        Option_YX_EmailMany_Edit = 163,


        /// <summary>
        /// 删除群发邮件
        /// </summary>
        Option_YX_EmailMany_Delete = 164,


        /// <summary>
        /// 群发邮件发送
        /// </summary>
        Option_YX_EmailMany_Send = 165,

        /// <summary>
        /// 短信群发
        /// </summary>
        Option_YX_SMSMany_Send = 166,

        /// <summary>
        /// 手机号码下载
        /// </summary>
        Option_YX_Download_Mobile = 167,

        /// <summary>
        /// 邮件地址下载
        /// </summary>
        Option_YX_Download_Email = 168,

        /// <summary>
        /// 项目订单下载
        /// </summary>
        Option_YX_Download_Order = 169,

        /// <summary>
        /// 项目优惠券下载
        /// </summary>
        Option_YX_Download_Coupon = 170,

        /// <summary>
        /// 用户信息下载
        /// </summary>
        Option_YX_Download_UserInfo = 171,


        /// <summary>
        /// 红包派发
        /// </summary>
        Option_YX_Packet_Send = 172,

        /// <summary>
        /// 促销活动列表
        /// </summary>
        Option_YX_CXHD_List = 173,

        /// <summary>
        /// 添加促销活动
        /// </summary>
        Option_YX_CXHD_Add = 174,

        /// <summary>
        /// 删除促销活动
        /// </summary>
        Option_YX_CXHD_Delete = 175,

        /// <summary>
        /// 编辑促销活动
        /// </summary>
        Option_YX_CXHD_Edit = 176,

        /// <summary>
        /// 促销活动详情
        /// </summary>
        Option_YX_CXHD_Detail = 177,

        /// <summary>
        /// 促销活动规则列表
        /// </summary>
        Option_YX_CXHD_RuleList = 178,

        /// <summary>
        /// 添加促销活动规则信息
        /// </summary>
        Option_YX_CXHD_RuleAdd = 179,

        /// <summary>
        /// 删除促销活动规则信息
        /// </summary>
        Option_YX_CXHD_RuleDelete = 180,

        /// <summary>
        /// 编辑活动规则信息
        /// </summary>
        Option_YX_CXHD_RuleEdit = 181,
        /// <summary>
        /// 促销活动规则信息
        /// </summary>
        Option_YX_CXHD_RuleDetail = 182,

        /// <summary>
        /// 城市列表
        /// </summary>
        Option_Category_City_List = 183,

        /// <summary>
        ///新建城市
        /// </summary>
        Option_Category_City_Add = 184,


        /// <summary>
        /// 编辑城市
        /// </summary>
        Option_Category_City_Edit = 185,

        /// <summary>
        /// 删除城市
        /// </summary>
        Option_Category_City_Delete = 186,

        /// <summary>
        /// 城市公告
        /// </summary>
        Option_Category_City_Announce = 187,

        /// <summary>
        /// 子城市列表
        /// </summary>
        Option_Category_CityChild_List = 188,

        /// <summary>
        /// 添加子城市
        /// </summary>
        Option_Category_CityChild_Add = 189,

        /// <summary>
        /// 编辑子城市
        /// </summary>
        Option_Category_CityChild_Edit = 190,

        /// <summary>
        /// 删除子城市
        /// </summary>
        Option_Category_CityChild_Delete = 191,

        /// <summary>
        /// 子城市广告
        /// </summary>
        Option_Category_CityChild_Announce = 192,

        /// <summary>
        /// 城市分组列表
        /// </summary>
        Option_Category_CityGroup_List = 193,

        /// <summary>
        /// 新建城市分组
        /// </summary>
        Option_Category_CityGroup_Add = 194,

        /// <summary>
        /// 编辑城市分组
        /// </summary>
        Option_Category_CityGroup_Edit = 195,

        /// <summary>
        /// 删除城市分组
        /// </summary>
        Option_Category_CityGroup_Delete = 196,

        /// <summary>
        /// 区域商圈列表
        /// </summary>
        Option_Category_Area_List = 197,

        /// <summary>
        /// 新建区域商圈
        /// </summary>
        Option_Category_Area_Add = 198,

        /// <summary>
        /// 编辑区域商圈
        /// </summary>
        Option_Category_Area_Edit = 199,

        /// <summary>
        /// 删除区域商圈
        /// </summary>
        Option_Category_Area_Delete = 200,

        /// <summary>
        /// 商圈列表
        /// </summary>
        Option_Category_Area_Circle_List = 201,

        /// <summary>
        /// 添加商圈列表
        /// </summary>
        Option_Category_Area_Circle_Add = 202,

        /// <summary>
        /// 编辑商圈
        /// </summary>
        Option_Category_Area_Circle_Edit = 203,

        /// <summary>
        /// 删除商圈
        /// </summary>
        Option_Category_Area_Circle_Delete = 204,


        /// <summary>
        /// 项目分类列表
        /// </summary>
        Option_Category_Team_List = 205,

        /// <summary>
        /// 新建项目分类
        /// </summary>
        Option_Category_Team_Add = 206,

        /// <summary>
        /// 编辑项目分类
        /// </summary>
        Option_Category_Team_Edit = 207,

        /// <summary>
        /// 删除项目分类
        /// </summary>
        Option_Category_Team_Delete = 208,


        /// <summary>
        /// api分类列表
        /// </summary>
        Option_Category_Api_List = 209,

        /// <summary>
        /// 新建api分类
        /// </summary>
        Option_Category_Api_Add = 210,

        /// <summary>
        /// 编辑api分类
        /// </summary>
        Option_Category_Api_Edit = 211,

        /// <summary>
        /// 删除api分类
        /// </summary>
        Option_Category_Api_Delete = 212,

        /// <summary>
        /// 新建子APi分类
        /// </summary>
        Option_Category_Api_AddChild = 213,

        /// <summary>
        /// 讨论区分类列表
        /// </summary>
        Option_Category_Topic_List = 214,

        /// <summary>
        /// 新建讨论区分类
        /// </summary>
        Option_Category_Topic_Add = 215,

        /// <summary>
        /// 编辑讨论区分类
        /// </summary>
        Option_Category_Topic_Edit = 216,

        /// <summary>
        /// 删除讨论区分类
        /// </summary>
        Option_Category_Topic_Delete = 217,

        /// <summary>
        /// 用户等级列表
        /// </summary>
        Option_Category_UserLeve_List = 218,

        /// <summary>
        /// 新建用户等级
        /// </summary>
        Option_Category_UserLeve_Add = 219,

        /// <summary>
        /// 编辑用户等级
        /// </summary>
        Option_Category_UserLeve_Edit = 220,

        /// <summary>
        /// 删除用户等级
        /// </summary>
        Option_Category_UserLeve_Delete = 221,

        /// <summary>
        /// 商户分类列表
        /// </summary>
        Option_Category_Partner_List = 222,

        /// <summary>
        /// 新建商户分类
        /// </summary>
        Option_Category_Partner_Add = 223,

        /// <summary>
        /// 编辑商户分类
        /// </summary>
        Option_Category_Partner_Edit = 224,

        /// <summary>
        /// 删除商户分类
        /// </summary>
        Option_Category_Partner_Delete = 225,


        /// <summary>
        /// 品牌分类列表
        /// </summary>
        Option_Category_Brand_List = 226,

        /// <summary>
        /// 新建品牌分类
        /// </summary>
        Option_Category_Brand_Add = 227,

        /// <summary>
        /// 编辑品牌分类
        /// </summary>
        Option_Category_Brand_Edit = 228,

        /// <summary>
        /// 删除品牌分类
        /// </summary>
        Option_Category_Brand_Delete = 229,

        /// <summary>
        /// 问题调查数据统计
        /// </summary>
        Option_DiaoCha_DataDisplay = 230,

        /// <summary>
        /// 问题反馈列表信息
        /// </summary>
        Option_DiaoCha_Feedback_List = 231,

        /// <summary>
        /// 问题选项反馈列表
        /// </summary>
        Option_DiaoCha_Feedback_OptionList = 232,

        /// <summary>
        /// 问题选项详情反馈列表
        /// </summary>
        Option_DiaoCha_Feedback_OptionDetailList = 233,

        /// <summary>
        /// 问题列表
        /// </summary>
        Option_DiaoCha_Problem_List = 234,


        /// <summary>
        /// 添加问题
        /// </summary>
        Option_DiaoCha_Problem_Add = 235,

        /// <summary>
        /// 编辑问题
        /// </summary>
        Option_DiaoCha_Problem_Edit = 236,

        /// <summary>
        /// 删除问题
        /// </summary>
        Option_DiaoCha_Problem_Delete = 237,

        /// <summary>
        /// 显示问题
        /// </summary>
        Option_DiaoCha_Problem_Display = 238,

        /// <summary>
        /// 问题选项列表
        /// </summary>
        Option_DiaoCha_Problem_Option_List = 239,


        /// <summary>
        /// 新建问题选项
        /// </summary>
        Option_DiaoCha_Problem_Option_Add = 240,

        /// <summary>
        /// 是否显示问题选项
        /// </summary>
        Option_DiaoCha_Problem_Option_Display = 241,

        /// <summary>
        /// 编辑问题选项
        /// </summary>
        Option_DiaoCha_Problem_Option_Edit = 242,

        /// <summary>
        /// 删除问题选项
        /// </summary>
        Option_DiaoCha_Problem_Option_Delete = 243,

        /// <summary>
        /// 基本设置
        /// </summary>
        Option_SetTg_Jiben = 244,

        /// <summary>
        ///选项设置
        /// </summary>
        Option_SetTg_XuanXiang = 245,

        /// <summary>
        /// 团购导航列表
        /// </summary>
        Option_SetTg_Guid_List = 246,

        /// <summary>
        /// 新建团购导航
        /// </summary>
        Option_SetTg_Guid_Add = 247,

        /// <summary>
        /// 编辑团购导航
        /// </summary>
        Option_SetTg_Guid_Edit = 248,

        /// <summary>
        /// 删除团购导航
        /// </summary>
        Option_SetTg_Guid_Delete = 249,

        /// <summary>
        /// 全局广告设置
        /// </summary>
        Option_SetTg_Advertisement_AllPosition = 250,

        /// <summary>
        /// 支付方式设置
        /// </summary>
        Option_Set_PayMode = 251,

        /// <summary>
        /// 普通邮件设置
        /// </summary>
        Option_Set_Email_General = 252,

        /// <summary>
        /// 群发邮件服务设置列表
        /// </summary>
        Option_Set_Email_SentManyService_List = 253,

        /// <summary>
        /// 添加群发邮件服务设置
        /// </summary>
        Option_Set_Email_SentManyService_Add = 254,

        /// <summary>
        /// 编辑群发邮件服务设置
        /// </summary>
        Option_Set_Email_SentManyService_Edit = 255,

        /// <summary>
        /// 删除群发邮件服务设置
        /// </summary>
        Option_Set_Email_SentManyService_Delete = 256,

        /// <summary>
        /// 群发邮件发送测试
        /// </summary>
        Option_Set_Email_SentManyService_TestSend = 257,

        /// <summary>
        /// 网站短信帐号设置
        /// </summary>
        Option_Set_Sms_Account = 258,

        /// <summary>
        /// 网站短信模板设置
        /// </summary>
        Option_Set_Sms_Template = 259,

        /// <summary>
        /// 网站页面编辑
        /// </summary>
        Option_Set_Page = 260,

        /// <summary>
        /// 设置网站皮肤
        /// </summary>
        Option_Set_Skin = 261,

        /// <summary>
        /// 广告位列表
        /// </summary>
        Option_Set_Add_List = 262,

        /// <summary>
        /// 添加首页广告位
        /// </summary>
        Option_Set_Add_AddIndex = 263,


        /// <summary>
        /// 添加右侧广告位列表
        /// </summary>
        Option_Set_Add_AddRight = 264,

        /// <summary>
        /// 编辑广告位
        /// </summary>
        Option_Set_Add_Edit = 265,

        /// <summary>
        /// 删除广告位
        /// </summary>
        Option_Set_Add_Delete = 266,

        /// <summary>
        /// 一站通设置
        /// </summary>
        Option_Set_Yizhantong = 267,

        /// <summary>
        /// UC设置
        /// </summary>
        Option_Set_UC = 268,

        /// <summary>
        /// CPS设置
        /// </summary>
        Option_Set_CPS = 269,

        /// <summary>
        /// 网站升级
        /// </summary>
        Option_Set_Upgrade = 270,

        /// <summary>
        /// 上传项目图片列表
        /// </summary>
        Option_TeamImg_UploadList = 271,

        /// <summary>
        /// 删除项目图片目录
        /// </summary>
        Option_TeamImg_DeleteDir = 272,

        /// <summary>
        /// 查看项目图片
        /// </summary>
        Option_TeamImg_Display = 273,

        /// <summary>
        /// 删除项目图片
        /// </summary>
        Option_TeamImg_Delete = 274,

        /// <summary>
        /// 图片列表
        /// </summary>
        Option_Image_List = 275,

        /// <summary>
        /// 上传图片
        /// </summary>
        Option_Image_Upload = 276,

        /// <summary>
        /// 删除图片
        /// </summary>
        Option_Image_Delete = 277,

        /// <summary>
        /// 积分列表
        /// </summary>
        Option_Score_List = 278,

        /// <summary>
        /// 积分规则
        /// </summary>
        Option_Score_Set = 279,

        /// <summary>
        /// 积分订单列表
        /// </summary>
        Option_Score_OrderList = 280,

        /// <summary>
        /// 积分订单详情
        /// </summary>
        Option_Score_OrderDetail = 281,

        /// <summary>
        /// 删除积分订单
        /// </summary>
        Option_Score_OrderDelete = 282,

        /// <summary>
        /// 上架积分项目
        /// </summary>
        Option_Score_TeamBeginList = 283,

        /// <summary>
        /// 积分项目详情
        /// </summary>
        Option_Score_TeamBeginDetail = 284,

        /// <summary>
        /// 编辑上架积分项目
        /// </summary>
        Option_Score_TeamBeginEdit = 285,

        /// <summary>
        /// 删除上架积分项目
        /// </summary>
        Option_Score_TeamBeginDelete = 286,

        /// <summary>
        /// 复制上架积分项目
        /// </summary>
        Option_Score_TeamBeginCopy = 287,


        /// <summary>
        /// 上架积分项目出入库
        /// </summary>
        Option_Score_TeamBeginStorage = 288,

        /// <summary>
        /// 下架积分列表
        /// </summary>
        Option_Score_TeamOverList = 289,

        /// <summary>
        /// 下架积分项目详情
        /// </summary>
        Option_Score_TeamOverDetail = 290,

        /// <summary>
        /// 编辑下架积分项目
        /// </summary>
        Option_Score_TeamOverEdit = 291,

        /// <summary>
        /// 删除下架积分项目
        /// </summary>
        Option_Score_TeamOverDelete = 292,

        /// <summary>
        /// 复制下架积分项目
        /// </summary>
        Option_Score_TeamOverCopy = 293,

        /// <summary>
        /// 下架积分项目入库
        /// </summary>
        Option_Score_TeamOverStorage = 294,

        /// <summary>
        /// 用户注册统计
        /// </summary>
        Option_TJ_UserReister = 295,


        /// <summary>
        /// 用户注册统计下载
        /// </summary>
        Option_TJ_UserReisterDown = 296,

        /// <summary>
        /// 用户订单统计
        /// </summary>
        Option_TJ_UserOrder = 297,

        /// <summary>
        /// 用户订单统计下载
        /// </summary>
        Option_TJ_UserOrderDown = 298,

        /// <summary>
        /// 订单统计
        /// </summary>
        Option_TJ_Order = 299,

        /// <summary>
        /// 订单统计下载
        /// </summary>
        Option_TJ_OrderDown = 300,

        /// <summary>
        /// 项目统计
        /// </summary>
        Option_TJ_Team = 301,

        /// <summary>
        /// 项目统计下载
        /// </summary>
        Option_TJ_TeamDown = 302,

        /// <summary>
        /// 打印模板列表
        /// </summary>
        Option_PrintTemplate = 303,

        /// <summary>
        /// 打印模板详情
        /// </summary>
        Option_PrintTemplateDetail = 304,

        /// <summary>
        /// 新建打印模板详情
        /// </summary>
        Option_PrintTemplateAdd = 305,

        /// <summary>
        /// 删除打印模板详情
        /// </summary>
        Option_PrintTemplateDelete = 306,

        /// <summary>
        /// 发件人设置
        /// </summary>
        Option_PrintTemplate_UserSend = 307,

        /// <summary>
        /// 物流城市列表
        /// </summary>
        Option_LogisticsCity_List = 308,

        /// <summary>
        /// 添加物流城市
        /// </summary>
        Option_LogisticsCity_Add = 309,

        /// <summary>
        /// 编辑物流城市
        /// </summary>
        Option_LogisticsCity_Edit = 310,

        /// <summary>
        /// 删除物流城市及子城市
        /// </summary>
        Option_LogisticsCity_Delete = 311,

        /// <summary>
        /// 运费模板列表
        /// </summary>
        Option_FareTemplate_List = 312,

        /// <summary>
        /// 新建运费模板
        /// </summary>
        Option_FareTemplate_Add = 313,

        /// <summary>
        /// 编辑运费模板
        /// </summary>
        Option_FareTemplate_Editt = 314,

        /// <summary>
        /// 删除运费模板
        /// </summary>
        Option_FareTemplate_Delete = 315,

        /// <summary>
        /// 快递公司列表
        /// </summary>
        OPtion_ExpressCompany_List = 316,

        /// <summary>
        /// 新建快递公司
        /// </summary>
        Option_ExpressCompany_Add = 317,

        /// <summary>
        /// 运费价格
        /// </summary>
        Option_ExpressCompany_FarePrice = 318,

        /// <summary>
        /// 未送达区域设置
        /// </summary>
        Option_ExpressCompany_CancleSendArea = 319,

        /// <summary>
        /// 编辑快递公司
        /// </summary>
        Option_ExpressCompany_Edit = 320,

        /// <summary>
        /// 删除快递公司
        /// </summary>
        Option_ExpressCompany_Delete = 321,

        /// <summary>
        /// 包邮设置
        /// </summary>
        Option_BagMail_Set = 322,

        /// <summary>
        /// 短信发送记录
        /// </summary>
        Option_SMS_SendLog = 323,

        /// <summary>
        /// 短信充值
        /// </summary>
        Option_SMS_Charge = 324,

        /// <summary>
        /// 新闻列表
        /// </summary>
        Option_News_List = 325,

        /// <summary>
        /// 新建新闻
        /// </summary>
        Option_News_Add = 326,

        /// <summary>
        /// 编辑新闻
        /// </summary>
        Option_News_Edit = 327,

        /// <summary>
        /// 删除新闻
        /// </summary>
        Option_News_Delete = 328,

        /// <summary>
        /// 用户消费数据聚合
        /// </summary>
        Option_UserData_Polymerization = 329,

        /// <summary>
        /// 页面缓存清理
        /// </summary>
        Option_PageCache_Clear = 330,

        /// <summary>
        /// 本周统计
        /// </summary>
        Option_TJ_Week = 331,

        /// <summary>
        /// 用户充值
        /// </summary>
        Option_User_Charge = 332,

        /// <summary>
        /// 管理员操作日志
        /// </summary>
        Option_Log_List = 333,
        /// <summary>
        /// 问题反馈统计
        /// </summary>
        Option_TJ_ProblemFeedBack = 334,
        /// <summary>
        /// 问题反馈列表
        /// </summary>
        Option_ProblemFeedBack_List = 335,
        /// <summary>
        /// 问题选项反馈列表
        /// </summary>
        Option_ProblemOptionFeedBack_List = 336,
        /// <summary>
        /// 问题列表
        /// </summary>
        Option_Problem_List = 337,
        /// <summary>
        /// 添加新问题
        /// </summary>
        Option_Add_NewProblem = 338,
        /// <summary>
        /// 编辑问题
        /// </summary>
        Option_Edit_Problem = 339,
        /// <summary>
        /// 删除问题
        /// </summary>
        Option_Delete_Problem = 340,

        /// <summary>
        /// 问题选项列表
        /// </summary>
        Option_ProblemOption_List = 341,
        /// <summary>
        /// 添加问题新选项
        /// </summary>
        Option_Add_NewOption = 342,

        /// <summary>
        /// 编辑问题选项
        /// </summary>
        Option_Edit_Option = 343,
        /// <summary>
        /// 删除问题选项
        /// </summary>
        Option_Delete_Option = 344,
        /// <summary>
        /// 反馈详情
        /// </summary>
        Option_Feedback_Information=345,
        /// <summary>
        /// 反馈详情内容
        /// </summary>
        Option_Feedback_InformationContent=346,

        /// <summary>
        /// 付款订单来源统计
        /// </summary>
        Option_TJ_Order_Pay_Source = 347,

        /// <summary>
        /// 用户注册来源统计
        /// </summary>
        Option_TJ_User_Reg_Source = 348,

        /// <summary>
        /// 数据库升级
        /// </summary>
        Option_Data_Escalate = 349,
    }
}
