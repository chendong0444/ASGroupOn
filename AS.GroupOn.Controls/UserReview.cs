using System;
using System.Collections.Generic;
using System.Text;
using System.Collections.Specialized;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.Domain;
using AS.GroupOn.App;
using AS.Common.Utils;
using System.Web;

namespace AS.GroupOn.Controls
{
    public class UserReview
    {

        #region 用户发表商品评价操作
        /// <summary>
        /// 用户发表商品评价
        /// </summary>
        /// <param name="score">评分</param>
        /// <param name="comment">内容</param>
        /// <param name="userid">用户ID</param>
        /// <param name="teamid">项目ID</param>
        /// <param name="sysconfig">配置文件</param>
        /// <returns></returns>
        public static string User_ReView(int score, string type, string comment, int userid, int teamid, NameValueCollection sysconfig)
        {
            string error = String.Empty;
            //处理过程判断内容是否为空，用户ID,项目ID是否大于0评论返现 flow表 action='review'
            //判断内容是否为空，项目ID，用户ID是否大于0
            if (comment.Trim() != "" && userid > 0 && teamid > 0)
            {
                //1.该用户是否购买过这个项目，如果购买进行，下一步判断,否则退出操作]
                int cnt =0;
                OrderFilter of = new OrderFilter();
                ITeam team = Store.CreateTeam();
                IUserReview userreview = Store.CreateUserReview();
                IList<IUserReview> listreview = null;
                IUser userinfo = Store.CreateUser();
                of.TeamOr = teamid;
                of.StateIn = "'pay','scorepay'";
                of.User_id = userid;
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                   cnt = seion.Orders.GetUnpay(of);
                }
                if (cnt > 0)
                {

                    decimal price = 0;
                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        team = seion.Teams.GetByID(teamid);
                    }

                    if (team != null)
                    {
                        price = Helper.GetDecimal(team.commentscore, 0);//买家评论返利金额根据项目来
                    }
                    if (price == 0)
                    {
                        if (sysconfig["userreview_rebate"] != null && sysconfig["userreview_rebate"].ToString().Trim() != "")
                        {
                            price = Convert.ToDecimal(sysconfig["userreview_rebate"].ToString());
                        }
                    }
                    bool result = false;
                    //2.该用户是否参与评论过，如果没有评论则进行下一步操作，否则退出操作
                    UserReviewFilter userReviewf = new UserReviewFilter();
                    userReviewf.user_id = userid;
                    userReviewf.team_id = teamid;
                    userReviewf.AddSortOrder(UserReviewFilter.ID_DESC);
                    userReviewf.pidisnull = 0;
                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        listreview = seion.UserReview.GetList(userReviewf);
                    }
                    if (listreview == null || listreview.Count <= 0)
                    {
                        if (!(sysconfig["UserreviewYN"] != null && sysconfig["UserreviewYN"].ToString().Trim() == "1"))
                        {
                            result = true; //true自动 false 手动
                        }

                        userreview.comment = HttpUtility.HtmlEncode(comment);
                        userreview.user_id = userid;
                        userreview.team_id = teamid;
                        userreview.score = score;
                        userreview.type = type;
                        userreview.create_time = DateTime.Now;
                        if (result)
                        {
                            userreview.rebate_price = price;
                            userreview.rebate_time = System.DateTime.Now;
                            userreview.admin_id = 0;
                            userreview.state = 1;

                        }
                        try
                        {
                            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                seion.UserReview.Insert(userreview);
                            }
                            sysconfig = new NameValueCollection();
                            //3.判断返利金额
                            //是否为手动

                            if (result)
                            {
                                //3.1更新用户表

                                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    userinfo = seion.Users.GetByID(userid);
                                }
                                if (userinfo != null)
                                {
                                    userinfo.Money += price;

                                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        seion.Users.UpdateMoney(userinfo);
                                    }
                                }
                                //3.2先查找刚增加的买家评论ID
                                int id = 0;
                                UserReviewFilter urf = new UserReviewFilter();
                                urf.team_id = teamid;
                                urf.user_id = userid;
                                IFlow flow = Store.CreateFlow();

                                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    id = seion.UserReview.GetTop1Id(urf);
                                }

                                if (id > 0)
                                {
                                    //3.3增加消费记录
                                    flow.Detail_id = id.ToString();
                                    flow.Action = "review";
                                    flow.Direction = "income";
                                    flow.User_id = userid;
                                    flow.Money = price;
                                    flow.Create_time = DateTime.Now;
                               
                                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        seion.Flow.Insert(flow);
                                    }
                                }

                            }


                            error = "";
                        }
                        catch (Exception e)
                        {

                            error = "评论失败";
                        }

                    }
                    else
                    {
                        error = "已参与过评论";
                    }
                }
                else
                {
                    error = "没有购买过此项目";
                }
            }
            else
            {
                error = "内容为空";
            }
            return error;
        }

        #endregion


        #region 用户提交在线答疑
        /// <summary>
        /// 用户提交在线答疑
        /// </summary>
        /// <param name="teamid">项目ID</param>
        /// <param name="userid">用户ID</param>
        /// <param name="content">答疑问题</param>
        /// <returns></returns>
        public static string User_SubmitAsk(int teamid, int userid, int cityid, string content)
        {
            IUser usermodel = Store.CreateUser();
            ITeam teammodel = Store.CreateTeam();
            IAsk askmodel = Store.CreateAsk();
            string error = String.Empty;
            if (content.Trim().Length > 0)
            {

                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    usermodel = seion.Users.GetByID(userid);
                }

                if (usermodel == null)
                {
                    error = "非法提交信息";
                }
                else
                {

                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        teammodel = seion.Teams.GetByID(teamid);
                    }
                    if (teammodel == null)
                    {
                        error = "不存在此项目";
                    }
                    else
                    {
                        askmodel.User_id = userid;
                        askmodel.Team_id = teamid;
                        askmodel.City_id = cityid;
                        askmodel.Content = content;
                        askmodel.Create_time = DateTime.Now;
                        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            seion.Ask.Insert(askmodel);
                        }

                    }
                }
            }
            else
            {
                error = "咨询内容不能为空";
            }


            return error;
        }
        #endregion




    }
}
