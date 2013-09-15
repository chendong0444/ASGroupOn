<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Drawing.Text" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="AS.GroupOn.App" %>

<script runat="server">
    private NameValueCollection _system = null;
    private NameValueCollection _system1 = null;
    public WebUtils sysmodel = new WebUtils();
    IGuid guid = Store.CreateGuid();
    public string strLeftTop = "";
    public string strTopMiddle = "";
    public string strRightTop = "";
    public string strCenter = "";
    public string strRigthBottom = "";
    public string strLeftBottom = "";
    public string strBottomMiddle = "";
    public string strdramimgurl = "";
    public string strcheck = "";
    public string strcheck1 = "";
    public string strcheck2 = "";
    public string strcheck3 = "";
    public string strcheck4 = "";
    public string strcheck5 = "";
    public string strcheck6 = "";

    public string bulletinDiscount = "";
    public string bulletinPrice = "";
    public string mallheadlogo = "";
    public string mallfootlogo = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Mall_SetView))
        {
            SetError("你不具有查看商城基本设置的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        _system1 = WebUtils.GetSystem();
        if (!IsPostBack)
        {
            initFont();
            getSystem();
        }
    }
    private void initFont()
    {

        InstalledFontCollection ifc = new InstalledFontCollection();
        FontFamily[] ff = ifc.Families;
        foreach (FontFamily f in ff)
        {
            ListItem lt = new ListItem(f.Name.ToString(), f.Name.ToString());
            drawfont.Items.Add(lt);

        }
    }
    private string ReturnUrl()
    {
        string str = "";
        if (_system1["moretuan"] == "0")
            str = GetUrl("一日多团一", "index_tuanmore.aspx");
        else if (_system1["moretuan"] == "1")
            str = GetUrl("一日多团二", "index_tuanmore2.aspx");
        else if (_system1["moretuan"] == "2")
            str = GetUrl("一日多团三", "index_tuanmore3.aspx");
        else if (_system1["moretuan"] == "3")
            str = GetUrl("一日多团四", "index_tuanmore4.aspx");
        else if (_system1["moretuan"] == "4")
            str = GetUrl("一日多团五", "index_tuanmore5.aspx");
        else if (_system1["moretuan"] == "5")
            str = GetUrl("一日多团六", "index_tuanmore6.aspx");
        return str;
    }
    protected void save_Click(object sender, EventArgs e)
    {
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Mall_SetEdit))
        {
            SetError("你不具有修改商城基本设置的权限！");
            Response.Redirect(PageValue.WebRoot + "manage/SheZhi_mallJiben.aspx");
            Response.End();
            return;

        }
        _system = new NameValueCollection();
        _system.Add("headcatanum", Request["headcatanum"]);
        _system.Add("setmallindex", Request["ddlShouYe"]);
        _system.Add("MallTemplate", Request["MallTemplate"]);
        
        //商城首页显示
        GuidFilter guidfilter = new GuidFilter();
        IList<IGuid> ilistguid = null;
        if (ddlShouYe.Value == "1")
        {
            guidfilter.guidlink = "'index.aspx','" + PageValue.WWWprefix + "/index.aspx','/index.aspx'";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistguid = session.Guid.GetList(guidfilter);
            }
            foreach (var guidmodel in ilistguid)
            {
                guidmodel.guidlink = ReturnUrl();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int i = session.Guid.Update(guidmodel);
                }
            }

        }
        else if (ddlShouYe.Value == "0")
        {
            guidfilter.guidlink = "'" + ReturnUrl() + "'";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistguid = session.Guid.GetList(guidfilter);
            }
            foreach (var guidmodel in ilistguid)
            {
                guidmodel.guidlink = "/index.aspx";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int i = session.Guid.Update(guidmodel);
                }
            }
        }
        _system.Add("listcatanum", Request["listcatanum"]);
        _system.Add("mallsitename", Request["sitename"]);
        _system.Add("malltitle", Request["title"]);
        _system.Add("mallkeyword", Request["keyword"]);
        _system.Add("malldescription", Request["description"]);
        _system.Add("malldrawimg", Request["drawimg"]);
        _system.Add("malldrawfont", Request["drawfont"]);
        _system.Add("malldrawalpha", Request["drawalpha"]);
        _system.Add("malldrawposition", Request.Form["watermarkstatus"]);
        _system.Add("malldrawsize", Request.Form["drawsize"]);
        _system.Add("mallusedrawimg", Request.Form["usedrawimg"]);
        _system.Add("malldrawimgType", Request.Form["drawimgType"]);
        _system.Add("recommendnum", Request.Form["recommendnum"]);

        //折扣搜索的条件
        if (_system1["malldiscount"] != null && _system1["malldiscount"] != "")
        {
            //_system.Add("malldiscount", AddDiscount(Request["totalNumberDiscount"].Split('|').Length));
            _system.Add("malldiscount", AddDiscount(_system1["malldiscount"].Split('|').Length));
        }
        else
        {
            _system.Add("malldiscount", AddDiscount(0));
        }
        //价格搜索的条件
        if (_system1["mallprice"] != null && _system["mallprice"] != "")
        {
            //_system.Add("mallprice", AddPrice(Request["totalNumberPrice"].Split('|').Length));
            _system.Add("mallprice", AddPrice(_system1["mallprice"].Split('|').Length));
        }
        else
        {
            _system.Add("mallprice", AddPrice(0));
        }
        Random ran = new Random();

        #region 上传水印图片
        string strdramimgurl = PageValue.WebRoot + "upfile/dramimgurl/";
        if (drawmimgurl.FileName != "")
        {
            //判断上传文件的大小
            if (drawmimgurl.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = drawmimgurl.FileName;//获取待上传图片的完整路径，包括文件名 
            string hpictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (drawmimgurl.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".jpg" || suffix.ToLower() == ".png" || suffix.ToLower() == ".gif" || suffix.ToLower() == ".jpeg" || suffix.ToLower() == ".bmp")
                {
                    hpictureName = DateTime.Now.Ticks.ToString() + ran.Next() + suffix;
                }
                else
                {
                    SetError("图片格式不正确！");
                    Response.Redirect(PageValue.WebRoot + "manage/SheZhi_mallJiben.aspx");
                    Response.End();
                    return;
                }
            }
            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(strdramimgurl);
                    if (!Directory.Exists(path))
                    {
                        Directory.CreateDirectory(path);

                    }
                    drawmimgurl.PostedFile.SaveAs(path + hpictureName);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }

            string urldrawimg = strdramimgurl + hpictureName;
            _system.Add("malldrawimgurl", urldrawimg);

        }

        #endregion 上传headlogo图片

        string createUpload = PageValue.WebRoot + "upfile/logo/";
        if (headlogo.FileName != "")
        {
            #region 上传headlogo图片

            //判断上传文件的大小
            if (headlogo.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = headlogo.FileName;//获取待上传图片的完整路径，包括文件名 
            string hpictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (headlogo.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".jpg" || suffix.ToLower() == ".png" || suffix.ToLower() == ".gif" || suffix.ToLower() == ".jpeg" || suffix.ToLower() == ".bmp")
                {
                    hpictureName = DateTime.Now.Ticks.ToString() + ran.Next() + suffix;
                }
                else
                {
                    SetError("图片格式不正确！");
                    Response.Redirect(PageValue.WebRoot + "manage/SheZhi_mallJiben.aspx");
                    Response.End();
                    return;
                }

            }
            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(createUpload);
                    if (!Directory.Exists(path))
                    {
                        Directory.CreateDirectory(path);

                    }
                    headlogo.PostedFile.SaveAs(path + hpictureName);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }

            _system.Add("mallheadlogo", createUpload + hpictureName);
            #endregion
        }

        if (footlogo.FileName != "")
        {
            #region 上传footlogo图片

            //判断上传文件的大小
            if (footlogo.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = footlogo.FileName;//获取待上传图片的完整路径，包括文件名 
            string fpictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (footlogo.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".jpg" || suffix.ToLower() == ".png" || suffix.ToLower() == ".gif" || suffix.ToLower() == ".jpeg" || suffix.ToLower() == ".bmp")
                {
                    fpictureName = DateTime.Now.Ticks.ToString() + ran.Next() + suffix;
                }
                else
                {
                    SetError("图片格式不正确！");
                    Response.Redirect(PageValue.WebRoot + "manage/SheZhi_mallJiben.aspx");
                    Response.End();
                    return;
                }

            }
            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(createUpload);
                    if (!Directory.Exists(path))
                    {
                        Directory.CreateDirectory(path);

                    }
                    footlogo.PostedFile.SaveAs(path + fpictureName);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }

            _system.Add("mallfootlogo", createUpload + fpictureName);
            #endregion
        }

        sysmodel.CreateSystemByNameCollection(_system);
        for (int i = 0; i < _system.Count; i++)
        {
            string strKey = _system.Keys[i];
            string strValue = _system[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }


        SetSuccess("设置成功");
        Response.Redirect(PageValue.WebRoot + "manage/SheZhi_mallJiben.aspx");
        Response.End();
    }

    #region 显示折扣搜索条件
    public void GetDiscount(string oldDiscount)
    {
        for (int i = 0; i < oldDiscount.Split('|').Length; i++)
        {
            string[] str = oldDiscount.Split('|');
            if (str[i] != "" && str[i].Split(',')[0] != "")
            {
                bulletinDiscount += "<tr>";
                bulletinDiscount += "<td>";
                bulletinDiscount += "折扣条件：<input type=\"text\" class=\"numberkd\" name=\"StuNameaDiscount" + i + "\" value='" + str[i].Split(',')[0] + "'>-<input type=\"text\" class=\"numberkd\" name=\"StuNameaDiscount" + i + "\" value='" + str[i].Split(',')[1] + "'><input type=\"button\" value=\"删除\" onclick='deleteDiscount(this," + '"' + "tbDiscount" + '"' + ");'>";
                bulletinDiscount += "</td>";
                bulletinDiscount += "</tr>";
            }
        }
    }
    #endregion

    #region 显示价格搜索条件
    public void GetPrice(string oldPrice)
    {
        for (int i = 0; i < oldPrice.Split('|').Length; i++)
        {
            string[] str = oldPrice.Split('|');
            if (str[i] != "" && str[i].Split(',')[0] != "")
            {
                bulletinPrice += "<tr>";
                bulletinPrice += "<td>";
                bulletinPrice += "价格条件：<input type=\"text\" class=\"numberkd\" name=\"StuNameaPrice" + i + "\" value='" + str[i].Split(',')[0] + "'>-<input type=\"text\" class=\"numberkd\" name=\"StuNameaPrice" + i + "\" value='" + str[i].Split(',')[1] + "'><input type=\"button\" value=\"删除\" onclick='deletePrice(this," + '"' + "tbPrice" + '"' + ");'>";
                bulletinPrice += "</td>";
                bulletinPrice += "</tr>";
            }
        }
    }
    #endregion

    #region 添加折扣的搜索间隔
    public string AddDiscount(int countDiscount)
    {
        string str = string.Empty;


        for (int i = 0; i < countDiscount; i++)
        {
            if (Request["StuNameaDiscount" + i] != null && Request["StuNameaDiscount" + i].ToString() != "")
            {
                string[] strAttr = Request["StuNameaDiscount" + i].ToString().Split(',');
                if (strAttr[0] != null && strAttr[0].ToString() != "" && strAttr[1] != null && strAttr[1].ToString() != "")
                {
                    str += Request["StuNameaDiscount" + i] + "|";
                }

            }

        }

        if (Request["totalNumberDiscount"] != null && Request["totalNumberDiscount"] != "")
        {

            for (int i = 0; i < Convert.ToInt32(Request["totalNumberDiscount"]); i++)
            {
                if (Request["StuNameDiscount" + i] != null && Request["StuNameDiscount" + i] != null)
                {
                    string[] strAttr = Request["StuNameDiscount" + i].ToString().Split(',');
                    if (strAttr[0] != null && strAttr[0].ToString() != "" && strAttr[1] != null && strAttr[1].ToString() != "")
                    {
                        str += Request["StuNameDiscount" + i] + "|";
                    }
                }
            }
        }

        return str;
    }
    #endregion

    #region 添加价格的搜索间隔
    public string AddPrice(int countPrice)
    {
        string str = string.Empty;


        for (int i = 0; i < countPrice; i++)
        {
            if (Request["StuNameaPrice" + i] != null && Request["StuNameaPrice" + i].ToString() != "")
            {
                string[] strAttr = Request["StuNameaPrice" + i].ToString().Split(',');
                if (strAttr[0] != null && strAttr[0].ToString() != "" && strAttr[1] != null && strAttr[1].ToString() != "")
                {
                    str += Request["StuNameaPrice" + i] + "|";
                }

            }

        }

        if (Request["totalNumberPrice"] != null && Request["totalNumberPrice"] != "")
        {

            for (int i = 0; i < Convert.ToInt32(Request["totalNumberPrice"]); i++)
            {
                if (Request["StuNamePrice" + i] != null && Request["StuNamePrice" + i] != null)
                {
                    string[] strAttr = Request["StuNamePrice" + i].ToString().Split(',');
                    if (strAttr[0] != null && strAttr[0].ToString() != "" && strAttr[1] != null && strAttr[1].ToString() != "")
                    {
                        str += Request["StuNamePrice" + i] + "|";
                    }
                }
            }
        }

        return str;
    }
    #endregion
    private void getSystem()
    {

        _system = WebUtils.GetSystem();

        sitename.Value = _system["mallsitename"];
        MallTemplate.Value = _system["MallTemplate"];
        title.Value = _system["malltitle"];
        keyword.Value = _system["mallkeyword"];
        description.Value = _system["malldescription"];
        if (!string.IsNullOrEmpty(_system["headcatanum"]))
        {
            headcatanum.Value = _system["headcatanum"];
        }
        else
        {
            headcatanum.Value = "12";
        }
        if (!string.IsNullOrEmpty(_system["listcatanum"]))
        {
            listcatanum.Value = _system["listcatanum"];
        }
        else
        {
            listcatanum.Value = "5";
        }

        headlogodef.Value = _system["mallheadlogo"];
        footlogodef.Value = _system["mallfootlogo"];

        if (_system["setmallindex"] == "1")
        {
            ddlShouYe.Value = "1";

        }
        else
        {
            ddlShouYe.Value = "0";
        }

        drawimg.Value = _system["malldrawimg"];
        drawfont.Value = _system["malldrawfont"];
        if (!string.IsNullOrEmpty(_system["malldrawalpha"]))
        {
            drawalpha.Value = _system["malldrawalpha"];
        }
        else
        {
            drawalpha.Value = "0";
        }
        usedrawimg.Value = _system["mallusedrawimg"];
        drawimgType.Value = _system["malldrawimgType"];
        strdramimgurl = _system["malldrawimgurl"];
        if (!string.IsNullOrEmpty(_system["recommendnum"]))
        {
            recommendnum.Value = _system["recommendnum"];
        }
        else
        {
            recommendnum.Value = "12";
        }
        mallheadlogo = _system["mallheadlogo"];
        mallfootlogo = _system["mallfootlogo"];
        string position = _system["malldrawposition"];
        switch (position)
        {
            case "LeftTop":
                strLeftTop = " checked ";
                break;
            case "TopMiddle":
                strTopMiddle = " checked ";
                break;
            case "RightTop":
                strRightTop = " checked ";
                break;
            case "Center":
                strCenter = " checked ";
                break;
            case "LeftBottom":
                strLeftBottom = " checked ";
                break;
            case "BottomMiddle":
                strBottomMiddle = " checked ";
                break;
            case "RigthBottom":
                strRigthBottom = " checked ";
                break;
            default:
                strCenter = "checked";
                break;

        }
        if (_system["malldrawsize"] != null)
        {
            switch (_system["malldrawsize"])
            {
                case "48":
                    strcheck = "selected";
                    break;
                case "36":
                    strcheck1 = "selected";
                    break;
                case "28":
                    strcheck2 = "selected";
                    break;
                case "24":
                    strcheck3 = "selected";
                    break;
                case "16":
                    strcheck4 = "selected";
                    break;
                case "12":
                    strcheck5 = "selected";
                    break;
                case "10":
                    strcheck6 = "selected";
                    break;
            }
        }
        else
        {
            strcheck = "selected";
        }

        sitename.Value = _system["mallsitename"];

        if (_system["malldiscount"] != null && _system["malldiscount"] != "")
        {
            GetDiscount(_system["malldiscount"]);
        }

        if (_system["mallprice"] != null && _system["mallprice"] != "")
        {
            GetPrice(_system["mallprice"]);
        }
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
                                        <h2>商城基本</h2>
                                    </div>
                                    <div class="sect">
                                        <div class="wholetip clear">
                                            <h3>1、基本信息</h3>
                                        </div>
                                        <div class="field">
                                            <label>
                                                商城名称</label>
                                            <input type="text" size="30" name="sitename" id="sitename" class="f-input" group="goto"
                                                datatype="require" require="true" value="艾尚商城" runat="server" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                商城标题</label>
                                            <input type="text" size="30" name="title" id="title" maxlength="250" group="goto"
                                                class="f-input" runat="server" value="" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                商城关键字</label>
                                            <input type="text" size="30" name="keyword" id="keyword" maxlength="250" group="goto"
                                                require="true" class="f-input" runat="server" value="" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                商城描述</label>
                                            <input type="text" size="30" name="description" id="description" maxlength="1000"
                                                group="goto" require="true" class="f-input" runat="server" value="" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                头部LOGO</label>
                                            <asp:FileUpload ID="headlogo" runat="server" Height="26px" Width="694px" size="100" />
                                            <input type="hidden" name="headlogodef" id="headlogodef" runat="server" value="/upfile/img/mall_logo.png" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">建议大小是(263*58)像素&nbsp;&nbsp;</span><%=mallheadlogo%>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                底部LOGO</label>
                                            <asp:FileUpload ID="footlogo" runat="server" Height="26px" Width="694px" size="100" />
                                            <input type="hidden" name="footlogodef" id="footlogodef" runat="server" value="/upfile/img/mall_logo.png" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">大小是(172*39)像素&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><%=mallfootlogo%>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                设置商城为首页</label>
                                            <select id="ddlShouYe" name="ddlShouYe" runat="server" style="float: left;">
                                                <option value="0">否</option>
                                                <option value="1">是</option>
                                            </select>
                                            <span class="inputtip">&nbsp;&nbsp;选择"是"，则设置商城为首页，否则首页为团购</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                选择商城模板</label>
                                            <select id="MallTemplate" name="MallTemplate" runat="server" style="float: left;">
                                                <option value="0">米奇模板</option>
                                                <option value="1">京东模板</option>
                                            </select>
                                        </div>
                                        <div class="wholetip clear">
                                            <h3>2、商城分类设置</h3>
                                        </div>
                                        <div class="field">
                                            <label>
                                                首页顶部分类数</label>
                                            <input type="text" size="30" name="headcatanum" id="headcatanum" group="goto" datatype="integer"
                                                runat="server" class="number" value="12" />
                                            <span class="inputtip">首页顶部分类个数，默认为 12</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                首页分类列表数</label>
                                            <input id="listcatanum" type="text" class="number" name="listcatanum" value="5" runat="server"
                                                datatype="number" group="go" />
                                            <span class="inputtip">首页分类列表显示数，默认为 5</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                首页商品推荐数</label>
                                            <input type="text" size="30" name="recommendnum" id="recommendnum" group="goto" datatype="integer"
                                                runat="server" class="number" value="10" />
                                            <span class="inputtip">首页推荐产品、新品上架、热销产品、低价促销个数，默认为 12</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                折扣搜索间隔</label>
                                            <input type="button" name="btnAddDiscount" value="添加" onClick="addDiscount('tbDiscount')" /><font
                                                style='color: red'>例如 8-9</font>
                                        </div>
                                        <div class="field">
                                            <label>
                                            </label>
                                            <table id="tbDiscount">
                                                <%=bulletinDiscount%>
                                            </table>
                                            <input type="hidden" name="totalNumberDiscount" id="totalNumberDiscount" value="" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                价格搜索间隔</label>
                                            <input type="button" name="btnAddPrice" value="添加" onClick="addPrice('tbPrice')" /><font
                                                style='color: red'>例如 100-200</font>
                                        </div>
                                        <div class="field">
                                            <label>
                                            </label>
                                            <table id="tbPrice">
                                                <%=bulletinPrice%>
                                            </table>
                                            <input type="hidden" name="totalNumberPrice" id="totalNumberPrice" value="" />
                                        </div>
                                        <div class="wholetip clear">
                                            <h3>3、水印设置</h3>
                                        </div>
                                        <div class="field">
                                            <label>
                                                启用水印</label>
                                            <select id="usedrawimg" name="usedrawimg" runat="server">
                                                <option value="0">不使用</option>
                                                <option value="1">使用</option>
                                            </select>
                                        </div>
                                        <div class="field">
                                            <label>
                                                水印类型</label>
                                            <select id="drawimgType" name="drawimgType" runat="server">
                                                <option value="0">图片</option>
                                                <option value="1">文字</option>
                                            </select>
                                        </div>
                                        <div class="field">
                                            <label>
                                                水印文字</label>
                                            <input type="text" size="30" name="drawimg" id="drawimg" runat="server" value="" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                水印文字字体</label>
                                            <select id="drawfont" name="drawfont" runat="server">
                                            </select>
                                        </div>
                                        <div class="field">
                                            <label>
                                                水印文字大小</label>
                                            <select id="drawsize" name="drawsize" style="height: 22px;">
                                                <option style="font-size: 48px" value="48" <%=strcheck %>>48</option>
                                                <option value="36" <%=strcheck1 %> style="font-size: 36px;">36</option>
                                                <option value="28" <%=strcheck2 %> style="font-size: 28px;">28</option>
                                                <option value="24" <%=strcheck3 %> style="font-size: 24px;">24</option>
                                                <option value="16" <%=strcheck4 %> style="font-size: 16px;">16</option>
                                                <option value="12" <%=strcheck5 %> style="font-size: 12px;">12</option>
                                                <option value="10" <%=strcheck6 %> style="font-size: 10px;">10</option>
                                            </select>
                                        </div>
                                        <div class="field">
                                            <label>
                                                图片型水印文件</label>
                                            <asp:FileUpload ID="drawmimgurl" runat="server" Height="26px" Width="694px" size="100" />
                                            <div style="float: left; width: 600px; margin-left: 135px;">
                                                <input type="hidden" name="dramimgurl" id="dramimgurl" runat="server" value="<%--<%=dramimgurl()%>--%>" />
                                                <%=strdramimgurl%>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                水印透明度</label>
                                            <input type="text" size="30" class="number" name="system[drawalpha]" id="drawalpha"  group="goto" datatype="money"
                                                runat="server" value="" /><span class="inputtip">透明度(0.1~1.0之间)</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                水印位置</label>
                                            <table height="207" border="0" background="<%=PageValue.WebRoot %>upfile/css/i/flower.jpg"
                                                width="256">
                                                <tbody>
                                                    <tr>
                                                        <td align="center" width="33%" style="vertical-align: middle;">
                                                            <input type="radio" name="watermarkstatus" id="leftTop" <%=strLeftTop %> value="LeftTop" /><b>左上</b>
                                                        </td>
                                                        <td align="center" width="33%" style="vertical-align: middle;">
                                                            <input type="radio" name="watermarkstatus" id="topMiddle" <%=strTopMiddle %> value="TopMiddle" /><b>顶部居中</b>
                                                        </td>
                                                        <td align="center" width="33%" style="vertical-align: middle;">
                                                            <input type="radio" name="watermarkstatus" id="rightTop" <%=strRightTop %> value="RightTop" /><b>右上</b>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center" width="33%" style="vertical-align: middle;"></td>
                                                        <td align="center" width="33%" style="vertical-align: middle;">
                                                            <input type="radio" name="watermarkstatus" id="center" <%=strCenter %> value="Center" /><b>中心</b>
                                                        </td>
                                                        <td align="center" width="33%" style="vertical-align: middle;"></td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center" width="33%" style="vertical-align: middle;">
                                                            <input type="radio" name="watermarkstatus" id="leftBottom" <%=strLeftBottom %> value="LeftBottom" /><b>左下</b>
                                                        </td>
                                                        <td align="center" width="33%" style="vertical-align: middle;">
                                                            <input type="radio" name="watermarkstatus" id="bottomMiddle" <%=strBottomMiddle %>
                                                                value="BottomMiddle" /><b>底部居中</b>
                                                        </td>
                                                        <td align="center" width="33%" style="vertical-align: middle;">
                                                            <input type="radio" name="watermarkstatus" id="rigthBottom" <%=strRigthBottom %>
                                                                value="RigthBottom" /><b>右下</b>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                        <div class="act">
                                            <input type="submit" id="save" runat="server" name="commit" group="goto" class="validator formbutton"
                                                value="保存" onserverclick="save_Click" />
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
<script type="text/javascript">
    function onhide(obj) {
        if (obj.value == 1) {
            $("#type").show();
        } else {
            $("#type").hide();
        }
    }
    function issum(obj) {
        if (obj.value == 3 || obj.value == 4) {
            $("#host").show();
        } else {
            $("#host").hide();
        }

    }
    var num = 0;
    function addDiscount(id) {

        var row, cell, str;
        row = document.getElementById(id).insertRow(-1);
        if (row != null) {
            cell = row.insertCell(-1);
            cell.innerHTML = "折扣条件：<input type=\"text\" class=\"numberkd\" name=\"StuNameDiscount" + num + "\">-<input type=\"text\" class=\"numberkd\" name=\"StuNameDiscount" + num + "\"><input type=\"button\" value=\"删除\" onclick='deleteDiscount(this," + '"' + "tbDiscount" + '"' + ");'>";
        }
        num++
        document.getElementsByName("totalNumberDiscount")[0].value = num;
    }
    function addPrice(id) {

        var row, cell, str;
        row = document.getElementById(id).insertRow(-1);
        if (row != null) {
            cell = row.insertCell(-1);
            cell.innerHTML = "价格条件：<input type=\"text\" class=\"numberkd\" name=\"StuNamePrice" + num + "\">-<input type=\"text\" class=\"numberkd\" name=\"StuNamePrice" + num + "\"><input type=\"button\" value=\"删除\" onclick='deletePrice(this," + '"' + "tbPrice" + '"' + ");'>";
        }
        num++
        document.getElementsByName("totalNumberPrice")[0].value = num;
    }
    function deleteDiscount(obj, id) {
        var rowNum, curRow;
        curRow = obj.parentNode.parentNode;
        rowNum = document.getElementById(id).rows.length - 1;
        document.getElementById(id).deleteRow(curRow.rowIndex);
    }
    function deletePrice(obj, id) {
        var rowNum, curRow;
        curRow = obj.parentNode.parentNode;
        rowNum = document.getElementById(id).rows.length - 1;
        document.getElementById(id).deleteRow(curRow.rowIndex);
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>