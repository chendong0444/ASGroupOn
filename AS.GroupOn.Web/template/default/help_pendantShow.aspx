<%@ Page Language="C#" AutoEventWireup="true"  Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<script runat="server">
    protected string type = "";
    protected string strBg = "";
    protected string strHeight = "";
    protected string strHeightsimpe = "";
    protected string strWidth = "";
    protected string strHeight1 = "";
    protected string strHeight2 = "";
    protected ITeam  team = null;
    protected TeamFilter filter = new TeamFilter();
    protected IList<ICategory> categoryList = null;
    protected CategoryFilter categoryfilter = new CategoryFilter(); 
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (ASSystem.title == String.Empty)
        {
            AS.GroupOn.Controls.PageValue.Title = "团购达人";
        }
        if (!Page.IsPostBack)
        {
            string cityid = "";
            if (Request["cityid"] != null && Request["cityid"].ToString() != "")
            {
                cityid = Request["cityid"].ToString();
            }
            if (Request["stype"] != null && Request["stype"].ToString() != "")
            {
                type = Request["stype"].ToString();
                if (type == "1")
                {
                    p1.Visible = true;
                    p2.Visible = false;
                    p3.Visible = false;
                }
                if (type == "2")
                {
                    p1.Visible = false;
                    p2.Visible = true;
                    p3.Visible = false;
                }

                if (type == "3")
                {
                    p1.Visible = false;
                    p2.Visible = false;
                    p3.Visible = true;
                }

            }
            if (Request["bg"] != null && Request["bg"].ToString() != "")
            {
                string bg = Request["bg"].ToString();
                if (bg == "0" || bg == "4")
                {
                    strBg = "#FF6600";
                }

                if (bg == "1" || bg == "5")
                {
                    strBg = "#A8C5EE";
                }

                if (bg == "2" || bg == "6")
                {
                    strBg = "#FFC690";
                }

                if (bg == "3" || bg == "7")
                {
                    strBg = "#000000";
                }
            }
            else
            {
                strBg = "#FF6600";
            }


            if (Request["height"] != null && Request["height"].ToString() != "")
            {
                strHeight = Request["height"].ToString();
                strHeightsimpe = Request["height"].ToString();
            }
            else
            {
                strHeight = "360";
                strHeightsimpe = "365";
            }
            if (Request["width"] != null && Request["width"].ToString() != "")
            {
                strWidth = Request["width"].ToString();
            }
            else
            {
                strWidth = "224";
            }

            strHeight1 = Convert.ToString(int.Parse(strHeight) - 60);
            strHeight2 = Convert.ToString(int.Parse(strHeightsimpe) - 20);
        }

        int citid = 0;
        if (Request["cityid"] != null && Request["cityid"].ToString() != "")
        {
            citid = AS.Common.Utils.Helper.GetInt(Request["cityid"], 0);
        }
        else
        {
            citid = AS.Common.Utils.Helper.GetInt(Request.Form["switchcity"], 0);
        }
       
        if (citid == 0)
        {
            string sql1 = "select * from (select top 1 * from team where  Begin_time<='" + DateTime.Now.ToString() + "' and End_time>='" + DateTime.Now.ToString() + "'  order by  sort_order desc,id asc) as t1  ";

            filter.ToBegin_time = DateTime.Now;
            filter.FromEndTime = DateTime.Now;
            filter.AddSortOrder(" sort_order desc,id asc ");
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
            {
                team = session.Teams.Get(filter);
            }
        }
        else
        {
            string sql2 = "select * from (select top 1 * from team where (City_id=" + citid + " or city_id=0) and  Begin_time<='" + DateTime.Now.ToString() + "' and End_time>='" + DateTime.Now.ToString() + "'  order by  sort_order desc ,id asc ) as t1 ";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                team = session.Teams.Get(filter);
            }
        }
        categoryfilter.Zone = "city";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
        {
            
            categoryList = session.Category.GetList(categoryfilter);
        }
        
    }
    </script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">

<title></title>


    <style type="text/css">
        #switchcity
        {
            width: 78px;
        }
        #Select2
        {
            width: 78px;
        }
    </style>


</head>
<body style="margin:0px;background:#fff">
<script type="text/javascript" language="javascript">
    $(document).ready(function () {
        $("#switchcity").change(function () {
            var cityid = $(this).val();
            var swidth = $("#showWidth").val();
            var bg = $("#bgcolor").val();
            var sheight = $("#showHeight").val();

            window.location.href = "pendantShow.aspx?stype=1&&bg=&&width=&&height=&&cityid=" + cityid;
        });

        $("#Select2").change(function () {
            var cityid = $(this).val();
            var swidth = $("#showWidth").val();
            var bg = $("#bgcolor").val();
            var sheight = $("#showHeight").val();

            window.location.href = "pendantShow.aspx?stype=2&&bg=&&width=&&height=&&cityid=" + cityid;
        });
    });

</script>
<form id="form1" runat="server">
<input type="hidden" id="bgcolor" value="<%=strBg%>" />
<input type="hidden" id="showWidth" value="<%=strWidth%>" />
<input type="hidden" id="showHeight" value="<%=strHeight%>" />
        <asp:Panel ID="p1" runat="server">
             <div style="background: none repeat scroll 0% 0%;background-color:<%=strBg%>;border: 2px solid <%=strBg%>; color: rgb(255, 255, 255);height:<%=strHeight%>px; font-size:12px">
			      <div style="float: left; padding-left: 5px; width: 148px;"> 切换城市:
                  <select id="switchcity" name="switchcity" >
				           <% foreach (ICategory item in categoryList)
                               {%>
                                   <option value="<%=item.Id %>"
                                   <% if(Convert.ToInt32(Request["switchcity"])==item.Id){ %>
                                   selected="selected"<%} %>><%=item.Name %></option>
                               <%} %>
                    </select>
		          </div>
			     <%if (team != null)
                { %>
			    <div style="float: right;">
			      <a href="<%=AS.GroupOn.Controls.PageValue.WebRoot%>template/default/Team_view.aspx?id=<%=team.Id%>" target="_blank">
                  <img height="30" border="0" width="70" src="<%=AS.GroupOn.Controls.PageValue.WebRoot%>upfile/css/i/btn_buy.png"/></a>
			    </div>
			    <div style="clear: both; background: none repeat scroll 0% 0% rgb(255, 255, 255); padding: 5px; color: rgb(0, 0, 0); 
					height:<%=strHeight1%>px;overflow: hidden;">
			  	    <p style="font-size: 16px; font-family: 黑体;">今日团购:<%=team.Title%></p>
				     <p><img w="<%=(AS.Common.Utils.Helper.GetInt(strWidth,100)-10) %>" src="<%=team.Image %>"/></p>
                       <p>已有<%=team.Now_number%>人购买<br>
				        剩余时间：<span ID="time"> <%if ((team.End_time - DateTime.Now).Days > 0)
                          { %><%=(team.End_time - DateTime.Now).Days%>天<%=(team.End_time - DateTime.Now).Hours%>小时<%=(team.End_time - DateTime.Now).Minutes%>分钟 
                           <%}
                          else
                          { %><%=(team.End_time - DateTime.Now).Hours%>小时<%=(team.End_time - DateTime.Now).Minutes%>分钟<%=(team.End_time - DateTime.Now).Seconds%>秒 
                           <%} %></span>
                           <br/>
                           原价:<%=team.Market_price%>元<br/> 折扣:<%=AS.Common.Utils.WebUtils.GetDiscount(AS.Common.Utils.Helper.GetDecimal(team.Market_price, 0), AS.Common.Utils.Helper.GetDecimal(team.Team_price, 0))%>折<br/> 
                           现价:<%=team.Team_price%>元<br/> 节省:<%=team.Market_price - team.Team_price%>元<br/>
					    </p>
			      </div>
			    <div>
			    <div style="float: left; ">
                    <a href="<%=AS.GroupOn.Controls.PageValue.WebRoot%>index.aspx" target="_blank" style="text-decoration:none"><font color="white"><%=ASSystem.sitename %></font></a>
                </div>
				<div style="text-align: right;">
                <a href="<%=AS.GroupOn.Controls.PageValue.WebRoot%>template/default/team_view.aspx?id=<%=team.Id %>" target="_blank" style="text-decoration:none"><font color="white">查看详情&gt;&gt;</font></a>
                </div>
				<div style="clear: both;"></div>
			  </div>
            <%} %>
			</div>
        </asp:Panel>

        <asp:Panel ID="p2" runat="server">
            <div style="background: none repeat scroll 0% 0%;background-color:<%=strBg%>;border: 2px solid <%=strBg%>; color: rgb(255, 255, 255);height:<%=strHeight%>px;overflow: hidden; ">
			         <%if (team != null)
                    { %>
                  <div style="display:none" id="Div2">551093</div>
			      <div style="clear: both; background: none repeat scroll 0% 0% rgb(255, 255, 255); padding: 5px; color: rgb(0, 0, 0); 
					    height:<%=strHeight2%>px		  ">
			  	    <p style="font-size: 12px; font-family: 黑体;"><%=ASSystem.sitename %>团购
                    <select id="Select2" name="Select2">
                        <% foreach (ICategory item in categoryList)
                                           {%>
                                               <option value="<%=item.Id %>"
                                               <% if(Convert.ToInt32(Request["Select2"])==item.Id){ %>
                                               selected="selected"<%} %>><%=item.Name %></option>
                                           <%} %>
                        </select>:<%=team.Title%></p>
                     <p>            
			         <a href="<%=getTeamPageUrl(team.Id)%>" target="_blank">
                      <img height="30" border="0" width="70"  src="<%=AS.GroupOn.Controls.PageValue.WebRoot%>upfile/css/i/btn_buy.png" /></a>
                      <a style="font-size:12px;text-decoration:none;" href="<%=getTeamPageUrl(team.Id)%>" target="_blank">查看详情&gt;&gt;</a>
                      </p>
                 
				    <p><img width="<%=(AS.Common.Utils.Helper.GetInt(strWidth,100)-10) %>" src="<%=team.Image %>"/></p>
			      </div>
                    <%} %>
			</div>
        </asp:Panel>

        <asp:Panel ID="p3" runat="server">
            <div style="background: none repeat scroll 0% 0%;border: 2px solid ; color: rgb(255, 255, 255);height:<%=strHeight%>px;">
			     <%if (team != null)
                { %>
			  <div style="clear: both; background: none repeat scroll 0% 0% rgb(255, 255, 255); padding:5px; color: rgb(0, 0, 0); 
					height:<%=strHeight%>px		  ">
			  	<p style="font-size: 12px; font-family: 黑体;"><%=ASSystem.sitename %>团购:<%=team.Title%><a href="<%=AS.GroupOn.Controls.PageValue.WebRoot%>template/default/team_view.aspx?id=<%=team.Id %>"  target="_blank" style="text-decoration:none">查看详情&gt;&gt;</a>
                </p>
			  </div>
                <%} %>
		      </div>
            </asp:Panel>

</form>
</body>
</html>
