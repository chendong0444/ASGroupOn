using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
   public interface IObj
    {
       /// <summary>
       /// 获取属性值
       /// </summary>
       /// <param name="propName">属性名称,必须是public类型</param>
       /// <returns></returns>
       object GetValue(string propName);
       /// <summary>
       /// 设置属性值
       /// </summary>
       /// <param name="propName">属性名称,必须是public类型</param>
       /// <param name="value">属性值</param>
       void SetValue(string propName, object value);
    }
}
