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
    protected string ad = String.Empty;
    protected int cityid = 0;
    protected bool show = false;
    protected IList<ILocation> loction = null;
    protected LocationFilter filter = new LocationFilter();
    public override void UpdateView()
    {
        int cityid = 0;
        if (CurrentCity != null)
            cityid = CurrentCity.Id;
        ad = Getimg(cityid.ToString());

    }
    public override string CacheKey
    {
        get
        {
            string key = "cacheusercontrol-adleft-";
            if (CurrentCity != null)
                key = key + CurrentCity.Id;
            else
                key = key + 0;
            return key;
        }
    }
    public override bool CanCache
    {
        get
        {
            return true;
        }
    }
    public string Getimg(string cityid)
    {
        StringBuilder sb = new StringBuilder();
        if (cityid != "0") filter.Cityid = "," + cityid + ",";
        filter.Location = 2;
        filter.visibility = 1;
        filter.To_Begintime = DateTime.Now;
        filter.From_Endtime = DateTime.Now;
        filter.height = "0";
        using (IDataSession session = Store.OpenSession(false))
        {
            loction = session.Location.GetList(filter);
        }
        if (loction != null && loction.Count > 0)
        {
            foreach (var item in loction)
            {
                if (item.image != null)
                {
                    if (item.type == 0)
                    {
                        sb.Append("<div class=\"sbox side-business\">");
                        sb.Append("<div class=\"\">");
                        sb.Append("<div class=\"advertising\">");
                        sb.Append(item.decpriction);
                        sb.Append("<a href='" + item.pageurl + "' target='_blank'><img src='" + item.image + "'></a>");
                        sb.Append("</div></div></div>");
                    }
                    else if (item.type == 1)
                    {
                        sb.Append("<div class=\"sbox side-business\">");
                        sb.Append("<div class=\"\">");
                        sb.Append("<div class=\"advertising\">");
                        sb.Append(item.decpriction);
                        if (item.pageurl != "")
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
<%=ad %>