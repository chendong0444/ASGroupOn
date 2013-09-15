using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
   public interface IPagers<T>
    {
       /// <summary>
       /// 当前页码
       /// </summary>
       int CurrentPage { get;}
       /// <summary>
       /// 总页码
       /// </summary>
       int TotalPage { get;}
       /// <summary>
       /// 总记录
       /// </summary>
       int TotalRecords { get;}

       IList<T> Objects { get; }


    }
}
