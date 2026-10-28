-- dbo.PMV_SALES_DETAIL_STORE_TENDER source

CREATE      view [dbo].[PMV_SALES_DETAIL_STORE_TENDER_bak21062022]
AS
select
    psm.TX_DATE as TX_DATE,
    CAST(CAST(psm.TX_DT as time) as VARCHAR(8)) as TX_TIME,
    pc2.COMPANY_CODE as COMPANY_CODE,
    pc2.COMPANY_DESC as COMPANY_DESC,
    pst.STORE_TYPE_CODE as STORE_TYPE_CODE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.LOCATION_DESC,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_CODE as LOCATION_CODE,
    pl.LOCATION_DESC as STORE_NAME,
    psm.MEMO_NO as TRANSACTION_ID,
    psm.TX_DT as TRANSACTION_TIME,
    pt2.TENDER_CODE as TENDER_CODE,
    case
        when pt2.TENDER_NAME = 'CASH' then pt2.TENDER_NAME + '-' + pc.CCY_CODE
        else pt2.TENDER_NAME
    end as TENDER_NAME,
    sum(psmp.AMOUNT ) as AMOUNT,
    psm.POS_MEMO_NO as POS_TRANSACTION_ID,
    CASE
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='MAC' THEN 'MO'
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='HKG' THEN 'HK'
        ELSE LEFT(pl.COMPANY_CODE,2)
    END as ENTITY
from dbo.PT_SALES_MEMO_PAYMENT psmp
inner join dbo.PT_SALES_MEMO psm
    on psmp.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join dbo.PM_COMPANY pc2
    on pc2.COMPANY_CODE = psmp.COMPANY_CODE
inner join dbo.PM_TERMINAL pt
    on psm.TERMINAL_ID_FK = pt.TERMINAL_ID
inner join dbo.PM_LOCATION pl
    on pt.LOCATION_ID_FK = pl.LOCATION_ID
inner join dbo.PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
LEFT join dbo.PM_TENDER pt2
    on psmp.TENDER_ID_FK = pt2.TENDER_ID
LEFT join dbo.PM_CURRENCY pc
    on pt2.CURRENCY_ID_FK = pc.CURRENCY_ID
inner join dbo.PR_POS_REPORT_SUP pprs
    on 1 = 1
where psm.TX_DT < pprs.MV_DT
group by
    psm.TX_DATE ,
    CAST(CAST(psm.TX_DT as time) as VARCHAR(8)) ,
    pc2.COMPANY_CODE ,
    pc2.COMPANY_DESC ,
    pst.STORE_TYPE_CODE ,
    pst.STORE_TYPE_NAME ,
    pl.LOCATION_DESC,
    pl.CITY_TXT ,
    pl.LOCATION_CODE ,
    pl.LOCATION_DESC ,
    psm.MEMO_NO,
    psm.TX_DT,
    pt2.TENDER_CODE,
    CASE
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='MAC' THEN 'MO'
        WHEN RIGHT(pl.COUNTRY_ID_FK,3)='HKG' THEN 'HK'
        ELSE LEFT(pl.COMPANY_CODE,2)
    END ,
    --pt2.TENDER_NAME,
    case
        when pt2.TENDER_NAME = 'CASH' then pt2.TENDER_NAME + '-' + pc.CCY_CODE
        else pt2.TENDER_NAME
    end,
    psm.POS_MEMO_NO
    ;
