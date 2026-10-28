CREATE   VIEW PV_R8881_TEST AS
select
    top 100 percent bs.COMPANY_CODE,
    BRAND_CODE,
    BRAND_DESC,
    STORE_TYPE_CODE,
    STORE_TYPE_NAME,
    LOCATION_CODE,
    SAP_CUSTOMER_CODE AS SAP_DOOR_CODE,
    CONCAT(LOCATION_CODE, '-', LOCATION_DESC) AS LOCATION_DESC,
    STORE_ADDRESS,
    LOCATION_NAME,
    STAFF_CODE,
    FIRST_NAME,
    --CITY_TXT,
    F_TX_DT,
    Convert(decimal(18, 2), isnull(tg.TARGET_AMOUNT, 0)) TG_AMT,
    Convert(decimal(18, 2), NET_LINE_AMT) NET_LINE_AMT
from
    (
        select
            memo.COMPANY_CODE,
            memo.COMPANY_CODE as BRAND_CODE,
            pc.COMPANY_DESC as BRAND_DESC,
            loc.LOCATION_CODE,
            loc.SAP_CUSTOMER_CODE ,
            loc.LOCATION_DESC,
            loc.LOCATION_ID,
            stype.STORE_TYPE_CODE,
            stype.STORE_TYPE_NAME,
            loc.ADDRESS1 STORE_ADDRESS,
            loc.location_name,
            staff.STAFF_CODE,
            staff.FIRST_NAME,
            memo.TX_DATE F_TX_DT,
            datename(weekday, CONVERT(varchar(100), memo.TX_DATE, 111)) WEEK_NAME,
            count(memo.POS_MEMO_NO) PERSON_COUNT,
            sum(itemh.QTY) SAL_QTY,
            sum(itemh.NET_LINE_AMT) NET_LINE_AMT
        from
            PT_SALES_MEMO memo
        inner join PM_COMPANY pc on
            memo.COMPANY_CODE = pc.COMPANY_CODE
        inner join PM_SALES_MEMO_TYPE psmt on
            memo.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
        left join PM_LOCATION loc on
            memo.LOCATION_ID_FK = loc.LOCATION_ID
            and loc.COMPANY_CODE = memo.COMPANY_CODE
        left join PM_STORE_TYPE stype on
            stype.STORE_TYPE_ID = loc.STORE_TYPE_ID_FK
        left join PT_SALES_MEMO_ITEM_H itemh on
            memo.sales_memo_id = itemh.sales_memo_id_fk
            and itemh.COMPANY_CODE = memo.COMPANY_CODE
            --left join PM_BRAND brand on itemh.brand_code=brand.BRAND_CODE and brand.COMPANY_CODE=itemh.COMPANY_CODE
        left join PT_MEMO_ITEM_STAFF_SET pmiss on
            itemh.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
        left join PT_SALES_MEMO_ITEM_STAFF psmis on
            psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
        left join PM_SKU sku on
            itemh.sku = sku.sku_code
            and sku.COMPANY_CODE = itemh.COMPANY_CODE
        left join PM_ITEM item on
            sku.ITEM_ID_FK = item.ITEM_ID
            and item.COMPANY_CODE = sku.COMPANY_CODE
        inner join PM_USER pu on
            psmis.STAFF_NO = pu.USER_CODE
            and psmis.COMPANY_CODE = pu.COMPANY_CODE
        LEFT JOIN PM_STAFF staff on
            pu.STAFF_ID_FK = staff.STAFF_ID
            --		memo.CASHIER_CODE = staff.STAFF_CODE
            --		and memo.COMPANY_CODE = staff.COMPANY_CODE
        left join PT_SALES_MEMO_PAYMENT psmp on
            psmp.SALES_MEMO_ID_FK = memo.SALES_MEMO_ID
            and psmp.DEPOSIT_NO is not null
        where
            psmt.TYPE_CODE not in ('05', '06', '07', '09', '10', '11', '99', '08')
            and memo.MEMO_STATUS not in ('VOIDED')
            and memo.MEMO_KIND not in ('RESERVE', 'handoff')
            and memo.PICKUP_STATUS <> 'PICKUPED'
            and itemh.ORG_RETAIL_PRICE <> 0
            and psmp.DEPOSIT_NO is null
            --		and memo.COMPANY_CODE = 'TWTF'
            --		and memo.TX_DATE >= '2021-11-01'
        group by
            memo.COMPANY_CODE,
            --  pc.EXT_DIVISION_CODE,
            pc.COMPANY_DESC, loc.LOCATION_CODE, loc.SAP_CUSTOMER_CODE , loc.LOCATION_DESC, loc.LOCATION_ID,
            --loc.CITY_TXT,
            stype.STORE_TYPE_CODE, stype.STORE_TYPE_NAME, loc.ADDRESS1, loc.location_name, staff.FIRST_NAME, staff.STAFF_CODE, memo.TX_DATE ) bs
left join PM_SALES_TARGET tg on
    bs.LOCATION_ID = tg.LOCATION_ID_FK
    and bs.F_TX_DT = tg.DATE_FROM
    and tg.SALES_TARGET_TYPE = 'DAILY'
    and tg.COMPANY_CODE = bs.COMPANY_CODE
    AND tg.STAFF_NO = bs.STAFF_CODE
ORDER BY
    BRAND_CODE,
    BRAND_DESC,
    STORE_TYPE_NAME,
    LOCATION_CODE,
    LOCATION_DESC,
    F_TX_DT
