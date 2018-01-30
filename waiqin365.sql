-- author:panying
-- conding；gbk
-- codetime:2018-01-30


-- 本模块用于外勤365系统的盘点，库存上报明细情况
SELECT
 tt.`区域`,
 tt.`部门（必填）` AS 地区,
 tt.`上级领导` AS 地区负责人,
 tt.`客户总数` AS 拜访客户数,
 tt.过期品客户数,
 CONCAT(ROUND(100*tt.过期品客户数/tt.`客户总数`,1),"%") AS 过期品客户数占比,
 tt.红灯区客户数,
 CONCAT(ROUND(100*tt.红灯区客户数/tt.`客户总数`,1),"%") AS 红灯区客户数占比,
 tt.黄灯区客户数,
 CONCAT(ROUND(100*tt.黄灯区客户数/tt.`客户总数`,1),"%") AS 黄灯区客户数占比,
 tt.绿灯区客户数,
 CONCAT(ROUND(100*tt.绿灯区客户数/tt.`客户总数`,1),"%") AS 绿灯区客户数占比
FROM
(SELECT
 tt.`区域`,
 tt.`部门（必填）`,
 tt.`上级领导`,
SUM((CASE WHEN tt.`类型` = "过期品" THEN tt.`客户数` ELSE 0 END)) AS 过期品客户数,
SUM((CASE WHEN tt.`类型` = "红灯区" THEN tt.`客户数` ELSE 0 END)) AS 红灯区客户数,
SUM((CASE WHEN tt.`类型` = "黄灯区" THEN tt.`客户数` ELSE 0 END)) AS 黄灯区客户数,
SUM((CASE WHEN tt.`类型` = "绿灯区" THEN tt.`客户数` ELSE 0 END)) AS 绿灯区客户数,
ROUND(AVG(tt.`客户总数`),0) AS 客户总数
FROM
(SELECT
 tt.`区域`,
 tt.`部门（必填）`,
 tt.`上级领导`,
 tt.`类型`,
 tt.`客户数`,
 zz.`客户数` AS 客户总数
FROM
(SELECT
 MID(tt.`部门全路径`,6,2) AS 区域,
 tt.`部门（必填）`,
 tt.`上级领导`,
 tt.`类型`,
 COUNT(tt.`客户名称`) AS 客户数
FROM
(SELECT
 tt.`最近上报人`,
 zz.`部门（必填）`,
 zz.`部门全路径`,
 zz.`上级领导`,
 tt.`客户名称`,
 tt.`类型`
FROM
waiqin.`效期管理` tt
LEFT JOIN
waiqin.员工数据 zz
ON 
 tt.`最近上报人`=zz.`姓名（必填）`)tt
GROUP BY
 区域,
 tt.`部门（必填）`,
 tt.`上级领导`,
 tt.`类型`)tt
LEFT JOIN
(SELECT
 MID(tt.`部门全路径`,6,2) AS 区域,
 tt.`部门（必填）`,
 tt.`上级领导`,
 COUNT(tt.`客户名称`) AS 客户数
FROM
(SELECT
 tt.`最近上报人`,
 zz.`部门（必填）`,
 zz.`部门全路径`,
 zz.`上级领导`,
 tt.`客户名称`,
 tt.`类型`
FROM
waiqin.`效期管理` tt
LEFT JOIN
waiqin.员工数据 zz
ON 
 tt.`最近上报人`=zz.`姓名（必填）`)tt
GROUP BY
 区域,
 tt.`部门（必填）`,
 tt.`上级领导`)zz
ON CONCAT(tt.`区域`,tt.`部门（必填）`,tt.`上级领导`)= CONCAT(zz.`区域`,zz.`部门（必填）`,zz.`上级领导`))tt
GROUP BY
 tt.`区域`,
 tt.`部门（必填）`,
 tt.`上级领导`)tt
ORDER BY
 tt.区域 DESC,
 地区;
 
-- # 战报速递使用情况
SELECT
 tt.`区域`,
 tt.`职务`,
 tt.`操作用户`,
 SUM(tt.操作次数) AS 总操作次数,
 SUM((CASE WHEN tt.`操作周` = "48" THEN tt.操作次数 ELSE 0 END)) AS 第48周操作次数,
 SUM((CASE WHEN tt.`操作周` = "49" THEN tt.操作次数 ELSE 0 END)) AS 第49周操作次数,
 SUM((CASE WHEN tt.`操作周` = "50" THEN tt.操作次数 ELSE 0 END)) AS 第50周操作次数,
 SUM((CASE WHEN tt.`操作周` = "51" THEN tt.操作次数 ELSE 0 END)) AS 第51周操作次数,
 SUM((CASE WHEN tt.`操作周` = "52" THEN tt.操作次数 ELSE 0 END)) AS 第52周操作次数
FROM
(SELECT
 tt.`区域`,
 tt.`职务`,
 tt.`操作用户`,
 tt.`操作周`,
 COUNT(DISTINCT tt.`操作时间`) AS 操作次数
FROM
(SELECT
 MID(zz.`部门全路径`,6,2) AS 区域,
 tt.`操作时间`,
 WEEKOFYEAR(tt.`操作时间`) AS 操作周,
 tt.`操作用户`,
 zz.`职务`,
 tt.`操作类型`
FROM
 waiqin.`战报速递使用明细` tt
LEFT JOIN
 waiqin.`员工数据` zz
ON
 tt.`操作用户`= zz.`姓名（必填）`
 WHERE
 (zz.`职务` IN("事业部经理","地区经理")
OR
  zz.`姓名（必填）` IN("江丛林","刘宝刚")))tt
GROUP BY
 tt.`区域`,
 tt.`职务`,
 tt.`操作用户`,
 tt.`操作周`)tt
GROUP BY
 tt.`区域`,
 tt.`职务`,
 tt.`操作用户`
ORDER BY
 tt.`区域`,
 tt.`职务`,
 总操作次数 DESC;


-- 任务发布情况
SELECT
 tt.`区域`,
 tt.`部门（必填）`,
 tt.`职务`,
 tt.`创建人`,
 SUM(tt.任务创建次数) AS 发布任务数,
 SUM((CASE WHEN tt.`创建周` = "48" THEN tt.任务创建次数 ELSE 0 END)) AS 第48周发布任务数,
 SUM((CASE WHEN tt.`创建周` = "49" THEN tt.任务创建次数 ELSE 0 END)) AS 第49周发布任务数,
 SUM((CASE WHEN tt.`创建周` = "50" THEN tt.任务创建次数 ELSE 0 END)) AS 第50周发布任务数,
 SUM((CASE WHEN tt.`创建周` = "51" THEN tt.任务创建次数 ELSE 0 END)) AS 第51周发布任务数,
 SUM((CASE WHEN tt.`创建周` = "52" THEN tt.任务创建次数 ELSE 0 END)) AS 第52周发布任务数
FROM
(SELECT
 tt.`区域`,
 tt.`部门（必填）`,
 tt.`职务`,
 tt.`创建人`,
 tt.`创建周`,
 COUNT(DISTINCT tt.`创建时间`) AS 任务创建次数,
 SUM(tt.`总通知人数`) AS 任务送达,
 SUM(tt.`已办理`) AS 任务执行
FROM
(SELECT
 MID(zz.`部门全路径`,6,2) AS 区域,
 zz.`部门（必填）`,
 tt.`创建时间`,
 WEEKOFYEAR(tt.`创建时间`) AS 创建周,
 tt.`创建人`,
 zz.`职务`,
 tt.`总通知人数`,
 tt.`已办理`
FROM
waiqin.`任务情况` tt
LEFT JOIN
 waiqin.`员工数据` zz
ON tt.`创建人` = zz.`姓名（必填）`)tt
GROUP BY
 tt.`区域`,
 tt.`部门（必填）`,
 tt.`职务`,
 tt.`创建人`,
 tt.`创建周`)tt
GROUP BY
 tt.`区域`,
 tt.`部门（必填）`,
 tt.`职务`,
 tt.`创建人`
ORDER BY
 tt.`区域` DESC,
 tt.`职务`,
 tt.`部门（必填）`;


-- -- 任务执行情况
SELECT
 tt.`区域`,
 tt.`部门（必填）`,
 tt.`职务`,
 tt.`创建人`,
 SUM(tt.任务创建次数) AS 发布任务数,
 ROUND(100*SUM((CASE WHEN tt.`创建周` = "48" THEN tt.任务执行 ELSE 0 END))/SUM((CASE WHEN tt.`创建周` = "48" THEN tt.任务送达 ELSE 0 END)),1) AS 第48周执行率,
 ROUND(100*SUM((CASE WHEN tt.`创建周` = "49" THEN tt.任务执行 ELSE 0 END))/SUM((CASE WHEN tt.`创建周` = "49" THEN tt.任务送达 ELSE 0 END)),1) AS 第49周执行率,
 ROUND(100*SUM((CASE WHEN tt.`创建周` = "50" THEN tt.任务执行 ELSE 0 END))/SUM((CASE WHEN tt.`创建周` = "50" THEN tt.任务送达 ELSE 0 END)),1) AS 第50周执行率,
 ROUND(100*SUM((CASE WHEN tt.`创建周` = "51" THEN tt.任务执行 ELSE 0 END))/SUM((CASE WHEN tt.`创建周` = "51" THEN tt.任务送达 ELSE 0 END)),1) AS 第51周执行率,
 ROUND(100*SUM((CASE WHEN tt.`创建周` = "52" THEN tt.任务执行 ELSE 0 END))/SUM((CASE WHEN tt.`创建周` = "52" THEN tt.任务送达 ELSE 0 END)),1) AS 第52周执行率
FROM
(SELECT
 tt.`区域`,
 tt.`部门（必填）`,
 tt.`职务`,
 tt.`创建人`,
 tt.`创建周`,
 COUNT(DISTINCT tt.`创建时间`) AS 任务创建次数,
 SUM(tt.`总通知人数`) AS 任务送达,
 SUM(tt.`已办理`) AS 任务执行
FROM
(SELECT
 MID(zz.`部门全路径`,6,2) AS 区域,
 zz.`部门（必填）`,
 tt.`创建时间`,
 WEEKOFYEAR(tt.`创建时间`) AS 创建周,
 tt.`创建人`,
 zz.`职务`,
 tt.`总通知人数`,
 tt.`已办理`
FROM
waiqin.`任务情况` tt
LEFT JOIN
 waiqin.`员工数据` zz
ON tt.`创建人` = zz.`姓名（必填）`)tt
GROUP BY
 tt.`区域`,
 tt.`部门（必填）`,
 tt.`职务`,
 tt.`创建人`,
 tt.`创建周`)tt
GROUP BY
 tt.`区域`,
 tt.`部门（必填）`,
 tt.`职务`,
 tt.`创建人`
ORDER BY
 tt.`区域` DESC,
 tt.`职务`,
 tt.`部门（必填）`;
-- 











