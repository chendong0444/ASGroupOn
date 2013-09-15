using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using AS.Common.Utils;
using System.Collections;

namespace AS.GroupOn.Domain.Spi
{
    public class Partner : Obj, IPartner
    {
        /// <summary>
        /// 商户ID
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 商户用户名
        /// </summary>
        public virtual string Username { get; set; }
        /// <summary>
        /// 密码
        /// </summary>
        public virtual string Password { get; set; }
        /// <summary>
        /// 商户名称
        /// </summary>
        public virtual string Title { get; set; }
        /// <summary>
        /// 分类ID
        /// </summary>
        public virtual int Group_id { get; set; }
        /// <summary>
        /// 商户主页
        /// </summary>
        public virtual string Homepage { get; set; }
        /// <summary>
        /// 所属城市
        /// </summary>
        public virtual int City_id { get; set; }
        /// <summary>
        /// 开户行
        /// </summary>
        public virtual string Bank_name { get; set; }
        /// <summary>
        /// 银行账号
        /// </summary>
        public virtual string Bank_no { get; set; }
        /// <summary>
        /// 开户名
        /// </summary>
        public virtual string Bank_user { get; set; }
        /// <summary>
        /// 位置信息
        /// </summary>
        public virtual string Location { get; set; }
        /// <summary>
        /// 联系人
        /// </summary>
        public virtual string Contact { get; set; }
        /// <summary>
        /// 商户图片
        /// </summary>
        public virtual string Image { get; set; }
        /// <summary>
        /// 商户图片1
        /// </summary>
        public virtual string Image1 { get; set; }
        /// <summary>
        /// 商户图片2
        /// </summary>
        public virtual string Image2 { get; set; }
        /// <summary>
        /// 联系电话
        /// </summary>
        public virtual string Phone { get; set; }
        /// <summary>
        /// 地址
        /// </summary>
        public virtual string Address { get; set; }
        /// <summary>
        /// 其他信息
        /// </summary>
        public virtual string Other { get; set; }
        /// <summary>
        /// 手机号码
        /// </summary>
        public virtual string Mobile { get; set; }
        /// <summary>
        /// 商户秀 (为Y则在导航品牌商户里显示)
        /// </summary>
        public virtual string Open { get; set; }
        /// <summary>
        /// 是否激活 (如果不激活则不应该出现在所有的商户列表中)
        /// </summary>
        public virtual string Enable { get; set; }
        /// <summary>
        /// 置顶(值越大越靠前显示)
        /// </summary>
        public virtual int Head { get; set; }
        /// <summary>
        /// 会员ID(创建这条记录的管理员ID)
        /// </summary>
        public virtual int User_id { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        public virtual DateTime Create_time { get; set; }
        /// <summary>
        /// 商圈信息,多个之间用半角逗号分隔如(中关村,三里屯)
        /// </summary>
        public virtual string area { get; set; }
        /// <summary>
        /// 经纬度
        /// </summary>
        public virtual string point { get; set; }
        /// <summary>
        /// 商家消费密码
        /// </summary>
        public virtual string Secret { get; set; }
        /// <summary>
        /// 记录此商户是由哪个销售人员维护的销售人员ID
        /// </summary>
        public virtual string sale_id { get; set; }
        /// <summary>
        /// 记录此商户是哪个销售人员ID
        /// </summary>
        public virtual string saleid { get; set; }
        /// <summary>
        /// 400验证电话
        /// </summary>
        public virtual string verifymobile { get; set; }

        ///////////////////////////////////////////////////////////////////
        /// <summary>
        /// 销售人员
        /// </summary>
        public virtual ISales Sale { get; set; }

        public static IPartner GetDefault()
        {
            Partner p = new Partner();
            p.Address = String.Empty;
            p.area = String.Empty;
            p.Bank_name = String.Empty;
            p.Bank_no = String.Empty;
            p.Bank_user = String.Empty;
            p.City_id = 0;
            p.Contact = String.Empty;
            p.Homepage = String.Empty;
            p.Image = String.Empty;
            p.Id = 0;
            p.Location = String.Empty;
            p.Mobile = String.Empty;
            p.Other = String.Empty;
            p.Phone = String.Empty;
            p.Title = String.Empty;
            return p;
        }

        /// <summary>
        /// 所属分类 通过Group_id
        /// </summary>
        private ICategory category = null;
        public virtual ICategory getTypeNameByGroupID 
        {
            get
            {
                CategoryFilter filter = new CategoryFilter();
                filter.Zone="partner";
                
                filter.Id=this.Group_id;

                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                    {
                        category = session.Category.Get(filter);
                    }
               
                return category;
            }
        }


        /// <summary>
        /// 所属城市 通过City_id
        /// </summary>
        private ICategory category1 = null;
        public virtual ICategory getTypeNameByCityID
        {
            get
            {
                CategoryFilter filter = new CategoryFilter();
                filter.Zone = "city";
                filter.Id = this.City_id;

                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    category1 = session.Category.Get(filter);
                }
                return category1;
            }
        }

        /// <summary>
        /// 销售人员
        /// </summary>
        private ISales sales = null;
        private string realName = String.Empty;
        public virtual string getRealName
        {
            get
            {
                realName = String.Empty;

                if (this.saleid != null && this.saleid != String.Empty)
                {
                    if (this.saleid.ToString().IndexOf(",") > 0)
                    {

                        string[] salelist = this.saleid.ToString().Split(',');
                        string str = "";
                        for (int i = 0; i < salelist.Length; i++)
                        {
                            if (str.IndexOf(salelist[i]) == -1)
                            {
                                str += salelist[i] + ",";
                            }
                        }
                        string[] list = str.Split(',');
                        for (int i = 0; i < list.Length; i++)
                        {
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                sales = session.Sales.GetByID(Helper.GetInt(list[i], 0));
                            }
                            if (sales != null)
                            {
                                realName = realName + sales.realname + ",";
                            }
                        }
                        int a = realName.ToString().Length - 1;
                        if (a > 0)
                        {
                            realName = realName.ToString().Remove(a);
                        }
                        
                    }
                    else 
                    {
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                        {
                            sales = session.Sales.GetByID(AS.Common.Utils.Helper.GetInt(this.saleid,0));
                        }
                        if (sales != null) 
                        {
                            realName = sales.realname;
                        }
                    
                    }
                }
                return realName;
            }
        }
        /// <summary>
        /// 得到商户状态为待审核的count
        /// </summary>
        private int pd = 0;
        public virtual int getPartnerState 
        {
            get 
            {
                Partner_DetailFilter filter = new Partner_DetailFilter();
                filter.settlementstate = 1;
                filter.partnerid = this.Id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                {
                    pd = session.Partner_Detail.GetCount(filter);
                }
                return pd;
            }
        }

        /// <summary>
        /// 父商户ID
        /// </summary>
        public virtual int parentId { get; set; }

    }
}
