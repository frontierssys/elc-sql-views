CREATE view [dbo].[PMV_SALES_STORE_STAFF_DEMOGRAPHIC_WALKIN_V2] as
select
    'Walk-in' as CUSTOMER_TYPE,
    psssdv.*,
    a.TX_COUNT,
    a.ITEM_COUNT
from
    PCV_SALES_STORE_STAFF_DEMOGRAPHIC_WALKIN psssdv
inner join (
    select
        COMPANY_CODE, LOCATION_CODE, TX_DATE, STAFF_NO, DEMOGRAPHIC, count(*)as TX_COUNT, sum(ITEM_COUNT)as ITEM_COUNT
    from
        PCV_SALES_STORE_STAFF_DEMOGRAPHIC_TX_COUNT_WALKIN psssdtcv
    group by
        COMPANY_CODE, location_code, TX_DATE, STAFF_NO, DEMOGRAPHIC ) a on
    psssdv.COMPANY_CODE = a.COMPANY_CODE
    and psssdv.LOCATION_CODE = a.LOCATION_CODE
    and psssdv.TX_DATE = a.TX_DATE
    and psssdv.STAFF_NO = a.STAFF_NO
    and psssdv.DEMOGRAPHIC = a.DEMOGRAPHIC
