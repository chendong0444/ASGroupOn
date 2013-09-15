using System;
using System.Collections.Generic;
using System.Text;
using System.Collections.Specialized;
using System.IO;
using System.Xml;
using System.Web;
namespace AS.Common.Utils
{
   public class FileUtils
    {
       private static object obj = new object();
       private static object objkey = new object();
       private static NameValueCollection _config = null;
       private static string _key = String.Empty;
       /// <summary>
       /// 返回配置文件信息
       /// </summary>
       /// <returns></returns>
       public static NameValueCollection GetConfig()
       {

           lock (obj)
           {
               if (_config == null)
               {
                   //read xml
                   string path = AppDomain.CurrentDomain.BaseDirectory + "config\\data.config";
                   initSystemConfig();
                   NameValueCollection nvc = new NameValueCollection();
                   XmlDocument Doc_Detail = new XmlDocument();
                   Doc_Detail.Load((path));
                   XmlNodeList NodeList = Doc_Detail.SelectNodes("/root/system/*");
                   if (NodeList.Count > 0)
                   {
                       for (int i = 0; i < NodeList.Count; i++)
                       {
                           if (NodeList[i] != null)
                           {
                               nvc.Add(NodeList[i].Name, NodeList[i].InnerText);
                           }
                       }
                   }
                   _config = nvc;
               }
               
           }
           return _config;
       }

       /// <summary>
       /// 初始化配置文件信息
       /// </summary>
       private static void initSystemConfig()
       {
           string path1 = AppDomain.CurrentDomain.BaseDirectory + "config";
           if (!Directory.Exists(path1))
           {
               Directory.CreateDirectory(path1);

           }
           string path = AppDomain.CurrentDomain.BaseDirectory + "config\\data.config";
           FileInfo CreateFile = new FileInfo(path); //创建文件
           if (!CreateFile.Exists)
           {
               FileStream FS = CreateFile.Create();
               FS.Close();

               StreamWriter SW;
               SW = File.AppendText(path);
               SW.WriteLine("<?xml version=\"1.0\"?><root><system></system></root>");
               SW.Close();
           }
       }

       /// <summary>
       /// 保存配置文件
       /// </summary>
       /// <param name="name"></param>
       /// <param name="value"></param>
       public static void SetConfig(string name, string value)
       {
           lock (obj)
           {
               if (_config == null)
               {
                   initSystemConfig();
               }
               string path=AppDomain.CurrentDomain.BaseDirectory + "config\\data.config";
               XmlDocument xmldoc = new XmlDocument();
               xmldoc.Load(path);
               XmlNode node = xmldoc.SelectSingleNode("/root/system/" + name);
               if (node != null)
                   node.InnerText = value;
               else
               {
                   node = xmldoc.CreateNode(XmlNodeType.Element, name, null);
                   node.InnerText = value;
                   xmldoc.SelectSingleNode("/root/system").AppendChild(node);
               }
               xmldoc.Save(path);
               _config = null;
           }

       }
       /// <summary>
       /// 返回加密密钥
       /// </summary>
       /// <returns></returns>
       public static string GetKey()
       {
           string path = AppDomain.CurrentDomain.BaseDirectory + "bin\\loginkey.config";
           lock (objkey)
           {
               if (String.IsNullOrEmpty(_key))
               {
                   XmlDocument xmldoc = new XmlDocument();
                   xmldoc.Load(path);
                   XmlNode node = xmldoc.SelectSingleNode("//appSettings/add[@key='login']");
                   if (node != null)
                   {
                       _key = node.Attributes["value"].Value;
                   }
               }
               return _key;
           }
       }

       /// <summary>
       /// 返回已上传文件的绝对路径
       /// </summary>
       /// <param name="file">文件</param>
       /// <param name="savePath">保存路径</param>
       /// <param name="extName">文件扩展名</param>
       /// <returns>上传成功返回图片绝对路径。失败返回空字符串</returns>
       private static string upfile(HttpPostedFile file, string savePath, string extName)
       {
           string p_path = HttpContext.Current.Server.MapPath(savePath);
           if (!Directory.Exists(p_path))
           {
               Directory.CreateDirectory(p_path);
           }
           string filename = StringUtils.GetRandomString(8) + extName;
           file.SaveAs(p_path + "\\" + filename);
           savePath = "/" + StringUtils.DelSideChar(savePath, '/') + "/" + filename;
           return savePath;
       }


       /// <summary>
       /// 上传文件
       /// </summary>
       /// <param name="filestream">文件流</param>
       /// <param name="savePath">保存路径</param>
       /// <param name="extName">扩展名</param>
       /// <returns>上传成功返回图片绝对路径。失败返回空字符串</returns>
       public static string upfile(Stream filestream, string savePath, string extName)
       {
           string p_path = HttpContext.Current.Server.MapPath(savePath);
           if (!Directory.Exists(p_path))
           {
               Directory.CreateDirectory(p_path);
           }
           string filename = StringUtils.GetRandomString(8) + extName;
           FileStream fs = File.Create(p_path + "\\" + filename);
           byte[] buffer = new byte[filestream.Length];
           filestream.Read(buffer, 0, (int)filestream.Length);
           fs.Write(buffer, 0, buffer.Length);
           fs.Flush();
           fs.Close();
           filestream.Close();
           savePath = "/" + StringUtils.DelSideChar(savePath, '/') + "/" + filename;
           return savePath;
       }

       /// <summary>
       /// 保存上传的图片文件
       /// </summary>
       /// <param name="file">文件</param>
       /// <param name="savePath">保存路径</param>
       /// <returns>上传成功返回图片绝对路径。失败返回空字符串</returns>
       public static string UpImageFile(HttpPostedFile file, string savePath)
       {
           if (file == null) return String.Empty;
           string extName = Path.GetExtension(file.FileName).ToLower();
           if (extName != ".jpg" && extName != ".bmp" && extName != ".jpeg" && extName != ".gif" && extName != ".png") return String.Empty;
           return upfile(file, savePath, extName);
       }

       /// <summary>
       /// 上传用户头像
       /// </summary>
       /// <param name="file"></param>
       /// <returns></returns>
       public static string UpUserActarImageFile(HttpPostedFile file)
       {
           return UpImageFile(file, "/upfile/user/");
       }
       /// <summary>
       /// 上传项目图片
       /// </summary>
       /// <param name="file"></param>
       /// <returns></returns>
       public static string UpTeamImage(HttpPostedFile file)
       {
           return UpImageFile(file, "/upfile/team/" + DateTime.Now.Year.ToString() + "/" + DateTime.Now.Month.ToString() + "/" + DateTime.Now.Day.ToString() + "/");
       }
       /// <summary>
       /// 上传Logo图片
       /// </summary>
       /// <param name="file"></param>
       /// <returns></returns>
       public static string UpLogoImage(HttpPostedFile file)
       {
           return UpImageFile(file, "/upfile/logo/");
       }


       /// <summary>
       /// 保存上传的图片文件
       /// </summary>
       /// <param name="file">文件</param>
       /// <param name="savePath">保存路径</param>
       /// <returns>上传成功返回图片绝对路径。失败返回空字符串</returns>
       public static string UpImageFile(Stream fileStream, string savePath, string extName)
       {
           if (fileStream == null || fileStream.Length == 0) return String.Empty;
           if (String.IsNullOrEmpty(extName)) return String.Empty;
           extName = extName.ToLower();
           if (extName != ".jpg" && extName != ".bmp" && extName != ".jpeg" && extName != ".gif" && extName != ".png") return String.Empty;
           return upfile(fileStream, savePath, extName);
       }




       


    }
}
