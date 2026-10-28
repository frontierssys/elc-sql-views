CREATE   view [dbo].[PV_R0014] as
select
    pstt.TX_DATE,
    pstt.COMPANY_CODE,
    pstt.COMPANY_DESC,
    pstt.STORE_TYPE_CODE,
    pstt.STORE_TYPE_NAME,
    pstt.LOCATION_DESC,
    pstt.STORE_LOCATION,
    pstt.STORE_ID,
    pstt.STORE_NAME,
    pstt.TENDER_CODE,
    pstt.TENDER_NAME,
    pstt.SYSTEM_AMT,
    pstt.DECLARED_AMT,
    pstt.VARIANCE_AMT,
    pstt.VARIANCE_REASON ,
    pr.REASON_DESC as VARIANCE_REASON_DESC
from PMV_SETTLEMENT_TERMINAL_TENDER pstt
left join PM_REASON pr on
    pr.COMPANY_CODE = pstt.COMPANY_CODE
    and pr.REASON_CODE = pstt.VARIANCE_REASON
Where 1 = 1
