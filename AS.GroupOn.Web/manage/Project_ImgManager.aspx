<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected List<string> lstExt = new List<string>() { ".png", ".jpg", ".gif", ".bmp", "jpeg" };
    protected string relupath = string.Empty;
    protected string widthAndHeight = string.Empty;

    protected string selValue = string.Empty;
    protected string dir = string.Empty;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Image_Delete))
        {
            SetError("你不具有管理图片的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (!IsPostBack)
        {
            GetDirName();
        }
        if (Request["btnsee"] == "查看")
        {
            selValue = DropDir.SelectedValue;
            if (selValue == "0")
            {
                SetError("请选择目录！");
            }
            else
            {
                GetDirIMG(selValue);
            }

        }


        if (Request["btndel"] == "删除目录")
        {
            selValue = DropDir.SelectedValue;
            if (selValue == "0")
            {
                SetError("请选择目录！");
            }
            else
            {
                string dirpath = Server.MapPath("..\\" + selValue);
                try
                {
                    if (System.IO.Directory.Exists(dirpath))
                    {
                        DeleteDir(dirpath);
                        SetSuccess("删除目录成功！");
                    }
                }
                catch
                {
                    SetError("删除目录失败！");
                }
            }
            Response.Redirect("Project_ImgManager.aspx");
        }


        if (!string.IsNullOrEmpty(Request["delimg"]))
        {
            string imgpath = Server.MapPath("..\\" + Request["delimg"]);
            try
            {
                if (File.Exists(imgpath))
                {
                    DELImg(imgpath);
                    //SetSuccess("删除成功！");
                    DropDir.SelectedValue = Path.GetDirectoryName(Request["delimg"]);
                    dir = DropDir.SelectedValue;
                }
                else
                {
                    SetError("文件不存在！");
                }
            }
            catch
            {
                SetError("未知错误，删除失败！");
            }
            Response.Redirect("Project_ImgManager.aspx?dir=" + dir);
        }

        if (!string.IsNullOrEmpty(Request["dir"]) && string.IsNullOrEmpty(Request["btnsee"]) && string.IsNullOrEmpty(Request["btndel"]))
        {
            relupath = Server.MapPath("..\\" + Request["dir"]);
            if (!Directory.Exists(relupath))
            {
                SetError("目录不存在！");
            }
            else
            {
                DropDir.SelectedValue = Request["dir"];
                GetDirIMG(DropDir.SelectedValue);
            }
        }
    }


    private void GetDirName()
    {
        string path = Request.MapPath("~/upload/images");
        if (Directory.Exists(path))
        {
            DropDir.Items.Add(new ListItem("请选择", "0"));
            string[] dirPaths = Directory.GetDirectories(path);
            for (int i = 0; i < dirPaths.Length; i++)
            {
                string dirName = Path.GetFileName(dirPaths[i]);
                if (dirName.Contains("day_"))
                {
                    DropDir.Items.Add(new ListItem(dirName, GetDayDirName(dirPaths[i])));
                }
            }
            DropDir.DataBind();
        }

    }

    /// <summary>
    /// 递归删除文件夹，避免只读文件导致删除不了的情况
    /// </summary>
    /// <param name="dir">文件夹全路径</param>
    private static void DeleteDir(string dir)
    {
        if (Directory.Exists(dir)) //判断是否存在   
        {
            foreach (string childName in Directory.GetFileSystemEntries(dir))//获取子文件和子文件夹
            {
                if (File.Exists(childName)) //如果是文件
                {
                    FileInfo fi = new FileInfo(childName);
                    if (fi.IsReadOnly)
                    {
                        fi.IsReadOnly = false; //更改文件的只读属性
                    }
                    File.Delete(childName); //直接删除其中的文件   
                }
                else//不是文件就是文件夹
                    DeleteDir(childName); //递归删除子文件夹   
            }
            Directory.Delete(dir, true); //删除空文件夹 
        }
    }
    protected string GetDayDirName(string path)
    {
        int indexupload = path.IndexOf("upload", StringComparison.OrdinalIgnoreCase);
        return path.Substring(indexupload);
    }


    private void GetDirIMG(string selValue)
    {
        string Dir = Server.MapPath("..\\" + selValue);
        if (Directory.Exists(Dir))
        {
            Literal1.Text = "<tr><td  width='5%'>ID</td><td width='15%'>图片</td><td width='40%'>图片路径</td><td width='10%'>图片大小</td><td width='30%'>操作</td></tr>";
            StringBuilder sb = new StringBuilder();
            string[] Files = Directory.GetFiles(Dir);
            int j = 1;
            for (int i = 0; i < Files.Length; i++)
            {
                if (File.Exists(Files[i]))
                {
                    string ext = Path.GetExtension(Files[i]);
                    if (lstExt.Contains(ext.ToLower()))
                    {

                        if (i % 2 == 0)
                        {
                            sb.Append("<tr class='alt'>");
                        }
                        else
                        {
                            sb.Append("<tr>");
                        }
                        sb.Append("<td>" + j + "</td>");
                        sb.Append("<td><img src='" + GetSmallSrc(Files[i]) + "'/></td>");
                        sb.Append("<td>" + relupath + "</td>");
                        sb.Append("<td>" + widthAndHeight + "</td>");
                        sb.Append("<td><a href='../" + GetReplaceSrc(relupath) + "' target='_bank' >查看原图<a> | <a href='Project_ImgManager.aspx?delimg=" + relupath + "' onclick='return confirm(\"确定要永久地删除 " + Path.GetFileName(relupath) + "  吗？\");'> 删除</a></td>");
                        sb.Append("</tr>");
                        j++;
                    }
                }
            }
            Literal2.Text = sb.ToString();
        }
    }


    protected string GetReplaceSrc(string path)
    {
        return path.Replace("\\", "/");
    }


    protected string GetSmallSrc(string src)
    {
        string DirPath = Path.GetDirectoryName(src);
        string fileName = Path.GetFileName(src);
        string SmallDirPath = Path.Combine(DirPath, "small");
        if (!Directory.Exists(SmallDirPath))
        {
            Directory.CreateDirectory(SmallDirPath);
        }
        string SmallPath = Path.Combine(SmallDirPath, fileName);
        if (!File.Exists(SmallPath))
        {
            MakeThumbnail(src, SmallPath, 100, 75, "Cut");
        }
        string relu = string.Empty;
        int indexUp = SmallPath.IndexOf("upload", StringComparison.OrdinalIgnoreCase);

        relu = SmallPath.Substring(indexUp);

        //大图片路径
        indexUp = src.IndexOf("upload", StringComparison.OrdinalIgnoreCase);
        relupath = src.Substring(indexUp);
        //大图片 长 宽
        widthAndHeight = GetWidthHeight(src);

        return ("..\\" + relu).Replace("\\", "/");
    }


    protected string GetWidthHeight(string src)
    {
        FileStream file = new FileStream(src, FileMode.Open, FileAccess.Read);
        int byteLength = (int)file.Length;
        byte[] wf = new byte[byteLength];
        file.Read(wf, 0, byteLength);
        file.Close();
        file = null;
        System.Drawing.Bitmap map = new Bitmap(src);
        return map.Width + "px\t*\t" + map.Height + "px";
    }


    protected void DELImg(string src)
    {
        string dir = Path.GetDirectoryName(src);
        string fileName = Path.GetFileName(src);
        string smallPath = Path.Combine(Path.Combine(dir, "small"), fileName);
        try
        {
            if (File.Exists(smallPath))
            {
                File.Delete(smallPath);
            }
            File.Delete(src);

            SetSuccess("删除成功！");
        }
        catch
        {
            SetError("删除失败！");
        }
    }


    #region 按比例生成缩略图
    /// <summary>
    /// 生成缩略图
    /// </summary>
    /// <param name="originalImagePath">源图路径（物理路径）</param>
    /// <param name="thumbnailPath">缩略图路径（物理路径）</param>
    /// <param name="width">缩略图宽度</param>
    /// <param name="height">缩略图高度</param>
    /// <param name="mode">生成缩略图的方式</param>    
    public void MakeThumbnail(string originalImagePath, string thumbnailPath, int width, int height, string mode)
    {
        System.Drawing.Image originalImage = System.Drawing.Image.FromFile(originalImagePath);
        int towidth = width;
        int toheight = height;
        int x = 0;
        int y = 0;
        int ow = originalImage.Width;
        int oh = originalImage.Height;

        switch (mode)
        {
            case "HW"://指定高宽缩放（可能变形）                
                break;
            case "W"://指定宽，高按比例                    
                toheight = originalImage.Height * width / originalImage.Width;
                break;
            case "H"://指定高，宽按比例
                towidth = originalImage.Width * height / originalImage.Height;
                break;
            case "Cut"://指定高宽裁减（不变形）                
                if ((double)originalImage.Width / (double)originalImage.Height > (double)towidth / (double)toheight)
                {
                    oh = originalImage.Height;
                    ow = originalImage.Height * towidth / toheight;
                    y = 0;
                    x = (originalImage.Width - ow) / 2;
                }
                else
                {
                    ow = originalImage.Width;
                    oh = originalImage.Width * height / towidth;
                    x = 0;
                    y = (originalImage.Height - oh) / 2;
                }
                break;
            default:
                break;
        }

        //新建一个bmp图片
        System.Drawing.Image bitmap = new System.Drawing.Bitmap(towidth, toheight);

        //新建一个画板

        Graphics g = System.Drawing.Graphics.FromImage(bitmap);

        //设置高质量插值法
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.High;

        //设置高质量,低速度呈现平滑程度
        g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;

        //清空画布并以透明背景色填充

        g.Clear(Color.Transparent);

        //在指定位置并且按指定大小绘制原图片的指定部分
        g.DrawImage(originalImage, new Rectangle(0, 0, towidth, toheight),
            new Rectangle(x, y, ow, oh),
            GraphicsUnit.Pixel);

        try
        {
            //以jpg格式保存缩略图

            bitmap.Save(thumbnailPath, System.Drawing.Imaging.ImageFormat.Jpeg);
        }
        catch (System.Exception e)
        {
            ///缩略图生成失败！
        }
        finally
        {
            originalImage.Dispose();
            bitmap.Dispose();
            g.Dispose();
        }
    }

    #endregion
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <script type="text/javascript">
        window.onload = function () {
            document.getElementById("del").onclick = function () {

                if (confirm("确定要永久地删除吗？")) {
                    return true;
                }
                else {
                    return false;
                }
            }

        }
    
    </script>
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
                                <div class="head" style="padding: 0 10px 30px">
                                    <h2>
                                        图片管理</h2>
                                    <div class="search">
                                        <ul class="filter" style="margin-top: 0px; left: 20px;">
                                            <li style="left: 0px;">图片目录:
                                                <asp:DropDownList class="h-input" ID="DropDir" runat="server">
                                                </asp:DropDownList>
                                                &nbsp;
                                                <input type="submit" value="查看" class="formbutton" style="padding: 1px 6px;" name="btnsee" />
                                                &nbsp;
                                                <input type="submit" value="删除目录" class="formbutton" style="padding: 1px 6px;" name="btndel"
                                                    id="del" />
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- bd end -->
            </div>
            <!-- bdw end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>