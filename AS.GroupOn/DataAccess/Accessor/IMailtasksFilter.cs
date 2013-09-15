﻿using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// 创建时间: 2012-10-24
    /// 创建人:   zlj
    /// </summary>
    public interface IMailtasksFilter
    {

        #region 邮件任务列表
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="Mailtasks"></param>
        /// <returns></returns>
        int Insert(IMailtasks Mailtasks);
        /// <summary>
        /// 修改一条记录，返回其ID
        /// </summary>
        /// <param name="Mailtasks"></param>
        /// <returns></returns>
        int Update(IMailtasks Mailtasks);
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
        IMailtasks Get(MailtasksFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IMailtasks> GetList(MailtasksFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPagers<IMailtasks> GetPager(MailtasksFilter filter);
        /// <summary>
        /// 返回指定id的记录数
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IMailtasks GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(MailtasksFilter filter);
        /// <summary>
        /// 得到最大ID
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetMaxID();

        #endregion
    }
}
