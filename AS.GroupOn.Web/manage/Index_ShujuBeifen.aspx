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
<%@ Import Namespace="System.Data" %>
<script runat="server">
    protected DataTable selectoptions = new DataTable();
    protected bool backup = false;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Data_Backup))
        {
            SetError("你不具有查看数据备份的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        selectoptions.Columns.Add(new DataColumn("text", Type.GetType("System.String")));
        selectoptions.Columns.Add(new DataColumn("value", Type.GetType("System.String")));
        List<Hashtable> resultHash = new List<Hashtable>();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            resultHash = session.Custom.Query("select name as text,name as value from sysobjects where xtype='U' order by text");
        }
        selectoptions = Helper.ConvertDataTable(resultHash.ToList());
        DataRow row = selectoptions.NewRow();
        row["text"] = "请选择数据表";
        row["value"] = "";
        selectoptions.Rows.InsertAt(row, 0);
      
    }
    protected void submit_ServerClick(object sender, EventArgs e)
    {

        
            string backuptype = Helper.GetString(Request["bfzl"], String.Empty);
            if (backuptype == "all")//备份全部
            {
                Utilys.BackUpAll();
                SetSuccess("备份成功");
                Response.Redirect(PageValue.WebRoot + "manage/index_shujubeifen.aspx");
            }
            else//备份单张表
            {
                string tablename = Helper.GetString(Request["tablename"], String.Empty);
                if (tablename.Length > 0)
                {
                    Utilys.BackUpSingle(tablename);
                    SetSuccess("备份成功");
                    Response.Redirect(PageValue.WebRoot + "manage/index_shujubeifen.aspx");
                }
                else
                {
                    SetError("数据表选择错误");
                    Response.Redirect(PageValue.WebRoot + "manage/index_shujubeifen.aspx");
                }
            }
        
    }
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
                                <div class="head">
                    <h2>数据库备份</h2>
                   
				</div>
                <div class="sect">
                    <table width="96%" border="0" align="center" class="coupons-table">
                        <tr><td width="510px">备份方式：</td><td rowspan="11" valign="top" style="padding-left:20px"><font color="red"><b>提示信息：</b></font><br/>服务器备份目录为backup<br/></td></tr>
                        <tr><td width="510px"><input type="radio" name="bfzl" value="all" checked="checked"/>备份全部数据<span class="gray">备份全部数据表中的数据到一个备份文件</span></td></tr>    
                        <tr><td width="510px"><input type="radio" name="bfzl" value="single"/>备份单张表数据&nbsp;<%=WebUtils.AppendSelectControl("tablename", "tablename", "", selectoptions, "text", "value", "")%>&nbsp;&nbsp;<span class="gray">备份单独的数据表到备份文件</span></td></tr>
                        <tr><td align='left' width="510px"><input type="button" runat="server" onserverclick="submit_ServerClick" class="formbutton validator" group="backup"  value="开始备份"/></td></tr>
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

