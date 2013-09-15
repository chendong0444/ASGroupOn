using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
    public interface IUserAccessor
    {

        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        int Insert(IUser user);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        int Update(IUser user);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IUser Get(UserFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IUser> GetList(UserFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IUser> GetPager(UserFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IUser GetByID(int id);
        /// <summary>
        /// 更新一条记录的某些字段，返回受影响的行数
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        int UpdateUserInfo(IUser user);
        /// <summary>
        /// 更新user表的某些字段
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        int UpdateUser(IUser user);

        int GetCountByCityId(UserFilter filter);

        IUser GetByName(UserFilter filter);

        IUser GetbyUName(string UserName);

        IUser GetByEmail(UserFilter filter);

        int UpdateNewBie(IUser user);

        int UpdateUserScore(IUser user);

        int UpdateMoney(IUser user);
        int UpdateMoneys(IUser user);

        int UpdateAuth(IUser user);

        int UpdateBuy(IUser user);

        int UpdateUcsyc(IUser user);

        int UpdateIpTime(IUser user);

        int GetMaxId(UserFilter filter);

        int UpdateEnable(IUser user);

        int UpdateSecret(IUser user);

        int UpdatePassword(IUser user);


    }
}
