using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Web;
using System.Collections.Specialized;

using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;

namespace AS.Common.Utils
{
    public class ImageHelper
    {
        /**/
        /// < summary>  
        /// ASP.NET图片加水印：将byte转换成MemoryStream类型  
        /// < /summary>  
        /// < param name="mybyte">byte[]变量< /param>  
        /// < returns>< /returns>  
        private static MemoryStream ByteToStream(byte[] mybyte)
        {
            MemoryStream mymemorystream = new MemoryStream(mybyte, 0, mybyte.Length);
            return mymemorystream;
        }


        /// < summary>  
        /// 将文件转换成流  
        /// < /summary>  
        /// < param name="fileName">文件全路径< /param>  
        /// < returns>< /returns>  
        private static byte[] SetImageToByteArray(string fileName)
        {
            byte[] image = null;
            try
            {
                FileStream fs = new FileStream(fileName, FileMode.Open);
                FileInfo fileInfo = new FileInfo(fileName);
                //fileSize = Convert.ToDecimal(fileInfo.Length / 1024).ToString("f2") + " K";  
                int streamLength = (int)fs.Length;
                image = new byte[streamLength];
                fs.Read(image, 0, streamLength);
                fs.Close();
                return image;
            }
            catch
            {
                return image;
            }
        }

        /// <summary>
        /// 为项目图片加水印
        /// </summary>
        /// <param name="path">相对路径 如/upfile/xxx</param>
        /// <param name="drawuse"></param>
        /// <param name="drawimgType"></param>
        /// <param name="_system">配置文件</param>
        public static void DrawImgWord(string fullpathfile, ref string drawuse, ref string drawimgType, NameValueCollection _system)
        {
            fullpathfile = HttpContext.Current.Server.MapPath(fullpathfile);
            string filename = Path.GetFileName(fullpathfile);
            string path = Path.GetDirectoryName(fullpathfile);
            string word = "";
            string drawfont = "";
            string drawalpha = "";
            string drawposition = "";
            string drawsize = "";

            drawimgType = "";
            string drawimgurl = "";
            if (_system != null)
            {
                word = _system["drawimg"];
                drawfont = _system["drawfont"];
                drawalpha = _system["drawalpha"];
                drawposition = _system["drawposition"];
                drawsize = _system["drawsize"];
                drawuse = _system["usedrawimg"];
                drawimgType = _system["drawimgType"];
                drawimgurl = _system["drawimgurl"];
            }
            HelpDrawWords.ImagePosition position = new Utils.HelpDrawWords.ImagePosition();

            switch (drawposition)
            {
                case "BottomMiddle":
                    position = Utils.HelpDrawWords.ImagePosition.BottomMiddle;
                    break;
                case "Center":
                    position = Utils.HelpDrawWords.ImagePosition.Center;
                    break;
                case "LeftBottom":
                    position = Utils.HelpDrawWords.ImagePosition.LeftBottom;
                    break;
                case "LeftTop":
                    position = Utils.HelpDrawWords.ImagePosition.LeftTop;
                    break;
                case "RightTop":
                    position = Utils.HelpDrawWords.ImagePosition.RightTop;
                    break;
                case "RigthBottom":
                    position = Utils.HelpDrawWords.ImagePosition.RigthBottom;
                    break;
                case "TopMiddle":
                    position = Utils.HelpDrawWords.ImagePosition.TopMiddle;
                    break;
                default:
                    position = Utils.HelpDrawWords.ImagePosition.Center;
                    break;
            }

            Utils.HelpDrawWords helpdraw = new Utils.HelpDrawWords();
            if (drawuse == "1")
            {
                if (drawimgType == "0" && !String.IsNullOrEmpty(drawimgurl))
                {
                    //图片水印
                    try
                    {
                        helpdraw.AddImageSignPic(fullpathfile, path + "\\syp_" + filename, HttpContext.Current.Server.MapPath(drawimgurl), position, Utils.Helper.GetFloat(drawalpha, 0.5f));
                        File.Delete(fullpathfile);
                        File.Move(path + "\\syp_" + filename, fullpathfile);
                    }
                    catch { }
                }

                if (drawimgType == "1" && !String.IsNullOrEmpty(word))
                {
                    //文字水印
                    helpdraw.DrawWords(fullpathfile, word, Utils.Helper.GetString(drawfont, "Arial"), Utils.Helper.GetFloat(drawalpha, 0.5f), position, true, Utils.Helper.GetInt(drawsize, 38));
                }
            }
        }


        /// <summary>
        /// 为商城图片加水印
        /// </summary>
        /// <param name="path">相对路径 如/upfile/xxx</param>
        /// <param name="drawuse"></param>
        /// <param name="drawimgType"></param>
        /// <param name="_system">配置文件</param>
        public static void Mall_DrawImgWord(string fullpathfile, ref string drawuse, ref string drawimgType, NameValueCollection _system)
        {
            fullpathfile = HttpContext.Current.Server.MapPath(fullpathfile);
            string filename = Path.GetFileName(fullpathfile);
            string path = Path.GetDirectoryName(fullpathfile);
            string word = "";
            string drawfont = "";
            string drawalpha = "";
            string drawposition = "";
            string drawsize = "";

            drawimgType = "";
            string drawimgurl = "";
            if (_system != null)
            {
                word = _system["malldrawimg"];
                drawfont = _system["malldrawfont"];
                drawalpha = _system["malldrawalpha"];
                drawposition = _system["malldrawposition"];
                drawsize = _system["malldrawsize"];
                drawuse = _system["mallusedrawimg"];
                drawimgType = _system["malldrawimgType"];
                drawimgurl = _system["malldrawimgurl"];
            }
            Utils.HelpDrawWords.ImagePosition position = new Utils.HelpDrawWords.ImagePosition();


            switch (drawposition)
            {
                case "BottomMiddle":
                    position = Utils.HelpDrawWords.ImagePosition.BottomMiddle;
                    break;
                case "Center":
                    position = Utils.HelpDrawWords.ImagePosition.Center;
                    break;
                case "LeftBottom":
                    position = Utils.HelpDrawWords.ImagePosition.LeftBottom;
                    break;
                case "LeftTop":
                    position = Utils.HelpDrawWords.ImagePosition.LeftTop;
                    break;
                case "RightTop":
                    position = Utils.HelpDrawWords.ImagePosition.RightTop;
                    break;
                case "RigthBottom":
                    position = Utils.HelpDrawWords.ImagePosition.RigthBottom;
                    break;
                case "TopMiddle":
                    position = Utils.HelpDrawWords.ImagePosition.TopMiddle;
                    break;
                default:
                    position = Utils.HelpDrawWords.ImagePosition.Center;
                    break;
            }

            Utils.HelpDrawWords helpdraw = new Utils.HelpDrawWords();
            if (drawuse == "1")
            {
                if (drawimgType == "0" && !String.IsNullOrEmpty(drawimgurl))
                {
                    //图片水印
                    try
                    {
                        helpdraw.AddImageSignPic(fullpathfile, path + "\\syp_" + filename, HttpContext.Current.Server.MapPath(drawimgurl), position, Utils.Helper.GetFloat(drawalpha, 0.5f));
                        File.Delete(fullpathfile);
                        File.Move(path + "\\syp_" + filename, fullpathfile);
                    }
                    catch { }
                }

                if (drawimgType == "1" && !String.IsNullOrEmpty(word))
                {
                    //文字水印
                    helpdraw.DrawWords(fullpathfile, word, Utils.Helper.GetString(drawfont, "Arial"), Utils.Helper.GetFloat(drawalpha, 0.5f), position, true, Utils.Helper.GetInt(drawsize, 38));
                }
            }
        }



        /// <summary>
        /// 生成缩略图
        /// </summary>
        /// <param name="img_src">原图路径</param>
        /// <param name="width">缩略宽度</param>
        /// <param name="height">缩略高度</param>
        /// <param name="img_new">缩略图绝对路径</param>
        /// <param name="del">是否删除原图</param>
        /// <returns>返回缩略图绝对路径</returns>
        public static string ImageThumb(string img_src, int width, int height, string img_new, bool del)
        {


            string newfile = String.Empty;//缩略图的绝对路径
            //执行过程
            if (!System.IO.File.Exists(img_src))
            {
                return "";
            }

            Image imageFrom = null;
            try
            {

                imageFrom = Image.FromFile(img_src);
                //imageFrom = Image.FromStream(ByteToStream(SetImageToByteArray(img_src)));
            }
            catch (Exception e)
            {
                throw new Exception(e.Message.ToString());
            }
            if (imageFrom == null)
            {
                return "";
            }
            // 源图宽度及高度
            int imageFromWidth = imageFrom.Width;
            int imageFromHeight = imageFrom.Height;
            // 生成的缩略图实际宽度及高度
            int bitmapWidth = width;
            int bitmapHeight = height;
            // 生成的缩略图在上述"画布"上的位置
            int X = 0;
            int Y = 0;
            // 根据源图及欲生成的缩略图尺寸,计算缩略图的实际尺寸及其在"画布"上的位置
            if (bitmapHeight * imageFromWidth > bitmapWidth * imageFromHeight)
            {
                bitmapHeight = imageFromHeight * width / imageFromWidth;
                Y = (height - bitmapHeight) / 2;
            }
            else
            {
                bitmapWidth = imageFromWidth * height / imageFromHeight;
                X = (width - bitmapWidth) / 2;
            }
            // 创建画布
            Bitmap bmp = new Bitmap(width, height);
            Graphics g = Graphics.FromImage(bmp);
            // 用白色清空
            g.Clear(Color.White);
            // 指定高质量的双三次插值法。执行预筛选以确保高质量的收缩。此模式可产生质量最高的转换图像。
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            // 指定高质量、低速度呈现。
            g.SmoothingMode = SmoothingMode.HighQuality;
            // 在指定位置并且按指定大小绘制指定的 Image 的指定部分。
            g.DrawImage(imageFrom, new Rectangle(X, Y, bitmapWidth, bitmapHeight), new Rectangle(0, 0, imageFromWidth, imageFromHeight), GraphicsUnit.Pixel);
            try
            {

                string img_new_file = img_new.Substring(0, img_new.LastIndexOf("\\"));
                if (!Directory.Exists(img_new_file))
                {
                    Directory.CreateDirectory(img_new_file);
                }
                //经测试 .jpg 格式缩略图大小与质量等最优
                bmp.Save(img_new, ImageFormat.Jpeg);
                newfile = img_new;
                //是否删除原图
                if (del)
                {
                    File.Delete(img_src);
                }
            }
            catch (Exception e)
            {
                throw new Exception(e.Message.ToString());
            }
            finally
            {
                //显示释放资源
                imageFrom.Dispose();
                bmp.Dispose();
                g.Dispose();
            }


            return newfile;
        }

        /// <summary>  
        /// 生成没有背景的缩略图  
        /// </summary>  
        /// <param name="originalImagePath">源图路径（物理路径）</param>  
        /// <param name="thumbnailPath">缩略图路径（物理路径）</param>  
        /// <param name="width">缩略图宽度</param>  
        /// <param name="height">缩略图高度</param>  
        public static bool CreateThumbnailNobackcolor(string originalImagePath, string thumbnailPath, int width, int height)
        {
            bool ok = true;
            //获取原始图片  
            try
            {
                System.Drawing.Image originalImage = System.Drawing.Image.FromFile(originalImagePath);
                //缩略图画布宽高  
                int towidth = width;
                int toheight = height;
                //原始图片写入画布坐标和宽高(用来设置裁减溢出部分)  
                int x = 0;
                int y = 0;
                int ow = originalImage.Width;
                int oh = originalImage.Height;
                //原始图片画布,设置写入缩略图画布坐标和宽高(用来原始图片整体宽高缩放)  
                int bg_x = 0;
                int bg_y = 0;
                int bg_w = towidth;
                int bg_h = toheight;
                //倍数变量  
                double multiple = 0;
                //获取宽长的或是高长与缩略图的倍数  
                if (originalImage.Width >= originalImage.Height) multiple = (double)originalImage.Width / (double)width;
                else multiple = (double)originalImage.Height / (double)height;
                //上传的图片的宽和高小等于缩略图  
                if (ow <= width && oh <= height)
                {
                    //图片按缩略图宽高  
                    bg_w = originalImage.Width;
                    bg_h = originalImage.Height;
                    //缩略图按原始宽高.  
                    towidth = originalImage.Width;
                    toheight = originalImage.Height;
                }
                //上传的图片的宽和高大于缩略图  
                else
                {
                    //宽高按比例缩放  
                    bg_w = Convert.ToInt32((double)originalImage.Width / multiple);
                    bg_h = Convert.ToInt32((double)originalImage.Height / multiple);
                    //缩略图宽高按比例缩放.  
                    towidth = Convert.ToInt32((double)originalImage.Width / multiple);
                    toheight = Convert.ToInt32((double)originalImage.Height / multiple);
                    //设置坐标  
                    bg_x = 0;
                    bg_y = 0;
                }
                //新建一个bmp图片,并设置缩略图大小.  
                System.Drawing.Image bitmap = new System.Drawing.Bitmap(towidth, toheight);
                //新建一个画板  
                System.Drawing.Graphics g = System.Drawing.Graphics.FromImage(bitmap);
                //设置高质量插值法  
                //g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBilinear;
                //设置高质量,低速度呈现平滑程度  
                g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;

                //清空画布并设置背景色  
                g.Clear(System.Drawing.ColorTranslator.FromHtml("#F2F2F2"));
                //在指定位置并且按指定大小绘制原图片的指定部分  
                //第一个System.Drawing.Rectangle是原图片的画布坐标和宽高,第二个是原图片写在画布上的坐标和宽高,最后一个参数是指定数值单位为像素  
                g.DrawImage(originalImage, new System.Drawing.Rectangle(bg_x, bg_y, bg_w, bg_h), new System.Drawing.Rectangle(x, y, ow, oh), System.Drawing.GraphicsUnit.Pixel);
                try
                {
                    //获取图片类型  
                    string fileExtension = System.IO.Path.GetExtension(originalImagePath).ToLower();
                    //按原图片类型保存缩略图片,不按原格式图片会出现模糊,锯齿等问题.  
                    switch (fileExtension)
                    {
                        case ".gif": bitmap.Save(thumbnailPath, ImageFormat.Gif); break;
                        case ".jpg": bitmap.Save(thumbnailPath, ImageFormat.Jpeg); break;
                        case ".bmp": bitmap.Save(thumbnailPath, ImageFormat.Bmp); break;
                        case ".png": bitmap.Save(thumbnailPath, ImageFormat.Png); break;
                    }
                }
                catch (System.Exception e)
                {
                    throw e;
                }
                finally
                {
                    originalImage.Dispose();
                    bitmap.Dispose();
                    g.Dispose();
                }
            }
            catch { ok = false; }
            return ok;
        }

        public static void ImageThumb(string img_src, string img_new, int width, int height, bool del)
        {
            ImageThumb(img_src, width, height, img_new, del);
        }

        /// <summary>
        /// 根据原图得到缩略图的路径，当缩略图不存在的时候，自动生成缩略图-----团购
        /// </summary>
        /// <param name="oldurl">图片原路径</param>
        /// <returns></returns>
        public static string getSmallImgUrl(string oldurl)
        {
            string newUrl = oldurl;
            if (oldurl != null && oldurl != "")
            {
                if (oldurl.IndexOf("http://") >= 0 || oldurl.IndexOf("www.") >= 0)
                {
                    newUrl = oldurl;
                }
                else
                {
                    if (!File.Exists(HttpContext.Current.Server.MapPath(oldurl)))
                    {
                        newUrl = oldurl;
                    }
                    else
                    {
                        string imgname = oldurl.Substring(oldurl.LastIndexOf('/') + 1);
                        //判断缩略图是否存在，不存在则生成。
                        string isExistSmallUrl = newUrl.Replace(imgname, "small_" + imgname);
                        if (!File.Exists(HttpContext.Current.Server.MapPath(isExistSmallUrl)))
                        {
                            string str_oldurl = HttpContext.Current.Server.MapPath(oldurl);
                            string str_newUrl = HttpContext.Current.Server.MapPath(isExistSmallUrl);
                            if (CreateThumbnailNobackcolor(str_oldurl, str_newUrl, 235, 150))
                            {
                                newUrl = isExistSmallUrl;
                            }
                        }
                        else
                        {
                            newUrl = isExistSmallUrl;
                        }
                    }
                }

            }
            return newUrl;
        }

        /// <summary>
        /// 根据原图得到缩略图的路径，当缩略图不存在的时候，自动生成缩略图---- 商城
        /// </summary>
        /// <param name="oldurl">图片原路径</param>
        /// <returns></returns>
        public static string good_getSmallImgUrl(string oldurl, int width, int height)
        {
            string newUrl = oldurl;
            if (oldurl != null && oldurl != "")
            {
                if (oldurl.IndexOf("http://") >= 0 || oldurl.IndexOf("www.") >= 0)
                {
                    newUrl = oldurl;
                }
                else
                {
                    if (!File.Exists(HttpContext.Current.Server.MapPath(oldurl)))
                    {
                        newUrl = oldurl;
                    }
                    else
                    {
                        string imgname = oldurl.Substring(oldurl.LastIndexOf('/') + 1);
                        //判断缩略图是否存在，不存在则生成。
                        string isExistSmallUrl = newUrl.Replace(".", "_" + width + ".");
                        if (!File.Exists(HttpContext.Current.Server.MapPath(isExistSmallUrl)))
                        {
                            string str_oldurl = HttpContext.Current.Server.MapPath(oldurl);
                            string str_newUrl = HttpContext.Current.Server.MapPath(isExistSmallUrl);
                            if (ImageHelper.CreateThumbnailNobackcolor(str_oldurl, str_newUrl, width, height))
                            {
                                newUrl = isExistSmallUrl;
                            }
                        }
                        else
                        {
                            newUrl = isExistSmallUrl;
                        }
                    }
                }

            }
            return newUrl;
        }
    }
}
