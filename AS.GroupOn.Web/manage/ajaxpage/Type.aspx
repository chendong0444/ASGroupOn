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
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected string zone = String.Empty;
    protected string cid = String.Empty;
    protected string pid = String.Empty;
    protected string brandimg = String.Empty;
    public string message = "";
    public string str = string.Empty;
    protected override void OnLoad(EventArgs e)
    {
        cid = Helper.GetString(Request["id"], String.Empty);
        zone = Helper.GetString(Request["zone"], String.Empty);
        pid = Helper.GetString(Request["add"], String.Empty);
        if (Request.HttpMethod != "POST")
        {
            if (Request["Zone"] != null)
            {
                if (zone == "city")
                {
                    bindcityGroup("");
                }
                if (zone == "citygroup")
                {

                }
                bian.Visible = false;
                mingcheng.InnerText = setMing(Request["Zone"].ToString());
                this.hid.Value = pid;
            }
            if (Request["update"] != null)
            {
                xin.Visible = false;
                setValue(int.Parse(Request["update"].ToString()));
            }

        }
        else
        {
            if (Request.Form["button"] == "确定")
            {
                if (this.BrandImageSet.InnerText != "")
                {
                    brandimg = this.BrandImageSet.InnerText;
                }
                if (Request["update"] != null)
                {
                    xin.Visible = false;
                    //setValue(int.Parse(Request["update"].ToString()));
                }
                if (Request["zone"] != null)
                {
                    if (zone == "city")
                    {
                        bindcityGroup("");
                    }
                    bian.Visible = false;
                    mingcheng.InnerText = setMing(Request["zone"].ToString());

                    str = this.hid.Value;
                }
                if (cid == "")
                {
                    IList<ICategory> catelis = null;
                    CategoryFilter catefil = new CategoryFilter();
                    catefil.Name = name.Value;
                    catefil.Ename = ename.Value;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        catelis = session.Category.GetList(catefil);
                    }
                    if (catelis.Count == 0 || zone == "citygroup")
                    {
                        insertValue();
                    }
                    else
                    {
                        SetError("不能添加重复数据！");
                    }
                }
                else
                {
                    updateValue();
                }
                Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                Response.End();
                return;

            }
        }
    }


    private void bindcityGroup(string strgroupid)
    {
        ddlcitygroup.InnerHtml = "<select class='f-input' id='ddlCzone' name='ddlCzone'>";
        ddlcitygroup.InnerHtml += "<option value='0'>选择分组</option>";
        IList<ICategory> ilistcate = null;
        CategoryFilter filter = new CategoryFilter();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistcate = session.Category.SelsectByzd(filter);
        }
        if (ilistcate != null)
        {
            foreach (ICategory cate in ilistcate)
            {
                if (strgroupid != "" && strgroupid == cate.Id.ToString())
                {
                    ddlcitygroup.InnerHtml += "<option value='" + cate.Id.ToString() + "' selected='selected'>" + cate.Name.ToString() + "</option>";
                }
                else
                {
                    ddlcitygroup.InnerHtml += "<option value='" + cate.Id.ToString() + "'>" + cate.Name.ToString() + "</option>";
                }
            }
        }
    }

    private string setMing(string name)
    {
        string title = "";
        if (name == "public")
        {
            title = "讨论区分类";
        }
        else if (name == "city")
        {
            if (Request["update"] != null)
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_City_Edit))
                {
                    SetError("你不具编辑城市的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                }
                else
                {
                    title = "城市分类";
                }
            }
            else
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_City_Add))
                {
                    SetError("你不具有新建城市的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                }
                else
                {
                    title = "城市分类";
                }
            }
        }
        else if (name == "citygroup")
        {
            if (Request["update"] != null)
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_CityGroup_Edit))
                {
                    SetError("你不具编辑城市分组的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                }
                else
                {
                    title = "城市分组";
                }
            }
            else
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_CityGroup_Add))
                {
                    SetError("你不具有新建城市分组的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                }
                else
                {
                    title = "城市分组";
                }
            }
        }
        else if (name == "express")
        {
            if (Request["update"] != null)
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_ExpressCompany_Edit))
                {
                    SetError("你不具编辑快递公司的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                }
                else
                {
                    title = "快递公司分类";
                    message += "<tr>";

                    message += "<td  colspan='2'><font style='color:red'>注：此处英文名称，必须按照此处<a href='" + PageValue.WebRoot + "manage/help.htm' target=_blank>【快递公司代码】</a>标准，对应填写相应英文名称，否则不能进行快递单实时查询位置。如：圆通速递 对应英文名称为：yuantong</font>";
                    message += "</td>";

                    message += "</tr>";
                }
            }
            else
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_ExpressCompany_Add))
                {
                    SetError("你不具有新建快递公司的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                }
                else
                {
                    title = "快递公司分类";
                    message += "<tr>";

                    message += "<td  colspan='2'><font style='color:red'>注：此处英文名称，必须按照此处<a href='" + PageValue.WebRoot + "manage/help.htm' target=_blank>【快递公司代码】</a>标准，对应填写相应英文名称，否则不能进行快递单实时查询位置。如：圆通速递 对应英文名称为：yuantong</font>";
                    message += "</td>";

                    message += "</tr>";
                }
            }
        }
        else if (name == "partner")
        {
            if (Request["update"] != null)
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Partner_Edit))
                {
                    SetError("你不具编辑商户分类的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                }
                else
                {
                    title = "商户分类";
                }
            }
            else
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Partner_Add))
                {
                    SetError("你不具有新建商户分类的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();

                }
                else
                {
                    title = "商户分类";
                }
            }
        }
        else if (name == "brand")
        {
            if (Request["update"] != null)
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Brand_Edit))
                {
                    SetError("你不具编辑品牌的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                }
                else
                {
                    title = "品牌分类";
                }
            }
            else
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Brand_Add))
                {
                    SetError("你不具有新建品牌的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();

                }
                else
                {
                    title = "品牌分类";
                }
            }
        }

        //else if (name == "group")
        //{
        //    title = "API分类";
        //}
        //else if (name == "grade")
        //{
        //    title = "用户等级分类";
        //}
        zone = name;
        return title;
    }
    private void setValue(int id)
    {
        IList<ICategory> icate = null;
        CategoryFilter filter = new CategoryFilter();
        filter.Id = id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            icate = session.Category.GetList(filter);
        }
        foreach (ICategory item in icate)
        {
            name.Value = item.Name;
            ename.Value = item.Ename;
            letter.Value = item.Letter;
            brandimg = item.content;
            if (brandimg != string.Empty && brandimg != "")
            {
                this.hidden.Value = brandimg;
            }
            if (item.Display == "N")
            {
                display.Value = "";
                display.Value = "N";
            }
            else
            {
                display.Value = "";
                display.Value = "Y";
            }


            sort_order.Value = item.Sort_order.ToString();
            cid = item.Id.ToString();
            if (item.Zone == "city")
            {
                bindcityGroup(item.Czone);

            }
            else
            {
                czone.Value = item.Czone;
            }
            zone = item.Zone;
        }

    }
    private void updateValue()
    {
        ICategory cate = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            cate = session.Category.GetByID(int.Parse(cid));
        }
        cate.Name = name.Value;
        cate.Ename = ename.Value;
        if (letter.Value != String.Empty)
            cate.Letter = letter.Value.ToUpper();
        else
            cate.Letter = "N";
        //cate.Letter = letter.Value;
        if (zone == "city")
        {
            cate.Czone = Request.Form["ddlCzone"].ToString();
        }
        else
        {
            cate.Czone = czone.Value;
        }
        cate.Zone = zone;
        cate.Display = display.Value.ToUpper();
        cate.Sort_order = int.Parse(sort_order.Value);
        #region 上传图片
        if (FileUpload1.FileName != null && FileUpload1.FileName.ToString() != "")
        {
            //判断上传文件的大小
            if (FileUpload1.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的品牌图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = FileUpload1.FileName;//获取待上传图片的完整路径，包括文件名 
            string ext = System.IO.Path.GetExtension(uploadName).ToLower();
            if (ext != ".jpg" && ext != ".bmp" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
            {
                //SetError("上传的图片不合法");
                Response.Redirect(Request.RawUrl);
                Response.End();
                return;
            }
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (FileUpload1.FileName != "")
            {

                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 
                pictureName = DateTime.Now.Ticks.ToString() + 1 + suffix;
            }
            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(PageValue.WebRoot + "upload/user/");
                    if (!Directory.Exists(path))
                    {
                        Directory.CreateDirectory(path);

                    }
                    FileUpload1.PostedFile.SaveAs(path + pictureName);

                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }

            pictureName = PageValue.WebRoot + "upload/user/" + pictureName;
            cate.content = pictureName;
        }
        else
        {
            cate.content = this.hidden.Value;
        }
        #endregion
        int i = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            i = session.Category.Update(cate);

        }
        if (i > 0)
        {
            SetSuccess("更新成功！！");
        }
    }
    private void insertValue()
    {
        ICategory cate1 = Store.CreateCategory();
        cate1.Name = name.Value;
        cate1.Ename = ename.Value;
        if (letter.Value != String.Empty)
            cate1.Letter = letter.Value.ToUpper();
        else
            cate1.Letter = "N";

        if (this.hid.Value != null && Helper.GetInt(this.hid.Value, 0) > 0)
        {
            cate1.City_pid = Helper.GetInt(this.hid.Value, 0);
        }
        if (zone == "city")
        {
            cate1.Czone = Request.Form["ddlCzone"].ToString();
        }
        else
        {
            cate1.Czone = czone.Value;
        }
        if (this.hid.Value != String.Empty)
        {
            cate1.City_pid = Convert.ToInt32(this.hid.Value);
        }
        else
        {
            cate1.City_pid = 0;
        }
        cate1.Zone = zone;
        cate1.Display = display.Value.ToUpper();
        cate1.Sort_order = int.Parse(sort_order.Value);
        //开始上传上传图片
        #region 上传图片
        if (FileUpload1.FileName != null && FileUpload1.FileName.ToString() != "")
        {


            //判断上传文件的大小
            if (FileUpload1.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的品牌图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = FileUpload1.FileName;//获取待上传图片的完整路径，包括文件名 
            string ext = System.IO.Path.GetExtension(uploadName).ToLower();
            if (ext != ".jpg" && ext != ".bmp" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
            {
                SetError("上传的图片不合法");
                Response.Redirect(Request.RawUrl);
                Response.End();
                return;
            }
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (FileUpload1.FileName != "")
            {

                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 
                pictureName = DateTime.Now.Ticks.ToString() + 1 + suffix;
            }
            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(PageValue.WebRoot + "upload/user/");
                    if (!Directory.Exists(path))
                    {
                        Directory.CreateDirectory(path);

                    }
                    FileUpload1.PostedFile.SaveAs(path + pictureName);

                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }

            pictureName = PageValue.WebRoot + "upload/user/" + pictureName;
            cate1.content = pictureName;
        }
        else
        {
            if (brandimg != "" && brandimg != string.Empty)
            {
                cate1.content = brandimg;
            }
            else
            {
                cate1.content = "";
            }

        }
        #endregion
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int i = session.Category.Insert(cate1);
            if (i > 0)
            {
                SetSuccess("添加成功！");
            }
        }

    }


</script>
<form id="Form1" runat="server">
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">&nbsp;&nbsp;关闭</span><span
            id="bian" style="float: left; text-indent: 5px;" runat="server">编辑</span><span id="xin"
                style="float: left; text-indent: 5px;" runat="server">新建</span><span id="mingcheng"
                    style="float: left; text-indent: 5px;" runat="server"></span></h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <p>
            中文名称<%if (zone != "citygroup")
                  { %>、英文名称<%} %>：均要求分类唯一性</p>
        <asp:hiddenfield runat="server" id="hid"></asp:hiddenfield>
        <table width="96%" class="coupons-table-xq">
            <tr>
                <td width="80" nowrap>
                    <b>中文名称：</b>
                </td>
                <td>
                    <input group="city" type="text" name="name" id="name" require="true" datatype="require"
                        class="f-input" runat="server" />
                </td>
            </tr>
            <%if (zone != "citygroup")
              { %>
            <tr>
                <td nowrap>
                    <b>英文名称：</b>
                </td>
                <td>
                    <input type="text" group="city" name="ename" id="ename" require="true" datatype="english"
                        class="f-input" style="text-transform: lowercase;" runat="server" />
                </td>
            </tr>
            <%} %>
            <%=message%>
            <%if (zone != "citygroup")
              { %>
            <tr>
                <td nowrap>
                    <b>首字母：</b>
                </td>
                <td>
                    <input type="text" group="city" name="letter" id="letter" maxlength="1" require="true"
                        datatype="english" class="f-input" style="text-transform: uppercase;" runat="server" />
                </td>
            </tr>
            <%} %>
            <%if (zone == "city")
              { %>
            <tr>
                <td nowrap>
                    <b>选择分组：</b>
                </td>
                <td>
                    <label id="ddlcitygroup" runat="server">
                    </label>
                </td>
            </tr>
            <%}
              else
              { %>
            <%if (zone != "citygroup")
              { %>
            <tr>
                <td nowrap>
                    <b>自定义分组：</b>
                </td>
                <td>
                    <input type="text" group="city" name="czone" id="czone" class="f-input" runat="server" />
                </td>
            </tr>
            <%} %>
            <%} %>
            <tr>
                <td nowrap>
                    <b>导航显示(Y/N)：</b>
                </td>
                <td>
                    <input type="text" group="city" name="display" maxlength="1" datatype="english" id="display"
                        class="f-input" style="text-transform: uppercase;" runat="server" />
                </td>
            </tr>
            <tr>
                <td nowrap>
                    <b>排序(降序)：</b>
                </td>
                <td>
                    <input type="text" group="city" name="sort_order" id="sort_order" require="true"
                        datatype="number" value="0" class="f-input" runat="server" />
                </td>
            </tr>
            <%if (zone == "brand")
              {%>
            <tr>
                <td nowrap>
                    <b>品牌图片：</b>
                </td>
                <td>
                    <div id="Div1" runat="server">
                        <asp:fileupload id="FileUpload1" runat="server" height="29px" width="200px" />
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <input type="hidden" id="hidden" name="hidden" runat="server" value="" />
                    <lable name="BrandImageSet" id="BrandImageSet" runat="server" class="hint"><%=brandimg%></lable>
                </td>
            </tr>
            <%} %>
            <tr>
                <td colspan="2" height="10">
                    <input id="zone" type="hidden" name="zone" value="<%=zone %>" />
                    <input id="cid" type="hidden" name="id" value="<%=cid%>" />
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <input type="submit" name="button" id="button" group="city" class="validator formbutton"
                        action="<%=PageValue.WebRoot%>manage/ajaxpage/Type.aspx" value="确定" />
                </td>
            </tr>
        </table>
    </div>
</div>
</form>
<script type="text/javascript">
    window.x_init_hook_validator();
</script>
