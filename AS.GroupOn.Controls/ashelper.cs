using System;
using System.Collections.Generic;
using System.Text;
using System.Collections.Specialized;
using AS.Common.Utils;
using System.Text.RegularExpressions;

namespace AS.GroupOn.Controls
{
    public class ashelper
    {


        /// <summary>
        /// 返回图片路径
        /// </summary>
        /// <param name="src"></param>
        /// <returns></returns>
        public static string getimgsrc(object src)
        {
            if (WebUtils.config["slowimage"] == "1")
                return " original='" + src + "' src='" + PageValue.WebRoot + "upfile/img/spacer.gif' ";
            else
                return "  src='" + src + "' ";
        }
        /// <summary>
        /// 显示图片延时内容
        /// </summary>
        /// <param name="value">内容</param>
        /// <returns></returns>
        public static string returnContentDetail(string value)
        {
            string ContentDetail = "";
            if (WebUtils.config["slowimage"] == "1")
                ContentDetail = GetHtmlImageUrlList(value);
            else
                ContentDetail = value;
            return ContentDetail;
        }
        /// <summary>
        /// 取得HTML中所有图片的 URL。
        /// </summary>
        /// <param name="sHtmlText">HTML代码</param>
        /// <returns>图片的URL列表</returns>
        public static string GetHtmlImageUrlList(string sHtmlText)
        {

            Regex reg = new Regex("<img(.+?)src=[\"|'](.+?)[\"|'](.+?)?>", RegexOptions.IgnoreCase);
            MatchCollection matches = reg.Matches(sHtmlText);
            sHtmlText = reg.Replace(sHtmlText, "<img class='dynload' src='" + PageValue.WebRoot + "upfile/img/spacer.gif' $1original=\"$2\"$3>");
            return sHtmlText;

        }
        /// <summary>
        /// 取得HTML中所有图片的 URL。
        /// </summary>
        /// <param name="sHtmlText">HTML代码</param>
        /// <returns>手机端图片的URL列表</returns>
        public static string GetHtmlWapImageUrlList(string sHtmlText)
        {
            Regex reg = new Regex("<img(.+?)src=(.+?)?>", RegexOptions.IgnoreCase);
            MatchCollection matches = reg.Matches(sHtmlText);
            sHtmlText = reg.Replace(sHtmlText, "<img class='standard-image' alt='" + PageValue.CurrentSystem.sitename + "图' src=$2>");
            return sHtmlText;

        }
    }
}
