-- dbo.PMV_SALES_STORE_SKU_DEMOGRAPHIC_WALKIN_V2 source

CREATE   view PMV_SALES_STORE_SKU_DEMOGRAPHIC_WALKIN_V2 as
select
    'Walk-in' as CUSTOMER_TYPE,
    psssdv.*,
    a.TX_COUNT,
    a.ITEM_COUNT,
    a.TX_AMT
from
    PXV_SALES_STORE_SKU_DEMOGRAPHIC_WALKIN psssdv
left join (
    select
        COMPANY_CODE, LOCATION_CODE, TX_DATE, SKU, DEMOGRAPHIC,
        SALE_OR_RETURN,
        count(*)as TX_COUNT, sum(ITEM_COUNT)as ITEM_COUNT, sum(psssdtcv.TX_AMOUNT ) as TX_AMT
    from
        PXV_SALES_STORE_SKU_DEMOGRAPHIC_TX_COUNT_WALKIN psssdtcv
    group by
        COMPANY_CODE, location_code, TX_DATE, SKU, DEMOGRAPHIC, SALE_OR_RETURN ) a on
    psssdv.COMPANY_CODE = a.COMPANY_CODE
    and psssdv.LOCATION_CODE = a.LOCATION_CODE
    and psssdv.TX_DATE = a.TX_DATE
    and psssdv.SKU = a.SKU
    and psssdv.DEMOGRAPHIC = a.DEMOGRAPHIC
    and psssdv.SALE_OR_RETURN = a.SALE_OR_RETURN
    AND psssdv.IS_REVENUE_ITEM = 'Y'
    --where
    --	psssdv.IS_REVENUE_ITEM = 'Y'
UNION ALL
select
    'Walk-in' as CUSTOMER_TYPE,
    psssdv.*,
    a.TX_COUNT,
    a.ITEM_COUNT,
    a.TX_AMT
from
    PCV_SALES_STORE_SKU_DEMOGRAPHIC_WALKIN psssdv
left join (
    select
        COMPANY_CODE, LOCATION_CODE, TX_DATE, SKU, DEMOGRAPHIC,
        SALE_OR_RETURN,
        count(*)as TX_COUNT, sum(ITEM_COUNT) as ITEM_COUNT, sum(psssdtcv.TX_AMOUNT ) as TX_AMT
    from
        PCV_SALES_STORE_SKU_DEMOGRAPHIC_TX_COUNT_WALKIN psssdtcv
    group by
        COMPANY_CODE, location_code, TX_DATE, SKU, DEMOGRAPHIC, SALE_OR_RETURN ) a on
    psssdv.COMPANY_CODE = a.COMPANY_CODE
    and psssdv.LOCATION_CODE = a.LOCATION_CODE
    and psssdv.TX_DATE = a.TX_DATE
    and psssdv.SKU = a.SKU
    and psssdv.DEMOGRAPHIC = a.DEMOGRAPHIC
    and psssdv.SALE_OR_RETURN = a.SALE_OR_RETURN
    AND psssdv.IS_REVENUE_ITEM = 'Y'
    --where
    --	psssdv.IS_REVENUE_ITEM = 'Y';
