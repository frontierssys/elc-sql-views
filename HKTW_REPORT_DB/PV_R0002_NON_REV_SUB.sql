CREATE VIEW [dbo].[PV_R0002_NON_REV_SUB] AS
SELECT
    psm.company_code as 'COMPANY_CODE',
    pl.location_code,
    psm.TX_DATE as 'TX_DATE',
    psmt.TYPE_CODE ,
    pgcc.GIFT_CARD_TYPE ,
    CASE
        WHEN psmt.TYPE_CODE = '03' THEN 'Deposit'
        WHEN psmt.TYPE_CODE = '04' THEN 'Deposit Refund'
        WHEN psmt.TYPE_CODE = '05' THEN pgcc.GIFT_CARD_TYPE + ' Issue'
        WHEN pia.IS_PLASTIC_BAG = 'Y' THEN 'Shopping Bag'
        WHEN psmih.IS_SALES_KIT_ITEM = 'Y' THEN 'Service Package'
        ELSE 'Others'
    END as NON_REVENUE_PRODUCT_TYPE,
    sum(psmih.CUR_RETAIL_PRICE * qty) as 'SALES_GROSS_AMT',
    sum(psmih.NET_LINE_AMT) as 'SALES_NET_AMT',
    sum(psmih.CUR_RETAIL_PRICE * qty - psmih.NET_LINE_AMT) as MARKDOWN,
    sum(psmih.QTY) as 'QTY',
    COUNT(DISTINCT psm.MEMO_NO) as 'MEMO_COUNT',
    pt.TERMINAL_NO,
    CASE
        WHEN psmt.TYPE_CODE in ('03', '04', '05') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.COMPANY_CODE IN ('AUCS', 'NZCS')
            AND psa.IH_L1 = '120' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y'
            AND psmih.IS_SALES_KIT_ITEM = 'N' THEN 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y'
            AND psmih.IS_SALES_KIT_ITEM = 'Y'
            AND psmih.qty < 0 THEN 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' THEN 'Y'
        ELSE 'N'
    END AS 'IS_REVENUE_ITEM'
    ----------------
    --------------
FROM
    dbo.PT_SALES_MEMO psm
    --------------------------------
INNER JOIN dbo.PT_SALES_MEMO_ITEM_H psmih on
    psm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
    --------------------------------
INNER JOIN dbo.PM_SALES_MEMO_TYPE psmt on
    psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
    ----------------------------------------
INNER JOIN dbo.PM_SKU ps on
    psmih.COMPANY_CODE = ps.COMPANY_CODE
    AND psmih.SKU = ps.SKU_CODE
INNER JOIN dbo.PM_SKU_ATTR psa
-------------------------------------------
    on
    ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
    -----
INNER JOIN dbo.PM_ITEM pi2 on
    ps.ITEM_ID_FK = pi2.ITEM_ID
INNER JOIN PM_ITEM_ATTR pia on
    pia.ITEM_ATTR_ID = pi2.ITEM_ATTR_ID_FK
    -----------------------------------------
INNER JOIN dbo.PM_COMPANY pc2 on
    pc2.COMPANY_CODE = psm.COMPANY_CODE
INNER JOIN dbo.PM_LOCATION pl on
    psm.LOCATION_ID_FK = pl.LOCATION_ID
INNER JOIN dbo.PM_STORE_TYPE pst on
    pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
INNER JOIN PM_TERMINAL pt on
    psm.TERMINAL_ID_FK = pt.TERMINAL_ID
LEFT JOIN PC_GIFT_CARD_CFG pgcc on
    pgcc.COMPANY_CODE = psm.COMPANY_CODE
    AND pgcc.SKU_CODE = psmih.SKU
INNER JOIN dbo.PR_POS_REPORT_SUP pprs on
    1 = 1
WHERE
    psmt.TYPE_CODE not in (
    --'05',
        '06',
        '07',
        '09',
        '10',
        '11',
        '99',
        '08')
    AND psm.MEMO_STATUS not in ('VOIDED')
    AND psm.MEMO_KIND not in ('RESERVE', 'hANDoff')
    --AND psm.MEMO_STATUS= 'COMPLETED'
    AND (
        pia.IS_PLASTIC_BAG = 'Y'
            OR psmt.TYPE_CODE in ('03', '04', '05')
            OR (( psa.IH_L1 = '110'
                    AND psmih.IS_SALES_KIT_ITEM = 'Y')
                    OR (psmih.IS_SERVICE_ITEM = 'N'
                            AND psa.IH_L1 <> '110'))
    )
    AND psmih.NET_LINE_AMT <> 0
    AND pst.STORE_TYPE_NAME <> 'ONLINE'
GROUP BY
    psm.company_code,
    pl.location_code,
    pt.TERMINAL_NO,
    psm.TX_DATE ,
    psmt.TYPE_CODE ,
    pgcc.GIFT_CARD_TYPE,
    CASE
        WHEN psmt.TYPE_CODE = '03' THEN 'Deposit'
        WHEN psmt.TYPE_CODE = '04' THEN 'Deposit Refund'
        WHEN psmt.TYPE_CODE = '05' THEN pgcc.GIFT_CARD_TYPE + ' Issue'
        WHEN pia.IS_PLASTIC_BAG = 'Y' THEN 'Shopping Bag'
        WHEN psmih.IS_SALES_KIT_ITEM = 'Y' THEN 'Service Package'
        ELSE 'Others'
    END,
    CASE
        WHEN psmt.TYPE_CODE in ('03', '04', '05') THEN 'N'
        WHEN psa.IH_L1 = '110' THEN 'Y'
        WHEN psmih.COMPANY_CODE IN ('AUCS', 'NZCS')
            AND psa.IH_L1 = '120' THEN 'Y'
        WHEN psmih.IS_SERVICE_ITEM = 'Y'
            AND psmih.IS_SALES_KIT_ITEM = 'N' THEN 'Y'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y'
            AND psmih.IS_SALES_KIT_ITEM = 'Y'
            AND psmih.qty < 0 THEN 'N'
        WHEN psmih.IS_REDEEM_SERVICE_ITEM = 'Y' THEN 'Y'
        ELSE 'N'
    END;
