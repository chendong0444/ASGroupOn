<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected string mess = "";
    protected static DataTable rt = new DataTable();
    protected override void OnLoad(EventArgs e)
    {

        base.OnLoad(e);
        //  rt.Columns.Clear();
        rt.Clear();
        if (Request["button"] == "提交")
        {
            if (Request["teamid"] != null)
            {
                if (AS.Common.Utils.Helper.GetInt(Request["teamid"], 0) != 0)
                {
                    // mess = Maticsoft.BLL.pcoupon.Manage_ImportExpressNumber(Utils.Helper.GetInt(Request["teamid"], 0));
                    //// Response.Write(messge);
                    // mess = messge;
                    mess = Manage_ImportExpressNumber(AS.Common.Utils.Helper.GetInt(Request["teamid"], 0));
                }
                else
                {
                    // Response.Write("请输入有效字符");
                    mess = "请输入有效字符";
                }
            }
        }
    }


    #region 商户优惠券是否有重复的记录
    public static bool issame(System.Data.DataTable dt, int teamid)
    {
        bool falg = false;
        string str = "";
        System.Data.DataSet ds = new System.Data.DataSet();
        rt = new System.Data.DataTable();


        DataColumn column;

        column = new DataColumn();
        column.DataType = System.Type.GetType("System.String");
        column.ColumnName = "number";
        column.ReadOnly = true;
        column.Unique = true;
        rt.Columns.Add(column);

        foreach (DataRow dr in dt.Rows)
        {
            string txt = str;
            string txt1 = dr["Id"].ToString();
            if (AS.Common.Utils.Helper.GetString(dr["Id"].ToString(), "") != "")
            {
                if (str.Contains(dr["Id"].ToString()))
                {
                    falg = true;
                    DataRow rdr = rt.NewRow();
                    rdr["number"] = dr["Id"].ToString();
                    rt.Rows.Add(rdr);
                }
                else
                {

                    str += "," + dr["Id"];
                }
            }
        }


        foreach (DataRow dr in dt.Rows)
        {
            PcouponFilter pcoubll = new PcouponFilter();
            IList<IPcoupon> list = null;
            pcoubll.number = dr["Id"].ToString();
            pcoubll.teamid = teamid;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                list = session.Pcoupon.GetList(pcoubll);
            }
            DataTable dt2 = null;
            dt2 = AS.Common.Utils.Helper.ToDataTable(list.ToList());

            if (dt2.Rows.Count > 0)
            {
                falg = true;
            }
        }


        return falg;
    }
    #endregion




    #region 导入商户优惠券
    public static string Manage_ImportExpressNumber(int teamid)
    {


        ITeam teammodel = null;
        TeamFilter teambll = new TeamFilter();

        IPcoupon pcoumodel = AS.GroupOn.App.Store.CreatePcoupon();
        PcouponFilter pcoubll = new PcouponFilter();
        string msg = String.Empty;//导入结果提示信息
        //过程
        string filename = null;

        HttpFileCollection files = HttpContext.Current.Request.Files;
        if (files.Count > 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teammodel = session.Teams.GetByID(teamid);
            }
            filename = files[0].FileName;

            string path2 = AppDomain.CurrentDomain.BaseDirectory + DateTime.Now.ToString("yyyyMMddHHmmss") + ".xls";


            HttpContext.Current.Request.Files[0].SaveAs(path2);//保存文件到web根目录
            //连接字符串
            string strConn = "Provider=Microsoft.Jet.OLEDB.4.0;" + "Data Source=" + path2 + ";" + "Extended Properties=Excel 8.0;";
            System.Data.OleDb.OleDbConnection conn = new System.Data.OleDb.OleDbConnection(strConn);
            System.Data.DataSet ds = null;
            try
            {
                conn.Open();
                string strExcel = "";
                System.Data.OleDb.OleDbDataAdapter myCommand = null;
                strExcel = "select Id from [Sheet1$]";
                myCommand = new System.Data.OleDb.OleDbDataAdapter(strExcel, conn);
                ds = new System.Data.DataSet();
                myCommand.Fill(ds, "table1");
                System.Data.DataTable dt = ds.Tables["table1"];

                if (issame(dt, teamid))
                {
                    msg = "Excel中有重复数据，请仔细检查";
                }
                else
                {
                    int j = dt.Rows.Count;
                    if (j > 0)
                    {//执行插入数据库动作
                        //  HttpContext.Current.Response.Write("成功");
                        msg = "成功";
                        for (int i = 0; i < j; i++)
                        {
                            if (AS.Common.Utils.Helper.GetString(dt.Rows[i]["Id"].ToString(), "") != "")
                            {
                                pcoumodel.number = dt.Rows[i]["Id"].ToString();
                                pcoumodel.teamid = teamid;
                                pcoumodel.userid = 0;
                                pcoumodel.state = "nobuy";
                                pcoumodel.expire_time = teammodel.Expire_time;
                                pcoumodel.create_time = DateTime.Now;
                                pcoumodel.partnerid = teammodel.Partner_id;
                                pcoumodel.start_time = teammodel.start_time;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int Id = session.Pcoupon.Insert(pcoumodel);
                                }
                            }
                        }
                        teammodel.inventory = teammodel.inventory + dt.Rows.Count;
                        teammodel.open_invent = 1;//开启库存
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int Id = session.Teams.Update(teammodel);
                        }
                    }
                    else
                    {
                        msg = "Excel中没有数据";
                    }
                }
            }
            catch (Exception ex)
            {
                msg = "打开连接失败啦！";
                // HttpContext.Current.Response.Write(ex.Message);
            }
            finally
            {
                conn.Close();

                //删除xls文件
                if (System.IO.File.Exists(path2))
                {
                    System.IO.File.Delete(path2);
                }

            }

        }
        return msg;
    }
    #endregion
    
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>无标题文档</title>
    <style type="text/css">
<!--
body,td,th {
	font-size: 12px;
	color: #333333;
}
-->
</style>
</head>
<body>
    <form action="" method="post" enctype="multipart/form-data">
    <table width="600" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td bgcolor="#CCCCCC">
                <table width="600" border="0" align="center" bgcolor="#CCCCCC" cellpadding="10" cellspacing="1px">
                    <tr>
                        <td bgcolor="#FFFFFF">
                            <div class="field">
                                <label>
                                    选择文件：</label>
                                <input type="hidden" name="action" value="importexpressnumber" id="action" />
                                <input type="file" name="fileField" id="fileField" class="f-input" />
                                <input type="submit" name="button" id="button" value="提交" class="validator formbutton" />
                                <font style='color: red'></font>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <% if (rt.Rows.Count > 0)
                           {%>
                        <td bgcolor="#FFFFFF">
                            重复的券号,提交失败
                            <br>
                            <%foreach (System.Data.DataRow dr in rt.Rows)
                              { %>
                            <%=dr["number"].ToString()%><br>
                            <% }%>
                        </td>
                        <% }
                           else
                           {%>
                        <td bgcolor="#FFFFFF">
                            <%if (mess != "")
                              { %>
                            <%=mess %>
                            <%}
                              else
                              { %>
                            <strong>注：请上传xls文档，。 </strong>
                            <br />
                            <br />
                            <strong>文档列名说明：</strong>
                            <br />
                            Id：商户优惠券号
                            <br />
                            <br />
                            <a href="<%=PageValue.WebRoot%>upload/coupon.xls"><strong>点击此处下载范例文档</strong></a>
                            <% }%>
                        </td>
                        <%}%>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>