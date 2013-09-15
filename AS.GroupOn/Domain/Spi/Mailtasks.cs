using System;
using System.Collections.Generic;
using System.Text;
using AS.Common.Utils;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public class Mailtasks:Obj,IMailtasks
    {
        #region 邮件任务列表
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        ///邮件标题 不能出现特殊字符
        /// </summary>
        public virtual string subject { get; set; }
        /// <summary>
        /// 邮件正文 
        /// </summary>
        public virtual string content { get; set; }
        /// <summary>
        /// 已发送数量
        /// </summary>
        public virtual int sendcount{get;set;}
        /// <summary>
        /// 发送总数量
        /// </summary>
        public virtual int totalcount { get; set; }
        /// <summary>
        /// 已阅读的mailerid
        /// </summary>
        public virtual string readmailerid { get; set; }
        /// <summary>
        /// 已阅读的数量
        /// </summary>
        public virtual int readcount { get; set; }
        /// <summary>
        /// 0未发送 1正在发送 2发送完毕 3已暂停 4 已取消
        /// </summary>
        public virtual int state { get; set; }
        /// <summary>
        /// 城市编号
        /// </summary>
        public virtual string cityid { get; set; }

        /// <summary>
        /// 返回城市
        /// </summary>
        public string City
        {
            get
            {
                ICategory category = null;
                string mailcitys = String.Empty;
                if (this.cityid.Length > 0)
                {
                    string[] mail = cityid.Split(',');

                    for (int j = 0; j < mail.Length; j++)
                    {
                        using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                        {
                            category = session.Category.GetByID(Helper.GetInt(mail[j], 0));
                        }

                        if (category != null)
                        {
                            mailcitys = mailcitys + category.Name + ",";
                        }
                        else
                        {
                            if (mail[j] == "0")
                            {
                                mailcitys = mailcitys + "全部城市,";
                            }
                        }
                    }
                }
                else
                {
                    mailcitys = "全部城市";
                }
                return mailcitys;
            }
        }

        #endregion
    }
}
