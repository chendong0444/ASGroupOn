using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Controls;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess.Accessor;
using AS.GroupOn.DataAccess;
using AS.GroupOn;
namespace AS.AdminEvent
{
    /// <summary>
    /// 项目答疑后台事件：lsm
    /// </summary>
    public class AskEvent
    {
        //项目答辩编辑
        public static RedirctResult xmdb_Update(string comment, string id)
        {
            BasePage b = new BasePage();
            RedirctResult result = null;
            IAsk _ask = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                _ask = session.Ask.GetByID(Convert.ToInt32(id));
            }
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                _ask.Content = comment;
                i = session.Ask.Update(_ask);

            }
            if (i > 0)
            {
                b.SetSuccess("修改成功");
                result = new RedirctResult("Index-XiangmuDabian.aspx?id=" + id, true);
            }
            else
            {
                b.SetError("修改失败");
                result = new RedirctResult("SheZhi_Duanxin.aspx", true);
            }
            return result;
        }
        //项目答辩回复
        public static RedirctResult xmdb_Edit(string comment, string id)
        {
            BasePage b = new BasePage();
            RedirctResult result = null;
            IAsk _ask = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {

                _ask = session.Ask.GetByID(Convert.ToInt32(id));
            }
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                _ask.Comment = comment;
                i = session.Ask.Update(_ask);
            }
            if (i > 0)
            {
                b.SetSuccess("回复成功");
                result = new RedirctResult("Index-XiangmuDabian.aspx?id=" + id, true);
            }
            else
            {
                b.SetError("回复失败");
                result = new RedirctResult("SheZhi_Duanxin.aspx", true);
            }
            return result;
        }
    }
}
