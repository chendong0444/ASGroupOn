using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
   public interface ICatalogs:IObj
    {
       /// <summary>
       /// 分类ID
       /// </summary>
       int id { get; }
       /// <summary>
       /// 分类名称
       /// </summary>
       string catalogname { get; set; }
       /// <summary>
       /// 排序
       /// </summary>
       int sort_order { get; set; }
       /// <summary>
       /// 父类ID,根为0
       /// </summary>
       int parent_id { get; set; }
       /// <summary>
       /// 记录分类编号(保存当前分类所有子类的ID 用，分隔)
       /// </summary>
       string ids { get; set; }
       /// <summary>
       /// 记录当前分类的父分类ID用,分隔
       /// </summary>
       string parentids { get; set; }
       /// <summary>
       /// 分类关键字 当前分类下显示的关键词
       /// </summary>
       string keyword { get; set; }
       /// <summary>
       /// 关键词显示数量
       /// </summary>
       int keytop { get; set; }
       /// <summary>
       /// 分类是否显示 0显示 1隐藏
       /// </summary>
       int visibility { get; set; }
       /// <summary>
       /// 是否主推到首页 0是 1否
       /// </summary>
       int catahost { get; set; }
       /// <summary>
       /// 城市ID 用半角逗号分割
       /// </summary>
       string cityid { get; set; }
       /// <summary>
       /// 分类类型 0团购  1商城
       /// </summary>
       int type { get; set; }
       /// <summary>
       /// 项目分类推广图片
       /// </summary>
       string image { get; set; }
       /// <summary>
       /// 分类广告连接地址
       /// </summary>
       string url { get; set; }
       /// <summary>
       /// 项目分类京东右侧推广图片
       /// </summary>
       string image1 { get; set; }
       /// <summary>
       /// 京东模板右侧广告连接地址
       /// </summary>
       string url1 { get; set; }
       /// <summary>
       /// 分类显示位置（0全部 1顶部 2列表 ）
       /// </summary>
       int location { get; set; }
       /// <summary>
       /// 当前分类当前城市的项目数量
       /// </summary>
       int TeamCount(int? cityid);
       /// <summary>
       /// 父类
       /// </summary>
       ICatalogs ParentCatalog { get; }

       int number { get; set; }

    }
}
