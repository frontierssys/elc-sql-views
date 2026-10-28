CREATE   VIEW [dbo].[PV_R0001_PAYEMENT_OVERVIEW] as
select
    pssps.TX_DATE ,
    pssps.COMPANY_CODE ,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pssps.location_code ,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    pssps.TENDER_NAME ,
    pssps.EXPECTED_TOTAL as EXPECTED_AMOUNT,
    pssps.TOTAL_SETTLED  as ACTUAL_AMOUNT,
    CASE
        when pssps.TOTAL_SETTLED is null then null
        ELSE pssps.TOTAL_SETTLED - pssps.EXPECTED_TOTAL
    END as VARIANCE_AMOUNT
from PMV_SALES_STORE_PAYMENT_SETTLEMENT pssps
inner join PM_LOCATION pl
    on pl.LOCATION_CODE = pssps.location_code
    and pl.COMPANY_CODE = pssps.COMPANY_CODE
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
