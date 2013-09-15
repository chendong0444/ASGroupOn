<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>


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
    public string Names = "";
    public string No = "";
    public string Users = "";
    public int pid = 0;
    protected ISystem system = Store.CreateSystem();
    protected IPartner pbmodel = Store.CreatePartner();
    protected decimal Ymoney=0;
    protected decimal Smoney=0;
    protected decimal Ssale=0;
    protected Partner_DetailFilter pardefilter = new Partner_DetailFilter();
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
           base.OnLoad(e);
      
        pid = Helper.GetInt(CookieUtils.GetCookieValue("partner",key), 0);
        pardefilter.partnerid = pid;
        pardefilter.settlementstate = 8;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pbmodel = session.Partners.GetByID(pid);
            system = session.System.GetByID(1);
            Ymoney = session.Partner_Detail.exts_sp_GetPMoney(pid);
            Smoney = session.Partner_Detail.getRealSettle(pardefilter);
            Ssale = session.Partner_Detail.GetActualPMoney(pid);
        }
        
        Names = pbmodel.Bank_name;
        No = pbmodel.Bank_no;
        Users = pbmodel.Bank_user;

    }
</script>

<%LoadUserControl("_header.ascx", null); %>
<body>
<form id="form1" runat="server" method="post">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
  <div id="doc">
        
        <script src="../upfile/js/datePicker/WdatePicker.js" type="text/javascript"></script>
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                             <div class="box-content">
                            <div class="head">
                            <h2>结算信息</h2>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <div class="shjs_left">
                                            应 结 算:</div>
                                        <div class="shjs_right">
                                            <%=system.currency + Ymoney%></div>
                                    </div>
                                    <div class="field">
                                        <div class="shjs_left">
                                            实际结算:</div>
                                        <div class="shjs_right">
                                            <%=system.currency + Smoney%></div>
                                    </div>
                                    <div class="field">
                                        <div class="shjs_left">
                                            实际卖出:</div>
                                        <div class="shjs_right">
                                            <%=system.currency + Ssale%></div>
                                    </div>
                                    <br />
                                    <div id="shjs_list2" class="field">
                                        <div class="shjs_left">
                                            开 户 行 :</div>
                                        <div class="shjs_right">
                                            <%=Names%></div>
                                    </div>
                                    <br />
                                    <div id="shjs_list2" class="field">
                                        <div class="shjs_left">
                                            开 户 名：</div>
                                        <div class="shjs_right">
                                            <%=Users%></div>
                                    </div>
                                    <br />
                                    <div id="shjs_list2" class="field">
                                        <div class="shjs_left">
                                            银行账号:</div>
                                        <div class="shjs_right">
                                            <%=No%></div>
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