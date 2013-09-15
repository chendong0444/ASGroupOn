<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>

<script runat="server">
    private NameValueCollection _system = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断用户失效！
        NeedLogin();
        #region 产品评论
        if (Request.QueryString["uid"] != null && Request.QueryString["uid"].ToString() != "" && Request.QueryString["id"] != null && Request.QueryString["id"].ToString() != "" && (Request.QueryString["pid"] == null || Request.QueryString["pid"].ToString() == ""))
        {
            string val = String.Empty;
            if (Request.QueryString["content"] != null && Request.QueryString["content"].ToString() != "")
            {
                string contents = Request.QueryString["content"].ToString();
                if (Request.QueryString["content"].ToString().Length > 2000)
                {
                    SetError("输入的字符不能大于2000，您输入的字符过长，请重新输入！");
                }
                else if (contents.Contains("<") || contents.Contains(">"))
                {
                    string str = "<script>alert('输入了带有安全隐患的字符，请重新评论！')</";
                    str += "script>";
                    Response.Write(str);
                }
                else
                {
                    _system = new NameValueCollection();
                    _system = WebUtils.GetSystem();
                    string result = ActionHelper.User_ReView(0, "team", Request.QueryString["content"].ToString(), Convert.ToInt32(Request.QueryString["uid"].ToString()), Convert.ToInt32(Request.QueryString["Id"].ToString()), _system);
                    if (result == "")
                    {
                        SetSuccess("提交成功");
                    }
                    else
                    {
                        SetError(result);
                    }

                    Response.Write(JsonUtils.GetJson(val, "refresh"));
                }
            }
            else
            {
                val = WebUtils.LoadPageString(WebRoot + "ajaxpage/ajax_dialog_comments.aspx?uid=" + Request.QueryString["uid"].ToString() + "&id=" + Request.QueryString["id"].ToString() + "");
                Response.Write(JsonUtils.GetJson(val, "dialog"));
            }
        }
        #endregion

        #region  商户评论
        else if (Request.QueryString["uid"] != null && Request.QueryString["uid"].ToString() != "" && Request.QueryString["id"] != null && Request.QueryString["id"].ToString() != "" && Request.QueryString["pid"] != null && Request.QueryString["pid"].ToString() != "")
        {
            string val = String.Empty;
            if (Request.QueryString["content"] != null && Request.QueryString["content"].ToString() != "" && Request.QueryString["score"].ToString() != "" && Request.QueryString["score"] != null && Request.QueryString["isgo"] != null && Request.QueryString["isgo"].ToString() != "")
            {
                //脚本语言，div 
                string contents = Request.QueryString["content"].ToString();

                int score = int.Parse(Request.QueryString["score"].ToString());
                string isGo = Request.QueryString["isgo"].ToString();
                if (Request.QueryString["content"].ToString().Length > 2000)
                {
                    SetError("输入的字符不能大于2000，您输入的字符过长，请重新输入！");
                }
                else if (contents.Contains("<") || contents.Contains(">"))
                {
                    SetError("输入了带有安全隐患的字符，请重新评论！");
                }

                else if (score != 0 && score != 50 && score != 100)
                {
                    SetError("选择错误，请重新选择！");
                }
                else if (isGo != "0" && isGo != "1")
                {
                    SetError("选择错误，请重新选择！");
                }
                else
                {
                    _system = new NameValueCollection();
                    _system = WebUtils.GetSystem();
                    string result = ActionHelper.User_ReViewP(score, int.Parse(isGo), "partner", Request.QueryString["content"].ToString(), Convert.ToInt32(Request.QueryString["uid"].ToString()), Convert.ToInt32(Request.QueryString["pid"].ToString()), Convert.ToInt32(Request.QueryString["id"].ToString()), _system);
                    if (result == "")
                    {
                        SetSuccess("提交成功");
                    }
                    else
                    {
                        SetError(result);
                    }
                    Response.Write(JsonUtils.GetJson(val, "refresh"));
                }
            }
            else
            {
                val = WebUtils.LoadPageString(WebRoot + "ajaxpage/ajax_dialog_comments.aspx?id=" + Request.QueryString["id"] + "&uid=" + Request.QueryString["uid"].ToString() + "&pid=" + Request.QueryString["pid"].ToString());
                Response.Write(JsonUtils.GetJson(val, "dialog"));
            }
        }
        #endregion
        else
        {
            Response.Write(JsonUtils.GetJson("您还没有登录或登录超时，请重新登录！", "alert"));
            return;
        }
    }
</script>