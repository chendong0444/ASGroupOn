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
    
    protected string nowday = "";
    //protected string strnewstype = "";
    protected string strcontent = "";
    protected INews inews = null;
    protected int strAdminId = 0;
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        nowday = DateTime.Now.ToString("yyyy-MM-dd");
        
        if (Request["updateId"] != null && Request["updateId"].ToString() != "")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_News_Edit))
            {
                SetError("你不具有编辑新闻公告的权限！");
                Response.Redirect("NewList.aspx");
                Response.End();
                return;
            }
            else
            {
                Update();
            }
        }
        else
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_News_Add))
            {
                SetError("你不具有新建新闻公告的权限！");
                Response.Redirect("NewList.aspx");
                Response.End();
                return;
            }
            if (!string.IsNullOrEmpty(PageValue.CurrentAdmin.ToString()))
            {
                strAdminId = PageValue.CurrentAdmin.Id;
            }
            else
            {
                SetError("没有检索到您的登录");
                Response.Redirect("Login.aspx");
            }
        }
    }

    /// <summary>
    /// 修改
    /// </summary>
    protected void Update()
    {
        int strid = Helper.GetInt(Request["updateId"], 0);
        if (strid > 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                inews = session.News.GetByID(strid);

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
                                    <h2>添加新闻公告</h2>
                                    <ul class="filter">
                                        <li></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <%
                                        if (inews != null)
                                        {
                                    %>
                                    <div class="field">
                                        <label>
                                            类型</label>
                                        <select name="newstype">
                                            <option value="0" <%if(inews.type == 0){%> selected="selected" <%} %>>团购 </option>
                                            <option value="1" <%if(inews.type == 1){%> selected="selected" <%} %>>商城 </option>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>
                                            标题</label>
                                        <input type="text" size="30" name="title" id="title" class="f-input" size="15" value="<%=inews.title %>"
                                            require="true" datatype="require" style="width:700px;"><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            内容</label>
                                        <textarea cols="45" rows="5" name="newscontent" id="newscontent" class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1'}"  ><%=inews.content %></textarea>
                                        <span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            新闻外链地址</label>
                                        <input type="text" class="f-input" size="30" name="newsurl" id="newsurl" value="<%=inews.link %>" style="width:700px;" />
                                        <label>
                                        </label>
                                        <span class="inputtip" style=" width:74%; text-align:center;">填写详细的新闻外链地址。如果这里填写，前台新闻点击后，直接跳转到填写的新闻页面。</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            SEO标题</label>
                                        <input type="text" size="30" name="seotitle" id="seotitle" class="f-input" size="15"
                                            value="<%=inews.seotitle %>" group="g" style="width:700px;" /><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            SEO关键字</label>
                                        <input type="text" size="30" name="seokeyword" id="seokeyword" class="f-input" size="15"
                                            value="<%=inews.seokeyword %>" group="g"  style="width:700px;"/><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            SEO描述</label>
                                        <input type="text" size="30" name="seodescription" id="seodescription" class="f-input"
                                            size="15" value="<%=inews.seodescription %>" group="g"  style="width:700px;"/><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            发布时间</label>
                                        <input type="text" name="createtime" class="h-input" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});"
                                         datatype="date" value="<%=inews.create_time.ToString("yyyy-MM-dd") %>"  group="g"/><span class="inputtip"></span>
                                    </div>
                                    <input type='hidden' name='upadminid' value='<%=inews.adminid %>' />
                                    <input type='hidden' name='id' value='<%=inews.id %>' />
                                   
                                    <input type='hidden' name='action' value='updatenews' />
                                    <%
                                        }
                                    else
                                    {
                                    %>
                                    <div class="field">
                                        <label>
                                            类型</label>
                                        <select name="newstype">
                                            <option value="0" <%if(Request["newstype"] == "0"){%> selected="selected" <%} %>>团购
                                            </option>
                                            <option value="1" <%if(Request["newstype"] == "1"){%> selected="selected" <%} %>>商城
                                            </option>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>
                                            标题</label>
                                        <input type="text" size="30" name="title" id="title" class="f-input" size="15" value=""
                                            group="g" require="true" datatype="require"  style="width:700px;"><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            内容</label>
                                        <textarea cols="45" rows="5" name="content" class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1'}"></textarea>
                                        <span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            新闻外链地址</label>
                                        <input type="text" class="f-input" size="30" name="newsurl" id="Text2" value=""  style="width:700px;" />
                                        <label>
                                        </label>
                                        <span class="inputtip"  style=" width:74%; text-align:center;">填写详细的新闻外链地址。如果这里填写，前台新闻点击后，直接跳转到填写的新闻页面。</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            SEO标题</label>
                                        <input type="text" size="30" name="seotitle" id="Text3" class="f-input" size="15"
                                            value="" group="g"  style="width:700px;" /><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            SEO关键字</label>
                                        <input type="text" size="30" name="seokeyword" id="Text4" class="f-input" size="15"
                                            value="" group="g"  style="width:700px;" /><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            SEO描述</label>
                                        <input type="text" size="30" name="seodescription" id="Text5" class="f-input" size="15"
                                            value="" group="g" style="width:700px;" /><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            发布时间</label>
                                        <input type="text" name="createtime" class="h-input" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});"
                                            datatype="date" value="<%=nowday %>"  group="g"/><span class="inputtip"></span>
                                    </div>
                                    <input type='hidden' name='adminid' value="<%=strAdminId %>" />
                                    <input type='hidden' name='action' value='addnews' />
                                    <%
                                        }
                                    %>
                                    <div class="act">
                                        
                                        <input id="Submit1" type="submit" value="保存" name="commit" class="validator formbutton"
                                            group="g" />
                                    </div>
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