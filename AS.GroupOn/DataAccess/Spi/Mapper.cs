using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Xml;
using IBatisNet.DataMapper;
using IBatisNet.Common.Utilities;
using IBatisNet.DataMapper.Configuration;
namespace AS.GroupOn.DataAccess.Spi
{
    public class Mapper
    {
        private static ISqlMapper _mapper = null;
        protected static void Configure(object obj)
        {
            _mapper = null;
        }
        protected static void InitMapper()
        {
            ConfigureHandler hander = new ConfigureHandler(Configure);
            DomSqlMapBuilder builder = new DomSqlMapBuilder();

            string rootPath = AppDomain.CurrentDomain.BaseDirectory + @"bin\mybatis\mssql";//@"F:\Newgroup\AS.GroupOn\mybatis\mssql";
            string xmlPath = AppDomain.CurrentDomain.BaseDirectory + @"bin\mybatis\mssql\datamap.config";
            string sqlmapPath = AppDomain.CurrentDomain.BaseDirectory + @"bin\mybatis\mssql\SqlMap.config";
            NameValueCollection values = new NameValueCollection();
            values.Add("root", rootPath);
            XmlDocument xmldoc = new XmlDocument();
            xmldoc.Load(xmlPath);
            XmlNodeList nodelist = xmldoc.SelectNodes("/root/propertys/property");
            for (int i = 0; i < nodelist.Count; i++)
            {
                values.Add(nodelist[i].Attributes["key"].Value, nodelist[i].Attributes["value"].Value);
            }
            builder.Properties = values;
            _mapper = builder.Configure(sqlmapPath);
            _mapper.SessionStore = new IBatisNet.DataMapper.SessionStore.HybridWebThreadSessionStore(_mapper.Id);
        }

        protected static ISqlMapper Instance()
        {
            if (_mapper == null)
            {
                lock (typeof(SqlMapper))
                {
                    if (_mapper == null)
                    {
                        InitMapper();
                    }
                }

            }
            return _mapper;
        }
        /// <summary>
        /// 返回数据库操作对象
        /// </summary>
        /// <returns></returns>
        public static ISqlMapper Get()
        {
            return Instance();
        }
    }
}
