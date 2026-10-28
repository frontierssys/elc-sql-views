-- dbo.PV_SALES_TENDER_BY_TRANSACTION source

-- dbo.PV_SALES_TENDER_BY_TRANSACTION source

CREATE VIEW PV_SALES_TENDER_BY_TRANSACTION
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
        FOR XML PATH('')), 1, 1, '') as TENDERS,
    trace_data.TRACE_NO
FROM
    dbo.PT_SALES_MEMO psm
OUTER APPLY (
    SELECT
        NULLIF(
            stuff((
                SELECT DISTINCT ',' + pt.CARD_NO
                FROM PT_SALES_MEMO_PAYMENT psmp
                LEFT JOIN PT_SALES_MEMO_PAYMENT_ATTR pt ON psmp.SALES_MEMO_PAYMENT_ATTR_ID_FK = pt.SALES_MEMO_PAYMENT_ATTR_ID
                LEFT JOIN PM_TENDER pmt ON psmp.TENDER_ID_FK = pmt.TENDER_ID
                WHERE psm.SALES_MEMO_ID = psmp.SALES_MEMO_ID_FK
                    AND pmt.TENDER_CODE = 164
                FOR XML PATH('')
            ), 1, 1, ''),
            '') AS TRACE_NO
) trace_data
--inner join PT_SALES_MEMO_PAYMENT psmp
--on psm.SALES_MEMO_ID = psmp.SALES_MEMO_ID_FK
--inner join PM_TENDER pt
--on psmp.TENDER_ID_FK = pt.TENDER_ID;



-- dbo.PMV_SALES_STORE_DEMOGRAPHIC_ALL source;
