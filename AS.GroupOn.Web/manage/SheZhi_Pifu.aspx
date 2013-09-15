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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Skin))
        {
            SetError("你不具有查看网站皮肤的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request.HttpMethod == "POST")
        {
            TextAdd();
        }
        setText();
    }
    List<string> fileNames = new List<string>();
    string[] filenames;
    /// <summary>
    /// 查找文件目录
    /// </summary>
    /// <returns></returns>
    private string getText()
    {
        string dirPath = HttpContext.Current.Server.MapPath(PageValue.TemplatePath + "theme");
        return dirPath;
    }
    /// <summary>
    /// 通过当前目录去查找他的所有子目录
    /// </summary>
    /// <param name="s"></param>
    /// <returns></returns>
    private List<string> getNextTest(string srcPath)
    {
        List<string> directorys = new List<string>();
        // int fileNum=0;
        // 得到源目录的文件列表，该里面是包含文件以及目录路径的一个数组
        string[] fileList = System.IO.Directory.GetFileSystemEntries(srcPath);
        // 遍历所有的文件和目录
        foreach (string file in fileList)
        {
            // 先当作目录处理如果存在这个目录就重新调用GetFileNum(string srcPath)
            if (System.IO.Directory.Exists(file))
                directorys.Add(file);
        }
        return directorys;
    }
    ISystem system = null;
    /// <summary>
    /// 显示文件夹信息
    /// </summary>
    private void setText()
    {
        fileNames = getNextTest(getText());
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
        }
        if (system.skintheme != null)
        {
            string[] theme = system.skintheme.Split('|');
            Literal1.Text = InitData("tuangou", theme[0]);
            if (theme.Length > 1)
            {
                Literal2.Text = InitData("shangcheng", theme[1]);
            }
            else
            {
                Literal2.Text = InitData("shangcheng", "default");
            }
            if (theme.Length > 2)
            {
                Literal3.Text = InitData("wap", theme[2]);
            }
            else
            {
                Literal3.Text = InitData("wap", "default");
            }
        }
        else
        {
            Literal1.Text = InitData("tuangou", "default");
            Literal2.Text = InitData("shangcheng", "default");
            Literal3.Text = InitData("wap", "default");
        }
    }
    private string InitData(string type, string theme)
    {
        fileNames = getNextTest(getText());
        StringBuilder sb = new StringBuilder();
        if (fileNames!=null)
        {
            sb.Append("<select name='" + type + "' class='f-input' style='width:200px;'>");
            for (int i = 0; i < fileNames.Count; i++)
            {
                string s = fileNames[i];
                string[] s1 = s.Split('\\');
                if (theme == fileNames[i])
                {
                    sb.Append("<option  value='" + s1[s1.Length - 1].ToString() + " ' >" + s1[s1.Length - 1].ToString() + "</option>");
                }
                else
                {
                    if (theme == s1[s1.Length - 1].ToString())
                    {
                        sb.Append("<option  value='" + s1[s1.Length - 1].ToString() + "' selected>" + s1[s1.Length - 1].ToString() + "</option>");
                    }
                    else
                    {
                        sb.Append("<option  value='" + s1[s1.Length - 1].ToString() + "' >" + s1[s1.Length - 1].ToString() + "</option>");
                    }
                }

            }
            if (system.skintheme == String.Empty || system.skintheme == "default")
                sb.Append("<option value='default' selected >默认皮肤</option>");
            else
                sb.Append("<option value='default' >默认皮肤</option>");
            sb.Append("</select> ");
        }
        return sb.ToString();
    }
    /// <summary>
    /// 提交到数据库
    /// </summary>
    private void TextAdd()
    {
        if (!String.IsNullOrEmpty(Helper.GetString(Request.Form["tuangou"], String.Empty)) && !String.IsNullOrEmpty(Helper.GetString(Request.Form["shangcheng"], String.Empty)) && !String.IsNullOrEmpty(Helper.GetString(Request.Form["wap"], String.Empty)))
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                system = session.System.GetByID(1);
                system.skintheme = Request.Form["tuangou"].ToString() + "|" + Request.Form["shangcheng"].ToString() + "|" + Request.Form["wap"].ToString();
                int id = session.System.Update(system);
            }

            SetSuccess("设置成功");
        }
        else
        {
            SetSuccess("设置失败");
        }

      

    }
    
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server" method="post">
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
                                    <h2>
                                        系统皮肤</h2>
                                </div>
                                <div class="sect">
                                <div class="field">
                                    <label>
                                        团购主题切换</label>
                                    <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                </div>
                                <div class="field">
                                    <label>
                                        手机主题切换</label>
                                    <asp:Literal ID="Literal3" runat="server"></asp:Literal>
                                </div>
                                <div class="field">
                                    <label>
                                        商城主题切换</label>
                                    <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                       <label style="color:Red">只适用于米奇模板 </label>
                                </div>
                                <div class="act">
                                    <input type="hidden" name="action" value="textadd" />
                                    <input id="Submit1" type="submit" value="提交" class="formbutton" />
                                </div>
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