CREATE   VIEW [dbo].[PV_R0022_ASN_BAK] as
select
    'ASN' as INVENTORY_TYPE ,
    --CAST(DATEDIFF(MINUTE , itoh.OUT_DT , iti.IN_DATE) / 1440.0 as DECIMAL(8,2)) as STOCK_TRANSFER_DURATION_DAY,
    pstin.STORE_TYPE_CODE as STORE_TYPE_NAME,
    -- REDO END
    pc.COMPANY_CODE as COMPANY_CODE ,
    pc.COMPANY_DESC as COMPANY_DESC,
    --itoh.OUT_NO as TRANSFER_NO,
    iarh.ASN_RECEIVED_NO as DOCUMENT_ID,
    --psd.SKU_10 as SKU_10,
    iard.TARGET_BALANCE ,
    iard.SKU_CODE as SKU_10,
    Left(iard.SKU_CODE,6) as SKU_6,
    Left(iard.SKU_CODE,4) as SKU_4,
    --psd.SKU_6 as SKU_6,
    --psd.SKU_4 as SKU_4,
    psd.PRODUCT_NAME as PRODUCT_NAME,
    psd.UPC as UPC,
    psd.PRODUCT_BRAND as SUB_BRAND,
    psd.MAJOR_CATEGORY + ' ' + psd.MAJOR_CATEGORY_DESC as MAJOR_CATEGORY,
    psd.MAJOR_CATEGORY as MAJOR_CATEGORY_CODE,
    psd.APPLICATION + ' ' + psd.APPLICATION_DESC as APPLICATION,
    psd.APPLICATION as APPLICATION_CODE,
    psd.CATEGORY +' ' + psd.CATEGORY_DESC as CATEGORY,
    psd.CATEGORY as CATEGORY_CODE,
    psd.SUB_CATEGORY + ' ' + psd.SUB_CATEGORY_DESC as SUB_CATEGORY,
    psd.SUB_CATEGORY as SUB_CATEGORY_CODE,
    psd.INVENTORY_HIER as 'INVENTORY_HIER',
    iard.ORI_ASN_QTY as EXPECTED_QTY,
    iard.ORI_ASN_QTY * psd.RETAIL_PRICE  as EXPECTED_VALUE,
    iard.TOTAL_QTY as RECEIVED_QTY,
    iard.TOTAL_QTY * psd.RETAIL_PRICE as RECEIVED_VALUE,
    iard.TOTAL_QTY - iard.ORI_ASN_QTY as VARIANCE_QTY,
    (iard.TOTAL_QTY - iard.ORI_ASN_QTY) * psd.RETAIL_PRICE as VARIANCE_VALUE,
    CASE
        WHEN iard.TOTAL_QTY = iard.ORI_ASN_QTY then 'N'
        WHEN iard.ORI_ASN_QTY is null or iard.ORI_ASN_QTY is null then null
        else 'Y'
    end as VARIANCE_PROMPT,
    'Warehouse' as SHIPPING_STORE_CODE ,
    'Warehouse' as SHIPPING_STORE_NAME,
    '' as SHIPPING_STORE_LOCATION,
    '' as SHIPPING_STORE_TYPE,
    iarh.RECEIVE_LOCATION_CODE as RECEIVING_STORE_CODE ,
    plin.LOCATION_DESC as RECEIVING_STORE_NAME,
    plin.ADDRESS1 +' '+ plin.ADDRESS1 + ' ' + plin.ADDRESS1 as RECEIVING_STORE_LOCATION,
    pstin.STORE_TYPE_CODE as RECEIVING_STORE_TYPE,
    --iah.CRE_DATET as CREATE_DATE,
    FORMAT(iah.CRE_DATET,'yyyy-MM-dd hh:mm:ss') as CREATE_DATE,
    CONVERT(varchar(10), iah.CRE_DATET, 126) as TX_DT,
    null as SHIPPING_DATE,
    iard.TARGET_BALANCE as REASON_CODE,
    --iarh.RECEIVED_DATE as RECEIVE_DATE,
    FORMAT(iarh.RECEIVED_DATE,'yyyy-MM-dd hh:mm:ss') as RECEIVE_DATE,
    null as APPROVAL_DATE,
    --iarh.UPDATE_BY as RECEIVER_ID,
    COALESCE (iarh.UPDATE_BY ,iarh.CRE_BY) as RECEIVER_ID,
    --ps.FIRST_NAME as RECEIVER_NAME,
    CASE
        when iarh.UPDATE_BY is null then ps2.FIRST_NAME +' '+ left(ps2.LAST_NAME,1) + '.'
        else ps.FIRST_NAME +' '+ left(ps.LAST_NAME,1)
    end as RECEIVER_NAME,
    psd.RETAIL_PRICE as SUGGESTED_RETAIL_PRICE,
    'ASN RECEIVE' as ORDER_TYPE,
    iah.PO_NO as PO_REF_NO,   -----------------
    iah.DELIVERY_NO as DELIVERY_NOTE_NO,
    CASE
        when iarh.STATUS = 'CONFIRM' then 'CLOSED'
        else 'IN PROGRESS'
    end as STATUS,
    null as STOCK_TRANSFER_DURATION_DAY
from IT_ASN_RECEIVED_H iarh
inner join PM_COMPANY pc
    on iarh.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION plin
    on iarh.COMPANY_CODE = plin.COMPANY_CODE
    and iarh.RECEIVE_LOCATION_CODE = plin.LOCATION_CODE
inner join PM_STORE_TYPE pstin
    on plin.COMPANY_CODE = pstin.COMPANY_CODE
    and plin.STORE_TYPE_ID_FK = pstin.STORE_TYPE_ID
inner join IT_ASN_RECEIVED_D iard
    on iard.ASN_RECEIVED_H_ID_FK = iarh.ASN_RECEIVED_H_ID
inner join IT_ASN_H iah
    on iarh.ASN_H_ID_FK = iah.ASN_H_ID
left join PM_USER pu
    on pu.USER_CODE = iarh.UPDATE_BY
    and pu.COMPANY_CODE = iarh.COMPANY_CODE
left join PM_STAFF ps
    on ps.STAFF_ID = pu.STAFF_ID_FK
left join PM_USER pu2
    on pu2.USER_CODE = iarh.CRE_BY
    and pu2.COMPANY_CODE = iarh.COMPANY_CODE
left join PM_STAFF ps2
    on ps2.STAFF_ID = pu2.STAFF_ID_FK
left join PV_SKU_DETAIL psd
    on iard.SKU_CODE = psd.SKU_10
    and iard.COMPANY_CODE = psd.COMPANY_CODE
where iarh.STATUS = 'CONFIRM'
-- and plin.LOCATION_CODE = 'HKBB0003'
-- order by iarh.ASN_RECEIVED_NO;
