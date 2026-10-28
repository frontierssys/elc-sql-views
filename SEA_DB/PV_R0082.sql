-- dbo.PV_R0082 source

CREATE   VIEW [dbo].[PV_R0082] AS
select
    memo.COMPANY_CODE,
    isnull(staff.STAFF_CODE, ' ') STAFF_CODE,
    isnull(staff.STAFF_CODE , ' ') STAFF_NO,
    isnull(pu.NAME, ' ') FIRST_NAME,
    isnull(' ', ' ') LAST_NAME,
    isnull(memo.COMPANY_CODE , ' ') BRAND_CODE,
    isnull(pc.COMPANY_DESC , ' ') BRAND_DESC,
    loc.LOCATION_CODE,
    psmiha.VIRTUAL_SET_PARENT_SKU as VIRTUAL_SET_PARENT_ITEM_CODE,
    pvss.REF_SKU_DESC  as VIRTUAL_SET_ITEM_DESC,
    psmiha.VIRTUAL_SET_PARENT_SKU as VIRTUAL_SET_PARENT_SKU,
    memo.TX_DATE as TX_DT,
    sum(itemh.QTY)/pvss.SET_QTY VIRTUAL_SET_QTY,
    sum(itemh.NET_LINE_AMT) NET_LINE_AMT
from
    PT_SALES_MEMO memo
inner join PM_SALES_MEMO_TYPE psmt ON memo.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join PM_COMPANY pc ON memo.COMPANY_CODE = pc.COMPANY_CODE
INNER JOIN PM_LOCATION loc ON memo.LOCATION_ID_FK = loc.LOCATION_ID 	AND loc.COMPANY_CODE = memo.COMPANY_CODE
INNER JOIN PT_SALES_MEMO_ITEM_H itemh ON memo.sales_memo_id = itemh.sales_memo_id_fk and itemh.COMPANY_CODE = memo.COMPANY_CODE
INNER JOIN dbo.PT_SALES_MEMO_ITEM_H_ATTR psmiha ON psmiha.SALES_MEMO_ITEM_H_ATTR_ID = itemh.SALES_MEMO_ITEM_H_ATTR_ID_FK  and psmiha.VIRTUAL_SET_PARENT_SKU is not NULL
LEFT JOIN dbo.PV_VIRTUAL_SET_SUMMARY pvss ON pvss.COMPANY_CODE = psmiha.COMPANY_CODE and pvss.SKU_CODE  = psmiha.VIRTUAL_SET_PARENT_SKU
LEFT JOIN PT_MEMO_ITEM_STAFF_SET pmiss ON itemh.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
LEFT JOIN PT_SALES_MEMO_ITEM_STAFF psmis ON psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
left join PM_SKU sku ON itemh.sku = sku.sku_code and sku.COMPANY_CODE = itemh.COMPANY_CODE
left join PM_ITEM item ON sku.ITEM_ID_FK = item.ITEM_ID and item.COMPANY_CODE = sku.COMPANY_CODE
inner join PM_USER pu ON psmis.STAFF_NO = pu.USER_CODE and psmis.COMPANY_CODE = pu.COMPANY_CODE
LEFT JOIN PM_STAFF staff ON pu.STAFF_ID_FK = staff.STAFF_ID
left join PT_SALES_MEMO_PAYMENT psmp ON psmp.SALES_MEMO_ID_FK = memo.SALES_MEMO_ID and psmp.DEPOSIT_NO is not null
where
    psmt.TYPE_CODE not in ('05', '06', '07', '09', '10', '11', '99', '08')
    and memo.MEMO_STATUS not in ('VOIDED')
    and memo.MEMO_KIND not in ('RESERVE', 'handoff')
    and memo.PICKUP_STATUS <> 'PICKUPED'
    and psmp.DEPOSIT_NO is null
    --and memo.COMPANY_CODE like 'TWEL%'
    --and memo.TX_DATE >='2022-06-08'
group by
    memo.COMPANY_CODE,
    staff.STAFF_CODE,
    pu.NAME,
    pc.COMPANY_DESC,
    loc.LOCATION_CODE,
    psmiha.VIRTUAL_SET_PARENT_SKU ,
    pvss.REF_SKU_DESC ,pvss.SET_QTY,
    psmiha.VIRTUAL_SET_PARENT_SKU,
    memo.TX_DATE
