<%@ Page Language="C#" AutoEventWireup="true" Debug="true" %>

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {

        System.Random ran = new Random();
        string str = "123456789ABCDEFGHIJKLMNPQRSTUVWXYZ";
        string num = null;
        int pich = 20;
        int picw = 40;
        for (int i = 1; i <= 4; i++)
        {
            num = num + str[ran.Next(0, str.Length - 1)];
        }
        System.Drawing.Bitmap bit = new System.Drawing.Bitmap(picw, pich);

        System.Drawing.Graphics gra = System.Drawing.Graphics.FromImage(bit);
        gra.Clear(System.Drawing.Color.White);
        for (int i = 1; i < pich; i++)
        {
            bit.SetPixel(ran.Next(1, picw - 1), i, System.Drawing.Color.FromArgb(ran.Next(255), ran.Next(255), ran.Next(255)));
        }
        for (int i = 1; i < picw; i++)
        {
            bit.SetPixel(i, ran.Next(1, pich - 1), System.Drawing.Color.Pink);
        }
        System.Drawing.Font font = new System.Drawing.Font("宋体", (float)10.5);

        gra.DrawString(num, font, System.Drawing.Brushes.Red, new System.Drawing.PointF((float)4, (float)4));


        System.IO.MemoryStream ms = new System.IO.MemoryStream();
        if (Session["checkcode"] == null)
        {
            Session.Add("checkcode", num);

        }
        else
        {
            Session["checkcode"] = num;
        }
        bit.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg);
        Response.Clear();
        Response.ContentType = "image/jpeg";
        Response.BinaryWrite(ms.ToArray());


    }
</script>
