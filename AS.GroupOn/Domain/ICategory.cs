using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface ICategory : IObj
    {
        /// <summary>
        /// ID
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 类别
        /// </summary>
        string Zone { get; set; }
        /// <summary>
        /// 自定义分组
        /// </summary>
        string Czone { get; set; }
        /// <summary>
        /// 名称
        /// </summary>
        string Name { get; set; }
        /// <summary>
        /// 英文名称
        /// </summary>
        string Ename { get; set; }
        /// <summary>
        /// 英文首字母
        /// </summary>
        string Letter { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
       int Sort_order { get; set; }
        /// <summary>
        /// 导航显示
        /// </summary>
        string Display { get; set; }
        /// <summary>
        /// 城市公告
        /// </summary>
        string content { get; set; }
        /// <summary>
        /// 2.28新增二级城市id
        /// </summary>
        int City_pid { get; set; }
        /// <summary>
        /// 快递数量
        /// </summary>
        int Num { get; set; }

        /// <summary>
        /// 返回用户
        /// </summary>
        //IMailtasks Mailtasks { get; }

        int number { get; set; }
    }
}
