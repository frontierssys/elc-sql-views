-- dbo.PV_R8801_BASE source

create     view PV_R8801_BASE as
select
    memo.COMPANY_CODE,
    isnull(brand.BRAND_CODE, ' ') BRAND_CODE,
    isnull(brand.BRAND_DESC, ' ') BRAND_DESC,
    loc.LOCATION_CODE,
    concat(loc.LOCATION_CODE , '-' , loc.LOCATION_DESC) as LOCATION_DESC,
    item.ITEM_CODE,
    item.ITEM_DESC_1 ITEM_DESC,
    itemh.SKU,
    --CONVERT(varchar(100), memo.TX_DT, 112) TX_DT,
    -- memo.TX_DT TX_DT,
    memo.TX_DATE TX_DT,
    sum(itemh.QTY) SAL_QTY,
    sum(itemh.NET_LINE_AMT) NET_LINE_AMT
from
    PT_SALES_MEMO memo
left join PM_LOCATION loc on
    memo.LOCATION_ID_FK = loc.LOCATION_ID
    and loc.COMPANY_CODE = memo.COMPANY_CODE
left join PT_SALES_MEMO_ITEM_H itemh on
    memo.sales_memo_id = itemh.sales_memo_id_fk
    and itemh.COMPANY_CODE = memo.COMPANY_CODE
left join PM_BRAND brand on
    itemh.brand_code = brand.BRAND_CODE
    and brand.COMPANY_CODE = itemh.COMPANY_CODE
left join PM_SKU sku on
    itemh.sku = sku.sku_code
    and sku.COMPANY_CODE = sku.COMPANY_CODE
left join PM_ITEM item on
    sku.ITEM_ID_FK = item.ITEM_ID
    and item.COMPANY_CODE = sku.COMPANY_CODE
inner join PM_SALES_MEMO_TYPE psmt on
    memo.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
left join PT_SALES_MEMO_PAYMENT psmp
    on psmp.SALES_MEMO_ID_FK = memo.SALES_MEMO_ID
    and psmp.DEPOSIT_NO is not null
where
    psmt.TYPE_CODE not in ('05', '06', '07', '09', '10', '11', '99', '08')
    and memo.MEMO_STATUS not in ('VOIDED')
    and memo.MEMO_KIND not in ('RESERVE', 'handoff')
    and memo.PICKUP_STATUS <> 'PICKUPED'
    and psmp.DEPOSIT_NO is null
group by
    memo.COMPANY_CODE,
    brand.BRAND_CODE,
    brand.BRAND_DESC,
    loc.LOCATION_CODE,
    loc.LOCATION_DESC,
    item.ITEM_CODE,
    item.ITEM_DESC_1,
    itemh.sku,
    --	memo.TX_DT
    memo.TX_DATE
