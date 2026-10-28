-- dbo.PV_SALES_TENDER_BY_TRANSACTION source
CREATE view [dbo].[BACKUP_PV_SALES_TENDER_BY_TRANSACTION_RMB_164_20250819]
AS
select
    psm.SALES_MEMO_ID as SALES_MEMO_ID,
    psm.POS_MEMO_NO as POS_MEMO_NO,
    stuff((
        SELECT DISTINCT ',' + pt.TENDER_NAME
        FROM PT_SALES_MEMO_PAYMENT psmp
        left join PM_TENDER pt
            on psmp.TENDER_ID_FK = pt.TENDER_ID
        WHERE psm.SALES_MEMO_ID = psmp.SALES_MEMO_ID_FK
        FOR XML PATH('')),1,1,'') as TENDERS
FROM PT_SALES_MEMO psm
--inner join PT_SALES_MEMO_PAYMENT psmp
--on psm.SALES_MEMO_ID = psmp.SALES_MEMO_ID_FK
--inner join PM_TENDER pt
--on psmp.TENDER_ID_FK = pt.TENDER_ID;
