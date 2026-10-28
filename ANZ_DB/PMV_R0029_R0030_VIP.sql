CREATE   VIEW  PMV_R0029_R0030_VIP
--WITH SCHEMABINDING
AS
SELECT
    psm.company_code as 'COMPANY_CODE',
    pc2.COMPANY_DESC as 'COMPANY_DESC',
    pl.location_code,
    pl.LOCATION_DESC,
    CONCAT( pl.ADDRESS1,
        pl.ADDRESS2,
        pl.ADDRESS3) as 'Address',
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pn.DEMOGRAPHIC as DEMOGRAPHIC,
    --pcs.COUNTRY_RESIDENCE,
    CAST(psm.TX_DT as date) as 'TX_DATE',
    --sum(psmih.NET_LINE_AMT) as 'SALES_AMT',
    --sum(psmih.QTY) as 'QTY',
    --sum(abs(psmid.NET_AMT) * psmid.qty) as 'SALES_AMT',
    --sum(psmid.QTY) as 'QTY',
    sum(psmih.NET_LINE_AMT ) as 'SALES_AMT',
    sum(psmih.qty)as 'QTY',
    COUNT(DISTINCT psm.MEMO_NO) as 'MEMO_COUNT'
From dbo.PT_SALES_MEMO psm
inner join dbo.PT_SALES_MEMO_ITEM_H psmih
    on psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
    --inner join dbo.PT_SALES_MEMO_ITEM_D psmid
    --on psmih.SALES_MEMO_ITEM_H_ID = psmid.SALES_MEMO_ITEM_H_ID_FK
inner join dbo.PM_SALES_MEMO_TYPE psmt
    on psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join dbo.PM_COMPANY pc2
    on pc2.COMPANY_CODE = psm.COMPANY_CODE
inner join dbo.PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join dbo.PM_VIP pv
    on psm.VIP_NO = pv.VIP_NO
    and psm.COMPANY_CODE = pv.COMPANY_CODE
inner join dbo.PM_SKU ps
    on psmih.SKU = ps.SKU_CODE
    and psmih.COMPANY_CODE = ps.COMPANY_CODE
inner join dbo.PM_SKU_ATTR psa
    on ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
inner join dbo.PM_CUSTOMER pc
    on pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
inner join dbo.PM_CUSTOMER_SECRET pcs
    on pc.CUSTOMER_ID = pcs.CUSTOMER_ID_FK
inner join dbo.PM_NATION pn
    on pcs.COUNTRY_RESIDENCE = pn.ISO3_CODE
    and pcs.COMPANY_CODE = pn.COMPANY_CODE
inner join dbo.PR_POS_REPORT_SUP pprs
    on 1 = 1
where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.VIP_NO is not NULL
    and psm.TX_DT < pprs.MV_DT
    and psa.IH_L1 = '110'
GROUP BY
    psm.company_code,
    pc2.COMPANY_DESC,
    pl.location_code,
    pl.LOCATION_DESC,
    pl.ADDRESS1,
    pl.ADDRESS2,
    pl.ADDRESS3,
    pst.STORE_TYPE_CODE,
    pn.DEMOGRAPHIC,
    --pcs.COUNTRY_RESIDENCE,
    CAST(psm.TX_DT as date)
