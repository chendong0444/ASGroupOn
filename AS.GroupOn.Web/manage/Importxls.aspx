<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_Express_UploadExpressCode))
        {
            SetError("你不具有批量上传快递单的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        Response.Charset = "UTF-8";

        if (Request["action"] == "importexpressnumber")
        {
            bool ok = false;
            string result = Manage_ImportExpressNumber(out ok);
            Response.Write(result);
        }

        // 初始化一大堆变量

    }


    string jsonString(string str)
    {
        str = str.Replace("\\", "\\\\");
        str = str.Replace("/", "\\/");
        str = str.Replace("'", "\\'");
        return str;
    }


    string GetFileExt(string FullPath)
    {
        if (FullPath != "") return FullPath.Substring(FullPath.LastIndexOf('.') + 1).ToLower();
        else return "";
    }

    void CreateFolder(string FolderPath)
    {
        if (!System.IO.Directory.Exists(FolderPath)) System.IO.Directory.CreateDirectory(FolderPath);
    }



    #region 批量导入快递单号
    public static string Manage_ImportExpressNumber(out bool ok)
    {

        ok = false;//倒入结果 true成功 false失败
        string msg = String.Empty;//导入结果提示信息
        //过程
        string filename = null;
        HttpFileCollection files = HttpContext.Current.Request.Files;
        if (files.Count > 0)
        {
            filename = files[0].FileName;//从上传控件上直接取到文件的上传路径  
            string path2 = AppDomain.CurrentDomain.BaseDirectory + DateTime.Now.ToString("yyyyMMddHHmmss") + ".xls";
            WebUtils.LogWrite("xls导入", path2);
            HttpContext.Current.Request.Files[0].SaveAs(path2);//保存文件到web根目录

            //连接字符串
            string strConn = "Provider=Microsoft.Jet.OLEDB.4.0;" + "Data Source=" + path2 + ";" + "Extended Properties=Excel 8.0;";
            OleDbConnection conn = new OleDbConnection(strConn);

            DataSet ds = null;
            try
            {
                conn.Open();
                string strExcel = "";
                OleDbDataAdapter myCommand = null;
                strExcel = "select orderid,expressname,expressnumber from [Sheet1$]";
                // strExcel = "select ID,Username,ordercount,suncount from [Sheet1$]";
                myCommand = new OleDbDataAdapter(strExcel, conn);
                ds = new DataSet();
                myCommand.Fill(ds, "table1");
                DataTable dt = ds.Tables["table1"];
                CategoryFilter filter = new CategoryFilter();
                ICategory category = Store.CreateCategory();
                IOrder order = Store.CreateOrder();
                int j = dt.Rows.Count;
                int cnt;
                if (j > 0)
                {//执行插入数据库动作

                    for (int i = 0; i < j; i++)
                    {
                        string orderid = dt.Rows[i]["orderid"].ToString();
                        string expressname = dt.Rows[i]["expressname"].ToString();//expressname中的快递公司名称取出来通过category表找到对应的expressid 将expressid写入order表中的Express_id中
                        string expressnumber = dt.Rows[i]["expressnumber"].ToString();//快递编号插入order表中的Express_no字段中

                        filter.Zone = "express";
                        filter.Name = expressname;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            category = session.Category.Get(filter);
                        }

                        if (category != null)
                        {
                            order.Express_no = expressnumber;
                            order.Express_id = category.Id;
                            order.Id = Helper.GetInt(orderid, 0);
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                cnt = session.Orders.UpdateUpload(order);
                            }

                            if (cnt == 0)
                            {
                                msg = msg + "<br>订单" + orderid + "更新失败";
                            }
                            else
                            {
                                msg = msg + "<br>订单" + orderid + "更新成功";
                            }
                        }
                    }

                }
                else
                {
                    msg = "Excel中没有数据";
                }
            }
            catch (Exception ex)
            {
                msg = "打开连接失败！";
                HttpContext.Current.Response.Write(ex.Message);
            }
            finally
            {
                conn.Close();

                //删除xls文件
                if (File.Exists(path2))
                {
                    File.Delete(path2);
                }

            }
        }
        else
        {

            msg = "上传文件不存在!";

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
                                <input type="submit" class="formbutton" name="button" id="button" value="提交" class="validator formbutton" /></div>
                        </td>
                    </tr>
                    <tr>
                        <td bgcolor="#FFFFFF">
                            <strong>注：请上传xls文档，暂不支持订单生成快递单号短信提醒。 </strong>
                            <br />
                            <br />
                            <strong>文档列名说明：</strong>
                            <br />
                            orderid：订单编号
                            <br />
                            expressname：自己后台建立快递公司中文名
                            <br />
                            expressnumber ：快递单号
                            <br />
                            <br />
                            <a href="<%=PageValue.WebRoot%>upfile/demo/demo.xls"><strong>点击此处下载范例文档</strong></a>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
