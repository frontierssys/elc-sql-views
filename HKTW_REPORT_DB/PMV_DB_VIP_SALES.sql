create     view [dbo].[PMV_DB_VIP_SALES]
--WITH SCHEMABINDING
as
SELECT
    psm.company_code as 'COMPANY_CODE',
    pv.VIP_ID ,
    pv.VIP_NO ,
    pl.location_code,
    pst.STORE_TYPE_CODE ,
    CAST(psm.TX_DT as date) as 'TX_DATE',
    --pcs.COUNTRY_RESIDENCE,
    --sum(psmih.NET_LINE_AMT) as 'SALES_AMT',
    --sum(psmih.QTY) as 'QTY',
    sum(psmih.NET_LINE_AMT) as 'SALES_AMT',
    sum(psmih.QTY) as 'QTY',
    COUNT(DISTINCT psm.MEMO_NO) as 'MEMO_COUNT'
From dbo.PT_SALES_MEMO psm
inner join dbo.PT_SALES_MEMO_ITEM_H psmih
    on psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
    --inner join dbo.PT_SALES_MEMO_ITEM_D psmid
    --on psmih.SALES_MEMO_ITEM_H_ID = psmid.SALES_MEMO_ITEM_H_ID_FK
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join dbo.PM_SKU ps
    on psmih.SKU = ps.SKU_CODE
inner join dbo.PM_SKU_ATTR psa
    on ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
    -----
inner join dbo.PM_ITEM pi2
    on ps.ITEM_ID_FK = pi2.ITEM_ID
    -----
inner join dbo.PM_COMPANY pc2
    on pc2.COMPANY_CODE = psm.COMPANY_CODE
inner join dbo.PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join dbo.PM_VIP pv
    on psm.VIP_NO = pv.VIP_NO
    and psm.COMPANY_CODE = pv.COMPANY_CODE
inner join dbo.PR_POS_REPORT_SUP pprs
    on 1 = 1
where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.VIP_NO is not NULL
    and psm.TX_DT < pprs.MV_DT
    --and psa.IH_L1 = '110'
    --and pst.STORE_TYPE_NAME <> 'ONLINE'
    and psa.IH_L1='110'
GROUP BY
    psm.company_code,
    pv.VIP_ID ,
    pv.VIP_NO ,
    pl.location_code,
    pst.STORE_TYPE_CODE ,
    CAST(psm.TX_DT as date)
