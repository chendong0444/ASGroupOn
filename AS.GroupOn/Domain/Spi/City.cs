using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
   public  class City:Obj,ICity
    {
        /// <summary>
        /// ID号
        /// </summary>
       public virtual int Id { get; set; }
        /// <summary>
        /// 城市中文名称
        /// </summary>
       public virtual string Name { get; set; }
        /// <summary>
        /// 城市英文名称
        /// </summary>
       public virtual string Ename { get; set; }
        /// <summary>
        /// 首字母
        /// </summary>
       public virtual string Letter { get; set; }
        /// <summary>
        /// 排列序号
        /// </summary>
       public virtual int Sort_order { get; set; }
        /// <summary>
        /// 是否显示  Y显示 N不显示
        /// </summary>
       public virtual string Display { get; set; }
       private static ICity _city = null;
       public static ICity GetDefault()
       {
           if (_city == null)
           {
               City city = new City();
               city.Id = 0;
               city.Ename = "quanguo";
               city.Name = "全国";
               city.Letter = "";
               _city = city;
           }
           return _city;
       }
    }
}
