DROP TABLE 
IF EXISTS 扫码日期城市;
CREATE TABLE 扫码日期城市 AS
SELECT
tt.`扫码年`,
tt.`扫码月`,
tt.扫码省,
tt.扫码城市,
tt.`手机人次`,
tt.手机人数,
tt.`产品类型`,
tt.`销量规格`
FROM
(
(SELECT
 DATE_FORMAT(tt.`扫码时间`,"%Y") AS 扫码年,
 DATE_FORMAT(tt.`扫码时间`,"%m") AS  扫码月,
 tt.`扫码位置_省` AS 扫码省,
 tt.`扫码位置_城市` AS 扫码城市,
 COUNT(DISTINCT tt.`手机号码`) AS 手机人数,
 COUNT(tt.`手机号码`) AS 手机人次,
 "全国A" AS 产品类型,
 "小包" AS 销量规格
FROM
 tag_text.`A产品小包扫码流水` tt
GROUP BY
 扫码年,
 扫码月,
 扫码省,
 扫码城市
ORDER BY
 扫码省,
 扫码城市,
 扫码年,
 扫码月,
 手机人次 DESC)
UNION
(SELECT
 DATE_FORMAT(tt.`扫码时间`,"%Y") AS 扫码年,
 DATE_FORMAT(tt.`扫码时间`,"%m") AS 扫码月,
 tt.`扫码位置_省` AS 扫码省,
 tt.`扫码位置_城市` AS 扫码城市,
 COUNT(DISTINCT tt.`手机号码`) AS 手机人数,
 COUNT(tt.`手机号码`) AS 手机人次,
 "全国A" AS 产品类型,
 "条盒" AS 销量规格
FROM
 tag_text.`A产品条盒扫码流水` tt
GROUP BY
 扫码年,
 扫码月,
 扫码省,
 扫码城市
ORDER BY
 扫码省,
 扫码城市,
 扫码年,
 扫码月,
 手机人次 DESC)
UNION
(SELECT
 DATE_FORMAT(tt.`扫码时间`,"%Y") AS 扫码年,
 DATE_FORMAT(tt.`扫码时间`,"%m") AS 扫码月,
 tt.`扫码位置_省` AS 扫码省,
 tt.`扫码位置_城市` AS 扫码城市,
 COUNT(DISTINCT tt.`手机号码`) AS 手机人数,
 COUNT(tt.`手机号码`) AS 手机人次,
 "重庆A" AS 产品类型,
 "小包" AS 销量规格
FROM
 tag_text.`A产品重庆版小包扫码流水` tt
GROUP BY
 扫码年,
 扫码月,
 扫码省,
 扫码城市
ORDER BY
 扫码省,
 扫码城市,
 扫码年,
 扫码月,
 手机人次 DESC)
UNION
(SELECT
 DATE_FORMAT(tt.`扫码时间`,"%Y") AS 扫码年,
 DATE_FORMAT(tt.`扫码时间`,"%m") AS 扫码月,
 tt.`扫码位置_省` AS 扫码省,
 tt.`扫码位置_城市` AS 扫码城市,
 COUNT(DISTINCT tt.`手机号码`) AS 手机人数,
 COUNT(tt.`手机号码`) AS 手机人次,
 "重庆A" AS 产品类型,
 "条盒" AS 销量规格
FROM
 tag_text.`A产品重庆版条盒扫码流水` tt
GROUP BY
 扫码年,
 扫码月,
 扫码省,
 扫码城市
ORDER BY
 扫码省,
 扫码城市,
 扫码年,
 扫码月,
 手机人次 DESC)
)tt;



SELECT
 tt.`扫码年`,
 tt.`扫码月`,
 tt.`扫码省`,
 tt.`扫码城市`,
 tt.全国A小包数_人数,
 tt.全国A条盒数_人数,
 tt.重庆A小包数_人数,
 tt.重庆A条盒数_人数,
 tt.全国A小包数_人次,
 tt.全国A条盒数_人次,
 tt.重庆A小包数_人次,
 tt.重庆A条盒数_人次,
 zz.全国A小包数,
 zz.全国B小包数,
 zz.全国A户数数,
 zz.全国B户数数,
 yy.`活动开始日期`
FROM
(SELECT
 tt.`扫码年`,
 tt.`扫码月`,
 tt.`扫码省`,
 tt.`扫码城市`,
 SUM(CASE WHEN tt.`产品类型`="全国A" AND tt.`销量规格`= "小包" THEN tt.`手机人数` ELSE 0 END) AS 全国A小包数_人数,
 SUM(CASE WHEN tt.`产品类型`="全国A" AND tt.`销量规格`= "条盒" THEN tt.`手机人数` ELSE 0 END) AS 全国A条盒数_人数,
 SUM(CASE WHEN tt.`产品类型`="重庆A" AND tt.`销量规格`= "小包" THEN tt.`手机人数` ELSE 0 END) AS 重庆A小包数_人数,
 SUM(CASE WHEN tt.`产品类型`="重庆A" AND tt.`销量规格`= "条盒" THEN tt.`手机人数` ELSE 0 END) AS 重庆A条盒数_人数,
 SUM(CASE WHEN tt.`产品类型`="全国A" AND tt.`销量规格`= "小包" THEN tt.`手机人次` ELSE 0 END) AS 全国A小包数_人次,
 SUM(CASE WHEN tt.`产品类型`="全国A" AND tt.`销量规格`= "条盒" THEN tt.`手机人次` ELSE 0 END) AS 全国A条盒数_人次,
 SUM(CASE WHEN tt.`产品类型`="重庆A" AND tt.`销量规格`= "小包" THEN tt.`手机人次` ELSE 0 END) AS 重庆A小包数_人次,
 SUM(CASE WHEN tt.`产品类型`="重庆A" AND tt.`销量规格`= "条盒" THEN tt.`手机人次` ELSE 0 END) AS 重庆A条盒数_人次
FROM
tag_text.`扫码日期城市` tt
GROUP BY
 tt.`扫码年`,
 tt.`扫码月`,
 tt.`扫码省`,
 tt.`扫码城市`)tt
LEFT JOIN
(SELECT
 zz.`年份`,
 zz.`月份`,
 zz.`省份`,
 zz.`城市`,
 SUM(CASE WHEN zz.`产品类型`="A" THEN zz.`小包数` ELSE 0 END) AS 全国A小包数,
 SUM(CASE WHEN zz.`产品类型`="B" THEN zz.`小包数` ELSE 0 END) AS 全国B小包数,
 SUM(CASE WHEN zz.`产品类型`="A" THEN zz.`累计户数` ELSE 0 END) AS 全国A户数数,
 SUM(CASE WHEN zz.`产品类型`="B" THEN zz.`累计户数` ELSE 0 END) AS 全国B户数数
 FROM
 tag_text.`AB产品销量数据分月分城市`zz
 GROUP BY
 zz.`年份`,
 zz.`月份`,
 zz.`省份`,
 zz.`城市`
)zz
ON CONCAT(tt.`扫码年`,tt.`扫码月`,tt.`扫码省`,tt.`扫码城市`)=CONCAT(zz.`年份`,zz.`月份`,zz.`省份`,zz.`城市`)
LEFT JOIN
tag_text.`活动开始时间` yy
ON CONCAT(tt.`扫码省`,tt.`扫码城市`)=CONCAT(yy.`省份`,yy.`城市`)
ORDER BY
 tt.`扫码省`,
 tt.`扫码城市`;






SELECT
 tt.`奖品`,
 tt.`奖品价值`,
 tt.`奖品类型`,
 COUNT(DISTINCT tt.`手机号码`) AS 手机人数,
 COUNT(tt.`手机号码`) AS 手机人次
FROM
 tag_text.`A产品小包扫码流水` tt
GROUP BY
 tt.`奖品`,
 tt.`奖品价值`,
 tt.`奖品类型`;


