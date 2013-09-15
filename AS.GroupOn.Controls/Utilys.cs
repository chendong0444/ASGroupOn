using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.App;
using AS.Common.Utils;
using System.Collections;
using System.Data;
using System.IO;
using System.Data.SqlClient;

namespace AS.GroupOn.Controls
{
    public class Utilys
    {
        #region 查询用户的等级 用户表的totalamount 用户累计消费金额.
        public static string GetUserLevel(decimal totalamount)
        {
            string result = string.Empty;
            IUserlevelrules iuserleve = null;
            UserlevelrulesFilters userlevefilter = new UserlevelrulesFilters();
            userlevefilter.totalamount = totalamount;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iuserleve = session.Userlevelrelus.Get(userlevefilter);
            }
            if (iuserleve != null)
            {
                if (iuserleve.Category != null)
                {
                    result = iuserleve.Category.Name;
                }
            }
            IUserlevelrules iuserleve2 = null;
            UserlevelrulesFilters userlevefilter2 = new UserlevelrulesFilters();
            userlevefilter2.AddSortOrder(UserlevelrulesFilters.MAXMONEY_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iuserleve2 = session.Userlevelrelus.Get(userlevefilter2);
            }
            if (iuserleve2 != null)
            {
                if (totalamount > iuserleve2.maxmoney)
                {
                    if (iuserleve2 != null)
                    {
                        result = iuserleve2.Category.Name;
                    }
                }
            }
            return result;
        }
        #endregion
        #region 规格数量的变化 back 0,代表入库,1,代表出库,state 1代表后台，2代表前台
        public static bool Getrule(string newrule)
        {
            string result = string.Empty;
            bool falg = false;
            int sum = 0;
            if (newrule != null)
            {
                if (newrule.IndexOf('|') > 0)
                {
                    string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
                    //项目规格的原有的数量

                    for (int j = 0; j < newrulemo.Length; j++)
                    {
                        string txt3 = newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','));
                        if (result.Contains(newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','))))
                        {
                            falg = true;
                        }
                        result += "{" + newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(',')) + ",数量:[" + sum + "]}|";
                    }
                }
            }
            return falg;

        }
        #endregion

        #region 规格数量的变化 back 0,代表入库,1,代表出库,state 1代表后台，2代表前台
        public static string Getrule(string newrule, string oldrule, int back, int state)
        {
            string result = string.Empty;
            string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
            string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('|');
            int newnum = 0;
            int oldnum = 0;
            int sum = 0;
            string bottom = "";

            bool falg = false;

            //项目规格的原有的数量
            for (int j = 0; j < newrulemo.Length; j++)
            {
                //新规格的数量
                newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                string str = "";
                if (j < oldrulemo.Length)
                {
                    string txt1 = oldrulemo[j];
                    str = oldrulemo[j].Substring(0, oldrulemo[j].LastIndexOf(','));
                    oldnum = Convert.ToInt32(oldrulemo[j].Substring(oldrulemo[j].LastIndexOf(','), oldrulemo[j].Length - oldrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                }
                else
                {
                    oldnum = 0;
                }
                if (newrulemo[j].Contains(str))
                {
                    string txt = newrulemo[j];
                    txt = newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','));
                }
                string txt3 = newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','));
                sum = newnum + oldnum;
                if (sum < 0)
                {
                    sum = 0;
                }
                else
                {
                    result += "{" + newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(',')) + ",数量:[" + sum + "]}|";
                }
            }
            result = result.Remove(result.LastIndexOf('|'));
            return result;
        }
        #endregion

        #region 规格数量的变化 back 0,代表添加,1,代表修改,state 1代表后台，2代表前台
        public static int Getrulenum(string newrule, string oldrule, int back, int state)
        {
            string result = string.Empty;
            string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
            string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('|');
            int newnum = 0;
            int oldnum = 0;
            int sum = 0;


            //项目规格的原有的数量

            for (int j = 0; j < newrulemo.Length; j++)
            {

                newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                string str = "";
                if (j < oldrulemo.Length)
                {
                    string txt1 = oldrulemo[j];
                    str = oldrulemo[j].Substring(0, oldrulemo[j].LastIndexOf(','));
                    oldnum = Convert.ToInt32(oldrulemo[j].Substring(oldrulemo[j].LastIndexOf(','), oldrulemo[j].Length - oldrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                }
                else
                {
                    oldnum = 0;
                }
                if (newrulemo[j].Contains(str))
                {
                    string txt = newrulemo[j];
                    txt = newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','));
                }
                if (back == 0)
                {
                    if (newnum > 0)
                    {
                        sum += newnum;
                    }
                }
                else if (back == 1)
                {
                    if ((newnum + oldnum) > 0)
                    {
                        sum += (newnum + oldnum);
                    }
                }

            }

            return sum;
        }
        #endregion

        #region 判断项目是否是不同规格不同价格的项目
        public static bool GetTeamType(int teamid)
        {
            bool result = false;
            if (teamid > 0)
            {
                ITeam teammodel = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(teamid);
                }
                if (teammodel != null && teammodel.invent_result!=null)
                {
                    if (teammodel.invent_result != null && teammodel.invent_result != "")
                    {
                        string[] str = teammodel.invent_result.Replace("{", "").Replace("}", "").Split('|');
                        for (int i = 0; i < str.Length - 1; i++)
                        {
                            if (str[i].Contains("价格") && teammodel.bulletin != "")
                            {
                                if (str[i].Remove(str[i].LastIndexOf(',')).Substring(str[i].Remove(str[i].LastIndexOf(',')).IndexOf(',') + 1) != str[i + 1].Remove(str[i + 1].LastIndexOf(',')).Substring(str[i + 1].Remove(str[i + 1].LastIndexOf(',')).IndexOf(',') + 1))
                                {
                                    result = true;
                                    break;
                                }
                            }
                            else
                            {
                                result = false;
                            }
                        }
                    }
                }
                else
                {
                    result = false;
                }

            }
            return result;
        }
        #endregion

        #region 通过项目ID查询默认规格
        public static string GetProductByTeamId(int Team_id)
        {
            string result = "";
            string[] _result = null;
            if (Team_id > 0)
            {
                ITeam team = null;

                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    team = session.Teams.GetByID(Team_id);
                }
                if (team != null)
                {
                    if (team.invent_result.IndexOf('|') > 0)
                    {
                        _result = team.invent_result.Split('|');

                        result = _result[0];//取默认规格
                    }
                    else
                    {
                        result = team.invent_result;//仅有一种规格
                    }
                }
            }
            return result;
        }
        #endregion

        #region 通过某一规格查询价格
        public static decimal GetPriceByResult(string result)
        {
            decimal price = 0;
            result = result.Replace("{", "").Replace("}", "");
            if (result.Contains("价格"))
            {
                string[] str = result.Split(',');
                for (int i = 0; i < str.Length; i++)
                {
                    if (str[i].Contains("价格"))
                    {
                        price = Helper.GetDecimal(str[i].Split(':')[1].Replace("[", "").Replace("]", ""), 0);
                        break;
                    }
                }
            }
            else
            {
                price = 0;
            }
            return price;
        }
        #endregion

        #region 通过规格查询数量
        public static string GetNumByResult(string result)
        {
            string num = "0";
            result = result.Replace("{", "").Replace("}", "");
            if (result.Contains("数量"))
            {
                string[] str = result.Split(',');
                for (int i = 0; i < str.Length; i++)
                {
                    if (str[i].Contains("数量"))
                    {
                        num = str[i].Split(':')[1].Replace("[", "").Replace("]", "").ToString();
                        break;
                    }
                }
            }
            else
            {
                num = "0";
            }

            return num;
        }
        #endregion

        #region 显示颜色或者尺寸  back参数：判断显示在前台，和后台 0：前台，1：后台
        public static string Getfont(int num, int teamid, int count, string oldresult)
        {
            string str = "";
            string bulletin = "";

            ITeam teammodel = Store.CreateTeam();
            string sum = "0";
            using (IDataSession seion = Store.OpenSession(false))
            {
                teammodel = seion.Teams.GetByID(teamid);
            }
            if (teammodel != null)
            {
                bulletin = teammodel.bulletin;
                if (Getbulletin(bulletin) != "")
                {
                    #region
                    string[] bulletinteam = bulletin.Replace("{", "").Replace("}", "").Split(',');
                    if (teammodel.invent_result!=null)
                    {
                        string[] bullteam = teammodel.invent_result.Replace("{", "").Replace("}", "").Split('|');
                    }
                    string[] oldteam = oldresult.Replace("{", "").Replace("}", "").Split('|');
                    #region

                    int rows = 0; //规格行数初始数量
                    if (oldresult == "")
                    {
                        str += "<table id='tb" + num + "'>";
                        str += "<tr>";
                        str += " <td colspan='7' bgcolor='#E4E4E4' class='deal-buy-desc' id='rule" + num + "'>";

                        for (int i = 0; i < bulletinteam.Length; i++)
                        {
                            if (bulletinteam[i].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                            {
                                str += "<b>" + bulletinteam[i].Split(':')[0] + ":</b>";
                                string[] bull = bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                                str += "<select name='rule" + num + "' rows='" + rows + "' onchange='checkintory(this)'>";
                                for (int j = 0; j < bull.Length; j++)
                                {
                                    str += "<option value='" + bulletinteam[i].Split(':')[0] + ":" + bull[j] + "'>" + bull[j] + "</option>";
                                }
                                str += "</select>";
                            }
                        }
                        str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;数量：<input id='textfield' num_tid='" + teamid + "' rows='" + rows + "' name='num" + num + "' type='text'   value='" + count + "' size='5' require='true' datatype='number' group='a' />&nbsp;&nbsp;&nbsp;&nbsp;";
                        str += "<input type='button' name='button' id='button' rows='" + rows + "' value='其他规格' onclick=\"additem(this,'tb" + num + "','rule" + num + "','" + count + "',document.getElementById('textfield').value," + teamid + ")\" />";
                        str += "<input type='button' value='删除' onclick=\"deleteitem(this,'tb" + num + "'," + teamid + ",'" + count + "')\"/>";
                        str += "</td>";
                        str += "</tr>";
                        str += "</table><script>var rows=" + rows + ";</script>";
                    }
                    else
                    {
                        #region

                        str += "<table id='tb" + num + "'>";
                        for (int i = 0; i < oldteam.Length; i++)
                        {
                            rows = rows + 1;
                            str += "<tr>";
                            str += " <td colspan='7' bgcolor='#E4E4E4' class='deal-buy-desc' id='rule" + num + "'>";
                            sum = oldteam[i].Substring(oldteam[i].LastIndexOf(','), oldteam[i].Length - oldteam[i].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", "");
                            #region
                            for (int k = 0; k < bulletinteam.Length; k++)
                            {
                                if (bulletinteam[k].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                                {
                                    str += "<b>" + bulletinteam[k].Split(':')[0] + ":</b>";
                                    string[] bull = bulletinteam[k].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                                    str += "<select name='rule" + num + "' onchange='checkintory(this)' rows='" + rows + "'>";
                                    for (int h = 0; h < bull.Length; h++)
                                    {
                                        string txt6 = oldteam[i];
                                        if (oldteam[i].Contains(bull[h]))
                                        {
                                            str += "<option value='" + bulletinteam[k].Split(':')[0] + ":" + bull[h] + "' selected='selected'>" + bull[h] + "</option>";
                                        }
                                        else
                                        {

                                            str += "<option value='" + bulletinteam[k].Split(':')[0] + ":" + bull[h] + "'>" + bull[h] + "</option>";
                                        }
                                    }
                                    str += "</select>";
                                }
                            }
                            #endregion
                            str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;数量:<input id='textfield' num_tid='" + teamid + "' name='num" + num + "' rows='" + rows + "' type='text'  size='5'  value='" + sum + "'  require='true' datatype='number' group='a'/>&nbsp;&nbsp;&nbsp;&nbsp;";
                            str += "<input type='button' name='button' id='button' value='其他规格' rows='" + rows + "' onclick=\"additem(this,'tb" + num + "','rule" + num + "','" + sum + "',document.getElementById('textfield').value," + teamid + ")\" /> ";
                            str += "<input type='button' value='删除' onclick=\"deleteitem(this,'tb" + num + "'," + teamid + ",'" + sum + "')\"/>";
                            str += "</td>";
                            str += "</tr><script>var rows=" + rows + "</script>";
                        }
                        #endregion
                    }

                }
                    #endregion



                    #endregion

            }

            return str;
        }
        #endregion

        #region 显示并得到用户选择的项目规格
        public static string Getfont1(int teamid, string oldresult)
        {
            string str = "";
            string bulletin = "";
            string initfont = "";

            ITeam iteam = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iteam = session.Teams.GetByID(teamid);
            }
            if (iteam != null)
            {
                bulletin = iteam.bulletin;
            }
            if (Utility.Getbulletin(bulletin) != "")
            {
                #region
                string[] bulletinteam = bulletin.Replace("{", "").Replace("}", "").Split(',');

                #region
                if (Utility.Getbulletin(iteam.bulletin) != "")
                {

                    if (oldresult != "")
                    {

                        string strResult = "";

                        for (int k = 0; k < bulletinteam.Length; k++)
                        {
                            strResult = strResult + "," + bulletinteam[k].Split(':')[0];
                            if (bulletinteam[k] != "")
                            {
                                str += "<div class=\"guige\">";
                                str += "<font id=\"font_attr_name" + k + "\">" + bulletinteam[k].Split(':')[0] + "：</font><span id=\"s_attr_name" + k + "\" class=\"STYLE317\"></span><br/>";
                                str += "<input type=\"hidden\" name='attr_value' id=\"attr_value_" + k + "\" />";
                                str += "<input type=\"hidden\" id=\"redspan" + k + "\" />";

                                if (bulletinteam[k].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                                {
                                    string[] bull = bulletinteam[k].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                                    // initfont += bull[0].ToString();
                                    initfont = initfont + "," + bulletinteam[k].Split(':')[0] + ":[" + bull[0].ToString() + "]";
                                    str += "<ul class=\"ml_color\">";
                                    for (int h = 0; h < bull.Length; h++)
                                    {
                                        str += "<li id=\"ligreyspan" + h + "\">";
                                        if (h == 0)
                                        {
                                            str += "<a style=\"cursor: pointer;\" class=\"lbrd_bycur\" id=\"greyspan" + h + "_" + k + "\" name=\"greyspan" + k + "\" class=\"\"   onclick=\"setattrvalue1(" + k + ",'" + bulletinteam[k].Split(':')[0] + "'," + h + ",'" + bull[h] + "')\">" + "<font class=\"font24\" >" + bull[h] + "</font>" + "</a>";
                                        }
                                        else
                                        {
                                            str += "<a style=\"cursor: pointer;\"  id=\"greyspan" + h + "_" + k + "\" name=\"greyspan" + k + "\" class=\"\"   onclick=\"setattrvalue1(" + k + ",'" + bulletinteam[k].Split(':')[0] + "'," + h + ",'" + bull[h] + "')\">" + "<font class=\"font24\" >" + bull[h] + "</font>" + "</a>";
                                        }
                                        str += "</li>";

                                    }
                                    str += "</ul>";
                                }
                                str += "</div>";
                            }


                        }
                        str += "<input type=\"hidden\"  value=\"" + initfont + "\" id=\"hidattrname\" />";
                        str += "<input type=\"hidden\" id=\"hidattrvale\" value='" + strResult.Substring(1) + "' />";
                    }

                }
                #endregion



                #endregion

            }


            return str;
        }
        #endregion

        #region 显示颜色或者尺寸  back参数：判断显示在前台，和后台 0：前台，1：后台  ------------产品用
        public static string GetTestProduct(int num, IOrder model, int productid, int back)
        {
            string str = "";
            string bulletin = "";
            IOrder ordermodel = null;
            OrderFilter orderft = new OrderFilter();
            IProduct promodel = null;
            ProductFilter productft = new ProductFilter();
            BasePage bp = new BasePage();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                promodel = session.Product.GetByID(productid);
            }
            bulletin = promodel.bulletin;
            // team_price = teamdal.GetModel(teamid).Team_price;

            IOrderDetail detailmodel = null;

            OrderDetailFilter detailft = new OrderDetailFilter();
            if (Getbulletin(bulletin) != "")
            {
                #region
                string[] bulletinteam = bulletin.Replace("{", "").Replace("}", "").Split(',');

                #region
                if (promodel.invent_result == null || promodel.invent_result == "")
                {
                    str += "<table id='tb" + num + "' style=\"margin-left:10px;\">";
                    str += "<tr>";
                    str += " <td colspan='7' bgcolor='#E4E4E4' class='deal-buy-desc' id='rule" + num + "'>";
                    for (int i = 0; i < bulletinteam.Length - 1; i++)
                    {
                        if (bulletinteam[i].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                        {
                            str += "<b>" + bulletinteam[i].Split(':')[0] + ":</b>";
                            string[] bull = bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                            str += "<select name='rule" + num + "'>";
                            for (int j = 0; j < bull.Length; j++)
                            {
                                str += "<option value='" + bulletinteam[i].Split(':')[0] + ":" + bull[j] + "'>" + bull[j] + "</option>";
                            }
                            str += "</select>";
                        }
                    }
                    str += "<b>价格：</b><input type=\"text\" value='" + bp.GetMoney(promodel.team_price) + "' size='5' onkeyup=\"checkIsNum(this," + promodel.team_price + ")\" name=\"bmoney" + num + "\"/>&nbsp;&nbsp;";
                    str += "总库存:" + promodel.inventory;
                    str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;增加库存<input id='textfield' num_tid='" + productid + "' name='insertnum" + num + "' type='text'   value='0' size='5' onkeyup=\"clearNoNum(this)\" />&nbsp;";
                    str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;减少库存<input id='textfield' num_tid='" + productid + "' name='deletenum" + num + "' type='text'   value='0' size='5' onkeyup=\"clearNoNum(this)\" />&nbsp;&nbsp;&nbsp;&nbsp;";
                    str += "<input type='button' name='button' id='button' value='其他规格' onclick=\"additem('tb" + num + "','rule" + num + "','" + promodel.inventory + "',document.getElementById('textfield').value," + productid + ")\" />";
                    str += "<input type='button' value='删除' onclick=\"deleteitem(this,'tb" + num + "'," + productid + ",'" + promodel.inventory + "')\"/>";
                    str += "</td>";
                    str += "</tr>";
                    str += "</table>";

                }
                #endregion

                #region
                else
                {
                    string[] bullteam = promodel.invent_result.Replace("{", "").Replace("}", "").Split('|');
                    str += "<table id='tb" + num + "' style=\"margin-left:10px;\">";
                    string sum = "";//选择的数量
                    string money = "";//选择的价格
                    for (int i = 0; i < bullteam.Length; i++)
                    {

                        string txt3 = bullteam[i];
                        str += "<tr>";
                        str += " <td colspan='7' bgcolor='#E4E4E4' class='deal-buy-desc' id='rule" + num + "'>";
                        sum = bullteam[i].Substring(bullteam[i].LastIndexOf(','), bullteam[i].Length - bullteam[i].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", "");
                        if (bullteam[i].ToString().Contains("价格"))
                        {
                            money = bullteam[i].Substring(0, bullteam[i].LastIndexOf(','));
                            money = money.Substring(money.LastIndexOf(','), money.Length - money.LastIndexOf(',')).Replace(",", "").Replace("价格", "").Replace(":", "").Replace("[", "").Replace("]", "");
                        }
                        else
                        {
                            money = promodel.team_price.ToString();
                        }
                        #region
                        for (int k = 0; k < bulletinteam.Length - 1; k++)
                        {
                            str += "<b>" + bulletinteam[k].Split(':')[0] + ":</b>";
                            if (bulletinteam[k].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                            {
                                string[] bull = bulletinteam[k].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                                str += "<select name='rule" + num + "'>";
                                for (int h = 0; h < bull.Length; h++)
                                {
                                    string txt6 = bullteam[i];
                                    if (bullteam[i].Contains("[" + bull[h] + "]"))
                                    {
                                        str += "<option value='" + bulletinteam[k].Split(':')[0] + ":" + bull[h] + "' selected='selected'>" + bull[h] + "</option>";
                                    }
                                    else
                                    {
                                        if (back == 1)
                                        {
                                            str += "<option value='" + bulletinteam[k].Split(':')[0] + ":" + bull[h] + "'>" + bull[h] + "</option>";
                                        }
                                    }
                                }
                                str += "</select>";
                            }
                        }
                        #endregion

                        if (back == 1)
                        {
                            str += "<b>价格：</b><input type=\"text\" value='" + bp.GetMoney(money) + "' onkeyup=\"checkIsNum(this," + bp.GetMoney(money) + ")\" size='5' name=\"bmoney" + num + "\"/>&nbsp;&nbsp;";
                            str += "总库存:" + sum;
                            str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;增加库存<input id='textfield' num_tid='" + productid + "' name='insertnum" + num + "' type='text'   value='0' size='5' onkeyup=\"clearNoNum(this)\" />&nbsp;";
                            str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;减少库存<input id='textfield' num_tid='" + productid + "' name='deletenum" + num + "' type='text'   value='0' size='5' onkeyup=\"clearNoNum(this)\" />&nbsp;&nbsp;&nbsp;&nbsp;";
                            str += "<input type='button' name='button' id='button' value='其他规格' onclick=\"additem('tb" + num + "','rule" + num + "','" + sum + "',document.getElementById('textfield').value," + model.Team_id + ")\" /> ";
                            str += "<input type='button' value='删除' onclick=\"deleteitem(this,'tb" + num + "'," + productid + ",'" + sum + "')\"/>";
                        }
                        else
                        {
                            str += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;数量<input id='textfield'  num_tid='" + model.Team_id + "' name='num" + num + "' type='text'  size='5' value=''   onkeyup=\"clearNoNum(this)\"/>&nbsp;&nbsp;&nbsp;&nbsp;";
                        }
                        str += "</td>";
                        str += "</tr>";
                    }
                    str += "</table>";
                }
                #endregion

                #endregion

            }


            return str;
        }
        #endregion

        #region 显示项目规格信息
        /// <summary>
        /// 显示项目规格信息[购物车]
        /// </summary>
        /// <param name="teamid">项目id</param>
        /// <param name="oldresult">规格</param>
        /// <returns></returns>
        public static string Getfont2(int teamid, string oldresult)
        {
            string str = "";
            string bulletin = "";

            ITeam iteam = Store.CreateTeam();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iteam = session.Teams.GetByID(teamid);
            }
            if (iteam != null)
            {
                bulletin = iteam.bulletin;
            }
            string initfont = "";

            if (Getbulletin(bulletin) != "")
            {
                #region
                string[] bulletinteam = bulletin.Replace("{", "").Replace("}", "").Split(',');

                #region
                if (Getbulletin(bulletin) != "")
                {

                    if (oldresult != "")
                    {
                        str += "<table >";
                        str += "<tbody>";

                        string strResult = "";

                        for (int k = 0; k < bulletinteam.Length; k++)
                        {
                            strResult = strResult + "," + bulletinteam[k].Split(':')[0];
                            if (bulletinteam[k] != "")
                            {
                                str += "<tr>";
                                str += "<td id=\"td_attrcontent\" class=\"td8\"><font id=\"font_attr_name" + k + "\">" + bulletinteam[k].Split(':')[0] + "</font>：<span id=\"s_attr_name" + k + "\" class=\"STYLE317\"></span>";
                                str += "<input type=\"hidden\" name='attr_value' id=\"attr_value_" + k + "\" />";
                                str += "<input type=\"hidden\" id=\"redspan" + k + "\" /></td>";
                                str += "</tr>";



                                if (bulletinteam[k].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                                {
                                    string[] bull = bulletinteam[k].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                                    initfont = initfont + "," + bulletinteam[k].Split(':')[0] + ":[" + bull[0].ToString() + "]";
                                    //str += "<tr>";
                                    //str += "<td><ul class=\"acc2\">";
                                    str += "<td><ul class=\"acc2\">";
                                    for (int h = 0; h < bull.Length; h++)
                                    {

                                        str += "<li id=\"ligreyspan" + h + "\">";
                                        if (h == 0)
                                        {
                                            str += "<table style=\"cursor: pointer;\" id=\"greyspan" + h + "_" + k + "\" class=\"ulliahover\"  name='greyspan" + k + "' onclick=\"setattrvalue(" + k + ",'" + bulletinteam[k].Split(':')[0] + "'," + h + ",'" + bull[h] + "')\">";
                                        }
                                        else
                                        {
                                            str += "<table style=\"cursor: pointer;\" id=\"greyspan" + h + "_" + k + "\" class=\"td28\"  name='greyspan" + k + "' onclick=\"setattrvalue(" + k + ",'" + bulletinteam[k].Split(':')[0] + "'," + h + ",'" + bull[h] + "')\">";
                                        }
                                        str += "<tbody>";
                                        str += " <tr>";
                                        str += "<td><table>";
                                        str += "<tbody>";
                                        str += "<tr>";
                                        str += "<td class=\"tdC\"><font class=\"font24\">" + bull[h] + "</font></td>";
                                        str += "</tr>";
                                        str += "</tbody>";
                                        str += "</table></td>";
                                        str += "</tr>";
                                        str += "</tbody>";
                                        str += "</table>";
                                        str += "</li>";

                                    }
                                    str += "</ul>";

                                    str += "</td>";
                                    //str += "</tr>";

                                }
                            }


                        }



                        str += "</tbody>";
                        str += "</table>";

                        if (initfont.Substring(0, 1) == ",")
                        {
                            initfont = initfont.Substring(1);
                        }
                        str += "<input type=\"hidden\"  value=\"" + initfont + "\" id=\"hidattrname\" />";
                        str += "<input type=\"hidden\" id=\"hidattrvale\" value='" + strResult.Substring(1) + "' />";
                    }

                }
                #endregion



                #endregion

            }


            return str;
        }
        #endregion

        #region 项目替换
        public static string Getbulletin(string bulletin)
        {
            string str = bulletin.Replace("{", "").Replace(":", "").Replace("[", "").Replace("]", "").Replace("}", "");
            return str;
        }
        #endregion

        public static void BackUpAll()
        {
            string logname = DateTime.Now.ToString("yyyyMMddHHmmss");
            try
            {
                string folter = AppDomain.CurrentDomain.BaseDirectory + "backup/";
                if (!Directory.Exists(folter)) Directory.CreateDirectory(folter);
                string file = folter + "all_" + DateTime.Now.ToString("yyyy-MM-dd-HH-mm-ss-") + AS.Common.Utils.Version.SiteVersion + ".sql";
                List<Hashtable> resultHash = new List<Hashtable>();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    resultHash = session.Custom.Query("select * from sysobjects where xtype='U'");
                }
                for (int i = 0; i < resultHash.Count; i++)
                {
                    Hashtable column = resultHash[i];
                    BackUpSingleTable(column["name"].ToString(), file, logname);
                }
            }
            catch (Exception ex)
            {
                AS.Common.Utils.WebUtils.LogWrite(logname, ex.Message);
            }
        }

        /// <summary>
        /// 备份单个表
        /// </summary>
        /// <param name="tablename">表名</param>
        /// <param name="file">字段</param>
        /// <param name="logname">日志文件名</param>
        public static void BackUpSingleTable(string tablename, string file, string logname)
        {
            try
            {

                List<Hashtable> resultHash = new List<Hashtable>();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    resultHash = session.Custom.Query("select * from sysobjects where name='" + tablename + "' and type='U'");
                }
                if (resultHash != null && resultHash.Count > 0)
                {
                    string sql = String.Empty;
                    bool auto_insert = false;
                    if (resultHash.Count == 1)
                    {

                        Hashtable t = resultHash[0];
                        sql = sql + ";\r\nif(EXISTS(select * from sysobjects where  xtype='U' and name='" + t["name"] + "'))drop table [" + t["name"] + "]";
                        sql = sql + ";\r\ncreate table [" + t["name"] + "] \r\n (\r\n";


                        List<Hashtable> columnHash = new List<Hashtable>();
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            columnHash = session.Custom.Query("select t3.*,t2.indid from(select t1.*,syscomments.text as syscomments_text from (select syscolumns.colid as syscolumns_colid, syscolumns.name as syscolumns_name,syscolumns.id as syscolumns_id,syscolumns.xtype as syscolumns_xtype,syscolumns.length as syscolumns_length,syscolumns.status as syscolumns_status,syscolumns.prec as syscolumns_prec,syscolumns.scale as syscolumns_scale, syscolumns.colstat as syscolumns_colstat,syscolumns.cdefault as syscolumns_cdefault,syscolumns.isnullable as syscolumns_isnullable,systypes.name as systypes_name from syscolumns  inner join systypes on(syscolumns.xtype=systypes.xtype) where syscolumns.id=" + t["id"] + ") t1 left join syscomments on(t1.syscolumns_cdefault=syscomments.id))t3 left join (select sysindexes.id,sysindexes.indid,colid from sysindexes inner join sysindexkeys on(sysindexes.id=sysindexkeys.id) where sysindexes.id=" + t["id"] + " and sysindexes.indid=1)t2 on(t3.syscolumns_colid=t2.colid)where systypes_name<>'sysname' order by syscolumns_colid asc");
                        }

                        for (int i = 0; i < columnHash.Count; i++)
                        {
                            Hashtable column = columnHash[i];
                            sql = sql + "[" + column["syscolumns_name"] + "] " + column["systypes_name"];
                            string name = column["systypes_name"].ToString();
                            if (name == "numeric" || name == "decimal" && column["syscolumns_prec"] != null && column["syscolumns_scale"] != null)
                            {
                                sql = sql + "(" + column["syscolumns_prec"] + "," + column["syscolumns_scale"] + ")";
                            }
                            else if (name == "char" || name == "nchar" || name == "nvarchar" || name == "varchar" && column["syscolumns_prec"] != null)
                            {
                                sql = sql + "(" + column["syscolumns_prec"] + ")";
                            }
                            if (Convert.ToInt32(column["syscolumns_colstat"]) > 0 && column["syscolumns_colstat"] != null)
                            {
                                sql = sql + " identity(1,1)";
                                auto_insert = true;
                            }
                            if (Convert.ToInt32(column["syscolumns_isnullable"]) == 0 && column["syscolumns_isnullable"] != null)
                            {
                                sql = sql + " not null";
                            }
                            else
                            {
                                sql = sql + " null";
                            }
                            if (Convert.ToInt32(column["indid"]) == 1 && i == 0 && column["indid"] != null)
                            {
                                sql = sql + " primary key";
                            }
                            if (Convert.ToInt32(column["syscolumns_cdefault"]) > 0 && column["syscolumns_cdefault"] != null && column["syscomments_text"] != null)
                            {
                                sql = sql + " default " + column["syscomments_text"];
                            }
                            sql = sql + ",\r\n";

                        }
                        sql = sql + ") ;\r\n";

                        if (auto_insert)
                        {
                            sql = sql + ";\r\nSET IDENTITY_INSERT  [" + t["name"] + "] ON";
                        }
                        BackUp(sql, file); //写入文件
                        sql = String.Empty;//清空sql


                        List<Hashtable> dataHash = new List<Hashtable>();
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            dataHash = session.Custom.Query("select * from [" + t["name"] + "]");
                        }
                        if (dataHash != null)
                        {
                            for (int j = 0; j < dataHash.Count; j++)
                            {
                                string insertsqlvalue = String.Empty;
                                string insertsql = String.Empty;
                                Hashtable d = dataHash[j];
                                for (int i = 0; i < columnHash.Count; i++)
                                {
                                    Hashtable column = columnHash[i];
                                    insertsql = insertsql + ",[" + column["syscolumns_name"] + "]";
                                    if (d[column["syscolumns_name"].ToString()] != null)
                                    {
                                        string value = d[column["syscolumns_name"].ToString()].ToString();
                                        if (d[column["syscolumns_name"].ToString()] is DBNull)
                                            insertsqlvalue = insertsqlvalue + ",null";
                                        else if (value == String.Empty)
                                            insertsqlvalue = insertsqlvalue + ",''";
                                        else
                                            insertsqlvalue = insertsqlvalue + ",'" + value.Replace("'", "''").Replace(";\r\n", "; \r\n") + "'";
                                    }
                                    else
                                    {
                                        insertsqlvalue = insertsqlvalue + ",null";
                                    }
                                }
                                if (insertsql.Length > 0)
                                {
                                    insertsql = ";\r\ninsert into [" + t["name"] + "](" + insertsql.Substring(1) + ")values(" + insertsqlvalue.Substring(1) + ")";
                                }
                                sql = sql + insertsql + ";\r\n";
                                BackUp(sql, file); //写入文件
                                sql = String.Empty;//清空sql
                            }
                        }


                        if (auto_insert)
                        {
                            sql = sql + ";\r\nSET IDENTITY_INSERT  [" + t["name"] + "] OFF";
                        }
                        BackUp(sql, file);//写入文件
                    }
                }


            }
            catch (Exception ex) { AS.Common.Utils.WebUtils.LogWrite(logname, ex.Message); }
        }
        public static void BackUp(string sql, string file)
        {
            File.AppendAllText(file, sql, System.Text.Encoding.UTF8);
        }
        public static void BackUpSingle(object tablename)
        {
            string logname = DateTime.Now.ToString("yyyyMMddHHmmss");
            string folter = AppDomain.CurrentDomain.BaseDirectory + "backup/";
            if (!Directory.Exists(folter)) Directory.CreateDirectory(folter);
            string file = folter + tablename + "_" + DateTime.Now.ToString("yyyy-MM-dd-HH-mm-ss") + "-" + AS.Common.Utils.Version.SiteVersion + ".sql";
            BackUpSingleTable(tablename.ToString(), file, logname);
        }

        public static void Restore(object path)
        {
            string logname = DateTime.Now.ToString("yyyyMMddHHmmss");
            try
            {
                string connectionStr = PageValue.GetConnectString();//System.Configuration.ConfigurationManager.AppSettings["ConnectionString"]
                using (SqlConnection conn = new SqlConnection(connectionStr))
                {
                    string filename = path.ToString();
                    FileStream reader = File.OpenRead(filename);
                    try
                    {
                        conn.Open();
                        string sql = String.Empty;
                        string[] sqls = null;
                        long totalcount = reader.Length;
                        int curpos = 0;
                        while (totalcount > 0)
                        {
                            if (totalcount > 512000)
                            {
                                byte[] buffer = new byte[512000];
                                curpos = curpos + reader.Read(buffer, 0, buffer.Length);
                                sql = sql + System.Text.Encoding.UTF8.GetString(buffer);
                                string[] split = new string[] { ";\r\n" };
                                sqls = sql.Split(split, StringSplitOptions.RemoveEmptyEntries);
                                if (sqls.Length > 1)
                                {
                                    for (int i = 0; i < sqls.Length - 1; i++)
                                    {
                                        try
                                        {
                                            SqlCommand cmd = new SqlCommand(sqls[i], conn);
                                            cmd.ExecuteNonQuery();
                                        }
                                        catch (Exception ex)
                                        {
                                            AS.Common.Utils.WebUtils.LogWrite(logname, ex.Message);
                                        }
                                    }
                                }
                                if (sqls.Length >= 1)
                                    sql = sqls[sqls.Length - 1];
                                totalcount = totalcount - buffer.Length;
                            }
                            else
                            {
                                byte[] buffer = new byte[totalcount];
                                curpos = curpos + reader.Read(buffer, 0, (int)totalcount);
                                sql = sql + System.Text.Encoding.UTF8.GetString(buffer);
                                string[] split = new string[] { ";\r\n" };
                                sqls = sql.Split(split, StringSplitOptions.RemoveEmptyEntries);
                                if (sqls.Length > 1)
                                {
                                    for (int i = 0; i < sqls.Length - 1; i++)
                                    {
                                        try
                                        {
                                            SqlCommand cmd = new SqlCommand(sqls[i], conn);
                                            cmd.ExecuteNonQuery();
                                        }
                                        catch (Exception ex)
                                        {
                                            AS.Common.Utils.WebUtils.LogWrite(logname, ex.Message);
                                        }
                                    }
                                }
                                if (sqls.Length >= 1)
                                    sql = sqls[sqls.Length - 1];
                                totalcount = 0;
                            }
                        }

                        if (sql != String.Empty)
                        {
                            try
                            {
                                SqlCommand cmd = new SqlCommand(sql, conn);
                                cmd.ExecuteNonQuery();
                            }
                            catch (Exception ex)
                            {
                                AS.Common.Utils.WebUtils.LogWrite(logname, ex.Message);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        AS.Common.Utils.WebUtils.LogWrite(logname, ex.Message);
                    }
                    finally
                    {
                        reader.Close();
                        conn.Close();

                    }
                }
            }
            catch (Exception ex) { AS.Common.Utils.WebUtils.LogWrite(logname, ex.Message); }

        }

        public static bool Restore(string sql)
        {
            bool ok = true;
            if (sql == String.Empty)
                return true;

            string connectionStr = PageValue.GetConnectString();//System.Configuration.ConfigurationManager.AppSettings["ConnectionString"]
            using (SqlConnection conn = new SqlConnection(connectionStr))
            {
                string logname = DateTime.Now.ToString("yyyyMMddHHmmss");
                try
                {
                    conn.Open();
                    string[] split = new string[] { ";\r\n" };
                    string[] sqls = null;
                    sqls = sql.Split(split, StringSplitOptions.RemoveEmptyEntries);
                    if (sqls != null && sqls.Length > 0)
                    {

                        for (int i = 0; i < sqls.Length; i++)
                        {
                            if (sqls[i].Length > 5)
                            {
                                try
                                {
                                    SqlCommand cmd = new SqlCommand(sqls[i], conn);
                                    cmd.ExecuteNonQuery();
                                }
                                catch (Exception ex)
                                {
                                    ok = false;
                                    AS.Common.Utils.WebUtils.LogWrite(logname, ex.Message + sqls[i]);
                                }
                            }
                        }
                    }

                }
                catch (Exception ex)
                {
                    AS.Common.Utils.WebUtils.LogWrite(logname, ex.Message);
                    ok = false;
                }
                finally
                {
                    conn.Close();
                }
            }
            return ok;
        }
        #region 统计出入库的数量
        public static int Getnum(string newrule)
        {
            int newnum = 0;
            int sum = 0;
            if (AS.Common.Utils.Helper.GetString(newrule, "") != "")
            {
                string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
                for (int j = 0; j < newrulemo.Length; j++)
                {
                    newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                    sum += newnum;
                }
            }
            return sum;
        }
        #endregion

        #region 判断是否报警
        public static bool IsWar(ITeam model)
        {
            bool falg = false;
            if (model.inventory < model.invent_war)
            {
                falg = true;
            }
            return falg;
        }
        #endregion

    }
}
