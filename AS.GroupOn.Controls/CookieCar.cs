using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Collections.Generic;
using AS.Common.Utils;

namespace AS.GroupOn.Controls
{
    /// <summary>
    ///CookieCar 的摘要说明
    /// </summary>
    public class CookieCar
    {
        public CookieCar()
        {
            //
            //TODO: 在此处添加构造函数逻辑
            //

        }
        public const string COOKIE_CAR = "Car";     //cookie中的购物车


        /// <summary>
        /// 添加不同规格的同一商品到购物车
        /// </summary>
        /// <param name="id"></param>
        /// <param name="quantity"></param>
        /// 
        public static void AddSameProductToCar(string id, string quantity, string goodname, decimal price, string pic, string max, string farfee, string fee, string result, string min)
        {
            string product = id + "," + quantity + "," + goodname + "," + price + "," + pic + "," + max + "," + farfee + "," + fee + "," + result + "," + min;


            string oldCar = GetCarInfo();
            string newCar = null;
            if (oldCar != "")
            {
                oldCar += "|";
            }
            newCar += oldCar + product;
            AddCar(newCar);

        }



        public static void AddProductToCar(string id, string quantity, string goodname, decimal price, string pic, string max, string farfee, string fee, string result, string min)
        {
            string product = id + "," + quantity + "," + goodname + "," + price + "," + pic + "," + max + "," + farfee + "," + fee + "," + result + "," + min;
            int num = 0;
            //购物车中没有该商品
            if (!VerDictCarIsExit(id))
            {
                string oldCar = GetCarInfo();
                string newCar = null;
                if (oldCar != "")
                {
                    oldCar += "|";
                }
                newCar += oldCar + product;
                AddCar(newCar);
            }
            else
            {
                int count = int.Parse(GetProductInfoById(id).Split(',')[1].ToString());
                if (Convert.ToInt32(max) > 0)
                {
                    if (count + 1 > Convert.ToInt32(max))
                    {
                        num = Convert.ToInt32(max);
                    }
                    else
                    {
                        num = count + 1;
                    }
                }
                else
                {
                    num = count + 1;
                }
                UpdateQuantity(id, num, goodname, price, pic, max, farfee, fee, result, min);
            }
        }

        /// <summary>
        /// 得到购物车数据
        /// </summary>
        public static List<Car> GetCarData()
        {

            List<Car> carlist = new List<Car>();
            string carInfo = GetCarInfo();
            try
            {
                if (carInfo != "")
                {
                    string sql = "";
                    Car carmodel;
                    foreach (string product in carInfo.Split('|'))
                    {
                        carmodel = new Car();
                        string id = (product.Split(',')[0].ToString());
                        int quantitiy = int.Parse(product.Split(',')[1].ToString());
                        string goodname = product.Split(',')[2].ToString();
                        string money = product.Split(',')[3].ToString();

                        decimal price = decimal.Parse(product.Split(',')[3].ToString());
                        string pic = product.Split(',')[4].ToString();
                        string max = product.Split(',')[5].ToString();

                        string farefee = product.Split(',')[6].ToString();
                        string fee = product.Split(',')[7].ToString();
                        string result = product.Split(',')[8].ToString();
                        string min = product.Split(',')[9].ToString();
                        carmodel.Qid = id;
                        carmodel.Quantity = quantitiy;
                        carmodel.Pic = pic;
                        carmodel.Price = price;
                        carmodel.Goodname = goodname;
                        carmodel.Weight = max;
                        carmodel.min = min;
                        carmodel.Farfee = farefee;
                        carmodel.Fee = fee;
                        carmodel.Result = result;
                        carlist.Add(carmodel);

                    }

                    //TotalPrice(gv);       //计算总价
                    return carlist;
                }
                else
                {

                    //return "购物车为空，请选择商品！";
                    return null;
                }
            }
            catch (Exception ex)
            {
                ClearCar();
                return null;
            }
            // return null;
        }
        /// <summary>
        /// 添加商品的数量    用于选择了规格的商品
        /// </summary>
        /// <param name="id"></param>
        public static void UpdateQuantity(string id, int quantity, string goodname, decimal price, string pic, string max, string farfee, string fee, string result, string min)
        {
            //得到购物车
            string results = id + System.Web.HttpContext.Current.Server.UrlDecode(result);
            string products = GetCarInfo();
            products = "|" + products + "|";
            string oldProduct = "|" + GetProductInfo(results) + "|";
            if (GetProductInfo(results) != null)
            {
                if (products != "")
                {

                    string oldCar = GetCarInfo();
                    string newProduct = "|" + id + "," + quantity + "," + goodname + "," + price + "," + pic + "," + max + "," + farfee + "," + fee + "," + result + "," + min + "|";
                    products = products.Replace(oldProduct, newProduct);
                    products = products.TrimStart('|').TrimEnd('|');
                    AddCar(products);

                }
            }
            else
            {
                UpdateQuantityById(id, quantity, goodname, price, pic, max, farfee, fee, result, min);
            }

        }


        /// <summary>
        /// 添加商品的数量   用于无规格或不选择规格的商品
        /// </summary>
        /// <param name="id"></param>
        public static void UpdateQuantityById(string id, int quantity, string goodname, decimal price, string pic, string max, string farfee, string fee, string result, string min)
        {
            //得到购物车
            string products = GetCarInfo();
            products = "|" + products + "|";
            string oldProduct = "|" + GetProductInfoById(id) + "|";

            if (products != "")
            {
                string oldCar = GetCarInfo();
                string newProduct = "|" + id + "," + quantity + "," + goodname + "," + price + "," + pic + "," + max + "," + farfee + "," + fee + "," + result + "," + min + "|";
                products = products.Replace(oldProduct, newProduct);
                products = products.TrimStart('|').TrimEnd('|');
                AddCar(products);
            }

        }

        /// <summary>
        /// 根据ID得到购物车中一种商品的信息
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public static string GetProductInfoById(string id)
        {
            string productInfo = null;
            //得到购物车中的所有商品
            string products = GetCarInfo();
            foreach (string product in products.Split('|'))
            {
                if (id == product.Split(',')[0])
                {
                    productInfo = product;
                    break;
                }
            }
            return productInfo;
        }


        /// <summary>
        /// 得到购物车
        /// </summary>
        /// <returns></returns>
        public static string GetCarInfo()
        {
            if (HttpContext.Current.Request.Cookies[COOKIE_CAR] != null)
            {
                string str = HttpContext.Current.Request.Cookies[COOKIE_CAR].Value.ToString();
                return HttpContext.Current.Request.Cookies[COOKIE_CAR].Value.ToString();
            }
            return "";
        }

        /// <summary>
        /// 根据ID+result得到购物车中一种商品的信息 
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public static string GetProductInfo(string idresult)
        {
            string productInfo = null;
            if (idresult.Contains("."))
            {
                idresult = idresult.Substring(0, idresult.LastIndexOf('.'));
            }
            //得到购物车中的所有商品
            string products = GetCarInfo();
            if (products.Split('|')[0] != null)
            {
                foreach (string product in products.Split('|'))
                {
                    string endresult = (product.Split(',')[0] + System.Web.HttpContext.Current.Server.UrlDecode(product.Split(',')[8]));
                    if (endresult.Contains("."))
                    {
                        endresult = endresult.Substring(0, endresult.LastIndexOf('.'));
                    }

                    if (idresult == endresult)
                    {
                        productInfo = product;
                        break;
                    }
                }
            }

            return productInfo;
        }


        #region 根据最大运费查询项目编号
        public static string GetProid(string fare)
        {
            // string proid = null;
            decimal[] num = new decimal[500];
            //得到购物车中的所有商品
            string products = GetCarInfo();
            int count = 0;
            foreach (string product in products.Split('|'))
            {

                if (fare == product.Split(',')[7])
                {
                    num[count] = decimal.Parse(product.Split(',')[6]);
                    //proid = product.Split(',')[0];
                    Utility.sort(num);
                }
                count++;
            }
            return num[0].ToString();
        }
        #endregion
        /// <summary>
        /// 加入购物车   
        /// </summary>
        public static void AddCar(string product)
        {

            HttpCookie car = new HttpCookie(COOKIE_CAR, product);
            car.Domain = WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
            //HttpContext.Current.Response.Cookies.Remove(COOKIE_CAR);
            HttpContext.Current.Response.Cookies.Add(car);

        }

        /// <summary>
        /// 判断商品是否存在
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public static bool VerDictCarIsExit(string id)
        {
            //存在的标志: true 有， false 没有
            bool flag = false;
            //得到购物车中的所有商品
            string products = GetCarInfo();
            foreach (string product in products.Split('|'))
            {
                if (id == product.Split(',')[0])
                {
                    flag = true;
                    break;
                }
            }
            return flag;
        }

        /// <summary>
        /// 通过商品编号删除订单
        /// </summary>
        /// <param name="id"></param>
        public static void DeleteProduct(string id)
        {
            string oldProduct = GetProductInfoById(id);
            oldProduct = "|" + oldProduct + "|";
            string products = GetCarInfo();
            if (products != "")
            {
                products = "|" + products + "|";
                products = products.Replace(oldProduct, "|");
                products = products.TrimStart('|').TrimEnd('|');
                AddCar(products);

            }
        }

        public static void DeleteProduct(string id, string result)
        {
            if (result != "")
            {
                string oldProduct = "";
                string products = GetCarInfo();

                if (products != "")
                {
                    string[] _products = products.Split('|');
                    for (int i = 0; i < _products.Length; i++)
                    {
                        string teamid = _products[i].Split(',')[0].ToString();
                        string resultcard = _products[i].Split(',')[8].ToString();
                        resultcard = Utility.GetCarfont(HttpContext.Current.Server.UrlDecode(resultcard));
                        if (teamid == id && resultcard == result)
                        {

                            if (products != "")
                            {
                                products = "|" + products + "|";
                                oldProduct = "|" + _products[i] + "|";
                                products = products.Replace(oldProduct.Replace("{", "").Replace("}", ""), "|");
                                products = products.TrimStart('|').TrimEnd('|');
                                AddCar(products);

                            }
                        }

                    }
                }
            }
            else
            {
                DeleteProduct(id);
            }


        }

        /// <summary>
        /// 晴空购物车
        /// </summary>
        public static void ClearCar()
        {
            AddCar("");
        }



    }

}
