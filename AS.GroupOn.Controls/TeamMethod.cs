using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using AS.GroupOn.Domain;
using System.Collections;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using AS.Common.Utils;
using AS.GroupOn.App;
using System.Collections.Specialized;
using AS.GroupOn.Domain.Spi;


namespace AS.GroupOn.Controls
{
    public class TeamMethod
    {
        #region 显示关键字
        public static List<key> Getkey(string where, string cityid)
        {
            List<key> keylist = new List<key>();
            List<Hashtable> hs = new List<Hashtable>();
            key keymodel;
            DataSet ds = new DataSet();
            string str = "select keyword from catalogs where type=0 and visibility=0";
            if (where != "")
            {
                if (cityid != "0")
                    str = str + "and (cityid like '%," + cityid + ",%'  or cityid like '%,0,%') and " + where;
                else
                    str = str + "and" + where;
            }
            else
            {
                if (cityid != "0")
                    str = str + "and (cityid like '%," + cityid + ",%'  or cityid like '%,0,%')";
            }
            using (IDataSession session = Store.OpenSession(false))
            {
                hs = session.GetData.GetDataList(str);
            }
            if (hs.Count > 0)
            {
                for (int i = 0; i < hs.Count; i++)
                {
                    string[] num = hs[i]["keyword"].ToString().Split(',');
                    for (int j = 0; j < num.Length; j++)
                    {
                        if (!str.Contains(num[j]))
                        {
                            str += num[j] + ",";
                            keymodel = new key();
                            keymodel.keyname = num[j];
                            keylist.Add(keymodel);
                        }
                    }
                }
            }
            return keylist;
        }
        #endregion

        #region 显示區域
        public static IList<IArea> GetArea(int cityid)
        {
            AreaFilter af = new AreaFilter();
            IList<IArea> areaList = null;
            if (cityid != 0)
            {
                af.cityid = cityid;
            }
            af.type = "area";
            af.display = "Y";
            using (IDataSession session = Store.OpenSession(false))
            {
                areaList = session.Area.GetList(af);
            }
            return areaList;
        }
        #endregion

        #region 根据项目分类的编号，显示此分类下面团购项目的数量
        /// <summary>
        /// 根据项目分类的编号，显示此分类下面团购项目的数量
        /// </summary>
        /// <param name="cataid">分类ID</param>
        /// <param name="cityid">城市ID</param>
        /// <returns></returns>
        public static int GetSum(int cataid, int cityid, int teamid)
        {
            int sum = 0;
            string where = "";
            List<Hashtable> hs = new List<Hashtable>();
            if (teamid != 0) where += " and id not in(" + teamid + ") ";
            if (cityid != 0) where = " and (city_id=" + cityid + " or level_cityid=" + cityid + " or othercity like '%," + cityid + ",%' or city_id=0)";
            if (cataid != 0) where += " and cataid in (" + cataid + ")";
            string sql = string.Format("select count(Id) as sum from Team where teamcata=0 and Team_type='normal' and  Begin_time<='{0}' and End_time>='{1}' {2}", DateTime.Now.ToString(), DateTime.Now.ToString(), where);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                hs = session.GetData.GetDataList(sql);
            }
            if (hs.Count > 0)
            {
                sum = Helper.GetInt(hs[0]["sum"].ToString(), 0);
            }
            return sum;
        }
        #endregion


        #region 显示主推大类
        public static IList<ICatalogs> GethostCata(int top, int cityid)
        {
            IList<ICatalogs> catalist = new List<ICatalogs>();
            CatalogsFilter cf = new CatalogsFilter();
            cf.type = 0;
            cf.parent_id = 0;
            cf.visibility = 0;
            cf.catahost = 0;
            if (top == 0)
            {
                if (cityid != 0)
                {
                    cf.cityidLikeOr = cityid;
                }
            }
            else
            {
                cf.Top = top;
                if (cityid != 0)
                {
                    cf.cityidLikeOr = cityid;
                }
            }
            cf.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
            using (IDataSession session = Store.OpenSession(false))
            {
                catalist = session.Catalogs.GetList(cf);
            }
            return catalist;
        }
        #endregion

        #region 根据项目分类的编号，显示团购项目的信息
        public static IList<ITeam> GetTopTeam(int cityid, int top, string cataid, string ids)
        {
            IList<ITeam> teamlist = null;
            DataSet ds = new DataSet();
            string sql = "";
            if (top == 0)//如果top 为0 ，那么查询全部
            {
                if (cityid == 0)
                {
                    if (cataid != "")
                    {
                        sql = "select * from Team where teamcata=0 and teamhost=0 and teamnew=0 and  (Team_type='normal' or Delivery='draw')  and Begin_time<='" + DateTime.Now.ToString() + "' and id not in(" + ids + ")  and end_time>='" + DateTime.Now.ToString() + "' and cataid in (" + cataid + ")  order by  sort_order desc,Begin_time desc,id desc";
                    }
                    else
                    {
                        sql = "select * from Team where teamcata=0 and teamhost=0 and teamnew=0 and (Team_type='normal' or Delivery='draw')  and Begin_time<='" + DateTime.Now.ToString() + "' and id not in(" + ids + ")  and end_time>='" + DateTime.Now.ToString() + "'   order by  sort_order desc,Begin_time desc,id desc";
                    }
                }
                else
                {
                    if (cataid != "")
                    {
                        sql = "select * from Team where teamcata=0 and teamhost=0 and teamnew=0 and (Team_type='normal' or Delivery='draw')  and Begin_time<='" + DateTime.Now.ToString() + "' and id not in(" + ids + ")  and end_time>='" + DateTime.Now.ToString() + "' and (City_id=" + cityid + " or level_cityid=" + cityid + " or city_id=0 or ','+othercity+',' like '%," + cityid + ",%')   and cataid in (" + cataid + ") order by  sort_order desc,Begin_time desc,id desc";
                    }
                    else
                    {
                        sql = "select * from Team where teamcata=0 and teamhost=0 and teamnew=0 and (Team_type='normal' or Delivery='draw')  and Begin_time<='" + DateTime.Now.ToString() + "' and id not in(" + ids + ")  and end_time>='" + DateTime.Now.ToString() + "' and (City_id=" + cityid + " or level_cityid=" + cityid + " or city_id=0 or ','+othercity+',' like '%," + cityid + ",%')  order by  sort_order desc,Begin_time desc,id desc";
                    }
                }
            }
            else
            {
                if (cityid == 0)
                {
                    if (cataid != "")
                    {
                        sql = "select top " + top + " * from Team where teamcata=0 and teamhost=0 and teamnew=0 and (Team_type='normal' or Delivery='draw')  and Begin_time<='" + DateTime.Now.ToString() + "' and id not in(" + ids + ")  and end_time>='" + DateTime.Now.ToString() + "' and cataid in (" + cataid + ") order by  sort_order desc,Begin_time desc,id desc";
                    }
                    else
                    {
                        sql = "select top " + top + " * from Team where teamcata=0 and teamhost=0 and teamnew=0  and (Team_type='normal' or Delivery='draw')  and Begin_time<='" + DateTime.Now.ToString() + "' and id not in(" + ids + ")  and end_time>='" + DateTime.Now.ToString() + "' order by  sort_order desc,Begin_time desc,id desc";
                    }


                }
                else
                {
                    if (cataid != "")
                    {
                        sql = "select top " + top + " * from Team where teamcata=0 and teamhost=0 and teamnew=0 and (Team_type='normal' or Delivery='draw')  and Begin_time<='" + DateTime.Now.ToString() + "' and id not in(" + ids + ")  and end_time>='" + DateTime.Now.ToString() + "' and (City_id=" + cityid + " or  level_cityid=" + cityid + " or  city_id=0 or ','+othercity+',' like '%," + cityid + ",%') and cataid in (" + cataid + ") order by  sort_order desc,Begin_time desc,id desc";
                    }
                    else
                    {
                        sql = "select top " + top + " * from Team where teamcata=0 and teamhost=0 and teamnew=0 and (Team_type='normal' or Delivery='draw')  and Begin_time<='" + DateTime.Now.ToString() + "' and id not in(" + ids + ")  and end_time>='" + DateTime.Now.ToString() + "' and (City_id=" + cityid + " or  level_cityid=" + cityid + "  or city_id=0 or ','+othercity+',' like '%," + cityid + ",%') order by  sort_order desc,Begin_time desc,id desc";
                    }
                }
            }
            using (IDataSession session = Store.OpenSession(false))
            {
                teamlist = session.Teams.GetList(sql);
            }
            return teamlist;
        }
        #endregion

        #region 根据条件显示全部大类
        /// <summary>
        /// 全部大类
        /// </summary>
        /// <param name="top"></param>
        /// <param name="parent_id"></param>
        /// <returns></returns>
        public static IList<ICatalogs> GetCataall(int top, int parent_id, int cityid)
        {
            IList<ICatalogs> catalist = null;
            CatalogsFilter cf = new CatalogsFilter();
            cf.type = 0;
            cf.visibility = 0;
            if (top != 0)
                cf.Top = top;
            if (parent_id != 0)
                cf.parent_id = parent_id;
            if (cityid != 0)
                cf.cityidLikeOr = cityid;
            cf.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
            using (IDataSession session = Store.OpenSession(false))
            {
                catalist = session.Catalogs.GetList(cf);
            }
            return catalist;
        }
        #endregion

        #region 显示大类
        public static IList<ICatalogs> GettopCata(int cityid)
        {
            IList<ICatalogs> catalist = null;
            CatalogsFilter cf = new CatalogsFilter();
            cf.type = 0;
            cf.visibility = 0;
            cf.parent_id = 0;
            if (cityid != 0)
                cf.cityidLikeOr = cityid;
            cf.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
            using (IDataSession session = Store.OpenSession(false))
            {
                catalist = session.Catalogs.GetList(cf);
            }
            return catalist;
        }
        #endregion

        #region 判断此项目是否购物车
        public static bool isShop(ITeam model)
        {
            bool falg = false;
            NameValueCollection configs = WebUtils.GetSystem();
            if (configs["closeshopcar"] == "0")//开启购物车车标志
            {
                //2013年4月23日9:45:23修改(判断如果是不同规格不同价格项目则不能加入购物车)
                if (model.Delivery == "express" && !Utilys.GetTeamType(model.Id))//是否是快递
                {
                    falg = true;
                }
            }
            return falg;
        }
        #endregion

        public static int GetBuyCount(int userid, int teamid)
        {

            int buycount1 = 0;
            int buycount2 = 0;
            OrderFilter of = new OrderFilter();
            of.User_id = userid;
            of.Team_id = teamid;
            of.State = "pay";
            OrderDetailFilter odf = new OrderDetailFilter();
            odf.order_userid = userid;
            odf.Teamid = teamid;

            using (IDataSession seion = Store.OpenSession(false))
            {
                buycount1 = seion.Orders.GetBuyCount1(of);
            }
            using (IDataSession seion = Store.OpenSession(false))
            {
                buycount2 = seion.OrderDetail.GetBuyCount2(odf);
            }

            return buycount1 + buycount2;

        }

        #region 根据项目分类的编号、关键词、品牌、城市、区域，显示此分类下面项目的数量
        public static int GetSumByArea(int cataid, string keyword, int brandid, int cityid, int areaid)
        {
            int sum = 0;
            string wheresql = "";
            if (cityid != 0)
            {
                wheresql += " and (city_id=" + cityid + " or  level_cityid=" + cityid + " or othercity  like '%," + cityid + ",%' or city_id=0)";
            }
            if (cataid != 0)
            {
                ICatalogs catalogs = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    catalogs = session.Catalogs.GetByID(cataid);
                }
                if (catalogs != null)
                {
                    if (Helper.GetString(catalogs.ids, String.Empty) != String.Empty)
                    {
                        wheresql += " and cataid in (" + catalogs.ids.Trim(',') + "," + cataid + ")";
                    }
                    else
                    {
                        wheresql += " and cataid in (" + cataid.ToString().Trim(',') + ")";
                    }
                }
            }
            if (Helper.GetString(keyword, String.Empty) != String.Empty)
            {
                wheresql += " and (title like '%" + keyword + "%' or catakey like '%" + keyword + "%')";
            }
            if (brandid != 0)
            {
                wheresql += " and brand_id=" + brandid;
            }
            if (areaid != 0)
            {
                IArea area = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    area = session.Area.GetByID(areaid);
                }
                if (area != null)
                {
                    if (area.type == "area")
                        wheresql += " and areaid=" + areaid;
                    else
                        wheresql += " and circleid=" + areaid;
                }
            }
            string sql = string.Format("select count(*) as sum from Team where teamcata=0 and (Team_type='normal' or Team_type='goods' or Team_type='seconds' ) and  Begin_time<='{0}' and End_time>='{1}' {2}", DateTime.Now.ToString(), DateTime.Now.ToString(), wheresql);
            IList<Hashtable> teamlist = null;
            using (IDataSession seion = Store.OpenSession(false))
            {
                teamlist = seion.Custom.Query(sql);
            }
            if (teamlist != null && teamlist.Count > 0)
            {
                sum = Helper.GetInt(teamlist[0]["sum"].ToString(), 0);
            }
            return sum;
        }

        public static string GetTeamListByArea(int cataid, string keyword, int brandid, int cityid, int areaid)
        {
            string wheresql = "";
            if (cityid != 0)
            {
                wheresql += " and (city_id=" + cityid + " or  level_cityid=" + cityid + " or othercity  like '%," + cityid + ",%' or city_id=0)";
            }
            if (cataid != 0)
            {
                ICatalogs catalogs = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    catalogs = session.Catalogs.GetByID(cataid);
                }
                if (catalogs != null)
                {
                    if (Helper.GetString(catalogs.ids, String.Empty) != String.Empty)
                    {
                        wheresql += " and cataid in (" + catalogs.ids + "," + cataid + ")";
                    }
                    else
                    {
                        wheresql += " and cataid in (" + cataid.ToString() + ")";
                    }
                }
            }
            if (keyword != null && keyword != "")
            {
                wheresql += " and (title like '%" + keyword + "%' or catakey like '%" + keyword + "%')";
            }
            if (brandid != 0)
            {
                wheresql += " and brand_id=" + brandid;
            }
            if (areaid != 0)
            {
                IArea area = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    area = session.Area.GetByID(areaid);
                }
                if (area != null)
                {
                    if (area.type == "area")
                        wheresql += " and areaid=" + areaid;
                    else
                        wheresql += " and circleid=" + areaid;
                }
            }
            string sql = string.Format("select * from Team where teamcata=0 and (Team_type='normal' or Team_type='goods' or  Team_type='seconds' ) and  Begin_time<='{0}' and End_time>='{1}' {2}", DateTime.Now.ToString(), DateTime.Now.ToString(), wheresql);
            return sql;
        }
        #endregion


        #region 查询项目的分页
        public static string GetTeamPageStr(int count, int pagenum, int acinum, string kfid, string keyid, string p, string keyname, string tname, string categoryid)
        {
            StringBuilder Notin = new StringBuilder();

            int countpage = count / acinum;
            int yucount = count % acinum;
            if (yucount > 0)
                countpage++;
            int num = 1;
            if (countpage > 11)
            {
                if (pagenum > 6)
                    num = pagenum - 5;
            }
            Notin.Append("<UL class=paginator>");
            Notin.Append("<a href='" + PageValue.WebRoot + "usercontrols_tuandetail.aspx?pgnum=1'><<</a>");
            for (int i = num; i <= 11 + num; i++)
            {//推荐
                if (i <= countpage)
                {
                    if (i == pagenum)
                        Notin.Append("<LI class=current><a href='" + PageValue.WebRoot + "usercontrols_tuandetail.aspx?kfid=" + kfid + "&keyid=" + keyid + "&keyname=" + keyname + "&p=" + p + "&pgnum=" + i + "&t=" + tname + "&cateid=" + categoryid + "'><font>" + i + "</font></a></li>");
                    else
                        Notin.Append("<LI><a href='" + PageValue.WebRoot + "usercontrols_tuandetail.aspx?kfid=" + kfid + "&keyid=" + keyid + "&keyname=" + keyname + "&p=" + p + "&pgnum=" + i + "&t=" + tname + "&cateid=" + categoryid + "'>" + i + "</a></li>");
                }
            }
            Notin.Append("<a href='" + PageValue.WebRoot + "usercontrols_tuandetail.aspx?kfid=" + kfid + "&keyid=" + keyid + "&keyname=" + keyname + "&p=" + p + "&pgnum=" + countpage + "&t=" + tname + "&cateid=" + categoryid + "'>>></a>");
            Notin.Append("</ul>");
            return Notin.ToString();
        }
        #endregion

        #region 获取项目类型
        public static string GetTeamtype(ITeam team)
        {
            string strtitle = "";
            if (team != null)
            {
                if (team.Team_type == "seconds")
                    strtitle = "今日秒杀";
                if (team.Team_type == "goods")
                    strtitle = "今日热销";
                if (team.Team_type == "normal")
                    strtitle = "今日团购";
                if (team.Team_type == "draw")
                    strtitle = "今日抽奖";
            }
            else
            {
                strtitle = "今日团购";
            }
            return strtitle;
        }
        #endregion

        #region 项目删除操作
        public static int delProject(int id)
        {
            int num = 0;
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                num = session.Teams.Delete(id);
            }
            OrderFilter orderfilter = new OrderFilter();
            OrderDetailFilter orderdetailfilter = new OrderDetailFilter();
            IList<IOrder> orderlist = null;
            orderfilter.Team_id = id;
            orderfilter.StateIn = "'unpay','cancel'";
            orderdetailfilter.Teamid = id;
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                orderlist = session.Orders.GetList(orderfilter);

            }
            if (orderlist != null && orderlist.Count > 0)
            {
                foreach (var order in orderlist)
                {
                    using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.Orders.Delete(order.Id);
                    }
                }
            }
            List<Hashtable> hs = null;
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                hs = session.Custom.Query("select o.*,d.id as detailid from orderdetail as d,[Order] as o where d.Teamid='" + id + "' and d.Order_id=o.Id and (o.State='unpay' or o.State='cancel')");
            }
            if (hs != null && hs.Count > 0)
            {
                foreach (var orderdetail in hs)
                {
                    using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.Orders.Delete(Convert.ToInt32(orderdetail["Id"]));
                        session.OrderDetail.Delete(Convert.ToInt32(orderdetail["detailid"]));
                    }
                }
            }
            return num;
        }
        #endregion

        #region 判断项目是否已是成交的项目
        public static bool isExist(int id)
        {
            OrderFilter orderfilter = new OrderFilter();
            OrderDetailFilter orderdetailfilter = new OrderDetailFilter();

            IList<IOrderDetail> orderdetaillist = null;
            IList<IOrder> orderlist = null;
            bool result = false;
            orderdetailfilter.TeamidOrder = id;
            orderfilter.Team_id = id;
            orderfilter.State = "pay";

            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                orderdetaillist = session.OrderDetail.GetList(orderdetailfilter);
                orderlist = session.Orders.GetList(orderfilter);
            }

            if (orderlist.Count > 0 || orderdetaillist.Count > 0)
            {
                result = true;
            }
            return result;
        }
        #endregion

        #region 项目数据下载
        /// <summary>
        /// 下载
        /// </summary>
        /// <param name="teamid"></param>
        //属于购物车的项目名称

        public static string xiazai(string teamid)
        {
            ITeam teamodel = null;
            ICategory categorymodel = null;
            string[] GteamName = new string[1];
            //属于购物车的项目ID
            int[] GteamID = new int[1];
            //属于购物车项目的商品名称
            string[] Product = new string[1];
            //属于购物车的购买数量
            int[] GNum = new int[1];
            //属于购物车的规格
            string[] GResult = new string[1];
            bool blag = true;
            System.Data.DataTable dt = null;
            StringBuilder sb1 = new StringBuilder();
            IOrder order = null;
            IUser usermodel = null;
            //不属于购物车的项目名称
            string teamName;
            //不属于购物车的项目ID
            int teamID;
            //记录是否属于购物车,如果是false就不属于购物车，否则属于购物车
            bool result = false;
            string where = " 1=1  ";
            string orderby = "[order].create_time";
            if (teamid != "0")
            {
                where = where + " and (Team_id=" + teamid + " or teamid=" + teamid + ")";
            }
            where = where + " and state='pay'";
            List<Hashtable> halis = null;
            //select [order].Id,[order].Pay_id ,[order].Express,[order].State,[order].Service,[order].Price,[order].Fare,[order].Origin,[order].Money,[order].Credit,[order].fromdomain ,[order].adminremark,[order].IP_Address,[order].Realname,[order].Address,[order].Zipcode,[order].Mobile,[order].User_id,  orderdetail.Order_id,[order].Card  ,orderdetail.result as bb , User_id , Admin_id, State, Quantity from [order] left join orderdetail on [order].Id=orderdetail.order_id left join [user] on User_id=[user].Id  where  1=1   and (Team_id=3959 or teamid=3959) and state='pay' order by [order].create_time
            //select *,orderdetail.result as bb  ,[order].result as aa , from [order] left join orderdetail on [order].Id=orderdetail.order_id left join [user] on User_id=[user].Id  where " + where + " order by " + orderby



            using (IDataSession sesssion = AS.GroupOn.App.Store.OpenSession(false))
            {
                halis = sesssion.GetData.GetDataList("select [order].Id,[order].Pay_id ,[order].Express,[order].State,[order].Service,[order].Price,[order].Fare,[order].Origin,[order].Money,[order].Credit,[order].fromdomain ,[order].adminremark,[order].IP_Address,[order].Realname,[order].Address,[order].Zipcode,[order].Mobile,[order].User_id,  orderdetail.Order_id,[order].Card  , [order].Team_id,orderdetail.result,[order].Pay_time,[order].Remark,[order].Express_id,Quantity ,[User].Username,[User].Email from [order] left join orderdetail on [order].Id=orderdetail.order_id left join [user] on User_id=[user].Id  where " + where + " order by " + orderby);
            }


            sb1.Append("<html>");
            sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
            sb1.Append("<body><table border=\'1\'>");
            sb1.Append("<tr>");
            sb1.Append("<td>ID</td>");
            sb1.Append("<td align='left'>订单号</td>");
            sb1.Append("<td>支付方式</td>");
            sb1.Append("<td>单价</td>");
            sb1.Append("<td>运费</td>");
            sb1.Append("<td>总金额</td>");
            sb1.Append("<td>支付款</td>");
            sb1.Append("<td>余额付款</td>");
            sb1.Append("<td>支付状态</td>");
            sb1.Append("<td>支付日期</td>");
            sb1.Append("<td>备注</td>");
            sb1.Append("<td>快递信息</td>");
            sb1.Append("<td>用户名</td>");
            sb1.Append("<td>用户邮箱</td>");
            sb1.Append("<td>用户手机</td>");
            sb1.Append("<td>收件人</td>");
            sb1.Append("<td>邮政编码</td>");
            sb1.Append("<td>送货地址</td>");
            sb1.Append("<td>支付号</td>");
            sb1.Append("</tr>");
            //AS.Common.Utils.Helper.ConvertDataTable
            //AS.Common.Utils.Helper.ToDataTable
            dt = AS.Common.Utils.Helper.ConvertDataTable(halis);
            if (dt != null && dt.Rows.Count > 0)
            {
                int num = 0;
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    if (num != Convert.ToInt32(dt.Rows[i]["Id"].ToString()))
                    {
                        num = Convert.ToInt32(dt.Rows[i]["Id"].ToString());
                        sb1.Append("<tr>");
                        sb1.Append("<td>");
                        sb1.Append(dt.Rows[i]["Id"]);
                        sb1.Append("</td>");

                        //是否属于购物车
                        if (Convert.ToInt32(dt.Rows[i]["Team_id"].ToString()) == 0)
                        {
                            result = true;
                            OrderDetailFilter orderft = new OrderDetailFilter();
                            IList<IOrderDetail> orderlis = null;
                            orderft.Order_ID = AS.Common.Utils.Helper.GetInt(dt.Rows[i]["Id"], 0);
                            orderft.Teamid = AS.Common.Utils.Helper.GetInt(teamid, 0); //3959;
                            orderft.AddSortOrder(OrderDetailFilter.Order_ID_DESC);
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                orderlis = session.OrderDetail.GetList(orderft);
                            }
                            //属于购物车就查找购物车表并查找用户表

                            GteamID = new int[orderlis.Count];
                            GteamName = new string[orderlis.Count];
                            Product = new string[orderlis.Count];
                            GNum = new int[orderlis.Count];
                            GResult = new string[orderlis.Count];
                            if (orderlis != null && orderlis.Count > 0)
                            {
                                for (int j = 0; j < orderlis.Count; j++)
                                {
                                    IOrderDetail order1 = orderlis[j];
                                    //把项目ID，添加到数组中
                                    int s = order1.Teamid;

                                    GteamID[j] = order1.Teamid;
                                    //把项目名称，添加到数组中
                                    GteamName[j] = order1.Team.Title;
                                    //把项目的商品名称，添加到数组中
                                    Product[j] = order1.Product;
                                    //把订单的数量，添加到数组中
                                    GNum[j] = order1.Num;
                                    //把规格添加到数组中
                                    GResult[j] = order1.result;
                                }
                            }
                        }
                        else
                        {
                            result = false;
                            //不属于购物车
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                teamodel = session.Teams.GetByID(AS.Common.Utils.Helper.GetInt(dt.Rows[i]["Team_id"], 0));
                            }
                            if (teamodel != null)
                            {
                                //添加项目ID
                                teamID = teamodel.Id;
                                //项目名称
                                teamName = teamodel.Title;
                            }
                        }
                        //订单号
                        sb1.Append("<td>");
                        if (result)
                        {
                            for (int j = 0; j < GteamID.Length; j++)
                            {
                                sb1.Append(Product[j]);

                                if (GteamName[j] != null && GteamName[j].ToString() != "")
                                {
                                    sb1.Append(GteamName[j].ToString());
                                }
                                if (GResult[j] != null && GResult[j].ToString() != "")
                                {
                                    sb1.Append(GResult[j].ToString());
                                }
                                else
                                {
                                    sb1.Append("[" + GNum[j].ToString() + "件] ");
                                }
                            }

                        }
                        else
                        {
                            if (teamodel != null)
                            {
                                sb1.Append(teamodel.Product);
                                if (dt.Rows[i]["result"] != null && dt.Rows[i]["result"].ToString() != "")
                                {
                                    sb1.Append(dt.Rows[i]["result"].ToString());
                                }
                                else
                                {
                                    sb1.Append("[" + dt.Rows[i]["Quantity"].ToString() + "件]");
                                }
                            }

                        }
                        sb1.Append("</td>");
                        //支付方式
                        sb1.Append("<td>");
                        switch (dt.Rows[i]["Service"].ToString())
                        {
                            case "yeepay":
                                sb1.Append("易宝");
                                break;
                            case "alipay":
                                sb1.Append("支付宝");
                                break;
                            case "tenpay":
                                sb1.Append("财付通");
                                break;
                            case "chinamobilepay":
                                sb1.Append("移动支付");
                                break;
                            case "chinabank":
                                sb1.Append("网银在线");
                                break;
                            case "credit":
                                sb1.Append("余额付款");
                                break;
                            case "allinpay":
                                sb1.Append("通联支付");
                                break;
                            case "cash":
                                sb1.Append("线下支付");
                                break;
                            default:
                                sb1.Append("");
                                break;
                        }
                        sb1.Append("</td>");
                        //单价
                        sb1.Append("<td>" + dt.Rows[i]["Price"].ToString() + "</td>");
                        //运费
                        sb1.Append("<td>" + dt.Rows[i]["Fare"] + "</td>");
                        //总金额
                        sb1.Append("<td>" + dt.Rows[i]["Origin"] + "</td>");
                        //支付款
                        sb1.Append("<td>" + dt.Rows[i]["Money"] + "</td>");
                        //余额付款
                        sb1.Append("<td>" + dt.Rows[i]["Credit"] + "</td>");
                        //支付状态
                        sb1.Append("<td>" + dt.Rows[i]["State"] + "</td>");
                        //支付日期
                        sb1.Append("<td>" + dt.Rows[i]["Pay_time"] + "</td>");
                        //备注
                        if (dt.Rows[i]["Remark"].ToString() != "")
                        {
                            sb1.Append("<td>" + dt.Rows[i]["Remark"] + "</td>");
                        }
                        else
                        {
                            sb1.Append("<td>&nbsp;</td>");
                        }

                        //快递信息
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            categorymodel = session.Category.GetByID(AS.Common.Utils.Helper.GetInt(dt.Rows[i]["Express_id"], 0));
                        }

                        sb1.Append("<td>");
                        if (categorymodel != null)
                        {
                            sb1.Append(categorymodel.Name);
                        }
                        else
                        {
                            sb1.Append("&nbsp;");
                        }
                        sb1.Append("</td>");
                        //用户名
                        sb1.Append("<td>" + dt.Rows[i]["Username"].ToString() + "</td>");
                        //用户邮箱
                        sb1.Append("<td>" + dt.Rows[i]["Email"].ToString() + "</td>");
                        //用户手机
                        sb1.Append("<td>" + dt.Rows[i]["Mobile"].ToString() + "</td>");
                        //收件人
                        sb1.Append("<td>" + dt.Rows[i]["Realname"] + "</td>");
                        //邮政编码
                        sb1.Append("<td>" + dt.Rows[i]["Zipcode"].ToString() + "</td>");
                        //送货地址
                        sb1.Append("<td>" + dt.Rows[i]["Address"].ToString() + "</td>");
                        //支付号
                        sb1.Append("<td>" + dt.Rows[i]["Pay_id"].ToString() + "</td>");
                        sb1.Append("</tr>");
                    }

                }
            }
            else
            {                
                return "没有数据505";
            }
            sb1.Append("</table></body></html>");
            return sb1.ToString();
        }

        #endregion

        #region  获取手机端项目图片
        public static string GetWapImgUrl(string url)
        {
            string imgurl = String.Empty;

            if (url == null || url == String.Empty) return String.Empty;
            if (Helper.ValidateString(url, "url"))
            {
                imgurl = url;
            }
            else
            {
                imgurl = PageValue.CurrentSystem.domain + PageValue.WebRoot + url;
            }
            return imgurl;
        }
        #endregion
    }
}
