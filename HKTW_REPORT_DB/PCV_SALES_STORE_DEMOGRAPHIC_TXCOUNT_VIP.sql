CREATE     VIEW [dbo].[PCV_SALES_STORE_DEMOGRAPHIC_TXCOUNT_VIP] AS
--WITH SCHEMABINDING AS
SELECT
    psm.company_code AS 'COMPANY_CODE',
    pl.location_code,
    psm.TX_DATE AS 'TX_DATE',
    --pn.DEMOGRAPHIC AS 'DEMOGRAPHIC',
    isnull(pn.DEMOGRAPHIC, 'TOURIST') AS 'DEMOGRAPHIC',
    CASE
        WHEN psm.TOTAL_NET_AMT >= 0 THEN 'SALE'
        ELSE 'RETURN'
    END AS SALE_OR_RETURN,
    CASE
    --WHEN psmt.TYPE_CODE in ('03', '04') THEN 'N'
        WHEN psmt.TYPE_CODE in ('03', '04','12','13','14') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END AS 'IS_REVENUE_ITEM',
    --COUNT_BIG(*) AS 'MEMO_COUNT'
    COUNT(DISTINCT psm.MEMO_NO) AS 'MEMO_COUNT'
FROM
    dbo.PT_SALES_MEMO psm
INNER JOIN dbo.PT_SALES_MEMO_ITEM_H psmih ON
    psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
INNER JOIN dbo.PM_SALES_MEMO_TYPE psmt ON
    psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
    -----
INNER JOIN dbo.PM_SKU ps ON
    psmih.COMPANY_CODE = ps.COMPANY_CODE
    AND psmih.SKU = ps.SKU_CODE
INNER JOIN dbo.PM_SKU_ATTR psa ON
    ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
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
LEFT JOIN dbo.PM_NATION pn ON
    pcs.COMPANY_CODE = pn.COMPANY_CODE
    AND pcs.COUNTRY_RESIDENCE = pn.ISO3_CODE
INNER JOIN (
    select min(prd.REPORT_DATE) as REPORT_DATE
    from PR_REPORT_DATES prd) a on
    psm.REPORT_DT > a.REPORT_DATE
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
        --	AND psm.TX_DT >= pprs.MV_DT
    AND pst.STORE_TYPE_NAME <> 'ONLINE'
    AND psm.VIP_NO IS NOT NULL
    --AND psm.TOTAL_NET_AMT <> 0
GROUP BY
    psm.company_code,
    pl.location_code,
    psm.TX_DATE ,
    --pn.DEMOGRAPHIC,
    isnull(pn.DEMOGRAPHIC, 'TOURIST'),
    CASE
        WHEN psm.TOTAL_NET_AMT >= 0 THEN 'SALE'
        ELSE 'RETURN'
    END,
    CASE
    --WHEN psmt.TYPE_CODE in ('03', '04') THEN 'N'
        WHEN psmt.TYPE_CODE in ('03', '04','12','13','14') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END
