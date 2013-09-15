<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected int cnt = 0;
    Template_printFilter filter = new Template_printFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        string action = Helper.GetString(Request["action"], String.Empty);
        
         if (action == "selectexpress")
            {
               int id = Helper.GetInt(Request["expressid"], 0);
               string all_id = Request["all_id"].ToString();

             
               if (all_id != "" && all_id !=null && id !=null)
               {
                   
                   string all_id1 = all_id.Substring(0, all_id.Length - 1);

                   IOrder order = Store.CreateOrder();
                   order.all_id = all_id1;
                   order.Express_id = id;
                  
                   using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                   {
                       cnt = session.Orders.UpdateExpress_id_all(order);
                   }
                   if (cnt > 0)
                   {
                       Response.Write(JsonUtils.GetJson("alert('批量操作成功');location.reload(true);", "eval"));
                   }
               }
             
            }
         else if (action == "print")
         {
             int id = Helper.GetInt(Request["id"], 0);
             string html = String.Empty;
             if (id > 0)//打印单一订单
             {
                 html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/manage_ajax_dialog_printtemplate.aspx?action=print&oid=" + Request["id"]);
             }
             else
             {
                 html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/manage_ajax_dialog_printtemplate.aspx?action=print&where=" + Request["where"]);
             }
             Response.Write(JsonUtils.GetJson(html, "dialog"));
         }

         else if (action == "add")
         {

             string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/manage_ajax_dialog_printtemplate.aspx?action=add");
             Response.Write(JsonUtils.GetJson(html, "dialog"));
         }
         else if (action == "addsave")//新建保存
         {
             StreamReader sr = new StreamReader(Request.InputStream);
             string val = sr.ReadToEnd();
             NameValueCollection namevalues = HttpUtility.ParseQueryString(val);
             
             ITemplate_print Template_print=Store.CreateTemplate_print();

             string name = namevalues["name"];
             string data = namevalues["value"];
             if (name.Length > 0 && data.Length > 0)
             {
                 Template_print.template_name=name;
                 Template_print.template_value=data;
                 
                 using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                 {
                     cnt = session.Template_print.Insert(Template_print);
                 }
                 if (cnt > 0)
                 {
                     Response.Write("alert('保存成功');location.replace(location.href);");
                     Response.End();
                     return;
                 }
             }
             Response.Write("alert('保存失败');");
             Response.End();
             return;
         }
         else if (action == "edit")
         {
             string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/manage_ajax_dialog_printtemplate.aspx?action=edit&id=" + Request["id"]);
             Response.Write(JsonUtils.GetJson(html, "dialog"));
         }
           
             // 删除快递模版
         else if (action == "delete")
         {
             int id = Helper.GetInt(Request["id"], 0);

             using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
             {
                 cnt = session.Template_print.Delete(id);
             }
             
             if (cnt > 0)
             {
                 Response.Write(JsonUtils.GetJson("alert('删除成功');location.replace('" + Request.UrlReferrer.AbsoluteUri + "');", "eval"));
                 Response.End();
                 return;
             }
         }
         else if (action == "upimage")
         {
             string filename = Request.QueryString["filename"];
             if (filename != String.Empty && Request.ContentLength > 0)
             {
                 Stream tream = Request.InputStream;
                 byte[] inputbytes = new byte[tream.Length];
                 tream.Read(inputbytes, 0, inputbytes.Length);
                 string extname = Path.GetExtension(filename).ToLower();//文件扩展名
                 if (extname == ".jpg" || extname == ".png")
                 {
                     filename = "upfile/print/" + DateTime.Now.ToString("yyyyMMddHHmmss") + extname;
                     FileStream fs = File.Create(AppDomain.CurrentDomain.BaseDirectory + filename, inputbytes.Length);
                     fs.Write(inputbytes, 0, inputbytes.Length);
                     fs.Flush();
                     fs.Close();
                     Response.Clear();
                     Response.Write(filename);
                     Response.End();
                     return;
                 }
                
             }
         }
         else if (action == "updatesave")
         {
             int cnt = 0;
             ITemplate_print Template_print = Store.CreateTemplate_print();
             StreamReader sr = new StreamReader(Request.InputStream);
             string val = sr.ReadToEnd();
             NameValueCollection namevalues = HttpUtility.ParseQueryString(val);
             string name = namevalues["name"];
             string data = namevalues["value"];
             int id = Helper.GetInt(namevalues["id"], 0);
             
             Template_print.template_name = name;
             Template_print.template_value = data;
             Template_print.id = id;
             
             if (name.Length > 0 && data.Length > 0)
             {
                 using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                 {
                   cnt=  session.Template_print.Update(Template_print);
                 
                 }

                 if (cnt > 0)
                 {
                     Response.Write("alert('保存成功');X.boxClose();");
                     Response.End();
                     return;
                 }
             }
             Response.Write("alert('保存失败');");
             Response.End();
             return;
         }
         else if (action == "geteditdata")
         {

             ITemplate_print Template_print = Store.CreateTemplate_print();
             int id = Helper.GetInt(Request["id"], 0);

             using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
             {
                  Template_print = session.Template_print.GetByID(id);

             }
             if (Template_print != null)
             {
                 string value = Template_print.template_name + "|" + Template_print.template_value;
                 Response.Write(value);
             }
             
         }
         else if (action == "getprintdata")
         {
             
             ITemplate_print Template_print = Store.CreateTemplate_print();
             int id = Helper.GetInt(Request["id"], 0);

             using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
             {
                 Template_print = session.Template_print.GetByID(id);
             }
             if (Template_print != null)
             {
                 string value = Template_print.template_name + "|" + Template_print.template_value;
                 Response.Write(value);
             }
             
         }

    }
</script>