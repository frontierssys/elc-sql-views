CREATE   VIEW PV_STORE_MONTHLY_SALES_BY_CAT_VIEW
--WITH SCHEMABINDING
AS
select sum(isnull(psmih.DISP_LINE_NET_TOTAL, 0.00)) Sales_Amount, pc.CLASS_DESC,  CONVERT(varchar(6), psm.TX_DT, 112) TX_MONTH , pl.LOCATION_CODE, psm.COMPANY_CODE, COUNT_BIG(*) c
from dbo.PT_SALES_MEMO psm, dbo.PT_SALES_MEMO_ITEM_H psmih, dbo.PM_SKU ps2, dbo.PM_ITEM pi2, dbo.PM_LOCATION pl, dbo.PM_CLASS pc, dbo.PR_POS_REPORT_SUP pprs
where  psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
    and psm.COMPANY_CODE = ps2.COMPANY_CODE
    and pl.COMPANY_CODE = psm.COMPANY_CODE
    and ps2.COMPANY_CODE = psm.COMPANY_CODE
    and pi2.COMPANY_CODE = psm.COMPANY_CODE
    and pl.LOCATION_ID = psm.LOCATION_ID_FK
    and ps2.ITEM_ID_FK = pi2.ITEM_ID
    and psmih.SKU = ps2.SKU_CODE
    and pc.CLASS_ID = pi2.CLASS_ID_FK
    and psm.MEMO_STATUS = 'COMPLETED'
    and  psm.TX_DT <  pprs.mv_dt
group by pc.CLASS_DESC,  CONVERT(varchar(6), psm.TX_DT, 112) , pl.LOCATION_CODE, psm.COMPANY_CODE
