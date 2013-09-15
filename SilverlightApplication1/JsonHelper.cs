using System;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.Text;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace SilverlightApplication1
{
    public class JsonHelper
    {
        public static string GetJsonFromObject(object obj)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("{");
            Type type = obj.GetType();
            PropertyInfo valuepro = type.GetProperty("Values");
            PropertyInfo keypro = type.GetProperty("Keys");
            if (valuepro != null && keypro != null)
            {
                ICollection coll = (ICollection)valuepro.GetValue(obj, null);
                ICollection keycoll = (ICollection)keypro.GetValue(obj, null);
                string val = String.Empty;

                List<string> keys = new List<string>();
                foreach (object o in keycoll)
                {
                    keys.Add(o.ToString());
                }

                int i = 0;
                val = String.Empty;
                foreach (object o in coll)
                {

                    Type otype = o.GetType();
                    if (otype.ToString() == "System.String" || otype.ToString() == "System.Int32" || otype.ToString() == "System.Boolean")
                    {
                        if (o is string)
                        {
                            val = val + ",\"" + keys[i] + "\":\"" + o.ToString().Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r") + "\"";
                        }
                        else
                        {
                            val = val + ",\"" + keys[i] + "\":" + o.ToString();
                        }


                    }
                    else
                    {
                        val = val + ",\"" + keys[i] + "\":{" + tojson(o) + "}";
                    }

                    i = i + 1;
                }
                if (val.Length > 0)
                {
                    val = val.Substring(1);
                    sb.Append(val);
                }

            }
            else
            {

                string val = String.Empty;
                if (obj is int || obj is bool)
                    val = val + ",\"" + type.Name + "\":" + obj.ToString();
                else if (obj is string)
                    val = val + ",\"" + type.Name + "\":\"" + obj.ToString().Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r") + "\"";
                else
                {
                    PropertyInfo[] propertyinfos = type.GetProperties();
                    for (int i = 0; i < propertyinfos.Length; i++)
                    {
                        PropertyInfo propertyinfo = propertyinfos[i];
                        object propertyvalue = propertyinfo.GetValue(obj, null);
                        Type propertytype = propertyvalue.GetType();

                        if (propertyvalue is int || propertyvalue is bool)
                            val = val + ",\"" + propertyinfo.Name + "\":" + propertyvalue.ToString();
                        else if (propertyvalue is string)
                            val = val + ",\"" + propertyinfo.Name + "\":\"" + propertyvalue.ToString().Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r") + "\"";
                        else
                        {
                            val = val + ",\"" + propertyinfo.Name + "\":{" + tojson(propertyvalue) + "}";
                        }
                    }
                }
                if (val.Length > 0)
                    sb.Append(val.Substring(1));

            }

            sb.Append("}");
            return sb.ToString();
        }


        private static string tojson(object obj)
        {
            Type type = obj.GetType();
            string jsonvalue = String.Empty;
            PropertyInfo valuepro = type.GetProperty("Values");
            PropertyInfo keypro = type.GetProperty("Keys");
            if (valuepro != null && keypro != null)
            {
                ICollection keycoll = (ICollection)keypro.GetValue(obj, null);
                ICollection coll = (ICollection)valuepro.GetValue(obj, null);
                string val = String.Empty;
                List<string> keys = new List<string>();
                foreach (object o in keycoll)
                {
                    keys.Add(o.ToString());
                }
                int i = 0;
                val = String.Empty;
                foreach (object o in coll)
                {

                    Type otype = o.GetType();
                    if (otype.ToString() == "System.String" || otype.ToString() == "System.Int32" || otype.ToString() == "System.Boolean")
                    {
                        if (o is string)
                        {
                            val = val + ",\"" + keys[i] + "\":\"" + o.ToString().Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r") + "\"";
                        }
                        else
                        {
                            val = val + ",\"" + keys[i] + "\":" + o.ToString();
                        }

                    }
                    else
                    {
                        val = val + ",\"" + keys[i] + "\":{" + tojson(o) + "}";
                    }
                    i = i + 1;
                }
                if (val.Length > 0)
                {
                    val = val.Substring(1);
                    jsonvalue = jsonvalue + val;
                }
            }
            else
            {
                string val = String.Empty;
                if (obj is int || obj is bool)
                    val = val + ",\"" + type.Name + "\":" + obj.ToString();
                else if (obj is string)
                    val = val + ",\"" + type.Name + "\":\"" + obj.ToString().Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r") + "\"";
                else
                {
                    PropertyInfo[] propertyinfos = type.GetProperties();
                    for (int i = 0; i < propertyinfos.Length; i++)
                    {
                        PropertyInfo propertyinfo = propertyinfos[i];
                        object propertyvalue = propertyinfo.GetValue(obj, null);
                        Type propertytype = propertyvalue.GetType();

                        if (propertyvalue is int || propertyvalue is bool)
                            val = val + ",\"" + propertyinfo.Name + "\":" + propertyvalue.ToString();
                        else if (propertyvalue is string)
                            val = val + ",\"" + propertyinfo.Name + "\":\"" + propertyvalue.ToString().Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r") + "\"";
                        else
                        {
                            val = val + ",\"" + propertyinfo.Name + "\":{" + tojson(propertyvalue) + "}";
                        }
                    }
                }
                if (val.Length > 0)
                    jsonvalue = jsonvalue + val.Substring(1);
            }
            return jsonvalue;
        }
        

        public static Dictionary<string,object> JsonToObject(string json)
        {
            Dictionary<string, object> tod = new Dictionary<string, object>();
            Dictionary<string, string> namevalues = new Dictionary<string, string>();

            string s = json;
            Regex regex = new Regex("{(.+)}");
            
            Match match = regex.Match(s);
            s = regex.Replace(match.Value, "$1");
            List<pos> poses = new List<pos>();
            int begin = -1;
            int left = 0;//左括号数量
            int right = 0;//右括号数量
            for (int i = 0; i < s.Length; i++)
            {
                if (s[i] == '{')
                {
                    if (begin == -1)
                    {
                        begin = i;
                    }
                    left = left + 1;
                }
                else if (s[i] == '}')
                {
                    right = right + 1;
                }
                else if (s[i] == '[')
                {
                    if (begin == -1)
                    {
                        begin = i;
                    }
                    left = left + 1;
                }
                else if (s[i] == ']')
                {
                    right = right + 1;
                }
                if (left == right && left > 0)
                {

                    pos p = new pos();
                    p.left = begin;
                    p.right = i;
                    p.newstr = GetRandomString(8);
                    p.oldstr = s.Substring(begin, i - begin + 1);
                    poses.Add(p);
                    left = 0;
                    right = 0;
                    begin = -1;
                    namevalues.Add(p.newstr, p.oldstr);
                }

            }

            for (int i = 0; i < poses.Count; i++)
            {
                s = s.Replace(poses[i].oldstr, poses[i].newstr);
            }
            Dictionary<string, object> namevalues_ = new Dictionary<string, object>();
            string[] s_arr = s.Split(new string[] { ",\"" },StringSplitOptions.RemoveEmptyEntries);
            for (int i = 0; i < s_arr.Length; i++)
            {
                int pos = s_arr[i].IndexOf(":");
                string key = s_arr[i].Substring(0, pos);
                string value = s_arr[i].Substring(pos+1);
                key = key.Replace("\"", "");
          
                string temp_value;
                if (namevalues.TryGetValue(value, out temp_value) && temp_value.Length > 0) //被加密了
                {
                    

                    if (temp_value.IndexOf("[") == 0)//是数组
                    {
                        temp_value = temp_value.Substring(1);
                        temp_value = temp_value.Substring(0, temp_value.Length - 1);
                        if (temp_value.IndexOf("{") >= 0)
                        {//对象数组

                            List<object> objects = new List<object>();
                            tod.Add(key, objects);
                            temp_value = temp_value.Substring(1);
                            string[] temp_value_arr = temp_value.Split(new string[] { ",{" }, StringSplitOptions.RemoveEmptyEntries);
                            for (int j = 0; j < temp_value_arr.Length; j++)
                            {

                                Dictionary<string, object> dict = new Dictionary<string, object>();
                                objects.Add(dict);
                                jsontoobject("{" + temp_value_arr[j], dict);
                            }
                        }
                        else if (temp_value.IndexOf("\"") >= 0)
                        {//字符串数组
                            List<string> objects = new List<string>();
                            tod.Add(key, objects);
                            temp_value = temp_value.Substring(1);
                            string[] temp_value_arr = temp_value.Split(new string[] { ",\"" }, StringSplitOptions.RemoveEmptyEntries);
                            for (int j = 0; j < temp_value_arr.Length; j++)
                            {

                                string v = temp_value_arr[j];
                                objects.Add(v.Substring(0, v.Length - 1)); ;

                            }
                        }
                        else if (temp_value.IndexOf("true") >= 0 || temp_value.IndexOf("false") >= 0)
                        {//布尔数组
                            List<bool> objects = new List<bool>();
                            tod.Add(key, objects);
                            //temp_value = temp_value.Substring(1);
                            string[] temp_value_arr = temp_value.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                            for (int j = 0; j < temp_value_arr.Length; j++)
                            {
                                bool val;
                                if (bool.TryParse(temp_value_arr[j], out val))
                                {
                                    objects.Add(val);
                                }
                            }
                        }
                        else
                        {//数值数组
                            List<double> objects = new List<double>();
                            tod.Add(key, objects);
                            // temp_value = temp_value.Substring(1);
                            string[] temp_value_arr = temp_value.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                            for (int j = 0; j < temp_value_arr.Length; j++)
                            {
                                double val;
                                if (double.TryParse(temp_value_arr[j], out val))
                                {
                                    objects.Add(val);
                                }
                            }
                        }
                       
                    }
                    else
                    {
                        Dictionary<string, object> od = new Dictionary<string, object>();
                        tod.Add(key, od);
                        jsontoobject(temp_value, od);

                    }
                }
                else
                {
                    double d;
                    bool b;
                    if (double.TryParse(value, out d))
                    {
                        tod.Add(key, d);
                    }
                    else if (bool.TryParse(value, out b))
                    {
                        tod.Add(key, b);
                    }
                    else if(value.IndexOf("\"")==0) //字符串
                    {
                        value = value.Substring(1);
                        value = value.Substring(0, value.Length - 1);
                        tod.Add(key, value);
                    }
                }
               
            }

            return tod;
        }

        private static void jsontoobject(string json, Dictionary<string, object> tod)
        {
            Dictionary<string, string> namevalues = new Dictionary<string, string>();

            string s = json;
            Regex regex = new Regex("{(.+)}");

            Match match = regex.Match(s);
            s = regex.Replace(match.Value, "$1");
            List<pos> poses = new List<pos>();
            int begin = -1;
            int left = 0;//左括号数量
            int right = 0;//右括号数量
            for (int i = 0; i < s.Length; i++)
            {
                if (s[i] == '{')
                {
                    if (begin == -1)
                    {
                        begin = i;
                    }
                    left = left + 1;
                }
                else if (s[i] == '}')
                {
                    right = right + 1;
                }
                else if (s[i] == '[')
                {
                    if (begin == -1)
                    {
                        begin = i;
                    }
                    left = left + 1;
                }
                else if (s[i] == ']')
                {
                    right = right + 1;
                }
                if (left == right && left > 0)
                {

                    pos p = new pos();
                    p.left = begin;
                    p.right = i;
                    p.newstr = GetRandomString(8);
                    p.oldstr = s.Substring(begin, i - begin + 1);
                    poses.Add(p);
                    left = 0;
                    right = 0;
                    begin = -1;
                    namevalues.Add(p.newstr, p.oldstr);
                }

            }

            for (int i = 0; i < poses.Count; i++)
            {
                s = s.Replace(poses[i].oldstr, poses[i].newstr);
            }
            Dictionary<string, object> namevalues_ = new Dictionary<string, object>();
            string[] s_arr = s.Split(new string[] { ",\"" }, StringSplitOptions.RemoveEmptyEntries);
            for (int i = 0; i < s_arr.Length; i++)
            {
                int pos = s_arr[i].IndexOf(":");
                string key = s_arr[i].Substring(0, pos);
                string value = s_arr[i].Substring(pos + 1);
                key = key.Replace("\"", "");

                string temp_value;
                if (namevalues.TryGetValue(value, out temp_value)&&temp_value.Length>0) //被加密了
                {
                   

                    if (temp_value.IndexOf("[") == 0)//是数组
                    {
                        temp_value = temp_value.Substring(1);
                        temp_value = temp_value.Substring(0, temp_value.Length - 1);
                        if (temp_value.IndexOf("{") >= 0)
                        {//对象数组
                            
                            List<object> objects = new List<object>();
                            tod.Add(key, objects);
                            temp_value = temp_value.Substring(1);
                            string[] temp_value_arr = temp_value.Split(new string[] { ",{" }, StringSplitOptions.RemoveEmptyEntries);
                            for (int j = 0; j < temp_value_arr.Length; j++)
                            {
                                
                                Dictionary<string, object> dict = new Dictionary<string, object>();
                                objects.Add(dict);
                                jsontoobject("{" + temp_value_arr[j], dict);
                            }
                        }
                        else if (temp_value.IndexOf("\"") >= 0)
                        {//字符串数组
                            List<string> objects = new List<string>();
                            tod.Add(key, objects);
                            temp_value = temp_value.Substring(1);
                            string[] temp_value_arr = temp_value.Split(new string[] { ",\"" }, StringSplitOptions.RemoveEmptyEntries);
                            for (int j = 0; j < temp_value_arr.Length; j++)
                            {

                                string v=temp_value_arr[j];
                                objects.Add(v.Substring(0, v.Length - 1)); ;
                               
                            }
                        }
                        else if (temp_value.IndexOf("true") >= 0 || temp_value.IndexOf("false") >= 0)
                        {//布尔数组
                            List<bool> objects = new List<bool>();
                            tod.Add(key, objects);
                            //temp_value = temp_value.Substring(1);
                            string[] temp_value_arr = temp_value.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                            for (int j = 0; j < temp_value_arr.Length; j++)
                            {
                                bool val ;
                                if (bool.TryParse(temp_value_arr[j], out val))
                                {
                                    objects.Add(val);
                                }
                            }
                        }
                        else
                        {//数值数组
                            List<double> objects = new List<double>();
                            tod.Add(key, objects);
                           // temp_value = temp_value.Substring(1);
                            string[] temp_value_arr = temp_value.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                            for (int j = 0; j < temp_value_arr.Length; j++)
                            {
                                double val;
                                if (double.TryParse(temp_value_arr[j], out val))
                                {
                                    objects.Add(val);
                                }
                            }
                        }
                    }
                    else
                    {
                        Dictionary<string, object> od = new Dictionary<string, object>();
                        tod.Add(key, od);
                        jsontoobject(temp_value, od);

                    }
                }
                else
                {
                    double d;
                    bool b;
                    if (double.TryParse(value, out d))
                    {
                        tod.Add(key, d);
                    }
                    else if (bool.TryParse(value, out b))
                    {
                        tod.Add(key, b);
                    }
                    else if (value.IndexOf("\"") == 0) //字符串
                    {
                        value = value.Substring(1);
                        value = value.Substring(0, value.Length - 1);
                        tod.Add(key, value);
                    }
                }

            }

        }
        private static System.Random ran = new Random();
        public static string GetRandomString(int bit)
        {
            string val = ran.Next(1, 10).ToString();
            for (int i = 1; i < bit; i++)
            {
                val = val + ran.Next(0, 10).ToString();
            }
            return val;

        }
    }
    public struct pos
    {
        public int left;
        public int right;
        public string oldstr;
        public string newstr;
    }


}
