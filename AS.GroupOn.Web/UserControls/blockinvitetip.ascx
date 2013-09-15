<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
    }
</script>
<div class="sbox">

    <div class="sbox-content">
        <div class="r-top"></div>
        <div class="side-tip referrals-side">
            <h2 class="first">在哪里可以看到我的返利？</h2>
            <p>如果邀请成功：在您的用户中心》我的邀请》即可以查看邀请注册的记录及状态；账户余额里可以看到返利的记录。</p>
            <h2>好友已经注册过<%=ASSystemArr["abbreviation"] %>账户，邀请购买还有效么？</h2>
            <p>只要好友是首次购买，不管之前是否注册过<%=ASSystemArr["abbreviation"] %>账户都有效。</p>
            <h2>哪些情况会导致邀请返利失效？</h2>
            <ul class="invalid">
                <li>好友购买之前点击了其他人的邀请链接</li>
                <li>好友的本次购买不是首次购买</li>
                <li>由于最终团购人数没有达到人数下限，本次团购取消</li>
            </ul>
            <h2>自己邀请自己也能获得返利吗？</h2>

            <p>我们会有人工审核的，对于查实的作弊行为，是不予以返利的。</p>
        </div>
        <div class="r-bottom"></div>
    </div>

</div>
