<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>
<%@ Import  Namespace="AS.GroupOn.Controls" %>
<%@ Import  Namespace="System.IO" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Xml" %>
<script runat="server">
    protected string installInfo = String.Empty;
    protected bool showbutton = true;
    protected override void OnLoad(EventArgs e)
    {
        string folter = Server.MapPath(AS.GroupOn.Controls.PageValue.WebRoot + "db/");
        string installfile = folter + "install.ok";
        string sqlfile = folter + "db.sql";
        if (System.IO.File.Exists(installfile))
        {
            Response.Write("请先使用FTP删除掉db目录下的install.ok文件在进行安装");
            Response.End();
            return;
        }

        installInfo = "1.请确保站点目录有来宾账号的读取权限，users组账号的修改权限";
        string directpath = Server.MapPath(AS.GroupOn.Controls.PageValue.WebRoot + "testdirect/");
        string filepath = Server.MapPath(AS.GroupOn.Controls.PageValue.WebRoot + "testfile.txt");
        try
        {
            if (System.IO.Directory.Exists(directpath))
            {
                System.IO.Directory.Delete(directpath);
            }
            System.IO.Directory.CreateDirectory(directpath);
            System.IO.Directory.Delete(directpath);
            System.IO.File.WriteAllText(filepath, "test");
            System.IO.File.Delete(filepath);
            installInfo = installInfo + "<br>";
        }
        catch
        {
            installInfo = installInfo + "<span style='color:#FF0000;'>失败,没有权限</span><br>";
            showbutton = false;
        }
        if (Page.IsPostBack)
        {

            string host = Request["host"];
            string user = Request["user"];
            string pass = Request["pass"];
            string name = Request["name"];
            string root = Request.Form["rpath"];//根目录
            //if(root.LastIndexOf)
            if (host == String.Empty || user == String.Empty || pass == String.Empty || name == String.Empty || root == String.Empty)
            {
                SetError("您输入的信息不完整，请重试");
                return;
            }
            AS.Common.Utils.WebUtils webUtils = new AS.Common.Utils.WebUtils();
            NameValueCollection values = new NameValueCollection();
            values.Add("rootpath", root);
            webUtils.CreateSystemByNameCollection(values);
            bool ok = true;
            string connstr = String.Format("server={0};database={1};uid={2};pwd={3}", host, name, user, pass);
            using (SqlConnection conn = new SqlConnection(connstr))
            {
                string err = String.Empty;
                try
                {
                    err = "数据库连接失败";
                    conn.Open();
                    err = "当前数据库用户没有权限创建表";
                    SqlCommand cmd = new SqlCommand("IF EXISTS (SELECT name FROM sysobjects WHERE name = 'a' AND type = 'U')DROP table a;create table a(id int not null default 0);drop table a;", conn);
                    cmd.ExecuteNonQuery();
                    err = "数据库配置文件读取失败，可能没有读取权限。请确认database.config拥有users组的修改权限";
                    XmlDocument xmldoc = new XmlDocument();
                    xmldoc.Load(Server.MapPath(PageValue.WebRoot + "bin/mybatis/mssql/DataMap.config"));
                    XmlNode node = xmldoc.SelectSingleNode("//propertys/property[@key='masterSqlserver']");
                    if (node != null)
                    {
                        node.Attributes["value"].Value = connstr;
                        xmldoc.Save(Server.MapPath(PageValue.WebRoot + "bin/mybatis/mssql/DataMap.config"));
                    }
                    else
                    {
                        SetError("安装错误");
                        return;
                    }
                    err = "数据库安装文件读取失败";
                    string sql = File.ReadAllText(sqlfile, System.Text.Encoding.UTF8);
                    string[] split = new string[] { "\r\n;" };
                    string[] s = sql.Split(split, StringSplitOptions.RemoveEmptyEntries);
                    err = "数据库安装失败";
                    for (int i = 0; i < s.Length; i++)
                    {
                        cmd = new SqlCommand(s[i], conn);
                        sql = s[i];
                        cmd.ExecuteNonQuery();
                    }
                    File.WriteAllText(installfile, "删除此文件就能安装啦");
                    string okfile = Server.MapPath(PageValue.WebRoot + "db/installok.ok");
                    File.WriteAllText(okfile, "ok");
                    File.Delete(okfile);
                }
                catch (Exception ex)
                {
                    ok = false;
                    SetError(err + "<br>" + ex.Message);
                }
                finally
                {
                    conn.Close();
                }
            }
            if (!ok)
            {
                return;
            }
            string domain = Request.Url.ToString().Replace(Request.FilePath.ToString(), "");
            AS.Common.Utils.FileUtils.SetConfig("domain", domain);
            //站点 权限
            if (domain.Substring(domain.Length - 1, 1) == "/")
            {
                domain = domain.Substring(0, domain.Length - 1);
            }
            AS.Common.Utils.WebUtils.CheckRecord(AS.GroupOn.UrlRewrite.HttpModule.GetRecord(domain));
            Response.Redirect("index.aspx");
            Response.End();
            return;
        }
    }

    public void SetError(string errtext)
    {
        installInfo = errtext;
    }    
    
    
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>艾尚团购程序商业版程序安装</title>
    <link rel="stylesheet" href="template/default/theme/default/css/index.css" type="text/css" media="screen"
        charset="utf-8" />
</head>
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="partner">
                    <div id="content" class="clear mainwide">
                        <div class="clear box">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        安装信息</h2>
                                </div>
                                <div class="sect">
                                    <%=installInfo %>
                                </div>
                                <input type="hidden" name="id" value="100027" />
                                <div class="wholetip clear">
                                    <h3>
                                        1、数据库信息</h3>
                                </div>
                                <div class="field">
                                    <label>
                                        主机名</label>
                                    <input type="text" size="30" require="true" datatype="require" name="host" group="install"
                                        id="partner-create-username" class="f-input" value="localhost" />
                                </div>
                                <div class="field">
                                    <label>
                                        用户名</label>
                                    <input type="text" size="30" name="user" require="true" datatype="require" group="install"
                                        id="settings-password" class="f-input" value="" />
                                </div>
                                <div class="field password">
                                    <label>
                                        密码</label>
                                    <input type="text" size="30" name="pass" require="true" datatype="require" group="install"
                                        id="settings-password" class="f-input" value="" />
                                </div>
                                <div class="field password">
                                    <label>
                                        数据库名</label>
                                    <input type="text" size="30" name="name" require="true" datatype="require" group="install"
                                        id="settings-password-confirm" class="f-input" value="" />
                                </div>
                                <div class="field password">
                                    <label>
                                        网站根目录</label>
                                    <input type="text" size="30" name="rpath" require="true" datatype="require" group="install"
                                        id="rpath" class="f-input" value="/" />
                                </div>
                                   <div class="field">
                                    <label>&nbsp;
                                        </label>
                                   (<span style=" color:Red;"><strong>一般默认即可，如果修改注意末位要加"/", 二级目录如："/tuan/"</strong></span>)
                                    </div>
                                <div class="act">
                                    <%if (showbutton)
                                      { %><input type="submit" value="安装" group="install" name="commit"
                                        id="partner-submit validator" class="formbutton" /><%} %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="sidebar">
                </div>
            </div>
        </div>
        <!-- bd end -->
    </div>
    <!-- bdw end -->
    </form>
</body>
</html>


