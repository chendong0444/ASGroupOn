using System;
using System.Collections.Generic;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using System.Collections;

namespace AS.GroupOn.DataAccess.Accessor
{
    public interface ITeamAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="team"></param>
        /// <returns></returns>
        int Insert(ITeam team);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="team"></param>
        /// <returns></returns>
        int Update(ITeam team);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="team"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ITeam Get(TeamFilter filter);
        /// <summary>
        /// 返回數據列表
        /// </summary>
        /// <param name="sql"></param>
        /// <returns></returns>
        IList<ITeam> GetList(string sql);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ITeam> GetList(TeamFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ITeam> GetPager(TeamFilter filter);

        IPagers<ITeam> GetDetailPager(TeamFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ITeam GetByID(int id);
        /// <summary>
        /// 返回符合条件的记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(TeamFilter filter);

        IList<ITeam> GetByCurrentTeam(TeamFilter filter);

        IList<ITeam> GetByCurrentOtherTeam(TeamFilter filter);

        int UpdateSaleid(ITeam team);

        IList<ITeam> GetBlockOthers(TeamFilter filter);

        IList<ITeam> GetBrandId(TeamFilter filter);

        IList<ITeam> GetBrandAll(TeamFilter filter);

        IPagers<ITeam> GetPagerTeambuy(TeamFilter filter);

        IList<ITeam> GetPingLun(TeamFilter filter);

        //喜欢此产品的用户还喜欢
        IList<ITeam> GetTeamOper(TeamFilter filter);

        ////同类热销排行
        IList<ITeam> GetTeamDto(TeamFilter filter);

        int GetSumId(TeamFilter filter);

        IList<Hashtable> GetpBranch(TeamFilter filter);

        int UpdateCloseTime(ITeam team);
        int UpdateReachTime(ITeam team);

        IList<Hashtable> GetpBranch1(TeamFilter filter);

        int GetDetailCount(TeamFilter filter);
        int GetSum(TeamFilter filter);
    }
}
