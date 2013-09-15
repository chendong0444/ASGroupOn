<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
    protected IPagers<IVote_Question> pager = null;
    protected string pagerHtml = String.Empty;
   protected IList<IVote_Feedback_Question> ilistvofq = null;
   protected  Vote_Feedback_QuestionFilters vofqf = new Vote_Feedback_QuestionFilters();
  protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_ProblemFeedBack_List))
        {
            SetError("你不具有查看反馈列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (!IsPostBack)
        {
            fanKui();
        }
    }
  private void fanKui()
  {
      StringBuilder sb1 = new StringBuilder();
      sb1.Append("<tr >");
      sb1.Append("<th width='10%'>ID</th>");
      sb1.Append("<th width='30%'>标题</th>");
      sb1.Append("<th width='15%'>反馈(人次)</th>");
      sb1.Append("<th width='10%'>状态</th>");
      sb1.Append("<th width='10%'>排序</th>");
      sb1.Append("<th width='25%'>操作</th>");
      sb1.Append("</tr>");
      //调查问卷人员回答的问题
      
      
      //调查问卷问题

      StringBuilder sb2 = new StringBuilder();
      Vote_QuestionFilters voqf = new Vote_QuestionFilters();
      IList<IVote_Question> ilistvoqf = null;
      
      voqf.IsShow = 1;
      voqf.PageSize = 30;
      voqf.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
      voqf.AddSortOrder(Vote_QuestionFilters.ID_DESC);
      using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
      {
          pager = session.Vote_Question.GetPager(voqf);
      }
      ilistvoqf = pager.Objects;
       if (ilistvoqf != null && ilistvoqf.Count > 0)
      {
          int i = 0;
          foreach(IVote_Question voqtmodel in ilistvoqf)
          {
             if (i % 2 != 0)
              {
                  sb1.Append("<tr>");
              }
              else
              {
                  sb1.Append("<tr class='alt'>");
              }
              sb1.Append("<td >" + voqtmodel.id + "</td>");
              sb1.Append("<td >" + voqtmodel.Title + "</td>");
              vofqf.Question_ID = voqtmodel.id;
              using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
              {
                  ilistvofq = session.Vote_Feedback_Question.GetList(vofqf);
              }
               if(ilistvofq.Count>=0)
              {
                  sb1.Append("<td >" + ilistvofq.Count + "(人次)</td>");
              }
              else
              {
                  sb1.Append("<td >0(人次)</td>");
              }
              if (Convert.ToInt32(voqtmodel.is_show.ToString()) == 1)
              {
                  sb1.Append("<td >显示</td>");
              }
              else
              {
                  sb1.Append("<td >隐藏</td>");
              }
              sb1.Append("<td >" + voqtmodel.order + "</td>");
              sb1.Append("<td ><a href='Diaocha_Fankui_Xiangqing.aspx?xiangqing=" + voqtmodel.id + "&title=" + voqtmodel.Title + "'>详情</a></td>");
              sb1.Append("</tr>");
              i++;
          }
      }

      Literal1.Text = sb1.ToString();
      Literal2.Text = sb2.ToString();
      pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, "DiaoCha_Fankui.aspx?&page={0}");
  }
</script>
<%LoadUserControl("_header.ascx", null); %>

<body class="newbie">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                   <div id="content" class="coupons-box clear mainwide">
		<div class="box clear">
            
            <div class="box-content">
                <div class="head" style="height:35px;">
                    <h2>调查中的问题列表</h2>
                    <div class="search">
					<ul class="filter">
						<li><a href="DiaoCha_SumPage.aspx">全部问题列表</a></li>
						<%--<li><a href="Diaocha_Fankui_Xiangqing.aspx?action=list">详细反馈列表</a></li>--%>
					</ul>
                    </div>
				</div>
                <div class="sect">
					<table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                        <asp:Literal ID="Literal1" runat="server"></asp:Literal><asp:Literal ID="Literal2" runat="server"></asp:Literal><tr><td colspan="8" style="height: 66px">
                        <ul class="paginator">
                       <li class="current">
                            <%=pagerHtml%>
                        </li></ul>
                        </td>
                        </tr>
                    </table>
				</div>
			</div>
          
        </div>
    </div>
                </div>
            </div>
        </div>
    </div>
</body>
<%LoadUserControl("_footer.ascx", null); %>
