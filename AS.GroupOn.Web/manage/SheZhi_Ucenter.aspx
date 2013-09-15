<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">
    protected NameValueCollection configs = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_UC))
        {
            SetError("你不具有查看UC设置的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["UC_Islogin"] != null && Request.Form["UC_Islogin"].ToString() == "1")
            {
                if (Request.Form["UC_API"] != null && Request.Form["UC_API"].ToString() != "" && Request.Form["UC_KEY"] != null && Request.Form["UC_KEY"].ToString() != "" && Request.Form["UC_CHARSET"] != null && Request.Form["UC_CHARSET"].ToString() != "" && Request.Form["UC_APPID"] != null && Request.Form["UC_APPID"].ToString() != "")
                {
                    setUcenter(Request.Form["UC_Islogin"], Request.Form["UC_API"].ToString(), Request.Form["UC_IP"], Request.Form["UC_KEY"].ToString(), Request.Form["UC_CHARSET"].ToString(), Request.Form["UC_APPID"].ToString());
                }
                else
                {
                    SetError("设置失败,请把相关参数填写完!");
                }
            }
            else
            {
                setUcenter(Request.Form["UC_Islogin"], Request.Form["UC_API"].ToString(), Request.Form["UC_IP"], Request.Form["UC_KEY"].ToString(), Request.Form["UC_CHARSET"].ToString(), Request.Form["UC_APPID"].ToString());
            }
        }
        getUcenter();
    }
    /// <summary>
    /// 设置Ucenter
    /// </summary>
    /// <param name="UC_Islogin"></param>
    /// <param name="UC_API"></param>
    /// <param name="UC_IP"></param>
    /// <param name="UC_KEY"></param>
    /// <param name="UC_CHARSET"></param>
    /// <param name="UC_APPID"></param>
    protected void setUcenter(string UC_Islogin, string UC_API, string UC_IP, string UC_KEY, string UC_CHARSET, string UC_APPID)
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("UC_Islogin", UC_Islogin);
        values.Add("UC_API", UC_API);
        values.Add("UC_IP", UC_IP);
        values.Add("UC_KEY", UC_KEY);
        values.Add("UC_CHARSET", UC_CHARSET);
        values.Add("UC_APPID", UC_APPID);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
        SetSuccess("设置成功!");
        Response.Redirect("Shezhi_Ucenter.aspx");
    }
    /// <summary>
    /// 提取Ucenter值
    /// </summary>
    protected void getUcenter()
    {
        configs = PageValue.CurrentSystemConfig;
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server" method="post">
        <div id="pagemasker">
        </div>
        <div id="dialog">
        </div>
        <div id="doc">
            <div id="bdw" class="bdw">
                <div id="bd" class="cf">
                    <div id="coupons">
                        <div id="content" class="box-content clear mainwide">
                            <div class="box clear">
                                <div class="box-content">
                                     <div class="head">
                                    <h2>
                                        Ucenter设置</h2></div>
                                    <div class="sect">
                                        <div>
                                            <div class="field">
                                                <label>
                                                    是否开启Ucenter</label>
                                                <input id="UC_Islogin" name="UC_Islogin" type="checkbox" <% if (configs["UC_Islogin"] == "1")
                                                                                                            {%>checked="checked"
                                                    <%} %> value="1" />
                                            </div>
                                            <div class="field">
                                                <label>
                                                    UC_API:</label>
                                                <input type="text" size="30" name="UC_API" value="<%=configs["UC_API"] %>" group="goto" id="UC_API" class="f-input" />
                                            </div>
                                            <span class="tts">ucenter地址</span>
                                            <div class="field">
                                                <label>
                                                    UC_IP:</label>
                                                <input type="text" size="30" name="UC_IP" value="<%=configs["UC_IP"] %>"" group="goto" id="UC_IP" class="f-input" />
                                            </div>
                                            <span class="tts">应用的IP地址,正常情况下不需要修改。如果由于域名解析问题导致 UCenter 与该应用通信失败，请尝试设置为该应用所在服务器的 IP 地址</span>
                                            <div class="field">
                                                <label>
                                                    UC_KEY:</label>
                                                <input type="text" size="30" name="UC_KEY" value="<%=configs["UC_KEY"] %>" group="goto" id="UC_KEY" class="f-input" />
                                            </div>
                                            <span class="tts">通信密锁</span>
                                            <div class="field">
                                                <label>
                                                    UC_CHARSET:</label>
                                                <input type="text" size="30" name="UC_CHARSET" value="<%=configs["UC_CHARSET"] %>" group="goto" id="UC_CHARSET"
                                                    class="f-input" />
                                            </div>
                                            <span class="tts">编码格式(输入 UTF-8 或者 GB2312)</span>
                                            <div class="field">
                                                <label>
                                                    UC_APPID:</label>
                                                <input type="text" size="30" name="UC_APPID" value="<%=configs["UC_APPID"] %>" group="goto" id="UC_APPID"
                                                    class="f-input" />
                                            </div>
                                            <span class="tts">应用ID</span>
                                            <span class="tts">请填好相关的值。</span>
                                        </div>
                                        <div class="act">
                                            <input id="btnsave" name="btnsave" type="submit" value="保存" group="goto" class="validator formbutton" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- bd end -->
            </div>
            <!-- bdw end -->
        </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
