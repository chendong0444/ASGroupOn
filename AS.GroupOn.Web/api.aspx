<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat="server">
    protected System.Data.DataTable teamtable = new System.Data.DataTable();
    protected string cityename = String.Empty;
    protected NameValueCollection Classes = new NameValueCollection();
    protected int top = 0; //显示的团购信息数量。0为全部显示
    protected int step = 1;//编号初始值 默认为1
    protected string[] ascitys = new string[0]; //项目为全国时输出的城市列表
    protected string[] ascitysen = new string[0];//项目为全国时输出的城市英文列表
    string contentType = "xml";
    protected override void OnLoad(EventArgs e)
    {

        Response.ContentType = "text/xml";
        string key = Helper.GetString(Request["key"], String.Empty);
        string code = Helper.GetString(Request["code"], String.Empty);
        string type = Helper.GetString(Request["type"], String.Empty);
        if (type == "txt")
        {
            Response.ContentType = "text/plain";
            contentType = "txt";
        }
        cityename = Helper.GetString(Request["city"], String.Empty);
        if (key != String.Empty)
        {
            string v = GetAPI(key);//.htm字符串
            Regex regex = new Regex(@"<catalogs>(.|\s)+?</catalogs>\r\n");
            Match match = regex.Match(v);
            v = regex.Replace(v, "");
            if (match.Success)
            {
                try
                {
                    System.Xml.XmlDocument xmldoc = new System.Xml.XmlDocument();
                    xmldoc.LoadXml(match.Value);
                    System.Xml.XmlNodeList nodelist = xmldoc.SelectNodes("/catalogs/catalog");
                    for (int i = 0; i < nodelist.Count; i++)
                    {
                        Classes.Add(nodelist[i].Attributes["name"].Value, nodelist[i].Attributes["value"].Value);
                    }
                }
                catch { }

            }

            regex = new Regex(@"<ascitys>(.|\s)+?</ascitys>\r\n");
            match = regex.Match(v);
            v = regex.Replace(v, "");
            if (match.Success)
            {
                try
                {
                    System.Xml.XmlDocument xmldoc = new System.Xml.XmlDocument();
                    xmldoc.LoadXml(match.Value);
                    System.Xml.XmlNode node = xmldoc.SelectSingleNode("/ascitys");
                    if (node.InnerText.Length > 0)
                    {
                        string val = node.InnerText;
                        ascitys = val.Split(',');
                    }
                }
                catch { }

            }



            regex = new Regex(@"<asencitys>(.|\s)+?</asencitys>\r\n");
            match = regex.Match(v);
            v = regex.Replace(v, "");
            if (match.Success)
            {
                try
                {
                    System.Xml.XmlDocument xmldoc = new System.Xml.XmlDocument();
                    xmldoc.LoadXml(match.Value);
                    System.Xml.XmlNode node = xmldoc.SelectSingleNode("/asencitys");
                    if (node.InnerText.Length > 0)
                    {
                        string val = node.InnerText;
                        ascitysen = val.Split(',');
                    }
                }
                catch { }

            }


            regex = new Regex(@"<top>(.|\s)+?</top>\r\n");
            match = regex.Match(v);
            v = regex.Replace(v, "");
            if (match.Success)
            {
                try
                {
                    System.Xml.XmlDocument xmldoc = new System.Xml.XmlDocument();
                    xmldoc.LoadXml(match.Value);
                    System.Xml.XmlNode node = xmldoc.SelectSingleNode("/top");
                    if (node != null)
                    {
                        top = Helper.GetInt(node.InnerText, 0);
                    }
                }
                catch { }
            }



            regex = new Regex(@"<step>(.|\s)+?</step>\r\n");
            match = regex.Match(v);
            v = regex.Replace(v, "");
            if (match.Success)
            {
                try
                {
                    System.Xml.XmlDocument xmldoc = new System.Xml.XmlDocument();
                    xmldoc.LoadXml(match.Value);
                    System.Xml.XmlNode node = xmldoc.SelectSingleNode("/step");
                    if (node != null)
                    {
                        step = Helper.GetInt(node.InnerText, 1);
                    }
                }
                catch { }
            }
            if (contentType == "xml")
            {
                if (code != "gb2312")
                {
                    Response.Write("<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n");

                }
                else
                {
                    Response.Write("<?xml version=\"1.0\" encoding=\"GB2312\"?>\r\n");
                    Response.HeaderEncoding = System.Text.Encoding.GetEncoding("GB2312");
                    Response.ContentEncoding = System.Text.Encoding.GetEncoding("GB2312");
                }
            }
            ConvertAPI(v);
            // Response.Write(ConvertAPI(v));

        }
        Response.End();
    }

    /// <summary>
    /// 根据key找到.htm 先去缓存里去找，没有找到放入缓存
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    private string GetAPI(string name)
    {
        string val = String.Empty;
        if (name == String.Empty)
            return val;
        object obj = HttpContext.Current.Cache[name];
        if (obj == null)
        {//没有缓存
            string file = Server.MapPath(WebRoot + "apitemplate/" + name + ".htm");
            if (System.IO.File.Exists(file))//判断api模板文件是否存在
            {
                val = System.IO.File.ReadAllText(file);
                HttpContext.Current.Cache.Add(name, val, new System.Web.Caching.CacheDependency(file), System.Web.Caching.Cache.NoAbsoluteExpiration, System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.Normal, null);
            }
        }
        else
            val = obj.ToString();
        return val;
    }

    /// <summary>
    /// 得到该项目的一级分类
    /// </summary>
    /// <param name="teamid">项目id</param>
    /// <param name="firstclass">一级分类</param>
    /// <param name="secondclass">二级分类</param>
    private string GetClassFirst(string teamid)
    {
        string firstclass = "";
        string secondclass = "";
        ITeam teammodel = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(int.Parse(teamid));
        }
        if (teammodel != null && teammodel.Group_id != 0)
        {
            if (teammodel.TeamCategory != null)
            {
                if (teammodel.TeamCategory.City_pid != 0)
                {
                    ICategory firmodel = null;
                    ICategory secmodel = null;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        firmodel = session.Category.GetByID(teammodel.TeamCategory.City_pid);
                    }
                    if (firmodel != null)
                    {
                        if (firmodel.City_pid != 0)
                        {
                            secondclass = firmodel.Name;
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                secmodel = session.Category.GetByID(firmodel.City_pid);
                            }
                            if (secmodel != null)
                            {
                                firstclass = secmodel.Name;
                            }
                        }
                        else
                        {
                            firstclass = firmodel.Name;
                        }
                    }
                }
                else
                {
                    firstclass = teammodel.TeamCategory.Name;
                }

            }
        }
        return firstclass;
    }

    /// <summary>
    /// 得到二级分类
    /// </summary>
    /// <param name="teamid">项目id</param>
    /// <param name="firstclass">一级分类</param>
    /// <param name="secondclass">二级分类</param>
    private string GetClassSecond(string teamid)
    {
        string firstclass = "";
        string secondclass = "";
        ITeam teammodel = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(int.Parse(teamid));
        }
        if (teammodel != null && teammodel.Group_id != 0)
        {
            if (teammodel.TeamCategory != null)
            {
                if (teammodel.TeamCategory.City_pid != 0)
                {
                    ICategory firmodel = null;
                    ICategory secmodel = null;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        firmodel = session.Category.GetByID(teammodel.TeamCategory.City_pid);
                    }
                    if (firmodel != null)
                    {
                        if (firmodel.City_pid != 0)
                        {
                            secondclass = firmodel.Name;
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                secmodel = session.Category.GetByID(firmodel.City_pid);
                            }
                            if (secmodel != null)
                            {
                                firstclass = secmodel.Name;
                            }
                        }
                        else
                        {
                            firstclass = firmodel.Name;
                        }
                    }
                }

            }
        }
        return secondclass;
    }


    /// <summary>
    /// 处理api，直接输出流
    /// </summary>
    /// <param name="api"></param>
    private void ConvertAPI(string api)
    {
        NameValueCollection namevalues = new NameValueCollection();
        namevalues.Add("网站名称", ASSystem.sitename);
        namevalues.Add("网站地址", WWWprefix);
        namevalues.Add("当前日期", DateTime.Now.ToString("yyyy-MM-dd"));
        namevalues.Add("版本号", AS.Common.Utils.Version.SiteVersion);

        if (api == String.Empty)
            return;
        string topval = String.Empty;
        string rechval = String.Empty;
        string bottomval = String.Empty;
        string[] apis = api.Split(new string[] { "<!--loop-->" }, StringSplitOptions.RemoveEmptyEntries);
        if (apis.Length == 2)
        {
            topval = apis[0];
            rechval = apis[1];
        }
        else
            rechval = apis[0];
        apis = rechval.Split(new string[] { "<!--end-->" }, StringSplitOptions.RemoveEmptyEntries);
        rechval = apis[0];
        if (apis.Length == 2) bottomval = apis[1];
        if (topval != String.Empty)
        {


            for (int j = 0; j < namevalues.Keys.Count; j++)
            {
                string key = namevalues.Keys[j];
                Regex r = new Regex("{(" + key + ")}|{(" + key + "),(\\d+)}");
                topval = r.Replace(topval, namevalues[key]);

            }
            Response.Write(topval);
        }
        string sql = "(select t2.*,title as ptitle,homepage,Contact,Phone,Address,location,area from (select t1.*,Category.Name as groupname from(select Team.Id as teamid,team.sort_order as teamsort,Category.Name as cityname,Notice,Team.Product as productname,team.start_time,team.Delivery,team.title as teamname,Team.Image,team.Partner_id,Team.Begin_time,Team.End_time,Team.Market_price,Team.Team_price,Team.Now_number,Per_number,Min_number,Team.Summary,Team.Detail,Team.catakey,Team.Group_id,Max_number,Expire_time,teamcata from Team left join Category on(Team.City_id=Category.Id) where Team.teamcata=0 and Team.apiopen=0 and Team.Begin_time<='" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "' and '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "'<=Team.End_time and Team.Team_type='normal')  t1 left join Category on(t1.Group_id=Category.Id)) as t2 left join partner on t2.Partner_id=partner.id) t3 order by teamsort desc,Begin_time desc,teamid desc  ";
        if (cityename != String.Empty && cityename.ToLower() != "quanguo")
            sql = "(select t2.*,title as ptitle,homepage,Contact,Phone,Address,location,area from (select t1.*,Category.Name as groupname from(select Team.Id as teamid,team.sort_order as teamsort,Category.Name as cityname,Notice,Team.Product as productname,team.start_time,team.Delivery,Team.Image,team.Partner_id,Team.Begin_time,Team.End_time,Team.Market_price,Team.Team_price,Team.Now_number,Per_number,Min_number,teamcata,Team.Summary,Team.Detail,team.Title as teamname,Team.Group_id,Team.catakey,Max_number,Expire_time from Team left join Category on(Team.City_id=Category.Id) where Team.teamcata=0 and Category.ename='" + cityename + "' and Team.apiopen=0 and Team.Begin_time<='" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "' and '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "'<=Team.End_time and Team.Team_type='normal')  t1 left join Category on(t1.Group_id=Category.Id)) as t2 left join partner on t2.Partner_id=partner.id) t3  order by teamsort desc,Begin_time desc,teamid desc";

        //得到当前正在进行的项目，并以开始时间降序排列
        if (top == 0)
        {
            sql = "select * from " + sql;
        }
        else
        {
            sql = "select top(" + top + ") * from " + sql;
        }
        List<Hashtable> hs = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            hs = session.Custom.Query(sql);
        }
        for (int i = 0; i < hs.Count; i++)
        {
            if (hs[i]["groupname"] != null)
            {
                if (Classes[hs[i]["groupname"].ToString()] == null)
                {
                    namevalues["分类"] = hs[i]["groupname"].ToString();
                }
                else
                {
                    namevalues["分类"] = Classes[hs[i]["groupname"].ToString()];
                }
            }
            if (Classes[GetClassFirst(hs[i]["teamid"].ToString())] == null)
            {
                namevalues["一级分类"] = GetClassFirst(hs[i]["teamid"].ToString());
            }
            else
            {
                namevalues["一级分类"] = Classes[GetClassFirst(hs[i]["teamid"].ToString())];
            }
            if (Classes[GetClassSecond(hs[i]["teamid"].ToString())] == null)
            {
                namevalues["二级分类"] = GetClassSecond(hs[i]["teamid"].ToString());
            }
            else
            {
                namevalues["二级分类"] = Classes[GetClassSecond(hs[i]["teamid"].ToString())];
            }
            namevalues["最小成团人数"] = hs[i]["Min_number"].ToString();
            namevalues["最大购买人数"] = hs[i]["Max_number"].ToString();
            namevalues["限购数量"] = hs[i]["Per_number"].ToString();
            namevalues["已购人数"] = hs[i]["Now_number"].ToString();
            if (contentType == "xml")
            {
                namevalues["商品描述"] = "<![CDATA[" + hs[i]["Detail"].ToString() + "]]>";
                namevalues["商品简介"] = "<![CDATA[" + hs[i]["Summary"].ToString() + "]]>";
                namevalues["项目名称"] = "<![CDATA[" + hs[i]["teamname"].ToString() + "]]>";
                namevalues["项目特别提示"] = "<![CDATA[" + hs[i]["Notice"].ToString() + "]]>";
            }
            else if (contentType == "txt")
            {
                namevalues["商品描述"] = hs[i]["Detail"].ToString().Replace("\r\n", "<br>");
                namevalues["商品简介"] = hs[i]["Summary"].ToString().Replace("\r\n", "<br>");
                namevalues["项目名称"] = hs[i]["teamname"].ToString().Replace("\r\n", "<br>");
                namevalues["项目特别提示"] = hs[i]["Notice"].ToString().Replace("\r\n", "<br>");
            }
            namevalues["折扣"] = WebUtils.GetDiscount(Convert.ToDecimal(hs[i]["Market_price"]), Convert.ToDecimal(hs[i]["Team_price"])).Replace("折", "");
            namevalues["团购价"] = hs[i]["Team_price"].ToString();
            namevalues["市场价"] = hs[i]["Market_price"].ToString();
            namevalues["结束时间年月日时分秒"] = Convert.ToDateTime(hs[i]["End_time"]).ToString("yyyyMMddHHmmss");
            namevalues["开始时间年月日时分秒"] = Convert.ToDateTime(hs[i]["Begin_time"]).ToString("yyyyMMddHHmmss");
            namevalues["开始时间戳"] = Helper.GetTimeFix(Convert.ToDateTime(hs[i]["Begin_time"])).ToString();
            namevalues["结束时间戳"] = Helper.GetTimeFix(Convert.ToDateTime(hs[i]["End_time"])).ToString();
            namevalues["结束时间年-月-日 时:分:秒"] = Convert.ToDateTime(hs[i]["End_time"]).ToString("yyyy-MM-dd HH:mm:ss");
            namevalues["开始时间年-月-日 时:分:秒"] = Convert.ToDateTime(hs[i]["Begin_time"]).ToString("yyyy-MM-dd HH:mm:ss");
            namevalues["项目ID"] = hs[i]["teamid"].ToString();
            namevalues["项目关键词"] = hs[i]["catakey"].ToString();
            ITeam t = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                t = session.Teams.GetByID(int.Parse(hs[i]["teamid"].ToString()));
            }
            if (t != null)
            {
                namevalues["项目状态"] = GetTeamStateName(GetState(t));
            }
            string image = hs[i]["Image"].ToString();
            namevalues["商品图片"] = WebUtils.GetRealTeamImageUrl(image);
            namevalues["商品缩略图"] = WWWprefix + ImageHelper.getSmallImgUrl(image);
            namevalues["商品名称"] = "<![CDATA[" + hs[i]["productname"].ToString() + "]]>";
            string cityname = "";
            if (hs[i]["cityname"] == null)
                namevalues["城市必"] = "全国";
            else
                namevalues["城市必"] = hs[i]["cityname"].ToString();
            namevalues["项目地址"] = WWWprefix.Remove(WWWprefix.Length - 1) + getTeamPageUrl(Helper.GetInt(hs[i]["teamid"].ToString(), 0));
            if (hs[i]["Partner_id"] != null && hs[i]["Partner_id"].ToString() != "0")
            {
                if (hs[i]["ptitle"] != null)
                {
                    namevalues["商户名称"] = hs[i]["ptitle"].ToString();
                }
                if (hs[i]["homepage"] != null)
                {
                    namevalues["商户网站"] = hs[i]["homepage"].ToString();
                }
                if (hs[i]["Contact"] != null)
                {
                    namevalues["商户联系人"] = hs[i]["Contact"].ToString();
                }
                if (hs[i]["Phone"] != null)
                {
                    namevalues["商户联系电话"] = hs[i]["Phone"].ToString();
                }
                if (hs[i]["Address"] != null)
                {
                    namevalues["商户联系地址"] = hs[i]["Address"].ToString();
                }
                if (hs[i]["area"] != null)
                {
                    namevalues["商圈"] = hs[i]["area"].ToString();
                }
            }
            namevalues["优惠券过期时间"] = Convert.ToDateTime(hs[i]["Expire_time"]).ToString("yyyyMMddHHmmss");
            namevalues["优惠券过期时间戳"] = Helper.GetTimeFix(Convert.ToDateTime(hs[i]["Expire_time"])).ToString();
            namevalues["优惠券过期时间年月日时分秒"] = Convert.ToDateTime(hs[i]["Expire_time"]).ToString("yyyy-MM-dd HH:mm:ss");

            IPartner partner = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                partner = session.Partners.GetByID(int.Parse(hs[i]["Partner_id"].ToString()));
            }
            if (partner != null)
            {
                namevalues["经纬度"] = partner.point;
            }
            if (hs[i]["Delivery"] == "express")
            {
                namevalues["快递"] = "yes";
            }
            else
            {
                namevalues["快递"] = "no";
            }
            if (int.Parse(hs[i]["Now_number"].ToString()) >= int.Parse(hs[i]["Max_number"].ToString()) && int.Parse(hs[i]["Max_number"].ToString()) != 0 && int.Parse(hs[i]["Now_number"].ToString()) != 0)
            {
                namevalues["卖光"] = "ture";
            }
            else
            {
                namevalues["卖光"] = "no";
            }
            if (hs[i]["start_time"] != null && hs[i]["start_time"].ToString() != "")
            {
                namevalues["优惠券开始时间"] = Convert.ToDateTime(hs[i]["start_time"]).ToString("yyyyMMddHHmmss");
                namevalues["优惠券开始时间戳"] = Helper.GetTimeFix(Convert.ToDateTime(hs[i]["start_time"])).ToString();
                namevalues["优惠券开始时间年月日时分秒"] = Convert.ToDateTime(hs[i]["start_time"]).ToString("yyyy-MM-dd HH:mm:ss");
            }
            else
            {
                namevalues["开始时间年月日时分秒"] = Convert.ToDateTime(hs[i]["Begin_time"]).ToString("yyyyMMddHHmmss");
                namevalues["开始时间戳"] = Helper.GetTimeFix(Convert.ToDateTime(hs[i]["Begin_time"])).ToString();
                namevalues["开始时间年-月-日 时:分:秒"] = Convert.ToDateTime(hs[i]["Begin_time"]).ToString("yyyy-MM-dd HH:mm:ss");
            }
            string str = rechval;
            for (int j = 0; j < namevalues.Keys.Count; j++)
            {
                string key = namevalues.Keys[j];
                Regex r = new Regex("{(" + key + ")}|{(" + key + "),(\\d+)}");
                MatchCollection matchs = r.Matches(str);
                for (int k = 0; k < matchs.Count; k++)
                {
                    string value = Helper.GetString(namevalues[key], String.Empty);
                    string numstr = r.Replace(matchs[k].Value, "$3");
                    bool ok = false;
                    if (numstr != String.Empty)
                    {
                        int num = Helper.GetInt(numstr, 0);
                        if (num > 0)
                        {
                            if (contentType == "xml")
                            {
                                str = str.Replace(matchs[k].Value, "<![CDATA[" + StringUtils.SubString(value.Replace("<![CDATA[", "").Replace("]]>", ""), num * 2) + "]]>");
                            }
                            else if (contentType == "txt")
                            {
                                str = str.Replace(matchs[k].Value, StringUtils.SubString(value.Replace("\r\n", ""), num * 2));
                            }
                            ok = true;
                        }

                    }
                    if (!ok)
                        str = str.Replace(matchs[k].Value, value);

                }

            }
            if ((cityname == "全国" || cityname.Length == 0) && ascitys.Length > 0)
            {
                for (int k = 0; k < ascitys.Length; k++)
                {
                    string tempstr = str;
                    tempstr = tempstr.Replace("全国", ascitys[k]).Replace("quanguo", ascitysen[k]);
                    Response.Write(tempstr.Replace("{编号}", step.ToString()));
                    step = step + 1;
                }
            }
            else
            {
                str = str.Replace("{编号}", step.ToString());
                step = step + 1;
                Response.Write(str);
            }
        }
        Response.Write(bottomval);
        return;
    }
    protected string GetTeamStateName(AS.Enum.TeamState state)
    {
        string val = String.Empty;
        switch (state)
        {
            case AS.Enum.TeamState.none:
                val = "未开始";
                break;
            case AS.Enum.TeamState.begin:
                val = "正在进行";
                break;
            case AS.Enum.TeamState.fail:
                val = "失败";
                break;
            case AS.Enum.TeamState.successbuy:
                val = "成功可继续";
                break;
            case AS.Enum.TeamState.successnobuy:
                val = "成功已卖光";
                break;
            case AS.Enum.TeamState.successtimeover:
                val = "成功已过期";
                break;
        }
        return val;
    }
</script>
