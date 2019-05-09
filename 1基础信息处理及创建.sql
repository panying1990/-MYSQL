-- 创建基础客户信息表并插入
DROP TABLE
IF
	EXISTS client_info;
CREATE TABLE client_info (
client_id VARCHAR ( 50 ) COMMENT '客户编码',
client_name VARCHAR ( 255 ) COMMENT '客户名称',
client_type VARCHAR ( 50 ) COMMENT '客户类型',
client_level VARCHAR ( 50 ) COMMENT '客户级别',
client_province VARCHAR ( 50 ) COMMENT '客户所在省',
client_city VARCHAR ( 50 ) COMMENT '客户所在城市',
last_dis varchar(50) comment '最小区域',
sale_manager VARCHAR ( 50 ) COMMENT '客户经理',
sale_allpath VARCHAR ( 255 ) COMMENT '销售区域全路径',
coop_status  varchar(50) comment '合作状态'
) COMMENT = '客户信息表';
INSERT INTO client_info ( client_id, client_name, client_type,client_level, client_province, client_city, last_dis,sale_manager, sale_allpath, coop_status  ) SELECT
客户编码,客户名称,客户类型,客户级别,行政省,市,getarea(销售区域全路径,-1) as last_dis,
客户经理,销售区域全路径,合作状态 from
	client_data_template;
	
	-- 创建规范的员工信息表
	DROP TABLE
IF
	EXISTS staff_info;
CREATE TABLE staff_info (
sale_manager VARCHAR ( 50 ) COMMENT '客户经理',
sale_post VARCHAR ( 50 ) COMMENT '公司职务',
sale_department VARCHAR ( 255 ) COMMENT '部门全路径',
first_dis VARCHAR ( 50 ) COMMENT '战区级',
second_dis VARCHAR ( 50 ) COMMENT '地区级',
third_dis VARCHAR ( 50 ) COMMENT '末级'
) COMMENT = '员工信息表';
INSERT INTO staff_info ( sale_manager, sale_post,sale_department,first_dis,second_dis,third_dis) SELECT
`姓名（必填）`,职务,`部门全路径`,getarea(`部门全路径`, 4) as first_dis,getarea(`部门全路径`, 5) as second_dis,getarea(部门全路径,-1) as third_dis from staff_data_template;


	
-- 创建拜访信息记录表
DROP TABLE
IF
	EXISTS visit_log;
CREATE TABLE visit_log (
visit_date DATE COMMENT '拜访日期',
sale_manager VARCHAR ( 50 ) COMMENT '拜访人',
sale_allpath VARCHAR ( 255 ) COMMENT '销售区域全路径',
client_id VARCHAR ( 50 ) COMMENT '客户编号',
client_name VARCHAR ( 255 ) COMMENT '客户名称',
client_type VARCHAR ( 50 ) COMMENT '客户类型',
visit_status VARCHAR ( 50 ) COMMENT '拜访状态',
visit_minute INT COMMENT '拜访持续时长' 
) COMMENT '拜访记录表';
INSERT INTO visit_log (
visit_date,
sale_manager,
sale_allpath ,
client_id,
client_name,
client_type,
visit_status,
visit_minute
) SELECT
`拜访日期`,
`拜访人`,
`销售区域全路径`,
`客户编码`,
`拜访客户`,
`客户类型`,
`拜访完成`,
`拜访用时(分钟)` 
FROM
	visit_data_template 
WHERE
	拜访完成 = '已完成';
	

-- 创建南战区终端任务表记录
DROP TABLE
IF
	EXISTS southtask_log;
CREATE TABLE southtask_log (
visit_date DATETIME COMMENT '拜访日期',
sale_manager VARCHAR ( 255 ) COMMENT '拜访人',
sale_allpath VARCHAR ( 255 ) COMMENT '销售区域全路径',
client_id VARCHAR ( 255 ) COMMENT '客户编号',
client_name VARCHAR ( 255 ) COMMENT '客户名称',
client_type VARCHAR ( 255 ) COMMENT '客户类型',
display_duitou VARCHAR ( 255 ) COMMENT '堆头',
display_huojia VARCHAR ( 255 ) COMMENT '货架',
display_ph_pt VARCHAR ( 255 ) COMMENT '喷绘/PT版',
display_pop VARCHAR ( 255 ) COMMENT '海报',
display_other VARCHAR ( 255 ) COMMENT '其他',
price_run25 VARCHAR ( 255 ) COMMENT '常润茶25袋价格',
price_jing25 VARCHAR ( 255 ) COMMENT '常菁茶25袋价格',
price_run40 VARCHAR ( 255 ) COMMENT '常润茶40袋价格',
price_jing40 VARCHAR ( 255 ) COMMENT '常菁茶40袋价格',
price_laili VARCHAR ( 255 ) COMMENT '来利价格',
activity_status VARCHAR ( 255 ) COMMENT '是否参加活动',
activity_describe VARCHAR ( 255 ) COMMENT '活动描述',
activity_gifts VARCHAR ( 255 ) COMMENT '活动是否有赠品',
activity_giftsdescribe VARCHAR ( 255 ) COMMENT '赠品情况描述'
) COMMENT = '南战区终端任务表';
INSERT INTO southtask_log (
visit_date,
sale_manager,
sale_allpath,
client_id,
client_name,
client_type,
display_duitou,
display_huojia,
display_ph_pt,
display_pop,
display_other,
price_run25,
price_jing25,
price_run40,
price_jing40,
price_laili,
activity_status,
activity_describe,
activity_gifts,
activity_giftsdescribe
) SELECT
`上报时间`,
`拜访人`,
`销售区域全路径`,
`客户编码`,
`拜访客户`,
`客户类型`,
tt.陈列 as 堆头,
tt.`货架`,
tt.`喷绘/PT板`,
tt.POP,
tt.`其它`,
tt.零售价 as 常润茶25袋,
tt.`常菁25袋（元）`,
tt.`常润40袋（元）`,
tt.`常菁40袋（元）`,
tt.`来利（元）`,
tt.活动,
tt.`活动描述`,
tt.`是否有赠品`,
tt.`赠品描述`
FROM
	termtask_data_template tt 
WHERE
	拜访完成 = '已完成' ;
	
	
-- 创建库存明细表
DROP TABLE
IF
	EXISTS store_log;
CREATE TABLE store_log (
report_date DATETIME COMMENT '库存上报日期',
sale_manager VARCHAR ( 50 ) COMMENT '上报人 即拜访人',
sale_allpath VARCHAR ( 255 ) COMMENT '销售区域全路径',
client_id VARCHAR ( 50 ) COMMENT '客户编号',
client_name VARCHAR ( 255 ) COMMENT '客户名称',
client_type VARCHAR ( 50 ) COMMENT '客户类型',
product_name VARCHAR ( 50 ) COMMENT '商品名称',
prodstore_volume INT COMMENT '商品库存量' 
) COMMENT = '库存明细表';
INSERT INTO store_log ( report_date, sale_manager, sale_allpath,  client_id, client_name, client_type, product_name, prodstore_volume ) SELECT
a.* 
FROM
	(
SELECT
	a.`上报日期` AS report_date,
	a.上报人 AS sale_manager,
	b.sale_allpath AS sale_allpath,
	a.`客户编码` AS client_id,
	a.`客户` AS client_name,
	a.客户类型 AS client_type,
	a.`商品名称` AS product_name,
	a.`库存数量`*1 AS prodstore_volume 
FROM
	store_data_template a left join client_info b 
on
	a.`客户编码` = b.client_id 
	) a ;
