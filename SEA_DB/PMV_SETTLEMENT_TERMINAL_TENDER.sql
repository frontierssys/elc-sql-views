CREATE   view [dbo].[PMV_SETTLEMENT_TERMINAL_TENDER]
--WITH SCHEMABINDING
as
select
--pcs2.CASH_SETTLEMENT_ID,
    t.TX_DATE as TX_DATE,
    t.COMPANY_CODE as COMPANY_CODE,
    t.COMPANY_DESC as COMPANY_DESC,
    t.STORE_TYPE_CODE as STORE_TYPE_CODE,
    t.STORE_TYPE_CODE as STORE_TYPE_NAME,
    t.LOCATION_DESC,
    t.STORE_LOCATION as STORE_LOCATION,
    t.STORE_ID as STORE_ID,
    t.STORE_NAME as STORE_NAME,
    t.TENDER_CODE as TENDER_CODE,
    t.TENDER_NAME as TENDER_NAME,
    sum(pcs2.SYSTEM_AMT) as SYSTEM_AMT,
    sum(pcs2.USER_AMT) as DECLARED_AMT,
    sum(pcs2.VARIANCE_AMT) as VARIANCE_AMT,
    pcs2.VARIANCE_REASON as VARIANCE_REASON
from
    dbo.PT_CASH_SETTLEMENT pcs2
inner join
    (
        select
            distinct pcs.CASH_SETTLEMENT_ID as CASH_SETTLEMENT_ID,
            CAST(pc.TX_DATE as date) as TX_DATE,
            pc2.COMPANY_CODE as COMPANY_CODE,
            pc2.COMPANY_DESC as COMPANY_DESC,
            pst.STORE_TYPE_CODE as STORE_TYPE_CODE,
            pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
            pl.LOCATION_DESC,
            CONCAT( pl.ADDRESS1,pl.ADDRESS2, pl.ADDRESS3) as STORE_LOCATION,
            pl.LOCATION_CODE as STORE_ID,
            pl.LOCATION_DESC as STORE_NAME,
            pt2.TENDER_CODE as TENDER_CODE,
            pt2.TENDER_NAME as TENDER_NAME
        from dbo.PT_CASH_SETTLEMENT pcs
        inner join dbo.PL_CASH pc
            on pcs.CASH_SETTLEMENT_ID = pc.CASH_SETTLEMENT_ID_FK
        inner join dbo.PM_COMPANY pc2
            on pc2.COMPANY_CODE = pcs.COMPANY_CODE
        inner join dbo.PM_TERMINAL pt
            on pc.TERMINAL_ID_FK = pt.TERMINAL_ID
        inner join dbo.PM_LOCATION pl
            on pt.LOCATION_ID_FK = pl.LOCATION_ID
        inner join dbo.PM_STORE_TYPE pst
            on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
        inner join dbo.PM_TENDER pt2
            on pc.TENDER_ID_FK = pt2.TENDER_ID
        inner join dbo.PR_POS_REPORT_SUP pprs
            on 1 = 1
        where pc.TX_DATE < pprs.MV_DT
            AND PC.DOC_TYPE = 'sales'
    ) as t
    on pcs2.CASH_SETTLEMENT_ID = t.CASH_SETTLEMENT_ID
    --where t.COMPANY_CODE = 'HKTF'
    --and t.TX_DATE = '2020-09-08'
group by
--pcs2.CASH_SETTLEMENT_ID,
    t.TX_DATE,
    t.COMPANY_CODE ,
    t.COMPANY_DESC ,
    t.STORE_TYPE_CODE ,
    t.LOCATION_DESC,
    t.STORE_LOCATION ,
    t.STORE_ID ,
    t.STORE_NAME ,
    t.TENDER_CODE ,
    t.TENDER_NAME ,
    pcs2.VARIANCE_REASON
