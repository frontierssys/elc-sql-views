CREATE   VIEW [dbo].[PV_R0031_OVERVIEW] AS
SELECT
--need to add start
-- Store Division
-- Store Type
-- Store Location
-- Tender Type
-- Material Description
--need to add end
    pl.COMPANY_CODE as COMPANY_CODE,
    pst.STORE_TYPE_CODE as STORE_TYPE,
    pl.ADDRESS1 + pl.ADDRESS2 + pl.ADDRESS3 as STORE_LOCATION,
    pl.LOCATION_CODE,
    pl.LOCATION_NAME,
    pu.USER_CODE as CASHIER_ID,
    ps.FIRST_NAME + ' ' + ps.LAST_NAME as CASHIER_NAME,
    '' as BA_ID,
    '' as BA_NAME,
    psm.VIP_NO as CUSTOMER_ID,
    CAST (psm.TX_DT as date) as TX_DT,
    psm.MEMO_NO as TRANSACTION_NO,
    CAST (psm.TX_DT as time) as TRAN_TIME,
    pstbt.TENDERS as TENDER_TYPE,
    psd.PRODUCT_BRAND as BRAND,
    psd.PRODUCT_BRAND as SUB_BRAND,
    psd.SKU_10 ,
    psd.SKU_6 ,
    psd.SKU_4 ,
    psd.PRODUCT_NAME as MATERIAL_DESCRIPTION,
    psdh.PROM_DESC ,
    psdh.DISC_TYPE ,
    psmih.CUR_RETAIL_PRICE as SUGGESTED_RETAIL_PRICE,
    psmih.QTY ,
    psmih.CUR_RETAIL_PRICE * psmih.QTY as TOTAL_RETAIL_PRICE,
    psdh.DISCOUNT_RATE ,
    psdd.DISCOUNT_AMOUNT * psmih.QTY as DISCOUNT_AMOUNT,
    psmih.NET_LINE_AMT
FROM
    PT_SALES_DISCOUNT_H psdh
inner join PT_SALES_MEMO psm
    on psdh.SALES_MEMO_ID_FK = psm.SALES_MEMO_ID
inner join PT_SALES_DISCOUNT_D psdd
    on psdd.SALES_DISCOUNT_H_ID_FK = psdh.SALES_DISCOUNT_H_ID
inner join PM_LOCATION pl
    on pl.LOCATION_ID = psm.LOCATION_ID_FK
inner join PM_STORE_TYPE pst
    on pst.STORE_TYPE_ID = pl.STORE_TYPE_ID_FK
inner join PT_SALES_MEMO_ITEM_H psmih
    on psdd.SALES_MEMO_ITEM_H_ID_FK = psmih.SALES_MEMO_ITEM_H_ID
left join PV_SKU_DETAIL psd
    on psd.SKU_10 = psmih.SKU
    and psd.COMPANY_CODE = psmih.COMPANY_CODE
left join PM_USER pu
    on psm.CASHIER_CODE = pu.USER_CODE
    and psm.COMPANY_CODE = pu.COMPANY_CODE
left join PM_STAFF ps
    on ps.STAFF_ID = pu.STAFF_ID_FK
left join PV_SALES_TENDER_BY_TRANSACTION pstbt
    on psm.SALES_MEMO_ID = pstbt.SALES_MEMO_ID
