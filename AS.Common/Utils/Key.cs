using System;
using System.Collections.Generic;
using System.Text;

namespace AS.Common.Utils
{
   public class Key
    {

        private string _keyname = "";

        public string keyname
        {
            set { _keyname = value; }
            get { return _keyname; }
        }
    }
}
