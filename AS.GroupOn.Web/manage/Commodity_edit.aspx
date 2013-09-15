<%@ Page Language="C#" Debug="true" EnableEventValidation="false" ViewStateEncryptionMode="Never"
    AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">

    protected string headYes = "";
    protected int headSum = 0;
    protected int update_value;
    protected int Autolimit;
    protected int time_state;
    protected int team_id;

    public NameValueCollection nvc = new NameValueCollection();
    public NameValueCollection _system = null;
    //public SystemConfig sysmodel = new SystemConfig();
    public TeamFilter teamft = new TeamFilter();
    public PartnerFilter partnerft = new PartnerFilter();
    public IPartner mpartner = null;
    public ICatalogs catalogsmodel = null;
    public CatalogsFilter catalogft = new CatalogsFilter();
    public CategoryFilter categoryft = new CategoryFilter();
    public string cata = "";
    public bool ispoint = false;//判断如果是积分项目，那么用户选择了优惠券无法进行提交
    public string strcitys = "";
    public string comment = "0";//评论返利金额
    public ProductFilter productft = new ProductFilter();
    public string bulletin = "";
    public string inven = "";
    protected static int i = 0;//用于记录项目分类默认选择项
    public int invenStatus = 0;//表示是否显示项目规格的添加，只有在项目选择产品了，编辑项目信息时，不能再对规格信息修改。
    protected IProduct productm = null;
    protected ITeam team = null;
    protected ISystem system = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_MallTeam_Edit))
        {
            SetError("你不具有编辑商城项目的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        _system = WebUtils.GetSystem();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
        }
       
        //第一次提及,赋初值
        if (!IsPostBack)
        {

            if (!string.IsNullOrEmpty(Request.QueryString["id"]))
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    team = session.Teams.GetByID(Convert.ToInt32(Request.QueryString["id"]));
                }
                team_id = team.Id;
                HiddenField1.Value = team.Id.ToString();
                initdorp(); //初始化模板选择框
                selectContent();
                cataloglist();//初始化项目分类
                if (Helper.GetDecimal(team.commentscore, 0) > 0)
                {
                    commentscore.Value = GetMoney(team.commentscore.ToString());
                }
                if (team.productid != 0)
                {
                    invenStatus = 1;
                    ddlinventory.Enabled = false;
                    ddlProduct.Disabled = true;
                }
                else
                {
                    ddlProduct.Disabled = true;
                }

                #region 项目的颜色或者尺寸
                string[] bulletinteam = team.bulletin.Replace("{", "").Replace("}", "").Split(',');
                for (int i = 0; i < bulletinteam.Length; i++)
                {
                    string txt = bulletinteam[i];

                    if (bulletinteam[i] != "")
                    {


                        if (bulletinteam[i].Split(':')[0] != "" && bulletinteam[i].Split(':')[1] != "")
                        {
                            bulletin += "<tr>";
                            bulletin += "<td>";

                            if (invenStatus == 0)
                            {
                                bulletin += "属性：<input class=\"h-input\" type=\"text\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + ">数值：<input style=\"width:500px\" class=\"h-input\" type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + " >";
                                bulletin += "<input  class=\"formbutton\" type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
                            }
                            else
                            {
                                bulletin += "属性：<input class=\"h-input\" type=\"text\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + " readonly>数值：<input style=\"width:500px\" class=\"h-input\" type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + " readonly>";
                            }
                            bulletin += "</td>";
                            bulletin += "</tr>";

                        }
                    }
                }
                #endregion

                //关键字
                //birds.Value = team.catakey;
                //首页推荐
                if (team.teamhost < 5 && team.teamhost > -1)
                {
                    hostt.SelectedIndex = team.teamhost;
                }
                //项目标题
                title.Value = team.Title;
                //seo标题
                seotitle.Value = team.seotitle;
                //seo关键字
                seokeyword.Value = team.seokeyword;
                //seo描述
                seodescription.Value = team.seodescription;
                //商户

                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mpartner = session.Partners.GetByID(team.Partner_id);
                }
                if (mpartner != null)
                {
                    shanghu.Value = team.Partner_id.ToString() + ":" + mpartner.Title;
                    shanghuid.Value = team.Partner_id.ToString();
                }
                else
                {
                    shanghu.Value = "";
                    shanghuid.Value = "0";
                }
                //市场价
                market_price.Value = team.Market_price.ToString();
                //商城价
                teamPrice.Value = team.Team_price.ToString();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    productm = session.Product.GetByID(team.productid);
                }
                if (productm != null)
                {
                    if (!String.IsNullOrEmpty(productm.invent_result) && productm.invent_result.Contains("价格"))
                    {
                        string[] bullteam = productm.invent_result.Replace("{", "").Replace("}", "").Split('|');
                        string money = bullteam[0].Substring(0, bullteam[0].LastIndexOf(','));
                        money = money.Substring(money.LastIndexOf(','), money.Length - money.LastIndexOf(',')).Replace(",", "").Replace("价格", "").Replace(":", "").Replace("[", "").Replace("]", "");
                        teamPrice.Value = money;
                        teamPrice.Disabled = true;

                    }
                }
                //最低购买数量
                //////////////////////////////
                per_minnumber.Value = team.Per_minnumber.ToString();
                //成本价
                Cost_price.Value = team.cost_price.ToString();
                //排序
                createsort_order.Value = team.Sort_order.ToString();
                //返利积分值
                score.Value = team.score.ToString();
                //启用库存
                ddlinventory.SelectedIndex = team.open_invent;
                //启用库存报警
                ddlinven_war.SelectedIndex = team.open_war;
                //库存报警电话
                inventmobile.Value = team.warmobile;
                //库存数量
                inven = team.inventory.ToString();
                //报警数量
                invent_war.Value = team.invent_war.ToString();

                //销售人员
                //代金券使用
                createcard.Value = team.Card.ToString();
                //邀请返利
                createbonus.Value = GetMoney(team.Bonus.ToString());
                //商品名称
                createproduct.Value = team.Product;

                //商品图片
                ImageSet.InnerText = team.Image;
                // //商城分类图片
                //// lblImg1.InnerText = team.Image1;
                //本单详情
                createdetail.Value = team.Detail;

                //递送方式  默认选中

                //结算方式
                if (team.teamway == "Y")
                {
                    expressway.Items[1].Selected = true;
                }
                else
                {
                    expressway.Items[0].Selected = true;
                }

                //填写快递费还是使用快递模板
                //选的是填写快递费
                if (team.freighttype == 0)
                {
                    freighttype0.Checked = true;
                    //快递费用
                    createfare.Value = team.Fare.ToString();
                    //免单数量
                    createfarefree.Value = team.Farefree.ToString();
                }
                //选的是使用快递模板
                else
                {
                    freighttype1.Checked = true;
                    //弹出层                    
                    if (team.freighttype != 0)
                    {
                        faretemplate_drop.SelectedValue = team.freighttype.ToString();
                    }
                    //免单数量
                    farefree2.Value = team.Farefree.ToString();
                    createfarefree.Value = "0";
                    createfare.Value = team.Fare.ToString();//createfare.Value="0";
                }
                //快递配送说明
                createexpress.Value = team.Express;
                ddlCashOnDelivery.SelectedValue = Helper.GetString(team.cashOnDelivery, "0");


                //初始化
                if (team != null)
                {
                    if (team.Manualupdate == 1)
                    {
                        headYes = "checked=\"checked\"";
                        headSum = team.Now_number;
                    }
                    else
                    {
                        headYes = "";
                        headSum = team.Now_number;
                    }
                }
                update_value = team.update_value;
                Autolimit = team.autolimit;
                time_state = team.time_state;
            }

        }
        if (Request["commit"] == "好了，提交")//Request.HttpMethod=="POST"
        {                //更新
            addContent();
            Response.Redirect("Commoditylist.aspx", true);
        }
        ddlProduct.Attributes.Add("onchange", Page.GetPostBackEventReference(ddlProduct));
    }


    #region 显示目录信息
    public void cataloglist()
    {
        catalogft.type = 1;
        DataTable dt = null;
        IList<ICatalogs> list = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            list = session.Catalogs.GetList(catalogft);
        }
        dt = AS.Common.Utils.Helper.ToDataTable(list.ToList());
        BindData(dt, 0, "");
    }
    #endregion
    private void BindData(DataTable dt, int id, string blank)
    {
        ITeam team = null;
        ICatalogs catalog = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            team = session.Teams.GetByID(Convert.ToInt32(Request["id"]));
            catalog = session.Catalogs.GetByID(team.cataid);
        }
        if (dt != null && dt.Rows.Count > 0)
        {
            DataView dv = new DataView(dt);
            dv.RowFilter = "parent_id = " + id.ToString();

            if (id != 0)
            {
                blank += "|─";
            }
            foreach (DataRowView drv in dv)
            {
                if (catalog != null)
                {
                    if (catalog.catalogname == drv["catalogname"].ToString())
                    {
                        cata += " <option selected=\"true\" value=" + drv["id"] + ">" + blank + "" + drv["catalogname"].ToString() + "</option>";
                    }
                    else
                    {
                        cata += " <option value=" + drv["id"] + ">" + blank + "" + drv["catalogname"].ToString() + "</option>";
                    }
                }
                else
                {
                    cata += " <option value=" + drv["id"] + ">" + blank + "" + drv["catalogname"].ToString() + "</option>";
                }
                BindData(dt, Convert.ToInt32(drv["id"]), blank);
            }
        }

    }

    protected void initdorp()
    {
        DataTable droptable = new DataTable();
        IList<IFareTemplate> farelist = null;
        FareTemplateFilter fareplateft = new FareTemplateFilter();
        fareplateft.AddSortOrder(FareTemplateFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            farelist = session.FareTemplate.GetList(fareplateft);
        }
        if (farelist.Count > 0)
        {
            droptable = AS.Common.Utils.Helper.ToDataTable(farelist.ToList());
        }
        for (int i = 0; i < droptable.Rows.Count; i++)
        {
            DataRow row = droptable.Rows[i];
            faretemplate_drop.Items.Add(new ListItem(row["name"].ToString(), row["id"].ToString()));
        }

        //初始化时绑定产品，默认选中
        ITeam team = null;
        IProduct product = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            team = session.Teams.GetByID(Convert.ToInt32(Request.QueryString["id"]));
            product = session.Product.GetByID(team.productid);
        }
        if (product != null)
        {
            ddlProduct.Value = product.id.ToString() + ":" + product.productname;
            prohidden.Value = product.id.ToString();
        }
        else
        {
            prohidden.Value = "0";
        }

    }
    public string GetMoney(object price)
    {
        string money = String.Empty;
        if (price != null)
        {
            Regex regex = new Regex(@"^(\d+)$|^(\d+.[1-9])0$|^(\d+).00$");

            Match match = regex.Match(price.ToString());
            if (match.Success)
            {
                money = regex.Replace(match.Value, "$1$2$3");
            }
            else
            {
                money = price.ToString();
                if (money.IndexOf(".00") > 0)
                {
                    money = money.Substring(0, money.IndexOf(".00"));
                }
            }
        }
        return money;
    }

    ListItem teamType = null;
    private void selectContent()
    {
        //开启库存费提醒
        ListItem inventory2 = new ListItem();
        inventory2.Text = "否";
        inventory2.Value = "0";
        ListItem inventory1 = new ListItem();
        inventory1.Text = "是";
        inventory1.Value = "1";


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
        //添加分类
        ListItem pinpai = new ListItem();
        pinpai.Text = "==请选择品牌分类==";
        pinpai.Value = "0";
        pinpai.Selected = true;
        this.ddlbrand.Items.Add(pinpai);
        categoryft.Zone = "brand";
        IList<ICategory> listCategory = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listCategory = session.Category.GetList(categoryft);
        }
        if (listCategory.Count > 0)
        {
            foreach (ICategory item in listCategory)
            {
                ListItem li = new ListItem();
                li.Text = item.Name;
                li.Value = item.Id.ToString();
                ddlbrand.Items.Add(li);
            }
        }

        //品牌分类
        ITeam team = null;
        ICategory category1 = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            team = session.Teams.GetByID(Convert.ToInt32(Request.QueryString["id"]));
            category1 = session.Category.GetByID(team.brand_id);
        }

        if (category1 != null)//对品牌进行了分类
        {
            ddlbrand.SelectedItem.Text = category1.Name;
            ddlbrand.SelectedValue = team.brand_id.ToString();
        }
        ddlbrand.DataBind();

    }

    /// <summary>
    /// 编辑项目
    /// </summary>
    private void addContent()
    {
        string createUpload = "";
        //Maticsoft.Model.Team team = new Maticsoft.Model.Team();               
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            team = session.Teams.GetByID(Convert.ToInt32(Request.QueryString["id"]));
        }

        team.User_id = AS.Common.Utils.Helper.GetInt(AdminPage.AsAdmin.Id, 0);

        //team.catakey = Request["catakey"];//项目分类的关键字
        //team.catakey = Request["birds"];

      
        team.commentscore = Convert.ToDecimal(Helper.GetDouble(Request["commentscore"], 0));//评论返利的金额



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

        team.Reach_time = null;
        team.System = "N";

        team.Begin_time = DateTime.Now;
        team.End_time = DateTime.Now.AddDays(2);
        team.Sort_order = Helper.GetInt(createsort_order.Value, 0);
        string partneridstr = Helper.GetString(Request["shanghu"], String.Empty);
        if (partneridstr != String.Empty)
        {
            string str = partneridstr.Substring(0, partneridstr.IndexOf(":"));
            team.Partner_id = int.Parse(str);
        }
        else
        {
            team.Partner_id = 0;
        }
        //在项目表中添加sale_id 同时更新到partner表中
        if (Request.Form["xiaoshou"] != null)
        {
            int saleId = Helper.GetInt(Request.Form["xiaoshou"].ToString(), 0);
            //if (shanghu.Value != "" && shanghu.Value != null && shanghu.Value != "-----")
            if (shanghuid.Value != "" && shanghuid.Value != "0")
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



        team.Card = Helper.GetInt(createcard.Value, 0);
        team.Bonus = Helper.GetInt(Request["createbonus"], 0);

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
                    if (!Directory.Exists(path))
                    {
                        Directory.CreateDirectory(path);
                    }

                    Image.PostedFile.SaveAs(path + pictureName);

                    //生成缩略图
                    string strOldUrl = path + pictureName;
                    string strNewUrl = path + "small_" + pictureName;
                    AS.Common.Utils.ImageHelper.CreateThumbnailNobackcolor(strOldUrl, strNewUrl, 235, 150);

                    //图片加水印
                    string drawuse = "";
                    string drawimgType = "";
                    ImageHelper.Mall_DrawImgWord(createUpload + "\\" + pictureName, ref drawuse, ref drawimgType, _system);
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
        team.Detail = createdetail.Value;
        team.Userreview = "";
        team.Delivery = Request.Form["radio"].ToString();
        team.Credit = 0;
        if (Helper.GetInt(Request["freighttype"], 0) == 0)//没有使用快递模板
        {
            team.freighttype = 0;
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
                team.Farefree = Helper.GetInt(createfarefree.Value, 0);
                team.cashOnDelivery = Helper.GetString(ddlCashOnDelivery.SelectedValue, "0");
            }
            catch (Exception)
            {

                SetError("您输入的免单数量格式不正确,请重新输入");
            }
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
                team.freighttype = Helper.GetInt(faretemplate_drop.SelectedValue, 0);
                team.Farefree = Helper.GetInt(farefree2.Value, 0);
                //如果使用了快递模板，那么快递费清0 
                team.Fare = 0;
                team.cashOnDelivery = Helper.GetString(ddlCashOnDelivery.SelectedValue, "0");
            }
        }

        team.Express = createexpress.Value;
        // 库存和报警设置
        team.open_invent = Convert.ToInt32(this.ddlinventory.SelectedValue);
        team.open_war = Convert.ToInt32(this.ddlinven_war.SelectedValue);
        team.warmobile = Request["inventmobile"];
        team.teamway = expressway.SelectedValue;
        team.cost_price = Convert.ToDecimal(Cost_price.Value);//商户成本价格
        team.teamhost = Helper.GetInt(Request["hostt"], 0);//首页推荐热销
        if (Helper.GetInt(Request["hostt"], 0) != 0)
        {
            team.cataid = 0;//项目分类的编号
        }
        else
        {
            team.cataid = Helper.GetInt(Request["parent"], 0);//项目分类的编号
        }

        team.drawType = Helper.GetInt(Request["dtype"], 0);//抽奖方式，0:默认为随机,1按顺序生成

        //编辑
        //时间间隔
        if (Request["team_create_now_update"] != null && Request["team_create_now_time"] != null && Request["team_create_now_update"].ToString() != "" && Request["team_create_now_time"].ToString() != "")
        {
            team.update_value = Convert.ToInt32(Request["team_create_now_update"].ToString());
            team.time_state = Convert.ToInt32(Request["team_create_now_time"].ToString());
        }
        //最高上限
        if (Request.Form["team_create_autolimit"] != null && Request.Form["team_create_autolimit"].ToString() != "")
        {
            team.autolimit = Convert.ToInt32(Request.Form["team_create_autolimit"].ToString());
        }
        //是否是手动更新人数
        if (Request.Form["manualupdate"] != null && Request.Form["now_number"] != null && Request.Form["now_number"].ToString() != "" && Request.Form["manualupdate"].ToString() != "")
        {
            team.Manualupdate = 1;
            team.Now_number = Convert.ToInt32(Request.Form["now_number"].ToString());
        }
        else
        {
            team.Manualupdate = 0;

            //购买数量
            OrderFilter orderft = new OrderFilter();
            OrderDetailFilter orderdeft = new OrderDetailFilter();
            orderdeft.Teamid = team.Id;
            orderft.State = "pay";
            orderft.Team_id = team.Id;
            int count = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                count = session.OrderDetail.GetList(orderdeft).Count + session.Orders.GetList(orderft).Count;
            }
            team.Now_number = count;
            team.update_value = 0;
            team.time_state = 0;
            team.autolimit = 0;
        }
        ////////////////////////////////////////////////////
        team.time_interval = 0;

        //添加颜色或者尺寸

        if (ddlProduct.Value != "" && ddlProduct.Value != null && ddlProduct.Value != "-----")
        {
            IProduct promodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                promodel = session.Product.GetByID(Helper.GetInt(prohidden.Value, 0));
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
            string[] bulletinteam = team.bulletin.Replace("{", "").Replace("}", "").TrimEnd(',').Split(',');
            int cou = 0;
            if (team.bulletin != "")
            {
                cou = bulletinteam.Length;
            }
            team.bulletin = addcolor(cou);
        }
        team.productid = Helper.GetInt(prohidden.Value, 0);


        if (team.productid != 0 && team.bulletin != "" && team.Delivery != "express")
        {

            SetError("友情提示：该项目的产品有规格只能选择快递的递送方式");
            return;
        }

        team.teamcata = 1;

        if (ispoint && team.teamscore > 0)
        {
            SetSuccess("友情提示：积分项目无法选择优惠券");
        }
        else
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int id = session.Teams.Update(team);
            }
            if (Helper.GetInt(team.open_invent, 0) == 1)//开启库存
            {
                if (team.productid == 0)
                {
                    // SetSuccess("<script language='javascript'>if(!confirm('友情提示：已开启库存功能，是否进行出入库操作！')){location.href='Commoditylist.aspx'}else{X.get('ajax_coupon.aspx?action=invent&p=d&inventid=" + team.Id + "')}<" + "/script>\r\n");
                    Response.Redirect("Commodity_edit.aspx?id=" + team.Id + "&d=d");
                }
                else
                {
                    SetSuccess("友情提示：编辑项目成功");
                }
            }
            else
            {
                SetSuccess("友情提示：编辑项目成功");
            }
            SetSuccess("友情提示：编辑项目成功");

        }
    }

    /// <summary>
    /// 显示文件夹信息
    /// </summary>

    public string setUpload()
    {
        string result1 = "~/upload/team/";
        string path = Server.MapPath("~/upload/team/");
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
        result1 = result1 + DateTime.Now.Year + "/";
        path = path + DateTime.Now.Year + "/";
        if (!Directory.Exists(path))
            Directory.CreateDirectory(path);
        path = path + DateTime.Now.ToString("MMdd");
        if (!Directory.Exists(path))
            Directory.CreateDirectory(path);
        result1 = result1 + DateTime.Now.ToString("MMdd") + "/";


        return result1;
    }
    #region 添加颜色或者尺寸
    public string addcolor(int count)
    {
        string str = "";
        if (Request["totalNumber"] != null && Request["totalNumber"] != "")
        {
            int num = Convert.ToInt32(Request["totalNumber"]);
            str += "{";

            for (int i = 0; i < count; i++)
            {
                if (Request["StuNamea" + i] != null && Request["Stuvaluea" + i] != null && Request["StuNamea" + i].ToString() != "" && Request["Stuvaluea" + i].ToString() != "")
                {
                    str += Request["StuNamea" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(",", "") + ":";
                    str += "[";
                    str += Request["Stuvaluea" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(",", "");
                    str += "]";
                    str += ",";
                }

            }
            for (int i = 0; i < num; i++)
            {
                if (Request["StuName" + i] != null && Request["Stuvalue" + i] != null && Request["StuName" + i].ToString() != "" && Request["Stuvalue" + i].ToString() != "")
                {
                    str += Request["StuName" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(",", "") + ":";
                    str += "[";
                    str += Request["Stuvalue" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(",", "");
                    str += "]";
                    str += ",";
                }
            }
            str += "}";
        }
        return str;
    }
    #endregion




    protected string state = "0";
    public string productid = "0";
    public IProduct productmodel = null;
    protected void cha(object sender, EventArgs e)
    {
        cataloglist();
        if (ddlProduct.Value != "" && ddlProduct.Value != null && ddlProduct.Value != "-----")
        {
            IProduct iproduct = null;
            int strindexof = ddlProduct.Value.IndexOf(":");
            if (strindexof != -1)
            {
                iproduct = GetProductData(ddlProduct.Value.Substring(0, strindexof), "");
            }
            if (iproduct != null)
            {
                productid = iproduct.id.ToString();
                prohidden.Value = iproduct.id.ToString();
            }
            else
            {
                SetError("无此产品！请先添加产品。如果不填写产品，无需输入。");
                Response.Redirect("Project_XinjianXiangmu.aspx");
                Response.End();
                return;
            }

            state = "1";

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                productmodel = session.Product.GetByID(Helper.GetInt(productid, 0));
            }
            if (productmodel != null)
            {
                createproduct.Value = productmodel.productname;
                market_price.Value = productmodel.price.ToString();
                #region 项目的颜色或者尺寸
                string[] bulletinteam = productmodel.bulletin.Replace("{", "").Replace("}", "").Split(',');
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
                                bulletin += "属性：<input class=\"h-input\" type=\"text\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + ">数值：<input style=\"width:500px\" class=\"h-input\" type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + " >";
                                bulletin += "<input type=\"button\"  class=\"formbutton\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
                            }
                            else
                            {
                                bulletin += "属性：<input class=\"h-input\" type=\"text\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + " readonly>数值：<input style=\"width:500px\" class=\"h-input\" type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + " readonly>";
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
                IPartner partmodel = GetPartnerData(productmodel.partnerid.ToString(), "");
                if (partmodel != null)
                {
                    shanghu.Value = partmodel.Id.ToString() + ":" + partmodel.Title;
                    shanghuid.Value = partmodel.Id.ToString();
                }
                else
                {
                    shanghuid.Value = "0";
                }
                teamPrice.Value = productmodel.team_price.ToString();
                //如果产品的品牌已删除，品牌不选中
                int id = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    id = session.Category.Delete(productmodel.brand_id);
                }
                if (id != 0)
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
            shanghu.Value = "";
            ddlinventory.Enabled = true;
            teamPrice.Value = "1";
        }
    }
    public IProduct GetProductData(string strId, string strprname)
    {
        ProductFilter productfilter = new ProductFilter();
        IProduct productmodel = null;
        if (strId != null && strId != "")
        {
            productfilter.Id = AS.Common.Utils.Helper.GetInt(strId, 0);
        }
        if (strprname != null && strprname != "")
        {
            productfilter.Productname = strprname;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            productmodel = session.Product.Get(productfilter);
        }
        return productmodel;
    }
    public IPartner GetPartnerData(string strId, string strprname)
    {
        PartnerFilter partnerfilter = new PartnerFilter();
        IPartner partnermodel = null;
        if (strId != null && strId != "")
        {
            partnerfilter.Id = AS.Common.Utils.Helper.GetInt(strId, 0);
        }
        if (strprname != null && strprname != "")
        {
            partnerfilter.Titles = strprname;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            partnermodel = session.Partners.Get(partnerfilter);
        }
        return partnermodel;
    }  
       
</script>
<%LoadUserControl("_header.ascx", null); %>
<script src="<%=PageValue.WebRoot %>upfile/js/jquery_ui/ui/jquery.ui.core.js" type="text/javascript"></script>
<script src="<%=PageValue.WebRoot %>upfile/js/jquery_ui/ui/jquery.ui.widget.js" type="text/javascript"></script>
<script src="<%=PageValue.WebRoot %>upfile/js/jquery_ui/ui/jquery.ui.position.js"
    type="text/javascript"></script>
<script src="<%=PageValue.WebRoot %>upfile/js/jquery_ui/ui/jquery.ui.autocomplete.js"
    type="text/javascript"></script>
<link rel="stylesheet" href="<%=PageValue.WebRoot %>upfile/js/jquery_ui/themes/base/jquery.ui.all.css" />
<style type="text/css">
    .ui-autocomplete-loading
    {
        background: white url('/upfile/js/jquery_ui/autocomplete/images/ui-anim_basic_16x16.gif') right center no-repeat;
    }
</style>
<%int openinvent = 0;
  if (team != null)
  {
      openinvent = AS.Common.Utils.Helper.GetInt(team.open_invent, 0);
  }
  else if (productmodel != null && productmodel.open_invent == 1)
  {
      openinvent = 1;
  }
  if (openinvent == 1 && Request["d"] == "d")
  {%>
<script language='javascript'>
    if (!confirm('友情提示：该项目已开启库存功能，是否进行出入库操作！')) { location.href = 'Commoditylist.aspx' } else { X.get('/manage/ajax_coupon.aspx?action=invent&p=d&inventid=<%=team.Id%>') }</script>
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

    function ischange(obj) {
        if (obj.value == "goods") {
            $("#divIsPredict").hide();
        } else {
            if (obj.value != "point") {
                $("#divIsPredict").show();
            }
        }
        if (obj.value == "point") {

            $("#dparent").hide();
            $("#dbrand").hide();
            $("#dhost").hide();
            $("#field_notice").hide();
            $("#summery").hide();
            $("#field_userreview").hide();
            $("#field_systemreview").hide();
            $("#express_zone_coupon").hide();
            $("#express_zone_express").show();
            $("#fanli").hide();
            $("#start").hide();
            $("#way").hide();
            $("#drawmobile").hide();
            $("#coupon").hide();
            $("#pcoupon").hide();
            $("#express").show();
            $("#draw").hide();
            document.getElementById("zonediv2").checked = true;
            $("#price").hide();
            $("#pscore").show();
            $("#ctime").hide();
            $("#bkey").hide();
            $("#apitype").hide();
            $("#fscore").hide();
            $("#divIsPredict").hide();

        } else {

            $("#dparent").show();
            $("#dbrand").show();
            $("#dhost").show();
            $("#field_notice").show();
            $("#summery").show();
            $("#field_userreview").show();
            $("#field_systemreview").show();
            $("#express_zone_express").hide();
            $("#express_zone_coupon").show();
            $("#fanli").show();
            $("#start").show();
            $("#way").show();
            $("#drawmobile").hide();
            document.getElementById("zonediv1").checked = true;
            $("#coupon").show();
            $("#pcoupon").show();
            $("#express").show();
            $("#draw").show();
            $("#price").show();
            $("#pscore").hide();
            $("#ctime").show();
            $("#bkey").show();
            $("#apitype").show();
            $("#fscore").show();
            if (obj.value != "goods") {
                $("#divIsPredict").show();
            }
        }
    }

    function additem(id) {
        var row, cell, str;
        row = document.getElementById(id).insertRow(-1);
        if (row != null) {
            cell = row.insertCell(-1);
            cell.innerHTML = "属性：<input class=\"h-input\" type=\"text\" name=\"StuName" + num + "\">数值：<input style=\"width:500px\" class=\"h-input\" type=\"text\" name=\"Stuvalue" + num + "\"><input  class=\"formbutton\" type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
        }
        num++;
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
        // don't navigate away from the field on tab when selecting an item
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
			        // custom minLength
			        var term = extractLast(this.value);
			        if (term.length < 1) {
			            return false;
			        }
			    },
			    focus: function () {
			        // prevent value inserted on focus
			        return false;
			    },
			    select: function (event, ui) {
			        var terms = split(this.value);
			        // remove the current input
			        terms.pop();
			        // add the selected item
			        terms.push(ui.item.value);
			        // add placeholder to get the comma-and-space at the end
			        terms.push("");
			        this.value = terms.join(", ");
			        return false;
			    }
			});
    });
</script>
<script type="text/javascript">
    $(function () {
        $("#shanghu").autocomplete({
            minLength: 1,
            source: function (request, response) {
                $.ajax({
                    type: "POST",
                    url: "ajaxpage/autocompletedatash.aspx?keyword=" + encodeURI(request.term) + "&type=pa",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        if (data == "") {
                            alert("未检索到任何商户,请您输入商户名称以及商户ID进行检索");
                        }
                        response($.map(data, function (item) {
                            return { value: item };
                        }));
                    },
                    error: function () {
                        alert("ajax请求失败");
                    }
                });
            },
            focus: function (event, ui) {
                $("#shanghu").val(ui.item.label);
                return false;
            }
        });
    });
    $(function () {
        var str = jQuery("#shanghuid").val();
        var teamid = jQuery("#HiddenField1").val();
        if (str != "" & str != "0") {
            $("#saleceng").show();
            $.ajax({
                type: "POST",
                url: "manage_ajax_getsales.aspx",
                data: { "partnerid": str, "team_id": teamid },
                success: function (msg) {
                    $("#all_Sales").html(msg);
                }
            });
        }
    });
    function GetSale() {
        var str = jQuery("#shanghuid").val();
        var teamid = jQuery("#HiddenField1").val();
        if (str != "" & str != "0") {
            $("#saleceng").show();
            $.ajax({
                type: "POST",
                url: "manage_ajax_getsales.aspx",
                data: { "partnerid": str, "team_id": teamid },
                success: function (msg) {
                    $("#all_Sales").html(msg);
                }
            });
        }
        else {
            $("#saleceng").hide();
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
                        <div class="head">
                            <h2>
                                编辑项目</h2>
                        </div>
                        <div class="sect">
                            <div class="wholetip clear">
                                <h3>
                                    1、基本信息</h3>
                            </div>
                            <div class="field">
                                <label>
                                    产品</label>
                                <input type="text" id="ddlProduct" name="ddlProduct" class="f-input" style="width: 360px;"
                                    runat="server" onserverchange="cha" value="-----" onclick="this.focus();this.select();" />
                                <input id="prohidden" runat="server" type="hidden" />
                            </div>
                            <div class="field" id="dhost">
                                <label>
                                    首页推荐</label>
                                <select id="hostt" name="hostt" style="width: 160px;" class="f-input" runat="server"
                                    onchange="stateType()">
                                    <option value="0">请选择</option>
                                    <option value="1">新品上架</option>
                                    <option value="2">热销产品</option>
                                    <option value="3">推荐商品</option>
                                    <option value="4">低价促销</option>
                                </select>
                            </div>
                            <div class="field" id="dparent" <%if (team != null)
                                                                  {
                                                                      if (team.teamhost != 0)
                                                                      {%> style="display: none" <%}
                                     }%>>
                                <label>
                                    项目分类</label>
                                <select id="parent" name="parent" style="width: 160px;" class="f-input">
                                    <option value="0">==请选择项目分类==</option>
                                    <%=cata%>
                                </select>
                            </div>
                            <script type="text/javascript">
                                function stateType() {
                                    var state = $("#hostt").val();
                                    if (state.toString() != "0") {
                                        document.getElementById('dparent').style.display = "none";
                                    }
                                    else {
                                        document.getElementById('dparent').style.display = "block";
                                    }
                                }
                            </script>
                            <div class="field" id="dbrand">
                                <label>
                                    品牌分类</label>
                                <asp:DropDownList ID="ddlbrand" name="ddlbrand" class="f-input" runat="server" Style="width: 160px;">
                                </asp:DropDownList>
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
                                    group="g" runat="server" /><span class="inputtip"></span>
                            </div>
                            <div class="field">
                                <label>
                                    SEO关键字</label>
                                <input type="text" size="30" name="seokeyword" id="seokeyword" maxlength="250" class="f-input"
                                    group="g" runat="server" /><span class="inputtip"></span>
                            </div>
                            <div class="field">
                                <label>
                                    SEO描述</label>
                                <input type="text" size="30" name="seodescription" id="seodescription" maxlength="1000"
                                    class="f-input" group="g" runat="server" /><span class="inputtip"></span>
                            </div>
                            <%if (state == "0")
                              { %>
                            <div class="field">
                                <label>
                                    项目规格</label>
                                <input type="button" class="formbutton" name="btnAddFile" value="添加" onclick="additem('tb')" /><font
                                    style='color: red'>例如：属性填写：颜色 数值填写：红色|黄色|蓝色</font>
                                <%--<input type="text" name="btnAddFile" id="btnAddFile" runat="server" maxlength="1000"/>--%>
                            </div>
                            <%} %>
                            <div class="field">
                                <label>
                                </label>
                                <table id="tb">
                                    <%=bulletin%>
                                </table>
                                <input type="hidden" name="totalNumber" value="0" />
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
                            <%--12--%>
                            <div class="field">
                                <div class="label_c">
                                    <label>
                                        手动更新人数</label>
                                    <table width="20px" border="0" cellspacing="0" cellpadding="0" align="left">
                                        <tr>
                                            <td valign="middle" height="30px">
                                                <input type="checkbox" name="manualupdate" id="team-create-manualupdate" value="1"
                                                    <%=headYes %> />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div class="label_b">
                                    已购数量
                                    <input type="text" size="10" name="now_number" id="team-create-now-number" class="number_a"
                                        value="<%=headSum %>" group="g" maxlength="6" datatype="integer" />
                                </div>
                            </div>
                            <div class="field">
                                <label>
                                    每过</label>
                                <input type="text" size="6" name="team_create_now_time" id="team_create_now_time"
                                    class="number" value="<%=time_state %>" group="g" require="true" maxlength="4"
                                    datatype="integer" /><span style="float: left; height: 30px; line-height: 30px;">分钟</span>
                                <label>
                                    自动更新</label>
                                <input type="text" size="6" name="team_create_now_update" id="team_create_now_update"
                                    class="number" value="<%=update_value %>" require="true" group="g" maxlength="4"
                                    datatype="integer" /><span style="float: left; height: 30px; line-height: 30px;">人</span>
                                <label>
                                    最高上线</label>
                                <input type="text" size="6" name="team_create_autolimit" id="team_create_autolimit"
                                    class="number" value="<%=Autolimit %>" require="true" group="g" maxlength="4"
                                    datatype="integer" />
                                <span class="hint" id="SPAN4" runat="server">自动加油条件：1：选中手动更新人数；2：大于0分钟；3：自动更新人数大于0；4：自动加油的数目大于已购数量。
                                </span>
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
                            <asp:HiddenField ID="HiddenField1" runat="server" />
                            <!--kxx 增加-->
                            <div class="wholetip clear">
                                <h3>
                                    2、库存信息</h3>
                            </div>
                            <div class="field">
                                <label>
                                    启用库存</label>
                                <asp:DropDownList ID="ddlinventory" Style="float: left;" runat="server">
                                </asp:DropDownList>
                                <span class="inputtip">是否开启库存功能</span>
                            </div>
                            <div class="field">
                                <label>
                                    启用库存报警</label>
                                <asp:DropDownList ID="ddlinven_war" Style="float: left;" runat="server">
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
                            <input type="hidden" name="guarantee" value="Y" id="Hidden1" runat="server" />
                            <input type="hidden" name="system" value="Y" id="Hidden2" runat="server" />
                            <div class="wholetip clear">
                                <h3>
                                    3、项目信息</h3>
                            </div>
                            <div class="field">
                                <label>
                                    商户</label>
                                <input type="text" id="shanghu" runat="server" style="width: 50%" class="f-input"
                                    value="" onclick="this.focus();this.select();" onblur="GetSale();" />
                                <input id="shanghuid" runat="server" type="hidden" />
                                <span class="inputtip">商户为可选项</span>
                            </div>
                            <%-- 增加销售人员id --%>
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
                                    require="true" datatype="money" runat="server" />
                                <span class="inputtip">评论之后的返利金额</span>
                            </div>
                            <div class="field">
                                <label>
                                    商品名称</label>
                                <input type="text" size="30" name="product" id="createproduct" class="f-input" group="g"
                                    style="width: 692px" datatype="require" require="true" runat="server" />
                            </div>
                            <div class="field">
                                <label>
                                    商品图片</label>
                                <asp:FileUpload ID="Image" name="Image" class="f-input" Height="26px" Width="694px"
                                    runat="server" />
                                <span class="hint">至少得上传一张商品图片</span>&nbsp;
                                <label id="ImageSet" class="hint" runat="server">
                                </label>
                                <%-- <a href="javascript:show(0)">引用其他图片</a>--%>
                            </div>
                            <div id="img0" class="field">
                                <label>
                                    引用其他图片</label>
                                <input type="text" size="30" name="imget" id="imget" class="f-input" style="width: 692px"
                                    runat="server" />
                            </div>
                            <div class="field">
                                <label>
                                    本单详情</label>
                                <div style="float: left;">
                                    <textarea cols="45" style="height: 500px;" rows="5" name="detail" id="createdetail"
                                        class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1&t=1',urlType:'abs'}"
                                        runat="server"></textarea>
                                </div>
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
                                        <input id="zonediv2" type="radio" name="radio" value="express" checked="true" runat="server" />快递
                                    </div>
                                </div>
                            </div>
                            <div id="express_zone_express">
                                <div class="field" id="Div2">
                                    <label>
                                        结算方式</label>
                                    <asp:DropDownList ID="expressway" runat="server" class="f-input" Style="width: 280px;">
                                        <asp:ListItem Value="S">按实际发货数量(已填写快递单号的订单)</asp:ListItem>
                                        <asp:ListItem Value="Y">按实际购买数量</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="field_xm">
                                    <label>
                                        <input name="freighttype" id="freighttype0" type="radio" value="0" runat="server"
                                            onclick=" return freighttype0_onclick()" />填写快递费</label>
                                    <label>
                                        <input name="freighttype" id="freighttype1" type="radio" value="1" runat="server"
                                            onclick=" return freighttype1_onclick()" />使用快递模板(<a href='fare_template.aspx'>编辑快递模板</a>)</label>
                                </div>
                                <div class="field" id="type1" <%if (team.freighttype == 0)
                                                                    {%> style="display: none" <%}%>>
                                    <label>
                                        快递费模板</label>
                                    <asp:DropDownList ID="faretemplate_drop" Style="float: left;" runat="server">
                                    </asp:DropDownList>
                                    <label>
                                        免单数量</label>
                                    <input type="text" size="10" id="farefree2" class="number" value="0" maxlength="6"
                                        datatype="money" require="true" runat="server" />
                                    <span class="hint">快递费用，免单数量：0表示不免运费，2表示购买2件免运费</span>
                                </div>
                                <div class="field" id="type0" <%if (team.freighttype != 0)
                                                                    { %>style=" display:none;" <%} %>>
                                    <label>
                                        快递费用</label>
                                    <input type="text" size="10" name="fare" id="createfare" class="number" value="5"
                                        maxlength="6" datatype="money" require="true" runat="server" />
                                    <label>
                                        免单数量</label>
                                    <input type="text" size="10" name="farefree" id="createfarefree" class="number" value="0"
                                        maxlength="6" datatype="money" runat="server" />
                                    <span class="hint">快递费用，免单数量：0表示不免运费，2表示购买2件免运费</span>
                                </div>
                                <div class="field" id="expressmemo" style="display: none;">
                                    <label>
                                        快递配送说明</label>
                                    <div>
                                        <textarea cols="45" rows="5" name="express" id="createexpress" class="f-textarea"
                                            runat="server"></textarea>
                                    </div>
                                </div>
                                <div>
                                </div>
                                <div class="field">
                                    <label>
                                        货到付款接口</label>
                                    <asp:DropDownList ID="ddlCashOnDelivery" Style="float: left;" runat="server">
                                        <asp:ListItem Value="0">关闭</asp:ListItem>
                                        <asp:ListItem Value="1">开启</asp:ListItem>
                                    </asp:DropDownList>
                                    <span class="inputtip">只有开启本功能的项目才支持货到付款</span>
                                </div>
                            </div>
                            <div class="act">
                                <input id="leadesubmit" name="commit" type="submit" value="好了，提交" group="g" class="formbutton validator"
                                    onclick="return leadesubmit_onclick()" />
                                <script type="text/javascript">
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
                             <%if (this.shanghu.Value != "")
                              {
                                  Page.ClientScript.RegisterStartupScript(this.GetType(), "js", "GetSale();", true);
                              } %>
                            <!--</form>-->
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