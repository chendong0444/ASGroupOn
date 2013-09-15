using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
   public  interface ISmsLogAccessor
    {
       /// <summary>
       /// 写入一条数据，返回其ID
       /// </summary>
       /// <param name="SmsLog"></param>
       /// <returns></returns>
       int Insert(ISmsLog SmsLog);
       /// <summary>
       /// 修改一条数据，返回受影响的行数
       /// </summary>
       /// <param name="SmsLog"></param>
       /// <returns></returns>
       int Update(ISmsLog SmsLog);

       /// <summary>
       /// 删除一条数据，返回受影响的行数
       /// </summary>
       /// <param name="id"></param>
       /// <returns></returns>
       int Delete(int id);

       /// <summary>
       /// 返回符合条件的一条数据
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       ISmsLog Get(SmsLogFilter filter);
       /// <summary>
       /// 返回符合条件的一组数据
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       IList<ISmsLog> GetList(SmsLogFilter filter);

       /// <summary>
       /// 返回指定页的数据数
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       IPagers<ISmsLog> GetPager(SmsLogFilter filter);
       /// <summary>
       ///返回指定条件的记录数
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       int GetCount(SmsLogFilter filter);

       /// <summary>
       /// 返回指定条件的数据
       /// </summary>
       /// <param name="id"></param>
       /// <returns></returns>
       ISmsLog GetByName(string name);

    }
}
