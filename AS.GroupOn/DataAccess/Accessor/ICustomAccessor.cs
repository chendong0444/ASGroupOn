using System;
using System.Collections.Generic;
using System.Text;
using System.Collections.Specialized;
using System.Collections;

namespace AS.GroupOn.DataAccess.Accessor
{
   public interface ICustomAccessor
    {
       /// <summary>
       /// 返回指定品牌在指定城市的产品数量
       /// </summary>
       /// <param name="cataid">品牌ID</param>
       /// <param name="cityid">城市ID</param>
       /// <param name="typeid">类型(1品牌 2分类)</param>
       /// <returns></returns>
       int GetTeamCount(int? cataid, int? cityid, int? typeid);
       /// <summary>
       /// 修改项目购买人数
       /// </summary>
       /// <param name="Begin_time">开始时间</param>
       /// <param name="End_time">结束时间</param>
       void UpdateTeamNowNumber();

       /// <summary>
       /// 得到短信订阅用户的数据（优惠券号，用户手机号）
       /// </summary>
       /// <param name="nowTime"></param>
       /// <returns></returns>
       List<System.Collections.Hashtable> GetSMSSubscribe(DateTime nowTime);

       /// <summary>
       /// 提前查询到期的项目
       /// </summary>
       /// <param name="Days">天数（提前多少天查询）</param>
       /// <returns></returns>
       List<System.Collections.Hashtable> GetTeamIsEndTime(int Days);

       /// <summary>
       /// 修改项目结束时间
       /// </summary>
       /// <param name="hashtable"></param>
       void UpdateTeamEndTime(Hashtable hashtable );

       /// <summary>
       /// 执行某个查询语句
       /// </summary>
       /// <param name="selectSql">执行的sql</param>
       /// <returns></returns>
       List<Hashtable> Query(string selectSql);

       /// <summary>
       /// 查询某个表的数据（tableName:表名;WhereString：查询条件;SortOrderString：排序规则）
       /// </summary>
       /// <param name="selectSql">上面参数的hash信息</param>
       /// <returns></returns>
       List<Hashtable> SelectTableWithParameter(Hashtable selectHash);
       /// <summary>
       /// 更新某个表的信息
       /// </summary>
       /// <param name="updateSql">更新sql</param>
       void Update(string updateSql);

    }
}
