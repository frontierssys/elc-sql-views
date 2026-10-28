-- dbo.PV_R8881 source

-- dbo.PV_R8881 source

CREATE   VIEW [dbo].[PV_R8881] AS
select
    top 100 percent tg.COMPANY_CODE COMPANY_CODE,
    tg.COMPANY_CODE BRAND_CODE,
    tg.COMPANY_DESC BRAND_DESC,
    TG_STORE_TYPE_CODE STORE_TYPE_CODE,
    TG_STORE_TYPE_NAME STORE_TYPE_NAME,
    tg.TG_LOCATION_CODE LOCATION_CODE,
    --tg.TG_LOCATION_CODE AS SAP_DOOR_CODE,
    Tg.SAP_CUSTOMER_CODE AS SAP_DOOR_CODE,
    --CONCAT(tg.TG_LOCATION_CODE, '-', tg.TG_LOCATION_DESC) AS LOCATION_DESC,
    tg.TG_LOCATION_CODE AS LOCATION_DESC,
    tg.TG_STORE_ADRESS AS STORE_ADDRESS,
    tg.TG_LOCATION_NAME AS LOCATION_NAME,
    tg.staff_no as STAFF_CODE,
    tg.TG_FIRST_NAME as FIRST_NAME,
    --CITY_TXT,
    -- CONVERT(varchar(100),tg.DATE_FROM ,111) as F_TX_DT,
    TG_TARGET_DATE F_TX_DT,
    Convert(decimal(18, 2), isnull(tg.TARGET_AMOUNT, 0)) TG_AMT,
    Convert(decimal(18, 2), isnull(NET_LINE_AMT, 0)) NET_LINE_AMT
from
    (
        select
            memo.COMPANY_CODE, pc.EXT_DIVISION_CODE as BRAND_CODE, pc.COMPANY_DESC as BRAND_DESC, loc.LOCATION_CODE, loc.LOCATION_DESC, loc.LOCATION_ID, loc.SAP_CUSTOMER_CODE ,
            --loc.CITY_TXT,
            stype.STORE_TYPE_CODE, stype.STORE_TYPE_NAME, loc.ADDRESS1 STORE_ADDRESS, loc.location_name, staff.STAFF_CODE, pu.NAME as FIRST_NAME, CONVERT(varchar(100), memo.TX_DT, 111) F_TX_DT, datename(weekday, CONVERT(varchar(100), memo.TX_DT, 111)) WEEK_NAME, count(
                case
                    when memo.TXN_MODE <> 'IOU' then memo.POS_MEMO_NO
                end) PERSON_COUNT,  sum(itemh.QTY) SAL_QTY, sum(itemh.NET_LINE_AMT) NET_LINE_AMT
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
        left join PM_SKU sku on
            itemh.sku = sku.sku_code
            and sku.COMPANY_CODE = itemh.COMPANY_CODE
        left join PM_ITEM item on
            sku.ITEM_ID_FK = item.ITEM_ID
            and item.COMPANY_CODE = sku.COMPANY_CODE
        left join PT_MEMO_ITEM_STAFF_SET pmiss
            on itemh.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
        left join PT_SALES_MEMO_ITEM_STAFF psmis
            on psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
        LEFT JOIN PM_USER pu on
            psmis.STAFF_NO = pu.USER_CODE
            and psmis.COMPANY_CODE = pu.COMPANY_CODE
        left join PM_STAFF staff on
            pu.STAFF_ID_FK = staff.STAFF_ID
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
        group by
            memo.COMPANY_CODE, pc.EXT_DIVISION_CODE, pc.COMPANY_DESC, loc.LOCATION_CODE, loc.LOCATION_DESC, loc.LOCATION_ID,loc.SAP_CUSTOMER_CODE ,
            --loc.CITY_TXT,
            stype.STORE_TYPE_CODE, stype.STORE_TYPE_NAME, loc.ADDRESS1, loc.location_name, pu.NAME, staff.STAFF_CODE, CONVERT(varchar(100), memo.TX_DT, 111) ) bs
right join (
    select
        t.*,
        --		CONVERT(varchar(100), t.DATE_FROM , 111) TG_TARGET_DATE,
        t.DATE_FROM TG_TARGET_DATE,
        c.COMPANY_DESC, l.LOCATION_CODE as TG_LOCATION_CODE, l.LOCATION_DESC AS TG_LOCATION_DESC, stype.STORE_TYPE_CODE as TG_STORE_TYPE_CODE, l.SAP_CUSTOMER_CODE as SAP_CUSTOMER_CODE, l.ADDRESS1 as TG_STORE_ADRESS, l.location_name as TG_LOCATION_NAME, pu.NAME as TG_FIRST_NAME, stype.STORE_TYPE_NAME as TG_STORE_TYPE_NAME
    from
        PM_SALES_TARGET t
    inner join PM_COMPANY c on
        t.COMPANY_CODE = c.COMPANY_CODE
    inner join PM_LOCATION l on
        l.COMPANY_CODE = t.COMPANY_CODE
        and t.LOCATION_ID_FK = l.LOCATION_ID
    inner join PM_STORE_TYPE stype on
        stype.STORE_TYPE_ID = l.STORE_TYPE_ID_FK
    inner join PM_STAFF staff on
        t.STAFF_NO = staff.STAFF_CODE
        and t.COMPANY_CODE = staff.COMPANY_CODE
    left join PM_USER pu on  pu.STAFF_ID_FK =staff.STAFF_ID
    WHERE
        t.SALES_TARGET_TYPE = 'DAILY'
        and t.STAFF_NO is not null ) tg on
    bs.LOCATION_ID = tg.LOCATION_ID_FK
    and bs.F_TX_DT = CONVERT(varchar(100), tg.DATE_FROM , 111)
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
