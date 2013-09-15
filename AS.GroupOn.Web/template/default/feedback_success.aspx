<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<script runat="server">
   
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Form.Action = GetUrl("商务合作成功", "feedback_success.aspx");
    }
    
</script>

<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form1" runat="server">
    <div id="bdw" class="bdw">
        <div id="bd" class="cf">
            <div id="feedback">
                <div id="content" class="help">
                    <div class="box">
                        <div class="box-content">
                            <div class="head">
                                <h2>意见反馈</h2>
                            </div>
                            <div class="sect">
                                <p class="notice">提交成功，谢谢您的支持。 <a href="<%=WebRoot %>index.aspx">&gt;&gt;返回首页</a></p>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
        <!-- bd end -->
    </div>
    <!-- bdw end -->
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
