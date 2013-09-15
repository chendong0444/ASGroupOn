using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;

namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// 统计
    /// </summary>
    public interface IGetDataAccessor
    {
        /// <summary>
        /// 获取数据列表
        /// </summary>
        List<Hashtable> GetDataList(string sql);
    }
}
