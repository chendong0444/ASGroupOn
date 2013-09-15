using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
    public interface IUserlevelrelusAccessor
    {
        #region 用户等级表
        /// <summary>
        /// 增加一条记录
        /// </summary>
        int Insert(IUserlevelrules Userlevelrules);
        /// <summary>
        /// 修改一条记录
        /// </summary>
        int Update(IUserlevelrules Userlevelrules);
        /// <summary>
        /// 删除
        /// </summary>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        IUserlevelrules Get(UserlevelrulesFilters filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        IList<IUserlevelrules> GetList(UserlevelrulesFilters filter);
        /// <summary>
        /// 分页
        /// </summary>
        IPagers<IUserlevelrules> GetPager(UserlevelrulesFilters filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        IUserlevelrules GetByID(int id);
        /// <summary>
        /// 根据用户等级ID删除记录
        /// </summary>
        /// <param name="levelid"></param>
        /// <returns></returns>
        int DelByLevelid(int levelid);

        IList<IUserlevelrules> GetdataByMinmoney(UserlevelrulesFilters filter);

        #endregion
    }
}
