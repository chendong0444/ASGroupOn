<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>
<script runat="server">

    protected int CategoryValue;
    protected ICategory categoryModel = null;
    protected CategoryFilter categoryft = new CategoryFilter();

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (Request.HttpMethod == "POST" && Request.Form["hiddenValue"] != null && Request.Form["hiddenValue"].ToString() != "")
        {            
            updateCategory(Convert.ToInt32(Request.Form["hiddenValue"].ToString()));
        }
        if (Request.QueryString["Id"] != null && Request.QueryString["Id"].ToString() != "")
        {
            selectCategoryView(Convert.ToInt32(Request.QueryString["Id"].ToString()));
        }
    }

    protected ICategory selectCategoryView(int categoryId)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            categoryModel = session.Category.GetByID(categoryId);
        }
        if (categoryModel == null)
        {
            Response.Redirect("Type_Chengshi.aspx");
            Response.End();
        }
        this.hiddenValue.Value = categoryModel.Id.ToString();
        creatnotice.Value = categoryModel.content;
        return categoryModel;
    }

    protected void updateCategory(int categoryId)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            categoryModel = session.Category.GetByID(categoryId);
        }
        if (Request.Form["creatnotice"] != null)
        {
            categoryModel.content = Request.Form["creatnotice"].ToString();
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int id = session.Category.Update(categoryModel);
        }
        SetSuccess("友情提示,修改成功!");
        Response.Redirect("Type_Chengshi.aspx");
        Response.End();

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
                <div id="system">
                    <div id="content" class="box-content clear mainwide">
                        <div class="clear box">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        <%=categoryModel.Name %>城市公告
                                    </h2>
                                </div>
                                <div class="sect">
                                    <input type="hidden" name="id" value="1" />
                                    <div class="field">
                                        <div style="float: left;">
                                            <textarea cols="45" rows="5" name="notice" id="creatnotice" class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"
                                                runat="server"></textarea></div>
                                        <input id="hiddenValue" name="hiddenValue"  type="hidden" runat="server" />
                                        <div class="act">
                                            <input  type="submit" value="保存" name="commit" id="system-submit"
                                                class="formbutton" />
                                        </div>
                                    </div>
                                    <!--</form>-->
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