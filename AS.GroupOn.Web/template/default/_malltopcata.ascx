<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
   
    protected NameValueCollection _system = new NameValueCollection();
    protected IList<ICatalogs> headcatas = null;//中间商品项目父分类
    protected IList<ICatalogs> headchildlist = null;//查询头部子类下的子类

    public override void UpdateView()
    {
        _system = WebUtils.GetSystem();

        headcatas = getCata("head"); //得到头部商品项目父分类
    }

    /// <summary>
    /// 得到分类
    /// </summary>
    protected IList<ICatalogs> getCata(string type)
    {
        int top = 0;
        IList<ICatalogs> iListCatalogsds = null;

        //后台设置中读取配置文件中的
        if (_system["headcatanum"] != null && _system["headcatanum"].ToString() != "")
        {
            top = int.Parse(_system["headcatanum"].ToString());
            if (top > 8)
            {
                top = 7;
            }
        }
        else
        {
            top = 7;//建议不要超过7个，否则太多会换行，网页会变形
        }

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

    /// <summary>
    /// 根据条件top二级大类：商城
    /// </summary>
    /// <param name="where"></param>
    /// <returns></returns>
    protected IList<ICatalogs> GetCataMall(string where)
    {
        IList<ICatalogs> iListCatalogsTwo = null;
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        catalogsfilter.type = 1;
        catalogsfilter.parent_idNotZero = 0;
        catalogsfilter.visibility = 0;
        if (where != "")
        {
            catalogsfilter.parent_id = Helper.GetInt(where, 0);
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCatalogsTwo = session.Catalogs.GetList(catalogsfilter);

        }
        return iListCatalogsTwo;
    }

    public override string CacheKey
    {
        get
        {
            int cityid = 0;
            if (CurrentCity != null)
                cityid = CurrentCity.Id;
            return "cacheusercontrol-malltopcata";
        }
    }
    public override bool CanCache
    {
        get
        {
            return true;
        }
    }
</script>
<div class="mall_nav">
    <div class="mall_nav_box">
        <ul class="nav">
            <%if (headcatas != null && headcatas.Count > 0)
              {
                  foreach (ICatalogs icatalogsInfo in headcatas)
                  {
            %>
            <li class="nav-xq"><span class="border"><a href="<%=getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), icatalogsInfo.id,0, 0,"0","0") %>">
                <%=icatalogsInfo.catalogname%></a></span>
                <%
                      headchildlist = GetCataMall(icatalogsInfo.id.ToString());
                      if (headchildlist != null && headchildlist.Count > 0)
                      {
                %>
                <div class="nav_filter">
                    <ul>
                        <%foreach (ICatalogs icatalogsInfo2 in headchildlist)
                          {
                        %>
                        <li><a href="<%=getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), icatalogsInfo2.id,0, 0,"0","0") %>">
                            <%=icatalogsInfo2.catalogname%></a></li>
                        <%
                       
                          } %>
                    </ul>
                </div>
                <% 
                    }
                %>
            </li>
            <% 
                  }
                  if (headcatas.Count >= 7)
                  { 
            %>
           
            <%
                }

              } %>
        </ul> <span style="line-height: 40px; width: 25px; float: left; "><a href="<%=BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, 0, 0,"0","0") %>">更多</a></span>
    </div>
</div>
