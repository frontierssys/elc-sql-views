create     view [dbo].[PMV_R0067_R0068]
--WITH SCHEMABINDING
AS
SELECT
    pb.BRAND_DESC,
    pi2.BUSINESS_UNIT_CODE as 'PRODUCT_CAT',
    CAST(psm.TX_DT as date) as 'TX_DATE',
    sum(abs(psmid.NORMAL_PRICE) * psmid.qty ) as 'SALES_GROSS_AMT',
    sum(abs(psmid.NET_AMT) * psmid.qty) as 'SALES_NET_AMT',
    sum(psmid.QTY) as 'QTY',
    COUNT(DISTINCT psm.MEMO_NO) as 'MEMO_COUNT'
From dbo.PT_SALES_MEMO psm
inner join dbo.PT_SALES_MEMO_ITEM_H psmih
    on psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
inner join dbo.PT_SALES_MEMO_ITEM_D psmid
    on psmih.SALES_MEMO_ITEM_H_ID = psmid.SALES_MEMO_ITEM_H_ID_FK
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join dbo.PM_COMPANY pc2
    on pc2.COMPANY_CODE = psm.COMPANY_CODE
inner join dbo.PM_SKU ps
    on psmih.sku = ps.SKU_CODE
inner join dbo.PM_SKU_ATTR psa
    on ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
    and psmih.COMPANY_CODE = ps.COMPANY_CODE
inner join dbo.PM_ITEM pi2
    on ps.ITEM_ID_FK = pi2.ITEM_ID
inner join dbo.PM_BRAND pb
    on pi2.BRAND_ID_FK = pb.BRAND_ID
    and psmih.COMPANY_CODE = pi2.COMPANY_CODE
inner join dbo.PR_POS_REPORT_SUP pprs
    on 1 = 1
where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'HANDOFF')
    and psm.TX_DT < pprs.MV_DT
    and abs(psmid.NORMAL_PRICE) > 0
    and psa.IH_L1 = '110'
GROUP BY
    pb.BRAND_DESC,
    pi2.BUSINESS_UNIT_CODE,
    CAST(psm.TX_DT as date)
