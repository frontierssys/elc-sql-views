CREATE     view [dbo].[PV_R0023_TRANSFER] AS
select
-- REDO START
    'STORE TRANSFER' as INVENTORY_TYPE ,
    --CAST(DATEDIFF(MINUTE , itoh.OUT_DT , iti.IN_DATE) / 1440.0 as DECIMAL(8,2)) as STOCK_TRANSFER_DURATION_DAY,
    pstout .STORE_TYPE_CODE as STORE_TYPE_NAME,
    -- REDO END
    pc.COMPANY_CODE as COMPANY_CODE ,
    pc.COMPANY_DESC as COMPANY_DESC,
    itoh.OUT_NO as DOCUMENT_ID,
    itod.SKU_CODE as SKU_10,
    LEFT(itod.SKU_CODE, 6) as SKU_6,
    LEFT(itod.SKU_CODE, 4) as SKU_4,
    pi2.ITEM_DESC_1 as PRODUCT_NAME,
    pvu.VENDOR_UPC_CODE as UPC,
    pb.BRAND_DESC as SUB_BRAND,
    psd.MAJOR_CATEGORY + ' ' + psd.MAJOR_CATEGORY_DESC as MAJOR_CATEGORY,
    psd.MAJOR_CATEGORY as MAJOR_CATEGORY_CODE,
    psd.APPLICATION + ' ' + psd.APPLICATION_DESC as APPLICATION,
    psd.APPLICATION as APPLICATION_CODE,
    psd.CATEGORY +' ' + psd.CATEGORY_DESC as CATEGORY,
    psd.CATEGORY as CATEGORY_CODE,
    psd.SUB_CATEGORY + ' ' + psd.SUB_CATEGORY_DESC as SUB_CATEGORY,
    psd.SUB_CATEGORY as SUB_CATEGORY_CODE,
    concat(psa.IH_L1,psa.IH_L2,psa.IH_L3) as 'INVENTORY_HIER',
    itod.QTY as EXPECTED_QTY,
    itod.QTY * itod.ORI_RETAIL_PRICE  as EXPECTED_VALUE,
    iti.IN_QTY as RECEIVED_QTY,
    iti.IN_QTY * itod.ORI_RETAIL_PRICE as RECEIVED_VALUE,
    CASE
        WHEN iti.IN_QTY is null then 0
        else (iti.IN_QTY - itod.QTY )
    end as VARIANCE_QTY,
    CASE
        WHEN iti.IN_QTY is null then 0
        else (iti.IN_QTY - itod.QTY ) * itod.ORI_RETAIL_PRICE
    end as VARIANCE_VALUE,
    CASE
        WHEN itod.QTY = iti.IN_QTY then 'N'
        WHEN itod.QTY is null or iti.IN_QTY is null then null
        else 'Y'
    end as VARIANCE_PROMPT,
    itoh.OUT_LOCATION_CODE as SHIPPING_STORE_CODE ,
    plout.LOCATION_DESC as SHIPPING_STORE_NAME,
    plout.ADDRESS1 +' '+ plout.ADDRESS1 + ' ' + plout.ADDRESS1 as SHIPPING_STORE_LOCATION,
    pstout.STORE_TYPE_CODE as SHIPPING_STORE_TYPE,
    itoh.IN_LOCATION_CODE as RECEIVING_STORE_CODE ,
    plin.LOCATION_DESC as RECEIVING_STORE_NAME,
    plin.ADDRESS1 +' '+ plin.ADDRESS1 + ' ' + plin.ADDRESS1 as RECEIVING_STORE_LOCATION,
    pstin.STORE_TYPE_CODE as RECEIVING_STORE_TYPE,
    itoh.CRE_DATET as CREATE_DATE,
    CONVERT(varchar(10), itoh.CRE_DATET, 126) as TX_DT,
    itoh.OUT_DT as SHIPPING_DATE,
    ir.REASON_DESCRIPTION as REASON_CODE,
    iti.IN_DATE as RECEIVE_DATE,
    itrh.OVERALL_APPROVE_DT as APPROVAL_DATE,
    iti.UPDATE_BY as RECEIVER_ID,
    ps3.FIRST_NAME as RECEIVER_NAME,
    itod.ORI_RETAIL_PRICE as SUGGESTED_RETAIL_PRICE,
    'STORE TRANSFER' as ORDER_TYPE,
    --null as PO_REF_NO,
    --null as DELIVERY_NOTE_NO,
    CASE
        WHEN iti.STATUS is not null then 'CLOSED'
        else 'IN PROGRESS'
    end as STATUS,
    CAST(DATEDIFF(MINUTE , itoh.OUT_DT , iti.IN_DATE) / 1440.0 as DECIMAL(8,2)) as STOCK_TRANSFER_DURATION_DAY,
    CASE
        WHEN RIGHT(plin.COUNTRY_ID_FK,3)='MAC' THEN 'MO'
        WHEN RIGHT(plin.COUNTRY_ID_FK,3)='HKG' THEN 'HK'
        ELSE LEFT(plin.COMPANY_CODE,2)
    END as ENTITY,
    psa.DEFAULT_UOM_CODE as UOM
from IT_TRANSFER_OUT_H itoh
inner join PM_COMPANY pc
    on itoh.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION plout
    on itoh.OUT_LOCATION_CODE = plout.LOCATION_CODE
    and itoh.COMPANY_CODE = plout.COMPANY_CODE
inner join PM_STORE_TYPE pstout
    on plout.STORE_TYPE_ID_FK = pstout.STORE_TYPE_ID
inner join PM_LOCATION plin
    on itoh.COMPANY_CODE = plin.COMPANY_CODE
    and itoh.IN_LOCATION_CODE = plin.LOCATION_CODE
inner join PM_STORE_TYPE pstin
    on itoh.COMPANY_CODE = pstin.COMPANY_CODE
    and plin.STORE_TYPE_ID_FK = pstin.STORE_TYPE_ID
inner join IT_TRANSFER_OUT_D itod
    on itoh.TRANSFER_OUT_H_ID = itod.TRANSFER_OUT_H_ID_FK
LEFT join IM_REASON ir
    on ir.COMPANY_CODE = itoh.COMPANY_CODE
    and ir.SAP_REASON_CODE = itoh.REASON_CODE
inner join IT_TRANSFER_REQUEST_H itrh
    on itoh.TRANSFER_REQ_H_ID_FK = itrh.TRANSFER_REQ_H_ID
LEFT join PM_VENDOR_UPC pvu
    on pvu.SKU = itod.SKU_CODE
    and pvu.COMPANY_CODE = itod.COMPANY_CODE
inner join dbo.PM_SKU ps
    on itod.COMPANY_CODE = ps.COMPANY_CODE
    and itod.SKU_CODE = ps.SKU_CODE
left join dbo.PV_SKU_DETAIL psd
    on ps.SKU_ID = psd.SKU_ID
inner join dbo.PM_SKU_ATTR psa
-------------------------------------------
    on ps.SKU_ATTR_ID_FK = psa.SKU_ATTR_ID
    -----
inner join dbo.PM_ITEM pi2
    on ps.ITEM_ID_FK = pi2.ITEM_ID
    -----------------------------------------
inner join dbo.PM_CLASS pc3
    on pi2.CLASS_ID_FK = pc3.CLASS_ID
inner join dbo.PM_SUBCLASS ps2
    on pi2.SUBCLASS_ID_FK = ps2.SUBCLASS_ID
inner join dbo.PM_BRAND pb
    on pi2.BRAND_ID_FK = pb.BRAND_ID
inner join dbo.PM_BU pb2
    on pb2.COMPANY_CODE = pi2.COMPANY_CODE
    and pb2.BU_CODE = pi2.BUSINESS_UNIT_CODE
inner join dbo.PM_DEPT pd
    on pd.COMPANY_CODE = pi2.COMPANY_CODE
    and pd.DEPT_CODE = pi2.DEPT_CODE
    and pd.BU_ID_FK = pb2.BU_ID
LEFT join
    (
        select
            itih.COMPANY_CODE ,
            itih.TRANSFER_OUT_H_ID_FK ,
            itih.IN_NO as TRANSFER_NO,
            itih.IN_DT as IN_DATE,
            itih.STATUS ,
            itih.UPDATE_BY ,
            itih.CONFIRM_BY ,
            itid.SKU_CODE as SKU_10,
            itid.qty as IN_QTY
        from
            IT_TRANSFER_IN_H itih
        inner join IT_TRANSFER_IN_D itid
            on itih.TRANSFER_IN_H_ID = itid.TRANSFER_IN_H_ID_FK
        WHERE itih.STATUS = 'CONFIRM'
    ) iti
    on itoh.TRANSFER_OUT_H_ID = iti.TRANSFER_OUT_H_ID_FK
    and itod.SKU_CODE =iti.SKU_10
left join PM_USER pu
    on pu.COMPANY_CODE = iti.COMPANY_CODE
    and pu.USER_CODE = iti.UPDATE_BY
left join PM_STAFF ps3
    on pu.STAFF_ID_FK = ps3.STAFF_ID
WHERE itoh.STATUS = 'CONFIRM'
