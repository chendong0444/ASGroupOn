using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Controls
{
    /// <summary>
    /// 实体类Card 。(属性说明自动提取数据库字段的描述信息)
    /// </summary>
    [Serializable]
    public class Car
    {
        public Car()
        { }
        #region Model
        private string _qid;
        private int _quantity;
        private string _goodname;
        private decimal _price;
        private string _pic;
        private string _weight;
        private string _farfee;
        private string _fee;
        private string _result;

        private string _min;

        public string min
        {
            set { _min = value; }
            get { return _min; }
        }


        public string Result
        {
            set { _result = value; }
            get { return _result; }
        }

        public string Farfee
        {
            set { _farfee = value; }
            get { return _farfee; }
        }

        public string Fee
        {
            set { _fee = value; }
            get { return _fee; }
        }
        /// <summary>
        /// 
        /// </summary>
        public string Qid
        {
            set { _qid = value; }
            get { return _qid; }
        }
        /// <summary>
        /// 
        /// </summary>
        public int Quantity
        {
            set { _quantity = value; }
            get { return _quantity; }
        }
        /// <summary>
        /// 
        /// </summary>
        public string Goodname
        {
            set { _goodname = value; }
            get { return _goodname; }
        }
        /// <summary>
        /// 
        /// </summary>
        public decimal Price
        {
            set { _price = value; }
            get { return _price; }
        }
        /// <summary>
        /// 
        /// </summary>
        public string Pic
        {
            set { _pic = value; }
            get { return _pic; }
        }
        /// <summary>
        /// 
        /// </summary>
        public string Weight
        {
            set { _weight = value; }
            get { return _weight; }
        }

        #endregion Model

    }
}
