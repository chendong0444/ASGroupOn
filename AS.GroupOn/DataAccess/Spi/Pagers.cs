using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
namespace AS.GroupOn.DataAccess.Spi
{
    public class Pagers<T>:IPagers<T>
    {
        private IList<T> objs = new List<T>();
        public IList<T> Objects
        {
            get
            {
                return objs;
            }
            set
            {
                objs = value;
            }
        }



        private int _currentpage = 0;//当前页
        public int CurrentPage
        {
            get
            {
                return _currentpage;
            }
            set
            {
                _currentpage = value;
            }
        }

        private int _totalpage = 0;//总页数
        public int TotalPage
        {
            get
            {
                return _totalpage;
            }
            set
            {
                _totalpage = value;
            }
        }

        private int _totalrecords = 0;//总记录数
        public int TotalRecords
        {
            get
            {
                return _totalrecords;
            }
            set
            {
                _totalrecords = value;
            }
        }

        
    }
}
