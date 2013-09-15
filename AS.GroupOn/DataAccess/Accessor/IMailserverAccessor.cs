using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    public interface IMailserverAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="Mailserver"></param>
        /// <returns></returns>
        int Insert(IMailserver Mailserver);
        /// <summary>
        /// 修改一条记录，返回其ID
        /// </summary>
        /// <param name="Mailserver"></param>
        /// <returns></returns>
        int Update(IMailserver Mailserver);
        /// <summary>
        /// 删除一条记录返受影响的行数
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录    
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IMailserver Get(MailserverFilter filter);
        /// <summary>
        /// 返回符合条件的多条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IMailserver> GetList(MailserverFilter filter);
        /// <summary>
        /// 返回指定页数的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPagers<IMailserver> GetPager(MailserverFilter filter);
        /// <summary>
        /// 返回指定ID的记录数
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IMailserver GetByID(int id);
    }
}
