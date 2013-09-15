<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Linq" %>
<script runat="server">

    protected int number = 0;
    protected decimal sum = 0;
    public ITeam teammodel = Store.CreateTeam();
    public int num = 0;
    public bool invent = false;
    protected string htmlresult = String.Empty;
    public bool blagg = false;
    protected NameValueCollection _system = null;
    protected override void OnLoad(EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            initPage();

        }
        _system = WebUtils.GetSystem();
    }

    private void initPage()
    {
        string teamid = Request["addteamid"];
        string num = Request["num"];
        string result = Request["result"];
        string money = Request["m_rule"];
        using (IDataSession seion = Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(Convert.ToInt32(teamid));
        }
        if (teammodel != null)
        {
            money = teammodel.Team_price.ToString();
        }
        if (Request["m_rule"] != null && Request["m_rule"].ToString() != "")
        {
            if (decimal.Parse(money) == decimal.Parse(Request["m_rule"]))
            {
                money = teammodel.Team_price.ToString();
            }
            else
            {
                money = Request["m_rule"];
            }
        }
        else
        {
            money = teammodel.Team_price.ToString();
        }
         int carcount=0;
        bool isExistrule = false;
        System.Collections.Generic.List<Car> newcarlist = CookieCar.GetCarData();
        if (newcarlist!=null&&newcarlist.Count > 0)
        {
            var querys = from Car c in newcarlist
                         where c.Qid == teammodel.Id.ToString()
                         select c;

            foreach (var item in querys)
            {
                carcount = item.Quantity;
            }
        }

        if (num != "" && num.Length <= 6)
        {
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
                htmlresult = "您不可以选择一样的规格，请重新选择";
            }
            else if (isExistrule)
            {
                //result = "友情提示:您选择的产品库存数量为0，无法购买";
                htmlresult = "您选择了此项目所没有的规格，请重新选择";
            }
            else if (invent)
            {
                htmlresult = "您购买的数量超过了库存数量，请减少一些";
            }
            else if (teammodel.teamcata == 0 && Helper.GetInt(carcount, 0) >= teammodel.Per_number && teammodel.Per_number > 0)
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
                int intSameTeamResultNum = 0;//标志新增相同规格的同项目的数量
                //判断购物车是否有项目信息，没有则往购物车中添加
                if (carlist != null)
                {

                    string strRule = "0"; //标志购物车中 相同项目是否存在相同规格信息 0：不同规格的相同项目  1： 表示相同规格的相同项目
                    string strTeamCar = ""; //标志购物车中是否有该项目信息 1:表示有该项目新
                    string strNewResult = "";
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

                            string strOldResult = Server.UrlDecode(model.Result);


                            //{颜色:[卡其色].尺寸:[M].数量:[1]}-{颜色:[卡其色].尺寸:[S].数量:[1]}

                            //判断是否相同规格项目
                            if (Utility.IsSameResultCar(result.Replace(",", "."), strOldResult, ref intSameTeamResultNum))
                            {
                                if (teamid == model.Qid)
                                {
                                    // intSameTeamResultNum=str.Replace
                                    //sumQuantity = sumQuantity + model.Quantity;
                                    intSameTeamResultNum = intSameTeamResultNum + Helper.GetInt(num, 0);
                                    // sumQuantity =Utils.Helper.GetInt(num,0);
                                    //拼写新的规格信息
                                    if (result != "" && strOldResult != "")
                                    {
                                        string str = result.Replace(",", ".");
                                        int length = str.Split('.').Length - 1;
                                        strNewResult = str.Replace(str.Split('.')[length].ToString(), "数量:[" + intSameTeamResultNum + "]");
                                        string ss = getNewResult(strNewResult, strOldResult);
                                        result = ss;
                                    }
                                    //相同则修改数量
                                    strRule = "1";
                                }

                            }
                            else
                            {
                                if (teamid == model.Qid)
                                {
                                    if (strOldResult.IndexOf("{") < 0)
                                    {
                                        strOldResult = "{" + strOldResult.Replace(".", ",") + "}";
                                    }
                                    result = strOldResult + "|" + result;
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
                            if (Helper.GetString(teammodel.bulletin,String.Empty)!=String.Empty|| Helper.GetString(teammodel.invent_result, "") != "")//有规格的商品
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
                            string sum_num = Convert.ToString(sumQuantity + Utility.Getnum(result));
                            //不同规格的新增
                            //intSameTeamResultAdd = 1;
                            // CookieCar.AddSameProductToCar(teamid, num, "", Convert.ToDecimal(money), teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);
                            if (teammodel.invent_result!=null&&teammodel.invent_result.IndexOf("价格") > 0)
                            {
                                intSameTeamResultAdd = 1;
                                CookieCar.AddSameProductToCar(teamid, num, "", Convert.ToDecimal(money), teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);
                            }
                            else
                            {
                                CookieCar.UpdateQuantity(teamid, int.Parse(sum_num), "", Convert.ToDecimal(money), teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);
                            }

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

                if (htmlresult == "yes")
                {
                    if (blagg == true)
                    {
                        number += 1;
                    }
                    htmlresult = "<span style=\"color:#d80c18;font-size:14px;font-weight: bold;\">此商品已成功添加到购物车</span><br><br>购物车共 <span style=\"color:#d80c18;\">" + number + "</span> 种商品    合计：<span style=\"color:#d80c18;\">" + (sum + (Convert.ToDecimal(money) * int.Parse(num))) + "</span>元";
                }
            }
        }
        else if (num == "")
        {
            htmlresult = "请选择购买数量";

        }
        else
        {
            htmlresult = "您放入购物车的数量已超出交易数量上限999999，请减少一些！";

        }
    }
    private string getNewResult(string result, string oldResult)
    {
        string newResult = "";
        string newr = result.Substring(0, result.LastIndexOf('.'));
        string[] oldResults = oldResult.Split('-');
        if (oldResults.Length > 1)
        {
            for (int i = 0; i < oldResults.Length; i++)
            {
                if (oldResults[i].Contains(newr))
                {
                    newResult = newResult + "-{" + result + "}";
                }
                else
                {
                    newResult = newResult + "-" + oldResults[i];
                }
            }
            // -{{颜色:[卡其色].尺寸:[M].数量:[2]}-{颜色:[卡其色].尺寸:[S].数量:[1]}
            if (newResult.Length > 0)
            {
                newResult = newResult.Substring(2).Replace(".", ",");
            }
        }
        else
        {
            newResult = result.Replace(".", ",");
        }
        return newResult;

    }
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="position: absolute; z-index: 10000; bottom: -300px; left: -400px;">
    <script type="text/javascript">
        function tofindcart() {
            <%if (Helper.GetString(Request["type"],String.Empty)=="jd")
	        {%>
            location.href = '<%=GetUrl("京东购物车列表", "mall_jdcart.aspx")%>';
            <%}
              else
              {%>
            location.href = '<%=GetUrl("购物车列表", "shopcart_show.aspx")%>';
            <%}%>
        }
    </script>
    <table width="277" cellspacing="0" cellpadding="0" border="0" align="center">
        <tbody>
            <tr>
                <td width="225">
                    <img height="26" src="<%=PageValue.WebRoot%>upfile/css/i/jxgw1_03.gif"
                        style="width: 225px">
                </td>
                <td onmouseout="this.style.cursor='normal'" onmouseover="this.style.cursor='pointer'" onclick="return X.boxClose();" style="cursor: pointer;">
                    <img width="52" height="26" src="<%=PageValue.WebRoot%>upfile/css/i/cpzs6_04.gif">
                </td>
            </tr>
        </tbody>
    </table>
    <table width="275" cellspacing="0" cellpadding="0" border="0" bgcolor="#ededed" align="center" style="border: 1px solid #c2c2c2; border-top: 0px">
        <tbody>
            <tr>
                <td height="50" align="center" id="tdalertstr">
                    <%=htmlresult %>
                </td>
            </tr>
            <tr>
                <td>
                    <table width="275" cellspacing="0" cellpadding="0" border="0">
                        <tbody>
                            <tr>
                                <td align="center" onclick="tofindcart()" id="tdqjs" style="cursor: pointer;">
                                    <img width="120" height="31" src="<%=PageValue.WebRoot%>upfile/css/i/jxgw1_08.gif">
                                </td>
                                <td id="tdqjsnbsp" style="">&nbsp;</td>
                                <td height="40" align="center">
                                    <a onclick="return X.boxClose();" href="#">
                                        <img width="121" height="31" src="<%=PageValue.WebRoot%>upfile/css/i/jxgw1_10.gif">
                                    </a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
        </tbody>
    </table>
</div>
