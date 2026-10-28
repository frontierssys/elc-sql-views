CREATE   view [dbo].[PMV_SALES_STORE_CASHIER_SKU_DEMOGRAPHIC_WALKIN_V2] as
select
    'Walk-in' as CUSTOMER_TYPE,
    psssdv.*,
    a.TX_COUNT,
    a.ITEM_COUNT,
    a.TX_AMT
from
    PCV_SALES_STORE_CASHIER_SKU_DEMOGRAPHIC_WALKIN psssdv
inner join (
    select
        COMPANY_CODE, LOCATION_CODE, TX_DATE, STAFF_NO, SKU, DEMOGRAPHIC, count(*)as TX_COUNT, sum(ITEM_COUNT)as ITEM_COUNT, sum(psssdtcv.TX_AMOUNT ) as TX_AMT
    from
        PCV_SALES_STORE_CASHIER_SKU_DEMOGRAPHIC_TX_COUNT_WALKIN psssdtcv
    where psssdtcv.IS_REVENUE_ITEM = 'Y'
    group by
        COMPANY_CODE, location_code, TX_DATE, STAFF_NO, SKU, DEMOGRAPHIC ) a on
    psssdv.COMPANY_CODE = a.COMPANY_CODE
    and psssdv.LOCATION_CODE = a.LOCATION_CODE
    and psssdv.TX_DATE = a.TX_DATE
    and psssdv.STAFF_NO = a.STAFF_NO
    and psssdv.SKU = a.SKU
    and psssdv.DEMOGRAPHIC = a.DEMOGRAPHIC
    --where
    --	psssdv.IS_REVENUE_ITEM = 'Y'
