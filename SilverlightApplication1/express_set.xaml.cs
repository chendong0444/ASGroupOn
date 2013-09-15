using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.Windows.Navigation;
using System.IO;
using System.Text.RegularExpressions;
using System.Windows.Media.Imaging;
using System.Windows.Browser;
namespace SilverlightApplication1
{
    public partial class express_set : Page
    {
      
        public express_set()
        {
            InitializeComponent();
        }

        private int step = 1;
        string printaction = String.Empty; //提交命令 add新建 否则为更新
        string printimageurl = String.Empty; //模板背景
        string id = String.Empty; //更新用的ID
        private FileInfo fileinfo = null;//选中的上传文件
        private string url = String.Empty;//当前url http://xxx/
        // 当用户导航到此页面时执行。
        private FontFamily font = new FontFamily("SimHei"); //打印字体
        private int order_count = 0; //订单数量
        private int current_order = 0;
        private List<object> objects = new List<object>(); //打印文本控件集合
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
           
        }

        private void regionset_Click(object sender, RoutedEventArgs e)
        {
         
            int value=0;
            bool ok = true;
            if (!int.TryParse(region_width.Text, out value)&&value<=0)
            {
                MessageBox.Show("宽度应为大于0");
                ok = false;
            }
            
            if (!int.TryParse(region_height.Text, out value)&&value<=0)
            {
                MessageBox.Show("宽度应大于0");
                ok = false;
            }
            if (!int.TryParse(textbox_fontsize.Text, out value) && value <= 0)
            {
                MessageBox.Show("字体大小应大于0");
                ok = false;
            }
            if (ok)
            {

                canvas2.Height = Convert.ToInt32(region_height.Text);
                canvas2.Width = Convert.ToInt32(region_width.Text);
                ImageBrush brush = canvas2.Background as ImageBrush;
                if (brush != null)
                {
                    brush.Stretch = Stretch.Fill;
                    canvas2.Background = null;
                    canvas2.Background = brush;
                }
                int fontsize=Convert.ToInt32(textbox_fontsize.Text);
                for (int i = 0; i < canvas2.Children.Count; i++)
                {
                    Border border = canvas2.Children[i] as Border;
                    if (border != null)
                    {
                        TextBlock block = border.Child as TextBlock;
                        if (block != null)
                        {
                            block.FontSize = fontsize;
                        }
                    }
                }
                for (int i = 0; i <canvasselect.Children.Count; i++)
                {
                    Border border = canvas2.Children[i] as Border;
                    if (border != null)
                    {
                        TextBlock block = border.Child as TextBlock;
                        if (block != null)
                        {
                            block.FontSize = fontsize;
                        }
                    }
                }
            }
            
        }

        protected string Url
        {
            get
            {
                if (url == String.Empty)
                {
                    Regex urlregex = new Regex("http://.+?/");
                    url = System.Windows.Browser.HtmlPage.Document.DocumentUri.AbsoluteUri;
                    Match urlmatch = urlregex.Match(url);
                    if (urlmatch.Success)
                    {
                        url = urlmatch.Value;
                    }
                }
                return url;
            }
        }
        private string cookiemanager = String.Empty;
        private void upfile_button_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog filedialog = new OpenFileDialog();
            filedialog.Filter = "Image Files (*.bmp, *.jpg)|*.bmp;*.jpg";
            filedialog.Multiselect = false;
            bool? ok = filedialog.ShowDialog();
            if (ok.HasValue && ok.Value)
            {
               fileinfo = filedialog.File;
               
               if (Url.Length > 0)
               {

                   HttpWebRequest request = (HttpWebRequest)WebRequest.Create(new Uri(Url +  "manage/ajax_print.aspx?action=upimage&filename=" + fileinfo.Name, UriKind.Absolute));
                   request.ContentType = "application/x-www-form-urlencoded";
                   request.Method = "POST";
                   request.BeginGetRequestStream(new AsyncCallback(requestcallback), request);
                   upfile_button.Content = "正在上传...";
                   upfile_button.IsEnabled = false;

               }
            }
        }

        private void requestcallback(IAsyncResult result)
        {
            if (fileinfo != null)
            {

                HttpWebRequest request = (HttpWebRequest)result.AsyncState;
                Stream request_stream = request.EndGetRequestStream(result);
                FileStream fs = fileinfo.OpenRead();
                byte[] filearr = new byte[fs.Length];
                fs.Read(filearr, 0, filearr.Length);
                request_stream.Write(filearr, 0, filearr.Length);
                request_stream.Close();
                request_stream.Dispose();
                request.BeginGetResponse(new AsyncCallback(sendcallback), request);
            }
        }

        private void sendcallback(IAsyncResult result)
        {
            HttpWebRequest request = (HttpWebRequest)result.AsyncState;
            HttpWebResponse response = (HttpWebResponse)request.EndGetResponse(result);
           Stream responsestream= response.GetResponseStream();
           StreamReader sreader = new StreamReader(responsestream);
          printimageurl= sreader.ReadToEnd();
           response.Close();
           sreader.Close();
           canvas2.Dispatcher.BeginInvoke(new SetBackGround(set_background), new object[] { canvas2, Url+printimageurl });
        }
        private delegate void SetBackGround(Canvas canvas, string upfileurl);

        private void set_background(Canvas canvas, string upfileurl)
        {
            ImageBrush imgbrush = new ImageBrush();
            BitmapImage bitimage = new BitmapImage(new Uri(upfileurl, UriKind.Absolute));
            imgbrush.ImageSource = bitimage;
            imgbrush.Stretch = Stretch.Fill;
            upfile_button.Content = "上传";
            upfile_button.IsEnabled = true;
            canvas2.Background = imgbrush;
        }


        private void bind(FrameworkElement element)
        {
            element.MouseMove += new MouseEventHandler(OnMouseMove);
            element.MouseLeftButtonDown += new MouseButtonEventHandler(OnMouseLeftButtonDown);
            element.MouseLeftButtonUp += new MouseButtonEventHandler(OnMouseLeftButtonUp);

        }

       private void OnMouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            FrameworkElement item = sender as FrameworkElement;
            isMouseCaptured = false;
            item.ReleaseMouseCapture();
            mouseVerticalPosition = -1;
            mouseHorizontalPosition = -1;
           
          
            Point point_item = e.GetPosition(null);
            IEnumerable<UIElement> elements = VisualTreeHelper.FindElementsInHostCoordinates(point_item, Application.Current.RootVisual);  //VisualTreeHelper.FindElementsInHostCoordinates(point_item,Application.Current.RootVisual);
           //textBox1.Text = String.Empty;
           //bool ok = true;
                    foreach (UIElement obj in elements)
                    {
                        if(obj is Panel){
                            Panel parent = item.Parent as Panel;

                            Panel newparent = obj as Panel;
                            //if (ok)
                            //{
                                if (parent.Name != newparent.Name)
                                {
                                    if (newparent.Name == "canvas2"||newparent.Name=="canvasselect")
                                    {
                                        parent.Children.Remove(item);
                                        newparent.Children.Add(item);
                                        break;
                                    }
                                    //else
                                    //{
                                    //    parent.Children.Remove(item);
                                    //    canvasselect.Children.Add(item);
                                    //    //newparent.Children.Add(item);

                                    //}
                                    //break;
                                    //ok = false;
                                }
                           // }
                           // textBox1.Text = textBox1.Text + "," + ((FrameworkElement)obj).Name;
                            //break;
                            
                        }
                    }
        }

       private void OnMouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            FrameworkElement item = sender as FrameworkElement;
            mouseVerticalPosition = e.GetPosition(null).Y;
            mouseHorizontalPosition = e.GetPosition(null).X;
            blockpoint = e.GetPosition((UIElement)item);
            isMouseCaptured = true;
            item.CaptureMouse();
            borderpoint = new Point(item.Width, item.Height);
        }
       bool isMouseCaptured;
       double mouseVerticalPosition;
       double mouseHorizontalPosition;
       Point blockpoint = new Point();//鼠标相对于textblock的位置
       Point borderpoint = new Point();//记录控件的当前宽度高度
       private void OnMouseMove(object sender, MouseEventArgs e)
        {
            FrameworkElement item = sender as FrameworkElement;

           //当前鼠标相对于

           //当前鼠标坐标相对于canvas的位置
            double x = e.GetPosition(null).X;
            double y = e.GetPosition(null).Y;
            
            //当前鼠标相对于textblock的位置
            Point point = e.GetPosition(item);
            

            bool isborder = false; //控件边缘

            if (item.Height - point.Y <= 5)
            {
                item.Cursor = Cursors.SizeNS;
                isborder = true;
            }
            
            if (item.Width - point.X <= 5)
            {
                item.Cursor = Cursors.SizeWE;
                isborder = true;
            }


            if (isborder) //如果只在控件边缘并且鼠标左键按下
            {
                if (isMouseCaptured)
                {
                    Point movepoint = e.GetPosition(item);
                    if (item.Cursor == Cursors.SizeNS)//准备调整高度
                    {
                        double deltaV = movepoint.Y-blockpoint.Y;
                        if(borderpoint.Y + deltaV>1)
                        item.Height = borderpoint.Y + deltaV;
                        else
                            item.Height = 1;
                    }
                    if (item.Cursor == Cursors.SizeWE)//准备调整宽度
                    {
                        double deltaH = movepoint.X-blockpoint.X;
                        if (borderpoint.X + deltaH > 1)
                            item.Width = borderpoint.X + deltaH;
                        else
                            item.Width = 1;
                    }
                }
            }
            else
            {
                item.Cursor = Cursors.Hand;
                if (isMouseCaptured)
                {
                    // Calculate the current position of the object.
                    double deltaV = e.GetPosition(null).Y - mouseVerticalPosition;
                    double deltaH = e.GetPosition(null).X - mouseHorizontalPosition;
                    double newTop = deltaV + (double)item.GetValue(Canvas.TopProperty);
                    double newLeft = deltaH + (double)item.GetValue(Canvas.LeftProperty);

                    // Set new position of object.
                    item.SetValue(Canvas.TopProperty, newTop);
                    item.SetValue(Canvas.LeftProperty, newLeft);

                    // Update position global variables.
                    Point movepoint_root = e.GetPosition(null);
                    mouseVerticalPosition = movepoint_root.Y;
                    mouseHorizontalPosition = movepoint_root.X;

                }
            }


        }
       bool isprint = false; //打印
       int order_id = 0; //订单ID
       private void canvas1_Loaded(object sender, RoutedEventArgs e)
       {
          
           printaction = System.Windows.Browser.HtmlPage.Window.Eval("printaction()").ToString();
           bool canmove = true;//控件移动
           bool getdata = false;//读取数据
           
           if (printaction.IndexOf("edit")>=0)
           {
               getdata = true;
         
           }
           else if (printaction.IndexOf("print") >= 0)
           {
               canmove = false;
               getdata = true;
               isprint = true;
           }
           if (getdata)
           {
               id = printaction.Split('|')[1];
               WebClient getupdatedata = new WebClient();
               getupdatedata.DownloadStringAsync(new Uri(Url + "manage/ajax_print.aspx?action=geteditdata&id=" + id + "&asdht=" + JsonHelper.GetRandomString(4)), null);
               getupdatedata.DownloadStringCompleted += new DownloadStringCompletedEventHandler(getupdatedata_DownloadStringCompleted);
             
           }
           if (isprint)
           {
               string[] args = printaction.Split('|');

               order_count = Convert.ToInt32(System.Windows.Browser.HtmlPage.Window.Eval("printdata.order.length"));
               if (order_count > 1)
               {
                   canvasprintmode.Visibility = Visibility.Visible;
               }
               else
               {
                   canvasprintmode.Visibility = Visibility.Collapsed;
               }
               if (order_count > 0)
               {
                   order_id = Convert.ToInt32(System.Windows.Browser.HtmlPage.Window.Eval("printdata.order[0].orderid"));
                   express_no.Text = System.Windows.Browser.HtmlPage.Window.Eval("printdata.order[0].express_no").ToString();
                   tabControl1.Visibility = Visibility.Collapsed;
                   canvas_printbutton.Visibility = Visibility.Visible;
                   current_order = 0;
                   gotonext(current_order);
               }
               label_orders.Content = (current_order+1).ToString() + "/" + order_count;
           }
           else
           {
               tabControl1.Visibility = Visibility.Visible;
               canvas_printbutton.Visibility = Visibility.Collapsed;
               
           }
           if (canmove)
           {
               for (int i = 0; i < canvasselect.Children.Count; i++)
               {
                   bind((FrameworkElement)canvasselect.Children[i]);
               }
           }
       }

       void getupdatedata_DownloadStringCompleted(object sender, DownloadStringCompletedEventArgs e)
       {
           string[] values = e.Result.Split('|');
           if (values.Length == 2)
           {
               template_name.Text = values[0];
               Dictionary<string, object> json = JsonHelper.JsonToObject(values[1]);
               canvas2.Height = Convert.ToDouble(json["height"]);
               canvas2.Width = Convert.ToDouble(json["width"]);
               int fontsize = 14;
               object tryval;
               if (json.TryGetValue("fontsize",out tryval))
               {
                   fontsize = Convert.ToInt32(tryval);

               }
               textbox_fontsize.Text = fontsize.ToString();
               region_height.Text = canvas2.Height.ToString();
               region_width.Text = canvas2.Width.ToString();
               object value = String.Empty;
               if (json.TryGetValue("image", out value))
               {
                   string img = value.ToString();
                   if (img.Length > 0)
                   {
                       BitmapImage bitimage = new BitmapImage(new Uri(Url + img));
                       ImageBrush brush = new ImageBrush();
                       brush.ImageSource = bitimage;
                       brush.Stretch = Stretch.Fill;
                       canvas2.Background = brush;
                       printimageurl = img;
                   }
               }
               if (json.TryGetValue("value", out value))
               {
                   objects = value as List<object>;
                   if (objects != null)
                   {
                       for (int i = 0; i < objects.Count; i++)
                       {
                           Dictionary<string, object> obj = objects[i] as Dictionary<string, object>;
                           Border b = canvasselect.FindName(obj["name"].ToString()) as Border;
                           if (b != null)
                           {
                               TextBlock t = b.Child as TextBlock;
                               canvasselect.Children.Remove(b);
                               canvas2.Children.Add(b);
                               b.SetValue(Canvas.TopProperty, obj["top"]);
                               b.SetValue(Canvas.LeftProperty, obj["left"]);
                               b.Height = Convert.ToDouble(obj["height"]);
                               b.Width = Convert.ToDouble(obj["width"]);
                               t.FontSize = fontsize;
                               t.FontFamily = font;
                               if (isprint)
                                   t.Text = System.Windows.Browser.HtmlPage.Window.Eval("printdata.order[" + current_order + "]."+t.Name).ToString();
                           }
                       }
                   }
               }
           }
       }

       private void button1_Click(object sender, RoutedEventArgs e)
       {
           canvasselect.Children.Remove(border2);
           canvas2.Children.Add(border2);
       }

       private void save_button_Click(object sender, RoutedEventArgs e)
       {
           
           if (template_name.Text == String.Empty)
           {
               MessageBox.Show("请输入模板名称");
           }
           else
           {
               string name = template_name.Text; 
               string value = "{\"width\":"+canvas2.Width+",\"height\":"+canvas2.Height+",\"image\":\""+printimageurl+"\",\"fontsize\":"+Convert.ToInt32(Math.Floor(textBlock1.FontSize))+",\"value\":[";
               //{\"name\":\"发货人\",\"top\":10,\"left\":10,\"width\":100,\"height\":100}
               string tempvalue = String.Empty;
               for (int i = 0; i < canvas2.Children.Count; i++)
               {
                   Border b = canvas2.Children[i] as Border;
                   if (b != null)
                   {
                       TextBlock t = b.Child as TextBlock;
                       if (t != null)
                       {
                           tempvalue = tempvalue + "," + "{\"name\":\"" + b.Name + "\",\"top\":" + b.GetValue(Canvas.TopProperty) + ",\"left\":" + b.GetValue(Canvas.LeftProperty) + ",\"width\":" + b.Width + ",\"height\":" + b.Height + "}";
                       }
                   }
               }
               if (tempvalue.Length > 0)
               {
                   tempvalue = tempvalue.Substring(1);
               }
               value = value+tempvalue+"]}";


               string turl = String.Empty;
               if (printaction == "add")//新建
               {
                   turl = "manage/ajax_print.aspx?action=addsave&asdht=" + JsonHelper.GetRandomString(4);
                   string data = "name=" + name + "&value=" + value;
                   WebClient wc = new WebClient();
                   wc.UploadStringAsync(new Uri(Url + turl), "POST", data, null);
                   wc.UploadStringCompleted += new UploadStringCompletedEventHandler(wc_UploadStringCompleted);
               }
               else //更新
               {
                   turl = "manage/ajax_print.aspx?action=updatesave&asdht=" + JsonHelper.GetRandomString(4);
                   string data = "name=" + name + "&value=" + value+"&id="+id;
                   WebClient wc = new WebClient();
                   wc.UploadStringAsync(new Uri(Url + turl), "POST", data, null);
                   wc.UploadStringCompleted += new UploadStringCompletedEventHandler(wc_UploadStringCompleted);
               }
           }

       }

       void wc_UploadStringCompleted(object sender, UploadStringCompletedEventArgs e)
       { 
           System.Windows.Browser.HtmlPage.Window.Eval(e.Result);
       }

       private void gotonext(int page)//打印订单
       {
           order_id = Convert.ToInt32(System.Windows.Browser.HtmlPage.Window.Eval("printdata.order[" + page + "].orderid").ToString());
           if (objects != null)
           {
               for (int i = 0; i < objects.Count; i++)
               {
                   Dictionary<string, object> obj = objects[i] as Dictionary<string, object>;
                   Border b = canvas2.FindName(obj["name"].ToString()) as Border;
                   if (b != null)



                   {
                       TextBlock t = b.Child as TextBlock;
                       if (isprint)
                           t.Text = System.Windows.Browser.HtmlPage.Window.Eval("printdata.order[" + page + "]." + t.Name).ToString();
                   }
               }
           }
       }

     private string getnextexpressid(string oldid) {
       Regex regex=new Regex(@"([a-z|A-Z|0]*)(\d+)");
       string newid= regex.Replace(oldid,"$2");
       string mychar =regex.Replace(oldid,"$1"); //oldid.replace(regex, "$1");
       long id=0;
       long.TryParse(newid, out id);
       id = id + 1;
       newid = id.ToString();  //parseInt(newid) + 1;
       return mychar + newid;
    }

       private void print_button_Click(object sender, RoutedEventArgs e)
       {
           if (express_no.Text == String.Empty)
           {
               MessageBox.Show("快递单号不能为空,如果连续打印，快递单号只需第一单输入一次，之后系统会自动生成");
               return ;
           }
           canvas2.Background = null;
           for (int i = 0; i < canvas2.Children.Count; i++)
           {
               Border border = canvas2.Children[i] as Border;
               if (border != null)
               {
                   border.Background = null;
                   border.BorderBrush = null;
               }
           }
           System.Windows.Printing.PrintDocument pd = new System.Windows.Printing.PrintDocument();
           pd.PrintPage += new EventHandler<System.Windows.Printing.PrintPageEventArgs>(pd_PrintPage);
           pd.EndPrint += new EventHandler<System.Windows.Printing.EndPrintEventArgs>(pd_EndPrint);
           pd.Print("快递单");
           
       }

       void pd_EndPrint(object sender, System.Windows.Printing.EndPrintEventArgs e)
       {

           if (current_order >= order_count)
               System.Windows.Browser.HtmlPage.Window.Eval("location.replace(location.href)");
           else
           {
               gotonext(current_order);
               express_no.Text = getnextexpressid(express_no.Text);
               label_orders.Content = (current_order + 1).ToString() + "/" + order_count.ToString();
           }

       }
        /// <summary>
        /// 是否可以打印
        /// </summary>
       private bool canprint = true;
       void pd_PrintPage(object sender, System.Windows.Printing.PrintPageEventArgs e)
       {
           int second = 1;
           while (second<=3)
           {
               if (canprint) break;
               System.Threading.Thread.Sleep(1000);
               second++;
           }
           if (!canprint) return;
           e.HasMorePages = false;
           current_order = current_order + 1;
           if (current_order< order_count)
           {
               if (autoprint.IsChecked.HasValue && autoprint.IsChecked.Value)//没有到最后一页
               {
                   e.HasMorePages = true;
               }  
           }
           if (autoprint.IsChecked.HasValue && autoprint.IsChecked.Value)//没有到最后一页
           {
               gotonext(current_order - 1);
               if (current_order > 1)
                   express_no.Text = getnextexpressid(express_no.Text);
               label_orders.Content = (current_order).ToString() + "/" + order_count.ToString();
           }
           e.PageVisual = canvas2;
           string turl = "manage/ajax_print.aspx?action=updateprintstate&asdht=" + JsonHelper.GetRandomString(4)+"&id="+order_id+"&express_no="+express_no.Text;
           
           WebClient wc = new WebClient();
           wc.DownloadStringCompleted += new DownloadStringCompletedEventHandler(wc_DownloadStringCompleted);
           wc.DownloadStringAsync(new Uri(Url + turl));
           canprint = false;
           
       }

       void wc_DownloadStringCompleted(object sender, DownloadStringCompletedEventArgs e)
       {
           
           if (e.Error!=null|| e.Result != "success")
           {
               canprint = false;
               noautoprint.IsChecked = true;
               noautoprint.Dispatcher.BeginInvoke(new StopPrintAction(StopPrint));
               System.Windows.Browser.HtmlPage.Window.Eval("alert('打印发生错误。打印的订单状态没有更新到系统中，可能是网络原因。请关闭此窗口后。重新筛选订单进行打印');");
           }
           else
               canprint = true;
       }
       private delegate void StopPrintAction();

       private void StopPrint()
       {
           noautoprint.IsChecked = true;
       }

    }
}
