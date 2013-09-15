using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI;
namespace AS.GroupOn.Controls
{
    public interface IUserControl
    {
        void UpdateView();
        object Params { get; set; }
        bool CanCache { get; }
        string CacheKey { get; }
        HtmlTextWriter HTW { get; set; }
    }
}
