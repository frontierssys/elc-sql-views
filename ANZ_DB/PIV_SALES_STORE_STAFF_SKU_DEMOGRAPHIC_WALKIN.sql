CREATE   VIEW  [dbo].[PIV_SALES_STORE_STAFF_SKU_DEMOGRAPHIC_WALKIN]
--WITH SCHEMABINDING
AS
SELECT
    psm.company_code AS 'COMPANY_CODE',
    pl.location_code,
    CONVERT(varchar(10), psm.TX_DT,126) AS 'TX_DATE',
    ps2.STAFF_CODE as STAFF_NO,
    psmih.SKU,
    pn.DEMOGRAPHIC AS 'DEMOGRAPHIC',
    CASE
        WHEN psmt.TYPE_CODE in ('03', '04') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END AS 'IS_REVENUE_ITEM',
    CASE
        When psmih.QTY > 0 then 'SALE'
        when psmt.TYPE_CODE in ('03', '04') THEN 'SALE'
        When psmih.IS_SALES_KIT_ITEM = 'Y' then 'SALE'
        else 'RETURN'
    end as 'SALE_OR_RETURN',
    sum(psmih.CUR_RETAIL_PRICE * qty) AS 'SALES_GROSS_AMT',
    sum(psmih.NET_LINE_AMT) AS 'SALES_NET_AMT',
    sum(psmih.QTY) AS 'QTY',
    COUNT_BIG(*) AS RECORD_COUNT
    --COUNT(DISTINCT psm.MEMO_NO) as 'MEMO_COUNT'
FROM dbo.PT_SALES_MEMO psm
INNER JOIN dbo.PT_SALES_MEMO_ITEM_H psmih ON
    psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
INNER JOIN dbo.PM_SALES_MEMO_TYPE psmt ON
    psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
INNER JOIN dbo.PM_SKU ps ON
    psmih.COMPANY_CODE = ps.COMPANY_CODE
    AND psmih.SKU = ps.SKU_CODE
INNER JOIN dbo.PM_ITEM pi2 ON
    pi2.ITEM_ID = ps.ITEM_ID_FK
INNER JOIN dbo.PM_ITEM_ATTR pia ON
    pia.ITEM_ATTR_ID = pi2.ITEM_ATTR_ID_FK
INNER JOIN dbo.PM_SKU_ATTR psa ON
    ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
INNER join dbo.PT_MEMO_ITEM_STAFF_SET pmiss on
    psmih.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
INNER join dbo.PT_SALES_MEMO_ITEM_STAFF psmis on
    psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
INNER join dbo.PM_STAFF ps2 on
    psmis.COMPANY_CODE = ps2.COMPANY_CODE
    and psmis.STAFF_NO = ps2.STAFF_CODE
    -----
INNER JOIN dbo.PM_COMPANY pc2 ON
    pc2.COMPANY_CODE = psm.COMPANY_CODE
INNER JOIN dbo.PM_LOCATION pl ON
    psm.LOCATION_ID_FK = pl.LOCATION_ID
INNER JOIN dbo.PM_STORE_TYPE pst ON
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join dbo.PM_NATION pn
    on psm.NATION_ID_FK = pn.NATION_ID
INNER JOIN dbo.PR_REPORT_DATES prd on
    psm.REPORT_DT = prd.REPORT_DATE
WHERE
    psmt.TYPE_CODE NOT IN (
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
    AND psm.VIP_NO IS NULL
    --	AND pia.IS_PLASTIC_BAG = 'N'
    --	and psm.TX_DT >= '2019-07-11'
    --	and psm.TX_DT < '2019-07-12'
    --	and psm.COMPANY_CODE = 'HKEL'
GROUP BY
    psm.company_code,
    pl.location_code,
    CONVERT(varchar(10),
        psm.TX_DT,
        126),
    ps2.STAFF_CODE ,
    psmih.SKU,
    pn.DEMOGRAPHIC,
    CASE
        WHEN psmt.TYPE_CODE in ('03', '04') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'N' then 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' and psmih.IS_SALES_KIT_ITEM = 'Y' and psmih.qty < 0  then 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' then 'Y'
        ELSE 'N'
    END,
    CASE
        When psmih.QTY > 0 then 'SALE'
        when psmt.TYPE_CODE in ('03', '04') THEN 'SALE'
        When psmih.IS_SALES_KIT_ITEM = 'Y' then 'SALE'
        else 'RETURN'
    end
