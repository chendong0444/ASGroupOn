using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
using AS.GroupOn.App;
using AS.GroupOn.DataAccess.Filters;
using AS.Common.Utils;
using System.Collections;
using System.Data;

namespace AS.GroupOn.Controls
{
   public class Catalogs
    {

       public static string GetCataId(int cataid)
       {
           string cid = "";
           CatalogsFilter cf = new CatalogsFilter();
           cf.id = cataid;
           ICatalogs catalogs = Store.CreateCatalogs();
           using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
           {
             catalogs = seion.Catalogs.Get(cf);
           }

           if (catalogs != null)
           {
               if (Helper.GetString(catalogs.ids, "") != "")
               {
                   cid = catalogs.ids + "," + cataid;

               }
               else
               {
                   cid = cataid.ToString();
               }
           }
           return cid;
       }


       #region 根据条件top二级大类
       public static IList<ICatalogs> GetCata(string where)
       {
           IList<ICatalogs> listcata = null;
           CatalogsFilter cf = new CatalogsFilter();
           cf.type = 0;
           cf.parent_idNotZero = 0;
           cf.visibility = 0;
           if (where != "")
           {
               cf.Where = where;
           }
           using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
           {
              listcata = seion.Catalogs.GetList(cf);
           }
           return listcata;
       }
       #endregion

       #region 显示大类
       public static IList<ICatalogs> GettopCata(int cityid)
       {
           IList<ICatalogs> catalist = null;
           CatalogsFilter cf = new CatalogsFilter();
           cf.type = 0;
           cf.parent_id = 0;
           cf.visibility = 0;
           cf.AddSortOrder(CatalogsFilter.MoreSort_DESC_ASC);
           if (cityid != 0)
           {
               cf.cityidLikeOr = cityid;
           }
           using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
           {
               catalist = seion.Catalogs.GetList(cf);
           }
           return catalist;
       }
       #endregion


       /// <summary>
       /// 根据项目类型，显示项目数量
       /// </summary>
       /// <param name="type">项目类型</param>
       /// <param name="cataid">分类id</param>
       /// <param name="cityid">城市id</param>
       /// <returns></returns>
       public static int GetSumTeam(string teamtype, int cataid, int cityid)
       {
           int sum = 0;
           string cid = "";
           ICatalogs catalogmodel = null;
           CatalogsFilter cataft = new CatalogsFilter();
           TeamFilter teamft = new TeamFilter();
           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
           {
               catalogmodel = session.Catalogs.GetByID(cataid);
           }
           if (catalogmodel != null)
           {
               if (AS.Common.Utils.Helper.GetString(catalogmodel.ids, "") != "")
               {
                   cid = catalogmodel.ids + "," + cataid;
               }
               else
               {
                   cid = cataid.ToString();
               }
           }           
            teamft.Cityblockothers = cityid; // 包含了城市id为0  即城市为全部城市的情况
           
           if (AS.Common.Utils.Helper.GetString(cid, "") != "" && cid.Replace(",", "") != "") //分类城市为全部城市
           {
               teamft.CataIDin = cid;
           }
           if (PageValue.CurrentSystem.Displayfailure == 0)
           {
               teamft.not = "";
           }
           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
           {
               if (teamtype != String.Empty && teamtype != "")
               {
                   teamft.teamcata = 0;
                   if (teamtype == "normal")
                   {
                       teamft.Team_type = "normal";
                       sum = session.Teams.GetCount(teamft);
                   }
                   else if (teamtype == "seconds")
                   {
                       teamft.Team_type = "seconds";
                       sum = session.Teams.GetCount(teamft);
                   }
                   else if (teamtype == "goods")
                   {
                       teamft.Team_type = "goods";
                       teamft.ToBegin_time = System.DateTime.Now;
                       teamft.FromEndTime = System.DateTime.Now;
                       sum = session.Teams.GetCount(teamft);
                   }
                   else if (teamtype == "notice")
                   {
                       teamft.Team_type = "normal";
                       teamft.isPredict = 1;
                       teamft.FromBegin_time = System.DateTime.Now;
                       teamft.FromEndTime = System.DateTime.Now;
                       sum = session.Teams.GetCount(teamft);
                   }
                   else
                   {
                       teamft.Team_type = "normal";
                       sum = session.Teams.GetCount(teamft);
                   }
               }
               else
               {
                   teamft.teamcata = 0;
                   teamft.Team_type = "normal";
                   sum = session.Teams.GetCount(teamft);
               }
           }
           return sum;
       }
    }
}
