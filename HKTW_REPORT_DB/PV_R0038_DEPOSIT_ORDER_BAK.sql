CREATE   VIEW [dbo].[PV_R0038_DEPOSIT_ORDER] AS
select
    psm.COMPANY_CODE ,
    pl.LOCATION_CODE as LOCATION_CODE,
    psm.COMPANY_CODE as DIVISION,
    'Deposit' as ORDER_TYPE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    'Deposit' as LIABILITY_TYPE,
    COALESCE(a.ORIG_MEMO_NO,psm.MEMO_NO) as LIABILITY_ID,
    'Deposit Order' as LIABILITY_DESCRIPTION,
    psmt.TYPE_DESC as TRAN_TYPE,
    case
        when psmp.SALES_MEMO_PAYMENT_ID is null AND psmid.SALES_MEMO_ITEM_H_ID_FK is null and psmt.TYPE_DESC='Deposit Issue' then 'OPEN'
        else 'CLOSE'
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
    --psmp.AMOUNT as REMAINING_BALANCE,
    CASE
        WHEN psmid.SALES_MEMO_ITEM_H_ID_FK is not null then 0
        ELSE psm.TOTAL_NET_AMT + isnull(psm2.TOTAL_NET_AMT,0)
    END as REMAINING_BALANCE,
    CAST (psm.TX_DT as date) as ORIGINAL_PURCHASE_DATE,
    DATEDIFF(day,CAST (psm.TX_DT as date),GETDATE()) as DAYS_SINCE_POURCHASE_DATE,
    psm.RESERVE_EXP_DT as EXPIRATION_DATE,
    CASE
        when DATEDIFF(day, GETDATE(), CAST(psm.RESERVE_EXP_DT as date)) < 0 then 'Y'
        ELSE 'N'
    END as EXPIRED
FROM
    PT_SALES_MEMO psm
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
LEFT JOIN (
    select distinct psm.MEMO_NO , psmid.ORIG_MEMO_NO
    from PT_SALES_MEMO psm
    inner join PT_SALES_MEMO_ITEM_H psmih on
        psmih.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
    inner join PT_SALES_MEMO_ITEM_D psmid on
        psmid.SALES_MEMO_ITEM_H_ID_FK = psmih.SALES_MEMO_ITEM_H_ID ) a ON a.MEMO_NO=psm.MEMO_NO
LEFT JOIN PT_SALES_MEMO psm2 ON psm2.MEMO_NO =a.ORIG_MEMO_NO
LEFT JOIN PT_SALES_MEMO_PAYMENT psmp on psm.MEMO_NO = psmp.DEPOSIT_NO
LEFT JOIN PT_SALES_MEMO_ITEM_D psmid ON psmid.ORIG_MEMO_NO =psm.MEMO_NO
WHERE psmt.TYPE_CODE in ('03' ,'04') --Added typecode 04
    and (isnull(psmt.TYPE_CODE,0) <> '09' and isnull(psm.MEMO_STATUS,0) <> 'VOIDED')
    --and psm.MEMO_NO IN ('HKMC001202HQ21000016','HKMC001202HQ21000015')
    --and psm.COMPANY_CODE = 'HKEL'
    --and psm.TX_DT >= '2021-01-01'
UNION
SELECT psm.COMPANY_CODE ,
    pl.LOCATION_CODE as LOCATION_CODE,
    psm.COMPANY_CODE as DIVISION,
    'Deposit' as ORDER_TYPE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    'Deposit' as LIABILITY_TYPE,
    psmp.DEPOSIT_NO as LIABILITY_ID,
    'Deposit Order' as LIABILITY_DESCRIPTION,
    'Deposit PickUp' as TRAN_TYPE,
    'CLOSE' as STATUS,
    psm.MEMO_NO as TRANSACTION_NUMBER,
    CAST(psm.TX_DT as date) as TX_DATE,
    CAST(psm.TX_DT as time) as TRANSACTION_TIME,
    psm.CASHIER_CODE as BA_ID,
    ps22.FIRST_NAME + ' ' + ps22.LAST_NAME as BA_NAME,
    pv.VIP_NO as CUSTOMER_ID,
    pc.FIRSTNAME + ' ' + pc.SURNAME as CUSTOMER_NAME,
    'NA' as SKU10,
    'NA' as SKU6 ,
    'NA' as SKU4 ,
    'NA' as PRODUCT_DESCRIPTION,
    0 as QUANTITY,
    psmp.AMOUNT*-1 as SALES_AMOUNT,
    0 as REMAINING_BALANCE,
    CAST (psm2.TX_DT as date) as ORIGINAL_PURCHASE_DATE,
    DATEDIFF(day,CAST (psm2.TX_DT as date),GETDATE()) as DAYS_SINCE_POURCHASE_DATE,
    psm2.RESERVE_EXP_DT as EXPIRATION_DATE,
    CASE
        when DATEDIFF(day, GETDATE(), CAST(psm2.RESERVE_EXP_DT as date)) < 0 then 'Y'
        ELSE 'N'
    END as EXPIRED
from PT_SALES_MEMO_PAYMENT psmp
inner join PM_TENDER pt
    on psmp.TENDER_ID_FK = pt.TENDER_ID
inner join PT_SALES_MEMO psm
    on psmp.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join PT_SALES_MEMO_PAYMENT_ATTR psmpa
    on psmpa.SALES_MEMO_PAYMENT_ATTR_ID = psmp.SALES_MEMO_PAYMENT_ATTR_ID_FK
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
LEFT JOIN PT_SALES_MEMO psm2
    ON psm2.MEMO_NO =psmp.DEPOSIT_NO
where pt.TENDER_CODE = '12' and psmp.DEPOSIT_NO is not null
