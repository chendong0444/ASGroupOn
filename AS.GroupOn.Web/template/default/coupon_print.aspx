<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    CouponFilter couponfile = new CouponFilter();
    IList<ICoupon> couponmodel = null;
    IUser usermodel = null;
    ITeam teamodel = null;
    IPartner parmodel=null;
    ISystem sysmodel = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NeedLogin();
        form1.Action = GetUrl("优惠券打印", "coupon_print.aspx?couponid=" + Request["couponid"] + "&csecret=" + Request["csecret"]);
        if (Request["couponid"] != null && Request["csecret"] != null)
        {
            string  id=Request["couponid"].ToString();
            string secret = Request["csecret"].ToString();
            GetCoupon(id,secret);
        }
    }

    #region 根据优惠券编号，打印优惠券
    public void GetCoupon(string id, string secret)
    {
        couponfile.Id = id;
        couponfile.Secret = secret;
        using (IDataSession session=AS.GroupOn.App.Store.OpenSession(false))
        {
            couponmodel = session.Coupon.GetList(couponfile);
        }
        if (couponmodel != null)
        {
            using (IDataSession session=AS.GroupOn.App.Store.OpenSession(false))
            {
                usermodel = session.Users.GetByID(couponmodel[0].User_id);
            }
            string key = FileUtils.GetKey();
            if (usermodel.Id.ToString()!= CookieUtils.GetCookieValue("userid",key))
            {
                SetError("您没有权限打印该优惠券！");
                Response.Redirect(PageValue.WebRoot + "index.aspx");
                Response.End();
                return;
            }
            using (IDataSession session=AS.GroupOn.App.Store.OpenSession(false))
            {
                teamodel = session.Teams.GetByID(Convert.ToInt32(couponmodel[0].Team_id));
            };
            if (teamodel != null)//防止项目删除后报错
            {
                using(IDataSession session =AS.GroupOn.App.Store.OpenSession(false))
	        {
		         parmodel=session.Partners.GetByID(Convert.ToInt32(teamodel.Partner_id));
	        }
            }
            using (IDataSession session =AS.GroupOn.App.Store.OpenSession(false))
            {
                sysmodel = session.System.GetByID(1);
            }
        }
        else
        {
            SetError("该优惠券不存在！");
            Response.Redirect("index.aspx");
        }

    }
    #endregion
    </script>
<head id="Head1" runat="server">
    <title></title>
    <style type="text/css">
        body
        {
            background: #fff;
        }
        *
        {
            margin: 0 auto;
        }
        #ecard
        {
            width: 660px;
            clear: both;
            border: 1px solid #000;
            margin-top: 40px;
            margin-right: auto;
            margin-left: auto;
            background-color: White;
        }
        #econ
        {
            width: 620px;
            margin: 0 auto;
            margin-bottom: 10px;
            overflow: hidden;
        }
        #etop
        {
            height: 90px;
            border-bottom: 1px solid #000;
        }
        #logo
        {
            width: 320px;
            height: 80px;
            float: left;
            background: url(/.jpg) no-repeat;
        }
        #welcome
        {
            float: right;
            font-family: "黑体";
            font-size: 36px;
            margin-top: 20px;
            text-align: right;
            width: 280px;
        }
        #teamtitle
        {
            width: 620px;
            text-align: left;
            font-size: 20px;
            font-weight: bold;
            margin-top: 8px;
            margin-bottom: 10px;
        }
        #main
        {
            width: 620px;
            margin-bottom: 20px;
        }
        #mleft
        {
            float: left;
            width: 320px;
            line-height: 150%;
        }
        #name
        {
            font-size: 20px;
            font-weight: bold;
            margin-top: 10px;
        }
        #relname
        {
            font-size: 14px;
            padding-left: 8px;
        }
        #coupon
        {
            margin-top: 20px;
            font-size: 26px;
            font-family: "黑体";
            font-weight: bold;
            text-align: left;
        }
        #coupon p
        {
            line-height: 120%;
        }
        
        #notice
        {
            font-size: 14px;
            padding-top: 8px;
        }
        #notice ul
        {
            margin: 0px;
            list-style: none;
            padding-left: 0px;
        }
        #notice ul li
        {
            line-height: 26px;
        }
        #server
        {
            background-color: #dcdcdc;
            width: 600px;
            height: 20px;
            font-size: 14px;
            color: #000;
            margin-top: 20px;
            line-height: 20px;
            text-align: center;
            clear: both;
        }
        
        @media print
        {
            .noprint
            {
                display: none;
            }
        }
        #mright
        {
            float: right;
            padding-right: 10px;
            width: 290px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div id="ecard">
        <div id="econ">
            <!--top -->
            <div id="etop">
                <%if (sysmodel != null)
                  {
                      if (sysmodel.printlogo!= null)
                      {
                %>
                <div style="float: left">
                    <img src="<%=sysmodel.printlogo %>" /></div>
                <% }%>
                <% }%>
                <div id="welcome">
                    祝您消费愉快！</div>
            </div>
            <!--endtop -->
            <%if (couponmodel != null)
              { %>
            <div id="teamtitle">
                <%if (teamodel != null)
                  { %>
                <%=teamodel.Title%>
                <% }%>
            </div>
            <!--main -->
            <div id="main">
                <div id="mleft">
                    <div id="name">
                        贵宾</div>
                    <div id="relname">
                        <%=usermodel.Username%>
                        (<%=usermodel.Email%>)</div>
                    <div id="name">
                        有效期</div>
                    <div id="relname">
                        截止至：<%=couponmodel[0].Expire_time%></div>
                    <div id="name">
                        地址</div>
                    <div id="relname">
                        <%if (parmodel != null)
                          { %>
                        <%=parmodel.Address%>
                        <% }%>
                    </div>
                    <div id="coupon">
                        <p>
                            券号:<%=couponmodel[0].Id%></p>
                        <p>
                            密码:<%=couponmodel[0].Secret%></p>
                    </div>
                </div>
                <!--right -->
                <div id="mright">
                    <div id="name">
                        提示</div>
                    <div id="notice">
                        <%if (teamodel != null)
                          { %>
                        <%=teamodel.Notice%>
                        <% }%>
                    </div>
                    <div id="name">
                        如何使用<%=ASSystemArr["couponname"]%></div>
                    <div id="notice">
                        <% }%>
                        <ul>
                            <li>1、本券仅在
                                <%if (parmodel != null)
                                  { %>
                                <%=parmodel.Title%>
                                <% }%>
                                有效</li>
                            <li>2、打印本券（券上有唯一消费码）</li>
                            <li>3、持券在有效期内到商家消费</li>
                        </ul>
                    </div>
                </div>
                <div style="clear: both;">
                </div>
            </div>
            <!--endmain -->
            <div id="server">
                商家电话：
                <%if (parmodel != null)
                  { %>
                <%=parmodel.Phone%>
                地址：<%=parmodel.Address%>
                <% }%>
            </div>
        </div>
    </div>
    <div class="noprint" style="text-align: center; margin: 20px;">
        <button style="padding: 10px 20px; font-size: 16px; cursor: pointer;" onclick="window.print();">
            打印<%=sysmodel.couponname %></button></div>
    </form>
</body>