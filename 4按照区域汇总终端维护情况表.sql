-- 按最小销售区域汇总的终端维护情况表：
DROP TABLE
IF
	EXISTS client_visit_summary;
CREATE TABLE client_visit_summary (
second_dis VARCHAR ( 50 ) COMMENT '二级区域',
third_dis VARCHAR ( 50 ) COMMENT '三级区域',
last_dis VARCHAR ( 50 ) COMMENT '最小区域',
last_clientcnt INT COMMENT '最小区域的全部终端数',
mananger_count int comment '区域内客户经理数' ,
visit_count INT COMMENT '区域内拜访户数',
managers_visit INT COMMENT '区域内拜访次数',
manager_visit_per VARCHAR ( 255 ) COMMENT '维护率 区域内拜访门店户数/区域终端数',
businessvisit INT COMMENT '用户负责区域范围内拜访商业客户户数',
termvisit INT COMMENT '用户负责区域范围内拜访终端客户户数',
distance_5min INT COMMENT '区域范围内拜访客户时间少于5min的户数',
min5_visit_per VARCHAR ( 255 ) COMMENT '5min拜访率 区域范围内拜访时间<5min/用户负责区域范围内拜访客户数',
distance_1hour INT COMMENT '区域范围内拜访客户时间大于5min少于1hour的户数',
hour1_visit_per VARCHAR ( 255 ) COMMENT '5min少于1hour拜访率 区域范围内拜访时间大于5min少于1hour/用户负责区域范围内拜访客户数',
distance_overhour INT COMMENT '区域范围内拜访客户时间大于1hour的户数',
overhour_visit_per VARCHAR ( 255 ) COMMENT '大于1hour拜访率 区域范围内拜访时间大于1hour/用户负责区域范围内拜访客户数',
onetime INT COMMENT '区域范围内拜访客户次数1次户数',
twotimes INT COMMENT '区域范围内拜访客户次数2次户数',
threetimes INT COMMENT '区域范围内拜访客户客户次数>2次户数',
display_duanhuo INT COMMENT '区域范围内拜访客户有库存上报户数',
duanhuo_per VARCHAR ( 255 ) COMMENT '断货率 区域范围内上报库存户数/用户负责区域范围内拜访客户数',
display_pop INT COMMENT '区域范围内拜访客户有pop上报户数',
display_ph_pt INT COMMENT '区域范围内拜访客户有ph和pt版上报户数',
display_chenlie INT COMMENT '区域范围内拜访客户有陈列报户数' 
) COMMENT = '最小销售区域汇总拜访行为及终端维护情况表';
INSERT INTO client_visit_summary (
second_dis,
third_dis,
last_dis,
last_clientcnt,
mananger_count,
visit_count,
managers_visit,
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
a.second_dis,
a.third_dis,
a.last_dis,
c.last_clientcnt,
a.mananger_count,
a.visit_count,
a.managers_visit,
concat( round( a.visit_count / c.last_clientcnt * 100, 0 ), '%' ) AS manager_visit_per,
a.businessvisit,
a.termvisit,
a.distance_5min,
concat( round( a.distance_5min / a.visit_count * 100, 0 ), '%' ) AS min5_visit_per,
a.distance_1hour,
concat( round( a.distance_1hour / a.visit_count * 100, 0 ), '%' ) AS hour1_visit_per,
a.distance_overhour,
concat( round( a.distance_overhour / a.visit_count * 100, 0 ), '%' ) AS overhour_visit_per,
a.onetime,
a.twotimes,
a.threetimes,
a.display_duanhuo,
concat( round( ( a.visit_count - a.display_duanhuo ) / a.visit_count * 100, 0 ), '%' ) AS duanhuo_per,
a.display_pop,
a.display_ph_pt,
a.display_chenlie 
FROM
	(
select
  a.second_dis,
	a.third_dis,
	a.last_dis,
	count(a.client_id) as visit_count,
	count(distinct sale_manager) as mananger_count,
	sum( managers_visit) AS managers_visit,
	sum( businessvisit) AS businessvisit,
	sum( termvisit) AS termvisit,
	sum( distance_5min) AS distance_5min,
	sum( distance_1hour) AS distance_1hour,
	sum( distance_overhour) AS distance_overhour,
	sum( IF ( a.managers_visit=1, 1, 0 ) ) AS onetime,
	sum( IF ( a.managers_visit=2, 1, 0 ) ) AS twotimes,
	sum( IF( a.managers_visit>2, 1, 0 )) AS threetimes,
	sum(a.display_duanhuo) AS display_duanhuo,
	sum(a.display_pop) AS display_pop,
	sum(a.display_ph_pt) AS display_ph_pt,
	sum(a.display_chenlie) AS display_chenlie
FROM
	(
SELECT
	s.second_dis,
	s.third_dis,
	c.last_dis,
  b.sale_manager,
  b.client_id,
	b.managers_visit,
	b.businessvisit,
	b.termvisit,
	b.distance_5min,
	b.distance_1hour,
	b.distance_overhour,
	b.display_chenlie,
	b.display_ph_pt,
	b.display_pop,
	b.display_duanhuo
 FROM
	staff_visit_client_base b
	left join client_info c
	on b.client_id = c.client_id
  left join staff_info s
	on b.sale_manager = s.sale_manager
	where 
	 s.second_dis is not null)a
	 GROUP BY
	  a.second_dis,
	a.third_dis,
	a.last_dis)a
	 left join (select last_dis,count(client_id) as last_clientcnt from client_info GROUP BY last_dis)c
	 on a.last_dis = c.last_dis;
	

