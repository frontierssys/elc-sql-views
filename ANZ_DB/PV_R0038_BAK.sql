CREATE   VIEW PV_R0038_BAK
as
select
    psm.COMPANY_CODE ,
    pl.LOCATION_CODE as LOCATION_CODE,
    psm.COMPANY_CODE as DIVISION,
    CASE
        when psmih.IS_SERVICE_ITEM = 'Y' then 'Service Package'
        when psmt.TYPE_CODE = '03' THEN 'Deposit'
        ELSE 'Incorrect Data'
    END as ORDER_TYPE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    CASE
        when psmih.IS_SERVICE_ITEM = 'Y' then 'Service Package'
        when psmt.TYPE_CODE = '03' THEN 'Deposit'
        ELSE 'Incorrect Data'
    END as LIABILITY_TYPE,
    psm.MEMO_NO as LIABILITY_ID,
    CASE
        when psmih.IS_SERVICE_ITEM = 'Y' then psmih.SKU
        when psmt.TYPE_CODE = '03' THEN 'Deposit Order'
        ELSE 'Incorrect Data'
    END as LIABILITY_DESCRIPTION,
    psmt.TYPE_DESC as TRAN_TYPE,
    '' as STATUS,
    psm.MEMO_NO as TRANSACTION_NUMBER,
    CAST(psm.TX_DT as date) as TX_DATE,
    CAST(psm.TX_DT as time) as TRANSACTION_TIME,
    ps22.STAFF_CODE as BA_ID,
    ps22.FIRST_NAME + ' ' + ps22.LAST_NAME as BA_NAME,
    pv.VIP_NO as CUSTOMER_ID,
    pc.FIRSTNAME + ' ' + pc.SURNAME as CUSTOMER_NAME,
    psd.SKU_10 as SKU10,
    psd.SKU_6 as SKU6 ,
    psd.SKU_4 as SKU4 ,
    psd.PRODUCT_NAME as PRODUCT_DESCRIPTION,
    psmih.QTY as QUANTITY,
    psmih.NET_LINE_AMT as SALES_AMOUNT,
    0 as REMAINING_BALANCE,
    CAST (psm.TX_DT as date) as ORIGINAL_PURCHASE_DATE,
    0 as DAYS_SINCE_POURCHASE_DATE,
    CAST (psm.TX_DT as date) as EXPIRATION_DATE,
    'N' as EXPIRED
FROM
    PT_SALES_MEMO psm
inner join PT_SALES_MEMO_ITEM_H psmih on
    psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join PM_SALES_MEMO_TYPE psmt on
    psmt.SALES_MEMO_TYPE_ID = psm.SALES_MEMO_TYPE_ID_FK
inner join PM_LOCATION pl on
    pl.LOCATION_ID = psm.LOCATION_ID_FK
inner join PM_STORE_TYPE pst on
    pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
left join PM_VIP pv on
    pv.COMPANY_CODE = psm.COMPANY_CODE
    and pv.VIP_NO = psm.VIP_NO
left join PM_CUSTOMER pc on
    pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
LEFT join dbo.PT_MEMO_ITEM_STAFF_SET pmiss on
    psmih.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
LEFT join dbo.PT_SALES_MEMO_ITEM_STAFF psmis on
    psmis.MEMO_ITEM_STAFF_SET_ID_FK = pmiss.MEMO_ITEM_STAFF_SET_ID
LEFT join dbo.PM_STAFF ps22 on
    ps22.COMPANY_CODE = psmis.COMPANY_CODE
    and ps22.STAFF_CODE = psmis.STAFF_NO
left join PV_SKU_DETAIL psd on
    psd.COMPANY_CODE = psmih.COMPANY_CODE
    and psd.SKU_10 = psmih.SKU
WHERE
    psmih.IS_SERVICE_ITEM = 'Y'
    or psmt.TYPE_CODE = '03'
    --and psm.COMPANY_CODE = 'HKEL'
    --and psm.TX_DT >= '2021-01-01';






    -- dbo.PV_R0038_NEW source
