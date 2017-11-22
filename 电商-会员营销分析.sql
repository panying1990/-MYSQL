-- 会员营销这边需要针对所有零售会员进行每日、每月的交易数据分析。
-- 数据维度： 日度、月度、季度、年度
-- 取数周期：建议取数周期为截止日后2日10点
-- 数据最终格式：

-- 新老客销售分析
USE tag_text;
DROP TABLE
IF EXISTS member_repurchase_analysis;
CREATE TABLE member_repurchase_analysis AS
SELECT
 tt.year_mon_day AS  年月日,
 SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.user_count ELSE 0 END) AS 总客户数,
 ROUND(SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.total_fee ELSE 0 END),1) AS 成交总金额,
 SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.trade_count ELSE 0 END) AS 成交总订单数,
 SUM(CASE WHEN tt.user_pay_type IN('新客') THEN tt.user_count ELSE 0 END) AS 新客人数,
 ROUND(100*SUM(CASE WHEN tt.user_pay_type IN('新客') THEN tt.user_count ELSE 0 END)/SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.user_count ELSE 0 END),1) AS 新客人数占比,
 SUM(CASE WHEN tt.user_pay_type IN('新客') THEN tt.trade_count ELSE 0 END) AS 新客总订单数,
 ROUND(SUM(CASE WHEN tt.user_pay_type IN('新客') THEN tt.total_fee ELSE 0 END),1) AS 新客成交总金额,
 ROUND(100*SUM(CASE WHEN tt.user_pay_type IN('新客') THEN tt.total_fee ELSE 0 END)/SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.total_fee ELSE 0 END),1) AS 新客成交额占比,
 SUM(CASE WHEN tt.user_pay_type IN('老客') THEN tt.user_count ELSE 0 END) AS 老客人数,
 ROUND(100*SUM(CASE WHEN tt.user_pay_type IN('老客') THEN tt.user_count ELSE 0 END)/SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.user_count ELSE 0 END),1) AS 老客人数占比,
 SUM(CASE WHEN tt.user_pay_type IN('老客') THEN tt.trade_count ELSE 0 END) AS 老客总订单数, 
 ROUND(SUM(CASE WHEN tt.user_pay_type IN('老客') THEN tt.total_fee ELSE 0 END),1) AS 老客成交总金额,
 ROUND(100*SUM(CASE WHEN tt.user_pay_type IN('老客') THEN tt.total_fee ELSE 0 END)/SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.total_fee ELSE 0 END),1) AS 老客成交额占比
FROM
(SELECT
 DATE_FORMAT(tt.created,"%Y-%m-%d") AS year_mon_day,
 tt.user_pay_type AS user_pay_type,
 tt.trade_status,
 COUNT(DISTINCT tt.sys_customer_id) AS user_count,
 COUNT(DISTINCT tt.sys_trade_id) AS trade_count,
 sum(tt.payment) AS total_fee
-- pp.pay_times,
FROM
(SELECT
 tt.*,
 CASE tt.pay_times
      WHEN 0 THEN '潜客'
      WHEN 1 THEN '新客'
      ELSE '老客' END AS user_pay_type
FROM
(SELECT
 tt.*,
 pp.pay_times AS pay_times
FROM
 crm_kd.kd_trade tt
LEFT JOIN crm_kd.kd_customer pp
ON tt.sys_customer_id =pp.sys_customer_id
WHERE
  DATE_FORMAT(tt.pay_time,"%Y-%m-%d") BETWEEN "2017-01-01" AND DATE_FORMAT(NOW(),"%Y-%m-%d")
AND
 tt.trade_status IN('TRADE_FINISHED','TRADE_BUYER_SIGNED','WAIT_BUYER_CONFIRM_GOODS','WAIT_SELLER_SEND_GOODS')
AND
 tt.plat_from_id IN('585','586','587','588','590' ,'591','592','593','597','598')
AND
 tt.seller_memo <> CONCAT("%","1药网","%") -- 非医药网用户
AND
 tt.seller_memo <> CONCAT("%","碧生源药品旗舰店用户","%")
)tt)tt
GROUP BY
year_mon_day,
user_pay_type,
tt.trade_status)tt
GROUP BY
 年月日
ORDER BY
年月日 DESC
LIMIT 7;


-- 新老客销售分析
USE tag_text;
DROP TABLE
IF EXISTS member_repurchase_analysis_month;
CREATE TABLE member_repurchase_analysis_month AS
SELECT
 tt.year_mon_day AS 年月,
 SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.user_count ELSE 0 END) AS 总客户数,
 ROUND(SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.total_fee ELSE 0 END),1) AS 成交总金额,
 SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.trade_count ELSE 0 END) AS 成交总订单数,
 SUM(CASE WHEN tt.user_pay_type IN('新客') THEN tt.user_count ELSE 0 END) AS 新客人数,
 ROUND(100*SUM(CASE WHEN tt.user_pay_type IN('新客') THEN tt.user_count ELSE 0 END)/SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.user_count ELSE 0 END),1) AS 新客人数占比,
 SUM(CASE WHEN tt.user_pay_type IN('新客') THEN tt.trade_count ELSE 0 END) AS 新客总订单数,
 ROUND(SUM(CASE WHEN tt.user_pay_type IN('新客') THEN tt.total_fee ELSE 0 END),1) AS 新客成交总金额,
 ROUND(100*SUM(CASE WHEN tt.user_pay_type IN('新客') THEN tt.total_fee ELSE 0 END)/SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.total_fee ELSE 0 END),1) AS 新客成交额占比,
 SUM(CASE WHEN tt.user_pay_type IN('老客') THEN tt.user_count ELSE 0 END) AS 老客人数,
 ROUND(100*SUM(CASE WHEN tt.user_pay_type IN('老客') THEN tt.user_count ELSE 0 END)/SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.user_count ELSE 0 END),1) AS 老客人数占比,
 SUM(CASE WHEN tt.user_pay_type IN('老客') THEN tt.trade_count ELSE 0 END) AS 老客总订单数, 
 ROUND(SUM(CASE WHEN tt.user_pay_type IN('老客') THEN tt.total_fee ELSE 0 END),1) AS 老客成交总金额,
 ROUND(100*SUM(CASE WHEN tt.user_pay_type IN('老客') THEN tt.total_fee ELSE 0 END)/SUM(CASE WHEN tt.user_pay_type IN('新客','老客') THEN tt.total_fee ELSE 0 END),1) AS 老客成交额占比
FROM
(SELECT
 DATE_FORMAT(tt.pay_time,"%Y-%m") AS year_mon_day,
 tt.user_pay_type AS user_pay_type,
 tt.trade_status,
 COUNT(DISTINCT tt.sys_customer_id) AS user_count,
 COUNT(DISTINCT tt.sys_trade_id) AS trade_count,
 sum(tt.payment) AS total_fee
-- pp.pay_times,
FROM
(SELECT
 tt.*,
 CASE tt.pay_times
      WHEN 0 THEN '潜客'
      WHEN 1 THEN '新客'
      ELSE '老客' END AS user_pay_type
FROM
(SELECT
 tt.*,
 pp.pay_times AS pay_times
FROM
 crm_kd.kd_trade tt
LEFT JOIN crm_kd.kd_customer pp
ON tt.sys_customer_id =pp.sys_customer_id
WHERE
  DATE_FORMAT(tt.pay_time,"%Y-%m-%d") BETWEEN "2016-01-01" AND DATE_FORMAT(NOW(),"%Y-%m-%d")
AND
 tt.trade_status IN('TRADE_FINISHED','TRADE_BUYER_SIGNED','WAIT_BUYER_CONFIRM_GOODS','WAIT_SELLER_SEND_GOODS')
AND
 tt.plat_from_id IN('585','586','587','588','590' ,'591','592','593','597','598')
AND
 tt.seller_memo <> CONCAT("%","1药网","%") -- 非医药网用户
AND
 tt.seller_memo <> CONCAT("%","碧生源药品旗舰店用户","%") -- 非碧生源奥利司他用户
)tt)tt
GROUP BY
year_mon_day,
user_pay_type,
tt.trade_status)tt
GROUP BY
 年月
ORDER BY
年月 DESC
LIMIT 24;

