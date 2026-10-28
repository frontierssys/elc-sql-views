CREATE   VIEW  PV_R0018_bak as
--select
--pr.*,
--isnull(d.AS_OF_QTY,0)  as CLOSING_QUANTITY,
--isnull(d.AS_OF_QTY,0) * isnull(pr.SUGGESTED_RETAIL_PRICE ,0)  as CLOSING_$_VALUE,
--isnull(d.AS_OF_QTY,0) - pr.SALES_QTY - pr.TRANSFER_OUT_QTY - pr.TRANSFER_IN_QTY - pr.RTW_QUANTITY - pr.RECEIVE_QTY - pr.ADJUSTMENT_QUANTITY - pr.RTW_QTY as OPENING_QUANTITY,
--(isnull(d.AS_OF_QTY,0) - pr.SALES_QTY - pr.TRANSFER_OUT_QTY - pr.TRANSFER_IN_QTY - pr.RTW_QUANTITY - pr.RECEIVE_QTY - pr.ADJUSTMENT_QUANTITY - pr.RTW_QTY) * isnull(pr.SUGGESTED_RETAIL_PRICE ,0) as OPENING_$_VALUE
--from PV_R0018_NOINV pr
--outer apply checkBalanceR0018(pr.COMPANY_CODE , pr.LOCATION_ID , pr.SKU_10 , pr.TX_DT , pr.INVENTORY_BUCKET ) d
----where pr.LOCATION_ID = 'HKEL0042' and pr.TX_DT = '2021-01-07'
select
    pr.*,
    isnull(d.AS_OF_QTY, 0) as CLOSING_QUANTITY,
    isnull(d.AS_OF_QTY, 0) * isnull(pr.SUGGESTED_RETAIL_PRICE , 0) as CLOSING_$_VALUE,
    isnull(d.AS_OF_QTY, 0) - pr.SALES_QTY - pr.TRANSFER_OUT_QTY - pr.TRANSFER_IN_QTY - pr.RTW_QUANTITY - pr.RECEIVE_QTY - pr.ADJUSTMENT_QUANTITY - pr.RTW_QTY as OPENING_QUANTITY,
    (isnull(d.AS_OF_QTY, 0) - pr.SALES_QTY - pr.TRANSFER_OUT_QTY - pr.TRANSFER_IN_QTY - pr.RTW_QUANTITY - pr.RECEIVE_QTY - pr.ADJUSTMENT_QUANTITY - pr.RTW_QTY) * isnull(pr.SUGGESTED_RETAIL_PRICE , 0) as OPENING_$_VALUE
from
    PV_R0018_NOINV pr
outer apply (
    select
        *
    from
        checkBalanceByLocationByDate(pr.LOCATION_ID , pr.TX_DT ) ) d
where
    1 = 1
    and pr.SKU_10 = d.SKU_10
    AND pr.INVENTORY_BUCKET = d.BUCKET_TYPE
