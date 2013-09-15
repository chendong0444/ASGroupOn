using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Xml;
using System.Configuration;

namespace AS.Ucenter
{
    internal class XmlFunc
    {
        public static Hashtable xml_unserialize(string strXml)
        {
            Hashtable ht = new Hashtable();
            XmlDocument XMLDom = new XmlDocument();
            XMLDom.LoadXml(strXml);
            XmlNode newXMLNode = XMLDom.SelectSingleNode("root");
            int i = 0;
            foreach (XmlNode xn in newXMLNode.ChildNodes)
            {
                ht.Add(i++, xn.InnerText);
            }
            return ht;
        }
    }
}