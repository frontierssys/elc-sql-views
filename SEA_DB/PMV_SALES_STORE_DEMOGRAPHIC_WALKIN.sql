-- CREATE   VIEW [dbo].[PMV_SALES_STORE_DEMOGRAPHIC_VIP_V2] AS
-- SELECT
-- 	pssdvv.COMPANY_CODE AS COMPANY_CODE,
-- 	pcld.COMPANY_DESC ,
-- 	pssdvv.location_code ,
-- 	pcld.LOCATION_DESC ,
-- 	pcld.LOCATION_NAME ,
-- 	pcld.Address ,
-- 	pcld.STORE_TYPE_NAME,
-- 	pssdvv.IS_REVENUE_ITEM ,
-- 	pssdvv.TX_DATE AS TX_DATE,
-- 	isnull(pstd.TARGET_AMOUNT, 0) as TARGET_AMOUNT,
-- 	pssdvv.SALE_OR_RETURN ,
-- 	pssdvv.DEMOGRAPHIC ,
-- 	pssdvv.SALES_GROSS_AMT ,
-- 	pssdvv.SALES_NET_AMT ,
-- 	pssdvv.QTY ,
-- 	isnull(pssdtvv.MEMO_COUNT,
-- 	0) AS MEMO_COUNT
-- FROM
-- 	PCV_SALES_STORE_DEMOGRAPHIC_VIP pssdvv
-- LEFT JOIN PCV_SALES_STORE_DEMOGRAPHIC_TXCOUNT_VIP pssdtvv ON
-- 	pssdvv.COMPANY_CODE = pssdtvv.COMPANY_CODE
-- 	AND pssdvv.location_code = pssdtvv.location_code
-- 	AND pssdvv.TX_DATE = pssdtvv.TX_DATE
-- 	AND pssdvv.DEMOGRAPHIC = pssdtvv.DEMOGRAPHIC
-- 	AND pssdvv.SALE_OR_RETURN = pssdtvv.SALE_OR_RETURN
-- 	AND pssdvv.IS_REVENUE_ITEM = 'Y'
-- 	AND pssdtvv.IS_REVENUE_ITEM = 'Y'
-- LEFT JOIN PV_COMPANY_LOCATION_DETAIL pcld ON
-- 	pssdvv.COMPANY_CODE = pcld.COMPANY_CODE
-- 	AND pssdvv.location_code = pcld.location_code
-- left join PV_SALES_TARGET_DAILY pstd on
-- pstd.LOCATION_CODE = pssdvv.location_code
-- and pstd.COMPANY_CODE = pssdvv.company_code
-- and pstd.TX_DATE =pssdvv.tx_date
-- ;
CREATE   view [dbo].[PMV_SALES_STORE_DEMOGRAPHIC_WALKIN]
--WITH SCHEMABINDING
as
SELECT
    psm.company_code as 'COMPANY_CODE',
    pc2.COMPANY_DESC as 'COMPANY_DESC',
    pl.location_code,
    pl.LOCATION_DESC,
    CONCAT( pl.ADDRESS1,
        pl.ADDRESS2,
        pl.ADDRESS3) as 'Address',
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    ----
    --pi2.BUSINESS_UNIT_CODE as 'CLASS',
    --pi2.DEPT_CODE as 'DEPARTMENT',
    --pc3.CLASS_CODE as 'SUB_DEPARTMENT',
    --ps2.SUBCLASS_CODE 'DIVISION',
    ----
    CAST(psm.TX_DT as date) as 'TX_DATE',
    pn.DEMOGRAPHIC as 'DEMOGRAPHIC',
    CASE
        when psa.IH_L1='110' then 'Y'
        else 'N'
    end as 'IS_REVENUE_ITEM',
    --sum(psmih.NET_LINE_AMT) as 'SALES_AMT',
    --sum(psmih.QTY) as 'QTY',
    sum(psmih.CUR_RETAIL_PRICE * qty) as 'SALES_GROSS_AMT',
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
inner join dbo.PM_CLASS pc3
    on pi2.CLASS_ID_FK = pc3.CLASS_ID
inner join dbo.PM_SUBCLASS ps2
    on pi2.SUBCLASS_ID_FK = ps2.SUBCLASS_ID
    -----
inner join dbo.PM_COMPANY pc2
    on pc2.COMPANY_CODE = psm.COMPANY_CODE
inner join dbo.PM_LOCATION pl
    on psm.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join dbo.PM_NATION pn
    on psm.NATION_ID_FK = pn.NATION_ID
inner join dbo.PR_POS_REPORT_SUP pprs
    on 1 = 1
where psmt.TYPE_CODE not in ('03','04','05','06','07','09','10','11','99','08')
    and psm.MEMO_STATUS not in ('VOIDED')
    and psm.MEMO_KIND not in ('RESERVE', 'handoff')
    and psm.VIP_NO is NULL
    and psm.TX_DT < pprs.MV_DT
    --and psa.IH_L1 = '110'
    and pst.STORE_TYPE_NAME <> 'ONLINE'
GROUP BY
    psm.company_code,
    pc2.COMPANY_DESC,
    pl.location_code,
    pl.LOCATION_DESC,
    pl.ADDRESS1,
    pl.ADDRESS2,
    pl.ADDRESS3,
    pst.STORE_TYPE_CODE,
    --pi2.BUSINESS_UNIT_CODE,
    --pi2.DEPT_CODE,
    --pc3.CLASS_CODE ,
    --ps2.SUBCLASS_CODE ,
    CAST(psm.TX_DT as date),
    pn.DEMOGRAPHIC,
    CASE
        when psa.IH_L1='110' then 'Y'
        else 'N'
    end
