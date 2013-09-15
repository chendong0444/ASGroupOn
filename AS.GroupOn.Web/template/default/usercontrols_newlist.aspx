<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

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
    public string cityid = "0";
    public string strhtml = "";
    protected IList<ILocation> loction = null;
    protected LocationFilter filter = new LocationFilter();
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (CurrentCity != null)
        {
            cityid = CurrentCity.Id.ToString();
        }
        if (Request["id"] != null)
        {
            GetContent(Helper.GetInt(Request["id"], 0));
        }
    }
    #region 根据编号，查询内容
    public void GetContent(int id)
    {
        INews newmodel = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            newmodel = session.News.GetByID(id);
        }
        if (newmodel != null)
        {
            strhtml = "<div class='news_header'><h1>" + newmodel.title + "</h1><p class='news_time'>" + newmodel.create_time.ToString(" yyyy-MM-dd ") + "</p></div>";
            strhtml += "<div class='news'>" + newmodel.content + "</div>";
            
        }
        else
        {
            Response.Redirect(GetUrl("新闻公告", "usercontrols_Morenewlist.aspx"));
        }

    }
    #endregion

    public string Getimg(string cityid)
    {
        StringBuilder sb = new StringBuilder();
        
        filter.Location = 2;
        filter.visibility = 1;
        if (cityid != "0")
        {
            filter.CityidS = cityid;
        }
        else
        {
            filter.To_Begintime = DateTime.Now;
            filter.From_Endtime = DateTime.Now;
        }
        filter.AddSortOrder(LocationFilter.More_DESC);
        
        using (IDataSession session = Store.OpenSession(false))
        {
            loction = session.Location.GetList(filter);
        }
        if (loction != null && loction.Count > 0)
        {
            foreach (ILocation item in loction)
            {
                if (item.image != "" && item.image!=null)
                {
                    if (item.type == 0)
                    {
                        sb.Append("<div class=\"sbox side-business\">");
                        sb.Append("<div class=\"\">");
                        sb.Append("<div class=\"advertising\">");
                        sb.Append(item.decpriction);
                        sb.Append("<a href='" + item.pageurl + "' target='_blank'><img src='" + item.image + "'></a>");
                    }
                    else if (item.type == 1)
                    {
                        sb.Append("<div class=\"sbox side-business\">");
                        sb.Append("<div class=\"\">");
                        sb.Append("<div class=\"advertising\">");
                        sb.Append(item.decpriction);
                        if (item.pageurl != ""|| item.pageurl!=null)
                            sb.Append("<embed src='" + item.pageurl + "' quality='high'  align='middle' allowScriptAccess='sameDomain' type='application/x-shockwave-flash'></embed>");
                        else
                            sb.Append("<embed src='" + item.image + "' quality='high'  align='middle' allowScriptAccess='sameDomain' type='application/x-shockwave-flash'></embed>");
                        sb.Append("</div></div></div>");
                    }

                }
                else
                {
                    if (item.height == "0")
                    {
                        sb.Append("<div class=\"sbox side-business\">");
                        sb.Append("<div class=\"\">");
                        sb.Append("<div class=\"advertising\">");
                        sb.Append(item.decpriction);
                        sb.Append("<a href='" + item.pageurl + "'>" + item.locationname + "</a>");
                        sb.Append("</div></div></div>");
                    }
                }
            }
        }
        return sb.ToString();
    }
</script>

<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div id="bdw">
    <div class="cf" id="bd">
        <div class="news_content">
            <%=strhtml %>
        </div>
        <div id="sidebar">
            <%=Getimg(cityid)%>
            <%LoadUserControl(PageValue.WebRoot + "UserControls/blockothers.ascx", null); %>
            <%LoadUserControl(PageValue.WebRoot + "UserControls/blockbulletin.ascx", null); %>
            <%LoadUserControl(PageValue.WebRoot + "UserControls/blockflv.ascx", null); %>
            <%LoadUserControl(PageValue.WebRoot + "UserControls/uc_NewList.ascx", null); %>
            <%LoadUserControl(PageValue.WebRoot + "UserControls/blockbusiness.ascx", null); %>
            <%LoadUserControl(PageValue.WebRoot + "UserControls/blocksubscribe.ascx", null); %>

        </div>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>