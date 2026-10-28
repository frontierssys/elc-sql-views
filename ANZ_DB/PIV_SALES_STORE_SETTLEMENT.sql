CREATE   VIEW  [dbo].[PIV_SALES_STORE_SETTLEMENT]
--WITH SCHEMABINDING
AS
select
    pcs.COMPANY_CODE ,
    pl.location_code,
    CONVERT(varchar(10),
        pc.TX_DATE ,
        126) AS 'TX_DATE',
    pt2.TENDER_CODE ,
    pt2.TENDER_NAME ,
    sum(pcs.SYSTEM_AMT ) as EXPECTED_AMOUNT,
    sum(pcs.SETTLE_AMT ) as TOTAL_SETTLED,
    COUNT_BIG(*) AS RECORD_COUNT
from dbo.PT_CASH_SETTLEMENT pcs
inner join dbo.PL_CASH pc
    on pc.CASH_SETTLEMENT_ID_FK = pcs.CASH_SETTLEMENT_ID
inner join dbo.PM_TERMINAL pt
    on pc.TERMINAL_ID_FK = pt.TERMINAL_ID
inner join dbo.PM_LOCATION pl
    on pt.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_TENDER pt2
    on pcs.TENDER_CODE = pt2.TENDER_CODE
    and pcs.COMPANY_CODE = pt2.COMPANY_CODE
INNER JOIN dbo.PR_REPORT_DATES prd on
    CAST (pc.TX_DATE as date) = prd.REPORT_DATE
group by
    pcs.COMPANY_CODE ,
    pl.location_code,
    CONVERT(varchar(10),
        pc.TX_DATE ,
        126),
    pt2.TENDER_CODE ,
    pt2.TENDER_NAME
