<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
<script runat="server">

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        string action = Helper.GetString(Request["action"], String.Empty);
        string orderview = Helper.GetString(Request["orderview"], String.Empty);
        string saleid = Helper.GetString(Request["saleid"], String.Empty);
        string userview = Helper.GetString(Request["Id"], String.Empty);
        string authorization = Helper.GetString(Request["authorization"], String.Empty);
        int addrole = Helper.GetInt(Request["addrole"], 0);
        string sms_v = Helper.GetString(Request["v"], String.Empty);
        string couponsecret = Helper.GetString(Request["couponsecret"], String.Empty);
        string sid = Helper.GetString(Request["cid"], String.Empty);
        int id = Helper.GetInt(Request["id"], 0);
        string orderid = Helper.GetString(Request["orderid"], String.Empty);
        string tid = Helper.GetString(Request["id"], string.Empty);
        string adminfenzhan = Helper.GetString(Request["adminfenzhan"], String.Empty);
        string pageIndex = Helper.GetString(Request["pageIndex"], string.Empty);
        //判断管理员是否有此操作
        //if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_User_ListView))
        //{
        //    SetError("你不具有查看用户列表的权限！");
        //    Response.Redirect("index.aspx");
        //    Response.End();
        //    return;
        //}
        if (action == "orderview")
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_Detail))
            {
                Response.Write(JsonUtils.GetJson("你不具有查看订单详情的权限", "alert"));
                return;
            }
            string html = WebUtils.LoadPageString("manage_ajax_orderview.aspx?orderview=" + Helper.GetInt(orderview, 0));
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "salerelation")
        {
            string html = WebUtils.LoadPageString("manage_ajax_salerelation.aspx?saleid=" + Helper.GetInt(saleid, 0));
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "userview") //用户信息及充值
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_User_Detail))
            {
                Response.Write(JsonUtils.GetJson("你没有查看用户详情权限", "alert"));
                return;
            }
            string userviews_id = Helper.GetString(Request["Id"], String.Empty);
            string html = WebUtils.LoadPageString("manage_ajax_userview.aspx?userview=" + Helper.GetInt(userviews_id, 0));
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "authorization")
        {
            string html = WebUtils.LoadPageString("manage_ajax_authorization.aspx?authorization=" + Helper.GetInt(authorization, 0));
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "adminfenzhan")
        {
            string html = WebUtils.LoadPageString("manage_ajax_adminfenzhan.aspx?adminfenzhanid=" + Helper.GetInt(adminfenzhan, 0));
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "sms")
        {
            string html = WebUtils.LoadPageString("manage_ajax_dialog_miscsms.aspx?v=" + sms_v + "");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "secret")
        {
            string type = "";
            if (Request["type"] != null && Request["type"].ToString() != "")
            {
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_CouponP_Detail))
                {
                    Response.Write(JsonUtils.GetJson("你不具有查看站外券的权限", "alert"));
                    return;
                } 
                type = Request["type"].ToString();
            }
            else
            {
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Coupon_Detail))
                {
                    Response.Write(JsonUtils.GetJson("你不具有查看站内券的权限", "alert"));
                    return;
                } 
            }
            string html = WebUtils.LoadPageString("manage_ajax_dialog_couponsecret.aspx?type=" + type + "&couponsecret=" + couponsecret + "&id=" + sid);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            return;
        }
        else if (action == "authorization")
        {
            string html = WebUtils.LoadPageString("manage_ajax_authorization.aspx?authorization=" + Helper.GetInt(authorization, 0));
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "addrole")//添加或修改角色
        {
            if (addrole > 0)
            {
                string html = WebUtils.LoadPageString("ajax_addRole.aspx?addrole=" + Helper.GetInt(addrole, 0));
                Response.Write(JsonUtils.GetJson(html, "dialog"));
            }
            else
            {

                string html = WebUtils.LoadPageString("ajax_addRole.aspx");
                Response.Write(JsonUtils.GetJson(html, "dialog"));
            }
        }
        else if (action == "addrole") //添加或修改角色
        {
            if (addrole > 0)
            {
                string html = WebUtils.LoadPageString("ajax_addRole.aspx?addrole=" + Helper.GetInt(addrole, 0));
                Response.Write(JsonUtils.GetJson(html, "dialog"));
            }
            else
            {
                string html = WebUtils.LoadPageString("ajax_addRole.aspx");
                Response.Write(JsonUtils.GetJson(html, "dialog"));
            }
        }
        else if (action == "pcoupon")
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_CouponP_Edit))
            {
                Response.Write(JsonUtils.GetJson("你不具有编辑站外券的权限", "alert"));
                return;
            } 
            string html = WebUtils.LoadPageString("manage_ajax_dialog_editpcoupon.aspx?id=" + Helper.GetInt(sid, 0) + "");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "teamdetail")
        {
            string html = WebUtils.LoadPageString("manage_ajax_dialog_teamdetail.aspx?id=" + tid);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            return;
        }
        else if (action == "updateorder")
        {
            int oid = Helper.GetInt(Request["orderid"], 0);
            int expressid = Helper.GetInt(Request["expressid"], 0);

            IOrder order = Store.CreateOrder();

            order.Id = oid;
            order.Express_id = expressid;
            int cnt;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                cnt = session.Orders.UpdateExpress_id(order);
            }
            if (cnt > 0)
            {
                Response.Write(JsonUtils.GetJson("$('#orderbutton" + orderid + "').val('保存成功')", "eval"));
            }
            else
            {
                Response.Write(JsonUtils.GetJson("$('#orderbutton" + orderid + "').val('保存失败')", "eval"));
            }
            Response.End();
        }

        else if (action == "adminremark")
        {
            string html = AS.AdminEvent.OrderEvent.Manager_GetReMark(Helper.GetInt(id, 0)).ToString();
            Response.Clear();
            OrderedDictionary od = new OrderedDictionary();
            od.Add("id", "adminremark");
            od.Add("html", html);
            Response.Write(JsonUtils.GetJson(od, "updater"));
            Response.End();
        }
        else if (action == "submitadminremark")
        {
            string content = Helper.GetString(Request.Form["content"], String.Empty);
            string msg = String.Empty;
            int adminid = Helper.GetInt(AsAdmin.Id, 0);
            if (content.Length > 0 && adminid > 0)
            {
                msg = AS.AdminEvent.OrderEvent.Manager_AddReMark(adminid, content, Helper.GetInt(id, 0));
                if (msg == String.Empty)
                    Response.Write("OK");
                else
                    Response.Write(msg);
            }
            else
                Response.Write("管理员不存在!");
        }
        else if (action == "refunddel")//客服删除退款记录
        {
            int refundid = Helper.GetInt(Request.QueryString["rid"], 0);
            int adminid = Helper.GetInt(AsAdmin.Id, 0);
            IRefunds refunds = Store.CreateRefunds();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                refunds = session.Refunds.GetByID(refundid);
            }
            string msg = AS.AdminEvent.OrderEvent.Refund_Delete(refundid, adminid, DateTime.Now);
            string key = AS.Common.Utils.FileUtils.GetKey();
            AS.AdminEvent.ConfigEvent.AddOprationLog(AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0), "删除订单", "删除订单 ID:" + refunds.Order_ID, DateTime.Now);
            Response.Write(JsonUtils.GetJson(msg, "alert"));
        }
        else if (action == "refund8")//财务接受退款请求
        {

            int refundid = Helper.GetInt(Request.QueryString["rid"], 0);
            int adminid = Helper.GetInt(AsAdmin.Id, 0);
            string msg = AS.AdminEvent.OrderEvent.Refund_Receive(refundid, adminid, DateTime.Now);
            if (msg.Length == 0)//接受成功
            {
                Response.Write(JsonUtils.GetJson("alert('接受成功');window.location.reload();$(\"a[rid='" + refundid + "']\").attr('href','ajax_manage.aspx?action=refund16&rid=" + refundid + "');$(\"a[rid='" + refundid + "']\").html('处理');", "eval"));
            }
            else
                Response.Write(JsonUtils.GetJson(msg, "alert"));
        }
        else if (action == "refund16")//弹出财务处理窗口
        {
            int refundid = Helper.GetInt(Request.QueryString["rid"], 0);
            string html = WebUtils.LoadPageString("ajax_refundover.aspx?id=" + refundid);
            Response.Clear();
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            return;
        }
        else if (action == "Refund")
        {
            string html = WebUtils.LoadPageString("manage_ajax_order_refund.aspx?orderview=" + Helper.GetInt(Request["orderview"], 0));
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "refundover")
        {
            int refundid = Helper.GetInt(Request.Form["rid"], 0);
            int adminid = Helper.GetInt(AsAdmin.Id, 0);
            string remark = Request.Form["remark"];
            string result = AS.AdminEvent.OrderEvent.Refund_Confir(refundid, adminid, DateTime.Now, remark);
            if (result.Length == 0)//处理成功
                Response.Write(JsonUtils.GetJson("alert('处理成功');window.location.reload();", "eval"));
            else
                Response.Write(JsonUtils.GetJson("alert('" + result + "');window.location.reload();", "eval"));
        }
        else if (action == "area" || action == "circle")
        {
            string add = String.Empty;
            string update = String.Empty;
            string html = String.Empty;
            if (action == "area")
            {
                add = "&add=" + Helper.GetString(Request["add"], String.Empty);
                html = WebUtils.LoadPageString("manag_ajax_Area.aspx?" + add);
            }
            else if (action == "circle")
            {

                update = "&update=" + Helper.GetString(Request["update"], String.Empty);
                html = WebUtils.LoadPageString("manag_ajax_Area.aspx?add=" + AS.Common.Utils.Helper.GetString(Request["add"], String.Empty) + update);
            }
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if (action == "productstatus")
        {
            string html = WebUtils.LoadPageString("manage_ajax_ProductReview.aspx?id=" + AS.Common.Utils.Helper.GetInt(id, 0));
            Response.Clear();
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            return;
        }
        else if ("productdetail" == action)
        {
            string html = WebUtils.LoadPageString("manage_ajax_dialog_productdetail.aspx?id=" + id);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            return;
        }
        //结算审核
        else if (action == "partner_detailstate")
        {
            int parid = AS.Common.Utils.Helper.GetInt(Request["pid"], 0);
            int teamid = AS.Common.Utils.Helper.GetInt(Request["teamid"], 0);
            int num = AS.Common.Utils.Helper.GetInt(Request["num"], 0);
            int state = AS.Common.Utils.Helper.GetInt(Request["state"], 0);
            string ids = AS.Common.Utils.Helper.GetString(Request["Id"], String.Empty);
            string html = WebUtils.LoadPageString("manage_ajax_PartnerDetailReview.aspx?id=" + ids + "&sta=" + state + "&num=" + num + "&teamid=" + teamid + "&pid=" + parid);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            return;
        }
        //结算详情
        else if (action == "PartnerXiangQing")
        {
            string ids = AS.Common.Utils.Helper.GetString(Request["Id"], String.Empty);
            string html = WebUtils.LoadPageString("manage_ajax_PartnerDetailXiangqing.aspx?Id=" + ids);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            
        }
        else if (action == "freight")//设置每个快递公司的运费
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_ExpressCompany_FarePrice))
            {
                SetError("你不具有查看运费价格的权限！");
                Response.Redirect("Type_KuaidiGongsi.aspx");
                Response.End();
                return;

            }
            string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/manage_expressprice.aspx?id=" + id);
            Response.Clear();
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
        }
        else if (action == "freightedit")//保存快递公司的运费设置
        {
            IExpressprice expressprice = Store.CreateExpresspric();
            ExpresspriceFilter filter = new ExpresspriceFilter();

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                expressprice = session.Expressprice.GetByExpressID(id);

            }
            if (expressprice != null)
            {
                decimal oneprice = Helper.GetDecimal(Request["oneprice"], 0);
                decimal twoprice = Helper.GetDecimal(Request["twoprice"], 0);
                expressprice.expressid = id;
                expressprice.oneprice = oneprice;
                expressprice.twoprice = twoprice;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int i = session.Expressprice.Update(expressprice);
                }
            }
            else
            {
                IExpressprice expre = Store.CreateExpresspric();

                decimal oneprice = Helper.GetDecimal(Request["oneprice"], 0);
                decimal twoprice = Helper.GetDecimal(Request["twoprice"], 0);
                expre.expressid = id;
                expre.oneprice = oneprice;
                expre.twoprice = twoprice;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int i = session.Expressprice.Insert(expre);
                }
            }
            SetSuccess("运费设置成功");
            Response.Redirect(Request.UrlReferrer.AbsoluteUri, false);
            Response.End();
        }
        else if ("categoryedit" == action)
        {
            string update = String.Empty;
            string add = String.Empty;
            string html = String.Empty;
            if (Request["update"] != null)
            {
                update = "&update=" + Helper.GetString(Request["update"], String.Empty);
                html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/Type.aspx?zone=" + Helper.GetString(Request["zone"], String.Empty) + update);
            }
            else if (Request["add"] != null)
            {
                add = "&add=" + Helper.GetString(Request["add"], String.Empty);
                html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxPage/Type.aspx?zone=" + Helper.GetString(Request["zone"], String.Empty) + add);
            }
            else
            {             
                html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxPage/Type.aspx?zone=" + Helper.GetString(Request["zone"], String.Empty) + update);
            }

            Response.Write(JsonUtils.GetJson(html, "dialog"));

        }
        else if (action == "nocitysview")//显示快递公司不到的区域
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_ExpressCompany_Add))
            {
                SetError("你不具有查看未送达区域设置的权限！");
                Response.Redirect("Type_KuaidiGongsi.aspx");
                Response.End();
                return;

            }
            string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/nocitysview.aspx?expressid=" + id);
            Response.Clear();
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
        }
        //商户结算按钮
        else if (action == "pmoney")
        {
            int Pid = AS.Common.Utils.Helper.GetInt(Request["id"], 0);
            string html = WebUtils.LoadPageString("manage_ajax_pmoney.aspx?par_Id=" + Pid);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
            return;
        }
        //上传图片
        else if (action == "addImg")
        {

            string add = String.Empty;
            string html = String.Empty;
            add = AS.Common.Utils.Helper.GetString(Request["action"], String.Empty);
            html = WebUtils.LoadPageString("manage_ajax_ImgUpload.aspx?add=" + add);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        else if ("pinvent" == action)
        {
            int inventid = Helper.GetInt(Request["inventid"], 0);
            string p = Helper.GetString(Request["p"],null);
            string html = String.Empty;
            html = WebUtils.LoadPageString("manage_ajax_AddInventoryLogProdunct.aspx?id=" + inventid + "&p=" + p + "");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
            return;
        }
        else if (action == "userlevelrule")
        {
            #region 新建用户等级
            if (Request["zone"] != null)
            {
                string grade = Helper.GetString(Request["zone"], String.Empty);
                string html = String.Empty;
                html = WebUtils.LoadPageString("manage_ajax_Userlevelrules.aspx?zone=" + grade);
                Response.Write(JsonUtils.GetJson(html, "dialog"));
            }
            else 
            {
                int user_id = Helper.GetInt(Request["userid"], 0);
                string html = String.Empty;
                html = WebUtils.LoadPageString("manage_ajax_Userlevelrules.aspx?userida="+ user_id);
                Response.Write(JsonUtils.GetJson(html, "dialog"));
            }
            Response.End();
            return;
            #endregion
        }

        else if (action == "cuxiaodetial")
        {
            string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/ajax_addCuxiaoDetial.aspx?id=" + Helper.GetInt(Request["id"], 0));
            Response.Clear();
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
            return;
        }
        else if (action == "guizedetail")
        {
            string html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/ajax_addguizeDetial.aspx?id=" + Helper.GetInt(Request["id"], 0) + "&typeid=" + Helper.GetInt(Request["typeid"], 0));
            Response.Clear();
            Response.Write(JsonUtils.GetJson(html, "dialog"));
            Response.End();
            return;
        }

        else if (action == "nocitysedit")//设置不显示快递公司
        {
            //id为快递公司id
            Response.Clear();
            if (Helper.GetInt(id, 0) > 0)
            {
                int cityid = Helper.GetInt(Request["cityid"], 0);
                string act =Helper.GetString(Request["act"], String.Empty);
                if (act == "no")//不送
                {
                    ActionHelper.Manager_SetNoCitys(cityid, Helper.GetInt(id, 0), true);
                    
                }
                else
                {
                    ActionHelper.Manager_SetNoCitys(cityid, Helper.GetInt(id, 0), false);
                }
            }
        }
        else if ("showbuy" == action && id != 0 && pageIndex != "")
        {
            string html = "<div class=\"guanbi\"><span style='float:right;width:35px;padding-right:20px;background:url(" + WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "upfile/Manager/i/bg-newbie-close.gif) no-repeat 100% 50%;*background-position:100% 45%;color:#2f2f2f;cursor:pointer;font-weight:normal;' onclick=\"return X.boxClose();\"  id=\"order-pay-dialog-close\">关闭</span></div><iframe width='700px' style='background_color:#FFFFFF;height:500px;' frameborder='0' src=\"" + Page.ResolveUrl(PageValue.WebRoot + "manage/ajaxPage/showorder.aspx?Id=" + Helper.GetInt(id, 0) + "&pageIndex=" + Helper.GetInt(pageIndex, 0) + "\"></iframe></font>");
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
        
    }
</script>
