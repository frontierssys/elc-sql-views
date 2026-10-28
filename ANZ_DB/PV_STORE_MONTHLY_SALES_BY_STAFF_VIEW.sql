CREATE   VIEW PV_STORE_MONTHLY_SALES_BY_STAFF_VIEW
--WITH SCHEMABINDING
AS
select sum(isnull(psmih.DISP_LINE_NET_TOTAL,0.00)) Sales_Amount,  CONCAT(ps2.FIRST_NAME, ' ',ps2.LAST_NAME) Staff_Name, psmis.STAFF_NO,
    CONVERT(varchar(6), psm.TX_DT, 112) TX_MONTH , pl.LOCATION_CODE, psm.COMPANY_CODE,
    count_big(*) C
from dbo.PT_SALES_MEMO psm, dbo.PT_SALES_MEMO_ITEM_H psmih, dbo.PT_SALES_MEMO_ITEM_STAFF psmis, dbo.PM_STAFF ps2, dbo.PM_LOCATION pl , dbo.PR_POS_REPORT_SUP pprs
where pl.LOCATION_ID = psm.LOCATION_ID_FK
    and pl.COMPANY_CODE = psm.COMPANY_CODE
    and psmis.STAFF_NO = ps2.STAFF_CODE
    and psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
    and psmih.MEMO_ITEM_STAFF_SET_ID_FK = psmis.MEMO_ITEM_STAFF_SET_ID_FK
    and ps2.COMPANY_CODE = psm.COMPANY_CODE
    and psm.MEMO_STATUS = 'COMPLETED'
    and psm.TX_DT <  pprs.mv_dt
group by CONCAT(ps2.FIRST_NAME, ' ',ps2.LAST_NAME), psmis.STAFF_NO, CONVERT(varchar(6), psm.TX_DT, 112)   , pl.LOCATION_CODE, psm.COMPANY_CODE
