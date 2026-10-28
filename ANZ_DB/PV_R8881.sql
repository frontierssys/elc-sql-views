CREATE   VIEW PV_R8881 AS
select     top 100 percent
    bs.COMPANY_CODE,
    BRAND_CODE,
    BRAND_DESC,
    STORE_TYPE_CODE,
    STORE_TYPE_NAME,
    LOCATION_CODE,
    STORE_ADDRESS,
    LOCATION_NAME,
    STAFF_CODE,
    FIRST_NAME,
    --CITY_TXT,
    F_TX_DT,
    Convert(decimal(18,2),isnull(tg.TARGET_AMOUNT,0)) TG_AMT,
    Convert(decimal(18,2),NET_LINE_AMT) NET_LINE_AMT
from
    (
        select
            memo.COMPANY_CODE,
            brand.BRAND_CODE,
            brand.BRAND_DESC,
            loc.LOCATION_CODE,
            loc.LOCATION_ID,
            --loc.CITY_TXT,
            stype.STORE_TYPE_CODE,
            stype.STORE_TYPE_NAME,
            loc.ADDRESS1 STORE_ADDRESS,
            loc.location_name,
            staff.STAFF_CODE,
            staff.FIRST_NAME,
            CONVERT(varchar(100), memo.TX_DT, 111) F_TX_DT,
            datename(weekday, CONVERT(varchar(100), memo.TX_DT, 111))  WEEK_NAME,
            count(memo.POS_MEMO_NO) PERSON_COUNT,
            sum(itemh.QTY) SAL_QTY,
            sum(itemh.NET_LINE_AMT) NET_LINE_AMT
        from PT_SALES_MEMO memo
        left join PM_LOCATION loc on memo.LOCATION_ID_FK = loc.LOCATION_ID and loc.COMPANY_CODE=memo.COMPANY_CODE
        left join PM_STORE_TYPE stype on stype.STORE_TYPE_ID=loc.STORE_TYPE_ID_FK
        left join PT_SALES_MEMO_ITEM_H itemh on memo.sales_memo_id=itemh.sales_memo_id_fk and itemh.COMPANY_CODE=memo.COMPANY_CODE
        left join PM_BRAND brand on itemh.brand_code=brand.BRAND_CODE and brand.COMPANY_CODE=itemh.COMPANY_CODE
        left join PM_SKU sku on itemh.sku = sku.sku_code and sku.COMPANY_CODE=itemh.COMPANY_CODE
        left join PM_ITEM item on sku.ITEM_ID_FK = item.ITEM_ID and item.COMPANY_CODE=sku.COMPANY_CODE
        LEFT JOIN PM_STAFF staff on memo.CASHIER_CODE=staff.STAFF_CODE and memo.COMPANY_CODE=staff.COMPANY_CODE
        group by memo.COMPANY_CODE,
            brand.BRAND_CODE,
            brand.BRAND_DESC,
            loc.LOCATION_CODE,
            loc.LOCATION_ID,
            --loc.CITY_TXT,
            stype.STORE_TYPE_CODE,
            stype.STORE_TYPE_NAME,
            loc.ADDRESS1,
            loc.location_name,
            staff.FIRST_NAME,
            staff.STAFF_CODE,
            CONVERT(varchar(100), memo.TX_DT, 111)
    ) bs
left join PM_SALES_TARGET tg on bs.LOCATION_ID = tg.LOCATION_ID_FK and bs.F_TX_DT = CONVERT(varchar(100),tg.DATE_FROM ,111) and tg.SALES_TARGET_TYPE='DAILY'
    and tg.COMPANY_CODE=bs.COMPANY_CODE AND tg.STAFF_NO=bs.STAFF_CODE
ORDER BY BRAND_CODE,BRAND_DESC,STORE_TYPE_NAME, LOCATION_CODE,F_TX_DT
