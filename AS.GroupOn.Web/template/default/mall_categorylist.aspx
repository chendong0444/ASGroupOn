<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    //所有父类
    //public List<Maticsoft.Model.catalogs> catalogsParentAll = new List<Maticsoft.Model.catalogs>();
    protected IList<ICatalogs> catalogsParentAll = null;
    //是否存在父类
    protected bool isCatalogsParentAll = false;
    //是否存在子类
    protected bool isCatalogsChildAll = false;
    //是否存在品牌
    protected bool isBrandAll = false;
    //是否存在折扣
    public bool isDiscountAll = false;
    //是否存在价格
    public bool isPriceAll = false;
    
    //选择的项目分类id
    protected int catalogid = 0;
    //是否选择了父类
    protected bool boolCatalogsParent = false;
    //是否选择了子类
    public bool boolCatalogsChild = false;
    //是否选择了品牌
    public bool boolBrand = false;
    //是否选择了折扣
    public bool boolDiscount = false;
    //是否选择了价格
    public bool boolPrice = false;
    
    
    //选择的父类id、名称
    protected int catalogParentId = 0;
    protected string catalogParentName = "";
    //选择的子类id、名称
    protected string catalogNameChild = "";
    protected int catalogIdChild = 0;

    //查询父类下的子类
    protected IList<ICatalogs> catalogsChildAll = null;
    

    //选择的父类
    protected ICatalogs catalogsParent = null;
    //public Maticsoft.Model.catalogs catalogsParent = new Maticsoft.Model.catalogs();

    //品牌
    //public Utils.DataTableObject brandAll = null;
    protected IList<ITeam> brandAll = null;
    public int cateBrandId = 0;
    public string cateBrandName = "";

    protected IPagers<ITeam> pagers = null;
    public IList<ITeam> pagerListTeam = null;
    public DataTable ds = null;
    //页数
    public string page = "1";
    //排序
    public string sort = " sort_order desc,id desc";
    //where
    protected TeamFilter teamfilter = new TeamFilter();
    //public string where = " teamcata=1 and mallstatus=1 ";
    //排序
    public int sortSelect = 0;
    //总数
    public int count = 0;
    public string pagerhtml = String.Empty;

    //折扣搜索
    public string discount = "0";
    public string strDiscount = "";
    public DataTable dtDiscount = null;
    public string discountFirst = "";
    public string discountEnd = "";

    //价格搜索
    public string price = "0";
    public string strPrice = "";
    public DataTable dtPrice = null;
    public string priceFirst = "";
    public string priceEnd = "";
    
    protected NameValueCollection _system = new NameValueCollection();
    public string keyword = "";
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();

        teamfilter.teamcata=1;
        teamfilter.mallstatus=1;
        
        
        #region 查询所有父类
        catalogsParentAll = GettopCataMall(0);
        //存在父类
        if (catalogsParentAll.Count > 0)
        {
            isCatalogsParentAll = true;
        }
        #endregion

        #region 选择了项目分类
        if (Request["catalogid"] != null && Request["catalogid"].ToString() != "" && Request["catalogid"].ToString() != "0")
        {
            if (NumberUtils.IsNum(Request["catalogid"].ToString()))
            {
                catalogid = int.Parse(Request["catalogid"].ToString());
                ICatalogs icatalogs = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    icatalogs = session.Catalogs.GetByID(catalogid);
                }
                //存在项目分类
                if (icatalogs != null)
                {

                    //catalogsSelcet = bllCatalogs.GetModel(catalogid);
                    #region 选择的是父类
                    if (icatalogs.parent_id == 0)
                    {
                        boolCatalogsParent = true;
                        catalogParentId = icatalogs.id;
                        catalogParentName = icatalogs.catalogname;

                        //IList<ICatalogs> iLCatalogsChild = null;
                        CatalogsFilter catalogsfilter = new CatalogsFilter();
                        catalogsfilter.parent_id = catalogParentId;
                        catalogsfilter.visibility = 0;
                        catalogsfilter.AddSortOrder(CatalogsFilter.MoreSort_DESC_ASC);
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            catalogsChildAll = session.Catalogs.GetList(catalogsfilter);
                        }
                        //catalogsChildAll = new Utils.DataTableObject(db.SqlExecDatatable("select *,0 as number from catalogs where parent_id=" + catalogParentId + " and visibility=0 order by sort_order desc,id asc"));
                        if (catalogsChildAll.Count > 0)
                        {
                            isCatalogsChildAll = true;
                            teamfilter.CataIDin = delsidechar(catalogParentId + "," + icatalogs.ids, ',');
                            //where += " and cataid in(" + delsidechar(catalogParentId + "," + icatalogs.ids, ',') + ")";
                        }
                        else
                        {
                            teamfilter.CataIDin = catalogParentId.ToString();
                            //where += " and cataid in(" + catalogParentId + ")";
                        }
                        //GetBrand(catalogParentId);
                    }
                    #endregion

                    #region 选择的是子类
                    else
                    {
                        boolCatalogsChild = true;
                        catalogIdChild = icatalogs.id;
                        catalogNameChild = icatalogs.catalogname;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            catalogsParent = session.Catalogs.GetByID(icatalogs.parent_id);
                        }
                        if (catalogsParent.parent_id == 0)
                        {
                            boolCatalogsParent = true;
                            catalogParentId = catalogsParent.id;
                            catalogParentName = catalogsParent.catalogname;

                            CatalogsFilter clogsfilter = new CatalogsFilter();
                            clogsfilter.parent_id = icatalogs.parent_id;
                            clogsfilter.visibility = 0;
                            clogsfilter.AddSortOrder(CatalogsFilter.MoreSort_DESC_ASC);
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                catalogsChildAll = session.Catalogs.GetList(clogsfilter);
                            }
                            if (catalogsChildAll.Count > 0)
                            {
                                isCatalogsChildAll = true;
                                teamfilter.CataIDin = delsidechar(icatalogs.id + "," + icatalogs.ids, ',');
                                //where += " and cataid in(" + delsidechar(catalogsSelcet.id + "," + catalogsSelcet.ids, ',') + ")";
                            }
                            //GetBrand(catalogIdChild);
                        }
                    }
                    #endregion

                }
                else
                {
                    //SetError("分类不存在");
                    GetInfoNo();
                }
            }
            else
            {
                //SetError("非法参数");
                GetInfoNo();
            }
        }
        else
        {
            //未选择项目分类
            GetInfoNo();
        }
        #endregion

        GetBrand(catalogid);

        #region 选择了品牌分类
        string brandid = "";
        ICategory category = null;
        
        if (Request["brandid"] != null && Request["brandid"].ToString() != "" && Request["brandid"].ToString() != "0")
        {
            if (NumberUtils.IsNum(Request["brandid"].ToString()))
            {
                brandid = Request["brandid"].ToString();

                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    category = session.Category.GetByID(int.Parse(brandid));
                }
                if (category != null && category.Zone == "brand")
                {
                    boolBrand = true;
                    cateBrandId = category.Id;
                    cateBrandName = category.Name;
                    teamfilter.BrandID = Convert.ToInt32(brandid);
                    //where += " and brand_id=" + brandid;
                }
            }
        }
        else if (Request["amp;brandid"] != null && Request["amp;brandid"].ToString() != "" && Request["amp;brandid"].ToString() != "0")
        {
            if (NumberUtils.IsNum(Request["amp;brandid"].ToString()))
            {
                brandid = Request["amp;brandid"].ToString();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    category = session.Category.GetByID(int.Parse(brandid));
                }
                if (category != null && category.Zone == "brand")
                {
                    boolBrand = true;
                    cateBrandId = category.Id;
                    cateBrandName = category.Name;
                    teamfilter.BrandID = Convert.ToInt32(brandid);
                    //where += " and brand_id=" + brandid;
                }
            }
        }
        #endregion

        GetGood();

        #region 折扣搜索
        if (_system["malldiscount"] != null && _system["malldiscount"] != "")
        {
            strDiscount = _system["malldiscount"];
            string[] sDiscount = strDiscount.Split('|');
            dtDiscount = new DataTable();
            dtDiscount.Columns.Add("first", typeof(string));
            dtDiscount.Columns.Add("end", typeof(string));
            for (int i = 0; i < sDiscount.Length; i++)
            {
                DataRow drDiscount = dtDiscount.NewRow();
                if (sDiscount[i].ToString() != "")
                {
                    isDiscountAll = true;
                    string[] ssDiscount = sDiscount[i].ToString().Split(',');
                    drDiscount["first"] = ssDiscount[0];
                    drDiscount["end"] = ssDiscount[1];
                    dtDiscount.Rows.Add(drDiscount);
                }
            }
        }
        #endregion

        #region 价格搜索
        if (_system["mallprice"] != null && _system["mallprice"] != "")
        {
            strPrice = _system["mallprice"];
            string[] sPrice = strPrice.Split('|');
            dtPrice = new DataTable();
            dtPrice.Columns.Add("first", typeof(string));
            dtPrice.Columns.Add("end", typeof(string));
            for (int i = 0; i < sPrice.Length; i++)
            {
                DataRow drPrice = dtPrice.NewRow();
                if (sPrice[i].ToString() != "")
                {
                    isPriceAll = true;
                    string[] ssPrice = sPrice[i].ToString().Split(',');
                    drPrice["first"] = ssPrice[0];
                    drPrice["end"] = ssPrice[1];
                    dtPrice.Rows.Add(drPrice);
                }
            }
        }
        #endregion

        #region 根据筛选条件显示项目
        if (Request["page"] != null && Request["page"].ToString() != "")
        {
            if (NumberUtils.IsNum(Request["page"].ToString()))
            {
                page = Request["page"].ToString();
            }
        }

        #region 折扣
        if (Request["discount"] != null && Request["discount"].ToString() != "" && Request["discount"] != "0")
        {
            string[] dis = Request["discount"].ToString().Split('-');
            if (IsN(dis[0].ToString()) && IsN(dis[1].ToString()))
            {
                boolDiscount = true;
                discountFirst = dis[0].ToString();
                discountEnd = dis[1].ToString();
                discount = Request["discount"].ToString();
                teamfilter.FromMarketPrice = Convert.ToDouble(dis[0].ToString()) * 0.1;
                teamfilter.ToMarketPrice = Convert.ToDouble(dis[1].ToString()) * 0.1;
                //where += " and Team_price/case Market_price when 0 then null else Market_price end>=" + Convert.ToDouble(dis[0].ToString()) * 0.1 + " and Team_price/case Market_price when 0 then null else Market_price end<=" + Convert.ToDouble(dis[1].ToString()) * 0.1;
            }
        }
        else if (Request["amp;discount"] != null && Request["amp;discount"].ToString() != "" && Request["amp;discount"] != "0")
        {
            string[] dis = Request["amp;discount"].ToString().Split('-');
            if (IsN(dis[0].ToString()) && IsN(dis[1].ToString()))
            {
                boolDiscount = true;
                discountFirst = dis[0].ToString();
                discountEnd = dis[1].ToString();
                discount = Request["amp;discount"].ToString();
                teamfilter.FromMarketPrice = Convert.ToDouble(dis[0].ToString()) * 0.1;
                teamfilter.ToMarketPrice = Convert.ToDouble(dis[1].ToString()) * 0.1;
                //where += " and Team_price/case Market_price when 0 then null else Market_price end>=" + Convert.ToDouble(dis[0].ToString()) * 0.1 + " and Team_price/case Market_price when 0 then null else Market_price end<=" + Convert.ToDouble(dis[1].ToString()) * 0.1;
            }
        }
        #endregion

        #region 价格
        if (Request["price"] != null && Request["price"].ToString() != "" && Request["price"] != "0")
        {
            string[] pri = Request["price"].ToString().Split('-');
            if (IsN(pri[0].ToString()) && IsN(pri[1].ToString()))
            {
                boolPrice = true;
                priceFirst = pri[0].ToString();
                priceEnd = pri[1].ToString();
                price = Request["price"].ToString();
                teamfilter.FromTeam_price = pri[0].ToString();
                teamfilter.ToTeam_price = pri[1].ToString();
                //where += " and Team_price>=" + pri[0].ToString() + " and Team_price<=" + pri[1].ToString();
            }
        }
        else if (Request["amp;price"] != null && Request["amp;price"].ToString() != "" && Request["amp;price"] != "0")
        {
            string[] pri = Request["amp;price"].ToString().Split('-');
            if (IsN(pri[0].ToString()) && IsN(pri[1].ToString()))
            {
                boolPrice = true;
                priceFirst = pri[0].ToString();
                priceEnd = pri[1].ToString();
                price = Request["amp;price"].ToString();
                teamfilter.FromTeam_price = pri[0].ToString();
                teamfilter.ToTeam_price = pri[1].ToString();
                //where += " and Team_price>=" + pri[0].ToString() + " and Team_price<=" + pri[1].ToString();
            }
        }
        #endregion

        #region 排序
        if (Request["sort"] != null && Request["sort"].ToString() != "" && Request["sort"].ToString() != "0")
        {
            if (NumberUtils.IsNum(Request["sort"].ToString()))
            {
                //人气
                if (Request["sort"] == "1")
                {
                    sortSelect = 1;
                    teamfilter.AddSortOrder(TeamFilter.Nownumber_DESC);
                    //sort = " Now_number desc";
                }
                if (Request["sort"] == "2")
                {
                    sortSelect = 2;
                    teamfilter.AddSortOrder(TeamFilter.Nownumber_ASC);
                    //sort = " Now_number asc";
                }
                //价格
                if (Request["sort"] == "3")
                {
                    sortSelect = 3;
                    teamfilter.AddSortOrder(TeamFilter.Team_Price_Desc);
                    //sort = " Team_price desc";
                }
                if (Request["sort"] == "4")
                {
                    sortSelect = 4;
                    teamfilter.AddSortOrder(TeamFilter.Team_Price_ASC);
                    //sort = " Team_price asc";
                }
                //折扣
                if (Request["sort"] == "5")
                {
                    sortSelect = 5;
                    //sql = "*,Team_price/case Market_price when 0 then null else Market_price end as discount";
                    teamfilter.AddSortOrder(TeamFilter.Discounts_DESC);
                    //sort = " discount desc";
                }
                if (Request["sort"] == "6")
                {
                    sortSelect = 6;
                    //sql = "*,Team_price/case Market_price when 0 then null else Market_price end as discount";
                    teamfilter.AddSortOrder(TeamFilter.Discounts_ASC);
                    //sort = " discount asc";
                }
            }
        }
        else if (Request["amp;sort"] != null && Request["amp;sort"].ToString() != "" && Request["amp;sort"].ToString() != "0")
        {
            if (NumberUtils.IsNum(Request["amp;sort"].ToString()))
            {
                //人气
                if (Request["amp;sort"] == "1")
                {
                    sortSelect = 1;
                    teamfilter.AddSortOrder(TeamFilter.Nownumber_DESC);
                    //sort = " Now_number desc";
                }
                if (Request["amp;sort"] == "2")
                {
                    sortSelect = 2;
                    teamfilter.AddSortOrder(TeamFilter.Nownumber_ASC);
                    //sort = " Now_number asc";
                }
                //价格
                if (Request["amp;sort"] == "3")
                {
                    sortSelect = 3;
                    teamfilter.AddSortOrder(TeamFilter.Team_Price_Desc);
                    //sort = " Team_price desc";
                }
                if (Request["amp;sort"] == "4")
                {
                    sortSelect = 4;
                    teamfilter.AddSortOrder(TeamFilter.Team_Price_ASC);
                    //sort = " Team_price asc";
                }
                //折扣
                if (Request["amp;sort"] == "5")
                {
                    sortSelect = 5;
                    //sql = "*,Team_price/case Market_price when 0 then null else Market_price end as discount";
                    teamfilter.AddSortOrder(TeamFilter.Discounts_DESC);
                    //sort = " discount desc";
                }
                if (Request["amp;sort"] == "6")
                {
                    sortSelect = 6;
                    //sql = "*,Team_price/case Market_price when 0 then null else Market_price end as discount";
                    teamfilter.AddSortOrder(TeamFilter.Discounts_ASC);
                    //sort = " discount asc";
                }
            }
        }
        else
        {
            teamfilter.AddSortOrder(TeamFilter.MoreSort3);
        }
        #endregion

        #region 关键字
        if (Request["keyword"] != null && Request["keyword"].ToString() != "")
        {
            keyword = Helper.GetString(Request["keyword"], "");
            teamfilter.KeyWord = keyword;
            //where += " and (title like '%" + keyword + "%' or catakey like '%" + keyword + "%')";
        }
        #endregion

        //list = bllTeam.SearchTeam(30, Convert.ToInt32(page), sql, sort, where, out count);
        teamfilter.PageSize = 30;
        teamfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pagers= session.Teams.GetPagerTeambuy(teamfilter);
        }
        pagerListTeam = pagers.Objects;
        //pager = Maticsoft.DBUtility.DbHelperSQL.SelectByPager(sql, where, sort, Convert.ToInt32(page), 30, "team", "", "");
        count = pagers.TotalRecords;
        if (keyword != "")
        {
            pagerhtml = WebUtils.GetPagerHtml(30, pagers.TotalRecords, int.Parse(page), BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, 0, sortSelect, discount, price) + "?keyword=" + keyword + "&page={0}");
        }
        else
        {
            pagerhtml = WebUtils.GetPagerHtml(30, pagers.TotalRecords, int.Parse(page), BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, cateBrandId, sortSelect, discount, price) + "?page={0}");
        }
        #endregion
    }

    #region 显示大类：商城
    protected IList<ICatalogs> GettopCataMall(int cityid)
    {
        IList<ICatalogs> iLCatalogs = null;
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        catalogsfilter.type = 1;
        catalogsfilter.parent_id = 0;
        catalogsfilter.visibility = 0;
        catalogsfilter.AddSortOrder(CatalogsFilter.MoreSort);
        
        if (cityid == 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iLCatalogs = session.Catalogs.GetList(catalogsfilter);
            }
        }
        else
        {
            catalogsfilter.cityidLikeOr = cityid;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iLCatalogs = session.Catalogs.GetList(catalogsfilter);
            }
        }
        return iLCatalogs;
    }
    #endregion

    #region 未选择项目分类
    protected void GetInfoNo()
    {
        if (isCatalogsParentAll == true)
        {
            boolCatalogsParent = true;
            catalogParentId = catalogsParentAll[0].id;
            //catalogid = catalogsParentAll[0].id;
            catalogid = 0;
            catalogParentName = catalogsParentAll[0].catalogname;

            CatalogsFilter catalogsfilter = new CatalogsFilter();
            catalogsfilter.parent_id = catalogParentId;
            catalogsfilter.visibility = 0;
            catalogsfilter.AddSortOrder(CatalogsFilter.MoreSort_DESC_ASC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                catalogsChildAll = session.Catalogs.GetList(catalogsfilter);
            }
            if (catalogsChildAll.Count > 0)
            {
                isCatalogsChildAll = true;
            }

        }
    }
    #endregion

    #region 获取品牌
    protected void GetBrand(int catalogid)
    {
        ICatalogs catalogrow = null;
        if (catalogid > 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                catalogrow = session.Catalogs.GetByID(catalogid);
            }
        }
        IList<ICatalogs> iLCatalogsbig = null;
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        catalogsfilter.parent_id = 0;
        catalogsfilter.visibility = 0;
        catalogsfilter.AddSortOrder(CatalogsFilter.MoreSort_ASC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iLCatalogsbig = session.Catalogs.GetList(catalogsfilter);
        }
        string ids = String.Empty;
        foreach (ICatalogs icatalogsInfo in iLCatalogsbig)
        {
            ids = icatalogsInfo.id.ToString();
            if (icatalogsInfo.ids.Length > 0) ids = ids + "," + icatalogsInfo.ids;
            ids = delsidechar(ids, ',');
            int num = 0;
            TeamFilter tfilter = new TeamFilter();
            tfilter.teamcata = 1;
            tfilter.cityidIn = ids;
            tfilter.Team_type = "normal";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                num = session.Teams.GetCount(tfilter);
            }
            //icatalogsInfo.SetValue("number", num);
            //row.SetValue("number", db.SqlExecDataRow("select count(*) as number from Team where  teamcata=1 and cataid in(" + ids + ") and Team_type='normal' ").ToInt("number", 0));
        }
        if (catalogrow != null)
        {
            IList<ICatalogs> childcatalogss = null;
            CatalogsFilter cfilter = new CatalogsFilter();
            cfilter.visibility = 0;
            cfilter.AddSortOrder(CatalogsFilter.MoreSort_ASC);

            if (catalogrow.parent_id == 0)
            {
                cfilter.parent_id = catalogrow.id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    childcatalogss = session.Catalogs.GetList(cfilter);
                }
            }
            else
            {
                cfilter.parent_id = catalogrow.parent_id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    childcatalogss = session.Catalogs.GetList(cfilter);
                }
            }
            foreach (ICatalogs iclogsInfo in childcatalogss)
            {
                ids = iclogsInfo.id.ToString();
                if (iclogsInfo.ids.Length > 0) ids = ids + "," + iclogsInfo.ids;
                ids = ids.Replace(",,", ",");

                int num = 0;
                TeamFilter tfilter = new TeamFilter();
                tfilter.teamcata = 1;
                tfilter.cityidIn = ids;
                tfilter.Team_type = "normal";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    num = session.Teams.GetCount(tfilter);
                }
                //iclogsInfo.SetValue("number", num);
                //row.SetValue("number", db.SqlExecDataRow("select count(*) as number from Team where  teamcata=1 and cataid in(" + ids + ") and Team_type='normal'").ToInt("number", 0));
            }
        }
        if (catalogrow == null)
        {
            TeamFilter tfilters = new TeamFilter();
            tfilters.teamcata = 1;
            tfilters.Team_type = "normal";
            tfilters.FromBrand_id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                brandAll = session.Teams.GetBrandAll(tfilters);
            }
            //brandAll = new Utils.DataTableObject(db.SqlExecDatatable("select top 11 t.*,category.name from (select brand_id,count(*) as number from Team where  teamcata=1 and Team_type='normal'  and brand_id>0 group by brand_id)t left join category on(t.brand_id=category.id)   order by number desc"));
        }
        else
        {
            ids = catalogrow.id.ToString() + "," + catalogrow.ids;
            //ids = catalogrow["id"] + "," + catalogrow["ids"];
            ids = delsidechar(ids, ',');

            TeamFilter tfilters = new TeamFilter();
            tfilters.teamcata = 1;
            tfilters.Team_type = "normal";
            tfilters.FromBrand_id = 0;
            tfilters.CataIDin = ids;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                brandAll = session.Teams.GetBrandAll(tfilters);
            }
            //brandAll = new Utils.DataTableObject(db.SqlExecDatatable("select top 11 t.*,category.name from (select brand_id,count(*) as number from Team where  teamcata=1 and  cataid in(" + ids + ") and Team_type='normal'  and brand_id>0 group by brand_id)t left join category on(t.brand_id=category.id)  order by number desc"));
        }
        if (brandAll.Count > 0)
        {
            isBrandAll = true;
        }

    }
    #endregion

    #region 热销排行
    public void GetGood()
    {
        IList<ITeam> ilistteam = null;
        TeamFilter tfilters = new TeamFilter();
        tfilters.teamcata = 1;
        tfilters.mallstatus = 1;
        tfilters.AddSortOrder(TeamFilter.Nownumber_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistteam = session.Teams.GetList(tfilters);
        }
        ds = AS.Common.Utils.Helper.ToDataTable(ilistteam.ToList());
        
    }
    #endregion
    
    protected string delsidechar(string str, char c)
    {
        str = str.Replace(",,", ",");
        if (str.Length > 0 && str[0] == c)
            str = str.Substring(1);
        if (str.Length > 0 && str[str.Length - 1] == c)
        {
            str = str.Substring(0, str.Length - 1);
        }
        return str;
    }

    #region 判断是否为数字
    public static bool IsN(String str)
    {
        if (Regex.IsMatch(str, @"^\d+(\.\d+)?$"))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    #endregion
    
</script>
<%LoadUserControl("_htmlheader_mall.ascx", null); %>
<%LoadUserControl("_header_mall.ascx", null); %>
        <script src="/upfile/js/Mall.js" type="text/javascript"></script>
        <script type="text/javascript" src="/upfile/js/srolltop.js"></script>
        <script type="text/javascript">

            jQuery(function () {
                function b() {
                    d.each(function () {
                        typeof $(this).attr("original") != "undefined" && $(this).offset().top < $(document).scrollTop() + $(window).height() && $(this).attr("src", $(this).attr("original")).removeAttr("original")
                    })
                }
                var d = $(".dynload");
                $(window).scroll(function () {
                    b();

                    jQuery('img[w]').each(function () {
                        try {

                            var w = parseInt(jQuery(this).attr("w"));
                            var width = jQuery(this).width();
                            if (width > w) {
                                jQuery(this).css("width", w);
                            }
                        }
                        catch (e) { }
                    });
                });
                b();

            });
        </script>
        <script type="text/javascript" language="javascript">
            function cataShow() {
                var aCata = $("#aCata").text();
                if (aCata == "更多") {
                    $("#aCata").text("精简");
                    $("#divCata").css("height", "auto");
                }
                if (aCata == "精简") {
                    $("#aCata").text("更多");
                    $("#divCata").css("height", "22px");
                }
            }
            function brandShow() {
                var aBrand = $("#aBrand").text();
                if (aBrand == "更多") {
                    $("#aBrand").text("精简");
                    $("#divBrand").css("height", "auto");
                }
                if (aBrand == "精简") {
                    $("#aBrand").text("更多");
                    $("#divBrand").css("height", "22px");
                }
            }
            function discountShow() {
                var aDiscount = $("#aDiscount").text();
                if (aDiscount == "更多") {
                    $("#aDiscount").text("精简");
                    $("#divDiscount").css("height", "auto");
                }
                if (aDiscount == "精简") {
                    $("#aDiscount").text("更多");
                    $("#divDiscount").css("height", "22px");
                }
            }
            function priceShow() {
                var aPrice = $("#aPrice").text();
                if (aPrice == "更多") {
                    $("#aPrice").text("精简");
                    $("#divPrice").css("height", "auto");
                }
                if (aPrice == "精简") {
                    $("#aPrice").text("更多");
                    $("#divPrice").css("height", "22px");
                }
            }
        </script>
        <div id="bdw" class="bdw">
            <div id="shop_box" class="cf">
                <!--品牌商城（开始）-->
                <div class="brdlst_tbly">
                    <div class="brdlst_tb">
                        您现在的位置:&nbsp;&nbsp; <a href="<%=BaseUserControl.getMallPageUrl(Helper.GetString(_system["isrewrite"], "0")) %>">
                            <%=_system["mallsitename"]%></a><em>›</em> <a href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, 0, 0,"0","0") %>">
                                分类大全</a>
                        <%if (Request["catalogid"] != null && Request["catalogid"].ToString() != "" && Request["catalogid"].ToString() != "0")
                          { %>
                        <%if (boolCatalogsParent == true && boolCatalogsChild == false)
                          { %>
                        <em>›</em><a href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogParentId, 0, 0,"0" ,"0") %>"
                            class="pink bold">
                            <%=catalogParentName%></a>
                        <%} %>
                        <%else if (boolCatalogsChild == true)
                            { %>
                        <em>›</em><a href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogParentId, 0, 0,"0" ,"0") %>"
                            class="">
                            <%=catalogParentName%></a> <span class="pink bold"><em>›</em>
                                <%=catalogNameChild%></span>
                        <%} %>
                        <%} %>
                    </div>
                </div>
                <!--品牌商城-left（开始）-->
                <div class="brdlst_left">
                    <!--品牌商城-产品分类（开始）-->
                    <div id="basic-accordian" class="brdlst_cls">
                        <%--用户选择了父类--%>
                        <%if (boolCatalogsParent == true)
                          { %>
                        <div class="header_highlight">
                            <h3 class="c" id="c0">
                                <div class="basic_lb">
                                    <p>
                                       <a title="<%=catalogParentName%>" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogParentId, 0, 0,"0","0") %>"> <%=catalogParentName%></a></p>
                                </div>
                            </h3>
                            <%if (isCatalogsChildAll == true)
                              {%>
                            <ul class="brdlst_clsul" id="menuid">
                                <%foreach (ICatalogs catalogsChild in catalogsChildAll)
                                  { %>
                                <%if (catalogsChild.id.ToString() != catalogIdChild.ToString())
                                  {%>
                                <%--<li class=""><a title="<%=catalogsChild["catalogname"]%>" href="<%=getGoodsCatalistPageUrl(Utils.Helper.GetString(_system["isrewrite"], "0"), int.Parse(catalogsChild["id"]), cateBrandId, 0) %>">--%>
                                <li><a title="<%=catalogsChild.catalogname %>" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogsChild.id, 0, 0,"0","0") %>">
                                    <%=catalogsChild.catalogname%></a></li>
                                <%}%>
                                <%--用户选择了子类--%>
                                <%else
                                    { %>
                                <%if (boolCatalogsChild == true)
                                  { %>
                                <li class=""><a title="" class="brdlst_dq">
                                    <%=catalogNameChild%></a></li>
                                <%} %>
                                <%} %>
                                <%} %>
                            </ul>
                            <%} %>
                        </div>
                        <%} %>
                        <%--显示父类--%>
                        <% if (isCatalogsParentAll == true)
                           { %>
                        <%foreach (ICatalogs catalogsParent in catalogsParentAll)
                          { %>
                        <%if (catalogsParent.id != catalogParentId)
                          { %>
                        <div class="header_highlight">
                            <%--<a title="<%=catalogsParent.catalogname%>" href="<%=getGoodsCatalistPageUrl(Utils.Helper.GetString(_system["isrewrite"], "0"), catalogsParent.id, cateBrandId, 0) %>" class="bcls bcls1">--%>
                            <a title="<%=catalogsParent.catalogname%>" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogsParent.id, cateBrandId, 0,"0","0") %>"
                                class="bcls bcls1" style="cursor: pointer">
                                <div class="header_highlight_tittle">
                                    <%=catalogsParent.catalogname%></div>
                            </a>
                        </div>
                        <%} %>
                        <%} %>
                        <%} %>
                    </div>
                    <!--品牌商城-产品分类（结束）-->

                    <!--品牌商城-热销排行（开始）-->
                    <div class="brdlst_sidebox" style="border-bottom-style: none">
                        <h2>
                            热销排行</h2>
                        <ul class="brdlst_slist" id="brdlst_slist">
                            <div id="bm_slist0">
                                <script type="text/javascript">
                                    function goodShow(id) {
                                        //$("#" + id).show();
                                        this.document.getElementById(id).style.display = "";
                                        var hidden = this.document.getElementById("hidden").value;
                                        //if ($("#hidden").val() != id) {
                                        if (hidden != id) {
                                            //$("#" + $("#hidden").val()).hide();
                                            this.document.getElementById(hidden).style.display = "none";
                                        }
                                        //$("#hidden").val(id);
                                        this.document.getElementById("hidden").value = id;
                                    }
                                </script>
                                <ul>
                                    <%if (ds.Rows.Count > 0)
                                      { %>
                                    <%
                                          int s = 0;
                                          if (ds.Rows.Count > 10)
                                          {
                                              s = 10;
                                          }
                                          else
                                          {
                                              s = ds.Rows.Count;
                                          }
                                    %>
                                    <%for (int i = 0; i < s; i++)
                                      {
                                          %>
                                    <li><a class="brdlst_slname" title="<%=ds.Rows[i]["title"] %>" style="overflow: hidden"
                                        href="<%=BasePage.getTeamPageUrl(int.Parse(ds.Rows[i]["id"].ToString())) %>"
                                        target="_blank" onmouseover="goodShow(<%=ds.Rows[i]["id"] %>)"><span class="brdlst_slnum">
                                            <%=i+1 %></span><%=ds.Rows[i]["title"] %></a>
                                        <%if (i == 0)
                                          {%>
                                        <input type="hidden" id="hidden" value="<%=ds.Rows[i]["id"] %>" />
                                        <div class="bm_slimg brdlst_slimg" style="display: block" id="<%=ds.Rows[i]["id"] %>">
                                            <a title="<%=ds.Rows[i]["title"] %>" href="<%=BasePage.getTeamPageUrl(int.Parse(ds.Rows[i]["id"].ToString())) %>"
                                                target="_blank">
                                                <img alt="<%=ds.Rows[i]["title"] %>" <%=ashelper.getimgsrc(ImageHelper.good_getSmallImgUrl(ds.Rows[i]["image"].ToString(),206,131))%>
                                                    class="dynload" width="206" height="131" /></a><h3>
                                                        <%=ds.Rows[i]["title"] %></h3>
                                            <span class="Price"><b>现价：<%=ds.Rows[i]["team_price"]%></b><span class="old_pr">原价：<%=ds.Rows[i]["market_price"] %></span></span>
                                        </div>
                                        <%}
                                          else
                                          { %>
                                        <div class="bm_slimg brdlst_slimg" style="display: none" id="<%=ds.Rows[i]["id"] %>">
                                            <a title="<%=ds.Rows[i]["title"] %>" href="<%=getTeamPageUrl(int.Parse(ds.Rows[i]["id"].ToString())) %>"
                                                target="_blank">
                                                <img alt="<%=ds.Rows[i]["title"] %>" <%=ashelper.getimgsrc(ImageHelper.good_getSmallImgUrl(ds.Rows[i]["image"].ToString(),206,131))%>
                                                    class="dynload" width="206" height="131" /></a><h3>
                                                        <%=ds.Rows[i]["title"] %></h3>
                                            <span class="Price"><b>现价：<%=ds.Rows[i]["team_price"]%></b><span class="old_pr">原价：<%=ds.Rows[i]["market_price"] %></span></span>
                                        </div>
                                        <%} %>
                                    </li>
                                    <%} %>
                                    
                                </ul>
                            </div>
                        
                            <%} %>
                        </ul>
                    </div>

                </div>
                <!--品牌商城-left（结束）-->
                <!--品牌商城-right（开始）-->
                <div class="brdlst_right">
                    <div class="brdlst_clsmore">
                        <div class="fl bm_sottitly">
                            <div class="fl bm_sottit bm_sottit1">
                                <div class="bm_sottit_1">
                                    商品</div>
                                <div class="bm_sottit_2">
                                    分类</div>
                                <div class="bm_sottit_3">
                                    Category</div>
                            </div>
                            <div class="fr bm_smore2">
                                <a href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, 0, 0,"0","0") %>"
                                    title="">重新筛选条件</a></div>
                        </div>
                        <div class="lsttem">
                            <h4>
                                分类：</h4>
                            <div id="divCata" class="lsttemcon">
                                <ul>
                                    <%if (isCatalogsChildAll == true)
                                      {%>
                                    <%if (boolCatalogsChild == true)
                                      { %>
                                    <%--<li><a title="全部" href="<%=getGoodsCatalistPageUrl(Utils.Helper.GetString(_system["isrewrite"], "0"), catalogsParent.id, cateBrandId, 0) %>">--%>
                                    <li><a title="全部" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogsParent.id, 0, sortSelect,discount,price) %>">
                                        <span>全部</span></a> </li>
                                    <li><span class="current">
                                        <%=catalogNameChild%></span></li>
                                    <%}
                                      else
                                      { %>
                                    <li><span class="current">全部</span></li>
                                    <% }%>
                                    <%foreach (ICatalogs catalogsChild in catalogsChildAll)
                                      { %>
                                    <%if (catalogsChild.id.ToString() != catalogIdChild.ToString())
                                      {%>
                                    <%--<li><a title="<%=catalogsChild["catalogname"]%>" href="<%=getGoodsCatalistPageUrl(Utils.Helper.GetString(_system["isrewrite"], "0"), int.Parse(catalogsChild["id"]), cateBrandId, 0) %>">--%>
                                    <li><a title="<%=catalogsChild.catalogname%>" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogsChild.id, 0, sortSelect,discount,price) %>">
                                        <span>
                                            <%=catalogsChild.catalogname%></span></a></li>
                                    <%}%>
                                    <%}%>
                                    <%}
                                      else
                                      {%>
                                    <li><span class="current">全部</span></li>
                                    <%}%>
                                </ul>
                            </div>
                            <a onclick="cataShow()" style="cursor: pointer;" class="more_brand" id="aCata">更多</a>
                            <div class="clear">
                            </div>
                        </div>
                        <div class="lsttem">
                            <h4>
                                品牌：</h4>
                            <div id="divBrand" class="lsttemcon">
                                <ul>
                                    <%if (isBrandAll == true)
                                      {%>
                                    <%if (boolBrand == true)
                                      { %>
                                    <li><a title="全部" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, 0, sortSelect,discount,price) %>">
                                        <span>全部</span></a></li>
                                    <li><span class="current">
                                        <%=cateBrandName%></span></li>
                                    <%}
                                      else
                                      {%>
                                    <li><span class="current">全部</span></li>
                                    <%} %>
                                    <%foreach (ITeam brand in brandAll)
                                      { %>
                                    <%if (brand.brand_id.ToString() != cateBrandId.ToString())
                                      { %>
                                    <li><a title="<%=brand.Name %>" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, brand.brand_id, 0,discount,price) %>">
                                        <span>
                                            <%=brand.Name %></span></a></li>
                                    <%} %>
                                    <%} %>
                                    <%}
                                      else
                                      { %>
                                    <li><span class="current">全部</span></li>
                                    <%} %>
                                </ul>
                            </div>
                            <a onclick="brandShow()" style="cursor: pointer;" class="more_brand" id="aBrand">更多</a>
                            <div class="clear">
                            </div>
                        </div>
                        <div class="lsttem">
                            <h4>
                                折扣：</h4>
                            <div id="divDiscount" class="lsttemcon">
                                <ul>
                                    <%if (isDiscountAll == true)
                                      { %>
                                    <%if (boolDiscount == true)
                                      { %>
                                    <li>
                                        <%if (Request["catalogid"] == "0")
                                          { %>
                                        <a title="全部" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, cateBrandId, sortSelect,"0",price) %>">
                                            <%}
                                          else
                                          { %>
                                            <a title="全部" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, cateBrandId, sortSelect,"0",price) %>">
                                                <%} %>
                                                <span>全部</span></a></li>
                                    <span>
                                        <%} %>
                                        <%else
                                            { %>
                                        <li><span class="current">全部</span></li>
                                        <%} %>
                                        <%if (dtDiscount != null)
                                          {%>
                                        <%if (dtDiscount.Rows.Count > 0)
                                          {
                                              string showDiscount = "";
                                        %>
                                        <%for (int i = 0; i < dtDiscount.Rows.Count; i++)
                                          {
                                              showDiscount = dtDiscount.Rows[i]["first"].ToString() + "-" + dtDiscount.Rows[i]["end"].ToString();
                                        %>
                                        <%if ((discountFirst + "-" + discountEnd) != showDiscount)
                                          { %>
                                        <li>
                                            <%if (Request["catalogid"] == "0")
                                              { %>
                                            <a title="" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, cateBrandId, sortSelect,showDiscount,price) %>">
                                                <%}
                                              else
                                              { %>
                                                <a title="" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, cateBrandId, sortSelect,showDiscount,price) %>">
                                                    <%} %>
                                                    <span>
                                                        <%=dtDiscount.Rows[i]["first"]%>-<%=dtDiscount.Rows[i]["end"]%>折</span></a></li>
                                        <%}
                                          else
                                          { %>
                                        <li><span class="current">
                                            <%=discountFirst %>-<%=discountEnd %>折</span></li>
                                        <%} %>
                                        <%} %>
                                        <%} %>
                                        <%} %>
                                        <%}
                                      else
                                      { %>
                                        <li><span class="current">全部</span></li>
                                        <%} %>
                                </ul>
                            </div>
                            <a onclick="discountShow()" style="cursor: pointer;" class="more_brand" id="aDiscount">更多</a>
                            <div class="clear">
                            </div>
                        </div>
                        <div class="lsttem border0">
                            <h4>
                                价格：</h4>
                            <div id="divPrice" class="lsttemcon">
                                <ul>
                                    <%if (isPriceAll == true)
                                      { %>
                                    <%if (boolPrice == true)
                                      { %>
                                    <li>
                                        <%if (Request["catalogid"] == "0")
                                          { %>
                                        <a title="全部" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, cateBrandId, sortSelect,discount,"0") %>">
                                            <%}
                                          else
                                          { %>
                                            <a title="全部" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, cateBrandId, sortSelect,discount,"0") %>">
                                                <%} %>
                                                <span>全部</span></a></li>
                                    <span>
                                        <%} %>
                                        <%else
                                            { %>
                                        <li><span class="current">全部</span></li>
                                        <%} %>
                                        <%if (dtPrice != null)
                                          {%>
                                        <%if (dtPrice.Rows.Count > 0)
                                          {
                                              string showPrice = "";
                                        %>
                                        <%for (int j = 0; j < dtPrice.Rows.Count; j++)
                                          {
                                              showPrice = dtPrice.Rows[j]["first"].ToString() + "-" + dtPrice.Rows[j]["end"].ToString();
                                        %>
                                        <%if ((priceFirst + "-" + priceEnd) != showPrice)
                                          { %>
                                        <li>
                                            <%if (Request["catalogid"] == "0")
                                              { %>
                                            <a title="" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, cateBrandId, sortSelect,discount,showPrice) %>">
                                                <%}
                                              else
                                              { %>
                                                <a title="" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, cateBrandId, sortSelect,discount,showPrice) %>">
                                                    <%} %>
                                                    <span>
                                                        <%=dtPrice.Rows[j]["first"]%>-<%=dtPrice.Rows[j]["end"]%>元</span></a></li>
                                        <%}
                                          else
                                          { %>
                                        <li><span class="current">
                                            <%=priceFirst %>-<%=priceEnd %>元</span></li>
                                        <%} %>
                                        <%} %>
                                        <%} %>
                                        <%} %>
                                        <%}
                                      else
                                      { %>
                                        <li><span class="current">全部</span></li>
                                        <%} %>
                                </ul>
                            </div>
                            <a onclick="priceShow()" style="cursor: pointer;" class="more_brand" id="aPrice">更多</a>
                            <div class="clear">
                            </div>
                        </div>
                    </div>
                    <div class="brdlst_rol">
                        <div class="ssearchl">
                            <%if (Request["sort"] == "2" || Request["amp;sort"] == "2")
                              { %>
                            <%if (Request["catalogid"] == "0")
                              { %>
                            <a class="schlist_downbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, cateBrandId, 1,discount,price) %>">
                                人气</a>
                            <%}
                              else
                              { %>
                            <a class="schlist_downbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, cateBrandId, 1,discount,price) %>">
                                人气</a>
                            <%} %>
                            <%}
                              else
                              {%>
                            <%if (Request["catalogid"] == "0")
                              { %>
                            <a class="schlist_upbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, cateBrandId, 2,discount,price) %>">
                                人气</a>
                            <%}
                              else
                              { %>
                            <a class="schlist_upbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, cateBrandId, 2,discount,price) %>">
                                人气</a>
                            <%} %>
                            <%} %>
                            <%if (Request["sort"] == "4" || Request["amp;sort"] == "4")
                              { %>
                            <%if (Request["catalogid"] == "0")
                              { %>
                            <a class="schlist_downbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, cateBrandId, 3,discount,price) %>">
                                价格</a>
                            <%}
                              else
                              { %>
                            <a class="schlist_downbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, cateBrandId, 3,discount,price) %>">
                                价格</a>
                            <%} %>
                            <%}
                              else
                              { %>
                            <%if (Request["catalogid"] == "0")
                              { %>
                            <a class="schlist_upbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, cateBrandId, 4,discount,price) %>">
                                价格</a>
                            <%}
                              else
                              { %>
                            <a class="schlist_upbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, cateBrandId, 4,discount,price) %>">
                                价格</a>
                            <%} %>
                            <%} %>
                            <%if (Request["sort"] == "6" || Request["amp;sort"] == "6")
                              { %>
                            <%if (Request["catalogid"] == "0")
                              { %>
                            <a class="schlist_downbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, cateBrandId, 5,discount,price) %>">
                                折扣</a>
                            <%}
                              else
                              { %>
                            <a class="schlist_downbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, cateBrandId, 5,discount,price) %>">
                                折扣</a>
                            <%} %>
                            <%}
                              else
                              { %>
                            <%if (Request["catalogid"] == "0")
                              { %>
                            <a class="schlist_upbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, cateBrandId, 6,discount,price) %>">
                                折扣</a>
                            <%}
                              else
                              { %>
                            <a class="schlist_upbtn" href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), catalogid, cateBrandId, 6,discount,price) %>">
                                折扣</a>
                            <%} %>
                            <%} %>
                        </div>
                        <div class="serch_num">
                            找到相关商品<span><%=count%></span>件</div>
                    </div>
                    <%if (pagerListTeam != null)
                      {%>
                    <%if (pagerListTeam.Count > 0)
                      { %>
                    <div id="teamRs">
                        <ul class="serch_teambuy">
                            <%foreach (ITeam itInfo in pagerListTeam)
                              {
                            %>
                            <li><a class="shop_show" href="<%=BasePage.getTeamPageUrl(itInfo.Id) %>"
                                target="_blank">
                                <img <%=ashelper.getimgsrc(ImageHelper.good_getSmallImgUrl(itInfo.Image,190,121))%>
                                    class="dynload" width="190" height="121" alt="<%=itInfo.Title %>" title="<%=itInfo.Title %>" />
                            </a>
                                <%--</a>--%>
                                <div class="shop_show_text">
                                    <a href="<%=BasePage.getTeamPageUrl(itInfo.Id) %>"
                                        target="_blank" title="<%=itInfo.Title %>">
                                        <%=itInfo.Title%></a></div>
                                <span class="shop_show_xj"><em>
                                    <%=ASSystem.currency%></em><%=GetMoney(itInfo.Team_price)%></span> <span class="shop_show_scj">
                                        市场价:<em><%=ASSystem.currency%><%=GetMoney(itInfo.Market_price)%></em></span>
                            </li>
                            <%} %>
                        </ul>
                    </div>
                    <div class="clear">
                    </div>
                    <div>
                        <%=pagerhtml%>
                    </div>
                    <%} %>
                    <%}
                      else
                      {%>
                    <div style="font-size: 14px; text-align: center; color: #666666;">
                        当前条件下没有找到合适的团购信息，您可以更换条件试试。
                    </div>
                    <%} %>
                </div>
            </div>
        </div>

<%LoadUserControl("_footer_mall.ascx", null); %>
<%LoadUserControl("_htmlfooter_mall.ascx", null); %>