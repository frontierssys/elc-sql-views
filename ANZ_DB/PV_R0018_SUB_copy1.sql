CREATE   VIEW  [dbo].[PV_R0018_SUB_copy1] AS
select
    COMPANY_CODE ,
    LOCATION_ID ,
    MOVEMENT_DT ,
    SKU,
    BUCKET ,
    isnull(sum([SALES]), 0) as SALES_QTY,
    isnull(sum([TRANSFER_OUT]), 0) as TRANSFER_OUT_QTY,
    isnull(sum([TRANSFER_IN]), 0) as TRANSFER_IN_QTY,
    isnull(sum([RETURN]), 0) as RETURN_QTY,
    isnull(sum([ASN]), 0) as RECEIVE_QTY,
    isnull(sum([ADJUSTMENT]), 0) as ADJUSTMENT_QTY,
    isnull(sum([RTW]), 0) as RTW_QTY
    --[BUCKET_TRANSFER]
from
    (
        Select pimbd.COMPANY_CODE , pimbd.LOCATION_ID , pimbd.MOVEMENT_DT , pimbd.BUCKET ,pimbd.SKU, pimbd.ORDER_NUMBER , pimbd.TRANS_TYPE , pimbd.MOVEMENT_QTY
        from PMV_INVENTORY_MOVEMENT_BY_DAY pimbd
    ) d
PIVOT
    (
        max(MOVEMENT_QTY)
        for TRANS_TYPE in ([SALES], [TRANSFER_OUT], [TRANSFER_IN], [RETURN], [ASN], [ADJUSTMENT], [RTW])
    ) piv
group by
    COMPANY_CODE ,
    LOCATION_ID ,
    MOVEMENT_DT ,
    SKU,
    BUCKET
