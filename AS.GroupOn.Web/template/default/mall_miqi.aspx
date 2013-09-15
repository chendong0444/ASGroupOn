<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Controls" %>
<%LoadUserControl("_htmlheader_mall.ascx", null); %>
<%LoadUserControl("_header_mall.ascx", null); %>
<script type="text/javascript">
    $(document).ready(function () {
        $('.nav-xq').mousemove(function () {
            $(this).find('.nav_filter').show();
            $(this).find('.border').addClass('hover');
        });
        $('.nav-xq').mouseleave(function () {
            $(this).find('.nav_filter').hide();
            $(this).find('.border').removeClass('hover');
        });
    });
</script>
<div class="bdw" id="bdw">
    <!--商城头部分类开始-->
    <%LoadUserControl("_malltopcata.ascx", null); %>
    <!--商城头部分类结束-->
    <div id="container">
        <div id="body">
            <!--商城头部开始-->
            <%LoadUserControl("_malltop.ascx", null); %>
            <!--商城头部结束-->
            <!--商城中间分类开始-->
            <%LoadUserControl("_mallbottom.ascx", null); %>
            <!--商城中间分类结束-->
        </div>
    </div>
</div>
<%LoadUserControl("_footer_mall.ascx", null); %>
<%LoadUserControl("_htmlfooter_mall.ascx", null); %>
