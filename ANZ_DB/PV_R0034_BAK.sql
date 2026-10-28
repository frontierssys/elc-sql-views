CREATE   VIEW [dbo].[PV_R0034_BAK] AS
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
    d.AS_OF_QTY as STOCK_ON_HAND
FROM PV_R0033 pr
outer apply (
    select
        *
    from
        checkBalanceByLocationByDateByBucket(pr.STORE_NUMBER , pr.TRANSACTION_DATE, 'GIFT' ) ) d
where
    1 = 1
    and pr.PRODUCT_SKU = d.SKU_10
    --	and pr.COMPANY_CODE = 'HKCM'
    --	and pr.TRANSACTION_DATE = '2021-01-13'
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
    d.AS_OF_QTY
