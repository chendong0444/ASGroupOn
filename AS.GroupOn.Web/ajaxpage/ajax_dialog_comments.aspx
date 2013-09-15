<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<script runat="server">
    public string pid = "";
    public string id = "";
    public string uid = "";
    public string content = "";
    public string urId = "";
    public int score = 100;
    public int isGo = 1;
    protected override void OnLoad(EventArgs e)
    {
        //用户id
        if (Request.QueryString["uid"] != null && Request.QueryString["uid"].ToString() != "")
        {
            uid = Request.QueryString["uid"].ToString();
        }
        //项目评论
        if (Request.QueryString["id"] != null && Request.QueryString["id"].ToString() != "" && (Request.QueryString["pid"] == null || Request.QueryString["pid"].ToString() == ""))
        {
            hidType.Value = "team";
            id = Request.QueryString["id"].ToString();
        }
        //商户评论
        else if (Request.QueryString["id"] != null && Request.QueryString["id"].ToString() != "" && Request.QueryString["pid"] != null && Request.QueryString["pid"].ToString() != "")
        {
            this.pScore.Style.Add("display", "block");
            this.pIsGo.Style.Add("display", "block");
            hidType.Value = "partner";
            id = Request.QueryString["id"].ToString();
            pid = Request.QueryString["pid"].ToString();
        }
    }
</script>

<head>
    <style type="text/css">
        .formbutton
        {
            width: 118px;
        }
        #consult_content
        {
            height: 115px;
            width: 299px;
        }
    </style>
</head>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span></h3>
    <p id="pScore" runat="server" class="notice" style="display: none">
        <span style="width: 64px; float: left">满意度：</span><select id="selScore" runat="server"
            name="selScore">
            <option value="100">满意</option>
            <option value="50">一般</option>
            <option value="0">失望</option>
        </select></p>
    <p id="pIsGo" runat="server" class="notice" style="display: none">
        愿意再去：
        <select id="selIsGo" runat="server" name="selIsGo">
            <option value="1">是</option>
            <option value="0">否</option>
        </select>
    </p>
    <p class="notice">
        评论内容：<textarea id="consult_content" name="content" group="a" require="true" id="consult_content"><%=content %></textarea></p>
    <p style="margin: 10px 3em;">
        <input id="smssub-dialog-query" class="formbutton" value="发表" name="query" type="submit"
            onclick="return comments_submit();" /></p>
    <input type="hidden" id="hidType" runat="server" />
</div>
<script type="text/javascript">
    function comments_submit() {
        var type = $("#hidType").val();
        var content = trim(jQuery('#consult_content').val());
        if (content == '') {
            alert('评论内容不能为空!');
            jQuery('#consult_content').focus();
        }
        else if (content.indexOf("<") >= 0 || content.indexOf(">") >= 0) {

            alert('输入了带有安全隐患的字符，请重新评论！');
            jQuery('#consult_content').focus();
        }
        else {
            if (type == "team") {
                X.get(webroot + "ajax/list_comments.aspx?id=<%=id %>&uid=<%=uid %>&content=" + encodeURIComponent(content));
            }
            if (type == "partner") {
                var score = $("#selScore").val();
                var isGo = $("#selIsGo").val();
                X.get(webroot + "ajax/list_comments.aspx?id=<%=id %>&uid=<%=uid %>&pid=<%=pid %>&score=" + score + "&isgo=" + isGo + "&content=" + encodeURIComponent(content));
            }
        }
        return false;
    }

    function trim(str) {
        return str.replace(/^\s*(.*?)[\s\n]*$/g, '$1');
    }
</script>
