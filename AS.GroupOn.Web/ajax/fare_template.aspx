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
<script runat="server">
    protected string asaction = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        asaction = Helper.GetString(Request["action"], String.Empty);

        if (asaction == "add")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FareTemplate_Add))
            {
                //SetError("你不具有添加运费模版的权限！");
                Response.Write("<script>alert('你不具有添加运费模版的权限');<"+"/script>");
                Response.Redirect("manage/fare_template.aspx");
                Response.End();
                return;

            }
            string html =WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/fare_template.aspx");
            Response.Clear();
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
            return;
        }
        else if (asaction == "addsave")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FareTemplate_Add))
            {
                //SetError("你不具有添加运费模版的权限！");
                Response.Write("<script>alert('你不具有添加运费模版的权限');<" + "/script>");
                Response.Redirect("manage/fare_template.aspx");
                Response.End();
                return;

            }
            string name = Helper.GetString(Request["name"], String.Empty);
            string value = Helper.GetString(Request["value"], String.Empty);
            IFareTemplate faretemplate = Store.CreateFareTemplate();
            faretemplate.name = name;
            faretemplate.value = value;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int i = session.FareTemplate.Insert(faretemplate);
            }
          
        }
        else if (asaction == "edit")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FareTemplate_Editt))
            {
                SetError("你不具有编辑运费模版的权限！");
                Response.Redirect("manage/fare_template.aspx");
                Response.End();
                return;

            }
            int id = Helper.GetInt(Request["id"], 0);
            if (id > 0)
            {
                string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/fare_template.aspx?id=" + id);
                Response.Clear();
                Response.Write(JsonUtils.GetJson(html, "dialog"));
                Response.End();
                return;
            }

        }
        else if (asaction == "editsave")
        {
            int id = Helper.GetInt(Request["id"], 0);
            string name = Helper.GetString(Request["name"], String.Empty);
            string value = Helper.GetString(Request["value"], String.Empty);
           
            IFareTemplate faretemplate = Store.CreateFareTemplate();
            faretemplate.name = name;
            faretemplate.value = value;
            faretemplate.id = id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int i = session.FareTemplate.Update(faretemplate);
            }
        }

    }
</script>