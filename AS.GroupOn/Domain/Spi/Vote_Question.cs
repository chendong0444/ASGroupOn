/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
   public class Vote_Question:Obj,IVote_Question
    {


       public int id
       {
           get;
           set;
       }

       public string Title
       {
           get;
           set;
       }

       public string Type
       {
           get;
           set;
       }

       public int is_show
       {
           get;
           set;
       }

       public DateTime Addtime
       {
           get;
           set;
       }

       public int order
       {
           get;
           set;
       }
    }
}
