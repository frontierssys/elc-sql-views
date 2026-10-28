create   view [dbo].[PV_R0057]
as
select
    prat.*,
    isnull(prvt.MEMO_COUNT, 0) as VOID_MEMO_COUNT,
    isnull(prvt.TOTAL_AMOUNT, 0) as VOID_AMOUNT
from PMV_R0057_ALL_TX prat
left join PMV_R0057_VOID_TX prvt
    on prvt.COMPANY_CODE = prat.COMPANY_CODE
    and prvt.STORE_ID = prat.STORE_ID
    and prvt.TX_DATE = prat.TX_DATE
where 1 = 1
