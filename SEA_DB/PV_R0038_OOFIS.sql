-- dbo.PV_R0038_OOFIS source

CREATE VIEW [dbo].[PV_R0038_OOFIS] AS
SELECT
    psm.COMPANY_CODE ,
    pl.LOCATION_CODE as LOCATION_CODE,
    psm.COMPANY_CODE as DIVISION,
    'OOFIS' as ORDER_TYPE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    'OOFIS' as LIABILITY_TYPE,
    psm.POS_MEMO_NO as LIABILITY_ID,
    'OOFIS Order' as LIABILITY_DESCRIPTION,
    --psmt.TYPE_DESC as TRAN_TYPE,
    CASE
        when psmoi.OOFIS_STATUS IN ('Returned','Shipped','Delivered','Cancelled') then 'OOFIS Order Original'
        else psmoi.OOFIS_STATUS
    END as TRAN_TYPE,
    case
        when psmoi.OOFIS_STATUS IN ('Returned','Shipped','Delivered','Cancelled') then 'CLOSE'
        else 'OPEN'
    end as STATUS,
    psm.MEMO_NO as TRANSACTION_NUMBER,
    CAST(psm.TX_DT as date) as TX_DATE,
    CAST(psm.TX_DT as time) as TRANSACTION_TIME,
    ps22.STAFF_CODE as BA_ID,
    ps22.FIRST_NAME + ' ' + ps22.LAST_NAME as BA_NAME,
    pv.VIP_NO as CUSTOMER_ID,
    pc.FIRSTNAME + ' ' + pc.SURNAME as CUSTOMER_NAME,
    'NA' as SKU10,
    'NA' as SKU6 ,
    'NA' as SKU4 ,
    'NA' as PRODUCT_DESCRIPTION,
    0 as QUANTITY,
    psm.TOTAL_NET_AMT as SALES_AMOUNT,
    CASE
        WHEN psmoi.OOFIS_STATUS IN ('Returned','Shipped','Delivered','Cancelled') then 0
        else psm.TOTAL_NET_AMT
    END  as REMAINING_BALANCE,
    CAST (psm.TX_DT as date) as ORIGINAL_PURCHASE_DATE,
    DATEDIFF(day,CAST (psm.TX_DT as date),GETDATE()) as DAYS_SINCE_POURCHASE_DATE,
    psm.RESERVE_EXP_DT as EXPIRATION_DATE,
    'N' as EXPIRED
FROM
    PT_SALES_MEMO_OOFIS_INFO psmoi
inner join	PT_SALES_MEMO psm on psmoi.SALES_MEMO_ID_FK =psm.SALES_MEMO_ID
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
LEFT join dbo.PM_STAFF ps22 on
    ps22.COMPANY_CODE = psm.COMPANY_CODE
    and ps22.STAFF_CODE = psm.CASHIER_CODE
WHERE psmt.TYPE_CODE in ('14') and (isnull(psm.MEMO_STATUS,0) <> 'VOIDED')
UNION ALL
select
    psm.COMPANY_CODE ,
    pl.LOCATION_CODE as LOCATION_CODE,
    psm.COMPANY_CODE as DIVISION,
    'OOFIS' as ORDER_TYPE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    'OOFIS' as LIABILITY_TYPE,
    psm.POS_MEMO_NO as LIABILITY_ID,
    'OOFIS Order' as LIABILITY_DESCRIPTION,
    psmoi.OOFIS_STATUS as TRAN_TYPE,
    case
        when psmoi.OOFIS_STATUS IN ('Returned','Shipped','Delivered','Cancelled') then 'CLOSE'
        else 'OPEN'
    end as STATUS,
    psm.MEMO_NO as TRANSACTION_NUMBER,
    --CAST(psm.TX_DT as date) as TX_DATE,
    --CAST(psm.TX_DT as time) as TRANSACTION_TIME,
    CAST(psmoi.UPDATE_DATET as date) as TX_DATE,
    CAST(psmoi.UPDATE_DATET as time) as TRANSACTION_TIME,
    ps22.STAFF_CODE as BA_ID,
    ps22.FIRST_NAME + ' ' + ps22.LAST_NAME as BA_NAME,
    pv.VIP_NO as CUSTOMER_ID,
    pc.FIRSTNAME + ' ' + pc.SURNAME as CUSTOMER_NAME,
    'NA' as SKU10,
    'NA' as SKU6 ,
    'NA' as SKU4 ,
    'NA' as PRODUCT_DESCRIPTION,
    0 as QUANTITY,
    psm.TOTAL_NET_AMT*-1  as SALES_AMOUNT,
    case
        when psmoi.OOFIS_STATUS IN ('Returned','Shipped','Delivered','Cancelled') then 0
        ELSE psm.TOTAL_NET_AMT
    END as REMAINING_BALANCE,
    CAST (psm.TX_DT as date) as ORIGINAL_PURCHASE_DATE,
    DATEDIFF(day,CAST (psm.TX_DT as date),GETDATE()) as DAYS_SINCE_POURCHASE_DATE,
    psm.RESERVE_EXP_DT as EXPIRATION_DATE,
    'N' as EXPIRED
FROM
    PT_SALES_MEMO_OOFIS_INFO psmoi
inner join	PT_SALES_MEMO psm on psmoi.SALES_MEMO_ID_FK =psm.SALES_MEMO_ID
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
LEFT join dbo.PM_STAFF ps22 on
    ps22.COMPANY_CODE = psm.COMPANY_CODE
    and ps22.STAFF_CODE = psm.CASHIER_CODE
WHERE psmt.TYPE_CODE in ('14') and (isnull(psm.MEMO_STATUS,0) <> 'VOIDED') and psmoi.OOFIS_STATUS IN ('Returned','Shipped','Delivered','Cancelled')
