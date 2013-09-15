using System;
using System.Collections.Generic;
using System.Web;

namespace AS.ucenter
{
    [Serializable]
    public class RetrunClass
    {
        #region privateData
        private int uid;
        private string username;
        private string password;
        private string email;
        private bool usernameused;
        #endregion

        #region public
        public int Uid
        {
            get { return uid; }
        }
        public string UserName
        {
            get { return username; }
        }
        public string PassWord
        {
            get { return password; }
        }
        public string Email
        {
            get { return email; }
        }
        public bool UserNameUsed
        {
            get { return usernameused; }
        }
        #endregion

        public RetrunClass()
        {
        }
        public RetrunClass(int uid, string uname, string pwd, string email, bool used)
        {
            this.uid = uid;
            this.username = uname;
            this.password = pwd;
            this.email = email;
            this.usernameused = used;
        }
    }
}