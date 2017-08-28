-- 用于删除钻展数据中符合要求的原始数据,该流程一般不可逆，慎重使用
DELETE
FROM
 mkt_tbk_data
WHERE
 DATE_FORMAT(确认收货时间,"%y-%m-%d") BETWEEN "17-08-13" AND "17-08-20";
