CREATE   VIEW  PV_SKU_WITH_BUCKET as
select
    ps.COMPANY_CODE as COMPANY_CODE ,
    ps.SKU_ID as SKU_ID ,
    ps.SKU_CODE as SKU_10,
    LEFT(ps.SKU_CODE,9) as SKU_9,
    LEFT(ps.SKU_CODE, 6) as SKU_6,
    pi2.ITEM_CODE as SKU_4,
    isnull(ps.SKU_DESC , pi2.ITEM_DESC_1) as PRODUCT_NAME,
    --ptip.CUR_RETAIL_PRICE as RETAIL_PRICE,
    bk.BUCKET_TYPE
from PM_SKU ps
inner join PM_SKU_ATTR psa
    on ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
inner join PM_ITEM pi2
    on ps.ITEM_ID_FK = pi2.ITEM_ID
    --inner join PV_TODAY_ITEM_PRICE ptip
    --on ps.SKU_ID = ptip.SKU_ID_FK
CROSS join (
    select DISTINCT DISPLAY_VALUE as BUCKET_TYPE
    from PC_INVENTORY_LOV
    where lov_code = 'BalanceType') bk
