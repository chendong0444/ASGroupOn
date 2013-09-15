<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    
    protected string zuo = System.DateTime.Now.AddDays(-1).ToString("yyyy-MM-dd");
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_Download_Coupon))
        {
            SetError("你不具有项目优惠券下载的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }

        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["consume[]"] != null)
            {
                string teamid = Request.Form["team_id"].ToString();
                string consume = Request.Form["consume[]"].ToString();
                downYouhui(teamid, consume);
            }
            else
            {
                SetError("-ERR ERR_NO_DATA");
                Response.Redirect("YingXiao_ShujuXiazai_Youhui.aspx");
                return;
            }
        }

    }

    private void downYouhui(string teamid, string consume)
    {
        StringBuilder sb1 = new StringBuilder();
        string strwhere = "";
        if (consume == "")
        {

            SetError("-ERR ERR_NO_DATA");
            Response.Redirect("YingXiao_ShujuXiazai_Youhui.aspx");
            return;
        }
        else
        {
            sb1.Append("<html>");
            sb1.Append("<meta http-equiv=content-type content=\"text/html; charset=UTF-8\">");
            sb1.Append("<body><table border=\'1\'>");
            sb1.Append("<tr>");
            sb1.Append("<td>ID</td>");
            sb1.Append("<td align='left'>编号</td>");
            sb1.Append("<td>用户名</td>");
            sb1.Append("<td>密码</td>");
            sb1.Append("<td>开始日</td>");
            sb1.Append("<td>到期日</td>");
            sb1.Append("<td>状态</td>");
            sb1.Append("</tr>");

            int num = 1;

            //处理状态开始
            string[] consumes = consume.Split(',');
            string str = "";
            for (int i = 0; i < consumes.Length; i++)
            {
                str = str + "'" + consumes[i] + "',";
            }
            str = str.Substring(0, str.Length - 1);
            //处理状态结束
            //时间
            CouponFilter couponfilter = new CouponFilter();
            
            if (Request.Form["txtstart"] != null && Request.Form["txtend"] != null && Request.Form["txtstart"].ToString() != "" && Request.Form["txtend"].ToString() != "")
            {
                //string dtstart = Helper.GetDateTime(Request.Form["txtstart"], DateTime.Now).ToString("yyyy-MM-dd 0:0:0");
                //string dtend = Helper.GetDateTime(Request.Form["txtend"], DateTime.Now).ToString("yyyy-MM-dd 0:0:0");
                //strwhere = "1=1 and Create_time between '" + dtstart + "' and '" + dtend + "'" + " and Team_id=" + teamid + " and Consume in (" + str + ")";
                couponfilter.FromCreate_time = Helper.GetDateTime(Request.Form["txtstart"], DateTime.Now);
                couponfilter.ToCreate_time = Helper.GetDateTime(Request.Form["txtend"], DateTime.Now);
                couponfilter.Team_ids = Convert.ToInt32(teamid);
                couponfilter.Consumes = str;
            }
            else
            {
                //strwhere = " Team_id=" + teamid + " and Consume in (" + str + ")";
                couponfilter.Team_ids = Convert.ToInt32(teamid);
                couponfilter.Consumes = str;
            }

            //Maticsoft.BLL.Coupon coupon = new BLL.Coupon();
            //int count = coupon.GetList(strwhere).Tables[0].Rows.Count;
            int count = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                count = session.Coupon.GetCount(couponfilter);
            }
                if (count > 0)
                {
                    IList<ICoupon> iListCoupon = null;
                    
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        iListCoupon = session.Coupon.GetList(couponfilter);
                    }
                    foreach(ICoupon icouponInfo in iListCoupon)
                    {
                        sb1.Append("<tr>");
                        sb1.Append("<td>" + (num++).ToString() + "</td>");
                        sb1.Append("<td align='left'>" + icouponInfo.Id + "&nbsp;" + "</td>");

                        if (icouponInfo.User != null)
                        {
                            sb1.Append("<td>" + icouponInfo.User.Username + "&nbsp;" + "</td>");
                        }
                        else
                        {
                            sb1.Append("<td>用户不存在</td>");
                        }
                        sb1.Append("<td>" + icouponInfo.Secret + "&nbsp;" + "</td>");
                        sb1.Append("<td>" + ((icouponInfo.start_time.HasValue) ? icouponInfo.start_time.Value.ToString("yyyy-MM-dd") : String.Empty) + "</td>");
                        sb1.Append("<td>" + DateTime.Parse(icouponInfo.Expire_time.ToString()).ToString("yyyy-MM-dd") + "</td>");
                        if (icouponInfo.Consume.ToUpper() == "Y")
                        {
                            sb1.Append("<td>已使用</td>");
                        }
                        if (icouponInfo.Consume.ToUpper() == "N")
                        {
                            sb1.Append("<td>未使用</td>");
                        }

                        sb1.Append("</tr>");
                    }
                }
                else
                {
                    SetError("没有数据，请重新选择条件下载！");
                    Response.Redirect("YingXiao_ShujuXiazai_Youhui.aspx");
                    Response.End();
                }
            
            sb1.Append("</table></body></html>");
            Response.ClearHeaders();
            Response.Clear();
            Response.Expires = 0;
            Response.Buffer = true;
            Response.AddHeader("Accept-Language", "zh-tw");
            //文件名称
            Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("coupon_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
            Response.ContentType = "Application/octet-stream";
        }

        //文件内容
        Response.Write(sb1.ToString());//-----------
        Response.End();
    }

</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
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
                                <div class="head">
                                    <h2>优惠券下载</h2>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>项目名称</label>
						                <input type="text" name="team_id" group="a" require="true" datatype="number" class="number" /><span class="inputtip">请输入项目的ID</span>
					                </div>
                                    <div class="field">
                                        <label>优惠卷生成日期</label>
                                        <input type="text" name="txtstart" require="true" datatype="date" group="a"  class="date" value="<%=zuo %>"/><span class="inputtip">-</span>
                                        <input type="text" name="txtend" require="true" datatype="date" group="a" class="date" value="<%=DateTime.Now.ToString("yyyy-MM-dd") %>" />
                                    </div>
                                    <div class="field">
                                        <label>消费状态</label>
						                <div style=""><input type="checkbox" name="consume[]" value="Y" checked />&nbsp;已消费&nbsp;&nbsp;<input type="checkbox" name="consume[]" value="N" checked>&nbsp;未消费</div>
					                </div>
                                    <div class="act">
                                        <input type="submit" value="下载" name="commit" group="a" class="formbutton validator"/>
                                    </div>
                                </div>
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