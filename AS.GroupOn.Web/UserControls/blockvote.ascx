<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
    }
</script>
<div class="sbox side-vote-tip">
    <div class="sbox-content">
        <div class="r-top">
        </div>
        <h3>
            小调查</h3>
        <div class="tip">
            <div class="text">
                <p class="mark">
                    <a href="<%=GetUrl("小调查","vote_index.aspx")%>">您最想在宗正大团上看到什么？</a></p>
                <p>
                    请告诉<%=ASSystemArr["abbreviation"] %>，让<%=ASSystemArr["abbreviation"] %>更好地为您服务！</p>
            </div>
            <p class="link">
                <a href="<%=GetUrl("小调查","vote_index.aspx")%>" >
                    <img src="<%=ImagePath() %>button-deal-vote.gif" style=" _clear:none;"></a></p>
        </div>
        <div class="r-bottom">
        </div>
    </div>
</div>
