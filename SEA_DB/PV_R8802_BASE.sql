-- dbo.PV_R8802_BASE source

-- dbo.PV_R8802_BASE_bk20220728 source

-- dbo.PV_R8802_BASE source

CREATE   VIEW [dbo].[PV_R8802_BASE] AS
SELECT
    COMPANY_CODE,
    BRAND_CODE,
    LOCATION_CODE,
    concat(LOCATION_CODE, '-', LOCATION_DESC) as LOCATION_DESC,
    CONVERT(varchar(100),DATEADD(YEAR,-1, F_TX_DT),111) lf,
    F_TX_DT,
    WEEK_NAME,
    TG_AMT,
    NET_LINE_AMT,
    Convert(decimal(18, 2),
        (
            CASE
                WHEN TG_AMT = 0
                    AND NET_LINE_AMT <= 0 THEN 0
                WHEN TG_AMT = 0
                    AND NET_LINE_AMT>0 THEN 100
                ELSE (NET_LINE_AMT / TG_AMT)* 100
            END) ) DAILY_COMP_PCT,
    0 CUMULATIVE_COMP_PCT,
    0 CUMULATIVE_ADD,
    PERSON_COUNT,
    SAL_QTY,
    Convert(decimal(18, 2),
        (
            CASE
                WHEN PERSON_COUNT <= 0 THEN 0
                ELSE NET_LINE_AMT / PERSON_COUNT
            END) ) CUST_UNIT_PRICE,
    Convert(decimal(18, 2),
        (
            CASE
                WHEN PERSON_COUNT = 0 THEN 0
                ELSE ((SAL_QTY*1.0)/ PERSON_COUNT)
            END) ) CUST_QTY,
    CUMULATIVE_TG_AMT,
    CUMULATIVE_LINE_AMT
FROM
    (
        select
            top 100 percent tg.COMPANY_CODE COMPANY_CODE,
            tg.COMPANY_CODE BRAND_CODE,
            tg.COMPANY_DESC BRAND_DESC,
            tg.TG_LOCATION_CODE LOCATION_CODE,
            tg.TG_LOCATION_DESC LOCATION_DESC,
            tg.DATE_FROM F_TX_DT,
            datename(weekday,tg.DATE_FROM) WEEK_NAME,
            Convert(decimal(18, 2),isnull(tg.TARGET_AMOUNT, 0)) TG_AMT,
            0 AS CUMULATIVE_TG_AMT,
            Convert(decimal(18, 2),ISNULL(NET_LINE_AMT,0)) NET_LINE_AMT,
            0 AS CUMULATIVE_LINE_AMT,
            ISNULL(PERSON_COUNT, 0) PERSON_COUNT,
            ISNULL(SAL_QTY, 0) SAL_QTY,
            Convert(decimal(18, 2),
                (
                    CASE
                        WHEN SAL_QTY = 0 THEN NET_LINE_AMT
                        ELSE NET_LINE_AMT / SAL_QTY
                    END)) CUST_UNIT_PRICE
        from
            (
                select
                    memo.COMPANY_CODE,
                    --                 pc.EXT_DIVISION_CODE as BRAND_CODE,
                    memo.COMPANY_CODE as BRAND_CODE, pc.COMPANY_DESC as BRAND_DESC, loc.LOCATION_CODE, loc.LOCATION_ID, loc.LOCATION_DESC as LOCATION_DESC,
                    --CONVERT(varchar(100), memo.TX_DT, 111) F_TX_DT,
                    memo.TX_DATE as F_TX_DT, datename(weekday,
                        memo.TX_DATE) WEEK_NAME,
                        --			count(distinct memo.POS_MEMO_NO) PERSON_COUNT,
                    count(distinct(
                        case
                            when memo.TXN_MODE <> 'IOU' then memo.POS_MEMO_NO
                        end)) PERSON_COUNT,
                    sum(itemh.QTY) SAL_QTY, sum(itemh.NET_LINE_AMT) NET_LINE_AMT
                from
                    PT_SALES_MEMO memo
                inner join PM_COMPANY pc on
                    memo.COMPANY_CODE = pc.COMPANY_CODE
                inner join PM_SALES_MEMO_TYPE psmt on
                    memo.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
                left join PM_LOCATION loc on
                    memo.LOCATION_ID_FK = loc.LOCATION_ID
                    and loc.COMPANY_CODE = memo.COMPANY_CODE
                left join PT_SALES_MEMO_ITEM_H itemh on
                    memo.sales_memo_id = itemh.sales_memo_id_fk
                    and itemh.COMPANY_CODE = memo.COMPANY_CODE
                left join PM_SKU sku on
                    itemh.sku = sku.sku_code
                    and sku.COMPANY_CODE = itemh.COMPANY_CODE
                left join PM_ITEM item on
                    sku.ITEM_ID_FK = item.ITEM_ID
                    and item.COMPANY_CODE = sku.COMPANY_CODE
                left join PT_SALES_MEMO_PAYMENT psmp on
                    psmp.SALES_MEMO_ID_FK = memo.SALES_MEMO_ID
                    and psmp.DEPOSIT_NO is not null
                WHERE
                    psmt.TYPE_CODE not in ('05',
                        '06',
                        '07',
                        '09',
                        '10',
                        '11',
                        '99',
                        '08')
                    and memo.MEMO_STATUS not in ('VOIDED')
                    and memo.MEMO_KIND not in ('RESERVE',
                        'handoff')
                    and memo.PICKUP_STATUS <> 'PICKUPED'
                    and itemh.ORG_RETAIL_PRICE <> 0
                    and psmp.DEPOSIT_NO is null
                group by
                    memo.COMPANY_CODE,
                    --pc.EXT_DIVISION_CODE,
                    pc.COMPANY_DESC, loc.LOCATION_CODE, loc.LOCATION_DESC, loc.LOCATION_ID,
                    --									 CONVERT(varchar(100), memo.TX_DT, 111)
                    memo.TX_DATE ) bs
        right join (
            select t.*,c.COMPANY_DESC,l.LOCATION_CODE as TG_LOCATION_CODE,l.LOCATION_DESC AS TG_LOCATION_DESC
            from PM_SALES_TARGET t
            inner join PM_COMPANY c on t.COMPANY_CODE = c.COMPANY_CODE
            inner join PM_LOCATION l on l.COMPANY_CODE = t.COMPANY_CODE and t.LOCATION_ID_FK=l.LOCATION_ID
            where t.SALES_TARGET_TYPE = 'DAILY' and t.STAFF_NO is null

        ) tg on
            bs.LOCATION_ID = tg.LOCATION_ID_FK
            and bs.F_TX_DT = tg.DATE_FROM
            and tg.SALES_TARGET_TYPE = 'DAILY'
            and tg.STAFF_NO is null
        ORDER BY
            COMPANY_CODE, BRAND_CODE, BRAND_DESC, LOCATION_CODE, F_TX_DT ) cust
