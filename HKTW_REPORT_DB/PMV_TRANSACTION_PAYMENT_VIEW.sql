CREATE   view [dbo].[PMV_TRANSACTION_PAYMENT_VIEW]
--WITH SCHEMABINDING
AS
select
    psm.SALES_MEMO_ID ,
    CONVERT(varchar(10), psm.TX_DT, 126) TX_date ,
    psm.MEMO_NO ,
    psm.VIP_NO ,
    psm.VIP_CLUSTER_ID_FK,
    psm.CRE_BY ,
    psm.COMPANY_CODE ,
    psm.LOCATION_ID_FK ,
    pl.LOCATION_CODE ,
    pl.LOCATION_NAME ,
    sum(isnull(psmp.AMOUNT, 0)) total_amt,
    pt.TENDER_CODE,
    pt.TENDER_NAME,
    pc.company_desc,
    pl.location_desc,
    pst.Store_type_name  ,
    count_big(*) C
from dbo.PT_SALES_MEMO psm,
    dbo.PM_LOCATION pl,
    dbo.PT_SALES_MEMO_PAYMENT psmp,
    dbo.PM_STORE_TYPE pst,
    dbo.PM_COMPANY pc ,
    dbo.PM_TENDER pt,
    dbo.PR_POS_REPORT_SUP pprs
where psmp.sales_memo_id_fk = psm.sales_memo_id
    and pl.LOCATION_ID = psm.LOCATION_ID_FK
    and psm.company_code = pc.company_code
    and pl.store_type_id_fk = pst.STORE_TYPE_ID
    and psmp.TENDER_ID_FK = pt.TENDER_ID
    and psm.TX_DT < pprs.MV_DT
group by
    psm.SALES_MEMO_ID ,
    CONVERT(varchar(10), psm.TX_DT, 126)  ,
    psm.MEMO_NO ,
    psm.VIP_NO ,
    psm.VIP_CLUSTER_ID_FK,
    psm.CRE_BY ,
    psm.COMPANY_CODE ,
    psm.LOCATION_ID_FK ,
    pl.LOCATION_CODE ,
    pl.LOCATION_NAME ,
    pt.TENDER_CODE,
    pt.TENDER_NAME,
    pc.company_desc,
    pl.location_desc,
    pst.Store_type_name
