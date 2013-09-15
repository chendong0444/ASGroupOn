using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.Common.Utils;
namespace AS.GroupOn.Controls
{
    public class FrontPage:BasePage
    {
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (PageValue.CurrentCity != null)
            {
                int cityid = Helper.GetInt(CookieUtils.GetCookieValue("cityid"), 0);
                if (cityid > 0)
                {
                    ICity city = null;
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        city = session.Citys.GetByID(cityid);
                    }
                    if (city != null) PageValue.CurrentCity = city;
                }
                else
                {
                    ICity city = null;
                    CityFilter cf = new CityFilter();
                    cf.Display = "Y";
                    cf.AddSortOrder(CityFilter.Sort_Order_DESC);
                    cf.AddSortOrder(CityFilter.ID_DESC);
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        city = session.Citys.Get(cf);
                    }
                    if (city != null)
                    {
                        PageValue.CurrentCity = city;
                        CookieUtils.SetCookie("cityid", city.Id.ToString(),DateTime.Now.AddDays(30));
                    }
                }
            }

        }

        /// <summary>
        /// 返回品牌列表
        /// </summary>
        /// <param name="top"></param>
        /// <returns></returns>
        public IList<IBrand> GetBrandList(int top)
        {
            if (top < 0) top = 5;
            IList<IBrand> brands = null;
            BrandFilter filter = new BrandFilter();
            filter.Display = "Y";
            filter.AddSortOrder(BrandFilter.Sort_Order_DESC);
            filter.AddSortOrder(BrandFilter.ID_ASC);
            filter.Top = top;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                brands = session.Brand.GetList(filter);
            }
            return brands;
        }

        /// <summary>
        /// 返回Page对象
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public IPage GetPage(string id)
        {
            IPage page = null;
            PageFilter pf = new PageFilter();
            pf.Id = id;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                page = session.Page.Get(pf);
            }
            return page;
        }

        /// <summary>
        /// 返回友情链接对象列表
        /// </summary>
        /// <param name="logo">是否查找带logo null为全部 true为带logo false为不带logo</param>
        /// <returns></returns>
        public IList<IFriendLink> GetFriendLinkList(bool? logo)
        {
            IList<IFriendLink> friendLinks = null;
            FriendLinkFilter flf = new FriendLinkFilter();
            flf.Logo = logo;
            flf.AddSortOrder(FriendLinkFilter.Sort_Order_DESC);
            flf.AddSortOrder(FriendLinkFilter.ID_ASC);
            using (IDataSession session = App.Store.OpenSession(false))
            {
                friendLinks = session.FriendLink.GetList(flf);
            }
            return friendLinks;
        }

        /// <summary>
        /// 返回城市列表
        /// </summary>
        /// <returns></returns>
        public IList<ICity> GetCityList()
        {
            IList<ICity> citys = null;
            CityFilter cf = new CityFilter();
            cf.Display = "Y";
            cf.AddSortOrder(CityFilter.Sort_Order_DESC);
            cf.AddSortOrder(CityFilter.ID_DESC);
            using (IDataSession session = App.Store.OpenSession(false))
            {
                citys = session.Citys.GetList(cf);
            }
            return citys;
        }



    }
}
