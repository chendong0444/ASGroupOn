
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'ask' AND type = 'U')
   DROP table [ask]
;

CREATE TABLE [Ask](
	[Id] [int] IDENTITY(1,1) primary key,
	[User_id] [int] NOT NULL,
	[Team_id] [int] NOT NULL default 0,
	[City_id] [int] NOT NULL  DEFAULT 0,
	[Content] [text]  NOT NULL,
	[Comment] [text] NULL,
	[Create_time] datetime NOT NULL DEFAULT (getdate())
)


;
if  exists(select id from sysobjects where type='U' and name='Area')
DROP table [Area]
;
CREATE TABLE [Area](
	[id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[areaname] [varchar](50) NOT NULL,
	[cityid] [int] NOT NULL default 0,
	[sort] [int] NOT NULL default 0,
	[ename] [varchar](50) NULL ,
	[display] [varchar](1) NOT NULL default 'Y',
	[type] [varchar](20) NOT NULL,
	[circle_id] [int] NULL,
) 
;


IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Card' AND type = 'U')
   DROP table [Card]
;

CREATE TABLE [Card](
	[Id] [varchar](16) primary key not null,
	[Code] [varchar](16)  NOT NULL,
	[Partner_id] [int] NOT NULL,
	[Team_id] [int] NOT NULL  DEFAULT 0,
	[Order_id] [int] NOT NULL DEFAULT ((0)),
	[Credit] [int] NOT NULL,
	[consume] [varchar](1)  DEFAULT ('N'),
	[Ip] [varchar](16)  NULL,
	[Begin_time] datetime NOT NULL,
	[End_time] datetime NOT NULL,
	[user_id] int not null default 0,
	[isGet] int null ,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'orderdetail' AND type = 'U')
   DROP table [orderdetail]

;
CREATE TABLE [orderdetail](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[Order_id] [int] not null,
	[Num] [int] not null default 1,
	[Teamid] [int] not null,
	[Teamprice] [decimal](18, 2) not null default 0,
	[result] [text] null,
	[carno] varchar(16) null,
	[Credit] int not null default 0,
	[discount] float not null default 1,
	[totalscore] int not null default 0,
	[orderscore] int null,
)

;



if EXISTS(select id from sysobjects where type='U' and name='Sales_promotion')
 DROP table [Sales_promotion];
CREATE TABLE [Sales_promotion](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[name] [varchar](200)  NOT NULL,
	[description] [varchar](500)  NOT NULL,
	[enable] [int] NOT NULL DEFAULT ((0)),
	[start_time] [datetime] NOT NULL,
	[end_time] [datetime] NOT NULL,
	[sort] [int] NOT NULL DEFAULT ((0)),

) 
;


if EXISTS(select id from sysobjects where type='U' and name='Promotion_rules')
 DROP table [Promotion_rules];
CREATE TABLE [Promotion_rules](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[full_money] [decimal](18, 2) NOT NULL,
	[typeid] [int] NOT NULL DEFAULT ((0)),
	[feeding_amount] [decimal](18, 2) NOT NULL,
	[start_time] [datetime] NOT NULL,
	[end_time] [datetime] NOT NULL,
	[sort] [int] NOT NULL DEFAULT ((0)),
	[rule_description] [varchar](500) NOT NULL,
	[enable] [int] NOT NULL DEFAULT ((0)),
	[free_shipping] [int] NOT NULL DEFAULT ((0)),
	[deduction] [decimal](18, 2) NOT NULL,
	[activtyid] [int] NULL,

) 
;


IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Category' AND type = 'U')
   DROP table [Category]

;
CREATE TABLE [Category](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[Zone] [varchar](16)  NOT NULL,
	[Czone] [varchar](32)  NULL,
	[Name] [varchar](32)  NOT NULL,
	[Ename] [varchar](16)  NULL,
	[Letter] [varchar](1)  NULL,
	[Sort_order] [int] NOT NULL  DEFAULT ((0)),
	[Display] [varchar](1)  NOT NULL   DEFAULT ('N'),
	[content] text null,
	City_pid int not null default(0),
) 

;

insert into Category (zone,[name],ename,letter,display,[content]) values ('activity','免运费','Free_shipping','F','N','购买金额大于指定金额将免运费');
insert into Category (zone,[name],ename,letter,display,[content]) values ('activity','减金额支付','Deduction','D','N','购买金额大于指定金额将减掉指定的支付金额');
insert into Category (zone,[name],ename,letter,display,[content]) values ('activity','返账户余额','Feeding_amount','F','N','购买金额大于指定金额并支付成功后，会返回账户余额指定的金额');

IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Coupon' AND type = 'U')
   DROP table [Coupon]

;
CREATE TABLE [Coupon](
	[Id] [varchar](14) NOT NULL ,
	[User_id] [int] NOT NULL,
	[Partner_id] [int] NOT NULL,
	[Team_id] [int] NOT NULL,
	[Order_id] [int] NOT NULL,
	[Type] [varchar](10)  NOT NULL  DEFAULT ('consume'),
	[Credit] [int] NOT NULL DEFAULT ((0)),
	[Secret] [varchar](10)  NOT NULL,
	[Consume] [varchar](1) NULL,
	[IP] [varchar](16)  NULL,
	[Sms] [int] NOT NULL  DEFAULT ((0)),
	[Expire_time] [datetime] NOT NULL,
	[Consume_time] [datetime] NULL,
	[Create_time] [datetime] NOT NULL  DEFAULT (getdate()),
	[Sms_time] [datetime] NULL,
	[start_time] datetime null,
	[shoptypes] int not null default 0,
)

;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Feedback' AND type = 'U')
   DROP table [Feedback]

;
CREATE TABLE [Feedback](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[City_id] [int] NOT NULL DEFAULT ((0)),
	[User_id] [int] NOT NULL  DEFAULT ((0)),
	[Category] [varchar](10) NOT NULL,
	[title] [varchar](128)  NOT NULL,
	[Contact] [varchar](255)  NOT NULL,
	[Content] text  NOT NULL,
	[Create_time] [datetime] NOT NULL DEFAULT (getdate()),
 )
 
 
 
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Flow' AND type = 'U')
   DROP table [Flow]
 
;
CREATE TABLE [Flow](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[User_id] [int] NOT NULL,
	[Admin_id] [int] NOT NULL,
	[Detail_id] [varchar](32) NOT NULL,
	[Detail] [varchar](255) NULL,
	[Direction] [varchar](10) NOT NULL,
	[Money] [decimal](10, 2) NOT NULL,
	[Action] [varchar](16)  NOT NULL,
	[Create_time] [datetime] NOT NULL  DEFAULT (getdate()),
 )
 
 
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Mailer' AND type = 'U')
   DROP table [Mailer] 

 
;
CREATE TABLE [Mailer](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[Email] [varchar](128)  NOT NULL,
	[City_id] [int] NOT NULL  DEFAULT ((0)),
	[Secret] [varchar](32)  NOT NULL,
	[sendmailids] varchar(4000) default '',
	[readcount] int not null default 0,
	[provider] varchar(100) null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'mailtasks' AND type = 'U')
   DROP table [mailtasks]
;
create table mailtasks
(
id int identity(1,1) primary key not null,
subject varchar(500) not null,
content text null,
sendcount int not null default 0,
totalcount int not null default 0,
readmailerid text null,
readcount int not null default 0,
state int not null default 0,
cityid varchar(4000)  null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'mailserviceprovider' AND type = 'U')
   DROP table [mailserviceprovider]
;
create table mailserviceprovider
(
id int  identity(1,1) primary key not null,
mailtasks_id int not null,
serviceprovider varchar(200) not null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Order' AND type = 'U')
   DROP table [Order] 

;
CREATE TABLE [Order](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[Pay_id] [varchar](32)   NULL,
	[Service] [varchar](16)  NULL,
	[User_id] [int] NOT NULL,
	[Admin_id] [int] NOT NULL  DEFAULT ((0)),
	[Team_id] [int] NOT NULL,
	[City_id] [int] NOT NULL  DEFAULT ((0)),
	[Card_id] [varchar](16)  NULL,
	[State] [varchar](10) NOT NULL  DEFAULT ('unpay'),
	[Quantity] [int] NOT NULL  DEFAULT ((1)),
	[Realname] [varchar](128)  NULL,
	[Mobile] [varchar](128) NULL,
	[Zipcode] [varchar](16)  NULL,
	[Address] [varchar](128)  NULL,
	[Express] [varchar](1) NOT NULL  DEFAULT ('N'),
	[Express_xx] [varchar](128)  NULL,
	[Express_id] [int] NOT NULL  DEFAULT ((0)),
	[Express_no] [varchar](32) NULL,
	[Price] [decimal](10, 2) NOT NULL,
	[Money] [decimal](10, 2) NOT NULL,
	[Origin] [decimal](10, 2) NOT NULL,
	[Credit] [decimal](10, 2) NOT NULL,
	[Card] [decimal](10, 2) NOT NULL,
	[Fare] [decimal](10, 2) NOT NULL,
	[Remark] [text] NULL,
	[Create_time] [datetime] NOT NULL  DEFAULT (getdate()),
	[Pay_time] [datetime] NULL,
	[IP_Address] [varchar](500) null,
	[fromdomain] [varchar](500) null,
	[result] [text] null,
	[refundtype] int not null default 0,
	[adminremark] text null,
	[orderscore] int not null default 0,
	[discount] float not null default 1,
	[totalscore] int not null default 0,
	[checkcode] varchar(50) null,
	disamount decimal(18,2) not null default 0,
	disinfo varchar(2000) null,
	Parent_orderid int not null default 0,
	Partner_id int not null default 0,
	cashondelivery [decimal](10, 2) NOT NULL default 0,
	returnmoney [decimal](10, 2) NOT NULL default 0,
	rviewstate int NULL,
	rviewremarke text NULL,
	userremarke text NULL,
	CashParent_orderid int null,
	partnerfare int null,
	refundTime datetime null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Role' AND type = 'U')
   DROP table [Role] 

;
CREATE TABLE [Role](
    Id int not null identity(1,1) primary key, 
    rolename varchar(50) null,
    code varchar(20) null,
) 
;
insert into Role(rolename,code)values('项目管理员','team')
;
insert into Role(rolename,code)values('客服管理员','help')
;
insert into Role(rolename,code)values('订单管理员','order')
;
insert into Role(rolename,code)values('营销管理员','market')
;
insert into Role(rolename,code)values('系统管理员','admin')
;

IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Author' AND type = 'U')
   DROP table [Author] 

;
CREATE TABLE [Author](
 	Id int not null identity(1,1) primary key,
	roleid int null,
	menuid int null,
) 
;
insert into Author values(1,16)
;
insert into Author values(1,17)
;
insert into Author values(1,19)
;
insert into Author values(1,20)
;
insert into Author values(1,21)
;
insert into Author values(1,22)
;
insert into Author values(1,23)
;
insert into Author values(1,25)
;
insert into Author values(1,26)
;
insert into Author values(1,27)
;
insert into Author values(1,29)
;
insert into Author values(1,30)
;
insert into Author values(1,32)
;
insert into Author values(1,33)
;
insert into Author values(2,2)
;
insert into Author values(2,3)
;
insert into Author values(2,5)
;
insert into Author values(2,6)
;
insert into Author values(3,35)
;
insert into Author values(3,36)
;
insert into Author values(3,37)
;
insert into Author values(3,39)
;
insert into Author values(3,40)
;
insert into Author values(3,42)
;
insert into Author values(3,43)
;
insert into Author values(3,143)
;
insert into Author values(4,55)
;
insert into Author values(4,56)
;
insert into Author values(4,57)
;
insert into Author values(4,58)
;
insert into Author values(4,60)
;
insert into Author values(4,61)
;
insert into Author values(4,62)
;
insert into Author values(4,63)
;
insert into Author values(4,64)
;
insert into Author values(4,65)
;
insert into Author values(4,66)
;
insert into Author values(5,7)
;
insert into Author values(5,8)
;
insert into Author values(5,9)
;
insert into Author values(5,10)
;
insert into Author values(5,11)
;
insert into Author values(5,13)
;
insert into Author values(5,14)
;
insert into Author values(5,45)
;
insert into Author values(5,46)
;
insert into Author values(5,47)
;
insert into Author values(5,48)
;
insert into Author values(5,49)
;
insert into Author values(5,51)
;
insert into Author values(5,52)
;
insert into Author values(5,68)
;
insert into Author values(5,69)
;
insert into Author values(5,70)
;
insert into Author values(5,72)
;
insert into Author values(5,73)
;
insert into Author values(5,74)
;
insert into Author values(5,75)
;
insert into Author values(5,76)
;
insert into Author values(5,77)
;
insert into Author values(5,78)
;
insert into Author values(5,80)
;
insert into Author values(5,82)
;
insert into Author values(5,83)
;
insert into Author values(5,85)
;
insert into Author values(5,86)
;
insert into Author values(5,88)
;
insert into Author values(5,89)
;
insert into Author values(5,91)
;
insert into Author values(5,92)
;
insert into Author values(5,93)
;
insert into Author values(5,94)
;
insert into Author values(5,96)
;
insert into Author values(5,97)
;
insert into Author values(5,98)
;
insert into Author values(5,100)
;
insert into Author values(5,101)
;
insert into Author values(5,102)
;
insert into Author values(5,103)
;
insert into Author values(5,104)
;
insert into Author values(5,105)
;
insert into Author values(5,106)
;
insert into Author values(5,107)
;
insert into Author values(5,108)
;
insert into Author values(5,109)
;
insert into Author values(5,110)
;
insert into Author values(5,112)
;
insert into Author values(5,113)
;
insert into Author values(5,116)
;
insert into Author values(5,117)
;
insert into Author values(5,118)
;
insert into Author values(5,119)
;
insert into Author values(5,120)
;
insert into Author values(5,123)
;
insert into Author values(5,124)
;
insert into Author values(5,125)
;
insert into Author values(5,126)
;
insert into Author values(5,128)
;
insert into Author values(5,129)
;
insert into Author values(5,131)
;
insert into Author values(5,132)
;
insert into Author values(5,133)
;
insert into Author values(5,134)
;
insert into Author values(5,136)
;
insert into Author values(5,137)
;
insert into Author values(5,139)
;
insert into Author values(5,140)
;
insert into Author values(5,141)
;
insert into Author values(5,142)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Authority' AND type = 'U')
   DROP table [Authority] 

;
CREATE TABLE [Authority](
 	[ID] int not null primary key,
	[AuthorityName] [varchar](100) NOT NULL,
) 
;
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (1,'项目咨询列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (2,'编辑项目咨询');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (3,'答复项目咨询');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (4,'删除项目咨询');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (5,'反馈意见列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (6,'处理反馈意见');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (7,'删除反馈意见');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (8,'商务合作列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (9,'处理商务合作');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (10,'删除商务合作');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (11,'产品评论列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (12,'处理产品评论');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (13,'删除产品评论');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (14,'商户评论列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (15,'处理商户评论');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (16,'删除商户评论');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (17,'邮件订阅列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (18,'删除邮件订阅');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (19,'短信订阅列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (20,'删除短信订阅');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (21,'邀请记录列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (22,'确认邀请记录');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (23,'取消邀请记录');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (24,'返利记录列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (25,'违规记录列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (26,'邀请统计列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (27,'邀请统计详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (28,'线下充值列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (29,'在线充值列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (30,'现金支付列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (31,'退款记录列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (32,'签名记录列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (33,'红包列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (34,'返余额列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (35,'查看在线购买');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (36,'查看优惠券返利');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (37,'查看提现记录');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (38,'查看评价返利记录');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (39,'友情链接列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (40,'添加友情链接');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (41,'编辑友情链接');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (42,'删除友情链接');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (43,'数据库备份');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (44,'数据库恢复');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (45,'产品列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (46,'产品详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (47,'编辑产品');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (48,'删除产品');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (49,'审核产品');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (50,'产品出入库');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (51,'新建产品');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (52,'当前项目列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (53,'项目详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (54,'编辑项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (55,'删除项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (56,'复制项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (57,'下载项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (58,'复制到商城');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (59,'项目出入库');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (60,'导入站外券');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (61,'抽奖信息');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (62,'未开始项目列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (63,'成功项目列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (64,'失败项目列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (65,'新建项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (66,'商城项目列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (67,'商城项目详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (68,'编辑商城项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (69,'删除商城项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (70,'复制到团购');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (71,'下载商城项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (72,'是否显示');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (73,'商城项目出入库');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (74,'新建商城项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (75,'查看商城设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (76,'修改商城设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (77,'商城项目分类列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (78,'新建商城项目分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (79,'编辑商城项目分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (80,'删除商城项目分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (81,'商城导航列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (82,'新建商城导航');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (83,'编辑商城导航');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (84,'删除商城导航');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (85,'订单信息列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (86,'订单信息详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (87,'确认现金支付');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (88,'删除订单信息');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (89,'查看付款订单列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (90,'查看未付款订单列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (91,'查看取消订单列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (92,'查看审核退款列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (93,'订单退款审核');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (94,'退款订单列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (95,'查看退款订单详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (96,'处理退款订单列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (97,'处理退款申请');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (98,'接受退款申请');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (99,'退款信息详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (100,'删除退款申请');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (101,'成功退款详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (102,'查看未选择快递订单');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (103,'订单批量选择快递');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (104,'选择快递公司');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (105,'未打印快递订单列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (106,'打印快递订单');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (107,'未打印快递订单详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (108,'已发货订单列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (109,'已发货订单详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (110,'未发货订单列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (111,'未发货订单详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (112,'批量上传快递单');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (113,'货到付款确认订单支付');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (114,'货到付款已完成订单列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (115,'站内券列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (116,'站内券短信');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (117,'站内券详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (118,'站内券消费');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (119,'站外券列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (120,'站外券短信');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (121,'站外券详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (122,'编辑站外券');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (123,'删除站外券');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (124,'代金券列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (125,'删除代金券');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (126,'下载代金券');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (127,'txt下载代金券');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (128,'新建代金券');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (129,'用户列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (130,'用户详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (131,'编辑用户');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (132,'删除用户信息');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (133,'管理员列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (134,'编辑管理员');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (135,'管理员授权');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (136,'销售人员列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (137,'添加销售人员');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (138,'删除销售人员');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (139,'编辑销售人员');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (140,'绑定项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (141,'角色权限授权');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (142,'角色管理列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (143,'添加角色');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (144,'编辑角色');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (145,'删除角色');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (146,'商户列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (147,'编辑商户');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (148,'删除商户');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (149,'分站管理');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (150,'编辑分站');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (151,'删除分站');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (152,'新建分站');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (153,'结算信息');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (154,'结算详情列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (155,'商户结算');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (156,'删除结算信息');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (157,'审核结算信息');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (158,'结算详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (159,'新建商户');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (160,'新建普通邮件');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (161,'群发邮件列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (162,'新建群发邮件');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (163,'编辑群发邮件信息');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (164,'删除群发邮件信息');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (165,'发送邮件群发信息');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (166,'短信群发');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (167,'手机号码下载');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (168,'邮件地址下载');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (169,'项目订单下载');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (170,'项目优惠券下载');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (171,'用户信息下载');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (172,'红包派发');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (173,'促销活动列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (174,'添加促销活动');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (175,'删除促销活动');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (176,'编辑促销活动');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (177,'促销活动详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (178,'促销活动规则');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (179,'添加促销规则');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (180,'删除促销规则');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (181,'编辑促销规则');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (182,'促销规则详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (183,'城市列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (184,'新建城市');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (185,'编辑城市');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (186,'删除城市');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (187,'城市公告');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (188,'操作子城市');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (189,'添加子城市');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (190,'编辑子城市');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (191,'删除子城市');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (192,'子城市公告');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (193,'城市分组列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (194,'新建城市分组');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (195,'编辑城市分组');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (196,'删除城市分组');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (197,'区域商圈列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (198,'新建区域商圈');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (199,'编辑区域商圈');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (200,'删除区域商圈');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (201,'操作商圈');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (202,'添加商圈');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (203,'编辑商圈');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (204,'删除商圈');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (205,'项目分类列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (206,'新建项目分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (207,'编辑项目分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (208,'删除项目分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (209,'api分类列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (210,'新建api分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (211,'编辑api分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (212,'删除api分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (213,'新建子分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (214,'讨论区分类列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (215,'新建讨论区分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (216,'编辑讨论区分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (217,'删除讨论区分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (218,'用户等级列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (219,'新建用户等级');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (220,'编辑用户等级');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (221,'删除用户等级');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (222,'商户分类列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (223,'新建商户分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (224,'编辑商户分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (225,'删除商户分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (226,'品牌分类列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (227,'新建品牌分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (228,'编辑品牌分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (229,'删除品牌分类');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (230,'问题反馈统计');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (231,'问题反馈列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (232,'问题选项反馈列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (233,'问题选项详情反馈列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (234,'问题列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (235,'添加新问题');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (236,'编辑问题');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (237,'删除问题');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (238,'是否显示问题');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (239,'问题选项列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (240,'添加新选项');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (241,'是否显示选项');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (242,'编辑选项');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (243,'删除选项');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (244,'网站基本设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (245,'网站选项设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (246,'导航列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (247,'新建导航栏目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (248,'编辑导航栏目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (249,'删除导航栏目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (250,'网站系统公告');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (251,'网站支付方式');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (252,'网站普通邮件设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (253,'网站群发邮件设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (254,'新建群发邮件服务');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (255,'编辑邮件服务');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (256,'删除邮件服务');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (257,'发送测试');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (258,'网站短信配置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (259,'短信模版设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (260,'网站页面编辑');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (261,'网站皮肤选择');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (262,'广告位列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (263,'添加首页广告位');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (264,'添加右侧广告位');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (265,'编辑广告位');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (266,'删除广告位');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (267,'网站一站通设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (268,'网站UC设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (269,'网站CPS设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (270,'网站升级');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (271,'图片管理');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (272,'删除图片目录');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (273,'查看原图');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (274,'删除图片');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (275,'图片列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (276,'上传图片');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (277,'删除图片');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (278,'积分记录列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (279,'积分规则');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (280,'积分订单列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (281,'积分订单详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (282,'删除积分订单');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (283,'上架积分项目列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (284,'上架积分项目详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (285,'编辑上架积分项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (286,'删除上架积分项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (287,'复制上架积分项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (288,'上架积分项目出入库');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (289,'下架积分项目列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (290,'下架积分项目详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (291,'编辑下架积分项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (292,'删除下架积分项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (293,'复制下架积分项目');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (294,'下架积分项目出入库');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (295,'用户注册统计');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (296,'用户注册统计下载');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (297,'用户订单统计');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (298,'用户订单统计下载');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (299,'订单统计');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (300,'订单统计下载');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (301,'项目统计');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (302,'项目统计下载');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (303,'打印模版列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (304,'打印模板详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (305,'新建打印模版');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (306,'删除打印模版');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (307,'发件人信息设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (308,'物流城市管理列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (309,'添加子城市');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (310,'编辑城市名称');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (311,'删除当前城市及子城市');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (312,'运费模版管理列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (313,'新建运费模版');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (314,'编辑运费模版');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (315,'删除运费模版');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (316,'快递公司列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (317,'新建快递公司');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (318,'运费价格');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (319,'未送达区域设置');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (320,'编辑快递公司');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (321,'删除快递公司');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (322,'包邮选项');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (323,'艾尚短信发送记录');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (324,'艾尚短信充值');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (325,'新闻公告列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (326,'新建新闻公告');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (327,'编辑新闻公告');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (328,'删除新闻公告');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (329,'用户消费总额聚合');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (330,'清除页面缓存');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (331,'本周统计');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (332,'用户充值');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (333,'管理员操作日志');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (334,'问题反馈统计');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (335,'问题反馈列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (336,'问题选项反馈列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (337,'问题列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (338,'添加新问题');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (339,'编辑问题');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (340,'删除问题');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (341,'问题选项列表');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (342,'添加问题新选项');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (343,'编辑问题选项');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (344,'删除问题选项');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (345,'反馈详情');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (346,'反馈详情内容');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (347,'付款订单来源统计');
INSERT INTO [Authority]([ID],[AuthorityName]) VALUES (348,'用户注册来源统计');

IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'RoleAuthority' AND type = 'U')
   DROP table [RoleAuthority] 

;
CREATE TABLE [RoleAuthority](
  [ID] [int] primary key identity(1,1) not null ,
  [RoleID] [int] NOT NULL,
  [AuthorityID] [int] NOT NULL,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'OprationLog' AND type = 'U')
   DROP table [OprationLog] 

;
CREATE TABLE [OprationLog](
	[id] [int] primary key identity(1,1) not null ,
	[adminid] [int] NOT NULL,
	[type] [varchar](50) NOT NULL,
	[logcontent] [nvarchar](250) NOT NULL,
	[createtime] [datetime] NOT NULL,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'userlevelrules' AND type = 'U')
   DROP table [userlevelrules] 

;
CREATE TABLE [userlevelrules](
id int primary key identity(1,1) not null ,
  levelid int not null default 0,
  maxmoney decimal(18,2) not null ,
  minmoney decimal(18,2) not null, 
  discount float not null default 1, 
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'scorelog' AND type = 'U')
   DROP table [scorelog] 

;
CREATE TABLE [scorelog](
id int primary key identity(1,1) not null,
      score int not null default 0,
      action varchar(50) not null,
      [key] varchar(50) not null,
      create_time datetime not null default getdate(),
      adminid int not null default 0,
      user_id int not null default 0,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Page' AND type = 'U')
   DROP table [Page] 

;
CREATE TABLE [Page](
	[Id] [varchar](16)  NOT NULL primary key,
	[Value] [text]  NULL,
)


;
insert into page(id,value)values('help_tour','玩转艾尚团购')
;

insert into page(id,value)values('help_faqs','常见问题')
;

insert into page(id,value)values('help_asdht','什么是艾尚团购')
;

insert into page(id,value)values('help_api','<p>Baidu API</p><p>http://您的网址/api.aspx?key=baidu</p><p>Sohu API</p><p>http://您的网址/api.aspx?key=sohu</p><p>Soso API</p><p>http://您的网址/api.aspx?key=soso</p><p>tuan123 API</p><p>http://您的网址/api.aspx?key=tuan123</p><p>tuan800 API</p><p>http://您的网址/api.aspx?key=tuan800</p><p>Tuanp API</p><p>http://您的网址/api.aspx?key=tuanp</p>')
;

insert into page(id,value)values('about_contact','联系方式')
;

insert into page(id,value)values('about_job','工作机会')
;

insert into page(id,value)values('about_us','艾尚团购')
;

insert into page(id,value)values('about_terms','用户协议')
;

insert into page(id,value)values('about_privacy','隐私声明')
;





;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Partner' AND type = 'U')
   DROP table [Partner] 

;
CREATE TABLE [Partner](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[Username] [varchar](32)  NOT NULL,
	[Password] [varchar](32)  NOT NULL,
	[Title] [varchar](128)  NOT NULL,
	[Group_id] [int] NOT NULL DEFAULT ((0)),
	[Homepage] [varchar](128)  NULL,
	[City_id] [int] NOT NULL  DEFAULT ((0)),
	[Bank_name] [varchar](128)  NULL,
	[Bank_no] [varchar](128)  NULL,
	[Bank_user] [varchar](128) NULL,
	[Location] [text] NOT NULL,
	[Contact] [varchar](32) NULL,
	[Image] [varchar](128) NOT NULL,
	[Image1] [varchar](128) NULL,
	[Image2] [varchar](128) NULL,
	[Phone] [varchar](18) NULL,
	[Address] [varchar](128) NULL,
	[Other] [text] NULL,
	[Mobile] [varchar](12) NULL,
	[Open] [varchar](1) NOT NULL DEFAULT ('N'),
	[Enable] [varchar](1) NOT NULL DEFAULT ('Y'),
	[Head] [bigint] NOT NULL DEFAULT ((0)),
	[User_id] [int] NOT NULL,
	[Create_time] [datetime] NOT NULL DEFAULT (getdate()),
	[area] varchar(1000) null,
	[Secret] varchar(500) null,
	[point] varchar(500) null,
	[sale_id] varchar(1000)  null ,
	[saleid] varchar(1000) null,
	[verifymobile] varchar(50) null,
 )
 
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Pay' AND type = 'U')
   DROP table [Pay]  
 
 ;
CREATE TABLE [Pay](
	[Id] [varchar](32) NOT NULL primary key,
	[Order_id] [int] NOT NULL default 0,
	[Bank] [varchar](32) NOT NULL,
	[Money] [decimal](18, 2) NOT NULL,
	[Currency] [varchar](10) NOT NULL DEFAULT ('''CNY'''),
	[Service] [varchar](16) NOT NULL,
	[Create_time] [datetime] NOT NULL DEFAULT (getdate()),
 )
 
 
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Smssubscribe' AND type = 'U')
   DROP table [Smssubscribe]  
 ;
CREATE TABLE [Smssubscribe](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[Mobile] [varchar](18)  NOT NULL,
	[City_id] [int] NOT NULL DEFAULT ((0)),
	[Secret] [varchar](6) NOT NULL,
	[Enable] [varchar](1) NOT NULL DEFAULT ('N'),
 )
 
 
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'system' AND type = 'U')
   DROP table [system]  
 
 ;
CREATE TABLE [system](
	[id] [int] NOT NULL primary key,
	[sitename] [varchar](500) NULL,
	[sitetitle] [varchar](500) NULL,
	[abbreviation] [varchar](500) NULL,
	[couponname] [varchar](500) NULL,
	[currency] [varchar](500) NOT NULL DEFAULT ('￥'),
	[currencyname] [varchar](500) NULL,
	[invitecredit] [decimal](18, 2) NOT NULL DEFAULT ((0)),
	[sideteam] [int] NOT NULL DEFAULT ((0)),
	[headlogo] [varchar](256) NULL,
	[footlogo] [varchar](256) NULL,
	[emaillogo] [varchar](256) NULL,
	[printlogo] [varchar](256) NULL,
	[conduser] [int] NOT NULL DEFAULT ((0)),
	[partnerdown] [int] NOT NULL DEFAULT ((0)),
	[kefuqq] [varchar](500) NULL,
	[kefumsn] [varchar](500) NULL,
	[icp] [varchar](500) NULL,
	[statcode] [varchar](500) NULL,
	[Navpartner] [int] NOT NULL DEFAULT ((0)),
	[navseconds] [int] NOT NULL DEFAULT ((0)),
	[navgoods] [int] NOT NULL DEFAULT ((0)),
	[navforum] [int] NOT NULL DEFAULT ((0)),
	[Displayfailure] [int] NOT NULL DEFAULT ((0)),
	[teamask] [int] NOT NULL DEFAULT ((0)),
	[creditseconds] [int] NOT NULL DEFAULT ((0)),
	[smssubscribe] [int] NOT NULL DEFAULT ((0)),
	[trsimple] [int] NOT NULL DEFAULT ((0)),
	[moneysave] [int] NOT NULL DEFAULT ((0)),
	[teamwhole] [int] NOT NULL DEFAULT ((0)),
	[encodeid] [int] NOT NULL DEFAULT ((0)),
	[cateteam] [int] NOT NULL DEFAULT ((0)),
	[catepartner] [int] NOT NULL DEFAULT ((0)),
	[citypartner] [int] NOT NULL DEFAULT ((0)),
	[cateseconds] [int] NOT NULL DEFAULT ((0)),
	[categoods] [int] NOT NULL DEFAULT ((0)),
	[emailverify] [int] NOT NULL DEFAULT ((0)),
	[needmobile] [int] NOT NULL DEFAULT ((0)),
	[gobalbulletin] [text] NULL,
	[bulletin] [text] NULL,
	[alipaymid] [varchar](100) NULL,
	[alipaysec] [varchar](100) NULL,
	[alipayacc] [varchar](100) NULL,
	[yeepaymid] [varchar](100) NULL,
	[yeepaysec] [varchar](100) NULL,
	[chinabankmid] [varchar](100) NULL,
	[chinabanksec] [varchar](100) NULL,
	[tenpaymid] [varchar](100) NULL,
	[tenpaysec] [varchar](100) NULL,
	[billmid] [varchar](100) NULL,
	[billsec] [varchar](100) NULL,
	[paypalmid] [varchar](100) NULL,
	[paypalsec] [varchar](100) NULL,
	[mailhost] [varchar](100) NULL,
	[mailport] [varchar](100) NULL,
	[mailuser] [varchar](100) NULL,
	[mailssl] [int] not null default 0,
	[mailpass] [varchar](100) NULL,
	[mailfrom] [varchar](100) NULL,
	[mailreply] [varchar](100) NULL,
	[mailinterval] [int] NOT NULL DEFAULT ((0)),
	[subscribehelpphone] [varchar](100) NULL,
	[subscribehelpemail] [varchar](100) NULL,
	[smsuser] [varchar](100) NULL,
	[smspass] [varchar](100) NULL,
	[smsinterval] [int] NOT NULL DEFAULT ((0)),
	[skintheme] [varchar](500) NULL,
	[siteversion] [decimal](18, 3) NULL DEFAULT ((2.232)),
	[mailss] int not null default 0,
	[sinablog] varchar(500) null,
	[qqblog] varchar(500) null,
	[jobtime] ntext null,
	[freepost] int not null default 0,
	[enablesohulogin] int not null default 0,
	[sohuloginkey] varchar(500) null,
	[title] varchar(500) null,
	[keyword] varchar(500) null,
	[description] varchar(200) null,
	[gouwuche] int not null default 0,
	[needmoretuan] int not null default 0,
	[guowushu] int not null default 0,
	[tuanphone] varchar(50) null,
)

;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Team' AND type = 'U')
   DROP table [Team];  

;
CREATE TABLE [Team](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[User_id] [int] NOT NULL,
	[Title] [varchar](500) NOT NULL,
	[Summary] [text] NULL,
	[City_id] [int] NOT NULL DEFAULT ((0)),
	[Group_id] [int] NOT NULL DEFAULT ((0)),
	[Partner_id] [int] NOT NULL DEFAULT ((0)),
	[System] [varchar](1) NOT NULL,
	[Team_price] [decimal](18, 2) NOT NULL,
	[Market_price] [decimal](18, 2) NOT NULL,
	[Product] [varchar](500) NOT NULL,
	[Per_number] [int] NOT NULL DEFAULT ((0)),
	[Min_number] [int] NOT NULL DEFAULT ((1)),
	[Max_number] [int] NOT NULL DEFAULT ((0)),
	[Now_number] [int] NOT NULL DEFAULT ((0)),
	[Manualupdate] [int] NOT NULL DEFAULT ((0)),
	[Image] [varchar](128) NOT NULL,
	[Image1] [varchar](128) NULL,
	[Image2] [varchar](128) NULL,
	[Flv] [varchar](128) NULL,
	[Mobile] [varchar](16) NULL,
	[Credit] [int] NOT NULL DEFAULT ((0)),
	[Card] [int] NOT NULL DEFAULT ((0)),
	[Fare] [int] NOT NULL DEFAULT ((0)),
	[Farefree] [int] NOT NULL DEFAULT ((0)),
	[Bonus] [int] NULL,
	[Address] [varchar](128) NULL,
	[Detail] [text] NULL,
	[Systemreview] [text] NULL,
	[Userreview] [text] NULL,
	[Notice] [text] NULL,
	[Express] [text] NULL,
	[Delivery] [varchar](10) NOT NULL DEFAULT ('coupon'),
	[State] [varchar](10) NOT NULL DEFAULT ('none'),
	[Conduser] [varchar](1) NOT NULL DEFAULT ('N'),
	[Buyonce] [varchar](1) NOT NULL DEFAULT ('Y'),
	[Team_type] [varchar](20) NOT NULL DEFAULT ('''normal'''),
	[Sort_order] [int] NOT NULL DEFAULT ((0)),
	[Expire_time] [datetime] NOT NULL DEFAULT (getdate()),
	[Begin_time] [datetime] NOT NULL DEFAULT (getdate()),
	[End_time] [datetime] NOT NULL DEFAULT (getdate()),
	[Reach_time] [datetime] NULL,
	[Close_time] [datetime] NULL,
	[bulletin] [text] null,
	[update_value] [int] not null default 0,
	[time_state] [int] not null default 0,
	[time_interval] [int] not null default 0,
	[autolimit] int not null default 0,
	[freighttype] int not null default 0,
	[start_time] datetime null,
    [inventory] int not null default 0,
	[invent_war] int not null default 0,
	[invent_result] varchar(4000) null,
	[teamscore] int not null default 0,
	[score] int not null default 0,
	[seotitle] varchar(500) null,
	[seokeyword] varchar(500) null,
	[seodescription] varchar(2000) null,
	[brand_id] int not null default 0,
	[open_invent] int not null default 0,
	[open_war] int not null default 0,
	[warmobile] varchar(500) null,
	[Per_minnumber] int not null default 0,
	[shanhu] int not null default 0,
	[codeswitch] varchar(50) not null default 'no',
	[othercity] varchar(2000) null,
	[cataid] int not null default 0,
	[teamhost] int not null default 0,
	[teamnew] int not null default 0,
	[catakey] varchar(4000) null,
	[apiopen] int not null default 0,
	[commentscore] decimal(18,2) not null default 0,
	[cost_price] decimal(18,2) not null default 0,
	[teamway] varchar(1) not null default 'Y',
	[productid] int not null default 0,
	[drawtype] int not null default 0,
	[status] int not null default 1,
	[sale_id] int not null default 0,
	[isPredict] int null,
	teamcata int not null default 0,
	level_cityid int not null default 0,
	mallstatus int not null default 1,
	areaid int not null default 0,
	circleid int not null default 0,
	isrefund varchar(1) not null default 'N',
	cashOnDelivery varchar(1) null,
	branch_id int default 0,

)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'inventorylog' AND type = 'U')
   DROP table [inventorylog]  
;
create table inventorylog
(
id int identity(1,1) not null primary key,
num int not null ,
orderid int not null default 0,
adminid int not null default 0, 
state int not null default 0, 
create_time datetime not null default getdate(), 
remark varchar(2000) null,
teamid int not null,
type int not null default 0,
) 
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'topic' AND type = 'U')
   DROP table [topic]  

;
CREATE TABLE [topic](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[Parent_id] [int] NOT NULL DEFAULT ((0)),
	[User_id] [int] NOT NULL,
	[Title] [varchar](128)  NULL,
	[Team_id] [int] NOT NULL DEFAULT ((0)),
	[City_id] [int] NOT NULL DEFAULT ((0)),
	[Public_id] [int] NOT NULL DEFAULT ((0)),
	[Content] [text] NULL,
	[Head] [bigint] NOT NULL DEFAULT ((0)),
	[Reply_number] [int] NOT NULL DEFAULT ((0)),
	[View_number] [int] NOT NULL DEFAULT ((0)),
	[Last_user_id] [int] NOT NULL DEFAULT ((0)),
	[Last_time] [datetime] NOT NULL  DEFAULT (getdate()),
	[create_time] [datetime] NOT NULL DEFAULT (getdate()),
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'User' AND type = 'U')
   DROP table [User]  

;
CREATE TABLE [User](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[Email] [varchar](128) NOT NULL,
	[Username] [varchar](500) NOT NULL,
	[Realname] [varchar](128) NULL,
	[Password] [varchar](32) NOT NULL,
	[Avatar] [varchar](128) NULL,
	[Gender] [varchar](2) NULL,
	[Newbie] [varchar](1) NOT NULL DEFAULT ('N'),
	[Mobile] [varchar](16) NULL,
	[Qq] [varchar](16) NULL,
	[Money] [decimal](18, 2) NOT NULL DEFAULT ((0)),
	[Score] [int] NOT NULL DEFAULT ((0)),
	[Zipcode] [varchar](16) NULL,
	[Address] [varchar](255)  NULL,
	[City_id] [int] NOT NULL DEFAULT ((0)),
	[Enable] [varchar](1) NOT NULL DEFAULT ((1)),
	[Manager] [varchar](1) NOT NULL DEFAULT ('N'),
	[Secret] [varchar](32) NULL,
	[Recode] [varchar](32) NULL,
	[Sns] [varchar](32) NULL,
	[IP] [varchar](16) NOT NULL,
	[Login_time] [datetime] NOT NULL DEFAULT (getdate()),
	[Create_time] [datetime] NOT NULL DEFAULT (getdate()),
	[msn] [varchar](128) NULL,
	[auth] [varchar](50) NULL,
	[IP_Address] [varchar](500) null,
	[fromdomain] [varchar](500) null,
	[userscore] int not null default 0,
	[totalamount] decimal(18,2) not null default 0,
	[ucsyc] varchar(500) not null default 'nosys',
	[yizhantong]  varchar(4000) null,
	Signmobile varchar(50) null,
	Sign_time datetime null,
	[IsManBranch] varchar(1) null,
)

;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'vote_feedback' AND type = 'U')
   DROP table [vote_feedback] 

;
CREATE TABLE [vote_feedback](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[Username] [varchar](32) NULL,
	[User_id] [int] NOT NULL DEFAULT ((0)),
	[Ip] [varchar](16) NOT NULL,
	[Addtime] [datetime] NOT NULL DEFAULT (getdate()),
 )
;

IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'cps' AND type = 'U')
   DROP table [cps] 

;
CREATE TABLE [cps](
	[id] [int] IDENTITY(1,1)  NOT NULL PRIMARY KEY,
	[channelId] [varchar](500) NULL,
	[u_id] [int] NOT NULL   DEFAULT ((0)),
	[order_id] [int] NOT NULL,
	[result] [varchar](1000)  NULL,
	[value1] [varchar](500)  NULL,
	[username] [varchar](500)  NULL,
	[tracking_code] [varchar](200)  NULL,
)
;


IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'vote_feedback_input' AND type = 'U')
   DROP table [vote_feedback_input]  
 
 ;
CREATE TABLE [vote_feedback_input](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[feedback_id] [int] NOT NULL,
	[options_id] [int] NOT NULL,
	[value] [varchar](256) NOT NULL,
 )


;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'vote_feedback_question' AND type = 'U')
   DROP table [vote_feedback_question]  

;
CREATE TABLE [vote_feedback_question](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[feedback_id] [int] NOT NULL,
	[question_id] [int] NOT NULL,
	[options_id] [int] NOT NULL,
 )
 
 
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Invite' AND type = 'U')
   DROP table Invite   
 
 ;
CREATE TABLE [Invite](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[User_id] [int] NOT NULL,
	[Admin_id] [int] NOT NULL  DEFAULT ((0)),
	[User_ip] [varchar](16)  NULL,
	[Other_user_id] [int] NOT NULL,
	[Other_user_ip] [varchar](16) NULL,
	[Team_id] [int] NOT NULL  DEFAULT ((0)),
	[Pay] [varchar](1) NOT NULL  DEFAULT ('N'),
	[Credit] [int] NOT NULL  DEFAULT ((0)),
	[Buy_time] [datetime] NULL,
	[Create_time] [datetime] NOT NULL  DEFAULT (getdate()),
)
 

;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'vote_options' AND type = 'U')
   DROP table vote_options  
 
 ;
CREATE TABLE [vote_options](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[question_id] [int] NOT NULL,
	[name] [varchar](60) NOT NULL,
	[is_br] [int] NOT NULL DEFAULT ((0)),
	[is_input] [int] NOT NULL DEFAULT ((0)),
	[is_show] [int] NOT NULL DEFAULT ((1)),
	[order] [int] NOT NULL DEFAULT ((0)),
)



;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'vote_question' AND type = 'U')
   DROP table vote_question 

;
CREATE TABLE [vote_question](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[Title] [varchar](100) NOT NULL,
	[Type] [varchar](50) NOT NULL DEFAULT ('radio'),
	[is_show] [int] NOT NULL DEFAULT ((1)),
	[Addtime] [datetime] NOT NULL DEFAULT (getdate()),
	[order] [int] NOT NULL DEFAULT ((0)),
 )
 
;
insert into system(id,sitename,headlogo,footlogo,emaillogo,printlogo,siteversion)values(1,'艾尚团购','/upfile/img/logo.png','/upfile/img/logo-footer.png','/upfile/img/mail-tpl-logo.png','/upfile/img/coupon-tpl-logo.jpg',3.0)

;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Friendlink' AND type = 'U')
   DROP table Friendlink  
 
 ;
CREATE TABLE [Friendlink](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[Title] [varchar](255) NULL,
	[url] [varchar](255) NULL,
	[Logo] [varchar](255) NULL,
	[Sort_order] [int] NOT NULL DEFAULT ((0))
)

;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Location' AND type = 'U')
   DROP table [Location]
;
CREATE TABLE [Location](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[locationname] text NULL,
	[pageurl] [varchar](100) NULL,
	[image] [varchar](200) NULL,
	[location] [int] not null default 0,
	[createdate] [datetime] NULL default getdate(),
	[visibility] [int] NOT NULL default 0,
	[type] [int] not null default 0,
	[width] [varchar](50) NULL,
	[height] [varchar](50) NULL,
	[decpriction] [varchar](2000) null,
	[begintime] datetime not null default getdate(),
	[endtime] datetime not null default DATEADD(day,7,getdate()),
	[cityid] varchar(4000) not null default '0',
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'template_print' AND type = 'U')
   DROP table [template_print]
;
CREATE TABLE template_print(
	id int identity(1,1) primary key not null,
	template_name varchar(500) not null,
	template_value text null,
)
;
insert into template_print(template_name,template_value)values('yuantong','{"width":881,"height":480,"image":"upfile/print/20101205131808.jpg","value":[{"name":"border1","top":92,"left":119,"width":60,"height":16},{"name":"border2","top":220,"left":151,"width":96,"height":15},{"name":"border4","top":170,"left":63,"width":334,"height":26},{"name":"border6","top":110,"left":477,"width":64,"height":16},{"name":"border7","top":222,"left":509,"width":123,"height":16},{"name":"border8","top":174,"left":424,"width":351,"height":25},{"name":"border3","top":120,"left":131,"width":253,"height":25},{"name":"border10","top":198,"left":543,"width":230,"height":25},{"name":"border11","top":196,"left":168,"width":228,"height":25}]}')
;
insert into template_print(template_name,template_value)values('huitongkuaidi','{"width":881,"height":480,"image":"upfile/print/20101205131852.jpg","value":[{"name":"border1","top":109,"left":124,"width":115,"height":25},{"name":"border2","top":254,"left":167,"width":116,"height":25},{"name":"border3","top":143,"left":115,"width":290,"height":21},{"name":"border4","top":190,"left":70,"width":335,"height":30},{"name":"border10","top":221,"left":123,"width":282,"height":30},{"name":"border6","top":111,"left":489,"width":129,"height":22},{"name":"border8","top":173,"left":478,"width":308,"height":39},{"name":"border7","top":254,"left":537,"width":124,"height":25},{"name":"border11","top":213,"left":533,"width":254,"height":38}]}')
;
insert into template_print(template_name,template_value)values('shentong','{"width":881,"height":480,"image":"upfile/print/20101205132756.jpg","value":[{"name":"border1","top":106,"left":130,"width":111,"height":25},{"name":"border2","top":246,"left":157,"width":115,"height":23},{"name":"border3","top":140,"left":116,"width":288,"height":25},{"name":"border4","top":170,"left":118,"width":293,"height":35},{"name":"border6","top":110,"left":494,"width":110,"height":21},{"name":"border8","top":170,"left":478,"width":309,"height":35},{"name":"border7","top":247,"left":521,"width":233,"height":23},{"name":"border11","top":209,"left":174,"width":228,"height":25},{"name":"border10","top":210,"left":533,"width":254,"height":25}]}')
;
insert into template_print(template_name,template_value)values('shunfeng','{"width":881,"height":570,"image":"upfile/print/20101205133129.jpg","value":[{"name":"border1","top":159,"left":319,"width":72,"height":25},{"name":"border2","top":249,"left":181,"width":160,"height":25},{"name":"border3","top":160,"left":113,"width":164,"height":25},{"name":"border4","top":188,"left":104,"width":286,"height":25},{"name":"border11","top":217,"left":155,"width":236,"height":25},{"name":"border6","top":292,"left":321,"width":72,"height":25},{"name":"border7","top":407,"left":199,"width":190,"height":24},{"name":"border8","top":321,"left":103,"width":286,"height":46},{"name":"border10","top":371,"left":163,"width":226,"height":35}]}')
;
insert into template_print(template_name,template_value)values('yunda','{"width":881,"height":506,"image":"upfile/print/20101205133458.jpg","value":[{"name":"border1","top":87,"left":111,"width":104,"height":25},{"name":"border3","top":111,"left":134,"width":270,"height":25},{"name":"border4","top":138,"left":105,"width":308,"height":34},{"name":"border2","top":244,"left":145,"width":103,"height":25},{"name":"border11","top":178,"left":167,"width":246,"height":39},{"name":"border5","top":253,"left":306,"width":106,"height":18},{"name":"border7","top":86,"left":678,"width":122,"height":20},{"name":"border6","top":242,"left":479,"width":160,"height":25},{"name":"border9","top":250,"left":693,"width":106,"height":16},{"name":"border10","top":178,"left":526,"width":273,"height":40},{"name":"border8","top":137,"left":471,"width":325,"height":38}]}')
;
insert into template_print(template_name,template_value)values('zhaijisong','{"width":881,"height":535,"image":"upfile/print/20101205134227.jpg","value":[{"name":"border1","top":141,"left":126,"width":94,"height":26},{"name":"border2","top":231,"left":100,"width":130,"height":25},{"name":"border3","top":200,"left":115,"width":286,"height":17},{"name":"border11","top":215,"left":207,"width":212,"height":20},{"name":"border4","top":170,"left":82,"width":324,"height":25},{"name":"border6","top":280,"left":122,"width":100,"height":15},{"name":"border8","top":308,"left":81,"width":333,"height":17},{"name":"border7","top":368,"left":102,"width":126,"height":25},{"name":"border10","top":325,"left":224,"width":191,"height":23}]}')
;
insert into template_print(template_name,template_value)values('zhongtong','{"width":881,"height":480,"image":"upfile/print/20101205134622.jpg","value":[{"name":"border1","top":109,"left":144,"width":96,"height":25},{"name":"border2","top":244,"left":143,"width":121,"height":25},{"name":"border5","top":247,"left":303,"width":99,"height":23},{"name":"border3","top":200,"left":135,"width":268,"height":25},{"name":"border4","top":139,"left":144,"width":260,"height":30},{"name":"border11","top":173,"left":126,"width":276,"height":25},{"name":"border6","top":109,"left":497,"width":108,"height":25},{"name":"border7","top":246,"left":498,"width":116,"height":23},{"name":"border9","top":250,"left":665,"width":95,"height":20},{"name":"border10","top":170,"left":504,"width":254,"height":25},{"name":"border8","top":140,"left":497,"width":264,"height":30}]}')
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'faretemplate' AND type = 'U')
   DROP table [faretemplate]
;
create table faretemplate
(
	id int identity(1,1) primary key not null,
	name varchar(500) not null,
	value text null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'faretemplate_details' AND type = 'U')
   DROP table [faretemplate_details]
;
create table faretemplate_details
(
	id int identity(1,1) primary key not null,
	templateid int not null,
	cityname varchar(500) not null,
	cityid int not null default 0,
	onefare decimal(18,2) not null,
	number int not null,
	fareadd decimal(18,2) not null,
	
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'farecitys' AND type = 'U')
   DROP table [farecitys]
;
create table farecitys
(
	id int identity(1,1) primary key not null,
	pid int not null default 0,
	name varchar(500) not null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'expressprice' AND type = 'U')
   DROP table [expressprice]
;
create table expressprice
(
	id int identity(1,1) primary key not null,
	expressid int not null, 
	oneprice decimal(18,2) not null , 
	twoprice decimal(18,2) not null ,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'userreview' AND type = 'U')
   DROP table [userreview]
;
create table userreview
(
    id int identity(1,1) primary key not null,
    user_id int not null,
    team_id int not null,
    create_time datetime not null,
    comment varchar(2000) null,
    score int not null default 0, 
    rebate_time datetime null,
    rebate_price decimal(18,2) not null default 0,
    [state] int not null default 0,
    admin_id int not null default 0,
	[isgo] int null,
	[partner_id] int null,
	[type] varchar(30) null,
)
;

if not exists(select id from sysobjects where type='U' and name='Packet')
CREATE TABLE [Packet](
	[Id] [int] IDENTITY(1,1) NOT NULL primary key,
	[User_Id] [int] NOT NULL  DEFAULT ((0)),
	[Money] [decimal](18, 2) NULL,
	[Number] [varchar](16)  NULL,
	[Admin_Id] [int] NOT NULL DEFAULT ((0)),
	[Type] [varchar](16)  NOT NULL,
	[State] [int] NOT NULL   DEFAULT ((0)),
	[Send_Time] [datetime] NOT NULL,
	[Get_Time] [datetime] NULL,

) 
;

if not exists(select id from sysobjects where type='U' and name='Smssubscribedetail')
CREATE TABLE [Smssubscribedetail](
	[id] [int] IDENTITY(1,1) NOT NULL primary key,
	[teamid] [int] NULL,
	[mobile] [varchar](30)  NULL,
	[sendtime] [int] NULL  DEFAULT ((9)),
	[issend] [int] NOT NULL  DEFAULT ((0)),
 
)
;


IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'expressnocitys' AND type = 'U')
   DROP table [expressnocitys]
;
create table expressnocitys
(
	id int identity(1,1) primary key not null,
	expressid int not null,
	nocitys varchar(6000) null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'news' AND type = 'U')
   DROP table [news]
;
create table news
(
  	id int identity(1,1) primary key not null,
    title varchar(1000) not null, 
    content text null,
    create_time datetime not null default getdate(),
    type int not null default 0, 
    link varchar(500) null,
    adminid int not null,
    seotitle varchar(500) null,
    seokeyword varchar(500) null,
    seodescription varchar(2000) null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'mailserver' AND type = 'U')
   DROP table [mailserver]
;
create table mailserver
(
   id int identity(1,1) primary key not null,
   smtphost varchar(500) not null,
   smtpport int not null default 25,
   ssl int not null default 0,
   mailuser varchar(500) null,
   realname varchar(500) null,
   mailpass varchar(500) null,
   sendmail varchar(500) null,
   receivemail varchar(500) null,
   sendcount int not null default 5,
)
;

IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'draw' AND type = 'U')
   DROP table draw   
 
 ;
create table [draw]
(
	id int identity(1,1) primary key not null, 
	userid int not null default 0,
	createtime datetime not null default getdate(),
	number varchar(500) not null,
	teamid int not null default 0,
	orderid int not null default 0,
	inviteid int not null default 0,
	state varchar(1) null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'pcoupon' AND type = 'U')
   DROP table pcoupon   
 
 ;
create table [pcoupon]
(
	id int identity(1,1) primary key,
	number varchar(500) not null,
	userid int not null default 0,
	partnerid int not null default 0,
	teamid int not null,
	create_time datetime not null default getdate(),
	buy_time datetime null, 
	state varchar(500) not null default 'nobuy', 
	start_time datetime not null  default getdate(),
	expire_time datetime not null,
	orderid int not null default 0,
	sms int not null default 0,
	sms_time datetime  null ,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'catalogs' AND type = 'U')
   DROP table catalogs   
 
 ;
create table [catalogs]
(
	id int identity(1,1) primary key,
	catalogname varchar(500) not null,
	sort_order int not null default 0,
	parent_id int not null default 0,
	ids varchar(4000) not null,
	keyword varchar(4000) null,
	keytop int not null default 0,
	visibility int not null default 0,
	catahost int not null default 0,
	cityid varchar(2000) null,
	[image] varchar(128) null,
	url varchar(128) null,
	[type] int not null default 0,
	location int not null default 0,
	[image1] varchar(128) null,
	url1 varchar(128) null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'guid' AND type = 'U')
   DROP table guid   
 
 ;
create table [guid]
(
    [id] int identity(1,1) primary key,
    [guidtitle] varchar(500) not null,
    [guidlink]  varchar(500) not null,
    [guidopen] int not null default 0,
    [guidparent] int not null default 0,
    [guidsort]  int  not null default 0,
    [createtime] datetime not null default getdate(),
	teamormall int not null default 0,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'yizhantong' AND type = 'U')
   DROP table yizhantong   
 
;
create table [yizhantong]
(
   [id] int identity(1,1) primary key,
   [name] varchar(500) not null,
   [userid] int not null,
   [safekey] varchar(200) null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'product' AND type = 'U')
   DROP table product   
 
;
create table [product]
(
   [id] int identity(1,1) primary key,
	[productname] varchar(500) not null,
	[price] decimal(18,2) not null default 0,
	[inventory] int not null default 0,
	[imgurl] varchar(500) null,
	[detail] text null,
	[sortorder] int not null default 0,
	[createtime] datetime not null default getdate(),
	[status] int not null default 0,
	[bulletin] text null,
	[open_invent] int not null default 0,
	[partnerid] int not null default 0,
	[invent_result] varchar(4000) null,
	[team_price] decimal(18,2) not null default 0,
	[brand_id] int not null default 0,
	[summary] text null,
	[adminid] int not null default 0,
	[operatortype] int not null default 0,
	[ramark] text null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Partner_Detail' AND type = 'U')
   DROP table Partner_Detail   
 
;
create table [Partner_Detail]
(
   [id] int identity(1,1) primary key not null,
	[partnerid] int not null,
	[createtime] datetime not null default getdate(),
	[adminid] int not null default 0,
	[money] decimal(18,2) not null default 0,
	[remark] varchar(2000) null,
	[settlementremark] text null,
	[settlementstate] int  not null default 8,
	[team_id] int not null default 0,
	[num] int not null default 0,

)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'branch' AND type = 'U')
   DROP table branch   
 
;
create table [branch]
(
	[id] int identity(1,1) primary key,
	[partnerid] int not null,
	[branchname] varchar(500) not null,
	[contact] varchar(500) null,
	[phone] varchar(500) null,
	[address] varchar(500) null,
	[mobile] varchar(500) null,
	[point] varchar(500) null,
	[secret] varchar(500) not null,
	[verifymobile] varchar(50) null,
	[username] varchar(500) null,
	[userpwd] varchar(500) null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'refunds_detail' AND type = 'U')
   DROP table refunds_detail   
 
;
CREATE TABLE [refunds_detail](
    Id int not null identity(1,1) primary key, 
  	[refunds_id] [int] NOT NULL,
	[teamnum] [int] NOT NULL,
	[teamid] [int] NOT NULL,
) 
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'refunds' AND type = 'U')
   DROP table refunds   
 
;
CREATE TABLE [refunds](
    Id int not null identity(1,1) primary key, 
  	[State] [int] NOT NULL,
	[Create_Time] [datetime] NULL,
	[PartnerViewTime] [datetime] NULL,
	[Order_ID] [int] NOT NULL,
	[Money] [decimal](18, 2) NOT NULL,
	[PartnerID] [int] NOT NULL,
	[FinanceBeginTime] [datetime] NULL,
	[FinanceEndTime] [datetime] NULL,
	[RefundMeans] [int] NOT NULL,
	[Reason] [varchar](4000) NULL,
	[Result] [varchar](4000) NULL,
	[CreateUserID] [int] NOT NULL,
	[AdminID] [int] NULL,
) 
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'sales' AND type = 'U')
   DROP table sales   
 
;
create table [sales]
(
	[id] int identity(1,1) primary key,
	[username] varchar(500) not null,
	[password] varchar(500) not null,
	[realname] varchar(500)  null,
	[contact] varchar(500)  null,
)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'Adjunct' AND type = 'U')
   DROP table Adjunct   
 
;
CREATE TABLE [Adjunct](
	[id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[url] [varchar](500) NOT NULL,
	[decription] nvarchar(300) null,
	[sort] [int] NOT NULL default (0),
	[display] int NOT NULL default (1),
	[uploadTime] datetime  default (getdate()),
) 
;

if not exists(select guidtitle from guid where guidtitle='今日团购')insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('今日团购','/index.aspx',0,0,999,0)
;
if not exists(select guidtitle from guid where guidtitle='往期团购')insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('往期团购','/team/index.html',0,0,998,0)
;
if not exists(select guidtitle from guid where guidtitle='热销商品')insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('热销商品','/team/goods.html',1,0,997,0)
;
if not exists(select guidtitle from guid where guidtitle='秒杀抢团')insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('秒杀抢团','/team/seconds.html',1,0,996,0)
;
if not exists(select guidtitle from guid where guidtitle='品牌商户')insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('品牌商户','/partner/index.html',1,0,995,0)
;
if not exists(select guidtitle from guid where guidtitle='购物车')insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('购物车','/shopcart/show.html',1,0,994,0)
;
insert into guid(guidtitle,guidlink,guidopen,guidparent,teamormall)values('团购地图','/team/maps.html',1,0,0)
;
if not exists(select guidtitle from guid where guidtitle='积分商城')insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('积分商城','/PointsShop/PointList.html',1,0,993,0)
;
if not exists(select guidtitle from guid where guidtitle='团购达人')insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('团购达人','/help/tour.html',1,0,992,0)
;
if not exists(select guidtitle from guid where guidtitle='讨论区')insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('讨论区','/forum/index.html',1,0,991,0)
;
if not exists(select guidtitle from guid where guidtitle='到货评价')insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('到货评价','/buy/list_comments.html',1,0,990,0)
;
if not exists(select guidtitle from guid where guidtitle='团购预告')insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('团购预告','/team/predict.html',1,0,989,0)
;
if not exists(select guidtitle from guid where guidtitle='艾尚商城' and teamormall=0)insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('艾尚商城','/mall/index.html',1,0,988,0)
;
if not exists(select guidtitle from guid where guidtitle='艾尚商城' and teamormall=1)insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('艾尚商城','/mall/index.html',0,0,988,1)
;
if not exists(select guidtitle from guid where guidtitle='品牌大全' and teamormall=1)insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('品牌大全','/mall/brand/list.html',0,0,987,1)
;
if not exists(select guidtitle from guid where guidtitle='今日团购' and teamormall=1)insert into [guid](guidtitle,guidlink,guidopen,guidparent,guidsort,teamormall)values('今日团购','/index.aspx',0,0,986,1)
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'smstemplate' AND type = 'U')
   DROP table smstemplate   
 
 ;
create table [smstemplate]
(
   name varchar(50) not null primary key,
   value text null,
)
;
if not exists(select name from smstemplate where name='couponsms')insert into [smstemplate](name,value)values('couponsms','项目：{商品名称}，券号：{券号}，密码：{密码}，有效期：{优惠券开始时间}至{优惠券结束时间}。【{网站简称}】')
;
if not exists(select name from smstemplate where name='orderpay')insert into [smstemplate](name,value)values('orderpay','{用户名}您好，您在{网站简称}下了订单，订单号：{订单号},订单金额：{订单总金额}。敬请查收。【{网站简称}】')
;
if not exists(select name from smstemplate where name='delivery')insert into [smstemplate](name,value)values('delivery','{网站简称}会员{用户名},您好 您的订单{订单号}已由{快递公司}发出，快递单号为:{快递单号},您可登陆{快递公司}查询物流信息。【{网站简称}】')
;
if not exists(select name from smstemplate where name='overtime')insert into [smstemplate](name,value)values('overtime','您在{网站简称} 有{商品名称}的未消费的优惠券：{优惠券号}即将到期【到期时间：{到期时间}】，请及时使用。【{网站简称}】')
;
if not exists(select name from smstemplate where name='consumption')insert into [smstemplate](name,value)values('consumption','尊敬的{网站简称}会员，{用户名}，您的券号{券号}已于{消费时间}被消费。【{网站简称}】')
;
if not exists(select name from smstemplate where name='drawcode')insert into [smstemplate](name,value)values('drawcode','{用户名},欢迎您参加{商品名称}活动，你的认证码为{认证码}，祝您好运【{网站简称}】。')
;
if not exists(select name from smstemplate where name='subscribe')insert into [smstemplate](name,value)values('subscribe','短信订阅，您的手机号：{手机号码} 短信订阅认证码：{认证码}。【{网站简称}】')
;
if not exists(select name from smstemplate where name='qxsubscribe')insert into [smstemplate](name,value)values('qxsubscribe','短信退订，您的手机号：{手机号码}短信退订认证码：{认证码}。【{网站简称}】')
;
if not exists(select name from smstemplate where name='inventory')insert into [smstemplate](name,value)values('inventory','库存提醒，项目编号：{项目编号}.库存已不足，请及时入库')
;
if not exists(select name from smstemplate where name='nowteam')insert into [smstemplate](name,value)values('nowteam','今日团购:{商品名称}。【{网站简称}】')
;
if not exists(select name from smstemplate where name='bizcouponsms')insert into [smstemplate](name,value)values('bizcouponsms','项目：{商品名称}，{商户优惠券}，有效期：{优惠券开始时间}至{优惠券结束时间}。【{网站简称}】')
;
if not exists(select name from smstemplate where name='orderpartner')insert into smstemplate(name,value)values('orderpartner','有新订单:{订单号},购买了{商品名称}数量{购买数量},{收货人} {收货地址} {联系电话} {订单备注}【{网站简称}】')
;
if not exists(select name from smstemplate where name='usersign')insert into smstemplate(name,value)values('usersign','{网站简称},您的手机号：{手机号码} 绑定码：{绑定码}.【{网站简称}】')
;
if not exists(select name from smstemplate where name='orderteam')insert into smstemplate ([name], [value]) values('orderteam','您好，您在{网站简称}订阅的{商品名称}已经开团了,请及时关注。' )
;
if not exists(select name from smstemplate where name='mobilecode')insert into smstemplate ([name], [value]) values('mobilecode','您的手机号：{手机号码}在{网站简称}注册的短信验证码为：{认证码}' )
;
SET IDENTITY_INSERT [farecitys] ON
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1, 0, CONVERT(TEXT, N'北京'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2, 1, CONVERT(TEXT, N'北京市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3, 2, CONVERT(TEXT, N'东城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (4, 2, CONVERT(TEXT, N'西城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (5, 2, CONVERT(TEXT, N'崇文区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (6, 2, CONVERT(TEXT, N'宣武区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (7, 2, CONVERT(TEXT, N'朝阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (8, 2, CONVERT(TEXT, N'丰台区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (9, 2, CONVERT(TEXT, N'石景山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (10, 2, CONVERT(TEXT, N'海淀区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (11, 2, CONVERT(TEXT, N'门头沟区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (12, 2, CONVERT(TEXT, N'房山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (13, 2, CONVERT(TEXT, N'通州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (14, 2, CONVERT(TEXT, N'顺义区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (15, 2, CONVERT(TEXT, N'昌平区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (16, 2, CONVERT(TEXT, N'大兴区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (17, 2, CONVERT(TEXT, N'怀柔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (18, 2, CONVERT(TEXT, N'平谷区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (19, 2, CONVERT(TEXT, N'密云县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (20, 2, CONVERT(TEXT, N'延庆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (21, 0, CONVERT(TEXT, N'上海'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (22, 21, CONVERT(TEXT, N'上海市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (23, 22, CONVERT(TEXT, N'黄浦区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (24, 22, CONVERT(TEXT, N'卢湾区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (25, 22, CONVERT(TEXT, N'徐汇区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (26, 22, CONVERT(TEXT, N'长宁区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (27, 22, CONVERT(TEXT, N'静安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (28, 22, CONVERT(TEXT, N'普陀区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (29, 22, CONVERT(TEXT, N'闸北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (30, 22, CONVERT(TEXT, N'虹口区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (31, 22, CONVERT(TEXT, N'杨浦区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (32, 22, CONVERT(TEXT, N'闵行区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (33, 22, CONVERT(TEXT, N'宝山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (34, 22, CONVERT(TEXT, N'嘉定区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (35, 22, CONVERT(TEXT, N'浦东新区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (36, 22, CONVERT(TEXT, N'金山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (37, 22, CONVERT(TEXT, N'松江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (38, 22, CONVERT(TEXT, N'青浦区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (39, 22, CONVERT(TEXT, N'南汇区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (40, 22, CONVERT(TEXT, N'奉贤区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (41, 22, CONVERT(TEXT, N'崇明县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (42, 0, CONVERT(TEXT, N'天津'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (43, 42, CONVERT(TEXT, N'天津市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (44, 43, CONVERT(TEXT, N'和平区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (45, 43, CONVERT(TEXT, N'河东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (46, 43, CONVERT(TEXT, N'河西区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (47, 43, CONVERT(TEXT, N'南开区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (48, 43, CONVERT(TEXT, N'河北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (49, 43, CONVERT(TEXT, N'红桥区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (50, 43, CONVERT(TEXT, N'塘沽区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (51, 43, CONVERT(TEXT, N'汉沽区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (52, 43, CONVERT(TEXT, N'大港区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (53, 43, CONVERT(TEXT, N'东丽区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (54, 43, CONVERT(TEXT, N'西青区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (55, 43, CONVERT(TEXT, N'津南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (56, 43, CONVERT(TEXT, N'北辰区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (57, 43, CONVERT(TEXT, N'武清区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (58, 43, CONVERT(TEXT, N'宝坻区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (59, 43, CONVERT(TEXT, N'宁河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (60, 43, CONVERT(TEXT, N'静海县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (61, 43, CONVERT(TEXT, N'蓟县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (62, 0, CONVERT(TEXT, N'重庆'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (63, 62, CONVERT(TEXT, N'重庆市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (64, 63, CONVERT(TEXT, N'万州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (65, 63, CONVERT(TEXT, N'涪陵区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (66, 63, CONVERT(TEXT, N'渝中区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (67, 63, CONVERT(TEXT, N'大渡口区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (68, 63, CONVERT(TEXT, N'江北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (69, 63, CONVERT(TEXT, N'沙坪坝区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (70, 63, CONVERT(TEXT, N'九龙坡区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (71, 63, CONVERT(TEXT, N'南岸区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (72, 63, CONVERT(TEXT, N'北碚区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (73, 63, CONVERT(TEXT, N'万盛区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (74, 63, CONVERT(TEXT, N'双桥区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (75, 63, CONVERT(TEXT, N'渝北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (76, 63, CONVERT(TEXT, N'巴南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (77, 63, CONVERT(TEXT, N'黔江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (78, 63, CONVERT(TEXT, N'长寿区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (79, 63, CONVERT(TEXT, N'綦江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (80, 63, CONVERT(TEXT, N'潼南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (81, 63, CONVERT(TEXT, N'铜梁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (82, 63, CONVERT(TEXT, N'大足县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (83, 63, CONVERT(TEXT, N'荣昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (84, 63, CONVERT(TEXT, N'璧山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (85, 63, CONVERT(TEXT, N'梁平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (86, 63, CONVERT(TEXT, N'城口县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (87, 63, CONVERT(TEXT, N'丰都县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (88, 63, CONVERT(TEXT, N'垫江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (89, 63, CONVERT(TEXT, N'武隆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (90, 63, CONVERT(TEXT, N'忠县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (91, 63, CONVERT(TEXT, N'开县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (92, 63, CONVERT(TEXT, N'云阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (93, 63, CONVERT(TEXT, N'奉节县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (94, 63, CONVERT(TEXT, N'巫山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (95, 63, CONVERT(TEXT, N'巫溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (96, 63, CONVERT(TEXT, N'石柱土家族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (97, 63, CONVERT(TEXT, N'秀山土家族苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (98, 63, CONVERT(TEXT, N'酉阳土家族苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (99, 63, CONVERT(TEXT, N'彭水苗族土家族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (100, 63, CONVERT(TEXT, N'江津市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (101, 63, CONVERT(TEXT, N'合川市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (102, 63, CONVERT(TEXT, N'永川市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (103, 63, CONVERT(TEXT, N'南川市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (104, 0, CONVERT(TEXT, N'安徽'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (105, 104, CONVERT(TEXT, N'合肥市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (106, 105, CONVERT(TEXT, N'瑶海区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (107, 105, CONVERT(TEXT, N'庐阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (108, 105, CONVERT(TEXT, N'蜀山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (109, 105, CONVERT(TEXT, N'包河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (110, 105, CONVERT(TEXT, N'长丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (111, 105, CONVERT(TEXT, N'肥东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (112, 105, CONVERT(TEXT, N'肥西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (113, 104, CONVERT(TEXT, N'安庆市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (114, 113, CONVERT(TEXT, N'迎江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (115, 113, CONVERT(TEXT, N'大观区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (116, 113, CONVERT(TEXT, N'郊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (117, 113, CONVERT(TEXT, N'怀宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (118, 113, CONVERT(TEXT, N'枞阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (119, 113, CONVERT(TEXT, N'潜山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (120, 113, CONVERT(TEXT, N'太湖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (121, 113, CONVERT(TEXT, N'宿松县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (122, 113, CONVERT(TEXT, N'望江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (123, 113, CONVERT(TEXT, N'岳西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (124, 113, CONVERT(TEXT, N'桐城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (125, 104, CONVERT(TEXT, N'蚌埠市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (126, 125, CONVERT(TEXT, N'龙子湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (127, 125, CONVERT(TEXT, N'蚌山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (128, 125, CONVERT(TEXT, N'禹会区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (129, 125, CONVERT(TEXT, N'淮上区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (130, 125, CONVERT(TEXT, N'怀远县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (131, 125, CONVERT(TEXT, N'五河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (132, 125, CONVERT(TEXT, N'固镇县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (133, 104, CONVERT(TEXT, N'亳州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (134, 133, CONVERT(TEXT, N'谯城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (135, 133, CONVERT(TEXT, N'涡阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (136, 133, CONVERT(TEXT, N'蒙城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (137, 133, CONVERT(TEXT, N'利辛县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (138, 104, CONVERT(TEXT, N'巢湖市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (139, 138, CONVERT(TEXT, N'居巢区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (140, 138, CONVERT(TEXT, N'庐江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (141, 138, CONVERT(TEXT, N'无为县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (142, 138, CONVERT(TEXT, N'含山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (143, 138, CONVERT(TEXT, N'和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (144, 104, CONVERT(TEXT, N'池州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (145, 144, CONVERT(TEXT, N'贵池区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (146, 144, CONVERT(TEXT, N'东至县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (147, 144, CONVERT(TEXT, N'石台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (148, 144, CONVERT(TEXT, N'青阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (149, 104, CONVERT(TEXT, N'滁州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (150, 149, CONVERT(TEXT, N'琅琊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (151, 149, CONVERT(TEXT, N'南谯区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (152, 149, CONVERT(TEXT, N'来安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (153, 149, CONVERT(TEXT, N'全椒县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (154, 149, CONVERT(TEXT, N'定远县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (155, 149, CONVERT(TEXT, N'凤阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (156, 149, CONVERT(TEXT, N'天长市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (157, 149, CONVERT(TEXT, N'明光市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (158, 104, CONVERT(TEXT, N'阜阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (159, 158, CONVERT(TEXT, N'颍州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (160, 158, CONVERT(TEXT, N'颍东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (161, 158, CONVERT(TEXT, N'颍泉区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (162, 158, CONVERT(TEXT, N'临泉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (163, 158, CONVERT(TEXT, N'太和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (164, 158, CONVERT(TEXT, N'阜南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (165, 158, CONVERT(TEXT, N'颍上县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (166, 158, CONVERT(TEXT, N'界首市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (167, 104, CONVERT(TEXT, N'淮北市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (168, 167, CONVERT(TEXT, N'杜集区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (169, 167, CONVERT(TEXT, N'相山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (170, 167, CONVERT(TEXT, N'烈山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (171, 167, CONVERT(TEXT, N'濉溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (172, 104, CONVERT(TEXT, N'淮南市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (173, 172, CONVERT(TEXT, N'大通区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (174, 172, CONVERT(TEXT, N'田家庵区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (175, 172, CONVERT(TEXT, N'谢家集区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (176, 172, CONVERT(TEXT, N'八公山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (177, 172, CONVERT(TEXT, N'潘集区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (178, 172, CONVERT(TEXT, N'凤台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (179, 104, CONVERT(TEXT, N'黄山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (180, 179, CONVERT(TEXT, N'屯溪区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (181, 179, CONVERT(TEXT, N'黄山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (182, 179, CONVERT(TEXT, N'徽州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (183, 179, CONVERT(TEXT, N'歙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (184, 179, CONVERT(TEXT, N'休宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (185, 179, CONVERT(TEXT, N'黟县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (186, 179, CONVERT(TEXT, N'祁门县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (187, 104, CONVERT(TEXT, N'六安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (188, 187, CONVERT(TEXT, N'金安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (189, 187, CONVERT(TEXT, N'裕安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (190, 187, CONVERT(TEXT, N'寿县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (191, 187, CONVERT(TEXT, N'霍邱县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (192, 187, CONVERT(TEXT, N'舒城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (193, 187, CONVERT(TEXT, N'金寨县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (194, 187, CONVERT(TEXT, N'霍山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (195, 104, CONVERT(TEXT, N'马鞍山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (196, 195, CONVERT(TEXT, N'金家庄区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (197, 195, CONVERT(TEXT, N'花山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (198, 195, CONVERT(TEXT, N'雨山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (199, 195, CONVERT(TEXT, N'当涂县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (200, 104, CONVERT(TEXT, N'宿州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (201, 200, CONVERT(TEXT, N'墉桥区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (202, 200, CONVERT(TEXT, N'砀山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (203, 200, CONVERT(TEXT, N'萧县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (204, 200, CONVERT(TEXT, N'灵璧县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (205, 200, CONVERT(TEXT, N'泗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (206, 104, CONVERT(TEXT, N'铜陵市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (207, 206, CONVERT(TEXT, N'铜官山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (208, 206, CONVERT(TEXT, N'狮子山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (209, 206, CONVERT(TEXT, N'郊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (210, 206, CONVERT(TEXT, N'铜陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (211, 104, CONVERT(TEXT, N'芜湖市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (212, 211, CONVERT(TEXT, N'镜湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (213, 211, CONVERT(TEXT, N'马塘区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (214, 211, CONVERT(TEXT, N'新芜区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (215, 211, CONVERT(TEXT, N'鸠江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (216, 211, CONVERT(TEXT, N'芜湖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (217, 211, CONVERT(TEXT, N'繁昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (218, 211, CONVERT(TEXT, N'南陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (219, 104, CONVERT(TEXT, N'宣城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (220, 219, CONVERT(TEXT, N'宣州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (221, 219, CONVERT(TEXT, N'郎溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (222, 219, CONVERT(TEXT, N'广德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (223, 219, CONVERT(TEXT, N'泾县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (224, 219, CONVERT(TEXT, N'绩溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (225, 219, CONVERT(TEXT, N'旌德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (226, 219, CONVERT(TEXT, N'宁国市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (227, 0, CONVERT(TEXT, N'福建'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (228, 227, CONVERT(TEXT, N'福州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (229, 228, CONVERT(TEXT, N'鼓楼区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (230, 228, CONVERT(TEXT, N'台江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (231, 228, CONVERT(TEXT, N'仓山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (232, 228, CONVERT(TEXT, N'马尾区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (233, 228, CONVERT(TEXT, N'晋安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (234, 228, CONVERT(TEXT, N'闽侯县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (235, 228, CONVERT(TEXT, N'连江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (236, 228, CONVERT(TEXT, N'罗源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (237, 228, CONVERT(TEXT, N'闽清县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (238, 228, CONVERT(TEXT, N'永泰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (239, 228, CONVERT(TEXT, N'平潭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (240, 228, CONVERT(TEXT, N'福清市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (241, 228, CONVERT(TEXT, N'长乐市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (242, 227, CONVERT(TEXT, N'龙岩市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (243, 242, CONVERT(TEXT, N'新罗区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (244, 242, CONVERT(TEXT, N'长汀县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (245, 242, CONVERT(TEXT, N'永定县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (246, 242, CONVERT(TEXT, N'上杭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (247, 242, CONVERT(TEXT, N'武平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (248, 242, CONVERT(TEXT, N'连城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (249, 242, CONVERT(TEXT, N'漳平市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (250, 227, CONVERT(TEXT, N'南平市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (251, 250, CONVERT(TEXT, N'延平区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (252, 250, CONVERT(TEXT, N'顺昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (253, 250, CONVERT(TEXT, N'浦城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (254, 250, CONVERT(TEXT, N'光泽县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (255, 250, CONVERT(TEXT, N'松溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (256, 250, CONVERT(TEXT, N'政和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (257, 250, CONVERT(TEXT, N'邵武市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (258, 250, CONVERT(TEXT, N'武夷山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (259, 250, CONVERT(TEXT, N'建瓯市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (260, 250, CONVERT(TEXT, N'建阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (261, 227, CONVERT(TEXT, N'宁德市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (262, 261, CONVERT(TEXT, N'蕉城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (263, 261, CONVERT(TEXT, N'霞浦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (264, 261, CONVERT(TEXT, N'古田县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (265, 261, CONVERT(TEXT, N'屏南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (266, 261, CONVERT(TEXT, N'寿宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (267, 261, CONVERT(TEXT, N'周宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (268, 261, CONVERT(TEXT, N'柘荣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (269, 261, CONVERT(TEXT, N'福安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (270, 261, CONVERT(TEXT, N'福鼎市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (271, 227, CONVERT(TEXT, N'莆田市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (272, 271, CONVERT(TEXT, N'城厢区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (273, 271, CONVERT(TEXT, N'涵江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (274, 271, CONVERT(TEXT, N'荔城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (275, 271, CONVERT(TEXT, N'秀屿区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (276, 271, CONVERT(TEXT, N'仙游县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (277, 227, CONVERT(TEXT, N'泉州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (278, 277, CONVERT(TEXT, N'鲤城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (279, 277, CONVERT(TEXT, N'丰泽区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (280, 277, CONVERT(TEXT, N'洛江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (281, 277, CONVERT(TEXT, N'泉港区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (282, 277, CONVERT(TEXT, N'惠安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (283, 277, CONVERT(TEXT, N'安溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (284, 277, CONVERT(TEXT, N'永春县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (285, 277, CONVERT(TEXT, N'德化县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (286, 277, CONVERT(TEXT, N'金门县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (287, 277, CONVERT(TEXT, N'石狮市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (288, 277, CONVERT(TEXT, N'晋江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (289, 277, CONVERT(TEXT, N'南安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (290, 227, CONVERT(TEXT, N'三明市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (291, 290, CONVERT(TEXT, N'梅列区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (292, 290, CONVERT(TEXT, N'三元区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (293, 290, CONVERT(TEXT, N'明溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (294, 290, CONVERT(TEXT, N'清流县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (295, 290, CONVERT(TEXT, N'宁化县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (296, 290, CONVERT(TEXT, N'大田县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (297, 290, CONVERT(TEXT, N'尤溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (298, 290, CONVERT(TEXT, N'沙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (299, 290, CONVERT(TEXT, N'将乐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (300, 290, CONVERT(TEXT, N'泰宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (301, 290, CONVERT(TEXT, N'建宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (302, 290, CONVERT(TEXT, N'永安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (303, 227, CONVERT(TEXT, N'厦门市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (304, 303, CONVERT(TEXT, N'思明区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (305, 303, CONVERT(TEXT, N'海沧区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (306, 303, CONVERT(TEXT, N'湖里区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (307, 303, CONVERT(TEXT, N'集美区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (308, 303, CONVERT(TEXT, N'同安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (309, 303, CONVERT(TEXT, N'翔安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (310, 227, CONVERT(TEXT, N'漳州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (311, 310, CONVERT(TEXT, N'芗城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (312, 310, CONVERT(TEXT, N'龙文区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (313, 310, CONVERT(TEXT, N'云霄县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (314, 310, CONVERT(TEXT, N'漳浦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (315, 310, CONVERT(TEXT, N'诏安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (316, 310, CONVERT(TEXT, N'长泰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (317, 310, CONVERT(TEXT, N'东山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (318, 310, CONVERT(TEXT, N'南靖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (319, 310, CONVERT(TEXT, N'平和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (320, 310, CONVERT(TEXT, N'华安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (321, 310, CONVERT(TEXT, N'龙海市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (322, 0, CONVERT(TEXT, N'甘肃'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (323, 322, CONVERT(TEXT, N'兰州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (324, 323, CONVERT(TEXT, N'城关区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (325, 323, CONVERT(TEXT, N'七里河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (326, 323, CONVERT(TEXT, N'西固区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (327, 323, CONVERT(TEXT, N'安宁区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (328, 323, CONVERT(TEXT, N'红古区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (329, 323, CONVERT(TEXT, N'永登县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (330, 323, CONVERT(TEXT, N'皋兰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (331, 323, CONVERT(TEXT, N'榆中县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (332, 322, CONVERT(TEXT, N'白银市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (333, 332, CONVERT(TEXT, N'白银区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (334, 332, CONVERT(TEXT, N'平川区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (335, 332, CONVERT(TEXT, N'靖远县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (336, 332, CONVERT(TEXT, N'会宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (337, 332, CONVERT(TEXT, N'景泰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (338, 322, CONVERT(TEXT, N'定西市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (339, 338, CONVERT(TEXT, N'安定区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (340, 338, CONVERT(TEXT, N'通渭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (341, 338, CONVERT(TEXT, N'陇西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (342, 338, CONVERT(TEXT, N'渭源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (343, 338, CONVERT(TEXT, N'临洮县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (344, 338, CONVERT(TEXT, N'漳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (345, 338, CONVERT(TEXT, N'岷县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (346, 322, CONVERT(TEXT, N'甘南藏族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (347, 346, CONVERT(TEXT, N'合作市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (348, 346, CONVERT(TEXT, N'临潭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (349, 346, CONVERT(TEXT, N'卓尼县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (350, 346, CONVERT(TEXT, N'舟曲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (351, 346, CONVERT(TEXT, N'迭部县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (352, 346, CONVERT(TEXT, N'玛曲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (353, 346, CONVERT(TEXT, N'碌曲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (354, 346, CONVERT(TEXT, N'夏河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (355, 322, CONVERT(TEXT, N'嘉峪关市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (356, 322, CONVERT(TEXT, N'金昌市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (357, 356, CONVERT(TEXT, N'金川区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (358, 356, CONVERT(TEXT, N'永昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (359, 322, CONVERT(TEXT, N'酒泉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (360, 359, CONVERT(TEXT, N'肃州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (361, 359, CONVERT(TEXT, N'金塔县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (362, 359, CONVERT(TEXT, N'安西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (363, 359, CONVERT(TEXT, N'肃北蒙古族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (364, 359, CONVERT(TEXT, N'阿克塞哈萨克族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (365, 359, CONVERT(TEXT, N'玉门市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (366, 359, CONVERT(TEXT, N'敦煌市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (367, 322, CONVERT(TEXT, N'临夏回族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (368, 367, CONVERT(TEXT, N'临夏市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (369, 367, CONVERT(TEXT, N'临夏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (370, 367, CONVERT(TEXT, N'康乐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (371, 367, CONVERT(TEXT, N'永靖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (372, 367, CONVERT(TEXT, N'广河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (373, 367, CONVERT(TEXT, N'和政县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (374, 367, CONVERT(TEXT, N'东乡族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (375, 367, CONVERT(TEXT, N'积石山保安族东乡族撒拉族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (376, 322, CONVERT(TEXT, N'陇南市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (377, 376, CONVERT(TEXT, N'武都区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (378, 376, CONVERT(TEXT, N'成县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (379, 376, CONVERT(TEXT, N'文县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (380, 376, CONVERT(TEXT, N'宕昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (381, 376, CONVERT(TEXT, N'康县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (382, 376, CONVERT(TEXT, N'西和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (383, 376, CONVERT(TEXT, N'礼县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (384, 376, CONVERT(TEXT, N'徽县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (385, 376, CONVERT(TEXT, N'两当县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (386, 322, CONVERT(TEXT, N'平凉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (387, 386, CONVERT(TEXT, N'崆峒区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (388, 386, CONVERT(TEXT, N'泾川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (389, 386, CONVERT(TEXT, N'灵台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (390, 386, CONVERT(TEXT, N'崇信县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (391, 386, CONVERT(TEXT, N'华亭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (392, 386, CONVERT(TEXT, N'庄浪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (393, 386, CONVERT(TEXT, N'静宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (394, 322, CONVERT(TEXT, N'庆阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (395, 394, CONVERT(TEXT, N'西峰区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (396, 394, CONVERT(TEXT, N'庆城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (397, 394, CONVERT(TEXT, N'环县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (398, 394, CONVERT(TEXT, N'华池县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (399, 394, CONVERT(TEXT, N'合水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (400, 394, CONVERT(TEXT, N'正宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (401, 394, CONVERT(TEXT, N'宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (402, 394, CONVERT(TEXT, N'镇原县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (403, 322, CONVERT(TEXT, N'天水市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (404, 403, CONVERT(TEXT, N'秦城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (405, 403, CONVERT(TEXT, N'北道区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (406, 403, CONVERT(TEXT, N'清水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (407, 403, CONVERT(TEXT, N'秦安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (408, 403, CONVERT(TEXT, N'甘谷县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (409, 403, CONVERT(TEXT, N'武山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (410, 403, CONVERT(TEXT, N'张家川回族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (411, 322, CONVERT(TEXT, N'武威市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (412, 411, CONVERT(TEXT, N'凉州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (413, 411, CONVERT(TEXT, N'民勤县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (414, 411, CONVERT(TEXT, N'古浪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (415, 411, CONVERT(TEXT, N'天祝藏族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (416, 322, CONVERT(TEXT, N'张掖市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (417, 416, CONVERT(TEXT, N'甘州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (418, 416, CONVERT(TEXT, N'肃南裕固族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (419, 416, CONVERT(TEXT, N'民乐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (420, 416, CONVERT(TEXT, N'临泽县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (421, 416, CONVERT(TEXT, N'高台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (422, 416, CONVERT(TEXT, N'山丹县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (423, 0, CONVERT(TEXT, N'广东'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (424, 423, CONVERT(TEXT, N'广州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (425, 424, CONVERT(TEXT, N'东山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (426, 424, CONVERT(TEXT, N'荔湾区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (427, 424, CONVERT(TEXT, N'越秀区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (428, 424, CONVERT(TEXT, N'海珠区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (429, 424, CONVERT(TEXT, N'天河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (430, 424, CONVERT(TEXT, N'芳村区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (431, 424, CONVERT(TEXT, N'白云区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (432, 424, CONVERT(TEXT, N'黄埔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (433, 424, CONVERT(TEXT, N'番禺区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (434, 424, CONVERT(TEXT, N'花都区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (435, 424, CONVERT(TEXT, N'增城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (436, 424, CONVERT(TEXT, N'从化市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (437, 423, CONVERT(TEXT, N'潮州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (438, 437, CONVERT(TEXT, N'湘桥区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (439, 437, CONVERT(TEXT, N'潮安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (440, 437, CONVERT(TEXT, N'饶平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (441, 423, CONVERT(TEXT, N'东莞市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (442, 423, CONVERT(TEXT, N'佛山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (443, 442, CONVERT(TEXT, N'禅城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (444, 442, CONVERT(TEXT, N'南海区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (445, 442, CONVERT(TEXT, N'顺德区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (446, 442, CONVERT(TEXT, N'三水区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (447, 442, CONVERT(TEXT, N'高明区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (448, 423, CONVERT(TEXT, N'河源市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (449, 448, CONVERT(TEXT, N'源城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (450, 448, CONVERT(TEXT, N'紫金县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (451, 448, CONVERT(TEXT, N'龙川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (452, 448, CONVERT(TEXT, N'连平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (453, 448, CONVERT(TEXT, N'和平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (454, 448, CONVERT(TEXT, N'东源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (455, 423, CONVERT(TEXT, N'惠州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (456, 455, CONVERT(TEXT, N'惠城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (457, 455, CONVERT(TEXT, N'惠阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (458, 455, CONVERT(TEXT, N'博罗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (459, 455, CONVERT(TEXT, N'惠东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (460, 455, CONVERT(TEXT, N'龙门县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (461, 423, CONVERT(TEXT, N'江门市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (462, 461, CONVERT(TEXT, N'蓬江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (463, 461, CONVERT(TEXT, N'江海区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (464, 461, CONVERT(TEXT, N'新会区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (465, 461, CONVERT(TEXT, N'台山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (466, 461, CONVERT(TEXT, N'开平市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (467, 461, CONVERT(TEXT, N'鹤山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (468, 461, CONVERT(TEXT, N'恩平市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (469, 423, CONVERT(TEXT, N'揭阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (470, 469, CONVERT(TEXT, N'榕城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (471, 469, CONVERT(TEXT, N'揭东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (472, 469, CONVERT(TEXT, N'揭西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (473, 469, CONVERT(TEXT, N'惠来县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (474, 469, CONVERT(TEXT, N'普宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (475, 423, CONVERT(TEXT, N'茂名市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (476, 475, CONVERT(TEXT, N'茂南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (477, 475, CONVERT(TEXT, N'茂港区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (478, 475, CONVERT(TEXT, N'电白县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (479, 475, CONVERT(TEXT, N'高州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (480, 475, CONVERT(TEXT, N'化州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (481, 475, CONVERT(TEXT, N'信宜市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (482, 423, CONVERT(TEXT, N'梅江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (483, 423, CONVERT(TEXT, N'梅州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (484, 483, CONVERT(TEXT, N'梅县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (485, 483, CONVERT(TEXT, N'大埔县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (486, 483, CONVERT(TEXT, N'丰顺县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (487, 483, CONVERT(TEXT, N'五华县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (488, 483, CONVERT(TEXT, N'平远县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (489, 483, CONVERT(TEXT, N'蕉岭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (490, 483, CONVERT(TEXT, N'兴宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (491, 423, CONVERT(TEXT, N'清远市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (492, 491, CONVERT(TEXT, N'清城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (493, 491, CONVERT(TEXT, N'佛冈县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (494, 491, CONVERT(TEXT, N'阳山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (495, 491, CONVERT(TEXT, N'连山壮族瑶族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (496, 491, CONVERT(TEXT, N'连南瑶族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (497, 491, CONVERT(TEXT, N'清新县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (498, 491, CONVERT(TEXT, N'英德市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (499, 491, CONVERT(TEXT, N'连州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (500, 423, CONVERT(TEXT, N'汕头市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (501, 500, CONVERT(TEXT, N'龙湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (502, 500, CONVERT(TEXT, N'金平区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (503, 500, CONVERT(TEXT, N'濠江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (504, 500, CONVERT(TEXT, N'潮阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (505, 500, CONVERT(TEXT, N'潮南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (506, 500, CONVERT(TEXT, N'澄海区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (507, 500, CONVERT(TEXT, N'南澳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (508, 423, CONVERT(TEXT, N'汕尾市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (509, 508, CONVERT(TEXT, N'城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (510, 508, CONVERT(TEXT, N'海丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (511, 508, CONVERT(TEXT, N'陆河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (512, 508, CONVERT(TEXT, N'陆丰市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (513, 423, CONVERT(TEXT, N'韶关市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (514, 513, CONVERT(TEXT, N'武江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (515, 513, CONVERT(TEXT, N'浈江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (516, 513, CONVERT(TEXT, N'曲江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (517, 513, CONVERT(TEXT, N'始兴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (518, 513, CONVERT(TEXT, N'仁化县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (519, 513, CONVERT(TEXT, N'翁源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (520, 513, CONVERT(TEXT, N'乳源瑶族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (521, 513, CONVERT(TEXT, N'新丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (522, 513, CONVERT(TEXT, N'乐昌市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (523, 513, CONVERT(TEXT, N'南雄市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (524, 423, CONVERT(TEXT, N'深圳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (525, 524, CONVERT(TEXT, N'罗湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (526, 524, CONVERT(TEXT, N'福田区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (527, 524, CONVERT(TEXT, N'南山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (528, 524, CONVERT(TEXT, N'宝安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (529, 524, CONVERT(TEXT, N'龙岗区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (530, 524, CONVERT(TEXT, N'盐田区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (531, 423, CONVERT(TEXT, N'阳江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (532, 531, CONVERT(TEXT, N'江城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (533, 531, CONVERT(TEXT, N'阳西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (534, 531, CONVERT(TEXT, N'阳东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (535, 531, CONVERT(TEXT, N'阳春市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (536, 423, CONVERT(TEXT, N'云浮市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (537, 536, CONVERT(TEXT, N'云城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (538, 536, CONVERT(TEXT, N'新兴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (539, 536, CONVERT(TEXT, N'郁南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (540, 536, CONVERT(TEXT, N'云安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (541, 536, CONVERT(TEXT, N'罗定市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (542, 423, CONVERT(TEXT, N'湛江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (543, 542, CONVERT(TEXT, N'赤坎区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (544, 542, CONVERT(TEXT, N'霞山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (545, 542, CONVERT(TEXT, N'坡头区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (546, 542, CONVERT(TEXT, N'麻章区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (547, 542, CONVERT(TEXT, N'遂溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (548, 542, CONVERT(TEXT, N'徐闻县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (549, 542, CONVERT(TEXT, N'廉江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (550, 542, CONVERT(TEXT, N'雷州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (551, 542, CONVERT(TEXT, N'吴川市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (552, 423, CONVERT(TEXT, N'肇庆市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (553, 552, CONVERT(TEXT, N'端州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (554, 552, CONVERT(TEXT, N'鼎湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (555, 552, CONVERT(TEXT, N'广宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (556, 552, CONVERT(TEXT, N'怀集县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (557, 552, CONVERT(TEXT, N'封开县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (558, 552, CONVERT(TEXT, N'德庆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (559, 552, CONVERT(TEXT, N'高要市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (560, 552, CONVERT(TEXT, N'四会市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (561, 423, CONVERT(TEXT, N'中山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (562, 423, CONVERT(TEXT, N'珠海市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (563, 562, CONVERT(TEXT, N'香洲区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (564, 562, CONVERT(TEXT, N'斗门区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (565, 562, CONVERT(TEXT, N'金湾区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (566, 0, CONVERT(TEXT, N'广西'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (567, 566, CONVERT(TEXT, N'南宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (568, 567, CONVERT(TEXT, N'兴宁区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (569, 567, CONVERT(TEXT, N'青秀区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (570, 567, CONVERT(TEXT, N'江南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (571, 567, CONVERT(TEXT, N'西乡塘区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (572, 567, CONVERT(TEXT, N'良庆区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (573, 567, CONVERT(TEXT, N'邕宁区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (574, 567, CONVERT(TEXT, N'武鸣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (575, 567, CONVERT(TEXT, N'隆安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (576, 567, CONVERT(TEXT, N'马山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (577, 567, CONVERT(TEXT, N'上林县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (578, 567, CONVERT(TEXT, N'宾阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (579, 567, CONVERT(TEXT, N'横县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (580, 566, CONVERT(TEXT, N'百色市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (581, 580, CONVERT(TEXT, N'右江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (582, 580, CONVERT(TEXT, N'田阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (583, 580, CONVERT(TEXT, N'田东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (584, 580, CONVERT(TEXT, N'平果县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (585, 580, CONVERT(TEXT, N'德保县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (586, 580, CONVERT(TEXT, N'靖西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (587, 580, CONVERT(TEXT, N'那坡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (588, 580, CONVERT(TEXT, N'凌云县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (589, 580, CONVERT(TEXT, N'乐业县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (590, 580, CONVERT(TEXT, N'田林县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (591, 580, CONVERT(TEXT, N'西林县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (592, 580, CONVERT(TEXT, N'隆林各族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (593, 566, CONVERT(TEXT, N'北海市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (594, 593, CONVERT(TEXT, N'海城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (595, 593, CONVERT(TEXT, N'银海区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (596, 593, CONVERT(TEXT, N'铁山港区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (597, 593, CONVERT(TEXT, N'合浦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (598, 566, CONVERT(TEXT, N'崇左市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (599, 598, CONVERT(TEXT, N'江洲区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (600, 598, CONVERT(TEXT, N'扶绥县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (601, 598, CONVERT(TEXT, N'宁明县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (602, 598, CONVERT(TEXT, N'龙州县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (603, 598, CONVERT(TEXT, N'大新县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (604, 598, CONVERT(TEXT, N'天等县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (605, 598, CONVERT(TEXT, N'凭祥市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (606, 566, CONVERT(TEXT, N'防城港市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (607, 606, CONVERT(TEXT, N'港口区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (608, 606, CONVERT(TEXT, N'防城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (609, 606, CONVERT(TEXT, N'上思县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (610, 606, CONVERT(TEXT, N'东兴市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (611, 566, CONVERT(TEXT, N'贵港市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (612, 611, CONVERT(TEXT, N'港北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (613, 611, CONVERT(TEXT, N'港南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (614, 611, CONVERT(TEXT, N'覃塘区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (615, 611, CONVERT(TEXT, N'平南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (616, 611, CONVERT(TEXT, N'桂平市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (617, 566, CONVERT(TEXT, N'桂林市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (618, 617, CONVERT(TEXT, N'秀峰区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (619, 617, CONVERT(TEXT, N'叠彩区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (620, 617, CONVERT(TEXT, N'象山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (621, 617, CONVERT(TEXT, N'七星区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (622, 617, CONVERT(TEXT, N'雁山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (623, 617, CONVERT(TEXT, N'阳朔县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (624, 617, CONVERT(TEXT, N'临桂县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (625, 617, CONVERT(TEXT, N'灵川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (626, 617, CONVERT(TEXT, N'全州县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (627, 617, CONVERT(TEXT, N'兴安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (628, 617, CONVERT(TEXT, N'永福县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (629, 617, CONVERT(TEXT, N'灌阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (630, 617, CONVERT(TEXT, N'龙胜各族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (631, 617, CONVERT(TEXT, N'资源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (632, 617, CONVERT(TEXT, N'平乐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (633, 617, CONVERT(TEXT, N'荔蒲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (634, 617, CONVERT(TEXT, N'恭城瑶族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (635, 566, CONVERT(TEXT, N'河池市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (636, 635, CONVERT(TEXT, N'金城江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (637, 635, CONVERT(TEXT, N'南丹县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (638, 635, CONVERT(TEXT, N'天峨县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (639, 635, CONVERT(TEXT, N'凤山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (640, 635, CONVERT(TEXT, N'东兰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (641, 635, CONVERT(TEXT, N'罗城仫佬族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (642, 635, CONVERT(TEXT, N'环江毛南族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (643, 635, CONVERT(TEXT, N'巴马瑶族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (644, 635, CONVERT(TEXT, N'都安瑶族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (645, 635, CONVERT(TEXT, N'大化瑶族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (646, 635, CONVERT(TEXT, N'宜州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (647, 566, CONVERT(TEXT, N'贺州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (648, 647, CONVERT(TEXT, N'八步区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (649, 647, CONVERT(TEXT, N'昭平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (650, 647, CONVERT(TEXT, N'钟山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (651, 647, CONVERT(TEXT, N'富川瑶族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (652, 566, CONVERT(TEXT, N'来宾市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (653, 652, CONVERT(TEXT, N'兴宾区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (654, 652, CONVERT(TEXT, N'忻城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (655, 652, CONVERT(TEXT, N'象州县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (656, 652, CONVERT(TEXT, N'武宣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (657, 652, CONVERT(TEXT, N'金秀瑶族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (658, 652, CONVERT(TEXT, N'合山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (659, 566, CONVERT(TEXT, N'柳州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (660, 659, CONVERT(TEXT, N'城中区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (661, 659, CONVERT(TEXT, N'鱼峰区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (662, 659, CONVERT(TEXT, N'柳南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (663, 659, CONVERT(TEXT, N'柳北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (664, 659, CONVERT(TEXT, N'柳江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (665, 659, CONVERT(TEXT, N'柳城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (666, 659, CONVERT(TEXT, N'鹿寨县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (667, 659, CONVERT(TEXT, N'融安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (668, 659, CONVERT(TEXT, N'融水苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (669, 659, CONVERT(TEXT, N'三江侗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (670, 566, CONVERT(TEXT, N'钦州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (671, 670, CONVERT(TEXT, N'钦南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (672, 670, CONVERT(TEXT, N'钦北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (673, 670, CONVERT(TEXT, N'灵山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (674, 670, CONVERT(TEXT, N'浦北县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (675, 566, CONVERT(TEXT, N'梧州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (676, 675, CONVERT(TEXT, N'万秀区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (677, 675, CONVERT(TEXT, N'蝶山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (678, 675, CONVERT(TEXT, N'长洲区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (679, 675, CONVERT(TEXT, N'苍梧县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (680, 675, CONVERT(TEXT, N'藤县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (681, 675, CONVERT(TEXT, N'蒙山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (682, 675, CONVERT(TEXT, N'岑溪市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (683, 566, CONVERT(TEXT, N'玉林市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (684, 683, CONVERT(TEXT, N'玉州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (685, 683, CONVERT(TEXT, N'容县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (686, 683, CONVERT(TEXT, N'陆川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (687, 683, CONVERT(TEXT, N'博白县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (688, 683, CONVERT(TEXT, N'兴业县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (689, 683, CONVERT(TEXT, N'北流市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (690, 0, CONVERT(TEXT, N'贵州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (691, 690, CONVERT(TEXT, N'贵阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (692, 691, CONVERT(TEXT, N'南明区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (693, 691, CONVERT(TEXT, N'云岩区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (694, 691, CONVERT(TEXT, N'花溪区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (695, 691, CONVERT(TEXT, N'乌当区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (696, 691, CONVERT(TEXT, N'白云区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (697, 691, CONVERT(TEXT, N'小河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (698, 691, CONVERT(TEXT, N'开阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (699, 691, CONVERT(TEXT, N'息烽县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (700, 691, CONVERT(TEXT, N'修文县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (701, 691, CONVERT(TEXT, N'清镇市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (702, 690, CONVERT(TEXT, N'安顺市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (703, 702, CONVERT(TEXT, N'西秀区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (704, 702, CONVERT(TEXT, N'平坝县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (705, 702, CONVERT(TEXT, N'普定县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (706, 702, CONVERT(TEXT, N'镇宁布依族苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (707, 702, CONVERT(TEXT, N'关岭布依族苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (708, 702, CONVERT(TEXT, N'紫云苗族布依族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (709, 690, CONVERT(TEXT, N'毕节地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (710, 709, CONVERT(TEXT, N'毕节市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (711, 709, CONVERT(TEXT, N'大方县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (712, 709, CONVERT(TEXT, N'黔西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (713, 709, CONVERT(TEXT, N'金沙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (714, 709, CONVERT(TEXT, N'织金县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (715, 709, CONVERT(TEXT, N'纳雍县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (716, 709, CONVERT(TEXT, N'威宁彝族回族苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (717, 709, CONVERT(TEXT, N'赫章县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (718, 690, CONVERT(TEXT, N'六盘水市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (719, 718, CONVERT(TEXT, N'钟山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (720, 718, CONVERT(TEXT, N'六枝特区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (721, 718, CONVERT(TEXT, N'水城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (722, 718, CONVERT(TEXT, N'盘县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (723, 690, CONVERT(TEXT, N'黔东南苗族侗族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (724, 723, CONVERT(TEXT, N'凯里市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (725, 723, CONVERT(TEXT, N'黄平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (726, 723, CONVERT(TEXT, N'施秉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (727, 723, CONVERT(TEXT, N'三穗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (728, 723, CONVERT(TEXT, N'镇远县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (729, 723, CONVERT(TEXT, N'岑巩县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (730, 723, CONVERT(TEXT, N'天柱县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (731, 723, CONVERT(TEXT, N'锦屏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (732, 723, CONVERT(TEXT, N'剑河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (733, 723, CONVERT(TEXT, N'台江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (734, 723, CONVERT(TEXT, N'黎平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (735, 723, CONVERT(TEXT, N'榕江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (736, 723, CONVERT(TEXT, N'从江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (737, 723, CONVERT(TEXT, N'雷山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (738, 723, CONVERT(TEXT, N'麻江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (739, 723, CONVERT(TEXT, N'丹寨县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (740, 690, CONVERT(TEXT, N'黔南布依族苗族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (741, 740, CONVERT(TEXT, N'都匀市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (742, 740, CONVERT(TEXT, N'福泉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (743, 740, CONVERT(TEXT, N'荔波县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (744, 740, CONVERT(TEXT, N'贵定县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (745, 740, CONVERT(TEXT, N'瓮安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (746, 740, CONVERT(TEXT, N'独山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (747, 740, CONVERT(TEXT, N'平塘县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (748, 740, CONVERT(TEXT, N'罗甸县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (749, 740, CONVERT(TEXT, N'长顺县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (750, 740, CONVERT(TEXT, N'龙里县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (751, 740, CONVERT(TEXT, N'惠水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (752, 740, CONVERT(TEXT, N'三都水族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (753, 690, CONVERT(TEXT, N'黔西南布依族苗族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (754, 753, CONVERT(TEXT, N'兴义市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (755, 753, CONVERT(TEXT, N'兴仁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (756, 753, CONVERT(TEXT, N'普安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (757, 753, CONVERT(TEXT, N'晴隆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (758, 753, CONVERT(TEXT, N'贞丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (759, 753, CONVERT(TEXT, N'望谟县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (760, 753, CONVERT(TEXT, N'册亨县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (761, 753, CONVERT(TEXT, N'安龙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (762, 690, CONVERT(TEXT, N'铜仁地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (763, 762, CONVERT(TEXT, N'铜仁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (764, 762, CONVERT(TEXT, N'江口县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (765, 762, CONVERT(TEXT, N'玉屏侗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (766, 762, CONVERT(TEXT, N'石阡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (767, 762, CONVERT(TEXT, N'思南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (768, 762, CONVERT(TEXT, N'印江土家族苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (769, 762, CONVERT(TEXT, N'德江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (770, 762, CONVERT(TEXT, N'沿河土家族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (771, 762, CONVERT(TEXT, N'松桃苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (772, 762, CONVERT(TEXT, N'万山特区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (773, 690, CONVERT(TEXT, N'遵义市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (774, 773, CONVERT(TEXT, N'红花岗区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (775, 773, CONVERT(TEXT, N'汇川区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (776, 773, CONVERT(TEXT, N'遵义县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (777, 773, CONVERT(TEXT, N'桐梓县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (778, 773, CONVERT(TEXT, N'绥阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (779, 773, CONVERT(TEXT, N'正安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (780, 773, CONVERT(TEXT, N'道真仡佬族苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (781, 773, CONVERT(TEXT, N'务川仡佬族苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (782, 773, CONVERT(TEXT, N'凤冈县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (783, 773, CONVERT(TEXT, N'湄潭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (784, 773, CONVERT(TEXT, N'余庆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (785, 773, CONVERT(TEXT, N'习水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (786, 773, CONVERT(TEXT, N'赤水市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (787, 773, CONVERT(TEXT, N'仁怀市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (788, 0, CONVERT(TEXT, N'海南'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (789, 788, CONVERT(TEXT, N'海口市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (790, 789, CONVERT(TEXT, N'秀英区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (791, 789, CONVERT(TEXT, N'龙华区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (792, 789, CONVERT(TEXT, N'琼山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (793, 789, CONVERT(TEXT, N'美兰区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (794, 788, CONVERT(TEXT, N'白沙黎族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (795, 788, CONVERT(TEXT, N'保亭黎族苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (796, 788, CONVERT(TEXT, N'昌江黎族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (797, 788, CONVERT(TEXT, N'澄迈县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (798, 788, CONVERT(TEXT, N'儋州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (799, 788, CONVERT(TEXT, N'定安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (800, 788, CONVERT(TEXT, N'东方市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (801, 788, CONVERT(TEXT, N'乐东黎族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (802, 788, CONVERT(TEXT, N'临高县'))

;
INSERT [farecitys] ([id], [pid], [name]) VALUES (803, 788, CONVERT(TEXT, N'陵水黎族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (804, 788, CONVERT(TEXT, N'南沙群岛'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (805, 788, CONVERT(TEXT, N'琼海市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (806, 788, CONVERT(TEXT, N'琼中黎族苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (807, 788, CONVERT(TEXT, N'三亚市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (808, 788, CONVERT(TEXT, N'屯昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (809, 788, CONVERT(TEXT, N'万宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (810, 788, CONVERT(TEXT, N'文昌市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (811, 788, CONVERT(TEXT, N'五指山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (812, 788, CONVERT(TEXT, N'西沙群岛'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (813, 788, CONVERT(TEXT, N'中沙群岛的岛礁及其海域'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (814, 0, CONVERT(TEXT, N'河北'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (815, 814, CONVERT(TEXT, N'石家庄市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (816, 815, CONVERT(TEXT, N'长安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (817, 815, CONVERT(TEXT, N'桥东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (818, 815, CONVERT(TEXT, N'桥西区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (819, 815, CONVERT(TEXT, N'新华区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (820, 815, CONVERT(TEXT, N'井陉矿区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (821, 815, CONVERT(TEXT, N'裕华区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (822, 815, CONVERT(TEXT, N'井陉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (823, 815, CONVERT(TEXT, N'正定县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (824, 815, CONVERT(TEXT, N'栾城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (825, 815, CONVERT(TEXT, N'行唐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (826, 815, CONVERT(TEXT, N'灵寿县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (827, 815, CONVERT(TEXT, N'高邑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (828, 815, CONVERT(TEXT, N'深泽县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (829, 815, CONVERT(TEXT, N'赞皇县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (830, 815, CONVERT(TEXT, N'无极县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (831, 815, CONVERT(TEXT, N'平山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (832, 815, CONVERT(TEXT, N'元氏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (833, 815, CONVERT(TEXT, N'赵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (834, 815, CONVERT(TEXT, N'辛集市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (835, 815, CONVERT(TEXT, N'藁城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (836, 815, CONVERT(TEXT, N'晋州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (837, 815, CONVERT(TEXT, N'新乐市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (838, 815, CONVERT(TEXT, N'鹿泉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (839, 814, CONVERT(TEXT, N'保定市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (840, 839, CONVERT(TEXT, N'新市区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (841, 839, CONVERT(TEXT, N'北市区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (842, 839, CONVERT(TEXT, N'南市区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (843, 839, CONVERT(TEXT, N'满城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (844, 839, CONVERT(TEXT, N'清苑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (845, 839, CONVERT(TEXT, N'涞水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (846, 839, CONVERT(TEXT, N'阜平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (847, 839, CONVERT(TEXT, N'徐水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (848, 839, CONVERT(TEXT, N'定兴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (849, 839, CONVERT(TEXT, N'唐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (850, 839, CONVERT(TEXT, N'高阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (851, 839, CONVERT(TEXT, N'容城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (852, 839, CONVERT(TEXT, N'涞源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (853, 839, CONVERT(TEXT, N'望都县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (854, 839, CONVERT(TEXT, N'安新县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (855, 839, CONVERT(TEXT, N'易县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (856, 839, CONVERT(TEXT, N'曲阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (857, 839, CONVERT(TEXT, N'蠡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (858, 839, CONVERT(TEXT, N'顺平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (859, 839, CONVERT(TEXT, N'博野县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (860, 839, CONVERT(TEXT, N'雄县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (861, 839, CONVERT(TEXT, N'涿州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (862, 839, CONVERT(TEXT, N'定州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (863, 839, CONVERT(TEXT, N'安国市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (864, 839, CONVERT(TEXT, N'高碑店市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (865, 814, CONVERT(TEXT, N'沧州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (866, 865, CONVERT(TEXT, N'新华区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (867, 865, CONVERT(TEXT, N'运河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (868, 865, CONVERT(TEXT, N'沧县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (869, 865, CONVERT(TEXT, N'青县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (870, 865, CONVERT(TEXT, N'东光县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (871, 865, CONVERT(TEXT, N'海兴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (872, 865, CONVERT(TEXT, N'盐山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (873, 865, CONVERT(TEXT, N'肃宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (874, 865, CONVERT(TEXT, N'南皮县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (875, 865, CONVERT(TEXT, N'吴桥县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (876, 865, CONVERT(TEXT, N'献县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (877, 865, CONVERT(TEXT, N'孟村回族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (878, 865, CONVERT(TEXT, N'泊头市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (879, 865, CONVERT(TEXT, N'任丘市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (880, 865, CONVERT(TEXT, N'黄骅市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (881, 865, CONVERT(TEXT, N'河间市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (882, 814, CONVERT(TEXT, N'承德市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (883, 882, CONVERT(TEXT, N'双桥区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (884, 882, CONVERT(TEXT, N'双滦区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (885, 882, CONVERT(TEXT, N'鹰手营子矿区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (886, 882, CONVERT(TEXT, N'承德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (887, 882, CONVERT(TEXT, N'兴隆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (888, 882, CONVERT(TEXT, N'平泉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (889, 882, CONVERT(TEXT, N'滦平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (890, 882, CONVERT(TEXT, N'隆化县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (891, 882, CONVERT(TEXT, N'丰宁满族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (892, 882, CONVERT(TEXT, N'宽城满族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (893, 882, CONVERT(TEXT, N'围场满族蒙古族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (894, 814, CONVERT(TEXT, N'邯郸市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (895, 894, CONVERT(TEXT, N'邯山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (896, 894, CONVERT(TEXT, N'丛台区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (897, 894, CONVERT(TEXT, N'复兴区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (898, 894, CONVERT(TEXT, N'峰峰矿区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (899, 894, CONVERT(TEXT, N'邯郸县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (900, 894, CONVERT(TEXT, N'临漳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (901, 894, CONVERT(TEXT, N'成安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (902, 894, CONVERT(TEXT, N'大名县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (903, 894, CONVERT(TEXT, N'涉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (904, 894, CONVERT(TEXT, N'磁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (905, 894, CONVERT(TEXT, N'肥乡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (906, 894, CONVERT(TEXT, N'永年县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (907, 894, CONVERT(TEXT, N'邱县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (908, 894, CONVERT(TEXT, N'鸡泽县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (909, 894, CONVERT(TEXT, N'广平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (910, 894, CONVERT(TEXT, N'馆陶县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (911, 894, CONVERT(TEXT, N'魏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (912, 894, CONVERT(TEXT, N'曲周县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (913, 894, CONVERT(TEXT, N'武安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (914, 814, CONVERT(TEXT, N'衡水市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (915, 914, CONVERT(TEXT, N'桃城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (916, 914, CONVERT(TEXT, N'枣强县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (917, 914, CONVERT(TEXT, N'武邑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (918, 914, CONVERT(TEXT, N'武强县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (919, 914, CONVERT(TEXT, N'饶阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (920, 914, CONVERT(TEXT, N'安平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (921, 914, CONVERT(TEXT, N'故城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (922, 914, CONVERT(TEXT, N'景县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (923, 914, CONVERT(TEXT, N'阜城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (924, 914, CONVERT(TEXT, N'冀州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (925, 914, CONVERT(TEXT, N'深州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (926, 814, CONVERT(TEXT, N'廊坊市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (927, 926, CONVERT(TEXT, N'安次区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (928, 926, CONVERT(TEXT, N'广阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (929, 926, CONVERT(TEXT, N'固安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (930, 926, CONVERT(TEXT, N'永清县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (931, 926, CONVERT(TEXT, N'香河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (932, 926, CONVERT(TEXT, N'大城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (933, 926, CONVERT(TEXT, N'文安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (934, 926, CONVERT(TEXT, N'大厂回族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (935, 926, CONVERT(TEXT, N'霸州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (936, 926, CONVERT(TEXT, N'三河市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (937, 814, CONVERT(TEXT, N'秦皇岛市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (938, 937, CONVERT(TEXT, N'海港区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (939, 937, CONVERT(TEXT, N'山海关区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (940, 937, CONVERT(TEXT, N'北戴河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (941, 937, CONVERT(TEXT, N'青龙满族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (942, 937, CONVERT(TEXT, N'昌黎县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (943, 937, CONVERT(TEXT, N'抚宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (944, 937, CONVERT(TEXT, N'卢龙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (945, 814, CONVERT(TEXT, N'唐山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (946, 945, CONVERT(TEXT, N'路南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (947, 945, CONVERT(TEXT, N'路北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (948, 945, CONVERT(TEXT, N'古冶区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (949, 945, CONVERT(TEXT, N'开平区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (950, 945, CONVERT(TEXT, N'丰南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (951, 945, CONVERT(TEXT, N'丰润区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (952, 945, CONVERT(TEXT, N'滦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (953, 945, CONVERT(TEXT, N'滦南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (954, 945, CONVERT(TEXT, N'乐亭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (955, 945, CONVERT(TEXT, N'迁西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (956, 945, CONVERT(TEXT, N'玉田县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (957, 945, CONVERT(TEXT, N'唐海县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (958, 945, CONVERT(TEXT, N'遵化市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (959, 945, CONVERT(TEXT, N'迁安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (960, 814, CONVERT(TEXT, N'邢台市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (961, 960, CONVERT(TEXT, N'桥东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (962, 960, CONVERT(TEXT, N'桥西区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (963, 960, CONVERT(TEXT, N'邢台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (964, 960, CONVERT(TEXT, N'临城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (965, 960, CONVERT(TEXT, N'内丘县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (966, 960, CONVERT(TEXT, N'柏乡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (967, 960, CONVERT(TEXT, N'隆尧县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (968, 960, CONVERT(TEXT, N'任县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (969, 960, CONVERT(TEXT, N'南和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (970, 960, CONVERT(TEXT, N'宁晋县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (971, 960, CONVERT(TEXT, N'巨鹿县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (972, 960, CONVERT(TEXT, N'新河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (973, 960, CONVERT(TEXT, N'广宗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (974, 960, CONVERT(TEXT, N'平乡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (975, 960, CONVERT(TEXT, N'威县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (976, 960, CONVERT(TEXT, N'清河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (977, 960, CONVERT(TEXT, N'临西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (978, 960, CONVERT(TEXT, N'南宫市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (979, 960, CONVERT(TEXT, N'沙河市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (980, 814, CONVERT(TEXT, N'张家口市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (981, 980, CONVERT(TEXT, N'桥东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (982, 980, CONVERT(TEXT, N'桥西区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (983, 980, CONVERT(TEXT, N'宣化区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (984, 980, CONVERT(TEXT, N'下花园区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (985, 980, CONVERT(TEXT, N'宣化县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (986, 980, CONVERT(TEXT, N'张北县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (987, 980, CONVERT(TEXT, N'康保县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (988, 980, CONVERT(TEXT, N'沽源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (989, 980, CONVERT(TEXT, N'尚义县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (990, 980, CONVERT(TEXT, N'蔚县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (991, 980, CONVERT(TEXT, N'阳原县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (992, 980, CONVERT(TEXT, N'怀安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (993, 980, CONVERT(TEXT, N'万全县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (994, 980, CONVERT(TEXT, N'怀来县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (995, 980, CONVERT(TEXT, N'涿鹿县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (996, 980, CONVERT(TEXT, N'赤城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (997, 980, CONVERT(TEXT, N'崇礼县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (998, 0, CONVERT(TEXT, N'河南'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (999, 998, CONVERT(TEXT, N'郑州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1000, 999, CONVERT(TEXT, N'中原区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1001, 999, CONVERT(TEXT, N'二七区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1002, 999, CONVERT(TEXT, N'管城回族区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1003, 999, CONVERT(TEXT, N'金水区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1004, 999, CONVERT(TEXT, N'上街区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1005, 999, CONVERT(TEXT, N'邙山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1006, 999, CONVERT(TEXT, N'中牟县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1007, 999, CONVERT(TEXT, N'巩义市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1008, 999, CONVERT(TEXT, N'荥阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1009, 999, CONVERT(TEXT, N'新密市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1010, 999, CONVERT(TEXT, N'新郑市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1011, 999, CONVERT(TEXT, N'登封市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1012, 998, CONVERT(TEXT, N'安阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1013, 1012, CONVERT(TEXT, N'文峰区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1014, 1012, CONVERT(TEXT, N'北关区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1015, 1012, CONVERT(TEXT, N'殷都区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1016, 1012, CONVERT(TEXT, N'龙安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1017, 1012, CONVERT(TEXT, N'安阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1018, 1012, CONVERT(TEXT, N'汤阴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1019, 1012, CONVERT(TEXT, N'滑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1020, 1012, CONVERT(TEXT, N'内黄县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1021, 1012, CONVERT(TEXT, N'林州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1022, 998, CONVERT(TEXT, N'鹤壁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1023, 1022, CONVERT(TEXT, N'鹤山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1024, 1022, CONVERT(TEXT, N'山城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1025, 1022, CONVERT(TEXT, N'淇滨区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1026, 1022, CONVERT(TEXT, N'浚县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1027, 1022, CONVERT(TEXT, N'淇县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1028, 998, CONVERT(TEXT, N'济源市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1029, 998, CONVERT(TEXT, N'焦作市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1030, 1029, CONVERT(TEXT, N'解放区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1031, 1029, CONVERT(TEXT, N'中站区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1032, 1029, CONVERT(TEXT, N'马村区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1033, 1029, CONVERT(TEXT, N'山阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1034, 1029, CONVERT(TEXT, N'修武县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1035, 1029, CONVERT(TEXT, N'博爱县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1036, 1029, CONVERT(TEXT, N'武陟县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1037, 1029, CONVERT(TEXT, N'温县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1038, 1029, CONVERT(TEXT, N'济源市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1039, 1029, CONVERT(TEXT, N'沁阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1040, 1029, CONVERT(TEXT, N'孟州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1041, 998, CONVERT(TEXT, N'开封市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1042, 1041, CONVERT(TEXT, N'龙亭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1043, 1041, CONVERT(TEXT, N'顺河回族区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1044, 1041, CONVERT(TEXT, N'鼓楼区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1045, 1041, CONVERT(TEXT, N'南关区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1046, 1041, CONVERT(TEXT, N'郊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1047, 1041, CONVERT(TEXT, N'杞县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1048, 1041, CONVERT(TEXT, N'通许县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1049, 1041, CONVERT(TEXT, N'尉氏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1050, 1041, CONVERT(TEXT, N'开封县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1051, 1041, CONVERT(TEXT, N'兰考县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1052, 998, CONVERT(TEXT, N'洛阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1053, 1052, CONVERT(TEXT, N'老城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1054, 1052, CONVERT(TEXT, N'西工区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1055, 1052, CONVERT(TEXT, N'廛河回族区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1056, 1052, CONVERT(TEXT, N'涧西区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1057, 1052, CONVERT(TEXT, N'吉利区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1058, 1052, CONVERT(TEXT, N'洛龙区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1059, 1052, CONVERT(TEXT, N'孟津县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1060, 1052, CONVERT(TEXT, N'新安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1061, 1052, CONVERT(TEXT, N'栾川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1062, 1052, CONVERT(TEXT, N'嵩县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1063, 1052, CONVERT(TEXT, N'汝阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1064, 1052, CONVERT(TEXT, N'宜阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1065, 1052, CONVERT(TEXT, N'洛宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1066, 1052, CONVERT(TEXT, N'伊川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1067, 1052, CONVERT(TEXT, N'偃师市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1068, 998, CONVERT(TEXT, N'漯河市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1069, 1068, CONVERT(TEXT, N'源汇区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1070, 1068, CONVERT(TEXT, N'郾城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1071, 1068, CONVERT(TEXT, N'召陵区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1072, 1068, CONVERT(TEXT, N'舞阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1073, 1068, CONVERT(TEXT, N'临颍县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1074, 998, CONVERT(TEXT, N'南阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1075, 1074, CONVERT(TEXT, N'宛城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1076, 1074, CONVERT(TEXT, N'卧龙区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1077, 1074, CONVERT(TEXT, N'南召县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1078, 1074, CONVERT(TEXT, N'方城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1079, 1074, CONVERT(TEXT, N'西峡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1080, 1074, CONVERT(TEXT, N'镇平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1081, 1074, CONVERT(TEXT, N'内乡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1082, 1074, CONVERT(TEXT, N'淅川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1083, 1074, CONVERT(TEXT, N'社旗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1084, 1074, CONVERT(TEXT, N'唐河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1085, 1074, CONVERT(TEXT, N'新野县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1086, 1074, CONVERT(TEXT, N'桐柏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1087, 1074, CONVERT(TEXT, N'邓州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1088, 998, CONVERT(TEXT, N'平顶山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1089, 1088, CONVERT(TEXT, N'新华区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1090, 1088, CONVERT(TEXT, N'卫东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1091, 1088, CONVERT(TEXT, N'石龙区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1092, 1088, CONVERT(TEXT, N'湛河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1093, 1088, CONVERT(TEXT, N'宝丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1094, 1088, CONVERT(TEXT, N'叶县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1095, 1088, CONVERT(TEXT, N'鲁山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1096, 1088, CONVERT(TEXT, N'郏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1097, 1088, CONVERT(TEXT, N'舞钢市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1098, 1088, CONVERT(TEXT, N'汝州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1099, 998, CONVERT(TEXT, N'濮阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1100, 1099, CONVERT(TEXT, N'华龙区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1101, 1099, CONVERT(TEXT, N'清丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1102, 1099, CONVERT(TEXT, N'南乐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1103, 1099, CONVERT(TEXT, N'范县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1104, 1099, CONVERT(TEXT, N'台前县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1105, 1099, CONVERT(TEXT, N'濮阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1106, 998, CONVERT(TEXT, N'三门峡市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1107, 1106, CONVERT(TEXT, N'湖滨区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1108, 1106, CONVERT(TEXT, N'渑池县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1109, 1106, CONVERT(TEXT, N'陕县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1110, 1106, CONVERT(TEXT, N'卢氏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1111, 1106, CONVERT(TEXT, N'义马市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1112, 1106, CONVERT(TEXT, N'灵宝市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1113, 998, CONVERT(TEXT, N'商丘市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1114, 1113, CONVERT(TEXT, N'梁园区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1115, 1113, CONVERT(TEXT, N'睢阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1116, 1113, CONVERT(TEXT, N'民权县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1117, 1113, CONVERT(TEXT, N'睢县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1118, 1113, CONVERT(TEXT, N'宁陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1119, 1113, CONVERT(TEXT, N'柘城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1120, 1113, CONVERT(TEXT, N'虞城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1121, 1113, CONVERT(TEXT, N'夏邑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1122, 1113, CONVERT(TEXT, N'永城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1123, 998, CONVERT(TEXT, N'新乡市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1124, 1123, CONVERT(TEXT, N'红旗区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1125, 1123, CONVERT(TEXT, N'卫滨区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1126, 1123, CONVERT(TEXT, N'凤泉区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1127, 1123, CONVERT(TEXT, N'牧野区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1128, 1123, CONVERT(TEXT, N'新乡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1129, 1123, CONVERT(TEXT, N'获嘉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1130, 1123, CONVERT(TEXT, N'原阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1131, 1123, CONVERT(TEXT, N'延津县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1132, 1123, CONVERT(TEXT, N'封丘县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1133, 1123, CONVERT(TEXT, N'长垣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1134, 1123, CONVERT(TEXT, N'卫辉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1135, 1123, CONVERT(TEXT, N'辉县市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1136, 998, CONVERT(TEXT, N'信阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1137, 1136, CONVERT(TEXT, N'师河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1138, 1136, CONVERT(TEXT, N'平桥区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1139, 1136, CONVERT(TEXT, N'罗山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1140, 1136, CONVERT(TEXT, N'光山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1141, 1136, CONVERT(TEXT, N'新县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1142, 1136, CONVERT(TEXT, N'商城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1143, 1136, CONVERT(TEXT, N'固始县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1144, 1136, CONVERT(TEXT, N'潢川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1145, 1136, CONVERT(TEXT, N'淮滨县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1146, 1136, CONVERT(TEXT, N'息县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1147, 998, CONVERT(TEXT, N'许昌市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1148, 1147, CONVERT(TEXT, N'魏都区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1149, 1147, CONVERT(TEXT, N'许昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1150, 1147, CONVERT(TEXT, N'鄢陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1151, 1147, CONVERT(TEXT, N'襄城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1152, 1147, CONVERT(TEXT, N'禹州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1153, 1147, CONVERT(TEXT, N'长葛市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1154, 998, CONVERT(TEXT, N'周口市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1155, 1154, CONVERT(TEXT, N'川汇区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1156, 1154, CONVERT(TEXT, N'扶沟县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1157, 1154, CONVERT(TEXT, N'西华县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1158, 1154, CONVERT(TEXT, N'商水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1159, 1154, CONVERT(TEXT, N'沈丘县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1160, 1154, CONVERT(TEXT, N'郸城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1161, 1154, CONVERT(TEXT, N'淮阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1162, 1154, CONVERT(TEXT, N'太康县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1163, 1154, CONVERT(TEXT, N'鹿邑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1164, 1154, CONVERT(TEXT, N'项城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1165, 998, CONVERT(TEXT, N'驻马店市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1166, 1165, CONVERT(TEXT, N'驿城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1167, 1165, CONVERT(TEXT, N'西平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1168, 1165, CONVERT(TEXT, N'上蔡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1169, 1165, CONVERT(TEXT, N'平舆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1170, 1165, CONVERT(TEXT, N'正阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1171, 1165, CONVERT(TEXT, N'确山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1172, 1165, CONVERT(TEXT, N'泌阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1173, 1165, CONVERT(TEXT, N'汝南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1174, 1165, CONVERT(TEXT, N'遂平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1175, 1165, CONVERT(TEXT, N'新蔡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1176, 0, CONVERT(TEXT, N'黑龙江'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1177, 1176, CONVERT(TEXT, N'哈尔滨市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1178, 1177, CONVERT(TEXT, N'道里区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1179, 1177, CONVERT(TEXT, N'南岗区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1180, 1177, CONVERT(TEXT, N'道外区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1181, 1177, CONVERT(TEXT, N'香坊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1182, 1177, CONVERT(TEXT, N'动力区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1183, 1177, CONVERT(TEXT, N'平房区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1184, 1177, CONVERT(TEXT, N'松北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1185, 1177, CONVERT(TEXT, N'呼兰区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1186, 1177, CONVERT(TEXT, N'依兰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1187, 1177, CONVERT(TEXT, N'方正县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1188, 1177, CONVERT(TEXT, N'宾县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1189, 1177, CONVERT(TEXT, N'巴彦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1190, 1177, CONVERT(TEXT, N'木兰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1191, 1177, CONVERT(TEXT, N'通河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1192, 1177, CONVERT(TEXT, N'延寿县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1193, 1177, CONVERT(TEXT, N'阿城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1194, 1177, CONVERT(TEXT, N'双城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1195, 1177, CONVERT(TEXT, N'尚志市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1196, 1177, CONVERT(TEXT, N'五常市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1197, 1176, CONVERT(TEXT, N'大庆市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1198, 1197, CONVERT(TEXT, N'萨尔图区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1199, 1197, CONVERT(TEXT, N'龙凤区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1200, 1197, CONVERT(TEXT, N'让胡路区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1201, 1197, CONVERT(TEXT, N'红岗区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1202, 1197, CONVERT(TEXT, N'大同区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1203, 1197, CONVERT(TEXT, N'肇州县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1204, 1197, CONVERT(TEXT, N'肇源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1205, 1197, CONVERT(TEXT, N'林甸县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1206, 1197, CONVERT(TEXT, N'杜尔伯特蒙古族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1207, 1176, CONVERT(TEXT, N'大兴安岭地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1208, 1207, CONVERT(TEXT, N'呼玛县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1209, 1207, CONVERT(TEXT, N'塔河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1210, 1207, CONVERT(TEXT, N'漠河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1211, 1176, CONVERT(TEXT, N'鹤岗市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1212, 1211, CONVERT(TEXT, N'向阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1213, 1211, CONVERT(TEXT, N'工农区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1214, 1211, CONVERT(TEXT, N'南山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1215, 1211, CONVERT(TEXT, N'兴安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1216, 1211, CONVERT(TEXT, N'东山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1217, 1211, CONVERT(TEXT, N'兴山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1218, 1211, CONVERT(TEXT, N'萝北县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1219, 1211, CONVERT(TEXT, N'绥滨县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1220, 1176, CONVERT(TEXT, N'黑河市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1221, 1220, CONVERT(TEXT, N'爱辉区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1222, 1220, CONVERT(TEXT, N'嫩江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1223, 1220, CONVERT(TEXT, N'逊克县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1224, 1220, CONVERT(TEXT, N'孙吴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1225, 1220, CONVERT(TEXT, N'北安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1226, 1220, CONVERT(TEXT, N'五大连池市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1227, 1176, CONVERT(TEXT, N'鸡西市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1228, 1227, CONVERT(TEXT, N'鸡冠区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1229, 1227, CONVERT(TEXT, N'恒山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1230, 1227, CONVERT(TEXT, N'滴道区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1231, 1227, CONVERT(TEXT, N'梨树区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1232, 1227, CONVERT(TEXT, N'城子河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1233, 1227, CONVERT(TEXT, N'麻山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1234, 1227, CONVERT(TEXT, N'鸡东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1235, 1227, CONVERT(TEXT, N'虎林市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1236, 1227, CONVERT(TEXT, N'密山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1237, 1176, CONVERT(TEXT, N'佳木斯市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1238, 1237, CONVERT(TEXT, N'永红区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1239, 1237, CONVERT(TEXT, N'向阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1240, 1237, CONVERT(TEXT, N'前进区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1241, 1237, CONVERT(TEXT, N'东风区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1242, 1237, CONVERT(TEXT, N'郊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1243, 1237, CONVERT(TEXT, N'桦南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1244, 1237, CONVERT(TEXT, N'桦川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1245, 1237, CONVERT(TEXT, N'汤原县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1246, 1237, CONVERT(TEXT, N'抚远县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1247, 1237, CONVERT(TEXT, N'同江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1248, 1237, CONVERT(TEXT, N'富锦市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1249, 1176, CONVERT(TEXT, N'牡丹江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1250, 1249, CONVERT(TEXT, N'东安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1251, 1249, CONVERT(TEXT, N'阳明区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1252, 1249, CONVERT(TEXT, N'爱民区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1253, 1249, CONVERT(TEXT, N'西安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1254, 1249, CONVERT(TEXT, N'东宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1255, 1249, CONVERT(TEXT, N'林口县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1256, 1249, CONVERT(TEXT, N'绥芬河市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1257, 1249, CONVERT(TEXT, N'海林市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1258, 1249, CONVERT(TEXT, N'宁安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1259, 1249, CONVERT(TEXT, N'穆棱市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1260, 1176, CONVERT(TEXT, N'七台河市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1261, 1260, CONVERT(TEXT, N'新兴区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1262, 1260, CONVERT(TEXT, N'桃山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1263, 1260, CONVERT(TEXT, N'茄子河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1264, 1260, CONVERT(TEXT, N'勃利县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1265, 1176, CONVERT(TEXT, N'齐齐哈尔市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1266, 1265, CONVERT(TEXT, N'龙沙区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1267, 1265, CONVERT(TEXT, N'建华区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1268, 1265, CONVERT(TEXT, N'铁锋区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1269, 1265, CONVERT(TEXT, N'昂昂溪区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1270, 1265, CONVERT(TEXT, N'富拉尔基区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1271, 1265, CONVERT(TEXT, N'碾子山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1272, 1265, CONVERT(TEXT, N'梅里斯达斡尔族区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1273, 1265, CONVERT(TEXT, N'龙江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1274, 1265, CONVERT(TEXT, N'依安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1275, 1265, CONVERT(TEXT, N'泰来县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1276, 1265, CONVERT(TEXT, N'甘南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1277, 1265, CONVERT(TEXT, N'富裕县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1278, 1265, CONVERT(TEXT, N'克山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1279, 1265, CONVERT(TEXT, N'克东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1280, 1265, CONVERT(TEXT, N'拜泉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1281, 1265, CONVERT(TEXT, N'讷河市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1282, 1176, CONVERT(TEXT, N'双鸭山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1283, 1282, CONVERT(TEXT, N'尖山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1284, 1282, CONVERT(TEXT, N'岭东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1285, 1282, CONVERT(TEXT, N'四方台区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1286, 1282, CONVERT(TEXT, N'宝山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1287, 1282, CONVERT(TEXT, N'集贤县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1288, 1282, CONVERT(TEXT, N'友谊县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1289, 1282, CONVERT(TEXT, N'宝清县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1290, 1282, CONVERT(TEXT, N'饶河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1291, 1176, CONVERT(TEXT, N'绥化市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1292, 1291, CONVERT(TEXT, N'北林区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1293, 1291, CONVERT(TEXT, N'望奎县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1294, 1291, CONVERT(TEXT, N'兰西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1295, 1291, CONVERT(TEXT, N'青冈县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1296, 1291, CONVERT(TEXT, N'庆安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1297, 1291, CONVERT(TEXT, N'明水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1298, 1291, CONVERT(TEXT, N'绥棱县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1299, 1291, CONVERT(TEXT, N'安达市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1300, 1291, CONVERT(TEXT, N'肇东市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1301, 1291, CONVERT(TEXT, N'海伦市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1302, 1176, CONVERT(TEXT, N'伊春市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1303, 1302, CONVERT(TEXT, N'伊春区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1304, 1302, CONVERT(TEXT, N'南岔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1305, 1302, CONVERT(TEXT, N'友好区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1306, 1302, CONVERT(TEXT, N'西林区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1307, 1302, CONVERT(TEXT, N'翠峦区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1308, 1302, CONVERT(TEXT, N'新青区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1309, 1302, CONVERT(TEXT, N'美溪区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1310, 1302, CONVERT(TEXT, N'金山屯区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1311, 1302, CONVERT(TEXT, N'五营区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1312, 1302, CONVERT(TEXT, N'乌马河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1313, 1302, CONVERT(TEXT, N'汤旺河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1314, 1302, CONVERT(TEXT, N'带岭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1315, 1302, CONVERT(TEXT, N'乌伊岭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1316, 1302, CONVERT(TEXT, N'红星区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1317, 1302, CONVERT(TEXT, N'上甘岭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1318, 1302, CONVERT(TEXT, N'嘉荫县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1319, 1302, CONVERT(TEXT, N'铁力市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1320, 0, CONVERT(TEXT, N'湖北'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1321, 1320, CONVERT(TEXT, N'武汉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1322, 1321, CONVERT(TEXT, N'江岸区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1323, 1321, CONVERT(TEXT, N'江汉区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1324, 1321, CONVERT(TEXT, N'乔口区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1325, 1321, CONVERT(TEXT, N'汉阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1326, 1321, CONVERT(TEXT, N'武昌区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1327, 1321, CONVERT(TEXT, N'青山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1328, 1321, CONVERT(TEXT, N'洪山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1329, 1321, CONVERT(TEXT, N'东西湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1330, 1321, CONVERT(TEXT, N'汉南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1331, 1321, CONVERT(TEXT, N'蔡甸区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1332, 1321, CONVERT(TEXT, N'江夏区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1333, 1321, CONVERT(TEXT, N'黄陂区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1334, 1321, CONVERT(TEXT, N'新洲区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1335, 1320, CONVERT(TEXT, N'鄂州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1336, 1335, CONVERT(TEXT, N'梁子湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1337, 1335, CONVERT(TEXT, N'华容区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1338, 1335, CONVERT(TEXT, N'鄂城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1339, 1320, CONVERT(TEXT, N'恩施土家族苗族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1340, 1339, CONVERT(TEXT, N'恩施市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1341, 1339, CONVERT(TEXT, N'利川市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1342, 1339, CONVERT(TEXT, N'建始县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1343, 1339, CONVERT(TEXT, N'巴东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1344, 1339, CONVERT(TEXT, N'宣恩县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1345, 1339, CONVERT(TEXT, N'咸丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1346, 1339, CONVERT(TEXT, N'来凤县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1347, 1339, CONVERT(TEXT, N'鹤峰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1348, 1320, CONVERT(TEXT, N'黄冈市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1349, 1348, CONVERT(TEXT, N'黄州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1350, 1348, CONVERT(TEXT, N'团风县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1351, 1348, CONVERT(TEXT, N'红安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1352, 1348, CONVERT(TEXT, N'罗田县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1353, 1348, CONVERT(TEXT, N'英山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1354, 1348, CONVERT(TEXT, N'浠水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1355, 1348, CONVERT(TEXT, N'蕲春县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1356, 1348, CONVERT(TEXT, N'黄梅县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1357, 1348, CONVERT(TEXT, N'麻城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1358, 1348, CONVERT(TEXT, N'武穴市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1359, 1320, CONVERT(TEXT, N'黄石市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1360, 1359, CONVERT(TEXT, N'黄石港区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1361, 1359, CONVERT(TEXT, N'西塞山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1362, 1359, CONVERT(TEXT, N'下陆区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1363, 1359, CONVERT(TEXT, N'铁山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1364, 1359, CONVERT(TEXT, N'阳新县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1365, 1359, CONVERT(TEXT, N'大冶市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1366, 1320, CONVERT(TEXT, N'荆门市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1367, 1366, CONVERT(TEXT, N'东宝区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1368, 1366, CONVERT(TEXT, N'掇刀区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1369, 1366, CONVERT(TEXT, N'京山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1370, 1366, CONVERT(TEXT, N'沙洋县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1371, 1366, CONVERT(TEXT, N'钟祥市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1372, 1320, CONVERT(TEXT, N'荆州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1373, 1372, CONVERT(TEXT, N'沙市区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1374, 1372, CONVERT(TEXT, N'荆州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1375, 1372, CONVERT(TEXT, N'公安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1376, 1372, CONVERT(TEXT, N'监利县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1377, 1372, CONVERT(TEXT, N'江陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1378, 1372, CONVERT(TEXT, N'石首市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1379, 1372, CONVERT(TEXT, N'洪湖市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1380, 1372, CONVERT(TEXT, N'松滋市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1381, 1320, CONVERT(TEXT, N'潜江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1382, 1320, CONVERT(TEXT, N'神农架林区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1383, 1320, CONVERT(TEXT, N'十堰市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1384, 1383, CONVERT(TEXT, N'茅箭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1385, 1383, CONVERT(TEXT, N'张湾区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1386, 1383, CONVERT(TEXT, N'郧县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1387, 1383, CONVERT(TEXT, N'郧西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1388, 1383, CONVERT(TEXT, N'竹山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1389, 1383, CONVERT(TEXT, N'竹溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1390, 1383, CONVERT(TEXT, N'房县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1391, 1383, CONVERT(TEXT, N'丹江口市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1392, 1320, CONVERT(TEXT, N'随州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1393, 1392, CONVERT(TEXT, N'曾都区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1394, 1392, CONVERT(TEXT, N'广水市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1395, 1320, CONVERT(TEXT, N'天门市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1396, 1320, CONVERT(TEXT, N'仙桃市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1397, 1320, CONVERT(TEXT, N'咸宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1398, 1397, CONVERT(TEXT, N'咸安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1399, 1397, CONVERT(TEXT, N'嘉鱼县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1400, 1397, CONVERT(TEXT, N'通城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1401, 1397, CONVERT(TEXT, N'崇阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1402, 1397, CONVERT(TEXT, N'通山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1403, 1397, CONVERT(TEXT, N'赤壁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1404, 1320, CONVERT(TEXT, N'襄樊市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1405, 1404, CONVERT(TEXT, N'襄城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1406, 1404, CONVERT(TEXT, N'樊城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1407, 1404, CONVERT(TEXT, N'襄阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1408, 1404, CONVERT(TEXT, N'南漳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1409, 1404, CONVERT(TEXT, N'谷城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1410, 1404, CONVERT(TEXT, N'保康县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1411, 1404, CONVERT(TEXT, N'老河口市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1412, 1404, CONVERT(TEXT, N'枣阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1413, 1404, CONVERT(TEXT, N'宜城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1414, 1320, CONVERT(TEXT, N'孝感市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1415, 1414, CONVERT(TEXT, N'孝南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1416, 1414, CONVERT(TEXT, N'孝昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1417, 1414, CONVERT(TEXT, N'大悟县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1418, 1414, CONVERT(TEXT, N'云梦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1419, 1414, CONVERT(TEXT, N'应城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1420, 1414, CONVERT(TEXT, N'安陆市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1421, 1414, CONVERT(TEXT, N'汉川市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1422, 1320, CONVERT(TEXT, N'宜昌市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1423, 1422, CONVERT(TEXT, N'西陵区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1424, 1422, CONVERT(TEXT, N'伍家岗区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1425, 1422, CONVERT(TEXT, N'点军区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1426, 1422, CONVERT(TEXT, N'猇亭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1427, 1422, CONVERT(TEXT, N'夷陵区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1428, 1422, CONVERT(TEXT, N'远安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1429, 1422, CONVERT(TEXT, N'兴山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1430, 1422, CONVERT(TEXT, N'秭归县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1431, 1422, CONVERT(TEXT, N'长阳土家族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1432, 1422, CONVERT(TEXT, N'五峰土家族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1433, 1422, CONVERT(TEXT, N'宜都市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1434, 1422, CONVERT(TEXT, N'当阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1435, 1422, CONVERT(TEXT, N'枝江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1436, 0, CONVERT(TEXT, N'湖南'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1437, 1436, CONVERT(TEXT, N'长沙市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1438, 1437, CONVERT(TEXT, N'芙蓉区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1439, 1437, CONVERT(TEXT, N'天心区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1440, 1437, CONVERT(TEXT, N'岳麓区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1441, 1437, CONVERT(TEXT, N'开福区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1442, 1437, CONVERT(TEXT, N'雨花区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1443, 1437, CONVERT(TEXT, N'长沙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1444, 1437, CONVERT(TEXT, N'望城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1445, 1437, CONVERT(TEXT, N'宁乡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1446, 1437, CONVERT(TEXT, N'浏阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1447, 1436, CONVERT(TEXT, N'常德市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1448, 1447, CONVERT(TEXT, N'武陵区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1449, 1447, CONVERT(TEXT, N'鼎城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1450, 1447, CONVERT(TEXT, N'安乡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1451, 1447, CONVERT(TEXT, N'汉寿县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1452, 1447, CONVERT(TEXT, N'澧县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1453, 1447, CONVERT(TEXT, N'临澧县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1454, 1447, CONVERT(TEXT, N'桃源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1455, 1447, CONVERT(TEXT, N'石门县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1456, 1447, CONVERT(TEXT, N'津市市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1457, 1436, CONVERT(TEXT, N'郴州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1458, 1457, CONVERT(TEXT, N'北湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1459, 1457, CONVERT(TEXT, N'苏仙区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1460, 1457, CONVERT(TEXT, N'桂阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1461, 1457, CONVERT(TEXT, N'宜章县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1462, 1457, CONVERT(TEXT, N'永兴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1463, 1457, CONVERT(TEXT, N'嘉禾县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1464, 1457, CONVERT(TEXT, N'临武县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1465, 1457, CONVERT(TEXT, N'汝城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1466, 1457, CONVERT(TEXT, N'桂东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1467, 1457, CONVERT(TEXT, N'安仁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1468, 1457, CONVERT(TEXT, N'资兴市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1469, 1436, CONVERT(TEXT, N'衡阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1470, 1469, CONVERT(TEXT, N'珠晖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1471, 1469, CONVERT(TEXT, N'雁峰区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1472, 1469, CONVERT(TEXT, N'石鼓区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1473, 1469, CONVERT(TEXT, N'蒸湘区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1474, 1469, CONVERT(TEXT, N'南岳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1475, 1469, CONVERT(TEXT, N'衡阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1476, 1469, CONVERT(TEXT, N'衡南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1477, 1469, CONVERT(TEXT, N'衡山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1478, 1469, CONVERT(TEXT, N'衡东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1479, 1469, CONVERT(TEXT, N'祁东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1480, 1469, CONVERT(TEXT, N'耒阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1481, 1469, CONVERT(TEXT, N'常宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1482, 1436, CONVERT(TEXT, N'怀化市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1483, 1482, CONVERT(TEXT, N'鹤城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1484, 1482, CONVERT(TEXT, N'中方县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1485, 1482, CONVERT(TEXT, N'沅陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1486, 1482, CONVERT(TEXT, N'辰溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1487, 1482, CONVERT(TEXT, N'溆浦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1488, 1482, CONVERT(TEXT, N'会同县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1489, 1482, CONVERT(TEXT, N'麻阳苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1490, 1482, CONVERT(TEXT, N'新晃侗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1491, 1482, CONVERT(TEXT, N'芷江侗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1492, 1482, CONVERT(TEXT, N'靖州苗族侗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1493, 1482, CONVERT(TEXT, N'通道侗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1494, 1482, CONVERT(TEXT, N'洪江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1495, 1436, CONVERT(TEXT, N'娄底市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1496, 1495, CONVERT(TEXT, N'娄星区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1497, 1495, CONVERT(TEXT, N'双峰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1498, 1495, CONVERT(TEXT, N'新化县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1499, 1495, CONVERT(TEXT, N'冷水江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1500, 1495, CONVERT(TEXT, N'涟源市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1501, 1436, CONVERT(TEXT, N'邵阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1502, 1501, CONVERT(TEXT, N'双清区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1503, 1501, CONVERT(TEXT, N'大祥区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1504, 1501, CONVERT(TEXT, N'北塔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1505, 1501, CONVERT(TEXT, N'邵东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1506, 1501, CONVERT(TEXT, N'新邵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1507, 1501, CONVERT(TEXT, N'邵阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1508, 1501, CONVERT(TEXT, N'隆回县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1509, 1501, CONVERT(TEXT, N'洞口县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1510, 1501, CONVERT(TEXT, N'绥宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1511, 1501, CONVERT(TEXT, N'新宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1512, 1501, CONVERT(TEXT, N'城步苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1513, 1501, CONVERT(TEXT, N'武冈市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1514, 1436, CONVERT(TEXT, N'湘潭市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1515, 1514, CONVERT(TEXT, N'雨湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1516, 1514, CONVERT(TEXT, N'岳塘区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1517, 1514, CONVERT(TEXT, N'湘潭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1518, 1514, CONVERT(TEXT, N'湘乡市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1519, 1514, CONVERT(TEXT, N'韶山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1520, 1436, CONVERT(TEXT, N'湘西土家族苗族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1521, 1520, CONVERT(TEXT, N'吉首市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1522, 1520, CONVERT(TEXT, N'泸溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1523, 1520, CONVERT(TEXT, N'凤凰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1524, 1520, CONVERT(TEXT, N'花垣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1525, 1520, CONVERT(TEXT, N'保靖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1526, 1520, CONVERT(TEXT, N'古丈县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1527, 1520, CONVERT(TEXT, N'永顺县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1528, 1520, CONVERT(TEXT, N'龙山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1529, 1436, CONVERT(TEXT, N'益阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1530, 1529, CONVERT(TEXT, N'资阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1531, 1529, CONVERT(TEXT, N'赫山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1532, 1529, CONVERT(TEXT, N'南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1533, 1529, CONVERT(TEXT, N'桃江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1534, 1529, CONVERT(TEXT, N'安化县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1535, 1529, CONVERT(TEXT, N'沅江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1536, 1436, CONVERT(TEXT, N'永州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1537, 1536, CONVERT(TEXT, N'芝山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1538, 1536, CONVERT(TEXT, N'冷水滩区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1539, 1536, CONVERT(TEXT, N'祁阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1540, 1536, CONVERT(TEXT, N'东安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1541, 1536, CONVERT(TEXT, N'双牌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1542, 1536, CONVERT(TEXT, N'道县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1543, 1536, CONVERT(TEXT, N'江永县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1544, 1536, CONVERT(TEXT, N'宁远县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1545, 1536, CONVERT(TEXT, N'蓝山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1546, 1536, CONVERT(TEXT, N'新田县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1547, 1536, CONVERT(TEXT, N'江华瑶族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1548, 1436, CONVERT(TEXT, N'岳阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1549, 1548, CONVERT(TEXT, N'岳阳楼区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1550, 1548, CONVERT(TEXT, N'云溪区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1551, 1548, CONVERT(TEXT, N'君山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1552, 1548, CONVERT(TEXT, N'岳阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1553, 1548, CONVERT(TEXT, N'华容县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1554, 1548, CONVERT(TEXT, N'湘阴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1555, 1548, CONVERT(TEXT, N'平江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1556, 1548, CONVERT(TEXT, N'汨罗市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1557, 1548, CONVERT(TEXT, N'临湘市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1558, 1436, CONVERT(TEXT, N'张家界市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1559, 1558, CONVERT(TEXT, N'永定区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1560, 1558, CONVERT(TEXT, N'武陵源区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1561, 1558, CONVERT(TEXT, N'慈利县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1562, 1558, CONVERT(TEXT, N'桑植县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1563, 1436, CONVERT(TEXT, N'株洲市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1564, 1563, CONVERT(TEXT, N'荷塘区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1565, 1563, CONVERT(TEXT, N'芦淞区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1566, 1563, CONVERT(TEXT, N'石峰区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1567, 1563, CONVERT(TEXT, N'天元区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1568, 1563, CONVERT(TEXT, N'株洲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1569, 1563, CONVERT(TEXT, N'攸县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1570, 1563, CONVERT(TEXT, N'茶陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1571, 1563, CONVERT(TEXT, N'炎陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1572, 1563, CONVERT(TEXT, N'醴陵市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1573, 0, CONVERT(TEXT, N'吉林'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1574, 1573, CONVERT(TEXT, N'长春市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1575, 1574, CONVERT(TEXT, N'南关区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1576, 1574, CONVERT(TEXT, N'宽城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1577, 1574, CONVERT(TEXT, N'朝阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1578, 1574, CONVERT(TEXT, N'二道区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1579, 1574, CONVERT(TEXT, N'绿园区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1580, 1574, CONVERT(TEXT, N'双阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1581, 1574, CONVERT(TEXT, N'农安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1582, 1574, CONVERT(TEXT, N'九台市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1583, 1574, CONVERT(TEXT, N'榆树市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1584, 1574, CONVERT(TEXT, N'德惠市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1585, 1573, CONVERT(TEXT, N'白城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1586, 1585, CONVERT(TEXT, N'洮北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1587, 1585, CONVERT(TEXT, N'镇赉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1588, 1585, CONVERT(TEXT, N'通榆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1589, 1585, CONVERT(TEXT, N'洮南市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1590, 1585, CONVERT(TEXT, N'大安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1591, 1573, CONVERT(TEXT, N'白山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1592, 1591, CONVERT(TEXT, N'八道江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1593, 1591, CONVERT(TEXT, N'抚松县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1594, 1591, CONVERT(TEXT, N'靖宇县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1595, 1591, CONVERT(TEXT, N'长白朝鲜族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1596, 1591, CONVERT(TEXT, N'江源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1597, 1591, CONVERT(TEXT, N'临江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1598, 1573, CONVERT(TEXT, N'吉林市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1599, 1598, CONVERT(TEXT, N'昌邑区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1600, 1598, CONVERT(TEXT, N'龙潭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1601, 1598, CONVERT(TEXT, N'船营区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1602, 1598, CONVERT(TEXT, N'丰满区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1603, 1598, CONVERT(TEXT, N'永吉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1604, 1598, CONVERT(TEXT, N'蛟河市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1605, 1598, CONVERT(TEXT, N'桦甸市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1606, 1598, CONVERT(TEXT, N'舒兰市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1607, 1598, CONVERT(TEXT, N'磐石市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1608, 1573, CONVERT(TEXT, N'辽源市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1609, 1608, CONVERT(TEXT, N'龙山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1610, 1608, CONVERT(TEXT, N'西安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1611, 1608, CONVERT(TEXT, N'东丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1612, 1608, CONVERT(TEXT, N'东辽县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1613, 1573, CONVERT(TEXT, N'四平市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1614, 1613, CONVERT(TEXT, N'铁西区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1615, 1613, CONVERT(TEXT, N'铁东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1616, 1613, CONVERT(TEXT, N'梨树县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1617, 1613, CONVERT(TEXT, N'伊通满族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1618, 1613, CONVERT(TEXT, N'公主岭市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1619, 1613, CONVERT(TEXT, N'双辽市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1620, 1573, CONVERT(TEXT, N'松原市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1621, 1620, CONVERT(TEXT, N'宁江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1622, 1620, CONVERT(TEXT, N'前郭尔罗斯蒙古族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1623, 1620, CONVERT(TEXT, N'长岭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1624, 1620, CONVERT(TEXT, N'乾安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1625, 1620, CONVERT(TEXT, N'扶余县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1626, 1573, CONVERT(TEXT, N'通化市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1627, 1626, CONVERT(TEXT, N'东昌区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1628, 1626, CONVERT(TEXT, N'二道江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1629, 1626, CONVERT(TEXT, N'通化县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1630, 1626, CONVERT(TEXT, N'辉南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1631, 1626, CONVERT(TEXT, N'柳河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1632, 1626, CONVERT(TEXT, N'梅河口市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1633, 1626, CONVERT(TEXT, N'集安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1634, 1573, CONVERT(TEXT, N'延边朝鲜族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1635, 1634, CONVERT(TEXT, N'延吉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1636, 1634, CONVERT(TEXT, N'图们市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1637, 1634, CONVERT(TEXT, N'敦化市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1638, 1634, CONVERT(TEXT, N'珲春市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1639, 1634, CONVERT(TEXT, N'龙井市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1640, 1634, CONVERT(TEXT, N'和龙市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1641, 1634, CONVERT(TEXT, N'汪清县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1642, 1634, CONVERT(TEXT, N'安图县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1643, 0, CONVERT(TEXT, N'江苏'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1644, 1643, CONVERT(TEXT, N'南京市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1645, 1644, CONVERT(TEXT, N'玄武区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1646, 1644, CONVERT(TEXT, N'白下区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1647, 1644, CONVERT(TEXT, N'秦淮区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1648, 1644, CONVERT(TEXT, N'建邺区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1649, 1644, CONVERT(TEXT, N'鼓楼区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1650, 1644, CONVERT(TEXT, N'下关区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1651, 1644, CONVERT(TEXT, N'浦口区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1652, 1644, CONVERT(TEXT, N'栖霞区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1653, 1644, CONVERT(TEXT, N'雨花台区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1654, 1644, CONVERT(TEXT, N'江宁区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1655, 1644, CONVERT(TEXT, N'六合区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1656, 1644, CONVERT(TEXT, N'溧水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1657, 1644, CONVERT(TEXT, N'高淳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1658, 1643, CONVERT(TEXT, N'常州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1659, 1658, CONVERT(TEXT, N'天宁区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1660, 1658, CONVERT(TEXT, N'钟楼区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1661, 1658, CONVERT(TEXT, N'戚墅堰区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1662, 1658, CONVERT(TEXT, N'新北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1663, 1658, CONVERT(TEXT, N'武进区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1664, 1658, CONVERT(TEXT, N'溧阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1665, 1658, CONVERT(TEXT, N'金坛市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1666, 1643, CONVERT(TEXT, N'淮安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1667, 1666, CONVERT(TEXT, N'清河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1668, 1666, CONVERT(TEXT, N'楚州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1669, 1666, CONVERT(TEXT, N'淮阴区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1670, 1666, CONVERT(TEXT, N'清浦区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1671, 1666, CONVERT(TEXT, N'涟水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1672, 1666, CONVERT(TEXT, N'洪泽县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1673, 1666, CONVERT(TEXT, N'盱眙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1674, 1666, CONVERT(TEXT, N'金湖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1675, 1643, CONVERT(TEXT, N'连云港市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1676, 1675, CONVERT(TEXT, N'连云区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1677, 1675, CONVERT(TEXT, N'新浦区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1678, 1675, CONVERT(TEXT, N'海州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1679, 1675, CONVERT(TEXT, N'赣榆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1680, 1675, CONVERT(TEXT, N'东海县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1681, 1675, CONVERT(TEXT, N'灌云县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1682, 1675, CONVERT(TEXT, N'灌南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1683, 1643, CONVERT(TEXT, N'南通市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1684, 1683, CONVERT(TEXT, N'崇川区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1685, 1683, CONVERT(TEXT, N'港闸区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1686, 1683, CONVERT(TEXT, N'海安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1687, 1683, CONVERT(TEXT, N'如东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1688, 1683, CONVERT(TEXT, N'启东市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1689, 1683, CONVERT(TEXT, N'如皋市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1690, 1683, CONVERT(TEXT, N'通州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1691, 1683, CONVERT(TEXT, N'海门市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1692, 1643, CONVERT(TEXT, N'苏州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1693, 1692, CONVERT(TEXT, N'沧浪区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1694, 1692, CONVERT(TEXT, N'平江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1695, 1692, CONVERT(TEXT, N'金阊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1696, 1692, CONVERT(TEXT, N'虎丘区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1697, 1692, CONVERT(TEXT, N'吴中区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1698, 1692, CONVERT(TEXT, N'相城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1699, 1692, CONVERT(TEXT, N'常熟市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1700, 1692, CONVERT(TEXT, N'张家港市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1701, 1692, CONVERT(TEXT, N'昆山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1702, 1692, CONVERT(TEXT, N'吴江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1703, 1692, CONVERT(TEXT, N'太仓市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1704, 1643, CONVERT(TEXT, N'宿迁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1705, 1704, CONVERT(TEXT, N'宿城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1706, 1704, CONVERT(TEXT, N'宿豫区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1707, 1704, CONVERT(TEXT, N'沭阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1708, 1704, CONVERT(TEXT, N'泗阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1709, 1704, CONVERT(TEXT, N'泗洪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1710, 1643, CONVERT(TEXT, N'泰州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1711, 1710, CONVERT(TEXT, N'海陵区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1712, 1710, CONVERT(TEXT, N'高港区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1713, 1710, CONVERT(TEXT, N'兴化市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1714, 1710, CONVERT(TEXT, N'靖江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1715, 1710, CONVERT(TEXT, N'泰兴市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1716, 1710, CONVERT(TEXT, N'姜堰市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1717, 1643, CONVERT(TEXT, N'无锡市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1718, 1717, CONVERT(TEXT, N'崇安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1719, 1717, CONVERT(TEXT, N'南长区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1720, 1717, CONVERT(TEXT, N'北塘区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1721, 1717, CONVERT(TEXT, N'锡山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1722, 1717, CONVERT(TEXT, N'惠山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1723, 1717, CONVERT(TEXT, N'滨湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1724, 1717, CONVERT(TEXT, N'江阴市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1725, 1717, CONVERT(TEXT, N'宜兴市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1726, 1643, CONVERT(TEXT, N'徐州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1727, 1726, CONVERT(TEXT, N'鼓楼区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1728, 1726, CONVERT(TEXT, N'云龙区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1729, 1726, CONVERT(TEXT, N'九里区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1730, 1726, CONVERT(TEXT, N'贾汪区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1731, 1726, CONVERT(TEXT, N'泉山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1732, 1726, CONVERT(TEXT, N'丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1733, 1726, CONVERT(TEXT, N'沛县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1734, 1726, CONVERT(TEXT, N'铜山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1735, 1726, CONVERT(TEXT, N'睢宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1736, 1726, CONVERT(TEXT, N'新沂市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1737, 1726, CONVERT(TEXT, N'邳州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1738, 1643, CONVERT(TEXT, N'盐城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1739, 1738, CONVERT(TEXT, N'亭湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1740, 1738, CONVERT(TEXT, N'盐都区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1741, 1738, CONVERT(TEXT, N'响水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1742, 1738, CONVERT(TEXT, N'滨海县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1743, 1738, CONVERT(TEXT, N'阜宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1744, 1738, CONVERT(TEXT, N'射阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1745, 1738, CONVERT(TEXT, N'建湖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1746, 1738, CONVERT(TEXT, N'东台市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1747, 1738, CONVERT(TEXT, N'大丰市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1748, 1643, CONVERT(TEXT, N'扬州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1749, 1748, CONVERT(TEXT, N'广陵区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1750, 1748, CONVERT(TEXT, N'邗江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1751, 1748, CONVERT(TEXT, N'郊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1752, 1748, CONVERT(TEXT, N'宝应县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1753, 1748, CONVERT(TEXT, N'仪征市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1754, 1748, CONVERT(TEXT, N'高邮市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1755, 1748, CONVERT(TEXT, N'江都市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1756, 1643, CONVERT(TEXT, N'镇江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1757, 1756, CONVERT(TEXT, N'京口区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1758, 1756, CONVERT(TEXT, N'润州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1759, 1756, CONVERT(TEXT, N'丹徒区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1760, 1756, CONVERT(TEXT, N'丹阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1761, 1756, CONVERT(TEXT, N'扬中市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1762, 1756, CONVERT(TEXT, N'句容市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1763, 0, CONVERT(TEXT, N'江西'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1764, 1763, CONVERT(TEXT, N'南昌市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1765, 1764, CONVERT(TEXT, N'东湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1766, 1764, CONVERT(TEXT, N'西湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1767, 1764, CONVERT(TEXT, N'青云谱区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1768, 1764, CONVERT(TEXT, N'湾里区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1769, 1764, CONVERT(TEXT, N'青山湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1770, 1764, CONVERT(TEXT, N'南昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1771, 1764, CONVERT(TEXT, N'新建县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1772, 1764, CONVERT(TEXT, N'安义县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1773, 1764, CONVERT(TEXT, N'进贤县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1774, 1763, CONVERT(TEXT, N'抚州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1775, 1774, CONVERT(TEXT, N'临川区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1776, 1774, CONVERT(TEXT, N'南城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1777, 1774, CONVERT(TEXT, N'黎川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1778, 1774, CONVERT(TEXT, N'南丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1779, 1774, CONVERT(TEXT, N'崇仁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1780, 1774, CONVERT(TEXT, N'乐安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1781, 1774, CONVERT(TEXT, N'宜黄县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1782, 1774, CONVERT(TEXT, N'金溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1783, 1774, CONVERT(TEXT, N'资溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1784, 1774, CONVERT(TEXT, N'东乡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1785, 1774, CONVERT(TEXT, N'广昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1786, 1763, CONVERT(TEXT, N'赣州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1787, 1786, CONVERT(TEXT, N'章贡区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1788, 1786, CONVERT(TEXT, N'赣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1789, 1786, CONVERT(TEXT, N'信丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1790, 1786, CONVERT(TEXT, N'大余县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1791, 1786, CONVERT(TEXT, N'上犹县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1792, 1786, CONVERT(TEXT, N'崇义县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1793, 1786, CONVERT(TEXT, N'安远县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1794, 1786, CONVERT(TEXT, N'龙南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1795, 1786, CONVERT(TEXT, N'定南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1796, 1786, CONVERT(TEXT, N'全南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1797, 1786, CONVERT(TEXT, N'宁都县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1798, 1786, CONVERT(TEXT, N'于都县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1799, 1786, CONVERT(TEXT, N'兴国县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1800, 1786, CONVERT(TEXT, N'会昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1801, 1786, CONVERT(TEXT, N'寻乌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1802, 1786, CONVERT(TEXT, N'石城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1803, 1786, CONVERT(TEXT, N'瑞金市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1804, 1786, CONVERT(TEXT, N'南康市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1805, 1763, CONVERT(TEXT, N'吉安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1806, 1805, CONVERT(TEXT, N'吉州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1807, 1805, CONVERT(TEXT, N'青原区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1808, 1805, CONVERT(TEXT, N'吉安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1809, 1805, CONVERT(TEXT, N'吉水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1810, 1805, CONVERT(TEXT, N'峡江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1811, 1805, CONVERT(TEXT, N'新干县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1812, 1805, CONVERT(TEXT, N'永丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1813, 1805, CONVERT(TEXT, N'泰和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1814, 1805, CONVERT(TEXT, N'遂川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1815, 1805, CONVERT(TEXT, N'万安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1816, 1805, CONVERT(TEXT, N'安福县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1817, 1805, CONVERT(TEXT, N'永新县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1818, 1805, CONVERT(TEXT, N'井冈山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1819, 1763, CONVERT(TEXT, N'景德镇市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1820, 1819, CONVERT(TEXT, N'昌江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1821, 1819, CONVERT(TEXT, N'珠山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1822, 1819, CONVERT(TEXT, N'浮梁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1823, 1819, CONVERT(TEXT, N'乐平市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1824, 1763, CONVERT(TEXT, N'九江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1825, 1824, CONVERT(TEXT, N'庐山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1826, 1824, CONVERT(TEXT, N'浔阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1827, 1824, CONVERT(TEXT, N'九江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1828, 1824, CONVERT(TEXT, N'武宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1829, 1824, CONVERT(TEXT, N'修水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1830, 1824, CONVERT(TEXT, N'永修县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1831, 1824, CONVERT(TEXT, N'德安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1832, 1824, CONVERT(TEXT, N'星子县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1833, 1824, CONVERT(TEXT, N'都昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1834, 1824, CONVERT(TEXT, N'湖口县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1835, 1824, CONVERT(TEXT, N'彭泽县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1836, 1824, CONVERT(TEXT, N'瑞昌市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1837, 1763, CONVERT(TEXT, N'萍乡市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1838, 1837, CONVERT(TEXT, N'安源区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1839, 1837, CONVERT(TEXT, N'湘东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1840, 1837, CONVERT(TEXT, N'莲花县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1841, 1837, CONVERT(TEXT, N'上栗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1842, 1837, CONVERT(TEXT, N'芦溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1843, 1763, CONVERT(TEXT, N'上饶市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1844, 1843, CONVERT(TEXT, N'信州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1845, 1843, CONVERT(TEXT, N'上饶县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1846, 1843, CONVERT(TEXT, N'广丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1847, 1843, CONVERT(TEXT, N'玉山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1848, 1843, CONVERT(TEXT, N'铅山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1849, 1843, CONVERT(TEXT, N'横峰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1850, 1843, CONVERT(TEXT, N'弋阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1851, 1843, CONVERT(TEXT, N'余干县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1852, 1843, CONVERT(TEXT, N'鄱阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1853, 1843, CONVERT(TEXT, N'万年县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1854, 1843, CONVERT(TEXT, N'婺源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1855, 1843, CONVERT(TEXT, N'德兴市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1856, 1763, CONVERT(TEXT, N'新余市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1857, 1856, CONVERT(TEXT, N'渝水区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1858, 1856, CONVERT(TEXT, N'分宜县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1859, 1763, CONVERT(TEXT, N'宜春市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1860, 1859, CONVERT(TEXT, N'袁州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1861, 1859, CONVERT(TEXT, N'奉新县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1862, 1859, CONVERT(TEXT, N'万载县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1863, 1859, CONVERT(TEXT, N'上高县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1864, 1859, CONVERT(TEXT, N'宜丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1865, 1859, CONVERT(TEXT, N'靖安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1866, 1859, CONVERT(TEXT, N'铜鼓县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1867, 1859, CONVERT(TEXT, N'丰城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1868, 1859, CONVERT(TEXT, N'樟树市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1869, 1859, CONVERT(TEXT, N'高安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1870, 1763, CONVERT(TEXT, N'鹰潭市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1871, 1870, CONVERT(TEXT, N'月湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1872, 1870, CONVERT(TEXT, N'余江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1873, 1870, CONVERT(TEXT, N'贵溪市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1874, 0, CONVERT(TEXT, N'辽宁'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1875, 1874, CONVERT(TEXT, N'沈阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1876, 1875, CONVERT(TEXT, N'和平区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1877, 1875, CONVERT(TEXT, N'沈河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1878, 1875, CONVERT(TEXT, N'大东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1879, 1875, CONVERT(TEXT, N'皇姑区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1880, 1875, CONVERT(TEXT, N'铁西区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1881, 1875, CONVERT(TEXT, N'苏家屯区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1882, 1875, CONVERT(TEXT, N'东陵区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1883, 1875, CONVERT(TEXT, N'新城子区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1884, 1875, CONVERT(TEXT, N'于洪区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1885, 1875, CONVERT(TEXT, N'辽中县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1886, 1875, CONVERT(TEXT, N'康平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1887, 1875, CONVERT(TEXT, N'法库县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1888, 1875, CONVERT(TEXT, N'新民市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1889, 1874, CONVERT(TEXT, N'鞍山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1890, 1889, CONVERT(TEXT, N'铁东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1891, 1889, CONVERT(TEXT, N'铁西区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1892, 1889, CONVERT(TEXT, N'立山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1893, 1889, CONVERT(TEXT, N'千山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1894, 1889, CONVERT(TEXT, N'台安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1895, 1889, CONVERT(TEXT, N'岫岩满族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1896, 1889, CONVERT(TEXT, N'海城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1897, 1874, CONVERT(TEXT, N'本溪市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1898, 1897, CONVERT(TEXT, N'平山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1899, 1897, CONVERT(TEXT, N'溪湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1900, 1897, CONVERT(TEXT, N'明山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1901, 1897, CONVERT(TEXT, N'南芬区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1902, 1897, CONVERT(TEXT, N'本溪满族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1903, 1897, CONVERT(TEXT, N'桓仁满族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1904, 1874, CONVERT(TEXT, N'朝阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1905, 1904, CONVERT(TEXT, N'双塔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1906, 1904, CONVERT(TEXT, N'龙城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1907, 1904, CONVERT(TEXT, N'朝阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1908, 1904, CONVERT(TEXT, N'建平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1909, 1904, CONVERT(TEXT, N'喀喇沁左翼蒙古族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1910, 1904, CONVERT(TEXT, N'北票市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1911, 1904, CONVERT(TEXT, N'凌源市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1912, 1874, CONVERT(TEXT, N'大连市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1913, 1912, CONVERT(TEXT, N'中山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1914, 1912, CONVERT(TEXT, N'西岗区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1915, 1912, CONVERT(TEXT, N'沙河口区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1916, 1912, CONVERT(TEXT, N'甘井子区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1917, 1912, CONVERT(TEXT, N'旅顺口区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1918, 1912, CONVERT(TEXT, N'金州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1919, 1912, CONVERT(TEXT, N'长海县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1920, 1912, CONVERT(TEXT, N'瓦房店市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1921, 1912, CONVERT(TEXT, N'普兰店市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1922, 1912, CONVERT(TEXT, N'庄河市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1923, 1874, CONVERT(TEXT, N'丹东市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1924, 1923, CONVERT(TEXT, N'元宝区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1925, 1923, CONVERT(TEXT, N'振兴区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1926, 1923, CONVERT(TEXT, N'振安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1927, 1923, CONVERT(TEXT, N'宽甸满族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1928, 1923, CONVERT(TEXT, N'东港市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1929, 1923, CONVERT(TEXT, N'凤城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1930, 1874, CONVERT(TEXT, N'抚顺市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1931, 1930, CONVERT(TEXT, N'新抚区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1932, 1930, CONVERT(TEXT, N'东洲区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1933, 1930, CONVERT(TEXT, N'望花区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1934, 1930, CONVERT(TEXT, N'顺城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1935, 1930, CONVERT(TEXT, N'抚顺县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1936, 1930, CONVERT(TEXT, N'新宾满族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1937, 1930, CONVERT(TEXT, N'清原满族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1938, 1874, CONVERT(TEXT, N'阜新市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1939, 1938, CONVERT(TEXT, N'海州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1940, 1938, CONVERT(TEXT, N'新邱区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1941, 1938, CONVERT(TEXT, N'太平区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1942, 1938, CONVERT(TEXT, N'清河门区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1943, 1938, CONVERT(TEXT, N'细河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1944, 1938, CONVERT(TEXT, N'阜新蒙古族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1945, 1938, CONVERT(TEXT, N'彰武县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1946, 1874, CONVERT(TEXT, N'葫芦岛市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1947, 1946, CONVERT(TEXT, N'连山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1948, 1946, CONVERT(TEXT, N'龙港区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1949, 1946, CONVERT(TEXT, N'南票区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1950, 1946, CONVERT(TEXT, N'绥中县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1951, 1946, CONVERT(TEXT, N'建昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1952, 1946, CONVERT(TEXT, N'兴城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1953, 1874, CONVERT(TEXT, N'锦州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1954, 1953, CONVERT(TEXT, N'古塔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1955, 1953, CONVERT(TEXT, N'凌河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1956, 1953, CONVERT(TEXT, N'太和区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1957, 1953, CONVERT(TEXT, N'黑山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1958, 1953, CONVERT(TEXT, N'义县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1959, 1953, CONVERT(TEXT, N'凌海市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1960, 1953, CONVERT(TEXT, N'北宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1961, 1874, CONVERT(TEXT, N'辽阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1962, 1961, CONVERT(TEXT, N'白塔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1963, 1961, CONVERT(TEXT, N'文圣区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1964, 1961, CONVERT(TEXT, N'宏伟区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1965, 1961, CONVERT(TEXT, N'弓长岭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1966, 1961, CONVERT(TEXT, N'太子河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1967, 1961, CONVERT(TEXT, N'辽阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1968, 1961, CONVERT(TEXT, N'灯塔市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1969, 1874, CONVERT(TEXT, N'盘锦市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1970, 1969, CONVERT(TEXT, N'双台子区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1971, 1969, CONVERT(TEXT, N'兴隆台区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1972, 1969, CONVERT(TEXT, N'大洼县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1973, 1969, CONVERT(TEXT, N'盘山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1974, 1874, CONVERT(TEXT, N'铁岭市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1975, 1974, CONVERT(TEXT, N'银州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1976, 1974, CONVERT(TEXT, N'清河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1977, 1974, CONVERT(TEXT, N'铁岭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1978, 1974, CONVERT(TEXT, N'西丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1979, 1974, CONVERT(TEXT, N'昌图县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1980, 1974, CONVERT(TEXT, N'调兵山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1981, 1974, CONVERT(TEXT, N'开原市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1982, 1874, CONVERT(TEXT, N'营口市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1983, 1982, CONVERT(TEXT, N'站前区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1984, 1982, CONVERT(TEXT, N'西市区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1985, 1982, CONVERT(TEXT, N'鲅鱼圈区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1986, 1982, CONVERT(TEXT, N'老边区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1987, 1982, CONVERT(TEXT, N'盖州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1988, 1982, CONVERT(TEXT, N'大石桥市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1989, 0, CONVERT(TEXT, N'内蒙古'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1990, 1989, CONVERT(TEXT, N'呼和浩特市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1991, 1990, CONVERT(TEXT, N'新城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1992, 1990, CONVERT(TEXT, N'回民区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1993, 1990, CONVERT(TEXT, N'玉泉区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1994, 1990, CONVERT(TEXT, N'赛罕区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1995, 1990, CONVERT(TEXT, N'土默特左旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1996, 1990, CONVERT(TEXT, N'托克托县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1997, 1990, CONVERT(TEXT, N'和林格尔县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1998, 1990, CONVERT(TEXT, N'清水河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (1999, 1990, CONVERT(TEXT, N'武川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2000, 1989, CONVERT(TEXT, N'阿拉善盟'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2001, 2000, CONVERT(TEXT, N'阿拉善左旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2002, 2000, CONVERT(TEXT, N'阿拉善右旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2003, 2000, CONVERT(TEXT, N'额济纳旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2004, 1989, CONVERT(TEXT, N'巴彦淖尔市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2005, 2004, CONVERT(TEXT, N'临河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2006, 2004, CONVERT(TEXT, N'五原县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2007, 2004, CONVERT(TEXT, N'磴口县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2008, 2004, CONVERT(TEXT, N'乌拉特前旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2009, 2004, CONVERT(TEXT, N'乌拉特中旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2010, 2004, CONVERT(TEXT, N'乌拉特后旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2011, 2004, CONVERT(TEXT, N'杭锦后旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2012, 1989, CONVERT(TEXT, N'包头市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2013, 2012, CONVERT(TEXT, N'东河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2014, 2012, CONVERT(TEXT, N'昆都仑区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2015, 2012, CONVERT(TEXT, N'青山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2016, 2012, CONVERT(TEXT, N'石拐区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2017, 2012, CONVERT(TEXT, N'白云矿区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2018, 2012, CONVERT(TEXT, N'九原区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2019, 2012, CONVERT(TEXT, N'土默特右旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2020, 2012, CONVERT(TEXT, N'固阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2021, 2012, CONVERT(TEXT, N'达尔罕茂明安联合旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2022, 1989, CONVERT(TEXT, N'赤峰市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2023, 2022, CONVERT(TEXT, N'红山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2024, 2022, CONVERT(TEXT, N'元宝山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2025, 2022, CONVERT(TEXT, N'松山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2026, 2022, CONVERT(TEXT, N'阿鲁科尔沁旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2027, 2022, CONVERT(TEXT, N'巴林左旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2028, 2022, CONVERT(TEXT, N'巴林右旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2029, 2022, CONVERT(TEXT, N'林西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2030, 2022, CONVERT(TEXT, N'克什克腾旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2031, 2022, CONVERT(TEXT, N'翁牛特旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2032, 2022, CONVERT(TEXT, N'喀喇沁旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2033, 2022, CONVERT(TEXT, N'宁城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2034, 2022, CONVERT(TEXT, N'敖汉旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2035, 1989, CONVERT(TEXT, N'鄂尔多斯市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2036, 2035, CONVERT(TEXT, N'东胜区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2037, 2035, CONVERT(TEXT, N'达拉特旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2038, 2035, CONVERT(TEXT, N'准格尔旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2039, 2035, CONVERT(TEXT, N'鄂托克前旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2040, 2035, CONVERT(TEXT, N'鄂托克旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2041, 2035, CONVERT(TEXT, N'杭锦旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2042, 2035, CONVERT(TEXT, N'乌审旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2043, 2035, CONVERT(TEXT, N'伊金霍洛旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2044, 1989, CONVERT(TEXT, N'呼伦贝尔市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2045, 2044, CONVERT(TEXT, N'海拉尔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2046, 2044, CONVERT(TEXT, N'阿荣旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2047, 2044, CONVERT(TEXT, N'莫力达瓦达斡尔族自治旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2048, 2044, CONVERT(TEXT, N'鄂伦春自治旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2049, 2044, CONVERT(TEXT, N'鄂温克族自治旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2050, 2044, CONVERT(TEXT, N'陈巴尔虎旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2051, 2044, CONVERT(TEXT, N'新巴尔虎左旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2052, 2044, CONVERT(TEXT, N'新巴尔虎右旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2053, 2044, CONVERT(TEXT, N'满洲里市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2054, 2044, CONVERT(TEXT, N'牙克石市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2055, 2044, CONVERT(TEXT, N'扎兰屯市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2056, 2044, CONVERT(TEXT, N'额尔古纳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2057, 2044, CONVERT(TEXT, N'根河市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2058, 1989, CONVERT(TEXT, N'通辽市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2059, 2058, CONVERT(TEXT, N'科尔沁区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2060, 2058, CONVERT(TEXT, N'科尔沁左翼中旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2061, 2058, CONVERT(TEXT, N'科尔沁左翼后旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2062, 2058, CONVERT(TEXT, N'开鲁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2063, 2058, CONVERT(TEXT, N'库伦旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2064, 2058, CONVERT(TEXT, N'奈曼旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2065, 2058, CONVERT(TEXT, N'扎鲁特旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2066, 2058, CONVERT(TEXT, N'霍林郭勒市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2067, 1989, CONVERT(TEXT, N'乌海市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2068, 2067, CONVERT(TEXT, N'海勃湾区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2069, 2067, CONVERT(TEXT, N'海南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2070, 2067, CONVERT(TEXT, N'乌达区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2071, 1989, CONVERT(TEXT, N'乌兰察布市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2072, 2071, CONVERT(TEXT, N'集宁区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2073, 2071, CONVERT(TEXT, N'卓资县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2074, 2071, CONVERT(TEXT, N'化德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2075, 2071, CONVERT(TEXT, N'商都县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2076, 2071, CONVERT(TEXT, N'兴和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2077, 2071, CONVERT(TEXT, N'凉城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2078, 2071, CONVERT(TEXT, N'察哈尔右翼前旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2079, 2071, CONVERT(TEXT, N'察哈尔右翼中旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2080, 2071, CONVERT(TEXT, N'察哈尔右翼后旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2081, 2071, CONVERT(TEXT, N'四子王旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2082, 2071, CONVERT(TEXT, N'丰镇市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2083, 1989, CONVERT(TEXT, N'锡林郭勒盟'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2084, 2083, CONVERT(TEXT, N'二连浩特市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2085, 2083, CONVERT(TEXT, N'锡林浩特市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2086, 2083, CONVERT(TEXT, N'阿巴嘎旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2087, 2083, CONVERT(TEXT, N'苏尼特左旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2088, 2083, CONVERT(TEXT, N'苏尼特右旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2089, 2083, CONVERT(TEXT, N'东乌珠穆沁旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2090, 2083, CONVERT(TEXT, N'西乌珠穆沁旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2091, 2083, CONVERT(TEXT, N'太仆寺旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2092, 2083, CONVERT(TEXT, N'镶黄旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2093, 2083, CONVERT(TEXT, N'正镶白旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2094, 2083, CONVERT(TEXT, N'正蓝旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2095, 2083, CONVERT(TEXT, N'多伦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2096, 1989, CONVERT(TEXT, N'兴安盟'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2097, 2096, CONVERT(TEXT, N'乌兰浩特市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2098, 2096, CONVERT(TEXT, N'阿尔山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2099, 2096, CONVERT(TEXT, N'科尔沁右翼前旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2100, 2096, CONVERT(TEXT, N'科尔沁右翼中旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2101, 2096, CONVERT(TEXT, N'扎赉特旗'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2102, 2096, CONVERT(TEXT, N'突泉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2103, 0, CONVERT(TEXT, N'宁夏'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2104, 2103, CONVERT(TEXT, N'银川市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2105, 2104, CONVERT(TEXT, N'兴庆区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2106, 2104, CONVERT(TEXT, N'西夏区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2107, 2104, CONVERT(TEXT, N'金凤区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2108, 2104, CONVERT(TEXT, N'永宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2109, 2104, CONVERT(TEXT, N'贺兰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2110, 2104, CONVERT(TEXT, N'灵武市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2111, 2103, CONVERT(TEXT, N'固原市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2112, 2111, CONVERT(TEXT, N'原州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2113, 2111, CONVERT(TEXT, N'西吉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2114, 2111, CONVERT(TEXT, N'隆德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2115, 2111, CONVERT(TEXT, N'泾源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2116, 2111, CONVERT(TEXT, N'彭阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2117, 2103, CONVERT(TEXT, N'石嘴山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2118, 2117, CONVERT(TEXT, N'大武口区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2119, 2117, CONVERT(TEXT, N'惠农区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2120, 2117, CONVERT(TEXT, N'平罗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2121, 2103, CONVERT(TEXT, N'吴忠市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2122, 2121, CONVERT(TEXT, N'利通区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2123, 2121, CONVERT(TEXT, N'盐池县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2124, 2121, CONVERT(TEXT, N'同心县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2125, 2121, CONVERT(TEXT, N'青铜峡市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2126, 2103, CONVERT(TEXT, N'中卫市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2127, 2126, CONVERT(TEXT, N'沙坡头区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2128, 2126, CONVERT(TEXT, N'中宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2129, 2126, CONVERT(TEXT, N'海原县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2130, 0, CONVERT(TEXT, N'青海'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2131, 2130, CONVERT(TEXT, N'西宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2132, 2131, CONVERT(TEXT, N'城东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2133, 2131, CONVERT(TEXT, N'城中区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2134, 2131, CONVERT(TEXT, N'城西区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2135, 2131, CONVERT(TEXT, N'城北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2136, 2131, CONVERT(TEXT, N'大通回族土族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2137, 2131, CONVERT(TEXT, N'湟中县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2138, 2131, CONVERT(TEXT, N'湟源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2139, 2130, CONVERT(TEXT, N'果洛藏族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2140, 2139, CONVERT(TEXT, N'玛沁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2141, 2139, CONVERT(TEXT, N'班玛县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2142, 2139, CONVERT(TEXT, N'甘德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2143, 2139, CONVERT(TEXT, N'达日县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2144, 2139, CONVERT(TEXT, N'久治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2145, 2139, CONVERT(TEXT, N'玛多县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2146, 2130, CONVERT(TEXT, N'海北藏族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2147, 2146, CONVERT(TEXT, N'门源回族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2148, 2146, CONVERT(TEXT, N'祁连县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2149, 2146, CONVERT(TEXT, N'海晏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2150, 2146, CONVERT(TEXT, N'刚察县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2151, 2130, CONVERT(TEXT, N'海东地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2152, 2151, CONVERT(TEXT, N'平安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2153, 2151, CONVERT(TEXT, N'民和回族土族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2154, 2151, CONVERT(TEXT, N'乐都县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2155, 2151, CONVERT(TEXT, N'互助土族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2156, 2151, CONVERT(TEXT, N'化隆回族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2157, 2151, CONVERT(TEXT, N'循化撒拉族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2158, 2130, CONVERT(TEXT, N'海南藏族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2159, 2158, CONVERT(TEXT, N'共和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2160, 2158, CONVERT(TEXT, N'同德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2161, 2158, CONVERT(TEXT, N'贵德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2162, 2158, CONVERT(TEXT, N'兴海县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2163, 2158, CONVERT(TEXT, N'贵南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2164, 2130, CONVERT(TEXT, N'海西蒙古族藏族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2165, 2164, CONVERT(TEXT, N'格尔木市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2166, 2164, CONVERT(TEXT, N'德令哈市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2167, 2164, CONVERT(TEXT, N'乌兰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2168, 2164, CONVERT(TEXT, N'都兰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2169, 2164, CONVERT(TEXT, N'天峻县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2170, 2130, CONVERT(TEXT, N'黄南藏族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2171, 2170, CONVERT(TEXT, N'同仁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2172, 2170, CONVERT(TEXT, N'尖扎县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2173, 2170, CONVERT(TEXT, N'泽库县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2174, 2170, CONVERT(TEXT, N'河南蒙古族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2175, 2130, CONVERT(TEXT, N'玉树藏族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2176, 2175, CONVERT(TEXT, N'玉树县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2177, 2175, CONVERT(TEXT, N'杂多县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2178, 2175, CONVERT(TEXT, N'称多县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2179, 2175, CONVERT(TEXT, N'治多县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2180, 2175, CONVERT(TEXT, N'囊谦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2181, 2175, CONVERT(TEXT, N'曲麻莱县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2182, 0, CONVERT(TEXT, N'山东'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2183, 2182, CONVERT(TEXT, N'济南市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2184, 2183, CONVERT(TEXT, N'历下区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2185, 2183, CONVERT(TEXT, N'市中区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2186, 2183, CONVERT(TEXT, N'槐荫区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2187, 2183, CONVERT(TEXT, N'天桥区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2188, 2183, CONVERT(TEXT, N'历城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2189, 2183, CONVERT(TEXT, N'长清区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2190, 2183, CONVERT(TEXT, N'平阴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2191, 2183, CONVERT(TEXT, N'济阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2192, 2183, CONVERT(TEXT, N'商河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2193, 2183, CONVERT(TEXT, N'章丘市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2194, 2182, CONVERT(TEXT, N'滨州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2195, 2194, CONVERT(TEXT, N'滨城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2196, 2194, CONVERT(TEXT, N'惠民县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2197, 2194, CONVERT(TEXT, N'阳信县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2198, 2194, CONVERT(TEXT, N'无棣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2199, 2194, CONVERT(TEXT, N'沾化县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2200, 2194, CONVERT(TEXT, N'博兴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2201, 2194, CONVERT(TEXT, N'邹平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2202, 2182, CONVERT(TEXT, N'德州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2203, 2202, CONVERT(TEXT, N'德城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2204, 2202, CONVERT(TEXT, N'陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2205, 2202, CONVERT(TEXT, N'宁津县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2206, 2202, CONVERT(TEXT, N'庆云县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2207, 2202, CONVERT(TEXT, N'临邑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2208, 2202, CONVERT(TEXT, N'齐河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2209, 2202, CONVERT(TEXT, N'平原县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2210, 2202, CONVERT(TEXT, N'夏津县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2211, 2202, CONVERT(TEXT, N'武城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2212, 2202, CONVERT(TEXT, N'乐陵市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2213, 2202, CONVERT(TEXT, N'禹城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2214, 2182, CONVERT(TEXT, N'东营市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2215, 2214, CONVERT(TEXT, N'东营区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2216, 2214, CONVERT(TEXT, N'河口区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2217, 2214, CONVERT(TEXT, N'垦利县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2218, 2214, CONVERT(TEXT, N'利津县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2219, 2214, CONVERT(TEXT, N'广饶县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2220, 2182, CONVERT(TEXT, N'菏泽市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2221, 2220, CONVERT(TEXT, N'牡丹区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2222, 2220, CONVERT(TEXT, N'曹县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2223, 2220, CONVERT(TEXT, N'单县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2224, 2220, CONVERT(TEXT, N'成武县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2225, 2220, CONVERT(TEXT, N'巨野县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2226, 2220, CONVERT(TEXT, N'郓城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2227, 2220, CONVERT(TEXT, N'鄄城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2228, 2220, CONVERT(TEXT, N'定陶县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2229, 2220, CONVERT(TEXT, N'东明县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2230, 2182, CONVERT(TEXT, N'济宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2231, 2230, CONVERT(TEXT, N'市中区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2232, 2230, CONVERT(TEXT, N'任城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2233, 2230, CONVERT(TEXT, N'微山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2234, 2230, CONVERT(TEXT, N'鱼台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2235, 2230, CONVERT(TEXT, N'金乡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2236, 2230, CONVERT(TEXT, N'嘉祥县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2237, 2230, CONVERT(TEXT, N'汶上县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2238, 2230, CONVERT(TEXT, N'泗水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2239, 2230, CONVERT(TEXT, N'梁山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2240, 2230, CONVERT(TEXT, N'曲阜市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2241, 2230, CONVERT(TEXT, N'兖州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2242, 2230, CONVERT(TEXT, N'邹城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2243, 2182, CONVERT(TEXT, N'莱芜市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2244, 2243, CONVERT(TEXT, N'莱城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2245, 2243, CONVERT(TEXT, N'钢城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2246, 2182, CONVERT(TEXT, N'聊城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2247, 2246, CONVERT(TEXT, N'东昌府区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2248, 2246, CONVERT(TEXT, N'阳谷县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2249, 2246, CONVERT(TEXT, N'莘县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2250, 2246, CONVERT(TEXT, N'茌平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2251, 2246, CONVERT(TEXT, N'东阿县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2252, 2246, CONVERT(TEXT, N'冠县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2253, 2246, CONVERT(TEXT, N'高唐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2254, 2246, CONVERT(TEXT, N'临清市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2255, 2182, CONVERT(TEXT, N'临沂市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2256, 2255, CONVERT(TEXT, N'兰山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2257, 2255, CONVERT(TEXT, N'罗庄区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2258, 2255, CONVERT(TEXT, N'河东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2259, 2255, CONVERT(TEXT, N'沂南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2260, 2255, CONVERT(TEXT, N'郯城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2261, 2255, CONVERT(TEXT, N'沂水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2262, 2255, CONVERT(TEXT, N'苍山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2263, 2255, CONVERT(TEXT, N'费县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2264, 2255, CONVERT(TEXT, N'平邑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2265, 2255, CONVERT(TEXT, N'莒南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2266, 2255, CONVERT(TEXT, N'蒙阴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2267, 2255, CONVERT(TEXT, N'临沭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2268, 2182, CONVERT(TEXT, N'青岛市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2269, 2268, CONVERT(TEXT, N'市南区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2270, 2268, CONVERT(TEXT, N'市北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2271, 2268, CONVERT(TEXT, N'四方区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2272, 2268, CONVERT(TEXT, N'黄岛区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2273, 2268, CONVERT(TEXT, N'崂山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2274, 2268, CONVERT(TEXT, N'李沧区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2275, 2268, CONVERT(TEXT, N'城阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2276, 2268, CONVERT(TEXT, N'胶州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2277, 2268, CONVERT(TEXT, N'即墨市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2278, 2268, CONVERT(TEXT, N'平度市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2279, 2268, CONVERT(TEXT, N'胶南市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2280, 2268, CONVERT(TEXT, N'莱西市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2281, 2182, CONVERT(TEXT, N'日照市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2282, 2281, CONVERT(TEXT, N'东港区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2283, 2281, CONVERT(TEXT, N'岚山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2284, 2281, CONVERT(TEXT, N'五莲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2285, 2281, CONVERT(TEXT, N'莒县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2286, 2182, CONVERT(TEXT, N'泰安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2287, 2286, CONVERT(TEXT, N'泰山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2288, 2286, CONVERT(TEXT, N'岱岳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2289, 2286, CONVERT(TEXT, N'宁阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2290, 2286, CONVERT(TEXT, N'东平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2291, 2286, CONVERT(TEXT, N'新泰市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2292, 2286, CONVERT(TEXT, N'肥城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2293, 2182, CONVERT(TEXT, N'威海市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2294, 2293, CONVERT(TEXT, N'环翠区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2295, 2293, CONVERT(TEXT, N'文登市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2296, 2293, CONVERT(TEXT, N'荣成市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2297, 2293, CONVERT(TEXT, N'乳山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2298, 2182, CONVERT(TEXT, N'潍坊市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2299, 2298, CONVERT(TEXT, N'潍城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2300, 2298, CONVERT(TEXT, N'寒亭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2301, 2298, CONVERT(TEXT, N'坊子区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2302, 2298, CONVERT(TEXT, N'奎文区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2303, 2298, CONVERT(TEXT, N'临朐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2304, 2298, CONVERT(TEXT, N'昌乐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2305, 2298, CONVERT(TEXT, N'青州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2306, 2298, CONVERT(TEXT, N'诸城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2307, 2298, CONVERT(TEXT, N'寿光市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2308, 2298, CONVERT(TEXT, N'安丘市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2309, 2298, CONVERT(TEXT, N'高密市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2310, 2298, CONVERT(TEXT, N'昌邑市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2311, 2182, CONVERT(TEXT, N'烟台市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2312, 2311, CONVERT(TEXT, N'芝罘区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2313, 2311, CONVERT(TEXT, N'福山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2314, 2311, CONVERT(TEXT, N'牟平区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2315, 2311, CONVERT(TEXT, N'莱山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2316, 2311, CONVERT(TEXT, N'长岛县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2317, 2311, CONVERT(TEXT, N'龙口市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2318, 2311, CONVERT(TEXT, N'莱阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2319, 2311, CONVERT(TEXT, N'莱州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2320, 2311, CONVERT(TEXT, N'蓬莱市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2321, 2311, CONVERT(TEXT, N'招远市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2322, 2311, CONVERT(TEXT, N'栖霞市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2323, 2311, CONVERT(TEXT, N'海阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2324, 2182, CONVERT(TEXT, N'枣庄市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2325, 2324, CONVERT(TEXT, N'市中区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2326, 2324, CONVERT(TEXT, N'薛城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2327, 2324, CONVERT(TEXT, N'峄城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2328, 2324, CONVERT(TEXT, N'台儿庄区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2329, 2324, CONVERT(TEXT, N'山亭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2330, 2324, CONVERT(TEXT, N'滕州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2331, 2182, CONVERT(TEXT, N'淄博市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2332, 2331, CONVERT(TEXT, N'淄川区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2333, 2331, CONVERT(TEXT, N'张店区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2334, 2331, CONVERT(TEXT, N'博山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2335, 2331, CONVERT(TEXT, N'临淄区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2336, 2331, CONVERT(TEXT, N'周村区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2337, 2331, CONVERT(TEXT, N'桓台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2338, 2331, CONVERT(TEXT, N'高青县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2339, 2331, CONVERT(TEXT, N'沂源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2340, 0, CONVERT(TEXT, N'山西'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2341, 2340, CONVERT(TEXT, N'太原市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2342, 2341, CONVERT(TEXT, N'小店区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2343, 2341, CONVERT(TEXT, N'迎泽区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2344, 2341, CONVERT(TEXT, N'杏花岭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2345, 2341, CONVERT(TEXT, N'尖草坪区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2346, 2341, CONVERT(TEXT, N'万柏林区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2347, 2341, CONVERT(TEXT, N'晋源区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2348, 2341, CONVERT(TEXT, N'清徐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2349, 2341, CONVERT(TEXT, N'阳曲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2350, 2341, CONVERT(TEXT, N'娄烦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2351, 2341, CONVERT(TEXT, N'古交市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2352, 2340, CONVERT(TEXT, N'长治市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2353, 2352, CONVERT(TEXT, N'城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2354, 2352, CONVERT(TEXT, N'郊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2355, 2352, CONVERT(TEXT, N'长治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2356, 2352, CONVERT(TEXT, N'襄垣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2357, 2352, CONVERT(TEXT, N'屯留县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2358, 2352, CONVERT(TEXT, N'平顺县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2359, 2352, CONVERT(TEXT, N'黎城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2360, 2352, CONVERT(TEXT, N'壶关县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2361, 2352, CONVERT(TEXT, N'长子县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2362, 2352, CONVERT(TEXT, N'武乡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2363, 2352, CONVERT(TEXT, N'沁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2364, 2352, CONVERT(TEXT, N'沁源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2365, 2352, CONVERT(TEXT, N'潞城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2366, 2340, CONVERT(TEXT, N'大同市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2367, 2366, CONVERT(TEXT, N'城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2368, 2366, CONVERT(TEXT, N'矿区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2369, 2366, CONVERT(TEXT, N'南郊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2370, 2366, CONVERT(TEXT, N'新荣区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2371, 2366, CONVERT(TEXT, N'阳高县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2372, 2366, CONVERT(TEXT, N'天镇县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2373, 2366, CONVERT(TEXT, N'广灵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2374, 2366, CONVERT(TEXT, N'灵丘县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2375, 2366, CONVERT(TEXT, N'浑源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2376, 2366, CONVERT(TEXT, N'左云县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2377, 2366, CONVERT(TEXT, N'大同县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2378, 2340, CONVERT(TEXT, N'晋城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2379, 2378, CONVERT(TEXT, N'城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2380, 2378, CONVERT(TEXT, N'沁水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2381, 2378, CONVERT(TEXT, N'阳城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2382, 2378, CONVERT(TEXT, N'陵川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2383, 2378, CONVERT(TEXT, N'泽州县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2384, 2378, CONVERT(TEXT, N'高平市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2385, 2340, CONVERT(TEXT, N'晋中市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2386, 2385, CONVERT(TEXT, N'榆次区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2387, 2385, CONVERT(TEXT, N'榆社县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2388, 2385, CONVERT(TEXT, N'左权县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2389, 2385, CONVERT(TEXT, N'和顺县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2390, 2385, CONVERT(TEXT, N'昔阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2391, 2385, CONVERT(TEXT, N'寿阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2392, 2385, CONVERT(TEXT, N'太谷县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2393, 2385, CONVERT(TEXT, N'祁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2394, 2385, CONVERT(TEXT, N'平遥县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2395, 2385, CONVERT(TEXT, N'灵石县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2396, 2385, CONVERT(TEXT, N'介休市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2397, 2340, CONVERT(TEXT, N'临汾市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2398, 2397, CONVERT(TEXT, N'尧都区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2399, 2397, CONVERT(TEXT, N'曲沃县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2400, 2397, CONVERT(TEXT, N'翼城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2401, 2397, CONVERT(TEXT, N'襄汾县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2402, 2397, CONVERT(TEXT, N'洪洞县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2403, 2397, CONVERT(TEXT, N'古县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2404, 2397, CONVERT(TEXT, N'安泽县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2405, 2397, CONVERT(TEXT, N'浮山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2406, 2397, CONVERT(TEXT, N'吉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2407, 2397, CONVERT(TEXT, N'乡宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2408, 2397, CONVERT(TEXT, N'大宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2409, 2397, CONVERT(TEXT, N'隰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2410, 2397, CONVERT(TEXT, N'永和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2411, 2397, CONVERT(TEXT, N'蒲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2412, 2397, CONVERT(TEXT, N'汾西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2413, 2397, CONVERT(TEXT, N'侯马市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2414, 2397, CONVERT(TEXT, N'霍州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2415, 2340, CONVERT(TEXT, N'吕梁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2416, 2415, CONVERT(TEXT, N'离石区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2417, 2415, CONVERT(TEXT, N'文水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2418, 2415, CONVERT(TEXT, N'交城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2419, 2415, CONVERT(TEXT, N'兴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2420, 2415, CONVERT(TEXT, N'临县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2421, 2415, CONVERT(TEXT, N'柳林县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2422, 2415, CONVERT(TEXT, N'石楼县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2423, 2415, CONVERT(TEXT, N'岚县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2424, 2415, CONVERT(TEXT, N'方山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2425, 2415, CONVERT(TEXT, N'中阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2426, 2415, CONVERT(TEXT, N'交口县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2427, 2415, CONVERT(TEXT, N'孝义市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2428, 2415, CONVERT(TEXT, N'汾阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2429, 2340, CONVERT(TEXT, N'朔州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2430, 2429, CONVERT(TEXT, N'朔城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2431, 2429, CONVERT(TEXT, N'平鲁区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2432, 2429, CONVERT(TEXT, N'山阴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2433, 2429, CONVERT(TEXT, N'应县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2434, 2429, CONVERT(TEXT, N'右玉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2435, 2429, CONVERT(TEXT, N'怀仁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2436, 2340, CONVERT(TEXT, N'忻州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2437, 2436, CONVERT(TEXT, N'忻府区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2438, 2436, CONVERT(TEXT, N'定襄县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2439, 2436, CONVERT(TEXT, N'五台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2440, 2436, CONVERT(TEXT, N'代县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2441, 2436, CONVERT(TEXT, N'繁峙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2442, 2436, CONVERT(TEXT, N'宁武县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2443, 2436, CONVERT(TEXT, N'静乐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2444, 2436, CONVERT(TEXT, N'神池县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2445, 2436, CONVERT(TEXT, N'五寨县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2446, 2436, CONVERT(TEXT, N'岢岚县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2447, 2436, CONVERT(TEXT, N'河曲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2448, 2436, CONVERT(TEXT, N'保德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2449, 2436, CONVERT(TEXT, N'偏关县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2450, 2436, CONVERT(TEXT, N'原平市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2451, 2340, CONVERT(TEXT, N'阳泉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2452, 2451, CONVERT(TEXT, N'城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2453, 2451, CONVERT(TEXT, N'矿区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2454, 2451, CONVERT(TEXT, N'郊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2455, 2451, CONVERT(TEXT, N'平定县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2456, 2451, CONVERT(TEXT, N'盂县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2457, 2340, CONVERT(TEXT, N'运城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2458, 2457, CONVERT(TEXT, N'盐湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2459, 2457, CONVERT(TEXT, N'临猗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2460, 2457, CONVERT(TEXT, N'万荣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2461, 2457, CONVERT(TEXT, N'闻喜县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2462, 2457, CONVERT(TEXT, N'稷山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2463, 2457, CONVERT(TEXT, N'新绛县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2464, 2457, CONVERT(TEXT, N'绛县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2465, 2457, CONVERT(TEXT, N'垣曲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2466, 2457, CONVERT(TEXT, N'夏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2467, 2457, CONVERT(TEXT, N'平陆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2468, 2457, CONVERT(TEXT, N'芮城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2469, 2457, CONVERT(TEXT, N'永济市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2470, 2457, CONVERT(TEXT, N'河津市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2471, 0, CONVERT(TEXT, N'陕西'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2472, 2471, CONVERT(TEXT, N'西安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2473, 2472, CONVERT(TEXT, N'新城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2474, 2472, CONVERT(TEXT, N'碑林区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2475, 2472, CONVERT(TEXT, N'莲湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2476, 2472, CONVERT(TEXT, N'灞桥区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2477, 2472, CONVERT(TEXT, N'未央区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2478, 2472, CONVERT(TEXT, N'雁塔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2479, 2472, CONVERT(TEXT, N'阎良区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2480, 2472, CONVERT(TEXT, N'临潼区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2481, 2472, CONVERT(TEXT, N'长安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2482, 2472, CONVERT(TEXT, N'蓝田县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2483, 2472, CONVERT(TEXT, N'周至县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2484, 2472, CONVERT(TEXT, N'户县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2485, 2472, CONVERT(TEXT, N'高陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2486, 2471, CONVERT(TEXT, N'安康市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2487, 2486, CONVERT(TEXT, N'汉滨区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2488, 2486, CONVERT(TEXT, N'汉阴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2489, 2486, CONVERT(TEXT, N'石泉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2490, 2486, CONVERT(TEXT, N'宁陕县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2491, 2486, CONVERT(TEXT, N'紫阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2492, 2486, CONVERT(TEXT, N'岚皋县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2493, 2486, CONVERT(TEXT, N'平利县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2494, 2486, CONVERT(TEXT, N'镇坪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2495, 2486, CONVERT(TEXT, N'旬阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2496, 2486, CONVERT(TEXT, N'白河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2497, 2471, CONVERT(TEXT, N'宝鸡市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2498, 2497, CONVERT(TEXT, N'渭滨区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2499, 2497, CONVERT(TEXT, N'金台区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2500, 2497, CONVERT(TEXT, N'陈仓区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2501, 2497, CONVERT(TEXT, N'凤翔县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2502, 2497, CONVERT(TEXT, N'岐山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2503, 2497, CONVERT(TEXT, N'扶风县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2504, 2497, CONVERT(TEXT, N'眉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2505, 2497, CONVERT(TEXT, N'陇县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2506, 2497, CONVERT(TEXT, N'千阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2507, 2497, CONVERT(TEXT, N'麟游县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2508, 2497, CONVERT(TEXT, N'凤县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2509, 2497, CONVERT(TEXT, N'太白县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2510, 2471, CONVERT(TEXT, N'汉中市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2511, 2510, CONVERT(TEXT, N'汉台区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2512, 2510, CONVERT(TEXT, N'南郑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2513, 2510, CONVERT(TEXT, N'城固县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2514, 2510, CONVERT(TEXT, N'洋县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2515, 2510, CONVERT(TEXT, N'西乡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2516, 2510, CONVERT(TEXT, N'勉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2517, 2510, CONVERT(TEXT, N'宁强县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2518, 2510, CONVERT(TEXT, N'略阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2519, 2510, CONVERT(TEXT, N'镇巴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2520, 2510, CONVERT(TEXT, N'留坝县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2521, 2510, CONVERT(TEXT, N'佛坪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2522, 2471, CONVERT(TEXT, N'商洛市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2523, 2522, CONVERT(TEXT, N'商州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2524, 2522, CONVERT(TEXT, N'洛南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2525, 2522, CONVERT(TEXT, N'丹凤县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2526, 2522, CONVERT(TEXT, N'商南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2527, 2522, CONVERT(TEXT, N'山阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2528, 2522, CONVERT(TEXT, N'镇安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2529, 2522, CONVERT(TEXT, N'柞水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2530, 2471, CONVERT(TEXT, N'铜川市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2531, 2530, CONVERT(TEXT, N'王益区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2532, 2530, CONVERT(TEXT, N'印台区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2533, 2530, CONVERT(TEXT, N'耀州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2534, 2530, CONVERT(TEXT, N'宜君县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2535, 2471, CONVERT(TEXT, N'渭南市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2536, 2535, CONVERT(TEXT, N'临渭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2537, 2535, CONVERT(TEXT, N'华县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2538, 2535, CONVERT(TEXT, N'潼关县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2539, 2535, CONVERT(TEXT, N'大荔县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2540, 2535, CONVERT(TEXT, N'合阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2541, 2535, CONVERT(TEXT, N'澄城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2542, 2535, CONVERT(TEXT, N'蒲城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2543, 2535, CONVERT(TEXT, N'白水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2544, 2535, CONVERT(TEXT, N'富平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2545, 2535, CONVERT(TEXT, N'韩城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2546, 2535, CONVERT(TEXT, N'华阴市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2547, 2471, CONVERT(TEXT, N'咸阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2548, 2547, CONVERT(TEXT, N'秦都区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2549, 2547, CONVERT(TEXT, N'杨凌区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2550, 2547, CONVERT(TEXT, N'渭城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2551, 2547, CONVERT(TEXT, N'三原县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2552, 2547, CONVERT(TEXT, N'泾阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2553, 2547, CONVERT(TEXT, N'乾县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2554, 2547, CONVERT(TEXT, N'礼泉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2555, 2547, CONVERT(TEXT, N'永寿县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2556, 2547, CONVERT(TEXT, N'彬县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2557, 2547, CONVERT(TEXT, N'长武县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2558, 2547, CONVERT(TEXT, N'旬邑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2559, 2547, CONVERT(TEXT, N'淳化县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2560, 2547, CONVERT(TEXT, N'武功县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2561, 2547, CONVERT(TEXT, N'兴平市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2562, 2471, CONVERT(TEXT, N'延安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2563, 2562, CONVERT(TEXT, N'宝塔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2564, 2562, CONVERT(TEXT, N'延长县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2565, 2562, CONVERT(TEXT, N'延川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2566, 2562, CONVERT(TEXT, N'子长县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2567, 2562, CONVERT(TEXT, N'安塞县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2568, 2562, CONVERT(TEXT, N'志丹县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2569, 2562, CONVERT(TEXT, N'吴旗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2570, 2562, CONVERT(TEXT, N'甘泉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2571, 2562, CONVERT(TEXT, N'富县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2572, 2562, CONVERT(TEXT, N'洛川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2573, 2562, CONVERT(TEXT, N'宜川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2574, 2562, CONVERT(TEXT, N'黄龙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2575, 2562, CONVERT(TEXT, N'黄陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2576, 2471, CONVERT(TEXT, N'榆林市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2577, 2576, CONVERT(TEXT, N'榆阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2578, 2576, CONVERT(TEXT, N'神木县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2579, 2576, CONVERT(TEXT, N'府谷县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2580, 2576, CONVERT(TEXT, N'横山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2581, 2576, CONVERT(TEXT, N'靖边县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2582, 2576, CONVERT(TEXT, N'定边县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2583, 2576, CONVERT(TEXT, N'绥德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2584, 2576, CONVERT(TEXT, N'米脂县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2585, 2576, CONVERT(TEXT, N'佳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2586, 2576, CONVERT(TEXT, N'吴堡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2587, 2576, CONVERT(TEXT, N'清涧县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2588, 2576, CONVERT(TEXT, N'子洲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2589, 0, CONVERT(TEXT, N'四川'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2590, 2589, CONVERT(TEXT, N'成都市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2591, 2590, CONVERT(TEXT, N'锦江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2592, 2590, CONVERT(TEXT, N'青羊区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2593, 2590, CONVERT(TEXT, N'金牛区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2594, 2590, CONVERT(TEXT, N'武侯区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2595, 2590, CONVERT(TEXT, N'成华区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2596, 2590, CONVERT(TEXT, N'龙泉驿区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2597, 2590, CONVERT(TEXT, N'青白江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2598, 2590, CONVERT(TEXT, N'新都区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2599, 2590, CONVERT(TEXT, N'温江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2600, 2590, CONVERT(TEXT, N'金堂县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2601, 2590, CONVERT(TEXT, N'双流县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2602, 2590, CONVERT(TEXT, N'郫县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2603, 2590, CONVERT(TEXT, N'大邑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2604, 2590, CONVERT(TEXT, N'蒲江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2605, 2590, CONVERT(TEXT, N'新津县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2606, 2590, CONVERT(TEXT, N'都江堰市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2607, 2590, CONVERT(TEXT, N'彭州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2608, 2590, CONVERT(TEXT, N'邛崃市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2609, 2590, CONVERT(TEXT, N'崇州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2610, 2589, CONVERT(TEXT, N'阿坝藏族羌族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2611, 2610, CONVERT(TEXT, N'汶川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2612, 2610, CONVERT(TEXT, N'理县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2613, 2610, CONVERT(TEXT, N'茂县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2614, 2610, CONVERT(TEXT, N'松潘县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2615, 2610, CONVERT(TEXT, N'九寨沟县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2616, 2610, CONVERT(TEXT, N'金川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2617, 2610, CONVERT(TEXT, N'小金县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2618, 2610, CONVERT(TEXT, N'黑水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2619, 2610, CONVERT(TEXT, N'马尔康县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2620, 2610, CONVERT(TEXT, N'壤塘县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2621, 2610, CONVERT(TEXT, N'阿坝县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2622, 2610, CONVERT(TEXT, N'若尔盖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2623, 2610, CONVERT(TEXT, N'红原县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2624, 2589, CONVERT(TEXT, N'巴中市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2625, 2624, CONVERT(TEXT, N'巴州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2626, 2624, CONVERT(TEXT, N'通江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2627, 2624, CONVERT(TEXT, N'南江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2628, 2624, CONVERT(TEXT, N'平昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2629, 2589, CONVERT(TEXT, N'达州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2630, 2629, CONVERT(TEXT, N'通川区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2631, 2629, CONVERT(TEXT, N'达县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2632, 2629, CONVERT(TEXT, N'宣汉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2633, 2629, CONVERT(TEXT, N'开江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2634, 2629, CONVERT(TEXT, N'大竹县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2635, 2629, CONVERT(TEXT, N'渠县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2636, 2629, CONVERT(TEXT, N'万源市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2637, 2589, CONVERT(TEXT, N'德阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2638, 2637, CONVERT(TEXT, N'旌阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2639, 2637, CONVERT(TEXT, N'中江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2640, 2637, CONVERT(TEXT, N'罗江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2641, 2637, CONVERT(TEXT, N'广汉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2642, 2637, CONVERT(TEXT, N'什邡市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2643, 2637, CONVERT(TEXT, N'绵竹市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2644, 2589, CONVERT(TEXT, N'甘孜藏族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2645, 2644, CONVERT(TEXT, N'康定县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2646, 2644, CONVERT(TEXT, N'泸定县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2647, 2644, CONVERT(TEXT, N'丹巴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2648, 2644, CONVERT(TEXT, N'九龙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2649, 2644, CONVERT(TEXT, N'雅江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2650, 2644, CONVERT(TEXT, N'道孚县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2651, 2644, CONVERT(TEXT, N'炉霍县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2652, 2644, CONVERT(TEXT, N'甘孜县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2653, 2644, CONVERT(TEXT, N'新龙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2654, 2644, CONVERT(TEXT, N'德格县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2655, 2644, CONVERT(TEXT, N'白玉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2656, 2644, CONVERT(TEXT, N'石渠县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2657, 2644, CONVERT(TEXT, N'色达县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2658, 2644, CONVERT(TEXT, N'理塘县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2659, 2644, CONVERT(TEXT, N'巴塘县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2660, 2644, CONVERT(TEXT, N'乡城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2661, 2644, CONVERT(TEXT, N'稻城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2662, 2644, CONVERT(TEXT, N'得荣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2663, 2589, CONVERT(TEXT, N'广安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2664, 2663, CONVERT(TEXT, N'广安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2665, 2663, CONVERT(TEXT, N'岳池县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2666, 2663, CONVERT(TEXT, N'武胜县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2667, 2663, CONVERT(TEXT, N'邻水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2668, 2663, CONVERT(TEXT, N'华莹市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2669, 2589, CONVERT(TEXT, N'广元市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2670, 2669, CONVERT(TEXT, N'市中区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2671, 2669, CONVERT(TEXT, N'元坝区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2672, 2669, CONVERT(TEXT, N'朝天区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2673, 2669, CONVERT(TEXT, N'旺苍县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2674, 2669, CONVERT(TEXT, N'青川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2675, 2669, CONVERT(TEXT, N'剑阁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2676, 2669, CONVERT(TEXT, N'苍溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2677, 2589, CONVERT(TEXT, N'乐山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2678, 2677, CONVERT(TEXT, N'市中区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2679, 2677, CONVERT(TEXT, N'沙湾区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2680, 2677, CONVERT(TEXT, N'五通桥区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2681, 2677, CONVERT(TEXT, N'金口河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2682, 2677, CONVERT(TEXT, N'犍为县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2683, 2677, CONVERT(TEXT, N'井研县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2684, 2677, CONVERT(TEXT, N'夹江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2685, 2677, CONVERT(TEXT, N'沐川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2686, 2677, CONVERT(TEXT, N'峨边彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2687, 2677, CONVERT(TEXT, N'马边彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2688, 2677, CONVERT(TEXT, N'峨眉山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2689, 2589, CONVERT(TEXT, N'凉山彝族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2690, 2689, CONVERT(TEXT, N'西昌市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2691, 2689, CONVERT(TEXT, N'木里藏族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2692, 2689, CONVERT(TEXT, N'盐源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2693, 2689, CONVERT(TEXT, N'德昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2694, 2689, CONVERT(TEXT, N'会理县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2695, 2689, CONVERT(TEXT, N'会东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2696, 2689, CONVERT(TEXT, N'宁南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2697, 2689, CONVERT(TEXT, N'普格县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2698, 2689, CONVERT(TEXT, N'布拖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2699, 2689, CONVERT(TEXT, N'金阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2700, 2689, CONVERT(TEXT, N'昭觉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2701, 2689, CONVERT(TEXT, N'喜德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2702, 2689, CONVERT(TEXT, N'冕宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2703, 2689, CONVERT(TEXT, N'越西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2704, 2689, CONVERT(TEXT, N'甘洛县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2705, 2689, CONVERT(TEXT, N'美姑县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2706, 2689, CONVERT(TEXT, N'雷波县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2707, 2589, CONVERT(TEXT, N'泸州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2708, 2707, CONVERT(TEXT, N'江阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2709, 2707, CONVERT(TEXT, N'纳溪区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2710, 2707, CONVERT(TEXT, N'龙马潭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2711, 2707, CONVERT(TEXT, N'泸县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2712, 2707, CONVERT(TEXT, N'合江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2713, 2707, CONVERT(TEXT, N'叙永县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2714, 2707, CONVERT(TEXT, N'古蔺县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2715, 2589, CONVERT(TEXT, N'眉山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2716, 2715, CONVERT(TEXT, N'东坡区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2717, 2715, CONVERT(TEXT, N'仁寿县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2718, 2715, CONVERT(TEXT, N'彭山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2719, 2715, CONVERT(TEXT, N'洪雅县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2720, 2715, CONVERT(TEXT, N'丹棱县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2721, 2715, CONVERT(TEXT, N'青神县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2722, 2589, CONVERT(TEXT, N'绵阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2723, 2722, CONVERT(TEXT, N'涪城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2724, 2722, CONVERT(TEXT, N'游仙区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2725, 2722, CONVERT(TEXT, N'三台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2726, 2722, CONVERT(TEXT, N'盐亭县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2727, 2722, CONVERT(TEXT, N'安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2728, 2722, CONVERT(TEXT, N'梓潼县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2729, 2722, CONVERT(TEXT, N'北川羌族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2730, 2722, CONVERT(TEXT, N'平武县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2731, 2722, CONVERT(TEXT, N'江油市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2732, 2589, CONVERT(TEXT, N'内江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2733, 2732, CONVERT(TEXT, N'市中区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2734, 2732, CONVERT(TEXT, N'东兴区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2735, 2732, CONVERT(TEXT, N'威远县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2736, 2732, CONVERT(TEXT, N'资中县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2737, 2732, CONVERT(TEXT, N'隆昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2738, 2589, CONVERT(TEXT, N'南充市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2739, 2738, CONVERT(TEXT, N'顺庆区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2740, 2738, CONVERT(TEXT, N'高坪区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2741, 2738, CONVERT(TEXT, N'嘉陵区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2742, 2738, CONVERT(TEXT, N'南部县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2743, 2738, CONVERT(TEXT, N'营山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2744, 2738, CONVERT(TEXT, N'蓬安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2745, 2738, CONVERT(TEXT, N'仪陇县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2746, 2738, CONVERT(TEXT, N'西充县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2747, 2738, CONVERT(TEXT, N'阆中市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2748, 2589, CONVERT(TEXT, N'攀枝花市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2749, 2748, CONVERT(TEXT, N'东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2750, 2748, CONVERT(TEXT, N'西区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2751, 2748, CONVERT(TEXT, N'仁和区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2752, 2748, CONVERT(TEXT, N'米易县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2753, 2748, CONVERT(TEXT, N'盐边县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2754, 2589, CONVERT(TEXT, N'遂宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2755, 2754, CONVERT(TEXT, N'船山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2756, 2754, CONVERT(TEXT, N'安居区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2757, 2754, CONVERT(TEXT, N'蓬溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2758, 2754, CONVERT(TEXT, N'射洪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2759, 2754, CONVERT(TEXT, N'大英县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2760, 2589, CONVERT(TEXT, N'雅安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2761, 2760, CONVERT(TEXT, N'雨城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2762, 2760, CONVERT(TEXT, N'名山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2763, 2760, CONVERT(TEXT, N'荥经县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2764, 2760, CONVERT(TEXT, N'汉源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2765, 2760, CONVERT(TEXT, N'石棉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2766, 2760, CONVERT(TEXT, N'天全县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2767, 2760, CONVERT(TEXT, N'芦山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2768, 2760, CONVERT(TEXT, N'宝兴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2769, 2589, CONVERT(TEXT, N'宜宾市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2770, 2769, CONVERT(TEXT, N'翠屏区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2771, 2769, CONVERT(TEXT, N'宜宾县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2772, 2769, CONVERT(TEXT, N'南溪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2773, 2769, CONVERT(TEXT, N'江安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2774, 2769, CONVERT(TEXT, N'长宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2775, 2769, CONVERT(TEXT, N'高县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2776, 2769, CONVERT(TEXT, N'珙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2777, 2769, CONVERT(TEXT, N'筠连县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2778, 2769, CONVERT(TEXT, N'兴文县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2779, 2769, CONVERT(TEXT, N'屏山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2780, 2589, CONVERT(TEXT, N'资阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2781, 2780, CONVERT(TEXT, N'雁江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2782, 2780, CONVERT(TEXT, N'安岳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2783, 2780, CONVERT(TEXT, N'乐至县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2784, 2780, CONVERT(TEXT, N'简阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2785, 2589, CONVERT(TEXT, N'自贡市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2786, 2785, CONVERT(TEXT, N'自流井区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2787, 2785, CONVERT(TEXT, N'贡井区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2788, 2785, CONVERT(TEXT, N'大安区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2789, 2785, CONVERT(TEXT, N'沿滩区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2790, 2785, CONVERT(TEXT, N'荣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2791, 2785, CONVERT(TEXT, N'富顺县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2792, 0, CONVERT(TEXT, N'西藏'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2793, 2792, CONVERT(TEXT, N'拉萨市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2794, 2793, CONVERT(TEXT, N'城关区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2795, 2793, CONVERT(TEXT, N'林周县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2796, 2793, CONVERT(TEXT, N'当雄县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2797, 2793, CONVERT(TEXT, N'尼木县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2798, 2793, CONVERT(TEXT, N'曲水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2799, 2793, CONVERT(TEXT, N'堆龙德庆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2800, 2793, CONVERT(TEXT, N'达孜县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2801, 2793, CONVERT(TEXT, N'墨竹工卡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2802, 2792, CONVERT(TEXT, N'阿里地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2803, 2802, CONVERT(TEXT, N'普兰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2804, 2802, CONVERT(TEXT, N'札达县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2805, 2802, CONVERT(TEXT, N'噶尔县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2806, 2802, CONVERT(TEXT, N'日土县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2807, 2802, CONVERT(TEXT, N'革吉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2808, 2802, CONVERT(TEXT, N'改则县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2809, 2802, CONVERT(TEXT, N'措勤县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2810, 2792, CONVERT(TEXT, N'昌都地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2811, 2810, CONVERT(TEXT, N'昌都县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2812, 2810, CONVERT(TEXT, N'江达县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2813, 2810, CONVERT(TEXT, N'贡觉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2814, 2810, CONVERT(TEXT, N'类乌齐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2815, 2810, CONVERT(TEXT, N'丁青县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2816, 2810, CONVERT(TEXT, N'察雅县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2817, 2810, CONVERT(TEXT, N'八宿县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2818, 2810, CONVERT(TEXT, N'左贡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2819, 2810, CONVERT(TEXT, N'芒康县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2820, 2810, CONVERT(TEXT, N'洛隆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2821, 2810, CONVERT(TEXT, N'边坝县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2822, 2792, CONVERT(TEXT, N'林芝地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2823, 2822, CONVERT(TEXT, N'林芝县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2824, 2822, CONVERT(TEXT, N'工布江达县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2825, 2822, CONVERT(TEXT, N'米林县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2826, 2822, CONVERT(TEXT, N'墨脱县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2827, 2822, CONVERT(TEXT, N'波密县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2828, 2822, CONVERT(TEXT, N'察隅县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2829, 2822, CONVERT(TEXT, N'朗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2830, 2792, CONVERT(TEXT, N'那曲地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2831, 2830, CONVERT(TEXT, N'那曲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2832, 2830, CONVERT(TEXT, N'嘉黎县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2833, 2830, CONVERT(TEXT, N'比如县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2834, 2830, CONVERT(TEXT, N'聂荣县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2835, 2830, CONVERT(TEXT, N'安多县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2836, 2830, CONVERT(TEXT, N'申扎县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2837, 2830, CONVERT(TEXT, N'索县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2838, 2830, CONVERT(TEXT, N'班戈县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2839, 2830, CONVERT(TEXT, N'巴青县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2840, 2830, CONVERT(TEXT, N'尼玛县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2841, 2792, CONVERT(TEXT, N'日喀则地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2842, 2841, CONVERT(TEXT, N'日喀则市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2843, 2841, CONVERT(TEXT, N'南木林县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2844, 2841, CONVERT(TEXT, N'江孜县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2845, 2841, CONVERT(TEXT, N'定日县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2846, 2841, CONVERT(TEXT, N'萨迦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2847, 2841, CONVERT(TEXT, N'拉孜县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2848, 2841, CONVERT(TEXT, N'昂仁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2849, 2841, CONVERT(TEXT, N'谢通门县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2850, 2841, CONVERT(TEXT, N'白朗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2851, 2841, CONVERT(TEXT, N'仁布县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2852, 2841, CONVERT(TEXT, N'康马县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2853, 2841, CONVERT(TEXT, N'定结县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2854, 2841, CONVERT(TEXT, N'仲巴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2855, 2841, CONVERT(TEXT, N'亚东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2856, 2841, CONVERT(TEXT, N'吉隆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2857, 2841, CONVERT(TEXT, N'聂拉木县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2858, 2841, CONVERT(TEXT, N'萨嘎县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2859, 2841, CONVERT(TEXT, N'岗巴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2860, 2792, CONVERT(TEXT, N'山南地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2861, 2860, CONVERT(TEXT, N'乃东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2862, 2860, CONVERT(TEXT, N'扎囊县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2863, 2860, CONVERT(TEXT, N'贡嘎县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2864, 2860, CONVERT(TEXT, N'桑日县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2865, 2860, CONVERT(TEXT, N'琼结县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2866, 2860, CONVERT(TEXT, N'曲松县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2867, 2860, CONVERT(TEXT, N'措美县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2868, 2860, CONVERT(TEXT, N'洛扎县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2869, 2860, CONVERT(TEXT, N'加查县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2870, 2860, CONVERT(TEXT, N'隆子县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2871, 2860, CONVERT(TEXT, N'错那县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2872, 2860, CONVERT(TEXT, N'浪卡子县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2873, 0, CONVERT(TEXT, N'新疆'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2874, 2873, CONVERT(TEXT, N'乌鲁木齐市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2875, 2874, CONVERT(TEXT, N'天山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2876, 2874, CONVERT(TEXT, N'沙依巴克区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2877, 2874, CONVERT(TEXT, N'新市区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2878, 2874, CONVERT(TEXT, N'水磨沟区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2879, 2874, CONVERT(TEXT, N'头屯河区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2880, 2874, CONVERT(TEXT, N'达坂城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2881, 2874, CONVERT(TEXT, N'东山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2882, 2874, CONVERT(TEXT, N'乌鲁木齐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2883, 2873, CONVERT(TEXT, N'阿克苏地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2884, 2883, CONVERT(TEXT, N'阿克苏市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2885, 2883, CONVERT(TEXT, N'温宿县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2886, 2883, CONVERT(TEXT, N'库车县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2887, 2883, CONVERT(TEXT, N'沙雅县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2888, 2883, CONVERT(TEXT, N'新和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2889, 2883, CONVERT(TEXT, N'拜城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2890, 2883, CONVERT(TEXT, N'乌什县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2891, 2883, CONVERT(TEXT, N'阿瓦提县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2892, 2883, CONVERT(TEXT, N'柯坪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2893, 2873, CONVERT(TEXT, N'阿拉尔市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2894, 2873, CONVERT(TEXT, N'阿勒泰地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2895, 2894, CONVERT(TEXT, N'阿勒泰市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2896, 2894, CONVERT(TEXT, N'布尔津县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2897, 2894, CONVERT(TEXT, N'富蕴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2898, 2894, CONVERT(TEXT, N'福海县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2899, 2894, CONVERT(TEXT, N'哈巴河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2900, 2894, CONVERT(TEXT, N'青河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2901, 2894, CONVERT(TEXT, N'吉木乃县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2902, 2873, CONVERT(TEXT, N'巴音郭楞蒙古自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2903, 2902, CONVERT(TEXT, N'库尔勒市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2904, 2902, CONVERT(TEXT, N'轮台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2905, 2902, CONVERT(TEXT, N'尉犁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2906, 2902, CONVERT(TEXT, N'若羌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2907, 2902, CONVERT(TEXT, N'且末县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2908, 2902, CONVERT(TEXT, N'焉耆回族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2909, 2902, CONVERT(TEXT, N'和静县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2910, 2902, CONVERT(TEXT, N'和硕县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2911, 2902, CONVERT(TEXT, N'博湖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2912, 2873, CONVERT(TEXT, N'博尔塔拉蒙古自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2913, 2912, CONVERT(TEXT, N'博乐市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2914, 2912, CONVERT(TEXT, N'精河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2915, 2912, CONVERT(TEXT, N'温泉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2916, 2873, CONVERT(TEXT, N'昌吉回族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2917, 2916, CONVERT(TEXT, N'昌吉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2918, 2916, CONVERT(TEXT, N'阜康市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2919, 2916, CONVERT(TEXT, N'米泉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2920, 2916, CONVERT(TEXT, N'呼图壁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2921, 2916, CONVERT(TEXT, N'玛纳斯县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2922, 2916, CONVERT(TEXT, N'奇台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2923, 2916, CONVERT(TEXT, N'吉木萨尔县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2924, 2916, CONVERT(TEXT, N'木垒哈萨克自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2925, 2873, CONVERT(TEXT, N'哈密地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2926, 2925, CONVERT(TEXT, N'哈密市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2927, 2925, CONVERT(TEXT, N'巴里坤哈萨克自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2928, 2925, CONVERT(TEXT, N'伊吾县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2929, 2873, CONVERT(TEXT, N'和田地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2930, 2929, CONVERT(TEXT, N'和田市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2931, 2929, CONVERT(TEXT, N'和田县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2932, 2929, CONVERT(TEXT, N'墨玉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2933, 2929, CONVERT(TEXT, N'皮山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2934, 2929, CONVERT(TEXT, N'洛浦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2935, 2929, CONVERT(TEXT, N'策勒县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2936, 2929, CONVERT(TEXT, N'于田县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2937, 2929, CONVERT(TEXT, N'民丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2938, 2873, CONVERT(TEXT, N'喀什地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2939, 2938, CONVERT(TEXT, N'喀什市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2940, 2938, CONVERT(TEXT, N'疏附县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2941, 2938, CONVERT(TEXT, N'疏勒县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2942, 2938, CONVERT(TEXT, N'英吉沙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2943, 2938, CONVERT(TEXT, N'泽普县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2944, 2938, CONVERT(TEXT, N'莎车县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2945, 2938, CONVERT(TEXT, N'叶城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2946, 2938, CONVERT(TEXT, N'麦盖提县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2947, 2938, CONVERT(TEXT, N'岳普湖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2948, 2938, CONVERT(TEXT, N'伽师县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2949, 2938, CONVERT(TEXT, N'巴楚县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2950, 2938, CONVERT(TEXT, N'塔什库尔干塔吉克自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2951, 2873, CONVERT(TEXT, N'克拉玛依市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2952, 2951, CONVERT(TEXT, N'独山子区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2953, 2951, CONVERT(TEXT, N'克拉玛依区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2954, 2951, CONVERT(TEXT, N'白碱滩区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2955, 2951, CONVERT(TEXT, N'乌尔禾区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2956, 2873, CONVERT(TEXT, N'克孜勒苏柯尔克孜自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2957, 2956, CONVERT(TEXT, N'阿图什市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2958, 2956, CONVERT(TEXT, N'阿克陶县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2959, 2956, CONVERT(TEXT, N'阿合奇县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2960, 2956, CONVERT(TEXT, N'乌恰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2961, 2873, CONVERT(TEXT, N'石河子市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2962, 2873, CONVERT(TEXT, N'塔城地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2963, 2962, CONVERT(TEXT, N'塔城市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2964, 2962, CONVERT(TEXT, N'乌苏市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2965, 2962, CONVERT(TEXT, N'额敏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2966, 2962, CONVERT(TEXT, N'沙湾县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2967, 2962, CONVERT(TEXT, N'托里县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2968, 2962, CONVERT(TEXT, N'裕民县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2969, 2962, CONVERT(TEXT, N'和布克赛尔蒙古自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2970, 2873, CONVERT(TEXT, N'图木舒克市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2971, 2873, CONVERT(TEXT, N'吐鲁番地区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2972, 2971, CONVERT(TEXT, N'吐鲁番市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2973, 2971, CONVERT(TEXT, N'鄯善县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2974, 2971, CONVERT(TEXT, N'托克逊县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2975, 2873, CONVERT(TEXT, N'五家渠市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2976, 2873, CONVERT(TEXT, N'伊犁哈萨克自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2977, 2976, CONVERT(TEXT, N'伊宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2978, 2976, CONVERT(TEXT, N'奎屯市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2979, 2976, CONVERT(TEXT, N'伊宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2980, 2976, CONVERT(TEXT, N'察布查尔锡伯自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2981, 2976, CONVERT(TEXT, N'霍城县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2982, 2976, CONVERT(TEXT, N'巩留县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2983, 2976, CONVERT(TEXT, N'新源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2984, 2976, CONVERT(TEXT, N'昭苏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2985, 2976, CONVERT(TEXT, N'特克斯县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2986, 2976, CONVERT(TEXT, N'尼勒克县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2987, 0, CONVERT(TEXT, N'云南'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2988, 2987, CONVERT(TEXT, N'昆明市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2989, 2988, CONVERT(TEXT, N'五华区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2990, 2988, CONVERT(TEXT, N'盘龙区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2991, 2988, CONVERT(TEXT, N'官渡区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2992, 2988, CONVERT(TEXT, N'西山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2993, 2988, CONVERT(TEXT, N'东川区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2994, 2988, CONVERT(TEXT, N'呈贡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2995, 2988, CONVERT(TEXT, N'晋宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2996, 2988, CONVERT(TEXT, N'富民县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2997, 2988, CONVERT(TEXT, N'宜良县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2998, 2988, CONVERT(TEXT, N'石林彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (2999, 2988, CONVERT(TEXT, N'嵩明县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3000, 2988, CONVERT(TEXT, N'禄劝彝族苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3001, 2988, CONVERT(TEXT, N'寻甸回族彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3002, 2988, CONVERT(TEXT, N'安宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3003, 2987, CONVERT(TEXT, N'保山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3004, 3003, CONVERT(TEXT, N'隆阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3005, 3003, CONVERT(TEXT, N'施甸县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3006, 3003, CONVERT(TEXT, N'腾冲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3007, 3003, CONVERT(TEXT, N'龙陵县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3008, 3003, CONVERT(TEXT, N'昌宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3009, 2987, CONVERT(TEXT, N'楚雄彝族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3010, 3009, CONVERT(TEXT, N'楚雄市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3011, 3009, CONVERT(TEXT, N'双柏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3012, 3009, CONVERT(TEXT, N'牟定县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3013, 3009, CONVERT(TEXT, N'南华县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3014, 3009, CONVERT(TEXT, N'姚安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3015, 3009, CONVERT(TEXT, N'大姚县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3016, 3009, CONVERT(TEXT, N'永仁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3017, 3009, CONVERT(TEXT, N'元谋县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3018, 3009, CONVERT(TEXT, N'武定县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3019, 3009, CONVERT(TEXT, N'禄丰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3020, 2987, CONVERT(TEXT, N'大理白族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3021, 3020, CONVERT(TEXT, N'大理市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3022, 3020, CONVERT(TEXT, N'漾濞彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3023, 3020, CONVERT(TEXT, N'祥云县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3024, 3020, CONVERT(TEXT, N'宾川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3025, 3020, CONVERT(TEXT, N'弥渡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3026, 3020, CONVERT(TEXT, N'南涧彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3027, 3020, CONVERT(TEXT, N'巍山彝族回族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3028, 3020, CONVERT(TEXT, N'永平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3029, 3020, CONVERT(TEXT, N'云龙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3030, 3020, CONVERT(TEXT, N'洱源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3031, 3020, CONVERT(TEXT, N'剑川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3032, 3020, CONVERT(TEXT, N'鹤庆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3033, 2987, CONVERT(TEXT, N'德宏傣族景颇族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3034, 3033, CONVERT(TEXT, N'瑞丽市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3035, 3033, CONVERT(TEXT, N'潞西市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3036, 3033, CONVERT(TEXT, N'梁河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3037, 3033, CONVERT(TEXT, N'盈江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3038, 3033, CONVERT(TEXT, N'陇川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3039, 2987, CONVERT(TEXT, N'迪庆藏族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3040, 3039, CONVERT(TEXT, N'香格里拉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3041, 3039, CONVERT(TEXT, N'德钦县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3042, 3039, CONVERT(TEXT, N'维西傈僳族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3043, 2987, CONVERT(TEXT, N'红河哈尼族彝族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3044, 3043, CONVERT(TEXT, N'个旧市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3045, 3043, CONVERT(TEXT, N'开远市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3046, 3043, CONVERT(TEXT, N'蒙自县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3047, 3043, CONVERT(TEXT, N'屏边苗族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3048, 3043, CONVERT(TEXT, N'建水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3049, 3043, CONVERT(TEXT, N'石屏县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3050, 3043, CONVERT(TEXT, N'弥勒县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3051, 3043, CONVERT(TEXT, N'泸西县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3052, 3043, CONVERT(TEXT, N'元阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3053, 3043, CONVERT(TEXT, N'红河县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3054, 3043, CONVERT(TEXT, N'金平苗族瑶族傣族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3055, 3043, CONVERT(TEXT, N'绿春县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3056, 3043, CONVERT(TEXT, N'河口瑶族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3057, 2987, CONVERT(TEXT, N'丽江市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3058, 3057, CONVERT(TEXT, N'古城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3059, 3057, CONVERT(TEXT, N'玉龙纳西族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3060, 3057, CONVERT(TEXT, N'永胜县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3061, 3057, CONVERT(TEXT, N'华坪县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3062, 3057, CONVERT(TEXT, N'宁蒗彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3063, 2987, CONVERT(TEXT, N'临沧市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3064, 3063, CONVERT(TEXT, N'临翔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3065, 3063, CONVERT(TEXT, N'凤庆县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3066, 3063, CONVERT(TEXT, N'云县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3067, 3063, CONVERT(TEXT, N'永德县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3068, 3063, CONVERT(TEXT, N'镇康县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3069, 3063, CONVERT(TEXT, N'双江拉祜族佤族布朗族傣族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3070, 3063, CONVERT(TEXT, N'耿马傣族佤族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3071, 3063, CONVERT(TEXT, N'沧源佤族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3072, 2987, CONVERT(TEXT, N'怒江傈僳族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3073, 3072, CONVERT(TEXT, N'泸水县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3074, 3072, CONVERT(TEXT, N'福贡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3075, 3072, CONVERT(TEXT, N'贡山独龙族怒族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3076, 3072, CONVERT(TEXT, N'兰坪白族普米族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3077, 2987, CONVERT(TEXT, N'曲靖市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3078, 3077, CONVERT(TEXT, N'麒麟区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3079, 3077, CONVERT(TEXT, N'马龙县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3080, 3077, CONVERT(TEXT, N'陆良县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3081, 3077, CONVERT(TEXT, N'师宗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3082, 3077, CONVERT(TEXT, N'罗平县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3083, 3077, CONVERT(TEXT, N'富源县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3084, 3077, CONVERT(TEXT, N'会泽县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3085, 3077, CONVERT(TEXT, N'沾益县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3086, 3077, CONVERT(TEXT, N'宣威市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3087, 2987, CONVERT(TEXT, N'思茅市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3088, 3087, CONVERT(TEXT, N'翠云区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3089, 3087, CONVERT(TEXT, N'普洱哈尼族彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3090, 3087, CONVERT(TEXT, N'墨江哈尼族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3091, 3087, CONVERT(TEXT, N'景东彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3092, 3087, CONVERT(TEXT, N'景谷傣族彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3093, 3087, CONVERT(TEXT, N'镇沅彝族哈尼族拉祜族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3094, 3087, CONVERT(TEXT, N'江城哈尼族彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3095, 3087, CONVERT(TEXT, N'孟连傣族拉祜族佤族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3096, 3087, CONVERT(TEXT, N'澜沧拉祜族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3097, 3087, CONVERT(TEXT, N'西盟佤族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3098, 2987, CONVERT(TEXT, N'文山壮族苗族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3099, 3098, CONVERT(TEXT, N'文山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3100, 3098, CONVERT(TEXT, N'砚山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3101, 3098, CONVERT(TEXT, N'西畴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3102, 3098, CONVERT(TEXT, N'麻栗坡县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3103, 3098, CONVERT(TEXT, N'马关县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3104, 3098, CONVERT(TEXT, N'丘北县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3105, 3098, CONVERT(TEXT, N'广南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3106, 3098, CONVERT(TEXT, N'富宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3107, 2987, CONVERT(TEXT, N'西双版纳傣族自治州'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3108, 3107, CONVERT(TEXT, N'景洪市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3109, 3107, CONVERT(TEXT, N'勐海县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3110, 3107, CONVERT(TEXT, N'勐腊县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3111, 2987, CONVERT(TEXT, N'玉溪市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3112, 3111, CONVERT(TEXT, N'红塔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3113, 3111, CONVERT(TEXT, N'江川县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3114, 3111, CONVERT(TEXT, N'澄江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3115, 3111, CONVERT(TEXT, N'通海县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3116, 3111, CONVERT(TEXT, N'华宁县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3117, 3111, CONVERT(TEXT, N'易门县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3118, 3111, CONVERT(TEXT, N'峨山彝族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3119, 3111, CONVERT(TEXT, N'新平彝族傣族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3120, 3111, CONVERT(TEXT, N'元江哈尼族彝族傣族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3121, 2987, CONVERT(TEXT, N'昭通市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3122, 3121, CONVERT(TEXT, N'昭阳区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3123, 3121, CONVERT(TEXT, N'鲁甸县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3124, 3121, CONVERT(TEXT, N'巧家县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3125, 3121, CONVERT(TEXT, N'盐津县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3126, 3121, CONVERT(TEXT, N'大关县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3127, 3121, CONVERT(TEXT, N'永善县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3128, 3121, CONVERT(TEXT, N'绥江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3129, 3121, CONVERT(TEXT, N'镇雄县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3130, 3121, CONVERT(TEXT, N'彝良县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3131, 3121, CONVERT(TEXT, N'威信县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3132, 3121, CONVERT(TEXT, N'水富县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3133, 0, CONVERT(TEXT, N'浙江'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3134, 3133, CONVERT(TEXT, N'杭州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3135, 3134, CONVERT(TEXT, N'上城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3136, 3134, CONVERT(TEXT, N'下城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3137, 3134, CONVERT(TEXT, N'江干区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3138, 3134, CONVERT(TEXT, N'拱墅区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3139, 3134, CONVERT(TEXT, N'西湖区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3140, 3134, CONVERT(TEXT, N'滨江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3141, 3134, CONVERT(TEXT, N'萧山区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3142, 3134, CONVERT(TEXT, N'余杭区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3143, 3134, CONVERT(TEXT, N'桐庐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3144, 3134, CONVERT(TEXT, N'淳安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3145, 3134, CONVERT(TEXT, N'建德市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3146, 3134, CONVERT(TEXT, N'富阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3147, 3134, CONVERT(TEXT, N'临安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3148, 3133, CONVERT(TEXT, N'湖州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3149, 3148, CONVERT(TEXT, N'吴兴区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3150, 3148, CONVERT(TEXT, N'南浔区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3151, 3148, CONVERT(TEXT, N'德清县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3152, 3148, CONVERT(TEXT, N'长兴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3153, 3148, CONVERT(TEXT, N'安吉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3154, 3133, CONVERT(TEXT, N'嘉兴市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3155, 3154, CONVERT(TEXT, N'秀城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3156, 3154, CONVERT(TEXT, N'秀洲区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3157, 3154, CONVERT(TEXT, N'嘉善县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3158, 3154, CONVERT(TEXT, N'海盐县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3159, 3154, CONVERT(TEXT, N'海宁市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3160, 3154, CONVERT(TEXT, N'平湖市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3161, 3154, CONVERT(TEXT, N'桐乡市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3162, 3133, CONVERT(TEXT, N'金华市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3163, 3162, CONVERT(TEXT, N'婺城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3164, 3162, CONVERT(TEXT, N'金东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3165, 3162, CONVERT(TEXT, N'武义县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3166, 3162, CONVERT(TEXT, N'浦江县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3167, 3162, CONVERT(TEXT, N'磐安县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3168, 3162, CONVERT(TEXT, N'兰溪市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3169, 3162, CONVERT(TEXT, N'义乌市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3170, 3162, CONVERT(TEXT, N'东阳市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3171, 3162, CONVERT(TEXT, N'永康市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3172, 3133, CONVERT(TEXT, N'丽水市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3173, 3172, CONVERT(TEXT, N'莲都区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3174, 3172, CONVERT(TEXT, N'青田县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3175, 3172, CONVERT(TEXT, N'缙云县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3176, 3172, CONVERT(TEXT, N'遂昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3177, 3172, CONVERT(TEXT, N'松阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3178, 3172, CONVERT(TEXT, N'云和县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3179, 3172, CONVERT(TEXT, N'庆元县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3180, 3172, CONVERT(TEXT, N'景宁畲族自治县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3181, 3172, CONVERT(TEXT, N'龙泉市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3182, 3133, CONVERT(TEXT, N'宁波市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3183, 3182, CONVERT(TEXT, N'海曙区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3184, 3182, CONVERT(TEXT, N'江东区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3185, 3182, CONVERT(TEXT, N'江北区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3186, 3182, CONVERT(TEXT, N'北仑区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3187, 3182, CONVERT(TEXT, N'镇海区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3188, 3182, CONVERT(TEXT, N'鄞州区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3189, 3182, CONVERT(TEXT, N'象山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3190, 3182, CONVERT(TEXT, N'宁海县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3191, 3182, CONVERT(TEXT, N'余姚市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3192, 3182, CONVERT(TEXT, N'慈溪市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3193, 3182, CONVERT(TEXT, N'奉化市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3194, 3133, CONVERT(TEXT, N'衢州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3195, 3194, CONVERT(TEXT, N'柯城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3196, 3194, CONVERT(TEXT, N'衢江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3197, 3194, CONVERT(TEXT, N'常山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3198, 3194, CONVERT(TEXT, N'开化县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3199, 3194, CONVERT(TEXT, N'龙游县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3200, 3194, CONVERT(TEXT, N'江山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3201, 3133, CONVERT(TEXT, N'绍兴市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3202, 3201, CONVERT(TEXT, N'越城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3203, 3201, CONVERT(TEXT, N'绍兴县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3204, 3201, CONVERT(TEXT, N'新昌县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3205, 3201, CONVERT(TEXT, N'诸暨市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3206, 3201, CONVERT(TEXT, N'上虞市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3207, 3201, CONVERT(TEXT, N'嵊州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3208, 3133, CONVERT(TEXT, N'台州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3209, 3208, CONVERT(TEXT, N'椒江区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3210, 3208, CONVERT(TEXT, N'黄岩区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3211, 3208, CONVERT(TEXT, N'路桥区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3212, 3208, CONVERT(TEXT, N'玉环县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3213, 3208, CONVERT(TEXT, N'三门县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3214, 3208, CONVERT(TEXT, N'天台县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3215, 3208, CONVERT(TEXT, N'仙居县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3216, 3208, CONVERT(TEXT, N'温岭市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3217, 3208, CONVERT(TEXT, N'临海市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3218, 3133, CONVERT(TEXT, N'温州市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3219, 3218, CONVERT(TEXT, N'鹿城区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3220, 3218, CONVERT(TEXT, N'龙湾区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3221, 3218, CONVERT(TEXT, N'瓯海区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3222, 3218, CONVERT(TEXT, N'洞头县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3223, 3218, CONVERT(TEXT, N'永嘉县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3224, 3218, CONVERT(TEXT, N'平阳县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3225, 3218, CONVERT(TEXT, N'苍南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3226, 3218, CONVERT(TEXT, N'文成县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3227, 3218, CONVERT(TEXT, N'泰顺县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3228, 3218, CONVERT(TEXT, N'瑞安市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3229, 3218, CONVERT(TEXT, N'乐清市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3230, 3133, CONVERT(TEXT, N'舟山市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3231, 3230, CONVERT(TEXT, N'定海区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3232, 3230, CONVERT(TEXT, N'普陀区'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3233, 3230, CONVERT(TEXT, N'岱山县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3234, 3230, CONVERT(TEXT, N'嵊泗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3235, 0, CONVERT(TEXT, N'香港'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3236, 3235, CONVERT(TEXT, N'九龙'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3237, 3235, CONVERT(TEXT, N'香港岛'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3238, 3235, CONVERT(TEXT, N'新界'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3239, 0, CONVERT(TEXT, N'澳门'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3240, 3239, CONVERT(TEXT, N'澳门半岛'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3241, 3239, CONVERT(TEXT, N'离岛'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3242, 0, CONVERT(TEXT, N'台湾'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3243, 3242, CONVERT(TEXT, N'台北市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3244, 3242, CONVERT(TEXT, N'高雄市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3245, 3242, CONVERT(TEXT, N'高雄县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3246, 3242, CONVERT(TEXT, N'花莲县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3247, 3242, CONVERT(TEXT, N'基隆市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3248, 3242, CONVERT(TEXT, N'嘉义市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3249, 3242, CONVERT(TEXT, N'嘉义县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3250, 3242, CONVERT(TEXT, N'金门县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3251, 3242, CONVERT(TEXT, N'苗栗县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3252, 3242, CONVERT(TEXT, N'南投县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3253, 3242, CONVERT(TEXT, N'澎湖县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3254, 3242, CONVERT(TEXT, N'屏东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3255, 3242, CONVERT(TEXT, N'台北县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3256, 3242, CONVERT(TEXT, N'台东县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3257, 3242, CONVERT(TEXT, N'台南市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3258, 3242, CONVERT(TEXT, N'台南县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3259, 3242, CONVERT(TEXT, N'台中市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3260, 3242, CONVERT(TEXT, N'台中县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3261, 3242, CONVERT(TEXT, N'桃园县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3262, 3242, CONVERT(TEXT, N'新竹市'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3263, 3242, CONVERT(TEXT, N'新竹县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3264, 3242, CONVERT(TEXT, N'宜兰县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3265, 3242, CONVERT(TEXT, N'云林县'))
;
INSERT [farecitys] ([id], [pid], [name]) VALUES (3266, 3242, CONVERT(TEXT, N'彰化县'))
;
SET IDENTITY_INSERT [farecitys] OFF
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'sp_GetListByPageAndFileds' AND type = 'P')
   DROP PROCEDURE sp_GetListByPageAndFileds
;
CREATE PROCEDURE [sp_GetListByPageAndFileds]
( 
	@pageSize  int,     
	@currentPage int = 1,    
	@fields   varchar(2000), 
	@tablename  varchar(200),   
	@orderString varchar(1000),   
	@whereString varchar(1000)   
)
AS
BEGIN
 DECLARE @sql varchar(2000)
 DECLARE @strOrder varchar(2000)
 DECLARE @strWhere varchar(2000)
 declare @recordcount int 
 declare @convertorderstr varchar(100)
declare @countsql nvarchar(500)
declare @totalpage int
 set @strOrder = REPLACE(RTRIM(LTRIM(@orderString)),'order by','')
 if @strOrder != ''
  set @strOrder = ' order by ' + @strOrder
 else
  set @strOrder = ' order by ID DESC'
set @strOrder=lower(@strOrder)
set @convertorderstr=replace(@strOrder,'desc','d_e_s_c')
set @convertorderstr=replace(@convertorderstr,'asc','desc')
set @convertorderstr=replace(@convertorderstr,'d_e_s_c','asc')
 set @strWhere = REPLACE(RTRIM(LTRIM(@whereString)),'where','')
 if @strWhere != ''
  set @strWhere = ' where ' + @strWhere

set @countsql='select @a=count(*) from ' + @tablename + @strWhere
exec  sp_executesql @countsql,N'@a int output',@recordcount output 


 if @pageSize = 0
  set @sql = 'select ' + @fields + ' from ' + @tablename + @strWhere + @strOrder
 else
 begin
		if @recordcount%@pageSize=0
			set @totalpage=@recordcount/@pageSize
		else
			set @totalpage=@recordcount/@pageSize+1
	if @totalpage <=1
	 set @currentPage=1 
	 if @totalpage <@currentPage 
	  set @currentPage=@totalpage
  if @currentPage = 1
   set @sql = 'select top ' + Str(@pageSize)+' '+ @fields + ' from ' + @tablename + @strWhere + @strOrder
  else
	if (@currentPage - 1) * @pageSize > @recordcount / 2
		set @sql = 'select top ' + str(@pageSize) + ' * from (select top ' + str((@recordcount - (@currentPage - 1) * @pageSize)) + ' ' + @fields + ' from ' + @tablename + @strWhere + @convertorderstr + ') as t1  ' + @strOrder
	else
		set @sql = 'select * from(select top ' + str(@pageSize) + ' * from (select top ' + str(@pageSize * @currentPage) + ' ' + @fields + ' from ' + @tablename + @strWhere + @strOrder + ') as t1  ' + @convertorderstr + ') as t2  ' + @strOrder
	end
	set @sql = @sql + '; select '+str(@recordcount)+' as cnt'
 exec(@sql)

END
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'sp_GetPMoney' AND type = 'P')
   DROP PROCEDURE sp_GetPMoney
;
CREATE
PROCEDURE [sp_GetPMoney]
(
	@partnerid int   
)
as
begin
declare @sum decimal(18,2)     
set @sum=0              
set @sum=@sum+
(select isnull(sum((cost_price*num)),0) from (select * from(select isnull(teamid,team_id) 

as teamid,isnull(num,quantity) as num from [order] left join [orderdetail] on([order].id=

[orderdetail].order_id) where state='pay')t where teamid in(select id from team where 

partner_id=@partnerid and teamway='Y'))t inner join team on(team.id=t.teamid))


set @sum=@sum+
(select isnull(sum((cost_price*num)),0) from (select * from(select isnull(teamid,team_id) 

as teamid,isnull(num,quantity) as num from [order] left join [orderdetail] on([order].id=

[orderdetail].order_id) where state='pay')t where teamid in(select id from team where 

partner_id=@partnerid and teamway='S'))t inner join team on(team.id=t.teamid))


set @sum=@sum+(select isnull(sum(s),0) from (select count(c.Id)*Cost_price as s from coupon 

as c inner join Team as t on c.Team_id=t.Id where c.Partner_id=@partnerid and Consume='Y' 

and t.teamway='N' group by Cost_price)t)
exec('select '+@sum+' as cnt')
end
;
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'sp_GetActualPMoney' AND type = 'P')
   DROP PROCEDURE sp_GetActualPMoney
;
CREATE
PROCEDURE [sp_GetActualPMoney]
(
	@partnerid int   
)
as
begin
declare @sum decimal(18,2)     
set @sum=0            
set @sum=@sum+
(select isnull(sum((cost_price*num)),0) from (select * from(select isnull(teamid,team_id) as teamid,isnull(num,quantity) as num from [order] left join [orderdetail] on([order].id=[orderdetail].order_id) where state='pay')t where teamid in(select id from team where partner_id=@partnerid ))t inner join team on(team.id=t.teamid))
exec('select '+@sum+' as cnt')
end