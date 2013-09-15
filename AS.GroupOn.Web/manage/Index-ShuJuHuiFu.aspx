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
<%@ Import Namespace="System.IO" %>
<script runat="server">
    protected bool backup = false;
    protected DataRow[] files = null;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Sale_List) )
        {
            SetError("你不具有查看数据库恢复的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        string delfile = Helper.GetString(Request["del"], String.Empty);
        if (delfile != String.Empty)
        {
            string dfile = Server.MapPath(PageValue.WebRoot + "backup/" + delfile);
            if (File.Exists(dfile))
            {
                File.Delete(dfile);
                SetSuccess("删除备份文件:" + delfile + "成功");
                Response.Redirect(PageValue.WebRoot + "manage/index-shujuhuifu.aspx");
                Response.End();
                return;
            }
        }
        files = WebUtils.GetFilesByTime(Server.MapPath(PageValue.WebRoot + "backup"));
    }

    protected void submit_ServerClick(object sender, EventArgs e)
    {

            string filename = Helper.GetString(Request["filename"], String.Empty);
            filename = Server.MapPath(PageValue.WebRoot + "backup/" + filename);
            if (filename == String.Empty || !File.Exists(filename))
            {
                SetError("请选择您要恢复的数据库文件");
            }
            else
            {
                Utilys.Restore((object)filename);
                SetSuccess("恢复成功！");
                Response.Redirect(PageValue.WebRoot + "manage/index-shujuhuifu.aspx");
                Response.End();
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
                    <h2>数据库恢复</h2>
                    
				</div>
                <div class="sect">
    <table width="96%" border="0" class="coupons-table">
    <tr>
    <td width="58%" height="25">   
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td height="25" width="70%">数据库文件名</td>
            <td>创建时间</td>
          </tr>
          <%for (int i = 0; i < files.Length; i++)
            { %>
          <tr>
            <td height="25" width="70%"><input type="radio" name="filename" id="filename<%=i %>" value="<%=files[i]["filename"] %>" /> <label for="filename<%=i %>"><%=files[i]["filename"]%></label>&nbsp;&nbsp;[<a target="_blank" href="<%=PageValue.WebRoot %>backup/<%=files[i]["filename"] %>">下载</a>]&nbsp;&nbsp;<a href="<%=PageValue.WebRoot %>manage/Index-ShuJuHuiFu.aspx?del=<%=files[i]["filename"] %>">[删除]</a></td>
            <td><%=files[i]["createtime"]%></td>
          </tr>
          <%} %>
        </table>
    </td>
		<td width="41%" rowspan="4" valign="top"><ul><li>1、本功能在恢复备份数据的同时，将全部覆盖原有数据</li><li>2、数据恢复只能恢复由本系统导出的数据文件，其他软件导出格式无法识别</li><%--<li>3、从本地恢复数据最大数据2M</li>--%><%--<li>4、如果您使用了分卷备份，只需手工导入文件卷1，其他数据文件会由系统导入</li>--%></ul></td></tr>
    <tr height="50px"><td align="left"><input type="submit" runat="server" onserverclick="submit_ServerClick" value="恢复" group="restore" class="formbutton validator"></td></tr>
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

