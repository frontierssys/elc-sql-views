CREATE   VIEW  [dbo].[PV_R0024] AS
SELECT
    iarh.COMPANY_CODE ,
    pc.COMPANY_DESC ,
    pst.STORE_TYPE_CODE as STORE_TYPE,
    --pl.ADDRESS1 + ' ' + pl.ADDRESS2 + ' ' + pl.ADDRESS3 as STORE_LOCATION,
    pl.CITY_TXT as STORE_LOCATION,
    pl.LOCATION_CODE as STORE_ID,
    pl.LOCATION_NAME as STORE_NAME,
    CONVERT(varchar(10), iah.CRE_DATET , 126) as CREATED_DATE,
    CONVERT(varchar(10), iarh.RECEIVED_DATE, 126) as RECEIVED_DATE,
    iah.PO_NO ,
    iah.ASN_NO as ASN_ID,
    iard.PRODUCT_CODE as SKU_10,
    LEFT(iard.PRODUCT_CODE,6) as SKU_6,
    LEFT(iard.PRODUCT_CODE,4) as SKU_4,
    pi2.ITEM_DESC_1 as PRODUCT_NAME,
    iard.ORI_ASN_QTY as EXPECTED_QTY,
    iard.TOTAL_QTY as RECEIVED_QTY,
    iard.ORI_ASN_QTY - iard.TOTAL_QTY as VARIANCE
FROM IT_ASN_RECEIVED_H iarh
inner join IT_ASN_RECEIVED_D iard
    on iarh.ASN_RECEIVED_H_ID = iard .ASN_RECEIVED_H_ID_FK
inner join IT_ASN_H iah
    on iarh.ASN_H_ID_FK = iah.ASN_H_ID
inner join PM_COMPANY pc
    on iarh.COMPANY_CODE = pc.COMPANY_CODE
inner join PM_LOCATION pl
    on iarh.RECEIVE_LOCATION_CODE = pl.LOCATION_CODE
    and iarh.COMPANY_CODE = pl.COMPANY_CODE
inner join PM_STORE_TYPE pst
    on pl.STORE_TYPE_ID_FK = pst.STORE_TYPE_ID
inner join PM_SKU ps
    on iarh.COMPANY_CODE = ps.COMPANY_CODE
    and iard.SKU_CODE = ps.SKU_CODE
inner join PM_ITEM pi2
    on ps.ITEM_ID_FK = pi2.ITEM_ID
where iard.ORI_ASN_QTY<>iard.TOTAL_QTY
