<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">
    protected int cityid = 0;
    protected bool show = false;
    protected IList<ILocation> dsloction = null;
    protected LocationFilter filter = new LocationFilter();
    public override void UpdateView()
    {
        if (CurrentCity != null)
            cityid = CurrentCity.Id;
        //得到团购首页广告对象集合
        dsloction = getAdd(0, 1, cityid.ToString());
    }
    public override string CacheKey
    {
        get
        {
            if (CurrentCity != null)
                cityid = CurrentCity.Id;
            return "cacheusercontrol-admid-" + cityid;
        }
    }
    public override bool CanCache
    {
        get
        {
            return true;
        }
    }
    /// <summary>
    /// 得到团购首页广告信息
    /// </summary>
    protected IList<ILocation> getAdd(int top, int type, string cityid)
    {
        if (cityid != "0") filter.Cityid = "," + cityid + ",";
        filter.Location = type;
        filter.visibility = 1;
        filter.To_Begintime = DateTime.Now;
        filter.From_Endtime = DateTime.Now;
        filter.AddSortOrder(LocationFilter.More_DESC);
        filter.height = "0";
        using (IDataSession session = Store.OpenSession(false))
        {
            dsloction = session.Location.GetList(filter);
        }
        return dsloction;
    }
</script>
<%if (dsloction != null && dsloction.Count > 0)
  {
%>
<%--<script src="<%=PageValue.WebRoot %>upfile/js/jquery.KinSlideshow-1.2.1.min.js" type="text/javascript"></script>
<script src="<%=PageValue.WebRoot %>upfile/js/jquery.toggle.js" type="text/javascript"></script>--%>
<div id="picBox">
    <ul id="show_pic" style="left: 0;">
        <%for (int i = 0; i < dsloction.Count; i++)
          {
              ILocation dr = dsloction[i];
        %>
        <li><a href="<%=dr.pageurl %>" target="_blank" style="outline-style: none; outline-width: medium">
            <img src="<%=dr.locationname %>" alt="<%=dr.width %>" width="995" height="90" /></a></li>
        <%
            } %>
    </ul>
   <ul id="icon_num">
        <%for (int i = 0; i < dsloction.Count; i++)
          {
           
        %>
        <li <%if(i==0){ %>class="active" <% } %>>
            <%=i+1 %></li>
        <%
            } %>
    </ul>
    <script type="text/javascript">
        //glide.layerGlide(true, 'icon_num', 'show_pic', 995, 3, 0.2, 'left');
        //$.st('#icon_num  > li', '#show_pic', { 'mode': 'slide', 'time': 3 });
    </script>
    
    <script type="text/javascript">
        // 轮播        
        var t = 0,
            imgIndex = 0,
            count;
        $(function () {
            count = $("#show_pic li a").length;
            $("#show_pic li a:not(:first-child)").hide();
            $("#icon_num li").click(function () {
                var i = $(this).text() - 1; //取Li元素内的值，即1，2，3，4
                imgIndex = i;
                showAuto()
            });
            t = setInterval(function () {
                imgIndex++;
                showAuto()
            }, 5000);
            $("#icon_num").hover(function () { clearInterval(t) }, function () {
                t = setInterval(function () {
                    imgIndex++;
                    showAuto()
                }, 5000);
            });
        });
        function showAuto() {
            imgIndex = (imgIndex >(count - 1)) ? 0 : imgIndex;
            var $li = $('#icon_num li').eq(imgIndex);
            $("#show_pic li").filter(":visible").fadeOut(200).parent().children().eq(imgIndex).fadeIn(200);

            document.getElementById("icon_num").style.background = "";
            var $ele = $("#icon_num li").eq(imgIndex);
            $ele.toggleClass("active");
            $ele.siblings().removeAttr("class");
        }
    </script>
</div>
<% 
    } %>
