CREATE   VIEW PV_R8803 AS
SELECT
    COMPANY_CODE,
    BRAND_CODE,
    BRAND_DESC,
    LOCATION_CODE,
    STAFF_NO,
    FIRST_NAME,
    F_TX_DT,
    WEEK_NAME,
    TG_AMT,
    NET_LINE_AMT,
    Convert(decimal(18,2),
        (
            CASE
                WHEN TG_AMT = 0 AND NET_LINE_AMT<=0 THEN 0
                WHEN TG_AMT = 0 AND NET_LINE_AMT>0  THEN 100
                ELSE (NET_LINE_AMT/TG_AMT)*100
            END)
    ) DAILY_COMP_PCT,

    Convert(decimal(18,2),
        (
            CASE
                WHEN CUMULATIVE_TG_AMT = 0 AND CUMULATIVE_LINE_AMT<=0 THEN 0
                WHEN CUMULATIVE_TG_AMT = 0 AND CUMULATIVE_LINE_AMT>0  THEN 100
                ELSE (CUMULATIVE_LINE_AMT/CUMULATIVE_TG_AMT)*100
            END)
    ) CUMULATIVE_COMP_PCT,

    0 CUMULATIVE_ADD,

    PERSON_COUNT,

    SAL_QTY,
    Convert(decimal(18,2),
        (
            CASE
                WHEN PERSON_COUNT<=0 THEN 0
                ELSE NET_LINE_AMT/PERSON_COUNT
            END)
    ) CUST_UNIT_PRICE,

    Convert(decimal(18,2),
        (
            CASE
                WHEN PERSON_COUNT = 0 THEN 0
                ELSE ((SAL_QTY*1.0)/PERSON_COUNT)
            END)
    )  CUST_QTY,
    CUMULATIVE_TG_AMT,
    CUMULATIVE_LINE_AMT
FROM
    (
        select     top 100 percent
            bs.COMPANY_CODE,
            BRAND_CODE,
            BRAND_DESC,
            LOCATION_CODE,
            bs.STAFF_NO,
            staf.FIRST_NAME,
            F_TX_DT,
            WEEK_NAME,

            Convert(decimal(18,2),isnull(tg.TARGET_AMOUNT,0)) TG_AMT,
            Convert(decimal(18,2),SUM(isnull(tg.TARGET_AMOUNT,0)) OVER(
                PARTITION BY bs.COMPANY_CODE,BRAND_CODE,BRAND_DESC,LOCATION_CODE,bs.STAFF_NO,staf.FIRST_NAME
                ORDER BY BRAND_CODE,bs.STAFF_NO,F_TX_DT )) AS CUMULATIVE_TG_AMT,

            Convert(decimal(18,2),NET_LINE_AMT) NET_LINE_AMT,
            Convert(decimal(18,2),SUM(NET_LINE_AMT) OVER(
                PARTITION BY bs.COMPANY_CODE,BRAND_CODE,BRAND_DESC,LOCATION_CODE,bs.STAFF_NO,staf.FIRST_NAME
                ORDER BY F_TX_DT )) AS CUMULATIVE_LINE_AMT,

            PERSON_COUNT,
            SAL_QTY,
            Convert(decimal(18,2),(
                CASE
                    WHEN SAL_QTY=0 THEN  NET_LINE_AMT
                    ELSE NET_LINE_AMT/SAL_QTY
                END))  CUST_UNIT_PRICE
        from
            (
                select
                    memo.COMPANY_CODE,
                    brand.BRAND_CODE,
                    brand.BRAND_DESC,
                    loc.LOCATION_CODE,
                    loc.LOCATION_ID,
                    memo.STAFF_NO,
                    CONVERT(varchar(100), memo.TX_DT, 111) F_TX_DT,
                    datename(weekday, CONVERT(varchar(100), memo.TX_DT, 111))  WEEK_NAME,
                    count(memo.POS_MEMO_NO) PERSON_COUNT,
                    sum(itemh.QTY) SAL_QTY,
                    sum(itemh.NET_LINE_AMT) NET_LINE_AMT
                from PT_SALES_MEMO memo
                left join PM_LOCATION loc on memo.LOCATION_ID_FK = loc.LOCATION_ID and loc.COMPANY_CODE=memo.COMPANY_CODE
                left join PT_SALES_MEMO_ITEM_H itemh on memo.sales_memo_id=itemh.sales_memo_id_fk and itemh.COMPANY_CODE=memo.COMPANY_CODE
                left join PM_BRAND brand on itemh.brand_code=brand.BRAND_CODE and brand.COMPANY_CODE=brand.COMPANY_CODE
                left join PM_SKU sku on itemh.sku = sku.sku_code and sku.COMPANY_CODE=itemh.COMPANY_CODE
                left join PM_ITEM item on sku.ITEM_ID_FK = item.ITEM_ID and item.COMPANY_CODE=item.COMPANY_CODE
                group by memo.COMPANY_CODE,
                    brand.BRAND_CODE,
                    brand.BRAND_DESC,
                    loc.LOCATION_CODE,
                    loc.LOCATION_ID,
                    memo.STAFF_NO,
                    CONVERT(varchar(100), memo.TX_DT, 111)
            ) bs
        left join PM_STAFF staf on staf.STAFF_CODE=bs.STAFF_NO and staf.COMPANY_CODE=bs.COMPANY_CODE
        left join PM_SALES_TARGET tg on bs.LOCATION_ID = tg.LOCATION_ID_FK and bs.F_TX_DT = CONVERT(varchar(100),tg.DATE_FROM ,111) and
            tg.STAFF_NO=bs.STAFF_NO and  tg.SALES_TARGET_TYPE='DAILY' and tg.COMPANY_CODE=bs.COMPANY_CODE
        ORDER BY COMPANY_CODE,BRAND_CODE,BRAND_DESC, LOCATION_CODE,bs.STAFF_NO,F_TX_DT
    ) cust
