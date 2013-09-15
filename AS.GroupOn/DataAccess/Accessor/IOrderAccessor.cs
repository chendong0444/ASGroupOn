using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using System.Collections;
using System.Data;
namespace AS.GroupOn.DataAccess.Accessor
{
    public interface IOrderAccessor
    {

        /// <summary>
        /// 返回一条最大记录
        /// </summary>
        /// <returns></returns>
        int GetMaxId();
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="orders"></param>
        /// <returns></returns>
        int Insert(IOrder order);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="orders"></param>
        /// <returns></returns>
        int Update(IOrder order);

        /// <summary>
        /// 更新快递单号
        /// </summary>
        /// <param name="order"></param>
        /// <returns></returns>
        int UpdateExpress_id(IOrder order);

        /// <summary>
        ///批量更新快递单号
        /// </summary>
        /// <param name="order"></param>
        /// <returns></returns>
        int UpdateExpress_id_all(IOrder order);

        /// <summary>
        /// 批量上传快递单
        /// </summary>
        /// <param name="order"></param>
        /// <returns></returns>
        int UpdateUpload(IOrder order);

        int UpdatePayTime(IOrder order);

        /// <summary>
        /// 未付款订单处理方法：在生成订单前。得到1个小时内，此用户的未付款,未过期的，购物车的订单。然后将状态更改为cancel 在创建新 订单
        /// </summary>
        /// <param name="order"></param>
        /// <returns></returns>
        int UpdateState(IOrder order);

        int UpdateFare(IOrder order);
        int UpdateOrigin(IOrder order);

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
        IOrder Get(OrderFilter filter);
        /// <summary>
        /// 根据条件获取行数
        /// </summary>
        /// <param name="orders"></param>
        /// <returns></returns>
        int GetCount(OrderFilter filter);
        /// <summary>
        /// 根据条件获取Origin总和
        /// </summary>
        /// <param name="orders"></param>
        /// <returns></returns>
        decimal GetSum(OrderFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IOrder> GetList(OrderFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IOrder> GetPager(OrderFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IOrder GetByID(int id);

        /// <summary>
        /// 返回打印指定ID
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IOrder GetByPrint(int id);


        /// <summary>
        /// 更新用户消费总和
        /// </summary>
        /// <param name="order"></param>
        /// <returns></returns>
        int UpdateTotalamount(IOrder order);


        /// <summary>
        /// 营销(数据下载--项目订单)
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IOrder> GetYx_TeamDown(OrderFilter filter);

        int  GetUnpay(OrderFilter filter);

        IList<Hashtable> SelById1(OrderFilter filter);

        IList<Hashtable> SelById2(OrderFilter filter);

        IList<Hashtable> SelById3(OrderFilter filter);

        /// <summary>
        /// 修改未付款订单 
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int UpdateUnpayOrder(OrderFilter filter);

        int UpdateFare(OrderFilter filter);

        int UpdateOrigin(OrderFilter filter);   

        int UpdateOrder(IOrder order);

        int GetBuyCount1(OrderFilter filter);

        IList<Hashtable> SelOrder(OrderFilter filter);

        IPagers<IOrder> GetPager2(OrderFilter filter);

        IList<Hashtable> Sel(OrderFilter filter);

        int Count(OrderFilter filter);
        int SellNumber(OrderFilter filter);
        int SendNumber(OrderFilter filter);

        IList<IOrder> OrderTongji(OrderFilter filter);

        IPagers<IOrder> GetBranchPage(OrderFilter filter);
        int SelCountBranch(OrderFilter filter);

        /// <summary>
        /// 根据订单交易单号返回订单需要支付的金额
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IOrder GetPayPrice(OrderFilter filter);

        int GetBranchCount(OrderFilter filter);

        IPagers<IOrder> GetPagerPartner(OrderFilter filter);
        IPagers<IOrder> GetPagerPLTeam(OrderFilter filter);
    }
}
