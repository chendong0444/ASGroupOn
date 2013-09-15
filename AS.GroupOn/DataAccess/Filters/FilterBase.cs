using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public class FilterBase
    {
        private string _sortorders = String.Empty;
        /// <summary>
        /// 添加排序规则
        /// </summary>
        /// <param name="sortOrder"></param>
        public void AddSortOrder(string sortOrder)
        {
            if (_sortorders == String.Empty)
                _sortorders = sortOrder;
            else
                _sortorders = _sortorders + "," + sortOrder;
        }
        /// <summary>
        /// 得到排序字符串
        /// </summary>
        public string SortOrderString
        {
            get
            {
                return _sortorders;
            }
        }
        /// <summary>
        /// 得到或设置当前页码
        /// </summary>
        public int? CurrentPage { get; set; }
        /// <summary>
        /// 得到或设置每页记录数
        /// </summary>
        public int? PageSize { get; set; }

        /// <summary>
        /// 开始行号
        /// </summary>
        private int _startrow = 0;
        public int StartRow
        {
            get
            {
                if (!CurrentPage.HasValue || !PageSize.HasValue)
                    throw new Exception("请先设置每页的记录数和当前页码");
                return (CurrentPage.Value - 1) * PageSize.Value + 1;
            }
        }
        /// <summary>
        /// 结束行号
        /// </summary>
        private int _endrow = 0;
        public int EndRow
        {
            get
            {
                if (!CurrentPage.HasValue || !PageSize.HasValue)
                    throw new Exception("请先设置每页的记录数和当前页码");
                return CurrentPage.Value * PageSize.Value;
            }
        }
        /// <summary>
        /// 查询前多少条记录
        /// </summary>
        public int? Top { get; set; }
    }
}
