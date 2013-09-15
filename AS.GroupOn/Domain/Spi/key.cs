using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    public class key
    {
        private string _keyname = "";

        public string keyname
        {
            set { _keyname = value; }
            get { return _keyname; }
        }
    }
}
