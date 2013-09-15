<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    
    protected NameValueCollection _system = new NameValueCollection();
    protected string strFLetter = "";
    protected string strBrand = "";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();

        GetWord();
        GetBrand();

    }
    private void GetBrand()
    {
        StringBuilder sb1 = new StringBuilder();
        for (int i = 65; i <= 90; i++)
        {
            char c = (char)i;

            IList<ICategory> catlist = null;
            CategoryFilter categoryfilter = new CategoryFilter();
            categoryfilter.Zone = "brand";
            categoryfilter.Letter = c.ToString();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                catlist = session.Category.GetList(categoryfilter);
            }
            if (catlist.Count > 0)
            {
                sb1.Append("<div class='clear'></div>");
                sb1.Append("<div class='gModuleCtn2'>");
                sb1.Append("<h4><div class='gml_tit1'> <ul class='tName'> ");
                sb1.Append("<li class='on'><a name='" + c + "'>&nbsp;[" + c + "]&nbsp;</a> <a onclick='scrolltotop.scrollup();' href='#' class='lnkGoTop'>返回顶部↑</a></li></ul> ");
                sb1.Append("</div> </h4>");
                sb1.Append("<div class='bdy'><ul class='bndNmLst'>");
                foreach (ICategory cat in catlist)
                {

                    if (PageValue.CurrentSystemConfig != null && PageValue.CurrentSystemConfig["MallTemplate"] != null && PageValue.CurrentSystemConfig["MallTemplate"].ToString() == "1")
                    {
                        sb1.Append("<li class=''><a href='" + GetTeamListPageUrl(0, 0, 0, cat.Id, 0, 0, 0, String.Empty) + "' target='_blank' title=" + cat.Name + "><img src='" + cat.content + "' alt=" + cat.Name + ">" + "</a></li>");
                    }
                    else
                    {

                        sb1.Append("<li class=''><a href='" + BaseUserControl.getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), 0, cat.Id, 0, "0", "0") + "' target='_blank' title=" + cat.Name + "><img src='" + cat.content + "' alt=" + cat.Name + ">" + "</a></li>"); 
                    }
                }
                sb1.Append("</ul><div class='clear'></div></div></div>");
            }


        }
        strBrand = sb1.ToString();

    }
    private void GetWord()
    {
        StringBuilder sb2 = new StringBuilder();
        for (int i = 65; i <= 90; i++)
        {
            char c = (char)i;
            sb2.Append("<li><a href='#" + c + "'>" + c);
            sb2.Append("</a></li>");
        }
        strFLetter = sb2.ToString();
    }
       
</script>

<%LoadUserControl("_htmlheader_mall.ascx", null); %>
<%LoadUserControl("_header_mall.ascx", null); %>
<script type="text/javascript" src="/upfile/js/srolltop.js"></script>
<script type="text/javascript">

    jQuery(function () {
        function b() {
            d.each(function () {
                typeof $(this).attr("original") != "undefined" && $(this).offset().top < $(document).scrollTop() + $(window).height() && $(this).attr("src", $(this).attr("original")).removeAttr("original")
            })
        }
        var d = $(".dynload");
        $(window).scroll(function () {
            b();

            jQuery('img[w]').each(function () {
                try {

                    var w = parseInt(jQuery(this).attr("w"));
                    var width = jQuery(this).width();
                    if (width > w) {
                        jQuery(this).css("width", w);
                    }
                }
                catch (e) { }
            });
        });
        b();

    });
</script>
<div id="bdw" class="bdw">
    <div id="shop_box" class="cf">
        <div class="brand_box">
            <!--品牌商城（开始）-->
            <div class="brdlst_tbly">
                <div class="brdlst_tb">
                    您现在的位置:&nbsp;&nbsp; <a href="<%=BaseUserControl.getMallPageUrl(Helper.GetString(_system["isrewrite"], "0")) %>">
                        <%=_system["mallsitename"]%></a><em>›</em> <a href="<%=BaseUserControl.getBrandPageUrl(Helper.GetString(_system["isrewrite"], "0")) %>">
                            <span class="lbrd_ltab">品牌大全</span></a>
                </div>
            </div>
            <ul class="tGud">
                <%=strFLetter %>
            </ul>
            <div class="clear">
            </div>
            <%= strBrand %>
        </div>
    </div>
</div>

<%LoadUserControl("_footer_mall.ascx", null); %>
<%LoadUserControl("_htmlfooter_mall.ascx", null); %>