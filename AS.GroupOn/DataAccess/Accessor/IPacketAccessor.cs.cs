using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
    public interface IPacketAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="orders"></param>
        /// <returns></returns>
        int Insert(IPacket packet);

        /// <summary>
        /// 写入一条记录(红包充值)，返回其ID
        /// </summary>
        /// <param name="orders"></param>
        /// <returns></returns>
        int InsertHBCZ(IPacket packet);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="orders"></param>
        /// <returns></returns>
        int Update(IPacket packet);
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
        IPacket Get(PacketFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IPacket> GetList(PacketFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IPacket> GetPager(PacketFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IPacket GetByID(int id);

        int InsertPfdjq(IPacket packet);
    }
}
