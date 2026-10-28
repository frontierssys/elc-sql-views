CREATE   VIEW PV_R8805 as
select memo.COMPANY_CODE,
    isnull(staff.STAFF_CODE,' ') STAFF_CODE,
    isnull(memo.STAFF_NO,' ') STAFF_NO,
    isnull(staff.FIRST_NAME,' ') FIRST_NAME,
    isnull(staff.LAST_NAME,' ') LAST_NAME,
    isnull(brand.BRAND_CODE,' ') BRAND_CODE,
    isnull(brand.BRAND_DESC,' ') BRAND_DESC,
    loc.LOCATION_CODE,
    item.ITEM_CODE,
    item.ITEM_DESC_1 ITEM_DESC,
    itemh.SKU,
    --CONVERT(varchar(100), memo.TX_DT, 112) TX_DT,
    --CONVERT(varchar(100), memo.TX_DT, 111) TX_DT,
    memo.TX_DT,
    sum(itemh.QTY) SAL_QTY,
    sum(itemh.NET_LINE_AMT) NET_LINE_AMT
from PT_SALES_MEMO memo
left join PM_LOCATION loc on memo.LOCATION_ID_FK = loc.LOCATION_ID AND loc.COMPANY_CODE=memo.COMPANY_CODE
left join PT_SALES_MEMO_ITEM_H itemh on memo.sales_memo_id=itemh.sales_memo_id_fk and itemh.COMPANY_CODE=memo.COMPANY_CODE
left join PM_BRAND brand on itemh.brand_code=brand.BRAND_CODE and brand.COMPANY_CODE=itemh.COMPANY_CODE
left join PM_SKU sku on itemh.sku = sku.sku_code and sku.COMPANY_CODE=itemh.COMPANY_CODE
left join PM_ITEM item on sku.ITEM_ID_FK = item.ITEM_ID and item.COMPANY_CODE=sku.COMPANY_CODE
LEFT JOIN PM_STAFF staff on memo.STAFF_NO=staff.STAFF_CODE and memo.COMPANY_CODE=staff.COMPANY_CODE
group by memo.COMPANY_CODE,
    staff.STAFF_CODE,
    memo.STAFF_NO,
    staff.FIRST_NAME,
    staff.LAST_NAME,
    brand.BRAND_CODE,
    brand.BRAND_DESC,
    loc.LOCATION_CODE,
    item.ITEM_CODE,
    item.ITEM_DESC_1,
    itemh.sku,
    --CONVERT(varchar(100), memo.TX_DT, 111)
    memo.TX_DT
