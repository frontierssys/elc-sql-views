-- CREATE   VIEW [dbo].[PV_COMPANY_LOCATION_DETAIL] AS
-- SELECT
-- 	pc.company_code AS 'COMPANY_CODE',
-- 	pc.COMPANY_DESC AS 'COMPANY_DESC',
-- 	pl.location_code,
-- 	pl.LOCATION_DESC,
-- 	pl.LOCATION_NAME,
-- 	pl.CITY_TXT AS 'Address',
-- 	pst.STORE_TYPE_CODE AS STORE_TYPE_NAME
-- FROM
-- 	PM_LOCATION pl
-- INNER JOIN PM_COMPANY pc ON
-- 	pl.COMPANY_CODE = pc.COMPANY_CODE
-- INNER JOIN PM_STORE_TYPE pst ON
-- 	pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID;
CREATE VIEW [dbo].[PV_CUSTOMER_PURCHASE_HISTORY]
--WITH SCHEMABINDING
AS
select
    psmih.SKU,
    concat(pi2.ITEM_DESC_1,' ',pi2.ITEM_DESC_2) item_desc,
    psm.company_code ,
    sum(isnull(psmih.DISP_LINE_NET_TOTAL,0))    AS Sales_Amount   ,
    psm.VIP_NO,
    psm.VIP_CLUSTER_ID_FK, sum(psmih.QTY) qty,
    count_big(*) c
from dbo.PT_SALES_MEMO psm,
    dbo.PT_SALES_MEMO_ITEM_H psmih,
    dbo.PM_SKU ps3 ,
    dbo.PM_ITEM pi2,
    dbo.PM_VIP_CLUSTER pvc,
    dbo.PM_VIP pv  ,
    dbo.PR_POS_REPORT_SUP pprs ,
    dbo.PM_SKU_ATTR psa
where pv.VIP_CLUSTER_ID_FK = pvc.VIP_CLUSTER_ID
    and pvc.VIP_CLUSTER_ID = psm.VIP_CLUSTER_ID_FK
    and psm.VIP_NO = pv.VIP_NO
    and psmih.SKU =ps3.SKU_CODE
    and ps3.ITEM_ID_FK = pi2.ITEM_ID
    and ps3.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
    and psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
    and psm.TX_DT >= pprs.MV_DT
    and psa.IH_L1 = '110'
group by psmih.SKU, concat(pi2.ITEM_DESC_1,' ',pi2.ITEM_DESC_2), psm.company_code , psm.VIP_NO, psm.VIP_CLUSTER_ID_FK
union
select sku, item_desc, company_code, sales_amount, vip_no, vip_cluster_id_fk ,qty , c
from dbo.PMV_CUSTOMER_PURCHASE_HISTORY pcph
