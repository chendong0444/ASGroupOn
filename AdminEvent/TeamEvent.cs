using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.App;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Controls;
using AS.Common.Utils;
using System.Data;
using System.Web;
using AS.GroupOn.Domain.Spi;
using AS.Common;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn;
using AS.Common;
using AS.GroupOn.DataAccess.Accessor;
using System.Linq;
namespace AS.AdminEvent
{
    /// <summary>
    /// 项目后台事件
    /// </summary>
    public class TeamEvent
    {
        private static RedirctResult result = null;
        //int i = 0;
        public RedirctResult Check(string ddlproductstatus, string remark, int id)
        {
            ProductFilter productft = new ProductFilter();

            IProduct productmodel;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                productmodel = session.Product.GetByID(id);
            }
            UserFilter userft = new UserFilter();
            productmodel.status = Helper.GetInt(ddlproductstatus, 0);
            productmodel.ramark = Helper.GetString(remark, String.Empty);
            productmodel.adminid = AdminPage.AsAdmin.Id;

            productmodel.operatortype = 0;

            TeamFilter teamft = new TeamFilter();
            IList<ITeam> listteam = null;
            int ires = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ires = session.Product.Update(productmodel);
            }

            if (ires > 0)
            {
                teamft.productid = id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    listteam = session.Teams.GetList(teamft);
                }
                if (listteam != null && listteam.Count > 0)
                {
                    foreach (var item in listteam)
                    {
                        if (productmodel.status == 8)
                        {
                            //下架  当产品有项目手动设置下架的时候，项目status 应该设置为下架状态
                            item.status = 8;
                            item.productid = id;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id2 = session.Teams.Update(item);
                            }

                        }
                        else if (productmodel.status == 1)
                        {
                            //上架  当产品有项目手动设置下架的时候，项目status 应该设置为下架状态
                            item.status = 1;
                            item.productid = id;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id2 = session.Teams.Update(item);
                            }
                        }
                    }
                }
                PageValue.SetMessage(new ShowMessageResult("产品审核成功", true, true));
                result = new RedirctResult("ProductList.aspx", true);
            }
            else
            {
                PageValue.SetMessage(new ShowMessageResult("产品审核失败", false, false));
                result = new RedirctResult("ProductList.aspx", true);
            }

            return result;
        }
        public RedirctResult ManCheck(string ddlproductstatus, string remark, int id)
        {
            ProductFilter productft = new ProductFilter();

            IProduct productmodel;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                productmodel = session.Product.GetByID(id);
            }
            UserFilter userft = new UserFilter();
            productmodel.status = Helper.GetInt(ddlproductstatus, 0);
            productmodel.ramark = Helper.GetString(remark, String.Empty);
            productmodel.adminid = AdminPage.AsAdmin.Id;

            productmodel.operatortype = 0;

            TeamFilter teamft = new TeamFilter();
            IList<ITeam> listteam = null;
            int ires = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ires = session.Product.Update(productmodel);
            }

            if (ires > 0)
            {
                teamft.productid = id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    listteam = session.Teams.GetList(teamft);
                }
                if (listteam != null && listteam.Count > 0)
                {
                    foreach (var item in listteam)
                    {
                        if (productmodel.status == 8)
                        {
                            //下架  当产品有项目手动设置下架的时候，项目status 应该设置为下架状态
                            item.status = 8;
                            item.productid = id;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id2 = session.Teams.Update(item);
                            }

                        }
                        else if (productmodel.status == 1)
                        {
                            //上架  当产品有项目手动设置下架的时候，项目status 应该设置为下架状态
                            item.status = 1;
                            item.productid = id;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id2 = session.Teams.Update(item);
                            }
                        }
                    }
                }
                PageValue.SetMessage(new ShowMessageResult("产品审核成功", true, true));
                result = new RedirctResult("ProductList.aspx", true);
            }
            else
            {
                PageValue.SetMessage(new ShowMessageResult("产品审核失败", false, false));
                result = new RedirctResult("ProductList.aspx", true);
            }

            return result;
        }
    }
}
