using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Collections;
namespace AS.Common.Utils
{
   public class DataRowObject
    {
       
            DataRow _row = null;
            public DataRowObject(DataRow row)
            {
                _row = row;
            }

            public void SetValue(string key, object value)
            {
                _row[key] = value;
            }

            public string this[string key]
            {
                get
                {
                    if (_row[key] == null)
                        throw new Exception("不存在key:" + key);
                    return _row[key].ToString();
                }
                
            }

            public int ToInt(string key)
            {
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                return Convert.ToInt32(_row[key]);
            }

            public int ToInt(string key, int defaultvalue)
            {
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                return Utils.Helper.GetInt(_row[key], defaultvalue);
            }
            

            public decimal ToDecimal(string key)
            {
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                return Convert.ToDecimal(_row[key]);
            }

            public decimal ToDecimal(string key, decimal defaultvalue)
            {
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                return Utils.Helper.GetDecimal(_row[key], defaultvalue);
            }

            public float ToFloat(string key)
            {
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                return Convert.ToSingle(_row[key]);
            }

            public float ToFloat(string key, float defaultvalue)
            {
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                return Utils.Helper.GetFloat(_row[key], defaultvalue);
            }

            public DateTime ToDateTime(string key)
            {
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                return Convert.ToDateTime(_row[key]);
            }

            public DateTime ToDateTime(string key, DateTime defaultvalue)
            {
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                return Utils.Helper.GetDateTime(_row[key], defaultvalue);
            }

            public bool ToBool(string key)
            {
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                return Utils.Helper.GetBool(_row[key], false);
            }

            public int? IsInt(string key)
            {
                int? value = null;
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                if (_row[key] is int)
                    value = Convert.ToInt32(_row[key]);
                return value;
            }

            public decimal? IsDecimal(string key)
            {
                decimal? value = null;
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                if (_row[key] is decimal)
                    value = Convert.ToDecimal(_row[key]);
                return value;
            }

            public DateTime? IsDateTime(string key)
            {
                DateTime? value = null;
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                if (_row[key] is DateTime)
                    value = Convert.ToDateTime(_row[key]);
                return value;
            }

            public bool? IsBool(string key)
            {
                bool? value = false;
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                if (_row[key] is bool)
                    value = Convert.ToBoolean(_row[key]);
                return value;
            }

            public bool HasColumnName(string key)
            {
                bool has=false;
                if (_row.Table.Columns.IndexOf(key)>=0)
                {
                    has = true;
                }
                return has;
            }
            public object ToObject(string key)
            {
                if (_row[key] == null)
                    throw new Exception("不存在key:" + key);
                return _row[key];
            }

    }
}
