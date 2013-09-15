<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Response.Write(GetMess(Request["mobile"], Request["teamid"], Request["orderid"]));
        Response.End();
    }
    //通过手机号获取认证码
    public string GetMess(string mobile, string teamid, string orderid)
    {
        string str = "";
        if (mobile == "")
        {
            str = "请输入手机号";
        }
        else
        {
            if (!Helper.ValidateString(mobile, "mobile"))
            {
                str = "请输入正确的手机号码";
            }
            else
            {
                if (AS.GroupOn.Controls.DrawMethod.isUserMobile(Helper.GetString(mobile, ""), Helper.GetInt(teamid, 0)))
                {
                    str = "此手机号已参加此抽奖活动";
                }
                else
                {
                    if (GetUesrCode(Helper.GetInt(orderid, 0), mobile))
                    {
                        str = "认证码已发送手机上，请注意查收";
                    }
                    else
                    {
                        str = "发送短信失败";
                    }
                }
            }
        }
        return str;
    }
    public bool IsHandset(string str_handset)
    {
        return System.Text.RegularExpressions.Regex.IsMatch(str_handset, @"^[1]+[3,5]+\d{9}");
    }
    public bool GetUesrCode(int orderid, string mobile)
    {
        bool falg = false;
        IOrder ordermodel = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(orderid);
        }
        ordermodel.checkcode = DrawMethod.GetCode(0);
        ordermodel.Mobile = Helper.GetString(mobile, "");
        using (IDataSession session = Store.OpenSession(false))
        {
            session.Orders.Update(ordermodel);
        }
        if (AsUser.Id != 0)
        {
            AsUser.Mobile = Helper.GetString(mobile, "");
            using (IDataSession session = Store.OpenSession(false))
            {
                session.Users.Update(AsUser);
            }
        }
        //抽奖验证码
        NameValueCollection values = new NameValueCollection();
        values.Add("网站简称", ASSystem.abbreviation);
        values.Add("用户名", UserName);
        if (ordermodel.Team != null)
        {
            values.Add("商品名称", ordermodel.Team.Product);
        }
        values.Add("认证码", ordermodel.checkcode);
        string message = ReplaceStr("drawcode", values);
        falg = setPhone(Helper.GetString(mobile, ""), message);
        return falg;
    }
    private bool setPhone(string telNumber, string telContent)
    {
        List<string> lists = new List<string>();
        string[] s = telNumber.Split(',');
        for (int i = 0; i < s.Length; i++)
        {
            lists.Add(s[i]);
        }
        return EmailMethod.SendSMS(lists, telContent);
    }
</script>
