-- dbo.PV_R8804_BASE source

-- dbo.PV_R8804_BASE source
CREATE   VIEW PV_R8804_BASE_X AS
SELECT
    COMPANY_CODE,
    POS_URL,
    CLIENT_URL,
    BRAND_CODE,
    LOCATION_CODE,
    CONCAT(LOCATION_CODE, '-', LOCATION_DESC) AS LOCATION_DESC,
    CONVERT(varchar(100),
        DATEADD(YEAR,-1, F_TX_DT),
        111) lf,
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
    Convert(decimal(18, 2),
        (
            CASE
                WHEN CUMULATIVE_TG_AMT = 0
                    AND CUMULATIVE_LINE_AMT <= 0 THEN 0
                WHEN CUMULATIVE_TG_AMT = 0
                    AND CUMULATIVE_LINE_AMT>0 THEN 100
                ELSE (CUMULATIVE_LINE_AMT / CUMULATIVE_TG_AMT)* 100
            END) ) CUMULATIVE_COMP_PCT,
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
            top 100 percent COALESCE (tg.COMPANY_CODE,bs.COMPANY_CODE) COMPANY_CODE,
            COALESCE (tg.COMPANY_CODE,bs.COMPANY_CODE) BRAND_CODE,
            COALESCE (tg.COMPANY_DESC,bs.BRAND_DESC) BRAND_DESC,
            COALESCE (tg.TG_LOCATION_CODE,bs.LOCATION_CODE) LOCATION_CODE,
            COALESCE (tg.TG_LOCATION_DESC,bs.LOCATION_DESC) LOCATION_DESC,
            COALESCE (tg.TG_POS_URL,bs.POS_URL) AS POS_URL,
            COALESCE (tg.TG_CLIENT_URL,bs.CLIENT_URL) AS CLIENT_URL,
            COALESCE (tg.DATE_FROM,bs.F_TX_DT) F_TX_DT,
            datename(weekday,COALESCE (tg.DATE_FROM,bs.F_TX_DT)) WEEK_NAME,
            Convert(decimal(18, 2),isnull(tg.TARGET_AMOUNT, 0)) TG_AMT,
            0 AS CUMULATIVE_TG_AMT,
            Convert(decimal(18, 2),ISNULL(NET_LINE_AMT,0)) NET_LINE_AMT,
            0 AS CUMULATIVE_LINE_AMT,
            isnull(PERSON_COUNT,0) PERSON_COUNT,
            isnull(SAL_QTY, 0) SAL_QTY,
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
                    memo.COMPANY_CODE as BRAND_CODE, pc.COMPANY_DESC as BRAND_DESC, loc.LOCATION_CODE, loc.LOCATION_DESC, loc.LOCATION_ID, loc.POS_URL, loc.CLIENT_URL as CLIENT_URL,
                    --								 CONVERT(varchar(100), memo.TX_DT, 111) F_TX_DT,
                    memo.TX_DATE as F_TX_DT, datename(weekday,
                        memo.TX_DATE ) WEEK_NAME, count(distinct(
                            case
                                when memo.TXN_MODE <> 'IOU' then memo.POS_MEMO_NO
                            end)) PERSON_COUNT, sum(itemh.QTY) SAL_QTY, sum(itemh.NET_LINE_AMT) NET_LINE_AMT
                from
                    PT_SALES_MEMO memo
                inner join PM_COMPANY pc on
                    memo.COMPANY_CODE = pc.COMPANY_CODE
                inner join PM_SALES_MEMO_TYPE psmt on
                    memo.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
                left join PM_LOCATION loc on
                    memo.LOCATION_ID_FK = loc.LOCATION_ID
                left join PT_SALES_MEMO_ITEM_H itemh on
                    memo.sales_memo_id = itemh.sales_memo_id_fk
                left join PM_SKU sku on
                    itemh.COMPANY_CODE = sku.COMPANY_CODE
                    and itemh.sku = sku.sku_code
                left join PM_ITEM item on
                    sku.ITEM_ID_FK = item.ITEM_ID
                left join PT_SALES_MEMO_PAYMENT psmp on
                    psmp.SALES_MEMO_ID_FK = memo.SALES_MEMO_ID
                    and psmp.DEPOSIT_NO is not null
                where
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
                    and psmp.DEPOSIT_NO is null
                    and itemh.ORG_RETAIL_PRICE <> 0
                group by
                    memo.COMPANY_CODE,
                    -- pc.EXT_DIVISION_CODE,
                    pc.COMPANY_DESC, loc.LOCATION_CODE, loc.LOCATION_DESC, loc.LOCATION_ID, loc.POS_URL, loc.CLIENT_URL,
                    --									 CONVERT(varchar(100), memo.TX_DT, 111)
                    memo.TX_DATE ) bs
        FULL OUTER JOIN (
            select t.*,c.COMPANY_DESC,l.LOCATION_CODE as TG_LOCATION_CODE,l.LOCATION_DESC AS TG_LOCATION_DESC,l.POS_URL AS TG_POS_URL,l.CLIENT_URL as TG_CLIENT_URL
            from PM_SALES_TARGET t
            inner join PM_COMPANY c on t.COMPANY_CODE = c.COMPANY_CODE
            inner join PM_LOCATION l on l.COMPANY_CODE = t.COMPANY_CODE and t.LOCATION_ID_FK=l.LOCATION_ID
            WHERE t.SALES_TARGET_TYPE = 'DAILY' and t.STAFF_NO is null
        ) tg on
            bs.LOCATION_ID = tg.LOCATION_ID_FK
            and bs.F_TX_DT = tg.DATE_FROM
            and tg.SALES_TARGET_TYPE = 'DAILY'
            and STAFF_NO is null
        ORDER BY
            POS_URL, BRAND_CODE, BRAND_DESC, LOCATION_CODE, LOCATION_DESC, F_TX_DT ) cust;
