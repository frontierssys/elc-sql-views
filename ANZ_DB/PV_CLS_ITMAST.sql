CREATE   VIEW  PV_CLS_ITMAST as
select
    pb.BU_CODE as CAT,
    LEFT (ps.SKU_CODE, 6) as ITEM6,
    ps.SKU_CODE as ITEM10,
    --pi2.ITEM_DESC_1 as 'DESC',
    LEFT(REPLACE(pi2.ITEM_DESC_1, ',', ''),50) as 'DESC',
    ptip.CUR_RETAIL_PRICE as PRICE,
    ps.COMPANY_CODE as DIVISION,
    psa.IH_L2 as LINE_TYPE,
    LEFT (psa.LH_L1,2) as LEVEL_1,
    Left (psa.LH_L2,2) as LEVEL_2,
    Left (psa.LH_L3, 2) as LEVEL_3,
    pb2.BRAND_CODE as BRAND,
    'NIL' as PRODUCT_LINE,
    'NIL' as SUB_PRODUCT_LINE
from PM_SKU ps
inner join PM_ITEM pi2
    on ps.ITEM_ID_FK = pi2.ITEM_ID
inner join PM_SKU_ATTR psa
    on ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
inner join PM_BU pb
    on pi2.BUSINESS_UNIT_CODE = pb.BU_CODE
    and pi2.COMPANY_CODE = pb.COMPANY_CODE
inner join PM_BRAND pb2
    on pi2.BRAND_ID_FK = pb2.BRAND_ID
LEFT join PV_TODAY_ITEM_PRICE ptip
    on ps.SKU_ID = ptip.SKU_ID_FK
where psa.IS_VIRTUAL_SET = 'N'
