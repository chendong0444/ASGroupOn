<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">

    protected ITeam teammodel = null;
    protected bool invent = false;
    protected string htmlresult = String.Empty;
    protected int number = 0;
    protected decimal sum = 0;
    
    protected override void OnLoad(EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            initPage();
        }

    }
    private void initPage()
    {
        string teamid = Request["goteamid"];
        string num = Request["gonum"];
        string result = Request["goresult"];
        string money = Request["m_rule"];

        using (IDataSession seion = Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(Convert.ToInt32(teamid));
        }
        if (result == "" || (result != "" && !result.Contains("价格")))
        {
            money = teammodel.Team_price.ToString();
        }

        bool isExistrule = false;

        if (teammodel.open_invent == 1)//开启库存
        {
            invent = Utility.isinvent(Helper.GetString(result, ""), Helper.GetString(teammodel.invent_result, ""));
            isExistrule = Utility.GetNewOld(result, teammodel.invent_result);
        }
        if (Utility.Getnum(result) <= 0)
        {
            htmlresult = "您的购买数量不能小于1";
        }
        else if (Utility.Getrule(result))
        {
            htmlresult = "您不可以选择一样的规格";
        }
        else if (isExistrule)
        {
            //result = "友情提示:您选择的产品库存数量为0，无法购买";
            htmlresult = "您选择了此项目所没有的规格";
        }
        else if (invent)
        {
            htmlresult = "您购买的数量超过了库存数量，请减少一些";
        }
        else if (teammodel.teamcata == 0 && Utility.Getnum(result) > teammodel.Per_number && teammodel.Per_number > 0)
        {
            htmlresult = "您最多可以购买" + teammodel.Per_number + "个";
        }
        else if (Utility.Getnum(result) < teammodel.Per_minnumber && teammodel.Per_minnumber > 0)
        {
            htmlresult = "您最低必须购买" + teammodel.Per_minnumber + "个";
        }
        else
        {
            string fee = "";
            fee = teammodel.Fare.ToString();
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

            System.Collections.Generic.List<Car> carlist = new System.Collections.Generic.List<Car>();
            carlist = CookieCar.GetCarData();
            int sumQuantity = 0;
            int intSameTeamResultAdd = 0;//标志是否是新增相同项目的不同规格

            // string products = CookieCar.GetProductInfo(teamid);

            //判断购物车是否有项目信息，没有则往购物车中添加
            if (carlist != null)
            {

                string strRule = "0"; //标志购物车中 相同项目是否存在相同规格信息 0：不同规格的相同项目  1： 表示相同规格的相同项目
                string strTeamCar = ""; //标志购物车中是否有该项目信息 1:表示有该项目新
                foreach (Car model in carlist)
                {

                    //teammodel = teambll.GetModel(Convert.ToInt32(model.Qid), false);
                    if (teammodel != null)
                    {
                        if (teamid == model.Qid)
                        {
                            strTeamCar = "1";
                        }
                        sum += model.Price * model.Quantity;

                        string str = Server.UrlDecode(model.Result);

                        //判断是否相同规格项目
                        if (Utility.IsSameResultCar(result.Replace(",", "."), Server.UrlDecode(model.Result)))
                        {
                            if (teamid == model.Qid)
                            {
                                sumQuantity = sumQuantity + model.Quantity;
                                //相同则修改数量
                                strRule = "1";
                            }

                        }


                    }
                }

                //标志购物车中是否有该项目信息
                if (strTeamCar == "1")
                {
                    //判断是否是同意规格项目
                    if (strRule == "1")
                    {
                        string sum_num = Convert.ToString(sumQuantity + Utility.Getnum(result));
                        if (Helper.GetString(teammodel.invent_result, "") != "")//有规格的商品
                        {
                            //开启库存并且每超出库存  或者没开启库存 则修改cookie，否则提示出错
                            if ((teammodel.open_invent == 1 && !Utility.isinventsum(sumQuantity, Helper.GetString(result, ""), Helper.GetString(teammodel.invent_result, ""))) || teammodel.open_invent == 0)
                            {
                                //相同则修改数量
                                CookieCar.UpdateQuantity(teamid, int.Parse(sum_num), "", Convert.ToDecimal(money), teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);
                                htmlresult = "yes";
                            }
                            else
                            {
                                htmlresult = "您放入购物车的数量加上当前购买的数量已超出库存，请减少一些！ ";
                            }
                        }
                        else//没有规格的商品
                        {
                            //开启库存并且购物车的数量加上当前购买的数量已超出库存     提示出错
                            if (teammodel.open_invent == 1 && int.Parse(sum_num) > Helper.GetInt(teammodel.inventory, 0))
                                htmlresult = "您放入购物车的数量加上当前购买的数量已超出库存，请减少一些！ ";
                            else
                            {

                                CookieCar.UpdateQuantityById(teamid, int.Parse(sum_num), "", Convert.ToDecimal(money), teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);
                                htmlresult = "yes";
                            }

                        }
                    }
                    else if (strRule == "0")
                    {
                        //不同规格的新增
                        intSameTeamResultAdd = 1;
                        CookieCar.AddSameProductToCar(teamid, num, "", Convert.ToDecimal(money), teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);
                        htmlresult = "yes";
                    }
                }
                else
                {
                    //物车中没有该项目信息
                    CookieCar.AddProductToCar(teamid, num, "", Convert.ToDecimal(money), teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);
                    htmlresult = "yes";
                }


            }
            else
            {
                //购物车中不存在
                CookieCar.AddProductToCar(teamid, num, "", Convert.ToDecimal(money), teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);
                htmlresult = "yes";
            }



            System.Collections.Generic.List<Car> newcarlist = CookieCar.GetCarData();

            if (newcarlist != null)
            {

                if (intSameTeamResultAdd == 1)
                {
                    number = newcarlist.Count + 1;
                }
                else
                {
                    number = newcarlist.Count;
                }
            }
            else
            {
                number = 1;
            }
        }
        Response.Write(htmlresult);
        Response.End();
    }
</script>
