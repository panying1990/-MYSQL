set @state = '华南|湖南省|湖北省|广西省|云南省|贵州省|四川重庆|江西省';

-- 创建基础人员拜访情况表
DROP TABLE
IF
	EXISTS staff_visit_client_base;
CREATE TABLE staff_visit_client_base (
client_id INT COMMENT '客户编码',
sale_allpath VARCHAR ( 255 ) COMMENT '拜访客户全路径',
sale_manager VARCHAR ( 50 ) COMMENT '拜访员工',
managers_visit INT COMMENT '拜访次数',
businessvisit INT COMMENT '商业拜访次数',
termvisit INT COMMENT '终端拜访次数',
distance_5min INT COMMENT '停留5min内的拜访户数',
distance_1hour INT COMMENT '停留5min-1hour内的拜访户数',
distance_overhour INT COMMENT '停留>1hour内的拜访户数',
display_chenlie INT COMMENT '有陈列的户数',
display_ph_pt INT COMMENT '有ph&pt的户数',
display_pop INT COMMENT '有ph&pt的户数',
display_duanhuo INT COMMENT '库存产品数',
duty_flag VARCHAR ( 50 ) COMMENT '是否负责标记'
) COMMENT = '手机系统统计周报基础表';
INSERT INTO staff_visit_client_base (
client_id,
sale_allpath,
sale_manager,
managers_visit,
businessvisit,
termvisit,
distance_5min,
distance_1hour,
distance_overhour,
display_chenlie,
display_ph_pt,
display_pop,
display_duanhuo,
duty_flag
)SELECT
			d.client_id,
			d.sale_allpath,
			d.sale_manager,
			d.managers_visit,
			d.businessvisit,
			d.termvisit,
			d.distance_5min,
			d.distance_1hour,
			d.distance_overhour,
		  if(g.display_chenlie is null, 0,g.display_chenlie)as display_chenlie,
		  if(g.display_ph_pt is null, 0,g.display_ph_pt)as display_ph_pt,
		  if(g.display_pop is null, 0,g.display_pop)as display_pop,
      if(a.store_sum is null, 0,1)as display_duanhuo,
			if(c.client_id is not null,'Y','N') AS duty_flag
			FROM
				(
					SELECT
					  d.client_id,
						d.sale_allpath,
						d.sale_manager,
			      count(d.client_id) as managers_visit,
						CASE WHEN typemake(d.client_type)='client' THEN count(d.client_id) ELSE 0 END AS businessvisit,
					  CASE WHEN typemake(d.client_type)='term' THEN count(d.client_id) ELSE 0 END AS termvisit,
					  getminute(d.visit_minute,0,5) as distance_5min,
					  getminute(d.visit_minute,5,61) as distance_1hour, 
					  getminute(d.visit_minute,60,400) as distance_overhour 
						FROM
							visit_log d
						GROUP BY
						 d.client_id,
						 d.sale_allpath,
						 d.sale_manager
						 having
						 getarea(sale_allpath,2) REGEXP @state
						) d -- 拜访数据汇总
					LEFT JOIN 
				  	(SELECT
					  g.client_id,
						g.sale_manager,
					  g.sale_allpath,
						getchenlie(concat(display_huojia,g.display_duitou)) as display_chenlie,
						getchenlie(display_ph_pt) as display_ph_pt,
						getchenlie(display_pop) as display_pop
						FROM
							southtask_log g
						GROUP BY
						  g.client_id,
						  g.sale_manager,
					    g.sale_allpath
						having
						 getarea(g.sale_allpath,2) REGEXP @state
						) g -- 南战区终端任务表数据汇总
						ON CONCAT( d.sale_manager, d.client_id ) = CONCAT( g.sale_manager, g.client_id)
						LEFT JOIN -- 左链接库存数据
						(
						SELECT
							 a.client_id,
							 a.sale_manager,
							 a.sale_allpath,
							a.changrun25 + a.changrun40 + a.changjing25 + a.changjing40 + a.laili24 AS store_sum 
						FROM
							(
							SELECT
                a.client_id,
								a.sale_manager,
								a.sale_allpath,
								getprod(a.product_name,'常润茶20+5',a.prodstore_volume) as changrun25,
								getprod(a.product_name,'常润茶40',a.prodstore_volume) as changrun40,
								getprod(a.product_name,'常菁茶20+5',a.prodstore_volume) as changjing25,
								getprod(a.product_name,'常菁茶40',a.prodstore_volume) as changjing40,
								getprod(a.product_name,'来利24',a.prodstore_volume) as laili24
							FROM
								store_log a )
								a
							GROUP BY
								a.client_id,
							  a.sale_manager,
							  a.sale_allpath
							) a -- 库存数据汇总
						ON CONCAT( d.sale_manager, d.client_id ) = CONCAT( a.sale_manager, a.client_id)
						left join (select client_id, sale_manager from client_info where client_level <> 'D' AND coop_status = '合作中')c on  CONCAT( d.sale_manager, d.client_id ) = CONCAT( c.sale_manager, c.client_id);