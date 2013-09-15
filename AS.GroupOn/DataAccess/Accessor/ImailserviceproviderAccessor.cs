using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    public interface ImailserviceproviderAccessor
    {
        /// <summary>
        /// 写入一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int Insert(Imailserviceprovider Mailserviceprovider);
        /// <summary>
        /// 修改一条记录，返回受影响的行数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int Update(Imailserviceprovider Mailserviceprovider);
        /// <summary>
        /// 删除一条记录，返回受影响的行数
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        Imailserviceprovider Get(MailserviceproviderFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<Imailserviceprovider> GetList(MailserviceproviderFilter filter);
        /// <summary>
        /// 返回指定页数的记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPagers<Imailserviceprovider> GetPager(MailserviceproviderFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        Imailserviceprovider  GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(MailserviceproviderFilter filter);
        /// <summary>
        /// 删除指定条件的记录，返回受影响的行数
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        int DeleteWhere(int mailtasks_id);
    }
}
