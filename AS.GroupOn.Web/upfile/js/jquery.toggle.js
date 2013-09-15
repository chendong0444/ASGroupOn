// JavaScript Document
jQuery.extend({
  st: function(s1,s2,op) {
	 var current=0;
 
	var set={current:0,//当前显示元素的索引
			 time:3,//切换时间间隔
			 on:'on',//控制层，
			 auto:1,//是否自动切换
			 mode:'normal',//切换模式 normal:普通;fade:淡入淡出;slide:滑动;
			 switchMode:'mouseover'//鼠标切换方式，mouseover鼠标经过时切换，click单击切换
			};
	
	//切换模式 normal:普通;fade:淡入淡出;slide:滑动;
 	$.extend(set,op);
	
	var e1=$(s1);//控制端
	var e2=$(s2);//内容
	var len=e1.length;//元素个数
	var height=e2.find('li').height();//展现元素的高度，zai切换模式为滑动时要用到
 	var timer;
   	var start=function(){
  		timer=setInterval(function(){  toggle();},set.time*1000);	
	};
	var toggle=function(to){
				if(to==null){
					 current++;
				}else{//如果to不为空，则切换到指定位置
					 current=to;
				}
				if( current>= len){//如果current越界了，则重置为0
					 current=0;	
				}

		        e1.filter('.active').removeClass('active');
		        e1.eq(current).addClass('active');
				switch(set.mode){
					case 'fade':
						e2.fadeOut(2000); 
				 		e2.eq(current).fadeIn(2000);
						break;
					case 'slide':
				  		e2.stop();
						//在图片未加载之前，chrome浏览器下图片的高宽为0，若img外部的li有又没有设置高度的话，此时li的高也是0。
						height=!height?e2.find('li').height():height;//若给img外面的li设上了高，则可以删去此行
				  		e2.animate({ top:-current*(height) }, { duration: "slow" }); 
						break;
					default:
						e2.hide(); 
						e2.eq(current).show();
				} 
	};
	var clear=function(){
		 clearInterval(timer);
	};
	e1.bind(set.switchMode,function(){
		 clear();
  		 current=e1.index(this);	
 		 toggle(current);
 	});
	if(set.auto){//如果自动切换
 		 e1.mouseout(function(){ clear(); start()});
		  start();
	}
  }//function end
		 
}); 
