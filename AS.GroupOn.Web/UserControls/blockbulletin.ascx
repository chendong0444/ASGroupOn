<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%
    AS.GroupOn.Domain.ICategory c = null;
    if (CurrentCity != null && CurrentCity.Id != 0)
    {

        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            c = session.Category.GetByID(CurrentCity.Id);
        }

    }
    if (c != null)
    {
        if (c.content !=null && c.content != "")
        {
%>
<div class="sbox side-business">
    <div class="sbox-content">
        <div class="r-top">
        </div>
        <h3>
            公告</h3>
        <div class="tip">
            <div>
                <%=c.content%></div>
        </div>
        <div class="r-bottom">
        </div>
    </div>
</div>
<%}
        else
        { %>
<%if (ASSystemArr["Gobalbulletin"] != String.Empty && ASSystemArr["Gobalbulletin"].ToString().Trim() != "" && ASSystemArr["Gobalbulletin"].ToString().Trim() != "<p>&nbsp;</p>")
  { %>
<div class="sbox side-business">
    <div class="sbox-content">
        <div class="r-top">
        </div>
        <h3>
            网站公告</h3>
        <div class="tip">
            <div style="width:210px; overflow:hidden;word-wrap: break-word;
word-break: normal;word-break:break-all;font-size: 14px;color:#000">
                <%=ASSystemArr["Gobalbulletin"]%>
            </div>
        </div>
        <div class="r-bottom">
        </div>
    </div>
</div>
<%}
}
    }%>