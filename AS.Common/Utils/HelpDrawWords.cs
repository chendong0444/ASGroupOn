using System;
using System.Collections.Generic;
using System.Text;

using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;

namespace AS.Common.Utils
{
    /// < summary>  
    /// 图像操作类(主要用于给图片加上透明文字水印)  
    /// < /summary>  
    public class HelpDrawWords
    {

        /**/
        /// < summary>  
        /// 水印位置  
        /// < /summary>  
        public enum ImagePosition
        {
            /**/
            /// < summary>  
            /// 左上  
            /// < /summary>  
            LeftTop,
            /**/
            /// < summary>  
            /// 左下  
            /// < /summary>  
            LeftBottom,
            /**/
            /// < summary>  
            /// 右上  
            /// < /summary>  
            RightTop,
            /**/
            /// < summary>  
            /// 右下  
            /// < /summary>  
            RigthBottom,
            /**/
            /// < summary>  
            /// 顶部居中  
            /// < /summary>  
            TopMiddle,
            /**/
            /// < summary>  
            /// 底部居中  
            /// < /summary>  
            BottomMiddle,
            /**/
            /// < summary>  
            /// 中心  
            /// < /summary>  
            Center
        }



        private string _ErrMsg;
        #region 出错信息
        /**/
        /// < summary>  
        /// 出错信息  
        /// < /summary>  
        public string ErrMsg
        {
            get { return _ErrMsg; }
            set { _ErrMsg = value; }
        }
        #endregion


        #region 将文件转换成流
        //public byte[] SetImageToByteArray(string fileName, ref string fileSize)  
        /**/
        /// < summary>  
        /// 将文件转换成流  
        /// < /summary>  
        /// < param name="fileName">文件全路径< /param>  
        /// < returns>< /returns>  
        private byte[] SetImageToByteArray(string fileName)
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
        #endregion

        #region 将byte转换成MemoryStream类型
        /**/
        /// < summary>  
        /// ASP.NET图片加水印：将byte转换成MemoryStream类型  
        /// < /summary>  
        /// < param name="mybyte">byte[]变量< /param>  
        /// < returns>< /returns>  
        private MemoryStream ByteToStream(byte[] mybyte)
        {
            MemoryStream mymemorystream = new MemoryStream(mybyte, 0, mybyte.Length);
            return mymemorystream;
        }
        #endregion

        #region 将byte转换成Image文件
        /**/
        /// < summary>  
        /// ASP.NET图片加水印：将byte转换成Image文件  
        /// < /summary>  
        /// < param name="mybyte">byte[]变量< /param>  
        /// < returns>< /returns>  
        private System.Drawing.Image SetByteToImage(byte[] mybyte)
        {
            System.Drawing.Image image;
            MemoryStream mymemorystream = new MemoryStream(mybyte, 0, mybyte.Length);
            image = System.Drawing.Image.FromStream(mymemorystream);
            return image;
        }
        #endregion


        #region 批量在图片上添加透明水印文字
        /**/
        /// < summary>  
        /// ASP.NET图片加水印：批量在图片上添加透明水印文字  
        /// < /summary>  
        /// < param name="arrsourcePicture">原来图片地址(路径+文件名)< /param>  
        /// < param name="waterWords">需要添加到图片上的文字< /param>  
        /// < param name="alpha">透明度(0.1~1.0之间)< /param>  
        /// < param name="position">文字显示的位置< /param>  
        /// < param name="fRewrite">是否覆盖原图片(如果不覆盖，那么将在同目录下生成一个文件名带0607的文件)< /param>  
        /// < returns>< /returns>  
        public bool DrawWords(string[] arrsourcePicture, string waterWords, string strFontName, float alpha, ImagePosition position, bool fRewrite, int fontsize)
        {
            foreach (string imgPath in arrsourcePicture)
            {
                if (!DrawWords(imgPath, waterWords, strFontName, alpha, position, fRewrite, fontsize))
                {
                    _ErrMsg += "——处理文件：" + imgPath + " 时出错。";
                    return false;
                }
            }
            return true;
        }
        #endregion

        #region 在图片上添加透明水印文字


        /// <summary>
        /// ASP.NET图片加水印：在图片上添加透明水印文字
        /// </summary>
        /// <param name="sourcePicture">原来图片地址(路径+文件名)</param>
        /// <param name="waterWords">需要添加到图片上的文字</param>
        /// <param name="strFontName">需要添加到图片上的文字字体</param>
        /// <param name="alpha">透明度(0.1~1.0之间)</param>
        /// <param name="position">文字显示的位置</param>
        /// <param name="fRewrite">是否覆盖原图片(如果不覆盖，那么将在同目录下生成一个文件名带0607的文件)</param>
        /// <returns></returns>
        public bool DrawWords(string sourcePicture, string waterWords, string strFontName, float alpha, ImagePosition position, bool fRewrite, int fontsize)
        {
            if (!System.IO.File.Exists(sourcePicture))
            {
                _ErrMsg = "文件不存在！";
                return false;
            }
            string fileExtension = System.IO.Path.GetExtension(sourcePicture).ToLower();
            if (fileExtension != ".gif" && fileExtension != ".jpg" && fileExtension != ".jpeg" && fileExtension != ".png" && fileExtension != ".bmp")
            {
                _ErrMsg = "不是图片文件！";
                return false;
            }

            Image imgPhoto = null;
            Bitmap bmPhoto = null;
            Graphics grPhoto = null;
            try
            {
                //创建一个图片对象用来装载要被添加水印的图片  
                imgPhoto = Image.FromStream(ByteToStream(SetImageToByteArray(sourcePicture)));

                //获取图片的宽和高  
                int phWidth = imgPhoto.Width;
                int phHeight = imgPhoto.Height;

                //建立一个bitmap，和我们需要加水印的图片一样大小  
                bmPhoto = new Bitmap(phWidth, phHeight, PixelFormat.Format24bppRgb);

                //SetResolution：设置此 Bitmap 的分辨率  
                //这里直接将我们需要添加水印的图片的分辨率赋给了bitmap  
                bmPhoto.SetResolution(imgPhoto.HorizontalResolution, imgPhoto.VerticalResolution);

                //Graphics：封装一个 GDI+ 绘图图面。  
                grPhoto = Graphics.FromImage(bmPhoto);

                //设置图形的品质  
                grPhoto.SmoothingMode = SmoothingMode.HighQuality;

                //将我们要添加水印的图片按照原始大小描绘（复制）到图形中  
                grPhoto.DrawImage(
                 imgPhoto,                                           //   要添加水印的图片  
                 new Rectangle(0, 0, phWidth, phHeight), //  根据要添加的水印图片的宽和高  
                 0,                                                     //  X方向从0点开始描绘  
                 0,                                                     // Y方向   
                 phWidth,                                            //  X方向描绘长度  
                 phHeight,                                           //  Y方向描绘长度  
                 GraphicsUnit.Pixel);                              // 描绘的单位，这里用的是像素  

                //根据图片的大小我们来确定添加上去的文字的大小  
                //在这里我们定义一个数组来确定  
                int[] sizes = new int[] { 48, 36, 28, 24, 16, 14, 12, 10 };

                //字体  
                Font crFont = null;
                //int fontSize = 12;
                //Font crFont = new Font("隶书", fontSize);


                //矩形的宽度和高度，SizeF有三个属性，分别为Height高，width宽，IsEmpty是否为空  
                SizeF crSize = new SizeF();

                //利用一个循环语句来选择我们要添加文字的型号  
                //直到它的长度比图片的宽度小  
                //for (int i = 0; i < sizes.Length; i++)
                //{
                //    crFont = new Font(strFontName, sizes[i], FontStyle.Bold);

                //    //测量用指定的 Font 对象绘制并用指定的 StringFormat 对象格式化的指定字符串。  
                //    crSize = grPhoto.MeasureString(waterWords, crFont);

                //    // ushort 关键字表示一种整数数据类型  
                //    if ((ushort)crSize.Width < (ushort)phWidth)
                //        break;
                //}
                crFont = new Font(strFontName, fontsize, FontStyle.Regular);
                //测量用指定的 Font 对象绘制并用指定的 StringFormat 对象格式化的指定字符串。  
                crSize = grPhoto.MeasureString(waterWords, crFont);


                //截边5%的距离，定义文字显示(由于不同的图片显示的高和宽不同，所以按百分比截取)  
                int yPixlesFromBottom = (int)(phHeight * .05);

                //定义在图片上文字的位置  
                float wmHeight = crSize.Height;
                float wmWidth = crSize.Width;

                float xPosOfWm;
                float yPosOfWm;

                //设置水印的位置  
                switch (position)
                {
                    case ImagePosition.BottomMiddle:
                        xPosOfWm = phWidth / 2;
                        yPosOfWm = phHeight - wmHeight - 10;
                        break;
                    case ImagePosition.Center:
                        xPosOfWm = phWidth / 2;
                        yPosOfWm = phHeight / 2;
                        break;
                    case ImagePosition.LeftBottom:
                        xPosOfWm = wmWidth;
                        yPosOfWm = phHeight - wmHeight - 10;
                        break;
                    case ImagePosition.LeftTop:
                        xPosOfWm = wmWidth / 2;
                        yPosOfWm = wmHeight / 2;
                        break;
                    case ImagePosition.RightTop:
                        xPosOfWm = phWidth - wmWidth - 10;
                        yPosOfWm = wmHeight;
                        break;
                    case ImagePosition.RigthBottom:
                        xPosOfWm = phWidth - wmWidth - 10;
                        yPosOfWm = phHeight - wmHeight - 10;
                        break;
                    case ImagePosition.TopMiddle:
                        xPosOfWm = phWidth / 2;
                        yPosOfWm = wmWidth;
                        break;
                    default:
                        xPosOfWm = wmWidth;
                        yPosOfWm = phHeight - wmHeight - 10;
                        break;
                }
                //封装文本布局信息（如对齐、文字方向和 Tab 停靠位），显示操作（如省略号插入和国家标准 (National) 数字替换）和 OpenType 功能。  
                StringFormat StrFormat = new StringFormat();

                //定义需要印的文字居中对齐  
                StrFormat.Alignment = StringAlignment.Center;

                //SolidBrush:定义单色画笔。画笔用于填充图形形状，如矩形、椭圆、扇形、多边形和封闭路径。  
                //这个画笔为描绘阴影的画笔，呈灰色  
                int m_alpha = Convert.ToInt32(256 * alpha);
                SolidBrush semiTransBrush2 = new SolidBrush(Color.FromArgb(m_alpha, 0, 0, 0));


                //描绘文字信息，这个图层向右和向下偏移一个像素，表示阴影效果  
                //DrawString 在指定矩形并且用指定的 Brush 和 Font 对象绘制指定的文本字符串。  
                grPhoto.DrawString(waterWords,                                    //string of text  
                                           crFont,                                        //font  
                                           semiTransBrush2,                            //Brush  
                                           new PointF(xPosOfWm + 1, yPosOfWm + 1),  //Position  
                                           StrFormat);

                //从四个 ARGB 分量（alpha、红色、绿色和蓝色）值创建 Color 结构，这里设置透明度为153  
                //这个画笔为描绘正式文字的笔刷，呈白色  
                SolidBrush semiTransBrush = new SolidBrush(Color.FromArgb(153, 255, 255, 255));



                //第二次绘制这个图形，建立在第一次描绘的基础上  
                grPhoto.DrawString(waterWords,                 //string of text  
                                           crFont,                                   //font  
                                           semiTransBrush,                           //Brush  
                                           new PointF(xPosOfWm, yPosOfWm),  //Position  
                                           StrFormat);

                //imgPhoto是我们建立的用来装载最终图形的Image对象  
                //bmPhoto是我们用来制作图形的容器，为Bitmap对象  
                imgPhoto = bmPhoto;
                //释放资源，将定义的Graphics实例grPhoto释放，grPhoto功德圆满  
                //grPhoto.Dispose();  

                //将grPhoto保存  
                if (fRewrite)
                {
                    imgPhoto.Save(sourcePicture);
                }
                else
                {
                    // 目标图片名称及全路径  
                    string targetImage = sourcePicture.Replace(System.IO.Path.GetExtension(sourcePicture), "") + "_0607" + fileExtension;
                    imgPhoto.Save(targetImage);
                }
                //imgPhoto.Dispose();  
                return true;
            }
            catch (Exception ex)
            {
                _ErrMsg = ex.Message;
                return false;
            }
            finally
            {
                if (imgPhoto != null)
                    imgPhoto.Dispose();
                if (bmPhoto != null)
                    bmPhoto.Dispose();
                if (grPhoto != null)
                    grPhoto.Dispose();
            }


        }
        #endregion






        /// <summary>
        /// 加图片水印
        /// </summary>
        /// <param name="filename">文件名</param>
        /// <param name="watermarkFilename">水印文件名</param>
        /// <param name="watermarkStatus">图片水印位置</param>
        public void AddImageSignPic(string Path, string Path_syp, string Path_sypf, ImagePosition watermarkStatus, float alpha)
        {
            System.Drawing.Image img = System.Drawing.Image.FromFile(Path);
            Graphics g = Graphics.FromImage(img);
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
            g.CompositingQuality = CompositingQuality.HighQuality;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            Image watermark = new Bitmap(Path_sypf);
            if (watermark.Height >= img.Height || watermark.Width >= img.Width)
                return;
            ImageAttributes imageAttributes = new ImageAttributes();
            ColorMap colorMap = new ColorMap();
            colorMap.OldColor = Color.FromArgb(255, 0, 255, 0);
            colorMap.NewColor = Color.FromArgb(0, 0, 0, 0);
            ColorMap[] remapTable = { colorMap };
            imageAttributes.SetRemapTable(remapTable, ColorAdjustType.Bitmap);
            float transparency = alpha;
            float[][] colorMatrixElements = {
												new float[] {1.0f,  0.0f,  0.0f,  0.0f, 0.0f},
												new float[] {0.0f,  1.0f,  0.0f,  0.0f, 0.0f},
												new float[] {0.0f,  0.0f,  1.0f,  0.0f, 0.0f},
												new float[] {0.0f,  0.0f,  0.0f,  transparency, 0.0f},
												new float[] {0.0f,  0.0f,  0.0f,  0.0f, 1.0f}
											};
            ColorMatrix colorMatrix = new ColorMatrix(colorMatrixElements);
            imageAttributes.SetColorMatrix(colorMatrix, ColorMatrixFlag.Default, ColorAdjustType.Bitmap);
            int xpos = 0;
            int ypos = 0;
            switch (watermarkStatus)
            {
                case ImagePosition.LeftTop:
                    xpos = (int)(img.Width * (float).01);
                    ypos = (int)(img.Height * (float).01);
                    break;
                case ImagePosition.TopMiddle:
                    xpos = (int)((img.Width * (float).50) - (watermark.Width / 2));
                    ypos = (int)(img.Height * (float).01);
                    break;
                case ImagePosition.RightTop:
                    xpos = (int)((img.Width * (float).99) - (watermark.Width));
                    ypos = (int)(img.Height * (float).01);
                    break;

                case ImagePosition.Center:
                    xpos = (int)((img.Width * (float).50) - (watermark.Width / 2));
                    ypos = (int)((img.Height * (float).50) - (watermark.Height / 2));
                    break;

                case ImagePosition.LeftBottom:
                    xpos = (int)(img.Width * (float).01);
                    ypos = (int)((img.Height * (float).99) - watermark.Height);
                    break;
                case ImagePosition.BottomMiddle:
                    xpos = (int)((img.Width * (float).50) - (watermark.Width / 2));
                    ypos = (int)((img.Height * (float).99) - watermark.Height);
                    break;
                case ImagePosition.RigthBottom:
                    xpos = (int)((img.Width * (float).99) - (watermark.Width));
                    ypos = (int)((img.Height * (float).99) - watermark.Height);
                    break;
            }
            g.DrawImage(watermark, new Rectangle(xpos, ypos, watermark.Width, watermark.Height), 0, 0, watermark.Width, watermark.Height, GraphicsUnit.Pixel, imageAttributes);
            //g.DrawImage(watermark, new Rectangle(xpos, ypos, watermark.Width, watermark.Height), 0, 0, watermark.Width, watermark.Height, GraphicsUnit.Pixel, imageAttributes);
            //g.DrawString("fffffffffffffff",new Font("宋体",0.5f),Brushes.Red,new PointF(0,0));
            g.Dispose();
            Bitmap bitMap = new Bitmap(img);
            //BitmapData b=bitMap.LockBits(new Rectangle(0,0,bitMap.Width,bitMap.Height),ImageLockMode.ReadWrite,PixelFormat.Format24bppRgb);

            // bitMap.Save(Path_syp,ImageCodecInfo.GetImageEncoders()[0],new EncoderParameter(
            ImageCodecInfo imageCode = null;
            ImageCodecInfo[] imageCodes = ImageCodecInfo.GetImageEncoders();
            for (int i = 0; i < imageCodes.Length; i++)
                if (imageCodes[i].MimeType == "image/jpeg")
                {
                    imageCode = imageCodes[i];
                    break;
                }
            EncoderParameters encoderParameters = new EncoderParameters(1);
            EncoderParameter encoderParameter = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 200L);
            encoderParameters.Param[0] = encoderParameter;
            bitMap.Save(Path_syp, imageCode, encoderParameters);
            bitMap.Dispose();
            img.Dispose();
            FileInfo fileSource = new FileInfo(Path); //原图片文件
            fileSource.Delete();//删除原图片文件 //得到图片的路径并保存

        }

    }
}
