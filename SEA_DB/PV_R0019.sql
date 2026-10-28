CREATE   view [dbo].[PV_R0019] as
SELECT
    prs.*,
    --pi2.ITEM_DESC_1 as ITEM_DESCRIPTION
    ptip.CUR_RETAIL_PRICE as RETAIL_PRICE,
    prs.QTY * ptip.CUR_RETAIL_PRICE as TOTAL_VALUE
from
    PV_R0019_SUB prs
left join PV_TODAY_ITEM_PRICE ptip
    on prs.SKU_ID = ptip.SKU_ID_FK
where 1 = 1
