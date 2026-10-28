-- dbo.PV_R0018_DataExtract source

CREATE   view [dbo].[PV_R0018_DataExtract] as
select
    pr.*,
    d.BALANCE + sum(d.MVMT_QTY) as CLOSING_QUANTITY,
    (d.BALANCE + sum(d.MVMT_QTY)) * isnull(pr.SUGGESTED_RETAIL_PRICE , 0) as CLOSING_$_VALUE,
    d.BALANCE + sum(d.MVMT_QTY) - pr.SALES_QTY - pr.TRANSFER_OUT_QTY - pr.TRANSFER_IN_QTY - pr.RTW_QUANTITY - pr.RECEIVE_QTY - pr.ADJUSTMENT_QUANTITY - pr.RTW_QTY as OPENING_QUANTITY,
    (d.BALANCE + sum(d.MVMT_QTY) - pr.SALES_QTY - pr.TRANSFER_OUT_QTY - pr.TRANSFER_IN_QTY - pr.RTW_QUANTITY - pr.RECEIVE_QTY - pr.ADJUSTMENT_QUANTITY - pr.RTW_QTY) * isnull(pr.SUGGESTED_RETAIL_PRICE , 0) as OPENING_$_VALUE
from PV_R0018_NOINV pr
left join
    (
        select
            timbd.COMPANY_CODE ,
            timbd.LOCATION_CODE,
            timbd.BALANCE_TYPE as BUCKET_TYPE,
            timbd.SKU as SKU_10,
            timbd.OPEN_BALANCE_DT,
            timbd.MOVEMENT_DATE ,
            timbd.BALANCE,
            sum(timbd.MOVEMENT_QTY) as MVMT_QTY
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
            /*inner join PV_R0018_NOINV pr1 on pr1.COMPANY_CODE = timbd.COMPANY_CODE and pr1.LOCATION_ID	= timbd.LOCATION_CODE and pr1.SKU_10=timbd.SKU
            and pr1.INVENTORY_BUCKET= timbd.BALANCE_TYPE*/
        where 1 =1
        --and timbd.LOCATION_CODE = @location
        group by
            timbd.COMPANY_CODE ,
            timbd.LOCATION_CODE,
            timbd.BALANCE_TYPE ,
            timbd.SKU,
            timbd.OPEN_BALANCE_DT,
            timbd.BALANCE,timbd.MOVEMENT_DATE
    ) d
    on pr.COMPANY_CODE = d.COMPANY_CODE
    and pr.LOCATION_ID	= d.LOCATION_CODE
    and pr.SKU_10= d.SKU_10
    and pr.INVENTORY_BUCKET= d.BUCKET_TYPE
    and d.MOVEMENT_DATE<=CAST(pr.TX_DT as DATE)
    --where  pr.TX_DT=>'2021-05-01' and pr.TX_DT<='2021-05-31'
    --and pr.location_id='HKMC0011' and pr.sku_10='M0N9040000'
group by pr.COMPANY_CODE ,
    pr.STORE_TYPE,
    pr.STORE_LOCATION,
    pr.LOCATION_ID ,
    pr.STORE_NAME,
    pr.SKU_10,
    pr.SKU_6,
    pr.SKU_4,
    pr.PRODUCT_NAME,
    pr.UPC,
    pr.SUB_BRAND,
    pr.MAJOR_CATEGORY,
    pr.MAJOR_CATEGORY_CODE,
    pr.APPLICATION,
    pr.APPLICATION_CODE,
    pr.CATEGORY,
    pr.CATEGORY_CODE,
    pr.SUB_CATEGORY,
    pr.SUB_CATEGORY_CODE,
    pr.INVENTORY_HIERARCHY,
    pr.L1,
    pr.L2,
    pr.L3,
    pr.L4,
    pr.L5,
    pr.SUGGESTED_RETAIL_PRICE,
    pr.TX_DT,
    pr.INVENTORY_BUCKET ,
    pr.SALES_QTY,
    pr.TRANSFER_OUT_QTY,
    pr.TRANSFER_IN_QTY,
    pr.RTW_QUANTITY,
    pr.RECEIVE_QTY,
    pr.ADJUSTMENT_QUANTITY,
    pr.RTW_QTY,
    pr.STATUS,
    pr.REASON,
    pr.UOM,
    d.balance;
