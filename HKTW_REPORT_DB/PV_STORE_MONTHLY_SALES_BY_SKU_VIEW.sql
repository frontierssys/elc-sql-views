--PV_STORE_MONTHLY_SALES_BY_SKU_VIEW


CREATE VIEW [dbo].[PV_STORE_MONTHLY_SALES_BY_SKU_VIEW]
WITH SCHEMABINDING
AS
select   psmih.SKU, pi2.ITEM_DESC_1, pi2.ITEM_DESC_2, Sum(isnull(psmih.QTY,0.00)) QTY, sum(isnull(psmih.DISP_LINE_NET_TOTAL,0.00)) Sales_Amount  , CONVERT(varchar(6), psm.TX_DT, 112) TX_MONTH , pl.LOCATION_CODE, psm.COMPANY_CODE, COUNT_BIG(*) c
from dbo.PT_SALES_MEMO psm, dbo.PT_SALES_MEMO_ITEM_H psmih, dbo.PM_SKU ps3 , dbo.PM_ITEM pi2 , dbo.PM_LOCATION pl , dbo.PM_ITEM_ATTR pia, dbo.PR_POS_REPORT_SUP pprs
where psmih.SKU =ps3.SKU_CODE
    and ps3.ITEM_ID_FK = pi2.ITEM_ID
    and psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
    and pl.LOCATION_ID = psm.LOCATION_ID_FK
    and pl.COMPANY_CODE = psm.COMPANY_CODE
    and psm.COMPANY_CODE = pi2.COMPANY_CODE
    and psm.COMPANY_CODE = ps3.COMPANY_CODE
    and pia.ITEM_ATTR_ID = pi2.ITEM_ATTR_ID_FK
    and psm.MEMO_STATUS = 'COMPLETED'
    and pia.IS_PLASTIC_BAG = 'N'
    and  psm.TX_DT <  pprs.mv_dt
group by psmih.SKU, pi2.ITEM_DESC_1, pi2.ITEM_DESC_2, CONVERT(varchar(6), psm.TX_DT, 112) , pl.LOCATION_CODE, psm.COMPANY_CODE
