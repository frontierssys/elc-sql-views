-- dbo.PV_R0038_DEPOSIT_ORDER source

CREATE   VIEW dbo.PV_R0038_DEPOSIT_ORDER AS
WITH valid_memo AS (
    SELECT
        psm.SALES_MEMO_ID,
        psm.COMPANY_CODE,
        psm.MEMO_NO,
        psm.TX_DT,
        psm.VIP_NO,
        psm.CASHIER_CODE,
        psm.LOCATION_ID_FK,
        psm.SALES_MEMO_TYPE_ID_FK,
        psm.RESERVE_EXP_DT,
        psm.TOTAL_NET_AMT,
        psmt.TYPE_CODE
    FROM PT_SALES_MEMO psm
    INNER JOIN PM_SALES_MEMO_TYPE psmt
        ON psm.SALES_MEMO_TYPE_ID_FK = psmt.SALES_MEMO_TYPE_ID
    WHERE psm.MEMO_KIND = 'NORMAL'
        AND psm.MEMO_STATUS <> 'VOIDED'
        AND psmt.TYPE_CODE <> '09'
),
    orig_memo AS (
        SELECT
            vm.COMPANY_CODE,
            vm.MEMO_NO,
            psmid.ORIG_MEMO_NO,
            MIN(psmid.SALES_MEMO_ITEM_H_ID_FK) AS SALES_MEMO_ITEM_H_ID_FK
        FROM valid_memo vm
        JOIN PT_SALES_MEMO_ITEM_H psmih
            ON psmih.SALES_MEMO_ID_FK = vm.SALES_MEMO_ID
        JOIN PT_SALES_MEMO_ITEM_D psmid
            ON psmid.SALES_MEMO_ITEM_H_ID_FK = psmih.SALES_MEMO_ITEM_H_ID
        GROUP BY vm.COMPANY_CODE, vm.MEMO_NO, psmid.ORIG_MEMO_NO
    ),
    deposit_payments AS (
        SELECT psmp.*
        FROM PT_SALES_MEMO_PAYMENT psmp
        JOIN valid_memo vm
            ON vm.SALES_MEMO_ID = psmp.SALES_MEMO_ID_FK
    ),
    redeem_items AS (
    -- Item details belonging to valid memos that reference an original memo
        SELECT
            psmid.ORIG_MEMO_NO,
            psmid.SALES_MEMO_ITEM_H_ID_FK
        FROM PT_SALES_MEMO_ITEM_D psmid
        JOIN PT_SALES_MEMO_ITEM_H psmih
            ON psmih.SALES_MEMO_ITEM_H_ID = psmid.SALES_MEMO_ITEM_H_ID_FK
        JOIN valid_memo vm
            ON vm.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
        WHERE psmid.ORIG_MEMO_NO IS NOT NULL
    ),
    redeem_pairs AS (
        SELECT DISTINCT
            orig.COMPANY_CODE,
            orig.MEMO_NO AS ORIG_MEMO_NO,
            redeem.MEMO_NO AS REDEEM_MEMO_NO
        FROM PT_SALES_MEMO_ITEM_D psmid
        JOIN PT_SALES_MEMO_ITEM_H psmih
            ON psmih.SALES_MEMO_ITEM_H_ID = psmid.SALES_MEMO_ITEM_H_ID_FK
        JOIN valid_memo redeem
            ON redeem.SALES_MEMO_ID = psmih.SALES_MEMO_ID_FK
        JOIN valid_memo orig
            ON orig.MEMO_NO = psmid.ORIG_MEMO_NO
            AND orig.COMPANY_CODE = redeem.COMPANY_CODE
        WHERE psmid.ORIG_MEMO_NO IS NOT NULL
    )
SELECT
    psm.COMPANY_CODE,
    pl.LOCATION_CODE AS LOCATION_CODE,
    psm.COMPANY_CODE AS DIVISION,
    'Deposit' AS ORDER_TYPE,
    pst.STORE_TYPE_CODE AS STORE_TYPE_NAME,
    pl.CITY_TXT AS STORE_LOCATION,
    pl.LOCATION_CODE AS STORE_ID,
    pl.LOCATION_NAME AS STORE_NAME,
    'Deposit' AS LIABILITY_TYPE,
    COALESCE(a.ORIG_MEMO_NO, psm.MEMO_NO) AS LIABILITY_ID,
    'Deposit Order' AS LIABILITY_DESCRIPTION,
    psmt.TYPE_DESC AS TRAN_TYPE,
    CASE
        WHEN psmp.SALES_MEMO_PAYMENT_ID IS NULL
            AND psmid.SALES_MEMO_ITEM_H_ID_FK IS NULL
            AND psmt.TYPE_DESC = 'Deposit Issue'
        THEN 'OPEN'
        ELSE 'CLOSE'
    END AS STATUS,
    psm.MEMO_NO AS TRANSACTION_NUMBER,
    CAST(psm.TX_DT AS date) AS TX_DATE,
    CAST(psm.TX_DT AS time) AS TRANSACTION_TIME,
    ps22.STAFF_CODE AS BA_ID,
    ps22.FIRST_NAME + ' ' + ps22.LAST_NAME AS BA_NAME,
    pv.VIP_NO AS CUSTOMER_ID,
    pc.FIRSTNAME + ' ' + pc.SURNAME AS CUSTOMER_NAME,
    'NA' AS SKU10,
    'NA' AS SKU6,
    'NA' AS SKU4,
    'NA' AS PRODUCT_DESCRIPTION,
    0 AS QUANTITY,
    psm.TOTAL_NET_AMT AS SALES_AMOUNT,
    CASE
        WHEN psmid.SALES_MEMO_ITEM_H_ID_FK IS NOT NULL THEN 0
        ELSE psm.TOTAL_NET_AMT + ISNULL(psm2.TOTAL_NET_AMT, 0)
    END AS REMAINING_BALANCE,
    CAST(psm.TX_DT AS date) AS ORIGINAL_PURCHASE_DATE,
    DATEDIFF(day, CAST(psm.TX_DT AS date), GETDATE()) AS DAYS_SINCE_POURCHASE_DATE,
    psm.RESERVE_EXP_DT AS EXPIRATION_DATE,
    CASE
        WHEN DATEDIFF(day, GETDATE(), CAST(psm.RESERVE_EXP_DT AS date)) < 0 THEN 'Y'
        ELSE 'N'
    END AS EXPIRED
FROM valid_memo psm
INNER JOIN PM_SALES_MEMO_TYPE psmt
    ON psmt.SALES_MEMO_TYPE_ID = psm.SALES_MEMO_TYPE_ID_FK
INNER JOIN PM_LOCATION pl
    ON pl.LOCATION_ID = psm.LOCATION_ID_FK
INNER JOIN PM_STORE_TYPE pst
    ON pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
LEFT JOIN PM_VIP pv
    ON pv.COMPANY_CODE = psm.COMPANY_CODE
    AND pv.VIP_NO = psm.VIP_NO
LEFT JOIN PM_CUSTOMER pc
    ON pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
LEFT JOIN PM_STAFF ps22
    ON ps22.COMPANY_CODE = psm.COMPANY_CODE
    AND ps22.STAFF_CODE = psm.CASHIER_CODE
LEFT JOIN orig_memo a
    ON a.COMPANY_CODE = psm.COMPANY_CODE
    AND a.MEMO_NO = psm.MEMO_NO
LEFT JOIN valid_memo psm2
    ON psm2.COMPANY_CODE = a.COMPANY_CODE
    AND psm2.MEMO_NO = a.ORIG_MEMO_NO
LEFT JOIN deposit_payments psmp
    ON psmp.DEPOSIT_NO = psm.MEMO_NO
LEFT JOIN redeem_items psmid
    ON psmid.ORIG_MEMO_NO = psm.MEMO_NO
WHERE psmt.TYPE_CODE IN ('03', '04')

UNION

SELECT
    redeem.COMPANY_CODE,
    pl.LOCATION_CODE AS LOCATION_CODE,
    redeem.COMPANY_CODE AS DIVISION,
    'Deposit' AS ORDER_TYPE,
    pst.STORE_TYPE_CODE AS STORE_TYPE_NAME,
    pl.CITY_TXT AS STORE_LOCATION,
    pl.LOCATION_CODE AS STORE_ID,
    pl.LOCATION_NAME AS STORE_NAME,
    'Deposit' AS LIABILITY_TYPE,
    orig.MEMO_NO AS LIABILITY_ID,
    'Deposit Order' AS LIABILITY_DESCRIPTION,
    'Deposit PickUp' AS TRAN_TYPE,
    'CLOSE' AS STATUS,
    redeem.MEMO_NO AS TRANSACTION_NUMBER,
    CAST(redeem.TX_DT AS date) AS TX_DATE,
    CAST(redeem.TX_DT AS time) AS TRANSACTION_TIME,
    redeem.CASHIER_CODE AS BA_ID,
    ps22.FIRST_NAME + ' ' + ps22.LAST_NAME AS BA_NAME,
    pv.VIP_NO AS CUSTOMER_ID,
    pc.FIRSTNAME + ' ' + pc.SURNAME AS CUSTOMER_NAME,
    'NA' AS SKU10,
    'NA' AS SKU6,
    'NA' AS SKU4,
    'NA' AS PRODUCT_DESCRIPTION,
    0 AS QUANTITY,
    ISNULL(psmp.AMOUNT, 0) * -1 AS SALES_AMOUNT,
    0 AS REMAINING_BALANCE,
    CAST(orig.TX_DT AS date) AS ORIGINAL_PURCHASE_DATE,
    DATEDIFF(day, CAST(orig.TX_DT AS date), GETDATE()) AS DAYS_SINCE_POURCHASE_DATE,
    orig.RESERVE_EXP_DT AS EXPIRATION_DATE,
    CASE
        WHEN DATEDIFF(day, GETDATE(), CAST(orig.RESERVE_EXP_DT AS date)) < 0 THEN 'Y'
        ELSE 'N'
    END AS EXPIRED
FROM redeem_pairs a
JOIN valid_memo orig
    ON orig.COMPANY_CODE = a.COMPANY_CODE
    AND orig.MEMO_NO = a.ORIG_MEMO_NO
JOIN valid_memo redeem
    ON redeem.COMPANY_CODE = a.COMPANY_CODE
    AND redeem.MEMO_NO = a.REDEEM_MEMO_NO
JOIN PM_LOCATION pl
    ON pl.LOCATION_ID = redeem.LOCATION_ID_FK
JOIN PM_STORE_TYPE pst
    ON pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
LEFT JOIN PM_VIP pv
    ON pv.COMPANY_CODE = redeem.COMPANY_CODE
    AND pv.VIP_NO = redeem.VIP_NO
LEFT JOIN PM_CUSTOMER pc
    ON pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
LEFT JOIN PM_STAFF ps22
    ON ps22.COMPANY_CODE = redeem.COMPANY_CODE
    AND ps22.STAFF_CODE = redeem.CASHIER_CODE
LEFT JOIN deposit_payments psmp
    ON psmp.SALES_MEMO_ID_FK = redeem.SALES_MEMO_ID
LEFT JOIN PM_TENDER pt
    ON pt.TENDER_ID = psmp.TENDER_ID_FK
WHERE (pt.TENDER_CODE = '12' AND psmp.DEPOSIT_NO IS NOT NULL)
    OR (psmp.SALES_MEMO_PAYMENT_ID IS NULL AND orig.TYPE_CODE = '03');
