CREATE   view [dbo].[PV_TRANSACTION_LINE_VIEW]
--WITH SCHEMABINDING
AS
select
    psmih.sales_memo_item_h_id,
    psm.SALES_MEMO_ID ,
    CONVERT(varchar(10),
        psm.TX_DT,
        126) TX_dt ,
    psm.MEMO_NO ,
    psm.VIP_NO ,
    psm.CRE_BY ,
    psmih.DISP_LINE_NET_PRICE,
    psmih.DISP_LINE_NET_TOTAL ,
    psmih.QTY ,
    psmih.LINE_DISC_AMT ,
    psmih.DISP_LINE_DISCOUNT_RATE ,
    psm.COMPANY_CODE ,
    pcomp.COMPANY_DESC,
    psm.LOCATION_ID_FK ,
    pl.LOCATION_CODE ,
    pl.LOCATION_NAME ,
    psmih.CUR_RETAIL_PRICE ,
    pn.CODE,
    psmt.TYPE_DESC,
    pst.Store_type_name,
    pl.location_desc,
    pterm.TERMINAL_NO,
    psm.vip_cluster_id_fk,
    CONVERT(varchar(10),
        psm.TX_DT,
        108) tx_time,
    psm.AUTH_BY,
    psmt.TYPE_CODE ,
    psm.MEMO_STATUS,
    pmiss.MEMO_ITEM_STAFF_SET_ID,
    psmih.sku
from
    dbo.PT_SALES_MEMO psm,
    dbo.PT_SALES_MEMO_ITEM_H psmih,
    dbo.PT_MEMO_ITEM_STAFF_SET pmiss,
    dbo.PM_LOCATION pl,
    dbo.PM_STORE_TYPE pst,
    dbo.PM_SALES_MEMO_TYPE psmt,
    dbo.PM_COMPANY pcomp,
    dbo.PM_NATION pn ,
    dbo.PM_TERMINAL pterm,
    dbo.PR_POS_REPORT_SUP pprs
where
    psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
    and pl.LOCATION_ID = psm.LOCATION_ID_FK
    and psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
    and psmt.COMPANY_CODE = psm.COMPANY_CODE
    and psm.NATION_ID_FK = pn.NATION_ID
    and pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
    and pterm.terminal_id = psm.terminal_id_fk
    and psm.company_code = pcomp.company_code
    and pmiss.MEMO_ITEM_STAFF_SET_ID = psmih.MEMO_ITEM_STAFF_SET_ID_FK
    and psmih.IS_PLASTIC_BAG = 'N'
    and psm.TX_DT > pprs.mv_dt
UNION
select sales_memo_item_h_id,
    SALES_MEMO_ID ,
    TX_dt ,
    MEMO_NO ,
    VIP_NO ,
    a.CRE_BY ,
    DISP_LINE_NET_PRICE,
    DISP_LINE_NET_TOTAL ,
    QTY ,
    LINE_DISC_AMT ,
    DISP_LINE_DISCOUNT_RATE ,
    a.COMPANY_CODE ,
    pcomp.COMPANY_DESC,
    LOCATION_ID_FK ,
    LOCATION_CODE ,
    LOCATION_NAME ,
    CUR_RETAIL_PRICE ,
    a.CODE,
    TYPE_DESC,
    Store_type_name,
    location_desc,
    TERMINAL_NO,
    vip_cluster_id_fk,
    tx_time,
    AUTH_BY,
    TYPE_CODE ,
    MEMO_STATUS,
    MEMO_ITEM_STAFF_SET_ID,
    sku
from dbo.PMV_TRANSACTION_LINE_VIEW a, dbo.PM_COMPANY pcomp
WHERE a.company_code = pcomp.company_code
