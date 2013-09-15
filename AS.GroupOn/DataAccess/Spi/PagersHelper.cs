using System;
using System.Collections.Generic;
using System.Text;
using IBatisNet.DataMapper;
namespace AS.GroupOn.DataAccess.Spi
{
   public class PagersHelper
    {
        public static Pagers<T> InitPager<T>(Filters.FilterBase filter,int TotalRecords)
        {
            Pagers<T> pager = new Pagers<T>();
            if (filter.CurrentPage.Value < 1)
                filter.CurrentPage = 1;
            int pageCount = 0;//一共页数
            string sql2 = String.Empty;
            pageCount = (TotalRecords % filter.PageSize.Value == 0) ? (TotalRecords / filter.PageSize.Value) : (TotalRecords / filter.PageSize.Value + 1);
            pager.TotalPage = pageCount;
            pager.TotalRecords = TotalRecords;
            if (filter.CurrentPage.Value > pageCount)
                filter.CurrentPage = pageCount;
            pager.CurrentPage = filter.CurrentPage.Value;
            return pager;
        }

    }
}
