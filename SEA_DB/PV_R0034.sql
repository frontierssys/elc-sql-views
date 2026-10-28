CREATE   VIEW [dbo].[PV_R0034] AS
select
    pr.COMPANY_CODE ,
    pr.STORE_TYPE ,
    pr.STORE_LOCATION ,
    pr.STORE_NUMBER ,
    pr.STORE_NAME ,
    'GIFT' as GIFT_TYPE,
    pr.PRODUCT_SKU as MATERIAL_CODE,
    pr.PRODUCT_DESCRIPTION ,
    pr.TRANSACTION_DATE as TX_DATE,
    pr.TRANSACTION_DATE ,
    --pr.REDEEMED_QTY as REDEEMED_QTY ,
    --pr.POINTS_DEDUCTED as POINTS_REDEEMED
    --sb.AS_OF_QTY as STOCK_ON_HAND
    sum(pr.REDEEMED_QTY) as REDEEMED_QTY ,
    sum(pr.POINTS_DEDUCTED) as POINTS_REDEEMED,
    sb.AS_OF_QTY as STOCK_ON_HAND
FROM PV_R0033 pr
left join (
    select
        timbd.COMPANY_CODE ,
        timbd.LOCATION_CODE,
        timbd.BALANCE_TYPE ,
        timbd.SKU,
        timbd.OPEN_BALANCE_DT,
        timbd.BALANCE + sum(timbd.MOVEMENT_QTY) AS_OF_QTY
    from
        PV_INVENTORY_MOVEMENT_BY_DAY_V2 timbd
    inner join
        (
            select
                a.COMPANY_CODE  , a.LOCATION_CODE, a.BALANCE_TYPE , a.SKU, max(a.OPEN_BALANCE_DT) MAX_BALANCE_DT
            from
                PV_INVENTORY_MOVEMENT_BY_DAY_V2 a
            group by
                a.COMPANY_CODE  , a.LOCATION_CODE, a.BALANCE_TYPE , a.SKU
        ) inv
        on timbd.COMPANY_CODE = inv.COMPANY_CODE
        and timbd.LOCATION_CODE = inv.LOCATION_CODE
        and timbd.BALANCE_TYPE = inv.BALANCE_TYPE
        and timbd.SKU = inv.SKU
        and timbd.OPEN_BALANCE_DT = inv.MAX_BALANCE_DT
    where 1 =1 and timbd.BALANCE_TYPE ='GIFT'
    group by
        timbd.COMPANY_CODE ,
        timbd.LOCATION_CODE,
        timbd.BALANCE_TYPE ,
        timbd.SKU,
        timbd.OPEN_BALANCE_DT,
        timbd.BALANCE
) as sb
    ON pr.PRODUCT_SKU = sb.SKU
    and pr.COMPANY_CODE = sb.COMPANY_CODE
    and pr.STORE_NUMBER = sb.LOCATION_CODE
group by
    pr.COMPANY_CODE ,
    pr.STORE_TYPE ,
    pr.STORE_LOCATION ,
    pr.STORE_NUMBER ,
    pr.STORE_NAME ,
    pr.PRODUCT_SKU ,
    pr.PRODUCT_DESCRIPTION ,
    pr.TRANSACTION_DATE ,
    pr.TRANSACTION_DATE ,
    sb.AS_OF_QTY
