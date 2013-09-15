<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.SalePage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
    public int partnerid = 0;
    int branchId = 0;
    int page = 1;
    protected string pagerhtml = String.Empty;
    string url = String.Empty;
    string request_name = String.Empty;
    protected string request_parid = String.Empty;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (Request.HttpMethod == "POST")
        {
            request_parid = Helper.GetString(Request.QueryString["bid"], String.Empty);
            request_name = bname.Text.ToString();
        }
        else
        {
            request_parid = Helper.GetString(Request.QueryString["bid"], String.Empty);
            request_name = Helper.GetString(Request.QueryString["branchName"], String.Empty);
            page = Helper.GetInt(Request.QueryString["page"], 1);
        }


        if (Request.QueryString["bdel"] != null && Request["bdel"].ToString() != "")
        {
            int branchId = Helper.GetInt(Request.QueryString["bdel"].ToString(), 0);

            //对商户分店的操作一定要属于销售人员
            PartnerFilter partfilter = new PartnerFilter();
            partfilter.table = "(select p.saleid,b.id,b.partnerid from partner p inner join branch b on  p.id=b.partnerid) tt where ','+saleid+',' like '%," + CookieUtils.GetCookieValue("sale", key).ToString() + ",%' and id=" + branchId + " and partnerid=" + request_parid;
            int existresult = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                existresult = session.Partners.Count(partfilter);
            }
            if(existresult<=0)
            {
                Response.Redirect("PartnetList.aspx");
                return;
            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int delresult = session.Branch.Delete(Helper.GetInt(branchId,0));
            }
            
            SetSuccess("删除成功");
        }
        BdbShow();
    }
    /// <summary>
    /// 显示数据方法
    /// </summary>
    private void BdbShow()
    {
        string sqlwhere = " 1=1 ";
        IPagers<IBranch> pager = null;
        IList<IBranch> ilistbranch = null;
        BranchFilter branfilter = new BranchFilter();
        if (request_parid != String.Empty)
        {
            sqlwhere = sqlwhere + "  and partnerid=" + request_parid + "";
            url = "bid=" + request_parid;
        }

        if (request_name != String.Empty)
        {
            sqlwhere = sqlwhere + " and branchname like '%" + request_name + "%'";
            url += "&branchName=" + request_name;
        }

        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<th width='28%'>总店名称</th>");
        sb1.Append("<th width='32%'>分站名称</th>");
        sb1.Append("<th width='20%'>已消费优惠券数量</th>");
        sb1.Append("<th width='20%'>操作</th>");
        sb1.Append("</tr>");
        Literal3.Text = sb1.ToString();
        
        StringBuilder sb2 = new StringBuilder();
        branfilter.table = "(select p.title,p.saleid,b.id,b.partnerid,b.branchname from partner p inner join branch b on  p.id=b.partnerid) tt where "+sqlwhere;
        branfilter.PageSize = 30;
        branfilter.CurrentPage = page;
        branfilter.AddSortOrder(BranchFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Branch.Page(branfilter);
        }
        ilistbranch = pager.Objects;
        if (ilistbranch != null && ilistbranch.Count > 0)
        {
            if (ilistbranch.Count > 0)
            {
                int i = 0;
                    foreach(IBranch braninfo in ilistbranch)
                {
                    int num = 0;
                    CouponFilter coufilter = new CouponFilter();
                    coufilter.Consume = "Y";
                    coufilter.shoptypes = Helper.GetInt(braninfo.id,0);
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        num = session.Coupon.GetCount(coufilter);
                    }
                    //显示的数据
                    if (i % 2 != 0)
                    {
                        sb2.Append("<tr  id='team-list-id-" + braninfo.id + "'>");
                    }
                    else
                    {
                        sb2.Append("<tr class=\"alt\"  id='team-list-id-" + braninfo.id + "'>");
                    }
                        IPartner pa=Store.CreatePartner();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        pa = session.Partners.GetByID(Helper.GetInt(braninfo.partnerid, 0));
                    }
                        
                    if (pa != null)
                    {
                        sb2.Append("<td style='word-wrap: break-word;overflow: hidden; width: 250px;'>" + pa.Title.ToString() + "</td>");
                    }
                    else
                    {
                        sb2.Append("<td style='word-wrap: break-word;overflow: hidden; width: 250px;'>无</td>");
                    }

                    sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 250px;'>" +braninfo.branchname.ToString() + "<br/>" + "</div></td>");
                    sb2.Append("<td style='width: 90px'>" + num + "</td>");
                    sb2.Append("<td class='op'>");
                    sb2.Append("<a href='PartnetBranch.aspx?bdel=" + braninfo.id.ToString() + "&bid=" + braninfo.partnerid.ToString() + "' ask='确定删除此分站？'>删除</a>｜");
                    sb2.Append("<a href='PartnetBranchUpdate.aspx?id=" + braninfo.id.ToString() + "&bid=" + braninfo.partnerid.ToString() + "'>编辑</a>");
                    //sb2.Append("<a href='PartnetBranchAdd.aspx?bid=" + braninfo.partnerid.ToString() + "'>新建分站</a>");
                    sb2.Append("</td>");
                    sb2.Append("</tr>");
                    i++;
                }
            }
        }

        Literal1.Text = sb2.ToString();
        pagerhtml = WebUtils.GetPagerHtml(30, pager.TotalRecords, page, PageValue.WebRoot + "sale/PartnetBranch.aspx?" + url + "&page={0}");

    }

    #region ################### 接参 ###################
    private int GetSaleId()//接收销售人员id
    {
        int sale_id = 0;
        if (!object.Equals(CookieUtils.GetCookieValue("sale", key), null))
        {
            try
            {
                sale_id = Helper.GetInt(CookieUtils.GetCookieValue("sale", key).ToString(), 0);
            }
            catch { }
        }
        return sale_id;
    }
        #endregion
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server" method="post">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head" style="padding: 0 10px 30px">
                                    <h2>
                                        分站列表</h2>
                                        <div class="search">
                                        分站名称：<asp:TextBox ID="bname" runat="server" CssClass="h-input" />&nbsp;
                                            <input id="saixuan" type="submit" value="筛选" class="formbutton" name="btnselect"
                                                style="padding: 1px 6px;" runat="server" />
                                        <ul class="filter" style="margin-top: 10px;">
                                        <li></li>
                                    </ul> </div>
                                   
                                </div>
                                <div class="sect">
                                <a style="float:right" href="PartnetBranchAdd.aspx?bid=<%=request_parid %>">新建分站</a>
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal3" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="11">
                                                <ul class="paginator">
                                                    <li class="current" style="margin-right: 50px;">
                                                        <%=pagerhtml %>
                                                     </li>
                                                </ul>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
