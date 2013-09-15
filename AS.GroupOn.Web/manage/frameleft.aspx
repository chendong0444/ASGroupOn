<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<script runat="server">
    protected string date = DateTime.Now.ToString("yyyy-MM-dd");
    protected string date2 = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
    protected int id = 0;
    protected AS.GroupOn.Domain.IUser user = null;
    protected NameValueCollection configs = new NameValueCollection();
    protected bool IsTeamRole = false;

    protected void Page_Load(object sender, EventArgs e)
    {
        string type = AS.Common.Utils.Helper.GetString(Request["type"], String.Empty);
        string key = AS.Common.Utils.FileUtils.GetKey();
        id = AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0);
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            user = session.Users.GetByID(id);
        }
        //判断用户是否商户
        foreach (IRole role in user.Role)
        {
            if (role.code == "team")
            {
                IsTeamRole = true;
                break;
            }
        }


        if (type == "project2" || IsTeamRole)
        {
            this.project2.Attributes.Add("style", "display:block");
        }
        else if (type == "project")
        {
            this.project.Attributes.Add("style", "display:block");
        }
        else if (type == "orders")
        {
            this.orders.Attributes.Add("style", "display:block");
        }
        else if (type == "shouhou")
        {
            this.ShouHou.Attributes.Add("style", "display:block");
        }
        else if (type == "caiwu")
        {
            this.CaiWu.Attributes.Add("style", "display:block");
        }
        else if (type == "tongji")
        {
            this.TongJi.Attributes.Add("style", "display:block");
        }
        else if (type == "huiyuan")
        {
            this.HuiYuan.Attributes.Add("style", "display:block");
        }
        else if (type == "kuaidi")
        {
            this.KuaiDi.Attributes.Add("style", "display:block");
        }
        else if (type == "yingxiao")
        {
            this.YingXiao.Attributes.Add("style", "display:block");
        }
        else if (type == "wangzhan")
        {
            this.WangZhan.Attributes.Add("style", "display:block");
        }
        else if (type == "online")
        {
            this.OnLine.Attributes.Add("style", "display:block");
        }
        else if (type == "shouye" || type == "")
        {
            this.defaultpage.Attributes.Add("style", "display:block");
            this.defaultuser.Attributes.Add("style", "display:block");
        }

        
    } 
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>管理后台头部</title>
    <link href="css/index.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" language="javascript">
        window.onload = function () {
            var dashboard = document.getElementById('dashboard'), aLi = dashboard.getElementsByTagName('li'), i = 0;
            for (i = 0; i < aLi.length; i++) {
                aLi[i].index = i;
                aLi[i].onclick = function () {
                    for (i = 0; i < aLi.length; i++) {
                        aLi[i].className = '';
                    }
                    this.className = 'current'
                }
            }

        }

    </script>
</head>
<body style="background: #F1F1F1;">
    <div class="bdw" id="bdw">
        <div class="cf mainwide1" id="bd">
            <div id="help">
            <%if (IsTeamRole)
              { %>
                <div id="ddashboard" class="dashboard">
                    <%--项目 --%>
                    <div id="project2" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">团购项目管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Project_DangqianXiangmu.aspx" target="Right">当前项目</a></li>
                                    <li name="type"><a href="Project_XinjianXiangmuTerm.aspx" target="Right">新建项目</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">产品管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="ProductList.aspx" target="Right">产品列表</a></li>
                                    <li name="type"><a href="ProductAddTerm.aspx" target="Right">添加新产品</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                </div>
              <%}
              else
              { %>

              
                <div id="dashboard" class="dashboard">
                    <%--登陆信息--%>
                    <div id="defaultuser" runat="server" style="display: none">
                        <dl class="acSide_Option" style="margin-top: 0;">
                            <dt class="acSide_title">登录用户</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="PersonalInfo.aspx?id=<%=id %>" target="Right">个人信息</a></li>
                                    <li name="type"><a href="ChangePWD.aspx?id=<%=id %>" target="Right">修改密码</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                    <%--登陆信息--%>
                    <%--首页默认 --%>
                    <div id="defaultpage" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">常用操作</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Project_DangqianXiangmu.aspx" target="Right">项目列表</a></li>
                                    <li name="type"><a href="Dingdan_DangqiDingdan.aspx" target="Right">订单列表</a></li>
                                    <li name="type"><a href="Index-XiangmuDabian.aspx" target="Right">本单答疑</a></li>
                                    <li name="type"><a href="ShangHu_JieSuan.aspx" target="Right">商户结算</a></li>
                                    <li name="type"><a href="User.aspx" target="Right">会员列表</a></li>
                                    <li name="type"><a href="ShangHu.aspx" target="Right">商家列表</a></li>
                                    <li name="type"><a href="DingDan_Weidayin.aspx" target="Right">订单打印</a></li>
                                    <li name="type"><a href="Youhui_WeiDaijinquan.aspx" target="Right">代金券列表</a></li>
                                    <li name="type"><a href="SheZhi_Jiben.aspx" target="Right">网站配置</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                    <%--项目 --%>
                    <div id="project" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">团购项目管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Project_DangqianXiangmu.aspx" target="Right">当前项目</a></li>
                                    <li name="type"><a href="Project_XinjianXiangmu.aspx" target="Right">新建项目</a></li>
                                    <li name="type"><a href="Project_WeiKaishixiangmu.aspx" target="Right">未开始项目</a></li>
                                    <li name="type"><a href="Project_ChenggongXiangmu.aspx" target="Right">成功项目</a></li>
                                    <li name="type"><a href="Project_ShibaiXiangmu.aspx" target="Right">失败项目</a></li>
                                    <li name="type"><a href="Project_PointXiangmu.aspx" target="Right">积分项目</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">商城项目管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="commoditylist.aspx" target="Right">项目列表</a></li>
                                    <li name="type"><a href="Commodity_add.aspx" target="Right">新建项目</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">项目分类管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Type_catalogs.aspx" target="Right">团购分类列表</a></li>
                                    <li name="type"><a href="Type_addcatalogs.aspx" target="Right">添加团购分类</a></li>
                                    <li name="type"><a href="mall_catalogs.aspx" target="Right">商城分类列表</a></li>
                                    <li name="type"><a href="mall_addcatalogs.aspx" target="Right">添加商城分类</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">产品管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="ProductList.aspx" target="Right">产品列表</a></li>
                                    <li name="type"><a href="ProductAdd.aspx" target="Right">添加新产品</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">城市管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Type_Chengshi.aspx?zone=city" target="Right">城市分类列表</a></li>
                                    <li name="type"><a href="Type_ChengshiGroup.aspx?zone=citygroup" target="Right">城市分组列表</a></li>
                                    <li name="type"><a href="Type_Area.aspx" target="Right">区域商圈列表</a></li>
                                    <li name="type"><a href="Type_addarea.aspx?zone=area" target="Right">新建区域商圈</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">品牌管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Type_PinPai.aspx?zone=brand" target="Right">品牌列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">项目图片管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Project_ImgManager.aspx" target="Right">主推图片列表</a></li>
                                    <li name="type"><a href="Project_ImgList.aspx" target="Right">详情图片列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                    <%--订单 --%>
                    <div id="orders" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">订单管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Dingdan_DangqiDingdan.aspx" target="Right">所有订单</a></li>
                                    <li name="type"><a href="Dingdan_FukuanDingdan.aspx" target="Right">付款订单</a></li>
                                    <li name="type"><a href="Dingdan_WeiFuDingdan.aspx" target="Right">未付款订单</a></li>
                                    <li name="type"><a href="Dingdan_QuxiaoDingdan.aspx" target="Right">取消订单</a></li>
                                    <li name="type"><a href="DingDan_Shenghe.aspx" target="Right">审核订单</a></li>
                                    <li name="type"><a href="Dingdan_TuikuanDingdan.aspx" target="Right">退款订单</a></li>
                                    <li name="type"><a href="Dingdan_Chulituikuan.aspx" target="Right">处理退款</a></li>
                                    <li name="type"><a href="Dingdan_Chengongtuikuan.aspx" target="Right">成功退款</a></li>
                                    <li name="type"><a href="Dingdan_Score.aspx" target="Right">积分订单</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">站内券管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Youhui_Weixiaofei.aspx" target="Right">未消费优惠券</a></li>
                                    <li name="type"><a href="Youhui_YiXiaofei.aspx" target="Right">已消费优惠券</a></li>
                                    <li name="type"><a href="Youhui_YiGuoqi.aspx" target="Right">已过期优惠券</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">站外券管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Youhui_pcoupon.aspx" target="Right">站外券列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                    <%--售后服务 --%>
                    <div id="ShouHou" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">购买咨询</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Index-XiangmuDabian.aspx" target="Right">项目答疑</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">买家评论</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Index_list_comments.aspx" target="Right">商品评论</a></li>
                                    <li name="type"><a href="Index_list_pcomments.aspx?hid=0" target="Right">商户评论</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <%--<dl class="acSide_Option">
<dt class="acSide_title">意见反馈</dt>
<dd><ul>
<li name="type" ><a href="Index_FankuiYijian.aspx" target="Right">意见反馈列表</a></li>
</ul></dd>
</dl>--%>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">商户合作</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="PartnerCooperaList.aspx" target="Right">商户合作列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                    <%--财务管理 --%>
                    <div id="CaiWu" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">商户结算</dt>
                            <dd>
                                <ul>
                                    <!--新增-->
                                    <li name="type"><a href="ShangHu_JieSuan.aspx" target="Right">商户结算</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">操作记录</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="CaiWu_Store.aspx" target="Right">线下充值记录</a></li>
                                    <li name="type"><a href="CaiWu_Charge.aspx" target="Right">在线充值记录</a></li>
                                    <li name="type"><a href="CaiWu_Cash.aspx" target="Right">现金支付记录</a></li>
                                    <li name="type"><a href="CaiWu_Refund.aspx" target="Right">退款记录</a></li>
                                    <li name="type"><a href="CaiWu_Score.aspx" target="Right">积分纪录</a></li>
                                    <li name="type"><a href="CaiWu_Sign.aspx" target="Right">签名记录</a></li>
                                    <li name="type"><a href="CaiWu_Money.aspx" target="Right">红包</a></li>
                                    <li name="type"><a href="CaiWu_Feeding_amount.aspx" target="Right">返余额</a></li>
                                    <!--新增-->
                                    <li name="type"><a href="CaiWu_Buy.aspx" target="Right">在线支付</a></li>
                                    <li name="type"><a href="CaiWu_Coupon.aspx" target="Right">优惠券消费返利</a></li>
                                    <%--<li name="type"><a href="CaiWu_Withdraw.aspx" target="Right">提现</a></li>--%>
                                    <li name="type"><a href="CaiWu_Comment.aspx" target="Right">评论返利</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                    <%--统计报表--%>
                    <div id="TongJi" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">销售统计</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Tongji_ASdht_Order.aspx" target="Right">订单统计</a></li>
                                    <li name="type"><a href="Tongji_ASdht_Team.aspx" target="Right">项目统计</a></li>
                                    <li name="type"><a href="Tongji_Week.aspx" target="Right">本周统计</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">用户统计</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Tongji_ASdht_User.aspx" target="Right">用户注册统计</a></li>
                                    <li name="type"><a href="Tongji_ASdht_UserOrder.aspx" target="Right">用户订单统计</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">来源统计</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Tongji_Fukuan.aspx" target="Right">付款订单来源统计</a></li>
                                    <li name="type"><a href="Tongji_User.aspx" target="Right">用户注册来源统计</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                    <%--会员 --%>
                    <div id="HuiYuan" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">会员管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="User.aspx" target="Right">会员列表</a></li>
                                    <li name="type"><a href="Type_YonghuDengji.aspx" target="Right">会员等级</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">邮件订阅</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Index-youjiandingyue.aspx" target="Right">邮件订阅列表</a></li>
                                    <%--<li name="type" ><a href="CancelSubscribe.aspx" target="Right">邮件退订列表</a></li>--%>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">短信订阅</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Index_DuanxinDingyue.aspx" target="Right">短信订阅列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                    <%--快递物流 --%>
                    <div id="KuaiDi" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">在线订单打印</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="DingDan_WeiXuanZe.aspx" target="Right">未选择快递</a></li>
                                    <li name="type"><a href="Dingdan_Weidayin.aspx" target="Right">未打印</a></li>
                                    <li name="type"><a href="Dingdan_YiFaHuo.aspx?key=2" target="Right">未发货</a></li>
                                    <li name="type"><a href="Dingdan_YiFaHuo.aspx?key=1" target="Right">已发货</a></li>
                                    <li name="type"><a href="Importxls.aspx" target="Right">批量上传快递单</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">货到付款订单</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="DingDan_CashOnDelivery.aspx" target="Right">未选择快递</a></li>
                                    <li name="type"><a href="DingDan_CashWeiDaYin.aspx" target="Right">未打印</a></li>
                                    <li name="type"><a href="DingDan_CashState.aspx?key=2" target="Right">未发货</a></li>
                                    <li name="type"><a href="DingDan_CashState.aspx?key=1" target="Right">已发货</a></li>
                                    <li name="type"><a href="DingDan_CashState.aspx?key=3" target="Right">已完成</a></li>
                                    <li name="type"><a href="importxls.aspx" target="Right">批量上传快递单</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">打印模版管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="print_setting.aspx" target="Right">打印模版</a></li>
                                    <li name="type"><a href="SheZhi_Send.aspx" target="Right">发件人信息设置</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                    <%--营销推广 --%>
                    <div id="YingXiao" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">代金券</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Youhui_XinjianDaijin.aspx" target="Right">新建代金券</a></li>
                                    <li name="type"><a href="Youhui_WeiDaijinquan.aspx" target="Right">未消费代金券</a></li>
                                    <li name="type"><a href="Youhui_Daijinquan.aspx" target="Right">已消费代金券</a></li>
                                    <li name="type"><a href="Youhui_GuoQiDaijinquan.aspx" target="Right">已过期代金券</a></li>
                                    <!--新增-->
                                    <li name="type"><a href="Youhui_PaiFaDaijinquan.aspx" target="Right">已派发代金券</a></li>
                                    <li name="type"><a href="Youhui_WeipaifaDaijinquan.aspx" target="Right">未派发代金券</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">CPS管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="SheZhi_CPS.aspx" target="Right">CPS列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">API分类管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Type_XiangmuFenlei.aspx?zone=group" target="Right">API分类列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">邀请返利管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Index-YaoqingFanli.aspx" target="Right">邀请返利列表</a></li>
                                    <li name="type"><a href="Index-FanliRecord.aspx" target="Right">返利记录</a></li>
                                    <li name="type"><a href="Index-YaoqingWeiGui.aspx" target="Right">违规记录</a></li>
                                    <li name="type"><a href="Index-YaoqingTongJi.aspx" target="Right">邀请统计</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">邮件管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="YingXiao_YoujianYingxiao.aspx" target="Right">邮件营销</a></li>
                                    <li name="type"><a href="MailtasksList.aspx" target="Right">邮件群发</a></li>
                                    <li name="type"><a href="YingXiao_DuanxinQunfa.aspx" target="Right">短信群发</a></li>
                                    <li name="type"><a href="SheZhi_Youjian.aspx" target="Right">普通邮件设置</a></li>
                                    <li name="type"><a href="MailServerList.aspx" target="Right">群发邮件设置</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">友情链接管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Index-YouqingLianjie.aspx" target="Right">友情链接列表</a></li>
                                    <li name="type"><a href="addyouqinglianjie.aspx" target="Right">添加友情链接</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">广告管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="SheZhi_GongGaoList.aspx" target="Right">广告位列表</a></li>
                                    <li name="type"><a href="Shezhi_Guangao.aspx" target="Right">添加广告位</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">一站通管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="SheZhi_sohu.aspx" target="Right">一站通列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">新闻公告</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="NewList.aspx" target="Right">新闻列表</a></li>
                                    <li name="type"><a href="Addnews.aspx" target="Right">添加新闻</a></li>
                                    <li name="type"><a href="Shezhi_GongGao.aspx" target="Right">系统公告</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">红包管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="YingXiao_Packet.aspx" target="Right">红包派送</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">促销活动管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="YingXiao_CuXiaoHuoDong.aspx" target="Right">促销活动列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">数据下载</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="YingXiao_ShujuXiazai.aspx" target="Right">手机号码</a></li>
                                    <li name="type"><a href="YingXiao_ShujuXiazai_Email.aspx" target="Right">邮件地址</a></li>
                                    <li name="type"><a href="YingXiao_ShujuXiazai_Team.aspx" target="Right">项目订单</a></li>
                                    <li name="type"><a href="YingXiao_ShujuXiazai_Youhui.aspx" target="Right">项目优惠券</a></li>
                                    <li name="type"><a href="YingXiao_ShujuXiazai_User.aspx" target="Right">用户信息</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">调查</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="DiaoCha.aspx" target="Right">首页</a></li>
                                    <li name="type"><a href="DiaoCha_Fankui.aspx" target="Right">反馈</a></li>
                                    <li name="type"><a href="DiaoCha_Wenti.aspx" target="Right">问题</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">推广</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="WeiBo.aspx" target="Right">微博</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                    <%--网站配置 --%>
                    <div id="WangZhan" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">全站设置</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="SheZhi_Jiben.aspx" target="Right">团购基本</a></li>
                                    <li name="type"><a href="SheZhi_mallJiben.aspx" target="Right">商城基本</a></li>
                                    <li name="type"><a href="SheZhi_XuanXiang.aspx" target="Right">选项</a></li>
                                    <li name="type"><a href="Tongji_ASdht_sum.aspx" target="Right">全局缓存</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">皮肤</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="SheZhi_Pifu.aspx" target="Right">皮肤列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">页面设置</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="SheZhi_YeMian.aspx" target="Right">页面设置</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">支付设置</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="SheZhi_Zhifu.aspx" target="Right">支付</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">UC设置</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="SheZhi_Ucenter.aspx" target="Right">UC</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">短信设置</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="asdht_sms_send.aspx" target="Right">短信发送记录</a></li>
                                    <li name="type"><a target="_blank" href="/ajax/misc.aspx?action=SMS_rechargeable">短信充值</a></li>
                                    <li name="type"><a href="SheZhi_Duanxin.aspx" target="Right">短信设置</a></li>
                                    <li name="type"><a href="SheZhi_SmsTemplate.aspx" target="Right">短信模版</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">物流设置</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="logistic_citys.aspx" target="Right">物流城市管理</a></li>
                                    <li name="type"><a href="fare_template.aspx" target="Right">运费模版管理</a></li>
                                    <li name="type"><a href="Type_KuaidiGongsi.aspx" target="Right">快递设置</a></li>
                                    <li name="type"><a href="freightsetting.aspx" target="Right">包邮选项</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">栏目设置</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Shezhi_GuidList.aspx" target="Right">团购导航栏目</a></li>
                                    <li name="type"><a href="Shezhi_GuidList_mall.aspx" target="Right">商城导航栏目</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">管理员</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="User_Roles.aspx" target="Right">管理角色列表</a></li>
                                    <li name="type"><a href="User_guanliyuanbiao.aspx" target="Right">管理员列表</a></li>
                                    <li name="type"><a href="User_Sale.aspx" target="Right">销售列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">日志</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Option_Log.aspx" target="Right">操作日志</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">数据库操作</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Index_ShujuBeifen.aspx" target="Right">数据库备份</a></li>
                                    <li name="type"><a href="Index-ShuJuHuiFu.aspx" target="Right">数据库还原</a></li>
                                    <li name="type"><a href="SheZhi_Shengji.aspx" target="Right">数据库升级</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                    <%--商家--%>
                    <div id="OnLine" runat="server" style="display: none">
                        <dl class="acSide_Option" style="">
                            <dt class="acSide_title">商户管理</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="ShangHu.aspx" target="Right">商户列表</a></li>
                                    <li name="type"><a href="ShangHu_Create.aspx" target="Right">添加新商户</a></li>
                                </ul>
                            </dd>
                        </dl>
                        <dl class="acSide_Option">
                            <dt class="acSide_title">商户分类</dt>
                            <dd>
                                <ul>
                                    <li name="type"><a href="Type_ShanghuFenlei.aspx?zone=partner" target="Right">商户分类列表</a></li>
                                </ul>
                            </dd>
                        </dl>
                    </div>
                </div>

              <%} %>
            </div>
        </div>
    </div>
</body>
</html>
