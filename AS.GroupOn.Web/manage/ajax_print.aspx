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
<script runat="server">

    private NameValueCollection _system = new NameValueCollection();
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


            if (all_id != "" && all_id != null && id != null)
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

            ITemplate_print Template_print = Store.CreateTemplate_print();

            string name = namevalues["name"];
            string data = namevalues["value"];
            if (name.Length > 0 && data.Length > 0)
            {
                Template_print.template_name = name;
                Template_print.template_value = data;

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
                    cnt = session.Template_print.Update(Template_print);

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
        else if (action == "updateprintstate")
        {
            _system = WebUtils.GetSystem();
            if (_system != null)
            {
                if (_system["printorder"] != null)
                {
                    if (_system["printorder"] == "1")//开启订单打印提醒
                    {
                        #region 发送短信
                        System.Collections.Generic.List<string> phone = new System.Collections.Generic.List<string>();
                        IOrder ordermodel = null;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            ordermodel = session.Orders.GetByID(Helper.GetInt(Request["id"], 0));
                        }
                        string catename = "";
                        ICategory catemodel = null;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            catemodel = session.Category.GetByID(Helper.GetInt(ordermodel.Express_id, 0));
                        }
                        if (catemodel != null)
                        {
                            catename = catemodel.Name;
                        }
                        if (ordermodel != null)
                        {
                            IUser usermodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                usermodel = session.Users.GetByID(Helper.GetInt(ordermodel.User_id, 0));
                            }
                            phone.Add(usermodel.Mobile);
                            //发货提醒
                            NameValueCollection values = new NameValueCollection();
                            values.Add("网站简称", ASSystem.abbreviation);
                            values.Add("用户名", usermodel.Username);
                            values.Add("订单号", Helper.GetInt(Request["id"], 0).ToString());
                            values.Add("快递公司", catename);
                            values.Add("快递单号", Helper.GetString(Request["express_no"], String.Empty));
                            string message = ReplaceStr("delivery", values);
                            EmailMethod.SendSMS(phone, message);
                            //{网站简称}用户{用户名}您好 您的订单{订单ID}已由{快递公司名称}发出，快递单号为{快递单号}，您可登录{快递公司名称}查询物流信息
                        }
                        #endregion
                    }
                }
            }
            IOrder iorders = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iorders = session.Orders.GetByID(Helper.GetInt(Request["id"], 0));

                iorders.Express_xx = "已打印";
                iorders.Express_no = Helper.GetString(Request["express_no"], String.Empty);
                session.Orders.Update(iorders);
            }
            Response.Write("success");
        }
    }
</script>