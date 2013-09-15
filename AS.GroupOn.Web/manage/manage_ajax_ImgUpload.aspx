<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    protected string imgpath = string.Empty;
    protected AdjunctFilter ajctft = new AdjunctFilter();
    protected string descInfo = string.Empty;
    protected override void OnLoad(EventArgs e)
    {
        if (Request["add"] == "addImg" && Request.Form["commit"] == "确定")
        {
            UploadImg();
            IAdjunct adj = AS.GroupOn.App.Store.CreateAdjunct();
            adj.url = imgpath;
            adj.sort = 1;
            adj.decription = Server.HtmlEncode(descInfo);
            adj.uploadTime = DateTime.Now;
            int result = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                result = session.Adjunct.Insert(adj);
            }            
            if (result > 0)
            {
                SetSuccess("上传成功！");
            }
            else
            {
                SetError("上传失败！");
            }
            Response.Redirect("Project_ImgList.aspx");
        }
    }
    /// <summary>
    /// 上传图片
    /// </summary>
    protected void UploadImg()
    {
        bool fileOk = false;
        string fileExt = string.Empty;
        string path = Server.MapPath("~/upload/images");
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
        if (FileUpload1.HasFile)
        {
            descInfo = DescriptInfo.Text.Replace("'", "‘").Replace(";", "；");
            if (descInfo.Length > 300)
            {
                SetError("图片描述请少于300字符！");
                Response.Redirect("Project_ImgList.aspx");
            }
            else
            {
                #region  图片类型验证
                HttpPostedFile myPostFile = Request.Files[0];
                fileExt = Path.GetExtension(myPostFile.FileName).ToLower();
                List<string> allExt = new List<string>() { ".gif", ".png", ".bmp", ".jpg" };
                if (allExt.Contains(fileExt))
                {
                    if (myPostFile.ContentLength > 2097152)
                    {
                        SetError("文件大小超过 2097152 字节！");
                        Response.Redirect("Project_ImgList.aspx");
                    }
                    else
                    {
                        fileOk = true;
                    }
                }
                else
                {
                    SetError("请上传 jpg、png、gif、bmp格式图片~！");
                    Response.Redirect("Project_ImgList.aspx");
                }
                #endregion
            }
        }
        else
        {
            SetError("请选择图片~！");
            Response.Redirect("Project_ImgList.aspx");
        }


        if (fileOk)
        {

            try
            {
                #region 图片上传
                string date = "day_" + DateTime.Now.ToString("yyMMdd");
                path = System.IO.Path.Combine(path, date);
                if (!Directory.Exists(path))
                {
                    Directory.CreateDirectory(path);
                }
                Random ran = new Random();
                string ranNum = ran.Next(1000, 9999).ToString();
                string dd = DateTime.Now.ToString("yyyyMMddhhmmfff");
                System.Drawing.Image upimg = System.Drawing.Image.FromStream(FileUpload1.PostedFile.InputStream);
                Bitmap bmp = new Bitmap(upimg);
                path = Path.Combine(path, dd + ranNum + fileExt);
                FileUpload1.SaveAs(path);
                imgpath = Path.Combine("upload/images/" + date + "/", (dd + ranNum + fileExt));

                #region 生成缩略图
                string absoluPath, absoluSmallPath, absoluDir, absoluSmallDir, fileName, relaDir, relaSmallDir;
                absoluPath = Server.MapPath(imgpath);

                if (File.Exists(absoluPath))
                {
                    fileName = Path.GetFileName(imgpath);
                    relaDir = Path.GetDirectoryName(imgpath);

                    //缩略图 的 绝对路径 
                    absoluDir = Path.GetDirectoryName(absoluPath);
                    absoluSmallDir = Path.Combine(absoluDir, "small");
                    if (!Directory.Exists(absoluSmallDir))
                    {
                        Directory.CreateDirectory(absoluSmallDir);
                    }
                    absoluSmallPath = Path.Combine(absoluSmallDir, fileName);

                    if (!File.Exists(absoluSmallPath))
                    {
                        MakeThumbnail(absoluPath, absoluSmallPath, 100, 75, "Cut");
                    }
                }
                #endregion


                #endregion
            }
            catch
            {
                SetError("上传图片失败!");
                Response.Redirect("Project_ImgList.aspx");
            }
        }
        else
        {
            SetError("图片不合法");
            Response.Redirect("Project_ImgList.aspx");
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
        g.DrawImage(originalImage, new System.Drawing.Rectangle(0, 0, towidth, toheight),
            new System.Drawing.Rectangle(x, y, ow, oh),
            System.Drawing.GraphicsUnit.Pixel);

        try
        {
            //以jpg格式保存缩略图

            bitmap.Save(thumbnailPath, System.Drawing.Imaging.ImageFormat.Jpeg);
        }
        catch
        {
            /// 缩略图生成失败！
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

<form id="Form1" runat="server" enctype="multipart/form-data">
   <div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">
	<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span><span
            id="bian" style="float: left; text-indent: 5px;" runat="server">图片上传</span></h3> 
	<div style="overflow-x:hidden;padding:10px;">
        <script type="text/javascript">
            $(function () {
                $("#commit").click(function () {
                    var filepath = $("#<%=FileUpload1.ClientID %>").val();
                    if (filepath.length <= 0) {
                        alert("请选择图片!");
                        return false;
                    }
                    else {
                        var desc = $("#<%=DescriptInfo.ClientID %>").val();
                        if (desc.length > 300) {
                            alert("图片描述请少于300字符！");
                            return false;
                        }
                        else {
                            var regex = /[^\\\/]*[\\\/]+/g;
                            //文件名
                            var filename = filepath.replace(regex, '');
                            var extindex = filename.lastIndexOf(".");
                            var ext = filename.substr(extindex);
                            var lowercase = ext.toLocaleLowerCase();
                            if (lowercase == ".jpg" || lowercase == ".png" || lowercase == ".bmp" || lowercase == ".gif") {
                                return true;
                            }
                            else {
                                alert("只能上传jpg、bmp、gif、png 等格式的图片!");
                                return false;
                            }
                        }
                    }
                });
            });
        </script>
	<table width="60%" style="table-layout:auto;"class="coupons-table-xq">
		<tr>
            <td nowrap><b>图片路径：</b></td><td>
            <div id="Div2" runat="server">
            <asp:FileUpload id="FileUpload1" runat="server" height="29px" width="200px" /></div>
            </td>
        </tr>
		<tr><td nowrap>&nbsp;</td><td>&nbsp;</td></tr>
	
        <tr><td nowrap><strong>图片描述：</strong></td><td rowspan="6">
            <asp:TextBox ID="DescriptInfo" runat="server" Height="102px"  TextMode="MultiLine" Width="265px"  ></asp:TextBox>
        </td></tr>
		<tr><td nowrap>&nbsp;</td></tr>
        <tr><td nowrap>&nbsp;</td></tr>
         <tr><td nowrap>&nbsp;</td></tr>
		<tr><td nowrap>&nbsp;</td></tr>
		<tr><td nowrap>&nbsp;</td></tr>
		<tr><td></td><td><br /><input type="submit" class="formbutton validator" name="commit" id="commit" group="g" class="validator"  value="确定"   /></td></tr>
	</table>
	</div>
</div>
</form>