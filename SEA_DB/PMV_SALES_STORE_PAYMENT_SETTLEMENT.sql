CREATE   view [dbo].[PMV_SALES_STORE_PAYMENT_SETTLEMENT] as
select
    pssp.COMPANY_CODE ,
    pssp.TX_DATE ,
    pssp.location_code ,
    pssp.TENDER_CODE ,
    pssp.TENDER_NAME ,
    pssp.EXPECTED_TOTAL ,
    psss.TOTAL_SETTLED
from PIV_SALES_STORE_PAYMENT pssp
LEFT join PIV_SALES_STORE_SETTLEMENT psss
    on pssp.COMPANY_CODE = psss.COMPANY_CODE
    and pssp.location_code = psss.location_code
    and pssp.TX_DATE = psss.TX_DATE
    and pssp.TENDER_CODE = psss.TENDER_CODE
union all
select
    pssp.COMPANY_CODE ,
    pssp.TX_DATE ,
    pssp.location_code ,
    pssp.TENDER_CODE ,
    pssp.TENDER_NAME ,
    pssp.EXPECTED_TOTAL ,
    psss.TOTAL_SETTLED
from PCV_SALES_STORE_PAYMENT pssp
LEFT join PCV_SALES_STORE_SETTLEMENT psss
    on pssp.COMPANY_CODE = psss.COMPANY_CODE
    and pssp.location_code = psss.location_code
    and pssp.TX_DATE = psss.TX_DATE
    and pssp.TENDER_CODE = psss.TENDER_CODE
