<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
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
    protected IList<ICategory> cataliss = null;
    //是否选择了子类
    public bool boolCatalogsChild = false;
    //是否选择了品牌
    public bool boolBrand = false;
    //是否选择了折扣
    public bool boolDiscount = false;
    //是否选择了价格
    public bool boolPrice = false;
    //搜索则隐藏分类筛选
    public string status = string.Empty;
    protected string catalogParentName = "";

    //品牌    
    protected IList<ITeam> brandAll = null;
    public int cateBrandId = 0;
    public string cateBrandName = "";

    protected IPagers<ITeam> pagers = null;
    public IList<ITeam> pagerListTeam = null;
    public System.Data.DataTable ds = null;
    //页数
    public string page = "1";
    //排序
    public int sort = 0;
    //where
    protected TeamFilter teamfilter = new TeamFilter();

    //排序
    public int sortSelect = 0;
    //总数
    public int count = 0;
    public string pagerhtml = String.Empty;

    //折扣搜索
    public int discount = 0;
    public string strDiscount = "";
    public System.Data.DataTable dtDiscount = null;
    public string discountFirst = "";
    public string discountEnd = "";

    //价格搜索
    public int price = 0;
    public string strPrice = "";
    public System.Data.DataTable dtPrice = null;
    public string priceFirst = "";
    public string priceEnd = "";
    protected NameValueCollection _system = new NameValueCollection();
    public string keyword = "";
    protected string headlogo = String.Empty;
    protected bool trsimple = false; //开启繁简转换
    protected string couponname = String.Empty;//优惠券名称
    protected string abbreviation = String.Empty;//网站简称
    protected bool opensmssubscribe = false; //是否开启短信订阅
    protected string url = String.Empty;
    protected string menuhtml = String.Empty;
    protected bool isPacket = false;
    protected IList<IGuid> iListGuid = null;
    protected IUser iuser = null;
    protected IList<IPacket> iListPacket = null;
    protected IList<ICatalogs> headcatas = null;//大分类
    protected IList<ICatalogs> smallcatas = null;//小分类
    protected string footlogo = String.Empty;
    protected bool isbrand = false;
    protected string sitename = String.Empty;
    protected string icp = String.Empty;
    protected string statcode = String.Empty;
    protected int smallid = 0;
    protected int endid = 0;
    protected int brandid = 0;
    public string headsname = string.Empty;
    protected int headsid = 0;
    protected IList<ICatalogs> partnercatas = null;
    public string endsname = string.Empty;
    protected int endsid = 0;
    public decimal summoney = 0;
    public int summount = 0;
    List<Car> carlist = new List<Car>();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        GetGuid();
        carlist = CookieCar.GetCarData();
        _system = WebUtils.GetSystem();
        if (ASSystem != null)
        {
            if (ASSystem.trsimple > 0) trsimple = true;
            couponname = ASSystem.couponname;
            abbreviation = ASSystem.abbreviation;

            if (_system["mallheadlogo"] != null && _system["mallheadlogo"].ToString() != "")
            {
                headlogo = _system["mallheadlogo"];
            }
            else
            {
                headlogo = "/upfile/img/mall_logo.png";
            }
            opensmssubscribe = Convert.ToBoolean(ASSystem.smssubscribe);


            if (PageValue.CurrentSystemConfig["mallfootlogo"] != null && PageValue.CurrentSystemConfig["mallfootlogo"].ToString() != "")
            {
                footlogo = _system["mallfootlogo"];
            }
            else
            {
                footlogo = ASSystem.footlogo;
            }
            sitename = ASSystem.sitename;
            icp = ASSystem.icp;
            statcode = ASSystem.statcode;
        }
        partnercatas = getCata("head"); //得到头部商品项目父分类
        teamfilter.teamcata = 1;
        teamfilter.mallstatus = 1;
        //提取用户的相关信息
        if (AsUser.Id != 0)
        {
            PacketFilter packetfilter = new PacketFilter();
            packetfilter.State = "0";
            packetfilter.User_id = AsUser.Id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iListPacket = session.Packet.GetList(packetfilter);
            }
            if (iListPacket != null && iListPacket.Count > 0)
            {
                isPacket = true;
            }
        }
        #region 选择了项目分类
        ICatalogs cata = null;
        if (Request["catalogid"] != null && Request["catalogid"].ToString() != "" && Request["catalogid"].ToString() != "0")
        {
            catalogid = Helper.GetInt(Request["catalogid"], 0);
            CatalogsFilter catalf = new CatalogsFilter();
            CatalogsFilter catalf2 = new CatalogsFilter();
            catalf.parent_id = 0;
            catalf.type = 1;
            catalf.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                cata = session.Catalogs.GetByID(catalogid);
            }
            if (cata != null)
            {
                catalogParentName = cata.catalogname;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    headcatas = session.Catalogs.GetList(catalf);
                }
                catalf2.parent_id = cata.id;
                catalf2.AddSortOrder(CatalogsFilter.Sort_Order_DESC);

                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    smallcatas = session.Catalogs.GetList(catalf2);
                }
                if (headcatas.Count > 0)
                {
                    boolCatalogsChild = false;
                    isCatalogsChildAll = true;
                }
            }
        }
        if (Request["smallid"] != null && Request["smallid"].ToString() != "" && Request["smallid"].ToString() != "0")
        {
            smallid = Helper.GetInt(Request["smallid"], 0);
            CatalogsFilter catalf = new CatalogsFilter();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                cata = session.Catalogs.GetByID(smallid);
            }
            headsname = cata.catalogname;
            headsid = cata.parent_id;
            catalf.parent_id = cata.parent_id;
            catalf.AddSortOrder(CatalogsFilter.ID_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                smallcatas = session.Catalogs.GetList(catalf);
            }
            boolCatalogsChild = true;
            isCatalogsChildAll = true;
        }
        string str = string.Empty;
        IList<ICatalogs> catalis = null;
        CatalogsFilter cataff = new CatalogsFilter();
        if (cata != null)
        {
            cataff.parent_id = cata.id;
        }
        cataff.type = 1;
        cataff.AddSortOrder(CatalogsFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catalis = session.Catalogs.GetList(cataff);
        }
        foreach (ICatalogs item in catalis)
        {
            str += "," + item.id;
        }
        if (cata != null)
        {
            teamfilter.CataIDin = delsidechar(cata.id + str, ',');
        }

        #endregion
        #region 选择了品牌分类
        ICategory category = null;
        if (Request["brandid"] != null && Request["brandid"].ToString() != "" && Request["brandid"].ToString() != "0")
        {
            if (NumberUtils.IsNum(Request["brandid"].ToString()))
            {
                brandid = Helper.GetInt(Request["brandid"].ToString(), 0);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    category = session.Category.GetByID(brandid);
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
                brandid = Helper.GetInt(Request["amp;brandid"].ToString(), 0);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    category = session.Category.GetByID(brandid);
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
        GetBrand(catalogid);
        GetGood();

        #region 折扣搜索
        if (_system["malldiscount"] != null && _system["malldiscount"] != "")
        {
            strDiscount = _system["malldiscount"];
            string[] sDiscount = strDiscount.Split('|');
            dtDiscount = new System.Data.DataTable();
            dtDiscount.Columns.Add("first", typeof(string));
            dtDiscount.Columns.Add("end", typeof(string));
            for (int i = 0; i < sDiscount.Length; i++)
            {
                System.Data.DataRow drDiscount = dtDiscount.NewRow();
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
            dtPrice = new System.Data.DataTable();
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
        if (Request["discount"] != null && Request["discount"].ToString() != "" && Helper.GetInt(Request["discount"], 0) != 0)
        {
            discount = Helper.GetInt(Request["discount"].ToString(), 0);
            string[] dis = new string[2];

            if (dtDiscount.Rows.Count > 0)
            {
                dis[0] = dtDiscount.Rows[discount - 1][0].ToString();
                dis[1] = dtDiscount.Rows[discount - 1][1].ToString();
            }
            if (IsN(dis[0].ToString()) && IsN(dis[1].ToString()))
            {
                boolDiscount = true;
                discountFirst = dis[0].ToString();
                discountEnd = dis[1].ToString();
                teamfilter.FromMarketPrice = Convert.ToDouble(dis[0].ToString()) * 0.1;
                teamfilter.ToMarketPrice = Convert.ToDouble(dis[1].ToString()) * 0.1;
                //where += " and Team_price/case Market_price when 0 then null else Market_price end>=" + Convert.ToDouble(dis[0].ToString()) * 0.1 + " and Team_price/case Market_price when 0 then null else Market_price end<=" + Convert.ToDouble(dis[1].ToString()) * 0.1;
            }
        }
        else if (Request["amp;discount"] != null && Request["amp;discount"].ToString() != "" && Helper.GetInt(Request["amp;discount"], 0) != 0)
        {
            discount = Helper.GetInt(Request["amp;discount"].ToString(), 0);
            string[] dis = new string[2];
            if (dtDiscount.Rows.Count > 0)
            {
                dis[0] = dtDiscount.Rows[discount - 1][0].ToString();
                dis[1] = dtDiscount.Rows[discount - 1][1].ToString();
            }
            if (IsN(dis[0].ToString()) && IsN(dis[1].ToString()))
            {
                boolDiscount = true;
                discountFirst = dis[0].ToString();
                discountEnd = dis[1].ToString();
                teamfilter.FromMarketPrice = Convert.ToDouble(dis[0].ToString()) * 0.1;
                teamfilter.ToMarketPrice = Convert.ToDouble(dis[1].ToString()) * 0.1;
                //where += " and Team_price/case Market_price when 0 then null else Market_price end>=" + Convert.ToDouble(dis[0].ToString()) * 0.1 + " and Team_price/case Market_price when 0 then null else Market_price end<=" + Convert.ToDouble(dis[1].ToString()) * 0.1;
            }
        }
        #endregion

        #region 价格
        if (Request["price"] != null && Request["price"].ToString() != "" && Helper.GetInt(Request["price"], 0) != 0)
        {
            string[] pri = new string[2];
            price = Helper.GetInt(Request["price"], 0);
            if (dtPrice.Rows.Count > 0)
            {
                pri[0] = dtPrice.Rows[price - 1][0].ToString();
                pri[1] = dtPrice.Rows[price - 1][1].ToString();
            }
            if (IsN(pri[0].ToString()) && IsN(pri[1].ToString()))
            {
                boolPrice = true;
                priceFirst = pri[0].ToString();
                priceEnd = pri[1].ToString();
                teamfilter.FromTeam_price = pri[0].ToString();
                teamfilter.ToTeam_price = pri[1].ToString();
                //where += " and Team_price>=" + pri[0].ToString() + " and Team_price<=" + pri[1].ToString();
            }
        }
        else if (Request["amp;price"] != null && Request["amp;price"].ToString() != "" && Helper.GetInt(Request["amp;price"], 0) != 0)
        {
            string[] pri = new string[2];
            price = Helper.GetInt(Request["amp;price"].ToString(), 0);
            if (dtPrice.Rows.Count > 0)
            {
                pri[0] = dtPrice.Rows[price - 1][0].ToString();
                pri[1] = dtPrice.Rows[price - 1][1].ToString();
            }
            if (IsN(pri[0].ToString()) && IsN(pri[1].ToString()))
            {
                boolPrice = true;
                priceFirst = pri[0].ToString();
                priceEnd = pri[1].ToString();
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
            status = " style='display:none'";
            teamfilter.KeyWord = keyword;
            //where += " and (title like '%" + keyword + "%' or catakey like '%" + keyword + "%')";
        }
        #endregion

        //list = bllTeam.SearchTeam(30, Convert.ToInt32(page), sql, sort, where, out count);
        teamfilter.PageSize = 32;
        teamfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pagers = session.Teams.GetPagerTeambuy(teamfilter);
        }
        pagerListTeam = pagers.Objects;
        //pager = Maticsoft.DBUtility.DbHelperSQL.SelectByPager(sql, where, sort, Convert.ToInt32(page), 30, "team", "", "");
        count = pagers.TotalRecords;
        if (keyword != "")
        {
            pagerhtml = WebUtils.GetPagerHtml(32, pagers.TotalRecords, int.Parse(page), GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, discount, sort, keyword) + "&page={0}");
        }
        else
        {
            pagerhtml = WebUtils.GetPagerHtml(32, pagers.TotalRecords, int.Parse(page), GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, discount, sort, keyword) + "?page={0}");
        }
        #endregion
    }

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
            isbrand = true;
            isBrandAll = true;
            CategoryFilter catelgs = new CategoryFilter();
            catelgs.Zone = "brand";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                cataliss = session.Category.GetList(catelgs);
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
        if (brandAll!=null && brandAll.Count > 0)
        {
            isBrandAll = true;
        }
    }
    #endregion

    /// <summary>
    /// 显示导航栏目
    /// </summary>
    public void GetGuid()
    {

        GuidFilter guidfilter = new GuidFilter();
        guidfilter.teamormall = 1;
        guidfilter.AddSortOrder(GuidFilter.guidsort_desc);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListGuid = session.Guid.GetList(guidfilter);
        }
    }
    #region 热销排行
    public void GetGood()
    {
        IList<ITeam> ilistteam = null;
        TeamFilter tfilters = new TeamFilter();
        tfilters.Top = 10;
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
    protected IList<ICatalogs> GetCataSamall(int partid, int top)
    {
        IList<ICatalogs> iListCatalogsTwo = null;
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        catalogsfilter.type = 1;
        catalogsfilter.visibility = 0;
        if (top != 0)
        {
            catalogsfilter.Top = top;
        }
        if (partid != 0)
        {
            catalogsfilter.parent_id = partid;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCatalogsTwo = session.Catalogs.GetList(catalogsfilter);

        }
        return iListCatalogsTwo;
    }
    /// <summary>
    /// 得到分类
    /// </summary>
    protected IList<ICatalogs> getCata(string type)
    {
        int top = 0;
        IList<ICatalogs> iListCatalogsds = null;
        iListCatalogsds = GethostCataMall(top, 0, 1);
        return iListCatalogsds;
    }

    /// <summary>
    /// 显示主推大类：商城
    /// </summary>
    /// <param name="top"></param>
    /// <param name="cityid"></param>
    /// <param name="location"></param>
    /// <returns></returns>
    protected IList<ICatalogs> GethostCataMall(int top, int cityid, int location)
    {
        IList<ICatalogs> iListCatalogs = null;
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        catalogsfilter.type = 1;
        catalogsfilter.parent_id = 0;
        catalogsfilter.visibility = 0;
        catalogsfilter.catahost = 0;
        catalogsfilter.AddSortOrder(CatalogsFilter.MoreSort);
        if (top == 0)
        {
            if (cityid == 0)
            {
                if (location == 1)
                {
                    catalogsfilter.LocationOr = 1;
                }
            }
        }
        else
        {
            if (cityid == 0)
            {
                if (location == 1)
                {
                    catalogsfilter.Top = top;
                    //catalogsfilter.LocationOr = 1;
                }
            }
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCatalogs = session.Catalogs.GetList(catalogsfilter);

        }
        return iListCatalogs;
    }
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta name="keywords" content="<%=PageValue.KeyWord %>" />
    <meta name="description" content="<%=PageValue.Description%>" />
    <script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/mall.js"></script>
    <link href="/upfile/css/index.css" rel="stylesheet" type="text/css" />
    <link rel="icon" href="<%=PageValue.WebRoot %>upfile/icon/favicon.ico" mce_href="<%=PageValue.WebRoot %>upfile/icon/favicon.ico"
        type="image/x-icon">
    <link href="<%=PageValue.WebRoot %>upfile/css/base.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="<%=PageValue.WebRoot %>upfile/js/jquery-1.4.2.min.js"></script>
    <script type='text/javascript'>        webroot = '<%=PageValue.WebRoot %>'; LOGINUID = '<%=AsUser.Id %>';</script>
    <title>
        <%=PageValue.CurrentSystemConfig["malltitle"]%></title>
</head>
<%if (WebUtils.config["slowimage"] == "1")
  { %>
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
<%} %>
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
    function addToFavorite() {
        var d = "<%=PageValue.WWWprefix%>";
            var c = "<%=PageValue.CurrentSystemConfig["mallsitename"] %>";
            if (document.all) {
                window.external.AddFavorite(d, c)
            } else {
                if (window.sidebar) {
                    window.sidebar.addPanel(c, d, "")
                } else {
                    alert("\u5bf9\u4e0d\u8d77\uff0c\u60a8\u7684\u6d4f\u89c8\u5668\u4e0d\u652f\u6301\u6b64\u64cd\u4f5c!\n\u8bf7\u60a8\u4f7f\u7528\u83dc\u5355\u680f\u6216Ctrl+D\u6536\u85cf\u672c\u7ad9\u3002")
                }
            }
        }
</script>
<body class="root61">
    <script type="text/javascript" src="/upfile/js/jdbase-v1.js"></script>
    <div id="shortcut-2013">
        <div class="w">
            <ul class="fl lh">
                <li class="fore1 ld"><b></b><a rel="nofollow" href="javascript:addToFavorite()">收藏<%= PageValue.CurrentSystemConfig["mallsitename"]%></a>
                </li>
            </ul>
            <ul class="fr lh">
                <%if (IsLogin && AsUser.Id != 0)
                  { %>
                <% if (AsUser.Realname != null && AsUser.Realname != "")
                   {%>
                <ul class="links">
                    <li class="fore1 ld" id="Li1">您好，
                        <%=AsUser.Realname%>！<a href="<%=PageValue.WebRoot %>loginout.aspx" class="link-logout">[退出]</a></li>
                    <li class="fore2"><a href="<%=GetUrl("我的订单", "order_index.aspx")%>" rel="nofollow">我的订单</a></li>
                    <%if (isPacket == true)
                      {%>
                    <li class="fore2"><a href="<%=GetUrl("我的红包", "order_packet.aspx")%>" rel="nofollow">
                        我的红包</a></li>
                    <%} %>
                </ul>
                <%}
                   else
                   { %>
                <ul class="links">
                    <li class="fore1 ld" id="Li2">您好，<%=AsUser.Username%>！<a href="<%=PageValue.WebRoot %>loginout.aspx"
                        class="link-logout">[退出]</a></li>
                    <li class="fore2"><a href="<%=GetUrl("我的订单", "order_index.aspx")%>" rel="nofollow">我的订单</a></li>
                </ul>
                <%} %>
                <%}
                  else
                  {%>
                <li class="fore1 ld" id="loginbar">您好！欢迎来到<%= PageValue.CurrentSystemConfig["mallsitename"]%>！<a
                    href="<%=GetUrl("用户登录", "account_login.aspx")%>">[登录]</a>&nbsp;<a href="<%=GetUrl("用户注册", "account_loginandreg.aspx")%>">[免费注册]</a></li>
                <%} %>
            </ul>
            <span class="clr"></span>
        </div>
    </div>
    <div id="o-header-2013">
        <div class="w" id="header-2013">
            <div id="logo" class="ld">
                <a href="<%=GetUrl("商城首页","mall_index.aspx")%>"><b></b>
                    <img src="<%=headlogo %>" width="259" height="50" alt="<%= PageValue.CurrentSystemConfig["mallsitename"]%>" /></a></div>
            <!--logo end-->
            <div id="search-2013">
                <div class="i-search ld">
                    <b></b><s></s>
                    <ul id="shelper" class="hide">
                    </ul>
                    <div class="form">
                        <input id="keyword" type="text" class="text" autocomplete="off" x-webkit-speech=""
                            lang="zh-CN">
                        <input type="button" value="搜索" class="button" id="submit" name="submit">
                    </div>
                </div>
            </div>
            <script type="text/javascript">
                $(document).ready(function () {
                    $("#submit").click(function () {
                        var keyword = $("#keyword").val();
                        if (keyword.indexOf('<script>') >= 0) {
                            alert("非法字符！");
                            return;
                        }
                        if (keyword != "") {
                            window.location.href = '<%=GetTeamListPageUrl(0,0,0,0,0,0,0,String.Empty)%>' + '?keyword=' + encodeURIComponent(keyword);
                        }
                    });

                });
                $(document).ready(function () {
                    $("#keyword").keypress(function (event) {
                        if (event.keyCode == 13) {
                            var keyword = $("#keyword").val();
                            if (keyword.indexOf('<script>') >= 0) {
                                alert("非法字符！");
                                event.preventDefault();
                                return;
                            }

                            if (keyword != "") {
                                window.location.href = '<%=GetTeamListPageUrl(0,0,0,0,0,0,0,String.Empty)%>' + '?keyword=' + encodeURIComponent(keyword);
                                event.preventDefault();
                            }
                            event.preventDefault();
                        }

                    });
                });
            </script>
            <!--search end-->
            <div id="settleup-2013">
                <dl>
                    <dt class="ld"><s><span id="shopping-amount"></span></s><a href="<%=GetUrl("京东购物车","mall_jdcart.aspx") %>">
                        <%if (carlist != null && carlist.Count > 0)
                          {%>
                        购物车<%=carlist.Count %>件
                        <%}
                          else
                          { %>
                        购物车0件
                        <%}%>
                    </a><b></b></dt>
                </dl>
            </div>
            <!--settleup end-->
        </div>
        <div class="w">
            <div id="nav-2013">
                <div id="categorys-2013">
                    <div class="mt ld">
                        <h2>
                            <a href="#" onmouseover="$('#_JD_ALLSORT').attr('style','display:block');$('#categorys-2013 .mt b').attr('style', 'background-position:-65px -23px;  display:block');"
                                onmouseout="$('#_JD_ALLSORT').attr('style','display:none');$('#categorys-2013 .mt b').attr('style', 'background-position:-65px 0; display:block')">
                                全部商品分类 <b style="background-position: -65px 0; display: block"></b></a>
                        </h2>
                    </div>
                    <div id="_JD_ALLSORT" class="mc" style="display: none" onmouseover="$('#_JD_ALLSORT').attr('style','display:block');$('#categorys-2013 .mt b').attr('style', 'background-position:-65px -23px;  display:block');"
                        onmouseout="$('#_JD_ALLSORT').attr('style','display:none');$('#categorys-2013 .mt b').attr('style', 'background-position:-65px 0;  display:block');">
                        <%if (partnercatas != null && partnercatas.Count > 0)
                          {
                              int c = 1;
                              foreach (ICatalogs icatalogsInfo in partnercatas)
                              {
                                  c++;
                                  IList<ICatalogs> small = GetCataSamall(icatalogsInfo.id, 0);
                        %>
                        <div class="item fore<%=c %>" onmouseover="showhover(this)" onmouseout="hidehover(this)">
                            <span>
                                <h3>
                                    <a href="<%=GetTeamListPageUrl(icatalogsInfo.id,0,0, 0,0,0,0,String.Empty) %>">
                                        <%=icatalogsInfo.catalogname %></a></h3>
                            </span>
                            <div class="i-mc">
                                <div class="subitem">
                                    <h4 style="height: 30px; line-height: 30px; border-bottom: 2px solid #E4393C; font-size: 15px;
                                        margin-top: 10px;">
                                        <%=icatalogsInfo.catalogname%></h4>
                                    <div onclick="$(this).parent().parent().removeClass('hover')" class="close">
                                    </div>
                                    <%foreach (var cata in small)
                                      {%>
                                    <dd>
                                        <em><a href="<%=GetTeamListPageUrl(icatalogsInfo.id,cata.id,0,0, 0,0,0,String.Empty) %>">
                                            <%=cata.catalogname %></a></em>
                                    </dd>
                                    <%} %>
                                </div>
                            </div>
                        </div>
                        <% }

                          } %>
                        <div class="extra">
                            <a href="#">全部商品分类</a>
                        </div>
                    </div>
                </div>
                <ul id="navitems-2013">
                    <%
                        bool click = false;
                        url = Request.Url.PathAndQuery;
                        string url1 = Request.RawUrl.ToString();
                        foreach (IGuid model in iListGuid)
                        {
                            if (model.guidopen == 0)
                            {
                                string target = "";
                                if (model.guidparent == 1)
                                {
                                    target = "target=_blank";
                                }
                                if (url1 == model.guidlink || url == model.guidlink)
                                {
                                    menuhtml = menuhtml + "<li class=\"hover\"><a href=\"" + model.guidlink + "\" " + target + ">" + model.guidtitle + "</a></li>";
                                }
                                else
                                {
                                    menuhtml = menuhtml + "<li id=\"nav-home\" class=\"fore1\"><a href=\"" + model.guidlink + "\"  " + target + ">" + model.guidtitle + "</a></li>";
                                }
                            }
                        }
                    %>
                    <%=menuhtml %>
                </ul>
                <script type="text/javascript">
                    function showhover(object) {
                        jQuery('#_JD_ALLSORT').children('div').removeClass('hover');
                        jQuery(object).addClass('hover');
                    }
                    function hidehover(object) {
                        jQuery('#_JD_ALLSORT').children('div').removeClass('hover');
                    }
                    $(document).ready(function () {
                        $("#navitems-2013 li").Jdropdown();
                    });
                </script>
            </div>
        </div>
    </div>
    <script type="text/javascript">
        (function () { if (pageConfig.navId) { var object = document.getElementById("nav-" + pageConfig.navId); if (object) object.className += " curr"; } })();
    </script>
    <!--header end-->
    <div class="w">
        <div class="breadcrumb">
            <strong>您现在的位置:</strong>&nbsp;&nbsp; <a href="<%=BaseUserControl.getMallPageUrl(Helper.GetString(_system["isrewrite"], "0")) %>">
                <%=_system["mallsitename"]%><em>›</em></a>
            <%if (Request["catalogid"] != null && Request["catalogid"].ToString() != "" && Request["catalogid"].ToString() != "0")
              { %>
            <a href="<%=GetTeamListPageUrl(catalogid, 0, 0, 0, price, discount, sort, keyword) %>"
                class="pink bold">
                <%=catalogParentName%></a>
            <%if (boolCatalogsChild == true)
              { %>
            <em>›</em><a href="<%=GetTeamListPageUrl(catalogid, smallid, 0, 0, price, discount, sort, keyword)%>"
                class="">
                <%=headsname%></a>
            <%if (Request["endid"] != null && Request["endid"].ToString() != "" && Request["endid"].ToString() != "0")
              { %>
            <span class="pink bold"><em>›</em>
                <%=endsname%></span>
            <%} %>
            <%} %>
            <%} %>
        </div>
    </div>
    <!--crumb end-->
    <div class="w main">
        <div class="right-extra">
            <div id="select" class="m" <%=status %>>
                <div class="mt">
                    <h1>
                        商品</h1>
                    <strong>&nbsp;-&nbsp; 筛选</strong>
                    <div class="extra">
                        <a href="<%=GetTeamListPageUrl(catalogid, 0, 0, 0, 0, 0, 0, keyword)  %>" title="">重新筛选条件</a></div>
                </div>
                <%--分类 --%>
                <dl>
                    <dt>分类：</dt>
                    <dd>
                        <a onclick="cataShow()" style="float: right;" id="aCata">更多</a>
                        <div id="divCata" class="lsttemcon">
                            <%if (isCatalogsChildAll == true)
                              {%>
                            <%if (boolCatalogsChild == true)
                              { %>
                            <div>
                                <a title="不限" href="<%=GetTeamListPageUrl(catalogid, 0, 0, brandid, price, discount, sort, keyword) %>">
                                    不限</a></div>
                            <%}
                              else
                              { %>
                            <div>
                                <a href="<%=GetTeamListPageUrl(catalogid, 0, 0, brandid, price, discount, sort, keyword) %>"
                                    class="curr">不限</a></div>
                            <% }
                              if (smallcatas != null)
                              {%>
                            <%foreach (ICatalogs catalogsChild in smallcatas)
                              { %>
                            <%if (catalogsChild.id != smallid)
                              {%>
                            <div>
                                <a title="<%=catalogsChild.catalogname%>" href="<%=GetTeamListPageUrl(catalogid, catalogsChild.id, 0, brandid, price, discount, sort, keyword)  %>">
                                    <%=catalogsChild.catalogname%></a></div>
                            <%}
                              else
                              {%>
                            <div>
                                <a class="curr" href="<%=GetTeamListPageUrl(catalogid, catalogsChild.id, 0, brandid, price, discount, sort, keyword)  %>">
                                    <%=catalogsChild.catalogname%></a></div>
                            <%}%>
                            <%}%>
                            <%}%>
                            <%}
                              else
                              {%>
                            <div>
                                <a href="<%=GetTeamListPageUrl(catalogid, 0, 0, brandid, price, discount, sort, keyword) %>"
                                    class="curr">不限</a></div>
                            <%}%>
                        </div>
                    </dd>
                </dl>
                <%--品牌 --%>
                <dl>
                    <dt>品牌：</dt>
                    <dd>
                        <a onclick="brandShow()" style="float: right;" id="aBrand">更多</a>
                        <div id="divBrand" class="lsttemcon">
                            <%if (isBrandAll == true)
                              {%>
                            <%if (boolBrand == true)
                              { %>
                            <div>
                                <a title="不限" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, 0, price, discount, sort, keyword) %>">
                                    不限</a></div>
                            <%}
                              else
                              {%>
                            <div>
                                <a class="curr" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, 0, price, discount, sort, keyword) %>">
                                    不限</a></div>
                            <%}
                              if (isbrand)
                              {
                                  foreach (ICategory brand in cataliss)
                                  { %>
                            <%if (brand.Id.ToString() != cateBrandId.ToString())
                              {%>
                            <div>
                                <a title="<%=brand.Name %>" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brand.Id, price, discount, sort, keyword) %>">
                                    <%=brand.Name %></a></div>
                            <%}%>
                            <%else
                                {%>
                            <div>
                                <a href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brand.Id, price, discount, sort, keyword) %>"
                                    class="curr">
                                    <%=brand.Name%></a></div>
                            <%}%>
                            <%}
                              }%>
                            <%else
                                {
                                    foreach (ITeam brand in brandAll)
                                    { %>
                            <%if (brand.brand_id.ToString() != cateBrandId.ToString())
                              {%>
                            <div>
                                <a title="<%=brand.Name %>" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brand.brand_id, price, discount, sort, keyword) %>">
                                    <%=brand.Name %></a></div>
                            <%}%>
                            <%else
                                {%>
                            <div>
                                <a href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brand.brand_id, price, discount, sort, keyword) %>"
                                    class="curr">
                                    <%=brand.Name%></a></div>
                            <%}%>
                            <%}
                                }

                              }
                              else
                              { %>
                            <div>
                                <a class="curr" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, 0, price, discount, sort, keyword) %>">
                                    不限</a></div>
                            <%} %>
                        </div>
                    </dd>
                </dl>
                <%--折扣 --%>
                <dl>
                    <dt>折扣：</dt>
                    <dd>
                        <a onclick="discountShow()" style="float: right;" id="aDiscount">更多</a>
                        <div id="divDiscount" class="lsttemcon">
                            <%if (isDiscountAll == true)
                              { %>
                            <%if (boolDiscount == true)
                              { %>
                            <div>
                                <a title="不限" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, 0, sort, keyword) %>">
                                    不限</a></div>
                            <%} %>
                            <%else
                                { %>
                            <div>
                                <a class="curr" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, 0, sort, keyword) %>">
                                    不限</a></div>
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
                            <%if (discountFirst + "-" + discountEnd != showDiscount)
                              {
                                  //(Helper.GetString(_system["isrewrite"], "0"), 0, cateBrandId, sortSelect,showDiscount,price
                                      
                            %>
                            <div>
                                <a title="" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, i+1, sort, keyword)  %>">
                                    <%=dtDiscount.Rows[i]["first"]%>-<%=dtDiscount.Rows[i]["end"]%>折</a></div>
                            <%}
                              else
                              { %>
                            <div>
                                <a class="curr" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, i+1, sort, keyword)  %>">
                                    <%=discountFirst %>-<%=discountEnd %>折</a></div>
                            <%} %>
                            <%} %>
                            <%} %>
                            <%} %>
                            <%}
                              else
                              { %>
                            <div>
                                <a class="curr" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, 0, sort, keyword) %>">
                                    不限</a></div>
                            <%} %>
                        </div>
                    </dd>
                </dl>
                <%--价格 --%>
                <dl>
                    <dt>价格：</dt>
                    <dd>
                        <a onclick="priceShow()" style="float: right;" id="aPrice">更多</a>
                        <div id="divPrice" class="lsttemcon">
                            <%if (isPriceAll == true)
                              { %>
                            <%if (boolPrice == true)
                              { %>
                            <div>
                                <a title="不限" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, 0, discount, sort, keyword) %>">
                                    不限</a></div>
                            <%} %>
                            <%else
                                { %>
                            <div>
                                <a class="curr" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, 0, discount, sort, keyword) %>">
                                    不限</a></div>
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
                            <%if (Request["catalogid"] == "0")
                              { %>
                            <div>
                                <a title="" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, j+1, discount, sort, keyword)%>">
                                    <%=dtPrice.Rows[j]["first"]%>-<%=dtPrice.Rows[j]["end"]%></a></div>
                            <%}
                              else
                              { %>
                            <div>
                                <a title="" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, j+1, discount, sort, keyword) %>">
                                    <%=dtPrice.Rows[j]["first"]%>-<%=dtPrice.Rows[j]["end"]%></a></div>
                            <%} %>
                            <%}
                              else
                              { %>
                            <div>
                                <a class="curr" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, j+1, discount, sort, keyword) %>">
                                    <%=priceFirst %>-<%=priceEnd %></a></div>
                            <%} %>
                            <%} %>
                            <%} %>
                            <%} %>
                            <%}
                              else
                              { %>
                            <div>
                                <a class="curr" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, 0, discount, sort, keyword) %>">
                                    不限</a></div>
                            <%} %>
                        </div>
                    </dd>
                </dl>
                <%--<a onclick="cataShow()" style="cursor: pointer;" class="more_brand" id="aCata">更多</a>--%>
                <div class="clear">
                </div>
            </div>
            <!--select end -->
            <div id="filter">
                <div class="fore1">
                    <dl class="order">
                        <dt>排序：</dt>
                        <%if (Request["sort"] == "1" || Request["amp;sort"] == "1")
                          { %>
                        <dd class="price curr down">
                            <b></b><a href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, discount, 2, keyword) %>">
                                人气</a><b></b></dd>
                        <%}
                          else if (Request["sort"] == "2" || Request["amp;sort"] == "2")
                          {%>
                        <dd class="price curr up">
                            <b></b><a href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, discount, 1, keyword) %>">
                                人气</a><b></b></dd>
                        <%}
                          else
                          {%>
                        <dd>
                            <a class="" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, discount, 1, keyword) %>">
                                人气</a></dd>
                        <%}
                          if (Request["sort"] == "3" || Request["amp;sort"] == "3")
                          { %>
                        <dd class="price curr down">
                            <b></b><a rel="nofollow" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, discount, 4, keyword) %>">
                                价格</a> <b></b>
                        </dd>
                        <%}
                          else if (Request["sort"] == "4" || Request["amp;sort"] == "4")
                          { %>
                        <dd class="price curr up">
                            <b></b><a href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, discount, 3, keyword) %>">
                                价格</a><b></b></dd>
                        <% }
                          else
                          {%>
                        <dd>
                            <a href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, discount, 3, keyword) %>">
                                价格</a></dd>
                        <%}

                          if (Request["sort"] == "5" || Request["amp;sort"] == "5")
                          { %>
                        <dd class="price curr up">
                            <b></b><a href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, discount,6, keyword)%>">
                                折扣</a><b></b></dd>
                        <%}
                          else if (Request["sort"] == "6" || Request["amp;sort"] == "6")
                          {%>
                        <dd class="price curr down">
                            <b></b><a class="schlist_downbtn" href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, discount,5, keyword)%>">
                                折扣</a><b></b></dd>
                        <%}
                          else
                          {%>
                        <dd>
                            <a href="<%=GetTeamListPageUrl(catalogid, smallid, endid, brandid, price, discount,5, keyword)%>">
                                折扣</a></dd>
                        <%}%>
                    </dl>
                    <div class="pagin pagin-m">
                        <div style="color: #CC3300; float: right; height: 22px; line-height: 22px; padding: 2px 15px 2px 0;">
                            <span>共<strong><%=count%></strong>个商品</span></div>
                    </div>
                    <span class="clr"></span>
                </div>
            </div>
            <div class="" id="plist">
                <%if (pagerListTeam != null)
                  {%>
                <%if (pagerListTeam.Count > 0)
                  { %>
                <ul class="list-h">
                    <%foreach (ITeam itInfo in pagerListTeam)
                      {
                    %>
                    <li>
                        <div class="p-img">
                            <a href="<%=BasePage.getTeamPageUrl(itInfo.Id) %>" target="_blank">
                                <img <%=ashelper.getimgsrc(ImageHelper.good_getSmallImgUrl(itInfo.Image,190,121))%>
                                    class="dynload" alt="<%=itInfo.Title %>" title="<%=itInfo.Title %>" /><div class="pi8">
                                    </div>
                            </a>
                        </div>
                        <%--</a>--%>
                        <div class="p-name">
                            <a class="adwords" href="<%=BasePage.getTeamPageUrl(itInfo.Id) %>" target="_blank"
                                title="<%=itInfo.Title %>">
                                <%=itInfo.Title%></a></div>
                        <span class="shop_show_xj" style="color: #ff0000; font-size: 15px;"><strong><em>
                            <%=ASSystem.currency%></em><%=GetMoney(itInfo.Team_price)%></strong></span>
                        <span class="shop_show_scj" style="color: #CCCCCC; font-size: 12px; font-weight: normal;
                            padding-left: 5px;">市场价:<em style="text-decoration: line-through"><%=ASSystem.currency%><%=GetMoney(itInfo.Market_price)%></em></span>
                    </li>
                    <%} %>
                </ul>
                <div class="clear">
                </div>
                <%}
                  else
                  {%>
                <div style="font-size: 14px; text-align: center; color: #666666;">
                    当前条件下没有找到合适的团购信息，您可以更换条件试试。
                </div>
                <%}
                  }
                  else
                  {%>
                <div style="font-size: 14px; text-align: center; color: #666666;">
                    当前条件下没有找到合适的团购信息，您可以更换条件试试。
                </div>
                <%} %>
            </div>
            <!--底部分页 -->
            <div class="m clearfix">
                <%-- class="pagin fr"--%>
                <div class="pagin fr">
                    <%=pagerhtml.Replace("<ul class=\"paginator\"> ", "").Replace("<li>", "").Replace("<li style=\" margin: 5px; 6px;\" ><font style=\"color:red;\">", "<a style=\"color:Red;\">").Replace("</li>", "").Replace("</ul>", "").Replace("</font>", "</a>")%>
                </div>
            </div>
            <div reco_id="2" class="shop-choice hide" id="shop-choice">
            </div>
        </div>
        <div class="left">
            <%if (headcatas != null)
              {%>
            <%CatalogsFilter cataft = new CatalogsFilter();
              IList<ICatalogs> catalis = null;
              cataft.AddSortOrder(CatalogsFilter.ID_DESC);
              cataft.type = 1;
              cataft.visibility = 0;
              using (IDataSession sesssion = AS.GroupOn.App.Store.OpenSession(false))
              {
                  catalis = sesssion.Catalogs.GetList(cataft);
              }%>
            <div class="m" id="sortlist">
                <% foreach (ICatalogs cata in headcatas)
                   {%>
                <div class="mc">
                    <% 
                        if (headsid == cata.id || cata.id == catalogid)
                        {%>
                    <div class="item current">
                        <%}
                        else
                        {%>
                        <div class="item">
                            <%} %>
                            <h3>
                                <b></b><a href="<%=GetTeamListPageUrl(cata.id, 0, 0, 0, price, discount, sort, keyword)%>">
                                    <%=cata.catalogname %></a></h3>
                            <ul>
                                <%foreach (ICatalogs item in catalis)
                                  {
                                      if (item.parent_id == cata.id)
                                      { %>
                                <li><a href="<%=GetTeamListPageUrl(cata.id, item.id, 0, 0, price, discount, sort, keyword) %>">
                                    <%=item.catalogname%></a></li>
                                <% }
                                  }
                                %>
                            </ul>
                        </div>
                    </div>
                    <%}%>
                </div>
                <%}%>
                <!-- sortlist end -->
                <script type="text/javascript">
                    $("#sortlist h3").bind("click", function () {
                        var element = $(this).parent();
                        if (element.hasClass("current")) {
                            element.removeClass("current");
                        } else {
                            element.addClass("current");
                        }
                    })
                </script>
                <div id="ad_left" class="m m0 hide" reco_id="6">
                </div>
                <!--品牌商城-热销排行（开始）-->
                <div id="weekRank" class="m rank" clstag="thirdtype|keycount|thirdtype|mrank">
                    <div class="mt">
                        <h2>
                            热销排行</h2>
                    </div>
                    <div id="bm_slist0" class="mc">
                        <ul class="tabcon">
                            <%if (ds.Rows.Count > 0)
                              { %>
                            <%for (int i = 0; i < ds.Rows.Count; i++)
                              { %>
                            <li><a class="brdlst_slname" title="<%=ds.Rows[i]["title"] %>" style="overflow: hidden"
                                href="<%=BasePage.getTeamPageUrl(int.Parse(ds.Rows[i]["id"].ToString())) %>"
                                target="_blank" onmouseover="goodShow(<%=ds.Rows[i]["id"] %>)"><span class="brdlst_slnum">
                                    <%string str = string.Empty;
                                      if (ds.Rows[i]["title"].ToString().Length > 24)
                                      {
                                          str = Helper.GetSubString(ds.Rows[i]["title"].ToString(), 24) + "...";
                                      }
                                      else
                                      {
                                          str = ds.Rows[i]["title"].ToString();
                                      }
                                    %>
                                    <%=i+1 %></span><%=str %></a></li>
                         
                            <%} %>
                           <%} %>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        <span class="clr"></span>
        <div id="Collect_Tip" class="Tip360 w260">
        </div>
    </div>
    <script type="text/javascript" src="<%=PageValue.WebRoot %>upfile/js/jdlib-v1.js"></script>
    <script type="text/javascript" src="<%=PageValue.WebRoot %>upfile/js/jdhome.js"></script>
    <div class="w">
        <div id="service-2013">
            <dl class="fore1">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("玩转东购团","help_tour.aspx")%>">玩转<%=abbreviation%></a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("常见问题","help_faqs.aspx")%>">常见问题</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("东购团概念","help_asdht.aspx")%>">
                            <%=abbreviation%>概念</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("开发API","help_api.aspx")%>">开发API</a>
                    </div>
                </dd>
            </dl>
            <dl class="fore2" clstag="homepage|keycount|home2012|33b">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("邮件订阅","help_Email_Subscribe.aspx?cityid="+CurrentCity.Id)%>">邮件订阅</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("RSS订阅","help_RSS_feed.aspx?ename="+CurrentCity.Ename)%>">RSS订阅</a>
                    </div>
                    <%if (ASSystem.sinablog != "")
                      {%>
                    <div>
                        <a href="<%=ASSystem.sinablog %>" target="_blank">新浪微博</a></div>
                    <%} %>
                    <%if (ASSystem.qqblog != "")
                      {%>
                    <div>
                        <a href="<%=ASSystem.qqblog %>" target="_blank">腾讯微博</a></div>
                    <%} %>
                </dd>
            </dl>
            <dl class="fore4" clstag="homepage|keycount|home2012|33d">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("关于东购团","about_us.aspx")%>">关于<%=abbreviation %></a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("工作机会","about_job.aspx")%>">工作机会</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("联系方式","about_contact.aspx")%>">联系方式</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("用户协议","about_terms.aspx")%>">用户协议</a>
                    </div>
                </dd>
            </dl>
            <dl class="fore5" clstag="homepage|keycount|home2012|33e">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("商务合作","feedback_seller.aspx")%>">商务合作</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("友情链接","help_link.aspx")%>">友情链接</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("后台管理","Login.aspx")%>">后台管理</a>
                    </div>
                </dd>
            </dl>
            <div class="fr">
                <div class="sm" id="branch-office">
                    <%if (Request.Url.ToString().ToLower().IndexOf("/mall/") > 0 || Request.Url.ToString().ToLower().IndexOf("/list/") > 0)
                      {
                    %>
                    <a href="<%=WebRoot%>mall/index.aspx">
                        <%if (_system != null && _system["mallfootlogo"] != null && _system["mallfootlogo"].ToString() != "")
                          {
                        %>
                        <img src="<%=_system["mallfootlogo"].ToString() %>" />
                        <%  
                            }
                          else
                          {
                        %>
                        <img src="/upfile/img/mall_logo.png" />
                        <%
                            } %>
                    </a>
                    <%
                        }
                      else
                      { 
                    %>
                    <a href="<%=WebRoot%>index.aspx">
                        <img src="<%=footlogo %>" /></a>
                    <%
                        } %>
                </div>
            </div>
            <span class="clr"></span>
        </div>
    </div>
    <div class="w">
        <div id="footer-2013">
            <div class="copyright">
                &copy;<span>2010</span>&nbsp;<%=sitename
                %>（<%=WWWprefix %>）版权所有&nbsp;<a href="<%=GetUrl("用户协议","about_terms.aspx")%>">使用<%=abbreviation
                %>前必读</a>&nbsp;<a href="http://www.miibeian.gov.cn/" target="_blank"><%=icp %></a>&nbsp;&nbsp;<%=statcode
                %><br />
                &nbsp;Powered by ASdht(<a target="_blank" href="http://www.asdht.com">艾尚团购系统程序</a>)
                Software V_<%=ASSystemArr["siteversion"] %>
            </div>
        </div>
    </div>
</body>
</html>
