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
<%@ Import Namespace="System.Web.Script.Serialization" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        string strtype = Request.QueryString["type"];
        if (strtype != null && strtype != "")
        {
            if (strtype == "pa") //商户
            {
                string keyword = HttpUtility.UrlDecode(Request.QueryString["keyword"]);
                GetPartner(keyword);
            }
            else if (strtype == "pr")//产品
            {
                string keyword = HttpUtility.UrlDecode(Request.QueryString["keyword"]);
                GetProduct(keyword);
            }
        }
        
    }

    //查询商户
    private void GetPartner(string keyword)
    {
        Response.ContentType = "text/plain";
        StringBuilder sb = new StringBuilder();
        if (keyword != null && keyword!="")
        {
            PartnerFilter pate = new PartnerFilter();
            IList<IPartner> partnerlist = null;
            pate.Titlelike = keyword;
            pate.Top = 15;
            pate.AddSortOrder(PartnerFilter.ID_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                partnerlist = session.Partners.GetList(pate);
            }
            sb.Append("[");
            if (partnerlist != null && partnerlist.Count>0)
            {
                int i = 0;

                foreach (IPartner partner in partnerlist)
                {
                    if (i == partnerlist.Count - 1)
                    {
                        sb.Append("\"" + partner.Id + ":" + partner.Title + "\"");
                    }
                    else
                    {
                        sb.Append("\"" + partner.Id + ":" + partner.Title + "\",");
                    }
                    i++;
                }
            }
            sb.Append("]");
        }
        Response.Write(sb.ToString());
    }

    //查询产品
    private void GetProduct(string keyword)
   {
       Response.ContentType = "text/plain";
       StringBuilder sb = new StringBuilder();
       if (keyword != null && keyword != "")
       {
           ProductFilter productfilter = new ProductFilter();
           IList<IProduct> productlist = null;
           productfilter.Status = 1;
           productfilter.Prnamelike = keyword;
           productfilter.Top = 15;
           productfilter.AddSortOrder(ProductFilter.ID_DESC);
           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
           {
               productlist = session.Product.GetList(productfilter);
           }
           if (productlist != null)
           {
               int i = 0;
               sb.Append("[");
               foreach (IProduct product in productlist)
               {
                   if (i == productlist.Count - 1)
                   {
                       sb.Append("\"" + product.id + ":" + product.productname + "\"");
                   }
                   else
                   {
                       sb.Append("\"" + product.id + ":" + product.productname + "\",");
                   }
                   i++;
               }
               sb.Append("]");
           }
       }
       Response.Write(sb.ToString());
    }
    
</script>