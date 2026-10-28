CREATE   VIEW PV_STORE_MONTHLY_SALES_VIEW
--WITH SCHEMABINDING
AS
select
    SUM(isnull(psm.TOTAL_NET_AMT , 0.00)) Sales_Amount ,
    CONVERT(varchar(6), psm.TX_DT, 112) TX_MONTH,
    psm.COMPANY_CODE, pl.LOCATION_CODE, psm.LOCATION_ID_FK, count_big(*) c
from dbo.PT_SALES_MEMO psm , dbo.PM_LOCATION pl , dbo.PR_POS_REPORT_SUP pprs
where pl.LOCATION_ID = psm.LOCATION_ID_FK
    and pl.COMPANY_CODE = psm.COMPANY_CODE
    and psm.MEMO_STATUS ='COMPLETED'
    and  psm.TX_DT <  pprs.mv_dt
group by   CONVERT(varchar(6), psm.TX_DT, 112)
    ,pl.LOCATION_CODE, psm.COMPANY_CODE, psm.LOCATION_ID_FK
