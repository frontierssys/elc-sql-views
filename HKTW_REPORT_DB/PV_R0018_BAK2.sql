CREATE   view [dbo].[PV_R0018_BAK2]
as
select
    pr.*,
    isnull(d.AS_OF_QTY, 0) as CLOSING_QUANTITY,
    isnull(d.AS_OF_QTY, 0) * isnull(pr.SUGGESTED_RETAIL_PRICE , 0) as CLOSING_$_VALUE,
    isnull(d.AS_OF_QTY, 0) - pr.SALES_QTY - pr.TRANSFER_OUT_QTY - pr.TRANSFER_IN_QTY - pr.RTW_QUANTITY - pr.RECEIVE_QTY - pr.ADJUSTMENT_QUANTITY - pr.RTW_QTY as OPENING_QUANTITY,
    (isnull(d.AS_OF_QTY, 0) - pr.SALES_QTY - pr.TRANSFER_OUT_QTY - pr.TRANSFER_IN_QTY - pr.RTW_QUANTITY - pr.RECEIVE_QTY - pr.ADJUSTMENT_QUANTITY - pr.RTW_QTY) * isnull(pr.SUGGESTED_RETAIL_PRICE , 0) as OPENING_$_VALUE
from PV_R0018_NOINV pr
left join
    (
        select
            timbd.COMPANY_CODE ,
            timbd.LOCATION_CODE,
            timbd.BALANCE_TYPE as BUCKET_TYPE,
            timbd.SKU as SKU_10,
            timbd.OPEN_BALANCE_DT,
            timbd.BALANCE + sum(timbd.MOVEMENT_QTY) as AS_OF_QTY
        from
            PV_INVENTORY_MOVEMENT_BY_DAY_V2 timbd
        inner join
            (
                select
                    a.COMPANY_CODE  , a.LOCATION_CODE, a.BALANCE_TYPE , a.SKU, max(a.OPEN_BALANCE_DT) MAX_BALANCE_DT
                from
                    PV_INVENTORY_MOVEMENT_BY_DAY_V2 a
                where a.OPEN_BALANCE_DT <= getdate()
                group by
                    a.COMPANY_CODE  , a.LOCATION_CODE, a.BALANCE_TYPE , a.SKU
            ) inv
            on timbd.COMPANY_CODE = inv.COMPANY_CODE
            and timbd.LOCATION_CODE = inv.LOCATION_CODE
            and timbd.BALANCE_TYPE = inv.BALANCE_TYPE
            and timbd.SKU = inv.SKU
            and timbd.OPEN_BALANCE_DT = inv.MAX_BALANCE_DT
        where 1 =1
        --and timbd.LOCATION_CODE = @location
        --and timbd.MOVEMENT_DATE <= @balanceDate
        group by
            timbd.COMPANY_CODE ,
            timbd.LOCATION_CODE,
            timbd.BALANCE_TYPE ,
            timbd.SKU,
            timbd.OPEN_BALANCE_DT,
            timbd.BALANCE
    ) d
    on pr.COMPANY_CODE = d.COMPANY_CODE
    and pr.LOCATION_ID	= d.LOCATION_CODE
    and pr.SKU_10= d.SKU_10
    and pr.INVENTORY_BUCKET= d.BUCKET_TYPE
