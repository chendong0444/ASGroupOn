using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using System.Collections;

namespace AS.GroupOn.DataAccess.Accessor
{
    public interface IPartner_DetailAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="orders"></param>
        /// <returns></returns>
        int Insert(IPartner_Detail partner_datail);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="orders"></param>
        /// <returns></returns>
        int Update(IPartner_Detail partner_datail);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="orders"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPartner_Detail Get(Partner_DetailFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IPartner_Detail> GetList(Partner_DetailFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IPartner_Detail> GetPager(Partner_DetailFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IPartner_Detail GetByID(int id);
        /// <summary>
        /// 返回符合条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(Partner_DetailFilter filter);
        /// <summary>
        ///某个商户的应结算金额
        /// </summary>
        decimal exts_sp_GetPMoney(int partner_id);
        /// <summary>
        /// 某个商户的实际结算金额
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        decimal getRealSettle(Partner_DetailFilter filter);
        /// <summary>
        /// 某个商户的实际卖出金额
        /// </summary>
        /// <param name="parid"></param>
        /// <returns></returns>
        decimal GetActualPMoney(int parid);
        /// <summary>
        /// 查询具体的某个项目的已结算金额
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        decimal getYjsMenory(Partner_DetailFilter filter);

        IList<Hashtable> Seljiesuan(Partner_DetailFilter filter);

    }
}
