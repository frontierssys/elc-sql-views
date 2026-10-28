create     VIEW [dbo].[PCV_SALES_STORE_PAYMENT]
--WITH SCHEMABINDING
AS
SELECT
    psm.company_code AS 'COMPANY_CODE',
    pl.location_code,
    psm.TX_DATE  AS 'TX_DATE',
    pt.TENDER_CODE ,
    pt.TENDER_NAME ,
    sum(psmp.AMOUNT ) as EXPECTED_TOTAL,
    COUNT_BIG(*) AS RECORD_COUNT
    --COUNT(DISTINCT psm.MEMO_NO) as 'MEMO_COUNT'
FROM dbo.PT_SALES_MEMO psm
INNER JOIN dbo.PM_SALES_MEMO_TYPE psmt ON
    psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
inner join dbo.PT_SALES_MEMO_PAYMENT psmp ON
    psmp.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join dbo.PM_TENDER pt on
    psmp.TENDER_ID_FK = pt.TENDER_ID
inner join dbo.PM_LOCATION pl on
    pl.LOCATION_ID = psm.LOCATION_ID_FK
INNER JOIN dbo.PM_STORE_TYPE pst ON
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
INNER JOIN (
    select max(prd.REPORT_DATE ) as MAX_DATE
    from dbo.PR_REPORT_DATES prd) a on
    psm.REPORT_DT > a.MAX_DATE
WHERE
    psmt.TYPE_CODE NOT IN (
        '06',
        '07',
        '09',
        '10',
        '11',
        '99',
        '08')
    AND psm.MEMO_STATUS NOT IN ('VOIDED')
    AND psm.MEMO_KIND NOT IN ('RESERVE',
        'handoff')
        --	AND psm.TX_DT < pprs.MV_DT
    AND pst.STORE_TYPE_NAME <> 'ONLINE'
    --	AND pia.IS_PLASTIC_BAG = 'N'
GROUP BY
    psm.company_code,
    pl.location_code,
    psm.TX_DATE ,
    pt.TENDER_CODE ,
    pt.TENDER_NAME
