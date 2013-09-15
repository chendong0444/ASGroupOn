<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
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
     protected string couponname = String.Empty;
     public override void UpdateView()
     {
         if (ASSystem != null)
         {
             couponname = ASSystem.couponname;
         }
     }
</script>
<div class="clear"></div>
<div class="header_info">
<br><strong>什么是<%=couponname %>？</strong>
<br>
<p> <%=couponname %>是当团购成功后，您以手机短信方式获取，或者自行下载打印使用的消费凭证（其中包含唯一优惠密码）。</p>
<br>
<strong>如何使用<%=couponname %>？</strong>
<br>
<p>当您去消费时，出示该短信或者打印的<%=couponname %>即可。打印版<%=couponname %>上通常还包含更详细的使用说明。</p>
</div>
