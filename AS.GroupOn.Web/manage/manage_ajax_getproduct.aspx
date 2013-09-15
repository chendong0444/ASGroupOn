<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">

    protected IProduct productmodel = null;
    protected CategoryFilter categoryfilter2 = new CategoryFilter();
    protected IList<ICategory> categorylist2 = null;
    protected CategoryFilter categoryfilterapi = new CategoryFilter();
    protected IList<ICategory> categorylist = null;
    protected System.Data.DataTable categorydt = new System.Data.DataTable();
    protected string strproduct;
    public string fstrcitys = "";
    protected string fstate = "0";
    protected string fisDisplay="";
    protected string fbulletin="";
    protected string finven = "";
    protected string fcreateproduct = "";
    protected string fmarket_price = "";
    protected string fddlinventory="";
    protected string fddlinventory2="";
    protected string fcreatedetail="";
    protected string fImageSet = "";
    protected string shanghutitle = "";
    protected string shanghuid = "";
    protected string fshanghu2="";
    protected string fteamPrice="";
    protected string fddlbrand="";
    protected string fcreatesummary = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        strproduct = Helper.GetString(Request["strproduct"], String.Empty);
        cha();
    }
    /// <summary>
    /// 产品列表选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void cha()
    {
        setcity();
        //api分类初始化  
        //BindApiClassData();
        if (strproduct != String.Empty)
        {
            string productid = "0";
            IProduct iproduct = null;
            int strindexof = strproduct.IndexOf(":");
            if (strindexof != -1)
            {
                iproduct = GetProductData(strproduct.Substring(0,strindexof),"");
            }
            if (iproduct != null)
            {
                productid = iproduct.id.ToString();
            }
            else
            {
                Response.Write("Error");
                Response.End();
                return;
            }
            fstate = "1";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                productmodel = session.Product.GetByID(AS.Common.Utils.Helper.GetInt(productid, 0));
            }
            if (productmodel != null && ((Helper.GetString(Request["ty"], String.Empty) == "mall") || (Helper.GetString(Request["ty"], String.Empty) == "pro")))
            {
                fcreateproduct = productmodel.productname;
                fmarket_price = productmodel.team_price.ToString();
                string[] bulletinteam = productmodel.bulletin.Replace("{", "").Replace("}", "").Split(',');
                if (productmodel.bulletin.Replace("{", "").Replace("}", "") != "")
                {
                    fisDisplay = "style='display:none;'";
                }
                for (int i = 0; i < bulletinteam.Length; i++)
                {
                    string txt = bulletinteam[i];
                    if (bulletinteam[i] != "")
                    {
                        if (bulletinteam[i].Split(':')[0] != "" && bulletinteam[i].Split(':')[1] != "")
                        {
                            fbulletin += "<tr>";
                            fbulletin += "<td>";
                            if (fstate == "0")
                            {
                                fbulletin += "属性：<input type=\"text\" disabled=\" disabled\" class=\"h-input\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + ">数值：<input disabled=\" disabled\" class=\"h-input\" type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + " >";
                                fbulletin += "<input type=\"button\"   class=\"formbutton\"  value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
                            }
                            else
                            {
                                fbulletin += "属性：<input type=\"text\" disabled=\" disabled\" class=\"h-input\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + " readonly>数值：<input disabled=\" disabled\" type=\"text\" class=\"h-input\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + " readonly>";
                            }
                            fbulletin += "</td>";
                            fbulletin += "</tr>";
                        }
                    }
                }
                bool isnotprice = false;
                if (!String.IsNullOrEmpty(productmodel.invent_result) && productmodel.invent_result.Contains("价格"))
                {
                    isnotprice = true;
                }
                fddlinventory = productmodel.open_invent.ToString();
                fddlinventory2 = "false";
                fcreatedetail = productmodel.detail.Replace("\"", "\'");
                fImageSet = productmodel.imgurl;
                finven = productmodel.inventory.ToString();
                IPartner partner = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    partner = session.Partners.GetByID(productmodel.partnerid);
                }
                if (partner != null)
                {
                    IPartner part = GetPartnerData(productmodel.partnerid.ToString(), "");
                    shanghutitle = part.Title;
                    shanghuid = part.Id.ToString();
                }
                else
                {
                    shanghutitle = "";
                    shanghuid = "0";
                }
                fteamPrice = productmodel.team_price.ToString();
                bool blag;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    blag = session.Category.getCount1(productmodel.brand_id);
                }
                //如果产品的品牌已删除，品牌不选中
                if (blag)
                {
                    fddlbrand = productmodel.brand_id.ToString();
                }
                else
                {
                    fddlbrand = "0";
                }
                fcreatesummary = productmodel.summary;
                StringBuilder Json = new StringBuilder();
                if (Request["ty"] == "pro")
                {
                    Json.Append(productmodel.productname + "|_|");//商品名称
                    Json.Append(productmodel.price + "|_|"); //市场价
                    Json.Append(productmodel.team_price + "|_|"); //网站价
                    Json.Append(fddlbrand + "|_|");//品牌分类
                    Json.Append(fcreatesummary + "|_|");//产品简介
                    Json.Append(fcreatedetail + "|_|");//本单详情
                    Json.Append(fddlinventory2 + "|_|");
                    Json.Append(finven + "|_|");//库存数量
                    Json.Append(shanghuid + "|_|"); //商户ID
                    Json.Append(shanghutitle + "|_|");//商户名称
                    Json.Append(fImageSet + "|_|");//产品图片
                    Json.Append(fbulletin + "|_|");//规格信息
                    Json.Append(isnotprice.ToString() + "|_|");//是否是多种价格
                    Json.Append(fddlinventory.ToString() + "|_|");//是否开启库存
                }
                else if (Request["ty"] == "mall")
                {
                    Json.Append(fcreateproduct + "|_|");//商品名称
                    Json.Append(productmodel.price + "|_|"); //市场价
                    Json.Append(productmodel.team_price + "|_|"); //网站价
                    Json.Append(fddlbrand + "|_|");//品牌分类
                    Json.Append(fcreatedetail + "|_|");//本单详情
                    Json.Append(fddlinventory2 + "|_|");
                    Json.Append(finven + "|_|");//库存数量
                    Json.Append(shanghuid + "|_|");//商户ID
                    Json.Append(shanghutitle + "|_|");//商户名称
                    Json.Append(fImageSet + "|_|");//产品图片
                    Json.Append(fbulletin + "|_|");//规格信息
                    Json.Append(isnotprice.ToString() + "|_|");//是否是多种价格
                    Json.Append(fddlinventory.ToString() + "|_|");//是否开启库存
                }
                Response.Write(Json.ToString());
                Response.End();
            }
            else
            {
                Response.Write("Error");
                Response.End();
                return;
            }
        }
    }
    private void setcity()
    {
        StringBuilder sb1 = new StringBuilder();
        categoryfilter2.Zone = "city";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            categorylist2 = session.Category.GetList(categoryfilter2);
        }
        if (categorylist2 != null && categorylist2.Count > 0)
        {
            foreach (ICategory category in categorylist2)
            {
                sb1.Append("<input type='checkbox' name='city_id' value='" + category.Id + "' disabled />&nbsp;" + category.Name + "&nbsp;&nbsp;");
            }
        }
        fstrcitys = sb1.ToString();
    }
    public IProduct GetProductData(string strId, string strprname)
    {
        ProductFilter productfilter = new ProductFilter();
        IProduct productmodel = null;
        if (strId != null && strId != "")
        {
            productfilter.Id = AS.Common.Utils.Helper.GetInt(strId, 0);
        }
        if (strprname != null && strprname != "")
        {
            productfilter.Productname = strprname;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            productmodel = session.Product.Get(productfilter);
        }
        return productmodel;
    }
    public IPartner GetPartnerData(string strId, string strprname)
    {
        PartnerFilter partnerfilter = new PartnerFilter();
        IPartner partnermodel = null;
        if (strId != null && strId != "")
        {
            partnerfilter.Id = AS.Common.Utils.Helper.GetInt(strId, 0);
        }
        if (strprname != null && strprname != "")
        {
            partnerfilter.Titles = strprname;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            partnermodel = session.Partners.Get(partnerfilter);
        }
        return partnermodel;
    }
</script>