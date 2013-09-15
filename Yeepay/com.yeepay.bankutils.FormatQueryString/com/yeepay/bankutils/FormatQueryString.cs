namespace com.yeepay.bankutils
{
    using System;
    using System.Text;
    using System.Web;

    public abstract class FormatQueryString
    {
        public static string GetQueryString(string strParaName)
        {
            return GetQueryString(strParaName, HttpContext.Current.Request.Url.Query, '&');
        }

        public static string GetQueryString(string strParaName, string strUrl)
        {
            return GetQueryString(strParaName, strUrl, '&');
        }

        public static string GetQueryString(string strParaName, string strUrl, char strSplitChar)
        {
            string[] strArray = strUrl.Split(new char[] { strSplitChar });
            for (int i = 0; i < strArray.Length; i++)
            {
                if (strArray[i].IndexOf(strParaName) >= 0)
                {
                    return HttpUtility.UrlDecode(strArray[i].Split(new char[] { '=' })[1], Encoding.GetEncoding("gb2312"));
                }
            }
            return "";
        }
    }
}

