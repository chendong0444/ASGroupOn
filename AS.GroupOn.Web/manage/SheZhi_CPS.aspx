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
    
    protected NameValueCollection configs = new NameValueCollection();
    protected WebUtils webutils = new WebUtils();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_CPS))
        {
            SetError("你不具有查看CPS列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request.HttpMethod == "POST")
        {
            Update();
        }

        configs = AS.Common.Utils.FileUtils.GetConfig();
        
    }

    /// <summary>
    /// 修改
    /// </summary>
    protected void Update()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("open51fanli", Request.Form["open51fanli"]);
        values.Add("_51fanliid", Request.Form["_51fanliid"]);
        values.Add("_51fanlisecret", Request.Form["_51fanlisecret"]);
        values.Add("openlinktech", Request.Form["openlinktech"]);
        values.Add("linktechid", Request.Form["linktechid"]);
        values.Add("opentmtb", Request.Form["opentmtb"]);
        values.Add("tmtbkey", Request.Form["tmtbkey"]);
        values.Add("openyotao", Request.Form["openyotao"]);
        values.Add("yotaokey", Request.Form["yotaokey"]);
        values.Add("yotaosecret", Request.Form["yotaosecret"]);
        values.Add("opentpy", Request.Form["opentpy"]);
        values.Add("tpykey", Request.Form["tpykey"]);
        values.Add("tpysecret", Request.Form["tpysecret"]);
        values.Add("openrenrenzhe", Request.Form["openrenrenzhe"]);
        values.Add("renrenzhe", Request.Form["renrenzhe"]);
        values.Add("rrzsecret", Request.Form["rrzsecret"]);
        values.Add("open360", Request.Form["open360"]);
        values.Add("cps360appid", Request.Form["cps360appid"]);
        values.Add("cps360appkey", Request.Form["cps360appkey"]);
        values.Add("cps360bili", Request.Form["cps360bili"]);
        
        webutils.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
        SetSuccess("保存成功");

    }

    
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
                    <div id="content" class="box-content">
                        <div class="box clear">
                            <div class="box-content clear mainwide">
                                <div class="head">
                                    <h2>
                                        CPS设置</h2>
                                    <ul class="filter">
                                        <li></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <div class="tong_box1">
                                        <div class="field">
                                            <label>
                                                领克特CPS</label>
                                            <input id="openlinktech" name="openlinktech" type="checkbox" <%if(configs["openlinktech"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                网站标识:</label>
                                            <input type="text" size="30" name="linktechid" value="<%=configs["linktechid"] %>"
                                                 id="linktechid" class="f-input" />
                                        </div>
                                        <span class="tts">请向<a href="http://www.linktech.cn" target="_blank">领克特</a>工作人员索取您的网站标识</span>
                                    </div>
                                    <div class="tong_box1" id="tong_box2" style="width:892px;">
                                        <div class="field">
                                            <label>
                                                优淘CPS</label>
                                            <input id="openyotao" name="openyotao" type="checkbox" <%if(configs["openyotao"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                网站标识:</label>
                                            <input type="text" size="30" name="yotaokey" value="<%=configs["yotaokey"] %>"
                                                 id="yotaokey" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                密钥:</label>
                                            <input type="text" size="30" name="yotaosecret" value="<%=configs["yotaosecret"] %>"
                                                 id="yotaosecret" class="f-input" />
                                        </div>
                                        <span class="tts">请向<a href="http://www.yotao.com" target="_blank">优淘</a>工作人员索取您的网站标识和密钥</span>
                                    </div>
                                    <div class="tong_box1">
                                        <div class="field">
                                            <label>
                                                太平洋CPS</label>
                                            <input id="opentpy" name="opentpy" type="checkbox" <%if(configs["opentpy"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                网站标识:</label>
                                            <input type="text" size="30" name="tpykey" value="<%=configs["tpykey"] %>"
                                                 id="tpykey" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                密钥:</label>
                                            <input type="text" size="30" name="tpysecret" value="<%=configs["tpysecret"] %>"
                                                 id="tpysecret" class="f-input" />
                                        </div>
                                        <span class="tts">请向<a href="http://fanli.tpy100.com" target="_blank">太平洋</a>工作人员索取您的网站标识和密钥</span>
                                    </div>
                                    <%-- 人人折CPS--%>
                                    <div class="tong_box1" id="tong_box2" style="width:892px;">
                                        <div class="field">
                                            <label>
                                                人人折CPS</label>
                                            <input id="openrenrenzhe" name="openrenrenzhe" type="checkbox" <%if(configs["openrenrenzhe"]=="1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                网站标识:</label>
                                            <input type="text" size="30" name="renrenzhe" value="<%=configs["renrenzhe"] %>"
                                                 id="renrenzhe" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                密钥:</label>
                                            <input type="text" size="30" name="rrzsecret" value="<%=configs["rrzsecret"] %>"
                                                id="rrzsecret" class="f-input" />
                                        </div>
                                        <span class="tts">请向<a href="http://www.renrenzhe.com" target="_blank">人人折</a>工作人员索取您的网站标识和密钥</span>
                                    </div>
                                   <div class="tong_box1" id="360" style="width:892px;display:none" >
                                        <div class="field">
                                            <label>
                                                360CPS</label>
                                            <input id="open360" name="open360" type="checkbox" <%if (configs["open360"] == "1"){ %>
                                                checked="checked" <%} %> value="1" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                网站标识:</label>
                                            <input type="text" size="30" name="cps360appid" value="<%=configs["cps360appid"] %>"
                                                 id="cps360appid" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                密钥:</label>
                                            <input type="text" size="30" name="cps360appkey" value="<%=configs["cps360appkey"] %>"
                                                id="cps360appkey" class="f-input" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                CPS分成比例:</label>
                                            <input type="text" size="30" name="cps360bili" value="<%=configs["cps360bili"] %>"
                                                id="cps360bili" class="f-input" />
                                        </div>
                                         <span class="tts">如:CPS分成比例4%,填写0.04即可</span>
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