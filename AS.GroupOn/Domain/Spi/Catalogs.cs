using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess;
namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：zjq
    /// 时间：2012-10-24
    /// </summary>
    public class Catalogs :Obj,ICatalogs
    {
        /// <summary>
        /// 分类ID
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 分类名称
        /// </summary>
        public virtual string catalogname { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        public virtual int sort_order { get; set; }
        /// <summary>
        /// 父类ID,根为0
        /// </summary>
        public virtual int parent_id { get; set; }
        /// <summary>
        /// 记录分类编号(保存当前分类所有子类的ID 用，分隔)
        /// </summary>
        public virtual string ids { get; set; }
        /// <summary>
        /// 记录当前分类的父分类ID用,分隔
        /// </summary>
        public virtual string parentids { get; set; }

        private string _keyword = String.Empty;
        /// <summary>
        /// 分类关键字 当前分类下显示的关键词
        /// </summary>
        public virtual string keyword
        {
            get
            {
                return _keyword;
            }
            set
            {
                if(value!=null)
                _keyword = value;
            }
        }
        /// <summary>
        /// 关键词显示数量
        /// </summary>
        public virtual int keytop { get; set; }
        /// <summary>
        /// 分类是否显示 0显示 1隐藏
        /// </summary>
        public virtual int visibility { get; set; }
        /// <summary>
        /// 是否主推到首页 0是 1否
        /// </summary>
        public virtual int catahost { get; set; }
        /// <summary>
        /// 城市ID 用半角逗号分割
        /// </summary>
        public virtual string cityid { get; set; }
        /// <summary>
        /// 分类类型 0团购  1商城
        /// </summary>
        public virtual int type { get; set; }
        /// <summary>
        /// 项目分类推广图片
        /// </summary>
        public virtual string image { get; set; }
        /// <summary>
        /// 分类广告连接地址
        /// </summary>
        public virtual string url { get; set; }
        /// <summary>
        /// 项目分类京东右侧推广图片
        /// </summary>
        public virtual string image1 { get; set; }
        /// <summary>
        /// 京东模板右侧广告连接地址
        /// </summary>
        public virtual string url1 { get; set; }
        /// <summary>
        /// 分类显示位置（0全部 1顶部 2列表 ）
        /// </summary>
        public virtual int location { get; set; }

        ////////////////////////////////////////////////////////
        private int _teamcount = -1;
        /// <summary>
        /// 当前分类当前城市的项目数量
        /// </summary>
        public virtual int TeamCount(int? cityid)
        {
            if (_teamcount < 0)
            {
                using (IDataSession session = App.Store.OpenSession(false))
                {
                    _teamcount = session.Custom.GetTeamCount(this.id, cityid, 2);
                }
            }
            return _teamcount;

        }

        private ICatalogs _catalog = null;
        /// <summary>
        /// 父类
        /// </summary>
        public virtual ICatalogs ParentCatalog
        {
            get
            {
                if (_catalog == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _catalog = session.Catalogs.GetByID(this.parent_id);
                    }
                }
                return _catalog;
            }
        }

        public virtual int number { get; set; }
    }
    
}
