<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    
    protected IMailtasks imailtasks = null;
    protected IList<ICategory> iListCategory = null;
    protected string mail = "";
    List<string> fileNames = new List<string>();
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        
        if (Request["updateId"] != null && Request["updateId"].ToString() != "")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_EmailMany_Edit))
            {
                SetError("你不具有编辑群发邮件的权限！");
                Response.Redirect("MailtasksList.aspx");
                Response.End();
                return;
            }
            else
            {
                GetMail(Helper.GetInt(Request["updateId"], 0));
            }
        }
        else
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_EmailMany_Add))
            {
                SetError("你不具有新建群发邮件的权限！");
                Response.Redirect("MailtasksList.aspx");
                Response.End();
                return;
            }
        }
        setText();
        GetCityList();
    }

    /// <summary>
    /// 邮件模板
    /// </summary>
    private void setText()
    {
        fileNames = getNextTest(getText());
        StringBuilder sb = new StringBuilder();

        if (fileNames != null)
        {
            sb.Append("<select name='theme' style='width:150px;'>");
            for (int i = 0; i < fileNames.Count; i++)
            {
                string s = fileNames[i];
                string[] s1 = s.Split('\\');
                sb.Append("<option  value='" + s1[s1.Length - 1].ToString() + " ' >" + s1[s1.Length - 1].ToString() + "</option>");
            }
            sb.Append("</select>");
            mail = sb.ToString();
        }
    }
    private string getText()
    {
        string dirPath = HttpContext.Current.Server.MapPath("~/MailTemplate");
        return dirPath;
    }
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
            //if (System.IO.Directory.Exists(file))
            directorys.Add(file);
        }
        return directorys;
    }
    /// <summary>
    /// 获取城市列表
    /// </summary>
    protected void GetCityList()
    {
        CategoryFilter filter = new CategoryFilter();
        filter.Zone = "city";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCategory = session.Category.GetList(filter);
        }
    }

    /// <summary>
    /// 根据编号查询内容
    /// </summary>
    /// <param name="id"></param>
    public void GetMail(int id)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            imailtasks = session.Mailtasks.GetByID(id);
        }
    }
</script>

<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    function checkallcity() {
        var str = $("[name=cityall]").attr('checked');

        if (str) {
            $('[name=SeCity]').attr('disabled', true);
            $('[name=SeCity]').attr('checked', false);
        }
        else {

            $('[name=SeCity]').attr('disabled', false);
        }

    }
</script>
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
                                    <%if (imailtasks != null)
                                      {
                                    %>
                                    <h2>
                                        编辑群发邮件 </h2>
                                    <%}
                                      else
                                      {
                                    %>
                                    <h2>
                                        新增群发邮件 </h2>
                                    <%}%>
                                    <ul class="filter">
                                        <li></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <div class="wholetip clear">
                                    </div>
                                    <%if (imailtasks != null)
                                      {
                                    %>
                                        <div class="tong_box1" style="width:960px;">
                                        <p style="font-size: 14px; padding: 15px;">
                                            发送形式A：发送本团购网站的项目进行营销</p>
                                        <div class="field">
                                            <label>
                                                邮件标题</label>
                                            <input type="text" size="30" name="subject" id="Text1" class="f-input" value="<%=imailtasks.subject %>" require="true" datatype="require"><span class="inputtip"></span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                邮件模板</label>
                                            <%=mail%>
                                        </div>
                                        <div class="field">
                                            <label>
                                                城市Id</label>
                                            
                                         

                                            <div style="float: left; width: 628px;">
                                            <%if (Helper.isEmpity(imailtasks.cityid))
                                                {%>
                                                <input  type="checkbox" name="cityall" value="0" checked="checked" onClick="checkallcity()" />全部城市
                                            <%}
                                                else
                                                {%>
                                                <input  type="checkbox" name="cityall" value="0"  onclick="checkallcity()"/>全部城市
                                               
                                            <%}%>
                             
                                               <%foreach (ICategory model in iListCategory)
                                                 {
                                                    if (imailtasks.cityid.Contains(model.Id.ToString()))
                                                    {
                                                        if (Helper.isEmpity(imailtasks.cityid))
                                                        {%>
                                 
                                                        <input  type="checkbox" name="SeCity" value="<%=model.Id %>"  checked=checked disabled=disabled /><%=model.Name%>
                                                    <%}
                                                        else
                                                        { %>
                                                        <input  type="checkbox" name="SeCity" value="<%=model.Id %>"  checked=checked /><%=model.Name%>
                                                    <%}
                                                    }
                                                    else
                                                    {
                                                        if (Helper.isEmpity(imailtasks.cityid))
                                                        { %>
                                                        <input  type="checkbox" name="SeCity" value="<%=model.Id %>"  disabled=disabled /><%=model.Name%>
                                                    <%}
                                                        else
                                                        { %>
                                                        <input  type="checkbox" name="SeCity" value="<%=model.Id %>"  /><%=model.Name%>
                                                    <%}
                                                    }
                                                     
                                                 }%>
                                               </div>

                                        

                                            <span class="inputtip"></span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                包含未开始项目</label>
                                            <input type="checkbox" name="nostartteam" value="1" />
                                        </div>
                                    </div>
                                        <div id="tong_box2" class="tong_box2" style="width:960px;">
                                            <p style="font-size: 14px; padding: 15px;">
                                                发送形式B：发送自己的邮件页面进行营销（请填写url地址，这里填写后A方式将失效）</p>
                                            <div class="field">
                                                <label>
                                                    邮件地址</label>
                                                <div>
                                                    <input type="text" size="30" name="url" id="Text2" value="" />
                                                    <select name="gbk">
                                                        <option value="utf-8">utf-8</option>
                                                        <option value="gb2312">gb2312</option>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="act">
                                            <input type='hidden' name='id' value='<%=imailtasks.id %>' />
                                            <input type='hidden' name='action' value='updatemailtasks' />
                                            <input id="Submit2" type="submit" value="保存" name="commit" class="validator formbutton" />
                                        </div>
                                    <%}
                                      else
                                      {
                                    %>
                                        <div class="tong_box1" style="width:960px;">
                                        <p style="font-size: 14px; padding: 15px;">
                                            发送形式A：发送本团购网站的项目进行营销</p>
                                        <div class="field">
                                            <label>
                                                邮件标题</label>
                                            <input type="text" size="30" name="subject" id="subject" class="f-input" value="" require="true" datatype="require"><span class="inputtip"></span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                邮件模板</label>
                                            <%=mail%>
                                        </div>
                                        <div class="field">
                                            <label>
                                                城市Id</label>
                                            
                                            <!--****************************************************-->

                                            <div style="float: left; width: 628px;">
                                            <%if (Request["id"] != null)
                                              {
                                                  if (Helper.isEmpity(imailtasks.cityid))
                                                  {%>
                                                    <input  type="checkbox" name="cityall" value="0" checked="checked" onClick="checkallcity()" />全部城市
                                                <%}
                                                  else
                                                  {%>
                                                   <input  type="checkbox" name="cityall" value="0"  onclick="checkallcity()"/>全部城市
                                                <%} 
                                              }
                                              else
                                              {%>
                                                   <input  type="checkbox" name="cityall" value="0"  checked=checked   onclick="checkallcity()"/>全部城市
                                            <%}%>
                             
                                               <%foreach (ICategory model in iListCategory)
                                                 {
                                                     if (Request["id"] != null)
                                                     {
                                                         if (imailtasks.cityid.Contains(model.Id.ToString()))
                                                         {
                                                             if (Helper.isEmpity(imailtasks.cityid))
                                                             {%>
                                 
                                                                <input  type="checkbox" name="SeCity" value="<%=model.Id %>"  checked=checked disabled=disabled /><%=model.Name%>
                                                           <%}
                                                             else
                                                             { %>
                                                                <input  type="checkbox" name="SeCity" value="<%=model.Id %>"  checked=checked /><%=model.Name%>
                                                           <%}
                                                         }
                                                         else
                                                         {
                                                             if (Helper.isEmpity(imailtasks.cityid))
                                                             { %>
                                                                <input  type="checkbox" name="SeCity" value="<%=model.Id %>"  disabled=disabled /><%=model.Name%>
                                                           <%}
                                                             else
                                                             { %>
                                                                <input  type="checkbox" name="SeCity" value="<%=model.Id %>"  /><%=model.Name%>
                                                           <%}
                                                         }
                                                     }
                                                     else
                                                     {%>
                                                        <input  type="checkbox" name="SeCity" value="<%=model.Id %>"  disabled=disabled /><%=model.Name%>
                                                  <% }
                                                 }%>
                                               </div>

                                            <!--****************************************************-->

                                            <span class="inputtip"></span>
                                        </div>
                                        <div class="field">
                                            <label>
                                                包含未开始项目</label>
                                            <input type="checkbox" name="nostartteam" value="1" />
                                        </div>
                                    </div>
                                        <div id="tong_box2" class="tong_box1" style="width:960px;">
                                            <p style="font-size: 14px; padding: 15px;">
                                                发送形式B：发送自己的邮件页面进行营销（请填写url地址，这里填写后A方式将失效）</p>
                                            <div class="field">
                                                <label>
                                                    邮件地址</label>
                                                <div>
                                                    <input type="text" size="30" name="url" id="url" value="" />
                                                    <select name="gbk">
                                                        <option value="utf-8">utf-8</option>
                                                        <option value="gb2312">gb2312</option>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="act">
                                        <%--<input type="hidden" name="content" value="<%=strContent %>" />
                                        <input type="hidden" name="cityid" value="<%=strCityid %>" />--%>
                                        <input type='hidden' name='action' value='addmailtasks' />
                                        <input id="Submit1" type="submit" value="保存" name="commit" class="validator formbutton" />
                                    </div>
                                    <%}%>
                                    
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>