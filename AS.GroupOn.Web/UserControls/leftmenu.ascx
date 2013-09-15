<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<script type="text/javascript">

    $(document).ready(function () {
        var width = document.body.clientWidth;

        var fwidth = $("#ft").width();

        //var left=(width-fwidth)*0.5+fwidth+5;
        var left = (width - fwidth) * 0.5 - 50;

        $("#daoh").css("left", left);
        $("#ritCode").css("left", fwidth+left+60);
    }
)
    $(window).scroll(function () { //监视浏览器滚动条事件
        var win = $(window).scrollTop(); //相对滚动条顶部的距离
        var csstop = $(window).height() / 4; // css top属性的置

        var percent = win + csstop; //percent将被赋值给css中的"top"属性,作为浮动栏的新高度值
        if (percent < 0) { //判断percent的值是否小于0,小于0就凑整,大于0就忽略小数部分
            percent = Math.ceil(percent);
        } else {
            percent = Math.floor(percent); //取整
            var v = percent + "px";
            $("#daoh").css("top", v); //percent被赋值给top属性,浏览器根据这个值动态的调整浮动栏的高度,如果按照上面给的代码,这个高度将正好让浮动栏一直保持在屏幕中央
        }
    })

</script>
<div id="daoh" style="left: 244px;">
  <a href="/team/list/3/0/0/0.html" target="_blank">
    <span><img alt="美食" src="/upfile/img/canju.png">美食</span>
  </a>
  <a href="/team/list/4/0/0/0.html" target="_blank">
    <span><img alt="娱乐" src="/upfile/img/yule.png">娱乐</span>
  </a>
  <a href="/team/list/5/0/0/0.html" target="_blank">
    <span><img alt="电影" src="/upfile/img/sheying.png">电影</span>
  </a>
  <a href="/team/list/8/0/0/0.html" target="_blank">
    <span><img alt="生活" src="/upfile/img/life.png">生活</span>
  </a>
  <a href="/team/list/10/0/0/0.html" target="_blank">
    <span><img alt="酒店" src="/upfile/img/jiudian.png">酒店</span>
  </a>
  <a href="/team/list/9/0/0/0.html" target="_blank">
    <span><img alt="购物" src="/upfile/img/wanggou.png">购物</span>
  </a>
  <a href="javascript:scroll(0,0)" target="_blank">
    <span><img alt="顶部" src="/upfile/img/db.png">顶部</span>
  </a>
</div>
<!--二维码-->
<div id="ritCode">
	<a href="#">
		<img src="/upfile/img/erweima.jpg" />
	</a>
</div>


