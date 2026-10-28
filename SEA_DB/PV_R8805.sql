-- dbo.PV_R8805 source

-- dbo.PV_R8805 source

-- dbo.PV_R8805_BA_CN_NAME source
CREATE   VIEW [dbo].[PV_R8805] AS
select
    memo.COMPANY_CODE,
    isnull(staff.STAFF_CODE, ' ') STAFF_CODE,
    isnull(staff.STAFF_CODE , ' ') STAFF_NO,
    isnull(pu.NAME, ' ') FIRST_NAME,
    isnull(' ', ' ') LAST_NAME,
    isnull(memo.COMPANY_CODE , ' ') BRAND_CODE,
    isnull(pc.COMPANY_DESC , ' ') BRAND_DESC,
    loc.LOCATION_CODE,
    itemh.SKU as ITEM_CODE,
    sku.SKU_DESC as ITEM_DESC,
    itemh.SKU,
    --CONVERT(varchar(100), memo.TX_DT, 112) TX_DT,
    --CONVERT(varchar(100), memo.TX_DT, 111) TX_DT,
    memo.TX_DATE as TX_DT,
    sum(itemh.QTY) SAL_QTY,
    sum(itemh.NET_LINE_AMT) NET_LINE_AMT
from
    PT_SALES_MEMO memo
inner join PM_SALES_MEMO_TYPE psmt on
    memo.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join PM_COMPANY pc on
    memo.COMPANY_CODE = pc.COMPANY_CODE
left join PM_LOCATION loc on
    memo.LOCATION_ID_FK = loc.LOCATION_ID
    AND loc.COMPANY_CODE = memo.COMPANY_CODE
left join PT_SALES_MEMO_ITEM_H itemh on
    memo.sales_memo_id = itemh.sales_memo_id_fk
    and itemh.COMPANY_CODE = memo.COMPANY_CODE
    --  left join PM_BRAND brand on itemh.brand_code=brand.BRAND_CODE and brand.COMPANY_CODE=itemh.COMPANY_CODE
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
    memo.COMPANY_CODE,
    staff.STAFF_CODE,
    --	memo.STAFF_NO,
    pu.NAME,
    --	staff.LAST_NAME,
    --         brand.BRAND_CODE,
    --			   brand.BRAND_DESC,
    pc.COMPANY_DESC,
    loc.LOCATION_CODE,
    itemh.SKU ,
    sku.SKU_DESC ,
    itemh.sku,
    --CONVERT(varchar(100), memo.TX_DT, 111)
    memo.TX_DATE
