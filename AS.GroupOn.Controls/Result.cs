using System;
using System.Collections.Generic;
using System.Text;
using AS.Common.Utils;
using System.Web;
namespace AS.GroupOn.Controls
{
    /// <summary>
    /// 跳转
    /// </summary>
    public class RedirctResult
    {
        private bool _result = false;
        /// <summary>
        /// 执行结果 true正确，false失败
        /// </summary>
        public bool Result
        {
            get
            {
                return _result;
            }
            set
            {
                _result = value;
            }
        }
        private string _url = "~/";
        /// <summary>
        /// 实例化
        /// </summary>
        /// <param name="url">要跳转的Url</param>
        /// <param name="result">执行结果 true正确,false失败</param>
        public RedirctResult(string url,bool result)
        {
            _url = url;
            _result = result;
        }
        /// <summary>
        /// 执行跳转
        /// </summary>
        public void Execute()
        {
            HttpContext.Current.Response.Redirect(_url);
            HttpContext.Current.Response.End();
        }
    }
    /// <summary>
    /// JSON
    /// </summary>
    public class JsonResult
    {
        private bool _result = false;
        /// <summary>
        /// 执行结果 true正确，false失败
        /// </summary>
        public bool Result
        {
            get
            {
                return _result;
            }
            set
            {
                _result = value;
            }
        }
        private string _json = String.Empty;
        /// <summary>
        /// 实例化
        /// </summary>
        /// <param name="data">json数据</param>
        /// <param name="type">json格式</param>
        /// <param name="result">执行结果</param>
        public JsonResult(string data, string type, bool result)
        {
           _json= JsonUtils.GetJson(data, type);
           _result = result;
        }
        public void Execute()
        {
            HttpContext.Current.Response.Write(_json);
            HttpContext.Current.Response.End();
        }
    }
    /// <summary>
    /// 提示信息
    /// </summary>
    public class ShowMessageResult
    {
        private bool _result = false;
        /// <summary>
        /// 执行结果 true正确，false失败
        /// </summary>
        public bool Result
        {
            get
            {
                return _result;
            }
            set
            {
                _result = value;
            }
        }
        private string _message = String.Empty;
        private bool _type = false;
        /// <summary>
        /// 实例化
        /// </summary>
        /// <param name="message">消息内容</param>
        /// <param name="type">false 失败消息,true 成功消息</param>
        /// <param name="result">执行结果</param>
        public ShowMessageResult(string message,bool type,bool result)
        {
            _message = message;
            _type = type;
            _result = result;
        }
        /// <summary>
        /// 只读消息内容
        /// </summary>
        public string Message
        {
            get
            {
                return _message;
            }
        }
        /// <summary>
        /// 只读消息类型 false 失败,true 成功
        /// </summary>
        public bool Type
        {
            get
            {
                return _type;
            }
        }
        public void Execute()
        {
            PageValue.SetMessage(this);
        }
    }
    /// <summary>
    /// 执行JS脚本
    /// </summary>
    public class JavaScriptResult
    {
        private bool _result = false;
        /// <summary>
        /// 执行结果 true正确，false失败
        /// </summary>
        public bool Result
        {
            get
            {
                return _result;
            }
            set
            {
                _result = value;
            }
        }
        private string _script = String.Empty;
        /// <summary>
        /// 实例化
        /// </summary>
        /// <param name="script">客户端脚本</param>
        /// <param name="result">执行结果</param>
        public JavaScriptResult(string script,bool result)
        {
            _script = script;
            _result = result;
        }
        public void Execute()
        {
            HttpContext.Current.Response.Write("<script type='text/javascript'>" + _script + "</" + "script>");
            HttpContext.Current.Response.End();
        }
    }
}
