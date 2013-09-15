<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    public const string COOKIE_CAR = "PointCar";     //cookie中的购物车
    public ITeam teammodel = Store.CreateTeam();
    public List<Car> carlist = new List<Car>();
    public IList<IOrder> orderlist = null;
    private NameValueCollection _system = new NameValueCollection();
    public int num = 0;
    public bool invent = false;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        if (!Page.IsPostBack)
        {
            if (Request["id"] != null)
            {
                AddPointCar(Request["id"].ToString());
            }
            if (Request["delid"] != null)
            {
                delete(Request["delid"].ToString());
            }
            if (Request["proid"] != null && Request["proid"] != "")
            {
                if (Request["result"] != null && Request["result"] != "")
                {
                    num = Utility.Getnum(Request["result"]);
                    judge(Convert.ToInt32(Request["proid"].ToString()), num, Request["result"]);
                }
                else
                {
                    num = Convert.ToInt32(Request["num"].ToString());
                    judge(Convert.ToInt32(Request["proid"].ToString()), num, Helper.GetString(Server.UrlDecode(CookieCar.GetProductInfo(Request["proid"]).Split(',')[8].ToString()), ""));
                }

            }
            if (Request["teamid"] != null)
            {
                update(Request["teamid"], Convert.ToInt32(Request["num"]), "", 0);
            }
        }
    }
    public void judge(int teamid, int num, string carresult)
    {
        string result = "";
        bool isExistrule = false;
        using (IDataSession seion = Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(teamid);
        }
        if (teammodel.open_invent == 1)//开启库存
        {

            invent = Utility.isinvent(Helper.GetString(carresult, ""), Helper.GetString(teammodel.invent_result, ""));
            isExistrule = Utility.GetNewOld(carresult, teammodel.invent_result);
        }
        if (Utility.Getnum(carresult) > 0)
        {
            if (Utility.Getrule(carresult))
            {
                result = "友情提示：您不可以选择一样的规格，请重新选择";
            }
            else if (isExistrule)
            {
                result = "友情提示:您选择了此项目所没有的规格，请重新选择";
            }
            else if (invent)
            {
                result = "友情提示:您选择了项目的数量超出了库存，请重新选择";
            }
            else if (Utility.Getnum(carresult) > teammodel.Per_number && teammodel.Per_number > 0)
            {
                result = "友情提示:您最多可以购买" + teammodel.Per_number + "个";
            }
            else if (Utility.Getnum(carresult) < teammodel.Per_minnumber && teammodel.Per_minnumber > 0)
            {
                result = "友情提示:您最低必须购买" + teammodel.Per_minnumber + "个";
            }
        }
        else
        {
            result = "友情提示:您的购买数量不能小于1个";
        }
        if (result != "")
        {
            OrderedDictionary list = new OrderedDictionary();
            list.Add("html", result);
            list.Add("id", "coupon-dialog-display-id1");
            Response.Write(JsonUtils.GetJson(list, "updater"));
        }
        else
        {
            update(teamid.ToString(), num, carresult, 1);
        }
    }
    //修改临时购物车的信息
    public void update(string teamid, int num, string result, int back)
    {
        using (IDataSession seion = Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(Convert.ToInt32(teamid));
        }
        //判断这个项目的数量是否>=免单数量，如果成立，没有运费，不成立，有运费
        string fee = "fee";
        if (num >= teammodel.Farefree)
        {
            fee = "0";
        }
        else
        {
            fee = teammodel.Fare.ToString();
        }
        string max = teammodel.Per_number.ToString();
        string min = teammodel.Per_minnumber.ToString();
        if (Helper.GetInt(teammodel.open_invent, 0) == 1)  //开启库存功能
        {
            max = Math.Min(Helper.GetInt(teammodel.Per_number, 0), Helper.GetInt(teammodel.inventory, 0)).ToString();
            if (teammodel.Per_number == 0)
            {
                max = teammodel.inventory.ToString();
            }
        }
        UpdateQuantity(teamid, num, "", teammodel.teamscore, teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);
        if (back == 0)
        {
            Response.Write(JsonUtils.GetJson("toal();", "eval"));
        }
        else
        {
            Response.Write(JsonUtils.GetJson("location.href='" + GetUrl("积分购物车", "PointsShop_PointCar.aspx") + "'", "eval"));
        }
    }
    //删除购物车中的信息
    public void delete(string teamid)
    {
        DeleteProduct(teamid);
        Response.Redirect(GetUrl("积分购物车", "PointsShop_PointCar.aspx"));
    }
    //把选中的商品添加到临时购物车
    public void AddPointCar(string teamid)
    {
        string quantity = "0";
        using (IDataSession seion = Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(Convert.ToInt32(teamid));
        }
        if (teammodel != null)
        {
            if (Utility.Getbulletin(teammodel.bulletin) == "")
            {
                quantity = "1";
            }

            string fee = "";

            fee = teammodel.Fare.ToString();
            string max = teammodel.Per_number.ToString();
            string min = teammodel.Per_minnumber.ToString();
            string num = "1";
            if (min != "0")
            {
                num = min;
            }
            if (Helper.GetInt(teammodel.open_invent, 0) == 1)  //开启库存功能
            {
                max = Math.Min(Helper.GetInt(teammodel.Per_number, 0), Helper.GetInt(teammodel.inventory, 0)).ToString();
                if (teammodel.Per_number == 0)
                {
                    max = teammodel.inventory.ToString();
                }
            }
            AddProductToCar(teamid, num, "", teammodel.teamscore, teammodel.Image, max, teammodel.Farefree.ToString(), fee, "", min);
            Response.Redirect(GetUrl("积分购物车", "PointsShop_PointCar.aspx"));
        }
    }
    //判断如果项目之可以购买一次，并且，用户在项目下过成功订单，那么用户不可以购买此项目，
    public void Judge(int teamid)
    {
        using (IDataSession seion = Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(teamid);
        }

        if (teammodel == null)
        {
            SetError("没有该项目");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
    }
    //根据最大运费查询项目编号
    public static string GetProid(string fare)
    {
        string proid = null;
        decimal[] num = new decimal[500];
        //得到购物车中的所有商品
        string products = CookieCar.GetCarInfo();
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
    //快递费的计算规则
    public decimal GetFarfee(string teamid, int n, string f)
    {
        decimal fee = 0;
        int sum = 0;
        try
        {
            int farfee;
            carlist = CookieCar.GetCarData();
            decimal[] num = new decimal[carlist.Count];
            //计算快递费,找出购物车中最大的运费
            for (int i = 0; i < carlist.Count; i++)
            {
                if (carlist[i].Qid == teamid)
                {
                    sum += n;
                    num[i] = decimal.Parse(f);
                }
                else
                {
                    num[i] = decimal.Parse(carlist[i].Fee);
                    sum += Convert.ToInt32(GetProductInfo(carlist[i].Qid).Split(',')[1]);
                }
                //  decimal.Parse[carlist[0+1].Fee]
            }
            num = Utility.sort(num);
            fee = num[0];

            //根据最大运费，找到项目编号，根据项目编号，找出项目的免单数量
            // farfee = Convert.ToInt32(Utils.CookieCar.GetProductInfo(Utils.CookieCar.GetProid(fee.ToString())).Split(',')[6].ToString());
            farfee = Convert.ToInt32(GetProid(fee.ToString()));

            //同时判断全部项目的数量>=运费最大的项目的免单数量如果成立则免运费，不成立则为有运费（为购物车中最大的运费）
            if (sum >= farfee)
            {
                fee = 0;
            }
            else
            {
                fee = num[0];
            }
        }
        catch (Exception ex)
        {

        }
        // return fee;
        return fee;
    }



    public static void AddProductToCar(string id, string quantity, string goodname, decimal price, string pic, string max, string farfee, string fee, string result, string min)
    {
        string product = id + "," + quantity + "," + goodname + "," + price + "," + pic + "," + max + "," + farfee + "," + fee + "," + result + "," + min;
        int num = 0;
        //购物车中没有该商品
        if (!VerDictCarIsExit(id))
        {
            string oldCar = CookieCar.GetCarInfo();
            string newCar = null;
            if (oldCar != "")
            {
                oldCar += "|";
            }
            newCar += oldCar + product;
            CookieCar.AddCar(newCar);
        }
        else
        {
            int count = int.Parse(GetProductInfo(id).Split(',')[1].ToString());
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
    /// 添加商品的数量
    /// </summary>
    /// <param name="id"></param>
    public static void UpdateQuantity(string id, int quantity, string goodname, decimal price, string pic, string max, string farfee, string fee, string result, string min)
    {
        //得到购物车
        string products = CookieCar.GetCarInfo();
        products = "|" + products + "|";
        string oldProduct = "|" + GetProductInfo(id) + "|";
        if (products != "")
        {
            string oldCar = CookieCar.GetCarInfo();
            string newProduct = "|" + id + "," + quantity + "," + goodname + "," + price + "," + pic + "," + max + "," + farfee + "," + fee + "," + result + "," + min + "|";
            products = products.Replace(oldProduct, newProduct);
            products = products.TrimStart('|').TrimEnd('|');
            CookieCar.AddCar(products);
        }
    }

    /// <summary>
    /// 根据ID得到购物车中一种商品的信息
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    public static string GetProductInfo(string id)
    {
        string productInfo = null;
        //得到购物车中的所有商品
        string products = CookieCar.GetCarInfo();
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
    /// 判断商品是否存在
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    public static bool VerDictCarIsExit(string id)
    {
        //存在的标志: true 有， false 没有
        bool flag = false;
        //得到购物车中的所有商品
        string products = CookieCar.GetCarInfo();
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
        string oldProduct = GetProductInfo(id);
        oldProduct = "|" + oldProduct + "|";
        string products = CookieCar.GetCarInfo();
        if (products != "")
        {
            products = "|" + products + "|";
            products = products.Replace(oldProduct, "|");
            products = products.TrimStart('|').TrimEnd('|');
            CookieCar.AddCar(products);

        }
    }
    /// <summary>
    /// 清空购物车
    /// </summary>
    public static void ClearCar()
    {
        CookieCar.AddCar("");
    }
</script>
