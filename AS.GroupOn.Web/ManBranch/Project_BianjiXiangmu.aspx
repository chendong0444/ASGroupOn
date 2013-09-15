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
    protected bool hidden = false;
    protected string youhuiquan = "";
    protected string kuaidi = "";
    protected string youhuiquan1 = "";
    protected string tkfs = "";
    protected string kuaidi1 = "";
    protected string headYes = "";
    protected int headSum = 0;
    protected string end = "";
    protected string endCss;
    protected string begin = "";
    protected string beginCss;
    protected int update_value;
    protected int Autolimit;
    protected int time_state;
    protected string num = "";
    public ICatalogs catamodel = null;
    public CatalogsFilter catabll = new CatalogsFilter();
    public PartnerFilter partner = new PartnerFilter();
    public IPartner mpartner = null;

    public string drawmobile = "";//项目是否是抽奖项目
    TeamFilter teams = new TeamFilter();
    ListItem teamType = null;
    public string bulletin = "";
    protected bool isfaretemplate = false; //是否启用了运费模版
    public NameValueCollection _system = null;
    public CouponFilter couponbll = new CouponFilter();
    public ICoupon couponmodel = null;
    public string inven;
    ListItem inventory1 = null;
    ListItem inven_war1 = null;
    public int shanhu = 0;
    public string tfan = "";
    public string cata = "";
    public string draw = "";
    public int api = 0;
    public int apiid = 0;//api分类id
    public string apicata = "";//api下拉框信息
    public string pcoupon;

    public int cataid = 0;//项目分类编号
    public bool ispoint = false;//判断如果是积分项目，那么用户选择了优惠券无法进行提交

    public string keyword = "";//项目的关键字


    public string strcitys = "";
    public string strothercityid = "";
    public int host = 0;//项目属性\
    public int teamnew = 0;//首页新品推荐

    public string comment = "0";//评论返利金额
    public string hideyhq = "";
    public string hidepoint = "";//积分项目的其他栏目
    public string showpoint = "";
    public int cityid = 0;

    public bool ishdraw = false;

    public ProductFilter productbl = new ProductFilter();
    protected string isDispaly = String.Empty;
    public string way = "";
    public string isrefund = "N";//退款方式

    public int invenStatus = 0;//表示是否显示项目规格的添加，只有在项目选择产品了，编辑项目信息时，不能再对规格信息修改。
    public string dtype = "";//抽奖方式
    public int productid = 0;
    public int branch_id = 0;
    protected string strAreas = String.Empty;
    protected string strcircle = String.Empty;
    protected string strlevelcity = String.Empty;
    public string team_id = String.Empty;
    protected ITeam team = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);              
        if (!IsPostBack)
        {
            if (Request.QueryString["id"] != null)
            {
                team_id = Request.QueryString["id"].ToString();
                getContent();
                cataloglist();
            }
            if (Request.QueryString["del"] != null && Request.QueryString["image"] != null)
            {
                using(IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    team = session.Teams.GetByID(int.Parse(Request.QueryString["del"].ToString()));
                }
                int index = int.Parse(Request.QueryString["image"].ToString());
                if (team != null)
                {
                    teams.Id = team.Id;
                    if (index == 1)
                    {
                        team.Image1 = Request.QueryString["image"].ToString();
                    }
                    if (index == 2)
                    {
                        team.Image2 = Request.QueryString["image"].ToString();
                    }
                    SetSuccess("删除成功!");
                    Response.Redirect("Project_BianjiXiangmu.aspx?id=" + team.Id + "");
                }
            }
        }
        if (Request["commit"] == "好了，提交")
        {
                updateContent();
        }

    }



    #region 显示目录信息
    public void cataloglist()
    {
        catabll.type = 0;
        DataTable dt = null;
        IList<ICatalogs> list = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            list = session.Catalogs.GetList(catabll);
        }
        dt = AS.Common.Utils.Helper.ToDataTable(list.ToList());        
        BindData(dt, 0, "");
    }
    #endregion


    #region
    public void isdraw(int teamid)
    {
        IList<IDraw> list = null;
        DrawFilter drawft = new DrawFilter();
        drawft.teamid = teamid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            list = session.Draw.GetList(drawft);
        }        
        if (list.Count > 0)
        {
            ishdraw = true;
        }
    }
    #endregion

    private void BindData(DataTable dt, int id, string blank)
    {
        DataView dv = new DataView(dt);
        dv.RowFilter = "parent_id = " + id.ToString();
        if (id != 0)
        {
            blank += "|─";
        }
        foreach (DataRowView drv in dv)
        {
            if (cataid == Convert.ToInt32(drv["id"].ToString()))
            {
                cata += " <option value=" + drv["id"] + " selected=selected>" + blank + "" + drv["catalogname"].ToString() + "</option>";
            }
            else
            {
                cata += " <option value=" + drv["id"] + ">" + blank + "" + drv["catalogname"].ToString() + "</option>";
            }
            BindData(dt, Convert.ToInt32(drv["id"]), blank);
        }
    }

    private void BindApiData(DataTable dt, int id, string blank)
    {
        DataView dv = new DataView(dt);
        dv.RowFilter = "city_pid = " + id.ToString();

        if (id != 0)
        {
            blank += "|─";
        }

        foreach (DataRowView drv in dv)
        {
            if (apiid == Convert.ToInt32(drv["id"].ToString()))
            {
                apicata += " <option value=" + drv["id"] + " selected=selected>" + blank + "" + drv["name"].ToString() + "</option>";
            }
            else
            {
                apicata += " <option value=" + drv["id"] + ">" + blank + "" + drv["name"].ToString() + "</option>";
            }
            BindApiData(dt, Convert.ToInt32(drv["id"]), blank);
        }

    }


    private void getArea(string City_id, string areaid, string circleid, string levelcityid)
    {
        AreaFilter areabl = new AreaFilter();
        CategoryFilter cat = new CategoryFilter();
        cat.Zone = "city";
        cat.City_pid = Convert.ToInt32( City_id);
        IList<ICategory> list = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            list = session.Category.GetList(cat);
        }
        DataTable dt_sec = AS.Common.Utils.Helper.ToDataTable(list.ToList());
        if (levelcityid != "0")
        {
            if (dt_sec != null && dt_sec.Rows.Count > 0)//该城市有二级城市
            {
                strlevelcity = strlevelcity + " <select id=\"ddllevelcity\" name=\"ddllevelcity\" style=\"width:135px;\" class=\"f-input\" onchange=\"getlevelcity()\">";
                strlevelcity = strlevelcity + "<option value=\"0\" >请选择二级城市</option>";
                if (dt_sec != null && dt_sec.Rows.Count > 0)
                {

                    for (int j = 0; j < dt_sec.Rows.Count; j++)
                    {
                        if (levelcityid == dt_sec.Rows[j]["id"].ToString())
                        {
                            strlevelcity = strlevelcity + "<option selected value=\"" + dt_sec.Rows[j]["id"].ToString() + "\" >" + dt_sec.Rows[j]["name"].ToString() + "</option>";
                        }
                        else
                        {
                            strlevelcity = strlevelcity + "<option value=\"" + dt_sec.Rows[j]["id"].ToString() + "\" >" + dt_sec.Rows[j]["name"].ToString() + "</option>";
                        }
                    }
                }
                strlevelcity = strlevelcity + "</select>";
            }
        }

        if (areaid != "0")
        {
            strAreas = strAreas + " <select id=\"ddlarea\" name=\"ddlarea\" style=\"width:135px;\" class=\"f-input\" onchange=\"getcircle()\">";
            strAreas = strAreas + "<option value=\"0\" >请选择区域</option>";
           
            AreaFilter areaft = new AreaFilter();
            areaft.type = "area";

            IList<IArea> listArea = null;

            DataTable dtArea = null; 
            if (levelcityid != "0")
            {
                areaft.cityid = Convert.ToInt32( levelcityid);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    listArea = session.Area.GetList(areaft);
                }
                dtArea=AS.Common.Utils.Helper.ToDataTable(listArea.ToList());
                isDispaly = "";
            }
            else
            {
                areaft.cityid = Convert.ToInt32(City_id);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    listArea = session.Area.GetList(areaft);
                }
                dtArea = AS.Common.Utils.Helper.ToDataTable(listArea.ToList());
                isDispaly = " style='display:none;'";
            }

            if (dtArea != null)
            {
                for (int i = 0; i < dtArea.Rows.Count; i++)
                {
                    if (areaid == dtArea.Rows[i]["id"].ToString())
                    {
                        strAreas = strAreas + "<option selected value=\"" + dtArea.Rows[i]["id"].ToString() + "\" >" + dtArea.Rows[i]["areaname"].ToString() + "</option>";
                    }
                    else
                    {
                        strAreas = strAreas + "<option value=\"" + dtArea.Rows[i]["id"].ToString() + "\" >" + dtArea.Rows[i]["areaname"].ToString() + "</option>";
                    }
                }
            }
            strAreas = strAreas + "</select>";
        }


        if (circleid != "" && circleid != "0")
        {
            DataTable dtArea = null;
            IList<IArea> listArea = null;
            AreaFilter areaft = new AreaFilter();
            areaft.type = "circle";
            areaft.cityid = Convert.ToInt32(areaid);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                listArea = session.Area.GetList(areaft);
            }
            dtArea = AS.Common.Utils.Helper.ToDataTable(listArea.ToList());
            if (dtArea != null)
            {
                strcircle = strcircle + " <select id=\"ddlcircle\" name=\"ddlcircle\" style=\"width:135px;\" class=\"f-input\">";
                strcircle = strcircle + "<option value=\"0\" >请选择商圈</option>";

                for (int i = 0; i < dtArea.Rows.Count; i++)
                {
                    if (circleid == dtArea.Rows[i]["id"].ToString())
                    {
                        strcircle = strcircle + "<option selected value=\"" + dtArea.Rows[i]["id"].ToString() + "\" >" + dtArea.Rows[i]["areaname"].ToString() + "</option>";
                    }
                    else
                    {
                        strcircle = strcircle + "<option value=\"" + dtArea.Rows[i]["id"].ToString() + "\" >" + dtArea.Rows[i]["areaname"].ToString() + "</option>";
                    }
                }

                strcircle = strcircle + "</select>";
            }
        }

    }

    private void setcity(string nowcityid, string othercity, string level_cityid)
    {
        strothercityid = othercity;
        StringBuilder sb1 = new StringBuilder();
        CategoryFilter categoryft = new CategoryFilter();
        IList<ICategory> listCategory = null;
        categoryft.Zone = "city";        
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listCategory = session.Category.GetList(categoryft);
        }
        foreach (ICategory item in listCategory)
        {
            if (nowcityid == "0")
            {
                sb1.Append("<input type='checkbox' name='city_id' value='" + item.Id + "' disabled  />&nbsp;" + item.Name + "&nbsp;&nbsp;");
            }
            else if (nowcityid != item.Id.ToString() && level_cityid != item.Id.ToString())
            {
                bool bres = false;
                if (othercity != null)
                {
                    string[] strcity = othercity.Split(',');
                   
                    for (int i = 0; i < strcity.Length; i++)
                    {
                        if (item.Id.ToString() == strcity[i].ToString())
                        {
                            bres = true;
                        }
                    }
                }  
                if (bres)
                {
                    sb1.Append("<input type='checkbox' name='city_id' value='" + item.Id + "' checked />&nbsp;" + item.Name + "&nbsp;&nbsp;");
                }
                else
                {
                    sb1.Append("<input type='checkbox' name='city_id' value='" + item.Id + "'   />&nbsp;" + item.Name + "&nbsp;&nbsp;");
                }
            }

        }
        strcitys = sb1.ToString();
    }

    #region 判断是否是积分项目，隐藏或者显示
    public void ishide(int num)
    {
        if (num == 1)
        {
            hidepoint = "display:none;";
            showpoint = "";
            creatsystemreview.Visible = false;
            createsummary.Visible = false;
            creatnotice.Visible = false;
        }
        else
        {
            hidepoint = "";
            showpoint = "display:none;";
            creatsystemreview.Visible = true;
            createsummary.Visible = true;
            creatnotice.Visible = true;
        }
    }
    #endregion

    /// <summary>
    /// 显示项目
    /// </summary>
    private void getContent()
    {

        ddlProduct.Items.Clear();
        ddlProduct.Items.Add(new ListItem("---------", "0"));
        ProductFilter productft = new ProductFilter();
        productft.Status = 1;
        IList<IProduct> listProduct = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listProduct = session.Product.GetList(productft);
        }
        DataTable dtproduct = AS.Common.Utils.Helper.ToDataTable(listProduct.ToList());
        if (dtproduct != null)
        {
            if (dtproduct.Rows.Count > 0)
            {
                for (int i = 0; i < dtproduct.Rows.Count; i++)
                {
                    ddlProduct.Items.Add(new ListItem(dtproduct.Rows[i]["Productname"].ToString(), dtproduct.Rows[i]["id"].ToString()));
                }
            }
        }

        ddlProduct.DataBind();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            team = session.Teams.GetByID(Convert.ToInt32(Request.QueryString["id"].ToString()));
        }        
        if (team != null)
        {
            Literal2.Text = team.Title;
            //是否手动过
            if (team.Conduser == "Y")
            {
                num = "已购人数";
            }
            else
            {
                num = "已购数量";
            }
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
        isdraw(team.Id);

        ddlProduct.SelectedValue = team.productid.ToString();
        productid = team.productid;
        if (team.productid != 0)
        {
            invenStatus = 1;
            ddlinventory.Enabled = false;
            shanghu.Enabled = false;
        }
        else
        {
            ddlProduct.Enabled = true;
        }


        teamscore.Value = team.teamscore.ToString();

        update_value = team.update_value;

        //分店
        if (team.branch_id.ToString() != "")
        {
            hidbranch.Value = team.branch_id.ToString();
        }

        //销售
        if (team.sale_id.ToString() != "")
        {
            hidsale.Value = team.sale_id.ToString();
        }


        commentscore.Value = team.commentscore.ToString();
        if (team.Delivery == "coupon")
        {
            way = team.teamway; //购买的方式//项目购买的方式
            if (team.isrefund != null && team.isrefund != String.Empty)
            {
                isrefund = team.isrefund;
            }
            else
            {
                isrefund = "N";
            }

        }
        else
        {
            expressway.SelectedValue = team.teamway; //购买的方式
        }
        //way = team.teamway; //购买的方式
        Cost_price.Value = team.cost_price.ToString(); //项目的成本价格，便于商户的结算
        time_state = team.time_state;
        if (team.Reach_time.HasValue)
            rech_time.Value = Convert.ToDateTime(team.Reach_time.Value).ToString("yyyy-MM-dd HH:mm:ss");
        if (team.Close_time.HasValue)
        {
            closetime.Value = Convert.ToDateTime(team.Close_time.Value).ToString("yyyy-MM-dd HH:mm:ss");
        }
        host = team.teamhost;
        dtype = team.drawType.ToString();
        inven = team.inventory.ToString();
        invent_war.Value = team.invent_war.ToString();
        per_minnumber.Value = team.Per_minnumber.ToString();

        #region 项目的颜色或者尺寸
        if (team.bulletin != null && team.Delivery == "express")
        {
            hideyhq = " display:none; ";
        }
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
                        bulletin += "属性：<input type=\"text\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + ">数值：<input type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + " >";
                        bulletin += "<input type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
                    }
                    else
                    {
                        bulletin += "属性：<input type=\"text\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + " readonly>数值：<input type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + " readonly>";
                    }
                    bulletin += "</td>";
                    bulletin += "</tr>";

                }
            }
        }
        #endregion


        comment = team.commentscore.ToString();//评论的返利金额

        // teamnew = team.teamnew;
        keyword = team.catakey;//显示项目的关键字
        cataid = team.cataid;
        apiid = team.Group_id;
        api = team.apiopen;//是否api输出的标志
        //添加项目类型
        teamType = new ListItem();

        seotitle.Value = team.seotitle;
        seokeyword.Value = team.seokeyword;
        seodescription.Value = team.seodescription;
        if (team.Team_type == "goods" || team.Team_type == "point")
        {
            divIsPredict.Style.Add("display", "none");
        }
        if (team.isPredict != 0 && team.isPredict != 1)
        {
            selIsPredict.Value = "1";
        }
        else
        {
            selIsPredict.Value = team.isPredict.ToString();//团购预告
        }

        shanhu = team.shanhu;
        teamType.Text = "团购项目";
        teamType.Value = "normal";
        if (team.Team_type == "normal")
        {
            ishide(0);
            teamType.Selected = true;
        }
        projectType.Items.Add(teamType);
        teamType = new ListItem();
        teamType.Text = "秒杀项目";
        teamType.Value = "seconds";
        if (team.Team_type == "seconds")
        {
            ishide(0);
            teamType.Selected = true;
        }
        projectType.Items.Add(teamType);


        teamType = new ListItem();
        teamType.Text = "热销商品";
        teamType.Value = "goods";
        if (team.Team_type == "goods")
        {
            ishide(0);
            teamType.Selected = true;
        }
        projectType.Items.Add(teamType);

        teamType = new ListItem();
        teamType.Text = "积分项目";
        teamType.Value = "point";
        if (team.Team_type == "point")
        {
            ishide(1);
            teamType.Selected = true;
        }
        projectType.Items.Add(teamType);

        projectType.DataBind();


        //开启库存费提醒
        inventory1 = new ListItem();
        inventory1.Text = "是";
        inventory1.Value = "1";
        if (team.open_invent == 1)
        {
            inventory1.Selected = true;
        }
        ddlinventory.Items.Add(inventory1);
        inventory1 = new ListItem();
        inventory1.Text = "否";
        inventory1.Value = "0";
        if (team.open_invent == 0)
        {
            inventory1.Selected = true;
        }
        ddlinventory.Items.Add(inventory1);
        this.ddlinventory.DataBind();
        //开启库存报警
        inven_war1 = new ListItem();
        inven_war1.Text = "是";
        inven_war1.Value = "1";
        if (team.open_war == 1)
        {
            inven_war1.Selected = true;
        }
        this.ddlinven_war.Items.Add(inven_war1);
        inven_war1 = new ListItem();
        inven_war1.Text = "否";
        inven_war1.Value = "0";
        if (team.open_war == 0)
        {
            inven_war1.Selected = true;
        }
        this.ddlinven_war.Items.Add(inven_war1);
        this.ddlinven_war.DataBind();

        inventmobile.Value = team.warmobile;

        //添加城市
        CategoryFilter categoryft = new CategoryFilter();
        ListItem chengshi = new ListItem();
        
       
        categoryft.Zone = "city";
        categoryft.City_pid = AsAdmin.City_id;

        //IList<ICategory> listCategory = null;
        //using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        //{
        //    listCategory = session.Category.GetList(categoryft);
        //}
        ICategory catcity = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catcity = session.Category.GetByID(AsAdmin.City_id);
        }
        if (catcity!=null)
        {
            if (catcity.Name!=null)
            {
                chengshi.Text = catcity.Name;
            }
            
        }
        
        chengshi.Value = AsAdmin.City_id.ToString();
        city.Items.Add(chengshi);
        //foreach (ICategory item in listCategory)
        //{
        //    ListItem li = new ListItem();
        //    li.Text = item.Name;
        //    li.Value = item.Id.ToString();

        //    if (team != null && item.Id == team.City_id)
        //    {
        //        chengshi.Selected = true;
        //    }
        //    city.Items.Add(li);
        //}
        //cityid = team.City_id;
        //city.DataBind();

        ////绑定其他城市
        //setcity(team.City_id.ToString(), team.othercity, team.level_cityid.ToString());

        //绑定区域商圈
        getArea(team.City_id.ToString(), team.areaid.ToString(), team.circleid.ToString(), team.level_cityid.ToString());

        //添加api分类
        categoryft.Zone = "group";
        DataTable dt = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            dt = AS.Common.Utils.Helper.ToDataTable(session.Category.GetList(categoryft).ToList());
        }
        if (dt.Rows.Count>0)
        {
            BindApiData(dt, 0, "");
        }
       

        //添加分类
        ListItem pinpai = new ListItem();
        pinpai.Text = "====请选择品牌分类=====";
        pinpai.Value = "0";
        this.ddlbrand.Items.Add(pinpai);
        categoryft.Zone = "brand";
        IList<ICategory> list = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            list= session.Category.GetList(categoryft);
        }
        foreach (ICategory item in list)
        {
            ListItem li = new ListItem();
            li.Text = item.Name;
            li.Value = item.Id.ToString();

            if (item.Id == team.brand_id)
            {
                li.Selected = true;
            }
            ddlbrand.Items.Add(li);
        }
        ddlbrand.DataBind();

        //添加商户
        PartnerFilter pateft = new PartnerFilter();
        ListItem li1 = new ListItem();
        li1.Text = "===========请选择商户============";
        li1.Value = "0";
        shanghu.Items.Add(li1);
        pateft.AddSortOrder(PartnerFilter.ID_DESC);
       // pateft.City_id = AsAdmin.City_id;
        IList<IPartner> listPartner = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listPartner = session.Partners.GetList(pateft);
        }
        //DataTable dt3 = AS.Common.Utils.Helper.ToDataTable(listPartner.ToList());
        if (listPartner != null && listPartner.Count > 0)
        {
            for (int i = 0; i < listPartner.Count; i++)
            {
                ListItem li = new ListItem();
                li.Text = listPartner[i].Title.ToString();
                li.Value = listPartner[i].Id.ToString();
                shanghu.Items.Add(li);
            }
        }
        shanghu.DataBind();

        //添加限制条件
        ListItem conduseName1 = new ListItem();
        conduseName1.Text = "以购买成功人数成团";
        conduseName1.Value = "Y";
        ListItem conduseName2 = new ListItem();
        conduseName2.Text = "以产品购买数量成团";
        conduseName2.Value = "N";
        if (team.Conduser == "Y")
        {
            conduseName1.Selected = true;
        }
        else
        {
            conduseName2.Selected = true;
        }
        Conduse.Items.Add(conduseName1);
        Conduse.Items.Add(conduseName2);
        Conduse.DataBind();


        ListItem code2 = new ListItem();
        code2.Text = "否";
        code2.Value = "no";
        ListItem code1 = new ListItem();
        code1.Text = "是";
        code1.Value = "yes";
        if (team.codeswitch == "no")
        {
            code2.Selected = true;
        }
        else
        {
            code1.Selected = true;
        }

        this.ddlcode.Items.Add(code2);
        this.ddlcode.Items.Add(code1);


        ListItem buyonce1 = new ListItem();
        buyonce1.Text = "仅购买一次";
        buyonce1.Value = "Y";
        ListItem buyonce2 = new ListItem();
        buyonce2.Text = "可购买多次";
        buyonce2.Value = "N";
        if (team.Buyonce == "Y")
        {
            buyonce1.Selected = true;
        }
        else
        {
            buyonce2.Selected = true;
        }
        Buyonce.Items.Add(buyonce1);
        Buyonce.Items.Add(buyonce2);
        Buyonce.DataBind();

        HiddenField1.Value = Request.QueryString["id"].ToString();
        if (team != null)
        {
            title.Value = HttpUtility.HtmlDecode(team.Title);
            market_price.Value = team.Market_price.ToString();
            teamPrice.Value = team.Team_price.ToString();
            minnumber.Value = team.Min_number.ToString();
            maxnumber.Value = team.Max_number.ToString();
            pernumber.Value = team.Per_number.ToString();
            if (team.Team_type == "seconds" || team.Team_type == "normal" || team.Team_type == "goods")
            {
                begintime.Value = team.Begin_time.ToString("yyyy-MM-dd HH:mm:ss");
                beginCss = "datetime";
                endtime.Value = team.End_time.ToString("yyyy-MM-dd HH:mm:ss");
                endCss = "datetime";

            }
            else
            {
                begintime.Value = team.Begin_time.ToString("yyyy-MM-dd HH:mm:ss");
                beginCss = "date";
                endtime.Value = team.End_time.ToString("yyyy-MM-dd HH:mm:ss");
                endCss = "date";
            }
            begin = team.Begin_time.ToString(" HH:mm:ss");
            end = team.End_time.ToString(" HH:mm:ss");

            expiretime.Value = team.Expire_time.ToString("yyyy-MM-dd");
            if (team.Summary != null && team.Summary!="")
            {
                 createsummary.Value = team.Summary.ToString();
            }
           
            creatnotice.Value = team.Notice;
            createsort_order.Value = team.Sort_order.ToString();
            createcard.Value = team.Card.ToString();
            createbonus.Value = team.Bonus.ToString();
            createproduct.Value = team.Product;
            ImageSet.InnerText = team.Image;
            shanghu.SelectedValue = team.Partner_id.ToString();
            //xiaoshou.SelectedValue = team.Sale_id.ToString();
            if (team.Image1 != "")
            {
                hfimg1.Value = team.Image1;
                lblImg1.InnerHtml = team.Image1 + "<span>&nbsp;&nbsp;</span><a href='Project_BianjiXiangmu.aspx?del=" + team.Id + "&image=1'>删除</a>";
            }
            if (team.Image2 != "")
            {

                lblImg2.InnerHtml = team.Image2 + "<span>&nbsp;&nbsp;</span>" + "<a href=' Project_BianjiXiangmu.aspx?del=" + team.Id + "&image=2'>删除</a>";

            }
            else
            {
                lblImg2.InnerHtml = "";
            }
            createflv.Value = team.Flv;

            createdetail.Value = team.Detail;
            createuserreview.Value = team.Userreview;
            creatsystemreview.Value = team.Systemreview;
            createcredit.Value = team.Credit.ToString();
            createmobile.Value = team.Mobile;
            createaddress.Value = team.Address;
            createfare.Value = team.Fare.ToString();
            ddlCashOnDelivery.SelectedValue = AS.Common.Utils.Helper.GetString(team.cashOnDelivery, "0");
            createfarefree.Value = team.Farefree.ToString();
            createexpress.Value = team.Express;
            city.SelectedValue = team.City_id.ToString();

            Autolimit = team.autolimit;
            score.Value = team.score.ToString();
            if (team.start_time.HasValue)
                createStarttime.Value = team.start_time.Value.ToString("yyyy-MM-dd");
            initdorp(team.freighttype);
            farefree2.Value = team.Farefree.ToString();

            if (team.freighttype > 0)//启用了运费模版
            {
                isfaretemplate = true;

            }
        }
        //添加单选项
        ListItem youhui = new ListItem();
        youhui.Text = "优惠券";
        youhui.Value = "coupon";
        ListItem express = new ListItem();
        express.Text = "快递";
        express.Value = "express";
        if (team != null && team.Delivery == "coupon")
        {
            youhuiquan1 = "checked=\"checked\"";
            kuaidi1 = "";
            draw = "";
            drawmobile = "display:none;";
            youhuiquan = " display:block;";
            kuaidi = " display:none;";

        }
        else if (team.Delivery == "express")
        {
            kuaidi1 = "checked=\"checked\"";
            youhuiquan1 = "";
            draw = "";
            drawmobile = "display:none;";
            kuaidi = " display:block;";
            youhuiquan = " display:none;";
        }
        else if (team.Delivery == "draw")
        {
            draw = "checked=\"checked\"";
            drawmobile = "display:block;";
            kuaidi1 = "";
            youhuiquan1 = "";
            kuaidi = " display:none;";
            youhuiquan = " display:none;";
        }
        else if (team.Delivery == "pcoupon")
        {
            pcoupon = "checked=\"checked\"";
            draw = "";
            drawmobile = "display:none;";
            kuaidi1 = "";
            youhuiquan1 = "";
            tfan = "display:none;";
            tkfs = " display:none;";
            kuaidi = " display:none;";
            youhuiquan = " display:block;";
        }

    }


    #region 初始化运费模版下拉框
    protected void initdorp(int templateid)
    {
        FareTemplateFilter ftft = new FareTemplateFilter();
        IList<IFareTemplate> listfareTemplate = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ftft.AddSortOrder(FareTemplateFilter.ID_DESC);
            listfareTemplate = session.FareTemplate.GetList(ftft);
            DataTable droptable = AS.Common.Utils.Helper.ToDataTable(listfareTemplate.ToList());
            for (int i = 0; i < droptable.Rows.Count; i++)
            {
                faretemplate_drop.Items.Add(new ListItem(droptable.Rows[i]["name"].ToString(), droptable.Rows[i]["id"].ToString()));
                if (templateid == Convert.ToInt32( droptable.Rows[i]["id"]))
                {
                    faretemplate_drop.SelectedIndex = i;
                }
            }
        }
    }

    #endregion


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
                    str += Request["StuNamea" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(".", "").Replace(",", "") + ":";
                    str += "[";
                    str += Request["Stuvaluea" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(".", "").Replace(",", "");
                    str += "]";
                    str += ",";
                }

            }
            for (int i = 0; i < num; i++)
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
        return str;
    }
    #endregion
    /// <summary>
    /// 更新内容
    /// </summary>
    private void updateContent()
    {
        string createUpload = "";

       
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            team = session.Teams.GetByID(Convert.ToInt32(HiddenField1.Value));
        }        
        team.productid = int.Parse(ddlProduct.SelectedValue);
        if (AdminPage.AsAdmin != null)
        {
            team.User_id = AdminPage.AsAdmin.Id;
        }
        else
        {
            team.User_id = 0;
        }
        
        if (projectType.SelectedItem.Value != "")
        {
            team.Team_type = projectType.SelectedItem.Value;

        }
        if (int.Parse(city.SelectedItem.Value) > -1)
        {

            team.City_id = int.Parse(city.SelectedItem.Value);
        }
        team.warmobile = Request["inventmobile"];
        team.open_invent = Convert.ToInt32(this.ddlinventory.SelectedValue);
        team.open_war = Convert.ToInt32(this.ddlinven_war.SelectedValue);
        team.seotitle = seotitle.Value;
        team.seokeyword = seokeyword.Value;
        team.seodescription = seodescription.Value;
        if (projectType.SelectedItem.Value == "goods" || projectType.SelectedItem.Value == "point")
        {
            team.isPredict = 0;
        }
        else
        {
            team.isPredict = AS.Common.Utils.Helper.GetInt(selIsPredict.Value, 1);
        }
        if (invent_war.Value == "")
        {
            team.invent_war = 0;
        }
        else
        {
            team.invent_war = Convert.ToInt32(invent_war.Value);
        }
        team.brand_id = Convert.ToInt32(this.ddlbrand.SelectedValue);

        if (shanghu.SelectedIndex > 0)
        {

            ///添加分站id
            ///
            if (Request.Form["fenzhan"] != null)
            {
                if (int.Parse(Request.Form["fenzhan"].ToString()) == 0)
                {
                    team.branch_id = 0;
                }
                else
                {
                    team.branch_id = int.Parse(Request.Form["fenzhan"].ToString());
                }

            }

            if (Request.Form["xiaoshou"] != null)
            {
                if (int.Parse(Request.Form["xiaoshou"].ToString()) == 0)
                {
                    team.sale_id = 0;
                }
                else
                {
                    team.sale_id = int.Parse(Request.Form["xiaoshou"].ToString());
                }
            }
        }


        string[] bulletinteam = team.bulletin.Replace("{", "").Replace("}", "").TrimEnd(',').Split(',');
        int cou = 0;
        if (team.bulletin != "")
        {
            cou = bulletinteam.Length;
        }
        team.bulletin = addcolor(cou);
        if (int.Parse(Request.Form["groupType"].ToString()) > -1)
        {

            team.Group_id = int.Parse(Request.Form["groupType"].ToString());
        }
        //项目分类的关键字
        team.catakey = Request["birds"];
        team.cataid = AS.Common.Utils.Helper.GetInt(Request["parent"], 0);//项目分类的编号


        team.commentscore = Convert.ToDecimal( AS.Common.Utils.Helper.GetDouble(commentscore.Value, 0));//评论的返利的金额
        team.cost_price = Convert.ToDecimal(Cost_price.Value); //项目的成本价格
        
        if (team.Delivery == "coupon")
        {
            team.teamway = Request["way"];//项目的购买的方式
            if (Request["isrefund"].ToString() != String.Empty && Request["isrefund"] != null)
            {
                team.isrefund = Request["isrefund"];//退款方式
            }
            else
            {
                team.isrefund = isrefund;
            }
        }
        else
        {
            team.teamway = expressway.SelectedValue; //购买的方式
        }

        team.apiopen = AS.Common.Utils.Helper.GetInt(Request["apiopen"], 0);
        team.shanhu = Convert.ToInt32(Request["shanhu"]);
        team.Conduser = Conduse.SelectedItem.Value;
        team.Buyonce = Buyonce.SelectedItem.Value;

        int titlelenth = System.Text.Encoding.Default.GetByteCount(title.Value);
        if (titlelenth > 500)
        {
            SetError("项目标题长度不能大于500个字符！");
            Response.Redirect("Project_BianjiXiangmu.aspx?id=" + HiddenField1.Value);
            Response.End();
            return;
        }
        team.Title = HttpUtility.HtmlEncode(title.Value);
        team.Market_price = Convert.ToDecimal(market_price.Value);
        team.Team_price = Convert.ToDecimal(teamPrice.Value);
        team.Min_number = int.Parse(minnumber.Value);
        team.Max_number = int.Parse(maxnumber.Value);
        team.Per_number = int.Parse(pernumber.Value);
        team.Per_minnumber = Convert.ToInt32(per_minnumber.Value);
        team.score = int.Parse(score.Value);
        DateTime btime = AS.Common.Utils.Helper.GetDateTime(begintime.Value, DateTime.MinValue);
        DateTime etime = AS.Common.Utils.Helper.GetDateTime(endtime.Value, DateTime.MinValue);

        team.codeswitch = this.ddlcode.SelectedValue;
        team.othercity = Request.Form["city_id"];

        if (Request.Form["ddlarea"] != null)
        {
            team.areaid = int.Parse(Request.Form["ddlarea"]);
        }
        if (Request.Form["ddlarea"] != null && Request.Form["ddlcircle"] != null)
        {
            team.circleid = int.Parse(Request.Form["ddlcircle"]);
        }
        else
        {
            team.circleid = 0;
        }

        if (rech_time.Value != "")
        {
            try
            {
                team.Reach_time = DateTime.Parse(rech_time.Value);
            }
            catch (Exception ex)
            {
                SetError("您输入的成团日期格式不正确,请重新输入");
            }
        }
        else
        {
            team.Reach_time = null;
        }

        if (closetime.Value != "")
        {
            try
            {
                team.Close_time = DateTime.Parse(closetime.Value);
            }
            catch (Exception ex)
            {
                SetError("您输入的卖光日期格式不正确,请重新输入");
            }

        }
        else
        {
            team.Close_time = null;
        }

        if (btime == DateTime.MinValue)
        {

        }
        else
        {
            if (etime == DateTime.MinValue)
            {

            }
            else
            {
                TimeSpan ts = etime - btime;
                if (expiretime.Value != "")
                {
                    team.Expire_time = Convert.ToDateTime(Convert.ToDateTime(expiretime.Value).ToString("yyyy-MM-dd 23:59:59"));
                }
                else
                {
                    team.Expire_time = Convert.ToDateTime(Convert.ToDateTime(endtime.Value).ToString("yyyy-MM-dd 23:59:59"));
                }
            }
        }
        team.System = "N";

        team.Begin_time = Convert.ToDateTime(begintime.Value);
        team.End_time = Convert.ToDateTime(endtime.Value.ToString());
        if (expiretime.Value != "")
        {

            team.Expire_time = Convert.ToDateTime(Helper.GetDateTime(expiretime.Value, DateTime.Now).ToString("yyyy-MM-dd 23:59:59"));
        }
        team.Summary = createsummary.Value;
        team.Notice = creatnotice.Value;
        int partnerID = AS.Common.Utils.Helper.GetInt(shanghu.SelectedItem.Value,0);
        //如果商户ID发生了变化则为true
        bool partnerIDHasChange = (partnerID == team.Partner_id) ? false : true;
        if (partnerID > 0)
        {
            team.Partner_id = partnerID;
            ////根据商户id找到销售人员id
            using (IDataSession sessioin = AS.GroupOn.App.Store.OpenSession(false))
            {
                mpartner = sessioin.Partners.GetByID(partnerID);
            }
            team.sale_id = AS.Common.Utils.Helper.GetInt(mpartner.sale_id,0);
        }
        else
        {
            team.sale_id = 0;
            team.Partner_id = 0;
        }
        //在项目表中添加sale_id 同时更新到partner表中
        team.Card = int.Parse(createcard.Value);
        team.Bonus = int.Parse(createbonus.Value);
        team.Product = createproduct.Value;
        if (Image.FileName != null || Image1.FileName != null || Image2.FileName != null)
        {
            createUpload = setUpload();
        }
        if (Image.FileName != null && Image.FileName.ToString() != "")
        {
            #region 上传图片
            string path = "";
            string uploadName = Image.FileName;//获取待上传图片的完整路径，包括文件名 

            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            int idx = uploadName.LastIndexOf(".");
            string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

            if (suffix.ToLower() == ".jpg" || suffix.ToLower() == ".png" || suffix.ToLower() == ".gif" || suffix.ToLower() == ".jpeg" || suffix.ToLower() == ".bmp")
            {
                pictureName = DateTime.Now.Ticks.ToString() + suffix;
            }
            else
            {
                SetError("图片格式不正确！");
                Response.Redirect("Project_BianjiXiangmu.aspx");
                return;
            }

            try
            {
                if (uploadName != "")
                {
                    path = Server.MapPath(createUpload);
                    Image.PostedFile.SaveAs(path + pictureName);


                    //生成缩略图
                    string strOldUrl = path + pictureName;
                    string strNewUrl = path + "small_" + pictureName;
                    AS.Common.Utils.ImageHelper.CreateThumbnailNobackcolor(strOldUrl, strNewUrl, 235, 150);


                    //图片加水印
                    string drawuse = "";
                    string drawimgType = "";
                    AS.Common.Utils.ImageHelper.DrawImgWord(createUpload + pictureName, ref drawuse, ref drawimgType, _system);

                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            createUpload = createUpload.Replace("~", "");
            team.Image = createUpload + pictureName;
            #endregion
        }
        else
        {
            if (Request["imget"] != "")
            {
                team.Image = Request["imget"];
            }


        }

        if (team.Image == null || team.Image == "")
        {
            SetError("图片不能为空！");
            Response.Redirect("Project_BianjiXiangmu.aspx?id=" + team.Id);
            Response.End();
        }

        if (Image1.FileName != null && Image1.FileName.ToString() != "")
        {
            #region 上传图片1


            string uploadName = Image1.FileName;//获取待上传图片的完整路径，包括文件名 
            //string uploadName = InputFile.PostedFile.FileName; 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 

            int idx = uploadName.LastIndexOf(".");
            string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

            if (suffix.ToLower() == ".jpg" || suffix.ToLower() == ".png" || suffix.ToLower() == ".gif" || suffix.ToLower() == ".jpeg" || suffix.ToLower() == ".bmp")
            {
                pictureName = DateTime.Now.Ticks.ToString() + 1 + suffix;
            }
            else
            {
                SetError("图片格式不正确！");
                Response.Redirect("Project_BianjiXiangmu.aspx");
                return;
            }


            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(createUpload);
                    Image1.PostedFile.SaveAs(path + pictureName);


                    //图片加水印
                    string drawuse = "";
                    string drawimgType = "";
                    AS.Common.Utils.ImageHelper.DrawImgWord(path + pictureName, ref drawuse, ref drawimgType, _system);
                    if (drawuse == "1")
                    {
                        if (drawimgType == "0")
                        {
                            pictureName = "syp_" + pictureName;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            createUpload = createUpload.Replace("~", "");
            team.Image1 = createUpload + pictureName;
            #endregion
        }
        else
        {
            if (Request["imget1"] != "")
            {
                team.Image1 = Request["imget1"];
            }

        }
        if (Image2.FileName != null && Image2.FileName.ToString() != "")
        {
            #region 上传图片2

            string uploadName = Image2.FileName;//获取待上传图片的完整路径，包括文件名 
            //string uploadName = InputFile.PostedFile.FileName; 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 

            int idx = uploadName.LastIndexOf(".");
            string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 
            if (suffix.ToLower() == ".jpg" || suffix.ToLower() == ".png" || suffix.ToLower() == ".gif" || suffix.ToLower() == ".jpeg" || suffix.ToLower() == ".bmp")
            {
                pictureName = DateTime.Now.Ticks.ToString() + 2 + suffix;
            }
            else
            {
                SetError("图片格式不正确！");
                Response.Redirect("Project_BianjiXiangmu.aspx");
                return;
            }



            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(createUpload);
                    Image2.PostedFile.SaveAs(path + pictureName);


                    //图片加水印
                    string drawuse = "";
                    string drawimgType = "";
                    AS.Common.Utils.ImageHelper.DrawImgWord(createUpload + "\\" + pictureName, ref drawuse, ref drawimgType, _system);

                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            createUpload = createUpload.Replace("~", "");
            team.Image2 = createUpload + pictureName;
            #endregion

        }
        else
        {
            if (Request["imget2"] != "")
            {
                team.Image1 = Request["imget2"];
            }

        }
        team.Flv = createflv.Value;
        team.Detail = createdetail.Value;
        team.Userreview = createuserreview.Value;
        team.Systemreview = creatsystemreview.Value;
        isdraw(team.Id);
        if (ishdraw == false)
        {
            team.drawType = AS.Common.Utils.Helper.GetInt(Request["dtype"], 0);//抽奖方式，0:默认为随机,1按顺序生成
            //team.drawType = 5;//抽奖方式，0:默认为随机,1按顺序生成
        }

        //  team.drawType = 1;
        if (projectType.SelectedItem.Value != "point")
        {
            team.teamscore = 0;
        }
        else
        {
            team.teamscore = AS.Common.Utils.Helper.GetInt(teamscore.Value, 0);
        }

        team.teamhost = Helper.GetInt(Request["host"], 0);
        // team.teamnew = Utils.Helper.GetInt(Request["teamnew"], 0);//首页新品推荐
        if (Request.Form["radio"] != null)
        {
            team.Delivery = Request.Form["radio"].ToString();
        }
        if (Request["team_create_now_update"] != null && Request["team_create_now_time"] != null && Request["team_create_now_update"].ToString() != "" && Request["team_create_now_time"].ToString() != "")
        {
            team.update_value = Convert.ToInt32(Request["team_create_now_update"].ToString());
            team.time_state = Convert.ToInt32(Request["team_create_now_time"].ToString());
        }
        if (team.Delivery == "coupon")
        {
            ispoint = true;
            team.Fare = 0;
            //team.teamway = Request.Form["way"];//项目的购买的方式
        }
        else
        {
            //team.teamway = Request.Form["freighttype"];
            try
            {
                team.Fare = Convert.ToInt32(createfare.Value);
                team.cashOnDelivery = Helper.GetString(ddlCashOnDelivery.SelectedValue, "0");
            }
            catch (Exception)
            {

                SetError("您输入的快递费用格式不正确,请重新输入");
            }
        }
        try
        {
            team.Credit = Convert.ToInt32(createcredit.Value);
        }
        catch (Exception)
        {

            SetError("您输入的消费返利格式不正确,请重新输入");
        }
        team.Mobile = createmobile.Value;
        team.Address = createaddress.Value;

        try
        {
            if (Request["freighttype"] == "0")
            {
                team.Farefree = Convert.ToInt32(createfarefree.Value);
                team.freighttype = 0;
            }
            else if (Request["freighttype"] == "1")
            {
                team.Farefree = Convert.ToInt32(farefree2.Value);
                team.freighttype = Helper.GetInt(faretemplate_drop.SelectedValue, 0);
            }


        }
        catch (Exception)
        {

            SetError("您输入的名单数量不正确,请重新输入");
        }
        team.Express = createexpress.Value;
        //判断状态



        //是否是手动更新人数
        if (Request.Form["manualupdate"] != null && Request.Form["now_number"] != null && Request.Form["now_number"].ToString() != "" && Request.Form["manualupdate"].ToString() != "")
        {
            team.Manualupdate = 1;
            team.Now_number = Convert.ToInt32(Request.Form["now_number"].ToString());

            int count = 0;
            if (Request.Form["now_number"] != null && Request.Form["now_number"].ToString() != "")
            {
                count = Convert.ToInt32(Request.Form["now_number"].ToString());
            }
            else
            {
                count = 0;
            }
            if (System.DateTime.Now > Convert.ToDateTime(endtime.Value))
            {
                if (count > team.Min_number && team.State != "soldout")
                {
                    team.State = "success";
                }
                else
                {
                    team.State = "failure";
                }
            }
            else
            {
                if (count > team.Max_number && team.Max_number != 0)
                {
                    team.State = "soldout";
                }
                else
                {
                    team.State = "none";
                }
            }
        }
        else
        {
            team.Manualupdate = 0;

            //购买数量
            OrderFilter orderft = new OrderFilter ();
            OrderDetailFilter orderdetalft = new OrderDetailFilter();
            IList<IOrder> listOrder = null;
            IList<IOrderDetail> listorderdetail = null;
            orderft.State = "pay";
            orderft.Team_id = team.Id;
            orderdetalft.Teamid = team.Id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                listOrder = session.Orders.GetList(orderft);
                listorderdetail = session.OrderDetail.GetList(orderdetalft);
            }
            int count = listOrder.Count + listorderdetail.Count;
            team.Now_number = count;
            //判断选择的内容
            if (team.Conduser == "Y")
            {
                //以购买成功人数成团
                //订单数达到最低数量就成功，反则失败，如果订单数达到最高数量就属于卖光状态。
                //num.InnerText = "已购人数";
                if (System.DateTime.Now > Convert.ToDateTime(endtime.Value))
                {
                    if (count > team.Min_number && team.State != "soldout")
                    {
                        team.State = "success";
                    }
                    else
                    {
                        team.State = "failure";
                    }
                }
                else
                {
                    if (count > team.Max_number && team.Max_number != 0)
                    {
                        team.State = "soldout";
                    }
                    else
                    {
                        team.State = "none";
                    }
                }
            }
            else
            {

                //num.InnerText = "已购数量";
                //以产品购买数量成团
                //每个订单的购买数量*订单数大于最低数量就成功，反则失败，如果大于最高数量就属于卖光状态。
                int sumNumber = 0;
                foreach (IOrder item in listOrder)
                {
                    if (item.Quantity!=null)
                    {
                        sumNumber += item.Quantity;
                    }                    
                }
                foreach (IOrderDetail item in listorderdetail)
                {
                    if (item.Num != null)
                    {
                        sumNumber += item.Num;
                    }                    
                }
                team.Now_number = sumNumber;
                if (System.DateTime.Now > Convert.ToDateTime(endtime.Value))
                {
                    if (sumNumber > team.Min_number && team.State != "soldout")
                    {
                        team.State = "success";
                    }
                    else
                    {
                        team.State = "failure";
                    }
                }
                else
                {
                    if (sumNumber > team.Max_number && team.Max_number != 0)
                    {
                        team.State = "soldout";
                    }
                    else
                    {
                        team.State = "none";
                    }
                }
            }
        }
        team.time_interval = 0;
        if (Request.Form["team_create_autolimit"] != null && Request.Form["team_create_autolimit"].ToString() != "")
        {
            team.autolimit = Convert.ToInt32(Request.Form["team_create_autolimit"].ToString());
        }
        if (createStarttime.Value != null && createStarttime.Value != "")
        {
            team.start_time = Convert.ToDateTime(createStarttime.Value);
        }
        else
        {
            team.start_time = Convert.ToDateTime(begintime.Value);
        }

        //#region 同时修改项目下面的优惠券的有效日期
        //couponbll.updatetime(team.Id, team.Expire_time);
        //#endregion

        if (Request.Form["ddllevelcity"] != null)
        {
            team.level_cityid = Helper.GetInt(Request.Form["ddllevelcity"].ToString(), 0);
        }
        else
        {
            team.level_cityid = 0;
        }
        //项目排序
        team.Sort_order = int.Parse(createsort_order.Value);
        if (ispoint && team.teamscore > 0)
        {
            SetSuccess("友情提示：积分项目无法选择优惠券");
            Response.Redirect("Project_BianjiXiangmu.aspx?id=" + team.Id + "");
        }
        else
        {
            if (team.Delivery == "coupon" && Getbulletin(team.bulletin) != "")
            {
                team.bulletin = "";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int id3 = session.Teams.Update(team);
                }                
                //如果项目的商户发生变化则更新到优惠券表中
                if (partnerIDHasChange)
                {
                    ICoupon coupon = null;
                    CouponFilter couponft = new CouponFilter();                    
                    couponft.Team_id = team.Id;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        coupon = session.Coupon.Get(couponft);
                        coupon.Partner_id = partnerID;
                        int id4 = session.Coupon.Update(coupon);
                    }
                }
                SetSuccess("友情提示：更新成功，优惠券项目没有规格");

            }
            else
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int id3 = session.Teams.Update(team);
                } 
            }
            Response.Redirect("Project_BianjiXiangmu.aspx?id=" + team.Id + "&d=d");
        }
    }

    #region 项目替换
    public static string Getbulletin(string bulletin)
    {
        string str = bulletin.Replace("{", "").Replace(":", "").Replace("[", "").Replace("]", "").Replace("}", "");
        return str;
    }
    #endregion
    /// <summary>
    /// 显示文件夹信息
    /// </summary>

    public string setUpload()
    {
        string result1 = "~/upload/team/";
        string path = Server.MapPath("~/upload/team/");
        if (!System.IO.Directory.Exists(path))
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
    
    public CategoryFilter categoryft = new CategoryFilter();
    protected void ddlProduct_SelectedIndexChanged(object sender, EventArgs e)
    {
        //api分类初始化
        DataTable dt = null;
        categoryft.Zone = "group";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            dt = AS.Common.Utils.Helper.ToDataTable(session.Category.GetList(categoryft).ToList());
        }
        BindApiData(dt, 0, "");

        cataloglist();
        setcity("", "", "");
        ishide(0);
        string productid = ddlProduct.SelectedValue;
        youhuiquan1 = "checked=\"checked\"";
        kuaidi1 = "";
        draw = "";
        drawmobile = "display:none;";
        youhuiquan = " display:block;";
        kuaidi = " display:none;";
        if (productid != "0")
        {
            IProduct productmodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                productmodel = session.Product.GetByID(int.Parse(productid));
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
                            bulletin += "属性：<input type=\"text\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + ">数值：<input type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + "><input type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
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

        }

    }

</script>
<%LoadUserControl("_header.ascx", null); %>
<%if (AS.Common.Utils.Helper.GetInt(team.open_invent, 0) == 1&&Request["d"]=="d")
  {%>
<script language='javascript'>
    if (!confirm('友情提示：该项目已开启库存功能，是否进行出入库操作！')) { location.href = 'Project_DangqianXiangmu.aspx' } else { X.get('/ManBranch/ajax_coupon.aspx?action=invent&p=d&inventid=<%=team.Id %>') }</script>
  <%}%>
<script type="text/javascript" language="javascript">

    function setTime() {
        jQuery("#begintime").attr("datatype", "<%=beginCss %>");
        jQuery("#endtime").attr("datatype", "<%=endCss %>");
    }
    function setTimeTxt(obj) {
        var type = obj.value;

        if (type == "seconds" || type == "normal") {
            var begin = document.getElementById("begintime").value + "<%=begin %>";
            var end = document.getElementById("endtime").value + "<%=end %>";
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
            //            $("#dnew").hide();
            $("#field_notice").hide();
            $("#summery").hide();
            $("#field_userreview").hide();
            $("#field_systemreview").hide();
            $("#express_zone_coupon").hide();
            $("#express_zone_express").show();
            $("#fanli").hide();
            $("#start").hide();
            $("#dway").hide();
            $("#refund").hide();
            $("#drawmobile").hide();
            $("#drawtype").hide();

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
            $("#divIsPredict").hide();
        } else {
            $("#dparent").show();
            $("#dbrand").show();
            $("#dhost").show();
            //            $("#dnew").show();
            $("#field_notice").show();
            $("#summery").hide();
            $("#field_userreview").show();
            $("#field_systemreview").show();
            $("#express_zone_express").hide();
            $("#express_zone_coupon").show();
            $("#fanli").show();
            $("#start").show();
            $("#dway").show();
            $("#refund").hide();
            $("#drawmobile").hide();
            $("#drawtype").hide();
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
            if (obj.value != "goods") {
                $("#divIsPredict").show();
            }
        }
    }

    jQuery(function () {
        $("input[type=radio]").click(function () {
            if ($("input[type=radio]:checked").val() == "coupon") {

                $("#express_zone_express").hide();
                $("#express_zone_coupon").show();
                $("#fanli").show();
                $("#start").show();
                $("#dway").show();
                $("#refund").show();
                $("#drawmobile").hide();
                $("#drawtype").hide();
            }
            else if ($("input[type=radio]:checked").val() == "express") {
                $("#express_zone_coupon").hide();
                $("#express_zone_express").show();

                $("#fanli").hide();
                $("#start").hide();
                $("#dway").hide();
                $("#refund").hide();
                $("#drawmobile").hide();
                $("#drawtype").hide();
            } else if ($("input[type=radio]:checked").val() == "draw") {
                $("#express_zone_coupon").hide();
                $("#express_zone_express").hide();
                $("#fanli").hide();
                $("#start").hide();
                $("#dway").hide();
                $("#refund").hide();
                $("#drawmobile").show();
                $("#drawtype").show();
            } else if ($("input[type=radio]:checked").val() == "pcoupon") {
                $("#express_zone_express").hide();
                $("#express_zone_coupon").show();
                $("#fanli").hide();
                $("#start").show();
                $("#dway").hide();
                $("#refund").hide();
                $("#drawmobile").hide();
                $("#drawtype").hide();
            }

            if ($(this).attr("id") == "freighttype0") {
                $("#type0").show();
                $("#type1").hide();
            }
            else if ($(this).attr("id") == "freighttype1") {
                $("#type1").show();
                $("#type0").hide();
            }
        });

    });

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
            cell.innerHTML = "属性：<input type=\"text\" name=\"StuName" + num + "\">数值：<input type=\"text\" name=\"Stuvalue" + num + "\"><input type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
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
            $("#key").html("<img src='" + webroot + "upfile/css/i/ajax-loader.gif'>");
            $.ajax({
                type: "POST",
                url: webroot + "ajax/ajax_key.aspx?id=" + obj.value + "",

                success: function (msg) {
                    if (msg != "") {
                        $("#key").html(msg);
                    } else {
                        $("#key").html("<img src='" + webroot + "upfile/css/i/ajax-loader.gif'>");
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
    function getcircle() {
        var str = jQuery("#ddlarea").val();

        $.ajax({
            type: "POST",
            url: webroot + "manage_ajax_Areadroplist.aspx?zone=circle",
            data: { "cityid": str },
            success: function (msg) {

                $("#lblcircle").html(msg);

            }
        });

    }

    function getlevelcity() {
        var levelcity = jQuery("#ddllevelcity").val();

        $.ajax({
            type: "POST",
            url: webroot + "manage_ajax_othercitys.aspx",
            data: { "lcity": levelcity },
            success: function (msg) {

                $("#cityother").html(msg);
            }
        });

        $.ajax({
            type: "POST",
            url: webroot + "manage_ajax_Areadroplist.aspx?zone=levelcity",
            data: { "cityid": levelcity },
            success: function (msg) {
                $("#lblarea").html(msg);
                $("#lblcircle").html("");
            }
        });
    }

    $(document).ready(function () {



        var str = jQuery("#city").val();
        var strothercityid = $("#hidcitys").val();
        if (str != "") {

            if (str == "0") {
                $('[name=cityall]').attr('disabled', true);
            } else {
                $('[name=cityall]').attr('disabled', false);
            }
            $.ajax({
                type: "POST",
                url: webroot + "manage_ajax_othercitys.aspx?type=edit",
                data: { "cityid": str, "othercityid": strothercityid },
                success: function (msg) {

                    $("#cityother").html(msg);

                }
            });

            $.ajax({
                type: "POST",
                url: webroot + "manage_ajax_Areadroplist.aspx?zone=area",
                data: { "cityid": str },
                success: function (msg) {
                    $("#lblcircle").html("");
                    var msgarray = msg.split('&');
                    if (msgarray[0] == "1") {
                        $("#lblarea").html(msgarray[1]);
                        $("#level_city").hide();
                        $("#level_city").html("");
                    }
                    else {
                        $("#level_city").show();
                        $("#level_city").html(msgarray[1]);
                        $("#lblarea").html("");
                    }
                }
            });
        }
    });

</script>
<script type="text/javascript">
    $(document).ready(function () {
        var str = jQuery("#shanghu").val();

        //销售人员
        if (str != "" & str != "0") {
            $("#saleceng").show();
            $.ajax({
                type: "POST",
                url: webroot + "manage_ajax_getsales.aspx",
                data: { "partnerid": str ,"team_id":<%=team_id %>},
                success: function (msg) {

                    $("#all_Sales").html(msg);

                }
            });
        }
        else {
            $("#saleceng").hide();
        }

        jQuery("#shanghu").change(function () {
            //            $("#saleceng").show();
            var str = jQuery("#shanghu").val();
            //            if (str == "0") {
            //                $("#saleceng").hide();
            //            }

            if (str != "" & str != "0") {
                $("#saleceng").show();
                $.ajax({
                    type: "POST",
                    url: webroot + "manage_ajax_getsales.aspx",
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

        //分站
        if (str != "" & str != "0") {
            $("#branchzeng").show();
            $.ajax({
                type: "POST",
                url: webroot + "manage_ajax_getbranch.aspx",
                data: { "partnerid": str,"team_id":<%=team_id %>  },
                success: function (msg) {

                    $("#all_branch").html(msg);

                }
            });
        }
        else {
            $("#branchzeng").hide();
        }

        $("#shanghu").change(function () {
            var str = $("#shanghu").val();

            if (str != "" & str != "0") {
                $("#branchzeng").show();
                $.ajax({
                    type: "POST",
                    url: webroot + "manage_ajax_getbranch.aspx",
                    data: { "partnerid": str },
                    success: function (msg) {

                        $("#all_branch").html(msg);

                    }
                });
            }
            else {

                $("#branchzeng").hide();
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
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons" class="mainwide">
                    <div id="content" class="box-content">
                        <div class="head">
                            <h2>
                                编缉项目</h2>
                            <span class="headtip">(<asp:Literal ID="Literal2" runat="server"></asp:Literal>)</span>
                        </div>
                        <div class="sect">
                            <div class="wholetip clear">
                                <h3>
                                    1、基本信息</h3>
                            </div>
                            <div class="field">
                                <label>
                                    产品</label>
                                <asp:DropDownList ID="ddlProduct" name="ddlProduct" runat="server" class="f-input"
                                    Style="width: 360px;" AutoPostBack="True" Enabled="false" OnSelectedIndexChanged="ddlProduct_SelectedIndexChanged">
                                </asp:DropDownList>
                            </div>
                            <div class="field">
                                <label>
                                    项目类型</label>
                                <asp:DropDownList ID="projectType" name="projectType" runat="server" class="f-input"
                                    Style="width: 160px;" onchange="setTimeTxt(this)">
                                </asp:DropDownList>
                            </div>
                            <div class="field" id="divIsPredict" runat="server">
                                <label>
                                    团购预告</label>
                                <select id="selIsPredict" name="isPredict" runat="server" style="float: left;">
                                    <option value="1">开启</option>
                                    <option value="0">关闭</option>
                                </select>
                            </div>
                            <div class="field" style='<%=hidepoint %>' id="dparent">
                                <label>
                                    项目分类</label>
                                <select id="parent" name="parent" style="width: 160px;" class="f-input" onChange="getkey(this)">
                                    <%if (cataid == 0)
                                      { %>
                                    <option value="0" selected="selected">请选择分类...</option>
                                    <% }
                                      else
                                      {%>
                                    <option value="0">请选择分类...</option>
                                    <% }%>
                                    <%=cata%>
                                </select>
                            </div>
                            <div class="field" style='<%=hidepoint %>'>
                                <label for="birds">
                                    关键字:
                                </label>
                                <input id="birds" size="30" name="birds" type="text" value='<%=keyword %>' />
                                <span class="hint" id="SPAN6">请输入关键词前几个字符，系统会自动匹配分类中类似的关键词。多个关键词以"，"号隔开。</span>
                            </div>
                            <div class="field" id="apitype" style='<%=hidepoint %>'>
                                <label>
                                    api分类</label>
                                <%--          <asp:DropDownList ID="groupType" name="groupType" class="f-input" runat="server"
                                            Style="width: 160px;">
                                        </asp:DropDownList>--%>
                                <select id="groupType" name="groupType" style="width: 160px;" class="f-input">
                                    <%if (apiid == 0)
                                      { %>
                                    <option value="0" selected="selected">==请选择api分类==</option>
                                    <% }
                                      else
                                      {%>
                                    <option value="0">==请选择api分类==</option>
                                    <% }%>
                                    <%=apicata%>
                                </select>
                            </div>
                            <div class="field" id="dbrand" style='<%=hidepoint %>'>
                                <label>
                                    品牌分类</label>
                                <asp:DropDownList ID="ddlbrand" name="ddlbrand" class="f-input" runat="server" Style="width: 160px;
                                    <%=hidepoint%>">
                                </asp:DropDownList>
                            </div>
                            <div class="field" id="dhost" style='<%=hidepoint %>'>
                                <label>
                                    首页推荐</label>
                                <select id="host" name="host" style="width: 160px;" class="f-input">
                                    <%if (host == 0)
                                      { %>
                                    <option value="0" selected="selected">请选择</option>
                                    <option value="1">新品</option>
                                    <option value="2">推荐</option>
                                    <% }
                                      else if (host == 1)
                                      {%>
                                    <option value="0">请选择</option>
                                    <option value="1" selected="selected">新品</option>
                                    <option value="2">推荐</option>
                                    <% }
                                      else if (host == 2)
                                      {%>
                                    <option value="0">请选择</option>
                                    <option value="1">新品</option>
                                    <option value="2" selected="selected">推荐</option>
                                    <% }%>
                                </select>
                                <span class="hint" id="SPAN7">仅一日多团4和一日多团5可用</span>
                            </div>
                            <div class="field" id="field_city" class="f-input" style="height: 38px;">
                                <label id="label1" runat="server">
                                    城市</label>
                                <asp:DropDownList ID="city" name="city" runat="server" class="f-input" Width="157px">
                                </asp:DropDownList>
                                <label id="level_city" <%=isDispaly %>>
                                    <%=strlevelcity %>
                                </label>
                                <label id="lblarea">
                                    <%=strAreas %>
                                </label>
                                <label id="lblcircle">
                                    <%=strcircle %>
                                </label>
                            </div>
                           <%-- <div class="city-list">
                                <label id="label2" runat="server">
                                    输出至其它城市</label>
                                <input type="hidden" name="hidcitys" id="hidcitys" value="<%=strothercityid%>">
                                <div id="cityother" class="city-box">
                                    <%if (cityid == 0)
                                      { %>
                                    <input type='checkbox' name='cityall' id="cityall" onclick="checkallcity()" value=""
                                        disabled />&nbsp;全选
                                    <% }
                                      else
                                      {%>
                                    <input type='checkbox' name='cityall' id="cityall" onclick="checkallcity()" value="" />&nbsp;全选
                                    <% }%>
                                    <br>
                                    <%=strcitys%>
                                </div>
                            </div>--%>
                            <div class="field" id="field_limit">
                                <label>
                                    限制条件</label>
                                <asp:DropDownList ID="Conduse" class="f-input" Style="width: 160px;" runat="server">
                                </asp:DropDownList>
                                <asp:DropDownList ID="Buyonce" class="f-input" Style="width: 160px;" runat="server">
                                </asp:DropDownList>
                            </div>
                            <div class="field">
                                <label>
                                    项目标题</label>
                                <input type="text" size="30" name="title" id="title" class="f-input" value="" group="g"
                                    require="true" datatype="require" runat="server" />
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
                                <input type="text" size="30" name="seokeyword" id="seokeyword" class="f-input" maxlength="250"
                                    group="g" runat="server" /><span class="inputtip"></span>
                            </div>
                            <div class="field">
                                <label>
                                    SEO描述</label>
                                <input type="text" size="30" name="seodescription" id="seodescription" class="f-input"
                                    maxlength="1000" group="g" runat="server" /><span class="inputtip"></span>
                            </div>
                            <%if (productid == 0 || bulletin != "")
                              { %>
                            <div class="field">
                                <label>
                                    项目规格</label>
                                <%if (invenStatus == 0)
                                  { %>
                                <input type="button" name="btnAddFile" class="formbutton" value="添加" onClick="additem('tb')" />
                                <%} %>
                                <font style='color: red; margin-left:10px;'>例如：属性填写：颜色 数值填写：红色|黄色|蓝色</font>
                            </div>
                            <div class="field">
                                <label>
                                </label>
                                <table id="tb">
                                    <%=bulletin%>
                                </table>
                                <input type="hidden" name="totalNumber" value="0" />
                            </div>
                            <%} %>
                            <div class="field">
                                <label>
                                    市场价</label>
                                <input type="text" size="10" name="market_price" id="market_price" class="number"
                                    group="g" value="1" datatype="money" require="true" runat="server" />
                                <div id="price" style='<%=hidepoint %>'>
                                    <label>
                                        网站价</label>
                                    <input type="text" size="10" name="team_price" id="teamPrice" class="number" value="1"
                                        group="g" datatype="double" require="true" runat="server" />
                                </div>
                                <div id="pscore" style='<%=showpoint %>'>
                                    <label>
                                        兑换积分</label>
                                    <input type="text" size="10" name="teamscore" id="teamscore" class="number" value="0"
                                        group="g" datatype="number" runat="server" />
                                </div>
                                <label>
                                    最低购买数量</label>
                                <input type="text" size="10" name="per_minnumber" id="per_minnumber" class="number"
                                    group="g" value="1" maxlength="6" datatype="number" require="true" runat="server" />
                            </div>
                            <div class="field" id="field_num">
                                <label>
                                    成团最低数量</label>
                                <input type="text" size="10" name="min_number" id="minnumber" class="number" group="g"
                                    value="1" maxlength="6" datatype="number" require="true" runat="server" />
                                <label>
                                    最高数量</label>
                                <input type="text" size="10" name="max_number" id="maxnumber" class="number" group="g"
                                    value="10" maxlength="6" datatype="number" require="true" runat="server" />
                                <label>
                                    每单限购</label>
                                <input type="text" size="10" name="per_number" id="pernumber" class="number" group="g"
                                    value="1" maxlength="6" datatype="number" require="true" runat="server" />
                                <span class="hint">最低数量必须大于0，最高数量/每人限购：0 表示没最高上限 （产品数|人数 由成团条件决定）</span>
                            </div>
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
                                    <%=num %>
                                    <input type="text" size="10" name="now_number" id="team-create-now-number" class="number_a"
                                        value="<%=headSum %>" group="g" maxlength="6" datatype="integer" /></div>
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
                                    开始时间</label>
                                <input type="text" name="begin_time" id="begintime" group="g" require="true" datatype="datetime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});"
                                    class="date" runat="server" />
                                <label>
                                    结束时间</label><input type="text" name="end_time" id="endtime" group="g" require="true" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});"
                                        datatype="datetime" class="date" runat="server" />
                                <div id="ctime" style='<%=hidepoint %>'>
                                    <label>
                                        优惠券有效期</label>
                                    <input type="text" size="10" name="expire_time" id="expiretime" class="number" maxlength="10"
                                        group="g" datatype="date" runat="server" />
                                    <span class="hint" id="SPAN1" runat="server">时间格式：hh:ii:ss (例：14:05:58)，日期格式：YYYY-MM-DD
                                        （例：2010-06-10）</span>
                                </div>
                            </div>
                            <div class="field">
                                <label>
                                    成本价</label>
                                <input type="text" name="Cost_price" id="Cost_price" group="g" datatype="money" class="date"
                                    value="0" runat="server" />
                                <span class="hint" id="SPAN8" runat="server">用于商户结算</span>
                            </div>
                            <div class="field">
                                <label>
                                    成团时间</label>
                                <input type="text" name="rech_time" id="rech_time" datatype="datetime" class="date"  onfocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});"
                                    value="" runat="server" />
                                <span class="hint" id="SPAN3" runat="server">日期格式:（例：2010-06-10 00:00:00）</span>
                            </div>
                            <div class="field">
                                <label>
                                    卖光时间</label><input type="text" name="closetime" style="width: 120px;" datatype="datetime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});"
                                        class="date" id="closetime" runat="server" /><span class="hint" id="SPAN5" runat="server">日期格式:（例：2010-06-10
                                            00:00:00）</span>
                            </div>
                            <div class="field">
                                <label>
                                    排序</label>
                                <input type="text" size="10" name="sort_order" id="createsort_order" group="g" class="number"
                                    value="0" datatype="number" runat="server" /><span class="inputtip">请填写数字，数值大到小排序，主推团购应设置较大值</span>
                            </div>
                            <div class="field" id="fscore" style='<%=hidepoint %>'>
                                <label>
                                    返利积分值</label>
                                <input type="text" size="10" name="invent_war" id="score" class="number" value="0"
                                    maxlength="10" group="g" datatype="number" runat="server" /><span class="inputtip">积分值</span>
                            </div>
                            <div class="field" id="summery" style='<%=hidepoint%>'>
                                <label>
                                    本单简介</label>
                                <div style="float: left;">
                                    <textarea cols="45" rows="5" name="summary" id="createsummary" class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"
                                        datatype="require" require="true" runat="server"></textarea></div>
                            </div>
                            <div class="field" id="field_notice" style='<%=hidepoint%>'>
                                <label>
                                    特别提示</label>
                                <div style="float: left;">
                                    <textarea cols="45" rows="5" name="notice" id="creatnotice" class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"
                                        runat="server"></textarea></div>
                                <span class="hint">关于本单项目的有效期及使用说明</span>
                            </div>
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
                            <div class="field">
                                <label>
                                    库存数量</label>
                                <span class="inputtip">
                                    <%=inven%></span>
                            </div>
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
                                <asp:DropDownList ID="shanghu" runat="server" Style="float: left;" CssClass="f-shinput">
                                </asp:DropDownList>
                                <span class="inputtip">商户为可选项</span>
                            </div>
                            <%-- 商户分站id --%>
                            <div class="field" id="branchzeng" style="display: none;">
                                <label>
                                    选择分站</label><div id="all_branch">
                                    </div>
                                <span class="inputtip">如不选择，默认不变</span>
                            </div>
                            <%-- 增加销售人员id --%>
                            <div class="field" id="saleceng" style="display: none;">
                                <label>
                                    销售人员</label><div id="all_Sales">
                                    </div>
                                <span class="inputtip">如不选择，默认不变</span>
                            </div>
                            <div class="field" id="Div4">
                                <label>
                                    项目详情页展示</label>
                                <select id="shanhu" name="shanhu" style="float: left;">
                                    <%if (shanhu == 0)
                                      { %>
                                    <option value="0" selected="selected">左右两列</option>
                                    <option value="1">通栏模式</option>
                                    <% }
                                      else if (shanhu == 1)
                                      {%>
                                    <option value="1" selected="selected">通栏模式</option>
                                    <option value="0">左右两列</option>
                                    <% }
                                      else
                                      {%>
                                    <option value="0">左右两列</option>
                                    <option value="1">通栏模式</option>
                                    <% }%>
                                </select>
                                <span class="inputtip"></span>
                            </div>
                            <div class="field">
                                <label>
                                    api输出</label>
                                <select id="Select1" name="apiopen" style="float: left;">
                                    <%if (api == 0)
                                      { %>
                                    <option value="0" selected="selected">开启</option>
                                    <option value="1">关闭</option>
                                    <% }
                                      else
                                      {%>
                                    <option value="0">开启</option>
                                    <option value="1" selected="selected">关闭</option>
                                    <% }%>
                                </select>
                                <span class="inputtip">是否开启api输出</span>
                            </div>
                            <div class="field" id="field_card">
                                <label>
                                    代金券使用</label>
                                <input type="text" size="10" name="card" id="createcard" group="g" class="number"
                                    value="0" require="true" datatype="money" runat="server" />
                                <span class="inputtip">可使用代金券最大面额</span>
                            </div>
                            <div class="field" id="Div1">
                                <label>
                                    邀请返利</label>
                                <input type="text" size="10" name="bonus" id="createbonus" group="g" class="number"
                                    value="0" require="true" datatype="number" runat="server" />
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
                                    datatype="require" require="true" runat="server" />
                            </div>
                            <div class="field">
                                <label>
                                    商品图片</label>
                                <asp:FileUpload ID="Image" runat="server" size="30" group="g" require="true" class="f-input" />
                                <label id="ImageSet" class="hint" runat="server">
                                </label>
                            </div>
                            <div id="img0" class="field">
                                <label>
                                    引用其他图片</label>
                                <input type="text" size="30" name="imget" id="imget" class="f-input" />
                            </div>
                            <div class="field">
                                <label>
                                    商品图片1</label>
                                <asp:FileUpload ID="Image1" runat="server" size="30" class="f-input" />
                                <label id="lblImg1" class="hint" runat="server">
                                </label>
                            </div>
                            <div id="img1" class="field">
                                <label>
                                    引用其他图片1</label>
                                <input type="text" size="30" name="imget1" id="imget1" class="f-input" />
                            </div>
                            <div class="field">
                                <label>
                                    商品图片2</label>
                                <asp:FileUpload ID="Image2" runat="server" size="30" class="f-input" />
                                <label id="lblImg2" class="hint" runat="server">
                                </label>
                            </div>
                            <div id="img2" class="field">
                                <label>
                                    引用其他图片2</label>
                                <input type="text" size="30" name="imget2" id="imget2" class="f-input" />
                            </div>
                            <div class="field">
                                <label>
                                    FLV视频短片</label>
                                <input type="text" size="30" name="flv" id="createflv" class="f-input" runat="server" />
                                <span class="hint" id="SPAN2" runat="server">形式如：http://.../video.flv</span>
                            </div>
                            <div class="field">
                                <label>
                                    本单详情</label>
                                <div style="float: left;">
                                    <textarea cols="45" style="height: 500px;" rows="5" name="detail" id="createdetail"
                                        group="g" require="true" class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"
                                        runat="server"></textarea></div>
                            </div>
                            <div class="field" id="field_userreview" style='<%=hidepoint %>'>
                                <label>
                                    网友点评</label>
                                <div style="float: left;">
                                    <textarea cols="45" rows="5" name="userreview" id="createuserreview" style='<%=hidepoint %>'
                                        class="f-textarea" runat="server"></textarea></div>
                                <span class="hint">格式：“真好用|小兔|http://ww....|XXX网”，每行写一个点评</span>
                            </div>
                            <div class="field" id="field_systemreview" style='<%=hidepoint %>'>
                                <label>
                                    <%--<%=ASSystemArr["abbreviation"] %>--%>推广辞</label>
                                <div style="float: left;">
                                    <textarea cols="45" rows="5" name="systemreview" id="creatsystemreview" style='<%=hidepoint %>'
                                        class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"
                                        runat="server"></textarea></div>
                            </div>
                            <div class="wholetip clear">
                                <h3>
                                    4、配送信息</h3>
                            </div>
                            <div class="field">
                                <label>
                                    递送方式</label>
                                <div id="zonediv">
                                    <div id="coupon" style='<%=hidepoint %>; <%=hideyhq %>'>
                                        <input id="zonediv1" name="radio" type="radio" value="coupon" <%=youhuiquan1 %> />优惠券</div>
                                    <div id="draw" style='<%=hidepoint %>; <%=hideyhq %>'>
                                        <input id="zonediv3" type="radio" name="radio" value="draw" <%=draw %> />抽奖</div>
                                    <div id="express" class="daoru">
                                        <input id="zonediv2" name="radio" type="radio" value="express" <%=kuaidi1 %> />快递</div>
                                    <div id="pcoupon" style='<%=hidepoint %>; <%=hideyhq %>'>
                                        <input id="Radio1" name="radio" type="radio" value="pcoupon" <%=pcoupon %> />导入站外券</div>
                                </div>
                            </div>
                            <div class="field" id="drawmobile" style="<%=drawmobile%>">
                                <label>
                                    短信验证</label>
                                <asp:DropDownList ID="ddlcode" runat="server" Style="float: left; width: 45px;">
                                </asp:DropDownList>
                                <span class="inputtip">抽奖项目是否需要短信验证</span>
                            </div>
                            <div class="field" id="drawtype" style="<%=drawmobile%>">
                                <label>
                                    抽奖方式</label>
                                <%if (dtype == "0")
                                  { %>
                                <input id="Radio2" type="radio" name="dtype" value="0" checked="checked" <%if(ishdraw){ %>disabled="disabled<% } %>" />按随机
                                <input id="Radio3" type="radio" name="dtype" value="1" <%if(ishdraw){ %>disabled="disabled<% } %>" />按顺序
                                <% }
                                  else if (dtype == "1")
                                  {%>
                                <input id="Radio4" type="radio" name="dtype" value="0" <%if(ishdraw){ %>disabled="disabled<% } %>" />按随机
                                <input id="Radio5" type="radio" name="dtype" value="1" checked="checked" <%if(ishdraw){ %>disabled="disabled<% } %>" />按顺序
                                <% }%>
                                <span style="color: #666666; font-size: 12px; margin-left: 0; margin-top: 5px;">抽奖项目如果生产抽奖号码，那么就不可以选择抽奖方式</span>
                            </div>
                            <div id="express_zone_coupon" style="<%=youhuiquan %>">
                                <div class="field" id="fanli" style="<%=tfan%>">
                                    <label>
                                        消费返利</label>
                                    <input type="text" size="10" name="credit" group="g" id="createcredit" class="number"
                                        value="0" datatype="money" require="true" runat="server" />
                                    <span class="inputtip">消费优惠券时，获得账户余额返利，单位CNY元</span>
                                </div>
                                <div class="field" id="start">
                                    <label>
                                        优惠券开始时间</label>
                                    <input type="text" size="10" name="start_time" id="createStarttime" group="g" datatype="date"
                                        class="date" runat="server" />
                                    <span class="inputtip">生成优惠券时的开始时间 （格式：2011-01-01）</span>
                                </div>
                                <div class="field" id="dway" style="<%=tfan%>">
                                    <label>
                                        结算方式</label>
                                    <select id="way" name="way" class="f-input" style="width: 160px;">
                                        <%if (way == "Y")
                                          { %>
                                        <option value="Y" selected="selected">按实际购买的数量</option>
                                        <option value="N">按实际消费的数量</option>
                                        <% }
                                          else
                                          {%>
                                        <option value="Y">按实际购买的数量</option>
                                        <option value="N" selected="selected">按实际消费的数量</option>
                                        <% }%>
                                    </select>
                                </div>
                                <div class="field"  style="<%=tkfs%>"  id="refund">
                                    <label>
                                        退款方式</label>
                                    <select id="isrefund" name="isrefund" class="f-input" style="width: 210px;">
                                        <%if (isrefund == "Y")
                                          { %>
                                        <option value="N">不支持7天退款以及过期退款</option>
                                        <option value="S">仅支持7天退款</option>
                                        <option value="G">仅支持过期退款</option>
                                        <option value="Y" selected="selected">支持7天退款以及过期退款</option>
                                        <% }
                                          else if (isrefund == "S")
                                          {%>
                                        <option value="N">不支持7天退款以及过期退款</option>
                                        <option value="S" selected="selected">仅支持7天退款</option>
                                        <option value="G">仅支持过期退款</option>
                                        <option value="Y">支持7天退款以及过期退款</option>
                                        <% }
                                          else if (isrefund == "G")
                                          {%>
                                        <option value="N">不支持7天退款以及过期退款</option>
                                        <option value="S">仅支持7天退款</option>
                                        <option value="G" selected="selected">仅支持过期退款</option>
                                        <option value="Y">支持7天退款以及过期退款</option>
                                        <% }
                                          else if (isrefund == "N")
                                          {%>
                                        <option value="N" selected="selected">不支持7天退款以及过期退款</option>
                                        <option value="S">仅支持7天退款</option>
                                        <option value="G">仅支持过期退款</option>
                                        <option value="Y">支持7天退款以及过期退款</option>
                                        <% }%>
                                    </select>
                                </div>
                            </div>
                            <div id="express-zone-pickup" style="display: none;">
                                <div class="field">
                                    <label>
                                        联系电话</label>
                                    <input type="text" size="10" name="mobile" id="createmobile" class="f-input" value=""
                                        runat="server" />
                                </div>
                                <div class="field">
                                    <label>
                                        自取地址</label>
                                    <input type="text" size="10" name="address" id="createaddress" class="f-input" value=""
                                        runat="server" />
                                </div>
                            </div>
                            <div id="express_zone_express" style="<%=kuaidi %>">
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
                                        <input name="freighttype" id="freighttype0" type="radio" <%if(!isfaretemplate){ %>checked="checked"
                                            <%} %> value="0">填写快递费</label>
                                    <label>
                                        <input name="freighttype" id="freighttype1" type="radio" <%if(isfaretemplate){ %>checked="checked"
                                            <%} %> value="1">使用快递模板 (<a href='fare_template.aspx'>编辑快递模板</a>)</label>
                                </div>
                                <div class="field" id="type1" <%if(!isfaretemplate){ %>style="display:none;" <%} %>>
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
                                <div class="field" id="type0" <%if(isfaretemplate){ %>style="display:none;" <%} %>>
                                    <label>
                                        快递费用</label>
                                    <input type="text" size="10" name="fare" id="createfare" group="g" class="number"
                                        value="5" maxlength="6" datatype="money" require="true" runat="server" />
                                    <label>
                                        免单数量</label>
                                    <input type="text" size="10" name="farefree" id="createfarefree" class="number" group="g"
                                        value="0" maxlength="6" datatype="money" require="true" runat="server" />
                                    <span class="hint">快递费用，免单数量：0表示不免运费，2表示，购买2件免运费</span>
                                </div>
                                <div class="field">
                                    <label style="display: none;">
                                        快递配送说明</label>
                                    <div style="float: left; display: none;">
                                        <textarea cols="45" rows="5" name="express" id="createexpress" class="f-textarea"
                                            runat="server"></textarea></div>
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
                                <asp:HiddenField ID="HiddenField1" runat="server" />
                                <input type="submit" value="好了，提交" name="commit" id="leadesubmit" group="g" class="validator formbutton" onclick="return freighttype1_onclick()" />
                                <script type="text/javascript">
                                    function freighttype1_onclick() {
                                        if ($("#ImageSet").html().trim() == "" && $("#Image").val().trim() == "") {
                                            alert("请上传商品图片");
                                            return false;
                                        }

                                    }                                    
                                </script>
                                <asp:HiddenField ID="hfimg1" runat="server" />
                                <asp:HiddenField ID="hidbranch" runat="server" />
                                <asp:HiddenField ID="hidsale" runat="server" />
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