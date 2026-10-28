CREATE   VIEW PV_R0038_NEW
as
select
    psm.COMPANY_CODE ,
    pl.LOCATION_CODE as LOCATION_CODE,
    psm.COMPANY_CODE as DIVISION,
    'Service Package' as ORDER_TYPE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    'Service Package' as LIABILITY_TYPE,
    psm.MEMO_NO as LIABILITY_ID,
    psmih.SKU as LIABILITY_DESCRIPTION,
    psmt.TYPE_DESC as TRAN_TYPE,
    case
        when SUM(
            case
                when pvsi.SVC_ITEM_STATUS = 'PENDING' then pvsi.PRICE
                else 0
            end
        ) > 0 then 'OPEN'
        else 'CLOSE'
    end as STATUS,
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
    SUM(
        case
            when pvsi.SVC_ITEM_STATUS = 'PENDING' then pvsi.PRICE
            else 0
        end
    ) as REMAINING_BALANCE,
    CAST (psm.TX_DT as date) as ORIGINAL_PURCHASE_DATE,
    DATEDIFF(day,CAST (psm.TX_DT as date),GETDATE()) as DAYS_SINCE_POURCHASE_DATE,
    CAST (pvsih.EXPIRY_DT as date) as EXPIRATION_DATE,
    CASE
        when DATEDIFF(day, GETDATE(), CAST(pvsih.EXPIRY_DT as date)) < 0 then 'Y'
        ELSE 'N'
    END as EXPIRED
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
inner join PM_VIP_SVC_ITEM_H pvsih on psm.MEMO_NO = pvsih .SALES_MEMO_NO and psmih.SKU = pvsih.SKU_CODE
LEFT join PM_VIP_SVC_ITEM pvsi on pvsih.VIP_SVC_ITEM_H_ID = pvsi.VIP_SVC_ITEM_H_ID_FK
WHERE psmih.IS_SALES_KIT_ITEM = 'Y' and psm.MEMO_STATUS = 'COMPLETED' and psmt.TYPE_CODE <> '09'
--and psm.COMPANY_CODE = 'HKEL'
--and psm.TX_DT >= '2021-01-01'
group by psm.COMPANY_CODE, pl.LOCATION_CODE, pst.STORE_TYPE_CODE, pl.CITY_TXT, pl.LOCATION_CODE, pl.LOCATION_NAME,
    psm.MEMO_NO, psmih.SKU, psmt.TYPE_DESC, psm.TX_DT, ps22.STAFF_CODE, pc.FIRSTNAME, pc.SURNAME, ps22.FIRST_NAME, ps22.LAST_NAME, pv.VIP_NO,
    psd.SKU_10, psd.SKU_6, psd.SKU_4, psd.PRODUCT_NAME, psmih.QTY, psmih.NET_LINE_AMT, pvsih.EXPIRY_DT
union
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
    psm.MEMO_NO as LIABILITY_ID,
    'Deposit Order' as LIABILITY_DESCRIPTION,
    psmt.TYPE_DESC as TRAN_TYPE,
    case
        when psmp.SALES_MEMO_PAYMENT_ID is null then 'OPEN'
        else 'CLOSE'
    end as STATUS,
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
    psmp.AMOUNT - psmih.NET_LINE_AMT as REMAINING_BALANCE,
    CAST (psm.TX_DT as date) as ORIGINAL_PURCHASE_DATE,
    DATEDIFF(day,CAST (psm.TX_DT as date),GETDATE()) as DAYS_SINCE_POURCHASE_DATE,
    psm.RESERVE_EXP_DT as EXPIRATION_DATE,
    CASE
        when DATEDIFF(day, GETDATE(), CAST(psm.RESERVE_EXP_DT as date)) < 0 then 'Y'
        ELSE 'N'
    END as EXPIRED
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
LEFT JOIN PT_SALES_MEMO_PAYMENT psmp on psm.MEMO_NO = psmp.DEPOSIT_NO
LEFT JOIN PT_SALES_MEMO psmpsmp on psmpsmp.SALES_MEMO_ID = psmp.SALES_MEMO_ID_FK
LEFT JOIN PM_SALES_MEMO_TYPE psmtpsmp on psmpsmp.SALES_MEMO_TYPE_ID_FK = psmtpsmp.SALES_MEMO_TYPE_ID
WHERE psmt.TYPE_CODE = '03' AND psm.MEMO_STATUS = 'COMPLETED' AND (psmtpsmp.TYPE_CODE <> '09' and psmpsmp.MEMO_STATUS <> 'VOIDED')
--and psm.COMPANY_CODE = 'HKEL'
--and psm.TX_DT >= '2021-01-01';


-- dbo.PV_R0039 source
