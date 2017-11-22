USE Olistat;
-- 设置报表时间
SET @nowday = DATE_FORMAT(NOW(),"%Y-%m-%d");
SET @yesterday = DATE_FORMAT(DATE_SUB(NOW(),INTERVAL 1 DAY),"%Y-%m-%d");

DROP TABLE
IF EXISTS olistat_monitor_report;
CREATE TABLE olistat_monitor_report AS
SELECT DISTINCT
 tt.`平台`,
 tt.`渠道`,
 tt.`品类`,
 tt.`品牌`,
 tt.`规格`,
 tt.`日常价`,
 tt.`日常粒单价`,
 tt.`活动价`,
 tt.款式,
 tt.`活动粒单价`,
 tt.`月销量`,
 tt.`评价量`,
 pp.`支付子订单数`,
 zz.`流量指数`,
 DATE_FORMAT(tt.`日期`,"%Y-%m-%d") AS 日期,
 tt.`产品详情页链接`
FROM
 Olistat.olistat_project_data tt
LEFT JOIN
(SELECT
   tt.`产品ID`,
   tt.`支付子订单数`
 FROM
 Olistat.olistat_sales_data tt
WHERE
DATE_FORMAT(tt.`日期`,"%Y-%m-%d")= @nowday)pp
ON tt.`产品ID`=pp.`产品ID`
LEFT JOIN
 (SELECT
   tt.`产品ID`,
   tt.`流量指数`
 FROM
 Olistat.olistat_traffic_data tt
 WHERE
  DATE_FORMAT(tt.`日期`,"%Y-%m-%d")= @nowday)zz
ON tt.`产品ID`=zz.`产品ID`
WHERE
 DATE_FORMAT(tt.`日期`,"%Y-%m-%d")= @nowday
ORDER BY
 tt.`平台` DESC,
 tt.`渠道s`,
 tt.`渠道`,
 tt.`品类`,
 tt.`品牌s`,
 tt.品牌,
 tt.`规格s`,
 tt.`规格`;
 
 
 == 对当天数据重新导入
 USE Olistat;
-- 设置报表时间
SET @nowday = DATE_FORMAT(NOW(),"%Y-%m-%d");
SET @yesterday = DATE_FORMAT(DATE_SUB(NOW(),INTERVAL 1 DAY),"%Y-%m-%d");

DELETE FROM Olistat.olistat_sales_data
WHERE Olistat.olistat_sales_data.`日期` = @nowday;

DELETE FROM Olistat.olistat_traffic_data
WHERE Olistat.olistat_traffic_data.`日期` = @nowday;

DELETE FROM Olistat.olistat_project_data
WHERE Olistat.olistat_project_data.`日期` = @nowday;
 
 
 
 
 
 
 
 
 
