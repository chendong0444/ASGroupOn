using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
 
  public  interface  ISmssubscribedetailAccessor
    {

      /// <summary>
      /// 写入一条数据返回ID
      /// </summary>
      /// <param name="smssubscribedetail"></param>
      /// <returns></returns>
      int Insert(ISmssubscribedetail smssubscribedetail);
      /// <summary>
      /// 更新一条数据 返回受影响的行数
      /// </summary>
      /// <param name="smssubscribedetail"></param>
      /// <returns></returns>
      int Update(ISmssubscribedetail smssubscribedetail);

      /// <summary>
      /// 删除一条数据，返回受影响的行数
      /// </summary>
      /// <param name="id"></param>
      /// <returns></returns>
      int Delete(int id);

    
      /// <summary>
      ///  返回符合条件的一条数据
      /// </summary>
      /// <param name="filter"></param>
      /// <returns></returns>
      ISmssubscribedetail Get(SmssubscribedetailFilter filter);

      /// <summary>
      /// 返回符合条件的一组记录
      /// </summary>
      /// <param name="filter"></param>
      /// <returns></returns>
      IList<ISmssubscribedetail> GetList(SmssubscribedetailFilter filter);

      /// <summary>
      ///返回指定页的记录数 
      /// </summary>
      /// <param name="filter"></param>
      /// <returns></returns>
      IPagers<ISmssubscribedetail> GetPager(SmssubscribedetailFilter filter);

      /// <summary>
      /// 返回指定ID的记录
      /// </summary>
      /// <param name="id"></param>
      /// <returns></returns>
      ISmssubscribedetail GetByID(int id);

      /// <summary>
      /// 返回指定条件的记录数
      /// </summary>
      /// <param name="filter"></param>
      /// <returns></returns>
      int GetCount(SmssubscribedetailFilter filter);


    }
}
