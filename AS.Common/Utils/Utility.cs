using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Web;
using AS.GroupOn.Controls;

namespace AS.Common.Utils
{
    public class Utility
    {
        #region
        public static string GetCity()
        {
            string str = string.Empty;
            Utils.IPScanner objScan = new Utils.IPScanner();
            objScan.DataPath = HttpContext.Current.Server.MapPath("~/qqwry.dat"); ;
            objScan.IP = WebUtils.GetClientIP;
            str = objScan.IPLocation();
            return str;
        }
        #endregion

        #region 统计出入库的数量
        public static int Getnum(string newrule)
        {
            int newnum = 0;
            int sum = 0;
            if (Utils.Helper.GetString(newrule, "") != "")
            {
                string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Replace(".", ",").Replace("-", "|").Split('|');
                for (int j = 0; j < newrulemo.Length; j++)
                {
                    newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                    sum += newnum;
                }
            }
            return sum;
        }
        #endregion

        #region 冒泡写法
        public static decimal[] sort(decimal[] m)
        {
            int intLenth = m.Length;
            /*执行intLenth次*/
            for (int i = 0; i < intLenth; i++)
            {
                /*每执行一次，将最小的数排在后面*/
                for (int j = 0; j < intLenth - i - 1; j++)
                {
                    decimal a = m[j];
                    decimal b = m[j + 1];
                    if (a < b)
                    {
                        m[j] = b;
                        m[j + 1] = a;
                    }
                }
            }
            return m;

        }
        #endregion

        #region 获取随机数
        /// <summary>
        /// 获取随机数
        /// </summary>
        /// <param name="num">随机长度</param>
        /// <returns></returns>
        public static string GetRanNum(int num)
        {
            Guid g = Guid.NewGuid();
            Random rad = new Random();
            int begin = rad.Next(0, 20);
            string newnum = g.ToString().Replace("-", "").Substring(begin, num).ToUpper();
            return newnum;

        }
        #endregion

        #region 获取随机数
        /// <summary>
        /// 获取随机数
        /// </summary>
        public static string RndNum(int VcodeNum)
        {
            string Vchar = "0,1,2,3,4,5,6,7,8,9";
            string[] VcArray = Vchar.Split(new Char[] { ',' });
            string VNum = "";
            Random rand = new Random();
            for (int i = 1; i < VcodeNum + 1; i++)
            {
                int t = rand.Next(10);
                VNum += VcArray[t];
            }
            return VNum;
        }
        #endregion

        #region 项目替换
        public static string Getbulletin(string bulletin)
        {
            string str = bulletin.Replace("{", "").Replace(":", "").Replace("[", "").Replace("]", "").Replace("}", "");
            return str;
        }
        #endregion

        #region 获取样式
        public static string GetStyle(string style)
        {
            string url = HttpContext.Current.Request.Url.ToString();
            string str = "";
            if (url.ToLower().Contains(style.ToLower()))
            {
                str = "class='current'";
            }
            else
            {
                str = "";

            }
            return str;

        }
        #endregion

        #region 判断是否为空
        public static bool isEmpity(string str)
        {
            bool falg = false;
            string[] num = str.Split(',');
            for (int i = 0; i < num.Length; i++)
            {
                if (num[i] == "0")
                {
                    falg = true;
                }
            }
            return falg;
        }
        #endregion

        #region 选中规格后，根据规格得到该规格的价钱
        public static string Getrulemoney(string teamprice, string oldrule, string nowrule)
        {
            string money = teamprice;
            string rule = "";
            string _newRule;
            if (Helper.GetString(nowrule, "") != "" && Helper.GetString(oldrule, "") != "")
            {
                string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('|');
                string[] newrules = nowrule.Replace("{", "").Replace("}", "").Split('|');
                for (int i = 0; i < oldrulemo.Length; i++)
                {
                    for (int j = 0; j < newrules.Length; j++)
                    {
                        if (oldrulemo[i].ToString() !="" && newrules[j].ToString() !="")
                        {
                            if (newrules[j].Contains("数量"))
                            {
                               _newRule = newrules[j].Substring(0, newrules[j].LastIndexOf(','));
                            }
                            else
                            {
                                _newRule = newrules[j].ToString();
                            }

                            if (oldrulemo[i].Contains(_newRule))
                            {

                                rule = oldrulemo[i].ToString();

                                if (rule.Contains("价格"))//如果设置了不同规格不同价格
                                {
                                    rule = rule.Substring(0, rule.LastIndexOf(','));
                                    rule = rule.Substring(rule.LastIndexOf(','), rule.Length - rule.LastIndexOf(',')).Replace(",", "").Replace("价格", "").Replace(":", "").Replace("[", "").Replace("]", "");
                                    return money = rule.ToString();
                                }


                            }
                        }
                    }

                }

            }

            return money;
        }
        #endregion

        #region 判断是否超出库存
        public static bool isinvent(string newrule, string oldrule)
        {
            bool falg = false;
            int newnum = 0;
            int oldnum = 0;
            if (newrule != "" && oldrule != "")
            {
                string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
                //项目规格的原有的数量
                string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('|');

                for (int i = 0; i < oldrulemo.Length; i++)
                {
                    for (int j = 0; j < newrulemo.Length; j++)
                    {
                        if (oldrulemo[i].Contains(newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','))))
                        {
                            newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                            oldnum = Convert.ToInt32(oldrulemo[i].Substring(oldrulemo[i].LastIndexOf(','), oldrulemo[i].Length - oldrulemo[i].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                            if (newnum > oldnum)
                            {
                                falg = true;
                            }
                        }
                    }
                }
            }
            return falg;
        }
        #endregion

        #region 获取选中规格对应的库存
        public static int GetInventNum(string newrule, string oldrule)
        {
            int falg = 0;
            int newnum = 0;
            int oldnum = 0;
            if (newrule != "" && oldrule != "")
            {
                string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
                //项目规格的原有的数量
                string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('|');

                for (int i = 0; i < oldrulemo.Length; i++)
                {
                    for (int j = 0; j < newrulemo.Length; j++)
                    {
                        if (oldrulemo[i].Contains(newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','))))
                        {
                            newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                            oldnum = Convert.ToInt32(oldrulemo[i].Substring(oldrulemo[i].LastIndexOf(','), oldrulemo[i].Length - oldrulemo[i].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                            falg = oldnum;
                        }
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
            //for (int i = 0; i < oldrulemo.Length; i++)
            //{
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

                //if (result.Contains(newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','))))
                //{
                //    result = "{" + newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(',')) + ",数量:[" + sum + "]}|";
                //}
                //else
                //{
                result += "{" + newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(',')) + ",数量:[" + sum + "]}|";
                // }
            }
            // }
            //if (state == 2)
            //{
            //    if (newrulemo.Length > oldrulemo.Length)
            //    {
            //        bottom = newrule.Substring(oldrule.Length, newrule.Length - oldrule.Length);
            //        result = result.Remove(result.LastIndexOf('|')) + bottom;
            //    }
            //    else
            //    {
            //        result = result.Remove(result.LastIndexOf('|'));
            //    }

            //}
            //else if (state == 1)
            //{ 
            //    if (newrulemo.Length < oldrulemo.Length)
            //    {
            //        bottom = oldrule.Substring(newrule.Length, oldrule.Length - newrule.Length);
            //        result = result.Remove(result.LastIndexOf('|')) + bottom;
            //    }
            //    else
            //    {
            //        result = result.Remove(result.LastIndexOf('|'));
            //    }
            //}
            result = result.Remove(result.LastIndexOf('|'));
            return result;
        }
        #endregion
        #region 规格数量的变化 back 0,代表入库,1,代表出库,state 1代表后台，2代表前台
        public static bool GetNewOld(string newrule, string oldrule)
        {
            string result = string.Empty;
            bool falg = false;
            int sum = 0;

            if (Helper.GetString(newrule, "") != "" || Helper.GetString(oldrule, "") != "")
            {

                string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
                //项目规格的原有的数量
                string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('|');
                for (int i = 0; i < newrulemo.Length; i++)
                {
                    if (!oldrule.Contains(newrulemo[i].Substring(0, newrulemo[i].LastIndexOf(','))))
                    {
                        falg = true;
                    }
                }

            }
            return falg;
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

        #region 显示购物车规格
        /// <summary>
        /// 显示购物车规格
        /// </summary>
        /// <param name="oldresult">规格</param>
        /// <returns></returns>
        public static string GetCarfont(string oldresult)
        {
            string strResult = "";



            if (oldresult != "")
            {


                string newresult = oldresult.Replace("{", "").Replace("}", "");

                string[] newresults = newresult.Split('-');
                string _result = "";
                for (int i = 0; i < newresults.Length; i++)
                {
                    _result = _result + "[";
                    string str = "";
                    if (newresults[i] != "")
                    {
                        string _newresult = newresults[i];

                        string[] bulletinteam = _newresult.Split('.');


                        for (int j = 0; j < bulletinteam.Length; j++)
                        {
                            //商城的项目规格不可以为空
                            if (bulletinteam[j] != "")
                            {
                                str = str + "," + bulletinteam[j].Split(':')[1].Replace("[", "").Replace("]", "");
                            }
                        }


                    }

                    _result = _result + str.Substring(1) + "],";
                }
                strResult = _result.Substring(0, _result.LastIndexOf(','));
            
            }
            else
            {
                strResult = oldresult;
            }


            return strResult;
        }
        #endregion

        #region 查找购物车中是否存在相同的规格的商品 其中购物中规格newrule是以"."分割的
        public static bool IsSameResultCar(string newrule, string oldrule)
        {
            bool falg = false;

            if (Helper.GetString(newrule, "") != "" || Helper.GetString(oldrule, "") != "")
            {

                string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');

                //项目规格的原有的数量
                string oldr = "";
                if (oldrule != "")
                {
                    string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('|');
                    if (oldrulemo[0].ToString().Contains("."))
                    {
                        oldr = oldrulemo[0].Substring(0, oldrulemo[0].LastIndexOf('.'));
                    }
                }
                for (int i = 0; i < newrulemo.Length; i++)
                {
                    string newr = newrulemo[i].Substring(0, newrulemo[i].LastIndexOf('.'));
                    
                    if ((oldrule.Contains(newr) && newr != "") || (oldr == "" && newr == ""))
                    {
                        falg = true;
                    }
                }

            }
            return falg;
        }



        #endregion


        public static bool IsSameResultCar(string newrule, string oldrule, ref int sameReslutNum)
        {
            bool falg = false;

            if (Utils.Helper.GetString(newrule, "") != "" && Utils.Helper.GetString(oldrule, "") != "")
            {

                string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');

                //项目规格的原有的数量

                for (int i = 0; i < newrulemo.Length; i++)
                {
                    string newr = newrulemo[i].Substring(0, newrulemo[i].LastIndexOf('.'));

                    //颜色:[卡其色].尺寸:[M]
                    if (oldrule != "")
                    {
                        string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('-');
                        for (int j = 0; j < oldrulemo.Length; j++)
                        {
                            if (oldrulemo[j].ToString() != "")
                            {
                                if (oldrulemo[j].ToString().Contains(newr) && newr != "")
                                {

                                    if (oldrulemo[j].ToString().Contains("."))
                                    {
                                        string strSameReslutNum = oldrulemo[0].Substring(oldrulemo[j].LastIndexOf('.'));
                                        sameReslutNum = Utils.Helper.GetInt(strSameReslutNum.Split(':')[1].Replace("[", "").Replace("]", ""), 0);


                                    }
                                    falg = true;
                                    continue;
                                }

                            }
                        }

                    }


                }

            }
            return falg;
        }




        #region 判断购物车中数量+当前选择的数量是否超出库存
        public static bool isinventsum(int sumQuantity, string newrule, string oldrule)
        {
            bool falg = false;
            int newnum = 0;
            int oldnum = 0;
            if (newrule != "" && oldrule != "")
            {
                string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
                //项目规格的原有的数量
                string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('|');

                for (int i = 0; i < oldrulemo.Length; i++)
                {
                    for (int j = 0; j < newrulemo.Length; j++)
                    {
                        if (oldrulemo[i].Contains(newrulemo[j].Substring(0, newrulemo[j].LastIndexOf(','))))
                        {
                            newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                            oldnum = Convert.ToInt32(oldrulemo[i].Substring(oldrulemo[i].LastIndexOf(','), oldrulemo[i].Length - oldrulemo[i].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                            if (newnum + sumQuantity > oldnum)
                            {
                                falg = true;
                            }
                        }
                    }
                }
            }

            return falg;
        }
        #endregion

        #region 订单支付成功，规格数量的变化 state 0 代表订单支付成功库存减少，1代表，退款到账户余额，库存增加
        public static string GetOrderrule(string newrule, string oldrule, int state)
        {
            try
            {
                string result = string.Empty;
                string[] newrulemo = newrule.Replace("{", "").Replace("}", "").Split('|');
                string[] oldrulemo = oldrule.Replace("{", "").Replace("}", "").Split('|');
                int newnum = 0;
                int oldnum = 0;
                int sum = 0;
                bool falg = false;
                //项目规格的原有的数量
                for (int j = 0; j < oldrulemo.Length; j++)
                {
                    falg = false;
                    string str = "";
                    if (oldrulemo[j].ToString().Contains("价格"))
                    {
                        str = oldrulemo[j].Substring(0, oldrulemo[j].LastIndexOf(','));
                        str = str.Substring(0, str.LastIndexOf(','));
                    }
                    else
                    {
                        str = oldrulemo[j].Substring(0, oldrulemo[j].LastIndexOf(','));
                    }

                    for (int i = 0; i < newrulemo.Length; i++)
                    {
                        if (newrulemo[i].Contains(str))
                        {
                            falg = true;
                            newnum = Convert.ToInt32(newrulemo[i].Substring(newrulemo[i].LastIndexOf(','), newrulemo[i].Length - newrulemo[i].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                            oldnum = Convert.ToInt32(oldrulemo[j].Substring(oldrulemo[j].LastIndexOf(','), oldrulemo[j].Length - oldrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                            if (state == 0)
                            {
                                sum = oldnum - newnum;
                            }
                            else
                            {
                                sum = oldnum + newnum;
                            }
                            result += "{" + oldrulemo[j].Substring(0, oldrulemo[j].LastIndexOf(',')) + ",数量:[" + sum + "]}|";
                        }
                        else
                        {
                            if (newrule.Contains(str))
                            {

                            }
                            else
                            {
                                if (falg == false)
                                {
                                    falg = true;
                                    oldnum = Convert.ToInt32(oldrulemo[j].Substring(oldrulemo[j].LastIndexOf(','), oldrulemo[j].Length - oldrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                                    sum = oldnum;
                                    result += "{" + oldrulemo[j].Substring(0, oldrulemo[j].LastIndexOf(',')) + ",数量:[" + sum + "]}|";
                                }
                            }
                        }
                    }
                }

                result = result.Remove(result.LastIndexOf('|'));
                return result;
            }
            catch
            {
            }
            return oldrule;
        }
        #endregion

      

    }
}
