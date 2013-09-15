using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
   public  interface ISmstemplateAccessor
    {
       /// <summary>
       /// 写入一条数据，返回其ID
       /// </summary>
       /// <param name="smstemplate"></param>
       /// <returns></returns>
       int Insert(ISmstemplate smstemplate);
       /// <summary>
       /// 修改一条数据，返回受影响的行数
       /// </summary>
       /// <param name="smstemplate"></param>
       /// <returns></returns>
       int Update(ISmstemplate smstemplate);

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
       ISmstemplate Get(SmstemplateFilter filter);
       /// <summary>
       /// 返回符合条件的一组数据
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       IList<ISmstemplate> GetList(SmstemplateFilter filter);

       /// <summary>
       /// 返回指定页的数据数
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       IPagers<ISmstemplate> GetPager(SmstemplateFilter filter);
       /// <summary>
       ///返回指定条件的记录数
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       int GetCount(SmstemplateFilter filter);

       /// <summary>
       /// 返回指定条件的数据
       /// </summary>
       /// <param name="id"></param>
       /// <returns></returns>
       ISmstemplate GetByName(string name);

    }
}
