CREATE      VIEW [dbo].[PIV_SALES_STORE_CASHIER_SKU_DEMOGRAPHIC_TX_COUNT_VIP]
--WITH SCHEMABINDING
AS
SELECT
    psm.company_code AS 'COMPANY_CODE',
    pl.location_code,
    CONVERT(varchar(10),
        psm.TX_DT,
        126) AS 'TX_DATE',
    psm.CASHIER_CODE as 'STAFF_NO',
    psmih.SKU ,
    pn.DEMOGRAPHIC AS 'DEMOGRAPHIC',
    CASE
        WHEN psm.TOTAL_NET_AMT > 0 THEN 'SALE'
        ELSE 'RETURN'
    END AS SALE_OR_RETURN,
    psm.SALES_MEMO_ID ,
    sum(psmih.NET_LINE_AMT ) as TX_AMOUNT,
    sum(psmih.QTY ) as 'ITEM_COUNT',
    COUNT_BIG(*) AS 'RECORD_COUNT'
FROM
    dbo.PT_SALES_MEMO psm
INNER JOIN dbo.PT_SALES_MEMO_ITEM_H psmih ON
    psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
INNER JOIN dbo.PM_SALES_MEMO_TYPE psmt ON
    psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
    ------------------------------------------
INNER JOIN dbo.PM_COMPANY pc2 ON
    pc2.COMPANY_CODE = psm.COMPANY_CODE
INNER JOIN dbo.PM_LOCATION pl ON
    psm.LOCATION_ID_FK = pl.LOCATION_ID
INNER JOIN dbo.PM_STORE_TYPE pst ON
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
INNER JOIN dbo.PM_VIP pv ON
    psm.VIP_NO = pv.VIP_NO
    AND psm.COMPANY_CODE = pv.COMPANY_CODE
INNER JOIN dbo.PM_CUSTOMER pc ON
    pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
INNER JOIN dbo.PM_CUSTOMER_SECRET pcs ON
    pc.CUSTOMER_ID = pcs.CUSTOMER_ID_FK
INNER JOIN dbo.PM_NATION pn ON
    pcs.COMPANY_CODE = pn.COMPANY_CODE
    AND pcs.COUNTRY_RESIDENCE = pn.ISO3_CODE
INNER JOIN dbo.PR_REPORT_DATES prd on
    psm.REPORT_DT = prd.REPORT_DATE
WHERE
    psmt.TYPE_CODE NOT IN ('03',
        '04',
        '05',
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
    AND psm.VIP_NO IS NOT NULL
    AND psm.TOTAL_NET_AMT <> 0
    AND psmih.CUR_RETAIL_PRICE <> 0
    --	and psm.TX_DT >= '2019-07-11'
    --	and psm.TX_DT < '2019-07-12'
    --	and psm.COMPANY_CODE = 'HKEL'
GROUP BY
    psm.company_code,
    pl.location_code,
    CONVERT(varchar(10),
        psm.TX_DT,
        126),
    pn.DEMOGRAPHIC,
    psm.CASHIER_CODE ,
    psmih.SKU ,
    CASE
        WHEN psm.TOTAL_NET_AMT > 0 THEN 'SALE'
        ELSE 'RETURN'
    END ,
    psm.SALES_MEMO_ID
