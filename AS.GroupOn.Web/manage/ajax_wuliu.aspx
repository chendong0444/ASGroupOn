<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<script runat="server">
    private NameValueCollection _system = new NameValueCollection();
    protected void Page_Load(object sender, EventArgs e)
    {
        _system = AS.Common.Utils.WebUtils.GetSystem();
        if (Request["id"] != null && Request["kuai"] != null && Request["id"] != "" && Request["kuai"] != "")
        {
            string txt2 = Getkuai(Request["id"], Request["kuai"]);
            string message = "&nbsp;&nbsp;<a target='_blank' href='http://www.kuaidi100.com/chaxun?com=" + Request["id"] + "&nu=" + Request["kuai"] + "'>查不到物流信息？请点击此处试试</a>";
            if (txt2.IndexOf("查询无结果") >= 0 || txt2.IndexOf("快递key为空") >= 0)
            {

                if (txt2.IndexOf("快递key为空") >= 0 && Request["type"] != null)
                {
                    txt2 = "&nbsp;&nbsp;<a target='_blank' href='http://www.kuaidi100.com/openapi/api_2_02.shtml?typeid=0'>由于您没有申请快递key,请点击此处申请</a><br/>" + message;
                }
                else
                {
                    if (txt2.IndexOf("快递key为空") >= 0)
                    {
                        txt2 = message;
                    }
                    else
                    {
                        txt2 = txt2 + message;
                    }
                }
            }
            Response.Clear();
            OrderedDictionary list = new OrderedDictionary();
            list.Add("html", txt2);
            list.Add("id", "wu");
            Response.Write(AS.Common.Utils.JsonUtils.GetJson(list, "updater"));
            Response.End();
        }

    }
    public string Getkuai(string code, string kuaidi)
    {
        string apikey = String.Empty;
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("<table style='width:100%;margin-left:14px;'>");
        if (_system != null && _system["kuaidikey"] != null && _system["kuaidikey"].ToString() != "")
            apikey = _system["kuaidikey"].ToString();
        if (apikey.Length <= 0)
        {
            sb.Append("快递key为空");
        }
        else
        {
            try
            {
                System.Xml.XmlDocument xmldoc = new System.Xml.XmlDocument();
                xmldoc.Load("http://api.kuaidi100.com/api?id=" + apikey + "&com=" + code + "&nu=" + kuaidi + "&show=1&muti=1&order=desc");
                System.Xml.XmlNodeList node = xmldoc.SelectNodes("/xml/data");
                System.Xml.XmlNode err_node = xmldoc.SelectSingleNode("/xml/message");
                if (node.Count != 0)
                {
                    sb.Append("<tr><td width='40%'>时间</td><td>内容</td></tr>");
                    foreach (System.Xml.XmlNode xns in node)
                    {
                        sb.Append("<tr><td width='40%'>" + xns.ChildNodes[0].InnerText + "</td><td width='60%'>" + xns.ChildNodes[1].InnerText + "</td></tr>");
                    }
                }
                else
                {
                    sb.Append("<tr><td width='40%' style='color:red'>" + err_node.ChildNodes[0].InnerText + "</td></tr>");
                    sb.Append("<tr><td width='40%' style='color:red'>查询无结果</td></tr>");
                }
            }
            catch
            {
                sb.Append("<tr><td width='40%' style='color:red'>查询无结果</td></tr>");
            }
            sb.Append("</table>");
        }
        return sb.ToString();
    }
    </script>