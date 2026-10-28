CREATE   view [dbo].[PV_R0038_BAK]
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
    COALESCE(a.ORIG_MEMO_NO,psm.MEMO_NO) as LIABILITY_ID,
    'Deposit Order' as LIABILITY_DESCRIPTION,
    psmt.TYPE_DESC as TRAN_TYPE,
    case
        when psmp.SALES_MEMO_PAYMENT_ID is null and psmt.TYPE_DESC='Deposit Issue' then 'OPEN'
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
    psm.TOTAL_NET_AMT + isnull(psm2.TOTAL_NET_AMT,0) as REMAINING_BALANCE,
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
        --LEFT JOIN PT_SALES_MEMO_PAYMENT psmp on psm.SALES_MEMO_ID = psmp.SALES_MEMO_ID_FK
LEFT JOIN PT_SALES_MEMO psm2 ON psm2.MEMO_NO =a.ORIG_MEMO_NO
LEFT JOIN PT_SALES_MEMO_PAYMENT psmp on psm.MEMO_NO = psmp.DEPOSIT_NO
/*LEFT JOIN PT_SALES_MEMO psmpsmp on psmpsmp.SALES_MEMO_ID = psmp.SALES_MEMO_ID_FK
LEFT JOIN PM_SALES_MEMO_TYPE psmtpsmp on psmpsmp.SALES_MEMO_TYPE_ID_FK = psmtpsmp.SALES_MEMO_TYPE_ID */
WHERE psmt.TYPE_CODE in ('03' ,'04') --Added typecode 04
--AND psm.MEMO_STATUS = 'COMPLETED'  --Commented to include INCOMPLETE status
--AND (psmtpsmp.TYPE_CODE <> '09' and psmpsmp.MEMO_STATUS <> 'VOIDED')  --commented and cheked for null in below
    and (isnull(psmt.TYPE_CODE,0) <> '09' and isnull(psm.MEMO_STATUS,0) <> 'VOIDED')
    --and psm.MEMO_NO IN ('HKMC001202HQ21000016','HKMC001202HQ21000015')
    --and psm.COMPANY_CODE = 'HKEL'
    --and psm.TX_DT >= '2021-01-01'
union
select
    psm.COMPANY_CODE ,
    pl.LOCATION_CODE as LOCATION_CODE,
    psm.COMPANY_CODE as DIVISION,
    --'Store Credit Issue' as ORDER_TYPE,
    pt.tender_name as ORDER_TYPE,
    pst.STORE_TYPE_CODE as STORE_TYPE_NAME,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    --'Store Credit Issue' as LIABILITY_TYPE,
    'Store Credit' as LIABILITY_TYPE,
    --psm.MEMO_NO as LIABILITY_ID,
    psmpa.STORE_CREDIT_NO as LIABILITY_ID,
    'Store Credit' as LIABILITY_DESCRIPTION,
    pt.TENDER_NAME as TRAN_TYPE,
    --case when psmp.SALES_MEMO_PAYMENT_ID is null then 'OPEN' else 'CLOSE' end as STATUS,
    --CASE WHEN pt.tender_code ='106' then 'OPEN' else   'CLOSE' END as STATUS,
    CASE
        WHEN b.NET_BAL <>0 AND pt.TENDER_CODE ='106' then 'OPEN'
        else 'CLOSE'
    END as STATUS,--Check again
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
    -- SUM(psmp.AMOUNT) as SALES_AMOUNT, -- visa+store credit
    psmp.AMOUNT,
    SUM(a.REMAINING_BAL) as REMAINING_BALANCE,
    -- a.REMAINING_BAL,
    CAST (psm.TX_DT as date) as ORIGINAL_PURCHASE_DATE,
    DATEDIFF(day,CAST (psm.TX_DT as date),GETDATE()) as DAYS_SINCE_POURCHASE_DATE,
    GETDATE()+365 as EXPIRATION_DATE,
    CASE
        when DATEDIFF(day, GETDATE(), CAST(psm.RESERVE_EXP_DT as date)) < 0 then 'Y'
        ELSE 'N'
    END as EXPIRED
FROM
    PT_SALES_MEMO psm
INNER JOIN PM_SALES_MEMO_TYPE psmt on psmt.SALES_MEMO_TYPE_ID = psm.SALES_MEMO_TYPE_ID_FK
INNER JOIN PT_SALES_MEMO_PAYMENT psmp on psm.SALES_MEMO_ID = psmp.SALES_MEMO_ID_FK
INNER JOIN PM_TENDER pt on psmp.TENDER_ID_FK = pt.TENDER_ID
INNER JOIN PT_SALES_MEMO_PAYMENT_ATTR psmpa on psmpa.SALES_MEMO_PAYMENT_ATTR_ID = psmp.SALES_MEMO_PAYMENT_ATTR_ID_FK
INNER JOIN PM_LOCATION pl on pl.LOCATION_ID = psm.LOCATION_ID_FK
INNER JOIN PM_STORE_TYPE pst on pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
LEFT JOIN PM_VIP pv on pv.COMPANY_CODE = psm.COMPANY_CODE and pv.VIP_NO = psm.VIP_NO
LEFT JOIN PM_CUSTOMER pc on  pv.CUSTOMER_ID_FK = pc.CUSTOMER_ID
LEFT JOIN (
    select CARD_NO,MOVEMENT_DT,sum(MOVEMENT_AMT) as REMAINING_BAL
    from PL_GIFT_CARD_LOG pgcl
    group by CARD_NO, MOVEMENT_DT) a ON a.CARD_NO=psmpa.STORE_CREDIT_NO and a.MOVEMENT_DT<= psm.TX_DT
LEFT JOIN (
    select CARD_NO,sum(MOVEMENT_AMT) as NET_BAL
    from PL_GIFT_CARD_LOG pgcl
    group by CARD_NO) b ON b.CARD_NO=psmpa.STORE_CREDIT_NO
LEFT join dbo.PM_STAFF ps22 on ps22.COMPANY_CODE = psm.COMPANY_CODE and ps22.STAFF_CODE = psm.CASHIER_CODE
where  (isnull(psmt.TYPE_CODE,0) <> '09' and isnull(psm.MEMO_STATUS,0) <> 'VOIDED')
    and PT.TENDER_CODE IN ('105','106')
    --and  psm.MEMO_NO in ('HKBB0016010J21000314','HKBB0016010J21000316')
GROUP BY psm.COMPANY_CODE ,pl.LOCATION_CODE,pst.STORE_TYPE_CODE,pl.CITY_TXT,pl.LOCATION_CODE,
    pl.LOCATION_NAME,psm.MEMO_NO,pt.tender_name,psmp.SALES_MEMO_PAYMENT_ID,  psmpa.STORE_CREDIT_NO,pt.tender_code,psm.CASHIER_CODE,
    psm.MEMO_NO,psm.TX_DT,psm.TX_DT,ps22.STAFF_CODE,pv.VIP_NO,ps22.FIRST_NAME,ps22.LAST_NAME,psm.RESERVE_EXP_DT,psmp.AMOUNT,
    PC.SURNAME,PC.FIRSTNAME,b.NET_BAL
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
