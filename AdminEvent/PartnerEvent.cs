using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Controls;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess.Accessor;
using AS.Common.Utils;
using System.Web;
using AS.GroupOn.Domain.Spi;
using AS.GroupOn.DataAccess;
using AS.GroupOn.App;
using System.IO;

namespace AS.AdminEvent
{
    /// <summary>
    /// 商户后台事件
    /// </summary>
    public class PartnerEvent
    {
        private static RedirctResult result = null;
        /// <summary>
        /// 新建分站
        /// </summary>
        public RedirctResult Insert_ShanghuBranch(int partnerid, string username, string newuserpwd, string userpwd, string branchname, string contact, string phone, string address, string mobile, string secret, string jingweidu) 
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Branch_Add))
            {
                PageValue.SetMessage(new ShowMessageResult("你没有添加分站的权限", false, false));
                result = new RedirctResult("index_index.aspx", true);
                return result;
            }
            else 
            {
                IBranch bran = new Branch();
                bran.partnerid = partnerid;
                bran.username = username;
                //验证商户分站用户名唯一性
                BranchFilter filter = new BranchFilter();
                IList<IBranch> branch = null;
                filter.AddSortOrder(BranchFilter.ID_DESC);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                {
                    branch = session.Branch.GetList(filter);
                }
                foreach (IBranch  item in branch)
                {
                    if (item.username == username) 
                    {
                        PageValue.SetMessage(new ShowMessageResult("用户名已存在", false, false));
                        result = new RedirctResult("ShangHuBranch.aspx?bid=" + partnerid, true);
                        return result;
                    }
                }
                if (userpwd != newuserpwd) 
                {
                    PageValue.SetMessage(new ShowMessageResult("两次密码不一致", false, false));
                    result = new RedirctResult("ShangHuBranch.aspx?bid=" + partnerid, true);
                    return result;
                }
                bran.userpwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(userpwd + BasePage.PassWordKey, "md5");
                bran.branchname = branchname;
                bran.contact = contact;
                bran.phone = phone;
                bran.address = address;
                bran.mobile = mobile;
                bran.secret = secret;
                bran.point = jingweidu;
                int count = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                {
                    count = session.Branch.Insert(bran);
                }
                if (count > 0)
                    PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
                else
                    PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
                result = new RedirctResult("ShangHuBranch.aspx?bid=" + partnerid, true);
                return result;
            }   
        }
        /// <summary>
        /// 编辑分站
        /// </summary>
        public RedirctResult Update_ShangHuBranch(int id, int partnerid, string username, string userpwd, string userpwda, string newuserpwd, string branchname, string contact, string phone, string address, string mobile,string secret, string jingweidu) 
        {
            IBranch bran = new Branch();
            bran.id = id;
            bran.partnerid = partnerid;
            bran.username = username;
            //验证商户分站用户名唯一性
            BranchFilter filter = new BranchFilter();
            IList<IBranch> branch = null;
            filter.AddSortOrder(BranchFilter.ID_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                branch = session.Branch.GetList(filter);
            }
            if (branch != null)
            {
                foreach (IBranch item in branch)
                {
                    if (item.username == username && item.id != id)
                    {
                        PageValue.SetMessage(new ShowMessageResult("用户名已存在", false, false));
                        result = new RedirctResult("ShangHuBranch.aspx?bid=" + partnerid, true);
                        return result;
                    }
                }
            }
            //用户是否有修改密码
            if (!string.IsNullOrEmpty(userpwda))
            {
                if (userpwda == newuserpwd)
                {
                    bran.userpwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(userpwda + BasePage.PassWordKey, "md5");
                }
                else 
                {
                    PageValue.SetMessage(new ShowMessageResult("两次密码不一致", false, false));
                    result = new RedirctResult("ShangHuBranch_Bianji.aspx?bid=" + partnerid + "&branch_id=" + id, true);
                    return result;
                }
            }
            else
            {
                bran.userpwd = userpwd;
            }
            bran.branchname = branchname;
            bran.contact = contact;
            bran.phone = phone;
            bran.address = address;
            bran.mobile = mobile;
            bran.secret = secret;
            bran.point = jingweidu;
            int count = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
            {
                count = session.Branch.Update(bran);
            }
            if (count > 0)
                PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
            result = new RedirctResult("ShangHuBranch.aspx?bid=" + partnerid, true);
            return result;
        
        }
        /// <summary>
        /// 新增商户分类
        /// </summary>
        public RedirctResult Insert_ShangHu_Type(string name, string ename, string letter, string czone, string disp, int sortorder) 
        {
            ICategory category = new Category();
            category.Name = name;
            category.Ename = ename.Length > 20 ? ename.Substring(0, 20) : ename;
            category.Letter = letter;
            category.Czone = czone;
            category.Display = disp.ToUpper() == "Y" ? "Y" : "N";
            category.Sort_order = sortorder;
            category.Zone = "partner";
            //中文名英文名唯一性验证
            CategoryFilter filter = new CategoryFilter();
            IList<ICategory> list = null;
            filter.Zone = "partner";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
            {
                list = session.Category.GetList(filter);
            }
            if (list!=null) 
            {
                foreach (Category item in list)
                {
                    if (item.Name == name) 
                    {
                        PageValue.SetMessage(new ShowMessageResult("请确保中英文名称没有重复", false, false));
                        result = new RedirctResult("Type_ShanghuFenlei.aspx?names=false", true);
                        return result;
                    }
                    else if (item.Ename == ename)
                    {
                        PageValue.SetMessage(new ShowMessageResult("请确保中英文名称没有重复", false, false));
                        result = new RedirctResult("Type_ShanghuFenlei.aspx?enames=false", true);
                        return result;
                    }
                  
                }
            }

            int cout = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
            {
                cout = session.Category.Insert(category);
            }
            if (cout > 0)
                PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
            result = new RedirctResult("Type_ShanghuFenlei.aspx", true);
            return result;
        }
        /// <summary>
        /// 编辑商户分类
        /// </summary>
        public RedirctResult Update_ShangHu_Type(int categoryid, string name, string ename, string letter, string czone, string disp, int sortorder)
        {
            ICategory category = new Category();
            category.Id = categoryid;
            category.Name = name;

            category.Ename = ename.Length > 20 ? ename.Substring(0, 20) : ename;

            //中文名英文名唯一性验证
            CategoryFilter filter = new CategoryFilter();
            IList<ICategory> list = null;
            filter.Zone = "partner";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                list = session.Category.GetList(filter);
            }
            if (list != null)
            {
                foreach (Category item in list)
                {
                    if (item.Id != categoryid && item.Name == name)
                    {
                        PageValue.SetMessage(new ShowMessageResult("请确保中英文名称没有重复", false, false));
                        result = new RedirctResult("Type_ShanghuFenlei.aspx?names=false", true);
                        return result;
                    }
                    else if (item.Id != categoryid && item.Ename == ename)
                    {
                        PageValue.SetMessage(new ShowMessageResult("请确保中英文名称没有重复", false, false));
                        result = new RedirctResult("Type_ShanghuFenlei.aspx?names=false", true);
                        return result;
                    }
                }
            }

            category.Letter = letter;
            category.Czone = czone;
            category.Display = disp.ToUpper() == "Y" ? "Y" : "N";
            category.Sort_order = sortorder;
            category.Zone = "partner";

            int count = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                count = session.Category.Update(category);
            }
            if (count > 0)
                PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
            result = new RedirctResult("Type_ShanghuFenlei.aspx", true);
            return result;
        }
        /// <summary>
        /// 结算商户
        /// </summary>
        public RedirctResult JieSuanShangHu(int teamid, int number, decimal pmoneys, string remark, int pid) 
        {
            if (teamid != 0)
            {
                if (number > 0)
                {
                    IPartner_Detail pdlist = new Partner_Detail();
                    pdlist.createtime = DateTime.Now;
                    pdlist.team_id = teamid;
                    pdlist.num = number;
                    pdlist.money = pmoneys;
                    pdlist.remark = remark;
                    pdlist.settlementstate = 8;
                    pdlist.adminid = AS.GroupOn.Controls.PageValue.CurrentAdmin.Id;
                    pdlist.partnerid = pid;
                    int num = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        num = session.Partner_Detail.Insert(pdlist);
                    }
                    if (num > 0)
                    {
                        PageValue.SetMessage(new ShowMessageResult("结算成功", true, true));
                        result = new RedirctResult("JieSuan_ShenHe.aspx?Id=" + pid, true);
                    }
                    else
                    {
                        PageValue.SetMessage(new ShowMessageResult("结算失败", false, false));
                        result = new RedirctResult("JieSuan_ShenHe.aspx?Id=" + pid, true);
                    }
                }
                else
                {
                    PageValue.SetMessage(new ShowMessageResult("结算失败", false, false));
                    result = new RedirctResult("JieSuan_ShenHe.aspx?Id=" + pid, true);
                }
            }
            else 
            {
                PageValue.SetMessage(new ShowMessageResult("没有该项目,无法结算", false, false));
                result = new RedirctResult("JieSuan_ShenHe.aspx?Id=" + pid, true);
            }
            
            return result;
        }
    }
}
