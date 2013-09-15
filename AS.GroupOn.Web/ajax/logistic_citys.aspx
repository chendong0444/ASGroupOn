<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="System.Data" %>
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
    protected string actionas = "query";
    protected override void OnLoad(EventArgs e)
    {
       
        base.OnLoad(e);
        actionas = Helper.GetString(Request["action"], String.Empty);
        if (actionas == "query")
        {
            int id = Helper.GetInt(Request["id"], 0);
            string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/logistic_citys.aspx?pid=" + id);
            Response.Clear();
            Response.Write(html);
            Response.End();
            return;
        }
        else if (actionas == "add")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_LogisticsCity_Add))
            {
                SetError("你不具有添加物流城市的权限！");
                Response.Redirect("manage/logistic_citys.aspx");
                Response.End();
                return;

            }
            IFarecitys farecitys = Store.CreateFarecitys();
            int pid = Helper.GetInt(Request["pid"], 0);
            string cityname = Helper.GetString(Request["name"], String.Empty);
            farecitys.pid = pid;
            farecitys.name = cityname;
            
            if (cityname.Length > 0)
            {
                using (IDataSession session=AS.GroupOn.App.Store.OpenSession(false))
                {
                    int a = session.Farecitys.Insert(farecitys);
                }
                string html = WebUtils.LoadPageString(PageValue.WebRoot+"manage/ajaxpage/logistic_citys.aspx?pid=" + pid);
                Response.Clear();
                Response.Write(html);
                Response.End();
            }
        }
        else if (actionas == "del")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_LogisticsCity_Delete))
            {
                SetError("你不具有删除物流城市的权限！");
                Response.Redirect("manage/logistic_citys.aspx");
                Response.End();
                return;

            }
            int id = Helper.GetInt(Request["id"], 0);
            if (id > 0)
            {
                using (IDataSession session=AS.GroupOn.App.Store.OpenSession(false))
                {
                    int a = session.Farecitys.Delete(id);
                }
            }

        }
        else if (actionas == "edit")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_LogisticsCity_Edit))
            {
                SetError("你不具有编辑物流城市的权限！");
                Response.Redirect("manage/logistic_citys.aspx");
                Response.End();
                return;

            }
            IFarecitys farecitys = Store.CreateFarecitys();
            int id = Helper.GetInt(Request["id"], 0);
            string cityname = Helper.GetString(Request["name"], String.Empty);
            farecitys.id = id;
            farecitys.name = cityname;
            if (id > 0 && cityname.Length > 0)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    //DataRowObject dro = db.SqlExecDataRow("select * from farecitys where id=" + id);
                    //dro.SetValue("name", cityname);
                    //Utils.DBHelper.FareCitys_Edit(db, dro);
                    int a = session.Farecitys.Update(farecitys);
                }
            }
        }
    }
</script>