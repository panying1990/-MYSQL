-- 按用户汇总销售人员拜访动作以及归属于个人的终端表现情况：
DROP TABLE
IF
	EXISTS sale_visit_summary;
CREATE TABLE sale_visit_summary (
first_dis VARCHAR ( 50 ) COMMENT '一级区域', 
second_dis VARCHAR ( 50 ) COMMENT '二级区域',
third_dis VARCHAR ( 50 ) COMMENT '三级区域',
sale_manager VARCHAR ( 50) COMMENT '业务代表 拜访人 协防人',
sale_post  varchar(50) comment '职位',
manager_clientcnt INT COMMENT '归属于用户的区域终端数',
visit_count INT COMMENT '统计时间范围内用户拜访的客户数',
duty_visit_count INT COMMENT '用户负责区域范围内拜访客户数',
managers_visit INT COMMENT '用户负责区域范围内拜访客户次数',
subduty_visit_count INT COMMENT '用户非负责区域范围内拜访客户数',
subduty_visit_per VARCHAR ( 255 ) COMMENT '协防率 用户非负责区域范围内拜访客户数/统计时间范围内用户拜访的客户数',
manager_visit_per VARCHAR ( 255 ) COMMENT '维护率 用户负责区域范围内拜访客户数/归属于用户的区域终端数',
businessvisit INT COMMENT '用户负责区域范围内拜访商业客户户数',
termvisit INT COMMENT '用户负责区域范围内拜访终端客户户数',
distance_5min INT COMMENT '用户负责区域范围内拜访客户时间少于5min的户数',
min5_visit_per VARCHAR ( 255 ) COMMENT '5min拜访率 用户负责区域范围内拜访时间<5min/用户负责区域范围内拜访客户数',
distance_1hour INT COMMENT '用户负责区域范围内拜访客户时间大于5min少于1hour的户数',
hour1_visit_per VARCHAR ( 255 ) COMMENT '5min少于1hour拜访率 用户负责区域范围内拜访时间大于5min少于1hour/用户负责区域范围内拜访客户数',
distance_overhour INT COMMENT '用户负责区域范围内拜访客户时间大于1hour的户数',
overhour_visit_per VARCHAR ( 255 ) COMMENT '大于1hour拜访率 用户负责区域范围内拜访时间大于1hour/用户负责区域范围内拜访客户数',
onetime INT COMMENT '用户负责区域范围内拜访客户次数1次户数',
twotimes INT COMMENT '用户负责区域范围内拜访客户次数2次户数',
threetimes INT COMMENT '用户负责区域范围内拜访客户客户次数>2次户数',
display_duanhuo INT COMMENT '用户负责区域范围内拜访客户有库存上报户数',
duanhuo_per VARCHAR ( 255 ) COMMENT '断货率 用户负责区域范围内上报库存户数/用户负责区域范围内拜访客户数',
display_pop INT COMMENT '用户负责区域范围内拜访客户有pop上报户数',
display_ph_pt INT COMMENT '用户负责区域范围内拜访客户有ph和pt版上报户数',
display_chenlie INT COMMENT '用户负责区域范围内拜访客户有陈列报户数' 
) COMMENT = '用户汇总销售人员拜访动作以及归属于个人的终端表现情况表';
INSERT INTO sale_visit_summary (
first_dis,
second_dis,
third_dis,
sale_post,
sale_manager,
manager_clientcnt,
visit_count,
duty_visit_count,
managers_visit,
subduty_visit_count,
subduty_visit_per,
manager_visit_per,
businessvisit,
termvisit,
distance_5min,
min5_visit_per,
distance_1hour,
hour1_visit_per,
distance_overhour,
overhour_visit_per,
onetime,
twotimes,
threetimes,
display_duanhuo,
duanhuo_per,
display_pop,
display_ph_pt,
display_chenlie 
) SELECT
s.first_dis,
s.second_dis,
s.third_dis,
s.sale_post,
a.sale_manager,
c.manager_clientcnt,
a.visit_count,
a.duty_visit_count,
a.managers_visit,
a.subduty_visit_count,
concat( round( a.subduty_visit_count / a.visit_count * 100, 0 ), '%' ) AS subduty_visit_per,
concat( round( a.duty_visit_count / c.manager_clientcnt * 100, 0 ), '%' ) AS manager_visit_per,
a.businessvisit,
a.termvisit,
a.distance_5min,
concat( round( a.distance_5min / a.duty_visit_count * 100, 0 ), '%' ) AS min5_visit_per,
a.distance_1hour,
concat( round( a.distance_1hour / a.duty_visit_count * 100, 0 ), '%' ) AS hour1_visit_per,
a.distance_overhour,
concat( round( a.distance_overhour / a.duty_visit_count * 100, 0 ), '%' ) AS overhour_visit_per,
a.onetime,
a.twotimes,
a.threetimes,
a.display_duanhuo,
concat( round( ( a.duty_visit_count - a.display_duanhuo ) / a.duty_visit_count * 100, 0 ), '%' ) AS duanhuo_per,
a.display_pop,
a.display_ph_pt,
a.display_chenlie 
FROM
	(
SELECT
	a.sale_manager,
	count(client_id) as visit_count,
	sum(if(a.duty_flag='Y',1,0)) as duty_visit_count,
	sum(if(a.duty_flag='Y',a.managers_visit,0)) as managers_visit,
	sum(if(a.duty_flag='N',1,0)) as subduty_visit_count,
  sum( IF ( a.duty_flag = 'Y', a.businessvisit, 0 ) ) AS businessvisit,
	sum( IF ( a.duty_flag = 'Y', a.termvisit, 0 ) ) AS termvisit,
  sum(if(a.duty_flag = 'Y',a.distance_5min,0))as distance_5min,
	sum(if(a.duty_flag = 'Y',a.distance_1hour,0))as distance_1hour,
	sum(if(a.duty_flag = 'Y',a.distance_overhour,0))as distance_overhour,
	sum( IF ( a.duty_flag='Y'and a.managers_visit=1, 1, 0 ) ) AS onetime,
	sum( IF ( a.duty_flag='Y'and a.managers_visit=2, 1, 0 ) ) AS twotimes,
	sum( IF( a.duty_flag='Y'and a.managers_visit>2, 1, 0 )) AS threetimes,
	sum( IF( a.duty_flag='Y', a.display_duanhuo, 0 )) AS display_duanhuo,
	sum( IF( a.duty_flag='Y', a.display_pop, 0 )) AS display_pop,
	sum( IF( a.duty_flag='Y', a.display_ph_pt, 0 )) AS display_ph_pt,
	sum( IF( a.duty_flag='Y', a.display_chenlie, 0 )) AS display_chenlie
FROM
	staff_visit_client_base a
GROUP BY
  a.sale_manager)a
	left join (select a.sale_manager,count(distinct a.client_id) as manager_clientcnt from (select client_id, sale_manager from client_info where client_level <> 'D' AND coop_status = '合作中') a group by a.sale_manager having sale_manager in (select sale_manager from staff_info)) c
	on a.sale_manager = c.sale_manager
	left join staff_info s
	on a.sale_manager = s.sale_manager;

	
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			