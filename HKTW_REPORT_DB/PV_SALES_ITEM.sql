-- dbo.PV_SALES_ITEM source
CREATE   view [dbo].[PV_SALES_ITEM] as
SELECT
    psm.TX_DATE ,
    psm.SALES_MEMO_ID ,
    psm.VIP_NO,
    psm.LOCATION_ID_FK,
    psmih.SALES_MEMO_ITEM_H_ID as SALES_MEMO_ITEM_H_ID,
    psmih.SKU as 'MATERIAL_CODE_10',
    CASE
        WHEN psmt.SALES_MEMO_TYPE_ID in ('03', '04') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END AS 'SALEABLE',
    CASE
        WHEN psmt.TYPE_CODE = '09' and psmih.NET_LINE_AMT <= 0 then psmih.QTY * -1
        ELSE psmih.QTY
    end as QUANTITY
from dbo.PT_SALES_MEMO psm
inner join dbo.PT_SALES_MEMO_ITEM_H psmih
    on psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
    -------------------
inner join dbo.PM_SKU ps3
    on psmih.COMPANY_CODE = ps3.COMPANY_CODE
    and psmih.SKU = ps3.SKU_CODE
inner join dbo.PM_SKU_ATTR psa
    on ps3.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
    -----------------------
where psmt.TYPE_CODE not in ('05','06','07','10','11','99','08')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psmih.ORG_RETAIL_PRICE <>0;
