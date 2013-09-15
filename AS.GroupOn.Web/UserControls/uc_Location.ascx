<%@ Control Language="C#" AutoEventWireup="true"  Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
   
        private string location="1"; //广告位显示的标志 1:首页显示，2：左侧显示
        public string Location
        {
            set { this.location = value; }
            get { return location; }
        }

        private string width;
        public string Width
        {
            set { this.width = value; }
            get { return width; }
        }

        private string type; //广告位的类型 0:图片，1:视频
        public string Type
        {
            set { this.type = value; }
            get { return type; }
        }

        private string height;
        public string Height
        {
            set { this.height = value; }
            get { return height; }
        }

        public string pic;
       
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                Init();
            }
        }

        protected void Init()
        {
            GetLocation();
        }

        #region 根据location和type 查询广告显示的位置
        public void GetLocation()
        {
           string cityid = "0";
            IList<ILocation> listlocation=null;
            LocationFilter lf=new LocationFilter();
            FBasePage b = new FBasePage();
            if (b.CurrentCity != null)
            {
                cityid = b.CurrentCity.Id.ToString();
            }
            
            string sql = "";
            if (cityid == "0")
            {
                lf.height="0";
                lf.Location=1;
                lf.visibilityS=1;
                lf.AddSortOrder(LocationFilter.ID_DESC);
                using(IDataSession seion=AS.GroupOn.App.Store.OpenSession(false))
                {
                    
                 listlocation= seion.Location.GetList(lf);
                    
                }
               
            }
            else
            {
                lf.height="0";
                lf.Location=1;
                lf.visibility=1;
                lf.CityidS= cityid;
                lf.AddSortOrder(LocationFilter.ID_DESC);
                using(IDataSession seion=AS.GroupOn.App.Store.OpenSession(false))
                {
                    
                 listlocation= seion.Location.GetList(lf);
                    
                }
                
            }
            
            if(listlocation == null || listlocation.Count==0)
            {
                pic = "";
            }
            else
            {
                foreach(ILocation location in listlocation)
                {
                    pic = pic + "<div class='midad' style='MARGIN: 0px 0px 8px 0px; OVERFLOW: hidden;  POSITION: relative; '>";
                    if (location.locationname.ToString() != "")
                    {
                        if (location.type == 0)//0:图片，1:视频
                        {
                            pic = pic + location.decpriction; 
                            pic = pic + "<a href='" + location.pageurl + "'  target='_blank'><img src='" + location.locationname + "' /></a>";
         
                        }
                        else if (location.type == 1)
                        {

                            pic = pic + location.decpriction;
                            if (location.pageurl != "" || location.pageurl != null)
                            {

                                pic = pic + "<embed src='" + location.pageurl + "' quality='high'  align='middle' allowScriptAccess='sameDomain' type='application/x-shockwave-flash'></embed>";

                            }
                            else
                            {
                                pic = pic + "<embed src='" + location.image + "' quality='high'  align='middle' allowScriptAccess='sameDomain' type='application/x-shockwave-flash'></embed>";
                            }
                        }
                    }
                    else
                    {
                        pic = pic + location.decpriction;
                        pic = pic +  location.locationname;
                    }
                    pic = pic + "</div>";
                }
            }
        }
        #endregion
    
 </script>

<%=pic%>