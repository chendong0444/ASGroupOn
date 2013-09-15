﻿using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：积分消费记录
    /// </summary>
    public interface IScorelogAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="scorelog"></param>
        /// <returns></returns>
        int Insert(IScorelog scorelog);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="scorelog"></param>
        /// <returns></returns>
        int Update(IScorelog scorelog);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="scorelog"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IScorelog Get(ScorelogFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IScorelog> GetList(ScorelogFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IScorelog> GetPager(ScorelogFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IScorelog GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(ScorelogFilter filter);
    }
}
