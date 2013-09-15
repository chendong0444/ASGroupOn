<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    
    protected string check = "";
    protected ISystem isystem = null;
    protected NameValueCollection configs = new NameValueCollection();
    protected WebUtils webutils = new WebUtils();
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Yizhantong))
        {
            SetError("你不具有一站通设置的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request["btnsave"] == "保存")
        {
            Update();
        }

        configs = AS.Common.Utils.FileUtils.GetConfig();
        InitData();

        if (isystem != null)
        {
            if (isystem.enablesohulogin == 0)
            {
                check = "";
            }
            else
            {
                check = "checked=checked";

            }
        }
    }

    protected void InitData()
    {
        SystemFilter filter = new SystemFilter();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            filter.id = 1;
            isystem = session.System.Get(filter);
        }
    }
    /// <summary>
    /// 修改
    /// </summary>
    protected void Update()
    {
        IsUse();
        Is360Login();
        Is2345Login();
        Istuan800Login();
        IsQQLogin();
        Is163Login();
        Isalipaylogin();
        IsSinaLogin();
        IstaobaoLogin();
        IsbaiduLogin();
        IsRenrenLogin();
        IsKaixin001Login();
    }


    #region 是否启用支付宝一站通
    public void Isalipaylogin()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("Isalipaylogin", Request["Isalipaylogin"]);
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
    }
    #endregion
    #region 是否启用搜狐一站通
    public void IsUse()
    {
        int result = 0;
        int sohu = 0;
        InitData();
        if (Request["chsohu"] != null && Request["chsohu"] != "")
        {
            sohu = 1;
        }
        isystem.enablesohulogin = sohu;
        isystem.sohuloginkey = Request["key"];
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            result = session.System.Update(isystem);
        }
        if (result > 0)
        {
            SetSuccess("设置成功");
        }
    }
    #endregion
    #region 360一站通
    protected void Is360Login()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("is360login", Request["is360login"]);
        values.Add("login360key", Request["login360key"]);
        values.Add("login360secret", Request["login360secret"]);
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
    }
    #endregion

    #region 2345一站通
    protected void Is2345Login()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("is2345login", Request["is2345login"]);
        values.Add("login2345key", Request["login2345key"]);
        values.Add("login2345secret", Request["login2345secret"]);
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
    }
    #endregion

    #region tuan800一站通
    protected void Istuan800Login()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("istuan800login", Request["istuan800login"]);
        values.Add("logintuan800key", Request["logintuan800key"]);
        values.Add("logintuan800secret", Request["logintuan800secret"]);
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
    }
    #endregion


    #region QQ一站通
    protected void IsQQLogin()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("isqqlogin", Request["isqqlogin"]);
        values.Add("loginqqkey", Request["loginqqkey"]);
        values.Add("loginqqkey1", Request["loginqqkey1"]);
        values.Add("loginqqsecret", Request["loginqqsecret"]);
        values.Add("loginqqsecret1", Request["loginqqsecret1"]);
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
    }
    #endregion

    #region 网易一站通
    protected void Is163Login()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("is163login", Request["is163login"]);
        values.Add("login163key", Request["login163key"]);
        values.Add("login163secret", Request["login163secret"]);
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
    }
    #endregion

    #region 新浪微博
    protected void IsSinaLogin()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("isSinalogin", Request["isSinalogin"]);
        values.Add("loginSinakey", Request["loginSinakey"]);
        values.Add("loginSinasecret", Request["loginSinasecret"]);
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
    }
    #endregion

    #region 淘宝一站通
    protected void IstaobaoLogin()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("istaobaologin", Request["istaobaologin"]);
        values.Add("logintaobaokey", Request["logintaobaokey"]);
        values.Add("logintaobaosecret", Request["logintaobaosecret"]);
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
    }
    #endregion


    #region baidu一站通
    protected void IsbaiduLogin()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("isbaidulogin", Request["isbaidulogin"]);
        values.Add("baiduid", Request["baiduid"]);
        values.Add("baidukey", Request["baidukey"]);
        values.Add("baidusecret", Request["baidusecret"]);
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
    }
    #endregion

    #region 人人网一站通
    protected void IsRenrenLogin()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("renrenkey", Request["renrenkey"]);
        values.Add("renrensecret", Request["renrensecret"]);
        values.Add("isrenrenlogin", Request["isrenrenlogin"]);
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
    }
    #endregion

    #region 开心网一站通
    protected void IsKaixin001Login()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("iskaixin001login", Request["iskaixin001login"]);
        values.Add("kaixin001id", Request["kaixin001id"]);
        values.Add("kaixin001key", Request["kaixin001key"]);
        values.Add("kaixin001secret", Request["kaixin001secret"]);
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
    }
    #endregion

    
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
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
                                    <h2>一站通</h2>
                                    <ul class="filter">
                                        <li></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <div class="tong_box1">
                                        <div class="field">
                                            <label>
                                                搜狐一站通</label>
                                            <input id="chsohu" name="chsohu" type="checkbox" <%=check %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                key:</label>
                                            <input type="text" size="30" name="key" value="<%=isystem.sohuloginkey %>" group="goto"
                                                id="key" class="f-input" />
                                        </div>
                                        <span class="tts">请向搜狐导航工作人员索取您的key值</span>
                                    </div>
                                    <div class="tong_box1" id="tong_box2" style="width:892px;">
                                        <div class="field">
                                            <label>
                                                支付宝快捷登录</label>
                                            <input id="Isalipaylogin" name="Isalipaylogin" type="checkbox" <% if(configs["Isalipaylogin"]=="1"){%>checked="checked"
                                                <%} %> value="1" />
                                        </div>
                                        <span class="tts">支付宝大快捷申请点击<a href="http://act.life.alipay.com/systembiz/asdht/?src=asdht"
                                            target="_blank">此处</a>,未注册支付宝大快捷的用户，请勿勾选，否则影响支付宝快捷登录错误</span>
                                    </div>
                                    <div class="tong_box1">
                                        <div class="field">
                                            <label>
                                                360一站通</label>
                                            <input id="Checkbox1" name="is360login" type="checkbox" <%if(configs["is360login"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                key:</label>
                                            <input type="text" size="30" name="login360key" value="<%=configs["login360key"] %>"
                                                group="goto" id="Text1" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                secret:</label>
                                            <input type="text" size="30" name="login360secret" value="<%=configs["login360secret"] %>"
                                                group="goto" id="secret" class="f-input" />
                                        </div>
                                        <span class="tts">请向360导航工作人员索取您的key值</span>
                                    </div>
                                    <div class="tong_box1" id="tong_box2" style="width:892px;">
                                        <div class="field">
                                            <label>
                                                2345一站通</label>
                                            <input id="is2345login" name="is2345login" type="checkbox" <%if(configs["is2345login"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                key:</label>
                                            <input type="text" size="30" name="login2345key" value="<%=configs["login2345key"] %>"
                                                group="goto" id="login2345key" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                secret:</label>
                                            <input type="text" size="30" name="login2345secret" value="<%=configs["login2345secret"] %>"
                                                group="goto" id="login2345secret" class="f-input" />
                                        </div>
                                        <span class="tts">请向2345导航工作人员索取您的key值</span>
                                    </div>
                                    <div class="tong_box1">
                                        <div class="field">
                                            <label>
                                                团800一站通</label>
                                            <input id="istuan800login" name="istuan800login" type="checkbox" <%if(configs["istuan800login"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                key:</label>
                                            <input type="text" size="30" name="logintuan800key" value="<%=configs["logintuan800key"] %>"
                                                group="goto" id="logintuan800key" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                secret:</label>
                                            <input type="text" size="30" name="logintuan800secret" value="<%=configs["logintuan800secret"] %>"
                                                group="goto" id="logintuan800secret" class="f-input" />
                                        </div>
                                        <span class="tts">请向团800导航工作人员索取您的key值</span>
                                    </div> 
                                    <div class="tong_box1" id="tong_box2" style="width:892px;">
                                        <div class="field">
                                            <label>
                                                QQ一站通</label>
                                            <input id="isqqlogin" name="isqqlogin" type="checkbox" <%if(configs["isqqlogin"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                appid:</label>
                                            <input type="text" size="30" name="loginqqkey" value="<%=configs["loginqqkey"]%>"
                                                group="goto" id="loginqqkey" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                appkey:</label>
                                            <input type="text" size="30" name="loginqqsecret" value="<%=configs["loginqqsecret"] %>"
                                                group="goto" id="loginqqsecret" class="f-input" />
                                        </div>
                                        <span class="tts">点击<a href="http://app.opensns.qq.com/dev_reg?proj=qz_connect" target="_blank">此处</a>申请QQ一站通key值</span>
                                    </div>
                                    <div class="tong_box1">
                                        <div class="field">
                                            <label>
                                                新浪微博一站通</label>
                                            <input id="Checkbox2" name="isSinalogin" type="checkbox" <%if(configs["isSinalogin"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                App Key:</label>
                                            <input type="text" size="30" name="loginSinakey" value="<%=configs["loginSinakey"] %>"
                                                group="goto" id="Text2" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                App Secret:</label>
                                            <input type="text" size="30" name="loginSinasecret" value="<%=configs["loginSinasecret"] %>"
                                                group="goto" id="Text3" class="f-input" />
                                        </div>
                                        <span class="tts">点击<a href="http://open.t.sina.com.cn/devel.php" target="_blank">此处</a>申请新浪微博一站通key值</span>
                                    </div>
                                    <div class="tong_box1" id="tong_box2" style="width:892px;">
                                        <div class="field">
                                            <label>
                                                网易微博一站通</label>
                                            <input id="is163login" name="is163login" type="checkbox" <%if(configs["is163login"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                key:</label>
                                            <input type="text" size="30" name="login163key" value="<%=configs["login163key"] %>"
                                                group="goto" id="login163key" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                secret:</label>
                                            <input type="text" size="30" name="login163secret" value="<%=configs["login163secret"] %>"
                                                group="goto" id="login163secret" class="f-input" />
                                        </div>
                                        <span class="tts">点击<a href="http://open.t.163.com/apps" target="_blank">此处</a>申请网易微博一站通key值</span>
                                    </div>
                                    <div class="tong_box1">
                                        <div class="field">
                                            <label>
                                                淘宝一站通</label>
                                            <input id="Checkbox3" name="istaobaologin" type="checkbox" <%if(configs["istaobaologin"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                App Key:</label>
                                            <input type="text" size="30" name="logintaobaokey" value="<%=configs["logintaobaokey"] %>"
                                                group="goto" id="Text4" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                App Secret:</label>
                                            <input type="text" size="30" name="logintaobaosecret" value="<%=configs["logintaobaosecret"] %>"
                                                group="goto" id="Text5" class="f-input" />
                                        </div>
                                        <span class="tts">点击<a href="http://open.taobao.com/" target="_blank">此处</a>申请淘宝一站通key值</span>
                                    </div>
                                    <div class="tong_box1" id="tong_box2" style="width:892px;">
                                        <div class="field">
                                            <label>
                                                百度一站通</label>
                                            <input id="isbaidulogin" name="isbaidulogin" type="checkbox" <%if(configs["isbaidulogin"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                应用ID:</label>
                                            <input type="text" size="30" name="baiduid" value="<%=configs["baiduid"] %>" group="goto"
                                                id="baiduid" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                API key:</label>
                                            <input type="text" size="30" name="baidukey" value="<%=configs["baidukey"] %>" group="goto"
                                                id="baidukey" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                secret:</label>
                                            <input type="text" size="30" name="baidusecret" value="<%=configs["baidusecret"] %>"
                                                group="goto" id="baidusecret" class="f-input" />
                                        </div>
                                        <span class="tts">点击<a href="http://dev.baidu.com/connect/" target="_blank">此处</a>申请百度一站通key值</span>
                                    </div>
                                    <div class="tong_box1">
                                        <div class="field">
                                            <label>
                                                人人网一站通</label>
                                            <input id="chkrenren" name="isrenrenlogin" type="checkbox" <%if(configs["isrenrenlogin"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                App Key:</label>
                                            <input type="text" size="30" name="renrenkey" value="<%=configs["renrenkey"] %>"
                                                group="goto" id="Text6" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                App Secret:</label>
                                            <input type="text" size="30" name="renrensecret" value="<%=configs["renrensecret"] %>"
                                                group="goto" id="Text7" class="f-input" />
                                        </div>
                                        <span class="tts">点击<a href="http://wiki.dev.renren.com/wiki/Authentication" target="_blank">此处</a>申请人人网一站通key值</span>
                                    </div>
                                    <div class="tong_box1" id="tong_box2" style="width:892px;">
                                        <div class="field">
                                            <label>
                                                开心网一站通</label>
                                            <input id="Checkbox4" name="iskaixin001login" type="checkbox" <%if(configs["iskaixin001login"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                应用ID:</label>
                                            <input type="text" size="30" name="kaixin001id" value="<%=configs["kaixin001id"] %>"
                                                group="goto" id="Text8" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                API key:</label>
                                            <input type="text" size="30" name="kaixin001key" value="<%=configs["kaixin001key"] %>"
                                                group="goto" id="Text9" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                secret:</label>
                                            <input type="text" size="30" name="kaixin001secret" value="<%=configs["kaixin001secret"] %>"
                                                group="goto" id="Text10" class="f-input" />
                                        </div>
                                        <span class="tts">点击<a href="http://open.kaixin001.com/" target="_blank">此处</a>申请开心网一站通key值</span>
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