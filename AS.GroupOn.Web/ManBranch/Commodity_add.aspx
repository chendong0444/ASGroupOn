<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">

    protected IFareTemplate faretempalte = null;
    protected FareTemplateFilter ftfilter = new FareTemplateFilter();
    protected IList<IFareTemplate> faretemlist = null;
    protected ProductFilter productfilter = new ProductFilter();
    protected IList<IProduct> productlist = null;
    protected IList<ICatalogs> catalogslist = null;
    protected CatalogsFilter catalogsfilter = new CatalogsFilter();
    protected IList<ICategory> categorylist = null;
    protected IList<ICategory> categorylist2 = null;
    protected IList<ICategory> categorylistpinpai = null;
    protected IList<ICategory> categorylistcity = null;
    public bool ispoint = false;//判断如果是积分项目，那么用户选择了优惠券无法进行提交
    protected CategoryFilter categoryfilter = new CategoryFilter();
    protected CategoryFilter categoryfilterapi = new CategoryFilter();
    protected CategoryFilter categoryfilter2 = new CategoryFilter();
    protected CategoryFilter categoryfiltercity = new CategoryFilter();

    protected IProduct productmodel = null;
    protected System.Data.DataTable categorydt = new System.Data.DataTable();
    protected System.Data.DataTable catalogsdt = new System.Data.DataTable();

    public string isDisplay = "";
    public string bulletin = "";
    public string inven = "";
    public string strcitys = "";
    public bool blag;
    protected string state = "0";
    public NameValueCollection _system = null;
    protected int aid = 0;
    ITeam team = AS.GroupOn.App.Store.CreateTeam();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system =AS.Common.Utils.WebUtils.GetSystem();
      

        //分类
        commentscore.Value = _system["userreview_rebate"];
        catalogsfilter.type = 1;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catalogslist = session.Catalogs.GetList(catalogsfilter);
        }
        if (catalogslist.Count>0)
        {
            catalogsdt = AS.Common.Utils.Helper.ToDataTable(catalogslist.ToList());
        }        
        productfilter.Status = 1;
        productfilter.AddSortOrder(ProductFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            productlist = session.Product.GetList(productfilter);
        }

        if (Request["commit"] == "好了，提交")//Request.HttpMethod=="POST"
        {
            addContent();            
            ITeam teamm = null;            
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teamm = session.Teams.GetByID(aid);
            }
            if (teamm.open_invent != 1)
            {
                Response.Redirect("Commoditylist.aspx", true);
            }
        }

        if (!IsPostBack)
        {
            selectContent();
            //产品
            initdorp();
            //项目分类
            this.ddlparent.Items.Add(new ListItem("请选择", "0"));
            BindData(catalogsdt, "0", "", "parent_id", this.ddlparent, "catalogname", "id");
            setcity();
        }
    }

    /// <summary>
    /// 绑定产品列表
    /// </summary>
    protected void initdorp()
    {

        //快递模版
        ftfilter.AddSortOrder(FareTemplateFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            faretemlist = session.FareTemplate.GetList(ftfilter);
        }
        System.Data.DataTable faretemdt = new System.Data.DataTable();
        if (faretemlist.Count>0)
        {
           faretemdt= AS.Common.Utils.Helper.ToDataTable(faretemlist.ToList());
        }        
        for (int i = 0; i < faretemdt.Rows.Count; i++)
        {
            System.Data.DataRow row = faretemdt.Rows[i];
            faretemplate_drop.Items.Add(new ListItem(row["name"].ToString(), row["id"].ToString()));
        }
        //产品列表
        //ddlProduct.Items.Clear();
        ddlProduct.Items.Add(new ListItem("---------", "0"));

        System.Data.DataTable productdt = new System.Data.DataTable();
        if (productlist.Count>0)
        {
            productdt=AS.Common.Utils.Helper.ToDataTable(productlist.ToList());
        }       

        if (productdt != null)
        {
            if (productdt.Rows.Count > 0)
            {
                for (int i = 0; i < productdt.Rows.Count; i++)
                {
                    ddlProduct.Items.Add(new ListItem(productdt.Rows[i]["id"].ToString() + ":" + productdt.Rows[i]["Productname"].ToString(), productdt.Rows[i]["id"].ToString()));
                }
            }
        }
        ddlProduct.DataBind();
    }
    /// <summary>
    /// 绑定下拉框列表
    /// </summary>
    /// <param name="dt"></param>
    /// <param name="id">ID 值 </param>
    /// <param name="blank">是否需要加符号?不加为null</param>
    /// <param name="sqlvalue">筛选为 ID值 的数据</param>
    /// <param name="listName"> 这里是需要绑定的下拉列表控件ID</param>
    private void BindData(System.Data.DataTable dt, string id, string blank, string sqlvalue, DropDownList listName, string name, string value)
    {
        if (dt != null && dt.Rows.Count > 0)
        {
            System.Data.DataView dv = new System.Data.DataView(dt);
            if (sqlvalue != null && sqlvalue != "")
            {
                dv.RowFilter = sqlvalue + "= " + id;
            }

            if (id != "0" && blank != null)
            {
                blank += "|─";
            }
            foreach (System.Data.DataRowView drv in dv)
            {
                listName.Items.Add(new ListItem(blank + "" + drv[name].ToString(), drv[value].ToString()));
                BindData(dt, drv[value].ToString(), blank, sqlvalue, listName, name, value);
            }
        }

    }


    private void selectContent()
    {

        //开启库存费提醒
        ListItem inventory2 = new ListItem();
        inventory2.Text = "否";
        inventory2.Value = "0";
        ListItem inventory1 = new ListItem();
        inventory1.Text = "是";
        inventory1.Value = "1";
        //抽奖短信开启
        ListItem code2 = new ListItem();
        code2.Text = "否";
        code2.Value = "no";
        ListItem code1 = new ListItem();
        code1.Text = "是";
        code1.Value = "yes";

        //开启库存报警
        ListItem inven_war2 = new ListItem();
        inven_war2.Text = "否";
        inven_war2.Value = "0";
        ListItem inven_war1 = new ListItem();
        inven_war1.Text = "是";
        inven_war1.Value = "1";

        if (_system != null)
        {
            if (_system["inventory"] != null)
            {
                if (_system["inventory"] == "1")
                {
                    inventory1.Selected = true;
                }
                else
                {
                    inventory2.Selected = true;
                }
            }
            if (_system["invent_war"] != null)
            {
                if (_system["invent_war"] == "1")
                {
                    inven_war1.Selected = true;
                }
                else
                {
                    inven_war2.Selected = true;
                }
            }
            if (_system["inventmobile"] != null)
            {
                inventmobile.Value = _system["inventmobile"];
            }
        }

        ddlinventory.Items.Add(inventory2);
        ddlinventory.Items.Add(inventory1);


        ddlinven_war.Items.Add(inven_war2);
        ddlinven_war.Items.Add(inven_war1);

        this.ddlinven_war.DataBind();
        this.ddlinventory.DataBind();

        //品牌分类
        categoryfilter.Zone = "brand";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            categorylistpinpai = session.Category.GetList(categoryfilter);
        }
        ddlbrand.Items.Clear();
        this.ddlbrand.Items.Add(new ListItem("====品牌分类====", "0"));
        if (categorylistpinpai.Count>0)
        {
            foreach (ICategory item in categorylistpinpai)
            {
                this.ddlbrand.Items.Add(new ListItem(item.Name, item.Id.ToString()));
            }
        }
        
        //添加商户        
        System.Collections.Generic.IList<IPartner> listPartner = null;
        PartnerFilter partnerFilter = new PartnerFilter();
        partnerFilter.AddSortOrder(PartnerFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listPartner = session.Partners.GetList(partnerFilter);
        }
        shanghu.Items.Clear();
        this.shanghu.Items.Add(new ListItem("===========请选择商户============", "0"));
        if (listPartner.Count>0)
        {
            foreach (IPartner item in listPartner)
            {
                this.shanghu.Items.Add(new ListItem(item.Title, item.Id.ToString()));
            }
        }       

    }

    /// <summary>
    /// 显示目录信息
    /// </summary>
    public void cataloglist()
    {
        BindData(catalogsdt, "0", "", "parent_id", this.ddlparent, "catalogname", "id");
    }

    /// <summary>
    /// 产品列表选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddlProduct_SelectedIndexChanged(object sender, EventArgs e)
    {
        int ip = this.ddlProduct.SelectedIndex;
        string productid = this.ddlProduct.SelectedValue;

        if (productid != "0")
        {
            state = "1";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                productmodel = session.Product.GetByID(AS.Common.Utils.Helper.GetInt(productid,0));
            }

            if (productmodel != null)
            {
                createproduct.Value = productmodel.productname;
                market_price.Value = productmodel.price.ToString();
                #region 项目的颜色或者尺寸
                string[] bulletinteam = productmodel.bulletin.Replace("{", "").Replace("}", "").Split(',');
                if (productmodel.bulletin.Replace("{", "").Replace("}", "") != "")
                {
                    isDisplay = "style='display:none;'";
                }
                for (int i = 0; i < bulletinteam.Length; i++)
                {
                    string txt = bulletinteam[i];

                    if (bulletinteam[i] != "")
                    {


                        if (bulletinteam[i].Split(':')[0] != "" && bulletinteam[i].Split(':')[1] != "")
                        {
                            bulletin += "<tr>";
                            bulletin += "<td>";

                            if (state == "0")
                            {
                                bulletin += "属性：<input class=\"h-input\"  type=\"text\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + ">数值：<input  class=\"h-input\" type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + " >";
                                bulletin += "<input class=\"formbutton\" type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
                            }
                            else
                            {
                                bulletin += "属性：<input class=\"h-input\"  type=\"text\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + " readonly>数值：<input class=\"h-input\"  type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + " readonly>";
                            }
                            bulletin += "</td>";
                            bulletin += "</tr>";

                        }
                    }
                }
                #endregion

                ddlinventory.SelectedValue = productmodel.open_invent.ToString();
                ddlinventory.Enabled = false;
                createdetail.Value = productmodel.detail;

                ImageSet.InnerText = productmodel.imgurl;
                inven = productmodel.inventory.ToString();
                shanghu.SelectedValue = productmodel.partnerid.ToString();
                shanghu.Enabled = false;
                teamPrice.Value = productmodel.team_price.ToString();

                categoryfilter.Zone = "group";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    blag = session.Category.getCount1(productmodel.brand_id);
                }
                //如果产品的品牌已删除，品牌不选中
                if (blag)
                {
                    ddlbrand.SelectedValue = productmodel.brand_id.ToString();
                }
                else
                {
                    ddlbrand.SelectedValue = "0";
                }
            }
        }
        else
        {
            createproduct.Value = "";
            market_price.Value = "1";
            bulletin = "";
            createdetail.Value = "";
            ImageSet.InnerText = "";
            inven = "";
            shanghu.SelectedValue = "0";
            ddlinventory.Enabled = true;
            shanghu.Enabled = true;
            teamPrice.Value = "1";

        }
    }

    private void setcity()
    {
        StringBuilder sb1 = new StringBuilder();

        categoryfilter2.Zone = "city";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            categorylist2 = session.Category.GetList(categoryfilter);
        }
        if (categorylist2.Count>0)
        {
            foreach (ICategory category in categorylist2)
            {
                sb1.Append("<input type='checkbox' name='city_id' value='" + category.Id + "' disabled />&nbsp;" + category.Name + "&nbsp;&nbsp;");
            }
        }
        
        strcitys = sb1.ToString();
    }

    /// <summary>
    /// 显示文件夹信息
    /// </summary>

    public string setUpload()
    {
        string result1 = "~/upload/team/";
        string path = Server.MapPath("~/upload/team/");
        if (!System.IO.Directory.Exists(path))
        {
            System.IO.Directory.CreateDirectory(path);
        }
        result1 = result1 + DateTime.Now.Year + "/";
        path = path + DateTime.Now.Year + "/";
        if (!System.IO.Directory.Exists(path))
            System.IO.Directory.CreateDirectory(path);
        path = path + DateTime.Now.ToString("MMdd");
        if (!System.IO.Directory.Exists(path))
            System.IO.Directory.CreateDirectory(path);
        result1 = result1 + DateTime.Now.ToString("MMdd") + "/";


        return result1;
    }
    /// <summary>
    /// 添加项目
    /// </summary>
    private void addContent()
    {
        string createUpload = "";
       
        team.User_id = AdminPage.AsAdmin.Id;
        team.cataid = AS.Common.Utils.Helper.GetInt(this.ddlparent.SelectedValue, 0);//项目分类的编号
        team.commentscore = AS.Common.Utils.Helper.GetDecimal(commentscore.Value, 0);//评论返利的金额
        int titlelenth = System.Text.Encoding.Default.GetByteCount(title.Value);
        if (titlelenth > 500)
        {
            SetError("项目标题长度不能大于500个字符！");
            Response.Redirect("Commodity_add.aspx");
            Response.End();
            return;
        }

        team.Title = HttpUtility.HtmlEncode(title.Value);
        team.Market_price = Convert.ToDecimal(market_price.Value);
        team.Team_price = Convert.ToDecimal(teamPrice.Value);
        team.Min_number = 1;
        team.Max_number = 0;
        team.Per_number = 1;
        team.brand_id = Convert.ToInt32(this.ddlbrand.SelectedValue);
        team.invent_war = Convert.ToInt32(invent_war.Value);
        team.score = Convert.ToInt32(score.Value);
        team.seotitle = Request["seotitle"];
        team.seokeyword = Request["seokeyword"];
        team.seodescription = Request["seodescription"];
        team.Per_minnumber = Convert.ToInt32(per_minnumber.Value);
        team.shanhu = Convert.ToInt32(Request["shanhu"]);
        team.Reach_time = null;
        team.System = "N";
        team.Begin_time = DateTime.Now;
        team.End_time = DateTime.Now.AddDays(2);
        team.Sort_order = int.Parse(createsort_order.Value);
        team.City_id = AsAdmin.City_id;
        team.start_time = DateTime.Now;
        team.Expire_time = DateTime.Now.AddDays(4);
        team.Reach_time = null;
        team.Close_time = null;
        team.State="none";
        team.Conduser = "Y";
        team.Buyonce="Y";
        team.Team_type = "normal";
        team.codeswitch = "no";
        
        
        if (int.Parse(shanghu.SelectedItem.Value) > 0)
        {
            team.Partner_id = int.Parse(shanghu.SelectedItem.Value);
        }
        else
        {

            team.Partner_id = 0;
        }

        //在项目表中添加sale_id 同时更新到partner表中
        if (Request.Form["xiaoshou"] != null)
        {
            int saleId = int.Parse(Request.Form["xiaoshou"].ToString());
            if (shanghu.SelectedIndex > 0)
            {
                if (saleId > 0)
                {
                    team.sale_id = saleId;

                }
            }
            else
            {
                team.sale_id = 0;
            }
        }
        team.Card = int.Parse(createcard.Value);
        if (createbonus.Value != null && createbonus.Value != "")
        {
            team.Bonus = int.Parse(createbonus.Value);
        }
        else
        {
            team.Bonus = 0;
        }
        team.Product = createproduct.Value;
        if (Image.FileName != null)
        {
            createUpload = setUpload();


        }
        if (Image.FileName != null && Image.FileName != "")
        {
            #region 上传图片

            //判断上传文件的大小
            if (Image.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = Image.FileName;//获取待上传图片的完整路径，包括文件名 
            //string uploadName = InputFile.PostedFile.FileName; 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (Image.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                if (suffix.ToLower() == ".jpg" || suffix.ToLower() == ".png" || suffix.ToLower() == ".gif" || suffix.ToLower() == ".jpeg" || suffix.ToLower() == ".bmp")
                {
                    pictureName = DateTime.Now.Ticks.ToString() + suffix;
                }
                else
                {
                    SetError("图片格式不正确！");
                    Response.Redirect("Commodity_add.aspx");
                    return;
                }

            }
            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(createUpload);
                    if (!System.IO.Directory.Exists(path))
                    {
                        System.IO.Directory.CreateDirectory(path);
                    }
                    Image.PostedFile.SaveAs(path + pictureName);

                    //生成缩略图
                    string strOldUrl = path + pictureName;
                    string strsmallUrl = path + pictureName.Replace(".", "_small.");
                    string midumimgname = path + pictureName.Replace(".", "_medum.");
                    string bigimgname = path + pictureName.Replace(".", "_big.");
                    AS.Common.Utils.ImageHelper.CreateThumbnailNobackcolor(strOldUrl, strsmallUrl, 176, 121);
                    AS.Common.Utils.ImageHelper.CreateThumbnailNobackcolor(strOldUrl, midumimgname, 240, 153);
                    AS.Common.Utils.ImageHelper.CreateThumbnailNobackcolor(strOldUrl, bigimgname, 440, 280);
                    //图片加水印
                    string drawuse = "";
                    string drawimgType = "";
                    AS.Common.Utils.ImageHelper.Mall_DrawImgWord(createUpload + "\\" + pictureName, ref drawuse, ref drawimgType, _system);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            team.Image = createUpload.Replace("~", "") + pictureName;
            #endregion
        }
        else
        {
            if (Request["imget"] != null && Request["imget"].ToString() != String.Empty)
            {
                team.Image = Request["imget"];
            }
            else if (ImageSet.InnerText != "")
            {
                team.Image = ImageSet.InnerText;
            }
        }
        if (team.Image == null || team.Image == "")
        {
            SetError("图片不能为空！");
            Response.Redirect("Commodity_add.aspx");
            Response.End();
        }
        team.Detail = createdetail.Value;
        team.Userreview = "";
        team.Delivery = Request.Form["radio"].ToString();
        team.Credit = 0;
        if (AS.Common.Utils.Helper.GetInt(Request["freighttype"], 0) == 0)
        {
            try
            {
                team.Fare = Convert.ToInt32(createfare.Value);
            }
            catch (Exception)
            {

                SetError("您输入的快递费用格式不正确,请重新输入");
            }
            try
            {
                team.Farefree = int.Parse(createfarefree.Value);
            }
            catch (Exception)
            {

                SetError("您输入的免单数量格式不正确,请重新输入");
            }
            team.cashOnDelivery = AS.Common.Utils.Helper.GetString(ddlCashOnDelivery.SelectedValue, "0");
        }
        else//使用快递模板
        {
            if (faretemplate_drop.SelectedIndex == -1)
            {
                SetError("您没有选择快递模板");
                return;
            }
            else
            {
                team.freighttype = AS.Common.Utils.Helper.GetInt(faretemplate_drop.SelectedValue, 0);
                team.Farefree = AS.Common.Utils.Helper.GetInt(farefree2.Value, 0);
                team.cashOnDelivery = AS.Common.Utils.Helper.GetString(ddlCashOnDelivery.SelectedValue, "0");
            }
        }

        team.Express = createexpress.Value;



        #region 库存和报警设置


        team.open_invent = Convert.ToInt32(this.ddlinventory.SelectedValue);

        team.open_war = Convert.ToInt32(this.ddlinven_war.SelectedValue);

        team.warmobile = Request["inventmobile"];


        #endregion

        team.teamway = expressway.SelectedValue;
        team.cost_price = Convert.ToDecimal(Cost_price.Value);//商户成本价格
        team.teamhost = AS.Common.Utils.Helper.GetInt(Request["hostt"], 0);//首页推荐热销
        // team.teamnew = Utils.Helper.GetInt(Request["teamnew"], 0);//首页新品推荐


        team.drawType = AS.Common.Utils.Helper.GetInt(Request["dtype"], 0);//抽奖方式，0:默认为随机,1按顺序生成

        team.apiopen = AS.Common.Utils.Helper.GetInt(Request["apiopen"], 0);
        //判断状态 

        team.update_value = 0;
        team.time_interval = 0;
        team.time_state = 0;
        //添加颜色或者尺寸

        if (ddlProduct.SelectedValue != "0")
        {
            IProduct promodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                promodel = session.Product.GetByID(int.Parse(ddlProduct.SelectedValue));
            }
            if (promodel != null)
            {
                if (promodel.bulletin == "{}")
                {
                    team.bulletin = "";
                }
                else
                {
                    team.bulletin = promodel.bulletin;
                }
                team.invent_result = promodel.invent_result;

                team.inventory = promodel.inventory;

            }
        }
        else
        {
            team.bulletin = addcolor();
        }
        team.productid = int.Parse(ddlProduct.SelectedValue);


        if (team.productid != 0 && team.bulletin != "" && team.Delivery != "express")
        {

            SetError("友情提示：该项目的产品有规格只能选择快递的递送方式");
            return;
        }

        team.isrefund = "N";
        team.teamcata = 1;

        if (ispoint && team.teamscore > 0)
        {
            SetSuccess("友情提示：积分项目无法选择优惠券");
        }
        else
        {          
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                aid = session.Teams.Insert(team);
            }
            if (aid > 0)
            {
                if (AS.Common.Utils.Helper.GetInt(team.open_invent, 0) == 1)//开启库存
                {
                    if (team.productid == 0)
                    {
                       
                        //Response.Redirect("Commoditylist.aspx");
                    }
                    else
                    {
                        SetSuccess("友情提示：添加项目成功");
                    }
                }
                else
                {
                    SetSuccess("友情提示：添加项目成功");
                }

            }

        }
    }

    #region 添加颜色或者尺寸
    public string addcolor()
    {
        string str = "";
        try
        {
            if (Request["totalNumber"] != null && Request["totalNumber"] != "")
            {
                int num = Convert.ToInt32(Request["totalNumber"]);
                str += "{";
                for (int i = 0; i < Convert.ToInt32(Request["totalNumber"]); i++)
                {
                    if (Request["StuName" + i] != null && Request["Stuvalue" + i] != null && Request["StuName" + i].ToString() != "" && Request["Stuvalue" + i].ToString() != "")
                    {
                        str += Request["StuName" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(".", "").Replace(",", "") + ":";
                        str += "[";
                        str += Request["Stuvalue" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(".", "").Replace(",", "");
                        str += "]";
                        str += ",";
                    }
                }
                str += "}";
            }
        }
        catch (Exception ex)
        {
            SetError("友情提示：项目格式不正确");
        }
        return str;
    }
    #endregion
    
    
</script>
<%LoadUserControl("_header.ascx", null); %>
<%if (AS.Common.Utils.Helper.GetInt(team.open_invent, 0) == 1 && team.productid == 0)
  {%>
<script language='javascript'>
    if (!confirm('友情提示：已开启库存功能，是否进行出入库操作！')) { location.href = 'Commoditylist.aspx' } else { X.get('/manage/ajax_coupon.aspx?action=invent&p=d&inventid=<%=team.Id %>') }</script>
  <%}%>
<script type="text/javascript" language="javascript">
    function setTimeTxt(obj) {
        var type = obj.value;
        if (type == "seconds" || type == "normal") {

            var begin = document.getElementById("begintime").value + " 00:00:00";
            var end = document.getElementById("endtime").value + " 00:00:00";
            if (begin.length > 19) {
                begin = begin.substring(0, 19);
            }
            if (end.length > 19) {
                end = end.substring(0, 19);
            }
            document.getElementById("begintime").value = begin;
            document.getElementById("endtime").value = end;
            jQuery("#begintime").attr("datatype", "datetime");
            jQuery("#endtime").attr("datatype", "datetime");

        }
        else {

            var begin = document.getElementById("begintime").value;
            var end = document.getElementById("endtime").value;
            if (begin.length > 10) {

                begin = begin.substring(0, 10);
            }
            document.getElementById("begintime").value = begin;

            if (end.length > 10) {
                end = end.substring(0, 10);
            }

            document.getElementById("endtime").value = end;
            jQuery("#begintime").attr("datatype", "date");
            jQuery("#endtime").attr("datatype", "date");
        }
        ischange(obj);
    }




    function show(mydiv) {
        var str = "img" + mydiv;
        alert(str);

        var obj = document.getElementById("img0");
        alert(obj.value);
    }


    var num = 0;

    function upload() {
        document.getElementById("status").innerHTML = "文件上传中...";
        multiUploadForm.submit();
    }


    function additem(id) {
        var row, cell, str;
        row = document.getElementById(id).insertRow(-1);
        if (row != null) {
            cell = row.insertCell(-1);
            cell.innerHTML = "属性：<input class=\"h-input\"  type=\"text\" name=\"StuName" + num + "\">数值：<input class=\"h-input\"  type=\"text\" name=\"Stuvalue" + num + "\"><input  class=\"formbutton\" type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
        }
        num++
        document.getElementsByName("totalNumber")[0].value = num;
    }
    function deleteitem(obj, id) {
        var rowNum, curRow;
        curRow = obj.parentNode.parentNode;
        rowNum = document.getElementById(id).rows.length - 1;
        document.getElementById(id).deleteRow(curRow.rowIndex);
    }
    function callback(msg) {
        document.getElementById("status").innerHTML = "文件上传完成...<br>" + msg;
    }

    function getkey(obj) {

        if (obj.value != 0) {
            $.ajax({
                type: "POST",
                url: webroot + "ajax_key.aspx?key=" + obj.value + "",

                success: function (msg) {
                    if (msg != "") {
                        $("#aa").html(msg);
                    }

                }
            });
        } else {
            $("#key").html("");
        }


    }

    function checkallcity() {
        var str = $("#cityall").attr('checked');

        if (str) {

            $('[name=city_id]').attr('checked', true);
        }
        else {

            $('[name=city_id]').attr('checked', false);
        }

    }
       
</script>
<script type="text/javascript">
    $(document).ready(function () {
        var str = jQuery("#shanghu").val();
        if (str != "" & str != "0") {
            $("#saleceng").show();
            $.ajax({
                type: "POST",
                url: "manage_ajax_getsales.aspx",
                data: { "partnerid": str },
                success: function (msg) {

                    $("#all_Sales").html(msg);

                }
            });
        }
        else {
            $("#saleceng").hide();
        }

        jQuery("#shanghu").change(function () {
            var str = jQuery("#shanghu").val();
            if (str != "" & str != "0") {
                $("#saleceng").show();
                $.ajax({
                    type: "POST",
                    url: "manage_ajax_getsales.aspx",
                    data: { "partnerid": str },
                    success: function (msg) {

                        $("#all_Sales").html(msg);

                    }
                });
            }
            else {
                $("#saleceng").hide();
            }
        });

    })
</script>
<script type="text/javascript">
    $(function () {
        function split(val) {
            return val.split(/,\s*/);
        }
        function extractLast(term) {
            return split(term).pop();
        }
        $("#pernumber").blur(function () {

            var minnum = $("#per_minnumber").val();
            var pernum = $("#pernumber").val();
            if (parseInt(pernum) < parseInt(minnum) && parseInt(pernum) != 0) {

                $("#pernumber").attr("class", "number errorInput");
            }

        });

        $("#birds")
			.bind("keydown", function (event) {
			    if (event.keyCode === $.ui.keyCode.TAB &&
						$(this).data("autocomplete").menu.active) {
			        event.preventDefault();
			    }
			})
			.autocomplete({

			    source: function (request, response) {
			        $.getJSON(webroot + "ajax_key.aspx?key=" + $("#birds").val(), {
			            term: extractLast(request.term)
			        }, response);
			    },


			    search: function () {
			        var term = extractLast(this.value);
			        if (term.length < 1) {
			            return false;
			        }
			    },
			    focus: function () {
			        return false;
			    },
			    select: function (event, ui) {
			        var terms = split(this.value);
			        terms.pop();
			        terms.push(ui.item.value);
			        terms.push("");
			        this.value = terms.join(", ");
			        return false;
			    }
			});
    });
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
                                    <h2>
                                        新建项目</h2>
                                </div>
                                <div class="sect">
                                    <div class="wholetip clear">
                                        <h3>
                                            1、基本信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            产品</label>
                                        <input type="hidden" name="action" value="addscontent" />
                                        <asp:DropDownList ID="ddlProduct" name="ddlProduct" runat="server" class="f-input"
                                            Style="width: 360px;" AutoPostBack="True" OnSelectedIndexChanged="ddlProduct_SelectedIndexChanged">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="field" id="dparent">
                                        <label>
                                            项目分类</label>
                                        <asp:DropDownList ID="ddlparent" runat="server"  style="width: 160px;" class="f-input">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="field" id="dbrand">
                                        <label>
                                            品牌分类</label>
                                        <asp:DropDownList ID="ddlbrand" name="ddlbrand" class="f-input" runat="server" Style="width: 160px;">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="field" id="dhost">
                                        <label>
                                            首页推荐</label>
                                        <select id="hostt" name="hostt" style="width: 160px;" class="f-input">
                                            <option value="0">请选择</option>
                                            <option value="1">新品上架</option>
                                            <option value="2">热销产品</option>
                                             <option value="3">推荐商品</option>
                                              <option value="4">低价促销</option>
                                        </select>
                                        <span class="hint" id="SPAN5">仅一日多团4和一日多团5可用</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            项目标题</label>
                                        <input type="text" size="100" name="title" id="title" class="f-input" group="g" require="true"
                                            datatype="require" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            SEO标题</label>
                                        <input type="text" size="30" name="seotitle" id="seotitle" maxlength="250" class="f-input"
                                            group="g" /><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            SEO关键字</label>
                                        <input type="text" size="30" name="seokeyword" id="seokeyword" maxlength="250" class="f-input"
                                            group="g" /><span class="inputtip"></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            SEO描述</label>
                                        <input type="text" size="30" name="seodescription" maxlength="1000" id="seodescription"
                                            class="f-input" group="g" /><span class="inputtip"></span>
                                    </div>
                                    <%if (state == "0")
                                      { %>
                                    <div class="field">
                                        <label>
                                            项目规格</label>
                                        <input type="button" class="formbutton" name="btnAddFile" value="添加" onClick="additem('tb')" /><font
                                            style='color: red; margin-left:10px;'>例如：属性填写：颜色 数值填写：红色|黄色|蓝色</font>
                                    </div>
                                    <%} %>
                                    <div class="field">
                                        <label>
                                        </label>
                                        <table id="tb">
                                            <%=bulletin%>
                                        </table>
                                        <input type="hidden" name="totalNumber" value="" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            市场价</label>
                                        <input type="text" size="10" name="market_price" id="market_price" class="number"
                                            value="1" datatype="money" group="g" require="true" runat="server" />
                                        <div id="price">
                                            <label>
                                                商城价</label>
                                            <input type="text" size="10" name="team_price" id="teamPrice" class="number" value="1"
                                                group="g" datatype="double" require="true" runat="server" />
                                        </div>
                                        <label>
                                            最低购买数量</label>
                                        <input type="text" size="10" name="per_minnumber" id="per_minnumber" class="number"
                                            value="1" maxlength="6" group="g" datatype="number" require="true" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            成本价</label>
                                        <input type="text" name="Cost_price" id="Cost_price" group="g" datatype="money" class="date"
                                            value="0" runat="server" />
                                        <span class="hint" id="SPAN6" runat="server">用于商户结算</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            排序</label>
                                        <input type="text" size="10" name="sort_order" id="createsort_order" class="number"
                                            value="0" group="g" datatype="number" runat="server" /><span class="inputtip">请填写数字，数值大到小排序，主推团购应设置较大值</span>
                                    </div>
                                    <div class="field" id="fscore">
                                        <label>
                                            返利积分值</label>
                                        <input type="text" size="10" name="score" id="score" class="number" value="0" group="g"
                                            datatype="number" runat="server" /><span class="inputtip">积分值</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            2、库存信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            启用库存</label>
                                        <asp:DropDownList ID="ddlinventory" Style="float: left; width:50px" class="h-input"  runat="server">
                                        </asp:DropDownList>
                                        <span class="inputtip">是否开启库存功能</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            启用库存报警</label>
                                        <asp:DropDownList ID="ddlinven_war" Style="float: left; width:50px" class="h-input"  runat="server">
                                        </asp:DropDownList>
                                        <span class="inputtip">是否开启库存报警功能</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            库存报警电话</label>
                                        <input id="inventmobile" type="text" class="number" name="inventmobile" value="0"
                                            runat="server" datatype="money" group="go" />
                                        <span class="inputtip">当库存报警是，系统会自动给库存报警电话，发送短信信息</span>
                                    </div>
                                    <%if (inven != "")
                                      { %>
                                    <div class="field">
                                        <label>
                                            库存数量</label>
                                        <span class="inputtip">
                                            <%=inven%></span>
                                    </div>
                                    <%} %>
                                    <div class="field">
                                        <label>
                                            报警数量</label>
                                        <input type="text" size="10" name="invent_war" id="invent_war" class="number" value="0"
                                            group="g" datatype="number" runat="server" /><span class="inputtip">请填写数字，库存报警数量</span>
                                    </div>
                                    <!--xxk-->
                                    <%--<input type="hidden" name="guarantee" value="Y" id="Hidden1" runat="server" />
                                    <input type="hidden" name="system" value="Y" id="Hidden2" runat="server" />--%>
                                    <div class="wholetip clear">
                                        <h3>
                                            3、项目信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户</label><div>
                                                <asp:DropDownList ID="shanghu" runat="server"  style="float: left; width:30%" class="f-input" >
                                                </asp:DropDownList>
                                            </div>
                                        <span class="inputtip">商户为可选项</span>
                                    </div>
                                    <div class="field" id="saleceng" style="display: none;">
                                        <label>
                                            销售人员</label><div id="all_Sales">
                                            </div>
                                        <span class="inputtip">销售人员为可选项</span>
                                    </div>
                                    <div class="field" id="field_card">
                                        <label>
                                            代金券使用</label>
                                        <input type="text" size="10" name="card" id="createcard" class="number" value="0"
                                            group="g" require="true" datatype="money" runat="server" />
                                        <span class="inputtip">可使用代金券最大面额</span>
                                    </div>
                                    <div class="field" id="Div1">
                                        <label>
                                            邀请返利</label>
                                        <input type="text" size="10" name="bonus" id="createbonus" class="number" require="true"
                                            datatype="number" runat="server" />
                                        <span class="inputtip">邀请好友参与本单商品购买时的返利金额</span>
                                    </div>
                                    <div class="field" id="Div3">
                                        <label>
                                            评论返利</label>
                                        <input type="text" size="10" name="commentscore" id="commentscore" class="number"
                                            require="true" datatype="money" runat="server" value="" />
                                        <span class="inputtip">评论之后的返利金额</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商品名称</label>
                                        <input type="text"  style="float: left; width:49%" name="product" id="createproduct" class="f-input" group="g"
                                            datatype="require" require="true" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            商品图片</label>
                                        <asp:FileUpload ID="Image" name="Image" class="f-input"  style="float: left; width:50%"
                                            runat="server" />
                                        <span class="hint">至少得上传一张商品图片</span>&nbsp;
                                        <label id="ImageSet" class="hint" runat="server">
                                        </label>
                                    </div>
                                    <div id="img0" class="field">
                                        <label>
                                            引用其他图片</label>
                                        <input type="text" style="float: left; width:49%" name="imget" id="imget" class="f-input" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            本单详情</label>
                                        <div style="float: left;">
                                            <textarea cols="45" style="height: 500px;" rows="5" name="detail" id="createdetail"
                                                class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1&t=1',urlType:'abs'}"
                                                runat="server"></textarea></div>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            4、配送信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            递送方式</label>
                                        <div style="margin-top: 5px;">
                                            <div id="express" class="daoru">
                                                <input id="zonediv2" type="radio" name="radio" value="express" checked="checked" />快递</div>
                                        </div>
                                    </div>
                                    <div id="express_zone_express">
                                        <div class="field" id="Div2">
                                            <label>
                                                结算方式</label>
                                            <asp:DropDownList ID="expressway" runat="server" class="f-input" Style="width: 280px;">
                                                <asp:ListItem Value="S" Selected="True">按实际发货数量(已填写快递单号的订单)</asp:ListItem>
                                                <asp:ListItem Value="Y">按实际购买数量</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                        <div class="field_xm">
                                            <label>
                                                <input name="freighttype" id="freighttype0" type="radio" checked="checked" value="0"
                                                    onclick="return freighttype0_onclick()">填写快递费</label>
                                            <label>
                                                <input name="freighttype" id="freighttype1" type="radio" value="1" onClick="return freighttype1_onclick()">使用快递模板(<a
                                                    href='fare_template.aspx'>编辑快递模板</a>)</label>
                                        </div>
                                        <div class="field" id="type1" style="display: none;">
                                            <label>
                                                快递费模板</label>
                                            <asp:DropDownList ID="faretemplate_drop" Style="float: left;" runat="server">
                                            </asp:DropDownList>
                                            <label>
                                                免单数量</label>
                                            <input type="text" size="10" id="farefree2" class="number" value="0" maxlength="6"
                                                datatype="money" require="true" runat="server" />
                                            <span class="hint">快递费用，免单数量：0表示不免运费，2表示，购买2件免运费</span>
                                        </div>
                                        <div class="field" id="type0">
                                            <label>
                                                快递费用</label>
                                            <input type="text" size="10" name="fare" id="createfare" class="number" value="5"
                                                maxlength="6" datatype="money" require="true" runat="server" />
                                            <label>
                                                免单数量</label>
                                            <input type="text" size="10" name="farefree" id="createfarefree" class="number" value="0"
                                                maxlength="6" datatype="money" runat="server" />
                                            <span class="hint">快递费用，免单数量：0表示不免运费，2表示，购买2件免运费</span>
                                        </div>
                                        <div class="field" id="expressmemo" style="display: none;">
                                            <label>
                                                快递配送说明</label>
                                            <div>
                                                <textarea cols="45" rows="5" name="express" id="createexpress" class="f-textarea"
                                                    runat="server"></textarea></div>
                                        </div>
                                        <div>
                                            <asp:HiddenField ID="HiddenField1" runat="server" />
                                        </div>
                                        <div class="field">
                                            <label>
                                                货到付款接口</label>
                                            <asp:DropDownList ID="ddlCashOnDelivery" Style="float: left; width: 80px;" class="f-input" runat="server">
                                                <asp:ListItem Value="0">关闭</asp:ListItem>
                                                <asp:ListItem Value="1">开启</asp:ListItem>
                                            </asp:DropDownList>
                                            <span class="inputtip">只有开启本功能的项目才支持货到付款</span>
                                        </div>
                                    </div>
                                    <div class="act">
                                        <input id="leadesubmit" name="commit" type="submit" value="好了，提交" group="g" class="formbutton validator" onclick="return leadesubmit_onclick()"  />
                                        <script>
                                            function leadesubmit_onclick() {
                                                if ($("#ImageSet").html().trim() == "" && $("#Image").val().trim() == "") {
                                                    alert("请上传商品图片");
                                                    return false;
                                                }

                                            }
                                            $(function () {
                                                $("form").submit(function () {
                                                    if ($("#ImageSet").html().trim() == "" && $("#Image").val().trim() == "" && $("#Text1").val().trim() == "") {
                                                        alert("请上传商品图片");
                                                        return false;
                                                    }
                                                });
                                            });
                                            function freighttype1_onclick() {
                                                $("#type1").show();
                                                $("#type0").hide();

                                            }

                                            function freighttype0_onclick() {
                                                $("#type1").hide();
                                                $("#type0").show();
                                            }
                                        </script>
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
