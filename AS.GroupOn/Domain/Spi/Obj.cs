using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
   public class Obj:IObj
    {

        public object GetValue(string propName)
        {
           return this.GetType().GetProperty(propName).GetValue(this, null);
        }

        public void SetValue(string propName, object value)
        {
            this.GetType().GetProperty(propName).SetValue(this, value, null);
        }
    }
}
