<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Drawing.Text" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">

    protected IPagers<ISystem> pager = null;
    protected IList<ISystem> ilistsystem = null;

    public string check1 = "";
    public string check2 = "";
    public string check3 = "";
    public string check4 = "";
    public string check5 = "";

    public FileUtils sysmodel = new FileUtils();

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
    public string choice2 = "";
    public string choice3 = "";
    public string host = "0";//热销商品的个数
    protected ISystem system = Store.CreateSystem();
    protected NameValueCollection configs = new NameValueCollection();
    int i = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_SetTg_Jiben))
        {
            SetError("你不具有查看基本设置的权限！");
            Response.Redirect("Index_Index.aspx");
            Response.End();
            return;
        }
        if (!IsPostBack)
        {

            initFont();
            int id = 1;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                system = session.System.GetByID(id);
            }
            configs = WebUtils.GetSystem();
            if (configs["moretuan"] != null)//一日多团1
            {
                check1 = configs["moretuan"];
                ////是否显示今日更多团购
                check2 = "style='display:block;'";
            }
            else
            {
                check1 = configs["moretuan"];
                check2 = "style='display:none;'";
            }
            if (configs["shanhu"] != null)
            {
                check3 = configs["shanhu"];
            }
            if (!string.IsNullOrEmpty(configs["row"]))
            {
                if (configs["row"] == "2")
                {
                    choice2 = "checked";
                }
                else
                {
                    choice3 = "checked";
                }
            }
            sitedomain.Value = system.domain;
            drawimg.Value = configs["drawimg"];
            drawfont.Value = configs["drawfont"];
            if (!string.IsNullOrEmpty(configs["drawalpha"]))
            {
                drawalpha.Value = configs["drawalpha"];
            }
            else
            {
                drawalpha.Value = "0";
            }
            usedrawimg.Value = configs["usedrawimg"];
            if (configs["couponlength"] != null && configs["couponlength"] != "")
            {
                couponlength.Value = configs["couponlength"];
            }
            else
            {
                couponlength.Value = "12";
            }
            drawimgType.Value = configs["drawimgType"];
            strdramimgurl = configs["drawimgurl"];
            statcode.Value = system.statcode;
            ////今日团购显示个数
            if (configs["indexteam"] != null && configs["indexteam"].ToString() != "")
            {
                indexteam.Value = configs["indexteam"];
            }
            else
            {
                indexteam.Value = "0";
            }
            //详情项目显示数
            if (configs["teamdetailnum"] != null && configs["teamdetailnum"].ToString() != "")
            {
                teamdetailnum.Value = configs["teamdetailnum"].ToString();
            }
            else
            {
                teamdetailnum.Value = "9";
            }
            string position = configs["drawposition"];

            host = configs["thost"];//热销商品个数
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
                default: strCenter = "checked";
                    break;

            }
            if (configs["drawsize"] != null)
            {
                switch (configs["drawsize"])
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
            ////是否显示今日更多团购
            if (system.needmoretuan == 0)
            {
                ddlmore.Value = "0";
                check2 = "style='display:none;'";
            }
            else if (system.needmoretuan == 1)
            {
                ddlmore.Value = "1";
                check2 = "style='display:block;'";
            }
            
        }
    }
    ///// <summary>
    ///// 修改团购基本信息
    ///// </summary>
    public void UpdateInfo(object sender, EventArgs e)
    {
        ISystem system = Store.CreateSystem();
        NameValueCollection values = new NameValueCollection();
        using (IDataSession sesssion = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = sesssion.System.GetByID(1);
        }

        if (system != null)
        {
            system.sitename = Request["sitename"];
            system.sitetitle = Request["sitetitle"];
            system.abbreviation = Request["abbreviation"];
            system.title = Request["title"];
            system.keyword = Request["keyword"];
            system.description = Request["description"];
            system.jobtime = Request["jobtime"];
            system.couponname = Request["couponname"];
            system.currency = Request["currency"];
            system.currencyname = Request["currencyname"];
            system.invitecredit = decimal.Parse(Request["invitecredit"]);
            system.teamwhole = int.Parse(Request["shanhu"]);
            system.sideteam = Helper.GetInt(Request["sideteam"], 20);
            system.conduser = int.Parse(Request["conduser"]);
            system.partnerdown = int.Parse(Request["partnerdown"]);
            system.kefuqq = Request["kefuqq"];
            system.kefumsn = Request["kefumsn"];
            system.tuanphone = Request["tuanphone"];
            system.icp = Request["icp"];
            system.statcode = statcode.Value;
            system.sinablog = Request["sinajiwai"];
            system.qqblog = Request["tencentjiwai"];
            system.needmoretuan = int.Parse(Request["ddlmore"]);
            system.domain = Request["sitedomain"];
            system.id = 1;

        }

        WebUtils systemmodel = new WebUtils();
        //values.Add("domain", Request.Form["sitedomain"]);
        values.Add("drawimg", Request["drawimg"]);
        values.Add("moretuan", Request.Form["more"]);
        values.Add("thost", Request["thost"]);
        values.Add("row", Request["row"]);
        values.Add("indexteam", Request.Form["indexteam"]);
        values.Add("teamdetailnum", Request.Form["teamdetailnum"]);
        values.Add("couponlength", Request.Form["couponlength"]);
        values.Add("usedrawimg", Request.Form["usedrawimg"]);
        values.Add("drawimgType", Request.Form["drawimgType"]);
        values.Add("drawfont", Request.Form["drawfont"]);
        values.Add("drawsize", Request.Form["drawsize"]);
        values.Add("drawalpha", Request.Form["drawalpha"]);
        values.Add("drawposition", Request.Form["watermarkstatus"]);

        Random ran = new Random();

        //上传水印图片
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
            //string uploadName = InputFile.PostedFile.FileName; 
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
                    Response.Redirect(PageValue.WebRoot + "manage/shezhi_jiben.aspx");
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
            values.Add("drawimgurl", urldrawimg);

        }
        systemmodel.CreateSystemByNameCollection(values);

        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
        string createUpload = PageValue.WebRoot + "upfile/logo/";
        if (headlogo.FileName != "")
        {
            //判断上传文件的大小
            if (headlogo.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = headlogo.FileName;//获取待上传图片的完整路径，包括文件名 
            //string uploadName = InputFile.PostedFile.FileName; 
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
                    Response.Redirect(PageValue.WebRoot + "manage/shezhi_jiben.aspx");
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

            system.headlogo = createUpload + hpictureName;

        }

        if (footlogo.FileName != "")
        {
            //判断上传文件的大小
            if (footlogo.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = footlogo.FileName;//获取待上传图片的完整路径，包括文件名 
            //string uploadName = InputFile.PostedFile.FileName; 
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
                    Response.Redirect(PageValue.WebRoot + "manage/shezhi_jiben.aspx");
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

            system.footlogo = createUpload + fpictureName;

        }
        if (printlogo.FileName != "")
        {
            //判断上传文件的大小
            if (printlogo.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = printlogo.FileName;//获取待上传图片的完整路径，包括文件名 
            //string uploadName = InputFile.PostedFile.FileName; 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (printlogo.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".jpg" || suffix.ToLower() == ".png" || suffix.ToLower() == ".gif" || suffix.ToLower() == ".jpeg" || suffix.ToLower() == ".bmp")
                {
                    pictureName = DateTime.Now.Ticks.ToString() + ran.Next() + suffix;
                }
                else
                {
                    SetError("图片格式不正确！");
                    Response.Redirect(PageValue.WebRoot + "manage/shezhi_jiben.aspx");
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
                    printlogo.PostedFile.SaveAs(path + pictureName);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }

            system.printlogo = createUpload + pictureName;

        }

        if (emaillogo.FileName != "")
        {
            //判断上传文件的大小
            if (emaillogo.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传
            string uploadName = emaillogo.FileName;//获取待上传图片的完整路径，包括文件名 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (emaillogo.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".jpg" || suffix.ToLower() == ".png" || suffix.ToLower() == ".gif" || suffix.ToLower() == ".jpeg" || suffix.ToLower() == ".bmp")
                {
                    pictureName = DateTime.Now.Ticks.ToString() + ran.Next() + suffix;
                }
                else
                {
                    SetError("图片格式不正确！");
                    Response.Redirect(PageValue.WebRoot + "manage/shezhi_jiben.aspx");
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
                    emaillogo.PostedFile.SaveAs(path + pictureName);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            system.emaillogo = createUpload + pictureName;

        }
        if (iphone_icon.FileName != "")
        {
            //判断上传文件的大小
            if (iphone_icon.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传
            string uploadName = iphone_icon.FileName;//获取待上传图片的完整路径，包括文件名 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (iphone_icon.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".png")
                {
                    pictureName = DateTime.Now.Ticks.ToString() + ran.Next() + suffix;
                }
                else
                {
                    SetError("图片格式不正确，请您上传png格式的图标！");
                    Response.Redirect(PageValue.WebRoot + "manage/shezhi_jiben.aspx");
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
                    iphone_icon.PostedFile.SaveAs(path + pictureName);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            system.iphone_icon = createUpload + pictureName;
            
        }
        if (iphone_retina_icon.FileName != "")
        {
            //判断上传文件的大小
            if (iphone_retina_icon.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传
            string uploadName = iphone_retina_icon.FileName;//获取待上传图片的完整路径，包括文件名 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (iphone_retina_icon.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".png")
                {
                    pictureName = DateTime.Now.Ticks.ToString() + ran.Next() + suffix;
                }
                else
                {
                    SetError("图片格式不正确，请您上传png格式的图标！");
                    Response.Redirect(PageValue.WebRoot + "manage/shezhi_jiben.aspx");
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
                    iphone_retina_icon.PostedFile.SaveAs(path + pictureName);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            system.iphone_retina_icon = createUpload + pictureName;
        }
        if (ipad_icon.FileName != "")
        {
            //判断上传文件的大小
            if (ipad_icon.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传
            string uploadName = ipad_icon.FileName;//获取待上传图片的完整路径，包括文件名 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (ipad_icon.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".png")
                {
                    pictureName = DateTime.Now.Ticks.ToString() + ran.Next() + suffix;
                }
                else
                {
                    SetError("图片格式不正确,请您上传png格式的图标！");
                    Response.Redirect(PageValue.WebRoot + "manage/shezhi_jiben.aspx");
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
                    ipad_icon.PostedFile.SaveAs(path + pictureName);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            system.ipad_icon = createUpload + pictureName;
        }
        if (ipad_retina_icon.FileName != "")
        {
            //判断上传文件的大小
            if (ipad_retina_icon.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传
            string uploadName = ipad_retina_icon.FileName;//获取待上传图片的完整路径，包括文件名 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (ipad_retina_icon.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".png")
                {
                    pictureName = DateTime.Now.Ticks.ToString() + ran.Next() + suffix;
                }
                else
                {
                    SetError("图片格式不正确,请您上传png格式的图标！");
                    Response.Redirect(PageValue.WebRoot + "manage/shezhi_jiben.aspx");
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
                    ipad_retina_icon.PostedFile.SaveAs(path + pictureName);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            system.ipad_retina_icon = createUpload + pictureName;
            
        }
        if (iphone4_startup.FileName != "")
        {
            //判断上传文件的大小
            if (iphone4_startup.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传
            string uploadName = iphone4_startup.FileName;//获取待上传图片的完整路径，包括文件名 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (iphone4_startup.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".png")
                {
                    pictureName = DateTime.Now.Ticks.ToString() + ran.Next() + suffix;
                }
                else
                {
                    SetError("图片格式不正确,请您上传png格式的图片！");
                    Response.Redirect(PageValue.WebRoot + "manage/shezhi_jiben.aspx");
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
                    iphone4_startup.PostedFile.SaveAs(path + pictureName);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            system.iphone4_startup = createUpload + pictureName;
            
        }
        if (iphone5_startup.FileName != "")
        {
            //判断上传文件的大小
            if (iphone5_startup.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传
            string uploadName = iphone5_startup.FileName;//获取待上传图片的完整路径，包括文件名 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (iphone5_startup.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".png")
                {
                    pictureName = DateTime.Now.Ticks.ToString() + ran.Next() + suffix;
                }
                else
                {
                    SetError("图片格式不正确，请您上传png格式的图片！");
                    Response.Redirect(PageValue.WebRoot + "manage/shezhi_jiben.aspx");
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
                    iphone5_startup.PostedFile.SaveAs(path + pictureName);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            system.iphone5_startup = createUpload + pictureName;

        }
        
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            i = session.System.Update(system);
            ASSystem = session.System.GetByID(1);
        }


        SetSuccess("更新成功！！");
        Response.Redirect(PageValue.WebRoot + "manage/SheZhi_Jiben.aspx");
        Response.End();
    }

    /// <summary>
    /// 初始化字体
    /// </summary>
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
                            <div class="box clear ">
                                <div class="box-content clear mainwide">
                                    <div class="head">
                                        <h2>团购基本</h2>
                                    </div>
                                    <div class="sect">
                                        <div class="wholetip clear">
                                            <h3>1、基本信息</h3>
                                        </div>
                                        <div class="field">
                                            <label>
                                                网站名称</label>
                                            <input type="text" size="30" name="sitename" id="sitename" class="f-input" group="goto"
                                                datatype="require" require="true" value="<%=system.sitename %>" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                网站域名</label>
                                            <input type="text" size="30" class="f-input" group="goto" datatype="require" require="true"
                                                runat="server" name="sitedomain" id="sitedomain" value="<%=PageValue.CurrentSystem.domain %>" />
                                            <span class="inputtip">&nbsp;&nbsp;&nbsp;&nbsp;如：http://www.域名.com</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                网站标题</label>
                                            <input type="text" size="30" name="sitetitle" id="sitetitle" group="goto" require="true"
                                                class="f-input" value="<%=system.sitetitle %>" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                网站简称</label>
                                            <input type="text" size="30" name="abbreviation" id="abbreviation" group="goto" require="true"
                                                class="f-input" value="<%=system.abbreviation %>" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                SEO标题</label>
                                            <input type="text" size="30" name="title" id="title" maxlength="250" group="goto"
                                                class="f-input" value="<%=system.title %>" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                SEO关键字</label>
                                            <input type="text" size="30" name="keyword" id="keyword" maxlength="250" group="goto"
                                                require="true" class="f-input" value="<%=system.keyword %>" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                SEO描述</label>
                                            <input type="text" size="30" name="description" id="description" maxlength="1000"
                                                group="goto" require="true" class="f-input" value="<%=system.description %>" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                工作日期</label>
                                            <input type="text" size="30" name="jobtime" id="jobtime" group="goto" require="true"
                                                class="f-input" value="<%=system.jobtime %>" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                优惠券名</label>
                                            <input type="text" size="30" name="couponname" id="couponname" class="f-input" value="<%=system.couponname %>" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                货币符号</label>
                                            <input type="text" size="30" name="currency" id="currency" class="number" value="<%=system.currency %>" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                货币代码</label>
                                            <input type="text" size="30" name="currencyname" group="goto" id="currencyname" class="number"
                                                value="<%=system.currencyname %>" /><span class="inputtip">如：CNY, USD 等</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                邀请返利</label>
                                            <input type="text" size="30" name="invitecredit" id="invitecredit" group="goto" datatype="money"
                                                class="number" value="<%=system.invitecredit %>" />
                                            <span class="inputtip">单位：元</span>
                                        </div>
                                        <div class="field" style="margin-top: 0px">
                                            <label>
                                                头部LOGO</label>
                                            <asp:FileUpload ID="headlogo" runat="server" Height="26px" Width="550px" size="100" />
                                            <input type="hidden" name="headlogodef" id="headlogodef" value="logo.gif" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">建议大小是(263*58)像素&nbsp;&nbsp;</span><%=system.headlogo %>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                底部LOGO</label>
                                            <asp:FileUpload ID="footlogo" runat="server" Height="26px" Width="550px" size="100" />
                                            <input type="hidden" name="footlogodef" id="footlogodef" value="logo-footer.gif" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">大小是(172*39)像素&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><%=system.footlogo %>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                打印页LOGO</label>
                                            <asp:FileUpload ID="printlogo" runat="server" Height="26px" Width="550px" size="100" />
                                            <input type="hidden" name="printlogodef" id="printlogodef" value="/upfile/img/coupon-tpl-logo.jpg" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">大小是(340*80)像素&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><%=system.printlogo %>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                订邮件LOGO</label>
                                            <asp:FileUpload ID="emaillogo" runat="server" Height="26px" Width="550px" size="100" />
                                            <input type="hidden" name="emaillogodef" id="emaillogodef" value="" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">大小是(137*57)像素&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><%=system.emaillogo %>
                                            </div>
                                        </div>
                                        <div class="wholetip clear">
                                            <h3>2、一日多团设置</h3>
                                        </div>
                                        <div class="field">
                                            <label>
                                                <strong><font color="#FF0000">一日多团</font></strong>
                                            </label>
                                            <select id="ddlmore" name="ddlmore" runat="server" style="float: left;" onchange="onhide(this)">
                                                <option value="0">否</option>
                                                <option value="1">是</option>
                                            </select>
                                            <div id="type" <%=check2 %>>
                                                <label>
                                                    <strong><font color="#FF0000">选择模式</font></strong>
                                                </label>
                                                <select id="more" name="more" onchange="issum(this)" style="float: left;">
                                                    <%if (check1 == "0")
                                                      { %>
                                                    <option value="0" selected="selected">一日多团1</option>
                                                    <option value="1">一日多团2</option>
                                                    <option value="2">一日多团3</option>
                                                    <option value="3">一日多团4</option>
                                                    <option value="4">一日多团5</option>
                                                    <option value="5">一日多团6</option>
                                                    <% }
                                                      else if (check1 == "1")
                                                      {%>
                                                    <option value="0">一日多团1</option>
                                                    <option value="1" selected="selected">一日多团2</option>
                                                    <option value="2">一日多团3</option>
                                                    <option value="3">一日多团4</option>
                                                    <option value="4">一日多团5</option>
                                                    <option value="5">一日多团6</option>
                                                    <% }
                                                      else if (check1 == "2")
                                                      {%>
                                                    <option value="0">一日多团1</option>
                                                    <option value="1">一日多团2</option>
                                                    <option value="2" selected="selected">一日多团3</option>
                                                    <option value="3">一日多团4</option>
                                                    <option value="4">一日多团5</option>
                                                    <option value="5">一日多团6</option>
                                                    <% }
                                                      else if (check1 == "3")
                                                      {%>
                                                    <option value="0">一日多团1</option>
                                                    <option value="1">一日多团2</option>
                                                    <option value="2">一日多团3</option>
                                                    <option value="3" selected="selected">一日多团4</option>
                                                    <option value="4">一日多团5</option>
                                                    <option value="5">一日多团6</option>
                                                    <% }
                                                      else if (check1 == "4")
                                                      {%>
                                                    <option value="0">一日多团1</option>
                                                    <option value="1">一日多团2</option>
                                                    <option value="2">一日多团3</option>
                                                    <option value="3">一日多团4</option>
                                                    <option value="4" selected="selected">一日多团5</option>
                                                    <option value="5">一日多团6</option>
                                                    <%}
                                                      else if (check1 == "5")
                                                      {%>
                                                    <option value="0">一日多团1</option>
                                                    <option value="1">一日多团2</option>
                                                    <option value="2">一日多团3</option>
                                                    <option value="3">一日多团4</option>
                                                    <option value="4">一日多团5</option>
                                                    <option value="5" selected="selected">一日多团6</option>
                                                    <%}
                                                      else
                                                      {%>
                                                    <option value="0">一日多团1</option>
                                                    <option value="1">一日多团2</option>
                                                    <option value="2">一日多团3</option>
                                                    <option value="3">一日多团4</option>
                                                    <option value="4">一日多团5</option>
                                                    <option value="5">一日多团6</option>
                                                    <% }%>
                                                </select>
                                                <div style="clear: both;">
                                                </div>
                                            </div>
                                            <div id="host" <%if (check1 != "3" && check1 != "4")
                                                             { %> style="display: none;" <% }%>>
                                                首页推荐显示个数：<input type="text" id="thost" name="thost" value="<%=configs["thost"]%>"
                                                    group="goto" datatype="number" />
                                            </div>
                                            <%--style="padding-left:310px"--%>
                                            <div id="display" <%if (check1 != "5")
                                                                { %>style="display: none; padding-left:310px"
                                                <%}%> style="padding-left: 310px">
                                                <input type="radio" name="row" value="2" id="row2" <%=choice2 %> />2排
                                            <input type="radio" name="row" value="3" id="row3" <%=choice3 %> />3排
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                项目详情页展示</label>
                                            <select id="shanhu" name="shanhu">
                                                <%if (system.teamwhole == 0)
                                                  {%>
                                                <option value="0" selected="selected">左右两列</option>
                                                <option value="1">通栏模式</option>
                                                <% }
                                                  else if (system.teamwhole == 1)
                                                  {%>
                                                <option value="0">左右两列</option>
                                                <option value="1" selected="selected">通栏模式</option>
                                                <% }
                                                  else
                                                  {%>
                                                <option value="0">左右两列</option>
                                                <option value="1">通栏模式</option>
                                                <%} %>
                                            </select>
                                        </div>
                                        <div class="field">
                                            <label>
                                                首页今日团购个数</label>
                                            <input type="text" size="30" name="indexteam" id="indexteam" runat="server" group="goto"
                                                datatype="number" class="number" />
                                            <span class="inputtip">首页今日团购个数，默认为 0</span> <span class="hint"></span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                详情右侧团购个数</label>
                                            <input type="text" size="30" name="sideteam" id="sideteam" datatype="number" group="goto"
                                                class="number" value="<%=system.sideteam %>" />
                                            <span class="inputtip">一日多团项目显示个数，默认为 20</span> <span class="hint">在团购页面的右侧栏显示和当前正在进行的其他团购项目个数</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                详情显示项目数</label>
                                            <input id="teamdetailnum" type="text" runat="server" class="number" value="" name="teamdetailnum"
                                                datatype="number" group="goto" />
                                            <span class="inputtip">项目详情中间显示项目个数</span>
                                        </div>
                                        <div class="wholetip clear">
                                            <h3>3、杂项设置</h3>
                                        </div>
                                        <div class="field">
                                            <label>
                                                成团条件</label>
                                            <input type="text" size="30" name="conduser" id="conduser" class="number" datatype="integer"
                                                group="goto" value="<%=system.conduser %>" /><span class="inputtip">1 以成功付款人数为限 0 以成交产品数量为限</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                优惠券下载</label>
                                            <input type="text" size="30" name="partnerdown" id="partnerdown" datatype="integer"
                                                group="goto" class="number" value="<%=system.partnerdown %>" /><span class="inputtip">1
                                                商户的优惠券密码不加密，0 商户的优惠券密码加密</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                优惠券长度</label>
                                            <select id="couponlength" name="couponlength" runat="server">
                                                <option value="5">5</option>
                                                <option value="6">6</option>
                                                <option value="7">7</option>
                                                <option value="8">8</option>
                                                <option value="9">9</option>
                                                <option value="10">10</option>
                                                <option value="11">11</option>
                                                <option value="12">12</option>
                                                <option value="13">13</option>
                                                <option value="14">14</option>
                                            </select>
                                        </div>
                                        <div class="wholetip clear">
                                            <h3>4、水印设置</h3>
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
                                            <input type="text" size="30" name="drawimg" runat="server" id="drawimg" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                水印文字字体</label>
                                            <select id="drawfont" runat="server" name="drawfont">
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
                                                <input type="hidden" name="dramimgurl" id="dramimgurl" value="" />
                                                <%=strdramimgurl%>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                水印透明度</label>
                                            <input type="text" size="30" class="number" runat="server" name="drawalpha" id="drawalpha"
                                                value="" /><span class="inputtip">透明度(0.1~1.0之间)</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                水印位置</label>
                                            <table height="202" style="padding-bottom: 5px" border="0" background="<%=PageValue.WebRoot %>upfile/css/i/flower.jpg"
                                                width="256">
                                                &nbsp;<tbody>
                                                    <tr>
                                                        <td width="33%" align="center" style="vertical-align: bottom;">
                                                            <input type="radio" name="watermarkstatus" id="leftTop" <%=strLeftTop %> value="LeftTop" />
                                                        </td>
                                                        <td align="center" width="33%" style="vertical-align: bottom;">
                                                            <b><b>
                                                                <input type="radio" name="watermarkstatus" id="topMiddle" <%=strTopMiddle %> value="TopMiddle" />
                                                            </b></b>
                                                        </td>
                                                        <td width="33%" align="center" style="vertical-align: bottom;">
                                                            <input type="radio" name="watermarkstatus" id="rightTop" <%=strRightTop %> value="RightTop" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td width="33%" align="center" style="vertical-align: middle;">
                                                            <b>左上</b>
                                                        </td>
                                                        <td align="center" style="vertical-align: middle;">
                                                            <b>顶部居中</b>
                                                        </td>
                                                        <td width="33%" align="center" style="vertical-align: middle;">
                                                            <b>右上</b>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td width="33%" rowspan="2" align="center" style="vertical-align: top;"></td>
                                                        <td align="center" width="33%" style="vertical-align: middle;">
                                                            <input type="radio" name="watermarkstatus" id="center" <%=strCenter %> value="Center" />
                                                        </td>
                                                        <td width="33%" rowspan="2" align="center" style="vertical-align: middle;"></td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center" style="vertical-align: top;">
                                                            <b>中心</b>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center" width="33%" style="vertical-align: bottom;">
                                                            <input type="radio" name="watermarkstatus" id="leftBottom" <%=strLeftBottom %> value="LeftBottom" />
                                                        </td>
                                                        <td width="33%" align="center" style="vertical-align: bottom;">
                                                            <input type="radio" name="watermarkstatus" id="bottomMiddle" <%=strBottomMiddle %>
                                                                value="BottomMiddle" />
                                                        </td>
                                                        <td width="33%" align="center" style="vertical-align: bottom;">
                                                            <input type="radio" name="watermarkstatus" id="rigthBottom" <%=strRigthBottom %>
                                                                value="RigthBottom" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center" style="vertical-align: top;">
                                                            <b><b>左</b>下</b>
                                                        </td>
                                                        <td width="33%" align="center" style="vertical-align: top;">
                                                            <b>底部居中</b>
                                                        </td>
                                                        <td width="33%" align="center" style="vertical-align: top;">
                                                            <b>右下</b>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                        <div class="wholetip clear">
                                            <h3>5、客服信息</h3>
                                        </div>
                                        <div class="field">
                                            <label>
                                                客服QQ</label>
                                            <input type="text" size="30" name="kefuqq" group="goto" id="kefuqq" class="f-input"
                                                value="<%=system.kefuqq %>" />
                                        </div>
                                        <div style="float: left; width: 600px; margin-left: 135px">
                                            <span class="inputtip">&nbsp;&nbsp;输入多个客服QQ时之间要使用半角的逗号隔开&nbsp;&nbsp;</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                客服MSN</label>
                                            <input type="text" size="30" name="kefumsn" id="kefumsn" class="f-input" value="<%=system.kefumsn %>" />
                                        </div>
                                        <div style="float: left; width: 600px; margin-left: 135px">
                                            <span class="inputtip">&nbsp;&nbsp;输入多个客服MSN时之间要使用半角的逗号隔开&nbsp;&nbsp;</span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                团购电话</label>
                                            <input type="text" size="30" name="tuanphone" id="tuanphone" class="f-input" value="<%=system.tuanphone %>" />
                                        </div>
                                        <div style="float: left; width: 600px; margin-left: 135px">
                                            <span class="inputtip">&nbsp;&nbsp;请输入一个团购电话，以便优惠券短信的发送&nbsp;&nbsp;</span>
                                        </div>
                                        <div class="wholetip clear">
                                            <h3>6、手机端桌面图标设置</h3>
                                        </div>
                                        <div class="field">
                                            <label>
                                                iPhone</label>
                                            <asp:FileUpload ID="iphone_icon" runat="server" Height="26px" Width="550px" size="100" />
                                            <input type="hidden" name="footlogodef" id="Hidden1" value="logo-footer.gif" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">大小是(57*57)像素&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><%=system.iphone_icon %>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                iPhone Retina</label>
                                            <asp:FileUpload ID="iphone_retina_icon" runat="server" Height="26px" Width="550px" size="100" />
                                            <input type="hidden" name="footlogodef" id="Hidden2" value="logo-footer.gif" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">大小是(114*114)像素&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><%=system.iphone_retina_icon %>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                iPad</label>
                                            <asp:FileUpload ID="ipad_icon" runat="server" Height="26px" Width="550px" size="100" />
                                            <input type="hidden" name="footlogodef" id="Hidden3" value="logo-footer.gif" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">大小是(72*72)像素&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><%=system.ipad_icon %>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                iPad Retina</label>
                                            <asp:FileUpload ID="ipad_retina_icon" runat="server" Height="26px" Width="550px" size="100" />
                                            <input type="hidden" name="footlogodef" id="Hidden4" value="logo-footer.gif" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">大小是(144*144)像素&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><%=system.ipad_retina_icon %>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                iPhone4/4s启动画面</label>
                                            <asp:FileUpload ID="iphone4_startup" runat="server" Height="26px" Width="550px" size="100" />
                                            <input type="hidden" name="footlogodef" id="Hidden5" value="logo-footer.gif" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">大小是(640*920)像素&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><%=system.iphone4_startup %>
                                            </div>
                                        </div>
                                        <div class="field">
                                            <label>
                                                iPhone5启动画面</label>
                                            <asp:FileUpload ID="iphone5_startup" runat="server" Height="26px" Width="550px" size="100" />
                                            <input type="hidden" name="footlogodef" id="Hidden6" value="logo-footer.gif" />
                                            <div style="float: left; width: 600px; margin-left: 135px">
                                                <span class="inputtip">大小是(640*1096)像素&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><%=system.iphone5_startup %>
                                            </div>
                                        </div>
                                        <div class="wholetip clear">
                                            <h3>7、其他信息</h3>
                                        </div>
                                        <div class="field">
                                            <label>
                                                ICP编号</label>
                                            <input type="text" size="30" name="icp" id="icp" group="goto" class="f-input" value="<%=system.icp %>" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                统计代码</label>
                                            <input type="text" runat="server" style="height: 109px" size="30" name="statcode"
                                                id="statcode" class="f-input" value="" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                新浪微博</label>
                                            <input type="text" size="30" name="sinajiwai" id="sinajiwai" class="f-input" value="<%=system.sinablog %>" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                腾讯微博</label>
                                            <input type="text" size="30" name="tencentjiwai" id="tencentjiwai" class="f-input"
                                                value="<%=system.qqblog %>" />
                                        </div>
                                        <div class="act">
                                            <input type="submit" id="submit" runat="server" group="goto" class="validator formbutton"
                                                value="保存" onserverclick="UpdateInfo" />
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
                $("#display").hide();

            } else if (obj.value == 5) {
                $("#host").hide();
                $("#display").show();
                $("#row2").attr("checked", "checked");

            } else {
                $("#host").hide();
                $("#display").hide();

            }

        }

    </script>
</body>
<%LoadUserControl("_footer.ascx", null); %>
