<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage"%>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.Domain.Spi" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<script runat="server">
    IUser user = new User();
    protected int user_id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        
        if (Request.HttpMethod=="GET")
        {
            user_id = Helper.GetInt(Request["userview"], 0);
        
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
            {
                user = session.Users.GetByID(user_id);
            }
            if (user == null) 
            {
                Response.Redirect(Request.UrlReferrer.ToString());
            }
        }
        if ( Request.HttpMethod=="POST") 
        {
            decimal inputmoeny = AS.Common.Utils.Helper.GetDecimal(Request["inputmoeny"], 0);
            int userscore = AS.Common.Utils.Helper.GetInt(Request["userscore"], 0);
            int user_id = AS.Common.Utils.Helper.GetInt(Request["user_id"], 0);
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_User_Charge))
            {
                SetError("你没有给用户充值的权限");
                Response.Redirect(Request.UrlReferrer.ToString());
                Response.End();
                return;
            }
            else
            {
                IUser user = new User();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    user = session.Users.GetByID(user_id);
                }
                int count = 0;
                user.Id = user_id;
                user.Money = user.Money + AS.Common.Utils.Helper.GetDecimal(inputmoeny, 0);
                user.userscore = user.userscore + AS.Common.Utils.Helper.GetInt(userscore, 0);
                if (inputmoeny != 0 || userscore != 0)
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        count = session.Users.UpdateUser(user);
                    }
                }
                else 
                {
                    Response.Redirect(Request.UrlReferrer.ToString());
                    Response.End();
                    return;
                }
                if (count > 0)
                {
                    
                    //充值成功，往消费记录表添加记录
                    IFlow flow = new Flow();
                    flow.User_id = user_id;
                    flow.Admin_id = AS.Common.Utils.Helper.GetInt(CookieUtils.GetCookieValue("userid", Key), 0);
                    flow.Detail_id = "0";
                    flow.Direction = "income";
                    flow.Money = inputmoeny;
                    flow.Action = "store";
                    flow.Create_time = DateTime.Now;
                    if (flow != null)
                    {
                        int counts = 0;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            counts = session.Flow.Insert(flow);
                        }
                    }
                    if (inputmoeny == 0 && userscore == 0)
                    {

                        Response.Redirect(Request.UrlReferrer.ToString());
                    }
                    else if (inputmoeny < 0 && userscore < 0)
                    {
                        SetSuccess(user.Username + "减去金额成功！减去" + ASSystem.currency + (inputmoeny * -1) + ",减去积分成功！减去" + (userscore * -1) + "积分");
                    }
                    else if (inputmoeny < 0 && userscore == 0)
                    {
                        SetSuccess(user.Username + "减去金额成功！减去" + ASSystem.currency + (inputmoeny * -1));
                    }
                    else if (inputmoeny > 0 && userscore == 0)
                    {
                        SetSuccess(user.Username + "充值金额成功！充值" + ASSystem.currency + (inputmoeny));
                    }
                    else if (userscore > 0 && inputmoeny == 0)
                    {
                        SetSuccess(user.Username + "充值积分成功！充值" + userscore + "积分");
                    }
                    else if (userscore < 0 && inputmoeny == 0)
                    {
                        SetSuccess(user.Username + "减去积分成功！减去" + (userscore * -1) + "积分");
                    }
                    else if (inputmoeny < 0 && userscore > 0)
                    {
                        SetSuccess(user.Username + "减去金额成功！减去" + ASSystem.currency + (inputmoeny * -1) + ",充值积分成功！充值" + userscore + "积分");
                    }
                    else if (inputmoeny > 0 && userscore < 0)
                    {
                        SetSuccess(user.Username + "充值金额成功！充值" + ASSystem.currency + inputmoeny + ",减去积分成功！减去" + (userscore * -1) + "积分");
                    }
                    else if (inputmoeny > 0 && userscore > 0)
                    {
                        SetSuccess(user.Username + "充值金额成功! 充值" + ASSystem.currency + inputmoeny + ",充值积分成功! 充值" + userscore + "积分");
                    }
                }
                else 
                {
                    SetError("充值失败");
                }
                Response.Redirect(Request.UrlReferrer.ToString());
                Response.End();
                return;
            }
        }
    }
</script>
<form method="post" action="<%=WebRoot %>manage/manage_ajax_userview.aspx">
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 330px;">
    <h3>
         <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>用户充值</h3>
    <input type="hidden" name="user_id" id="user_id" value="<%=user_id%>" />
    <table width="96%" align="center" class="coupons-table-xq">
        <tr>
            <td width="80"><b>Email：</b></td>
            <td><label style="width:300px;  white-space:normal; *white-space:nowrap;word-break:break-all; overflow:hidden;text-overflow:ellipsis;"><%=user.Email %></label></td>
        </tr>
        <tr>
            <td><b>用户名：</b></td>
            <td><label><%=user.Username %></label></td>
        </tr>
        <tr>
            <td><b>真实姓名：</b></td>
            <td><label><%=user.Realname %></label></td>
        </tr>
        <tr>
            <td class="style1"><b>手机号码：</b></td>
            <td class="style1"><label> <%=user.Mobile %></label></td>
        </tr>
        <tr>
            <td><b>邮政编码：</b></td>
            <td><label><%=user.Zipcode %></label></td>
        </tr>
        <tr>
            <td><b>派送地址：</b></td>
            <td><label> <%=user.Address %></label></td>
        </tr>
        <tr>
            <td><b>注册IP：</b></td>
            <td><label><%=user.IP %></label></td>
        </tr>
        <tr>
            <td colspan="2"><hr /></td>
        </tr>
        <tr>
            <td><b>账户余额：</b></td>
            <td><b><label> <%=user.Money %></label></b> 元</td>
        </tr>
        <tr>
            <td><b>积分余额：</b></td>
            <td><b><label><%=user.userscore %></label></b> 分</td>
        </tr>
        <tr>
            <td><b>消费统计：</b></td>
            <td>共消费 <b><label><%=user.BuyNum %></label></b> 次，累计 <b><label><%=user.GetTotalamount %></label></b> 元</td>
        </tr>
        <tr>
            <td colspan="2"><hr /></td>
        </tr>
        <tr>
            <td><b>账户充值：</b></td>
            <td> <input type="text" name="inputmoeny" id="inputmoeny" value="0"
                    size="6" maxlength="6" require="true" group="user"/>
            </td>
        </tr>
        <tr>
            <td><b>积分充值：</b></td>
            <td><input type="text" name="userscore"  id="userscore" value="0" size="6" maxlength="6" require="true" group="user" />
            </td>
        </tr>
        <tr>
            <td></td>
            <td><input type="submit" ask='确定给该用户充值吗?' name="but"  value="充值" group="user" class="formbutton validator" /></td>
        </tr>
        
    </table>
</div>
</form>
     <script type="text/javascript">
         $(function () { window.x_init_hook_validator(); });
    </script>