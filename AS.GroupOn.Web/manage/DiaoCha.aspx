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
  protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TJ_ProblemFeedBack))
        {
            SetError("你不具有查看调查统计的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        getDiaoCha();
    }
  private void getDiaoCha()
  {
      //当天的时间
      StringBuilder sb2 = new StringBuilder();
      IList<IVote_Feedback> ilistvofb = null;
      Vote_FeedbackFilters vofb = new Vote_FeedbackFilters();
      vofb.Fromadd_time =Helper.GetDateTime(System.DateTime.Today.ToString(),DateTime.Now);
      vofb.Toadd_time = Helper.GetDateTime(System.DateTime.Today.ToString("yyyy-MM-dd") + " 23:59:59", DateTime.Now);
      using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
      {
          ilistvofb = session.Vote_Feedback.GetList(vofb);
      }
      IList<IVote_Feedback> ilistvofb1 = null;
      Vote_FeedbackFilters vofb1 = new Vote_FeedbackFilters();
      using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
      {
          ilistvofb1 = session.Vote_Feedback.GetList(vofb1);
      }
      Vote_QuestionFilters voqt = new Vote_QuestionFilters();
      IList<IVote_Question> ilistvoqt = null;
      voqt.IsShow = 1;
      using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
      {
          ilistvoqt = session.Vote_Question.GetList(voqt);
      }
      Vote_QuestionFilters voqt1 = new Vote_QuestionFilters();
      IList<IVote_Question> ilistvoqt1 = null;
      using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
      {
          ilistvoqt1 = session.Vote_Question.GetList(voqt1);
      }
      
      
      
      StringBuilder sb1 = new StringBuilder();
      sb1.Append("<div style='margin:0 20px;'>");
      sb1.Append("<p>今日接受调查人次：" +ilistvofb.Count + "</p>");
      sb1.Append("<p>全部接受调查人次：" + ilistvofb1.Count + "</p>");
      sb1.Append("</div>");
      sb2.Append("<div style='margin:0 20px;'>");
      sb2.Append("<p>正在调查问题数：" + ilistvoqt.Count + "</p>");
      sb2.Append("<p>全部调查问题数：" + ilistvoqt1.Count + "</p>");
      sb2.Append("</div>");
      Literal1.Text = sb1.ToString();
      Literal2.Text = sb2.ToString();

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
                    <h2>首页 </h2>
				   
				</div>
                <div class="sect">
					<div class="wholetip clear"><h3>反馈数据</h3></div>
                    <asp:Literal ID="Literal1" runat="server"></asp:Literal>
					

					<div class="wholetip clear"><h3>问题数据</h3></div>
                    <asp:Literal ID="Literal2" runat="server"></asp:Literal>
					
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
