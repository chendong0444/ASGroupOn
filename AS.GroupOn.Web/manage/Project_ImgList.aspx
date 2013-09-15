<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected AdjunctFilter ajcft = new AdjunctFilter();
    protected StringBuilder sb1 = new StringBuilder();
    protected IList<IAdjunct> list = null;
    protected IPagers<IAdjunct> pager = null;
    protected IList<IAdjunct> iListajct = null;
    protected string pagerHtml = String.Empty;
    protected AdjunctFilter Adjunctft = new AdjunctFilter();
    IAdjunct adj = null;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Image_List))
        {
            SetError("你不具有查看图片列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }

        if (!string.IsNullOrEmpty(Request["delimg"]))
        {
            int imgId = AS.Common.Utils.Helper.GetInt(Request["delimg"], 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                adj = session.Adjunct.GetByID(imgId);
            }
            if (adj != null)
            {
                DelImg(adj.url);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int id2 = session.Adjunct.Delete(imgId);
                }
                SetSuccess("图片删除成功!");
            }
        }
        GetPageData();

    }
    protected int pages
    {
        get
        {
            if (this.ViewState["pages"] != null)
                return Convert.ToInt32(this.ViewState["pages"].ToString());
            else
                return 1;
        }
        set { this.ViewState["pages"] = value; }
    }


    private void GetPageData()
    {
        int count;
        url = url + "&page={0}";
        url = "Project_ImgList.aspx?" + url.Substring(1);
        ajcft.PageSize = 30;
        ajcft.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        ajcft.AddSortOrder(AdjunctFilter.uploadTime_DESC);
        ajcft.AddSortOrder(AdjunctFilter.ID_DESC);
        ajcft.reId = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {

            pager = session.Adjunct.GetPager(ajcft);
        }
        list = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        count = list.Count;
        int i = 0;
        foreach (IAdjunct item in list)
        {
            if (i % 2 != 0)
            {
                sb1.Append("<tr>");
            }
            else
            {
                sb1.Append("<tr class='alt'>");
            }
            i++;
            string str = "../"+ GetImgUrl(item.url);
            sb1.Append("<td>" + item.id + "</td>");
            sb1.Append("<td style='word-wrap: break-word;overflow: hidden; width: 250px;'><img src='" +str + "' /></td>");
            sb1.Append("<td style='word-wrap: break-word;overflow: hidden; width: 200px;'>" + item.url + "</td>");
            sb1.Append("<td >" + item.decription + "</td>");
            sb1.Append("<td>" + item.uploadTime.ToString("yyyy-MM-dd HH:mm:ss") + "</td>");
            sb1.Append("<td><a href='project_ImgList.aspx?delimg=" + item.id + "' onclick=\"return confirm('确定要永久地删除吗?');\" >删除</a></td>");
        }
        Literal2.Text = sb1.ToString();
    }

    protected void DelImg(string path)
    {
        string s = Server.MapPath(path);
        path = Server.MapPath("/") + s.Substring(s.Length-48); ;
        if (File.Exists(path))
        {
            File.Delete(path);
        }
        string smalldir = Path.GetDirectoryName(path);
        string filename = System.IO.Path.GetFileName(path);
        string smallpath = System.IO.Path.Combine(System.IO.Path.Combine(smalldir, "small"), filename);
        if (System.IO.File.Exists(smallpath))
        {
            System.IO.File.Delete(smallpath);
        }
    }

    /// <summary>
    /// 以相对路径 绘制 缩略图
    /// </summary>
    /// <param name="url"></param>
    /// <returns></returns>
    protected string GetImgUrl(string url)
    {
        string absoluPath, absoluSmallPath, absoluDir, absoluSmallDir, fileName, relaDir, relaSmallDir;
        absoluPath = Server.MapPath("~/"+url);

        if (System.IO.File.Exists(absoluPath))
        {
            fileName = System.IO.Path.GetFileName(url);
            relaDir = System.IO.Path.GetDirectoryName(url);

            //缩略图 的 绝对路径 
            absoluDir = System.IO.Path.GetDirectoryName(absoluPath);
            absoluSmallDir = System.IO.Path.Combine(absoluDir, "small");
            if (!System.IO.Directory.Exists(absoluSmallDir))
            {
                System.IO.Directory.CreateDirectory(absoluSmallDir);
            }
            absoluSmallPath = System.IO.Path.Combine(absoluSmallDir, fileName);

            if (!System.IO.File.Exists(absoluSmallPath))
            {
                MakeThumbnail(absoluPath, absoluSmallPath, 100, 75, "Cut");
            }

            relaSmallDir = System.IO.Path.Combine(relaDir, "small");
            return System.IO.Path.Combine(relaSmallDir, fileName).Replace("\\", "/");
        }
        else
        {
            return "#";
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

        System.Drawing.Graphics g = System.Drawing.Graphics.FromImage(bitmap);

        //设置高质量插值法
        g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.High;

        //设置高质量,低速度呈现平滑程度
        g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;

        //清空画布并以透明背景色填充

        g.Clear(System.Drawing.Color.Transparent);

        //在指定位置并且按指定大小绘制原图片的指定部分
        g.DrawImage(originalImage, new System.Drawing.Rectangle(0, 0, towidth, toheight),
            new System.Drawing.Rectangle(x, y, ow, oh),
            System.Drawing.GraphicsUnit.Pixel);

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
                                <div class="head" style="height:35px;">
                                    <h2>
                                        图片列表</h2>
                                    <ul class="filter">
                                        <li>
                                            <a class="ajaxlink" href="ajax_manage.aspx?action=addImg">上传图片</a> </li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table"
                                        style="table-layout: fixed;">
                                        <tr>
                                            <th width='10%'>
                                                ID
                                            </th>
                                            <th width='15%'>
                                                图片
                                            </th>
                                            <th width='25%'>
                                                图片路径
                                            </th>
                                            <th width='25%' >
                                                图片描述
                                            </th>                                            
                                            <th width='15%'>
                                                上传时间
                                            </th>
                                            <th width='10%'>
                                                操作
                                            </th>
                                        </tr>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="6">
                                                <%=pagerHtml %>
                                            </td>
                                        </tr>
                                    </table>
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
