using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
    public interface IPartnerAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="partner"></param>
        /// <returns></returns>
        int Insert(IPartner partner);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="partner"></param>
        /// <returns></returns>
        int Update(IPartner partner);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="partner"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPartner Get(PartnerFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IPartner> GetList(PartnerFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IPartner> GetPager(PartnerFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IPartner GetByID(int id);

        int UpdateSaleid(IPartner partner);

        int GetSaleid(PartnerFilter filter);

        int GetCount(PartnerFilter filter);

        int Count(PartnerFilter filter);

        IPagers<IPartner> Page(PartnerFilter filter);

        int UpdateImage1(IPartner partner);

        int UpdateImage2(IPartner partner);
    }
}
